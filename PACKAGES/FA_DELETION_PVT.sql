--------------------------------------------------------
--  DDL for Package FA_DELETION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DELETION_PVT" AUTHID CURRENT_USER as
/* $Header: FAVDELS.pls 120.1.12010000.2 2009/07/19 11:39:50 glchen ship $   */

FUNCTION do_validation
   (px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


END FA_DELETION_PVT;

/
