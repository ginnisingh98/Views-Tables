--------------------------------------------------------
--  DDL for Package PA_EVENT_TYPE_OUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EVENT_TYPE_OUS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXETOUS.pls 120.1 2005/08/19 17:13:28 mwasowic noship $ */


  PROCEDURE Insert_Row(X_ROWID            IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Event_Type                     VARCHAR2,
                       X_Output_tax_code                VARCHAR2,
		       X_ORG_ID                         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
                     );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Event_Type                       VARCHAR2,
                     X_Output_tax_code                  VARCHAR2,
		     X_ORG_ID                           NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Event_Type                     VARCHAR2,
                       X_Output_tax_code                VARCHAR2,
		       X_ORG_ID                         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_EVENT_TYPE_OUS_PKG;
 

/
