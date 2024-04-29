--------------------------------------------------------
--  DDL for Package FA_UNPLANNED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UNPLANNED_PUB" AUTHID CURRENT_USER as
/* $Header: FAPUNPLS.pls 120.2.12010000.2 2009/07/19 12:08:18 glchen ship $   */
/*#
 * Creates unplanned depreciation.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Unplanned Depreciation API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206479.1 Unplanned Depreciation API Documentation Supplement
 */



G_expense_account             VARCHAR2(25);



/*#
 * Enter unplanned depreciation for an asset in a specific book.
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
 * @param p_unplanned_deprn_rec The unplanned depreciation record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Unplanned Depreciation
 * @rep:compatibility S
 */
PROCEDURE do_unplanned
   (p_api_version             IN     NUMBER,
    p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn              IN     VARCHAR2 := NULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_unplanned_deprn_rec     IN     FA_API_TYPES.unplanned_deprn_rec_type
   );

END FA_UNPLANNED_PUB;

/
