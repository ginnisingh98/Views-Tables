--------------------------------------------------------
--  DDL for Package FA_INV_XFR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INV_XFR_PUB" AUTHID CURRENT_USER as
/* $Header: FAPIXFRS.pls 120.4.12010000.3 2010/02/01 14:35:18 bmaddine ship $   */
/*#
 * Creates asset transfers.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Invoice Transfer API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */



/*#
 * Transfer an invoice between two assets in the same book.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_src_trans_rec The source transaction record
 * @param px_src_asset_hdr_rec The source asset header record
 * @param px_dest_trans_rec The destination transaction record
 * @param px_dest_asset_hdr_rec destination asset header record
 * @param p_inv_tbl table of invoices to transfer
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Asset Source Line
 * @rep:compatibility S
 */
PROCEDURE do_transfer
   (p_api_version             IN     NUMBER,
    p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn              IN     VARCHAR2 := NULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    px_src_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_src_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_dest_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_asset_hdr_rec     IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_inv_tbl                 IN     FA_API_TYPES.inv_tbl_type
   );

-- Bug 8862296 Added new function
FUNCTION do_inv_sub_transfer
   (p_src_trans_rec          IN FA_API_TYPES.trans_rec_type,
    p_src_asset_hdr_rec      IN FA_API_TYPES.asset_hdr_rec_type,
    p_dest_trans_rec         IN FA_API_TYPES.trans_rec_type,
    p_dest_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
    p_inv_tbl                IN FA_API_TYPES.inv_tbl_type,
    p_inv_trans_rec          IN FA_API_TYPES.inv_trans_rec_type,
    p_log_level_rec          IN FA_API_TYPES.log_level_rec_type) return boolean;

END FA_INV_XFR_PUB;

/
