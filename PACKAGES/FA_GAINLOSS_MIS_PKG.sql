--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_MIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_MIS_PKG" AUTHID CURRENT_USER AS
/* $Header: fagmiss.pls 120.2.12010000.2 2009/07/19 13:56:31 glchen ship $*/

/*============================================================================
|  NAME         faggfy                                                       |
|                                                                            |
|  FUNCTION     It returns the fiscal year, prorate_calendar, prorate_periods|
|               per_year through the input parameter 'xdate"                 |
|                                                                            |
|  HISTORY      1/12/89         R Rumanang      Created                      |
|               08/09/90        M Chan          Modified for MPL 8           |
|               01/08/97        S Behura        Rewrote into PL/SQL          |
|===========================================================================*/

FUNCTION faggfy(xdate in date, p_cal in out nocopy varchar2,
                pro_month in out nocopy number, fiscalyr in out number,
                fiscal_year_name in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

/*===========================================================================
|  NAME         fagpdi                                                      |
|                                                                           |
|  FUNCTION     Return period information based on the deprn_calendar and   |
|               prorate_calendar                                            |
|                                                                           |
|  HISTORY      01/12/89        R Rumanang      Created                     |
|               06/23/89        R Rumanang      Standarized                 |
|               08/21/90        M Chan          return p_pds_per_year       |
|               04/04/91        M Chan          restructure the function    |
|               01/09/97        S Behura        Rewrote in PL/SQL           |
|===========================================================================*/

Function fagpdi(book_type in varchar2, pds_per_year_ptr in out nocopy number,
                period_type in out nocopy varchar2, cpdname in varchar2,
                cpdnum in out nocopy number, ret_p_date in out date,
                ret_pd in out nocopy number, p_pds_per_year_ptr in out number,
                fiscal_year_name in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

/*===========================================================================
|  NAME         faggbi                                                      |
|                                                                           |
|  FUNCTION     Returns book information based on a retirement-id           |
|                                                                           |
|  HISTORY      1/12/89         R Rumanang      Created                     |
|               6/23/89         R Rumanang      Standarized                 |
|               7/11/89         R Rumanang      Fixed a bug in getting      |
|                                               prorate date. There maybe   |
|                                               possible to have 2 rows     |
|                                               for calendar type year.     |
|               8/8/90          M Chan          Add prorate calendar        |
|               04/02/91        M Chan          Rewrite the routine         |
|               01/09/97        S Behura        Rewrote in PL/SQL           |
|===========================================================================*/

FUNCTION faggbi(bk in out nocopy fa_ret_types.book_struct,
                ret in out nocopy fa_ret_types.ret_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

END FA_GAINLOSS_MIS_PKG;

/
