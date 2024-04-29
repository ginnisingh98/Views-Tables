--------------------------------------------------------
--  DDL for Package FA_SORP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SORP_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: FAVSPUTS.pls 120.2.12010000.1 2009/07/21 12:37:49 glchen noship $   */


-- This function accepts a Book Type Code and returns True if SORP
-- is enabled for that book. False otherwise.
FUNCTION IS_SORP_ENABLED(p_book_type_code  FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION create_sorp_neutral_acct (
    p_amount                IN NUMBER,
    p_reversal              IN VARCHAR2,
    p_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE,
    p_last_update_date      IN DATE,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_who_mode              IN VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

FUNCTION create_sorp_neutral_acct (
    p_amount                IN NUMBER,
    p_reversal              IN VARCHAR2,
    p_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

END FA_SORP_UTIL_PVT;

/
