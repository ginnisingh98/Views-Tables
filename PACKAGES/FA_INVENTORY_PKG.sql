--------------------------------------------------------
--  DDL for Package FA_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INVENTORY_PKG" AUTHID CURRENT_USER as
/* $Header: faxpidms.pls 120.2.12010000.2 2009/07/19 09:59:12 glchen ship $ */


PROCEDURE Lock_Row(X_Rowid			IN OUT NOCOPY  VARCHAR2,
		   X_inventory_id			NUMBER,
	           X_Calling_Fn			        VARCHAR2
		  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
		       X_inventory_id			NUMBER,
		       X_unit_rec_mth_lookup_code	VARCHAR2,
		       X_loc_rec_mth_lookup_code	VARCHAR2,
		       X_status_lookup_code		VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
		       X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_INVENTORY_PKG;

/
