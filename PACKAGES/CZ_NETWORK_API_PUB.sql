--------------------------------------------------------
--  DDL for Package CZ_NETWORK_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_NETWORK_API_PUB" AUTHID CURRENT_USER AS
/*	$Header: czntapis.pls 120.2 2005/10/07 10:26:48 misheehy ship $		*/
/*#
 * This is the public interface for some operations with configurations in Oracle Configurator
 * @rep:scope internal
 * @rep:product CZ
 * @rep:displayname Network API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG
 */


G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'cz_network_api_pub';

--------------------------API status return codes-----------------------------------------
---Start of comments
---API name                 : generate_config_trees
---Type			    : Public
---Pre-reqs                 : None
---Function                 : generates config trees for a given set of config hdr ids and rev nbrs
---Parameters               :
---IN                       : p_api_version        IN  NUMBER 		   Required
---					p_config_tbl         IN  config_tbl_type     Required
---					p_tree_copy_mode     IN  VARCHAR2            Required
---					p_appl_param_rec     IN  appl_param_rec_type Required
---					p_validation_context IN  VARCHAR2            Required
---OUT			    :
---				    : x_return_status      OUT NOCOPY VARCHAR2
---				      x_msg_count          OUT NOCOPY NUMBER
---					x_msg_data           OUT NOCOPY VARCHAR2
---Version: Current version :1.0
---End of comments
/*#
 * generates config trees for a given set of config hdr ids and rev nbrs
 * @param p_api_version api verion
 * @param p_config_tbl PL/SQL table which represents configuation
 * @param p_tree_copy_mode     tree copy mode
 * @param p_appl_param_rec     application parameters record
 * @param p_validation_context validation context
 * @param x_config_model_tbl   PL/SQL table which represents output configuation
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Config Trees
 */
PROCEDURE generate_config_trees(p_api_version        IN  NUMBER,
                                p_config_tbl         IN  CZ_API_PUB.config_tbl_type,
					  p_tree_copy_mode     IN  VARCHAR2,
                                p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
                                p_validation_context IN  VARCHAR2,
                                x_config_model_tbl   OUT NOCOPY CZ_API_PUB.config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
				        );

---------------------------------------------------------------------------
---Start of comments
---API name                 : generate_config_trees
---Type			    : Public
---Pre-reqs                 : None
---Function                 : generates config trees for a given set of config hdr ids and rev nbrs
---Parameters               :
---IN                       : p_api_version        IN  NUMBER 		   Required
---					p_config_tbl         IN  config_tbl_type     Required
---					p_tree_copy_mode     IN  VARCHAR2            Required
---					p_appl_param_rec     IN  appl_param_rec_type Required
---					p_validation_context IN  VARCHAR2            Required
---                           p_validation_type    IN  VARCHAR2
---OUT			    :
---				    : x_return_status      OUT NOCOPY VARCHAR2
---				      x_msg_count          OUT NOCOPY NUMBER
---					x_msg_data           OUT NOCOPY VARCHAR2
---Version: Current version :1.0
---End of comments
/*#
 * generates config trees for a given set of config hdr ids and rev nbrs
 * @param p_api_version api verion
 * @param p_config_tbl PL/SQL table which represents configuation
 * @param p_tree_copy_mode     tree copy mode
 * @param p_appl_param_rec     application parameters record
 * @param p_validation_context validation context
 * @param p_validation_type    validation type, valid values are CZ_API_PUB.INTERACTIVE and CZ_API_PUB.VALIDATE_RETURN
 * @param x_config_model_tbl   PL/SQL table which represents output configuation
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Config Trees
 */
PROCEDURE generate_config_trees(p_api_version        IN  NUMBER,
                                p_config_tbl         IN  CZ_API_PUB.config_tbl_type,
					  p_tree_copy_mode     IN  VARCHAR2,
                                p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
                                p_validation_context IN  VARCHAR2,
                                p_validation_type    IN  VARCHAR2,
                                x_config_model_tbl   OUT NOCOPY CZ_API_PUB.config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
				        );

------------------------------------------------------------------------------------------
-----procedure adds instances to the saved configuration of a container model
-- Parameters:

-- IN: p_api_version (required), standard pl/sql api in parameter
-- p_inventory_item_id (optional), top inventory_item_id of network
-- container model
-- p_organization_id (optional), organization_id of network container model
-- p_config_hdr_id (optional), header id of saved network container config
-- p_config_rev_nbr (optional), revision of saved network container config
-- p_instance_tbl (required), table of instance records (config_hdr_id, config_rev_nbr)
-- p_tree_copy_mode (required), flag to specify the type of hierarchy to
-- build, has one of the following values. G_NEW_HEADER_COPY_MODE G_NEW_REVISION_COPY_MODE
-- p_appl_param_rec (required), publication applicability parameters
-- program callers should pass in the same set of applicability
-- parameter values as they pass in the Configurator xml initialize
-- message
-- p_validation_context (optional), has one of the following values. G_PENDING_OR_INSTALLED  G_INSTALLED

-- OUT: x_config_model_rec, new network container output record
-- If any error occurs during the execution of this procedure,
-- x_config_model_rec will be null.
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * procedure adds instances to the saved configuration of a container model
 * @param p_api_version api verion
 * @param p_inventory_item_id top inventory_item_id of network container model
 * @param p_organization_id organization_id of network container model
 * @param p_config_hdr_id header id of saved network container config
 * @param p_config_rev_nbr revision of saved network container config
 * @param p_instance_tbl table of instance records (config_hdr_id, config_rev_nbr)
 * @param p_tree_copy_mode flag to specify the type of hierarchy to
 *                         build, has one of the following values : G_NEW_HEADER_COPY_MODE G_NEW_REVISION_COPY_MODE
 * @param  p_appl_param_rec publication applicability parameters
 *                          program callers should pass in the same set of applicability
 *                          parameter values as they pass in the Configurator xml initialize message
 * @param p_validation_context has one of the following values. G_PENDING_OR_INSTALLED  G_INSTALLED
 * @param x_config_model_rec new network container output record
 *                           If any error occurs during the execution of this procedure,
 *                           x_config_model_rec will be null.
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add to Config Tree
 */
PROCEDURE add_to_config_tree (p_api_version	   IN  NUMBER,
					p_inventory_item_id  IN  NUMBER,
					p_organization_id    IN  NUMBER,
					p_config_hdr_id      IN  NUMBER,
					p_config_rev_nbr     IN  NUMBER,
					p_instance_tbl       IN  CZ_API_PUB.config_tbl_type,
					p_tree_copy_mode     IN  VARCHAR2,
					p_appl_param_rec     IN  CZ_API_PUB.appl_param_rec_type,
					p_validation_context IN  VARCHAR2,
					x_config_model_rec   OUT NOCOPY CZ_API_PUB.config_model_rec_type,
					x_return_status      OUT NOCOPY VARCHAR2,
					x_msg_count          OUT NOCOPY NUMBER,
					x_msg_data           OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------------------
-- API name : get_contained_models
-- Package Name: CZ_NETWORK_API_PUB
-- -Type : Public
-- Pre-reqs : None
-- Function: Retrieves all possible enclosed trackable child models for the network
-- container model specified by the input inventory_item_id and
-- organization_id
-- Version : Current version 1.0
-- Initial version 1.0

-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_inventory_item_id (required), top inventory_item_id of network
-- container model
-- p_organization_id (required), organization_id of network container model
-- p_appl_param_rec (required), publication applicability parameters
-- program callers should pass in the same set of applicability
-- parameter values as they pass in the Configurator xml initialize
-- message
--
-- OUT: x_model_tbl, output array of inventory_item_ids of enclosed models
-- IF any error occurs during execution of this procedure, null will be
-- returned.
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * retrieves all possible enclosed trackable child models for the network
 * container model specified by the input inventory_item_id and organization_id
 * @param p_api_version api verion
 * @param p_inventory_item_id top inventory_item_id of network container model
 * @param p_organization_id organization_id of network container model
 * @param p_appl_param_rec     application parameters record
 * @param x_model_tbl   PL/SQL table which represents output configuation
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Contained Models
 */
procedure get_contained_models(p_api_version        IN   NUMBER
                              ,p_inventory_item_id  IN   NUMBER
                              ,p_organization_id    IN   NUMBER
                              ,p_appl_param_rec     IN   CZ_API_PUB.appl_param_rec_type
                              ,x_model_tbl          OUT NOCOPY  CZ_API_PUB.number_tbl_type
                              ,x_return_status      OUT NOCOPY  VARCHAR2
                              ,x_msg_count          OUT NOCOPY  NUMBER
                              ,x_msg_data           OUT NOCOPY  VARCHAR2
                              );

------------------------------------------------------------------------------
-- API name : is_container
-- Package Name: CZ_NETWORK_API_PUB
-- Type : Public
-- Pre-reqs : None
-- Function: Checks if a model specified by the top inventory_item_id and
-- organization_id is a network container model.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameterp_inventory_item_id (required), top inventory_item_id of model
-- p_inventory_item_id (required), top inventory_item_id of model
-- p_organization_id (required), organization_id of model
-- p_appl_param_rec (required), publication applicability parameters
-- program callers should pass in the same set of applicability
-- parameter values as they pass in the Configurator xml initialize
-- message.
-- OUT: x_return_value, has one of the following values FND_API.G_TRUE,FND_API.G_FALSE,NULL
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * Checks if a model specified by the top inventory_item_id and organization_id is a network container model.
 * @param p_api_version api verion
 * @param p_inventory_item_id top inventory_item_id of network container model
 * @param p_organization_id organization_id of network container model
 * @param  p_appl_param_rec publication applicability parameters
 *                          program callers should pass in the same set of applicability
 *                          parameter values as they pass in the Configurator xml initialize message
 * @param x_return_value has one of the following values FND_API.G_TRUE,FND_API.G_FALSE,NULL
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check if it is Container
 */
procedure is_container(p_api_version        IN   NUMBER
                      ,p_inventory_item_id  IN   NUMBER
                      ,p_organization_id    IN   NUMBER
                      ,p_appl_param_rec     IN   CZ_API_PUB.appl_param_rec_type
                      ,x_return_value       OUT NOCOPY  VARCHAR2
                      ,x_return_status      OUT NOCOPY  VARCHAR2
                      ,x_msg_count          OUT NOCOPY  NUMBER
                      ,x_msg_data           OUT NOCOPY  VARCHAR2
                      );

----------------------------------------------------------------------------------
-- API name : is_configurable
-- Package Name: CZ_NETWORK_API_PUB
-- Type : Public
-- Pre-reqs : None
-- Function: Checks whether a config item is independently configurable or not.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_config_hdr_id (required), config_hdr_id of an instance
-- IN: p_config_hdr_id (required), config_hdr_id of an instance
-- p_config_hdr_id (required), config_hdr_id of an instance
-- p_config_rev_nbr (required), config_rev_nbr of an instance
-- p_config_item_id (required), config_item_id of an instance item
-- OUT: x_return_value, has one of the following values  FND_API.G_TRUE, FND_API.G_FALSE,NULL
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * Checks whether a config item is independently configurable or not.
 * @param p_api_version api verion
 * @param p_config_hdr_id  config_hdr_id of an instance
 * @param p_config_rev_nbr config_rev_nbr of an instance
 * @param p_config_item_id config_item_id of an instance item
 * @param x_return_value has one of the following values FND_API.G_TRUE,FND_API.G_FALSE,NULL
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check if it is Configurable
 */
procedure is_configurable(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT NOCOPY  VARCHAR2
                         ,x_return_status   OUT NOCOPY  VARCHAR2
                         ,x_msg_count       OUT NOCOPY  NUMBER
                         ,x_msg_data        OUT NOCOPY  VARCHAR2
                         );

--------------------------------------------------------------------------
-- API name : is_rma_allowed
-- Package Name: CZ_NETWORK_API_PUB
-- Type : Public
-- Pre-reqs : None
-- Function: Checks if a configurable item instance can be split.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_config_hdr_id (required), config_hdr_id of an instance
-- IN: p_config_hdr_id (required), config_hdr_id of the instance
-- p_config_rev_nbr (required), config_rev_nbr of the instance
-- p_config_item_id (required), config_item_id of the instance item
-- OUT: x_return_value, has one of the following values  FND_API.G_TRUE, FND_API.G_FALSE, NULL
-- x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * Checks if a configurable item instance can be split.
 * @param p_api_version api verion
 * @param p_config_hdr_id  config_hdr_id of an instance
 * @param p_config_rev_nbr config_rev_nbr of an instance
 * @param p_config_item_id config_item_id of an instance item
 * @param x_return_value has one of the following values FND_API.G_TRUE,FND_API.G_FALSE,NULL
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check if a configurable item instance can be split.
 */
procedure is_rma_allowed(p_api_version     IN   NUMBER
                        ,p_config_hdr_id   IN   NUMBER
                        ,p_config_rev_nbr  IN   NUMBER
                        ,p_config_item_id  IN   NUMBER
                        ,x_return_value    OUT NOCOPY  VARCHAR2
                        ,x_return_status   OUT NOCOPY  VARCHAR2
                        ,x_msg_count       OUT NOCOPY  NUMBER
                        ,x_msg_data        OUT NOCOPY  VARCHAR2
                        );

-------------------------------------------------------------------------------
-- API name : ext_deactivate_item
-- Package Name: CZ_NETWORK_API_PUB
-- Type : Public
-- Pre-reqs: None
-- Function: Externally deactivates an instance from CZ_CONFIG_DETAILS_V.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_config_hdr_id (required), config_hdr_id of an iteminstance
-- p_config_rev_nbr (required), config_rev_nbr of an iteminstance
-- p_config_item_id (required), config_item_id of an iteminstance
-- OUT: x_return_status, standard OUT NOCOPY parameter (see generate_config_trees)
-- x_msg_count, standard OUT NOCOPY parameter
-- x_msg_data, standard OUT NOCOPY parameter
/*#
 * Externally deactivates an instance from CZ_CONFIG_DETAILS_V.
 * @param p_api_version api verion
 * @param p_config_hdr_id  config_hdr_id of an instance
 * @param p_config_rev_nbr config_rev_nbr of an instance
 * @param p_config_item_id config_item_id of an instance item
 * @param x_return_status status string
 * @param x_msg_count number of error messages
 * @param x_msg_data string which contains error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Externally deactivate an instance from CZ_CONFIG_DETAILS_V.
 */
procedure ext_deactivate_item(p_api_version     IN   NUMBER
                             ,p_config_hdr_id   IN   NUMBER
                             ,p_config_rev_nbr  IN   NUMBER
                             ,p_config_item_id  IN   NUMBER
                             ,x_return_status   OUT NOCOPY  VARCHAR2
                             ,x_msg_count       OUT NOCOPY  NUMBER
                             ,x_msg_data        OUT NOCOPY  VARCHAR2
                             );

--------------------------Validation status return codes----------------------------------
PROCEDURE VALIDATE ( config_input_list IN  CZ_CF_API.CFG_INPUT_LIST,       -- input selections
    			   init_message      IN  VARCHAR2,             -- additional XML
    			   config_messages   IN OUT NOCOPY CZ_CF_API.CFG_OUTPUT_PIECES, -- table of output XML messages
    			   validation_status IN OUT NOCOPY NUMBER,            -- status return
    			   URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'),
    			   p_validation_type IN  VARCHAR2 DEFAULT CZ_API_PUB.VALIDATE_ORDER
			  );

-- The "is_item_added" function returns 1 if the config item has an "add" delta, 0 if not.
-- Note that p_config_hdr_id and p_config_rev_nbr are for the session header, not the instance header.

FUNCTION is_item_added (p_config_hdr_id IN NUMBER,
                        p_config_rev_nbr IN NUMBER,
                        p_config_item_id IN NUMBER) RETURN pls_integer;

END cz_network_api_pub;

 

/
