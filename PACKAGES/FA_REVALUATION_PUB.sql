--------------------------------------------------------
--  DDL for Package FA_REVALUATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_REVALUATION_PUB" AUTHID CURRENT_USER as
/* $Header: FAPRVLS.pls 120.1.12010000.2 2009/07/19 12:03:46 glchen ship $   */
/*#
 * Creates asset revaluations.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Revaluation API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */

--*********************** Public procedures ******************************--
/*#
 * Revalue an asset in a specific book based on the provided rules.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param p_reval_options_rec The revaluation options record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Revalue Asset
 * @rep:compatibility S
 */
PROCEDURE do_reval
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
    p_reval_options_rec        IN     FA_API_TYPES.reval_options_rec_type
   ) ;

-----------------------------------------------------------------------------

END FA_REVALUATION_PUB;

/
