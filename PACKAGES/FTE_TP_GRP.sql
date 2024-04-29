--------------------------------------------------------
--  DDL for Package FTE_TP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TP_GRP" AUTHID CURRENT_USER as
/* $Header: FTETPGPS.pls 115.2 2003/09/05 19:36:26 wrudge noship $ */

--
--  Procedure:          lookup_cm_info
--  Parameters:
--               p_trip_id             trip_id to look up its continuous move segment
--               x_cm_info_rec         attributes of continuous move and segment
--               x_return_status       return status
--
--  Description:
--               Looks up continuous move information associated with the trip
--               to be displayed in shipping UIs.
--
--

PROCEDURE lookup_cm_info (
        p_trip_id              IN            NUMBER,
        x_cm_info_rec          OUT    NOCOPY WSH_FTE_TP_INTEGRATION.cm_info_rec_type,
        x_return_status        OUT    NOCOPY VARCHAR2);



--
--  Procedure:          trip_callback
--  Parameters:
--               p_api_version_number  known api version (1.0)
--               p_init_msg_list       FND_API.G_TRUE to reset list
--               x_return_status       return status
--               x_msg_count           number of messages in the list
--               x_msg_data            text of messages
--               p_actions_prms        action parameters record
--                                          used to identify the action triggering
--                                          the callback to FTE.
--               p_rec_attr_tab        table of trip records to process
--
--  Description:
--               take care of continuous moves based on the action being
--               performed on the trips.
--

PROCEDURE trip_callback (
    p_api_version_number     IN             NUMBER,
    p_init_msg_list          IN             VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    p_action_prms            IN             WSH_TRIPS_GRP.action_parameters_rectype,
    p_rec_attr_tab           IN             WSH_TRIPS_PVT.Trip_Attr_Tbl_Type);




--
--  Procedure:          stop_callback
--  Parameters:
--               p_api_version_number  known api version (1.0)
--               p_init_msg_list       FND_API.G_TRUE to reset list
--               x_return_status       return status
--               x_msg_count           number of messages in the list
--               x_msg_data            text of messages
--               p_actions_prms        action parameters record
--                                          used to identify the action triggering
--                                          the callback to FTE.
--               p_rec_attr_tab        table of stop records to process
--
--  Description:
--               take care of continuous moves based on the action being performed
--               on the stops.
--

PROCEDURE stop_callback (
    p_api_version_number     IN             NUMBER,
    p_init_msg_list          IN             VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    p_action_prms            IN             WSH_TRIP_STOPS_GRP.action_parameters_rectype,
    p_rec_attr_tab           IN             WSH_TRIP_STOPS_PVT.stop_attr_tbl_type);



--
--  Procedure:          map_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Part of TP release process
--               Maps the plan's continuous moves: generate and lock candidates
--               x_obsoleted_trip_moves will have the obsoleted move segments.
--

PROCEDURE map_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );


--
--  Procedure:          reconciliate_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Part of TP release process
--               Create or update continous moves and their segments and firm them as needed.
--               x_obsoleted_trip_moves will have the obsoleted move segments.
--

PROCEDURE reconciliate_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_trips               IN OUT NOCOPY WSH_TP_RELEASE_INT.plan_trip_tab_type,
           x_plan_trip_moves          IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_trip_move_tab_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_obsoleted_trip_moves     IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.obsoleted_trip_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );



--
--  Procedure:          tp_firm_moves
--  Parameters:
--               x_context             context in this session
--               x_plan_trips          list of trips mapped to interface trips
--               x_plan_trip_moves     list of continuous move segments
--               x_plan_moves          list of continuous moves
--               x_obsoleted_trip_moves list of continous move segments that need to be deleted
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Part of TP release process
--               Upgrade continuous moves' PLANNED_FLAG based on the plan
--

PROCEDURE tp_firm_moves(
           x_context                  IN OUT NOCOPY WSH_TP_RELEASE_INT.context_rec_type,
           x_plan_moves               IN OUT NOCOPY WSH_FTE_TP_INTEGRATION.plan_move_tab_type,
           x_errors_tab               IN OUT NOCOPY WSH_TP_RELEASE_INT.interface_errors_tab_type,
           x_return_status               OUT NOCOPY VARCHAR2
          );



--
--  Procedure:          purge_interface_tables
--  Parameters:
--               p_group_ids           list of group_ids to purge
--                                     FTE interface tables (based on WSH_TRIPS_INTERFACE.GROUP_ID)
--               x_return_status       return status
--
--  Description:
--               Part of TP release process
--               Delete the records from FTE interface tables:
--                   FTE_MOVES_INTERFACE
--                   FTE_TRIP_MOVES_INTERFACE
--
PROCEDURE purge_interface_tables(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.ID_TAB_TYPE,
  x_return_status          OUT NOCOPY    VARCHAR2);




END FTE_TP_GRP;

 

/
