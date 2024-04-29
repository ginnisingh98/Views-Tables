--------------------------------------------------------
--  DDL for Package IEU_WP_PARAM_DEFS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_PARAM_DEFS_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUWACPS.pls 120.1 2005/07/07 02:25:13 appldev ship $ */

 TYPE WP_PARAM_DEFS_rec_type IS RECORD (
                	PARAM_ID          NUMBER(15),
                        PARAM_NAME        VARCHAR2(128),
                        DATA_TYPE         VARCHAR2(64),
			PARAM_USER_LABEL  VARCHAR2(32),
			PARAM_DESCRIPTION VARCHAR2(500),
      			created_by NUMBER(15),
      			creation_date DATE,
      			last_updated_by NUMBER(15),
      			last_update_date DATE,
      			last_update_login NUMBER(15),
                	owner VARCHAR2(15) );

PROCEDURE Insert_Row (p_WP_PARAM_DEFS_rec IN WP_PARAM_DEFS_rec_type);
PROCEDURE Update_Row (p_WP_PARAM_DEFS_rec IN WP_PARAM_DEFS_rec_type);

PROCEDURE translate_row (
    			p_PARAM_ID IN NUMBER,
			p_param_user_label IN VARCHAR2,
			p_param_description IN VARCHAR2,
                  p_last_update_date IN VARCHAR2,
                	p_owner IN VARCHAR2);

PROCEDURE Load_Row (
                    p_PARAM_ID          IN NUMBER,
                    p_PARAM_NAME        IN VARCHAR2,
                    p_DATA_TYPE         IN VARCHAR2,
                    p_param_user_label  IN VARCHAR2,
                    p_param_description IN VARCHAR2,
                    p_last_update_date IN VARCHAR2,
                    p_owner             IN VARCHAR2);

procedure DELETE_ROW (
  r_PARAM_ID in NUMBER
);

procedure ADD_LANGUAGE;

PROCEDURE Load_seed_Row (
  p_upload_mode       IN VARCHAR2,
  p_PARAM_ID          IN NUMBER,
  p_PARAM_NAME        IN VARCHAR2,
  p_DATA_TYPE         IN VARCHAR2,
  p_param_user_label  IN VARCHAR2,
  p_param_description IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_owner             IN VARCHAR2);


END IEU_WP_PARAM_DEFS_SEED_PKG;
 

/
