--------------------------------------------------------
--  DDL for Package FA_QUERY_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_QUERY_BALANCES_PKG" AUTHID CURRENT_USER as
/* $Header: faxqbals.pls 120.1.12010000.2 2009/07/19 10:00:47 glchen ship $ */


PROCEDURE QUERY_BALANCES
                (X_ASSET_ID                      NUMBER,
                 X_BOOK                          VARCHAR2,
                 X_PERIOD_CTR                    NUMBER   DEFAULT 0,
                 X_DIST_ID                       NUMBER   DEFAULT 0,
                 X_RUN_MODE                      VARCHAR2 DEFAULT 'STANDARD',
                 X_COST                      OUT NOCOPY NUMBER,
                 X_DEPRN_RSV                 OUT NOCOPY NUMBER,
                 X_REVAL_RSV                 OUT NOCOPY NUMBER,
                 X_YTD_DEPRN                 OUT NOCOPY NUMBER,
                 X_YTD_REVAL_EXP             OUT NOCOPY NUMBER,
                 X_REVAL_DEPRN_EXP           OUT NOCOPY NUMBER,
                 X_DEPRN_EXP                 OUT NOCOPY NUMBER,
                 X_REVAL_AMO                 OUT NOCOPY NUMBER,
                 X_PROD                      OUT NOCOPY NUMBER,
                 X_YTD_PROD                  OUT NOCOPY NUMBER,
                 X_LTD_PROD                  OUT NOCOPY NUMBER,
                 X_ADJ_COST                  OUT NOCOPY NUMBER,
                 X_REVAL_AMO_BASIS           OUT NOCOPY NUMBER,
                 X_BONUS_RATE                OUT NOCOPY NUMBER,
                 X_DEPRN_SOURCE_CODE         OUT NOCOPY VARCHAR2,
                 X_ADJUSTED_FLAG             OUT NOCOPY BOOLEAN,
                 X_TRANSACTION_HEADER_ID  IN     NUMBER DEFAULT -1,
                 X_BONUS_DEPRN_RSV           OUT NOCOPY NUMBER,
                 X_BONUS_YTD_DEPRN           OUT NOCOPY NUMBER,
                 X_BONUS_DEPRN_AMOUNT        OUT NOCOPY NUMBER,
                 X_IMPAIRMENT_RSV            OUT NOCOPY NUMBER,
                 X_YTD_IMPAIRMENT            OUT NOCOPY NUMBER,
                 X_IMPAIRMENT_AMOUNT         OUT NOCOPY NUMBER,
                 X_CAPITAL_ADJUSTMENT        OUT NOCOPY NUMBER,  -- Bug 6666666
                 X_GENERAL_FUND              OUT NOCOPY NUMBER,
                 X_MRC_SOB_TYPE_CODE          IN VARCHAR2,
                 X_SET_OF_BOOKS_ID            IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type); -- Bug 6666666



PROCEDURE ADD_ADJ_TO_DEPRN
                 (X_ADJ_DRS     IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                  X_DEST_DRS    IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                  X_SUCCESS        OUT NOCOPY BOOLEAN,
                  X_CALLING_FN         VARCHAR2,
                  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE QUERY_BALANCES_INT
                (X_DPR_ROW               IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_RUN_MODE                     VARCHAR2,
                 X_DEBUG                        BOOLEAN,
                 X_SUCCESS                  OUT NOCOPY BOOLEAN,
                 X_CALLING_FN                   VARCHAR2,
                 X_TRANSACTION_HEADER_ID IN     NUMBER  DEFAULT  -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE GET_PERIOD_INFO
                (X_BOOK                VARCHAR2,
                 X_CUR_PER_CTR  IN OUT NOCOPY NUMBER,
                 X_CUR_FY       IN OUT NOCOPY NUMBER,
                 X_NUM_PERS_FY  IN OUT NOCOPY NUMBER,
                 X_SUCCESS         OUT NOCOPY BOOLEAN,
                 X_CALLING_FN          VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE QUERY_DEPRN_SUMMARY
                (X_DPR_ROW       IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR IN OUT NOCOPY NUMBER,
                 X_RUN_MODE             VARCHAR2,
                 X_SUCCESS          OUT NOCOPY BOOLEAN,
                 X_CALLING_FN           VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE QUERY_DEPRN_DETAIL
                (X_DPR_ROW       IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR IN OUT NOCOPY NUMBER,
                 X_IS_ACC_NULL   IN OUT NOCOPY BOOLEAN,
                 X_RUN_MODE             VARCHAR2,
                 X_SUCCESS          OUT NOCOPY BOOLEAN,
                 X_CALLING_FN           VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE GET_ADJUSTMENTS_INFO
                (X_ADJ_ROW               IN OUT NOCOPY FA_STD_TYPES.FA_DEPRN_ROW_STRUCT,
                 X_FOUND_PER_CTR         IN OUT NOCOPY NUMBER,
                 X_RUN_MODE                     VARCHAR2,
                 X_TRANSACTION_HEADER_ID        NUMBER,
                 X_SUCCESS                  OUT NOCOPY BOOLEAN,
                 X_CALLING_FN                   VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_QUERY_BALANCES_PKG;

/
