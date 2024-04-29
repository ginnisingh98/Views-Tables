--------------------------------------------------------
--  DDL for Package GL_SUMMARY_BC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SUMMARY_BC_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistbcs.pls 120.2.12010000.1 2008/07/28 13:26:47 appldev ship $ */
--
-- Package
--   gl_summary_bc_options_pkg
-- Purpose
--   To contain validation and insertion routines for gl_summary_bc_options
-- History
--  01-07-05  	A Govil	Created


 -- Procedure
 --  Insert_Row
 -- Purpose
 --  Insert a new row into GL_SUMMARY_BC_OPTIONS
 -- History
 --  04/07/05 A Govil Created
 -- Example
 --  GL_SUMMARY_BC_OPTIONS_PKG.Insert_Row;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Funds_Check_Level_Code              VARCHAR2,
                     X_Dr_Cr_Code                          VARCHAR2,
                     X_Amount_Type                         VARCHAR2,
                     X_Boundary_Code                       VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Funding_Budget_Version_Id           NUMBER
                     );

 -- Procedure
 --  Lock_Row
 -- Purpose
 --  Lock a row in GL_SUMMARY_BC_OPTIONS
 -- History
 --  04/07/05 A Govil	Created
 -- Example
 --  GL_SUMMARY_BC_OPTIONS_PKG.Lock_Row;

PROCEDURE Lock_Row(X_Rowid                               VARCHAR2,
                   X_Funds_Check_Level_Code              VARCHAR2,
                   X_Dr_Cr_Code                          VARCHAR2,
                   X_Amount_Type                         VARCHAR2,
                   X_Boundary_Code                       VARCHAR2,
                   X_Template_Id                         NUMBER,
                   X_Last_Update_Date                    DATE,
                   X_Last_Updated_by                     NUMBER,
                   X_Created_By                          NUMBER,
                   X_Creation_Date                       DATE,
                   X_Last_Update_Login                   NUMBER,
                   X_Funding_Budget_Version_Id           NUMBER
                   );

 -- Procedure
 --  Insert_BC_Options
 -- Purpose
 --  API given to Isetup API to insert a new row into GL_SUMMARY_BC_OPTIONS
 -- History
 --  14/12/06 A Govil Created
 -- Example
 --  GL_SUMMARY_BC_OPTIONS_PKG.Insert_BC_Options;

PROCEDURE Insert_BC_Options(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                            X_Funds_Check_Level_Code              VARCHAR2,
                            X_Dr_Cr_Code                          VARCHAR2,
                            X_Amount_Type                         VARCHAR2,
                            X_Boundary_Code                       VARCHAR2,
                            X_Template_Id                         NUMBER,
                            X_Last_Update_Date                    DATE,
                            X_Last_Updated_by                     NUMBER,
                            X_Created_By                          NUMBER,
                            X_Creation_Date                       DATE,
                            X_Last_Update_Login                   NUMBER,
                            X_Funding_Budget_Version_Id           NUMBER
                           );

END gl_summary_bc_options_pkg;

/
