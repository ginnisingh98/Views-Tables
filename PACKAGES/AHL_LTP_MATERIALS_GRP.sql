--------------------------------------------------------
--  DDL for Package AHL_LTP_MATERIALS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_MATERIALS_GRP" AUTHID CURRENT_USER AS
/* $Header: AHLGMTLS.pls 120.0.12010000.1 2010/02/25 06:45:23 skpathak noship $ */
/*
 * This Group package spec provides the apis which will be invoked from the PS
 * basically for updating material requirement date and serial reservation dates
 * with WO scheduled start date
 */

G_PKG_NAME      CONSTANT        VARCHAR2(30)    := 'AHL_LTP_MATERIALS_GRP';


----------------------------------------
-- Start of Comments --
--  Procedure name    : Update_mtl_resv_dates
--  Type              : Public
--  Function          : Update material requirement date and serial
--                      reservation dates with WO scheduled start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Update_mtl_resv_dates Parameters:
--      p_wip_entity_id                 IN      NUMBER       Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_mtl_resv_dates
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
   p_commit                IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_wip_entity_id         IN            NUMBER
);


END AHL_LTP_MATERIALS_GRP;

/
