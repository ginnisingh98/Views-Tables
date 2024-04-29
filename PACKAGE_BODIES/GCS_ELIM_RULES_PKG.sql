--------------------------------------------------------
--  DDL for Package Body GCS_ELIM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ELIM_RULES_PKG" AS
/* $Header: gcselimrulesb.pls 120.1 2005/10/30 05:17:56 appldev noship $ */

PROCEDURE Insert_Row
(
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 SEEDED_RULE_FLAG VARCHAR2,
	 TRANSACTION_TYPE_CODE VARCHAR2,
	 RULE_TYPE_CODE VARCHAR2,
	 FROM_TREATMENT_ID NUMBER,
	 TO_TREATMENT_ID NUMBER,
	 ENABLED_FLAG VARCHAR2,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 RULE_NAME VARCHAR2,
	 DESCRIPTION VARCHAR2
) IS

  CURSOR	elimrules_row IS
    SELECT	rowid
    FROM	gcs_elim_rules_b cb
    WHERE	cb.RULE_ID= insert_row.RULE_ID;
  BEGIN
    IF RULE_ID IS NULL THEN
      raise no_data_found;
    END IF;

 INSERT INTO gcs_elim_rules_b
 (
	 RULE_ID,
	 SEEDED_RULE_FLAG,
	 TRANSACTION_TYPE_CODE,
	 RULE_TYPE_CODE,
	 FROM_TREATMENT_ID,
	 TO_TREATMENT_ID,
	 ENABLED_FLAG,
	 OBJECT_VERSION_NUMBER,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN
)
SELECT
	 RULE_ID,
	 SEEDED_RULE_FLAG,
	 TRANSACTION_TYPE_CODE,
	 RULE_TYPE_CODE,
	 FROM_TREATMENT_ID,
	 TO_TREATMENT_ID,
	 ENABLED_FLAG,
	 OBJECT_VERSION_NUMBER,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN

 FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_elim_rules_b cb
		 WHERE	cb.RULE_ID= insert_row.RULE_ID);

INSERT INTO  gcs_elim_rules_tl
(
	 RULE_ID,
	 LANGUAGE,
	 SOURCE_LANG,
	 RULE_NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 DESCRIPTION
)
 SELECT
	 RULE_ID,
	 userenv('LANG'),
	 userenv('LANG'),
	 RULE_NAME,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 last_update_login,
	 DESCRIPTION


 FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_elim_rules_tl ctl
		 WHERE	ctl.RULE_ID = insert_row.RULE_ID
		 AND	ctl.language = userenv('LANG'));

    OPEN elimrules_row;
    FETCH elimrules_row INTO row_id;
    IF elimrules_row%NOTFOUND THEN
      CLOSE elimrules_row;
      raise no_data_found;
    END IF;
    CLOSE elimrules_row;

  END Insert_Row;



 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 SEEDED_RULE_FLAG VARCHAR2,
	 TRANSACTION_TYPE_CODE VARCHAR2,
	 RULE_TYPE_CODE VARCHAR2,
	 FROM_TREATMENT_ID NUMBER,
	 TO_TREATMENT_ID NUMBER,
	 ENABLED_FLAG VARCHAR2,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 RULE_NAME VARCHAR2,
	 DESCRIPTION VARCHAR2
) IS
  BEGIN

     UPDATE	gcs_elim_rules_b cb
     SET
	     RULE_ID=update_row.RULE_ID,
	     SEEDED_RULE_FLAG=update_row.SEEDED_RULE_FLAG,
	     TRANSACTION_TYPE_CODE=update_row.TRANSACTION_TYPE_CODE,
	     RULE_TYPE_CODE=update_row.RULE_TYPE_CODE,
	     FROM_TREATMENT_ID=update_row.FROM_TREATMENT_ID,
	     TO_TREATMENT_ID=update_row.TO_TREATMENT_ID,
	     ENABLED_FLAG=update_row.ENABLED_FLAG,
	     LAST_UPDATE_DATE=update_row.LAST_UPDATE_DATE,
	     LAST_UPDATED_BY=update_row.LAST_UPDATED_BY,
	     CREATION_DATE=update_row.CREATION_DATE,
	     CREATED_BY=update_row.CREATED_BY,
	     LAST_UPDATE_LOGIN=update_row.LAST_UPDATE_LOGIN,
	     OBJECT_VERSION_NUMBER=update_row.OBJECT_VERSION_NUMBER

      WHERE		cb.RULE_ID = update_row.RULE_ID;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

 INSERT INTO
 gcs_elim_rules_tl
 (
	 RULE_ID,
	 LANGUAGE,
	 SOURCE_LANG,
	 RULE_NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 DESCRIPTION
 )
SELECT
  RULE_ID,
  userenv('LANG'),
  userenv('LANG'),
  RULE_NAME,
  last_update_date,
  last_updated_by,
  creation_date,
  created_by,
  last_update_login,
  DESCRIPTION

FROM	dual
      WHERE	NOT EXISTS
  		(SELECT	1
  		 FROM		gcs_elim_rules_tl ctl
  		 WHERE	ctl.RULE_ID = update_row.RULE_ID
  		 AND		ctl.language = userenv('LANG'));



 UPDATE	gcs_elim_rules_tl ctl
      SET
	       LAST_UPDATE_DATE = update_row.LAST_UPDATE_DATE,
	       LAST_UPDATED_BY = update_row.LAST_UPDATED_BY,
	       CREATION_DATE = update_row.CREATION_DATE,
	       CREATED_BY = update_row.CREATED_BY,
	       LAST_UPDATE_LOGIN = update_row.LAST_UPDATE_LOGIN

      WHERE		ctl.RULE_NAME 	= update_row.RULE_NAME
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;




PROCEDURE Load_Row
(
	 row_id	           IN OUT NOCOPY VARCHAR2,
	 RULE_ID                         NUMBER,
	 SEEDED_RULE_FLAG                VARCHAR2,
	 TRANSACTION_TYPE_CODE           VARCHAR2,
	 RULE_TYPE_CODE                  VARCHAR2,
	 FROM_TREATMENT_ID               NUMBER,
	 TO_TREATMENT_ID                 NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 owner                           varchar2,
	 custom_mode                     varchar2,
	 RULE_NAME                       varchar2,
	 DESCRIPTION			 varchar2


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
      FROM	gcs_elim_rules_b cb
      WHERE	cb.RULE_ID = load_row.RULE_ID;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
 update_row
 (
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 SEEDED_RULE_FLAG=>SEEDED_RULE_FLAG,
	 TRANSACTION_TYPE_CODE=>TRANSACTION_TYPE_CODE,
	 RULE_TYPE_CODE=>RULE_TYPE_CODE,
	 FROM_TREATMENT_ID=>FROM_TREATMENT_ID,
	 TO_TREATMENT_ID=>TO_TREATMENT_ID,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
         RULE_NAME=>RULE_NAME,
	 DESCRIPTION=>DESCRIPTION
);



END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
insert_row
(
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 SEEDED_RULE_FLAG=>SEEDED_RULE_FLAG,
	 TRANSACTION_TYPE_CODE=>TRANSACTION_TYPE_CODE,
	 RULE_TYPE_CODE=>RULE_TYPE_CODE,
	 FROM_TREATMENT_ID=>FROM_TREATMENT_ID,
	 TO_TREATMENT_ID=>TO_TREATMENT_ID,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
         RULE_NAME=>RULE_NAME,
	 DESCRIPTION=>DESCRIPTION

 );
 END;

 END Load_Row;



 PROCEDURE Translate_Row
 (
	 RULE_ID                         NUMBER,
	 RULE_NAME                       VARCHAR2,
	 DESCRIPTION                     VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 owner                           varchar2,
	 custom_mode                     varchar2
 )
 IS
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
      FROM	gcs_elim_rules_tl ctl
      WHERE	ctl.RULE_ID = translate_row.RULE_ID
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE
	gcs_elim_rules_tl ctl
        SET
		SOURCE_LANG= userenv('LANG'),
		RULE_ID=translate_row.RULE_ID,
		LAST_UPDATE_DATE=f_ludate,
		LAST_UPDATED_BY=f_luby,
		LAST_UPDATE_LOGIN=0

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
   gcs_elim_rules_tl tt
   (
		 RULE_ID,
		 LANGUAGE,
		 SOURCE_LANG,
		 RULE_NAME,
		 DESCRIPTION,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN
  )

    select /*+ parallel(v) parallel(t) use_nl(t) */
    v.*
    from
    ( SELECT /*+ no_merge ordered parellel(b) */

		 B.RULE_ID,
		 L.LANGUAGE_CODE,
		 B.SOURCE_LANG,
		 B.RULE_NAME,
		 B.DESCRIPTION,
		 B.LAST_UPDATE_DATE,
		 B.LAST_UPDATED_BY,
		 B.CREATION_DATE,
		 B.CREATED_BY,
		 B.LAST_UPDATE_LOGIN


  from gcs_elim_rules_tl B,
  FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  ) v, gcs_elim_rules_tl t
    where T.RULE_ID(+) = v.RULE_ID
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
    and t.RULE_ID IS NULL;

end ADD_LANGUAGE;



END GCS_ELIM_RULES_PKG;

/
