--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_TYPES_PUB" as
/* $Header: PAXATPBB.pls 120.1 2005/08/05 00:52:59 rgandhi noship $ */


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
                       X_return_status          OUT NOCOPY VARCHAR2,/*file.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER,/*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2 /*File.sql.39*/
                      )
    IS
    BEGIN

        PA_AGREEMENT_TYPES_PKG.Insert_Row(
                       X_Agreement_Type             => X_Agreement_Type             ,
                       X_Last_Update_Date           => X_Last_Update_Date           ,
                       X_Last_Updated_By            => X_Last_Updated_By            ,
                       X_Creation_Date              => X_Creation_Date              ,
                       X_Created_By                 => X_Created_By                 ,
                       X_Last_Update_Login          => X_Last_Update_Login          ,
                       X_Revenue_Limit_Flag         => X_Revenue_Limit_Flag         ,
                       X_Start_Date_Active          => X_Start_Date_Active          ,
                       X_End_Date_Active            => X_End_Date_Active            ,
                       X_Description                => X_Description                ,
                       X_Term_Id                    => X_Term_Id                    ,
                       X_Attribute_Category         => X_Attribute_Category         ,
                       X_Attribute1                 => X_Attribute1                 ,
                       X_Attribute2                 => X_Attribute2                 ,
                       X_Attribute3                 => X_Attribute3                 ,
                       X_Attribute4                 => X_Attribute4                 ,
                       X_Attribute5                 => X_Attribute5                 ,
                       X_Attribute6                 => X_Attribute6                 ,
                       X_Attribute7                 => X_Attribute7                 ,
                       X_Attribute8                 => X_Attribute8                 ,
                       X_Attribute9                 => X_Attribute9                 ,
                       X_Attribute10                => X_Attribute10                ,
                       X_Attribute11                => X_Attribute11                ,
                       X_Attribute12                => X_Attribute12                ,
                       X_Attribute13                => X_Attribute13                ,
                       X_Attribute14                => X_Attribute14                ,
                       X_Attribute15                => X_Attribute15                ,
                       X_return_status              => X_return_status              ,
                       X_msg_count                  => X_msg_count                  ,
                       X_msg_data                   => X_msg_data
                      );

    EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PUB' ,
              p_procedure_name => 'Insert_Row');

    END ;

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
                       X_return_status          OUT NOCOPY VARCHAR2,/*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER,/*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2/*File.sql.39*/
                      )
    IS
    BEGIN
        PA_AGREEMENT_TYPES_PKG.Lock_Row(
                       X_Agreement_Type             => X_Agreement_Type             ,
                       X_Last_Update_Date           => X_Last_Update_Date           ,
                       X_Last_Updated_By            => X_Last_Updated_By            ,
                       X_Creation_Date              => X_Creation_Date              ,
                       X_Created_By                 => X_Created_By                 ,
                       X_Last_Update_Login          => X_Last_Update_Login          ,
                       X_Revenue_Limit_Flag         => X_Revenue_Limit_Flag         ,
                       X_Start_Date_Active          => X_Start_Date_Active          ,
                       X_End_Date_Active            => X_End_Date_Active            ,
                       X_Description                => X_Description                ,
                       X_Term_Id                    => X_Term_Id                    ,
                       X_Attribute_Category         => X_Attribute_Category         ,
                       X_Attribute1                 => X_Attribute1                 ,
                       X_Attribute2                 => X_Attribute2                 ,
                       X_Attribute3                 => X_Attribute3                 ,
                       X_Attribute4                 => X_Attribute4                 ,
                       X_Attribute5                 => X_Attribute5                 ,
                       X_Attribute6                 => X_Attribute6                 ,
                       X_Attribute7                 => X_Attribute7                 ,
                       X_Attribute8                 => X_Attribute8                 ,
                       X_Attribute9                 => X_Attribute9                 ,
                       X_Attribute10                => X_Attribute10                ,
                       X_Attribute11                => X_Attribute11                ,
                       X_Attribute12                => X_Attribute12                ,
                       X_Attribute13                => X_Attribute13                ,
                       X_Attribute14                => X_Attribute14                ,
                       X_Attribute15                => X_Attribute15                ,
                       X_return_status              => X_return_status              ,
                       X_msg_count                  => X_msg_count                  ,
                       X_msg_data                   => X_msg_data
                      );

    EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PUB' ,
              p_procedure_name => 'Lock_Row');

    END ;

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
                       X_return_status          OUT NOCOPY VARCHAR2,/*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER,/*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2/*File.sql.39*/
                      )
    IS
    BEGIN
        PA_AGREEMENT_TYPES_PKG.Update_Row(
                       X_Agreement_Type             => X_Agreement_Type             ,
                       X_Last_Update_Date           => X_Last_Update_Date           ,
                       X_Last_Updated_By            => X_Last_Updated_By            ,
                       X_Creation_Date              => X_Creation_Date              ,
                       X_Created_By                 => X_Created_By                 ,
                       X_Last_Update_Login          => X_Last_Update_Login          ,
                       X_Revenue_Limit_Flag         => X_Revenue_Limit_Flag         ,
                       X_Start_Date_Active          => X_Start_Date_Active          ,
                       X_End_Date_Active            => X_End_Date_Active            ,
                       X_Description                => X_Description                ,
                       X_Term_Id                    => X_Term_Id                    ,
                       X_Attribute_Category         => X_Attribute_Category         ,
                       X_Attribute1                 => X_Attribute1                 ,
                       X_Attribute2                 => X_Attribute2                 ,
                       X_Attribute3                 => X_Attribute3                 ,
                       X_Attribute4                 => X_Attribute4                 ,
                       X_Attribute5                 => X_Attribute5                 ,
                       X_Attribute6                 => X_Attribute6                 ,
                       X_Attribute7                 => X_Attribute7                 ,
                       X_Attribute8                 => X_Attribute8                 ,
                       X_Attribute9                 => X_Attribute9                 ,
                       X_Attribute10                => X_Attribute10                ,
                       X_Attribute11                => X_Attribute11                ,
                       X_Attribute12                => X_Attribute12                ,
                       X_Attribute13                => X_Attribute13                ,
                       X_Attribute14                => X_Attribute14                ,
                       X_Attribute15                => X_Attribute15                ,
                       X_return_status              => X_return_status              ,
                       X_msg_count                  => X_msg_count                  ,
                       X_msg_data                   => X_msg_data
                      );

    EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PUB' ,
              p_procedure_name => 'Insert_Row');
    END;
END PA_AGREEMENT_TYPES_PUB;

/
