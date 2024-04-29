--------------------------------------------------------
--  DDL for Package IES_DEPLOYED_SCRIPTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_DEPLOYED_SCRIPTS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesvidss.pls 115.8 2002/12/09 21:13:38 appldev ship $ */

  PROCEDURE Insert_Deployed_Scripts
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_lang_id   IN  NUMBER                  ,
    p_panel_table_id    IN  NUMBER                  ,
    p_question_table_id IN  NUMBER                  ,
    p_dscript_name      IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    p_application_id    IN  NUMBER                  ,
    p_function_id       IN  NUMBER                  ,
    p_script_type       IN  VARCHAR2                ,
    p_description       IN  VARCHAR2                ,
    x_dscript_id        OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Deployed_Scripts
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_dscript_id        IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_dscript_lang_id   IN  NUMBER                  ,
    p_panel_table_id    IN  NUMBER                  ,
    p_question_table_id IN  NUMBER                  ,
    p_dscript_name      IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    p_application_id    IN  NUMBER                  ,
    p_function_id       IN  NUMBER                  ,
    p_script_type       IN  VARCHAR2                ,
    p_description       IN  VARCHAR2                ,
    x_dscript_id        OUT NOCOPY NUMBER
  );

  PROCEDURE Delete_Deployed_Scripts
    ( p_api_version       IN  NUMBER   := 1,
      p_init_msg_list	  IN  VARCHAR2 := 'DUMMY VAL',
      p_commit         	  IN  VARCHAR2 := 'DUMMY VAL',
      p_validation_level  IN  NUMBER   := 1,
      x_return_status	  OUT NOCOPY VARCHAR2,
      x_msg_count	  OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2,
      p_dscript_id        IN  NUMBER
   );

END;

 

/
