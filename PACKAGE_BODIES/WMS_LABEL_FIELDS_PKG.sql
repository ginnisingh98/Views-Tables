--------------------------------------------------------
--  DDL for Package Body WMS_LABEL_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LABEL_FIELDS_PKG" as
/* $Header: WMSLBFLB.pls 120.0 2005/05/24 19:11:22 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID               in out NOCOPY VARCHAR2,
  X_LABEL_FIELD_ID      in      NUMBER,
  X_DOCUMENT_ID         in      NUMBER,
  X_FIELD_LIST_UPDATED_FLAG     in VARCHAR2,
  X_COLUMN_NAME         in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2,
  X_FIELD_NAME          in VARCHAR2,
  X_FIELD_DESCRIPTION   in VARCHAR2,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER,
  X_CREATED_BY          in NUMBER,
  X_CREATION_DATE       in DATE,
  X_REQUEST_ID          in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID          in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_WMS_EXCLUSIVE       in VARCHAR2,
  X_SQL_STMT in VARCHAR2 DEFAULT null
) is
  cursor C is select ROWID from WMS_LABEL_FIELDS_B
    where LABEL_FIELD_ID = X_LABEL_FIELD_ID
    ;
begin
  insert into WMS_LABEL_FIELDS_B (
    LABEL_FIELD_ID,
    DOCUMENT_ID,
    FIELD_LIST_UPDATED_FLAG,
    COLUMN_NAME,
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
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    WMS_EXCLUSIVE,
    SQL_STMT
  ) values (
    X_LABEL_FIELD_ID,
    X_DOCUMENT_ID,
    X_FIELD_LIST_UPDATED_FLAG,
    X_COLUMN_NAME,
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
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    X_WMS_EXCLUSIVE,
    X_SQL_STMT
  );

  insert into WMS_LABEL_FIELDS_TL (
    LABEL_FIELD_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    FIELD_NAME,
    FIELD_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LABEL_FIELD_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_FIELD_NAME,
    X_FIELD_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_LABEL_FIELDS_TL T
    where T.LABEL_FIELD_ID = X_LABEL_FIELD_ID
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
  X_LABEL_FIELD_ID      in NUMBER,
  X_DOCUMENT_ID         in NUMBER,
  X_FIELD_LIST_UPDATED_FLAG in VARCHAR2,
  X_COLUMN_NAME         in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2,
  X_FIELD_NAME          in VARCHAR2,
  X_FIELD_DESCRIPTION   in VARCHAR2,
  X_WMS_EXCLUSIVE       in VARCHAR2,
  X_SQL_STMT            in VARCHAR2 DEFAULT NULL
) is
  cursor c is select
      DOCUMENT_ID,
      FIELD_LIST_UPDATED_FLAG,
      COLUMN_NAME,
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
      WMS_EXCLUSIVE,
      SQL_STMT
    from WMS_LABEL_FIELDS_B
    where LABEL_FIELD_ID = X_LABEL_FIELD_ID
    for update of LABEL_FIELD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FIELD_NAME,
      FIELD_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_LABEL_FIELDS_TL
    where LABEL_FIELD_ID = X_LABEL_FIELD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LABEL_FIELD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DOCUMENT_ID = X_DOCUMENT_ID)
      AND ((recinfo.FIELD_LIST_UPDATED_FLAG = X_FIELD_LIST_UPDATED_FLAG)
           OR ((recinfo.FIELD_LIST_UPDATED_FLAG is null) AND (X_FIELD_LIST_UPDATED_FLAG is null)))
      AND ((recinfo.COLUMN_NAME = X_COLUMN_NAME)
           OR ((recinfo.COLUMN_NAME is null) AND (X_COLUMN_NAME is null)))
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
      AND ((recinfo.WMS_EXCLUSIVE = X_WMS_EXCLUSIVE)
           OR ((recinfo.WMS_EXCLUSIVE is null) AND (X_WMS_EXCLUSIVE is null)))
      AND ((recinfo.SQL_STMT = X_SQL_STMT)
           OR ((recinfo.SQL_STMT is null) AND (X_SQL_STMT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y')  then
      if (    (tlinfo.FIELD_NAME = X_FIELD_NAME)
          AND (tlinfo.FIELD_DESCRIPTION = X_FIELD_DESCRIPTION)
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
  X_LABEL_FIELD_ID      in NUMBER,
  X_DOCUMENT_ID         in NUMBER,
  X_FIELD_LIST_UPDATED_FLAG in VARCHAR2,
  X_COLUMN_NAME         in VARCHAR2,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2,
  X_FIELD_NAME          in VARCHAR2,
  X_FIELD_DESCRIPTION   in VARCHAR2,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER,
  X_WMS_EXCLUSIVE       in VARCHAR2,
  X_SQL_STMT            in VARCHAR2 DEFAULT NULL
) is
begin
  update WMS_LABEL_FIELDS_B set
    DOCUMENT_ID 	= X_DOCUMENT_ID,
    FIELD_LIST_UPDATED_FLAG = X_FIELD_LIST_UPDATED_FLAG,
    COLUMN_NAME 	= X_COLUMN_NAME,
    ATTRIBUTE_CATEGORY 	= X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 		= X_ATTRIBUTE1,
    ATTRIBUTE2 		= X_ATTRIBUTE2,
    ATTRIBUTE3 		= X_ATTRIBUTE3,
    ATTRIBUTE4 		= X_ATTRIBUTE4,
    ATTRIBUTE5 		= X_ATTRIBUTE5,
    ATTRIBUTE6 		= X_ATTRIBUTE6,
    ATTRIBUTE7 		= X_ATTRIBUTE7,
    ATTRIBUTE8 		= X_ATTRIBUTE8,
    ATTRIBUTE9 		= X_ATTRIBUTE9,
    ATTRIBUTE10 	= X_ATTRIBUTE10,
    ATTRIBUTE11 	= X_ATTRIBUTE11,
    ATTRIBUTE12 	= X_ATTRIBUTE12,
    ATTRIBUTE13 	= X_ATTRIBUTE13,
    ATTRIBUTE14 	= X_ATTRIBUTE14,
    ATTRIBUTE15 	= X_ATTRIBUTE15,
    LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 	= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN,
    WMS_EXCLUSIVE       = X_WMS_EXCLUSIVE,
    SQL_STMT            = X_SQL_STMT
  where LABEL_FIELD_ID 	= X_LABEL_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_LABEL_FIELDS_TL set
    FIELD_NAME = X_FIELD_NAME,
    FIELD_DESCRIPTION = X_FIELD_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LABEL_FIELD_ID = X_LABEL_FIELD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LABEL_FIELD_ID in NUMBER
) is
begin
  delete from WMS_LABEL_FIELDS_TL
  where LABEL_FIELD_ID = X_LABEL_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_LABEL_FIELDS_B
  where LABEL_FIELD_ID = X_LABEL_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_LABEL_FIELDS_TL T
  where not exists
    (select NULL
    from WMS_LABEL_FIELDS_B B
    where B.LABEL_FIELD_ID = T.LABEL_FIELD_ID
    );

  update WMS_LABEL_FIELDS_TL T set (
      FIELD_NAME,
      FIELD_DESCRIPTION
    ) = (select
      	   B.FIELD_NAME,
      	   B.FIELD_DESCRIPTION
    	 from WMS_LABEL_FIELDS_TL B
    	 where B.LABEL_FIELD_ID = T.LABEL_FIELD_ID
    	   and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LABEL_FIELD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LABEL_FIELD_ID,
      SUBT.LANGUAGE
    from WMS_LABEL_FIELDS_TL SUBB, WMS_LABEL_FIELDS_TL SUBT
    where SUBB.LABEL_FIELD_ID = SUBT.LABEL_FIELD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FIELD_NAME <> SUBT.FIELD_NAME
      or SUBB.FIELD_DESCRIPTION <> SUBT.FIELD_DESCRIPTION
      or (SUBB.FIELD_DESCRIPTION is null and SUBT.FIELD_DESCRIPTION is not null)
      or (SUBB.FIELD_DESCRIPTION is not null and SUBT.FIELD_DESCRIPTION is null)
  ));

  insert into WMS_LABEL_FIELDS_TL (
    LABEL_FIELD_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    FIELD_NAME,
    FIELD_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LABEL_FIELD_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.FIELD_NAME,
    B.FIELD_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_LABEL_FIELDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_LABEL_FIELDS_TL T
    where T.LABEL_FIELD_ID = B.LABEL_FIELD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE translate_row
  (
   x_label_field_id           IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_field_name               IN  VARCHAR2 ,
   x_field_description        IN  VARCHAR2
   ) IS
BEGIN
   UPDATE wms_label_fields_tl SET
     field_name        = x_field_name,
     field_description = x_field_description,
     last_update_date  = sysdate,
     last_updated_by   = Decode(x_owner, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
     WHERE label_field_id = fnd_number.canonical_to_number(x_label_field_id)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;

PROCEDURE load_row
  (
   x_label_field_id           IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_document_id              IN  VARCHAR2 ,
   x_field_list_updated_flag  IN  VARCHAR2 ,
   x_column_name              IN  VARCHAR2 ,
   x_attribute_category       IN  VARCHAR2 ,
   x_attribute1               IN  VARCHAR2 ,
   x_attribute2               IN  VARCHAR2 ,
   x_attribute3               IN  VARCHAR2 ,
   x_attribute4               IN  VARCHAR2 ,
   x_attribute5               IN  VARCHAR2 ,
   x_attribute6               IN  VARCHAR2 ,
   x_attribute7               IN  VARCHAR2 ,
   x_attribute8               IN  VARCHAR2 ,
   x_attribute9               IN  VARCHAR2 ,
   x_attribute10              IN  VARCHAR2 ,
   x_attribute11              IN  VARCHAR2 ,
   x_attribute12              IN  VARCHAR2 ,
   x_attribute13              IN  VARCHAR2 ,
   x_attribute14              IN  VARCHAR2 ,
   x_attribute15              IN  VARCHAR2 ,
   x_field_name               IN  VARCHAR2 ,
   x_field_description        IN  VARCHAR2 ,
   x_wms_exclusive            IN  VARCHAR2
  ) IS
BEGIN
   DECLARE
      l_label_field_id	         NUMBER;
      l_document_id              NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_label_field_id 	:= fnd_number.canonical_to_number(x_label_field_id);
      l_document_id 	:= fnd_number.canonical_to_number(x_document_id);
      wms_label_fields_pkg.update_row
	(
 	  x_label_field_id           => l_label_field_id
	 ,x_document_id 	     => l_document_id
	 ,x_field_list_updated_flag  => x_field_list_updated_flag
	 ,x_column_name		     => x_column_name
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
	 ,x_field_name        	     => x_field_name
	 ,x_field_description 	     => x_field_description
	 ,x_last_update_date         => l_sysdate
	 ,x_last_updated_by          => l_user_id
	 ,x_last_update_login        => 0
         ,x_wms_exclusive            => x_wms_exclusive
	);
   EXCEPTION
     WHEN no_data_found THEN
       wms_label_fields_pkg.insert_row
        (
	  x_rowid                    => l_row_id
         ,x_label_field_id           => l_label_field_id
         ,x_document_id              => l_document_id
         ,x_field_list_updated_flag  => x_field_list_updated_flag
         ,x_column_name              => x_column_name
         ,x_attribute_category       => x_attribute_category
         ,x_attribute1               => x_attribute1
         ,x_attribute2               => x_attribute2
         ,x_attribute3               => x_attribute3
         ,x_attribute4               => x_attribute4
         ,x_attribute5               => x_attribute5
         ,x_attribute6               => x_attribute6
         ,x_attribute7               => x_attribute7
         ,x_attribute8               => x_attribute8
         ,x_attribute9               => x_attribute9
         ,x_attribute10              => x_attribute10
         ,x_attribute11              => x_attribute11
         ,x_attribute12              => x_attribute12
         ,x_attribute13              => x_attribute13
         ,x_attribute14              => x_attribute14
         ,x_attribute15              => x_attribute15
         ,x_field_name               => x_field_name
         ,x_field_description        => x_field_description
         ,x_last_update_date         => l_sysdate
         ,x_last_updated_by          => l_user_id
         ,x_last_update_login        => 0
	 ,x_created_by               => l_user_id
	 ,x_creation_date            => l_sysdate
	 ,x_request_id		     => null
	 ,x_program_application_id   => null
	 ,x_program_id		     => null
	 ,x_program_update_date      => null
         ,x_wms_exclusive            => x_wms_exclusive
	 );
   END;
END load_row;
end WMS_LABEL_FIELDS_PKG;

/
