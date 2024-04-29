--------------------------------------------------------
--  DDL for Package IEB_SVC_CAT_TEMPS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEB_SVC_CAT_TEMPS_SEED_PKG" AUTHID CURRENT_USER AS
 /* $Header: IEBSCTPS.pls 120.1 2005/09/16 00:00:51 appldev ship $ */
     PROCEDURE insert_row(
          x_wbsc_id                          NUMBER
        , x_svcpln_svcpln_id                 NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_login                NUMBER
        , x_media_type                       VARCHAR2
        , x_depth                            NUMBER
        , x_parent_id                        NUMBER
        , x_original_name                    VARCHAR2
        , x_active_y_n                       VARCHAR2
        , x_source_table_name                VARCHAR2
        , x_src_tbl_key_column               VARCHAR2
        , x_src_tbl_value_column             VARCHAR2
        , x_src_tbl_value_translation_fl     VARCHAR2
        , x_src_tbl_where_clause             VARCHAR2
        , x_MEDIA_TYPE_ID                    NUMBER
        , x_SERVICE_CATEGORY_NAME            VARCHAR2
        , x_DESCRIPTION                      VARCHAR2
        , x_MEDIA_CATEGORY_LABEL             VARCHAR2
     );


     PROCEDURE update_row(
          x_wbsc_id                          NUMBER
        , x_svcpln_svcpln_id                 NUMBER
        , x_last_update_date                 DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_login                NUMBER
        , x_media_type                       VARCHAR2
        , x_depth                            NUMBER
        , x_parent_id                        NUMBER
        , x_original_name                    VARCHAR2
        , x_active_y_n                       VARCHAR2
        , x_source_table_name                VARCHAR2
        , x_src_tbl_key_column               VARCHAR2
        , x_src_tbl_value_column             VARCHAR2
        , x_src_tbl_value_translation_fl     VARCHAR2
        , x_src_tbl_where_clause             VARCHAR2
        , x_MEDIA_TYPE_ID                    NUMBER
        , x_SERVICE_CATEGORY_NAME            VARCHAR2
        , x_DESCRIPTION                      VARCHAR2
        , x_MEDIA_CATEGORY_LABEL             VARCHAR2
     );

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
          p_MEDIA_TYPE_ID IN NUMBER,
          p_SERVICE_CATEGORY_NAME IN VARCHAR2,
          p_DESCRIPTION IN VARCHAR2,
          p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
          p_OWNER IN VARCHAR2);

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
          p_MEDIA_TYPE_ID IN NUMBER,
          p_SERVICE_CATEGORY_NAME IN VARCHAR2,
          p_DESCRIPTION IN VARCHAR2,
          p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
          p_OWNER IN VARCHAR2,
		p_UPLOAD_MODE IN VARCHAR2);

    PROCEDURE translate_row (
          p_wbsc_id IN NUMBER,
          p_SERVICE_CATEGORY_NAME IN VARCHAR2,
          p_DESCRIPTION IN VARCHAR2,
          p_MEDIA_CATEGORY_LABEL IN VARCHAR2,
          p_OWNER IN VARCHAR2);

   PROCEDURE ADD_LANGUAGE;


END ieb_svc_cat_temps_seed_pkg;

 

/
