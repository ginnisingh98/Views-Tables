--------------------------------------------------------
--  DDL for Package AHL_UC_UNITCONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_UNITCONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUCXS.pls 115.10 2003/08/22 21:47:53 jeli noship $ */

-- Start of Comments  --
-- Define Procedure create_uc_header
-- This API is used to create a UC header record in ahl_unit_config_headers
--
-- Procedure name  : create_uc_header
-- Type        	: Private
-- Function    	: To update a UC header record in ahl_unit_config_headers.
-- Pre-reqs    	:
--
-- create_uc_header parameters :
-- p_x_uc_header_rec   IN OUT ahl_uc_instance_pvt.uc_header_rec_type  Required
--                     Record of UC header attributes including the newly created
--                     UC header ID
-- Version:    	Initial Version   1.0
--
-- End of Comments  --
PROCEDURE create_uc_header(
  p_api_version           IN  NUMBER    := 1.0,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_module_type           IN  VARCHAR2  := NULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_x_uc_header_rec       IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type);

-- Start of Comments  --
-- Define Procedure update_uc_header
-- This API is used to update a UC header name or some attributes of the top node
-- instance of the UC.
--
-- Procedure name  : update_uc_header
-- Type        	: Private
-- Function    	: To update a UC header record name and some attributes
--                of the top node instance.
-- Pre-reqs    	:
--
-- update_uc_header parameters :
-- p_uc_header_rec     IN uc_header_rec_type  Required
--                     Record of UC header attributes
-- p_uc_instance_rec   IN uc_instance_rec_type Required
--                     Record of UC instance attributes
-- Version : Initial Version   1.0
--
-- End of Comments  --

PROCEDURE update_uc_header(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_uc_header_rec    IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type,
  p_uc_instance_rec    IN  ahl_uc_instance_pvt.uc_instance_rec_type);

-- Start of Comments  --
-- Define Procedure delete_uc_header
-- This API is used to delete a UC header record from ahl_unit_config_headers
--
-- Procedure name  : delete_uc_header
-- Type        	: Private
-- Function    	: To logically delete a UC header record from ahl_unit_config_headers.
-- Pre-reqs    	:
--
-- delete_uc_header parameters :
-- p_uc_header_id          IN NUMBER The UC header to be expired
-- p_object_version_number IN NUMBER Object version number of the UC header
-- p_csi_instance_ovn      IN NUMBER Object version number of the CSI instance
--
-- Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE delete_uc_header (
  p_api_version           IN  NUMBER    := 1.0,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_object_version_number IN  NUMBER,
  p_csi_instance_ovn      IN  NUMBER);

END AHL_UC_UNITCONFIG_PVT; -- Package spec

 

/
