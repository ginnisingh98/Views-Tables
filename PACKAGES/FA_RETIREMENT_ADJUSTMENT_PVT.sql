--------------------------------------------------------
--  DDL for Package FA_RETIREMENT_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIREMENT_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVRADJS.pls 120.2.12010000.2 2009/07/19 11:29:01 glchen ship $ */

FUNCTION do_retirement_adjustment
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old      IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec               IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code        IN     VARCHAR2,
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER DEFAULT NULL,
    p_proceeds_ccid            IN     NUMBER DEFAULT NULL
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_RETIREMENT_ADJUSTMENT_PVT;

/
