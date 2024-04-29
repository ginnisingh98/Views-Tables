--------------------------------------------------------
--  DDL for Package FA_CUA_TRX_APPROVAL_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_TRX_APPROVAL_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: FACPX09S.pls 120.0.12010000.2 2009/07/19 12:23:27 glchen ship $ */

 -- created: msiddiqu 02-NOV-99


  -- replaces fa_transaction_headers_hr_bri
  -- returns TRUE if transaction allowed
  FUNCTION facuas1 ( x_txn_type_code in varchar2
                   , x_book_type_code in varchar2
                   , x_asset_id in number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

  -- replaces the ifa_book_controls_bru trigger
  -- returns TRUE if transaction allowed
  FUNCTION facuas2 ( x_book_type_code in varchar2
                    , x_deprn_status   in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_CUA_TRX_APPROVAL_EXT_PKG;

/
