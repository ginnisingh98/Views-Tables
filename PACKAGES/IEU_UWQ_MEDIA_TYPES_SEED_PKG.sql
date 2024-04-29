--------------------------------------------------------
--  DDL for Package IEU_UWQ_MEDIA_TYPES_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MEDIA_TYPES_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUSEEDS.pls 120.1 2005/06/23 02:39:20 appldev ship $ */

TYPE uwq_media_types_rec_type IS RECORD (
                        media_type_id NUMBER(15),
                        media_type_uuid VARCHAR2(38),
                    simple_blending_order NUMBER,
                    tel_reqd_flag VARCHAR2(1),
                    svr_login_rule_id NUMBER,
                    application_id NUMBER,
                                sh_category_type VARCHAR2(30),
                                image_file_name VARCHAR2(80),
                                classification_query_proc VARCHAR2(60),
                    blended_flag VARCHAR2(1),
                    blended_dir VARCHAR2(1),
                        media_type_name VARCHAR2(1996),
                        media_type_description VARCHAR2(1996),
                     created_by NUMBER(15),
                     creation_date DATE,
                     last_updated_by NUMBER(15),
                     last_update_date DATE,
                     last_update_login NUMBER(15),
                        owner VARCHAR2(15) );

PROCEDURE Insert_Row (p_uwq_media_types_rec IN uwq_media_types_rec_type);
PROCEDURE Update_Row (p_uwq_media_types_rec IN uwq_media_types_rec_type);

PROCEDURE Load_Row (
                        p_media_type_id IN NUMBER,
                        p_media_type_uuid IN VARCHAR2,
                    p_simple_blending_order IN NUMBER,
                    p_tel_reqd_flag IN VARCHAR2,
                    p_svr_login_rule_id IN NUMBER,
                    p_application_id IN NUMBER,
                                p_sh_category_type IN VARCHAR2,
                                p_image_file_name IN VARCHAR2,
                                p_classification_query_proc IN VARCHAR2,
                    p_blended_flag IN VARCHAR2,
                    p_blended_dir IN VARCHAR2,
                             p_media_type_name IN VARCHAR2,
                        p_media_type_description IN VARCHAR2,
                        p_owner IN VARCHAR2);

PROCEDURE translate_row (
                        p_media_type_id IN NUMBER,
                        p_media_type_name IN VARCHAR2,
                        p_media_type_description IN VARCHAR2,
                        p_owner IN VARCHAR2);

PROCEDURE ADD_LANGUAGE;

procedure LOCK_ROW (
X_MEDIA_TYPE_ID in NUMBER,
X_MEDIA_TYPE_UUID in VARCHAR2,
X_LANGUAGE in VARCHAR2,
X_CREATED_BY in NUMBER,
X_CREATION_DATE in DATE,
X_LAST_UPDATED_BY in NUMBER,
X_LAST_UPDATE_DATE in DATE,
X_MEDIA_TYPE_NAME in VARCHAR2,
X_SOURCE_LANG in VARCHAR2,
X_MEDIA_TYPE_DESCRIPTION in VARCHAR2,
X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure DELETE_ROW (
X_MEDIA_TYPE_ID in NUMBER
);

PROCEDURE Load_Seed_Row (
  p_upload_mode IN VARCHAR2,
  p_media_type_id IN NUMBER,
  p_media_type_uuid IN VARCHAR2,
  p_simple_blending_order IN NUMBER,
  p_tel_reqd_flag IN VARCHAR2,
  p_svr_login_rule_id IN NUMBER,
  p_application_id IN NUMBER,
  p_sh_category_type IN VARCHAR2,
  p_image_file_name IN VARCHAR2,
  p_classification_query_proc IN VARCHAR2,
  p_blended_flag IN VARCHAR2,
  p_blended_dir IN VARCHAR2,
  p_media_type_name IN VARCHAR2,
  p_media_type_description IN VARCHAR2,
  p_owner IN VARCHAR2
);


END IEU_UWQ_MEDIA_TYPES_SEED_PKG;

 

/
