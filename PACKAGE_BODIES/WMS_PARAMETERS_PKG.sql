--------------------------------------------------------
--  DDL for Package Body WMS_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PARAMETERS_PKG" as
/* $Header: WMSPPARB.pls 120.1 2005/06/20 07:10:33 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_PARAMETER_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REF_TYPE_CODE in NUMBER,
  X_DB_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REFERENCE_ID in NUMBER,
  X_PARAMETER_TYPE_CODE in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DATA_TYPE_CODE in NUMBER,
  X_USE_FOR_PUT_SORT_FLAG in VARCHAR2,
  X_USE_FOR_PUT_REST_FLAG in VARCHAR2,
  X_USE_FOR_PUT_QTYF_FLAG in VARCHAR2,
  X_USE_FOR_PICK_SORT_FLAG in VARCHAR2,
  X_USE_FOR_PICK_REST_FLAG in VARCHAR2,
  X_USE_FOR_PICK_QTYF_FLAG in VARCHAR2,
  X_USE_FOR_TT_ASSN_FLAG   in VARCHAR2,
  X_USE_FOR_LABEL_REST_FLAG in VARCHAR2,
  X_USE_FOR_CG_REST_FLAG   in VARCHAR2,
  X_USE_FOR_PICK_CONSIST_FLAG   in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_FLEXFIELD_USAGE_CODE in VARCHAR2,
  X_FLEXFIELD_APPLICATION_ID in NUMBER,
  X_FLEXFIELD_NAME in VARCHAR2,
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
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USE_FOR_OP_SELECTION_FLAG in VARCHAR2
) is
  cursor C is select ROWID from WMS_PARAMETERS_B
    where PARAMETER_ID = X_PARAMETER_ID
    ;
begin
  insert into WMS_PARAMETERS_B (
    PARAMETER_ID,
    OBJECT_ID,
    DB_OBJECT_REF_TYPE_CODE,
    DB_OBJECT_ID,
    DB_OBJECT_REFERENCE_ID,
    PARAMETER_TYPE_CODE,
    COLUMN_NAME,
    EXPRESSION,
    DATA_TYPE_CODE,
    USE_FOR_PUT_SORT_FLAG,
    USE_FOR_PUT_REST_FLAG,
    USE_FOR_PUT_QTYF_FLAG,
    USE_FOR_PICK_SORT_FLAG,
    USE_FOR_PICK_REST_FLAG,
    USE_FOR_PICK_QTYF_FLAG,
    USE_FOR_TT_ASSN_FLAG,
    USE_FOR_LABEL_REST_FLAG,
    USE_FOR_CG_REST_FLAG,
    USE_FOR_PICK_CONSIST_FLAG,
    USER_DEFINED_FLAG,
    FLEXFIELD_USAGE_CODE,
    FLEXFIELD_APPLICATION_ID,
    FLEXFIELD_NAME,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    last_update_login,
    USE_FOR_OP_SELECTION_FLAG
  ) values (
    X_PARAMETER_ID,
    X_OBJECT_ID,
    X_DB_OBJECT_REF_TYPE_CODE,
    X_DB_OBJECT_ID,
    X_DB_OBJECT_REFERENCE_ID,
    X_PARAMETER_TYPE_CODE,
    X_COLUMN_NAME,
    X_EXPRESSION,
    X_DATA_TYPE_CODE,
    X_USE_FOR_PUT_SORT_FLAG,
    X_USE_FOR_PUT_REST_FLAG,
    X_USE_FOR_PUT_QTYF_FLAG,
    X_USE_FOR_PICK_SORT_FLAG,
    X_USE_FOR_PICK_REST_FLAG,
    X_USE_FOR_PICK_QTYF_FLAG,
    X_USE_FOR_TT_ASSN_FLAG,
    X_USE_FOR_LABEL_REST_FLAG,
    X_USE_FOR_CG_REST_FLAG,
    X_USE_FOR_PICK_CONSIST_FLAG,
    X_USER_DEFINED_FLAG,
    X_FLEXFIELD_USAGE_CODE,
    X_FLEXFIELD_APPLICATION_ID,
    X_FLEXFIELD_NAME,
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
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USE_FOR_OP_SELECTION_FLAG
    );

  insert into WMS_PARAMETERS_TL (
    PARAMETER_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PARAMETER_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_PARAMETERS_TL T
    where T.PARAMETER_ID = X_PARAMETER_ID
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
  X_PARAMETER_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REF_TYPE_CODE in NUMBER,
  X_DB_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REFERENCE_ID in NUMBER,
  X_PARAMETER_TYPE_CODE in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DATA_TYPE_CODE in NUMBER,
  X_USE_FOR_PUT_SORT_FLAG   in VARCHAR2,
  X_USE_FOR_PUT_REST_FLAG   in VARCHAR2,
  X_USE_FOR_PUT_QTYF_FLAG   in VARCHAR2,
  X_USE_FOR_PICK_SORT_FLAG  in VARCHAR2,
  X_USE_FOR_PICK_REST_FLAG  in VARCHAR2,
  X_USE_FOR_PICK_QTYF_FLAG  in VARCHAR2,
  X_USE_FOR_TT_ASSN_FLAG    in VARCHAR2,
  X_USE_FOR_LABEL_REST_FLAG in VARCHAR2,
  X_USE_FOR_CG_REST_FLAG    in VARCHAR2,
  X_USE_FOR_PICK_CONSIST_FLAG    in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_FLEXFIELD_USAGE_CODE in VARCHAR2,
  X_FLEXFIELD_APPLICATION_ID in NUMBER,
  X_FLEXFIELD_NAME in VARCHAR2,
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
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USE_FOR_OP_SELECTION_FLAG in VARCHAR2
  ) is
  cursor c is select
      OBJECT_ID,
      DB_OBJECT_REF_TYPE_CODE,
      DB_OBJECT_ID,
      DB_OBJECT_REFERENCE_ID,
      PARAMETER_TYPE_CODE,
      COLUMN_NAME,
      EXPRESSION,
      DATA_TYPE_CODE,
      USE_FOR_PUT_SORT_FLAG,
      USE_FOR_PUT_REST_FLAG,
      USE_FOR_PUT_QTYF_FLAG,
      USE_FOR_PICK_SORT_FLAG,
      USE_FOR_PICK_REST_FLAG,
      USE_FOR_PICK_QTYF_FLAG,
      USE_FOR_TT_ASSN_FLAG,
      USE_FOR_LABEL_REST_FLAG,
      USE_FOR_CG_REST_FLAG,
      USE_FOR_PICK_CONSIST_FLAG,
      USER_DEFINED_FLAG,
      FLEXFIELD_USAGE_CODE,
      FLEXFIELD_APPLICATION_ID,
      FLEXFIELD_NAME,
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
      USE_FOR_OP_SELECTION_FLAG
    from WMS_PARAMETERS_B
    where PARAMETER_ID = X_PARAMETER_ID
    for update of PARAMETER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_PARAMETERS_TL
    where PARAMETER_ID = X_PARAMETER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARAMETER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_ID = X_OBJECT_ID)
      AND (recinfo.DB_OBJECT_REF_TYPE_CODE = X_DB_OBJECT_REF_TYPE_CODE)
      AND ((recinfo.DB_OBJECT_ID = X_DB_OBJECT_ID)
           OR ((recinfo.DB_OBJECT_ID is null) AND (X_DB_OBJECT_ID is null)))
      AND ((recinfo.DB_OBJECT_REFERENCE_ID = X_DB_OBJECT_REFERENCE_ID)
           OR ((recinfo.DB_OBJECT_REFERENCE_ID is null) AND (X_DB_OBJECT_REFERENCE_ID is null)))
      AND (recinfo.PARAMETER_TYPE_CODE = X_PARAMETER_TYPE_CODE)
      AND ((recinfo.COLUMN_NAME = X_COLUMN_NAME)
           OR ((recinfo.COLUMN_NAME is null) AND (X_COLUMN_NAME is null)))
      AND ((recinfo.EXPRESSION = X_EXPRESSION)
           OR ((recinfo.EXPRESSION is null) AND (X_EXPRESSION is null)))
      AND (recinfo.DATA_TYPE_CODE = X_DATA_TYPE_CODE)
      AND (recinfo.USE_FOR_PUT_SORT_FLAG   = X_USE_FOR_PUT_SORT_FLAG)
      AND (recinfo.USE_FOR_PUT_REST_FLAG   = X_USE_FOR_PUT_REST_FLAG)
      AND (recinfo.USE_FOR_PUT_QTYF_FLAG   = X_USE_FOR_PUT_QTYF_FLAG)
      AND (recinfo.USE_FOR_PICK_SORT_FLAG  = X_USE_FOR_PICK_SORT_FLAG)
      AND (recinfo.USE_FOR_PICK_REST_FLAG  = X_USE_FOR_PICK_REST_FLAG)
      AND (recinfo.USE_FOR_PICK_QTYF_FLAG  = X_USE_FOR_PICK_QTYF_FLAG)
      AND (recinfo.USE_FOR_TT_ASSN_FLAG    = X_USE_FOR_TT_ASSN_FLAG)
      AND (recinfo.USE_FOR_LABEL_REST_FLAG = X_USE_FOR_LABEL_REST_FLAG)
      AND (recinfo.USE_FOR_CG_REST_FLAG    = X_USE_FOR_CG_REST_FLAG)
      AND (recinfo.USE_FOR_PICK_CONSIST_FLAG = X_USE_FOR_PICK_CONSIST_FLAG)
      AND (recinfo.USER_DEFINED_FLAG = X_USER_DEFINED_FLAG)
      AND ((recinfo.FLEXFIELD_USAGE_CODE = X_FLEXFIELD_USAGE_CODE)
           OR ((recinfo.FLEXFIELD_USAGE_CODE is null) AND (X_FLEXFIELD_USAGE_CODE is null)))
      AND ((recinfo.FLEXFIELD_APPLICATION_ID = X_FLEXFIELD_APPLICATION_ID)
           OR ((recinfo.FLEXFIELD_APPLICATION_ID is null) AND (X_FLEXFIELD_APPLICATION_ID is null)))
      AND ((recinfo.FLEXFIELD_NAME = X_FLEXFIELD_NAME)
           OR ((recinfo.FLEXFIELD_NAME is null) AND (X_FLEXFIELD_NAME is null)))
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
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.USE_FOR_OP_SELECTION_FLAG = X_USE_FOR_OP_SELECTION_FLAG)
           OR ((recinfo.USE_FOR_OP_SELECTION_FLAG is null) AND (X_USE_FOR_OP_SELECTION_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_PARAMETER_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REF_TYPE_CODE in NUMBER,
  X_DB_OBJECT_ID in NUMBER,
  X_DB_OBJECT_REFERENCE_ID in NUMBER,
  X_PARAMETER_TYPE_CODE in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DATA_TYPE_CODE in NUMBER,
  X_USE_FOR_PUT_SORT_FLAG   in VARCHAR2,
  X_USE_FOR_PUT_REST_FLAG   in VARCHAR2,
  X_USE_FOR_PUT_QTYF_FLAG   in VARCHAR2,
  X_USE_FOR_PICK_SORT_FLAG  in VARCHAR2,
  X_USE_FOR_PICK_REST_FLAG  in VARCHAR2,
  X_USE_FOR_PICK_QTYF_FLAG  in VARCHAR2,
  X_USE_FOR_TT_ASSN_FLAG    in VARCHAR2,
  X_USE_FOR_LABEL_REST_FLAG in VARCHAR2,
  X_USE_FOR_CG_REST_FLAG    in VARCHAR2,
  X_USE_FOR_PICK_CONSIST_FLAG    in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_FLEXFIELD_USAGE_CODE in VARCHAR2,
  X_FLEXFIELD_APPLICATION_ID in NUMBER,
  X_FLEXFIELD_NAME in VARCHAR2,
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
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_USE_FOR_OP_SELECTION_FLAG in VARCHAR2
) is
begin
  update WMS_PARAMETERS_B set
    OBJECT_ID = X_OBJECT_ID,
    DB_OBJECT_REF_TYPE_CODE = X_DB_OBJECT_REF_TYPE_CODE,
    DB_OBJECT_ID = X_DB_OBJECT_ID,
    DB_OBJECT_REFERENCE_ID = X_DB_OBJECT_REFERENCE_ID,
    PARAMETER_TYPE_CODE = X_PARAMETER_TYPE_CODE,
    COLUMN_NAME = X_COLUMN_NAME,
    EXPRESSION = X_EXPRESSION,
    DATA_TYPE_CODE = X_DATA_TYPE_CODE,
    USE_FOR_PUT_SORT_FLAG   = X_USE_FOR_PUT_SORT_FLAG,
    USE_FOR_PUT_REST_FLAG   = X_USE_FOR_PUT_REST_FLAG,
    USE_FOR_PUT_QTYF_FLAG   = X_USE_FOR_PUT_QTYF_FLAG,
    USE_FOR_PICK_SORT_FLAG  = X_USE_FOR_PICK_SORT_FLAG,
    USE_FOR_PICK_REST_FLAG  = X_USE_FOR_PICK_REST_FLAG,
    USE_FOR_PICK_QTYF_FLAG  = X_USE_FOR_PICK_QTYF_FLAG,
    USE_FOR_TT_ASSN_FLAG    = X_USE_FOR_TT_ASSN_FLAG,
    USE_FOR_LABEL_REST_FLAG = X_USE_FOR_LABEL_REST_FLAG,
    USE_FOR_CG_REST_FLAG    = X_USE_FOR_CG_REST_FLAG,
    USE_FOR_PICK_CONSIST_FLAG    = X_USE_FOR_PICK_CONSIST_FLAG,
    USER_DEFINED_FLAG = X_USER_DEFINED_FLAG,
    FLEXFIELD_USAGE_CODE = X_FLEXFIELD_USAGE_CODE,
    FLEXFIELD_APPLICATION_ID = X_FLEXFIELD_APPLICATION_ID,
    FLEXFIELD_NAME = X_FLEXFIELD_NAME,
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
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    USE_FOR_OP_SELECTION_FLAG = X_USE_FOR_OP_SELECTION_FLAG
    where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_PARAMETERS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARAMETER_ID = X_PARAMETER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_ID in NUMBER
) is
begin
  delete from WMS_PARAMETERS_TL
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_PARAMETERS_B
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_PARAMETERS_TL T
  where not exists
    (select NULL
    from WMS_PARAMETERS_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    );

  update WMS_PARAMETERS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WMS_PARAMETERS_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from WMS_PARAMETERS_TL SUBB, WMS_PARAMETERS_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WMS_PARAMETERS_TL (
    PARAMETER_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PARAMETER_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_PARAMETERS_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE translate_row
  (
   x_parameter_id             IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_name                     IN  VARCHAR2 ,
   x_description              IN  VARCHAR2
   ) IS
BEGIN
   UPDATE wms_parameters_tl SET
     name              = x_name,
     description       = x_description,
     last_update_date  = Sysdate,
     last_updated_by   = Decode(x_owner, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
     WHERE parameter_id = fnd_number.canonical_to_number(x_parameter_id)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;

PROCEDURE load_row
  (
   x_parameter_id             IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_object_id                IN  VARCHAR2 ,
   x_db_object_ref_type_code  IN  VARCHAR2 ,
   x_db_object_id             IN  VARCHAR2 ,
   x_db_object_reference_id   IN  VARCHAR2 ,
   x_parameter_type_code      IN  VARCHAR2 ,
   x_column_name              IN  VARCHAR2 ,
   x_expression               IN  VARCHAR2 ,
   x_data_type_code           IN  VARCHAR2 ,
   x_use_for_put_sort_flag    IN  VARCHAR2 ,
   x_use_for_put_rest_flag    IN  VARCHAR2 ,
   x_use_for_put_qtyf_flag    IN  VARCHAR2 ,
   x_use_for_pick_sort_flag   IN  VARCHAR2 ,
   x_use_for_pick_rest_flag   IN  VARCHAR2 ,
   x_use_for_pick_qtyf_flag   IN  VARCHAR2 ,
   x_use_for_TT_assn_flag     IN  VARCHAR2 ,
   x_use_for_label_rest_flag  IN  VARCHAR2 ,
   x_use_for_CG_rest_flag     IN  VARCHAR2 ,
   x_use_for_pick_consist_flag IN  VARCHAR2 ,
   x_use_for_op_selection_flag IN  VARCHAR2 ,
   x_user_defined_flag        IN  VARCHAR2 ,
   x_flexfield_usage_code     IN  VARCHAR2 ,
   x_flexfield_application_id IN  VARCHAR2 ,
   x_flexfield_name           IN  VARCHAR2 ,
   x_attribute_category       IN  VARCHAR2 ,
   x_attribute1               IN  VARCHAR2 ,
   x_attribute2 	      IN  VARCHAR2 ,
   x_attribute3 	      IN  VARCHAR2 ,
   x_attribute4 	      IN  VARCHAR2 ,
   x_attribute5 	      IN  VARCHAR2 ,
   x_attribute6 	      IN  VARCHAR2 ,
   x_attribute7 	      IN  VARCHAR2 ,
   x_attribute8 	      IN  VARCHAR2 ,
   x_attribute9 	      IN  VARCHAR2 ,
   x_attribute10 	      IN  VARCHAR2 ,
   x_attribute11 	      IN  VARCHAR2 ,
   x_attribute12 	      IN  VARCHAR2 ,
   x_attribute13 	      IN  VARCHAR2 ,
   x_attribute14 	      IN  VARCHAR2 ,
   x_attribute15 	      IN  VARCHAR2 ,
   x_name                     IN  VARCHAR2 ,
   x_description              IN  VARCHAR2
  ) IS
BEGIN
   DECLARE
      l_parameter_id             NUMBER;
      l_object_id                NUMBER;
      l_db_object_ref_type_code  NUMBER;
      l_db_object_id             NUMBER;
      l_db_object_reference_id   NUMBER;
      l_parameter_type_code      NUMBER;
      l_data_type_code           NUMBER;
      l_flexfield_application_id NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_parameter_id := fnd_number.canonical_to_number(x_parameter_id);
      l_object_id := fnd_number.canonical_to_number(x_object_id);
      l_db_object_ref_type_code := fnd_number.canonical_to_number(x_db_object_ref_type_code);
      l_db_object_id := fnd_number.canonical_to_number(x_db_object_id);
      l_db_object_reference_id := fnd_number.canonical_to_number(x_db_object_reference_id);
      l_parameter_type_code := fnd_number.canonical_to_number(x_parameter_type_code);
      l_data_type_code := fnd_number.canonical_to_number(x_data_type_code);
      l_flexfield_application_id :=
	fnd_number.canonical_to_number(x_flexfield_application_id);
      wms_parameters_pkg.update_row
	(
 	  x_parameter_id             => l_parameter_id
	 ,x_object_id 		     => l_object_id
	 ,x_db_object_ref_type_code  => l_db_object_ref_type_code
	 ,x_db_object_id 	     => l_db_object_id
	 ,x_db_object_reference_id   => l_db_object_reference_id
	 ,x_parameter_type_code      => l_parameter_type_code
	 ,x_column_name		     => x_column_name
	 ,x_expression 		     => x_expression
	 ,x_data_type_code 	     => l_data_type_code
	 ,x_use_for_put_sort_flag    => x_use_for_put_sort_flag
	 ,x_use_for_put_rest_flag    => x_use_for_put_rest_flag
	 ,x_use_for_put_qtyf_flag    => x_use_for_put_qtyf_flag
	 ,x_use_for_pick_sort_flag   => x_use_for_pick_sort_flag
	 ,x_use_for_pick_rest_flag   => x_use_for_pick_rest_flag
	 ,x_use_for_pick_qtyf_flag   => x_use_for_pick_qtyf_flag
	 ,x_use_for_TT_assn_flag     => x_use_for_TT_assn_flag
	 ,x_use_for_label_rest_flag  => x_use_for_label_rest_flag
	 ,x_use_for_CG_rest_flag     => x_use_for_CG_rest_flag
	 ,x_use_for_pick_consist_flag => x_use_for_pick_consist_flag
	 ,x_user_defined_flag 	     => x_user_defined_flag
	 ,x_flexfield_usage_code     => x_flexfield_usage_code
	 ,x_flexfield_application_id => l_flexfield_application_id
	 ,x_flexfield_name 	     => x_flexfield_name
	 ,x_attribute_category	     => x_attribute_category
	 ,x_attribute1 		     => x_attribute1
	 ,x_attribute2 		     => x_attribute2
	 ,x_attribute3 		     => x_attribute3
	 ,x_attribute4 		     => x_attribute4
	 ,x_attribute5 		     => x_attribute5
	 ,x_attribute6 		     => x_attribute6
	 ,x_attribute7               => x_attribute7
	 ,x_attribute8 		     => x_attribute8
	 ,x_attribute9 		     => x_attribute9
	 ,x_attribute10		     => x_attribute10
	 ,x_attribute11		     => x_attribute11
	 ,x_attribute12		     => x_attribute12
	 ,x_attribute13		     => x_attribute13
	 ,x_attribute14		     => x_attribute14
	 ,x_attribute15		     => x_attribute15
	 ,x_name        	     => x_name
	 ,x_description 	     => x_description
	 ,x_last_update_date         => l_sysdate
	 ,x_last_updated_by          => l_user_id
	 ,x_last_update_login        => 0
         ,x_use_for_op_selection_flag => x_use_for_op_selection_flag
	);
   EXCEPTION
      WHEN no_data_found THEN
	 wms_parameters_pkg.insert_row
	   (
	     x_rowid                    => l_row_id
	    ,x_parameter_id             => l_parameter_id
	    ,x_object_id 		=> l_object_id
	    ,x_db_object_ref_type_code  => l_db_object_ref_type_code
	    ,x_db_object_id 	        => l_db_object_id
	    ,x_db_object_reference_id   => l_db_object_reference_id
	    ,x_parameter_type_code      => l_parameter_type_code
	    ,x_column_name		=> x_column_name
	    ,x_expression 		=> x_expression
	    ,x_data_type_code 	        => l_data_type_code
	    ,x_use_for_put_sort_flag    => x_use_for_put_sort_flag
	    ,x_use_for_put_rest_flag    => x_use_for_put_rest_flag
	    ,x_use_for_put_qtyf_flag    => x_use_for_put_qtyf_flag
	    ,x_use_for_pick_sort_flag   => x_use_for_pick_sort_flag
	    ,x_use_for_pick_rest_flag   => x_use_for_pick_rest_flag
	    ,x_use_for_pick_qtyf_flag   => x_use_for_pick_qtyf_flag
	    ,x_use_for_TT_assn_flag     => x_use_for_TT_assn_flag
	    ,x_use_for_label_rest_flag  => x_use_for_label_rest_flag
	    ,x_use_for_CG_rest_flag     => x_use_for_CG_rest_flag
	    ,x_use_for_pick_consist_flag => x_use_for_pick_consist_flag
	    ,x_user_defined_flag 	=> x_user_defined_flag
	    ,x_flexfield_usage_code     => x_flexfield_usage_code
	    ,x_flexfield_application_id => l_flexfield_application_id
	    ,x_flexfield_name 	        => x_flexfield_name
	    ,x_attribute_category	=> x_attribute_category
	    ,x_attribute1 		=> x_attribute1
	    ,x_attribute2 		=> x_attribute2
	    ,x_attribute3 		=> x_attribute3
	    ,x_attribute4 		=> x_attribute4
	    ,x_attribute5 		=> x_attribute5
	    ,x_attribute6 		=> x_attribute6
	    ,x_attribute7               => x_attribute7
	    ,x_attribute8 		=> x_attribute8
	    ,x_attribute9 		=> x_attribute9
	    ,x_attribute10		=> x_attribute10
	    ,x_attribute11		=> x_attribute11
	    ,x_attribute12		=> x_attribute12
	    ,x_attribute13		=> x_attribute13
	    ,x_attribute14		=> x_attribute14
	    ,x_attribute15		=> x_attribute15
	    ,x_name        	        => x_name
	    ,x_description 	        => x_description
	    ,x_last_update_date         => l_sysdate
	    ,x_last_updated_by          => l_user_id
	    ,x_last_update_login        => 0
	    ,x_created_by               => l_user_id
	    ,x_creation_date            => l_sysdate
            ,x_use_for_op_selection_flag => x_use_for_op_selection_flag
	   );
   END;
END load_row;
end WMS_PARAMETERS_PKG;

/
