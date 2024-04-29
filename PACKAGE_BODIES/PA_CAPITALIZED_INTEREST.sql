--------------------------------------------------------
--  DDL for Package Body PA_CAPITALIZED_INTEREST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CAPITALIZED_INTEREST" as
/* $Header: PAXCINTB.pls 120.1 2005/08/09 04:16:24 avajain noship $ */

 p_pa_debug_mode VARCHAR2(1)   := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

PROCEDURE cint_compile_schedule(errbuf IN OUT NOCOPY varchar2,
				retcode IN OUT NOCOPY varchar2,
				p_sch_rev_id IN varchar2)
IS
   CURSOR org_cursor(ver_id NUMBER, org_id NUMBER)
   IS
      SELECT organization_id_child, organization_id_parent
      FROM   per_org_structure_elements
      CONNECT BY PRIOR organization_id_child = organization_id_parent
              AND  org_structure_version_id = ver_id
      START WITH organization_id_parent = org_id
              AND  org_structure_version_id = ver_id;

   status			number;
   stage			number;

   -- Standard who columns
   l_last_updated_by            NUMBER(15);
   l_last_update_login          NUMBER(15);
   l_request_id                 NUMBER(15);
   l_program_application_id     NUMBER(15);
   l_program_id                 NUMBER(15);

   l_ind_rate_sch_id            NUMBER;
   l_ind_rate_sch_rev_id        NUMBER;
   l_org_struc_ver_id		NUMBER;
   l_start_org			NUMBER;

   l_debug_mode			VARCHAR2(30);
   l_module_name		VARCHAR2(100) := 'cint_compile_schedule';
 l_temp NUMBER;
  completion_status    BOOLEAN;
BEGIN

   status := 0;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_CAPITALIZED_INTEREST.cint_compile_schedule');
      pa_debug.set_process('PLSQL','LOG', P_PA_DEBUG_MODE);
   END IF;

   l_ind_rate_sch_rev_id := p_sch_rev_id;
   --
   -- Get the standard who information
   --
   l_last_updated_by            := FND_GLOBAL.USER_ID;
   l_last_update_login          := FND_GLOBAL.LOGIN_ID;
   l_request_id                 := FND_GLOBAL.CONC_REQUEST_ID;
   l_program_application_id     := FND_GLOBAL.PROG_APPL_ID;
   l_program_id                 := FND_GLOBAL.CONC_PROGRAM_ID;

   -- During the start of the compilation process, pa_ind_rate_sch_revisions.complied_flag
   -- is set to an intermediate value 'I' (IN-PROCESS). Once the compilation process is
   -- successfully completed, the flag is updated to 'Y'

   --
   -- Set the compilation time in the rate schedule revision
   --

   UPDATE pa_ind_rate_sch_revisions
   SET
	last_update_date = SYSDATE,
	last_updated_by = l_last_updated_by,
	last_update_login = l_last_update_login,
	request_id = l_request_id,
	program_application_id = l_program_application_id,
	program_id = l_program_id,
	program_update_date = SYSDATE,
	compiled_flag = 'I'
   WHERE
	ind_rate_sch_revision_id = l_ind_rate_sch_rev_id;

   COMMIT;

   -- Whenever user recompiles the schedule by making changes for the rate structure,
   -- the compilation process will blow off the de normalized records for the given
   -- schedule revision from the pa_cint_rate_multiplers table and create new records.

     delete pa_cint_rate_multipliers
      where ind_rate_sch_revision_id = l_ind_rate_sch_rev_id;

   -- When deleted the records from multipliers in the Burden Schedules form,
   -- the pa_ind_cost_multipliers.ready_to_compile_flag is marked with X but not
   -- actually deleted. So, deleting those marked with X during compilation process.

     delete pa_ind_cost_multipliers
      where ind_rate_sch_revision_id = l_ind_rate_sch_rev_id
	and ready_to_compile_flag = 'X';

   IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Deleted all the existing compiled multipliers. No. of rows deleted: '||to_char(SQL%ROWCOUNT);
           pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
   END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Set the compilation time and compiled_flag = I in the rate schedule revision';
           pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
   END IF;

   pa_cost_plus.get_hierarchy_from_revision(p_sch_rev_id       => l_ind_rate_sch_rev_id,
		                            x_org_struc_ver_id => l_org_struc_ver_id,
		                            x_start_org        => l_start_org,
				            x_status           => status,
		                            x_stage            => stage);

   IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Getting org_struct_ver_id and start_org_id : '||l_org_struc_ver_id||' and '||l_start_org;
         pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
   END IF;

   IF status <> 0 THEN
      stage := 50;
      RETURN;
   END IF;

   select ind_rate_sch_id
     into l_ind_rate_sch_id
     from pa_ind_rate_sch_revisions
    where ind_rate_sch_revision_id = l_ind_rate_sch_rev_id;

   --
   -- Compile rates for all organizations starting from the highest organization
   --

   --
   -- First compile for the start organization
   --

      cint_compile_org_rates(p_rate_sch_rev_id  => l_ind_rate_sch_rev_id,
                             p_ind_rate_sch_id  => l_ind_rate_sch_id,
			     p_current_org_id   => l_start_org,
			     p_org_id_parent    => l_start_org,
			     p_org_struc_ver_id => l_org_struc_ver_id,
			     p_start_org        => l_start_org,
			     status             => status,
			     stage              => stage);

   IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Compiled multipliers for the start organization';
         pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
   END IF;

   --
   --  Compile all the organizations under the start organization
   --

   FOR org_row IN org_cursor(l_org_struc_ver_id, l_start_org) LOOP

      cint_compile_org_rates(p_rate_sch_rev_id  => l_ind_rate_sch_rev_id,
                             p_ind_rate_sch_id  => l_ind_rate_sch_id,
                             p_current_org_id   => org_row.organization_id_child,
                             p_org_id_parent    => org_row.organization_id_parent,
                             p_org_struc_ver_id => l_org_struc_ver_id,
                             p_start_org        => l_start_org,
                             status             => status,
                             stage              => stage);

      IF status <> 0 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Error while compiling multipliers for the organization: '||org_row.organization_id_child;
             pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
         END IF;
         RETURN;
      END IF;

   END LOOP;

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Compiled multipliers for all the child orgnizations';
        pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
    END IF;
   --
   --  Set the compilation time in the rate schedule revision
   --

   UPDATE pa_ind_rate_sch_revisions
   SET
	compiled_flag    = 'Y',
	compiled_date    = SYSDATE
   WHERE
	ind_rate_sch_revision_id    = l_ind_rate_sch_rev_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Updated the compiled_flag to Y ';
        pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
   END IF;

   COMMIT;

   IF P_PA_DEBUG_MODE = 'Y' THEN
	 pa_debug.reset_err_stack;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error '||SQLERRM(SQLCODE);
          pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
          pa_debug.reset_curr_function;
      END IF;

	 ROLLBACK;
         UPDATE pa_ind_rate_sch_revisions
   	    SET compiled_flag = 'N'
	   WHERE ind_rate_sch_revision_id = l_ind_rate_sch_rev_id;
          COMMIT;
       completion_status := fnd_concurrent.set_completion_status('ERROR', SQLERRM);

END cint_compile_schedule;

procedure cint_compile_org_rates (p_rate_sch_rev_id	IN number,
                                  p_ind_rate_sch_id     IN NUMBER,
			 	  p_current_org_id	IN number,
			 	  p_org_id_parent	IN number,
			 	  p_org_struc_ver_id	IN number,
				  p_start_org  		IN number,
				  status		IN OUT NOCOPY number,
				  stage		        IN OUT NOCOPY number)
IS

   -- Standard who
   l_last_updated_by   		NUMBER(15);
   l_created_by   		NUMBER(15);
   l_last_update_login		NUMBER(15);
   l_request_id			NUMBER(15);
   l_program_application_id	NUMBER(15);
   l_program_id			NUMBER(15);
   l_module_name                VARCHAR2(100) := 'cint_compile_org_rates';

BEGIN

   status := 0;
   stage := 100;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_CAPITALIZED_INTEREST.cint_compile_org_rates');
      pa_debug.set_process('PLSQL','LOG', P_PA_DEBUG_MODE);
   END IF;

   --
   -- Get the standard who information
   --
   l_created_by      		:= FND_GLOBAL.USER_ID;
   l_last_updated_by 		:= FND_GLOBAL.USER_ID;
   l_last_update_login		:= FND_GLOBAL.LOGIN_ID;
   l_request_id			:= FND_GLOBAL.CONC_REQUEST_ID;
   l_program_application_id	:= FND_GLOBAL.PROG_APPL_ID;
   l_program_id			:= FND_GLOBAL.CONC_PROGRAM_ID;

   INSERT INTO pa_cint_rate_multipliers
		  (IND_RATE_SCH_REVISION_ID,
		   ORGANIZATION_ID,
		   IND_RATE_SCH_ID,
		   RATE_NAME,
		   MULTIPLIER,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_LOGIN,
		   REQUEST_ID,
		   PROGRAM_APPLICATION_ID,
		   PROGRAM_ID,
		   PROGRAM_UPDATE_DATE)
    SELECT p_rate_sch_rev_id,
           p_current_org_id,
	   p_ind_rate_sch_id,
    	   cm.ind_cost_code,
	   cm.multiplier,
	   SYSDATE,
     	   l_last_updated_by,
	   l_created_by,
	   SYSDATE,
	   l_last_update_login,
	   l_request_id,
	   l_program_application_id,
	   l_program_id,
	   SYSDATE
      from pa_ind_cost_multipliers cm
     where cm.ind_rate_sch_revision_id = p_rate_sch_rev_id
       and cm.organization_id = p_current_org_id
   UNION ALL
    SELECT p_rate_sch_rev_id,
           p_current_org_id,
	   p_ind_rate_sch_id,
    	   icm.rate_name,
	   icm.multiplier,
	   SYSDATE,
     	   l_last_updated_by,
	   l_created_by,
	   SYSDATE,
	   l_last_update_login,
	   l_request_id,
	   l_program_application_id,
	   l_program_id,
	   SYSDATE
      from pa_cint_rate_multipliers  icm
     where icm.ind_rate_sch_revision_id = p_rate_sch_rev_id
       and icm.organization_id = p_org_id_parent
       and icm.rate_name not in (select cm1.ind_cost_code
                                   from pa_ind_cost_multipliers cm1
                                  where cm1.ind_rate_sch_revision_id = p_rate_sch_rev_id
                                   and cm1.organization_id = p_current_org_id);

EXCEPTION
    WHEN OTHERS THEN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM(SQLCODE);
          pa_debug.write_file(l_module_name, pa_debug.g_err_stage, 3);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;

END cint_compile_org_rates;

END PA_CAPITALIZED_INTEREST;

/
