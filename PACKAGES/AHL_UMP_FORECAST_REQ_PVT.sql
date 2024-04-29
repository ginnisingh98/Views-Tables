--------------------------------------------------------
--  DDL for Package AHL_UMP_FORECAST_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_FORECAST_REQ_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVURQS.pls 120.0.12010000.2 2008/12/27 00:44:26 sracha ship $ */

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_Mrl_Req_Forecast
--  Type              : Private
--  Function          : Private API to collect the material requirements for unit effectivities of a given set
--                      of item instances.
--                      Insert these material requirements into AHL_SCHEDULE_MATERIALS for ASCP/DP to pick up
--                      and plan the forecasted material requirements.
--                      If a unit effectivity does not have due date, the material forecast is not done.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Route_Mtl_Req Parameters:
--      P_applicable_instances_tbl      IN     AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type  Required
--                                             The table of records containing list of item instances for which the due
--                                             date calculation process is being performed.
--
--  Version :
--      Initial Version   1.0
--  Create By : Sunil Kumar
--  End of Comments.

PROCEDURE Process_Mrl_Req_Forecast
(
   p_api_version                IN            NUMBER,
   p_init_msg_list              IN            VARCHAR2  := FND_API.G_FALSE,
   p_commit                     IN             VARCHAR2  := FND_API.G_FALSE,
   p_validation_level           IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT  NOCOPY   VARCHAR2,
   x_msg_count                  OUT  NOCOPY   NUMBER,
   x_msg_data                   OUT  NOCOPY   VARCHAR2,
   P_applicable_instances_tbl   IN
   AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type
);


-- Called from concurrent program. This will create/update the material
-- forecast stream.
PROCEDURE Build_Mat_Forecast_Stream (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_unit_config_hdr_id    IN          NUMBER,
    p_item_instance_id      IN          NUMBER
);


End AHL_UMP_FORECAST_REQ_PVT;

/
