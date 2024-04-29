--------------------------------------------------------
--  DDL for Package GMD_SPEC_VRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_VRS_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDPSVRS.pls 120.1 2006/10/04 11:51:29 srakrish noship $*/
/*#
 * This interface is used for processing QC Spec Validity Rules.
 * This package defines and implements the procedures and datatypes
 * required for inserting, deleting QC Spec Validity Rules.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname QC Spec Validity Rules package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_QC_SPEC_VR
 */



/*  A Table type Definition */

TYPE INVENTORY_SPEC_VRS_TBL IS TABLE OF GMD_INVENTORY_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;

TYPE WIP_SPEC_VRS_TBL IS TABLE OF GMD_WIP_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;

TYPE CUSTOMER_SPEC_VRS_TBL IS TABLE OF GMD_CUSTOMER_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;

TYPE SUPPLIER_SPEC_VRS_TBL IS TABLE OF GMD_SUPPLIER_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;

TYPE MONITORING_SPEC_VRS_TBL IS TABLE OF GMD_MONITORING_SPEC_VRS%ROWTYPE
      INDEX BY BINARY_INTEGER;

/*   Define Procedures And Functions :   */


/*#
 * Creates multiple inventory spec validity rules.
 * Accepts a table of Inventory Spec Validity Rule definitions, validates
 * each table entry and if found valid, inserts a corresponding row
 * into gmd_inventory_spec_vrs.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate if message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_inventory_spec_vrs_tbl Input table structure for Inventory Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_inventory_spec_vrs_tbl Table structure containing inserted Inventory Specification Validity Rules
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Inventory Spec Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE CREATE_INVENTORY_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_inventory_spec_vrs_tbl IN  GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_inventory_spec_vrs_tbl OUT NOCOPY GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);


/*#
 * Creates multiple WIP spec validity rules.
 * Accepts a table of WIP Spec Validity Rule definitions, validates
 * each table entry and if found valid, inserts a corresponding row
 * into gmd_wip_spec_vrs.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_wip_spec_vrs_tbl Input table structure for WIP Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_wip_spec_vrs_tbl Table structure containing inserted WIP Specification Validity Rules
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create WIP Spec Validity Vules procedure
 * @rep:compatibility S
 */

PROCEDURE CREATE_WIP_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_wip_spec_vrs_tbl       IN  GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_wip_spec_vrs_tbl       OUT NOCOPY GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);

/*#
 * Inserts multiple customer spec validity rules.
 * Accepts a table of Customer Spec Validity Rule definitions, validates
 * each table entry and if found valid, inserts a corresponding row
 * into gmd_customer_spec_vrs.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_customer_spec_vrs_tbl Input table structure for Customer Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_customer_spec_vrs_tbl Table structure containing inserted Customer Specification Validity Rules
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Spec Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE CREATE_CUSTOMER_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_customer_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_customer_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);


/*#
 * Creates multiple supplier spec validity rules.
 * Accepts a table of Supplier Spec Validity Rule definitions, validates
 * each table entry and if found valid, inserts a corresponding row
 * into gmd_supplier_spec_vrs.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_supplier_spec_vrs_tbl Input table structure for Supplier Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_supplier_spec_vrs_tbl Table structure containing inserted Customer Specification Validity Rules
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Supplier Spec Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE CREATE_SUPPLIER_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_supplier_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_supplier_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);

/*#
 * Creates multiple monitoring spec validity rules.
 * Accepts a table of Monitoring Spec Validity Rule definitions, validates
 * each table entry and if found valid, inserts a corresponding row
 * into gmd_monitoring_spec_vrs.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_monitoring_spec_vrs_tbl Input table structure for Monitoring Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_monitoring_spec_vrs_tbl Table structure containing inserted Monitoring Specification Validity Rules
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Monitoring Spec Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE CREATE_MONITORING_SPEC_VRS
( p_api_version            IN  NUMBER
, p_init_msg_list          IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                 IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level       IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_monitoring_spec_vrs_tbl  IN  GMD_SPEC_VRS_PUB.monitoring_spec_vrs_tbl
, p_user_name              IN  VARCHAR2
, x_monitoring_spec_vrs_tbl  OUT NOCOPY GMD_SPEC_VRS_PUB.monitoring_spec_vrs_tbl
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);


/*#
 * Deletes multiple inventory spec validity rules.
 * Accepts a table of Inventory Spec Validity Rule definitions, validates
 * each table entry to ensure the corresponding row is not already
 * delete marked.  Where validation is successful, a logical delete.
 * is performed setting delete_mark=1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_inventory_spec_vrs_tbl Input table structure for Inventory Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_deleted_rows Number of rows deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Inventory Specification Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE DELETE_INVENTORY_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                   IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level         IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_inventory_spec_vrs_tbl   IN  GMD_SPEC_VRS_PUB.inventory_spec_vrs_tbl
, p_user_name                IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);


/*#
 * Deletes multiple WIP spec validity rules.
 * Accepts a table of WIP Spec Validity Rule definitions, validates
 * each table entry to ensure the corresponding row is not already
 * delete marked.  Where validation is successful, a logical delete.
 * is performed setting delete_mark=1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_wip_spec_vrs_tbl Input table structure for WIP Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_deleted_rows Number of rows deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete WIP Specification Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE DELETE_WIP_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                   IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level         IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_wip_spec_vrs_tbl         IN  GMD_SPEC_VRS_PUB.wip_spec_vrs_tbl
, p_user_name                IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);


/*#
 * Deletes multiple customer spec validity rules.
 * Accepts a table of Customer Spec Validity Rule definitions, validates
 * each table entry to ensure the corresponding row is not already
 * marked for delete.  If validation is successful, a logical delete.
 * is performed setting delete_mark=1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_customer_spec_vrs_tbl Input table structure for Customer Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_deleted_rows Number of rows deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Customer Specification Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE DELETE_CUSTOMER_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                   IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level         IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_customer_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.customer_spec_vrs_tbl
, p_user_name                IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);




/*#
 * Deletes multiple supplier spec validity rules.
 * Accepts a table of Supplier Spec Validity Rule definitions, validates
 * each table entry to ensure the corresponding row is not already
 * delete marked.  Where validation is successful, a logical delete.
 * is performed setting delete_mark=1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_supplier_spec_vrs_tbl Input table structure for Supplier Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_deleted_rows Number of rows deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Supplier Specification Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE DELETE_SUPPLIER_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                   IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level         IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_supplier_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.supplier_spec_vrs_tbl
, p_user_name                IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);


/*#
 * Deletes multiple monitoring spec validity rules.
 * Accepts a table of Monitoring Spec Validity Rule definitions.  Validates
 * each table entry to ensure the corresponding row is not already
 * delete marked.  Where validation is successful, a logical delete.
 * is performed setting delete_mark=1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to indicate message list is initialized
 * @param p_commit Flag to check for commit
 * @param p_validation_level For future use
 * @param p_monitoring_spec_vrs_tbl Input table structure for Monitoring Specification Validity Rule data
 * @param p_user_name Login User Name
 * @param x_deleted_rows Number of rows deleted
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Monitoring Specification Validity Rules procedure
 * @rep:compatibility S
 */

PROCEDURE DELETE_MONITORING_SPEC_VRS
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                   IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level         IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_monitoring_spec_vrs_tbl    IN  GMD_SPEC_VRS_PUB.MONITORING_spec_vrs_tbl
, p_user_name                IN  VARCHAR2        DEFAULT NULL
, x_deleted_rows             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

END GMD_SPEC_VRS_PUB;

 

/
