--------------------------------------------------------
--  DDL for Package Body OKE_FUNDING_POOLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDING_POOLS_PKG" as
/* $Header: OKEFDPLB.pls 115.5 2002/11/27 19:47:16 syho ship $ */

PROCEDURE Insert_Row(X_Rowid           IN OUT NOCOPY  VARCHAR2,
                     X_Funding_Pool_Id		      NUMBER,
                     X_Name			      VARCHAR2,
                     X_Description                    VARCHAR2,
                     X_Currency_Code	  	      VARCHAR2,
                     X_Contact_Person_Id              NUMBER,
                     X_Program_Id		      NUMBER,
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
  ) is

    cursor C is
    select rowid
    from   OKE_FUNDING_POOLS
    where  funding_pool_id = X_Funding_Pool_Id;

begin

       insert into OKE_FUNDING_POOLS(
              funding_pool_id,
              name,
              description,
              contact_person_id,
              program_id,
              currency_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
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
              X_Funding_Pool_Id,
              X_Name,
              X_Description,
              X_Contact_Person_Id,
              X_Program_Id,
              X_Currency_Code,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
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

  	open c;
 	fetch c into X_Rowid;
    	if (c%notfound) then
   	   close c;
    	   raise no_data_found;
        end if;
        close c;

end Insert_Row;


PROCEDURE Lock_Row(X_Funding_Pool_Id		      NUMBER,
                   X_Name			      VARCHAR2,
                   X_Description                      VARCHAR2,
                   X_Currency_Code	  	      VARCHAR2,
                   X_Contact_Person_Id                NUMBER,
                   X_Program_Id		     	      NUMBER,
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
  ) is

    cursor c is
    select funding_pool_id,
    	   name,
           description,
           contact_person_id,
           program_id,
           currency_code,
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
    from   OKE_FUNDING_POOLS
    where  funding_pool_id = X_Funding_Pool_Id
    for update of funding_pool_id nowait;

    recinfo c%rowtype;

begin

    open c;
    fetch c into recinfo;
    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
    end if;
    close c;

    if (   (rtrim(recinfo.currency_code) = rtrim(X_Currency_Code))
       AND ((recinfo.contact_person_id = X_Contact_Person_Id)
           OR ((recinfo.contact_person_id is null) AND (X_Contact_Person_Id is null)))
       AND ((recinfo.program_id = X_Program_Id)
           OR ((recinfo.program_id is null) AND (X_Program_Id is null)))
       AND ((rtrim(recinfo.description) = rtrim(X_Description))
           OR ((recinfo.description is null) AND (X_Description is null)))
       AND (rtrim(recinfo.name) = rtrim(X_Name))
       AND (recinfo.funding_pool_id = X_Funding_Pool_Id)
       AND ((rtrim(recinfo.attribute_category) = rtrim(X_Attribute_Category))
           OR ((recinfo.attribute_category is null) AND (X_Attribute_Category is null)))
       AND ((rtrim(recinfo.attribute1) = rtrim(X_Attribute1))
           OR ((recinfo.attribute1 is null) AND (X_Attribute1 is null)))
       AND ((rtrim(recinfo.attribute2) = rtrim(X_Attribute2))
           OR ((recinfo.attribute2 is null) AND (X_Attribute2 is null)))
       AND ((rtrim(recinfo.attribute3) = rtrim(X_Attribute3))
           OR ((recinfo.attribute3 is null) AND (X_Attribute3 is null)))
       AND ((rtrim(recinfo.attribute4) = rtrim(X_Attribute4))
           OR ((recinfo.attribute4 is null) AND (X_Attribute4 is null)))
       AND ((rtrim(recinfo.attribute5) = rtrim(X_Attribute5))
           OR ((recinfo.attribute5 is null) AND (X_Attribute5 is null)))
       AND ((rtrim(recinfo.attribute6) = rtrim(X_Attribute6))
           OR ((recinfo.attribute6 is null) AND (X_Attribute6 is null)))
       AND ((rtrim(recinfo.attribute7) = rtrim(X_Attribute7))
           OR ((recinfo.attribute7 is null) AND (X_Attribute7 is null)))
       AND ((rtrim(recinfo.attribute8) = rtrim(X_Attribute8))
           OR ((recinfo.attribute8 is null) AND (X_Attribute8 is null)))
       AND ((rtrim(recinfo.attribute9) = rtrim(X_Attribute9))
           OR ((recinfo.attribute9 is null) AND (X_Attribute9 is null)))
       AND ((rtrim(recinfo.attribute10) = rtrim(X_Attribute10))
           OR ((recinfo.attribute10 is null) AND (X_Attribute10 is null)))
       AND ((rtrim(recinfo.attribute11) = rtrim(X_Attribute11))
           OR ((recinfo.attribute11 is null) AND (X_Attribute11 is null)))
       AND ((rtrim(recinfo.attribute12) = rtrim(X_Attribute12))
           OR ((recinfo.attribute12 is null) AND (X_Attribute12 is null)))
       AND ((rtrim(recinfo.attribute13) = rtrim(X_Attribute13))
           OR ((recinfo.attribute13 is null) AND (X_Attribute13 is null)))
       AND ((rtrim(recinfo.attribute14) = rtrim(X_Attribute14))
           OR ((recinfo.attribute14 is null) AND (X_Attribute14 is null)))
       AND ((rtrim(recinfo.attribute15) = rtrim(X_Attribute15))
           OR ((recinfo.attribute15 is null) AND (X_Attribute15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end Lock_Row;


PROCEDURE Update_Row(X_Funding_Pool_Id		      NUMBER,
                     X_Name			      VARCHAR2,
                     X_Description                    VARCHAR2,
                     X_Contact_Person_Id              NUMBER,
                     X_Program_Id		      NUMBER,
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
  ) is

begin

    update OKE_FUNDING_POOLS
    set
       name			       =     X_Name,
       description		       =     X_Description,
       contact_person_id	       =     X_Contact_Person_Id,
       program_id		       =     X_Program_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute_Category              =     X_Attribute_Category,
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
    where funding_pool_id = X_Funding_Pool_Id;

    if (sql%notfound) then
        raise no_data_found;
    end if;

end Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

   DELETE FROM OKE_FUNDING_POOLS
   WHERE rowid = X_Rowid;

   if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
   end if;

EXCEPTION
   WHEN OTHERS THEN
        raise;

END Delete_Row;

end OKE_FUNDING_POOLS_PKG;

/
