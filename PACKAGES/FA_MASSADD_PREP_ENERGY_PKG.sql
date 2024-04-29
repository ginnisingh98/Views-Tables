--------------------------------------------------------
--  DDL for Package FA_MASSADD_PREP_ENERGY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_PREP_ENERGY_PKG" AUTHID CURRENT_USER as
/* $Header: FAMAPREPES.pls 120.2.12010000.2 2009/07/19 09:47:40 glchen ship $ */

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  function prep_asset_key_category(p_book_type_code     varchar2,
                                   p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) return boolean;

  function merge_lines(p_book_type_code     varchar2,
                       p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) return boolean;

  function prepare_expense_ccid(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;

  function prepare_location_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                               p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;

  function prepare_attributes(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                              p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;

  function prepare_group_asset_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                  p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
    return boolean;

end FA_MASSADD_PREP_ENERGY_PKG;

/
