--------------------------------------------------------
--  DDL for Package FA_MASSADD_PREP_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_PREP_DEFAULT_PKG" AUTHID CURRENT_USER as
/* $Header: FAMAPREPDS.pls 120.2.12010000.2 2009/07/19 09:46:18 glchen ship $ */

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations
  function prepare_asset_category_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                     p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;
  function prepare_expense_ccid(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;
  function prepare_attributes(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                              p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;

end FA_MASSADD_PREP_DEFAULT_PKG;

/
