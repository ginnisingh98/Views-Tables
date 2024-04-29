--------------------------------------------------------
--  DDL for Package Body GCS_CURR_TREATMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CURR_TREATMENTS_PKG" AS
/* $Header: gcs_curr_trtb.pls 120.1 2005/10/30 05:17:15 appldev noship $ */


PROCEDURE Insert_Row
(
 row_id	IN OUT NOCOPY	         VARCHAR2,
 CURR_TREATMENT_ID               NUMBER,
 ENDING_RATE_TYPE                VARCHAR2,
 AVERAGE_RATE_TYPE               VARCHAR2,
 EQUITY_MODE_CODE                VARCHAR2,
 INC_STMT_MODE_CODE              VARCHAR2,
 ENABLED_FLAG                    VARCHAR2,
 DEFAULT_FLAG                    VARCHAR2,
 FINANCIAL_ELEM_ID               NUMBER,
 PRODUCT_ID                      NUMBER,
 NATURAL_ACCOUNT_ID              NUMBER,
 CHANNEL_ID                      NUMBER,
 LINE_ITEM_ID                    NUMBER,
 PROJECT_ID                      NUMBER,
 CUSTOMER_ID                     NUMBER,
 CTA_USER_DIM1_ID                NUMBER,
 CTA_USER_DIM2_ID                NUMBER,
 CTA_USER_DIM3_ID                NUMBER,
 CTA_USER_DIM4_ID                NUMBER,
 CTA_USER_DIM5_ID                NUMBER,
 CTA_USER_DIM6_ID                NUMBER,
 CTA_USER_DIM7_ID                NUMBER,
 CTA_USER_DIM8_ID                NUMBER,
 CTA_USER_DIM9_ID                NUMBER,
 CTA_USER_DIM10_ID               NUMBER,
 TASK_ID                         NUMBER,
 CREATION_DATE                   DATE,
 CREATED_BY                      NUMBER,
 LAST_UPDATE_DATE                DATE,
 LAST_UPDATED_BY                 NUMBER,
 LAST_UPDATE_LOGIN               NUMBER,
 OBJECT_VERSION_NUMBER           NUMBER,
 CURR_TREATMENT_NAME             VARCHAR2,
 DESCRIPTION                     VARCHAR2
) IS

 CURSOR	curtreat_row IS
    SELECT	rowid
    FROM	gcs_curr_treatments_b cb
    WHERE	cb.CURR_TREATMENT_ID= insert_row.CURR_TREATMENT_ID;

 BEGIN
    IF CURR_TREATMENT_ID IS NULL THEN
      raise no_data_found;
    END IF;

 INSERT INTO gcs_curr_treatments_b
 (
	 CURR_TREATMENT_ID,
	 ENDING_RATE_TYPE,
	 AVERAGE_RATE_TYPE,
	 EQUITY_MODE_CODE,
	 INC_STMT_MODE_CODE,
	 ENABLED_FLAG,
	 DEFAULT_FLAG,
	 FINANCIAL_ELEM_ID,
	 PRODUCT_ID,
	 NATURAL_ACCOUNT_ID,
	 CHANNEL_ID,
	 LINE_ITEM_ID,
	 PROJECT_ID,
	 CUSTOMER_ID,
	 CTA_USER_DIM1_ID,
	 CTA_USER_DIM2_ID,
	 CTA_USER_DIM3_ID,
	 CTA_USER_DIM4_ID,
	 CTA_USER_DIM5_ID,
	 CTA_USER_DIM6_ID,
	 CTA_USER_DIM7_ID,
	 CTA_USER_DIM8_ID,
	 CTA_USER_DIM9_ID,
	 CTA_USER_DIM10_ID,
	 TASK_ID,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 OBJECT_VERSION_NUMBER
   )
   SELECT
     CURR_TREATMENT_ID,
     ENDING_RATE_TYPE,
     AVERAGE_RATE_TYPE,
     EQUITY_MODE_CODE,
     INC_STMT_MODE_CODE,
     ENABLED_FLAG,
     DEFAULT_FLAG,
     FINANCIAL_ELEM_ID,
     PRODUCT_ID,
     NATURAL_ACCOUNT_ID,
     CHANNEL_ID,
     LINE_ITEM_ID,
     PROJECT_ID,
     CUSTOMER_ID,
     CTA_USER_DIM1_ID,
     CTA_USER_DIM2_ID,
     CTA_USER_DIM3_ID,
     CTA_USER_DIM4_ID,
     CTA_USER_DIM5_ID,
     CTA_USER_DIM6_ID,
     CTA_USER_DIM7_ID,
     CTA_USER_DIM8_ID,
     CTA_USER_DIM9_ID,
     CTA_USER_DIM10_ID,
     TASK_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER
   FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_curr_treatments_b cb
		 WHERE	cb.CURR_TREATMENT_ID= insert_row.CURR_TREATMENT_ID);

    INSERT INTO gcs_curr_treatments_tl
    (
	CURR_TREATMENT_ID,
	LANGUAGE,
	SOURCE_LANG,
	CURR_TREATMENT_NAME,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	DESCRIPTION
   )
    SELECT
	    CURR_TREATMENT_ID,
	    userenv('LANG'),
	    userenv('LANG'),
	    CURR_TREATMENT_NAME,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    DESCRIPTION
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_curr_treatments_tl ctl
		 WHERE	ctl.CURR_TREATMENT_ID = insert_row.CURR_TREATMENT_ID
		 AND	ctl.language = userenv('LANG'));

    OPEN curtreat_row;

    FETCH curtreat_row INTO row_id;
    IF curtreat_row%NOTFOUND THEN
      CLOSE curtreat_row;
      raise no_data_found;
    END IF;
    CLOSE curtreat_row;

  END Insert_Row;


   --****************************************

 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY	         VARCHAR2,
	 CURR_TREATMENT_ID               NUMBER,
	 ENDING_RATE_TYPE                VARCHAR2,
	 AVERAGE_RATE_TYPE               VARCHAR2,
	 EQUITY_MODE_CODE                VARCHAR2,
	 INC_STMT_MODE_CODE              VARCHAR2,
	 ENABLED_FLAG                    VARCHAR2,
	 DEFAULT_FLAG                    VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 FINANCIAL_ELEM_ID               NUMBER,
	 PRODUCT_ID                      NUMBER,
	 NATURAL_ACCOUNT_ID              NUMBER,
	 CHANNEL_ID                      NUMBER,
	 LINE_ITEM_ID                    NUMBER,
	 PROJECT_ID                      NUMBER,
	 CUSTOMER_ID                     NUMBER,
	 CTA_USER_DIM1_ID                NUMBER,
	 CTA_USER_DIM2_ID                NUMBER,
	 CTA_USER_DIM3_ID                NUMBER,
	 CTA_USER_DIM4_ID                NUMBER,
	 CTA_USER_DIM5_ID                NUMBER,
	 CTA_USER_DIM6_ID                NUMBER,
	 CTA_USER_DIM7_ID                NUMBER,
	 CTA_USER_DIM8_ID                NUMBER,
	 CTA_USER_DIM9_ID                NUMBER,
	 CTA_USER_DIM10_ID               NUMBER,
	 TASK_ID                         NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CURR_TREATMENT_NAME             VARCHAR2,
	 DESCRIPTION                     VARCHAR2
) IS
  BEGIN

     UPDATE	gcs_curr_treatments_b cb
     SET
	     ENDING_RATE_TYPE=update_row.ENDING_RATE_TYPE,
	     AVERAGE_RATE_TYPE=update_row.AVERAGE_RATE_TYPE,
	     EQUITY_MODE_CODE=update_row.EQUITY_MODE_CODE,
	     INC_STMT_MODE_CODE=update_row.INC_STMT_MODE_CODE,
	     ENABLED_FLAG=update_row.ENABLED_FLAG,
	     DEFAULT_FLAG=update_row.DEFAULT_FLAG,
	     LAST_UPDATE_DATE=update_row.LAST_UPDATE_DATE,
	     LAST_UPDATED_BY=update_row.LAST_UPDATED_BY,
	     CREATION_DATE=update_row.CREATION_DATE,
	     CREATED_BY=update_row.CREATED_BY,
	     LAST_UPDATE_LOGIN=update_row.LAST_UPDATE_LOGIN,
	     FINANCIAL_ELEM_ID=update_row.FINANCIAL_ELEM_ID,
	     PRODUCT_ID=update_row.PRODUCT_ID,
	     NATURAL_ACCOUNT_ID=update_row.NATURAL_ACCOUNT_ID,
	     CHANNEL_ID=update_row.CHANNEL_ID,
	     LINE_ITEM_ID=update_row.LINE_ITEM_ID,
	     PROJECT_ID=update_row.PROJECT_ID,
	     CUSTOMER_ID=update_row.CUSTOMER_ID,
	     CTA_USER_DIM1_ID=update_row.CTA_USER_DIM1_ID,
	     CTA_USER_DIM2_ID=update_row.CTA_USER_DIM2_ID,
	     CTA_USER_DIM3_ID=update_row.CTA_USER_DIM3_ID,
	     CTA_USER_DIM4_ID=update_row.CTA_USER_DIM4_ID,
	     CTA_USER_DIM5_ID=update_row.CTA_USER_DIM5_ID,
	     CTA_USER_DIM6_ID=update_row.CTA_USER_DIM6_ID,
	     CTA_USER_DIM7_ID=update_row.CTA_USER_DIM7_ID,
	     CTA_USER_DIM8_ID=update_row.CTA_USER_DIM8_ID,
	     CTA_USER_DIM9_ID=update_row.CTA_USER_DIM9_ID,
	     CTA_USER_DIM10_ID=update_row.CTA_USER_DIM10_ID,
	     TASK_ID=update_row.TASK_ID,
	     OBJECT_VERSION_NUMBER=update_row.OBJECT_VERSION_NUMBER

      WHERE  cb.CURR_TREATMENT_ID = update_row.CURR_TREATMENT_ID;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

      INSERT INTO
      GCS_CURR_TREATMENTS_TL
      (
       CURR_TREATMENT_ID,
       LANGUAGE,
       SOURCE_LANG,
       CURR_TREATMENT_NAME,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       DESCRIPTION
      )
      SELECT
       CURR_TREATMENT_ID,
       userenv('LANG'),
       userenv('LANG'),
       CURR_TREATMENT_NAME,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       DESCRIPTION
      FROM	dual
      WHERE	NOT EXISTS
  		(
		 SELECT	1
  		 FROM		GCS_CURR_TREATMENTS_TL ctl
  		 WHERE	ctl.CURR_TREATMENT_ID = update_row.CURR_TREATMENT_ID
  		 AND		ctl.language = userenv('LANG')
		);



      UPDATE	GCS_CURR_TREATMENTS_TL ctl
      SET
       CURR_TREATMENT_NAME = update_row.CURR_TREATMENT_NAME,
       LAST_UPDATE_DATE = update_row.LAST_UPDATE_DATE,
       LAST_UPDATED_BY = update_row.LAST_UPDATED_BY,
       CREATION_DATE = update_row.CREATION_DATE,
       CREATED_BY = update_row.CREATED_BY,
       LAST_UPDATE_LOGIN = update_row.LAST_UPDATE_LOGIN,
       DESCRIPTION = update_row.DESCRIPTION
      WHERE		ctl.CURR_TREATMENT_ID 	= update_row.CURR_TREATMENT_ID
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;

 --****************************************
 PROCEDURE Load_Row
 (
	 row_id	IN OUT NOCOPY	         VARCHAR2,
	 CURR_TREATMENT_ID               NUMBER,
	 ENDING_RATE_TYPE                VARCHAR2,
	 AVERAGE_RATE_TYPE               VARCHAR2,
	 EQUITY_MODE_CODE                VARCHAR2,
	 INC_STMT_MODE_CODE              VARCHAR2,
	 ENABLED_FLAG                    VARCHAR2,
	 DEFAULT_FLAG                    VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 FINANCIAL_ELEM_ID               NUMBER,
	 PRODUCT_ID                      NUMBER,
	 NATURAL_ACCOUNT_ID              NUMBER,
	 CHANNEL_ID                      NUMBER,
	 LINE_ITEM_ID                    NUMBER,
	 PROJECT_ID                      NUMBER,
	 CUSTOMER_ID                     NUMBER,
	 CTA_USER_DIM1_ID                NUMBER,
	 CTA_USER_DIM2_ID                NUMBER,
	 CTA_USER_DIM3_ID                NUMBER,
	 CTA_USER_DIM4_ID                NUMBER,
	 CTA_USER_DIM5_ID                NUMBER,
	 CTA_USER_DIM6_ID                NUMBER,
	 CTA_USER_DIM7_ID                NUMBER,
	 CTA_USER_DIM8_ID                NUMBER,
	 CTA_USER_DIM9_ID                NUMBER,
	 CTA_USER_DIM10_ID               NUMBER,
	 TASK_ID                         NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
         CURR_TREATMENT_NAME           VARCHAR2,
	 DESCRIPTION                     VARCHAR2,
	 owner				 VARCHAR2,
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
      FROM	GCS_CURR_TREATMENTS_B cb
      WHERE	cb.CURR_TREATMENT_ID = load_row.CURR_TREATMENT_ID;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
 update_row
 (
	 row_id=>row_id,
	 CURR_TREATMENT_ID=>CURR_TREATMENT_ID,
	 ENDING_RATE_TYPE=>ENDING_RATE_TYPE,
	 AVERAGE_RATE_TYPE=>AVERAGE_RATE_TYPE,
	 EQUITY_MODE_CODE=>EQUITY_MODE_CODE,
	 INC_STMT_MODE_CODE=>INC_STMT_MODE_CODE,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 DEFAULT_FLAG=>DEFAULT_FLAG,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 FINANCIAL_ELEM_ID=>FINANCIAL_ELEM_ID,
	 PRODUCT_ID=>PRODUCT_ID,
	 NATURAL_ACCOUNT_ID=>NATURAL_ACCOUNT_ID,
	 CHANNEL_ID=>CHANNEL_ID,
	 LINE_ITEM_ID=>LINE_ITEM_ID,
	 PROJECT_ID=>PROJECT_ID,
	 CUSTOMER_ID=>CUSTOMER_ID,
	 CTA_USER_DIM1_ID=>CTA_USER_DIM1_ID,
	 CTA_USER_DIM2_ID=>CTA_USER_DIM2_ID,
	 CTA_USER_DIM3_ID=>CTA_USER_DIM3_ID,
	 CTA_USER_DIM4_ID=>CTA_USER_DIM4_ID,
	 CTA_USER_DIM5_ID=>CTA_USER_DIM5_ID,
	 CTA_USER_DIM6_ID=>CTA_USER_DIM6_ID,
	 CTA_USER_DIM7_ID=>CTA_USER_DIM7_ID,
	 CTA_USER_DIM8_ID=>CTA_USER_DIM8_ID,
	 CTA_USER_DIM9_ID=>CTA_USER_DIM9_ID,
	 CTA_USER_DIM10_ID=>CTA_USER_DIM10_ID,
	 TASK_ID=>TASK_ID,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
         CURR_TREATMENT_NAME => CURR_TREATMENT_NAME,
	 DESCRIPTION=>DESCRIPTION
);
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
insert_row
(
	 row_id=>row_id,
	 CURR_TREATMENT_ID=>CURR_TREATMENT_ID,
	 ENDING_RATE_TYPE=>ENDING_RATE_TYPE,
	 AVERAGE_RATE_TYPE=>AVERAGE_RATE_TYPE,
	 EQUITY_MODE_CODE=>EQUITY_MODE_CODE,
	 INC_STMT_MODE_CODE=>INC_STMT_MODE_CODE,
	 ENABLED_FLAG=>ENABLED_FLAG,
	 DEFAULT_FLAG=>DEFAULT_FLAG,
	 LAST_UPDATE_DATE=>f_ludate,
	 LAST_UPDATED_BY=>f_luby,
	 CREATION_DATE=>f_ludate,
	 CREATED_BY=>f_luby,
	 LAST_UPDATE_LOGIN=>0,
	 FINANCIAL_ELEM_ID=>FINANCIAL_ELEM_ID,
	 PRODUCT_ID=>PRODUCT_ID,
	 NATURAL_ACCOUNT_ID=>NATURAL_ACCOUNT_ID,
	 CHANNEL_ID=>CHANNEL_ID,
	 LINE_ITEM_ID=>LINE_ITEM_ID,
	 PROJECT_ID=>PROJECT_ID,
	 CUSTOMER_ID=>CUSTOMER_ID,
	 CTA_USER_DIM1_ID=>CTA_USER_DIM1_ID,
	 CTA_USER_DIM2_ID=>CTA_USER_DIM2_ID,
	 CTA_USER_DIM3_ID=>CTA_USER_DIM3_ID,
	 CTA_USER_DIM4_ID=>CTA_USER_DIM4_ID,
	 CTA_USER_DIM5_ID=>CTA_USER_DIM5_ID,
	 CTA_USER_DIM6_ID=>CTA_USER_DIM6_ID,
	 CTA_USER_DIM7_ID=>CTA_USER_DIM7_ID,
	 CTA_USER_DIM8_ID=>CTA_USER_DIM8_ID,
	 CTA_USER_DIM9_ID=>CTA_USER_DIM9_ID,
	 CTA_USER_DIM10_ID=>CTA_USER_DIM10_ID,
	 TASK_ID=>TASK_ID,
	 OBJECT_VERSION_NUMBER=>OBJECT_VERSION_NUMBER,
	 CURR_TREATMENT_NAME=>CURR_TREATMENT_NAME,
	 DESCRIPTION=>DESCRIPTION
);




    END;

  END Load_Row;


 --****************************************

 PROCEDURE Translate_Row
 (
	 CURR_TREATMENT_ID                      NUMBER,
	 CURR_TREATMENT_NAME                    VARCHAR2,
	 LAST_UPDATE_DATE                       DATE,
	 LAST_UPDATED_BY                        NUMBER,
	 CREATION_DATE                          DATE,
	 CREATED_BY                             NUMBER,
	 LAST_UPDATE_LOGIN                      NUMBER,
	 DESCRIPTION                            VARCHAR2,
	 owner					VARCHAR2,
	 custom_mode varchar2
 ) IS
    f_luby	NUMBER; -- category owner in file
    f_ludate	DATE;	-- category update date in file
    db_luby	NUMBER; -- category owner in db
    db_ludate	DATE;	-- category update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	ctl.last_updated_by, ctl.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_CURR_TREATMENTS_TL ctl
      WHERE	ctl.CURR_TREATMENT_ID = translate_row.CURR_TREATMENT_ID
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE
	GCS_CURR_TREATMENTS_TL ctl
        SET
		LANGUAGE=userenv('LANG'),
		SOURCE_LANG= userenv('LANG'),
		CURR_TREATMENT_NAME=translate_row.CURR_TREATMENT_NAME,
		LAST_UPDATE_DATE=f_ludate,
		LAST_UPDATED_BY=f_luby,
		LAST_UPDATE_LOGIN=0,
		DESCRIPTION=translate_row.DESCRIPTION
        WHERE
	ctl.CURR_TREATMENT_ID = translate_row.CURR_TREATMENT_ID
        AND userenv('LANG') IN (ctl.language, ctl.source_lang);
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
     gcs_curr_treatments_tl tt
     (
  	 CURR_TREATMENT_ID,
  	 LANGUAGE   ,
  	 SOURCE_LANG ,
  	 CURR_TREATMENT_NAME   ,
  	 LAST_UPDATE_DATE,
  	 LAST_UPDATED_BY ,
  	 CREATION_DATE,
  	 CREATED_BY,
  	 LAST_UPDATE_LOGIN,
  	 DESCRIPTION
      )

      select /*+ parallel(v) parallel(t) use_nl(t) */
      v.*
      from
      ( SELECT /*+ no_merge ordered parellel(b) */
  	 B.CURR_TREATMENT_ID,
	 L.LANGUAGE_CODE  ,
	 B.SOURCE_LANG ,
	 B.CURR_TREATMENT_NAME   ,
	 B.LAST_UPDATE_DATE,
	 B.LAST_UPDATED_BY ,
	 B.CREATION_DATE,
	 B.CREATED_BY,
	 B.LAST_UPDATE_LOGIN,
	 B.DESCRIPTION


    from gcs_curr_treatments_tl B,
    FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    ) v, gcs_curr_treatments_tl t
      where T.CURR_TREATMENT_ID(+) = v.CURR_TREATMENT_ID
      and T.LANGUAGE(+) = v.LANGUAGE_CODE
      and t.CURR_TREATMENT_ID IS NULL;

  end ADD_LANGUAGE;




END GCS_CURR_TREATMENTS_PKG;

/
