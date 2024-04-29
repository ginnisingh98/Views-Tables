--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_TYPES_PKG" as
/* $Header: asxvitpb.pls 120.1 2005/08/23 05:01:56 appldev ship $ */


-- This will be called by the Interest Types Forms UI

PROCEDURE INSERT_ROW (
  X_ROWID out nocopy VARCHAR2,
  X_INTEREST_TYPE_ID in NUMBER,
  X_MASTER_ENABLED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_COMPANY_CLASSIFICATION_FLAG in VARCHAR2,
  X_CONTACT_INTEREST_FLAG in VARCHAR2,
  X_LEAD_CLASSIFICATION_FLAG in VARCHAR2,
  X_EXPECTED_PURCHASE_FLAG in VARCHAR2,
  X_CURRENT_ENVIRONMENT_FLAG in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_INTEREST_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROD_CAT_SET_ID in NUMBER,
  X_PROD_CAT_ID in NUMBER
) IS

CURSOR C is
	SELECT ROWID
	FROM AS_INTEREST_TYPES_B
	WHERE INTEREST_TYPE_ID = X_INTEREST_TYPE_ID ;

BEGIN

-- There are three table _B, _TL and _ALL to be inserted

-- Inserting into _B table

	BEGIN

	  INSERT INTO AS_INTEREST_TYPES_B
  	(
    		INTEREST_TYPE_ID,
    		ENABLED_FLAG,
    		COMPANY_CLASSIFICATION_FLAG,
    		CONTACT_INTEREST_FLAG,
    		LEAD_CLASSIFICATION_FLAG,
    		EXPECTED_PURCHASE_FLAG,
    		CURRENT_ENVIRONMENT_FLAG,
    		CREATION_DATE,
    		CREATED_BY,
    		LAST_UPDATE_DATE,
    		LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN,
            PRODUCT_CAT_SET_ID,
            PRODUCT_CATEGORY_ID
  	)
  	VALUES
  	(
    		X_INTEREST_TYPE_ID,
    		X_MASTER_ENABLED_FLAG,
    		X_COMPANY_CLASSIFICATION_FLAG,
    		X_CONTACT_INTEREST_FLAG,
    		X_LEAD_CLASSIFICATION_FLAG,
    		X_EXPECTED_PURCHASE_FLAG,
    		X_CURRENT_ENVIRONMENT_FLAG,
    		X_CREATION_DATE,
    		X_CREATED_BY,
    		X_LAST_UPDATE_DATE,
    		X_LAST_UPDATED_BY,
    		X_LAST_UPDATE_LOGIN,
            X_PROD_CAT_SET_ID,
            X_PROD_CAT_ID
  	);


	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

-- Inserting into _ALL table


    /* AS_INTEREST_TYPES_ALL Obsoleted
 	BEGIN

  		INSERT INTO AS_INTEREST_TYPES_ALL
  		(
    			INTEREST_TYPE_ID,
    			ENABLED_FLAG,
    			ORG_ID,
    			CREATION_DATE,
    			CREATED_BY,
    			LAST_UPDATE_DATE,
    			LAST_UPDATED_BY,
    			LAST_UPDATE_LOGIN
  		)
  		VALUES
  		(
    		X_INTEREST_TYPE_ID,
    		X_ENABLED_FLAG,
    		X_ORG_ID,
    		X_CREATION_DATE,
    		X_CREATED_BY,
    		X_LAST_UPDATE_DATE,
    		X_LAST_UPDATED_BY,
    		X_LAST_UPDATE_LOGIN
  		);

	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;
    */


-- Inserting the _TL table

  BEGIN

  	INSERT INTO AS_INTEREST_TYPES_TL
  	(
    	INTEREST_TYPE_ID,
    	LAST_UPDATE_DATE,
    	LAST_UPDATED_BY,
    	CREATION_DATE,
    	CREATED_BY,
    	LAST_UPDATE_LOGIN,
    	INTEREST_TYPE,
    	DESCRIPTION,
    	LANGUAGE,
    	SOURCE_LANG
  	)
  	SELECT
    		X_INTEREST_TYPE_ID,
    		X_LAST_UPDATE_DATE,
    		X_LAST_UPDATED_BY,
    		X_CREATION_DATE,
    		X_CREATED_BY,
    		X_LAST_UPDATE_LOGIN,
    		rtrim(ltrim(X_INTEREST_TYPE)),
    		X_DESCRIPTION,
    		L.LANGUAGE_CODE,
    		userenv('LANG')
  		FROM FND_LANGUAGES L
  		WHERE L.INSTALLED_FLAG in ('I', 'B')
  		and not exists
    		(select NULL
    			from AS_INTEREST_TYPES_TL T
    			where T.INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
    			and T.LANGUAGE = L.LANGUAGE_CODE);

	  	open c;
  		fetch c into X_ROWID;
  		if (c%notfound) then
    			close c;
    			raise no_data_found;
  		end if;
  	close c;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;



EXCEPTION
WHEN OTHERS THEN
	RAISE NO_DATA_FOUND;
END INSERT_ROW;

procedure LOCK_ROW (
  X_INTEREST_TYPE_ID in NUMBER,
  X_MASTER_ENABLED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_COMPANY_CLASSIFICATION_FLAG in VARCHAR2,
  X_CONTACT_INTEREST_FLAG in VARCHAR2,
  X_LEAD_CLASSIFICATION_FLAG in VARCHAR2,
  X_EXPECTED_PURCHASE_FLAG in VARCHAR2,
  X_CURRENT_ENVIRONMENT_FLAG in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_INTEREST_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PROD_CAT_SET_ID in NUMBER,
  X_PROD_CAT_ID in NUMBER
) is
  cursor cb is select
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 ENABLED_FLAG,
	COMPANY_CLASSIFICATION_FLAG,
	CONTACT_INTEREST_FLAG,
	LEAD_CLASSIFICATION_FLAG,
	EXPECTED_PURCHASE_FLAG,
	CURRENT_ENVIRONMENT_FLAG,
    PRODUCT_CAT_SET_ID, PRODUCT_CATEGORY_ID
    from AS_INTEREST_TYPES_B
    where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
    for update of INTEREST_TYPE_ID nowait;
  binfo cb%rowtype;

  /* AS_INTEREST_TYPES_ALL Obsoleted
  cursor c is select
      ENABLED_FLAG,
	 ORG_ID
    from AS_INTEREST_TYPES_ALL
    where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
    and   ORG_ID = X_ORG_ID
    for update of INTEREST_TYPE_ID nowait;

  recinfo c%rowtype;
  */

  cursor c1 is select
      INTEREST_TYPE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_INTEREST_TYPES_TL
    where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INTEREST_TYPE_ID nowait;

BEGIN
  OPEN cb;
  FETCH cb INTO binfo;
  IF (cb%notfound) THEN
    CLOSE cb;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE cb;

  /* AS_INTEREST_TYPES_ALL Obsoleted
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%notfound) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  IF (  (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.ORG_ID = X_ORG_ID)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  */

  IF (  (binfo.ENABLED_FLAG = X_MASTER_ENABLED_FLAG)
      AND (binfo.COMPANY_CLASSIFICATION_FLAG = X_COMPANY_CLASSIFICATION_FLAG)
      AND (binfo.CONTACT_INTEREST_FLAG = X_CONTACT_INTEREST_FLAG)
      AND (binfo.LEAD_CLASSIFICATION_FLAG = X_LEAD_CLASSIFICATION_FLAG)
      AND (binfo.EXPECTED_PURCHASE_FLAG = X_EXPECTED_PURCHASE_FLAG)
      AND (binfo.CURRENT_ENVIRONMENT_FLAG = X_CURRENT_ENVIRONMENT_FLAG)
      AND ((binfo.PRODUCT_CATEGORY_ID = X_PROD_CAT_ID)
        OR ((binfo.PRODUCT_CATEGORY_ID is null) AND
            (X_PROD_CAT_ID is null)))
      AND ((binfo.PRODUCT_CAT_SET_ID = X_PROD_CAT_SET_ID)
        OR ((binfo.PRODUCT_CAT_SET_ID is null) AND
            (X_PROD_CAT_SET_ID is null)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.INTEREST_TYPE = X_INTEREST_TYPE)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) THEN
        NULL;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_INTEREST_TYPE_ID in NUMBER,
  X_MASTER_ENABLED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_COMPANY_CLASSIFICATION_FLAG in VARCHAR2,
  X_CONTACT_INTEREST_FLAG in VARCHAR2,
  X_LEAD_CLASSIFICATION_FLAG in VARCHAR2,
  X_EXPECTED_PURCHASE_FLAG in VARCHAR2,
  X_CURRENT_ENVIRONMENT_FLAG in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_INTEREST_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROD_CAT_SET_ID in NUMBER,
  X_PROD_CAT_ID in NUMBER
) is

BEGIN
 BEGIN
  	UPDATE AS_INTEREST_TYPES_B set
    		LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    		LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    		ENABLED_FLAG = X_MASTER_ENABLED_FLAG,
    		COMPANY_CLASSIFICATION_FLAG = X_COMPANY_CLASSIFICATION_FLAG,
    		CONTACT_INTEREST_FLAG = X_CONTACT_INTEREST_FLAG,
    		LEAD_CLASSIFICATION_FLAG = X_LEAD_CLASSIFICATION_FLAG,
    		EXPECTED_PURCHASE_FLAG = X_EXPECTED_PURCHASE_FLAG,
    		CURRENT_ENVIRONMENT_FLAG = X_CURRENT_ENVIRONMENT_FLAG,
            PRODUCT_CAT_SET_ID =  X_PROD_CAT_SET_ID ,
            PRODUCT_CATEGORY_ID = X_PROD_CAT_ID
  		WHERE INTEREST_TYPE_ID = X_INTEREST_TYPE_ID;

  	IF (sql%notfound) THEN
    		RAISE NO_DATA_FOUND;
  	END IF;


	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

 /* AS_INTEREST_TYPES_ALL Obsoleted
 BEGIN
  UPDATE AS_INTEREST_TYPES_ALL
  SET
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
  AND 	ORG_ID = X_ORG_ID;

  IF (sql%notfound) THEN
 --   RAISE NO_DATA_FOUND;
 -- If _ALL table cannot find the row, then create a record in _ALL
     INSERT INTO AS_INTEREST_TYPES_ALL
     ( INTEREST_TYPE_ID,
       ENABLED_FLAG,
       ORG_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN )
     VALUES
     ( X_INTEREST_TYPE_ID,
       X_ENABLED_FLAG,
       X_ORG_ID,
       SYSDATE,
       X_LAST_UPDATED_BY,
       SYSDATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN
     );

  END IF;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;
    */

 BEGIN
  UPDATE AS_INTEREST_TYPES_TL SET
    INTEREST_TYPE = X_INTEREST_TYPE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  WHERE INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;


	EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

END UPDATE_ROW;

procedure DELETE_ROW (
  X_INTEREST_TYPE_ID in NUMBER
) is
begin
  delete from AS_INTEREST_TYPES_TL
  where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  /* AS_INTEREST_TYPES_ALL Obsoleted
  delete from AS_INTEREST_TYPES_ALL
  where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  */

  delete from AS_INTEREST_TYPES_B
  where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure TRANSLATE_ROW (
  X_INTEREST_TYPE_ID in NUMBER,
  X_INTEREST_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin
  -- only update rows that have not been altered by user
   update AS_INTEREST_TYPES_TL
     set INTEREST_TYPE=X_INTEREST_TYPE,
	 DESCRIPTION=X_DESCRIPTION,
         source_lang = userenv('LANG'),
	    last_update_date = sysdate,
	    last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
	    last_update_login = 0
      where INTEREST_TYPE_ID = X_INTEREST_TYPE_ID
	 and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure ADD_LANGUAGE is

begin
  delete from AS_INTEREST_TYPES_TL T
  where not exists
    (select NULL
    from AS_INTEREST_TYPES_B B
    where B.INTEREST_TYPE_ID = T.INTEREST_TYPE_ID
    );

  update AS_INTEREST_TYPES_TL T
	set ( INTEREST_TYPE,
		DESCRIPTION) = ( select
						B.INTEREST_TYPE,
      					B.DESCRIPTION
					  from
						AS_INTEREST_TYPES_TL B
					  where
						B.INTEREST_TYPE_ID = T.INTEREST_TYPE_ID and
						B.LANGUAGE = T.SOURCE_LANG )
	where
	( T.INTEREST_TYPE_ID,
	  T.LANGUAGE ) in ( select
						SUBT.INTEREST_TYPE_ID,
						SUBT.LANGUAGE
					from
						AS_INTEREST_TYPES_TL SUBB,
						AS_INTEREST_TYPES_TL SUBT
					where
						SUBB.INTEREST_TYPE_ID = SUBT.INTEREST_TYPE_ID and
						SUBB.LANGUAGE = SUBT.SOURCE_LANG and
						(SUBB.INTEREST_TYPE <> SUBT.INTEREST_TYPE or
						SUBB.DESCRIPTION <> SUBT.DESCRIPTION or
							(SUBB.DESCRIPTION is null and
							SUBT.DESCRIPTION is not null) or
						(SUBB.DESCRIPTION is not null and
						SUBT.DESCRIPTION is null)));

  insert into AS_INTEREST_TYPES_TL (
    INTEREST_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    INTEREST_TYPE,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  )
  select
    B.INTEREST_TYPE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.INTEREST_TYPE,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from
	AS_INTEREST_TYPES_TL B,
	FND_LANGUAGES L
  where
	L.INSTALLED_FLAG in ('I', 'B') and
	B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_INTEREST_TYPES_TL T
    where T.INTEREST_TYPE_ID = B.INTEREST_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

PROCEDURE insert_as_int_types_all (
  X_INTEREST_TYPE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) IS

BEGIN

    /* AS_INTEREST_TYPES_ALL Obsoleted
  	INSERT INTO AS_INTEREST_TYPES_ALL
  		(
    			INTEREST_TYPE_ID,
    			ENABLED_FLAG,
    			ORG_ID,
    			CREATION_DATE,
    			CREATED_BY,
    			LAST_UPDATE_DATE,
    			LAST_UPDATED_BY,
    			LAST_UPDATE_LOGIN
  		)
  	VALUES
  	(
    		X_INTEREST_TYPE_ID,
    		X_ENABLED_FLAG,
    		X_ORG_ID,
    		X_CREATION_DATE,
    		X_CREATED_BY,
    		X_LAST_UPDATE_DATE,
    		X_LAST_UPDATED_BY,
    		X_LAST_UPDATE_LOGIN
  	);
    */
    NULL;


EXCEPTION
	WHEN OTHERS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END insert_as_int_types_all ;

END AS_INTEREST_TYPES_PKG;

/