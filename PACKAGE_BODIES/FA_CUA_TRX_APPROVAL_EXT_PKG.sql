--------------------------------------------------------
--  DDL for Package Body FA_CUA_TRX_APPROVAL_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_TRX_APPROVAL_EXT_PKG" AS
/* $Header: FACPX09MB.pls 120.0.12010000.2 2009/07/19 12:22:59 glchen ship $ */

  -- created: msiddiqu  01-NOV-99

  -- replaces fa_transaction_headers_hr_bri
  -- returns TRUE if transaction allowed
  FUNCTION facuas1 ( x_txn_type_code in varchar2
                   , x_book_type_code in varchar2
                   , x_asset_id in number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

    v_result BOOLEAN:= FALSE;
    v_error_code varchar2(630);

  BEGIN
    if x_txn_type_code IN ( 'ADJUSTMENT'
                        -- , 'CIP ADDITION'
                           , 'FULL RETIREMENT'
                           , 'PARTIAL RETIREMENT'
                           , 'RECLASS'
                           , 'REINSTATEMENT'
                           , 'REVALUATION'
                           , 'TRANSFER'
                           , 'UNIT ADJUSTMENT' ) then

            -- bugfix 1680737 msiddiqu 08-Mar-2001
            -- modified call to check_pending_batch
            v_result:=
              fa_cua_hr_retirements_pkg.check_pending_batch( x_calling_function  => 'TRANSACTION'
                                                        , x_book_type_code   => x_book_type_code
                                                        , x_event_code       => null
                                                        , x_asset_id         => x_asset_id
                                                        , x_node_id          => null
                                                        , x_category_id      => null
                                                        , x_attribute        => null
                                                        , x_conc_request_id  => null
                                                        , x_status           => v_error_code
                                                         , p_log_level_rec => p_log_level_rec);
         end if;

       if (v_result) then
           -- pending batch found
           return FALSE; -- transaction not allowed
       else
           return TRUE;  -- transaction allowed
       end if;
  END facuas1;



  /* replaces the ifa_book_controls_bru trigger */
  -- returns TRUE if transaction allowed
  FUNCTION facuas2 ( x_book_type_code in varchar2
                   , x_deprn_status   in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    v_result BOOLEAN:= FALSE;
    v_error_code varchar2(630);
  BEGIN

    if x_deprn_status = 'R' then

       -- bugfix 1680737 msiddiqu 08-Mar-2001
       -- modified call to check_pending_batch
      v_result :=
      fa_cua_hr_retirements_pkg.check_pending_batch('DEPRECIATION'
                                                , x_book_type_code
                                                , null, null, null
                                                , null, null, null, v_error_code, p_log_level_rec => p_log_level_rec);
    end if;

    if (v_result) then
      return FALSE; -- transaction not allowed
    else
      return TRUE;  -- transaction allowed
    end if;

  END facuas2;

END FA_CUA_TRX_APPROVAL_EXT_PKG;

/
