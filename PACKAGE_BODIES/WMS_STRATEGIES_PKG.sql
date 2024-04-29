--------------------------------------------------------
--  DDL for Package Body WMS_STRATEGIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_STRATEGIES_PKG" as
/* $Header: WMSHPSTB.pls 120.2.12010000.1 2008/07/28 18:34:29 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STRATEGY_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_TYPE_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_wms_enabled_flag in VARCHAR2 DEFAULT NULL,
  X_OVER_ALLOCATION_MODE in NUMBER DEFAULT NULL,
  X_TOLERANCE_VALUE in NUMBER DEFAULT NULL
) is
  cursor C is select ROWID from WMS_STRATEGIES_B
    where STRATEGY_ID = X_STRATEGY_ID
    ;
begin
  insert into WMS_STRATEGIES_B (
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
    STRATEGY_ID,
    ORGANIZATION_ID,
    TYPE_CODE,
    ENABLED_FLAG,
    USER_DEFINED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    wms_enabled_flag,
    OVER_ALLOCATION_MODE,
    TOLERANCE_VALUE
  ) values (
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
    X_STRATEGY_ID,
    X_ORGANIZATION_ID,
    X_TYPE_CODE,
    X_ENABLED_FLAG,
    X_USER_DEFINED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_wms_enabled_flag,
    X_OVER_ALLOCATION_MODE,
    X_TOLERANCE_VALUE
  );

  insert into WMS_STRATEGIES_TL (
    STRATEGY_ID,
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
    X_STRATEGY_ID,
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
    from WMS_STRATEGIES_TL T
    where T.STRATEGY_ID = X_STRATEGY_ID
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
  X_STRATEGY_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_TYPE_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
  X_OVER_ALLOCATION_MODE in NUMBER DEFAULT NULL,
  X_TOLERANCE_VALUE in NUMBER DEFAULT NULL
) is
  cursor c is select
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
      ORGANIZATION_ID,
      TYPE_CODE,
      ENABLED_FLAG,
      USER_DEFINED_FLAG,
      OVER_ALLOCATION_MODE,
      TOLERANCE_VALUE
    from WMS_STRATEGIES_B
    where STRATEGY_ID = X_STRATEGY_ID
    for update of STRATEGY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_STRATEGIES_TL
    where STRATEGY_ID = X_STRATEGY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STRATEGY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
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
      AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND (recinfo.TYPE_CODE = X_TYPE_CODE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.USER_DEFINED_FLAG = X_USER_DEFINED_FLAG)
      AND ((recinfo.OVER_ALLOCATION_MODE = X_OVER_ALLOCATION_MODE)
	   OR ((recinfo.OVER_ALLOCATION_MODE is null) AND (X_OVER_ALLOCATION_MODE is null)))
      AND ((recinfo.TOLERANCE_VALUE = X_TOLERANCE_VALUE)
	   OR ((recinfo.TOLERANCE_VALUE is null) AND (X_TOLERANCE_VALUE is null)))
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
  X_STRATEGY_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_TYPE_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_DEFINED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_OVER_ALLOCATION_MODE in NUMBER DEFAULT NULL,
  X_TOLERANCE_VALUE in NUMBER DEFAULT NULL
) is
begin
  update WMS_STRATEGIES_B set
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
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    TYPE_CODE = X_TYPE_CODE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    USER_DEFINED_FLAG = X_USER_DEFINED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OVER_ALLOCATION_MODE = X_OVER_ALLOCATION_MODE,
    TOLERANCE_VALUE = X_TOLERANCE_VALUE
  where STRATEGY_ID = X_STRATEGY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_STRATEGIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STRATEGY_ID = X_STRATEGY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STRATEGY_ID in NUMBER
) is
begin
  delete from WMS_STRATEGIES_TL
  where STRATEGY_ID = X_STRATEGY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_STRATEGIES_B
  where STRATEGY_ID = X_STRATEGY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_STRATEGIES_TL T
  where not exists
    (select NULL
    from WMS_STRATEGIES_B B
    where B.STRATEGY_ID = T.STRATEGY_ID
    );

  update WMS_STRATEGIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WMS_STRATEGIES_TL B
    where B.STRATEGY_ID = T.STRATEGY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STRATEGY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STRATEGY_ID,
      SUBT.LANGUAGE
    from WMS_STRATEGIES_TL SUBB, WMS_STRATEGIES_TL SUBT
    where SUBB.STRATEGY_ID = SUBT.STRATEGY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WMS_STRATEGIES_TL (
    STRATEGY_ID,
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
    B.STRATEGY_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_STRATEGIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_STRATEGIES_TL T
    where T.STRATEGY_ID = B.STRATEGY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
PROCEDURE translate_row
  (
   x_strategy_id IN VARCHAR2,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
   ) IS
BEGIN
   UPDATE wms_strategies_tl SET
     name              = x_name,
     description       = x_description,
     last_update_date  = Sysdate,
     last_updated_by   = Decode(x_owner, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
     WHERE strategy_id = fnd_number.canonical_to_number(x_strategy_id)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;
--
PROCEDURE load_row
  (
   x_strategy_id IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_organization_code IN VARCHAR2,
   x_type_code IN VARCHAR2,
   x_enabled_flag IN VARCHAR2,
   x_user_defined_flag IN VARCHAR2,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_attribute_category IN VARCHAR2,
   x_attribute1 IN VARCHAR2,
   x_attribute2 IN VARCHAR2,
   x_attribute3 IN VARCHAR2,
   x_attribute4 IN VARCHAR2,
   x_attribute5 IN VARCHAR2,
   x_attribute6 IN VARCHAR2,
   x_attribute7 IN VARCHAR2,
   x_attribute8 IN VARCHAR2,
   x_attribute9 IN VARCHAR2,
   x_attribute10 IN VARCHAR2,
   x_attribute11 IN VARCHAR2,
   x_attribute12 IN VARCHAR2,
   x_attribute13 IN VARCHAR2,
   x_attribute14 IN VARCHAR2,
   x_attribute15 IN VARCHAR2,
   x_over_allocation_mode in NUMBER DEFAULT NULL,
   x_tolerance_value in NUMBER DEFAULT NULL
   ) IS
BEGIN
   DECLARE
      l_strategy_id      NUMBER;
      l_organization_id  NUMBER;
      l_user_id          NUMBER := 0;
      l_row_id           VARCHAR2(64);
      l_sysdate          DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      SELECT Sysdate INTO l_sysdate FROM dual;
      --
      IF (x_organization_code =  '-1') THEN
         l_organization_id := -1;
      ELSE
         BEGIN
           SELECT organization_id INTO l_organization_id
           FROM mtl_parameters
           WHERE organization_code = x_organization_code;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_organization_id := -1;
        END;
      END IF;
      --
      l_strategy_id := fnd_number.canonical_to_number(x_strategy_id);
      wms_strategies_pkg.update_row
	(
	  X_STRATEGY_ID               => l_strategy_id
	 ,X_ORGANIZATION_ID 	      => l_organization_id
	 ,X_TYPE_CODE 	     => fnd_number.canonical_to_number(x_type_code)
	 ,X_ENABLED_FLAG 	      => x_enabled_flag
	 ,X_USER_DEFINED_FLAG 	      => x_user_defined_flag
	 ,X_NAME 		      => x_name
	 ,X_DESCRIPTION               => x_description
	 ,X_LAST_UPDATE_DATE	      => l_sysdate
	 ,X_LAST_UPDATED_BY 	      => l_user_id
	 ,X_LAST_UPDATE_LOGIN 	      => 0
	 ,X_ATTRIBUTE_CATEGORY 	      => x_attribute_category
	 ,X_ATTRIBUTE1 		      => x_attribute1
	 ,X_ATTRIBUTE2 		      => x_attribute2
	 ,X_ATTRIBUTE3 		      => x_attribute3
	 ,X_ATTRIBUTE4 		      => x_attribute4
	 ,X_ATTRIBUTE5 		      => x_attribute5
	 ,X_ATTRIBUTE6 		      => x_attribute6
	 ,X_ATTRIBUTE7 		      => x_attribute7
	 ,X_ATTRIBUTE8 		      => x_attribute8
	 ,X_ATTRIBUTE9 		      => x_attribute9
	 ,X_ATTRIBUTE10		      => x_attribute10
	 ,X_ATTRIBUTE11               => x_attribute11
	 ,X_ATTRIBUTE12               => x_attribute12
	 ,X_ATTRIBUTE13		      => x_attribute13
	 ,X_ATTRIBUTE14		      => x_attribute14
	 ,X_ATTRIBUTE15		      => x_attribute15
	 ,X_OVER_ALLOCATION_MODE      => x_over_allocation_mode
	 ,X_TOLERANCE_VALUE	      => x_tolerance_value
	 );
   EXCEPTION
      WHEN no_data_found THEN
         IF (l_strategy_id IS NULL) THEN
	    SELECT wms_strategies_s.NEXTVAL INTO l_strategy_id FROM dual;
         END IF;
	 wms_strategies_pkg.insert_row
	   (
	     X_ROWID 			 => l_row_id
	    ,X_STRATEGY_ID 		 => l_strategy_id
	    ,X_ATTRIBUTE_CATEGORY 	 => x_attribute_category
	    ,X_ATTRIBUTE1 		 => x_attribute1
	    ,X_ATTRIBUTE2 		 => x_attribute2
	    ,X_ATTRIBUTE3 		 => x_attribute3
	    ,X_ATTRIBUTE4 		 => x_attribute4
	    ,X_ATTRIBUTE5 		 => x_attribute5
	    ,X_ATTRIBUTE6 		 => x_attribute6
	    ,X_ATTRIBUTE7 		 => x_attribute7
	    ,X_ATTRIBUTE8 		 => x_attribute8
	    ,X_ATTRIBUTE9 		 => x_attribute9
	    ,X_ATTRIBUTE10 		 => x_attribute10
	    ,X_ATTRIBUTE11 		 => x_attribute11
	    ,X_ATTRIBUTE12 		 => x_attribute12
	    ,X_ATTRIBUTE13 		 => x_attribute13
	    ,X_ATTRIBUTE14 		 => x_attribute14
	    ,X_ATTRIBUTE15 		 => x_attribute15
	    ,X_ORGANIZATION_ID 		 => l_organization_id
	    ,X_TYPE_CODE       => fnd_number.canonical_to_number(x_type_code)
	    ,X_ENABLED_FLAG 		 => x_enabled_flag
	    ,X_USER_DEFINED_FLAG 	 => x_user_defined_flag
	    ,X_NAME 		         => x_name
	    ,X_DESCRIPTION 		 => x_description
	    ,X_CREATION_DATE 		 => l_sysdate
	    ,X_CREATED_BY 		 => l_user_id
	    ,X_LAST_UPDATE_DATE 	 => l_sysdate
	    ,X_LAST_UPDATED_BY 		 => l_user_id
	    ,X_LAST_UPDATE_LOGIN	 => 0
	    ,X_OVER_ALLOCATION_MODE      => x_over_allocation_mode
	    ,X_TOLERANCE_VALUE	         => x_tolerance_value
	   );
   END;
END load_row;
end WMS_STRATEGIES_PKG;

/
