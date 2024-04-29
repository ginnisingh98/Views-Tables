--------------------------------------------------------
--  DDL for Package Body BOM_STRUCTURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_STRUCTURE_TYPES_PKG" as
/* $Header: BOMPSTYPB.pls 120.2 2006/08/29 08:19:26 hgelli noship $ */

  PROCEDURE Insert_Row(X_Structure_Type_Name         VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Catalog_Group_Id          NUMBER,
                       X_Effective_Date                 DATE,
                       X_Structure_Creation_Allowed     VARCHAR2,
                       X_Allow_Subtypes     VARCHAR2,
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
                       X_Disable_Date                   VARCHAR2,
                       X_Parent_Structure_Type_Id       NUMBER,
                       X_Enable_Attachments_Flag        VARCHAR2,
                       X_Display_Name                   VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Upload_mode                    VARCHAR2,
                       X_Custom_mode      VARCHAR2,
                       X_Owner        VARCHAR2
                      )
                      IS
  BEGIN
    declare
      srv_id number;
      str_id number;
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
      stype_exists number;

    BEGIN
      IF (X_Upload_mode = 'NLS')
      THEN

        UPDATE BOM_STRUCTURE_TYPES_TL
          SET
            DISPLAY_NAME      = X_Display_Name,
            DESCRIPTION       = X_Description,
            LAST_UPDATE_DATE  = X_Last_Update_Date,
            LAST_UPDATED_BY   = X_Last_Updated_By,
            LAST_UPDATE_LOGIN = X_Last_Update_Login,
            SOURCE_LANG       = USERENV('LANG')
          WHERE STRUCTURE_TYPE_ID = (SELECT STRUCTURE_TYPE_ID FROM  BOM_STRUCTURE_TYPES_B
                                     WHERE  STRUCTURE_TYPE_NAME = X_Structure_Type_Name)
            AND USERENV('LANG') IN (LANGUAGE,SOURCE_LANG);
      ELSE

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_Owner);

        -- Translate char last_update_date to date
        f_ludate := nvl(X_Last_Update_Date, sysdate);

        -- Get current owner of row in database

        BEGIN

          SELECT LAST_UPDATED_BY,LAST_UPDATE_DATE
            INTO db_luby, db_ludate
          FROM BOM_STRUCTURE_TYPES_B
          WHERE STRUCTURE_TYPE_NAME = X_Structure_Type_Name;

          stype_exists := 1;

          EXCEPTION WHEN NO_DATA_FOUND
          THEN
          db_luby := f_luby;
          db_ludate := f_ludate;
          stype_exists := 0;
        END;

        IF (stype_exists = 0)
        THEN

            SELECT BOM_STRUCTURE_TYPES_B_S.nextval INTO str_id FROM dual;

            INSERT INTO BOM_STRUCTURE_TYPES_B
            (
            STRUCTURE_TYPE_ID,
            STRUCTURE_TYPE_NAME,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            ITEM_CATALOG_GROUP_ID,
            EFFECTIVE_DATE,
            STRUCTURE_CREATION_ALLOWED,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            DISABLE_DATE,
            PARENT_STRUCTURE_TYPE_ID,
            ENABLE_ATTACHMENTS_FLAG,
            ALLOW_SUBTYPES
            )
            SELECT
            str_id,
            X_Structure_Type_Name,
            SYSDATE,
            X_Last_Updated_By,
            SYSDATE,
            X_Created_By,
            X_Last_Update_Login,
            X_Item_Catalog_Group_Id,
            SYSDATE,
            X_Structure_Creation_Allowed,
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
            X_Disable_Date,
            X_Parent_Structure_Type_Id,
            X_Enable_Attachments_Flag,
            X_Allow_Subtypes
            FROM DUAL
            WHERE  NOT EXISTS (SELECT 1  from BOM_STRUCTURE_TYPES_B
                     WHERE STRUCTURE_TYPE_NAME = X_Structure_Type_Name );


            INSERT INTO BOM_STRUCTURE_TYPES_TL
            ( STRUCTURE_TYPE_ID,
            LANGUAGE,
            SOURCE_LANG,
            DISPLAY_NAME,
            DESCRIPTION,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE ,
            CREATED_BY,
            LAST_UPDATE_LOGIN
            )
            SELECT
            str_id,
            L.LANGUAGE_CODE,
            USERENV('LANG'),
            X_Display_Name,
            X_Description,
            SYSDATE,
            X_Last_Updated_By,
            SYSDATE,
            X_Created_By,
            X_Last_Update_Login
            FROM FND_LANGUAGES L
            WHERE L.INSTALLED_FLAG IN ('I','B')
            AND NOT EXISTS
            (SELECT NULL FROM BOM_STRUCTURE_TYPES_TL TL,BOM_STRUCTURE_TYPES_B B
              WHERE B.STRUCTURE_TYPE_ID  = TL.STRUCTURE_TYPE_ID
              AND B.STRUCTURE_TYPE_NAME = X_Structure_Type_Name
              AND  TL.LANGUAGE = L.LANGUAGE_CODE);

        END IF;  -- End of IF for Insert into B and TL

        -- Row exists, test if it should be over-written.
        IF  (stype_exists = 1) AND (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_Custom_mode))
        THEN

            UPDATE BOM_STRUCTURE_TYPES_B
              SET
              ITEM_CATALOG_GROUP_ID        = X_Item_Catalog_Group_Id,
              EFFECTIVE_DATE               = X_Effective_Date,
              STRUCTURE_CREATION_ALLOWED   = X_Structure_Creation_Allowed,
              ALLOW_SUBTYPES               = X_Allow_Subtypes,
              LAST_UPDATE_DATE             = X_Last_Update_Date,
              LAST_UPDATED_BY              = X_Last_Updated_By,
              LAST_UPDATE_LOGIN            = X_Last_Update_Login,
              ATTRIBUTE_CATEGORY           = X_Attribute_Category ,
              ATTRIBUTE1                   = X_Attribute1,
              ATTRIBUTE2                   = X_Attribute2,
              ATTRIBUTE3                   = X_Attribute3,
              ATTRIBUTE4                   = X_Attribute4,
              ATTRIBUTE5                   = X_Attribute5,
              ATTRIBUTE6                   = X_Attribute6,
              ATTRIBUTE7                   = X_Attribute7,
              ATTRIBUTE8                   = X_Attribute8,
              ATTRIBUTE9                   = X_Attribute9,
              ATTRIBUTE10                  = X_Attribute10,
              ATTRIBUTE11                  = X_Attribute11,
              ATTRIBUTE12                  = X_Attribute12,
              ATTRIBUTE13                  = X_Attribute13,
              ATTRIBUTE14                  = X_Attribute14,
              ATTRIBUTE15                  = X_Attribute15,
              DISABLE_DATE                 = X_Disable_Date,
              PARENT_STRUCTURE_TYPE_ID     = X_Parent_Structure_Type_Id,
              ENABLE_ATTACHMENTS_FLAG      = X_Enable_Attachments_Flag
            WHERE
               STRUCTURE_TYPE_NAME    = X_Structure_Type_Name;


            UPDATE BOM_STRUCTURE_TYPES_TL
              SET
              DISPLAY_NAME      = X_Display_Name,
              DESCRIPTION       = X_Description,
              LAST_UPDATE_DATE  = X_Last_Update_Date,
              LAST_UPDATED_BY   = X_Last_Updated_By,
              LAST_UPDATE_LOGIN = X_Last_Update_Login,
              SOURCE_LANG       = USERENV('LANG')
            WHERE STRUCTURE_TYPE_ID =
              (SELECT STRUCTURE_TYPE_ID FROM  BOM_STRUCTURE_TYPES_B
               WHERE  STRUCTURE_TYPE_NAME = X_Structure_Type_Name)
               AND USERENV('LANG') IN (LANGUAGE,SOURCE_LANG);

        END IF; -- End of Test for Updates
      END IF;  -- End of NLS MODE
    END;
  END Insert_Row;

/*

-- Will be using Add_Language generated by FND table handler

PROCEDURE ADD_LANGUAGE
IS
BEGIN
       INSERT INTO BOM_STRUCTURE_TYPES_TL
          (
            STRUCTURE_TYPE_ID,
            LANGUAGE,
            SOURCE_LANG,
            DISPLAY_NAME,
            DESCRIPTION,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE ,
            CREATED_BY,
            LAST_UPDATE_LOGIN
            )
            SELECT
              B.structure_type_id,
              L.LANGUAGE_CODE,
              userenv('LANG'),
              B.DISPLAY_NAME,
              B.DESCRIPTION,
              SYSDATE,
              B.LAST_UPDATED_BY,
              SYSDATE,
              B.CREATED_BY,
              B.LAST_UPDATE_LOGIN
            FROM FND_LANGUAGES L,
                 BOM_STRUCTURE_TYPES_TL B
            WHERE L.INSTALLED_FLAG IN ('I','B')
                 AND NOT EXISTS
                   (SELECT NULL FROM BOM_STRUCTURE_TYPES_TL TL
                      WHERE TL.STRUCTURE_TYPE_ID =   B.STRUCTURE_TYPE_ID
                 AND  TL.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;

*/
-- -------------- START OF CODE FOR TABLE HANDLERS  FOR BOM_STRUCTURE_TYPES_VL --------------
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_UNIMPLEMENTED_BOMS IN VARCHAR2,
  X_ALLOW_SUBTYPES IN VARCHAR2

) is
  cursor C is select ROWID from BOM_STRUCTURE_TYPES_B
    where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID
    ;
begin
  insert into BOM_STRUCTURE_TYPES_B (
    ATTRIBUTE12,
    ATTRIBUTE13,
    DISABLE_DATE,
    STRUCTURE_TYPE_ID,
    STRUCTURE_TYPE_NAME,
    ITEM_CATALOG_GROUP_ID,
    EFFECTIVE_DATE,
    STRUCTURE_CREATION_ALLOWED,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE14,
    ATTRIBUTE15,
    PARENT_STRUCTURE_TYPE_ID,
    ENABLE_ATTACHMENTS_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENABLE_UNIMPLEMENTED_BOMS,
    ALLOW_SUBTYPES
  ) values (
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_DISABLE_DATE,
    X_STRUCTURE_TYPE_ID,
    X_STRUCTURE_TYPE_NAME,
    X_ITEM_CATALOG_GROUP_ID,
    X_EFFECTIVE_DATE,
    X_STRUCTURE_CREATION_ALLOWED,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_PARENT_STRUCTURE_TYPE_ID,
    X_ENABLE_ATTACHMENTS_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ENABLE_UNIMPLEMENTED_BOMS,
    X_ALLOW_SUBTYPES
  );

  insert into BOM_STRUCTURE_TYPES_TL (
    LAST_UPDATE_LOGIN,
    STRUCTURE_TYPE_ID,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_STRUCTURE_TYPE_ID,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BOM_STRUCTURE_TYPES_TL T
    where T.STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENABLE_UNIMPLEMENTED_BOMS in VARCHAR2,
  X_ALLOW_SUBTYPES in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE12,
      ATTRIBUTE13,
      DISABLE_DATE,
      STRUCTURE_TYPE_NAME,
      ITEM_CATALOG_GROUP_ID,
      EFFECTIVE_DATE,
      STRUCTURE_CREATION_ALLOWED,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE14,
      ATTRIBUTE15,
      PARENT_STRUCTURE_TYPE_ID,
      ENABLE_ATTACHMENTS_FLAG,
      ENABLE_UNIMPLEMENTED_BOMS,
      ALLOW_SUBTYPES
    from BOM_STRUCTURE_TYPES_B
    where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID
    for update of STRUCTURE_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BOM_STRUCTURE_TYPES_TL
    where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STRUCTURE_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.DISABLE_DATE = X_DISABLE_DATE)
           OR ((recinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
      AND (recinfo.STRUCTURE_TYPE_NAME = X_STRUCTURE_TYPE_NAME)
      AND ((recinfo.ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID)
           OR ((recinfo.ITEM_CATALOG_GROUP_ID is null) AND (X_ITEM_CATALOG_GROUP_ID is null)))
      AND (recinfo.EFFECTIVE_DATE = X_EFFECTIVE_DATE)
      AND (recinfo.STRUCTURE_CREATION_ALLOWED = X_STRUCTURE_CREATION_ALLOWED)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.PARENT_STRUCTURE_TYPE_ID = X_PARENT_STRUCTURE_TYPE_ID)
           OR ((recinfo.PARENT_STRUCTURE_TYPE_ID is null) AND (X_PARENT_STRUCTURE_TYPE_ID is null)))
      AND ((recinfo.ENABLE_ATTACHMENTS_FLAG = X_ENABLE_ATTACHMENTS_FLAG)
           OR ((recinfo.ENABLE_ATTACHMENTS_FLAG is null) AND (X_ENABLE_ATTACHMENTS_FLAG is null)))
      AND ((recinfo.ENABLE_UNIMPLEMENTED_BOMS = X_ENABLE_UNIMPLEMENTED_BOMS)
           OR ((recinfo.ENABLE_UNIMPLEMENTED_BOMS is null) AND (X_ENABLE_UNIMPLEMENTED_BOMS is null)))
      AND ((recinfo.ALLOW_SUBTYPES = X_ALLOW_SUBTYPES)
           OR ((recinfo.ALLOW_SUBTYPES is null) AND (X_ALLOW_SUBTYPES is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_UNIMPLEMENTED_BOMS in VARCHAR2,
  X_ALLOW_SUBTYPES in VARCHAR2
) is
begin
  update BOM_STRUCTURE_TYPES_B set
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    DISABLE_DATE = X_DISABLE_DATE,
    STRUCTURE_TYPE_NAME = X_STRUCTURE_TYPE_NAME,
    ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID,
    EFFECTIVE_DATE = X_EFFECTIVE_DATE,
    STRUCTURE_CREATION_ALLOWED = X_STRUCTURE_CREATION_ALLOWED,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    PARENT_STRUCTURE_TYPE_ID = X_PARENT_STRUCTURE_TYPE_ID,
    ENABLE_ATTACHMENTS_FLAG = X_ENABLE_ATTACHMENTS_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ENABLE_UNIMPLEMENTED_BOMS = X_ENABLE_UNIMPLEMENTED_BOMS,
    ALLOW_SUBTYPES = X_ALLOW_SUBTYPES
  where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BOM_STRUCTURE_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER
) is
begin
  delete from BOM_STRUCTURE_TYPES_TL
  where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BOM_STRUCTURE_TYPES_B
  where STRUCTURE_TYPE_ID = X_STRUCTURE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BOM_STRUCTURE_TYPES_TL T
  where not exists
    (select NULL
    from BOM_STRUCTURE_TYPES_B B
    where B.STRUCTURE_TYPE_ID = T.STRUCTURE_TYPE_ID
    );

  update BOM_STRUCTURE_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from BOM_STRUCTURE_TYPES_TL B
    where B.STRUCTURE_TYPE_ID = T.STRUCTURE_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STRUCTURE_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STRUCTURE_TYPE_ID,
      SUBT.LANGUAGE
    from BOM_STRUCTURE_TYPES_TL SUBB, BOM_STRUCTURE_TYPES_TL SUBT
    where SUBB.STRUCTURE_TYPE_ID = SUBT.STRUCTURE_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BOM_STRUCTURE_TYPES_TL (
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    DISPLAY_NAME,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    STRUCTURE_TYPE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.STRUCTURE_TYPE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BOM_STRUCTURE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BOM_STRUCTURE_TYPES_TL T
    where T.STRUCTURE_TYPE_ID = B.STRUCTURE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- --------------------------------
PROCEDURE Check_If_Connected(
  p_parent_structure_type_id     IN NUMBER,
  p_structure_type_id            IN NUMBER,
--  p_parent_structure_type_id_new IN NUMBER,
  x_return_status                OUT NOCOPY VARCHAR2
) IS
  CURSOR c_tree_hierarchy(c_p_parent_structure_type_id IN NUMBER) IS
    /* SELECT structure_type_id
    FROM bom_structure_types_b
    CONNECT BY PRIOR structure_type_id = parent_structure_type_id
    START WITH parent_structure_Type_id = c_p_parent_structure_type_id ;
    */
   SELECT structure_type_id
   FROM bom_structure_types_b
   CONNECT BY PRIOR parent_structure_type_id = structure_type_id
   START WITH structure_type_id = c_p_parent_structure_type_id;
  l_structure_type_id NUMBER ;
  l_struct_type_id_orig NUMBER;
BEGIN


   SELECT parent_structure_type_id INTO l_struct_type_id_orig
   FROM bom_structure_types_b
   WHERE structure_type_id = p_structure_type_id;

   IF l_struct_type_id_orig IS null THEN
     x_return_status := 'T';  -- If parent structure type id is null
     RETURN;
   END IF;

   IF p_parent_structure_type_id = l_struct_type_id_orig THEN
    -- Occurs in Edit Mode
    x_return_status := 'T';
    RETURN;
   END IF;

   --dbms_output.put_line('l struct type id '||to_char(l_struct_type_id_orig));

   OPEN c_tree_hierarchy(l_struct_type_id_orig);
   LOOP
     FETCH c_tree_hierarchy INTO l_structure_type_id;
     EXIT WHEN c_tree_hierarchy%NOTFOUND;
     -- Bug : 2991692
     -- Changed p_structure_type_id -> p_parent_structure_type_id
     IF l_structure_type_id = p_parent_structure_type_id THEN
       CLOSE c_tree_hierarchy;
       x_return_status := 'T';
       return;
     END IF;
   END LOOP;
   CLOSE c_tree_hierarchy;
   x_return_status := 'F';
EXCEPTION
WHEN NO_DATA_FOUND
THEN
      x_return_status := 'T';
END Check_If_Connected;
-- -------------- END OF CODE FOR TABLE HANDLERS  FOR BOM_STRUCTURE_TYPES_VL --------------

END BOM_STRUCTURE_TYPES_PKG;

/
