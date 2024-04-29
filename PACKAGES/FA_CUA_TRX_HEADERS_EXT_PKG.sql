--------------------------------------------------------
--  DDL for Package FA_CUA_TRX_HEADERS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_TRX_HEADERS_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: FACPX14S.pls 120.0.12010000.2 2009/07/19 12:26:22 glchen ship $ */

 -- created: msiddiqu 02-NOV-99

  -- Replaces ifa_transaction_headers_ari trigger
  PROCEDURE facuas1 ( x_transaction_header_id in number
                    , x_asset_id              in number
                    , x_book_type_code        in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

END FA_CUA_TRX_HEADERS_EXT_PKG;

/
