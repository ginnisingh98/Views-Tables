--------------------------------------------------------
--  DDL for Package PA_PM_CONTROL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PM_CONTROL_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: PAPMPCRS.pls 120.1 2005/08/19 16:42:57 mwasowic noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Control_Rule_id         IN     NUMBER,
                       X_Pm_product_code         IN     VARCHAR2,
                       X_Field_value_code        IN     VARCHAR2,
                       X_Start_Date              IN     DATE,
                       X_End_Date                IN     DATE,
                       X_Creation_Date           IN     DATE,
                       X_Created_By              IN     NUMBER,
                       X_Last_Update_Date        IN     DATE,
                       X_Last_Updated_By         IN     NUMBER,
                       X_Last_Update_Login       IN     NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                     IN     VARCHAR2,
                     X_Control_Rule_id           IN     NUMBER,
                     X_Field_value_code          IN     VARCHAR2,
                     X_Start_Date                IN     DATE,
                     X_End_Date                  IN     DATE
                    );

  PROCEDURE Update_Row(X_Rowid                   IN     VARCHAR2,
                       X_Start_Date              IN     DATE,
                       X_End_Date                IN     DATE,
                       X_Control_rule_id         IN     NUMBER,
                       X_Last_Update_Date        IN     DATE,
                       X_Last_Updated_By         IN     NUMBER,
                       X_Last_Update_Login       IN     NUMBER
                     );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


END PA_PM_CONTROL_RULES_PKG;

 

/
