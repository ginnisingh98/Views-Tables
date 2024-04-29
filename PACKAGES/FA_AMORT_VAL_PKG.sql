--------------------------------------------------------
--  DDL for Package FA_AMORT_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_AMORT_VAL_PKG" AUTHID CURRENT_USER as
/* $Header: FAAMRTVS.pls 120.2.12010000.2 2009/07/19 12:37:49 glchen ship $ */

/*
---------------------------------------------------------------------------------------

   Name: val_amort_date

   Description:
        This function is called from both books form in asset workbench
        and asset hierarchy/category forms in asset hierarchy to validate
        amortization start date entered by user.

   Parameters
        x_amort_start_date   amortization start date user entered
        x_book               book
        x_asset_id           asset_id
        x_dpis               date placed in service
        x_txns_exist         set to Y if any txn exists between amortization start date
                             and current period
        x_err_code           returns error

----------------------------------------------------------------------------------------
*/



FUNCTION val_amort_date(x_amort_start_date           date,
                        x_new_amort_start_date   out nocopy date,
                        x_book                       varchar2,
                        x_asset_id                   number,
                        x_dpis                       date,
                        x_txns_exist         in  out nocopy varchar2,
                        x_err_code               out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

END FA_AMORT_VAL_PKG;

/
