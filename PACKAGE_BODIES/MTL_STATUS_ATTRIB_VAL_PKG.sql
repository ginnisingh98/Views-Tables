--------------------------------------------------------
--  DDL for Package Body MTL_STATUS_ATTRIB_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_STATUS_ATTRIB_VAL_PKG" as
/* $Header: INVSDOSB.pls 120.1 2005/07/01 12:56:28 appldev ship $ */


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Inventory_Item_Status_Code       VARCHAR2,
                     X_Attribute_Name                   VARCHAR2,
                     X_Attribute_Value                  VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   MTL_STATUS_ATTRIBUTE_VALUES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Inventory_Item_Status_Code NOWAIT;
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
    if ( (Recinfo.inventory_item_status_code =  X_Inventory_Item_Status_Code)
           AND (Recinfo.attribute_name =  X_Attribute_Name)
           AND (Recinfo.attribute_value =  X_Attribute_Value)) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Inventory_Item_Status_Code     VARCHAR2,
                       X_Status_Code_Ndb                NUMBER,
                       X_Attribute_Name                 VARCHAR2,
                       X_Attribute_Value                VARCHAR2,
                       X_Old_Attribute_Value            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN

    IF ((X_Attribute_Value <> X_Old_Attribute_Value) AND
        (X_STATUS_CODE_NDB = 1))  THEN
        INVUPDAT.UPDATE_ATTRIBUTES( X_Attribute_Name,
                                    X_Attribute_Value,
                                    X_Inventory_Item_Status_Code);
    END IF;

    UPDATE MTL_STATUS_ATTRIBUTE_VALUES
    SET
       inventory_item_status_code      =     X_Inventory_Item_Status_Code,
       attribute_name                  =     X_Attribute_Name,
       attribute_value                 =     X_Attribute_Value,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM MTL_STATUS_ATTRIBUTE_VALUES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


------ BUG #867987 : Changes made in the following procedure.
------ Adding variable 'userid' to populate the last_updated_by and created_by
------        fields of MTL_STATUS_ATTRIBUTE_VALUES. Earlier 'logid' was used instead.

 PROCEDURE     Populate_Tab ( status_code IN VARCHAR2 )
 IS
   logid  NUMBER;
   userid NUMBER;
 BEGIN
   logid := FND_GLOBAL.LOGIN_ID;
   userid := FND_GLOBAL.USER_ID;

   insert into mtl_status_attribute_values
  ( inventory_item_status_code,
    attribute_name,
    attribute_value,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login)
  select status_code,
        attr.attribute_name,
        'N',
        sysdate,
        userid,
        sysdate,
        userid,
        logid
 from   mtl_item_attributes attr
 where  attr.STATUS_CONTROL_CODE is not NULL;

  exception
    when others then
         raise_application_error(-20001, sqlerrm);

 END Populate_Tab;

END MTL_STATUS_ATTRIB_VAL_PKG;

/
