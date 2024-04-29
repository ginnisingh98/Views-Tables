--------------------------------------------------------
--  DDL for Package Body GCS_INTERCO_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_INTERCO_RULES_PKG" AS
/* $Header: gcsintercoruleb.pls 120.2 2005/09/30 17:43:50 spala noship $ */

 PROCEDURE Insert_Row
 (
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2
) IS

  CURSOR	intercorules_row IS
    SELECT	rowid
    FROM	gcs_interco_rules_b cb
    WHERE	cb.RULE_ID= insert_row.RULE_ID;
  BEGIN
    IF RULE_ID IS NULL THEN
      raise no_data_found;
    END IF;

 INSERT INTO gcs_interco_rules_b
 (
	 RULE_ID,
	 ENABLED_FLAG,
	 THRESHOLD_AMOUNT,
	 THRESHOLD_CURRENCY,
	 OBJECT_VERSION_NUMBER,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 SUS_FINANCIAL_ELEM_ID,
	 SUS_PRODUCT_ID,
	 SUS_NATURAL_ACCOUNT_ID,
	 SUS_CHANNEL_ID,
	 SUS_LINE_ITEM_ID,
	 SUS_PROJECT_ID,
	 SUS_CUSTOMER_ID,
	 SUS_TASK_ID,
	 SUS_USER_DIM1_ID,
	 SUS_USER_DIM2_ID,
	 SUS_USER_DIM3_ID,
	 SUS_USER_DIM4_ID,
	 SUS_USER_DIM5_ID,
	 SUS_USER_DIM6_ID,
	 SUS_USER_DIM7_ID,
	 SUS_USER_DIM8_ID,
	 SUS_USER_DIM9_ID,
	 SUS_USER_DIM10_ID
)
SELECT
	 RULE_ID,
	 ENABLED_FLAG,
	 THRESHOLD_AMOUNT,
	 THRESHOLD_CURRENCY,
	 OBJECT_VERSION_NUMBER,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 SUS_FINANCIAL_ELEM_ID,
	 SUS_PRODUCT_ID,
	 SUS_NATURAL_ACCOUNT_ID,
	 SUS_CHANNEL_ID,
	 SUS_LINE_ITEM_ID,
	 SUS_PROJECT_ID,
	 SUS_CUSTOMER_ID,
	 SUS_TASK_ID,
	 SUS_USER_DIM1_ID,
	 SUS_USER_DIM2_ID,
	 SUS_USER_DIM3_ID,
	 SUS_USER_DIM4_ID,
	 SUS_USER_DIM5_ID,
	 SUS_USER_DIM6_ID,
	 SUS_USER_DIM7_ID,
	 SUS_USER_DIM8_ID,
	 SUS_USER_DIM9_ID,
	 SUS_USER_DIM10_ID

 FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_interco_rules_b cb
		 WHERE	cb.RULE_ID= insert_row.RULE_ID);

    INSERT INTO gcs_interco_rules_tl
    (
	     RULE_ID,
	     LANGUAGE,
	     SOURCE_LANG,
	     RULE_NAME,
	     OBJECT_VERSION_NUMBER,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     LAST_UPDATE_LOGIN,
	     DESCRIPTION
    )
    SELECT
     RULE_ID,
     userenv('LANG'),
     userenv('LANG'),
     RULE_NAME,
     OBJECT_VERSION_NUMBER,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     description

   FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_interco_rules_tl ctl
		 WHERE	ctl.RULE_ID = insert_row.RULE_ID
		 AND	ctl.language = userenv('LANG'));

    OPEN intercorules_row;
    FETCH intercorules_row INTO row_id;
    IF intercorules_row%NOTFOUND THEN
      CLOSE intercorules_row;
      raise no_data_found;
    END IF;
    CLOSE intercorules_row;

  END Insert_Row;




 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2
) IS
  BEGIN

     UPDATE	gcs_interco_rules_b cb
     SET

	     ENABLED_FLAG =update_row.ENABLED_FLAG,
	     THRESHOLD_AMOUNT =update_row.THRESHOLD_AMOUNT,
	     THRESHOLD_CURRENCY =update_row.THRESHOLD_CURRENCY,
	     CREATION_DATE =update_row.CREATION_DATE,
	     CREATED_BY =update_row.CREATED_BY,
	     LAST_UPDATE_DATE =update_row.LAST_UPDATE_DATE,
	     LAST_UPDATED_BY =update_row.LAST_UPDATED_BY,
	     LAST_UPDATE_LOGIN =update_row.LAST_UPDATE_LOGIN,
	     SUS_FINANCIAL_ELEM_ID =update_row.SUS_FINANCIAL_ELEM_ID,
	     SUS_PRODUCT_ID =update_row.SUS_PRODUCT_ID,
	     SUS_NATURAL_ACCOUNT_ID =update_row.SUS_NATURAL_ACCOUNT_ID,
	     SUS_CHANNEL_ID =update_row.SUS_CHANNEL_ID,
	     SUS_LINE_ITEM_ID =update_row.SUS_LINE_ITEM_ID,
	     SUS_PROJECT_ID =update_row.SUS_PROJECT_ID,
	     SUS_CUSTOMER_ID =update_row.SUS_CUSTOMER_ID,
	     SUS_TASK_ID =update_row.SUS_TASK_ID,
	     SUS_USER_DIM1_ID =update_row.SUS_USER_DIM1_ID,
	     SUS_USER_DIM2_ID =update_row.SUS_USER_DIM2_ID,
	     SUS_USER_DIM3_ID =update_row.SUS_USER_DIM3_ID,
	     SUS_USER_DIM4_ID =update_row.SUS_USER_DIM4_ID,
	     SUS_USER_DIM5_ID =update_row.SUS_USER_DIM5_ID,
	     SUS_USER_DIM6_ID =update_row.SUS_USER_DIM6_ID,
	     SUS_USER_DIM7_ID =update_row.SUS_USER_DIM7_ID,
	     SUS_USER_DIM8_ID =update_row.SUS_USER_DIM8_ID,
	     SUS_USER_DIM9_ID =update_row.SUS_USER_DIM9_ID,
	     SUS_USER_DIM10_ID =update_row.SUS_USER_DIM10_ID,
	     OBJECT_VERSION_NUMBER =update_row.OBJECT_VERSION_NUMBER

      WHERE		cb.RULE_ID = update_row.RULE_ID;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

      INSERT INTO
      gcs_interco_rules_tl
      (
		RULE_ID,
		LANGUAGE,
		SOURCE_LANG,
		RULE_NAME,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		DESCRIPTION,
		OBJECT_VERSION_NUMBER
      )
      SELECT
		RULE_ID,
		userenv('LANG'),
		userenv('LANG'),
		RULE_NAME,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		DESCRIPTION,
		OBJECT_VERSION_NUMBER

      FROM	dual
      WHERE	NOT EXISTS
  		(SELECT	1
  		 FROM		gcs_interco_rules_tl ctl
  		 WHERE	ctl.RULE_ID = update_row.RULE_ID
  		 AND		ctl.language = userenv('LANG'));



      UPDATE	gcs_interco_rules_tl ctl
      SET
	       RULE_NAME= update_row.RULE_NAME,
	       LAST_UPDATE_DATE = update_row.LAST_UPDATE_DATE,
	       LAST_UPDATED_BY = update_row.LAST_UPDATED_BY,
	       CREATION_DATE = update_row.CREATION_DATE,
	       CREATED_BY = update_row.CREATED_BY,
	       LAST_UPDATE_LOGIN = update_row.LAST_UPDATE_LOGIN,
	       DESCRIPTION = update_row.DESCRIPTION

      WHERE		ctl.RULE_NAME 	= update_row.RULE_NAME
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;




PROCEDURE Load_Row
(
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2,
	 owner varchar2,
	 custom_mode varchar2
) IS

    f_luby	NUMBER;	-- category owner in file
    f_ludate	DATE;	-- category update date in file
    db_luby	NUMBER; -- category owner in db
    db_ludate	DATE;	-- category update date in db
    f_start_date	DATE; -- start date in file

  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	cb.last_updated_by, cb.last_update_date
      INTO	db_luby, db_ludate
      FROM	gcs_interco_rules_b cb
      WHERE	cb.RULE_ID = load_row.RULE_ID;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
 update_row
 (
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 THRESHOLD_AMOUNT=>THRESHOLD_AMOUNT,
	 THRESHOLD_CURRENCY=>THRESHOLD_CURRENCY,
	 SUS_FINANCIAL_ELEM_ID=>SUS_FINANCIAL_ELEM_ID,
	 SUS_PRODUCT_ID=>SUS_PRODUCT_ID,
	 SUS_NATURAL_ACCOUNT_ID=>SUS_NATURAL_ACCOUNT_ID,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 SUS_CHANNEL_ID=>SUS_CHANNEL_ID,
	 SUS_LINE_ITEM_ID=>SUS_LINE_ITEM_ID,
	 SUS_PROJECT_ID=>SUS_PROJECT_ID,
	 SUS_CUSTOMER_ID=>SUS_CUSTOMER_ID,
	 SUS_TASK_ID=>SUS_TASK_ID,
	 SUS_USER_DIM1_ID=>SUS_USER_DIM1_ID,
	 SUS_USER_DIM2_ID=>SUS_USER_DIM2_ID,
	 SUS_USER_DIM3_ID=>SUS_USER_DIM3_ID,
	 SUS_USER_DIM4_ID=>SUS_USER_DIM4_ID,
	 SUS_USER_DIM5_ID=>SUS_USER_DIM5_ID,
	 SUS_USER_DIM6_ID=>SUS_USER_DIM6_ID,
	 SUS_USER_DIM7_ID=>SUS_USER_DIM7_ID,
	 SUS_USER_DIM8_ID=>SUS_USER_DIM8_ID,
	 SUS_USER_DIM9_ID=>SUS_USER_DIM9_ID,
	 SUS_USER_DIM10_ID=>SUS_USER_DIM10_ID,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 DESCRIPTION=>DESCRIPTION,
	 RULE_NAME=>RULE_NAME
);
END IF;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
insert_row
(
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 THRESHOLD_AMOUNT=>THRESHOLD_AMOUNT,
	 THRESHOLD_CURRENCY=>THRESHOLD_CURRENCY,
	 SUS_FINANCIAL_ELEM_ID=>SUS_FINANCIAL_ELEM_ID,
	 SUS_PRODUCT_ID=>SUS_PRODUCT_ID,
	 SUS_NATURAL_ACCOUNT_ID=>SUS_NATURAL_ACCOUNT_ID,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 SUS_CHANNEL_ID=>SUS_CHANNEL_ID,
	 SUS_LINE_ITEM_ID=>SUS_LINE_ITEM_ID,
	 SUS_PROJECT_ID=>SUS_PROJECT_ID,
	 SUS_CUSTOMER_ID=>SUS_CUSTOMER_ID,
	 SUS_TASK_ID=>SUS_TASK_ID,
	 SUS_USER_DIM1_ID=>SUS_USER_DIM1_ID,
	 SUS_USER_DIM2_ID=>SUS_USER_DIM2_ID,
	 SUS_USER_DIM3_ID=>SUS_USER_DIM3_ID,
	 SUS_USER_DIM4_ID=>SUS_USER_DIM4_ID,
	 SUS_USER_DIM5_ID=>SUS_USER_DIM5_ID,
	 SUS_USER_DIM6_ID=>SUS_USER_DIM6_ID,
	 SUS_USER_DIM7_ID=>SUS_USER_DIM7_ID,
	 SUS_USER_DIM8_ID=>SUS_USER_DIM8_ID,
	 SUS_USER_DIM9_ID=>SUS_USER_DIM9_ID,
	 SUS_USER_DIM10_ID=>SUS_USER_DIM10_ID,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 RULE_NAME=>RULE_NAME,
	 DESCRIPTION=>DESCRIPTION
);
 END;

 END Load_Row;



 PROCEDURE Translate_Row
 (
	 RULE_ID                        NUMBER,
	 RULE_NAME                    VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 DESCRIPTION                  VARCHAR2,
	 owner varchar2,
	 custom_mode varchar2

 ) IS
    f_luby		NUMBER; -- category owner in file
    f_ludate	DATE;	-- category update date in file
    db_luby		NUMBER; -- category owner in db
    db_ludate	DATE;	-- category update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	ctl.last_updated_by, ctl.last_update_date
      INTO	db_luby, db_ludate
      FROM	gcs_interco_rules_tl ctl
      WHERE	ctl.RULE_ID = translate_row.RULE_ID
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE
	gcs_interco_rules_tl ctl
        SET
		SOURCE_LANG= userenv('LANG'),
		RULE_ID=translate_row.RULE_ID,
		LAST_UPDATE_DATE=f_ludate,
		LAST_UPDATED_BY=f_luby,
		LAST_UPDATE_LOGIN=0,
		DESCRIPTION=translate_row.DESCRIPTION

        WHERE	ctl.RULE_ID = translate_row.RULE_ID
        AND		userenv('LANG') IN (ctl.language, ctl.source_lang);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;


procedure ADD_LANGUAGE
is
begin
   insert /*+ append parallel(tt) */ into
   gcs_interco_rules_tl tt
   (
		 RULE_ID ,
		 LANGUAGE ,
		 SOURCE_LANG ,
		 RULE_NAME    ,
		 OBJECT_VERSION_NUMBER,
		 CREATION_DATE   ,
		 CREATED_BY      ,
		 LAST_UPDATE_DATE ,
		 LAST_UPDATED_BY  ,
		 LAST_UPDATE_LOGIN ,
		 DESCRIPTION
  )

    select /*+ parallel(v) parallel(t) use_nl(t) */
    v.*
    from
    ( SELECT /*+ no_merge ordered parellel(b) */

		 B.RULE_ID ,
		 L.LANGUAGE_CODE,
		 B.SOURCE_LANG ,
		 B.RULE_NAME    ,
		 B.OBJECT_VERSION_NUMBER,
		 B.CREATION_DATE   ,
		 B.CREATED_BY      ,
		 B.LAST_UPDATE_DATE  ,
		 B.LAST_UPDATED_BY   ,
		 B.LAST_UPDATE_LOGIN ,
		 B.DESCRIPTION


  from gcs_interco_rules_tl B,
  FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  ) v, gcs_interco_rules_tl t
    where T.RULE_ID(+) = v.RULE_ID
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
    and t.RULE_ID IS NULL;

end ADD_LANGUAGE;




END GCS_INTERCO_RULES_PKG;

/
