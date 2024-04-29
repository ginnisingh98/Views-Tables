--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_TYPES_PKG" as
/* $Header: PAXTATSB.pls 120.2 2005/08/05 03:17:37 rgandhi noship $ */


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
                       X_return_status          OUT NOCOPY VARCHAR2,/*File.sql.39*/
                       X_msg_count              OUT NOCOPY NUMBER,/*File.sql.39*/
                       X_msg_data               OUT NOCOPY VARCHAR2/*File.sql.39*/
                      )
     IS
     BEGIN
         INSERT INTO Pa_agreement_types
             (      Agreement_type
             ,      last_update_date
             ,      last_updated_by
             ,      creation_date
             ,      created_by
             ,      last_update_login
             ,      revenue_limit_flag
             ,      start_date_active
             ,      end_date_active
             ,      description
             ,      term_id
             ,      attribute_category
             ,      attribute1
             ,      attribute2
             ,      attribute3
             ,      attribute4
             ,      attribute5
             ,      attribute6
             ,      attribute7
             ,      attribute8
             ,      attribute9
             ,      attribute10
             ,      attribute11
             ,      attribute12
             ,      attribute13
             ,      attribute14
             ,      attribute15 )
         VALUES
             (      X_Agreement_type
             ,      X_last_update_date
             ,      X_last_updated_by
             ,      X_creation_date
             ,      X_created_by
             ,      X_last_update_login
             ,      X_revenue_limit_flag
             ,      X_start_date_active
             ,      X_end_date_active
             ,      X_description
             ,      X_term_id
             ,      X_attribute_category
             ,      X_attribute1
             ,      X_attribute2
             ,      X_attribute3
             ,      X_attribute4
             ,      X_attribute5
             ,      X_attribute6
             ,      X_attribute7
             ,      X_attribute8
             ,      X_attribute9
             ,      X_attribute10
             ,      X_attribute11
             ,      X_attribute12
             ,      X_attribute13
             ,      X_attribute14
             ,      X_attribute15 );

            X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;

     EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PKG' ,
              p_procedure_name => 'Insert_Row');
     END;

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

        CURSOR C IS
        SELECT *
        FROM   Pa_Agreement_Types
        WHERE  Agreement_Type = X_Agreement_Type
        FOR UPDATE of Agreement_Type NOWAIT;

       Recinfo C%ROWTYPE;


  BEGIN
      OPEN C;
      FETCH C INTO Recinfo;

      IF (C%NOTFOUND) THEN
         CLOSE C;
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C;
      if (
              (    Recinfo.Agreement_Type          = X_Agreement_Type)
         AND  (    Recinfo.Revenue_Limit_Flag      = X_Revenue_Limit_Flag)
         AND  (   (Recinfo.Start_Date_Active       = X_Start_Date_Active)
               OR (    (Recinfo.start_date_active IS NULL)
                   AND (X_Start_Date_Active IS NULL)))
         AND  (   (Recinfo.end_date_active         = X_End_Date_Active)
               OR (    (Recinfo.end_date_active IS NULL)
                   AND (X_End_Date_Active IS NULL)))
         AND  (   (Recinfo.description             = X_Description)
               OR (    (Recinfo.description IS NULL)
                   AND (X_Description IS NULL)))
         AND  (   (Recinfo.term_id                 = X_Term_Id)
               OR (    (Recinfo.term_id IS NULL)
                   AND (X_Term_Id IS NULL)))
         AND  (   (Recinfo.attribute_category      = X_Attribute_Category)
               OR (    (Recinfo.attribute_category IS NULL)
                   AND (X_Attribute_Category IS NULL)))
         AND  (   (Recinfo.attribute1              = X_Attribute1)
               OR (    (Recinfo.attribute1 IS NULL)
                   AND (X_Attribute1 IS NULL)))
         AND  (   (Recinfo.attribute2              = X_Attribute2)
               OR (    (Recinfo.attribute2 IS NULL)
                   AND (X_Attribute2 IS NULL)))
         AND  (   (Recinfo.attribute3              = X_Attribute3)
               OR (    (Recinfo.attribute3 IS NULL)
                   AND (X_Attribute3 IS NULL)))
         AND  (   (Recinfo.attribute4              = X_Attribute4)
               OR (    (Recinfo.attribute4 IS NULL)
                   AND (X_Attribute4 IS NULL)))
         AND  (   (Recinfo.attribute5              = X_Attribute5)
               OR (    (Recinfo.attribute5 IS NULL)
                   AND (X_Attribute5 IS NULL)))
         AND  (   (Recinfo.attribute6              = X_Attribute6)
               OR (    (Recinfo.attribute6 IS NULL)
                   AND (X_Attribute6 IS NULL)))
         AND  (   (Recinfo.attribute7              = X_Attribute7)
               OR (    (Recinfo.attribute7 IS NULL)
                   AND (X_Attribute7 IS NULL)))
         AND  (   (Recinfo.attribute8              = X_Attribute8)
               OR (    (Recinfo.attribute8 IS NULL)
                   AND (X_Attribute8 IS NULL)))
         AND  (   (Recinfo.attribute9              = X_Attribute9)
               OR (    (Recinfo.attribute9 IS NULL)
                   AND (X_Attribute9 IS NULL)))
         AND  (   (Recinfo.attribute10             = X_Attribute10)
               OR (    (Recinfo.attribute10 IS NULL)
                   AND (X_Attribute10 IS NULL)))
         AND  (   (Recinfo.attribute11             = X_Attribute11)
               OR (    (Recinfo.attribute11 IS NULL)
                   AND (X_Attribute11 IS NULL)))
         AND  (   (Recinfo.attribute12             = X_Attribute12)
               OR (    (Recinfo.attribute12 IS NULL)
                   AND (X_Attribute12 IS NULL)))
         AND  (   (Recinfo.attribute13             = X_Attribute13)
               OR (    (Recinfo.attribute13 IS NULL)
                   AND (X_Attribute13 IS NULL)))
         AND  (   (Recinfo.attribute14             = X_Attribute14)
               OR (    (Recinfo.attribute14 IS NULL)
                   AND (X_Attribute14 IS NULL)))
         AND  (   (Recinfo.attribute15             = X_Attribute15)
               OR (    (Recinfo.attribute15 IS NULL)
                   AND (X_Attribute15 IS NULL)))
      ) then
            X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      RAISE FND_API.G_EXC_ERROR;
    end if;

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR  THEN
           X_return_status := FND_API.G_RET_STS_ERROR;
           X_msg_count := FND_MSG_PUB.count_msg;
            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PKG' ,
              p_procedure_name => 'Lock_Row');

        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PKG' ,
              p_procedure_name => 'Lock_Row');
     END;

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
                      )
     IS
     BEGIN
         UPDATE Pa_Agreement_Types SET
                       Last_Update_Date           = X_Last_Update_Date           ,
                       Last_Updated_By            = X_Last_Updated_By            ,
                       Creation_Date              = X_Creation_Date              ,
                       Created_By                 = X_Created_By                 ,
                       Last_Update_Login          = X_Last_Update_Login          ,
                       Revenue_Limit_Flag         = X_Revenue_Limit_Flag         ,
                       Start_Date_Active          = X_Start_Date_Active          ,
                       End_Date_Active            = X_End_Date_Active            ,
                       Description                = X_Description                ,
                       Term_Id                    = X_Term_Id                    ,
                       Attribute_Category         = X_Attribute_Category         ,
                       Attribute1                 = X_Attribute1                 ,
                       Attribute2                 = X_Attribute2                 ,
                       Attribute3                 = X_Attribute3                 ,
                       Attribute4                 = X_Attribute4                 ,
                       Attribute5                 = X_Attribute5                 ,
                       Attribute6                 = X_Attribute6                 ,
                       Attribute7                 = X_Attribute7                 ,
                       Attribute8                 = X_Attribute8                 ,
                       Attribute9                 = X_Attribute9                 ,
                       Attribute10                = X_Attribute10                ,
                       Attribute11                = X_Attribute11                ,
                       Attribute12                = X_Attribute12                ,
                       Attribute13                = X_Attribute13                ,
                       Attribute14                = X_Attribute14                ,
                       Attribute15                = X_Attribute15
         WHERE Agreement_Type = X_agreement_Type;

            X_return_status := FND_API.G_RET_STS_SUCCESS;
            X_msg_count     := 0;
            X_msg_data      := NULL;

     EXCEPTION
        WHEN OTHERS THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            X_msg_count     := 1;
            X_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_AGREEMENT_TYPES_PKG' ,
              p_procedure_name => 'Update_Row');
     END;

END PA_AGREEMENT_TYPES_PKG;

/
