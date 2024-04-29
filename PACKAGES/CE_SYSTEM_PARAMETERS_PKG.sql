--------------------------------------------------------
--  DDL for Package CE_SYSTEM_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_SYSTEM_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: cesyspas.pls 120.6 2006/01/12 18:49:28 eliu ship $ */
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.6 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Legal_Entity_Id                NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Cashbook_Begin_Date            DATE,
                       X_Show_Cleared_Flag              VARCHAR2,
                       X_Show_Void_Payment_Flag         VARCHAR2,
		       X_line_autocreation_flag		VARCHAR2,
		       X_interface_purge_flag		VARCHAR2,
		       X_interface_archive_flag		VARCHAR2,
                       X_Lines_Per_Commit               NUMBER,
			   X_Signing_Authority_Approval 	VARCHAR2,
 		       X_CASHFLOW_EXCHANGE_RATE_TYPE	VARCHAR2,
		       X_AUTHORIZATION_BAT		VARCHAR2,
                       X_BSC_EXCHANGE_DATE_TYPE		VARCHAR2,
                       X_BAT_EXCHANGE_DATE_TYPE         VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Legal_Entity_Id                  NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Cashbook_Begin_Date              DATE,
                     X_Show_Cleared_Flag                VARCHAR2,
                     X_Show_Void_Payment_Flag           VARCHAR2,
		     X_line_autocreation_flag		VARCHAR2,
		     X_interface_purge_flag		VARCHAR2,
		     X_interface_archive_flag		VARCHAR2,
                     X_Lines_Per_Commit                 NUMBER,
			 X_Signing_Authority_Approval	VARCHAR2,
 		       X_CASHFLOW_EXCHANGE_RATE_TYPE	VARCHAR2,
		       X_AUTHORIZATION_BAT		VARCHAR2,
                       X_BSC_EXCHANGE_DATE_TYPE         VARCHAR2,
                       X_BAT_EXCHANGE_DATE_TYPE         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Legal_Entity_Id                NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Cashbook_Begin_Date            DATE,
                       X_Show_Cleared_Flag              VARCHAR2,
                       X_Show_Void_Payment_Flag         VARCHAR2,
		       X_line_autocreation_flag		VARCHAR2,
		       X_interface_purge_flag		VARCHAR2,
		       X_interface_archive_flag		VARCHAR2,
		       X_Lines_Per_Commit               NUMBER,
			   X_Signing_Authority_Approval		VARCHAR2,
 		       X_CASHFLOW_EXCHANGE_RATE_TYPE	VARCHAR2,
		       X_AUTHORIZATION_BAT		VARCHAR2,
                       X_BSC_EXCHANGE_DATE_TYPE         VARCHAR2,
                       X_BAT_EXCHANGE_DATE_TYPE         VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END CE_SYSTEM_PARAMETERS_PKG;

 

/
