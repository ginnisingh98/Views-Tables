--------------------------------------------------------
--  DDL for Package FA_CUA_GAIN_LOSS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_GAIN_LOSS_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: FACPX11S.pls 120.0.12010000.2 2009/07/19 12:24:23 glchen ship $ */

  /* created: msiddiqu
     facuas1: needs to be called from calculate_gain_loss ( proc) process
              after updating the status of fa_retirements to DELETED
              Replaces ifa_retirements_aru
              This procedure re-derives the hierarchy attributes of the
              reinstated assets  */

  PROCEDURE facuas1( x_book_type_code in varchar2
                   , x_asset_id       in number
                   , x_retire_status  in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END fa_cua_gain_loss_ext_pkg;

/
