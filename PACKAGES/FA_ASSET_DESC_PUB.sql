--------------------------------------------------------
--  DDL for Package FA_ASSET_DESC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_DESC_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPADSCS.pls 120.2.12010000.2 2009/07/19 14:26:34 glchen ship $   */
/*#
 * This is the public interface for the Asset, Invoice, and Retirement
 * Descriptive APIs.
 * @rep:scope  public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname  Update Asset Description API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */


--*********************** Public procedures ******************************--
/*#
 * Update the descriptive information of an asset.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_calling_fn The calling function
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_asset_desc_rec_new The asset descriptive record
 * @param px_asset_cat_rec_new The asset category record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Asset Descriptive Information
 * @rep:compatibility S
 * @rep:metalink 206481.1 Oracle Assets Asset Description API Documentation Supplement
 */
procedure update_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_asset_desc_rec_new   IN OUT NOCOPY fa_api_types.asset_desc_rec_type,
          px_asset_cat_rec_new    IN OUT NOCOPY fa_api_types.asset_cat_rec_type);



/*#
 * Update the descriptive information of an invoice.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_calling_fn The calling function
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_inv_tbl_new The table of invoices
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Asset Source Line
 * @rep:compatibility S
 * @rep:metalink 206477.1 Oracle Assets Invoice Description API Documentation Supplement
 */
procedure update_invoice_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_inv_tbl_new          IN OUT NOCOPY fa_api_types.inv_tbl_type);



/*#
 * Update the descriptive information of an asset retirement.
 * @param p_api_version The version of the API
 * @param p_init_msg_list initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_calling_fn The calling function
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_asset_retire_rec_new The asset retirement record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Asset Retirement Information
 * @rep:compatibility S
 */
procedure update_retirement_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_asset_retire_rec_new IN OUT NOCOPY fa_api_types.asset_retire_rec_type);

END FA_ASSET_DESC_PUB;

/
