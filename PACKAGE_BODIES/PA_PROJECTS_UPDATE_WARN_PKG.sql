--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_UPDATE_WARN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_UPDATE_WARN_PKG" as
/* $Header: PAYRPK3B.pls 120.2 2005/08/19 17:24:28 mwasowic noship $ */

--
-- Procedure     : Insert_row
-- Purpose       : Create Row in PA_PROJ_UPD_WARN_TEMP.
--
--
PROCEDURE insert_row
      ( p_project_name                    IN PA_PROJ_UPD_WARN_TEMP.project_name%TYPE,
	      p_warning			                    IN PA_PROJ_UPD_WARN_TEMP.warning%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          ,  --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            ,  --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
IS

   l_msg_index_out	     	 NUMBER;
   -- added for bug 4537865
   l_new_msg_data		VARCHAR2(2000);
   -- added for bug 4537865

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO PA_PROJ_UPD_WARN_TEMP
     (project_name                          ,
  	warning)
    VALUES
     (p_project_name			        ,
      p_warning);


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := FND_MSG_PUB.Count_Msg;
      x_msg_data      := substr(SQLERRM,1,240);

   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECTS_UPDATE_WARN_PKG',
                          p_procedure_name     => 'insert_row');

   IF x_msg_count = 1 THEN
      pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => x_msg_count,
               p_msg_data       => x_msg_data,
             --p_data           => x_msg_data,		* Commented for NOCOPY mandate changes bug fix: 4537865
	       p_data		=> l_new_msg_data,	-- added for Bug: 4537865
               p_msg_index_out  => l_msg_index_out );
	 -- added for Bug: 4537865
	 x_msg_data := l_new_msg_data;
	  -- added for Bug: 4537865
   END IF;
   RAISE;

END insert_row;


END PA_PROJECTS_UPDATE_WARN_PKG;

/
