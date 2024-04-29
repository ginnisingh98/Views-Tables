--------------------------------------------------------
--  DDL for Package FA_RETIREMENT_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIREMENT_ADJUSTMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPRADJS.pls 120.3.12010000.2 2009/07/19 12:00:18 glchen ship $ */
/*#
 * Performs group retirement adjustments.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Group Retirement Adjustment API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */

/*#
 * Adjust the proceeds and/or cost of removal information for a group asset.
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
 * @param p_cost_of_removal The cost of removal amount
 * @param p_proceeds The proceeds amount
 * @param p_cost_of_removal_ccid The cost of removal code combination identifier
 * @param p_proceeds_ccid The proceeds code combination identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Adjust Group Asset Retirement
 * @rep:compatibility S
 */
PROCEDURE do_retirement_adjustment
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
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER DEFAULT NULL,
    p_proceeds_ccid            IN     NUMBER DEFAULT NULL
   );

END FA_RETIREMENT_ADJUSTMENT_PUB ;

/
