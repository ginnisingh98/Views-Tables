--------------------------------------------------------
--  DDL for Package GMIPAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIPAPI" AUTHID CURRENT_USER AS
/* $Header: GMIPAPIS.pls 120.1 2006/10/04 18:30:56 pxkumar noship $ */
/*#
 * This is the public interface for OPM Inventory API
 * This API can be used for creation of Items, creation of Lots,
 * creation of Item/lot/sublot conversions, setting and posting of
 * Inventory journal
 * @rep:scope private
 * @rep:product GMI
 * @rep:displayname GMI Inventory API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMI_API
*/

/*#
 * Inventory Item Creation API
 * This API Creates a new Inventory Item in the OPM Inventory Item Master Table
 * @param p_api_version Version number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data
 * @param p_validation_level Indicator for validation level
 * @param p_item_rec Item details record type
 * @param x_ic_item_mst_row Item master row type
 * @param x_ic_item_cpg_row Item details row type
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create Inventory Item API
*/
PROCEDURE Create_Item
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_item_rec         IN  GMIGAPI.item_rec_typ
, x_ic_item_mst_row  OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row  OUT NOCOPY ic_item_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

/*#
 * Inventory Lot Creation API
 * This API Creates a new Inventory Lot in the Lot Master Table
 * @param p_api_version Version number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data
 * @param p_validation_level Indicator for validation level
 * @param p_lot_rec Lot details record type
 * @param x_ic_lots_mst_row Lot master row type
 * @param x_ic_lots_cpg_row Lot details row type
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create Inventory Lot API
*/
PROCEDURE Create_Lot
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  GMIGAPI.lot_rec_typ
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

/*#
 * Item/Lot/Sublot Conversion API
 * This API Creates a new Inventory Item/lot/sublot conversion
 * in Item/lot conversion table
 * @param p_api_version Version number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data
 * @param p_validation_level Indicator for validation level
 * @param p_conv_rec Conversion details record type
 * @param x_ic_item_cnv_row Item/lot conversion details row type
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create Inventory Item/Lot/Sublot Conversion API
*/
PROCEDURE Create_Item_Lot_Conv
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_conv_rec         IN  GMIGAPI.conv_rec_typ
, x_ic_item_cnv_row  OUT NOCOPY ic_item_cnv%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

/*#
 * Setting up and Posting Inventory Journal API
 * This API sets up and posts inventory journal in
 * Journal master header table
 * @param p_api_version Version number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data
 * @param p_validation_level Indicator for validation level
 * @param p_qty_rec Quantity details record type
 * @param x_ic_jrnl_mst_row Journal master header row type
 * @param x_ic_adjs_jnl_row1 Inventory adjustment detail row type
 * @param x_ic_adjs_jnl_row2 Inventory adjustment detail row type
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Setup and Post Inventory Journal API
*/
PROCEDURE Inventory_Posting
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qty_rec          IN  GMIGAPI.qty_rec_typ
, x_ic_jrnl_mst_row  OUT NOCOPY ic_jrnl_mst%ROWTYPE
, x_ic_adjs_jnl_row1 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_ic_adjs_jnl_row2 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE Inventory_Transfer
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2
, p_commit           IN  VARCHAR2
, p_validation_level IN  NUMBER
, p_xfer_rec         IN  GMIGAPI.xfer_rec_typ
, x_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

END GMIPAPI;

 

/
