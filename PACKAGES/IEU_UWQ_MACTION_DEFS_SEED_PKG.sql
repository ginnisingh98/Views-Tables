--------------------------------------------------------
--  DDL for Package IEU_UWQ_MACTION_DEFS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MACTION_DEFS_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUMACTS.pls 120.1 2005/07/07 02:18:00 appldev ship $ */

 TYPE uwq_maction_defs_rec_type IS RECORD (
                	maction_def_id NUMBER(15),
                	action_proc VARCHAR2(200),
			ACTION_PROC_TYPE_CODE  VARCHAR2(1),
			MACTION_DEF_TYPE_FLAG      VARCHAR2(1),
                        GLOBAL_FORM_PARAMS         VARCHAR2(500),
                        MULTI_SELECT_FLAG          VARCHAR2(1),
                        MACTION_DEF_KEY            VARCHAR2(32),
                	application_id NUMBER(15),
			action_user_label VARCHAR2(1996),
                	action_description VARCHAR2(1996),
      			created_by NUMBER(15),
      			creation_date DATE,
      			last_updated_by NUMBER(15),
      			last_update_date DATE,
      			last_update_login NUMBER(15),
                	owner VARCHAR2(15) );

PROCEDURE Insert_Row (p_uwq_maction_defs_rec IN uwq_maction_defs_rec_type);
PROCEDURE Update_Row (p_uwq_maction_defs_rec IN uwq_maction_defs_rec_type);
PROCEDURE Load_Row (
                	p_maction_def_id IN NUMBER,
                	p_action_proc IN VARCHAR2,
                  p_ACTION_PROC_TYPE_CODE IN VARCHAR2,
			p_MACTION_DEF_TYPE_FLAG  IN VARCHAR2,
	            p_GLOBAL_FORM_PARAMS IN VARCHAR2,
	            p_MULTI_SELECT_FLAG IN VARCHAR2,
	            p_MACTION_DEF_KEY IN VARCHAR2,
                  p_last_update_date IN VARCHAR2,
                	p_application_short_name IN VARCHAR2,
			p_action_user_label IN VARCHAR2,
                	p_action_description IN VARCHAR2,
                	p_owner IN VARCHAR2);

PROCEDURE translate_row (
    			p_maction_def_id IN NUMBER,
			p_action_user_label IN VARCHAR2,
                	p_action_description IN VARCHAR2,
                  p_last_update_date IN VARCHAR2,
                	p_owner IN VARCHAR2);

procedure ADD_LANGUAGE;
procedure LOCK_ROW (
  X_MACTION_DEF_ID in NUMBER,
  X_ACTION_PROC in VARCHAR2,
  X_ACTION_PROC_TYPE_CODE in VARCHAR2,
  X_MACTION_DEF_TYPE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_GLOBAL_FORM_PARAMS in VARCHAR2,
  X_ACTION_USER_LABEL in VARCHAR2,
  X_ACTION_DESCRIPTION in VARCHAR2
) ;
procedure DELETE_ROW (
  X_MACTION_DEF_ID in NUMBER
);

PROCEDURE Load_Seed_Row (
  p_upload_mode IN VARCHAR2,
  p_maction_def_id IN NUMBER,
  p_action_proc IN VARCHAR2,
  p_ACTION_PROC_TYPE_CODE IN VARCHAR2,
  p_MACTION_DEF_TYPE_FLAG  IN VARCHAR2,
  p_GLOBAL_FORM_PARAMS IN VARCHAR2,
  p_MULTI_SELECT_FLAG IN VARCHAR2,
  p_MACTION_DEF_KEY IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_application_short_name IN VARCHAR2,
  p_action_user_label IN VARCHAR2,
  p_action_description IN VARCHAR2,
  p_owner IN VARCHAR2);


END IEU_UWQ_MACTION_DEFS_SEED_PKG;
 

/
