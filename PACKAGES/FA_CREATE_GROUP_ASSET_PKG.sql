--------------------------------------------------------
--  DDL for Package FA_CREATE_GROUP_ASSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CREATE_GROUP_ASSET_PKG" AUTHID CURRENT_USER as
  /* $Header: FACGRPAS.pls 120.3.12010000.2 2009/07/19 09:41:33 glchen ship $ */

  -- Author  : SKCHAWLA
  -- Created : 6/20/2005 2:32:23 AM
  -- Purpose : Package to create the group assets using mass additions lines

  -- Public type declarations
  type group_asset_rec_type is record(
    asset_id         number,
    mass_addition_id number,
    rec_mode         varchar2(40),
    book_type_code   varchar2(30),
    group_asset_id   number);
  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations
  function create_group_asset(px_group_asset_rec IN out NOCOPY group_asset_rec_type,
                              p_log_level_rec    IN FA_API_TYPES.log_level_rec_type default null)
    return boolean;

end FA_CREATE_GROUP_ASSET_PKG;

/
