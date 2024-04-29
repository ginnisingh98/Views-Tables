--------------------------------------------------------
--  DDL for Package Body GCS_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CATEGORIES_PKG" AS
/* $Header: gcscategoryb.pls 120.3 2006/06/29 15:05:56 hakumar noship $ */



  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY		    VARCHAR2,
												category_code               VARCHAR2,
                        category_number             NUMBER,
												net_to_re_flag			        VARCHAR2,
												target_entity_code		      VARCHAR2,
												category_type_code		      VARCHAR2,
												associated_object_id		    NUMBER,
												org_output_code			        VARCHAR2,
												support_multi_parents_flag	VARCHAR2,
												enabled_flag			          VARCHAR2,
												specific_intercompany_id	  NUMBER,
												category_name			          VARCHAR2,
												description			            VARCHAR2,
												creation_date			          DATE,
												created_by			            NUMBER,
												last_update_date		        DATE,
												last_updated_by			        NUMBER,
												last_update_login		        NUMBER,
                        object_version_number       NUMBER) IS
    CURSOR catg_row IS
    SELECT rowid
    FROM	 gcs_categories_b cb
    WHERE	 cb.category_code= insert_row.category_code;

  BEGIN
    IF category_code IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_categories_b
        (category_code,
        category_number,
        net_to_re_flag,
        target_entity_code,
        category_type_code,
        associated_object_id,
        org_output_code,
        support_multi_parents_flag,
        enabled_flag,
        specific_intercompany_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        object_version_number)
    SELECT
	      insert_row.category_code,
        insert_row.category_number,
        insert_row.net_to_re_flag,
        insert_row.target_entity_code,
        insert_row.category_type_code,
        insert_row.associated_object_id,
        insert_row.org_output_code,
        insert_row.support_multi_parents_flag,
        insert_row.enabled_flag,
        insert_row.specific_intercompany_id,
        insert_row.creation_date,
        insert_row.created_by,
        insert_row.last_update_date,
        insert_row.last_updated_by,
        insert_row.last_update_login,
        insert_row.object_version_number
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_categories_b cb
		 WHERE	cb.category_code= insert_row.category_code);

  -- Bugfix 5158937  : Inserted rows for the other installed languages on the env.
    INSERT INTO gcs_categories_tl(
        category_code,
        language,
        source_lang,
        category_name,
        description,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by)
    -- Bugfix 5353211 : Qualify API variables with the API name, so that the values passed to the API are utilized
    SELECT
        insert_row.category_code,
        L.language_code,
        userenv('LANG'),
        insert_row.category_name,
        insert_row.description,
        insert_row.last_update_date,
        insert_row.last_updated_by,
        insert_row.last_update_login,
        insert_row.creation_date,
        insert_row.created_by
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND   NOT EXISTS
          (SELECT NULL
           FROM  gcs_categories_tl ctl
           WHERE ctl.category_code = insert_row.category_code
            AND  ctl.LANGUAGE = L.LANGUAGE_CODE);

    OPEN catg_row;
    FETCH catg_row INTO row_id;
    IF catg_row%NOTFOUND THEN
      CLOSE catg_row;
      raise no_data_found;
    END IF;
    CLOSE catg_row;

  END Insert_Row;

  PROCEDURE Update_Row(		row_id	IN OUT NOCOPY		   VARCHAR2,
                          category_code			         VARCHAR2,
                        	category_number            NUMBER,
                   				net_to_re_flag			       VARCHAR2,
                      		target_entity_code		     VARCHAR2,
                      		category_type_code		     VARCHAR2,
                          associated_object_id		   NUMBER,
                  				org_output_code			       VARCHAR2,
                  				support_multi_parents_flag VARCHAR2,
                  				enabled_flag			         VARCHAR2,
                   				specific_intercompany_id	 NUMBER,
                   				category_name			         VARCHAR2,
                   				description			           VARCHAR2,
                  				creation_date			         DATE,
                   				created_by			           NUMBER,
                  				last_update_date		       DATE,
                  				last_updated_by			       NUMBER,
                  				last_update_login		       NUMBER,
                        	object_version_number      NUMBER) IS
  BEGIN
      UPDATE	gcs_categories_b cb
      SET		category_number			= update_row.category_number,
          	net_to_re_flag			= update_row.net_to_re_flag,
      	    target_entity_code		= update_row.target_entity_code,
      	    category_type_code		= update_row.category_type_code,
  	      	associated_object_id		= update_row.associated_object_id,
          	org_output_code			= update_row.org_output_code,
          	support_multi_parents_flag	= update_row.support_multi_parents_flag,
          	enabled_flag			= update_row.enabled_flag,
          	specific_intercompany_id	= update_row.specific_intercompany_id,
          	last_update_date		= update_row.last_update_date,
          	last_updated_by			= update_row.last_updated_by,
        		last_update_login		= update_row.last_update_login,
      			object_version_number		= update_row.object_version_number
      WHERE	cb.category_code 		= update_row.category_code;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

    -- Bugfix 5158937  : Inserted rows for the other installed languages on the env.
      INSERT INTO gcs_categories_tl(
           category_code,
           language,
           source_lang,
           category_name,
           description,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by)
    -- Bugfix 5353211 : Qualify API variables with the API name, so that the values passed to the API are utilized
    SELECT
           update_row.category_code,
           L.language_code,
           userenv('LANG'),
           update_row.category_name,
           update_row.description,
           update_row.last_update_date,
           update_row.last_updated_by,
           update_row.last_update_login,
           update_row.creation_date,
           update_row.created_by
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND   NOT EXISTS
          (SELECT NULL
           FROM  gcs_categories_tl ctl
           WHERE ctl.category_code = update_row.category_code
            AND  ctl.LANGUAGE = L.LANGUAGE_CODE);


      UPDATE	gcs_categories_tl ctl
      SET		category_name		= update_row.category_name,
  			    description		= update_row.description,
  			    last_update_date	= update_row.last_update_date,
  			    last_updated_by		= update_row.last_updated_by,
  			    last_update_login	= update_row.last_update_login
      WHERE	ctl.category_code 	= update_row.category_code
      AND		ctl.language 		= userenv('LANG');

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;
  END Update_Row;



  PROCEDURE Load_Row(	  category_code			          VARCHAR2,
												owner				                VARCHAR2,
												last_update_date		        VARCHAR2,
												custom_mode			            VARCHAR2,
												category_number			        NUMBER,
												net_to_re_flag			        VARCHAR2,
												target_entity_code		      VARCHAR2,
												category_type_code		      VARCHAR2,
												associated_object_id		    NUMBER,
												org_output_code			        VARCHAR2,
												support_multi_parents_flag	VARCHAR2,
												enabled_flag			          VARCHAR2,
												specific_intercompany_id	  NUMBER,
												category_name			          VARCHAR2,
												description			            VARCHAR2,
                	      object_version_number       NUMBER) IS

    row_id	VARCHAR2(64);
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
      FROM	GCS_CATEGORIES_B cb
      WHERE	cb.category_code = load_row.category_code;

      -- Test for customization information
      IF fnd_load_util.upload_test( f_luby, f_ludate, db_luby, db_ludate,
                                    custom_mode) THEN

                                    update_row(		row_id				=> row_id,
																		category_code			          => load_row.CATEGORY_CODE,
																		category_number			        => load_row.CATEGORY_NUMBER,
																		net_to_re_flag			        => load_row.NET_TO_RE_FLAG,
																		target_entity_code		      => load_row.TARGET_ENTITY_CODE,
																		category_type_code		      => load_row.CATEGORY_TYPE_CODE,
																		associated_object_id		    => load_row.ASSOCIATED_OBJECT_ID,
																		org_output_code			        => load_row.ORG_OUTPUT_CODE,
																		support_multi_parents_flag	=> load_row.SUPPORT_MULTI_PARENTS_FLAG,
																		enabled_flag			          => load_row.ENABLED_FLAG,
																		specific_intercompany_id	  => load_row.SPECIFIC_INTERCOMPANY_ID,
																		category_name			          => load_row.CATEGORY_NAME,
																		description			            => load_row.DESCRIPTION,
																		creation_date			          => f_ludate,
																		created_by			            => f_luby,
																		last_update_date		        => f_ludate,
																		last_updated_by			        => f_luby,
																		last_update_login		        => 0,
                        	          object_version_number   	  => load_row.OBJECT_VERSION_NUMBER);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(	row_id				              => row_id,
            				category_code			          => load_row.CATEGORY_CODE,
						       	category_number         	  => load_row.CATEGORY_NUMBER,
										net_to_re_flag			        => load_row.NET_TO_RE_FLAG,
										target_entity_code		      => load_row.TARGET_ENTITY_CODE,
										category_type_code      	  => load_row.CATEGORY_TYPE_CODE,
										associated_object_id		    => load_row.ASSOCIATED_OBJECT_ID,
										org_output_code			        => load_row.ORG_OUTPUT_CODE,
										support_multi_parents_flag	=> load_row.SUPPORT_MULTI_PARENTS_FLAG,
										enabled_flag			          => load_row.ENABLED_FLAG,
										specific_intercompany_id	  => load_row.SPECIFIC_INTERCOMPANY_ID,
										category_name			          => load_row.CATEGORY_NAME,
										description			            => load_row.DESCRIPTION,
										creation_date		 	          => f_ludate,
										created_by			            => f_luby,
										last_update_date		        => f_ludate,
										last_updated_by			        => f_luby,
										last_update_login		        => 0,
										object_version_number		    => load_row.OBJECT_VERSION_NUMBER);
    END;

  END Load_Row;


  PROCEDURE Translate_Row(	category_code			VARCHAR2,
														owner				      VARCHAR2,
														last_update_date	VARCHAR2,
														custom_mode			  VARCHAR2,
														category_name			VARCHAR2,
														description			  VARCHAR2) IS

    f_luby		NUMBER; -- category owner in file
    f_ludate		DATE;	-- category update date in file
    db_luby		NUMBER; -- category owner in db
    db_ludate		DATE;	-- category update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	ctl.last_updated_by, ctl.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_CATEGORIES_TL ctl
      WHERE	ctl.category_code = translate_row.category_code
      AND	ctl.language = userenv('LANG');

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE	gcs_categories_tl ctl
        SET	    category_name		= translate_row.category_name,
								description		= translate_row.description,
								source_lang		= userenv('LANG'),
			    			last_update_date	= f_ludate,
					    	last_updated_by		= f_luby,
								last_update_login	= 0
        WHERE	ctl.category_code = translate_row.category_code
        AND		userenv('LANG') IN (ctl.language, ctl.source_lang);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;




PROCEDURE ADD_LANGUAGE
IS
BEGIN
   INSERT /*+ append parallel(tt) */ INTO
   GCS_CATEGORIES_TL tt
   (
		CATEGORY_CODE     ,
		CATEGORY_NAME     ,
		DESCRIPTION       ,
		CREATION_DATE     ,
		CREATED_BY        ,
		LAST_UPDATED_BY   ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATE_LOGIN ,
		LANGUAGE          ,
		SOURCE_LANG
 )

    SELECT /*+ parallel(v) parallel(t) use_nl(t) */
    v.*
    FROM
        ( SELECT /*+ no_merge ordered parellel(b) */
						B.CATEGORY_CODE     ,
						B.CATEGORY_NAME     ,
						B.DESCRIPTION       ,
						B.CREATION_DATE     ,
						B.CREATED_BY        ,
						B.LAST_UPDATED_BY   ,
						B.LAST_UPDATE_DATE  ,
						B.LAST_UPDATE_LOGIN ,
						L.LANGUAGE_CODE     ,
						B.SOURCE_LANG

				  FROM GCS_CATEGORIES_TL B,
				       FND_LANGUAGES L
				  WHERE L.INSTALLED_FLAG in ('I', 'B')
				  AND B.LANGUAGE = userenv('LANG')
				  ) v,
		   GCS_CATEGORIES_TL T
 WHERE T.CATEGORY_CODE(+) = v.CATEGORY_CODE
 AND T.LANGUAGE(+) = v.LANGUAGE_CODE
 AND T.CATEGORY_CODE IS NULL;

END ADD_LANGUAGE;



BEGIN

  SELECT  		category_code,
  	      		category_number,
  	      		net_to_re_flag,
  	      		target_entity_code,
          		support_multi_parents_flag
  BULK COLLECT INTO 	g_oper_category_info
  FROM	      gcs_categories_b
  WHERE	      target_entity_code	=	'CHILD'
  --Bugfix : 4209435
  AND			    enabled_flag		=	'Y'
  AND			    category_type_code	IN	('CONSOLIDATION_RULE', 'ELIMINATION_RULE')
  ORDER BY    category_number;

  SELECT   		category_code,
  	      		category_number,
  	      		net_to_re_flag,
  	      		target_entity_code,
         			support_multi_parents_flag
  BULK COLLECT INTO 	g_cons_category_info
  FROM	      gcs_categories_b
  WHERE	      target_entity_code	IN 	('ELIMINATION', 'PARENT')
  --Bugfix : 4209435
  AND			    enabled_flag		=	'Y'
  AND		      category_type_code	IN	('CONSOLIDATION_RULE', 'ELIMINATION_RULE')
  ORDER BY    category_number;

END GCS_CATEGORIES_PKG;

/
