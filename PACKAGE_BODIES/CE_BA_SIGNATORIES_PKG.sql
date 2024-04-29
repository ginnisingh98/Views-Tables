--------------------------------------------------------
--  DDL for Package Body CE_BA_SIGNATORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BA_SIGNATORIES_PKG" as
/* $Header: cebasigb.pls 120.0 2005/03/30 21:38:05 shawang noship $ */
--
-- Package
--  ce_ba_signatoriespkg
-- Purpose
--   To contain validation and insertion routines for ce_ba_signatories
-- History
--   15-dec-2004   Shaik Vali           Created

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into ce_ba_signatories
  -- History
  --   15-Dec-2004  Shaik Vali           Created
  -- Arguments
  -- all the columns of the table CE_BA_SIGNATORIES
  -- Example
  --   CE_BA_SIGNATORIES_PKG.Insert_Row(....;
  -- Notes
  --
PROCEDURE Insert_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Person_Id     	NUMBER,
				 X_Single_limit_amount	NUMBER,
		         X_Joint_limit_amount	NUMBER,
				 X_Signer_group		VARCHAR2,
				 X_Other_limits		VARCHAR2,
				 X_Start_date		DATE,
				 X_End_date		DATE,
				 X_Status		VARCHAR2,
				 X_Approval_type		VARCHAR2,
				 X_requester_id		NUMBER,
				 X_deleted_flag 	VARCHAR2,
                         X_Last_Updated_By                NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Update_Login              NUMBER,
                         X_Created_By                     NUMBER,
                         X_Creation_Date                  DATE,
				 X_Attribute_category		VARCHAR2,
				 X_Attribute1		VARCHAR2,
				 X_Attribute2		VARCHAR2,
				 X_Attribute3		VARCHAR2,
				 X_Attribute4		VARCHAR2,
				 X_Attribute5		VARCHAR2,
				 X_Attribute6		VARCHAR2,
				 X_Attribute7		VARCHAR2,
				 X_Attribute8		VARCHAR2,
				 X_Attribute9		VARCHAR2,
				 X_Attribute10		VARCHAR2,
				 X_Attribute11		VARCHAR2,
				 X_Attribute12		VARCHAR2,
				 X_Attribute13		VARCHAR2,
				 X_Attribute14		VARCHAR2,
				 X_Attribute15		VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM CE_BA_SIGNATORIES
                 WHERE signatory_id = X_signatory_id;

  CURSOR C2 IS SELECT ce_ba_signatories_s.nextval FROM sys.dual;
   --
   BEGIN
     --   cep_standard.debug('open c2 ');

       OPEN C2;
       FETCH C2 INTO X_Signatory_id;
       CLOSE C2;
       --

       INSERT INTO CE_BA_SIGNATORIES(
	      signatory_id,
              bank_account_id,
              person_id,
              single_limit_amount,
              joint_limit_amount,
              signer_group,
              other_limits,
              start_date,
              end_date,
              status,
              approval_type_flag,
	      requester_id,
	      deleted_flag,
   	      Last_Updated_By,
              Last_Update_Date,
              Last_Update_Login,
              Created_By,
              Creation_Date,
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
              attribute15
             ) VALUES (
              X_Signatory_Id,
              X_Bank_Account_id,
              X_Person_Id,
		X_Single_limit_amount,
		X_Joint_limit_amount,
		X_Signer_group,
		X_Other_limits,
		X_Start_date,
		X_End_date,
		X_Status,
		X_Approval_type,
		X_requester_id,
		X_deleted_flag,
                X_Last_Updated_By ,
                X_Last_Update_Date,
                X_Last_Update_Login,
                X_Created_By   ,
                X_Creation_Date,
		X_Attribute_category,
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
		X_Attribute15
             );
    --
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into ce_ba_signatories
  -- History
  --   15-Dec-2004  Shaik Vali	 Created
  -- Arguments
  -- all the columns of the table CE_BA_SIGNATORIES
  -- Example
  --   ce_ba_signatories_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row(
		 X_Rowid            IN OUT NOCOPY VARCHAR2,
                 X_Signatory_Id     IN OUT NOCOPY NUMBER,
                 X_Bank_Account_Id  NUMBER,
                 X_Person_Id     	NUMBER,
		 X_Single_limit_amount	NUMBER,
	         X_Joint_limit_amount	NUMBER,
		 X_Signer_group		VARCHAR2,
		 X_Other_limits		VARCHAR2,
		 X_Start_date		DATE,
		 X_End_date		DATE,
		 X_Status		VARCHAR2,
		 X_Approval_type		VARCHAR2,
		 X_Attribute_category	VARCHAR2,
		 X_Attribute1		VARCHAR2,
		 X_Attribute2		VARCHAR2,
		 X_Attribute3		VARCHAR2,
		 X_Attribute4		VARCHAR2,
		 X_Attribute5		VARCHAR2,
		 X_Attribute6		VARCHAR2,
		 X_Attribute7		VARCHAR2,
		 X_Attribute8		VARCHAR2,
		 X_Attribute9		VARCHAR2,
		 X_Attribute10		VARCHAR2,
		 X_Attribute11		VARCHAR2,
		 X_Attribute12		VARCHAR2,
		 X_Attribute13		VARCHAR2,
		 X_Attribute14		VARCHAR2,
		 X_Attribute15		VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CE_BA_SIGNATORIES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Signatory_id NOWAIT;
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
          (Recinfo.signatory_id =  X_Signatory_id)
           AND (Recinfo.bank_account_id =  X_Bank_Account_Id)
           AND (Recinfo.person_id =  X_person_id)
	   AND (Recinfo.single_limit_amount = X_single_limit_amount
		OR (Recinfo.single_limit_amount is NULL
		 	AND (X_single_limit_amount is NULL)))
	   AND (Recinfo.joint_limit_amount = X_joint_limit_amount
		OR (Recinfo.joint_limit_amount is NULL
		 	AND X_joint_limit_amount is NULL))
	   AND (Recinfo.signer_group = X_signer_group
		OR (Recinfo.signer_group is NULL
		 	AND (X_signer_group is NULL)))
	   AND (Recinfo.other_limits = X_other_limits
		OR (Recinfo.other_limits is NULL
		 	AND (X_other_limits is NULL)))
	   AND (Recinfo.start_date = X_start_Date
		OR (Recinfo.start_date is NULL
		 	AND (X_start_date is NULL)))
	   AND (Recinfo.end_date = X_end_date
		OR (Recinfo.end_date is NULL
		 	AND (X_end_date is NULL)))
	   AND (Recinfo.status = X_status
		OR (Recinfo.status is NULL
		 	AND (X_status is NULL)))
	   AND (Recinfo.approval_type_flag = X_approval_type
		OR (Recinfo.approval_type_flag is NULL
		 	AND (X_approval_type is NULL)))
	   AND (Recinfo.attribute_category = X_attribute_category
		OR (Recinfo.attribute_category is NULL
		 	AND (X_attribute_category is NULL)))
	   AND (Recinfo.attribute1 = X_attribute1
		OR (Recinfo.attribute1 is NULL
		 	AND (X_attribute1 is NULL)))
	   AND (Recinfo.attribute2 = X_attribute2
		OR (Recinfo.attribute2 is NULL
		 	AND (X_attribute2 is NULL)))
	   AND (Recinfo.attribute3 = X_attribute3
		OR (Recinfo.attribute3 is NULL
		 	AND (X_attribute3 is NULL)))
	   AND (Recinfo.attribute4 = X_attribute4
		OR (Recinfo.attribute4 is NULL
		 	AND (X_attribute4 is NULL)))
	   AND (Recinfo.attribute5 = X_attribute5
		OR (Recinfo.attribute5 is NULL
		 	AND (X_attribute5 is NULL)))
	   AND (Recinfo.attribute6 = X_attribute6
		OR (Recinfo.attribute6 is NULL
		 	AND (X_attribute6 is NULL)))
	   AND (Recinfo.attribute7 = X_attribute7
		OR (Recinfo.attribute7 is NULL
		 	AND (X_attribute7 is NULL)))
	   AND (Recinfo.attribute8 = X_attribute8
		OR (Recinfo.attribute8 is NULL
		 	AND (X_attribute8 is NULL)))
	   AND (Recinfo.attribute9 = X_attribute9
		OR (Recinfo.attribute9 is NULL
		 	AND (X_attribute9 is NULL)))
	   AND (Recinfo.attribute10 = X_attribute10
		OR (Recinfo.attribute10 is NULL
		 	AND (X_attribute10 is NULL)))
	   AND (Recinfo.attribute11 = X_attribute11
		OR (Recinfo.attribute11 is NULL
		 	AND (X_attribute11 is NULL)))
	   AND (Recinfo.attribute12 = X_attribute12
		OR (Recinfo.attribute12 is NULL
		 	AND (X_attribute12 is NULL)))
	   AND (Recinfo.attribute13 = X_attribute13
		OR (Recinfo.attribute13 is NULL
		 	AND (X_attribute13 is NULL)))
	   AND (Recinfo.attribute14 = X_attribute14
		OR (Recinfo.attribute14 is NULL
		 	AND (X_attribute14 is NULL)))
	   AND (Recinfo.attribute15 = X_attribute15
		OR (Recinfo.attribute15 is NULL
		 	AND (X_attribute15 is NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into ce_ba_signatories
  -- History
  --   15-Dec-2004  Shaik Vali Created
  -- Arguments
  -- all the columns of the table CE_BA_SIGNATORIES
  -- Example
  --   ce_ba_signatories_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Person_Id     	NUMBER,
				 X_Single_limit_amount	NUMBER,
		         X_Joint_limit_amount	NUMBER,
				 X_Signer_group		VARCHAR2,
				 X_Other_limits		VARCHAR2,
				 X_Start_date		DATE,
				 X_End_date		DATE,
				 X_Status		VARCHAR2,
				 X_Approval_type		VARCHAR2,
				 X_requester_id		NUMBER,
                         X_Last_Updated_By                NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Update_Login              NUMBER,
				 X_Attribute_category		VARCHAR2,
				 X_Attribute1		VARCHAR2,
				 X_Attribute2		VARCHAR2,
				 X_Attribute3		VARCHAR2,
				 X_Attribute4		VARCHAR2,
				 X_Attribute5		VARCHAR2,
				 X_Attribute6		VARCHAR2,
				 X_Attribute7		VARCHAR2,
				 X_Attribute8		VARCHAR2,
				 X_Attribute9		VARCHAR2,
				 X_Attribute10		VARCHAR2,
				 X_Attribute11		VARCHAR2,
				 X_Attribute12		VARCHAR2,
				 X_Attribute13		VARCHAR2,
				 X_Attribute14		VARCHAR2,
				 X_Attribute15		VARCHAR2
  ) IS
  BEGIN
    UPDATE CE_BA_SIGNATORIES
    SET
       signatory_id             =   X_signatory_id,
       bank_account_id          =   X_Bank_Account_Id,
       person_id                =   X_person_id,
	single_limit_amount		= 	X_single_limit_amount,
	joint_limit_amount		=	X_joint_limit_amount,
	signer_group			= 	X_signer_group,
	other_limits			= 	X_other_limits,
	start_date				= 	X_start_date,
	end_date				=	X_end_date,
	status					=	X_status,
	approval_type_flag			=   X_approval_type,
	requester_id			= 	X_requester_id,
        last_updated_by          =   X_Last_Updated_By,
        last_update_date         =   X_Last_Update_Date,
        last_update_login        =   X_Last_Update_Login,
	attribute_category		=	X_attribute_category,
	attribute1				= 	X_attribute1,
	attribute2				= 	X_attribute2,
	attribute3				= 	X_attribute3,
	attribute4				= 	X_attribute4,
	attribute5				= 	X_attribute5,
	attribute6				= 	X_attribute6,
	attribute7				= 	X_attribute7,
	attribute8				= 	X_attribute8,
	attribute9				= 	X_attribute9,
	attribute10				= 	X_attribute10,
	attribute11				= 	X_attribute11,
	attribute12				= 	X_attribute12,
	attribute13				= 	X_attribute13,
	attribute14				= 	X_attribute14,
	attribute15				= 	X_attribute15
    WHERE rowid = X_Rowid;
    --
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  --

  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from ce_je_mappings
  -- History
  --   14-JAN-2005  Shaik Vali  Created
  -- Arguments
  --    x_rowid         Rowid of a row
  -- Example
  --   ce_ba_signatories_pkg.delete_row(...;
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    -- Do not delete the record from the table.
    -- rather mark it for delete.

    UPDATE ce_ba_signatories
    SET deleted_flag = 'Y'
    WHERE rowid=X_Rowid;
   --
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
  --
END CE_BA_SIGNATORIES_PKG;

/
