--------------------------------------------------------
--  DDL for Package FA_UNIT_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UNIT_ADJ_PUB" AUTHID CURRENT_USER as
/* $Header: FAPUADJS.pls 120.3.12010000.2 2009/07/19 12:07:22 glchen ship $   */
/*#
 * Adjusts units of an asset.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Unit Adjustments API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206482.1 Unit Adjustment API Documentation Supplement
 */


/*#
 * Adjust the units of an asset.
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
 * @param px_asset_dist_tbl The table of asset assignments
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Adjust Asset Units
 * @rep:compatibility S
 */
PROCEDURE do_unit_adjustment(p_api_version         IN     NUMBER,
                      p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
                      p_commit              IN     VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn          IN     VARCHAR2,
                      x_return_status       OUT NOCOPY    VARCHAR2,
                      x_msg_count           OUT NOCOPY    NUMBER,
                      x_msg_data            OUT NOCOPY    VARCHAR2,
                      px_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                      px_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                      px_asset_dist_tbl     IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type);

/* moved the function to package body
FUNCTION valid_input(px_trans_rec     IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                     p_asset_hdr_rec  IN     FA_API_TYPES.asset_hdr_rec_type)
		RETURN BOOLEAN; */

END FA_UNIT_ADJ_PUB;

/
