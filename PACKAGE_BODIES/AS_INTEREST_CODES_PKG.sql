--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_CODES_PKG" as
/* $Header: asxvicpb.pls 120.1 2005/11/28 01:39:53 sumahali noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INTEREST_CODE_ID in NUMBER,
  X_INTEREST_TYPE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PARENT_INTEREST_CODE_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_CATEGORY_SET_ID in NUMBER,
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
  X_PF_ITEM_ID in NUMBER,
  X_PF_ORGANIZATION_ID in NUMBER,
  X_PRICE in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROD_CAT_SET_ID in NUMBER,
  X_PROD_CAT_ID in NUMBER
) is
  cursor C is
	select ROWID from AS_INTEREST_CODES_B
	where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

BEGIN
  insert into AS_INTEREST_CODES_B (
    INTEREST_CODE_ID,
    INTEREST_TYPE_ID,
    ENABLED_FLAG,
    PARENT_INTEREST_CODE_ID,
    CATEGORY_ID,
    CATEGORY_SET_ID,
    PF_ITEM_ID,
    PF_ORGANIZATION_ID,
    PRICE,
    CURRENCY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    PRODUCT_CAT_SET_ID,
    PRODUCT_CATEGORY_ID
  ) values (
    X_INTEREST_CODE_ID,
    X_INTEREST_TYPE_ID,
  	X_ENABLED_FLAG ,
    X_PARENT_INTEREST_CODE_ID,
    X_CATEGORY_ID,
    X_CATEGORY_SET_ID,
    X_PF_ITEM_ID,
    X_PF_ORGANIZATION_ID,
    X_PRICE,
    X_CURRENCY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
  	X_ATTRIBUTE_CATEGORY ,
  	X_ATTRIBUTE1 ,
  	X_ATTRIBUTE2 ,
  	X_ATTRIBUTE3 ,
  	X_ATTRIBUTE4 ,
  	X_ATTRIBUTE5 ,
  	X_ATTRIBUTE6 ,
  	X_ATTRIBUTE7 ,
  	X_ATTRIBUTE8 ,
  	X_ATTRIBUTE9 ,
  	X_ATTRIBUTE10 ,
  	X_ATTRIBUTE11 ,
  	X_ATTRIBUTE12 ,
  	X_ATTRIBUTE13 ,
  	X_ATTRIBUTE14 ,
  	X_ATTRIBUTE15 ,
    X_PROD_CAT_SET_ID ,
    X_PROD_CAT_ID
  );

--	insert into AS_INTEREST_CODES_ALL (
--    INTEREST_CODE_ID,
--    ENABLED_FLAG,
--		ORG_ID ,
--    CREATION_DATE,
--    CREATED_BY,
--    LAST_UPDATE_DATE,
--    LAST_UPDATED_BY,
--    LAST_UPDATE_LOGIN
--  ) values (
--    X_INTEREST_CODE_ID,
--    X_ENABLED_FLAG,
--		X_ORG_ID ,
--    X_CREATION_DATE,
--    X_CREATED_BY,
--    X_LAST_UPDATE_DATE,
--    X_LAST_UPDATED_BY,
--    X_LAST_UPDATE_LOGIN
--  );

  insert into AS_INTEREST_CODES_TL (
    INTEREST_CODE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CODE,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INTEREST_CODE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    ltrim(rtrim(X_CODE)),
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AS_INTEREST_CODES_TL T
    where T.INTEREST_CODE_ID = X_INTEREST_CODE_ID
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
  X_INTEREST_CODE_ID 		in NUMBER,
  X_INTEREST_TYPE_ID 		in NUMBER,
  X_ENABLED_FLAG			in VARCHAR2,
  X_PARENT_INTEREST_CODE_ID 	in NUMBER,
  X_CATEGORY_ID 			in NUMBER,
  X_CATEGORY_SET_ID			in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1				in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  X_PF_ITEM_ID 			in NUMBER,
  X_PF_ORGANIZATION_ID 		in NUMBER,
  X_PRICE 				in NUMBER,
  X_CURRENCY_CODE 			in VARCHAR2,
  X_CODE 					in VARCHAR2,
  X_DESCRIPTION 			in VARCHAR2,
  X_PROD_CAT_SET_ID			in NUMBER,
  X_PROD_CAT_ID				in NUMBER
) is
  cursor c is
	select
		INTEREST_TYPE_ID,
		ENABLED_FLAG,
		PARENT_INTEREST_CODE_ID,
		CATEGORY_ID,
		CATEGORY_SET_ID,
		PF_ITEM_ID,
		PF_ORGANIZATION_ID,
		PRICE,
		CURRENCY_CODE,
		ATTRIBUTE_CATEGORY, ATTRIBUTE1,
	 	ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
	 	ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
	 	ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
	 	ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
	 	ATTRIBUTE14, ATTRIBUTE15,
        PRODUCT_CAT_SET_ID, PRODUCT_CATEGORY_ID
  from AS_INTEREST_CODES_B
  where INTEREST_CODE_ID = X_INTEREST_CODE_ID
  for update of INTEREST_CODE_ID nowait;

  recinfo c%rowtype;

	--  cursor c_all is
		--select
      	--ENABLED_FLAG,
				--ORG_ID
		--from AS_INTEREST_CODES_ALL
		--where INTEREST_CODE_ID = X_INTEREST_CODE_ID
		--for update of INTEREST_CODE_ID nowait;
	--
	--  allinfo c_all%rowtype;

  cursor c1 is select
      CODE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_INTEREST_CODES_TL
    where INTEREST_CODE_ID = X_INTEREST_CODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INTEREST_CODE_ID nowait;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (
      (recinfo.INTEREST_TYPE_ID = X_INTEREST_TYPE_ID)
      AND ((recinfo.PARENT_INTEREST_CODE_ID = X_PARENT_INTEREST_CODE_ID)
           OR ((recinfo.PARENT_INTEREST_CODE_ID is null) AND
			(X_PARENT_INTEREST_CODE_ID is null)))
	AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.CATEGORY_ID = X_CATEGORY_ID)
           OR ((recinfo.CATEGORY_ID is null) AND
			(X_CATEGORY_ID is null)))
      AND ((recinfo.CATEGORY_SET_ID = X_CATEGORY_SET_ID)
           OR ((recinfo.CATEGORY_SET_ID is null) AND
			(X_CATEGORY_SET_ID is null)))
      AND ((recinfo.PF_ITEM_ID = X_PF_ITEM_ID)
           OR ((recinfo.PF_ITEM_ID is null) AND (X_PF_ITEM_ID is null)))
      AND ((recinfo.PF_ORGANIZATION_ID = X_PF_ORGANIZATION_ID)
           OR ((recinfo.PF_ORGANIZATION_ID is null) AND
			(X_PF_ORGANIZATION_ID is null)))
      AND ((recinfo.PRICE = X_PRICE)
           OR ((recinfo.PRICE is null) AND (X_PRICE is null)))
      AND ((recinfo.CURRENCY_CODE = X_CURRENCY_CODE)
           OR ((recinfo.CURRENCY_CODE is null) AND (X_CURRENCY_CODE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY= X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND
			(X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1= X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2= X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3= X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4= X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5= X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6= X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7= X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8= X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9= X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10= X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11= X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12= X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13= X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14= X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15= X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.PRODUCT_CATEGORY_ID = X_PROD_CAT_ID)
           OR ((recinfo.PRODUCT_CATEGORY_ID is null) AND
                    (X_PROD_CAT_ID is null)))
      AND ((recinfo.PRODUCT_CAT_SET_ID = X_PROD_CAT_SET_ID)
           OR ((recinfo.PRODUCT_CAT_SET_ID is null) AND
                    (X_PROD_CAT_SET_ID is null)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

--  open c_all;
--  fetch c_all into allinfo;
--  if (c_all%notfound) then
--    close c_all;
--    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
--    app_exception.raise_exception;
--  end if;
--  close c_all;
--  if (
--      (allinfo.ENABLED_FLAG = X_ENABLED_FLAG)
--      AND ((allinfo.ORG_ID = X_ORG_ID)
--           OR ((allinfo.ORG_ID is null) AND (X_ORG_ID is null)))
--  ) then
--    null;
--  else
--    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--    app_exception.raise_exception;
--  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ((tlinfo.CODE = X_CODE)
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
  X_INTEREST_CODE_ID 		in NUMBER,
  X_INTEREST_TYPE_ID 		in NUMBER,
  X_ENABLED_FLAG 			in VARCHAR2,
  X_PARENT_INTEREST_CODE_ID 	in NUMBER,
  X_CATEGORY_ID 			in NUMBER,
  X_CATEGORY_SET_ID 		in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
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
  X_PF_ITEM_ID 			in NUMBER,
  X_PF_ORGANIZATION_ID 		in NUMBER,
  X_PRICE 				in NUMBER,
  X_CURRENCY_CODE 			in VARCHAR2,
  X_CODE 					in VARCHAR2,
  X_DESCRIPTION 			in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  X_PROD_CAT_SET_ID		in NUMBER,
  X_PROD_CAT_ID			in NUMBER
) is
begin
  update
	AS_INTEREST_CODES_B set
    INTEREST_TYPE_ID = X_INTEREST_TYPE_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PARENT_INTEREST_CODE_ID = X_PARENT_INTEREST_CODE_ID,
    CATEGORY_ID = X_CATEGORY_ID,
    CATEGORY_SET_ID = X_CATEGORY_SET_ID,
    PF_ITEM_ID = X_PF_ITEM_ID,
    PF_ORGANIZATION_ID = X_PF_ORGANIZATION_ID,
    PRICE = X_PRICE,
    CURRENCY_CODE = X_CURRENCY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY ,
  	ATTRIBUTE1 = X_ATTRIBUTE1 ,
  	ATTRIBUTE2 = X_ATTRIBUTE2 ,
  	ATTRIBUTE3 = X_ATTRIBUTE3 ,
  	ATTRIBUTE4 = X_ATTRIBUTE4 ,
  	ATTRIBUTE5 = X_ATTRIBUTE5 ,
  	ATTRIBUTE6 = X_ATTRIBUTE6 ,
  	ATTRIBUTE7 = X_ATTRIBUTE7 ,
  	ATTRIBUTE8 = X_ATTRIBUTE8 ,
  	ATTRIBUTE9 = X_ATTRIBUTE9 ,
  	ATTRIBUTE10 = X_ATTRIBUTE10 ,
  	ATTRIBUTE11 = X_ATTRIBUTE11 ,
  	ATTRIBUTE12 = X_ATTRIBUTE12 ,
  	ATTRIBUTE13 = X_ATTRIBUTE13 ,
  	ATTRIBUTE14 = X_ATTRIBUTE14 ,
  	ATTRIBUTE15 = X_ATTRIBUTE15 ,
    PRODUCT_CAT_SET_ID =  X_PROD_CAT_SET_ID ,
    PRODUCT_CATEGORY_ID = X_PROD_CAT_ID
  where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

--  update AS_INTEREST_CODES_ALL set
--    ENABLED_FLAG = X_ENABLED_FLAG,
--    ORG_ID = X_ORG_ID,
--    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
--    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
--    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
--  where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AS_INTEREST_CODES_TL set
    CODE = X_CODE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INTEREST_CODE_ID = X_INTEREST_CODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTEREST_CODE_ID in NUMBER
) is
begin
  delete from AS_INTEREST_CODES_TL
  where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  --delete from AS_INTEREST_CODES_ALL
  --where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AS_INTEREST_CODES_B
  where INTEREST_CODE_ID = X_INTEREST_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure TRANSLATE_ROW (
  X_INTEREST_CODE_ID in NUMBER,
  X_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin
  -- only update rows that have not been altered by user
   update AS_INTEREST_CODES_TL
     set CODE=X_CODE,
	 DESCRIPTION=X_DESCRIPTION,
         source_lang = userenv('LANG'),
	    last_update_date = sysdate,
	    last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
	    last_update_login = 0
      where INTEREST_CODE_ID = X_INTEREST_CODE_ID
	 and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AS_INTEREST_CODES_TL T
  where not exists
    (select NULL
    from AS_INTEREST_CODES_B B
    where B.INTEREST_CODE_ID = T.INTEREST_CODE_ID
    );

  update AS_INTEREST_CODES_TL T set (
      CODE,
      DESCRIPTION
    ) = (select
      B.CODE,
      B.DESCRIPTION
    from AS_INTEREST_CODES_TL B
    where B.INTEREST_CODE_ID = T.INTEREST_CODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INTEREST_CODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INTEREST_CODE_ID,
      SUBT.LANGUAGE
    from AS_INTEREST_CODES_TL SUBB, AS_INTEREST_CODES_TL SUBT
    where SUBB.INTEREST_CODE_ID = SUBT.INTEREST_CODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CODE <> SUBT.CODE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AS_INTEREST_CODES_TL (
    INTEREST_CODE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CODE,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INTEREST_CODE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CODE,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_INTEREST_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_INTEREST_CODES_TL T
    where T.INTEREST_CODE_ID = B.INTEREST_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AS_INTEREST_CODES_PKG;

/
