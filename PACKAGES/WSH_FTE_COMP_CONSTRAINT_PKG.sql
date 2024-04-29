--------------------------------------------------------
--  DDL for Package WSH_FTE_COMP_CONSTRAINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FTE_COMP_CONSTRAINT_PKG" AUTHID CURRENT_USER as
/* $Header: WSHFTCCS.pls 120.0 2005/05/26 17:44:16 appldev noship $ */

-- Global Variables

g_session_id		NUMBER;


/* Utility Data structures */

  TYPE failed_line_rec_type IS RECORD (
       failed_line_index                        NUMBER
     , entity_line_id                           NUMBER
     );

  TYPE failed_line_tab_type IS TABLE OF failed_line_rec_type INDEX BY BINARY_INTEGER;

  TYPE line_group_rec_type IS RECORD (
       line_group_index                         NUMBER
     , entity_line_id                           NUMBER
     , line_group_id                            NUMBER --  Id to suggest which lines can be grouped together
     );

  TYPE line_group_tab_type IS TABLE OF line_group_rec_type INDEX BY BINARY_INTEGER;

  TYPE cc_group_rec_type IS RECORD (
       group_index                              NUMBER
     , line_group_id                            NUMBER --  Id to suggest which lines can be grouped together
     , upd_dlvy_intmed_ship_to                  VARCHAR2(1)  --  NULL means YES
     , upd_dlvy_ship_method                     VARCHAR2(1)
     );

  TYPE cc_group_tab_type IS TABLE OF cc_group_rec_type INDEX BY BINARY_INTEGER;

  --#DUM_LOC(S)
  TYPE valid_const_cache IS RECORD (
       valid_const_present	BOOLEAN
     , cache_date		DATE
     );

  /*TYPE  deconsol_output_rec_type IS RECORD (
	          deconsol_location NUMBER,
	          entity_id NUMBER,
	          validation_status VARCHAR2(1));

  TYPE deconsol_output_tab_type IS TABLE OF deconsol_output_rec_type INDEX BY BINARY_INTEGER;*/

  g_valid_const_cache		valid_const_cache;
   --#DUM_LOC(E)


-- Wrapper for calling validate_constraint_dlvy with approp. parameters populated for diff. actions
-- For compatibility constraints project
--auto pack, auto pack master do not have any constraints which are implemented in I so they will not be used as of now
-- p_entity_type 'D' for del, 'L' for line, 'T' for trip, 'S' for stop based on this pass p_del_attr_tab or p_det_attr_tab or p_trip_attr_tab or p_stop_attr_tab or just pass p_in_ids
-- p_target_id id of container/delivery/trip based on action
-- p_in_ids use this only for calling in cases where p_rec_attr_tab is not available

PROCEDURE validate_constraint_main
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_entity_type	     IN	  VARCHAR2,
    p_target_id		     IN   NUMBER,
    p_action_code            IN   VARCHAR2,
    p_del_attr_tab	     IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type ,
    p_det_attr_tab	     IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
    p_trip_attr_tab	     IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
    p_stop_attr_tab	     IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    p_in_ids		     IN   wsh_util_core.id_tab_type,
    p_pickup_stop_id         IN   NUMBER DEFAULT NULL,
    p_pickup_loc_id          IN   NUMBER DEFAULT NULL,
    p_pickup_stop_seq        IN   NUMBER DEFAULT NULL,
    p_dropoff_stop_id        IN   NUMBER DEFAULT NULL,
    p_dropoff_loc_id         IN   NUMBER DEFAULT NULL,
    p_dropoff_stop_seq       IN   NUMBER DEFAULT NULL,
    p_pickup_arr_date        IN   DATE DEFAULT NULL,
    p_pickup_dep_date        IN   DATE DEFAULT NULL,
    p_dropoff_arr_date       IN   DATE DEFAULT NULL,
    p_dropoff_dep_date       IN   DATE DEFAULT NULL,
    x_validate_result        OUT  NOCOPY VARCHAR2,
    x_failed_lines           OUT  NOCOPY failed_line_tab_type,
    x_line_groups            OUT  NOCOPY line_group_tab_type,
    x_group_info             OUT  NOCOPY cc_group_tab_type,
    x_fail_ids	     	     OUT  NOCOPY wsh_util_core.id_tab_type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
  );

PROCEDURE validate_constraint_dleg(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2,
             p_delivery_leg_id          IN      NUMBER DEFAULT NULL,
             p_delivery_id              IN      NUMBER,
             p_sequence_num             IN      NUMBER DEFAULT NULL,
             p_location1_id             IN      NUMBER DEFAULT NULL,
             p_location2_id             IN      NUMBER DEFAULT NULL,
             p_stop1_id                 IN      NUMBER DEFAULT NULL,
             p_stop2_id                 IN      NUMBER DEFAULT NULL,
             p_date_1                   IN      DATE DEFAULT NULL,
             p_date_2                   IN      DATE DEFAULT NULL,
             p_target_trip_id           IN      NUMBER DEFAULT NULL, -- For DST
             p_carrier_id               IN      NUMBER DEFAULT NULL, -- Following 3 for DCE
             p_mode_code                IN      VARCHAR2 DEFAULT NULL,
             p_service_level            IN      VARCHAR2 DEFAULT NULL,
             x_validate_result          OUT NOCOPY    VARCHAR2, --  Constraint Validation result : S / F
             x_msg_count                OUT NOCOPY    NUMBER,      -- Standard FND functionality
             x_msg_data                 OUT NOCOPY    VARCHAR2,  -- Will return message text only if number of messages = 1
             x_return_status            OUT NOCOPY    VARCHAR2);


END WSH_FTE_COMP_CONSTRAINT_PKG;


 

/
