--------------------------------------------------------
--  DDL for Package FA_TAX_RSV_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TAX_RSV_ADJ_PUB" AUTHID CURRENT_USER as
/* $Header: FAPTRSVS.pls 120.0.12010000.2 2009/07/19 09:52:09 glchen ship $   */

PROCEDURE do_tax_rsv_adj
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
    p_asset_tax_rsv_adj_rec    IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type
   );

END FA_TAX_RSV_ADJ_PUB;

/
