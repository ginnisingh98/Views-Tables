--------------------------------------------------------
--  DDL for Package FA_CUA_EXT_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_EXT_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: FACETFRMS.pls 120.3.12010000.3 2009/08/20 14:18:53 bridgway ship $ */
--
--
PROCEDURE Lock_Row(
        X_Rowid                         VARCHAR2,
        X_Mass_External_Transfer_Id     NUMBER   DEFAULT NULL,
        X_From_Asset_Id                 NUMBER   DEFAULT NULL,
        X_Transaction_Status            VARCHAR2 DEFAULT NULL,
        X_Book_Type_Code                VARCHAR2 DEFAULT NULL,
        X_Transaction_Type              VARCHAR2 DEFAULT NULL,
        X_Batch_Name                    VARCHAR2 DEFAULT NULL,
        X_Description                   VARCHAR2 DEFAULT NULL,
        X_Transaction_Date_Entered      DATE     DEFAULT NULL,
        X_External_Reference_Num        VARCHAR2 DEFAULT NULL,
        X_To_Asset_Id                   NUMBER   DEFAULT NULL,
        X_To_Location_Id                NUMBER   DEFAULT NULL,
        X_To_GL_CCID                    NUMBER   DEFAULT NULL,
        X_To_Employee_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Units                NUMBER   DEFAULT NULL,
        X_Source_Line_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Amount               NUMBER   DEFAULT NULL,
        X_From_Distribution_Id          NUMBER   DEFAULT NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);
--
--
PROCEDURE Update_Row(
        X_Rowid                         VARCHAR2,
        X_Mass_External_Transfer_Id     NUMBER   DEFAULT NULL,
        X_From_Asset_Id                 NUMBER   DEFAULT NULL,
        X_Transaction_Status            VARCHAR2 DEFAULT NULL,
        X_Book_Type_Code                VARCHAR2 DEFAULT NULL,
        X_Transaction_Type              VARCHAR2 DEFAULT NULL,
        X_Batch_Name                    VARCHAR2 DEFAULT NULL,
        X_Description                   VARCHAR2 DEFAULT NULL,
        X_Transaction_Date_Entered      DATE     DEFAULT NULL,
        X_External_Reference_Num        VARCHAR2 DEFAULT NULL,
        X_To_Asset_Id                   NUMBER   DEFAULT NULL,
        X_To_Location_Id                NUMBER   DEFAULT NULL,
        X_To_GL_CCID                    NUMBER   DEFAULT NULL,
        X_To_Employee_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Units                NUMBER   DEFAULT NULL,
        X_Source_Line_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Amount               NUMBER   DEFAULT NULL,
        X_From_Distribution_Id          NUMBER   DEFAULT NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);
--
--
END FA_CUA_EXT_TRANSFERS_PKG;

/
