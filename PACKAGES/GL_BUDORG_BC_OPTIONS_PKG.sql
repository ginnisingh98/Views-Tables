--------------------------------------------------------
--  DDL for Package GL_BUDORG_BC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDORG_BC_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibebcs.pls 120.3.12010000.1 2008/07/28 13:23:33 appldev ship $ */
--
-- Package
--   gl_budorg_bc_options_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budorg_bc_options
-- History
--   28-06-05  	A Govil	Created

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Funds_Check_Level_Code               VARCHAR2,
                     X_Amount_Type                          VARCHAR2,
                     X_Boundary_Code                        VARCHAR2,
                     X_Funding_Budget_Version_Id            NUMBER,
                     X_Range_Id                             NUMBER
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Funds_Check_Level_Code                 VARCHAR2,
                   X_Amount_Type                            VARCHAR2,
                   X_Boundary_Code                          VARCHAR2,
                   X_Funding_Budget_Version_Id              NUMBER,
                   X_Range_Id                               NUMBER
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Funds_Check_Level_Code              VARCHAR2,
                     X_Amount_Type                         VARCHAR2,
                     X_Boundary_Code                       VARCHAR2,
                     X_Funding_Budget_Version_Id           NUMBER,
                     X_Range_Id                            NUMBER
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE delete_budorg_bc_options(xrange_id NUMBER);

PROCEDURE Insert_BC_Options(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                            X_Last_Update_Date                     DATE,
                            X_Last_Updated_By                      NUMBER,
                            X_Creation_Date                        DATE,
                            X_Created_By                           NUMBER,
                            X_Last_Update_Login                    NUMBER,
                            X_Funds_Check_Level_Code               VARCHAR2,
                            X_Amount_Type                          VARCHAR2,
                            X_Boundary_Code                        VARCHAR2,
                            X_Funding_Budget_Version_Id            NUMBER,
                            X_Range_Id                             NUMBER
                     );

PROCEDURE Update_BC_Options(X_Range_Id                             NUMBER,
                            X_Last_Update_Date                     DATE,
                            X_Last_Updated_By                      NUMBER,
                            X_Last_Update_Login                    NUMBER,
                            X_Funds_Check_Level_Code               VARCHAR2,
                            X_Amount_Type                          VARCHAR2,
                            X_Boundary_Code                        VARCHAR2,
                            X_Funding_Budget_Version_Id            NUMBER
                     );


END gl_budorg_bc_options_pkg;

/
