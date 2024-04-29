--------------------------------------------------------
--  DDL for Package Body FA_CUA_TRX_HEADERS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_TRX_HEADERS_EXT_PKG" AS
/* $Header: FACPX14MB.pls 120.0.12010000.2 2009/07/19 12:25:53 glchen ship $ */

 -- created: msiddiqu 02-NOV-99
/* msiddiqu : to be called after inserting into
                fa_transaction_headers for any txn_type
                Storing Life Derivation Information in a Parallel table
                FA_LIFE_DERIVATION_INFO. The Life Derivation info is
                stored in 2 package variables initialized in
                the package body of FA_CUA_ASSET_APIS which has the logic
                for deriving life based on the Inheritance Rules */

  -- replaces fa_transaction_headers_hr_ari
  -- also replaces part of logic from fa_transaction_headers_hr_bri
  PROCEDURE facuas1 ( x_transaction_header_id in number
                    , x_asset_id in number
                    , x_book_type_code in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
  BEGIN

  if fa_cua_asset_apis.g_derive_from_entity is not null then
     insert into
     fa_life_derivation_info ( TRANSACTION_HEADER_ID,
                                ASSET_ID ,
                                BOOK_TYPE_CODE ,
                                DERIVED_FROM_ENTITY_ID ,
                                DERIVED_FROM_ENTITY )
                        values (x_transaction_header_id,
                                x_asset_id,
                                x_book_type_code,
                                fa_cua_asset_apis.g_derive_from_entity_value,
                                rtrim(fa_cua_asset_apis.g_derive_from_entity,' '));
  end if;

  END facuas1;

END FA_CUA_TRX_HEADERS_EXT_PKG;

/
