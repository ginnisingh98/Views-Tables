--------------------------------------------------------
--  DDL for Package PA_AGREEMENT_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AGREEMENT_TYPES_PUB" AUTHID CURRENT_USER as
/* $Header: PAXATPBS.pls 120.1 2005/08/05 00:54:42 rgandhi noship $ */


  PROCEDURE Insert_Row(X_Agreement_Type             VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Revenue_Limit_Flag         VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Term_Id                    NUMBER,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2,
                       X_return_status          OUT NOCOPY VARCHAR2 ,/*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER ,/*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2 /*File.sql.39*/
                      );

    PROCEDURE Lock_Row(X_Agreement_Type             VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Revenue_Limit_Flag         VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Term_Id                    NUMBER,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2,
                       X_return_status          OUT NOCOPY VARCHAR2, /*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER, /*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2 /*File.sql.39*/
                      );

  PROCEDURE Update_Row(X_Agreement_Type             VARCHAR2,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Login          NUMBER,
                       X_Revenue_Limit_Flag         VARCHAR2,
                       X_Start_Date_Active          DATE,
                       X_End_Date_Active            DATE,
                       X_Description                VARCHAR2,
                       X_Term_Id                    NUMBER,
                       X_Attribute_Category         VARCHAR2,
                       X_Attribute1                 VARCHAR2,
                       X_Attribute2                 VARCHAR2,
                       X_Attribute3                 VARCHAR2,
                       X_Attribute4                 VARCHAR2,
                       X_Attribute5                 VARCHAR2,
                       X_Attribute6                 VARCHAR2,
                       X_Attribute7                 VARCHAR2,
                       X_Attribute8                 VARCHAR2,
                       X_Attribute9                 VARCHAR2,
                       X_Attribute10                VARCHAR2,
                       X_Attribute11                VARCHAR2,
                       X_Attribute12                VARCHAR2,
                       X_Attribute13                VARCHAR2,
                       X_Attribute14                VARCHAR2,
                       X_Attribute15                VARCHAR2,
                       X_return_status          OUT NOCOPY VARCHAR2, /*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER, /*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2 /*File.sql.39*/
                      );

END PA_AGREEMENT_TYPES_PUB;
 

/
