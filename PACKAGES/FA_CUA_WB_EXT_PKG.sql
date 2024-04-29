--------------------------------------------------------
--  DDL for Package FA_CUA_WB_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_WB_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: FACPX13S.pls 120.0.12010000.2 2009/07/19 12:25:21 glchen ship $ */

   /* created: msiddiqu 08-NOV-99
     The procedure facuas1 replaces ifa_additions_hr_ard trigger
     It needs to be called from Asset Workbench
     on deleting the asset record  */
  PROCEDURE facuas1 ( x_asset_id in number , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_CUA_WB_EXT_PKG;

/
