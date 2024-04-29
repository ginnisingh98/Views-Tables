--------------------------------------------------------
--  DDL for Package Body IES_DEPLOYED_SCRIPTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_DEPLOYED_SCRIPTS_PVT" AS
/* $Header: iesvidsb.pls 115.7 2002/12/09 21:13:40 appldev ship $ */

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
    x_dscript_id        OUT NOCOPY NUMBER   )
  IS
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Deployed_Scripts_PVT;
    INSERT INTO ies_deployed_scripts ( dscript_id ,
                                       created_by      ,
                                       creation_date   ,
                                       dscript_lang_id ,
                                       panel_table_id    ,
                                       question_table_id ,
                                       dscript_name    ,
                                       active_status   ,
                                       application_id  ,
                                       function_id     ,
                                       script_type     ,
                                       description     ,
                                       dscript_file    ,
                                       schema_mapping  )
                      VALUES    ( ies_deployed_scripts_s.nextval ,
                                  p_created_by        ,
                                  sysdate             ,
                                  p_dscript_lang_id   ,
                                  p_panel_table_id    ,
                                  p_question_table_id ,
                                  p_dscript_name      ,
                                  p_active_status     ,
                                  p_application_id    ,
                                  p_function_id       ,
                                  p_script_type       ,
                                  p_description       ,
                                  empty_blob()        ,
                                  empty_blob()        )
     RETURNING dscript_id INTO x_dscript_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Deployed_Scripts_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Deployed_Scripts;

  PROCEDURE Update_Deployed_Scripts
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2                ,
    x_msg_count		OUT NOCOPY NUMBER	            ,
    x_msg_data		OUT NOCOPY VARCHAR2                ,
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
  ) IS
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Deployed_Scripts_PVT;
    UPDATE ies_deployed_scripts
                       SET last_updated_by   = p_last_updated_by   ,
                           last_update_date  = sysdate             ,
                           dscript_lang_id   = p_dscript_lang_id   ,
                           panel_table_id    = p_panel_table_id    ,
                           question_table_id = p_question_table_id ,
                           dscript_name      = p_dscript_name      ,
                           active_status     = p_active_status     ,
                           application_id    = p_application_id    ,
                           function_id       = p_function_id       ,
                           script_type       = p_script_type       ,
                           description       = p_description
                     WHERE dscript_id = p_dscript_id
            RETURNING dscript_id INTO x_dscript_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Update_Deployed_Scripts_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Update_Deployed_Scripts;

  PROCEDURE Delete_Deployed_Scripts
    ( p_api_version       IN  NUMBER   := 1,
      p_init_msg_list	  IN  VARCHAR2 := 'DUMMY VAL',
      p_commit         	  IN  VARCHAR2 := 'DUMMY VAL',
      p_validation_level  IN  NUMBER   := 1,
      x_return_status	  OUT NOCOPY VARCHAR2,
      x_msg_count	  OUT NOCOPY NUMBER,
      x_msg_data	  OUT NOCOPY VARCHAR2,
      p_dscript_id        IN  NUMBER
    ) IS
    BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	Delete_Deployed_Scripts_PVT;

	delete from ies_question_data where transaction_id in
	     (select transaction_id from ies_transactions where dscript_id = p_dscript_id);

	delete from ies_panel_data where transaction_id in
	   (select  transaction_id from ies_transactions where dscript_id = p_dscript_id);

	delete from ies_questions where panel_id in
	   (select panel_id  from ies_panels where dscript_id = p_dscript_id);

	delete from ies_answers where lookup_id in
	   (select lookup_id from ies_lookups where dscript_id = p_dscript_id);

	delete from ies_transactions where dscript_id = p_dscript_id;

	delete from ies_lookups where dscript_id = p_dscript_id;

	delete from ies_panels where dscript_id = p_dscript_id;

	delete from ies_deployed_scripts where dscript_id = p_dscript_id;

	x_return_status := 'S';

    EXCEPTION
	    WHEN OTHERS THEN
		 ROLLBACK TO Delete_Deployed_Scripts_PVT;
			   x_return_status := 'E';
			   x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
    END Delete_Deployed_Scripts;


END IES_Deployed_Scripts_PVT;

/
