--------------------------------------------------------
--  DDL for Package FA_CUA_MASS_UPDATE2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_MASS_UPDATE2_PKG" AUTHID CURRENT_USER as
/* $Header: FACMUP2MS.pls 120.1.12010000.2 2009/07/19 12:21:54 glchen ship $*/
/*===========================================================================
 PACKAGE NAME:          FA_CUA_MASS_UPDATE2_PKG as

 DESCRIPTION:           This package contains APIs For Mass UpdateProcess

 AUTHOR:                Gautam Prothia

 DATE:                  08-Jan-1999
===========================================================================*/
g_override_book_check varchar2(3) ;

Procedure UPDATE_LIFE
  (x_asset_id in number,
  x_book_type_code in varchar2,
  x_old_life in number,
  x_new_life in out nocopy number,
  x_amortization_flag in varchar2,
  x_amortization_date in date,
  x_err_code in out nocopy varchar2 ,
  x_err_stage in out nocopy varchar2 ,
  x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_CUA_MASS_UPDATE2_PKG;

/
