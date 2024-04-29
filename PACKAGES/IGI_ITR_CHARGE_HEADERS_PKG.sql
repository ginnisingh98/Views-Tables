--------------------------------------------------------
--  DDL for Package IGI_ITR_CHARGE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_CHARGE_HEADERS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrss.pls 120.3.12000000.1 2007/09/12 10:32:46 mbremkum ship $
--

  PROCEDURE  Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                        X_It_Header_Id          IN OUT NOCOPY NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  );


  PROCEDURE    Lock_Row(X_Rowid                 VARCHAR2,
                        X_It_Header_Id          NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  );


  PROCEDURE  Update_Row(X_Rowid                 VARCHAR2,
                        X_It_Header_Id          NUMBER,
                        X_Set_Of_Books_Id       NUMBER,
                        X_Name                  VARCHAR2,
                        X_It_Period_Name        VARCHAR2,
                        X_Submit_Flag           VARCHAR2,
                        X_It_Originator_Id      VARCHAR2,
                        X_Gl_Date               DATE,
                        X_Currency_Code         VARCHAR2,
                        X_Encumbrance_Type_Id   NUMBER,
                        X_Employee_Id           NUMBER,
                        X_Entered_Dr            NUMBER,
                        X_Entered_Cr            NUMBER,
                        X_Submit_Date           DATE,
                        X_Charge_Center_Id      NUMBER,
                        X_Creation_Date         DATE,
                        X_Created_By            NUMBER,
                        X_Last_Update_Login     NUMBER,
                        X_Last_Update_Date      DATE,
                        X_Last_Updated_By       NUMBER
  );

   PROCEDURE Delete_Row(X_Rowid VARCHAR2);

-- to check the cross charge header name is unique for the set of books

   PROCEDURE check_unique(X_Rowid           VARCHAR2,
                          X_Name            VARCHAR2,
                          X_Set_Of_Books_Id NUMBER);


END IGI_ITR_CHARGE_HEADERS_PKG;

 

/
