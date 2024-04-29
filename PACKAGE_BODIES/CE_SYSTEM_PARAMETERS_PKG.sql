--------------------------------------------------------
--  DDL for Package Body CE_SYSTEM_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_SYSTEM_PARAMETERS_PKG" as
/* $Header: cesyspab.pls 120.6 2006/01/12 18:49:28 eliu ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.6 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

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
		       X_Signing_Authority_Approval	VARCHAR2,
 		       X_CASHFLOW_EXCHANGE_RATE_TYPE	VARCHAR2,
		       X_AUTHORIZATION_BAT		VARCHAR2,
                       X_BSC_EXCHANGE_DATE_TYPE         VARCHAR2,
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
  ) IS
    CURSOR C IS SELECT rowid FROM CE_SYSTEM_PARAMETERS
                 WHERE set_of_books_id = X_Set_Of_Books_Id;
   BEGIN


       INSERT INTO CE_SYSTEM_PARAMETERS(
	      legal_entity_id,
	      set_of_books_id,
              cashbook_begin_date,
              show_cleared_flag,
              show_void_payment_flag,
	      line_autocreation_flag,
	      interface_purge_flag,
	      interface_archive_flag,
	      lines_per_commit,
	      SIGNING_AUTHORITY_APPR_FLAG,
 	      CASHFLOW_EXCHANGE_RATE_TYPE,
	      AUTHORIZATION_BAT,
              BSC_EXCHANGE_DATE_TYPE,
              BAT_EXCHANGE_DATE_TYPE,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
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
              X_Legal_Entity_Id,
              X_Set_Of_Books_Id,
              X_Cashbook_Begin_Date,
              X_Show_Cleared_Flag,
              X_Show_Void_Payment_Flag,
	      X_line_autocreation_flag,
	      X_interface_purge_flag,
	      X_interface_archive_flag,
              X_Lines_Per_Commit,
	      X_Signing_Authority_Approval,
 	      X_CASHFLOW_EXCHANGE_RATE_TYPE,
	      X_AUTHORIZATION_BAT,
              X_BSC_EXCHANGE_DATE_TYPE,
              X_BAT_EXCHANGE_DATE_TYPE,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
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
              X_Attribute15
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
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CE_SYSTEM_PARAMETERS
        WHERE  rowid = X_Rowid
       FOR UPDATE of Set_Of_Books_Id NOWAIT;
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
           (   (Recinfo.legal_entity_id =  X_Legal_Entity_Id)
                OR (    (Recinfo.legal_entity_id IS NULL)
                    AND (X_Legal_Entity_Id IS NULL)))
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.cashbook_begin_date =  X_Cashbook_Begin_Date)
           AND (Recinfo.show_cleared_flag =  X_Show_Cleared_Flag)
           AND (   (Recinfo.show_void_payment_flag = X_Show_Void_Payment_Flag)
                OR (    (Recinfo.show_void_payment_flag IS NULL)
                    AND (X_Show_Void_Payment_Flag IS NULL)))
           AND (   (Recinfo.lines_per_commit =  X_Lines_Per_Commit)
                OR (    (Recinfo.lines_per_commit IS NULL)
                    AND (X_Lines_Per_Commit IS NULL)))
           AND (   (Recinfo.SIGNING_AUTHORITY_APPR_FLAG =  X_Signing_Authority_Approval)
                OR (    (Recinfo.SIGNING_AUTHORITY_APPR_FLAG IS NULL)
                    AND (X_Signing_Authority_approval IS NULL)))
           AND (   (Recinfo.CASHFLOW_EXCHANGE_RATE_TYPE =  X_CASHFLOW_EXCHANGE_RATE_TYPE)
                OR (    (Recinfo.CASHFLOW_EXCHANGE_RATE_TYPE IS NULL)
                    AND (X_CASHFLOW_EXCHANGE_RATE_TYPE IS NULL)))
           AND (   (Recinfo.AUTHORIZATION_BAT =  X_AUTHORIZATION_BAT)
                OR (    (Recinfo.AUTHORIZATION_BAT IS NULL)
                    AND (X_AUTHORIZATION_BAT IS NULL)))
           AND (   (Recinfo.BSC_EXCHANGE_DATE_TYPE =  X_BSC_EXCHANGE_DATE_TYPE)
                OR (    (Recinfo.BSC_EXCHANGE_DATE_TYPE IS NULL)
                    AND (X_BSC_EXCHANGE_DATE_TYPE IS NULL)))
           AND (   (Recinfo.BAT_EXCHANGE_DATE_TYPE =  X_BAT_EXCHANGE_DATE_TYPE)
                OR (    (Recinfo.BAT_EXCHANGE_DATE_TYPE IS NULL)
                    AND (X_BAT_EXCHANGE_DATE_TYPE IS NULL)))
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
           AND (   (Recinfo.line_autocreation_flag =  X_line_autocreation_flag)
                OR (    (Recinfo.line_autocreation_flag IS NULL)
                    AND (X_line_autocreation_flag IS NULL)))
           AND (   (Recinfo.interface_purge_flag =  X_interface_purge_flag)
                OR (    (Recinfo.interface_purge_flag IS NULL)
                    AND (X_interface_purge_flag IS NULL)))
           AND (   (Recinfo.interface_archive_flag =  X_interface_archive_flag)
                OR (    (Recinfo.interface_archive_flag IS NULL)
                    AND (X_interface_archive_flag IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

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

  ) IS
  BEGIN
    UPDATE CE_SYSTEM_PARAMETERS
    SET
       set_of_books_id                 =     X_Set_Of_Books_Id,
       cashbook_begin_date             =     X_Cashbook_Begin_Date,
       show_cleared_flag               =     X_Show_Cleared_Flag,
       show_void_payment_flag          =     X_Show_Void_Payment_Flag,
       line_autocreation_flag	       =     X_line_autocreation_flag,
       interface_purge_flag	       =     X_interface_purge_flag,
       interface_archive_flag	       =     X_interface_archive_flag,
       lines_per_commit                =     X_Lines_Per_Commit,
       SIGNING_AUTHORITY_APPR_FLAG	   =	 X_Signing_Authority_Approval,
       CASHFLOW_EXCHANGE_RATE_TYPE	=       X_CASHFLOW_EXCHANGE_RATE_TYPE,
       AUTHORIZATION_BAT		=       X_AUTHORIZATION_BAT,
       BSC_EXCHANGE_DATE_TYPE		= 	X_BSC_EXCHANGE_DATE_TYPE,
       BAT_EXCHANGE_DATE_TYPE		=	X_BAT_EXCHANGE_DATE_TYPE,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
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
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM CE_SYSTEM_PARAMETERS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END CE_SYSTEM_PARAMETERS_PKG;

/
