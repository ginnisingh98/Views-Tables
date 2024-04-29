--------------------------------------------------------
--  DDL for Package FA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: FAVUTILS.pls 120.2.12010000.6 2009/08/06 13:10:30 bridgway ship $   */

FUNCTION get_asset_fin_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec        IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_transaction_header_id IN     FA_BOOKS.TRANSACTION_HEADER_ID_IN%TYPE DEFAULT NULL,
    p_mrc_sob_type_code     IN     VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null   ) RETURN BOOLEAN;


FUNCTION get_asset_deprn_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_deprn_rec      IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_counter        IN     FA_DEPRN_SUMMARY.period_counter%TYPE DEFAULT NULL,
    p_mrc_sob_type_code     IN     VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null
    ) RETURN BOOLEAN;

FUNCTION get_asset_cat_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_cat_rec        IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
    p_date_effective        IN     FA_ASSET_HISTORY.date_effective%TYPE DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
    ) RETURN BOOLEAN;

FUNCTION get_asset_type_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_type_rec       IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_date_effective        IN     FA_ASSET_HISTORY.date_effective%TYPE DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
    ) RETURN BOOLEAN;

FUNCTION get_asset_desc_rec
   (p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    px_asset_desc_rec       IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION get_inv_rec
   (px_inv_rec              IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2,
    p_set_of_books_id       IN     NUMBER,
    p_inv_trans_rec         IN     FA_API_TYPES.inv_trans_rec_type DEFAULT NULL
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

-----------------------------------------------------------------------------
--  NAME         check_asset_key_req                                         |
--                                                                           |
--  FUNCTION     checks whether the asset key flexfield has any              |
--               required segments                                           |
--                                                                           |
--               -- fdfkfa doesn't appear to allow you to                    |
--                  check the required status of a column                    |
--                  so hard coding this against FND.                         |
-----------------------------------------------------------------------------

FUNCTION check_asset_key_req
   (p_asset_key_chart_id         IN     NUMBER,
    p_asset_key_required            OUT NOCOPY BOOLEAN,
    p_calling_fn                 IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

-- Added for Retirement API
FUNCTION get_current_units
   (p_calling_fn     in  VARCHAR2
   ,p_asset_id       in  NUMBER
   ,x_current_units  out NOCOPY NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION get_latest_trans_date
   (p_calling_fn          in  VARCHAR2
   ,p_asset_id            in  NUMBER
   ,p_book                in  VARCHAR2
   ,x_latest_trans_date   out NOCOPY DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

-- This can be used by other APIs if necessary
FUNCTION get_period_rec
   (p_book           in  varchar2
   ,p_period_counter in  number   default null
   ,p_effective_date in  date     default null
   ,x_period_rec     out NOCOPY FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return BOOLEAN;

-- This populates retirement info.
-- Need to set set_of_books id first
-- Input: retirement_id is required before calling this

FUNCTION get_asset_retire_rec
   (px_asset_retire_rec   in out NOCOPY FA_API_TYPES.asset_retire_rec_type,
    p_mrc_sob_type_code   IN     VARCHAR2,
    p_set_of_books_id     IN     NUMBER
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return BOOLEAN;

-- End of Retirement API

FUNCTION get_corp_book( p_asset_id  IN     NUMBER,
                        p_corp_book IN OUT NOCOPY VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

PROCEDURE load_char_value
            (p_char_old  IN     VARCHAR2,
             p_char_adj  IN     VARCHAR2,
             x_char_new  IN OUT NOCOPY VARCHAR2
           , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE load_date_value
            (p_date_old  IN     VARCHAR2,
             p_date_adj  IN     VARCHAR2,
             x_date_new  IN OUT NOCOPY VARCHAR2
           , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE load_num_value
            (p_num_old   IN     VARCHAR2,
             p_num_adj   IN     VARCHAR2,
             x_num_new   IN OUT NOCOPY VARCHAR2
           , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

FUNCTION check_deprn_run
            (X_book          IN      VARCHAR2,
             X_asset_id      IN      NUMBER  DEFAULT 0,
	     X_deprn_amount  OUT  NOCOPY   NUMBER,
             p_log_level_rec IN  FA_API_TYPES.log_level_rec_type default null) return BOOLEAN;

END FA_UTIL_PVT ;

/
