--------------------------------------------------------
--  DDL for Package Body GCS_TREATMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TREATMENTS_PKG" AS
/* $Header: gcstreatmentsb.pls 120.1 2005/10/30 05:19:19 appldev noship $ */


PROCEDURE Insert_Row
(
 row_id	IN OUT NOCOPY			VARCHAR2,
 TREATMENT_ID				NUMBER,
 CONSOLIDATION_TYPE_CODE		VARCHAR2,
 ENABLED_FLAG				VARCHAR2,
 OPERATOR_LOW_CODE			VARCHAR2,
 OPERATOR_HIGH_CODE			VARCHAR2,
 LAST_UPDATE_DATE			DATE,
 LAST_UPDATED_BY			NUMBER,
 CREATION_DATE				DATE,
 CREATED_BY				NUMBER,
 LAST_UPDATE_LOGIN			NUMBER,
 OWNERSHIP_PERCENT_LOW			NUMBER,
 OWNERSHIP_PERCENT_HIGH			NUMBER,
 OBJECT_VERSION_NUMBER			NUMBER,
 DESCRIPTION				VARCHAR2,
 TREATMENT_NAME				varchar2

) IS

  CURSOR	treatment_row IS
    SELECT	rowid
    FROM	gcs_treatments_b cb
    WHERE	cb.TREATMENT_ID= insert_row.TREATMENT_ID;
  BEGIN
    IF TREATMENT_ID IS NULL THEN
      raise no_data_found;
    END IF;

 INSERT INTO gcs_treatments_b
 (
	 TREATMENT_ID,
	 CONSOLIDATION_TYPE_CODE,
	 ENABLED_FLAG,
	 OPERATOR_LOW_CODE,
	 OPERATOR_HIGH_CODE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 OWNERSHIP_PERCENT_LOW,
	 OWNERSHIP_PERCENT_HIGH,
	 OBJECT_VERSION_NUMBER
)
SELECT
 TREATMENT_ID,
 CONSOLIDATION_TYPE_CODE,
 ENABLED_FLAG,
 OPERATOR_LOW_CODE,
 OPERATOR_HIGH_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN,
 OWNERSHIP_PERCENT_LOW,
 OWNERSHIP_PERCENT_HIGH,
 OBJECT_VERSION_NUMBER

 FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_treatments_b cb
		 WHERE	cb.TREATMENT_ID= insert_row.TREATMENT_ID);

INSERT INTO gcs_treatments_TL
(
	 TREATMENT_ID,
	 LANGUAGE,
	 SOURCE_LANG,
	 TREATMENT_NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 DESCRIPTION
)
   SELECT
    TREATMENT_ID,
    userenv('LANG'),
    userenv('LANG'),
    TREATMENT_NAME,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    description

   FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_treatments_tl ctl
		 WHERE	ctl.TREATMENT_ID = insert_row.TREATMENT_ID
		 AND	ctl.language = userenv('LANG'));

    OPEN treatment_row;
    FETCH treatment_row INTO row_id;
    IF treatment_row%NOTFOUND THEN
      CLOSE treatment_row;
      raise no_data_found;
    END IF;
    CLOSE treatment_row;

  END Insert_Row;




  PROCEDURE Update_Row
  (
	 row_id	IN OUT NOCOPY			VARCHAR2,
	 TREATMENT_ID				NUMBER,
	 CONSOLIDATION_TYPE_CODE		VARCHAR2,
	 ENABLED_FLAG				VARCHAR2,
	 OPERATOR_LOW_CODE			VARCHAR2,
	 OPERATOR_HIGH_CODE			VARCHAR2,
	 LAST_UPDATE_DATE			DATE,
	 LAST_UPDATED_BY			NUMBER,
	 CREATION_DATE				DATE,
	 CREATED_BY				NUMBER,
	 LAST_UPDATE_LOGIN			NUMBER,
	 OWNERSHIP_PERCENT_LOW			NUMBER,
	 OWNERSHIP_PERCENT_HIGH			NUMBER,
	 OBJECT_VERSION_NUMBER			NUMBER,
	 DESCRIPTION				VARCHAR2,
	 TREATMENT_NAME				VARCHAR2
) IS
  BEGIN

     UPDATE	gcs_treatments_b cb
     SET
	     TREATMENT_ID=update_row.TREATMENT_ID,
	     CONSOLIDATION_TYPE_CODE=update_row.CONSOLIDATION_TYPE_CODE,
	     ENABLED_FLAG=update_row.ENABLED_FLAG,
	     OPERATOR_LOW_CODE=update_row.OPERATOR_LOW_CODE,
	     OPERATOR_HIGH_CODE=update_row.OPERATOR_HIGH_CODE,
	     LAST_UPDATE_DATE=update_row.LAST_UPDATE_DATE,
	     LAST_UPDATED_BY=update_row.LAST_UPDATED_BY,
	     CREATION_DATE=update_row.CREATION_DATE,
	     CREATED_BY=update_row.CREATED_BY,
	     LAST_UPDATE_LOGIN=update_row.LAST_UPDATE_LOGIN,
	     OWNERSHIP_PERCENT_LOW=update_row.OWNERSHIP_PERCENT_LOW,
	     OWNERSHIP_PERCENT_HIGH=update_row.OWNERSHIP_PERCENT_HIGH,
	     OBJECT_VERSION_NUMBER=update_row.OBJECT_VERSION_NUMBER

      WHERE		cb.TREATMENT_ID = update_row.TREATMENT_ID;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

 INSERT INTO
 GCS_TREATMENTS_TL
 (
	  TREATMENT_ID,
	  LANGUAGE,
	  SOURCE_LANG,
	  TREATMENT_NAME,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_LOGIN,
	  DESCRIPTION
 )
SELECT

	  TREATMENT_ID,
	  userenv('LANG'),
	  userenv('LANG'),
	  TREATMENT_NAME,
	  last_update_date,
	  last_updated_by,
	  creation_date,
	  created_by,
	  last_update_login,
	  description

FROM	dual
      WHERE	NOT EXISTS
  		(SELECT	1
  		 FROM		GCS_TREATMENTS_TL ctl
  		 WHERE	ctl.TREATMENT_ID = update_row.TREATMENT_ID
  		 AND		ctl.language = userenv('LANG'));



      UPDATE	GCS_TREATMENTS_TL ctl
      SET
	       LAST_UPDATE_DATE = update_row.LAST_UPDATE_DATE,
	       LAST_UPDATED_BY = update_row.LAST_UPDATED_BY,
	       CREATION_DATE = update_row.CREATION_DATE,
	       CREATED_BY = update_row.CREATED_BY,
	       LAST_UPDATE_LOGIN = update_row.LAST_UPDATE_LOGIN

      WHERE		ctl.TREATMENT_ID 	= update_row.TREATMENT_ID
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;


PROCEDURE Load_Row
(
 row_id	IN OUT NOCOPY			VARCHAR2,
 TREATMENT_ID				NUMBER,
 CONSOLIDATION_TYPE_CODE		VARCHAR2,
 ENABLED_FLAG				VARCHAR2,
 OPERATOR_LOW_CODE			VARCHAR2,
 OPERATOR_HIGH_CODE			VARCHAR2,
 LAST_UPDATE_DATE			DATE,
 LAST_UPDATED_BY			NUMBER,
 CREATION_DATE				DATE,
 CREATED_BY				NUMBER,
 LAST_UPDATE_LOGIN			NUMBER,
 OWNERSHIP_PERCENT_LOW			NUMBER,
 OWNERSHIP_PERCENT_HIGH			NUMBER,
 OBJECT_VERSION_NUMBER			NUMBER,
 owner					VARCHAR2,
 custom_mode				VARCHAR2,
 DESCRIPTION				VARCHAR2,
 TREATMENT_NAME				VARCHAR2
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
      FROM	GCS_TREATMENTS_B cb
      WHERE	cb.TREATMENT_ID = load_row.TREATMENT_ID;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
 update_row
 (
	 row_id=>row_id,
	 TREATMENT_ID=>TREATMENT_ID,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 CONSOLIDATION_TYPE_CODE=>CONSOLIDATION_TYPE_CODE,
	 OPERATOR_LOW_CODE=>OPERATOR_LOW_CODE,
	 OPERATOR_HIGH_CODE=>OPERATOR_HIGH_CODE,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 OWNERSHIP_PERCENT_LOW=>OWNERSHIP_PERCENT_LOW,
	 OWNERSHIP_PERCENT_HIGH=>OWNERSHIP_PERCENT_HIGH,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 DESCRIPTION=>DESCRIPTION,
	 TREATMENT_NAME=>TREATMENT_NAME
);

END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 insert_row
 (
	 row_id=>row_id,
	 TREATMENT_ID=>TREATMENT_ID,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 CONSOLIDATION_TYPE_CODE=>CONSOLIDATION_TYPE_CODE,
	 OPERATOR_LOW_CODE=>OPERATOR_LOW_CODE,
	 OPERATOR_HIGH_CODE=>OPERATOR_HIGH_CODE,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 OWNERSHIP_PERCENT_LOW=>OWNERSHIP_PERCENT_LOW,
	 OWNERSHIP_PERCENT_HIGH=>OWNERSHIP_PERCENT_HIGH,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 DESCRIPTION=>DESCRIPTION,
	 TREATMENT_NAME=>TREATMENT_NAME

);
 END;

 END Load_Row;





 PROCEDURE Translate_Row
 (
	 TREATMENT_ID                   NUMBER,
	 TREATMENT_NAME                 VARCHAR2,
	 LAST_UPDATE_DATE               DATE,
	 LAST_UPDATED_BY                NUMBER,
	 CREATION_DATE                  DATE,
	 CREATED_BY                     NUMBER,
	 LAST_UPDATE_LOGIN              NUMBER,
	 DESCRIPTION                    VARCHAR2,
	 owner                          VARCHAR2,
	 custom_mode                    VARCHAR2
  )  IS
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
      FROM	GCS_TREATMENTS_TL ctl
      WHERE	ctl.TREATMENT_ID = translate_row.TREATMENT_ID
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE
	GCS_TREATMENTS_TL ctl
        SET
		SOURCE_LANG= userenv('LANG'),
		TREATMENT_NAME=translate_row.TREATMENT_NAME,
		LAST_UPDATE_DATE=f_ludate,
		LAST_UPDATED_BY=f_luby,
		LAST_UPDATE_LOGIN=0,
		DESCRIPTION=translate_row.DESCRIPTION

        WHERE	ctl.TREATMENT_ID = translate_row.TREATMENT_ID
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
   GCS_TREATMENTS_TL tt
   (
	TREATMENT_ID    ,
	LANGUAGE         ,
	SOURCE_LANG      ,
	TREATMENT_NAME   ,
	LAST_UPDATE_DATE ,
	LAST_UPDATED_BY  ,
	CREATION_DATE    ,
	CREATED_BY       ,
	LAST_UPDATE_LOGIN,
	DESCRIPTION
  )

    select /*+ parallel(v) parallel(t) use_nl(t) */
    v.*
    from
    ( SELECT /*+ no_merge ordered parellel(b) */

        B.TREATMENT_ID     ,
	L.LANGUAGE_CODE    ,
	B.SOURCE_LANG      ,
	B.TREATMENT_NAME   ,
	B.LAST_UPDATE_DATE ,
	B.LAST_UPDATED_BY  ,
	B.CREATION_DATE    ,
	B.CREATED_BY        ,
	B.LAST_UPDATE_LOGIN  ,
	B.DESCRIPTION


  from GCS_TREATMENTS_TL B,
  FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  ) v, GCS_TREATMENTS_TL t
    where T.TREATMENT_ID(+) = v.TREATMENT_ID
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
    and t.TREATMENT_ID IS NULL;

end ADD_LANGUAGE;


END GCS_TREATMENTS_PKG;

/
