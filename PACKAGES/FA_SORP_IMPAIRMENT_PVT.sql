--------------------------------------------------------
--  DDL for Package FA_SORP_IMPAIRMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SORP_IMPAIRMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVSIMPS.pls 120.3.12010000.1 2009/07/21 12:37:46 glchen noship $ */


FUNCTION create_acct_impair_class (
    p_impair_class          IN VARCHAR2,
    p_impair_loss_acct      IN VARCHAR2,
    p_impairment_amount     IN NUMBER,
    p_reval_reserve_adj     IN NUMBER,
    px_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


-- This function is used to impairment accounting entries for SORP Compliance
-- Project
FUNCTION create_sorp_imp_acct (
    px_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_impairment_amount     IN NUMBER,
    p_reval_reserve_adj     IN NUMBER,

    p_impair_class          IN VARCHAR2,
    p_impair_loss_acct      IN VARCHAR2,
    p_split_impair_flag     IN VARCHAR2,

    p_split1_impair_class   IN VARCHAR2,
    p_split1_loss_amount    IN NUMBER,
    p_split1_reval_reserve  IN NUMBER,
    p_split1_loss_acct      IN VARCHAR2,

    p_split2_impair_class   IN VARCHAR2,
    p_split2_loss_amount    IN NUMBER,
    p_split2_reval_reserve  IN NUMBER,
    p_split2_loss_acct      IN VARCHAR2,

    p_split3_impair_class   IN VARCHAR2,
    p_split3_loss_amount    IN NUMBER,
    p_split3_reval_reserve  IN NUMBER,
    p_split3_loss_acct      IN VARCHAR2,

    p_created_by            IN NUMBER,
    p_creation_date         IN DATE

, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;



FUNCTION sorp_processing( p_request_id            IN NUMBER
                        , p_impairment_id         IN NUMBER
                        , p_mrc_sob_type_code     IN VARCHAR2
                        , p_set_of_books_id       IN NUMBER
                        , p_book_type_code        IN VARCHAR2
                        , p_precision             IN NUMBER

, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_SORP_IMPAIRMENT_PVT;

/
