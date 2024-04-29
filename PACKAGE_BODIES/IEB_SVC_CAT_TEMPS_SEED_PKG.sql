--------------------------------------------------------
--  DDL for Package Body IEB_SVC_CAT_TEMPS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEB_SVC_CAT_TEMPS_SEED_PKG" AS
/* $Header: IEBSCTPB.pls 120.3 2005/09/29 06:03:45 appldev ship $ */
     PROCEDURE insert_row(
          x_wbsc_id                          IN NUMBER
        , x_svcpln_svcpln_id                 IN NUMBER
        , x_created_by                       IN NUMBER
        , x_creation_date                    IN DATE
        , x_last_update_date                 IN DATE
        , x_last_updated_by                  IN NUMBER
        , x_last_update_login                IN NUMBER
        , x_media_type                       IN VARCHAR2
        , x_depth                            IN NUMBER
        , x_parent_id                        IN NUMBER
        , x_original_name                    IN VARCHAR2
        , x_active_y_n                       IN VARCHAR2
        , x_source_table_name                IN VARCHAR2
        , x_src_tbl_key_column               IN VARCHAR2
        , x_src_tbl_value_column             IN VARCHAR2
        , x_src_tbl_value_translation_fl     IN VARCHAR2
        , x_src_tbl_where_clause             IN VARCHAR2
        , x_MEDIA_TYPE_ID                    IN NUMBER
        , x_SERVICE_CATEGORY_NAME            IN VARCHAR2
        , x_DESCRIPTION                      IN VARCHAR2
        , x_MEDIA_CATEGORY_LABEL             IN VARCHAR2
     ) IS
        CURSOR l_insert IS
          SELECT 'X'
          FROM ieb_svc_cat_temps_b
          WHERE wbsc_id = x_wbsc_id;
     BEGIN
        INSERT INTO ieb_svc_cat_temps_b (
          wbsc_id
        , svcpln_svcpln_id
        , created_by
        , creation_date
        , last_update_date
        , last_updated_by
        , last_update_login
        , media_type
        , depth
        , parent_id
        , original_name
        , active_y_n
        , source_table_name
        , src_tbl_key_column
        , src_tbl_value_column
        , src_tbl_value_translation_flag
        , src_tbl_where_clause
        , media_type_id
        ) VALUES (
          x_wbsc_id
        , x_svcpln_svcpln_id
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_media_type,FND_API.G_MISS_CHAR,NULL,x_media_type)
        , DECODE(x_depth,FND_API.G_MISS_NUM,NULL,x_depth)
        , DECODE(x_parent_id,FND_API.G_MISS_NUM,NULL,x_parent_id)
        , DECODE(x_original_name,FND_API.G_MISS_CHAR,NULL,x_original_name)
        , DECODE(x_active_y_n,FND_API.G_MISS_CHAR,NULL,x_active_y_n)
        , DECODE(x_source_table_name,FND_API.G_MISS_CHAR,NULL,x_source_table_name)
        , DECODE(x_src_tbl_key_column,FND_API.G_MISS_CHAR,NULL,x_src_tbl_key_column)
        , DECODE(x_src_tbl_value_column,FND_API.G_MISS_CHAR,NULL,x_src_tbl_value_column)
        , DECODE(x_src_tbl_value_translation_fl,FND_API.G_MISS_CHAR,NULL,x_src_tbl_value_translation_fl)
        , DECODE(x_src_tbl_where_clause,FND_API.G_MISS_CHAR,NULL,x_src_tbl_where_clause)
        , x_MEDIA_TYPE_ID
        );

        INSERT INTO ieb_svc_cat_temps_tl (
          wbsc_id
        , created_by
        , creation_date
        , last_update_date
        , last_updated_by
        , last_update_login
        , SERVICE_CATEGORY_NAME
        , DESCRIPTION
        , MEDIA_CATEGORY_LABEL
        , language
        , source_lang
       ) select
            x_wbsc_id
          , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
          , DECODE(x_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_creation_date)
          , DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
          , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
          , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
          , DECODE(x_SERVICE_CATEGORY_NAME,FND_API.G_MISS_CHAR,NULL,x_SERVICE_CATEGORY_NAME)
          , DECODE(x_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,x_DESCRIPTION)
          , DECODE(x_MEDIA_CATEGORY_LABEL,FND_API.G_MISS_CHAR,NULL,x_MEDIA_CATEGORY_LABEL)
          , l.language_code
          , USERENV('LANG')
        from fnd_languages l
        WHERE l.installed_flag IN ('I', 'B')
        AND NOT EXISTS
         (SELECT NULL
         FROM ieb_svc_cat_temps_tl t
         WHERE t.wbsc_id = x_wbsc_id
         AND t.language = l.language_code);

     END insert_row;

     PROCEDURE update_row(
          x_wbsc_id                          IN NUMBER
        , x_svcpln_svcpln_id                 IN NUMBER
        , x_last_update_date                 IN DATE
        , x_last_updated_by                  IN NUMBER
        , x_last_update_login                IN NUMBER
        , x_media_type                       IN VARCHAR2
        , x_depth                            IN NUMBER
        , x_parent_id                        IN NUMBER
        , x_original_name                    IN VARCHAR2
        , x_active_y_n                       IN VARCHAR2
        , x_source_table_name                IN VARCHAR2
        , x_src_tbl_key_column               IN VARCHAR2
        , x_src_tbl_value_column             IN VARCHAR2
        , x_src_tbl_value_translation_fl     IN VARCHAR2
        , x_src_tbl_where_clause             IN VARCHAR2
        , x_media_type_id                    IN NUMBER
        , x_SERVICE_CATEGORY_NAME            IN VARCHAR2
        , x_DESCRIPTION                      IN VARCHAR2
        , x_MEDIA_CATEGORY_LABEL             IN VARCHAR2
     ) IS
     BEGIN
        UPDATE ieb_svc_cat_temps_b
        SET
         svcpln_svcpln_id=DECODE(x_svcpln_svcpln_id,FND_API.G_MISS_NUM,NULL,x_svcpln_svcpln_id)
        , last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , media_type=DECODE(x_media_type,FND_API.G_MISS_CHAR,NULL,x_media_type)
        , depth=DECODE(x_depth,FND_API.G_MISS_NUM,NULL,x_depth)
        , parent_id=DECODE(x_parent_id,FND_API.G_MISS_NUM,NULL,x_parent_id)
        , original_name=DECODE(x_original_name,FND_API.G_MISS_CHAR,NULL,x_original_name)
        , active_y_n=DECODE(x_active_y_n,FND_API.G_MISS_CHAR,NULL,x_active_y_n)
        , source_table_name=DECODE(x_source_table_name,FND_API.G_MISS_CHAR,NULL,x_source_table_name)
        , src_tbl_key_column=DECODE(x_src_tbl_key_column,FND_API.G_MISS_CHAR,NULL,x_src_tbl_key_column)
        , src_tbl_value_column=DECODE(x_src_tbl_value_column,FND_API.G_MISS_CHAR,NULL,x_src_tbl_value_column)
        , src_tbl_value_translation_flag=DECODE(x_src_tbl_value_translation_fl,FND_API.G_MISS_CHAR,NULL,x_src_tbl_value_translation_fl)
        , src_tbl_where_clause=DECODE(x_src_tbl_where_clause,FND_API.G_MISS_CHAR,NULL,x_src_tbl_where_clause)
        , media_type_id = x_media_type_id
        WHERE
          wbsc_id=x_wbsc_id;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;

        UPDATE ieb_svc_cat_temps_tl
        SET
          last_update_date=DECODE(x_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),x_last_update_date)
        , last_updated_by=DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , last_update_login=DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , SERVICE_CATEGORY_NAME = DECODE(x_SERVICE_CATEGORY_NAME,FND_API.G_MISS_CHAR,NULL,x_SERVICE_CATEGORY_NAME)
        , DESCRIPTION = DECODE(x_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,x_DESCRIPTION)
        , MEDIA_CATEGORY_LABEL = DECODE(x_MEDIA_CATEGORY_LABEL,FND_API.G_MISS_CHAR,NULL,x_MEDIA_CATEGORY_LABEL)
        , source_lang = USERENV('LANG')
         WHERE
            wbsc_id=x_wbsc_id
         AND USERENV('LANG') IN (language, source_lang);

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;

     END update_row;

     PROCEDURE load_row (
          p_wbsc_id IN NUMBER,
          p_svcpln_svcpln_id IN NUMBER,
          p_media_type IN VARCHAR2,
          p_depth IN NUMBER,
          p_parent_id IN NUMBER,
          p_original_name IN VARCHAR2,
          p_active_y_n IN VARCHAR2,
          p_source_table_name IN VARCHAR2,
          p_src_tbl_key_column IN VARCHAR2,
          p_src_tbl_value_column IN VARCHAR2,
          p_src_tbl_value_translation_fl IN VARCHAR2,
          p_src_tbl_where_clause IN VARCHAR2,
          p_media_type_id        IN NUMBER,
          p_SERVICE_CATEGORY_NAME IN VARCHAR2,
          p_DESCRIPTION IN VARCHAR2,
          p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
          p_OWNER IN VARCHAR2) is
    BEGIN
      DECLARE
        user_id  number := 0;
      BEGIN

	   user_id := fnd_load_util.owner_id(p_OWNER);

        update_row(p_wbsc_id, p_svcpln_svcpln_id, sysdate, user_id, 0, p_media_type,
                   p_depth, p_parent_id, p_original_name, p_active_y_n,
                   p_source_table_name, p_src_tbl_key_column, p_src_tbl_value_column,
                   p_src_tbl_value_translation_fl, p_src_tbl_where_clause,  p_media_type_id,
                   p_SERVICE_CATEGORY_NAME, p_DESCRIPTION, p_MEDIA_CATEGORY_LABEL);

      EXCEPTION
         when no_data_found then

        insert_row(p_wbsc_id, p_svcpln_svcpln_id, user_id, sysdate, sysdate, user_id, 0,
                   p_media_type,
                   p_depth, p_parent_id,  p_original_name, p_active_y_n,
                   p_source_table_name, p_src_tbl_key_column, p_src_tbl_value_column,
                   p_src_tbl_value_translation_fl, p_src_tbl_where_clause, p_media_type_id,
                   p_SERVICE_CATEGORY_NAME, p_DESCRIPTION, p_MEDIA_CATEGORY_LABEL);

      END;
    END load_row;

     PROCEDURE load_seed_row (
          p_wbsc_id IN NUMBER,
          p_svcpln_svcpln_id IN NUMBER,
          p_media_type IN VARCHAR2,
          p_depth IN NUMBER,
          p_parent_id IN NUMBER,
          p_original_name IN VARCHAR2,
          p_active_y_n IN VARCHAR2,
          p_source_table_name IN VARCHAR2,
          p_src_tbl_key_column IN VARCHAR2,
	     p_src_tbl_value_column IN VARCHAR2,
	     p_src_tbl_value_translation_fl IN VARCHAR2,
	     p_src_tbl_where_clause IN VARCHAR2,
	     p_media_type_id        IN NUMBER,
	     p_SERVICE_CATEGORY_NAME IN VARCHAR2,
	     p_DESCRIPTION IN VARCHAR2,
	     p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
	     p_OWNER IN VARCHAR2,
		p_UPLOAD_MODE IN VARCHAR2) is
	BEGIN
		if (p_UPLOAD_MODE = 'NLS') then
            ieb_svc_cat_temps_seed_pkg.TRANSLATE_ROW (
		                  p_WBSC_ID,
			             p_SERVICE_CATEGORY_NAME,
			             p_DESCRIPTION,
			             p_MEDIA_CATEGORY_LABEL,
			             p_OWNER);
	      else
             ieb_svc_cat_temps_seed_pkg.LOAD_ROW (
		             p_WBSC_ID,
		             p_SVCPLN_SVCPLN_ID,
		             p_MEDIA_TYPE,
			        p_DEPTH,
			        p_PARENT_ID,
			        p_ORIGINAL_NAME,
			        p_ACTIVE_Y_N,
			        p_SOURCE_TABLE_NAME,
			        p_SRC_TBL_KEY_COLUMN,
			        p_SRC_TBL_VALUE_COLUMN,
			        p_SRC_TBL_VALUE_TRANSLATION_FL,
			        p_SRC_TBL_WHERE_CLAUSE,
			        p_MEDIA_TYPE_ID,
			        p_SERVICE_CATEGORY_NAME,
			        p_DESCRIPTION,
			        p_MEDIA_CATEGORY_LABEL,
			        p_OWNER);
	      end if;
	END load_seed_row;

    PROCEDURE translate_row (
          p_wbsc_id IN NUMBER,
          p_SERVICE_CATEGORY_NAME IN VARCHAR2,
          p_DESCRIPTION IN VARCHAR2,
          p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
          p_OWNER IN VARCHAR2) is
    BEGIN
      DECLARE
        user_id  number := 0;
      BEGIN
        user_id := fnd_load_util.owner_id(p_OWNER);


       UPDATE ieb_svc_cat_temps_tl
        SET
          last_update_date=sysdate
        , last_updated_by=user_id
        , last_update_login=0
        , SERVICE_CATEGORY_NAME = DECODE(p_SERVICE_CATEGORY_NAME,FND_API.G_MISS_CHAR,
                                         NULL,p_SERVICE_CATEGORY_NAME)
        , DESCRIPTION = DECODE(p_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,p_DESCRIPTION)
        , MEDIA_CATEGORY_LABEL = DECODE(p_MEDIA_CATEGORY_LABEL,FND_API.G_MISS_CHAR,NULL,                                                    p_MEDIA_CATEGORY_LABEL)
        , source_lang = USERENV('LANG')
         WHERE
            wbsc_id=p_wbsc_id
         AND USERENV('LANG') IN (language, source_lang);

      END;

    END translate_row;

procedure ADD_LANGUAGE
is
begin
  delete from IEB_SVC_CAT_TEMPS_TL T
  where not exists
    (select NULL
    from IEB_SVC_CAT_TEMPS_B B
    where B.WBSC_ID = T.WBSC_ID
    );

  update IEB_SVC_CAT_TEMPS_TL T set (
      SERVICE_CATEGORY_NAME,
      DESCRIPTION
    ) = (select
      B.SERVICE_CATEGORY_NAME,
      B.DESCRIPTION
    from IEB_SVC_CAT_TEMPS_TL B
    where B.WBSC_ID = T.WBSC_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WBSC_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WBSC_ID,
      SUBT.LANGUAGE
    from IEB_SVC_CAT_TEMPS_TL SUBB, IEB_SVC_CAT_TEMPS_TL SUBT
    where SUBB.WBSC_ID = SUBT.WBSC_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SERVICE_CATEGORY_NAME <> SUBT.SERVICE_CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

    insert into IEB_SVC_CAT_TEMPS_TL (
      DESCRIPTION,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      SERVICE_CATEGORY_NAME,
      WBSC_ID,
      CREATED_BY,
      LANGUAGE,
      SOURCE_LANG
    ) select
      B.DESCRIPTION,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      B.SERVICE_CATEGORY_NAME,
      B.WBSC_ID,
      B.CREATED_BY,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    from IEB_SVC_CAT_TEMPS_TL B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from IEB_SVC_CAT_TEMPS_TL T
      where T.WBSC_ID = B.WBSC_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


 END ieb_svc_cat_temps_seed_pkg;

/
