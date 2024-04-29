--------------------------------------------------------
--  DDL for Package FA_IMPAIRMENT_PREV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_IMPAIRMENT_PREV_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVIMPWS.pls 120.3.12010000.1 2009/07/21 12:37:39 glchen noship $ */

TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; -- Bug# 7000391
--*********************** Private functions ******************************--
-- private declaration for books (mrc) wrapper
FUNCTION process_depreciation(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_worker_id         IN NUMBER,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_imp_period_rec    IN FA_API_TYPES.period_rec_type,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


FUNCTION calc_total_nbv(
              p_request_id            IN NUMBER
            , p_book_type_code        IN VARCHAR2
            , p_transaction_date      IN DATE
            , p_period_rec            IN FA_API_TYPES.period_rec_type
            , p_mrc_sob_type_code     IN VARCHAR2
            , p_set_of_books_id       IN NUMBER
            , p_calling_fn            IN VARCHAR2
	    , p_asset_id              OUT NOCOPY  tab_num_type --Bug# 7000391
       	    , p_nbv              OUT NOCOPY  tab_num_type --Bug# 7000391
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION process_history(p_request_id        number
                       , p_impairment_id     number
                       , p_asset_id          number
                       , p_book_type_code    varchar2
                       , p_period_rec        FA_API_TYPES.period_rec_type
                       , p_imp_period_rec    FA_API_TYPES.period_rec_type
                       , p_date_placed_in_service date
                       , x_dpr_out           OUT NOCOPY fa_std_types.dpr_out_struct
                       , x_dpr_in            OUT NOCOPY fa_std_types.dpr_struct
                       , p_mrc_sob_type_code varchar2
                       , p_calling_fn        varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calculate_catchup(p_request_id        number
                         , p_book_type_code    IN VARCHAR2
                         , p_worker_id         IN NUMBER
                         , p_period_rec        IN FA_API_TYPES.period_rec_type
                         , p_imp_period_rec    IN FA_API_TYPES.period_rec_type
                         , p_mrc_sob_type_code IN VARCHAR2
                         , p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_IMPAIRMENT_PREV_PVT;

/
