--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_GRP" AUTHID CURRENT_USER as
/* $Header: WSHINGPS.pls 120.1 2005/06/15 18:08:13 appldev  $ */

--===================
-- PUBLIC VARS
--===================

-- SSN change
-- Constants for Stop Sequence Mode
  G_STOP_SEQ_MODE_SSN NUMBER := 1;
  G_STOP_SEQ_MODE_PAD NUMBER := 2;

--========================================================================
-- PROCEDURE : Delivery_Action         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id/p_rec_attr.name.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_action_prms            IN   WSH_DELIVERIES_GRP.action_parameters_rectype,
    p_delivery_id_tab        IN   wsh_util_core.id_tab_type,
    x_delivery_out_rec       OUT  NOCOPY WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);
--========================================================================

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--========================================================================
-- PROCEDURE : Create_Update_Delivery  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--  	       x_del_out_rec           Record of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_in_rec                 IN   WSH_DELIVERIES_GRP.Del_In_Rec_Type,
    p_rec_attr_tab	     IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT  NOCOPY WSH_DELIVERIES_GRP.Del_Out_Tbl_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);
--========================================================================

-- I Harmonization: rvishnuv ******* Create/Update ******


    -- ---------------------------------------------------------------------
    -- Procedure:	Delivery_Detail_Action	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the wrapper(overloaded) version for the
    --               main delivery_detail_group API. This is for use by public APIs
    --		 and by other product APIs. This signature does not have
    --               the form(UI) specific parameters
    -- Created :  Patchset I : Harmonziation Project
    -- Created by: KVENKATE
    -- -----------------------------------------------------------------------
    PROCEDURE Delivery_Detail_Action
    (
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN 	    VARCHAR2,
       p_commit                    IN 	    VARCHAR2,
       x_return_status             OUT 	NOCOPY    VARCHAR2,
       x_msg_count                 OUT 	NOCOPY    NUMBER,
       x_msg_data                  OUT 	NOCOPY    VARCHAR2,

    -- Procedure specific Parameters
       p_detail_id_tab             IN	    WSH_UTIL_CORE.id_tab_type,
       p_action_prms               IN	    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
       x_action_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
    );


    -- ---------------------------------------------------------------------
    -- Procedure:	Create_Update_Delivery_Detail	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created    : Patchset I - Harmonization Project
    -- Created By : KVENKATE
    -- -----------------------------------------------------------------------

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number	 IN	 NUMBER,
       p_init_msg_list           IN 	 VARCHAR2,
       p_commit                  IN 	 VARCHAR2,
       x_return_status           OUT NOCOPY	 VARCHAR2,
       x_msg_count               OUT NOCOPY 	 NUMBER,
       x_msg_data                OUT NOCOPY	 VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN 	WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type,
       p_IN_rec                  IN  	WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY	WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
    );



  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_TRIPS_GRP.action_parameters_rectype,
    x_trip_out_rec           OUT  NOCOPY WSH_TRIPS_GRP.tripActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);

  PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_TRIP_STOPS_GRP.action_parameters_rectype,
    x_stop_out_rec           OUT  NOCOPY WSH_TRIP_STOPS_GRP.stopActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);

--heali
PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2,
        p_commit                IN  VARCHAR2,
        p_in_rec                IN  WSH_TRIP_STOPS_GRP.stopInRecType,
        p_rec_attr_tab          IN  WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_TRIP_STOPS_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE Create_Update_Trip(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_trip_info_tab          IN     WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
        p_In_rec                 IN     WSH_TRIPS_GRP.tripInRecType,
        x_Out_Tab                OUT    NOCOPY WSH_TRIPS_GRP.trip_Out_Tab_Type);

PROCEDURE Create_Update_Freight_Costs(
	p_api_version_number     IN     NUMBER,
	p_init_msg_list          IN     VARCHAR2,
	p_commit                 IN     VARCHAR2,
	x_return_status          OUT    NOCOPY VARCHAR2,
	x_msg_count              OUT    NOCOPY NUMBER,
	x_msg_data               OUT    NOCOPY VARCHAR2,
	p_freight_info_tab       IN     WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type,
	p_in_rec                 IN     WSH_FREIGHT_COSTS_GRP.freightInRecType,
	x_out_tab                OUT    NOCOPY WSH_FREIGHT_COSTS_GRP.freight_out_tab_type);
--heali

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

END WSH_INTERFACE_GRP;

 

/
