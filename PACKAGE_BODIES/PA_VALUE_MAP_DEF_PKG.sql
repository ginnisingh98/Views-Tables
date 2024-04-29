--------------------------------------------------------
--  DDL for Package Body PA_VALUE_MAP_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_VALUE_MAP_DEF_PKG" as
/* $Header: PAYMDEFB.pls 120.2 2005/08/23 04:29:55 sunkalya noship $ */

--
-- Procedure     : update_row
-- Purpose       : Update a row in PA_VALUE_MAP_DEFS.
--
--
PROCEDURE update_row
      ( p_value_map_def_id                 IN NUMBER                               ,
        p_record_version_number            IN NUMBER                               ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
  l_record_version_number NUMBER;
  l_msg_index_out NUMBER;
   -- added for Bug fix: 4537865
  l_new_msg_data	 VARCHAR2(2000);
   -- added for Bug fix: 4537865

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Increment the record version number by 1
  l_record_version_number :=  p_record_version_number +1;

  UPDATE pa_value_map_defs
    SET
		    record_version_number   = DECODE(p_record_version_number, NULL, record_version_number, l_record_version_number)                             ,
        creation_date           = sysdate                      ,
        created_by              = fnd_global.user_id           ,
        last_update_date        = sysdate                      ,
        last_updated_by         = fnd_global.user_id           ,
        last_update_login       = fnd_global.login_id
        WHERE value_map_def_id  = p_value_map_def_id
        AND   nvl(p_record_version_number, record_version_number) = record_version_number;

  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
	        	(p_encoded       => FND_API.G_TRUE,
		         p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
       	   --p_data           => x_msg_data,			* Commented for Bug Fix: 4537865
	     p_data	      => l_new_msg_data,		-- added for Bug fix: 4537865
	     p_msg_index_out  => l_msg_index_out );
	      -- added for Bug fix: 4537865
	      x_msg_data := l_new_msg_data;
	      -- added for Bug fix: 4537865
       END IF;

 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_VALUE_MAP_DEF_PKG',
                          p_procedure_name   => 'update_row');
 raise;

END update_row;


END PA_VALUE_MAP_DEF_PKG;

/
