--------------------------------------------------------
--  DDL for Package IEU_WP_ACT_PARAM_SETS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_ACT_PARAM_SETS_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUWAPSS.pls 120.1 2005/07/07 03:18:04 appldev ship $ */

 TYPE WP_ACT_PARAM_SETS_rec_type IS RECORD (
              ACTION_PARAM_SET_ID          NUMBER(15),
              WP_ACTION_DEF_ID  NUMBER(15),
              ACTION_PARAM_SET_LABEL  VARCHAR2(128),
              ACTION_PARAM_SET_DESC VARCHAR2(500),
              created_by NUMBER(15),
              creation_date DATE,
              last_updated_by NUMBER(15),
              last_update_date DATE,
              last_update_login NUMBER(15),
              owner VARCHAR2(15) );

PROCEDURE Insert_Row (p_WP_ACT_PARAM_SETS_rec IN WP_ACT_PARAM_SETS_rec_type);
PROCEDURE Update_Row (p_WP_ACT_PARAM_SETS_rec IN WP_ACT_PARAM_SETS_rec_type);

PROCEDURE translate_row (
              p_ACTION_PARAM_SET_ID IN NUMBER,
              p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
              p_action_param_set_desc IN VARCHAR2,
              p_last_update_date iN VARCHAR2,
              p_owner IN VARCHAR2);

PROCEDURE Load_Row (
              p_ACTION_PARAM_SET_ID          IN NUMBER,
              p_WP_ACTION_DEF_ID  IN NUMBER,
              /* p_WP_ACTION_KEY        IN VARCHAR2,*/
              p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
              p_action_param_set_desc  IN VARCHAR2,
              p_last_update_date iN VARCHAR2,
              p_owner             IN VARCHAR2);

procedure DELETE_ROW (
  X_ACTION_PARAM_SET_ID in NUMBER
);

procedure ADD_LANGUAGE;

PROCEDURE Load_Seed_Row (
  P_UPLOAD_MODE IN VARCHAR2,
  p_ACTION_PARAM_SET_ID          IN NUMBER,
  p_WP_ACTION_DEF_ID  IN NUMBER,
  /* p_WP_ACTION_KEY        IN VARCHAR2,*/
  p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
  p_action_param_set_desc  IN VARCHAR2,
  p_last_update_date iN VARCHAR2,
  p_owner             IN VARCHAR2);

END IEU_WP_ACT_PARAM_SETS_SEED_PKG;
 

/
