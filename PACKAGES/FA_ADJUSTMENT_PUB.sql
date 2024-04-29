--------------------------------------------------------
--  DDL for Package FA_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADJUSTMENT_PUB" AUTHID CURRENT_USER as
/* $Header: FAPADJS.pls 120.3.12010000.2 2009/07/19 14:25:32 glchen ship $   */
/*#
 * Create asset adjustments.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Adjustments API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206474.1 Adjustments API Documentation Supplement
 */



/*#
 * Adjust the financial information of an asset in a specific book.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function name
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param p_asset_fin_rec_adj The adjusted asset financial information record
 * @param x_asset_fin_rec_new The new asset financial information record
 * @param x_asset_fin_mrc_tbl_new The new MRC asset financial information table
 * @param px_inv_trans_rec The invoice transaction record
 * @param px_inv_tbl The table of invoices
 * @param p_asset_deprn_rec_adj The adjusted asset depreciation record
 * @param x_asset_deprn_rec_new The new asset depreciation record
 * @param x_asset_deprn_mrc_tbl_new The new MRC asset depreciation table
 * @param p_group_reclass_options_rec The asset group reclassification information
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Adjust Asset
 * @rep:compatibility S
 */
PROCEDURE do_adjustment
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_mrc_tbl_new       OUT NOCOPY FA_API_TYPES.asset_fin_tbl_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    p_asset_deprn_rec_adj      IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_mrc_tbl_new     OUT NOCOPY FA_API_TYPES.asset_deprn_tbl_type,
    p_group_reclass_options_rec IN    FA_API_TYPES.group_reclass_options_rec_type
   );

END FA_ADJUSTMENT_PUB;

/
