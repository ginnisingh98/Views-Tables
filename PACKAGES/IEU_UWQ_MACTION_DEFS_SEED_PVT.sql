--------------------------------------------------------
--  DDL for Package IEU_UWQ_MACTION_DEFS_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MACTION_DEFS_SEED_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUMACTS.pls 115.1 2000/02/29 15:55:11 pkm ship      $ */

TYPE uwq_maction_defs_rec_type IS RECORD (
                	maction_def_id NUMBER(15),
                	action_proc VARCHAR2(200),
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
                	p_application_short_name IN VARCHAR2,
			p_action_user_label IN VARCHAR2,
                	p_action_description IN VARCHAR2,
                	p_owner IN VARCHAR2);

PROCEDURE translate_row (
    			p_maction_def_id IN NUMBER,
			p_action_user_label IN VARCHAR2,
                	p_action_description IN VARCHAR2,
                	p_owner IN VARCHAR2);

procedure ADD_LANGUAGE;

END IEU_UWQ_MACTION_DEFS_SEED_PVT;

 

/
