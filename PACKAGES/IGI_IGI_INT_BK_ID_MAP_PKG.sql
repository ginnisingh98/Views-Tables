--------------------------------------------------------
--  DDL for Package IGI_IGI_INT_BK_ID_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_INT_BK_ID_MAP_PKG" AUTHID CURRENT_USER as
-- $Header: igiintcs.pls 120.4.12000000.1 2007/09/12 09:37:37 mbremkum ship $
--

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Feeder_Book_Id                 VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Feeder_Book_Id                   VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Feeder_Book_Id                 VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_IGI_INT_BK_ID_MAP_PKG;

 

/
