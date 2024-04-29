--------------------------------------------------------
--  DDL for Package FA_RESERVE_TRANSFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RESERVE_TRANSFER_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPRSVXS.pls 120.3.12010000.2 2009/07/19 12:02:50 glchen ship $ */
/*#
 * Transfers reserve between two group assets in the same book.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Reserve Transfer API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */



/*#
 * Transfer reserve between two group assets in the same book.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_src_asset_id The source asset identifier
 * @param p_dest_asset_id The destination asset identifier
 * @param p_book_type_code The book type code
 * @param p_amount The amount of depreciation reserve to transfer
 * @param px_src_trans_rec The source transaction record
 * @param px_dest_trans_rec The destination transaction record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Group Asset Reserve
 * @rep:compatibility S
 */
PROCEDURE do_reserve_transfer
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    p_src_asset_id             IN     NUMBER,
    p_dest_asset_id            IN     NUMBER,
    p_book_type_code           IN     VARCHAR2,
    p_amount                   IN     NUMBER,
    px_src_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type
   );

END FA_RESERVE_TRANSFER_PUB;

/
