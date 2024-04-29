--------------------------------------------------------
--  DDL for Package Body FA_CUA_WB_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_WB_EXT_PKG" AS
/* $Header: FACPX13MB.pls 120.0.12010000.2 2009/07/19 12:24:51 glchen ship $ */

  /* created: msiddiqu 08-NOV-99
     The procedure facuas1 replaces ifa_additions_hr_ard trigger
     It needs to be called from Asset Workbench
     on deleting the asset record.

     NB. FAXASSET actually calls faxdadb.pls to do the deletes.
         fa_cua_wb_ext_pkg.facuas1 is called from fa_det_add_pkg.delete_asset,
         not the workbench form itself.
  */

  PROCEDURE facuas1 ( x_asset_id in number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    Cursor C1 is
      select asset_hierarchy_id
      from fa_asset_hierarchy
      where asset_id = x_asset_id;
  Begin
    FOR c1_rec in C1 LOOP
      delete from FA_ASSET_HIERARCHY
      where asset_hierarchy_id = c1_rec.asset_hierarchy_id;
    END LOOP;
  End facuas1;


END FA_CUA_WB_EXT_PKG;

/
