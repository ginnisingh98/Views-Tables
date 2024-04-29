--------------------------------------------------------
--  DDL for Package PA_WORK_TYPE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORK_TYPE_UTILS" AUTHID CURRENT_USER as
/* $Header: PARWUTLS.pls 120.1 2005/08/11 10:06:02 eyefimov noship $ */

-- ----------------------------------------------------------------------------
--  PROCEDURE
--              Check_Work_Type_Name_or_ID
--  PURPOSE
--              This procedure does the following
--              If work type name is passed converts it to the id
--              If id is passed, based on the check_id_flag validates it
--  HISTORY
--   19-Jul-2000      nchouhan  Created
--   21-Sep-2000      nchouhan  Created
-- ----------------------------------------------------------------------------

procedure Check_Work_Type_Name_or_ID
      ( p_work_type_id       IN  pa_work_types_v.work_type_id%TYPE
       ,p_name               IN  pa_work_types_v.name%TYPE
       ,p_check_id_flag      IN  VARCHAR2
       ,x_work_type_id       OUT NOCOPY pa_work_types_v.work_type_id%TYPE
       ,x_return_status      OUT NOCOPY VARCHAR2
       ,x_error_message_code OUT NOCOPY VARCHAR2);

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

procedure Check_Work_Type
      ( p_work_type_id       IN  pa_work_types_v.work_type_id%TYPE
       ,p_project_id         IN  pa_projects.project_id%TYPE
       ,p_task_id            IN  pa_tasks.task_id%TYPE
       ,x_return_status      OUT NOCOPY VARCHAR2
       ,x_error_message_code OUT NOCOPY VARCHAR2);


end PA_WORK_TYPE_UTILS ;
 

/
