--------------------------------------------------------
--  DDL for Package FA_POLISH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_POLISH_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVPOLS.pls 120.4.12010000.2 2009/07/19 11:28:05 glchen ship $ */

CALLING_MODE             varchar2(10);
AMORTIZATION_START_DATE  date;
ADJUSTMENT_AMOUNT        number;

PROCEDURE Calc_Polish_Rate_Cost (
                    p_Book_Type_Code         IN            VARCHAR2,
                    p_Asset_Id               IN            NUMBER,
                    p_Polish_Rule            IN            NUMBER,
                    p_Deprn_Factor           IN            NUMBER,
                    p_Alternate_Deprn_Factor IN            NUMBER,
                    p_Polish_Adj_Calc_Basis_Flag
                                             IN            VARCHAR2,
                    p_Rate                   IN            NUMBER,
                    p_Depreciate_Flag        IN            VARCHAR2,
                    p_Adjusted_Cost          IN            NUMBER,
                    p_Recoverable_Cost       IN            NUMBER,
                    p_Adjusted_Recoverable_Cost
                                             IN            NUMBER,
                    p_Fiscal_Year            IN            NUMBER,
                    p_Period_Num             IN            NUMBER,
                    p_Periods_Per_Year       IN            NUMBER,
                    p_Year_Retired           IN            VARCHAR2,
                    p_MRC_Sob_Type_Code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_Rate                      OUT NOCOPY NUMBER,
                    x_Depreciate_Flag           OUT NOCOPY VARCHAR2,
                    x_Adjusted_Cost             OUT NOCOPY NUMBER,
                    x_Adjusted_Recoverable_Cost
                                                OUT NOCOPY NUMBER,
                    x_Success                   OUT NOCOPY INTEGER,
                    p_Calling_Fn             IN            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

END FA_POLISH_PVT;

/
