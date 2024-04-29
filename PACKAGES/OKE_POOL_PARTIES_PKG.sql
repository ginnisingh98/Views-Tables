--------------------------------------------------------
--  DDL for Package OKE_POOL_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_POOL_PARTIES_PKG" AUTHID CURRENT_USER as
/* $Header: OKEPLPTS.pls 115.5 2002/11/27 19:49:48 syho ship $ */


  PROCEDURE Insert_Row(X_Rowid           IN OUT NOCOPY  VARCHAR2,
   		       X_Pool_Party_Id			NUMBER,
     		       X_Funding_Pool_Id		NUMBER,
     		       X_Party_Id			NUMBER,
                       X_Currency_Code			VARCHAR2,
                       X_Conversion_Type		VARCHAR2,
                       X_Conversion_Date		DATE,
                       X_Conversion_Rate		NUMBER,
                       X_Initial_Amount			NUMBER,
                       X_Amount				NUMBER,
                       X_Available_Amount		NUMBER,
                       X_Start_Date_Active		DATE,
                       X_End_Date_Active		DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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

  PROCEDURE Lock_Row(X_Pool_Party_Id			NUMBER,
     		     X_Funding_Pool_Id			NUMBER,
     		     X_Party_Id				NUMBER,
                     X_Currency_Code			VARCHAR2,
                     X_Conversion_Type			VARCHAR2,
                     X_Conversion_Date			DATE,
                     X_Conversion_Rate			NUMBER,
                     X_Initial_Amount			NUMBER,
                     X_Amount				NUMBER,
                     X_Available_Amount			NUMBER,
                     X_Start_Date_Active		DATE,
                     X_End_Date_Active			DATE,
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

  PROCEDURE Update_Row(X_Pool_Party_Id			NUMBER,
     		       X_Party_Id			NUMBER,
     		       X_Currency_Code			VARCHAR2,
                       X_Conversion_Type		VARCHAR2,
                       X_Conversion_Date		DATE,
                       X_Conversion_Rate		NUMBER,
                       X_Amount				NUMBER,
                       X_Available_Amount		NUMBER,
                       X_Start_Date_Active		DATE,
                       X_End_Date_Active		DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
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

END OKE_POOL_PARTIES_PKG;

 

/
