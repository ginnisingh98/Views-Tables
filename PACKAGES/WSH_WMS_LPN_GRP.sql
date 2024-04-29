--------------------------------------------------------
--  DDL for Package WSH_WMS_LPN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WMS_LPN_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHWLGPS.pls 120.1.12010000.1 2008/07/29 06:21:02 appldev ship $ */

   g_call_group_api       VARCHAR2(2) := 'Y';
   g_update_to_container  VARCHAR2(2) := 'N';
   g_update_to_containers  VARCHAR2(2) := 'N';
   G_CALLBACK_REQUIRED   VARCHAR2(2) := 'Y';
   g_caller               VARCHAR2(100);
   g_hw_time_stamp             DATE;
   g_prev_hw_time_stamp        DATE;

   GK_WMS_PACK CONSTANT BOOLEAN := TRUE;
   GK_INV_PACK CONSTANT BOOLEAN := FALSE;
   GK_WMS_UNPACK CONSTANT BOOLEAN := TRUE;
   GK_INV_UNPACK CONSTANT BOOLEAN := FALSE;
   GK_WMS_ASSIGN_DLVY CONSTANT BOOLEAN := FALSE;
   GK_INV_ASSIGN_DLVY CONSTANT BOOLEAN := FALSE;
   GK_WMS_UNASSIGN_DLVY CONSTANT BOOLEAN := FALSE;
   GK_INV_UNASSIGN_DLVY CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_KEY CONSTANT BOOLEAN := TRUE;
   GK_INV_UPD_KEY CONSTANT BOOLEAN := TRUE;
   GK_WMS_UPD_WV CONSTANT BOOLEAN := TRUE;
   GK_INV_UPD_WV CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_FILL CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_FILL CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_MISC  CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_MISC  CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_PACK CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_PACK CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_ITEM CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_ITEM CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_FLEX CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_FLEX CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_GRP CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_GRP CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_INB_GRP CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_INB_GRP CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_STS CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_STS CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_DATE CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_DATE CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_INV_CTRL CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_INV_CTRL CONSTANT BOOLEAN := FALSE;
   GK_WMS_UPD_QTY     CONSTANT BOOLEAN := FALSE;
   GK_INV_UPD_QTY     CONSTANT BOOLEAN := FALSE;

--========================================================================
-- PROCEDURE : create_update_containers  Must be called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller,
--                                     and action_code ( CREATE,UPDATE,
--                                     UPDATE_NULL)
--         p_detail_info_tab           Table of attributes for the containers
--           x_OUT_rec                 not used (bms)
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================

  PROCEDURE create_update_containers
  ( p_api_version            IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2,
    p_detail_info_tab        IN  OUT NOCOPY
                        WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type,
    p_IN_rec                 IN     WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
    x_OUT_rec                OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
  );


--========================================================================
-- PROCEDURE : Delivery_Detail_Action  Must be called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_lpn_id_tbl            PLSQL table of LPN Ids for perform
--                                     any of the actions 'PACK', 'UNPACK'
--                                     'ASSIGN', 'UNASSIGN'.
--             p_del_det_id_tbl        PLSQL table of non-container delivery
--                                     lines to perform the same actions as above
--             p_action_prms           Contains actions related parameters
--                                     like action_code that can take any of the
--                                     four values mentioned above.
--                                     caller should be something like 'WMS%'
--                                     lpn_rec must be populated for actions
--                                     'PACK' or 'UNPACK'
--            x_defaults               not used currenlty.
--            x_action_out_rec         not used currenlty.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Performs any of the four actions as mentioned above i.e. 'PACK', 'UNPACK'
--             or 'ASSIGN', 'UNASSIGN'.
--========================================================================

  PROCEDURE Delivery_Detail_Action
  (
    p_api_version_number        IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_lpn_id_tbl                IN         wsh_util_core.id_tab_type,
    p_del_det_id_tbl            IN         wsh_util_core.id_tab_type,
    p_action_prms               IN         WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
    x_defaults                  OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type,
    x_action_out_rec            OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
  );

--========================================================================
-- PROCEDURE : Check_purge             Called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            x_action_out_rec         not used currenlty.
-- COMMENT   : Validates if the container records identified by
--             p_lpn_rec.lpn_ids, are purgable.  It populates the same table
--             with eligible records.
--========================================================================

  PROCEDURE Check_purge
  (
      p_api_version_number      IN      NUMBER,
      p_init_msg_list           IN      VARCHAR2,
      p_commit                  IN      VARCHAR2,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      P_lpn_rec                 IN  OUT NOCOPY
                                   WSH_GLBL_VAR_STRCT_GRP.purgeInOutRecType
  );

--========================================================================
-- PROCEDURE : is_valid_consol
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_input_delivery_id_tab     Table of delivery records to process
--
--             p_target_consol_delivery_id Table of delivery ids to process
--             x_deconsolidation_location  deconsolidation location
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is to find if a set of deliveries can be assigned to a consol delivery.
--             This procedure is called from WMS.
--
--========================================================================

PROCEDURE is_valid_consol(  p_init_msg_list             IN  VARCHAR2 DEFAULT fnd_api.g_false,
                            p_input_delivery_id_tab     IN  WSH_UTIL_CORE.id_tab_type,
                            p_target_consol_delivery_id IN  NUMBER,
                            p_caller                    IN  VARCHAR2 DEFAULT NULL,
                            x_deconsolidation_location  OUT NOCOPY NUMBER,
                            x_return_status             OUT  NOCOPY VARCHAR2,
                            x_msg_count                 OUT  NOCOPY NUMBER,
                            x_msg_data                  OUT  NOCOPY VARCHAR2
                          );




END WSH_WMS_LPN_GRP;

/
