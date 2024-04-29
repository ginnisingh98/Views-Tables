--------------------------------------------------------
--  DDL for Package Body GCS_ELIM_RULE_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ELIM_RULE_STEPS_PKG" AS
/* $Header: gcs_rule_stepb.pls 120.1 2005/10/30 05:19:03 appldev noship $ */

 PROCEDURE Insert_Row
 (
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 RULE_STEP_ID NUMBER,
	 STEP_SEQ NUMBER,
	 FORMULA_TEXT VARCHAR2,
	 PARSED_FORMULA VARCHAR2,
	 COMPILED_VARIABLES VARCHAR2,
	 SQL_STATEMENT_NUM NUMBER,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 STEP_NAME VARCHAR2
 )
 IS

  CURSOR	elimrulesteps_row IS
    SELECT	rowid
    FROM	gcs_elim_rule_steps_b cb
    WHERE	cb.RULE_STEP_ID= insert_row.RULE_STEP_ID;
  BEGIN
    IF RULE_STEP_ID IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_elim_rule_steps_b
    (
	     RULE_ID,
	     RULE_STEP_ID,
	     STEP_SEQ,
	     FORMULA_TEXT,
	     PARSED_FORMULA,
	     COMPILED_VARIABLES,
	     SQL_STATEMENT_NUM,
	     OBJECT_VERSION_NUMBER,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
     LAST_UPDATE_LOGIN
    )
    SELECT
	     RULE_ID,
	     RULE_STEP_ID,
	     STEP_SEQ,
	     FORMULA_TEXT,
	     PARSED_FORMULA,
	     COMPILED_VARIABLES,
	     SQL_STATEMENT_NUM,
	     OBJECT_VERSION_NUMBER,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN

    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_elim_rule_steps_b cb
		 WHERE	cb.RULE_STEP_ID= insert_row.RULE_STEP_ID
		);

    INSERT INTO gcs_elim_rule_steps_tl
    (
	     LANGUAGE,
	     SOURCE_LANG,
	     STEP_NAME,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     RULE_STEP_ID
    )
   SELECT
    userenv('LANG'),
    userenv('LANG'),
    STEP_NAME,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    LAST_UPDATE_LOGIN,
    RULE_STEP_ID

    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_elim_rule_steps_tl ctl
		 WHERE	ctl.RULE_STEP_ID = insert_row.RULE_STEP_ID
		 AND	ctl.language = userenv('LANG'));

    OPEN elimrulesteps_row;
    FETCH elimrulesteps_row INTO row_id;
    IF elimrulesteps_row%NOTFOUND THEN
      CLOSE elimrulesteps_row;
      raise no_data_found;
    END IF;
    CLOSE elimrulesteps_row;

  END Insert_Row;



 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 RULE_STEP_ID NUMBER,
	 STEP_SEQ NUMBER,
	 FORMULA_TEXT VARCHAR2,
	 PARSED_FORMULA VARCHAR2,
	 COMPILED_VARIABLES VARCHAR2,
	 SQL_STATEMENT_NUM NUMBER,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 STEP_NAME VARCHAR2
) IS
  BEGIN

 UPDATE	gcs_elim_rule_steps_b cb
 SET
	 RULE_ID=update_row.RULE_ID,
	 RULE_STEP_ID = update_row.RULE_STEP_ID,
	 STEP_SEQ = update_row.STEP_SEQ,
	 FORMULA_TEXT = update_row.FORMULA_TEXT,
	 PARSED_FORMULA = update_row.PARSED_FORMULA,
	 COMPILED_VARIABLES = update_row.COMPILED_VARIABLES,
	 SQL_STATEMENT_NUM = update_row.SQL_STATEMENT_NUM,
	 OBJECT_VERSION_NUMBER = update_row.OBJECT_VERSION_NUMBER,
	 LAST_UPDATE_DATE = update_row.LAST_UPDATE_DATE,
	 LAST_UPDATED_BY = update_row.LAST_UPDATED_BY,
	 CREATION_DATE = update_row.CREATION_DATE,
	 CREATED_BY = update_row.CREATED_BY,
	 LAST_UPDATE_LOGIN = update_row.LAST_UPDATE_LOGIN

 WHERE	cb.RULE_STEP_ID = update_row.RULE_STEP_ID;

 IF SQL%NOTFOUND THEN
        raise no_data_found;
 END IF;


 INSERT INTO
 gcs_elim_rule_steps_tl
 (
	  RULE_STEP_ID,
	  LANGUAGE,
	  SOURCE_LANG,
	  STEP_NAME,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_LOGIN
 )
      SELECT
	       RULE_STEP_ID,
	       userenv('LANG'),
	       userenv('LANG'),
	       STEP_NAME,
	       LAST_UPDATE_DATE,
	       LAST_UPDATED_BY,
	       CREATION_DATE,
	       CREATED_BY,
	       LAST_UPDATE_LOGIN

      FROM	dual
      WHERE	NOT EXISTS
  		(SELECT	1
  		 FROM		gcs_elim_rule_steps_tl ctl
  		 WHERE	ctl.RULE_STEP_ID = update_row.RULE_STEP_ID
  		 AND		ctl.language = userenv('LANG'));



      UPDATE	gcs_elim_rule_steps_tl ctl
      SET
  	   LAST_UPDATE_DATE		= update_row.LAST_UPDATE_DATE,
  	   LAST_UPDATED_BY		= update_row.LAST_UPDATED_BY,
  	   LAST_UPDATE_LOGIN		= update_row.LAST_UPDATE_LOGIN

      WHERE		ctl.RULE_STEP_ID 	= update_row.RULE_STEP_ID
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;


 PROCEDURE Load_Row
 (
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 RULE_STEP_ID NUMBER,
	 STEP_SEQ NUMBER,
	 FORMULA_TEXT VARCHAR2,
	 PARSED_FORMULA VARCHAR2,
	 COMPILED_VARIABLES VARCHAR2,
	 SQL_STATEMENT_NUM NUMBER,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 owner VARCHAR2,
	 custom_mode varchar2,
	 STEP_NAME VARCHAR2
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
      FROM	gcs_elim_rule_steps_TL cb
      WHERE	cb.RULE_STEP_ID = load_row.RULE_STEP_ID;

      -- Test for customization information
 IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,custom_mode)
 THEN
 update_row
 (
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 RULE_STEP_ID=>RULE_STEP_ID,
	 STEP_SEQ=>STEP_SEQ,
	 FORMULA_TEXT=>FORMULA_TEXT,
	 PARSED_FORMULA=>PARSED_FORMULA,
	 COMPILED_VARIABLES=>COMPILED_VARIABLES,
	 SQL_STATEMENT_NUM=>SQL_STATEMENT_NUM,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 STEP_NAME=>STEP_NAME
);
 END IF;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 insert_row
 (
	 row_id=>row_id,
	 RULE_ID=>RULE_ID,
	 RULE_STEP_ID=>RULE_STEP_ID,
	 STEP_SEQ=>STEP_SEQ,
	 FORMULA_TEXT=>FORMULA_TEXT,
	 PARSED_FORMULA=>PARSED_FORMULA,
	 COMPILED_VARIABLES=>COMPILED_VARIABLES,
	 SQL_STATEMENT_NUM=>SQL_STATEMENT_NUM,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 STEP_NAME=>STEP_NAME
);
 END;

 END Load_Row;



 PROCEDURE Translate_Row
 (
	 RULE_STEP_ID NUMBER,
	 STEP_NAME VARCHAR2,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
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
      FROM	gcs_elim_rule_steps_TL ctl
      WHERE	ctl.RULE_STEP_ID = translate_row.RULE_STEP_ID
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE
	gcs_elim_rule_steps_TL ctl
        SET
		STEP_NAME=translate_row.STEP_NAME,
		LAST_UPDATE_DATE=f_ludate,
		LAST_UPDATED_BY=f_luby,
		LAST_UPDATE_LOGIN=0

        WHERE	ctl.RULE_STEP_ID = translate_row.RULE_STEP_ID
        AND	userenv('LANG') IN (ctl.language, ctl.source_lang);
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
   gcs_elim_rule_steps_TL tt
   (
		 LANGUAGE,
		 SOURCE_LANG  ,
		 STEP_NAME ,
		 LAST_UPDATE_DATE ,
		 LAST_UPDATED_BY,
		 CREATION_DATE ,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN   ,
		 RULE_STEP_ID
   )

    select /*+ parallel(v) parallel(t) use_nl(t) */
    v.*
    from
    ( SELECT /*+ no_merge ordered parellel(b) */
		 L.LANGUAGE_CODE,
		 B.SOURCE_LANG  ,
		 B.STEP_NAME ,
		 B.LAST_UPDATE_DATE ,
		 B.LAST_UPDATED_BY,
		 B.CREATION_DATE ,
		 B.CREATED_BY,
		 B.LAST_UPDATE_LOGIN   ,
		 B.RULE_STEP_ID


  from gcs_elim_rule_steps_TL B,
  FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  ) v, gcs_elim_rule_steps_TL t
    where T.RULE_STEP_ID(+) = v.RULE_STEP_ID
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
    and t.RULE_STEP_ID IS NULL;

end ADD_LANGUAGE;


END GCS_ELIM_RULE_STEPS_PKG;

/
