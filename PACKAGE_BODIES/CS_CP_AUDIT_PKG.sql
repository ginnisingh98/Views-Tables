--------------------------------------------------------
--  DDL for Package Body CS_CP_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CP_AUDIT_PKG" as
/* $Header: csxciaub.pls 115.2 2000/07/18 21:43:34 pkm ship     $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,

                       X_Customer_Product_Id            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Changed_Flag          VARCHAR2,
                       X_Old_Customer_Id                NUMBER,
                       X_Current_Customer_Id            NUMBER,
                       X_System_Changed_Flag            VARCHAR2,
                       X_Old_System_Id                  NUMBER,
                       X_Current_System_Id              NUMBER,
                       X_Prd_Agreement_Changed_Flag   VARCHAR2,
                       X_Old_Product_Agreement_Id       NUMBER,
                       X_Current_Product_Agreement_Id   NUMBER,
                       X_Serv_Agreement_Changed_Flag   VARCHAR2,
                       X_Old_Service_Agreement_Id       NUMBER,
                       X_Current_Service_Agreement_Id   NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Cp_Status_Changed_Flag         VARCHAR2,
                       X_Old_Cp_Status_Id               NUMBER,
                       X_Current_Cp_Status_Id           NUMBER,
                       X_Type_Code_Changed_Flag         VARCHAR2,
                       X_Old_Type_Code                  VARCHAR2,
                       X_Current_Type_Code              VARCHAR2
  ) IS
    l_cp_audit_id     NUMBER;
    CURSOR C IS SELECT rowid FROM CS_CP_AUDIT
                 WHERE customer_product_id = X_Customer_Product_Id;

   BEGIN
        select cs_cp_audit_s.NEXTVAL
        into l_cp_audit_id
        from dual;

       INSERT INTO CS_CP_AUDIT(
              cp_audit_id,
              customer_product_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              customer_changed_flag,
              old_customer_id,
              current_customer_id,
              system_changed_flag,
              old_system_id,
              current_system_id,
              product_agreement_changed_flag,
              old_product_agreement_id,
              current_product_agreement_id,
              service_agreement_changed_flag,
              old_service_agreement_id,
              current_service_agreement_id,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              context,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              comments,
              cp_status_changed_flag,
              old_cp_status_id,
              current_cp_status_id,
              type_code_changed_flag,
              old_type_code,
              current_type_code
             ) VALUES (
              l_cp_audit_id,
              X_Customer_Product_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Customer_Changed_Flag,
              X_Old_Customer_Id,
              X_Current_Customer_Id,
              X_System_Changed_Flag,
              X_Old_System_Id,
              X_Current_System_Id,
              X_Prd_Agreement_Changed_Flag,
              X_Old_Product_Agreement_Id,
              X_Current_Product_Agreement_Id,
              X_Serv_Agreement_Changed_Flag,
              X_Old_Service_Agreement_Id,
              X_Current_Service_Agreement_Id,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Context,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Comments,
              X_Cp_Status_Changed_Flag,
              X_Old_Cp_Status_Id,
              X_Current_Cp_Status_Id,
              X_Type_Code_Changed_Flag,
              X_Old_Type_Code,
              X_Current_Type_Code

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Customer_Product_Id              NUMBER,
                     X_Customer_Changed_Flag            VARCHAR2,
                     X_Old_Customer_Id                  NUMBER,
                     X_Current_Customer_Id              NUMBER,
                     X_System_Changed_Flag              VARCHAR2,
                     X_Old_System_Id                    NUMBER,
                     X_Current_System_Id                NUMBER,
                     X_Prd_Agreement_Changed_Flag   VARCHAR2,
                     X_Old_Product_Agreement_Id         NUMBER,
                     X_Current_Product_Agreement_Id     NUMBER,
                     X_Serv_Agreement_Changed_Flag   VARCHAR2,
                     X_Old_Service_Agreement_Id         NUMBER,
                     X_Current_Service_Agreement_Id     NUMBER,
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
                     X_Context                          VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Cp_Status_Changed_Flag           VARCHAR2,
                     X_Old_Cp_Status_Id                 NUMBER,
                     X_Current_Cp_Status_Id             NUMBER,
                     X_Type_Code_Changed_Flag           VARCHAR2,
                     X_Old_Type_Code                    VARCHAR2,
                     X_Current_Type_Code                VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CS_CP_AUDIT
        WHERE  rowid = X_Rowid
        FOR UPDATE of Customer_Product_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.customer_product_id =  X_Customer_Product_Id)
           AND (Recinfo.customer_changed_flag =  X_Customer_Changed_Flag)
           AND (   (Recinfo.old_customer_id =  X_Old_Customer_Id)
                OR (    (Recinfo.old_customer_id IS NULL)
                    AND (X_Old_Customer_Id IS NULL)))
           AND (   (Recinfo.current_customer_id =  X_Current_Customer_Id)
                OR (    (Recinfo.current_customer_id IS NULL)
                    AND (X_Current_Customer_Id IS NULL)))
           AND (Recinfo.system_changed_flag =  X_System_Changed_Flag)
           AND (   (Recinfo.old_system_id =  X_Old_System_Id)
                OR (    (Recinfo.old_system_id IS NULL)
                    AND (X_Old_System_Id IS NULL)))
           AND (   (Recinfo.current_system_id =  X_Current_System_Id)
                OR (    (Recinfo.current_system_id IS NULL)
                    AND (X_Current_System_Id IS NULL)))
        AND (Recinfo.product_agreement_changed_flag =  X_Prd_Agreement_Changed_Flag)
           AND (   (Recinfo.old_product_agreement_id =  X_Old_Product_Agreement_Id)
                OR (    (Recinfo.old_product_agreement_id IS NULL)
                    AND (X_Old_Product_Agreement_Id IS NULL)))
           AND (   (Recinfo.current_product_agreement_id =  X_Current_Product_Agreement_Id)
                OR (    (Recinfo.current_product_agreement_id IS NULL)
                    AND (X_Current_Product_Agreement_Id IS NULL)))
   AND (Recinfo.service_agreement_changed_flag =  X_Serv_Agreement_Changed_Flag)
       AND (   (Recinfo.old_service_agreement_id =  X_Old_Service_Agreement_Id)
                OR (    (Recinfo.old_service_agreement_id IS NULL)
                    AND (X_Old_Service_Agreement_Id IS NULL)))
           AND (   (Recinfo.current_service_agreement_id =  X_Current_Service_Agreement_Id)
                OR (    (Recinfo.current_service_agreement_id IS NULL)
                    AND (X_Current_Service_Agreement_Id IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.comments =  X_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_Comments IS NULL)))
           AND (Recinfo.cp_status_changed_flag =  X_Cp_Status_Changed_Flag)
           AND (   (Recinfo.old_cp_status_id =  X_Old_Cp_Status_Id)
                OR (    (Recinfo.old_cp_status_id IS NULL)
                    AND (X_Old_Cp_Status_Id IS NULL)))
           AND (   (Recinfo.current_cp_status_id =  X_Current_Cp_Status_Id)
                OR (    (Recinfo.current_cp_status_id IS NULL)
                    AND (X_Current_Cp_Status_Id IS NULL)))
           AND (Recinfo.type_code_changed_flag =  X_Type_Code_Changed_Flag)
           AND (   (Recinfo.old_type_code =  X_Old_Type_Code)
                OR (    (Recinfo.old_type_code IS NULL)
                    AND (X_Old_Type_Code IS NULL)))
           AND (   (Recinfo.current_type_code =  X_Current_Type_Code)
                OR (    (Recinfo.current_type_code IS NULL)
                    AND (X_Current_Type_Code IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Customer_Product_Id            NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Changed_Flag          VARCHAR2,
                       X_Old_Customer_Id                NUMBER,
                       X_Current_Customer_Id            NUMBER,
                       X_System_Changed_Flag            VARCHAR2,
                       X_Old_System_Id                  NUMBER,
                       X_Current_System_Id              NUMBER,
                       X_Prd_Agreement_Changed_Flag VARCHAR2,
                       X_Old_Product_Agreement_Id       NUMBER,
                       X_Current_Product_Agreement_Id   NUMBER,
                       X_Serv_Agreement_Changed_Flag VARCHAR2,
                       X_Old_Service_Agreement_Id       NUMBER,
                       X_Current_Service_Agreement_Id   NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Cp_Status_Changed_Flag         VARCHAR2,
                       X_Old_Cp_Status_Id               NUMBER,
                       X_Current_Cp_Status_Id           NUMBER,
                       X_Type_Code_Changed_Flag         VARCHAR2,
                       X_Old_Type_Code                  VARCHAR2,
                       X_Current_Type_Code              VARCHAR2

  ) IS
  BEGIN
    UPDATE CS_CP_AUDIT
    SET
       customer_product_id             =     X_Customer_Product_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       customer_changed_flag           =     X_Customer_Changed_Flag,
       old_customer_id                 =     X_Old_Customer_Id,
       current_customer_id             =     X_Current_Customer_Id,
       system_changed_flag             =     X_System_Changed_Flag,
       old_system_id                   =     X_Old_System_Id,
       current_system_id               =     X_Current_System_Id,
       product_agreement_changed_flag   =     X_Prd_Agreement_Changed_Flag,
       old_product_agreement_id        =     X_Old_Product_Agreement_Id,
       current_product_agreement_id    =     X_Current_Product_Agreement_Id,
       service_agreement_changed_flag   =     X_Serv_Agreement_Changed_Flag,
       old_service_agreement_id        =     X_Old_Service_Agreement_Id,
       current_service_agreement_id    =     X_Current_Service_Agreement_Id,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       context                         =     X_Context,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       comments                        =     X_Comments,
       cp_status_changed_flag          =     X_Cp_Status_Changed_Flag,
       old_cp_status_id                =     X_Old_Cp_Status_Id,
       current_cp_status_id            =     X_Current_Cp_Status_Id,
       type_code_changed_flag          =     X_Type_Code_Changed_Flag,
       old_type_code                   =     X_Old_Type_Code,
       current_type_code               =     X_Current_Type_Code
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

END CS_CP_AUDIT_PKG;

/
