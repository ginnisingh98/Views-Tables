--------------------------------------------------------
--  DDL for Package FA_ADD_WARRANTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADD_WARRANTY_PKG" AUTHID CURRENT_USER AS
/* $Header: FAADDWRS.pls 120.1.12010000.2 2009/07/19 12:35:54 glchen ship $ */

  PROCEDURE Update_Table(WR_warranty_id      NUMBER,
                     WR_old_warranty_id      NUMBER,
       		     WR_asset_id         NUMBER,
		     WR_date_effective   DATE DEFAULT sysdate,
		     WR_date_ineffective  DATE,
		     WR_last_update_date DATE,
		     WR_last_updated_by  NUMBER,
		     WR_created_by       NUMBER DEFAULT -1,
		     WR_creation_date    DATE DEFAULT sysdate,
		     WR_last_update_login NUMBER DEFAULT -1,
		     WR_update_row       VARCHAR2,
		     WR_insert_row       VARCHAR2,
		     WR_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


  PROCEDURE Update_Row(X_old_warranty_id      NUMBER,
		     X_asset_id         NUMBER,
		     X_date_ineffective  DATE DEFAULT sysdate,
		     X_last_update_date DATE DEFAULT sysdate,
		     X_last_updated_by  NUMBER DEFAULT -1,
		     X_last_update_login NUMBER DEFAULT -1,
		     X_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



  PROCEDURE Insert_Row(X_warranty_id      NUMBER,
		     X_asset_id         NUMBER,
		     X_date_effective   DATE,
		     X_last_update_date DATE,
		     X_last_updated_by  NUMBER,
		     X_created_by       NUMBER DEFAULT -1,
		     X_creation_date    DATE DEFAULT sysdate,
		     X_last_update_login NUMBER DEFAULT -1,
		     X_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_ADD_WARRANTY_PKG;

/
