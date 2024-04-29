--------------------------------------------------------
--  DDL for Package Body AP_CARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CARDS_PKG" as
/* $Header: apiwcrdb.pls 120.6.12010000.4 2009/09/25 15:42:38 syeluri ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Card_Number                    VARCHAR2,
	               X_Card_Expiration_Date           DATE,
                       X_Card_Id                        IN OUT NOCOPY NUMBER,
                       X_Limit_Override_Amount          NUMBER,
                       X_Trx_Limit_Override_Amount      NUMBER,
                       X_Profile_Id                     NUMBER,
                       X_Cardmember_Name                VARCHAR2,
                       X_Department_Name                VARCHAR2,
                       X_Physical_Card_Flag             VARCHAR2,
                       X_Paper_Statement_Req_Flag       VARCHAR2,
                       X_Location_Id                    NUMBER,
   -- 		       X_Mothers_Maiden_Name            VARCHAR2,Commented for bug 2928064
                       X_Description                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Inactive_Date                  DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2,
                       X_CardProgramId                  NUMBER,
                       X_CardReferenceId                NUMBER,
                       X_paycardreferenceid             NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM ap_cards
                 WHERE card_id = X_Card_Id;
      CURSOR C2 IS SELECT ap_cards_s.nextval FROM sys.dual;
   BEGIN
      if (X_Card_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Card_Id;
        CLOSE C2;
      end if;

       INSERT INTO ap_cards(
              employee_id,
              card_number,
	          card_expiration_date,
              card_id,
              limit_override_amount,
              trx_limit_override_amount,
              profile_id,
              cardmember_name,
              department_name,
              physical_card_flag,
              paper_statement_req_flag,
              location_id,
   --         mothers_maiden_name, Commented for bug 2928064
              description,
              inactive_date,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              attribute_category,
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
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute16,
              attribute17,
              attribute18,
              attribute19,
              attribute20,
              attribute21,
              attribute22,
              attribute23,
              attribute24,
              attribute25,
              attribute26,
              attribute27,
              attribute28,
              attribute29,
              attribute30,
              card_program_id,
              card_reference_id,
              org_id,
              paycard_reference_id
             ) VALUES (

              X_Employee_Id,
              X_Card_Number,
              X_Card_Expiration_Date,
              X_Card_Id,
              X_Limit_Override_Amount,
              X_Trx_Limit_Override_Amount,
              X_Profile_Id,
              X_Cardmember_Name,
              X_Department_Name,
              X_Physical_Card_Flag,
              X_Paper_Statement_Req_Flag,
              X_Location_Id,
  --          X_Mothers_Maiden_Name,Commented for bug 2928064
              X_Description,
              X_Inactive_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Attribute_Category,
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
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute16,
              X_Attribute17,
              X_Attribute18,
              X_Attribute19,
              X_Attribute20,
              X_Attribute21,
              X_Attribute22,
              X_Attribute23,
              X_Attribute24,
              X_Attribute25,
              X_Attribute26,
              X_Attribute27,
              X_Attribute28,
              X_Attribute29,
              X_Attribute30,
              X_CardProgramId,
              X_CardReferenceId,
              X_Org_Id,
              X_paycardreferenceid
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
    commit; --Bug 3491216
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Employee_Id                      NUMBER,
            	     X_Card_Expiration_Date		DATE,
                     X_Card_Id                          NUMBER,
                     X_Limit_Override_Amount            NUMBER,
                     X_Trx_Limit_Override_Amount        NUMBER,
                     X_Profile_Id                       NUMBER,
                     X_Cardmember_Name                  VARCHAR2,
                     X_Department_Name                  VARCHAR2,
                     X_Physical_Card_Flag               VARCHAR2,
                     X_Paper_Statement_Req_Flag         VARCHAR2,
                     X_Location_Id                      NUMBER,
   --                X_Mothers_Maiden_Name              VARCHAR2,Commented for bug 2928064
                     X_Description                      VARCHAR2,
                     X_Org_Id                           NUMBER,
                     X_Inactive_Date                    DATE,
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
                     X_Attribute15                      VARCHAR2,
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Attribute21                      VARCHAR2,
                     X_Attribute22                      VARCHAR2,
                     X_Attribute23                      VARCHAR2,
                     X_Attribute24                      VARCHAR2,
                     X_Attribute25                      VARCHAR2,
                     X_Attribute26                      VARCHAR2,
                     X_Attribute27                      VARCHAR2,
                     X_Attribute28                      VARCHAR2,
                     X_Attribute29                      VARCHAR2,
                     X_Attribute30                      VARCHAR2,
                     X_CardProgramId                    NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ap_cards
        WHERE  rowid = X_Rowid
        FOR UPDATE of Card_Id NOWAIT;
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
    if (   (   (Recinfo.employee_id =  X_Employee_Id)
                OR (    (Recinfo.employee_id IS NULL)
                    AND (X_Employee_Id IS NULL)))
	   AND (   (Recinfo.card_expiration_date = X_Card_Expiration_Date)
		OR (	(Recinfo.card_expiration_date IS NULL)
		    AND (X_Card_Expiration_Date IS NULL)))
           AND (   (Recinfo.card_id =  X_Card_Id)
		OR (	(Recinfo.card_id IS NULL)
		    AND (X_Card_Id IS NULL)))
           AND (   (Recinfo.limit_override_amount =  X_Limit_Override_Amount)
                OR (    (Recinfo.limit_override_amount IS NULL)
                    AND (X_Limit_Override_Amount IS NULL)))
           AND (   (Recinfo.trx_limit_override_amount =  X_Trx_Limit_Override_Amount)
                OR (    (Recinfo.trx_limit_override_amount IS NULL)
                    AND (X_Trx_Limit_Override_Amount IS NULL)))
           AND (   (Recinfo.profile_id =  X_Profile_Id)
                OR (    (Recinfo.profile_id IS NULL)
                    AND (X_Profile_Id IS NULL)))
           AND (   (Recinfo.cardmember_name =  X_Cardmember_Name)
                OR (    (Recinfo.cardmember_name IS NULL)
                    AND (X_Cardmember_Name IS NULL)))
           AND (   (Recinfo.department_name =  X_Department_Name)
                OR (    (Recinfo.department_name IS NULL)
                    AND (X_Department_Name IS NULL)))
           AND (   (Recinfo.physical_card_flag =  X_Physical_Card_Flag)
                OR (    (Recinfo.physical_card_flag IS NULL)
                    AND (X_Physical_Card_Flag IS NULL)))
           AND (   (Recinfo.paper_statement_req_flag =  X_Paper_Statement_Req_Flag)
                OR (    (Recinfo.paper_statement_req_flag IS NULL)
                    AND (X_Paper_Statement_Req_Flag IS NULL)))
           AND (   (Recinfo.location_id =  X_Location_Id)
                OR (    (Recinfo.location_id IS NULL)
                    AND (X_Location_Id IS NULL)))
   /* Commented for bug 2928064
           AND (   (Recinfo.mothers_maiden_name =  X_Mothers_Maiden_Name)
                OR (    (Recinfo.mothers_maiden_name IS NULL)
                    AND (X_Mothers_Maiden_Name IS NULL)))
   */
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.inactive_date =  X_Inactive_Date)
                OR (    (Recinfo.inactive_date IS NULL)
                    AND (X_Inactive_Date IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
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
           AND (   (Recinfo.attribute16 =  X_Attribute16)
                OR (    (Recinfo.attribute16 IS NULL)
                    AND (X_Attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 =  X_Attribute17)
                OR (    (Recinfo.attribute17 IS NULL)
                    AND (X_Attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 =  X_Attribute18)
                OR (    (Recinfo.attribute18 IS NULL)
                    AND (X_Attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 =  X_Attribute19)
                OR (    (Recinfo.attribute19 IS NULL)
                    AND (X_Attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 =  X_Attribute20)
                OR (    (Recinfo.attribute20 IS NULL)
                    AND (X_Attribute20 IS NULL)))
           AND (   (Recinfo.attribute21 =  X_Attribute21)
                OR (    (Recinfo.attribute21 IS NULL)
                    AND (X_Attribute21 IS NULL)))
           AND (   (Recinfo.attribute22 =  X_Attribute22)
                OR (    (Recinfo.attribute22 IS NULL)
                    AND (X_Attribute22 IS NULL)))
           AND (   (Recinfo.attribute23 =  X_Attribute23)
                OR (    (Recinfo.attribute23 IS NULL)
                    AND (X_Attribute23 IS NULL)))
           AND (   (Recinfo.attribute24 =  X_Attribute24)
                OR (    (Recinfo.attribute24 IS NULL)
                    AND (X_Attribute24 IS NULL)))
           AND (   (Recinfo.attribute25 =  X_Attribute25)
                OR (    (Recinfo.attribute25 IS NULL)
                    AND (X_Attribute25 IS NULL)))
           AND (   (Recinfo.attribute26 =  X_Attribute26)
                OR (    (Recinfo.attribute26 IS NULL)
                    AND (X_Attribute26 IS NULL)))
           AND (   (Recinfo.attribute27 =  X_Attribute27)
                OR (    (Recinfo.attribute27 IS NULL)
                    AND (X_Attribute27 IS NULL)))
           AND (   (Recinfo.attribute28 =  X_Attribute28)
                OR (    (Recinfo.attribute28 IS NULL)
                    AND (X_Attribute28 IS NULL)))
           AND (   (Recinfo.attribute29 =  X_Attribute29)
                OR (    (Recinfo.attribute29 IS NULL)
                    AND (X_Attribute29 IS NULL)))
           AND (   (Recinfo.attribute30 =  X_Attribute30)
                OR (    (Recinfo.attribute30 IS NULL)
                    AND (X_Attribute30 IS NULL)))
           AND (   (Recinfo.card_program_id =  X_CardProgramId)
                OR (    (Recinfo.card_program_id IS NULL)
                    AND (X_CardProgramId IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Card_Expiration_Date		DATE,
                       X_Card_Id                        NUMBER,
                       X_Limit_Override_Amount          NUMBER,
                       X_Trx_Limit_Override_Amount      NUMBER,
                       X_Profile_Id                     NUMBER,
                       X_Cardmember_Name                VARCHAR2,
                       X_Department_Name                VARCHAR2,
                       X_Physical_Card_Flag             VARCHAR2,
                       X_Paper_Statement_Req_Flag       VARCHAR2,
                       X_Location_Id                    NUMBER,
   --                  X_Mothers_Maiden_Name            VARCHAR2,Commented for bug 2928064
                       X_Description                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Inactive_Date                  DATE,
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
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2,
                       X_CardProgramId                  NUMBER


  ) IS
  BEGIN
    UPDATE ap_cards
    SET
       employee_id                     =     X_Employee_Id,
       card_expiration_date	           =     X_Card_Expiration_Date,
       card_id                         =     X_Card_Id,
       limit_override_amount           =     X_Limit_Override_Amount,
       trx_limit_override_amount       =     X_Trx_Limit_Override_Amount,
       profile_id                      =     X_Profile_Id,
       cardmember_name                 =     X_Cardmember_Name,
       department_name                 =     X_Department_Name,
       physical_card_flag              =     X_Physical_Card_Flag,
       paper_statement_req_flag        =     X_Paper_Statement_Req_Flag,
       location_id                     =     X_Location_Id,
--     mothers_maiden_name             =     X_Mothers_Maiden_Name,Commented for bug 2928064
       description                     =     X_Description,
       inactive_date                   =     X_Inactive_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute_category              =     X_Attribute_Category,
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
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute16                     =     X_Attribute16,
       attribute17                     =     X_Attribute17,
       attribute18                     =     X_Attribute18,
       attribute19                     =     X_Attribute19,
       attribute20                     =     X_Attribute20,
       attribute21                     =     X_Attribute21,
       attribute22                     =     X_Attribute22,
       attribute23                     =     X_Attribute23,
       attribute24                     =     X_Attribute24,
       attribute25                     =     X_Attribute25,
       attribute26                     =     X_Attribute26,
       attribute27                     =     X_Attribute27,
       attribute28                     =     X_Attribute28,
       attribute29                     =     X_Attribute29,
       attribute30                     =     X_Attribute30,
       card_program_id                 =     X_CardProgramId
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM ap_cards
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

 PROCEDURE Supplier_Insert_Row( x_Card_Id NUMBER,
                               X_Vendor_id NUMBER,
                               X_Vendor_Site_id NUMBER,
                               X_Last_Updated_By NUMBER,
                               X_Last_Update_Login NUMBER,
                               X_Last_Update_Date DATE,
                               X_Created_By NUMBER,
                               X_Creation_Date DATE,
                               X_Org_Id NUMBER,
                               X_Rowid IN OUT NOCOPY VARCHAR2 ) IS

  CURSOR Fetch_Row_Id_Cur IS
    SELECT row_id
    FROM   Ap_Card_Suppliers_V
    WHERE  Card_Id = x_card_id
      AND  Vendor_Id = x_vendor_id
      AND  Vendor_Site_Id = x_vendor_site_id;

BEGIN

  INSERT INTO Ap_Card_Suppliers_V( Card_Id,
                                   Vendor_Id,
                                   Vendor_Site_Id,
                                   last_update_date,
                                   last_updated_by,
                                   last_update_login,
                                   creation_date,
                                   created_by,
                                   org_id)
  VALUES
  ( x_card_id,
    x_vendor_id,
    x_vendor_site_id,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    x_creation_date,
    x_created_by,
    x_org_id );

    OPEN Fetch_Row_Id_Cur;
    FETCH Fetch_Row_Id_Cur INTO X_Rowid;
    if (Fetch_Row_Id_Cur%NOTFOUND) then
      CLOSE Fetch_Row_Id_Cur;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE Fetch_Row_Id_Cur;

END Supplier_Insert_Row;

PROCEDURE Supplier_Update_Row( x_Card_Id NUMBER,
                               X_Vendor_id NUMBER,
                               X_Vendor_Site_id NUMBER,
                               X_Last_Updated_By NUMBER,
                               X_Last_Update_Login NUMBER,
                               X_Last_Update_Date DATE,
                               X_Rowid VARCHAR2 ) IS
BEGIN

  UPDATE Ap_Card_Suppliers_V
  SET    Vendor_Site_Id = x_vendor_site_id,
         Last_Updated_By = x_last_updated_by,
         Last_Update_Login = x_last_update_login,
         Last_Update_Date = x_last_update_date
  WHERE  Row_Id = x_rowid;

  IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
  END IF;

END Supplier_Update_Row;

PROCEDURE Supplier_Lock_Row( X_Rowid VARCHAR2,
                             X_Vendor_Site_Id NUMBER ) IS

    CURSOR C IS
        SELECT *
        FROM   ap_card_suppliers_v
        WHERE  rowid = X_Rowid
        FOR UPDATE of Card_Id NOWAIT;

    Recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    IF ( (Recinfo.Vendor_Site_Id =  x_vendor_site_id )
            OR ((Recinfo.Vendor_Site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
    THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
END Supplier_Lock_Row;

PROCEDURE Supplier_Delete_Row ( x_rowid IN VARCHAR2 ) IS
BEGIN
  DELETE FROM Ap_Card_Suppliers_V
  WHERE rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
  END IF;

END Supplier_Delete_Row;


-- 8726861
FUNCTION GET_CARD_ID(
      P_CARD_NUMBER     IN AP_EXPENSE_FEED_LINES_ALL.CARD_NUMBER%TYPE)
       RETURN AP_CARDS_ALL.CARD_ID%TYPE IS
  l_debug_info                  VARCHAR2(100);
  x_return_status VARCHAR2(4000);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(4000);
  p_card_instrument APPS.IBY_FNDCPT_SETUP_PUB.CREDITCARD_REC_TYPE;
  x_instr_id NUMBER;
  x_response APPS.IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
  l_card_id NUMBER;
BEGIN

  -- Call IBY API to get the card_reference_id.

  iby_fndcpt_setup_pub.card_exists(1.0,NULL,
           x_return_status, x_msg_count, x_msg_data,
           null ,trim(P_CARD_NUMBER), -- party id is null as we reference cards through ap_cards_all.employee_id
           p_card_instrument, x_response);

   if (x_return_status = 'S') then
           x_instr_id := p_card_instrument.card_id;

           if (x_instr_id is not null) then

	     begin
	       select card_id into l_card_id from
   	       ap_cards_all where card_reference_id=x_instr_id and rownum=1;

	     exception
		when NO_DATA_FOUND then
	          RETURN -1 ;
	     end;
           else
             RETURN -1 ;

           end if;
           RETURN l_card_id ;
    else
      RETURN -1 ;

    end if;

 END GET_CARD_ID ;
--8726861

--8947179
PROCEDURE UPG_HISTORICAL_TRANSACTIONS(errbuf OUT NOCOPY VARCHAR2,
				     retcode OUT NOCOPY NUMBER)
IS
BEGIN

  update ap_expense_feed_lines_all
     set card_number = '-1'
   where reject_code = 'VALID';

  COMMIT ;

END UPG_HISTORICAL_TRANSACTIONS ;




END AP_CARDS_PKG;

/
