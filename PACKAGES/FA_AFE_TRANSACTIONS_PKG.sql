--------------------------------------------------------
--  DDL for Package FA_AFE_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_AFE_TRANSACTIONS_PKG" AUTHID CURRENT_USER as
  /* $Header: FAAFETRS.pls 120.1.12010000.2 2009/07/19 12:56:58 glchen ship $ */


  -- Author  : SKCHAWLA
  -- Created : 7/26/2005 5:29:22 PM
  -- Purpose : This package will have code for various transaction which needs to be performed on transaction interface table.

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations
  function process_capitalize(p_trans_int_rec      FA_API_TYPES.trans_interface_rec_type,
                              p_asset_id           number,
                              p_new_asset_key_ccid number,
                              p_log_level_rec      IN FA_API_TYPES.log_level_rec_type)
    return boolean;

  function process_dry_hole(p_trans_int_rec      FA_API_TYPES.trans_interface_rec_type,
                            p_asset_id           number,
                            p_new_asset_key_ccid number,
                            p_log_level_rec      IN FA_API_TYPES.log_level_rec_type)
    return boolean;

  function process_expense(p_trans_int_rec FA_API_TYPES.trans_interface_rec_type,
                           p_asset_id      number,
                           p_log_level_rec IN FA_API_TYPES.log_level_rec_type)
    return boolean;

end FA_AFE_TRANSACTIONS_PKG;

/
