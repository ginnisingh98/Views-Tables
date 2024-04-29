--------------------------------------------------------
--  DDL for Package FA_RECLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RECLASS_PUB" AUTHID CURRENT_USER as
/* $Header: FAPRECS.pls 120.4.12010000.2 2009/07/19 12:01:24 glchen ship $   */
/*#
 * Creates asset reclassifications.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Reclassify Asset API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206478.1 Reclass API Documentation Supplement
 */

/* ---------------------------------------------------------------
 * Name            : Do_reclass
 * Type            : Function
 * Returns         : Boolean
 * Purpose         : Perform reclass transaction for an asset
 * Calling Details : This procedure expects the following parameters with
 *                   valid data for it to perform the Reclass transaction
 *                   successfully
 *                   p_asset_desc_rec.asset_number
 *                   p_asset_cat_rec_new.category_id
 * ---------------------------------------------------------------- */

/*#
 * Reclassify an asset to a different category.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_asset_cat_rec_new The new asset category record
 * @param p_recl_opt_rec reclass The options record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Reclassify Asset
 * @rep:compatibility S
 */
PROCEDURE do_reclass (
           -- std parameters
           p_api_version              IN      NUMBER,
           p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
           p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
           p_validation_level         IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
           p_calling_fn               IN      VARCHAR2,
           x_return_status               OUT NOCOPY  VARCHAR2,
           x_msg_count                   OUT NOCOPY  NUMBER,
           x_msg_data                    OUT NOCOPY  VARCHAR2,
           -- api parameters
           px_trans_rec               IN OUT NOCOPY  FA_API_TYPES.trans_rec_type,
           px_asset_hdr_rec           IN OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
           px_asset_cat_rec_new       IN OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
           p_recl_opt_rec             IN      FA_API_TYPES.reclass_options_rec_type );


END FA_RECLASS_PUB;

/
