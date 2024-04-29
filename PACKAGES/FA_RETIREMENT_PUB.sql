--------------------------------------------------------
--  DDL for Package FA_RETIREMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIREMENT_PUB" AUTHID CURRENT_USER as
/* $Header: FAPRETS.pls 120.2.12010000.2 2009/07/19 12:01:52 glchen ship $   */
/*#
 * Creates asset retirements, reinstatements, cancellation of retirements, and
 * cancellation of reinstatements.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Retirement/Reinstatement API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FA_ASSET
 * @rep:metalink 206476.1 Retirements/Reinstatements API Documentation Supplement
 */


/*#
 * Partially or fully retire an asset in a specific book.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list flag
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param p_calling_fn The calling function
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_trans_rec The transaction record
 * @param px_dist_trans_rec The distribution transaction record
 * @param px_asset_hdr_rec The asset header record
 * @param px_asset_retire_rec asset retirement record
 * @param p_asset_dist_tbl table of asset assignments
 * @param p_subcomp_tbl table of subcomponents
 * @param p_inv_tbl table of invoices
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retire Asset
 * @rep:compatibility S
 */
PROCEDURE do_retirement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
   ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
   ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
   );


/*#
 * Undo a retirement previously entered against an asset.
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
 * @param px_asset_retire_rec The asset retirement record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel Asset Retirement
 * @rep:compatibility S
 */
PROCEDURE undo_retirement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   );



/*#
 * Reinstate a retirement previously entered against an asset.
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
 * @param px_asset_retire_rec The asset retirement record
 * @param p_asset_dist_tbl The table of asset assignments
 * @param p_subcomp_tbl The table of subcomponents
 * @param p_inv_tbl The table of invoices
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Reinstate Asset
 * @rep:compatibility S
 */
PROCEDURE do_reinstatement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
   ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
   ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
   );



/*#
 * Undo the reinstatement of a retirement previously entered against an asset.
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
 * @param px_asset_retire_rec The asset retirement record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel Asset Reinstatement
 * @rep:compatibility S
 */
PROCEDURE undo_reinstatement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   );


END FA_RETIREMENT_PUB;

/
