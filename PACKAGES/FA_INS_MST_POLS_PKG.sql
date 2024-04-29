--------------------------------------------------------
--  DDL for Package FA_INS_MST_POLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INS_MST_POLS_PKG" AUTHID CURRENT_USER as
/* $Header: faxinsms.pls 120.2.12010000.2 2009/07/19 10:27:48 glchen ship $ */


PROCEDURE Lock_Row(     X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


PROCEDURE Update_Row(   X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


PROCEDURE Delete_Row(   X_Asset_policy_id        NUMBER,
                        X_Asset_id		 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_INS_MST_POLS_PKG;

/
