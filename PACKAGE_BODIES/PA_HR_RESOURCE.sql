--------------------------------------------------------
--  DDL for Package Body PA_HR_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_RESOURCE" AS
/* $Header: PAHRRESB.pls 120.1 2005/08/19 16:33:51 mwasowic noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist  OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
     reference_exists  exception;
     dummy1            varchar2(1);
     r_id pa_resource_txn_attributes.resource_id%type; /* Added for Bug#2738741 */
     l_ret_stat varchar2(1); /* these variables are added for bug#2738741 */
     msg_cnt number;
     msg_data varchar2(2000);
     forecastitem_err exception;

     cursor resource_txn( p_person_id number ) is
                select  resource_id    /* Bug 2738741 - Changed from null to resource_id */
                from    PA_RESOURCE_TXN_ATTRIBUTES         pa
                where   pa.person_id                    = P_PERSON_ID;

/* Bug#2738741 - Added this new cursor resource_list_ref for checking in pa_resource_list_members
which stores the members of a resource list */

     CURSOR resource_list_ref(p_resource_id number) IS
     SELECT 'x' FROM pa_resource_list_members
     WHERE resource_id = p_resource_id;

-- Bug 4116995 - check if person used in RBS
     CURSOR rbs_person_ref(p_person_id number) IS
     SELECT 'x' FROM pa_rbs_elements
     WHERE person_id = p_person_id;

  BEGIN

        -- Bug 4116995 - First check if person used in RBS
        Error_Message := 'PA_HR_PER_RBS_REF';
        OPEN rbs_person_ref(p_person_id);
        FETCH rbs_person_ref INTO dummy1;
        IF rbs_person_ref%found THEN
           CLOSE rbs_person_ref;
           raise reference_exists;
        END IF;
        CLOSE rbs_person_ref;


/* Bug#2738741 - Modified the code here to check in cursor pa_resource_list_members
and raise error if records in the cursor. If not delete records from pa_resources_denorm,
pa_resource_txn_attributes, pa_resources */

      Error_Message := 'PA_HR_PER_RES_TXN_ATTR';
      OPEN resource_txn(p_person_id);
      FETCH resource_txn INTO r_id; /* Bug#2738741 - Commenting dummy1 */
      IF resource_txn%found THEN
         OPEN resource_list_ref(r_id);
         FETCH resource_list_ref INTO dummy1;
         IF resource_list_ref%found THEN
           CLOSE resource_txn;
           CLOSE resource_list_ref;
           raise reference_exists;
         END IF;
        CLOSE resource_list_ref;

       /* Bug#2738741 - Delete from resource tables and denorm table as no reference */

      /* Bug#2738741 - Added code to check if prm is installed, if so delete from pa_resources_denorm
          and called delete API for forecast items */

      -- Bug 4092769 - Remove PJR license check.
      -- IF (pa_install.is_prm_licensed = 'Y') THEN

       PA_FORECASTITEM_PVT.Delete_FI(p_resource_id => r_id,
                       x_return_status => l_ret_stat,
                       x_msg_count => msg_cnt,
                       x_msg_data => msg_data);
       IF (l_ret_stat <> FND_API.G_RET_STS_SUCCESS) THEN
             Raise Forecastitem_err;
       END IF;

       DELETE FROM pa_resources_denorm WHERE resource_id = r_id;
      -- END IF;

       DELETE FROM pa_resource_txn_attributes where resource_id = r_id;

       DELETE FROM pa_resources WHERE resource_id = r_id;

     END IF;

     CLOSE resource_txn;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN forecastitem_err THEN
         raise;
        WHEN others  THEN
          raise;
  END check_person_reference;

  PROCEDURE check_job_reference    (p_job_id          IN number,
                                    Error_Message    OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist  OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor resource_txn( p_job_id    number ) is
                select  null
                from    PA_RESOURCE_TXN_ATTRIBUTES         pa
                where   pa.job_id                    = P_JOB_ID;

     cursor resource_map( p_job_id    number ) is
                select  null
                from    PA_RESOURCE_MAPS         pa
                where   pa.job_id                    = P_JOB_ID;

    cursor chk_plan_res_rbs(p_job_id IN NUMBER) IS
    SELECT 'Y'
    FROM   dual
    WHERE  exists (select 'Y' from pa_resource_list_members
                   where job_id = p_job_id
                   UNION
                   select 'Y' from pa_rbs_elements
                   where job_id = p_job_id);

  BEGIN
       /* Bug no.2432494: error message below was changed from PA_HR_JOB_RSRC_TRN_ATTR
           to PA_HR_JOB_RSRC_TXN_ATTR */
      Error_Message := 'PA_HR_JOB_RSRC_TXN_ATTR';
      OPEN resource_txn(p_job_id);
      FETCH resource_txn INTO dummy1;
      IF resource_txn%found THEN
         CLOSE resource_txn;
         raise reference_exists;
      END IF;
      CLOSE resource_txn;

      Error_Message := 'PA_HR_JOB_RES_MAP_DET';
      OPEN resource_map(p_job_id);
      FETCH resource_map INTO dummy1;
      IF resource_map%found THEN
         CLOSE resource_map;
         raise reference_exists;
      END IF;

      Error_Message := 'PA_HR_JOB_RES_FDN_EXISTS';
      OPEN chk_plan_res_rbs(p_job_id);
      FETCH chk_plan_res_rbs INTO dummy1;
      IF chk_plan_res_rbs%found THEN
         CLOSE chk_plan_res_rbs;
         raise reference_exists;
      END IF;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_job_reference;

--
END pa_hr_resource;

/
