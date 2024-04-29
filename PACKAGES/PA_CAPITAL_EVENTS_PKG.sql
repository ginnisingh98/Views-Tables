--------------------------------------------------------
--  DDL for Package PA_CAPITAL_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CAPITAL_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXEVNTS.pls 120.1 2005/08/09 04:16:39 avajain noship $ jpultorak 06-Jan-03*/


  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Capital_Event_Number           NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Event_Name                     VARCHAR2,
                       X_Asset_Allocation_Method        VARCHAR2,
                       X_Event_Period                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE
                      );

  PROCEDURE Lock_Row(X_Rowid                            IN OUT NOCOPY VARCHAR2,
                       X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Capital_Event_Number           NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Event_Name                     VARCHAR2,
                       X_Asset_Allocation_Method        VARCHAR2,
                       X_Event_Period                   VARCHAR2
                       );

  PROCEDURE Update_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Capital_Event_Id               IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Capital_Event_Number           NUMBER,
                       X_Event_Type                     VARCHAR2,
                       X_Event_Name                     VARCHAR2,
                       X_Asset_Allocation_Method        VARCHAR2,
                       X_Event_Period                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE
                      );

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2,
			           X_Capital_Event_Id               NUMBER
                       );

END PA_CAPITAL_EVENTS_PKG;

 

/
