--------------------------------------------------------
--  DDL for Package Body WMS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULES_PKG" as
/* $Header: WMSHPPRB.pls 120.0 2005/05/25 09:01:35 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY VARCHAR2,
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       in VARCHAR2,
  X_CREATION_DATE             in DATE,
  X_CREATED_BY                in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
 ,X_ALLOCATION_MODE_ID        in NUMBER
 ,X_wms_enabled_flag          in VARCHAR2 DEFAULT NULL
) is
  cursor C is select ROWID from WMS_RULES_B
    where RULE_ID = X_RULE_ID ;
begin

   insert into WMS_RULES_B (
    ATTRIBUTE11,
    ATTRIBUTE12,
    RULE_ID,
    ORGANIZATION_ID,
    TYPE_CODE,
    QTY_FUNCTION_PARAMETER_ID,
    ENABLED_FLAG,
    USER_DEFINED_FLAG,
    MIN_PICK_TASKS_FLAG,
    TYPE_HDR_ID,
    RULE_WEIGHT,
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
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ,ALLOCATION_MODE_ID
   ,wms_enabled_flag
  ) values (
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_RULE_ID,
    X_ORGANIZATION_ID,
    X_TYPE_CODE,
    X_QTY_FUNCTION_PARAMETER_ID,
    X_ENABLED_FLAG,
    X_USER_DEFINED_FLAG,
    X_MIN_PICK_TASKS_FLAG,
    X_TYPE_HEADER_ID,
    X_RULE_WEIGHT,
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
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
   ,X_ALLOCATION_MODE_ID
   ,X_wms_enabled_flag
  );

  insert into WMS_RULES_TL (
    RULE_ID,
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
    X_RULE_ID,
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
    from WMS_RULES_TL T
    where T.RULE_ID = X_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;
--
procedure LOCK_ROW (
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       in VARCHAR2,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
  ,X_ALLOCATION_MODE_ID       in NUMBER
) is
  cursor c is select
      ATTRIBUTE11,
      ATTRIBUTE12,
      ORGANIZATION_ID,
      TYPE_CODE,
      QTY_FUNCTION_PARAMETER_ID,
      ENABLED_FLAG,
      USER_DEFINED_FLAG,
      MIN_PICK_TASKS_FLAG,
      TYPE_HDR_ID,
      RULE_WEIGHT,
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
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
     ,ALLOCATION_MODE_ID
    from WMS_RULES_B
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_RULES_TL
    where RULE_ID = X_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND (recinfo.TYPE_CODE = X_TYPE_CODE)
      AND ((recinfo.QTY_FUNCTION_PARAMETER_ID = X_QTY_FUNCTION_PARAMETER_ID)
           OR ((recinfo.QTY_FUNCTION_PARAMETER_ID is null) AND
               (X_QTY_FUNCTION_PARAMETER_ID is null)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.USER_DEFINED_FLAG = X_USER_DEFINED_FLAG)
      AND (recinfo.MIN_PICK_TASKS_FLAG = X_MIN_PICK_TASKS_FLAG)
      AND ((recinfo.TYPE_HDR_ID = X_TYPE_HEADER_ID)
           OR ((recinfo.TYPE_HDR_ID is null) AND
               (X_TYPE_HEADER_ID is null)))
      AND ((recinfo.RULE_WEIGHT = X_RULE_WEIGHT)
           OR ((recinfo.RULE_WEIGHT is null) AND
               (X_RULE_WEIGHT is null)))
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
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       in VARCHAR2,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
 ,X_ALLOCATION_MODE_ID       in NUMBER
) is
begin
  update WMS_RULES_B set
    ORGANIZATION_ID           = X_ORGANIZATION_ID,
    TYPE_CODE                 = X_TYPE_CODE,
    QTY_FUNCTION_PARAMETER_ID = X_QTY_FUNCTION_PARAMETER_ID,
    ENABLED_FLAG              = X_ENABLED_FLAG,
    USER_DEFINED_FLAG         = X_USER_DEFINED_FLAG,
    MIN_PICK_TASKS_FLAG       = X_MIN_PICK_TASKS_FLAG,
    LAST_UPDATE_DATE          = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY           = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN         = X_LAST_UPDATE_LOGIN,
    TYPE_HDR_ID               = X_TYPE_HEADER_ID,
    RULE_WEIGHT               = X_RULE_WEIGHT,
    ATTRIBUTE_CATEGORY        = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1                = X_ATTRIBUTE1,
    ATTRIBUTE2                = X_ATTRIBUTE2,
    ATTRIBUTE3                = X_ATTRIBUTE3,
    ATTRIBUTE4                = X_ATTRIBUTE4,
    ATTRIBUTE5                = X_ATTRIBUTE5,
    ATTRIBUTE6                = X_ATTRIBUTE6,
    ATTRIBUTE7                = X_ATTRIBUTE7,
    ATTRIBUTE8                = X_ATTRIBUTE8,
    ATTRIBUTE9                = X_ATTRIBUTE9,
    ATTRIBUTE10               = X_ATTRIBUTE10,
    ATTRIBUTE11               = X_ATTRIBUTE11,
    ATTRIBUTE12               = X_ATTRIBUTE12,
    ATTRIBUTE13               = X_ATTRIBUTE13,
    ATTRIBUTE14               = X_ATTRIBUTE14,
    ATTRIBUTE15               = X_ATTRIBUTE15
   ,ALLOCATION_MODE_ID        = X_ALLOCATION_MODE_ID
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_RULES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULE_ID = X_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
) is
begin
  delete from WMS_RULES_TL
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_RULES_B
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_RULES_TL T
  where not exists
    (select NULL
    from WMS_RULES_B B
    where B.RULE_ID = T.RULE_ID
    );

  update WMS_RULES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WMS_RULES_TL B
    where B.RULE_ID = T.RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ID,
      SUBT.LANGUAGE
    from WMS_RULES_TL SUBB, WMS_RULES_TL SUBT
    where SUBB.RULE_ID = SUBT.RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WMS_RULES_TL (
    RULE_ID,
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
    B.RULE_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_RULES_TL T
    where T.RULE_ID = B.RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
procedure TRANSLATE_ROW
  (x_rule_id IN VARCHAR2,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
   ) IS
BEGIN
   UPDATE wms_rules_tl SET
     name              = x_name,
     description       = x_description,
     last_update_date  = Sysdate,
     last_updated_by   = Decode(x_owner, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
     WHERE rule_id = fnd_number.canonical_to_number(x_rule_id)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;
--
procedure LOAD_ROW (
   x_rule_id                     IN VARCHAR2,
   x_owner                       IN VARCHAR2,
   x_organization_code           IN VARCHAR2,
   x_type_code                   IN VARCHAR2,
   x_qty_function_parameter_id   IN VARCHAR2,
   x_enabled_flag                IN VARCHAR2,
   x_user_defined_flag           IN VARCHAR2,
   x_type_hdr_id                 IN VARCHAR2,
   x_rule_weight                 IN VARCHAR2,
   X_MIN_PICK_TASKS_FLAG         IN VARCHAR2,
   x_name                        IN VARCHAR2,
   x_description                 in VARCHAR2,
   x_attribute_category          IN VARCHAR2,
   x_attribute1                  IN VARCHAR2,
   x_attribute2                  IN VARCHAR2,
   x_attribute3                  IN VARCHAR2,
   x_attribute4                  IN VARCHAR2,
   x_attribute5                  IN VARCHAR2,
   x_attribute6                  IN VARCHAR2,
   x_attribute7                  IN VARCHAR2,
   x_attribute8                  IN VARCHAR2,
   x_attribute9                  IN VARCHAR2,
   x_attribute10                 IN VARCHAR2,
   x_attribute11                 IN VARCHAR2,
   x_attribute12                 IN VARCHAR2,
   x_attribute13                 IN VARCHAR2,
   x_attribute14                 IN VARCHAR2,
   x_attribute15                 IN VARCHAR2
   ,x_allocation_mode_id         IN NUMBER
   ) IS
BEGIN
   DECLARE
      l_rule_id          NUMBER;
      l_organization_id  NUMBER;
      l_qty_func_para_id NUMBER;
      l_user_id          NUMBER := 0 ;
      l_row_id           VARCHAR2(64);
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      IF ( x_organization_code = '-1') THEN
         l_organization_id := -1;
      ELSE
         SELECT organization_id INTO l_organization_id
	   FROM mtl_parameters
	   WHERE organization_code = x_organization_code;
      END IF;
      --
      /* SELECT parameter_id INTO l_qty_func_para_id
	FROM wms_parameters
	WHERE name = x_qty_function_parameter_name; */
      --
      l_rule_id := fnd_number.canonical_to_number(x_rule_id);
      l_qty_func_para_id := fnd_number.canonical_to_number(x_qty_function_parameter_id);
      wms_rules_pkg.update_row
	(
	  X_RULE_ID                   => l_rule_id
	 ,X_ATTRIBUTE11               => x_attribute11
	 ,X_ATTRIBUTE12               => x_attribute12
	 ,X_ORGANIZATION_ID 	      => l_organization_id
	 ,X_TYPE_CODE 		      => fnd_number.canonical_to_number(x_type_code)
	 ,X_QTY_FUNCTION_PARAMETER_ID => l_qty_func_para_id
	 ,X_ENABLED_FLAG 	      => x_enabled_flag
	 ,X_USER_DEFINED_FLAG 	      => x_user_defined_flag
         ,X_MIN_PICK_TASKS_FLAG       => x_min_pick_tasks_flag
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
	 ,X_ATTRIBUTE13		      => x_attribute13
	 ,X_ATTRIBUTE14		      => x_attribute14
	 ,X_ATTRIBUTE15		      => x_attribute15
	 ,X_NAME 		      => x_name
	 ,X_DESCRIPTION               => x_description
	 ,X_LAST_UPDATE_DATE	      => sysdate
	 ,X_LAST_UPDATED_BY 	      => l_user_id
	 ,X_LAST_UPDATE_LOGIN 	      => 0
     ,X_TYPE_HEADER_ID            => NULL
     ,X_RULE_WEIGHT               => NULL
     ,X_ALLOCATION_MODE_ID       => x_allocation_mode_id
	 );
   EXCEPTION
      WHEN no_data_found THEN
         IF ( l_rule_id IS NULL ) THEN
       	    SELECT wms_rules_s.NEXTVAL INTO l_rule_id FROM dual;
         END IF;
	 wms_rules_pkg.insert_row
	   (
	     X_ROWID 			 => l_row_id
	    ,X_RULE_ID 			 => l_rule_id
	    ,X_ATTRIBUTE11 		 => x_attribute11
	    ,X_ATTRIBUTE12 		 => x_attribute12
	    ,X_ORGANIZATION_ID 		 => l_organization_id
	    ,X_TYPE_CODE 	     => fnd_number.canonical_to_number(x_type_code)
	    ,X_QTY_FUNCTION_PARAMETER_ID => l_qty_func_para_id
	    ,X_ENABLED_FLAG 		 => x_enabled_flag
	    ,X_USER_DEFINED_FLAG 	 => x_user_defined_flag
            ,X_MIN_PICK_TASKS_FLAG       => x_min_pick_tasks_flag
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
	    ,X_ATTRIBUTE13 		 => x_attribute13
	    ,X_ATTRIBUTE14 		 => x_attribute14
	    ,X_ATTRIBUTE15 		 => x_attribute15
	    ,X_NAME 		         => x_name
	    ,X_DESCRIPTION 		 => x_description
	    ,X_CREATION_DATE 		 => Sysdate
	    ,X_CREATED_BY 		 => l_user_id
	    ,X_LAST_UPDATE_DATE 	 => Sysdate
	    ,X_LAST_UPDATED_BY 		 => l_user_id
	    ,X_LAST_UPDATE_LOGIN	 => 0
        ,X_TYPE_HEADER_ID            => NULL
        ,X_RULE_WEIGHT               => NULL
        ,X_ALLOCATION_MODE_ID  =>  x_allocation_mode_id
	   );
   END;
END load_row;
end WMS_RULES_PKG;

/
