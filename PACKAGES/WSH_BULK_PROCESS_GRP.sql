--------------------------------------------------------
--  DDL for Package WSH_BULK_PROCESS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BULK_PROCESS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHBPGPS.pls 120.0.12000000.1 2007/01/16 05:42:18 appldev ship $ */


--===================
-- PUBLIC VARS
--===================



--========================================================================
-- PROCEDURE : Create_update_delivery_details
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_commit                FND_API.G_TRUE to perform a commit
--	       p_action_prms           Additional attributes needed
--	       x_Out_Rec               Place holder
--	       p_line_rec              Line record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This API is called from ONT to import delivery details and
--              delivery_assignments
--              At this time only insert operation (action='CREATE') is
--              supported for OM lines.
--========================================================================
  PROCEDURE Create_update_delivery_details(
                  p_api_version_number IN   NUMBER,
                  p_init_msg_list          IN   VARCHAR2,
                  p_commit         IN   VARCHAR2,
                  p_action_prms      IN
                              WSH_BULK_TYPES_GRP.action_parameters_rectype,
                  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
                  x_Out_Rec               OUT NOCOPY
                                WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type,
                  x_return_status          OUT  NOCOPY VARCHAR2,
                  x_msg_count              OUT  NOCOPY NUMBER,
                  x_msg_data               OUT  NOCOPY VARCHAR2
  );

END WSH_bulk_process_grp;

 

/
