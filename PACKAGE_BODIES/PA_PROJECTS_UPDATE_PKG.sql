--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_UPDATE_PKG" as
/* $Header: PAYRPK2B.pls 120.2 2005/08/19 17:24:19 mwasowic noship $ */

--
-- Procedure     : Insert_row
-- Purpose       : Create Row in PA_PROJECTS_UPDATE_TEMP.
--
--
PROCEDURE insert_row
      ( p_project_name                    IN pa_projects_update_temp.project_name%TYPE,
	      p_project_number		              IN pa_projects_update_temp.project_number%TYPE,
        p_project_status_name             IN pa_projects_update_temp.project_status_name%TYPE,
        p_old_probability                 IN pa_projects_update_temp.old_probability%TYPE,
        p_new_probability		              IN pa_projects_update_temp.new_probability%TYPE,
        p_old_value                       IN pa_projects_update_temp.old_value%TYPE,
        p_new_value			                  IN pa_projects_update_temp.new_value%TYPE,
        p_old_value_currency              IN pa_projects_update_temp.old_value_currency%TYPE,
        p_new_value_currency              IN pa_projects_update_temp.new_value_currency%TYPE,
        p_old_exp_proj_apprvl_date        IN pa_projects_update_temp.old_expected_proj_apprvl_date%TYPE,
        p_new_exp_proj_apprvl_date        IN pa_projects_update_temp.new_expected_proj_apprvl_date%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          ,  --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            ,  --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
IS

   l_msg_index_out	     	 NUMBER;
   -- added for bug 4537865
   l_new_msg_data 		VARCHAR2(2000);
   -- added for bug 4537865

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO pa_projects_update_temp
     (project_name                        ,
  	project_number                        ,
  	project_status_name                   ,
  	old_probability                       ,
  	new_probability				                ,
  	old_value                             ,
  	new_value					                    ,
    old_value_currency                    ,
  	new_value_currency                    ,
  	old_expected_proj_apprvl_date         ,
  	new_expected_proj_apprvl_date)
    VALUES
     (p_project_name			                ,
      p_project_number                    ,
      p_project_status_name               ,
      p_old_probability                   ,
      p_new_probability     		          ,
      p_old_value            					    ,
      p_new_value					                ,
      p_old_value_currency    					  ,
      p_new_value_currency    					  ,
	    p_old_exp_proj_apprvl_date	        ,
	    p_new_exp_proj_apprvl_date);


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := FND_MSG_PUB.Count_Msg;
      x_msg_data      := substr(SQLERRM,1,240);

   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECTS_UPDATE_PKG',
                          p_procedure_name     => 'insert_row');

   IF x_msg_count = 1 THEN
      pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => x_msg_count,
               p_msg_data       => x_msg_data,
             --p_data           => x_msg_data, * Commmented for NOCOPY mandate changes Bug Fix: 4537865
               p_data		=> l_new_msg_data, 	-- added for bug 4537865
               p_msg_index_out  => l_msg_index_out );

	     -- added for bug 4537865
             x_msg_data := l_new_msg_data;
	     -- added for bug 4537865
   END IF;
   RAISE;

END insert_row;


END PA_PROJECTS_UPDATE_PKG;

/
