--------------------------------------------------------
--  DDL for Package IGI_ITR_CHARGE_SERVICES_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_CHARGE_SERVICES_SS_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrks.pls 120.3.12000000.1 2007/09/12 10:31:43 mbremkum ship $
--
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Service_Id                     NUMBER,
                       X_Charge_Service_Id              NUMBER,
	 	       X_Creation_Ccid                  NUMBER,
		       X_Receiving_Ccid                 NUMBER,
		       X_Start_Date                     Date,
		       X_End_Date                       Date,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER

                      );

  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_Charge_Center_Id               NUMBER,
                     X_Charge_Service_Id              NUMBER,
                     X_Service_Id                     NUMBER,
		     X_Creation_Ccid                  NUMBER,
		     X_Receiving_Ccid                 NUMBER,
		     X_Start_Date                     Date,
		     X_End_Date                       Date
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Center_Id               NUMBER,
                       X_Charge_Service_Id              NUMBER,
                       X_Service_Id                     NUMBER,
		       X_Creation_Ccid                  NUMBER,
		       X_Receiving_Ccid                 NUMBER,
		       X_Start_Date                     Date,
		       X_End_Date                       Date,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END IGI_ITR_CHARGE_SERVICES_SS_PKG;

 

/
