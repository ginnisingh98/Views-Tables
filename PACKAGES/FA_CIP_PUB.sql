--------------------------------------------------------
--  DDL for Package FA_CIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CIP_PUB" AUTHID CURRENT_USER as
/* $Header: FAPCIPS.pls 120.2.12010000.2 2009/07/19 14:27:31 glchen ship $   */
/*#
 * Capitalizes assets and reverses capitalization of assets.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Capitalize/Reverse Capitalize API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206480.1 CIP API Documentation Supplement
 */


/*#
 * Capitalize a CIP asset.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function name
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset headers record
 * @param px_asset_fin_rec The asset financial information record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Capitalize Asset
 * @rep:compatibility S
 */
PROCEDURE do_capitalization
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
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   );



/*#
 * Reverse the capitalization of a CIP asset.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function name
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset headers record
 * @param px_asset_fin_rec The asset financial information record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Reverse Capitalization of Asset
 * @rep:compatibility S
 */
PROCEDURE do_reverse
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
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   );

END FA_CIP_PUB;

/
