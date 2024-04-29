--------------------------------------------------------
--  DDL for Package IEU_WP_PARAM_PROPS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_PARAM_PROPS_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUWPROS.pls 120.2 2005/08/04 23:18:13 appldev ship $ */

 TYPE wp_param_props_rec_type IS RECORD (
                    PARAM_PROPERTY_ID NUMBER(15),
                    ACTION_PARAM_SET_ID     NUMBER,
                    PARAM_ID          NUMBER,
                    PROPERTY_ID       NUMBER,
                    PROPERTY_VALUE    VARCHAR(4000),
                    PROPERTY_VALUE_TL VARCHAR(4000),
                    VALUE_OVERRIDE_FLAG   VARCHAR2(5),
                    created_by NUMBER(15),
                    creation_date DATE,
                    last_updated_by NUMBER(15),
                    last_update_date DATE,
                    last_update_login NUMBER(15),
                    not_valid_flag     VARCHAR(4000),
                    owner VARCHAR2(15) );

PROCEDURE Insert_Row (p_wp_param_props_rec IN wp_param_props_rec_type);
PROCEDURE Update_Row (p_wp_param_props_rec IN wp_param_props_rec_type);

PROCEDURE translate_row (
                p_PARAM_PROPERTY_ID IN NUMBER,
                p_PROPERTY_VALUE_TL IN VARCHAR2,
                p_last_update_date IN VARCHAR2,
                p_owner IN VARCHAR2);
PROCEDURE Load_Row (
                p_PARAM_PROPERTY_ID IN NUMBER,
                p_ACTION_PARAM_SET_ID IN NUMBER,
                p_PARAM_ID IN NUMBER,
                p_PROPERTY_ID IN NUMBER,
                p_PROPERTY_VALUE IN VARCHAR2,
                p_VALUE_OVERRIDE_FLAG IN VARCHAR2,
                p_PROPERTY_VALUE_TL IN VARCHAR2,
                p_NOT_VALID_FLAG    IN VARCHAR2,
                p_last_update_date IN VARCHAR2,
                p_owner IN VARCHAR2);

procedure DELETE_ROW (
  X_PARAM_PROPERTY_ID in NUMBER
);

procedure ADD_LANGUAGE;

PROCEDURE Load_seed_Row (
  p_upload_mode IN VARCHAR2,
  p_PARAM_PROPERTY_ID IN NUMBER,
  p_ACTION_PARAM_SET_ID IN NUMBER,
  p_PARAM_ID IN NUMBER,
  p_PROPERTY_ID IN NUMBER,
  p_PROPERTY_VALUE IN VARCHAR2,
  p_VALUE_OVERRIDE_FLAG IN VARCHAR2,
  p_PROPERTY_VALUE_TL IN VARCHAR2,
  p_NOT_VALID_FLAG    IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_owner IN VARCHAR2);

END IEU_WP_PARAM_PROPS_SEED_PKG;
 

/
