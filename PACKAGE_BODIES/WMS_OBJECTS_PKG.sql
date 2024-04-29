--------------------------------------------------------
--  DDL for Package Body WMS_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OBJECTS_PKG" as
/* $Header: WMSPOBJB.pls 120.1 2005/06/20 03:31:44 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_DB_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_LOV_SQL in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
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
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from WMS_OBJECTS_B
    where OBJECT_ID = X_OBJECT_ID
    ;
begin
  insert into WMS_OBJECTS_B (
    OBJECT_ID,
    STRAT_ASGMT_DB_OBJECT_ID,
    STRAT_ASGMT_LOV_SQL,
    USER_DEFINED_FLAG,
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
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_ID,
    X_STRAT_ASGMT_DB_OBJECT_ID,
    X_STRAT_ASGMT_LOV_SQL,
    X_USER_DEFINED_FLAG,
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
    X_LAST_UPDATE_LOGIN
  );

  insert into WMS_OBJECTS_TL (
    NAME,
    DESCRIPTION,
    OBJECT_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NAME,
    X_DESCRIPTION,
    X_OBJECT_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_OBJECTS_TL T
    where T.OBJECT_ID = X_OBJECT_ID
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
  X_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_DB_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_LOV_SQL in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
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
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STRAT_ASGMT_DB_OBJECT_ID,
      STRAT_ASGMT_LOV_SQL,
      USER_DEFINED_FLAG,
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
      ATTRIBUTE15
    from WMS_OBJECTS_B
    where OBJECT_ID = X_OBJECT_ID
    for update of OBJECT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_OBJECTS_TL
    where OBJECT_ID = X_OBJECT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OBJECT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.STRAT_ASGMT_DB_OBJECT_ID = X_STRAT_ASGMT_DB_OBJECT_ID)
           OR ((recinfo.STRAT_ASGMT_DB_OBJECT_ID is null) AND (X_STRAT_ASGMT_DB_OBJECT_ID is null)))
      AND ((recinfo.STRAT_ASGMT_LOV_SQL = X_STRAT_ASGMT_LOV_SQL)
           OR ((recinfo.STRAT_ASGMT_LOV_SQL is null) AND (X_STRAT_ASGMT_LOV_SQL is null)))
      AND (recinfo.USER_DEFINED_FLAG = X_USER_DEFINED_FLAG)
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
  X_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_DB_OBJECT_ID in NUMBER,
  X_STRAT_ASGMT_LOV_SQL in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
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
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_OBJECTS_B set
    STRAT_ASGMT_DB_OBJECT_ID = X_STRAT_ASGMT_DB_OBJECT_ID,
    STRAT_ASGMT_LOV_SQL = X_STRAT_ASGMT_LOV_SQL,
    USER_DEFINED_FLAG = X_USER_DEFINED_FLAG,
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
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_OBJECTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_ID = X_OBJECT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_ID in NUMBER
) is
begin
  delete from WMS_OBJECTS_TL
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_OBJECTS_B
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_OBJECTS_TL T
  where not exists
    (select NULL
    from WMS_OBJECTS_B B
    where B.OBJECT_ID = T.OBJECT_ID
    );

  update WMS_OBJECTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WMS_OBJECTS_TL B
    where B.OBJECT_ID = T.OBJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_ID,
      SUBT.LANGUAGE
    from WMS_OBJECTS_TL SUBB, WMS_OBJECTS_TL SUBT
    where SUBB.OBJECT_ID = SUBT.OBJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WMS_OBJECTS_TL (
    NAME,
    DESCRIPTION,
    OBJECT_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.DESCRIPTION,
    B.OBJECT_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_OBJECTS_TL T
    where T.OBJECT_ID = B.OBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE translate_row
  (
   x_object_id   IN VARCHAR2,
   x_owner       IN VARCHAR2,
   x_name        IN VARCHAR2,
   x_description IN VARCHAR2
   ) IS
BEGIN
   UPDATE wms_objects_tl SET
     name              = x_name,
     description       = x_description,
     last_update_date  = Sysdate,
     last_updated_by   = Decode(x_owner,'SEED',1,0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
   WHERE object_id = fnd_number.canonical_to_number(x_object_id)
     AND userenv('LANG') IN (language,source_lang);
END translate_row;
PROCEDURE load_row
  (
    x_object_id                IN VARCHAR2
   ,x_owner                    IN VARCHAR2
   ,x_strat_asgmt_db_object_id IN VARCHAR2
   ,x_strat_asgmt_lov_sql      IN VARCHAR2
   ,x_user_defined_flag        IN VARCHAR2
   ,x_name                     IN VARCHAR2
   ,x_description              IN VARCHAR2
   ,x_attribute_category       IN VARCHAR2
   ,x_attribute1               IN VARCHAR2
   ,x_attribute2               IN VARCHAR2
   ,x_attribute3               IN VARCHAR2
   ,x_attribute4               IN VARCHAR2
   ,x_attribute5               IN VARCHAR2
   ,x_attribute6               IN VARCHAR2
   ,x_attribute7               IN VARCHAR2
   ,x_attribute8               IN VARCHAR2
   ,x_attribute9               IN VARCHAR2
   ,x_attribute10              IN VARCHAR2
   ,x_attribute11              IN VARCHAR2
   ,x_attribute12              IN VARCHAR2
   ,x_attribute13              IN VARCHAR2
   ,x_attribute14              IN VARCHAR2
   ,x_attribute15              IN VARCHAR2
  ) IS
BEGIN
   DECLARE
      l_user_id NUMBER := 0;
      l_object_id NUMBER;
      l_strat_asgmt_db_object_id NUMBER;
      l_rowid VARCHAR2(64);
      l_sysdate DATE;
   BEGIN
      IF x_owner = 'SEED' THEN
	 l_user_id := 1;
      END IF;
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_object_id := fnd_number.canonical_to_number(x_object_id);
      l_strat_asgmt_db_object_id :=
	fnd_number.canonical_to_number(x_strat_asgmt_db_object_id);
      wms_objects_pkg.update_row
	(
	 x_object_id                => l_object_id          ,
	 x_strat_asgmt_db_object_id => l_strat_asgmt_db_object_id,
	 x_strat_asgmt_lov_sql      => x_strat_asgmt_lov_sql,
	 x_user_defined_flag        => x_user_defined_flag  ,
	 x_attribute_category       => x_attribute_category ,
	 x_attribute1 		    => x_attribute1         ,
	 x_attribute2 		    => x_attribute2         ,
	 x_attribute3 		    => x_attribute3         ,
	 x_attribute4 		    => x_attribute4         ,
	 x_attribute5 		    => x_attribute5         ,
	 x_attribute6 		    => x_attribute6         ,
	 x_attribute7 		    => x_attribute7         ,
	 x_attribute8 		    => x_attribute8         ,
	 x_attribute9 		    => x_attribute9         ,
	 x_attribute10              => x_attribute10        ,
	 x_attribute11  	    => x_attribute11        ,
	 x_attribute12  	    => x_attribute12        ,
	 x_attribute13 	 	    => x_attribute13        ,
	 x_attribute14 		    => x_attribute14        ,
	 x_attribute15 		    => x_attribute15        ,
	 x_name                     => x_name               ,
	 x_description              => x_description        ,
	 x_last_update_date         => l_sysdate            ,
	 x_last_updated_by          => l_user_id            ,
	 x_last_update_login        => 0
	 );
   EXCEPTION
      WHEN no_data_found THEN
	 wms_objects_pkg.insert_row
	   (
	    x_rowid                    => l_rowid,
	    x_object_id                => l_object_id,
	    x_strat_asgmt_db_object_id => l_strat_asgmt_db_object_id,
	    x_strat_asgmt_lov_sql      => x_strat_asgmt_lov_sql,
	    x_user_defined_flag        => x_user_defined_flag,
	    x_attribute_category       => x_attribute_category ,
	    x_attribute1 	       => x_attribute1         ,
	    x_attribute2 	       => x_attribute2         ,
	    x_attribute3 	       => x_attribute3         ,
	    x_attribute4 	       => x_attribute4         ,
	    x_attribute5 	       => x_attribute5         ,
	    x_attribute6 	       => x_attribute6         ,
	    x_attribute7 	       => x_attribute7         ,
	    x_attribute8 	       => x_attribute8         ,
	    x_attribute9 	       => x_attribute9         ,
	    x_attribute10 	       => x_attribute10        ,
	    x_attribute11 	       => x_attribute11        ,
	    x_attribute12 	       => x_attribute12        ,
	    x_attribute13 	       => x_attribute13        ,
	    x_attribute14 	       => x_attribute14        ,
	    x_attribute15 	       => x_attribute15        ,
	    x_name 		       => x_name ,
	    x_description 	       => x_description,
	    x_creation_date 	       => l_sysdate ,
	    x_created_by 	       => l_user_id ,
	    x_last_update_date	       => l_sysdate ,
	    x_last_updated_by 	       => l_user_id ,
	    x_last_update_login        => 0
	   );
   END;
END load_row;
end WMS_OBJECTS_PKG;

/
