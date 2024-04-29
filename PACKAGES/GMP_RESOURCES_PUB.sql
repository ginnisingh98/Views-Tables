--------------------------------------------------------
--  DDL for Package GMP_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_RESOURCES_PUB" AUTHID CURRENT_USER AS
/* $Header: GMPGRESS.pls 120.1.12010000.2 2008/11/05 18:52:00 rpatangy ship $ */
/*#
 * This is the public interface for OPM Generic Resources API
 * These API can be used  for creation, updation and deletion of Generic
 * Resources in OPM
 * @rep:scope public
 * @rep:product GMP
 * @rep:displayname GMP_RESOURCES_PUB
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMP_GENERIC_RESOURCE
*/

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMP_RESOURCES_PUB';
  v_insert_flag  varchar2(1) := '';

  TYPE gmp_resources_tab IS TABLE OF cr_rsrc_mst%ROWTYPE
       INDEX BY BINARY_INTEGER;

  TYPE gmp_resources_dtl_tab IS TABLE OF cr_rsrc_dtl%ROWTYPE
       INDEX BY BINARY_INTEGER;

  /* define record and table type to specify the column that needs to
     updated */
  TYPE update_table_rec_type IS RECORD
  (
   p_col_to_update	VARCHAR2(30)
  ,p_value		VARCHAR2(30)
  );

  TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;


/*#
 *  API for INSERT_RESOURCES
 *  This API creates a generic resource based on the data provided as
 *  input after validating it. It inserts a row in Resource table cr_rsrc_mst
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_resources This is the resource information is prescribed format
 *  that need to be inserted into the resource table.
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname INSERT_RESOURCES
*/
  PROCEDURE insert_resources
  ( p_api_version            IN   NUMBER	                   :=  1
  , p_init_msg_list          IN   BOOLEAN	                   :=  TRUE
  , p_commit		     IN   BOOLEAN	                   :=  FALSE
  , p_resources              IN   cr_rsrc_mst%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          IN OUT  NOCOPY VARCHAR2
  );

/*#
 *  API for CHECK_DATA
 *  This API validates the data provided that is expected to be inserted in as a
 *  resource.
 *  @param p_resources These is the Resource that need to be inserted into the
 *  table.
 *  @param p_resource_desc This is the description of the Resource
 *  @param p_std_usage_um  Standard Usage Uom of the Resource
 *  @param p_resource_class  Resource Class for the Resource
 *  @param p_cost_cmpntcls_id  Cost Component Class for the Resource
 *  @param p_min_capacity    Minimum Capacity of the Resource
 *  @param p_max_capacity    Maximum Capacity of the Resource
 *  @param p_capacity_uom    Resource Capacity Uom
 *  @param p_capacity_constraint  Resource Capacity Constraint
 *  @param p_capacity_tolerance  Capacity Tolerance
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname CHECK_DATA
*/
  PROCEDURE  check_data
  ( p_resources        IN     VARCHAR2,
    p_resource_desc      IN   VARCHAR2,
    p_std_usage_um       IN   VARCHAR2,
    p_resource_class     IN   VARCHAR2,
    p_cost_cmpntcls_id   IN   NUMBER,
    p_min_capacity       IN   NUMBER,
    p_max_capacity       IN   NUMBER,
    p_capacity_uom       IN   VARCHAR2,
    p_capacity_constraint  IN   NUMBER,
    p_capacity_tolerance   IN   NUMBER,
    x_message_count      OUT  NOCOPY NUMBER,
    x_message_list       OUT  NOCOPY VARCHAR2,
    x_return_status      OUT  NOCOPY VARCHAR2
 );

/*#
 *  API for UPDATE_RESOURCES
 *  This API updates the given resource record with desired values.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_resources This is the resource information expected to be updated
 *  It contains the resource name to be updated and new values for various
 *  columns
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname UPDATE_RESOURCES
*/
  PROCEDURE update_resources
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_resources         IN      cr_rsrc_mst%ROWTYPE
  , x_message_count 	OUT 	NOCOPY NUMBER
  , x_message_list 	OUT 	NOCOPY VARCHAR2
  , x_return_status	OUT 	NOCOPY VARCHAR2
  );

/*#
 *  API for DELETE_RESOURCES
 *  This API to delete an OPM resource
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list BOOLEAN
 *  @param p_commit   This is the commmit flag BOOLEAN.
 *  @param p_resources Theis is the Resource that needs to be deleted.
 *  @param x_message_count Number of messages on message stack
 *  @param x_message_list  Actual message data from message stack
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname DELETE_RESOURCES
*/
  PROCEDURE delete_resources
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_resources         IN      cr_rsrc_mst.resources%TYPE      := NULL
  , x_message_count 	OUT 	NOCOPY NUMBER
  , x_message_list 	OUT 	NOCOPY VARCHAR2
  , x_return_status	OUT 	NOCOPY VARCHAR2
  );

END GMP_RESOURCES_PUB;

/
