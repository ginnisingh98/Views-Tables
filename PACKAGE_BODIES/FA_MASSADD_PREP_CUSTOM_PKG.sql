--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_PREP_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_PREP_CUSTOM_PKG" as
  /* $Header: FAMAPREPCB.pls 120.2.12010000.2 2009/07/19 09:44:21 glchen ship $ */

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Function and procedure implementations
  function prepare_attributes(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                              p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
  begin
    null;
    return true;
  end;

end FA_MASSADD_PREP_CUSTOM_PKG;

/
