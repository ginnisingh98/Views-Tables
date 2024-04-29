--------------------------------------------------------
--  DDL for Package FA_DELETION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DELETION_PUB" AUTHID CURRENT_USER as
/* $Header: FAPDELS.pls 120.3.12010000.2 2009/07/19 14:28:28 glchen ship $   */
/*#
 * Deletes assets from the system.
 * @rep:scope public
 * @rep:product FA
 * @rep:lifecycle active
 * @rep:displayname Delete Asset API
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY FA_ASSET
 */


/*#
 * Delete an asset from the system.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param px_asset_hdr_rec The asset header record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Asset
 * @rep:compatibility N
 */
PROCEDURE do_delete
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type
   );

END FA_DELETION_PUB;

/
