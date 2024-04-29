--------------------------------------------------------
--  DDL for Package CZ_CONFIG_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_CONFIG_API_PUB" AUTHID CURRENT_USER AS
/*      $Header: czcfgaps.pls 120.0 2005/05/25 05:26:35 appldev noship $  */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'cz_config_api_pub';

--------------------------------------------------------------------------------------
-- API name    :  copy_configuration
-- Package Name:  CZ_CONFIG_API_PUB
-- Type        :  Public
-- Pre-reqs    :  None
-- Function    :  Creates new configuration by copying the input configuration specified by
--                p_config_hdr_id and p_config_rev_nbr
-- Version     :  Current version 1.0
--                Initial version 1.0
-- Note        :  1. new config_item_id generated only if copy_mode is CZ_API_PUB.G_NEW_HEADER_COPY_MODE
--                   and baseline_rev_nbr is null
--                2. caller is responsible for initializtion of the message list and commit

PROCEDURE copy_configuration(p_api_version          IN  NUMBER
                            ,p_config_hdr_id        IN  NUMBER
                            ,p_config_rev_nbr       IN  NUMBER
                            ,p_copy_mode            IN  VARCHAR2
                            ,x_config_hdr_id        OUT NOCOPY  NUMBER
                            ,x_config_rev_nbr       OUT NOCOPY  NUMBER
                            ,x_orig_item_id_tbl     OUT NOCOPY  CZ_API_PUB.number_tbl_type
                            ,x_new_item_id_tbl      OUT NOCOPY  CZ_API_PUB.number_tbl_type
                            ,x_return_status        OUT NOCOPY  VARCHAR2
                            ,x_msg_count            OUT NOCOPY  NUMBER
                            ,x_msg_data             OUT NOCOPY  VARCHAR2
                            ,p_handle_deleted_flag  IN  VARCHAR2 := NULL
                            ,p_new_name             IN  VARCHAR2 := NULL
                            );

-- Parameters:
--         IN:  p_api_version (required), standard pl/sql api in parameter
--              p_config_hdr_id (required), header id of source config to be copied
--              p_config_rev_nbr (required), revision of source config to be copied
--              p_copy_mode (required), flag to specify whether creating a config having
--                  new header id or new revision, has one of the following values.
--                              CZ_API_PUB.G_NEW_HEADER_COPY_MODE
--                              CZ_API_PUB.G_NEW_REVISION_COPY_MODE
--              p_handle_deleted_flag (optional), flag to indicate if handle deleted_flag
--              p_new_name (optional), name of the output config

--        OUT:  x_config_hdr_id, new config_hdr_id of the new config
--              x_config_rev_nbr, config_rev_nbr of the new config
--              x_orig_item_id_tbl, table of config_item_ids from the source config
--              x_new_item_id_tbl, table of config_item_ids from the new config
--              x_return_status, standard OUT NOCOPY parameter (FND_API.G_RET_STS_SUCCESS,
--                FND_API.G_RET_STS_ERROR, or FND_API.G_RET_STS_UNEXP_ERROR)
--              x_msg_count, standard OUT NOCOPY parameter
--              x_msg_data, standard OUT NOCOPY parameter

-- Validation:
--   p_config_hdr_id/p_config_rev_nbr: config exists in cz schema and is a network container
--        config or a non-network config, i.e, component_instance_type is 'R'
--   p_copy_mode: must be either of the following values
--                    CZ_API_PUB.G_NEW_HEADER_COPY_MODE
--                    CZ_API_PUB.G_NEW_REVISION_COPY_MODE


-- API name    :  copy_configuration_auto
-- Package Name:  CZ_CONFIG_API_PUB
-- Type        :  Public
-- Pre-reqs    :  None
-- Function    :  Calls copy_configuration within an autonomous transaction and commits the copied data
-- Version     :  Current version 1.0
--                Initial version 1.0

PROCEDURE copy_configuration_auto
             (p_api_version          IN  NUMBER
             ,p_config_hdr_id        IN  NUMBER
             ,p_config_rev_nbr       IN  NUMBER
             ,p_copy_mode            IN  VARCHAR2
             ,x_config_hdr_id        OUT NOCOPY  NUMBER
             ,x_config_rev_nbr       OUT NOCOPY  NUMBER
             ,x_orig_item_id_tbl     OUT NOCOPY  CZ_API_PUB.number_tbl_type
             ,x_new_item_id_tbl      OUT NOCOPY  CZ_API_PUB.number_tbl_type
             ,x_return_status        OUT NOCOPY  VARCHAR2
             ,x_msg_count            OUT NOCOPY  NUMBER
             ,x_msg_data             OUT NOCOPY  VARCHAR2
             ,p_handle_deleted_flag  IN  VARCHAR2 := NULL
             ,p_new_name             IN  VARCHAR2 := NULL
      );

--------------------------------------------------------------------------------
-- API name    :  verify_configuration
-- Package Name:  CZ_CONFIG_API_PUB
-- Type        :  Public
-- Pre-reqs    :  None
-- Function    :  Verifies that the specified configuration exists and returns
--                whether it is valid and/or complete
-- Version     :  Current version 1.0
--                Initial version 1.0

PROCEDURE verify_configuration(p_api_version        IN  NUMBER
                              ,p_config_hdr_id      IN  NUMBER
                              ,p_config_rev_nbr     IN  NUMBER
                              ,x_exists_flag        OUT NOCOPY  VARCHAR2
                              ,x_valid_flag         OUT NOCOPY  VARCHAR2
                              ,x_complete_flag      OUT NOCOPY  VARCHAR2
                              ,x_return_status      OUT NOCOPY  VARCHAR2
                              ,x_msg_count          OUT NOCOPY  NUMBER
                              ,x_msg_data           OUT NOCOPY  VARCHAR2
                              );

-- Parameters:
--         IN:  p_api_version (required), standard pl/sql api in parameter
--              p_config_hdr_id (required), header id of config to be verified
--              p_config_rev_nbr (required), revision of config to be verified

--        OUT:  x_exists_flag  FND_API.G_TRUE if config_hdr_id and config_rev_nbr describe a saved configuration,
--                             FND_API.G_FALSE if there is no saved configuration
--              x_valid_flag  FND_API.G_TRUE if configuration exists and is valid, FND_API.G_FALSE if the configuration
--                            exists and is invalid, NULL if configuration does not exist.
--              x_complete_flag  FND_API.G_TRUE if configuration exists and is complete, FND_API.G_FALSE if the
--                               configuration exists and is incomplete, NULL if configuration does not exist.
--              x_return_status, standard OUT parameter (FND_API.G_RET_STS_SUCCESS,
--                FND_API.G_RET_STS_ERROR, or FND_API.G_RET_STS_UNEXP_ERROR)
--              x_msg_count, standard OUT parameter
--              x_msg_data, standard OUT parameter

-- Validation:
--   p_config_hdr_id/p_config_rev_nbr: In 19 Configurator builds and later, the API validates that the configuration header
--   identified by config_hdr_id and config_rev_nbr is a session (not instance) header.  If not, x_return_status will be
--   FND_API.G_RET_STS_ERROR and a message will be returned in x_msg_data.

END CZ_CONFIG_API_PUB;

 

/
