--------------------------------------------------------
--  DDL for Package Body PA_WORK_TYPE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORK_TYPE_UTILS" AS
/* $Header: PARWUTLB.pls 120.2 2005/11/03 04:00:51 sunkalya noship $ */

-- ----------------------------------------------------------------------------
--  PROCEDURE
--              Check_Work_Type_Name_or_ID
--  PURPOSE
--              This procedure does the following
--              If work type name is passed converts it to the id
--              If id is passed, based on the check_id_flag validates it
--  HISTORY
--   19-Jul-2000      nchouhan  Created
-- ----------------------------------------------------------------------------
procedure Check_Work_Type_Name_or_ID
      ( p_work_type_id       IN  pa_work_types_v.work_type_id%TYPE
       ,p_name               IN  pa_work_types_v.name%TYPE
       ,p_check_id_flag      IN  VARCHAR2
       ,x_work_type_id       OUT NOCOPY pa_work_types_v.work_type_id%TYPE
       ,x_return_status      OUT NOCOPY VARCHAR2
       ,x_error_message_code OUT NOCOPY VARCHAR2)
IS
BEGIN
   -- Set the error stack
   pa_debug.set_err_stack('PA_WORK_TYPE_UTILS.Check_Work_Type_Name_or_ID');

   IF p_work_type_id IS NOT NULL THEN
       -- Validate ID based on the check id flag
       IF p_check_id_flag = 'Y' THEN
           SELECT work_type_id
           INTO   x_work_type_id
           FROM   pa_work_types_b --pa_work_types_v changed pa_work_types_v to pa_work_types_b for performance issues. Refer Bug:4668829
           WHERE  work_type_id = p_work_type_id
             AND TRUNC(SYSDATE) BETWEEN start_date_active
                                    AND NVL(end_date_active,TRUNC(SYSDATE));
        ELSE
            x_work_type_id := p_work_type_id;
        END IF;
   ELSE
        -- Validate Name
        SELECT work_type_id
        INTO   x_work_type_id
        FROM   pa_work_types_v
        WHERE  name = p_name
          AND TRUNC(SYSDATE) BETWEEN start_date_active
                                 AND NVL(end_date_active,TRUNC(SYSDATE));
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   pa_debug.reset_err_stack; -- Reset error stack

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_WORK_TYPE_INVALID_AMBIGOUS';
       x_work_type_id := Null;
       pa_debug.reset_err_stack; -- Reset error stack

   WHEN TOO_MANY_ROWS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_WORK_TYPE_INVALID_AMBIGOUS';
       x_work_type_id := Null;
       pa_debug.reset_err_stack; -- Reset error stack

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_error_message_code := Null;
       x_work_type_id := Null;
       Raise;

END Check_Work_Type_Name_or_ID;

-- ----------------------------------------------------------------------------
--  PROCEDURE
--              Check_Work_Type
--  PURPOSE
--              This procedure does the following
--               It checks the work_type :
--               If Project is Indirect project then
--               only non-billable work-types can be assigned to it.
--               If Project is not Indirect project then
--               all work types are O.K.
--
--  HISTORY
--   28-Nov-2000      nmishra  Created
--
-- ----------------------------------------------------------------------------
--
procedure Check_Work_Type
      ( p_work_type_id       IN  pa_work_types_v.work_type_id%TYPE
       ,p_project_id         IN  pa_projects.project_id%TYPE
       ,p_task_id            IN  pa_tasks.task_id%TYPE
       ,x_return_status      OUT NOCOPY VARCHAR2
       ,x_error_message_code OUT NOCOPY VARCHAR2)
IS
BEGIN
 DECLARE
 l_proj_typ_class_code 	pa_project_types.project_type_class_code%TYPE;
 l_project_id  pa_projects.project_id%TYPE;
 l_project_type pa_project_types.project_type%TYPE;
 l_flag	 varchar2(1);
 CURSOR Get_Project_type_class_cur IS
 SELECT p.project_type_class_code
 FROM pa_project_types p
 WHERE p.project_type = l_project_type;
 CURSOR Get_Project_type IS
 SELECT a.project_type
 FROM pa_projects a
 WHERE a.project_id = l_project_id;
 CURSOR Get_Project_id IS
 SELECT t.project_id
 FROM pa_tasks t
 WHERE t.task_id = p_task_id;
 CURSOR work_type_cur IS
 SELECT  w.BILLABLE_CAPITALIZABLE_FLAG
 FROM pa_work_types_b w  -- changed pa_work_types_v to pa_work_types_b for performance issue. Refer Bug: 4668829
 WHERE w.work_type_id = p_work_type_id;

 l_proj_type_rec  Get_Project_type_class_cur%ROWTYPE;
 l_proj_rec Get_Project_type%ROWTYPE;
 l_proj_task_rec  Get_Project_id%ROWTYPE;
 l_work_type_rec work_type_cur%ROWTYPE;
 BEGIN
   -- Set the error stack
--   pa_debug.set_err_stack('PA_WORK_TYPE_UTILS.Check_Work_Type_Name_or_ID');
   IF p_work_type_id IS NOT NULL THEN
   IF (p_project_id IS NOT NULL AND p_task_id IS NULL)
	  OR (p_project_id IS NOT NULL  AND p_task_id IS NOT NULL)  THEN
		l_project_id := p_project_id;
		OPEN Get_Project_type;
		LOOP
		FETCH Get_Project_type INTO l_proj_rec	;
		IF Get_Project_type%NOTFOUND THEN
   		  EXIT;
   		ELSE
		 l_project_type := l_proj_rec.project_type;
		 OPEN Get_Project_type_class_cur;
		 LOOP
		 FETCH Get_Project_type_class_cur INTO l_proj_type_rec;
		  IF Get_Project_type_class_cur%NOTFOUND THEN
		  EXIT;
		  ELSE
		   l_proj_typ_class_code:= l_proj_type_rec.project_type_class_code;
		  END IF;
		  END LOOP;
		  CLOSE Get_Project_type_class_cur;
		END IF;
		END LOOP;
		CLOSE Get_Project_type;
   ELSIF (p_project_id IS NULL AND p_task_id IS NOT NULL) THEN
		OPEN Get_Project_id;
		LOOP
		FETCH Get_Project_id INTO l_proj_task_rec;
		IF Get_Project_id%NOTFOUND THEN
   		  EXIT;
   		ELSE
			l_project_id := l_proj_task_rec.project_id;
			OPEN Get_Project_type;
			LOOP
			FETCH Get_Project_type INTO l_proj_rec;
			IF Get_Project_type%NOTFOUND THEN
   			  EXIT;
   			ELSE
				l_project_type:= l_proj_rec.project_type;
				OPEN Get_Project_type_class_cur;
				LOOP
				FETCH Get_Project_type_class_cur INTO l_proj_type_rec;
				IF Get_Project_type_class_cur%NOTFOUND THEN
					EXIT;
				ELSE
				l_proj_typ_class_code:= l_proj_type_rec.project_type_class_code;
				END IF;
				END LOOP;
				CLOSE Get_Project_type_class_cur;
			END IF;
		END LOOP;
		CLOSE Get_Project_type;
		END IF;
		END LOOP;
		CLOSE Get_Project_id;
	END IF;
	OPEN work_type_cur;
	LOOP
	FETCH work_type_cur INTO l_work_type_rec;
	IF work_type_cur%NOTFOUND THEN
		EXIT;
	ELSE
		l_flag := l_work_type_rec.BILLABLE_CAPITALIZABLE_FLAG;
	END IF;
	END LOOP;
	CLOSE work_type_cur;

IF  l_proj_typ_class_code = 'INDIRECT'
    THEN
         IF l_flag = 'Y' THEN
         	x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_WORK_TYPE_INVALID';
         END IF;
END IF;
ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_error_message_code := 'PA_WORK_TYPE_INVALID';
END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   pa_debug.reset_err_stack; -- Reset error stack


EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_WORK_TYPE_INVALID';
       pa_debug.reset_err_stack; -- Reset error stack

   WHEN TOO_MANY_ROWS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_WORK_TYPE_INVALID';
       pa_debug.reset_err_stack; -- Reset error stack

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_error_message_code := Null;
       Raise;
END;
END Check_Work_Type;
END PA_WORK_TYPE_UTILS ;

/
