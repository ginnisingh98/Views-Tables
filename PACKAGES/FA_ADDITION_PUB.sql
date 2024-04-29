--------------------------------------------------------
--  DDL for Package FA_ADDITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADDITION_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPADDS.pls 120.3.12010000.2 2009/07/19 14:40:57 glchen ship $   */
/*#
 * Create asset additions.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Asset Addition API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 232070.1 Additions API Documentation Supplement
 */


/*#
 * Add an asset to a specific book.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_calling_fn The calling function name
 * @param px_trans_rec The transaction record
 * @param px_dist_trans_rec The distribution transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_asset_desc_rec The asset descriptive record
 * @param px_asset_type_rec The asset type record
 * @param px_asset_cat_rec The asset category record
 * @param px_asset_hierarchy_rec The asset hierarchy record
 * @param px_asset_fin_rec The asset financial information record
 * @param px_asset_deprn_rec The asset depreciation record
 * @param px_asset_dist_tbl The table of asset assignments
 * @param px_inv_tbl The table of invoices
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Asset
 * @rep:compatibility S
 */
procedure do_addition (
   -- Standard Paramters --
   p_api_version              IN      NUMBER,
   p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level         IN      NUMBER:=FND_API.G_VALID_LEVEL_FULL,
   x_return_status               OUT  NOCOPY VARCHAR2,
   x_msg_count                   OUT  NOCOPY NUMBER,
   x_msg_data                    OUT  NOCOPY VARCHAR2,
   p_calling_fn               IN      VARCHAR2,
   -- Transaction Object --
   px_trans_rec               IN OUT  NOCOPY fa_api_types.trans_rec_type,
   px_dist_trans_rec          IN OUT  NOCOPY fa_api_types.trans_rec_type,
   -- Asset Object --
   px_asset_hdr_rec           IN OUT  NOCOPY fa_api_types.asset_hdr_rec_type,
   px_asset_desc_rec          IN OUT  NOCOPY fa_api_types.asset_desc_rec_type,
   px_asset_type_rec          IN OUT  NOCOPY fa_api_types.asset_type_rec_type,
   px_asset_cat_rec           IN OUT  NOCOPY fa_api_types.asset_cat_rec_type,
   px_asset_hierarchy_rec     IN OUT  NOCOPY fa_api_types.asset_hierarchy_rec_type,
   px_asset_fin_rec           IN OUT  NOCOPY fa_api_types.asset_fin_rec_type,
   px_asset_deprn_rec         IN OUT  NOCOPY fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl          IN OUT  NOCOPY fa_api_types.asset_dist_tbl_type,
   -- Invoice Object --
   px_inv_tbl                 IN OUT  NOCOPY fa_api_types.inv_tbl_type
);

END FA_ADDITION_PUB;

/
