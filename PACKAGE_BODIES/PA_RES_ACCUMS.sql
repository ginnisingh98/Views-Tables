--------------------------------------------------------
--  DDL for Package Body PA_RES_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_ACCUMS" AS
/* $Header: PARESACB.pls 120.3.12010000.2 2008/10/14 09:06:17 sugupta ship $ */

 P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */


   -- Initialize function

   FUNCTION initialize RETURN NUMBER IS
      x_err_code NUMBER:=0;
   BEGIN

     RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RETURN x_err_code;
   END initialize;



   PROCEDURE get_resource_map
           (x_resource_list_id             IN NUMBER,
            x_resource_list_assignment_id  IN NUMBER,
            x_person_id                    IN NUMBER,
            x_job_id                       IN NUMBER,
            x_organization_id              IN NUMBER,
            x_vendor_id                    IN NUMBER,
            x_expenditure_type             IN VARCHAR2,
            x_event_type                   IN VARCHAR2,
            x_non_labor_resource           IN VARCHAR2,
            x_expenditure_category         IN VARCHAR2,
            x_revenue_category             IN VARCHAR2,
            x_non_labor_resource_org_id    IN NUMBER,
            x_event_type_classification    IN VARCHAR2,
            x_system_linkage_function      IN VARCHAR2,
            x_resource_list_member_id   IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_id               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_map_found        IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   BEGIN

     x_err_code := 0;
     x_err_stage := 'Getting the resource map';
     x_resource_map_found := TRUE;
     x_resource_list_member_id := NULL;
     x_resource_id := NULL;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     /* Seperating Map Check for Expenditures based/Event based Txns */

     IF (x_expenditure_type IS NOT NULL) THEN

        -- Process records differently based on the person_id is null/not null
        -- to take advantage of the index on person_id column

        IF ( x_person_id IS NOT NULL ) THEN
           -- person_id is not null
           SELECT
               resource_list_member_id,
               resource_id
           INTO
               x_resource_list_member_id,
               x_resource_id
           FROM
               pa_resource_maps prm
           WHERE
               prm.resource_list_assignment_id = x_resource_list_assignment_id
           AND prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id = x_person_id
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X');
        ELSE
           -- person_id is null
           SELECT
               resource_list_member_id,
               resource_id
           INTO
               x_resource_list_member_id,
               x_resource_id
           FROM
               pa_resource_maps prm
           WHERE
               prm.resource_list_assignment_id = x_resource_list_assignment_id
           AND prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id IS NULL
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X');
        END IF; -- IF ( x_person_id IS NOT NULL )
     ELSE
        /* Events */
        SELECT
            resource_list_member_id,
            resource_id
        INTO
            x_resource_list_member_id,
            x_resource_id
        FROM
            pa_resource_maps prm
        WHERE
            prm.resource_list_assignment_id = x_resource_list_assignment_id
        AND prm.resource_list_id  = x_resource_list_id
        AND prm.event_type        = x_event_type
        AND prm.organization_id   = x_organization_id
        AND prm.revenue_category  = x_revenue_category
        AND prm.event_type_classification = x_event_type_classification;

     END IF; --IF (x_expenditure_type IS NOT NULL)

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_resource_map_found := FALSE;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END get_resource_map;

   PROCEDURE get_resource_map_new
           (x_resource_list_id             IN NUMBER,
            x_person_id                    IN NUMBER,
            x_job_id                       IN NUMBER,
            x_organization_id              IN NUMBER,
            x_vendor_id                    IN NUMBER,
            x_expenditure_type             IN VARCHAR2,
            x_event_type                   IN VARCHAR2,
            x_non_labor_resource           IN VARCHAR2,
            x_expenditure_category         IN VARCHAR2,
            x_revenue_category             IN VARCHAR2,
            x_non_labor_resource_org_id    IN NUMBER,
            x_event_type_classification    IN VARCHAR2,
            x_system_linkage_function      IN VARCHAR2,
            x_resource_list_member_id   IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_id               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_map_found        IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   BEGIN

     x_err_code := 0;
     x_err_stage := 'Getting the resource map';
     x_resource_map_found := TRUE;
     x_resource_list_member_id := NULL;
     x_resource_id := NULL;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     /* Seperating Map Check for Expenditures based/Event based Txns */

     IF (x_expenditure_type IS NOT NULL) THEN

        -- Process records differently based on the person_id is null/not null
        -- to take advantage of the index on person_id column

        IF ( x_person_id IS NOT NULL ) THEN
           -- person_id is not null
           SELECT
               resource_list_member_id,
               resource_id
           INTO
               x_resource_list_member_id,
               x_resource_id
           FROM
               pa_resource_maps prm,
               pa_resource_list_assignments parla
           WHERE
               prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id = x_person_id
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X')
           AND prm.resource_list_assignment_id = parla.resource_list_assignment_id
           AND NVL(parla.resource_list_changed_flag,'N') <> 'Y'
           AND rownum < 2;
        ELSE
           -- person_id is null
           SELECT
               resource_list_member_id,
               resource_id
           INTO
               x_resource_list_member_id,
               x_resource_id
           FROM
               pa_resource_maps prm,
               pa_resource_list_assignments parla
           WHERE
               prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id IS NULL
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X')
           AND prm.resource_list_assignment_id = parla.resource_list_assignment_id
           AND NVL(parla.resource_list_changed_flag,'N') <> 'Y'
           AND rownum < 2;
        END IF; -- IF ( x_person_id IS NOT NULL )
     ELSE
        /* Events */
        SELECT
            resource_list_member_id,
            resource_id
        INTO
            x_resource_list_member_id,
            x_resource_id
        FROM
            pa_resource_maps prm,
            pa_resource_list_assignments parla
        WHERE
            prm.resource_list_id  = x_resource_list_id
        AND prm.event_type        = x_event_type
        AND prm.organization_id   = x_organization_id
        AND prm.revenue_category  = x_revenue_category
        AND prm.event_type_classification = x_event_type_classification
        AND prm.resource_list_assignment_id = parla.resource_list_assignment_id
        AND NVL(parla.resource_list_changed_flag,'N') <> 'Y'
        AND rownum < 2;

     END IF; --IF (x_expenditure_type IS NOT NULL)

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_resource_map_found := FALSE;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END get_resource_map_new;

   -- deleting the resource maps for the given resource list assignment id

   PROCEDURE delete_res_maps_on_asgn_id
           (x_resource_list_assignment_id  IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   tot_recs_processed    number(15):=0;
   BEGIN
/* Commented for bug# 1889671
     x_err_code  := 0;
     x_err_stage := 'Deleting the resource map for given resource list assignment id';


        pa_debug.debug('old_map_txns: ' || x_err_stage);

     Loop
     IF (x_resource_list_assignment_id is null) THEN
       DELETE
           pa_resource_maps where rownum <= pa_proj_accum_main.x_commit_size;
     ELSE
       DELETE
         pa_resource_maps prm
       WHERE
         prm.resource_list_assignment_id = x_resource_list_assignment_id
     and rownum <= pa_proj_accum_main.x_commit_size;
     END IF;
          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  Commit;
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  exit;
          else
                  commit;
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
          end if;
    End loop;


        pa_debug.debug('old_map_txns: ' || 'Numbers of Records Deleted = ' || TO_CHAR(tot_recs_processed));

  Completely commented for bug# 1889671 */
  Null;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_res_maps_on_asgn_id;

   -- deleting the resource maps for the given project_id and
   -- resource_list_id

   PROCEDURE delete_res_maps_on_prj_id
           (x_project_id                   IN NUMBER,
            x_resource_list_id             IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   tot_recs_processed    number(15):=0;
   BEGIN

/* Commented for bug# 1889671
     x_err_code  := 0;
     x_err_stage := 'Deleting the resource map for given project Id';


        pa_debug.debug('old_map_txns: ' || x_err_stage);

   LOOP

     DELETE
         pa_resource_maps prm
     WHERE
         prm.resource_list_assignment_id IN
         ( SELECT
                resource_list_assignment_id
           FROM
                pa_resource_list_assignments
           WHERE project_id = x_project_id
           AND   resource_list_id = NVL(x_resource_list_id,resource_list_id)
          )
     and rownum <= pa_proj_accum_main.x_commit_size;
          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  Commit;
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  exit;
          else
                  commit;
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
          end if;
    End loop;


        pa_debug.debug('old_map_txns: ' || 'Numbers of Records Deleted = ' || TO_CHAR(tot_recs_processed));

 Completely commented for bug# 1889671 */
   Null;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_res_maps_on_prj_id;

   -- the function given below creates a resource map

   PROCEDURE create_resource_map
           (x_resource_list_id            IN NUMBER,
            x_resource_list_assignment_id IN NUMBER,
            x_resource_list_member_id     IN NUMBER,
            x_resource_id                 IN NUMBER,
            x_person_id                   IN NUMBER,
            x_job_id                      IN NUMBER,
            x_organization_id             IN NUMBER,
            x_vendor_id                   IN NUMBER,
            x_expenditure_type            IN VARCHAR2,
            x_event_type                  IN VARCHAR2,
            x_non_labor_resource          IN VARCHAR2,
            x_expenditure_category        IN VARCHAR2,
            x_revenue_category            IN VARCHAR2,
            x_non_labor_resource_org_id   IN NUMBER,
            x_event_type_classification   IN VARCHAR2,
            x_system_linkage_function     IN VARCHAR2,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   BEGIN

     x_err_code  :=0;
     x_err_stage := 'Creating resource map';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     INSERT INTO pa_resource_maps
           (resource_list_id,
            resource_list_assignment_id,
            resource_list_member_id,
            resource_id,
            person_id,
            job_id,
            organization_id,
            vendor_id,
            expenditure_type,
            event_type,
            non_labor_resource,
            expenditure_category,
            revenue_category,
            non_labor_resource_org_id,
            event_type_classification,
            system_linkage_function,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id)
     VALUES
           (x_resource_list_id,
            x_resource_list_assignment_id,
            x_resource_list_member_id,
            x_resource_id,
            x_person_id,
            x_job_id,
            x_organization_id,
            x_vendor_id,
            x_expenditure_type,
            x_event_type,
            x_non_labor_resource,
            x_expenditure_category,
            x_revenue_category,
            x_non_labor_resource_org_id,
            x_event_type_classification,
            x_system_linkage_function,
            SYSDATE,
            x_created_by,
            x_last_updated_by,
            SYSDATE,
            x_last_update_login,
            x_request_id,
            x_program_application_id,
            x_program_id);

   EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END create_resource_map;

   -- change resource list assignment

   PROCEDURE change_resource_list_status
          (x_resource_list_assignment_id IN NUMBER,
           x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
           x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   BEGIN

     x_err_code := 0;
     x_err_stage := 'Updating resource list assignment status';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     UPDATE
          pa_resource_list_assignments
     SET
          resource_list_changed_flag ='N'
     WHERE
         resource_list_assignment_id = x_resource_list_assignment_id;

   EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END change_resource_list_status;

   FUNCTION get_resource_list_status
       (x_resource_list_assignment_id IN NUMBER)
       RETURN VARCHAR2
   IS
     x_resource_list_changed_flag   VARCHAR2(1);
   BEGIN

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || 'Getting Resource List Status');
     END IF;

     SELECT
          NVL(resource_list_changed_flag,'N')
     INTO
          x_resource_list_changed_flag
     FROM
          pa_resource_list_assignments
     WHERE
         resource_list_assignment_id = x_resource_list_assignment_id;

     RETURN x_resource_list_changed_flag;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
   END get_resource_list_status;

   -- Get the resource Rank


   -- If we donot find a rank for a given format and class code then
   -- no resource mapping will be done against that resource

   FUNCTION get_resource_rank
       (x_resource_format_id IN NUMBER,
        x_txn_class_code     IN VARCHAR2)
       RETURN NUMBER
   IS
     x_rank   NUMBER;
   BEGIN

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || 'Getting Resource Rank');
     END IF;

     SELECT
          rank
     INTO
          x_rank
     FROM
          pa_resource_format_ranks
     WHERE
         resource_format_id = x_resource_format_id
     AND txn_class_code = x_txn_class_code;

     RETURN x_rank;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;
     WHEN OTHERS THEN
       RETURN NULL;
   END get_resource_rank;

   -- This function returns the group resource_type_code for the given resoure list
   -- In case of 'None' Group Resource type, the table pa_resource_lists_all_bg
   -- will not join to the pa_resource_types table

   FUNCTION get_group_resource_type_code
       (x_resource_list_id IN NUMBER)
       RETURN VARCHAR2
   IS
     x_group_resource_type_code  VARCHAR2(20);
   BEGIN

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || 'Getting Resource Type Code');
     END IF;

     SELECT
          rt.resource_type_code
     INTO
          x_group_resource_type_code
     FROM
          pa_resource_types rt,
          pa_resource_lists_all_bg rl
     WHERE
         rl.resource_list_id = x_resource_list_id
         and nvl(rl.migration_code,'-99') <> 'N'
     AND rl.group_resource_type_id = rt.resource_type_id
     ;

     RETURN x_group_resource_type_code;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_group_resource_type_code := 'NONE';
       RETURN x_group_resource_type_code;
     WHEN OTHERS THEN
       RETURN NULL;
   END get_group_resource_type_code;

   -- This procedure created resource accum details
   -- We will not allow to have multiple PA_RESOURCE_ACCUM_DETAILS
   -- for the same TXN_ACCUM_ID and different resource_id and
   -- pa_resource_list_member_id

   PROCEDURE create_resource_accum_details
           (x_resource_list_id            IN NUMBER,
            x_resource_list_assignment_id IN NUMBER,
            x_resource_list_member_id     IN NUMBER,
            x_resource_id                 IN NUMBER,
            x_txn_accum_id                IN NUMBER,
            x_project_id                  IN NUMBER,
            x_task_id                     IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   BEGIN

     x_err_code  :=0;
     x_err_stage := 'Creating resource accum details';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     INSERT INTO pa_resource_accum_details
           (resource_list_id,
            resource_list_assignment_id,
            resource_list_member_id,
            resource_id,
            txn_accum_id,
            project_id,
            task_id,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id)
     SELECT
            x_resource_list_id,
            x_resource_list_assignment_id,
            x_resource_list_member_id,
            x_resource_id,
            x_txn_accum_id,
            x_project_id,
            x_task_id,
            SYSDATE,
            x_created_by,
            x_last_updated_by,
            SYSDATE,
            x_last_update_login,
            x_request_id,
            x_program_application_id,
            x_program_id
    FROM
            sys.dual
    WHERE NOT EXISTS
          (SELECT
                 'Yes'
           FROM
                 pa_resource_accum_details rad
           WHERE
                 resource_list_id = x_resource_list_id
           AND   resource_list_assignment_id = x_resource_list_assignment_id
/*
           AND   resource_list_member_id = x_resource_list_member_id
           AND   resource_id = x_resource_id
*/
           AND   txn_accum_id = x_txn_accum_id
           AND   project_id = x_project_id
           AND   task_id = x_task_id
           );

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END create_resource_accum_details;

   -- This procedure deleted resource accum details

   PROCEDURE delete_resource_accum_details
           (x_resource_list_assignment_id IN NUMBER,
            x_resource_list_id            IN NUMBER,
            x_project_id                  IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   tot_recs_processed    number(15):=0;
   BEGIN

     x_err_code  :=0;
     x_err_stage := 'Deleting resource accum details';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     LOOP
     IF (x_resource_list_id IS NULL) THEN
       DELETE
          pa_resource_accum_details
       WHERE
          resource_list_assignment_id =
              NVL(x_resource_list_assignment_id,resource_list_assignment_id)
       AND  project_id = x_project_id
       and rownum <= pa_proj_accum_main.x_commit_size;
     ELSE

       DELETE
          pa_resource_accum_details
       WHERE
          resource_list_assignment_id =
              NVL(x_resource_list_assignment_id,resource_list_assignment_id)
       AND  resource_list_id = x_resource_list_id
       AND  project_id = x_project_id
       and rownum <= pa_proj_accum_main.x_commit_size;

     END IF;
           if sql%rowcount < pa_proj_accum_main.x_commit_size then
		/* Commented for Bug 2984871 Commit; */
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		   /*Code Changes for Bug No.2984871 start */
		   Commit;
		   /*Code Changes for Bug No.2984871 end */
		  exit;
          else
		/* Commented for Bug 2984871 Commit; */
		  tot_recs_processed := tot_recs_processed + sql%rowcount;
		   /*Code Changes for Bug No.2984871 start */
		   Commit;
		   /*Code Changes for Bug No.2984871 end */
	  end if;
    End loop;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || 'Numbers of Records Deleted = ' || TO_CHAR(tot_recs_processed));
     END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_resource_accum_details;

   -- This procedure will return the resource and its attributes for the
   -- given project_id. It will return the group level resource for
   -- the resources for which no child resource exists and for the
   -- group if child exists then it will return only the childs
   -- please note that outer join is done for pa_resources to pa_resource_txn_attributes
   -- because some of the resource may not have attributes

--          x_resource_list_id            IN OUT resource_list_id_tabtype,
--          x_resource_list_assignment_id IN OUT resource_list_asgn_id_tabtype,
--          x_resource_list_member_id     IN OUT member_id_tabtype,
--          x_resource_id                 IN OUT resource_id_tabtype,
--          x_member_level                IN OUT member_level_tabtype,
--          x_person_id                   IN OUT person_id_tabtype,
--          x_job_id                      IN OUT job_id_tabtype,
--          x_organization_id             IN OUT organization_id_tabtype,
--          x_vendor_id                   IN OUT vendor_id_tabtype,
--          x_expenditure_type            IN OUT expenditure_type_tabtype,
--          x_event_type                  IN OUT event_type_tabtype,
--          x_non_labor_resource          IN OUT non_labor_resource_tabtype,
--          x_expenditure_category        IN OUT expenditure_category_tabtype,
--          x_revenue_category            IN OUT revenue_category_tabtype,
--          x_non_labor_resource_org_id   IN OUT nlr_org_id_tabtype,
--          x_event_type_classification   IN OUT event_type_class_tabtype,
--          x_system_linkage_function     IN OUT system_linkage_tabtype,
--          x_resource_format_id          IN OUT resource_format_id_tabtype,
--          x_resource_type_code          IN OUT resource_type_code_tabtype,


   PROCEDURE get_mappable_resources
          ( x_project_id                     IN  NUMBER,
            x_res_list_id                    IN  NUMBER,
            x_resource_ind                IN OUT NOCOPY resource_index_tbl, /*Added nocopy for bug 2674619*/
            x_resources_in                IN OUT NOCOPY resources_tbl_type, /*Added nocopy for bug 2674619*/
            x_no_of_resources             IN OUT NOCOPY BINARY_INTEGER, --File.Sql.39 bug 4440895
            x_index                       IN OUT NOCOPY BINARY_INTEGER, --File.Sql.39 bug 4440895
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            )

   IS

     -- Cursor for getting mappable resources for the given resource list
     CURSOR selmembers IS
     SELECT
         rla.resource_list_assignment_id,
         rl.resource_list_id,
         rlm.resource_list_member_id,
         rlm.resource_id,
         rlm.member_level,
         rta.person_id,
         rta.job_id,
         rta.organization_id,
         rta.vendor_id,
         rta.expenditure_type,
         rta.event_type,
         rta.non_labor_resource,
         rta.expenditure_category,
         rta.revenue_category,
         rta.non_labor_resource_org_id,
         rta.event_type_classification,
         rta.system_linkage_function,
         rta.resource_format_id,
         rt.resource_type_code
         , rl.job_group_id
     FROM
         pa_resource_lists_all_bg rl,
         pa_resource_list_members rlm,
         pa_resource_txn_attributes rta,
         pa_resources r,
         pa_resource_types rt,
         pa_resource_list_assignments rla
     WHERE
         rlm.resource_list_id = rl.resource_list_id
     AND rl.resource_list_id = NVL(x_res_list_id,rl.resource_list_id)
     and nvl(rl.migration_code,'-99') <> 'N'
     and nvl(rlm.migration_code,'-99') <> 'N'
     AND NVL(rlm.parent_member_id,0) = 0
     AND rlm.enabled_flag = 'Y'
     AND rlm.resource_id = rta.resource_id(+)  --- rta may not available for resource
     AND r.resource_id = rlm.resource_id
     AND rt.resource_type_id = r.resource_type_id
     AND rla.resource_list_id = rl.resource_list_id
     AND rla.project_id = x_project_id
     AND NOT EXISTS
         ( SELECT
             'Yes'
           FROM
             pa_resource_list_members rlmc
           WHERE
             rlmc.parent_member_id = rlm.resource_list_member_id
           and nvl(rlmc.migration_code,'-99') <> 'N'
           AND rlmc.enabled_flag = 'Y'
         )
     UNION
     SELECT
         rla.resource_list_assignment_id,
         rl.resource_list_id,
         rlmc.resource_list_member_id,
         rlmc.resource_id,
         rlmc.member_level,
         NVL(rtac.person_id,rtap.person_id),
         NVL(rtac.job_id,rtap.job_id),
         NVL(rtac.organization_id,rtap.organization_id),
         NVL(rtac.vendor_id,rtap.vendor_id),
         NVL(rtac.expenditure_type,rtap.expenditure_type),
         NVL(rtac.event_type,rtap.event_type),
         NVL(rtac.non_labor_resource,rtap.non_labor_resource),
         NVL(rtac.expenditure_category,rtap.expenditure_category),
         NVL(rtac.revenue_category,rtap.revenue_category),
         NVL(rtac.non_labor_resource_org_id,rtap.non_labor_resource_org_id),
         NVL(rtac.event_type_classification,rtap.event_type_classification),
         NVL(rtac.system_linkage_function,rtap.system_linkage_function),
         rtac.resource_format_id,
         rtc.resource_type_code
         , rl.job_group_id
     FROM
         pa_resource_lists_all_bg rl,
         pa_resource_list_members rlmc,
         pa_resource_list_members rlmp,
         pa_resource_txn_attributes rtac,
         pa_resource_txn_attributes rtap,
         pa_resources rc,
         pa_resource_types rtc,
         pa_resource_list_assignments rla
     WHERE
         rlmc.resource_list_id = rl.resource_list_id
           and nvl(rl.migration_code,'-99') <> 'N'
           and nvl(rlmc.migration_code,'-99') <> 'N'
           and nvl(rlmp.migration_code,'-99') <> 'N'
     AND rl.resource_list_id = NVL(x_res_list_id,rl.resource_list_id)
     AND rlmc.enabled_flag = 'Y'
     AND rlmc.resource_id = rtac.resource_id(+)  --- rta may not available for resource
     AND rlmc.parent_member_id  = rlmp.resource_list_member_id
     AND rlmp.enabled_flag = 'Y'
     AND rlmp.resource_id = rtap.resource_id(+)  --- rta may not available for resource
     AND rc.resource_id = rlmc.resource_id
     AND rtc.resource_type_id = rc.resource_type_id
     AND rla.resource_list_id = rl.resource_list_id
     AND rla.project_id = x_project_id
     /* The next order by is very impotant.
     Ordering the resource by resource_list_assignment_id, resource_list_id */
     ORDER BY 1,2;

     memberrec          selmembers%ROWTYPE;

   BEGIN

     x_err_code        := 0;
     x_no_of_resources := 0;
     x_index           := 0;
     x_err_stage       := 'Getting Mappable Resources';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     -- get the resource list assignments and process them one by one

     FOR memberrec IN selmembers LOOP
       ---------------------------------------------getting index of resource_list
     if   x_index = 0  then
            x_index := x_index + 1;
            x_resource_ind(x_index).resource_list_id := memberrec.resource_list_id;
            x_resource_ind(x_index).location         := x_no_of_resources + 1;
     elsif memberrec.resource_list_id <> x_resources_in(x_no_of_resources).resource_list_id then
            x_index := x_index + 1;
            x_resource_ind(x_index).resource_list_id := memberrec.resource_list_id;
            x_resource_ind(x_index).location         := x_no_of_resources + 1;
     end if;

       -- Get the mappable resource for this project
       x_no_of_resources := x_no_of_resources + 1;

       x_resources_in(x_no_of_resources).resource_list_assignment_id :=
                                        memberrec.resource_list_assignment_id;
       x_resources_in(x_no_of_resources).resource_list_id := memberrec.resource_list_id;
       x_resources_in(x_no_of_resources).resource_list_member_id := memberrec.resource_list_member_id;
       x_resources_in(x_no_of_resources).resource_id := memberrec.resource_id;
       x_resources_in(x_no_of_resources).member_level := memberrec.member_level;
       x_resources_in(x_no_of_resources).person_id := memberrec.person_id;
       x_resources_in(x_no_of_resources).job_id := memberrec.job_id;
       x_resources_in(x_no_of_resources).organization_id := memberrec.organization_id;
       x_resources_in(x_no_of_resources).vendor_id := memberrec.vendor_id;
       x_resources_in(x_no_of_resources).expenditure_type := memberrec.expenditure_type;
       x_resources_in(x_no_of_resources).event_type := memberrec.event_type;
       x_resources_in(x_no_of_resources).non_labor_resource := memberrec.non_labor_resource;
       x_resources_in(x_no_of_resources).expenditure_category := memberrec.expenditure_category;
       x_resources_in(x_no_of_resources).revenue_category := memberrec.revenue_category;
       x_resources_in(x_no_of_resources).non_labor_resource_org_id :=
                                 memberrec.non_labor_resource_org_id;
       x_resources_in(x_no_of_resources).event_type_classification :=
                                               memberrec.event_type_classification;
       x_resources_in(x_no_of_resources).system_linkage_function :=
                                               memberrec.system_linkage_function;
       x_resources_in(x_no_of_resources).resource_format_id := memberrec.resource_format_id;
       x_resources_in(x_no_of_resources).resource_type_code := memberrec.resource_type_code;
       x_resources_in(x_no_of_resources).job_group_id := memberrec.job_group_id;

     END LOOP;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || 'Number of resources found = ' || TO_CHAR(x_no_of_resources));
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END get_mappable_resources;


/* With resource mapping enhancement bug 1889671 this procedure is now obsolete and will
   not be used any more
*/

   PROCEDURE old_map_txns

          ( x_project_id              IN  NUMBER,
            x_res_list_id             IN  NUMBER,
            x_mode                    IN  VARCHAR2 DEFAULT 'I',
            x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code             IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS

     -- Cursor for getting the txns for which the mapping needs to be done

     CURSOR seltxnaccums IS
     SELECT
         pta.txn_accum_id,
         pta.project_id,
         pta.task_id,
         pta.person_id,
         pta.job_id,
         pta.organization_id,
         pta.vendor_id,
         pta.expenditure_type,
         pta.event_type,
         pta.non_labor_resource,
         pta.expenditure_category,
         pta.revenue_category,
         pta.non_labor_resource_org_id,
         pta.event_type_classification,
         pta.system_linkage_function
     FROM
         pa_txn_accum pta
     WHERE
         pta.project_id = x_project_id
     AND ((pta.actual_cost_rollup_flag = DECODE(x_mode,'I','Y',
                                           'F',pta.actual_cost_rollup_flag,
                                           pta.actual_cost_rollup_flag))
          OR
          (pta.revenue_rollup_flag = DECODE(x_mode,'I','Y',
                                           'F',pta.revenue_rollup_flag,
                                           pta.revenue_rollup_flag))
          OR
          (pta.cmt_rollup_flag = DECODE(x_mode,'I','Y',
                                                   'F',pta.cmt_rollup_flag,
                                                   pta.cmt_rollup_flag)))
     AND EXISTS
         ( SELECT 'Yes'
           FROM   pa_txn_accum_details ptad
           WHERE  pta.txn_accum_id = ptad.txn_accum_id
         );

     txnaccumrec         seltxnaccums%ROWTYPE;


--     x_resource_list_assignment_id  resource_list_asgn_id_tabtype;
--     x_resource_list_id             resource_list_id_tabtype;
--     x_resource_list_member_id      member_id_tabtype;
--     x_resource_id                  resource_id_tabtype;
--     x_member_level                 member_level_tabtype;
--     x_person_id                    person_id_tabtype;
--     x_job_id                       job_id_tabtype;
--     x_organization_id              organization_id_tabtype;
--     x_vendor_id                    vendor_id_tabtype;
--     x_expenditure_type             expenditure_type_tabtype;
--     x_event_type                   event_type_tabtype;
--     x_non_labor_resource           non_labor_resource_tabtype;
--     x_expenditure_category         expenditure_category_tabtype;
--     x_revenue_category             revenue_category_tabtype;
--     x_non_labor_resource_org_id    nlr_org_id_tabtype;
--     x_event_type_classification    event_type_class_tabtype;
--     x_system_linkage_function      system_linkage_tabtype;
--     x_resource_format_id           resource_format_id_tabtype;
--     x_resource_type_code           resource_type_code_tabtype;

     x_resource_ind                 resource_index_tbl;
     x_resources_in                 resources_tbl_type;
     x_no_of_resources              BINARY_INTEGER;
     x_index                        BINARY_INTEGER;
     res_count                      BINARY_INTEGER;
     ind_count                      BINARY_INTEGER;

     -- Variable to store the attributes of the resource list

     current_rl_assignment_id       NUMBER;      -- Current resource list assignment id
     current_rl_id                  NUMBER;      -- Current resource list id
     current_rl_changed_flag        VARCHAR2(1); -- was this resource list changed?
     mapping_done                   BOOLEAN;     -- is mapping done for current resource list
     current_rl_type_code           VARCHAR2(20);-- current resource list type code

     current_rl_member_id           NUMBER;
     current_resource_id            NUMBER;
     current_resource_rank          NUMBER;
     current_member_level           NUMBER;
     group_category_found           BOOLEAN;
     attr_match_found               BOOLEAN;
     new_resource_rank              NUMBER;

     old_resource_id                NUMBER;
     old_rl_member_id               NUMBER;
     old_rl_assignment_id           NUMBER;

     resource_map_found             BOOLEAN;

     -- member id for unclassified resources

     uncl_group_member_id           NUMBER;
     uncl_child_member_id           NUMBER;
     uncl_resource_id               NUMBER;  -- assuming one resource_id for unclassfied
     commit_rows                    NUMBER;
     current_rl_job_group_id       NUMBER;  -- for Project Jobs

   BEGIN

     x_err_code  :=0;
     x_err_stage := 'Maping Transaction to Resources - APR-28';
     commit_rows := 0;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('old_map_txns: ' || x_err_stage);
     END IF;

     -- Get the mappable resource for this project
     get_mappable_resources
          ( x_project_id,
            x_res_list_id,
            x_resource_ind,
            x_resources_in,
            x_no_of_resources,
            x_index,
            x_err_stage,
            x_err_code);

 /*    FOR res_count IN 1..x_no_of_resources LOOP

          pa_debug.debug('old_map_txns: ' || 'List id= '|| to_char(x_resources_in(res_count).resource_list_id)||
            ' Res id= '|| to_char(x_resources_in(res_count).resource_id) ||
            ' Asgn id= '|| to_char(x_resources_in(res_count).resource_list_assignment_id) ||
            ' Member id= '|| to_char(x_resources_in(res_count).resource_list_member_id));

     END LOOP; */

     -- Now process all the eligible pa_txn_accum

     -- Get the txns for which mapping is to be done
     FOR txnaccumrec IN seltxnaccums LOOP

       -- Map this txn to all the resoure lists for this project
       commit_rows := commit_rows + 1;
       ind_count   := 1;
       res_count   := 0;
       mapping_done := TRUE;
       current_rl_assignment_id :=0;

       LOOP
       res_count := res_count + 1;
       if res_count > x_no_of_resources then
           exit;
       end if;
       /*    pa_debug.debug('Rescount value is :' || TO_CHAR(res_count)); */
      IF (current_rl_assignment_id <> x_resources_in(res_count).resource_list_assignment_id) THEN

       -- Mapping to the next resource list
       -- Check if resource mapping was done for last resource_list_assigment_id or not
         IF ( NOT mapping_done ) THEN

            IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

             -- Map to unclassified Resource
             -- also if the group_category_found flag is true than map to unclassfied
             -- category within the group

             current_resource_id      := uncl_resource_id;

             IF (group_category_found AND uncl_child_member_id <> 0) THEN
                 current_rl_member_id := uncl_child_member_id;
             ELSE
                 current_rl_member_id := uncl_group_member_id;
             END IF;

            END IF; --- IF ( current_resource_id IS NULL )

           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              pa_debug.debug('old_map_txns: ' || 'Resource mapping=' ||
           to_char(current_rl_member_id)|| ' ' || to_char(current_resource_id));
           END IF;

            -- Create a map now
           create_resource_map
              (current_rl_id,
               current_rl_assignment_id,
               current_rl_member_id,
               current_resource_id,
               txnaccumrec.person_id,
               PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),
               txnaccumrec.organization_id,
               txnaccumrec.vendor_id,
               txnaccumrec.expenditure_type,
               txnaccumrec.event_type,
               txnaccumrec.non_labor_resource,
               txnaccumrec.expenditure_category,
               txnaccumrec.revenue_category,
               txnaccumrec.non_labor_resource_org_id,
               txnaccumrec.event_type_classification,
               txnaccumrec.system_linkage_function,
               x_err_stage,
               x_err_code);

           -- Now create pa_resource_accum_details

           create_resource_accum_details
               (current_rl_id,
                current_rl_assignment_id,
                current_rl_member_id,
                current_resource_id,
                txnaccumrec.txn_accum_id,
                txnaccumrec.project_id,
                txnaccumrec.task_id,
                x_err_stage,
                x_err_code);

         END IF;  -- IF ( NOT mapping_done )

         --- Proceed to the next resource list now

         current_rl_assignment_id   := x_resources_in(res_count).resource_list_assignment_id;
         current_rl_id              := x_resources_in(res_count).resource_list_id;
         current_rl_changed_flag    := get_resource_list_status(current_rl_assignment_id);
         current_rl_type_code       := get_group_resource_type_code(current_rl_id);
         current_rl_job_group_id    := x_resources_in(res_count).job_group_id;
         mapping_done               := FALSE;

         -- This variables will store the information for best match for the resource
         current_rl_member_id       := NULL;
         current_resource_id        := NULL;
         current_resource_rank      := NULL;
         current_member_level       := NULL;
         group_category_found       := FALSE;
         uncl_group_member_id       := 0;
         uncl_child_member_id       := 0;
         uncl_resource_id           := 0;

         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            pa_debug.debug('old_map_txns: ' || 'asn id='||current_rl_assignment_id ||
                          ' list id='||current_rl_id ||
                          ' changed flag='||current_rl_changed_flag ||
                          ' type code ='||current_rl_type_code );
         END IF;
         IF ( current_rl_changed_flag = 'Y' ) THEN -- This resource list assignmnet
                                                   -- has been changed
            -- delete all the old maps for this resource list assignments
            -- for all the transactions

            delete_res_maps_on_asgn_id(current_rl_assignment_id,x_err_stage,x_err_code);
            change_resource_list_status(current_rl_assignment_id,x_err_stage,x_err_code);

         ELSIF ( current_rl_changed_flag = 'N' ) THEN
            -- Get the resource map status
            get_resource_map
               (current_rl_id,
                current_rl_assignment_id,
                txnaccumrec.person_id,
                PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),
                txnaccumrec.organization_id,
                txnaccumrec.vendor_id,
                txnaccumrec.expenditure_type,
                txnaccumrec.event_type,
                txnaccumrec.non_labor_resource,
                txnaccumrec.expenditure_category,
                txnaccumrec.revenue_category,
                txnaccumrec.non_labor_resource_org_id,
                txnaccumrec.event_type_classification,
                txnaccumrec.system_linkage_function,
                old_rl_member_id,
                old_resource_id,
                resource_map_found,
                x_err_stage,
                x_err_code);

            -- check if a map exist for the given attributes in the map table
           IF NOT(resource_map_found) THEN
               get_resource_map_new
               (current_rl_id,
                txnaccumrec.person_id,
                PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),
                txnaccumrec.organization_id,
                txnaccumrec.vendor_id,
                txnaccumrec.expenditure_type,
                txnaccumrec.event_type,
                txnaccumrec.non_labor_resource,
                txnaccumrec.expenditure_category,
                txnaccumrec.revenue_category,
                txnaccumrec.non_labor_resource_org_id,
                txnaccumrec.event_type_classification,
                txnaccumrec.system_linkage_function,
                old_rl_member_id,
                old_resource_id,
                resource_map_found,
                x_err_stage,
                x_err_code);

               if (resource_map_found) THEN
                    create_resource_map
                         (current_rl_id,
                          current_rl_assignment_id,
                          old_rl_member_id,
                          old_resource_id,
                          txnaccumrec.person_id,
                          PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),
                          txnaccumrec.organization_id,
                          txnaccumrec.vendor_id,
                          txnaccumrec.expenditure_type,
                          txnaccumrec.event_type,
                          txnaccumrec.non_labor_resource,
                          txnaccumrec.expenditure_category,
                          txnaccumrec.revenue_category,
                          txnaccumrec.non_labor_resource_org_id,
                          txnaccumrec.event_type_classification,
                          txnaccumrec.system_linkage_function,
                          x_err_stage,
                          x_err_code);
                   mapping_done := TRUE;
                end if;
             else
                   mapping_done := TRUE;
             end if;

             if mapping_done then
              -- Now create pa_resource_accum_details
              create_resource_accum_details
                 (current_rl_id,
                  current_rl_assignment_id,
                  old_rl_member_id,
                  old_resource_id,
                  txnaccumrec.txn_accum_id,
                  txnaccumrec.project_id,
                  txnaccumrec.task_id,
                  x_err_stage,
                  x_err_code);
             end if;

            if(resource_map_found) THEN
         --------------------------------------------go to the next res list
              if ind_count >= x_index then
                 res_count := x_no_of_resources;
              else
                 ind_count := ind_count + 1;
                 res_count := x_resource_ind(ind_count).location - 1;
              end if;
         ------------------------------------------------------------------
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('old_map_txns: ' || 'an old MAP IS FOUND');
              END IF;
            else
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('old_map_txns: ' || 'old MAP IS not FOUND');
              END IF;
            end if;
         END IF;

       END IF; -- IF (current_rl_assignment_id <> x_resource_list_assignment_id ....

       IF ( NOT mapping_done ) THEN

           -- Mapping still need to be done
           attr_match_found     := TRUE;

           IF ((x_resources_in(res_count).resource_type_code = 'UNCLASSIFIED' OR
                x_resources_in(res_count).resource_type_code = 'UNCATEGORIZED') AND
                x_resources_in(res_count).member_level = 1 ) THEN
                  attr_match_found := FALSE;
                  uncl_resource_id := x_resources_in(res_count).resource_id;
                  uncl_group_member_id  := x_resources_in(res_count).resource_list_member_id;
           END IF;

           IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY') THEN

            -- The resource list is based on the expenditure category

              IF ( x_resources_in(res_count).expenditure_category = txnaccumrec.expenditure_category) THEN
                group_category_found := TRUE;
              ELSE
                attr_match_found := FALSE;
              END IF; --IF ( x_expenditure_category(res_count).....


           ELSIF ( current_rl_type_code = 'REVENUE_CATEGORY' ) THEN

            -- The resource list is based on the revenue category

              IF (x_resources_in(res_count).revenue_category = txnaccumrec.revenue_category) THEN
                group_category_found := TRUE;
              ELSE
                attr_match_found := FALSE;
              END IF; -- IF (x_revenue_category(res_count) ....


           ELSIF ( current_rl_type_code = 'ORGANIZATION' ) THEN

            -- The resource list is based on the organization

              IF (x_resources_in(res_count).organization_id = txnaccumrec.organization_id) THEN
                group_category_found := TRUE;
              ELSE
                attr_match_found := FALSE;
              END IF; -- IF (x_organization_id(res_count)


           END IF; -- IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY'...

           IF ( current_rl_type_code = 'NONE' OR attr_match_found ) THEN

            -- The resource list is based on the none category

            -- Now compare the txn attributes with resource attributes

            -- The table given below determines if the resource is eligible
            -- for accumulation or not

            --  TXN ATTRIBUTE       RESOURCE ATTRIBUTE  ELIGIBLE
            --     NULL                   NULL            YES
            --     NULL                 NOT NULL           NO
            --   NOT NULL                 NULL            YES
            --   NOT NULL               NOT NULL          YES/NO depending on value

            -- Do not match the attributes for an unclassified resource

              IF (x_resources_in(res_count).resource_type_code = 'UNCLASSIFIED' ) THEN
                 attr_match_found := FALSE;
                 uncl_resource_id := x_resources_in(res_count).resource_id;

                  IF ( x_resources_in(res_count).member_level = 1 ) THEN -- group level unclassified
                      uncl_group_member_id  := x_resources_in(res_count).resource_list_member_id;
                  ELSE
                      uncl_child_member_id  := x_resources_in(res_count).resource_list_member_id;
                  END IF;

              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).person_id,NVL(txnaccumrec.person_id,-1)) =
                  NVL(txnaccumrec.person_id, -1)))) THEN
                   attr_match_found := FALSE;
              END IF;


              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).job_id,NVL(PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),-1)) =
                  NVL(PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id), -1)))) THEN
                   attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).organization_id,NVL(txnaccumrec.organization_id,-1)) =
                  NVL(txnaccumrec.organization_id, -1)))) THEN
                   attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).vendor_id,NVL(txnaccumrec.vendor_id,-1)) =
                  NVL(txnaccumrec.vendor_id, -1)))) THEN
                    attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).expenditure_type,NVL(txnaccumrec.expenditure_type,'X')) =
                  NVL(txnaccumrec.expenditure_type, 'X')))) THEN
                    attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).event_type,NVL(txnaccumrec.event_type,'X')) =
                  NVL(txnaccumrec.event_type, 'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).non_labor_resource,NVL(txnaccumrec.non_labor_resource,'X')) =
                  NVL(txnaccumrec.non_labor_resource, 'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).expenditure_category,NVL(txnaccumrec.expenditure_category,'X')) =
                  NVL(txnaccumrec.expenditure_category, 'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).revenue_category,NVL(txnaccumrec.revenue_category,'X')) =
                  NVL(txnaccumrec.revenue_category,'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).non_labor_resource_org_id,NVL(txnaccumrec.non_labor_resource_org_id,-1)) =
                  NVL(txnaccumrec.non_labor_resource_org_id,-1)))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).event_type_classification,NVL(txnaccumrec.event_type_classification,'X')) =
                  NVL(txnaccumrec.event_type_classification,'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

              IF (NOT (attr_match_found AND
                 (NVL(x_resources_in(res_count).system_linkage_function,NVL(txnaccumrec.system_linkage_function,'X')) =
                  NVL(txnaccumrec.system_linkage_function,'X')))) THEN
                     attr_match_found := FALSE;
              END IF;

           END IF; --IF ( current_rl_type_code = 'NONE'......
           IF (attr_match_found) THEN

              -- Get the resource rank now
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('old_map_txns: ' || 'This resource is eligible for mapping');
              END IF;

              IF ( txnaccumrec.event_type_classification IS NOT NULL ) THEN

                 -- determine the rank based on event_type_classification
                 new_resource_rank   := get_resource_rank(
                                            x_resources_in(res_count).resource_format_id,
                                            txnaccumrec.event_type_classification);
              ELSE
                 -- determine the rank based on system_linkage_function
                 new_resource_rank   := get_resource_rank(
                                            x_resources_in(res_count).resource_format_id,
                                            txnaccumrec.system_linkage_function);
              END IF; -- IF ( txnaccumrec.event_type_classification IS NOT NULL )
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('old_map_txns: ' || 'Rank for this resource=' || to_char(new_resource_rank));
              END IF;

              IF (  NVL(new_resource_rank,99) < NVL(current_resource_rank,99) ) THEN

                current_resource_rank := new_resource_rank;
                current_rl_member_id  := x_resources_in(res_count).resource_list_member_id;
                current_resource_id   := x_resources_in(res_count).resource_id;
                current_member_level  := x_resources_in(res_count).member_level;

              END IF;
            END IF; -- IF (attr_match_found)

       END IF;  -- IF ( NOT mapping_done ) THEN

      END LOOP;

      -- Now create the map for the last resoure list assignment
      IF ( NOT mapping_done ) THEN

        IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

           -- Map to unclassified Resource
           -- also if the group_category_found flag is true than map to unclassfied
           -- category within the group

           current_resource_id      := uncl_resource_id;

           IF (group_category_found AND uncl_child_member_id <> 0) THEN
               current_rl_member_id := uncl_child_member_id;
           ELSE
               current_rl_member_id := uncl_group_member_id;
           END IF;

        END IF; --- IF ( current_resource_id IS NULL )
        -- Create a map now
        create_resource_map
              (current_rl_id,
               current_rl_assignment_id,
               current_rl_member_id,
               current_resource_id,
               txnaccumrec.person_id,
               PA_Cross_Business_Grp.IsMappedToJob(txnaccumrec.job_id,current_rl_job_group_id),
               txnaccumrec.organization_id,
               txnaccumrec.vendor_id,
               txnaccumrec.expenditure_type,
               txnaccumrec.event_type,
               txnaccumrec.non_labor_resource,
               txnaccumrec.expenditure_category,
               txnaccumrec.revenue_category,
               txnaccumrec.non_labor_resource_org_id,
               txnaccumrec.event_type_classification,
               txnaccumrec.system_linkage_function,
               x_err_stage,
               x_err_code);

         -- Now create pa_resource_accum_details

         create_resource_accum_details
               (current_rl_id,
                current_rl_assignment_id,
                current_rl_member_id,
                current_resource_id,
                txnaccumrec.txn_accum_id,
                txnaccumrec.project_id,
                txnaccumrec.task_id,
                x_err_stage,
                x_err_code);

       END IF;
    If commit_rows >= pa_proj_accum_main.x_commit_size then
        commit;
        commit_rows := 0;
    end if;

    END LOOP;


  EXCEPTION
     -- Return if either no resource list are assigned to the project and/or
     -- no records in pa_txn_accum table need to be rolled up

     WHEN NO_DATA_FOUND THEN
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.debug('old_map_txns: ' || 'Exception Raised on Procedure map_txns');
        END IF;
        NULL;
    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      RAISE;
  END old_map_txns;

/* Map_txns is a wrapper around new_map_txns. This is called from Summarization
   process and this will call new_map_txns. */

PROCEDURE map_txns

          ( x_project_id              IN  NUMBER,
            x_res_list_id             IN  NUMBER,
            x_mode                    IN  VARCHAR2 DEFAULT 'I',
            x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code             IN OUT NOCOPY NUMBER)  IS --File.Sql.39 bug 4440895

   l_resource_list_assignment_id NUMBER;
   l_resource_list_id            NUMBER;

   /* In case x_res_list_id is null then do mapping for all
      resource lists attached to the project */

   /* Bug 3812290 Added pa_resource_lists_all_bg for the below cursor c1 */

   CURSOR C1 IS
    SELECT prla.resource_list_id
          ,prla.resource_list_assignment_id
      FROM pa_resource_list_assignments prla,
           pa_resource_lists_all_bg res
     WHERE prla.resource_list_id = nvl(x_res_list_id,prla.resource_list_id)
       AND prla.project_id       = x_project_id
       AND res.resource_list_id = prla.resource_list_id
       AND NVL(res.MIGRATION_CODE,'-99') <> 'N';

   /* This cursor is used print all the attribute details of the txns which
      result in NULL insert into PA_RESOURCE_ACCUM_DETAILS. This cursor is called
      only during NULL insert exception (resource_id and resource_list_member_id can
      be NULL if MAP_TXNS has failed to derive the same) */

   CURSOR C2 IS
      SELECT resource_id,
             resource_list_member_id,
             person_id,
             job_id,
             organization_id,
             vendor_id,
             expenditure_type,
             event_type,
             non_labor_resource,
             expenditure_category,
             revenue_category,
             non_labor_resource_org_id,
             event_type_classification,
             system_linkage_function,
             system_reference1 txn_accum_id,
             system_reference2 project_id,
             system_reference3 task_id
      FROM    PA_MAPPABLE_TXNS_TMP pmt
      WHERE NOT EXISTS
           (SELECT 'Yes'
              FROM pa_resource_accum_details rad
             WHERE resource_list_id            = l_resource_list_id
               AND resource_list_assignment_id = l_resource_list_assignment_id
               AND txn_accum_id                = pmt.system_reference1
               AND project_id                  = pmt.system_reference2
               AND task_id                     = pmt.system_reference3)
     AND   (pmt.resource_list_member_id is null OR
            pmt.resource_id is null);
   /*Code Changes for Bug No.2984871 start */
   l_rowcount number :=0;
   /*Code Changes for Bug No.2984871 end */

BEGIN

   FOR c1rec IN c1 LOOP

          l_resource_list_id            := c1rec.resource_list_id;
          l_resource_list_assignment_id := c1rec.resource_list_assignment_id;

          x_err_stage := ('Processing for resource list ' || l_resource_list_id);
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             pa_debug.debug('map_txns: ' || x_err_stage);
          END IF;

          delete from pa_mappable_txns_tmp;

          x_err_stage := 'Inserting into pa_mappable_txns_tmp';
       /* Bug 5552602/	5571792: Split the insert based on x_mode = I (Incremental-Update Process) or F (Full-Refresh process)*/
       If nvl(x_mode,'F') = 'I' then
          INSERT INTO PA_MAPPABLE_TXNS_TMP (
             txn_id,
             person_id,
             job_id,
             organization_id,
             vendor_id,
             expenditure_type,
             event_type,
             non_labor_resource,
             expenditure_category,
             revenue_category,
             non_labor_resource_org_id,
             event_type_classification,
             system_linkage_function,
             project_role_id,
             resource_list_id,
             system_reference1,
             system_reference2,
             system_reference3
             )
          SELECT
             pa_mappable_txns_tmp_s.NEXTVAL,
             pta.person_id,
             pta.job_id,
             pta.organization_id,
             pta.vendor_id,
             pta.expenditure_type,
             pta.event_type,
             pta.non_labor_resource,
             pta.expenditure_category,
             pta.revenue_category,
             pta.non_labor_resource_org_id,
             pta.event_type_classification,
             pta.system_linkage_function,
             NULL,               /* Project role id is not there on pa_txn_accum */
             l_resource_list_id,
             pta.txn_accum_id,   /* To identify our records back */
             pta.project_id,     /* This will avoid joining to pa_txn_accum again during insertion */
             pta.task_id         /* pa_resource_accum_details table */
           FROM pa_txn_accum pta
          WHERE pta.project_id = x_project_id
          AND ((pta.actual_cost_rollup_flag = 'Y') OR
                 (pta.revenue_rollup_flag     = 'Y') OR
                 (pta.cmt_rollup_flag         = 'Y') )
          /* 5571792  AND ((pta.actual_cost_rollup_flag = DECODE(x_mode,'I','Y',
                                                              'F',pta.actual_cost_rollup_flag,
                                                                  pta.actual_cost_rollup_flag)) OR
                 (pta.revenue_rollup_flag     = DECODE(x_mode,'I','Y',
                                                              'F',pta.revenue_rollup_flag,
                                                                  pta.revenue_rollup_flag))     OR
                 (pta.cmt_rollup_flag         = DECODE(x_mode,'I','Y',
                                                              'F',pta.cmt_rollup_flag,
                                                                  pta.cmt_rollup_flag))) 	5571792 */
            AND EXISTS
                  (SELECT 'Yes'
                     FROM pa_txn_accum_details ptad
                    WHERE pta.txn_accum_id = ptad.txn_accum_id
                    /* following not exists will be valid even in case of refresh ( x_mode = 'F' )
                       because from refresh process we call map_txns only after we have
                       deleted records from pa_resource_accum_details table */
            AND NOT EXISTS
                  (SELECT 'Yes'
                      FROM pa_resource_accum_details prad
                     WHERE prad.txn_accum_id = pta.txn_accum_id
                       AND resource_list_id = l_resource_list_id
                       AND resource_list_assignment_id = l_resource_list_assignment_id
                    )
             );
         ELSE        /*	5571792*/
          INSERT INTO PA_MAPPABLE_TXNS_TMP (
             txn_id,
             person_id,
             job_id,
             organization_id,
             vendor_id,
             expenditure_type,
             event_type,
             non_labor_resource,
             expenditure_category,
             revenue_category,
             non_labor_resource_org_id,
             event_type_classification,
             system_linkage_function,
             project_role_id,
             resource_list_id,
             system_reference1,
             system_reference2,
             system_reference3
             )
          SELECT
             pa_mappable_txns_tmp_s.NEXTVAL,
             pta.person_id,
             pta.job_id,
             pta.organization_id,
             pta.vendor_id,
             pta.expenditure_type,
             pta.event_type,
             pta.non_labor_resource,
             pta.expenditure_category,
             pta.revenue_category,
             pta.non_labor_resource_org_id,
             pta.event_type_classification,
             pta.system_linkage_function,
             NULL,               /* Project role id is not there on pa_txn_accum */
             l_resource_list_id,
             pta.txn_accum_id,   /* To identify our records back */
             pta.project_id,     /* This will avoid joining to pa_txn_accum again during insertion */
             pta.task_id         /* pa_resource_accum_details table */
           FROM pa_txn_accum pta
          WHERE pta.project_id = x_project_id
            AND EXISTS
                  (SELECT 'Yes'
                     FROM pa_txn_accum_details ptad
                    WHERE pta.txn_accum_id = ptad.txn_accum_id
                    /* following not exists will be valid even in case of refresh ( x_mode = 'F' )
                       because from refresh process we call map_txns only after we have
                       deleted records from pa_resource_accum_details table */
            AND NOT EXISTS
                  (SELECT 'Yes'
                      FROM pa_resource_accum_details prad
                     WHERE prad.txn_accum_id = pta.txn_accum_id
                       AND resource_list_id = l_resource_list_id
                       AND resource_list_assignment_id = l_resource_list_assignment_id
                    )
             );
   END IF;    /* 5571792*/

		/*Code Changes for Bug No.2984871 start */
		l_rowcount:=sql%rowcount;
		/*Code Changes for Bug No.2984871 end */

            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
		/* Commented for Bug 2984871
		       pa_debug.debug('map_txns: ' || 'Inserted ' || sql%rowcount|| ' rows in pa_mappable_txns_tmp ');*/
		   /*Code Changes for Bug No.2984871 start */
		       pa_debug.debug('map_txns: ' || 'Inserted ' || l_rowcount || ' rows in pa_mappable_txns_tmp ');
		   /*Code Changes for Bug No.2984871 end*/
	    END IF;
	/* Commented for Bug 2984871
	            IF sql%rowcount = 0 THEN*/
   /*Code Changes for Bug No.2984871 start */
            IF  l_rowcount= 0 THEN
   /*Code Changes for Bug No.2984871 end*/
                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.debug('NEW_MAP_TXNS is not called for this resource list since there ' ||
                                 'arent any records to process');
                  END IF;

            ELSE /* PA_MAPPABLE_TXNS_TMP contains records to be processed */

                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.debug('map_txns: ' || 'Calling new mapping api @ ' ||
                                  to_CHAR(sysdate,'DD-MON-RR::HH:MI:SS'));
                  END IF;

                  new_map_txns (x_resource_list_id           => l_resource_list_id,
                                x_error_stage                => x_err_stage,
                                x_error_code                 => x_err_code);

                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.debug('map_txns: ' || 'Call returned from new mapping api @ ' ||
                                  to_char(sysdate,'DD-MON-RR::HH:MI:SS'));
                  END IF;

                  DECLARE

                    null_insert EXCEPTION;
                    PRAGMA EXCEPTION_INIT(null_insert,-1400);

                  BEGIN
                       x_err_stage := 'Inserting into pa_resource_accum_details';
                       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                          pa_debug.debug('map_txns: ' || x_err_stage);
                       END IF;

                       INSERT INTO pa_resource_accum_details
                           (resource_list_id,
                            resource_list_assignment_id,
                            resource_list_member_id,
                            resource_id,
                            txn_accum_id,
                            project_id,
                            task_id,
                            creation_date,
                            created_by,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            request_id,
                            program_application_id,
                            program_id)
                       SELECT
                            l_resource_list_id,
                            l_resource_list_assignment_id,
                            pmt.resource_list_member_id,
                            pmt.resource_id,
                            pmt.system_reference1 txn_accum_id,
                            pmt.system_reference2 project_id,
                            pmt.system_reference3 task_id,
                            SYSDATE,
                            x_created_by, /* Global who columns initialized in spec of the package */
                            x_last_updated_by,
                            SYSDATE,
                            x_last_update_login,
                            x_request_id,
                            x_program_application_id,
                            x_program_id
                       FROM    PA_MAPPABLE_TXNS_TMP pmt
                       WHERE NOT EXISTS
                             (SELECT 'Yes'
                                FROM pa_resource_accum_details rad
                               WHERE resource_list_id = l_resource_list_id
                                 AND resource_list_assignment_id = l_resource_list_assignment_id
                                 AND txn_accum_id = pmt.system_reference1
                                 AND project_id = pmt.system_reference2
                                 AND task_id = pmt.system_reference3
                              );
                  EXCEPTION
                  WHEN NULL_INSERT THEN
                       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                          pa_debug.debug('map_txns: ' || 'Trying to insert null into PA_RESORCE_ACCUM_DETAILS');
                       END IF;
                       FOR c2rec IN c2 LOOP
                             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                pa_debug.debug('map_txns: ' || 'Resource id : ' || to_char(c2rec.resource_id));
                                pa_debug.debug('map_txns: ' || 'Resource list member id : ' || to_char(c2rec.resource_list_member_id));
                                pa_debug.debug('map_txns: ' || 'Person id : ' || to_char(c2rec.person_id));
                                pa_debug.debug('map_txns: ' || 'Job id : ' || to_char(c2rec.job_id));
                                pa_debug.debug('map_txns: ' || 'Organization id : ' || to_char(c2rec.organization_id));
                                pa_debug.debug('map_txns: ' || 'Vendor_id : ' || to_char(c2rec.vendor_id));
                                pa_debug.debug('map_txns: ' || 'Expenditure type : ' || c2rec.expenditure_type);
                                pa_debug.debug('map_txns: ' || 'Event type : ' || c2rec.event_type);
                                pa_debug.debug('map_txns: ' || 'Non labor resource : ' || c2rec.non_labor_resource);
                                pa_debug.debug('map_txns: ' || 'Expenditure category : ' || c2rec.expenditure_category);
                                pa_debug.debug('map_txns: ' || 'Revenue category : ' || c2rec.revenue_category);
                                pa_debug.debug('map_txns: ' || 'Non-labor Resource org id : ' || to_char(c2rec.non_labor_resource_org_id));
                                pa_debug.debug('map_txns: ' || 'Event Type Classification : ' || c2rec.event_type_classification);
                                pa_debug.debug('map_txns: ' || 'System Linkage Function : ' || c2rec.system_linkage_function);
                                pa_debug.debug('map_txns: ' || 'System ref1 : txn accum id : ' || c2rec.txn_accum_id);
                                pa_debug.debug('map_txns: ' || 'System ref2 : project id : ' || c2rec.project_id);
                                pa_debug.debug('map_txns: ' || 'System ref3 : task id : ' || c2rec.task_id);
                             END IF;
                        END LOOP;
                        RAISE;
                  WHEN OTHERS THEN
                        RAISE;
                  END;

            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('map_txns: ' || 'Inserted ' || sql%rowcount || ' rows into PA_RESOURCE_ACCUM_DETAILS');
            END IF;

            COMMIT;
            END IF; /* PA_MAPPABLE_TXNS_TMP%rowcount check */

  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
         IF x_err_code IS NULL THEN
           x_err_code := SQLCODE;
         END IF;
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            pa_debug.debug('map_txns: ' || 'Error occurred at ' || x_err_stage || ' error code = ' || x_err_code);
         END IF;
         RAISE;
  END map_txns;

/* MAP_TRANSACTIONS Procedure : Created for bug# 1889671
   This process will update the RESOURCE_LIST_MEMBER_ID and RESOURCE_ID in
   table PA_MAPPABLE_TXNS_TMP table. Following needs to be done before a call
   to this API is made.

   PA_MAPPABLE_TXNS_TMP table should have been populated for a single RESOURCE_LIST
   with all the transaction attributes with TXN_ID populated with a unique id.

   Populate SYSTEM_REFERENCE1-5 columns are populated with unique identifiers
   which will be used by the calling program after the completion of the
   currenct process, i.e., after assigning the resources to the transactions.
*/

  PROCEDURE new_map_txns
         (x_resource_list_id           IN  NUMBER,
          x_error_stage                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_error_code                 OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

      l_unclassified_rlm_id    NUMBER;
      l_unclassified_res_id    NUMBER;
      l_group_resource_type_id NUMBER;
      l_rl_job_group_id        pa_resource_lists_all_bg.job_group_id%type;

       /* According to guidelines from Performance group
          plsql table size should never exceed 200 */

      l_plsql_max_array_size   NUMBER := 200;
      l_prev_txn_id            NUMBER := NULL;
      l_counter                NUMBER;  /* Used by plsql tables during their population */

      TYPE l_resource_member_id_tbl_typ IS TABLE OF
                PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
      TYPE l_resource_id_tbl_typ IS TABLE OF
                PA_RESOURCE_LIST_MEMBERS.RESOURCE_ID%TYPE;
      TYPE l_txn_id_table_typ IS TABLE OF PA_MAPPABLE_TXNS_TMP.TXN_ID%TYPE;

      l_resource_member_id_tbl L_RESOURCE_MEMBER_ID_TBL_TYP := L_RESOURCE_MEMBER_ID_TBL_TYP();
      l_resource_id_tbl        L_RESOURCE_ID_TBL_TYP        := L_RESOURCE_ID_TBL_TYP();
      l_txn_id_tbl             L_TXN_ID_TABLE_TYP           := L_TXN_ID_TABLE_TYP();
      l_uncategorized_flag     PA_RESOURCE_LISTS_ALL_BG.UNCATEGORIZED_FLAG%type;

      /* Logical Flow of this API

      1. In case resource list to which mapping needs to be done is grouped.
         1.1  Insert all parents in resource list and their attributes into
              PA_RESOURCE_LIST_PARENTS_TMP temp table. Currently oracle projects allows
              resource list to be grouped only by organization, expenditure_category
              and revenue_category. Hence PA_RESOURCE_LIST_PARENTS_TMP table has only
              these three attributes.

         1.2  Now assign parents to each transaction in PA_MAPPABLE_TXNS_TMP table. This can
              be done by matching organization, expenditure_category or revenue_category
              of the txn with that in PA_RESOURCE_LIST_PARENTS_TMP.

         1.3  At this point if parent could not be assigned then the txn should be
              assigned to list level unclassified resource.

         1.4  Now insert all possible child level resources in PA_TEMP_RES_MAPS_TMP table and
              their ranks in this table. This is done by matching all attributes of
              transactions with corresponding attribute of the child resource.

         1.5  Fetch all the resources with highest (lowest in magnitude) rank in pl/sql
              tables and update PA_MAPPABLE_TXNS_TMP table with the resource id.

         1.6  At this stage if no resource is assigned to any txn but parent is assigned
              then assign parent level unclassified resource to these transactions.

         1.7  This is possible that a parent does not have any child under it. In such case
              it may not have any unclassified member under it also. In such case parent is
              the resource that should be assigned to the txn.

      2. In case resource list not categorized then
         2.1  Insert all possible child level resources in PA_TEMP_RES_MAPS_TMP table and their
              ranks in this table. This is done by matching all attributes of transactions
              with corresponding attribute of the child resource.

         2.2  Same as 1.5

         2.3  If no resource is assigned to any txn then list level unclassified resource
              should be assigned to the txn.
      */

      /* This cursor is used for processing in step 1.5 mentioned above */

      CURSOR C1 IS
       SELECT txn_id
             ,resource_list_member_id
             ,resource_id
         FROM pa_temp_res_maps_tmp
        ORDER BY txn_id, rank; /* ORDER BY is important and should not be changed */

      /* This cursor selects parent level unclassified members for the transactions.
         This cursor is used to achieve point 1.6 mentioned above.
      */

      CURSOR C2 IS
       SELECT pmt.txn_id
             ,prlm.resource_list_member_id
             ,prlm.resource_id
         FROM pa_mappable_txns_tmp pmt
             ,pa_resource_list_members prlm
        WHERE pmt.resource_list_member_id is null        /* A resource is not already assigned */
          AND pmt.parent_member_id        is not null    /* But a parent is assigned */
          AND pmt.parent_member_id        = prlm.parent_member_id
          and nvl(prlm.migration_code,'-99') <> 'N'
          AND prlm.resource_type_code     = 'UNCLASSIFIED';

BEGIN

     x_error_stage := 'Start of new_map_txns : ' ||
                      'Selecting group_resource_type_id ' ||
                      'and list level unclassified member';
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        pa_debug.debug('new_map_txns: ' || x_error_stage);
     END IF;

     /* The following select should always return just one row, i.e.,
        one and only one list level unclassified resource should be
        present. With debug mode set to Yes, if the error stage is
        the one above, its an abnormal case of a list level unclassified
        resource not being present */

     SELECT prl.group_resource_type_id
          , prlm.resource_list_member_id
          , prlm.resource_id
          , prl.job_group_id
          , nvl(prl.uncategorized_flag,'N')
       INTO l_group_resource_type_id
          , l_unclassified_rlm_id
          , l_unclassified_res_id
          , l_rl_job_group_id
          , l_uncategorized_flag
       FROM pa_resource_lists_all_bg prl
           ,pa_resource_list_members prlm
      WHERE prl.resource_list_id    = x_resource_list_id
        AND prl.resource_list_id    = prlm.resource_list_id
        and nvl(prl.migration_code,'-99') <> 'N'
        and nvl(prlm.migration_code,'-99') <> 'N'
        AND prlm.parent_member_id   is NULL
        AND prlm.resource_type_code = decode(Nvl(prl.uncategorized_flag,'N'),
                    'Y','UNCATEGORIZED','UNCLASSIFIED');

      IF l_uncategorized_Flag = 'Y' THEN
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('new_map_txns: ' || 'Resource List is UNCATEGORIZED');
            END IF;

            UPDATE pa_mappable_txns_tmp PMT
               SET resource_list_member_id = l_unclassified_rlm_id
                  ,resource_id             = l_unclassified_res_id
            WHERE PMT.resource_list_id = x_resource_list_id;
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
            END IF;
            x_error_stage := 'Mapping done';
            Return;
      END IF;

      IF l_group_resource_type_id <> 0 THEN /* resource list is grouped */

            /* Point 1.1 and 1.2 */

            update_parents_mem_id(x_res_list_id => x_resource_list_id,
                                  x_err_stage   => x_error_stage,
                                  x_err_code    => x_error_code);

            x_error_stage := 'In case no parent is determined assign list level unclassified';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('new_map_txns: ' || x_error_stage);
            END IF;

            /* Point 1.3 : If PARENT_MEMBER_ID is NULL even after the above update, then
               those txns will be mapped to resource level UNCLASSIFIED resource.
               Doing this update at this level will avoid selection of these records later
               and will improve the process throughput also.
            */


            UPDATE pa_mappable_txns_tmp PMT
               SET resource_list_member_id = l_unclassified_rlm_id
                  ,resource_id             = l_unclassified_res_id
             WHERE pmt.parent_member_id is null;

            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows with list level unclassified resource ');
            END IF;

            /* Point 1.4 */

            ins_temp_res_map_grp(x_res_list_id   => x_resource_list_id,
                                 x_rl_job_grp_id => l_rl_job_group_id,
                                 x_err_stage     => x_error_stage,
                                 x_err_code      => x_error_code);

      ELSE /* i.e. IF l_group_resource_type_id = 0 */

            x_error_stage := 'Resource list is NOT grouped';

            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.debug('new_map_txns: ' || x_error_stage);
            END IF;

            /* Point 2.1 */

            ins_temp_res_map_ungrp(x_res_list_id => x_resource_list_id,
                                 x_rl_job_grp_id => l_rl_job_group_id,
                                 x_err_stage     => x_error_stage,
                                 x_err_code      => x_error_code);

      END IF; /* IF group_resource_type_id <> 0 */


      /* following bulk update logic is irrespective of whether resource list is categorized or not */

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug ('new_map_txns: ' || 'Update PA_MAPPABLE_TXNS_TMP table with resources assigned');
      END IF;

      /* Bulk update has very consistent time for updations. It takes precisely 30 secs for 50000
         updates. The time does not vary whether we do bulk updates in batches of 200 records or in
         batches of 50000 records. Hence as per guidelines by performance team we are taking batch
          size of 200 (PL/SQL size should not increase this limit)
      */

      x_error_stage := 'Initializing plsql tables';

      l_txn_id_tbl.extend(l_plsql_max_array_size);
      l_resource_member_id_tbl.extend(l_plsql_max_array_size);
      l_resource_id_tbl.extend(l_plsql_max_array_size);

      /* Point 1.5 and 2.2 : Just update PA_MAPPABLE_TXNS_TMP with records
         in plsql table and handle for every 200 records */

      l_prev_txn_id := NULL;
      l_counter     := 1;

      x_error_stage := 'Starting loop for cursor c1';

      FOR c1rec in c1 LOOP

            IF (c1rec.txn_id <> nvl(l_prev_txn_id,-1)) THEN

                  l_txn_id_tbl(l_counter)             := c1rec.txn_id;
                  l_resource_member_id_tbl(l_counter) := c1rec.resource_list_member_id;
                  l_resource_id_tbl(l_counter)        := c1rec.resource_id;
                  l_counter                           := l_counter + 1;
                  l_prev_txn_id                       := c1rec.txn_id;

                  IF l_counter > l_plsql_max_array_size THEN

                       x_error_stage := 'Updating pa_mappable_txns_tmp with records in pl/sql tables';

                       FORALL i in l_resource_member_id_tbl.first..l_resource_member_id_tbl.last
                       UPDATE pa_mappable_txns_tmp
                          SET resource_list_member_id = l_resource_member_id_tbl(i)
                             ,resource_id             = l_resource_id_tbl(i)
                        WHERE txn_id = l_txn_id_tbl(i);

                   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                      pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
                   END IF;

                   l_counter := 1;
                END IF;

          END IF;

      END LOOP;

    IF l_counter > 1 THEN

         x_error_stage := 'Updating if any more records left';

         FORALL i in l_resource_member_id_tbl.first..(l_counter-1)
           UPDATE pa_mappable_txns_tmp
              SET resource_list_member_id = l_resource_member_id_tbl(i)
                 ,resource_id             = l_resource_id_tbl(i)
            WHERE txn_id = l_txn_id_tbl(i);

          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
          END IF;

    END IF;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug ('new_map_txns: ' || 'Bulk update done');
    END IF;

    IF l_group_resource_type_id <> 0 THEN

          /* Point 1.6 */

          x_error_stage := 'Now update with parent level unclassified resource';
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             pa_debug.debug('new_map_txns: ' || x_error_stage);
          END IF;

          l_counter := 1;

          /* Select txns with PARENT_MEMBER_ID populated and RESOURCE_LIST_MEMBER_ID not
             populated. These are to be mapped to resource parent level UNCLASSIFIED
             resources. Refer comments of C2 rec for comments on this loop */

          /* Using bulk collect logic here */

          x_error_stage := 'Opening cursor c2';

          OPEN C2;
          LOOP
               x_error_stage := 'Doing bulk collect from c2';
               FETCH C2 BULK COLLECT INTO
                        l_txn_id_tbl
                       ,l_resource_member_id_tbl
                       ,l_resource_id_tbl
               LIMIT l_plsql_max_array_size;

               IF nvl(l_txn_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

                     x_error_stage := 'Doing bulk update of pa_mappable_txns_tmp from data fetched from c2';

                     FORALL i in l_resource_member_id_tbl.first..l_resource_member_id_tbl.last
                     UPDATE pa_mappable_txns_tmp
                        SET resource_list_member_id = l_resource_member_id_tbl(i)
                           ,resource_id             = l_resource_id_tbl(i)
                     WHERE txn_id = l_txn_id_tbl(i);
                     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                        pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
                     END IF;

               END IF;

               EXIT WHEN nvl(l_txn_id_tbl.last,0) < l_plsql_max_array_size;

          END LOOP;
	  CLOSE C2; -- Bug#6320026

           x_error_stage := 'Updating resource_list_member_id with parent_member_id ' ||
                            'in case member_id is still null';
           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              pa_debug.debug ('new_map_txns: ' || x_error_stage);
           END IF;

           /* If the RESOURCE_LIST_MEMBER_ID is NULL even at this stage, then assign the
              PARENT_MEMBER_ID as the RESOURCE_LIST_MEMBER_ID. Reason being, this is a
              categorized resource, and since there arent any children, assign the parent
              itself as the resource */

           UPDATE pa_mappable_txns_tmp pmt
              set resource_list_member_id = parent_member_id
                 ,resource_id             = parent_resource_id
            WHERE pmt.resource_list_member_id is null
              AND pmt.parent_member_id        is not null;

           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
           END IF;


    ELSE /* if resource list is not grouped */

          /* Point 2.3 */

          /* update all txns with resource list level unclassified resource */

          x_error_stage := 'Updating unassigned txns to list level unclassified';
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             pa_debug.debug('new_map_txns: ' || x_error_stage);
          END IF;

        UPDATE pa_mappable_txns_tmp PMT
           SET resource_list_member_id = l_unclassified_rlm_id
              ,resource_id             = l_unclassified_res_id
         WHERE pmt.resource_list_member_id is null;

        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.debug('new_map_txns: ' || 'Updated ' || sql%rowcount || ' rows ');
        END IF;

    END IF;/* resource list is grouped */

    x_error_stage := 'Mapping done';

    l_txn_id_tbl.delete;
    l_resource_member_id_tbl.delete;
    l_resource_id_tbl.delete;

  EXCEPTION
  WHEN OTHERS THEN
        IF x_error_code is null THEN
          x_error_code := sqlcode;
        END IF;
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.debug('new_map_txns: ' || 'Error occurred at ' || x_error_stage || ' errcode = ' || x_error_code);
        END IF;
        RAISE;
  END new_map_txns;

  PROCEDURE update_parents_mem_id
            (x_res_list_id IN  pa_resource_lists_all_bg.resource_list_id%type,
             x_err_stage   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_err_code    OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895
  BEGIN

      x_err_stage := 'Resource list is grouped : Deleting from resource list parents table';
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('update_parents_mem_id: ' || x_err_stage);
      END IF;

       delete from pa_resource_list_parents_tmp;

       /* PA_RESOURCE_LIST_PARENTS_TMP is a global temp table used by this process only.
          This table will have only one of the columns, either ORGANIZATION_ID or
          REVENUE_CATEGORY or EXPENDITURE_CATEGORY as NOT NULL, since PA_RESOURCE_LIST_MEMBERS
          can be grouped by any one of these three attributes only */

       /* Point 1.1 */

       x_err_stage := 'Inserting into pa_resource_list_parents_tmp table';
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_parents_mem_id: ' || x_err_stage);
       END IF;

       INSERT INTO pa_resource_list_parents_tmp
         (resource_list_id
         ,resource_list_member_id
         ,resource_id
         ,organization_id
         ,expenditure_category
         ,revenue_category
        )
        ( SELECT
          prlm.resource_list_id
         ,prlm.resource_list_member_id
         ,prlm.resource_id
         ,prlm.organization_id
         ,prlm.expenditure_category
         ,prlm.revenue_category
         FROM pa_resource_list_members prlm
        WHERE prlm.parent_member_id is null
          AND prlm.resource_list_id = x_res_list_id
          and nvl(prlm.migration_code,'-99') <> 'N'
          AND prlm.enabled_flag     = 'Y'
        );

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_parents_mem_id: ' || 'Inserted ' || sql%rowcount || ' rows into pa_resource_list_parents_tmp');
       END IF;

       /* Determine parent for each transaction in PA_MAPPABLE_TXNS_TMP.
          As parents can be only organizations, expenditure category or revenue category,
          and only one of the three attributes will be populated in the parents tables,
          one single update will do for resource lists grouped by any of these three
       */

       /* Point 1.2 */

       x_err_stage := 'Updating the parent member details in PA_MAPPABLE_TXNS_TMP';
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_parents_mem_id: ' || x_err_stage);
       END IF;

       UPDATE pa_mappable_txns_tmp PMT
         SET (parent_member_id, parent_resource_id) =
               (SELECT resource_list_member_id, resource_id
                  FROM pa_resource_list_parents_tmp PRLP
                 WHERE (pmt.expenditure_category = prlp.expenditure_category
                    OR  pmt.organization_id      = prlp.organization_id
                    OR  pmt.revenue_category     = prlp.revenue_category)
                   AND pmt.resource_list_id      = prlp.resource_list_id);

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('update_parents_mem_id: ' || 'Updated ' || sql%rowcount || ' rows in pa_mappable_txns_tmp with parent member details');
       END IF;


  EXCEPTION
    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('Procedure Update_Parents_Mem_Id' || x_err_stage || ' error code = ' || x_err_code);
      END IF;
      RAISE;
  END update_parents_mem_id;

  PROCEDURE ins_temp_res_map_grp
              (x_res_list_id     IN  pa_resource_lists_all_bg.resource_list_id%type,
               x_rl_job_grp_id   IN  pa_resource_lists_all_bg.job_group_id%type,
               x_err_stage       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
               x_err_code        OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

     /* This cursor select distinct resource types defined in the resource list at
        child level. This cursor is used in point 1.4 in order to fire only those
        inserts for which resources are defined in the list.
     */

       CURSOR C3 IS
          SELECT DISTINCT resource_type_code
            FROM pa_resource_list_members
           WHERE resource_list_id = x_res_list_id
             and nvl(migration_code,'-99') <> 'N'
             AND parent_member_id is not null;

  BEGIN

    x_err_stage := 'Deleting from pa_temp_res_maps_tmp table';
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
    END IF;

    DELETE FROM pa_temp_res_maps_tmp;

    /* Point 1.4 : In following statements we will insert records into temp table
       pa_temp_res_maps_tmp table. As one transaction can belong to multiple resources
       all such resources with txn_id and rank will be inserted into this table.
       Later only those resources will be picked up which have highest rank
       (lowest in magnitude).

       Since resource list is grouped then we use the parent_member_id info already
       stamped on PA_MAPPABLE_TXNS_TMP table else we do not.
    */

    FOR C3REC in C3 LOOP
        IF C3REC.RESOURCE_TYPE_CODE = 'EMPLOYEE' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             /* During prototyping it has been found that these 8 nuclear inserts work much faster than
                one insert having 8 conditions. The one single insert with all 8 conditions combined
                took hours to come back while these 8 inserts did the same job in few seconds.
                These inserts are not modified to dynamic inserts because of performance reasons.
             */

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id,
                     prfr.rank
               FROM pa_mappable_txns_tmp temp
                   ,pa_resource_list_members prlm
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.person_id               = temp.person_id
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id        = x_res_list_id
               AND prlm.enabled_flag            = 'Y'
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.parent_member_id        is not null
               AND prlm.person_id               is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'JOB' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id,
                     prfr.rank
               FROM pa_mappable_txns_tmp temp
                   ,pa_resource_list_members prlm
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.job_id                  = PA_Cross_Business_Grp.IsMappedToJob(temp.job_id,x_rl_job_grp_id)
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.parent_member_id        is not null
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.enabled_flag            = 'Y'
               AND prlm.job_id                  is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'ORGANIZATION' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
                END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
              WHERE temp.parent_member_id        = prlm.parent_member_id
                AND prlm.organization_id         = temp.organization_id
                AND prlm.resource_format_id      = prfr.resource_format_id
		and prlm.resource_list_id = x_res_list_id
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.parent_member_id        is not null
                AND prlm.enabled_flag            = 'Y'
                AND prlm.organization_id         is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'REVENUE_CATEGORY' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.revenue_category        = temp.revenue_category
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.parent_member_id        is not null
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.enabled_flag            = 'Y'
               AND prlm.revenue_category        is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'VENDOR' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.vendor_id               = temp.vendor_id
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.parent_member_id        is not null
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.enabled_flag            = 'Y'
               AND prlm.vendor_id               is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EXPENDITURE_TYPE' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.expenditure_type        = temp.expenditure_type
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.enabled_flag            = 'Y'
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.expenditure_type        is not null
               AND prlm.parent_member_id        is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EXPENDITURE_CATEGORY' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
            FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.expenditure_category    = temp.expenditure_category
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.enabled_flag            = 'Y'
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.expenditure_category    is not null
               AND prlm.parent_member_id        is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EVENT_TYPE' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.event_type              = temp.event_type
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.parent_member_id        is not null
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.enabled_flag            = 'Y'
               AND prlm.event_type              is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

       ELSIF C3REC.RESOURCE_TYPE_CODE = 'PROJECT_ROLE' THEN

             x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || x_err_stage);
             END IF;

             INSERT INTO pa_temp_res_maps_tmp
             (SELECT txn_id
                   , prlm.resource_list_member_id
                   , prlm.resource_id
                   , prfr.rank
               FROM pa_mappable_txns_tmp TEMP
                   ,pa_resource_list_members PRLM
                   ,pa_resource_format_ranks prfr
             WHERE temp.parent_member_id        = prlm.parent_member_id
               AND prlm.project_role_id         = temp.project_role_id
               AND prlm.resource_format_id      = prfr.resource_format_id
	       and prlm.resource_list_id = x_res_list_id
               AND prlm.parent_member_id        is not null
               and nvl(prlm.migration_code,'-99') <> 'N'
               AND prlm.enabled_flag            = 'Y'
               AND prlm.project_role_id         is not null
               AND temp.resource_list_member_id is null /* resource is not already determined */
               AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.debug('ins_temp_res_map_grp: ' || 'Inserted ' || sql%rowcount || ' rows ');
             END IF;

        END IF;
     END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('Procedure Ins_Temp_Res_Map_Grp ' || x_err_stage || ' error code = ' || x_err_code);
      END IF;
      RAISE;
  END ins_temp_res_map_grp;

  PROCEDURE ins_temp_res_map_ungrp
            (x_res_list_id     IN  pa_resource_lists_all_bg.resource_list_id%type,
             x_rl_job_grp_id   IN  pa_resource_lists_all_bg.job_group_id%type,
             x_err_stage       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_err_code        OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

     /* This cursor select distinct resource types defined in the resource list at
        child level. This cursor is used in point 2.1 in order to fire only those
        inserts for which resources are defined in the list.
     */

     CURSOR C3 IS
     SELECT DISTINCT resource_type_code
       FROM pa_resource_list_members
      WHERE resource_list_id = x_res_list_id
      and nvl(migration_code,'-99') <> 'N';

  BEGIN
    x_err_stage := 'Deleting from pa_temp_res_maps_tmp table';
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
    END IF;

    DELETE FROM pa_temp_res_maps_tmp;

    /* Point 2.1 : In following statements we will insert records into temp table
       pa_temp_res_maps_tmp table. As one transaction can belong to multiple resources
       all such resources with txn_id and rank will be inserted into this table.
       Later only those resources will be picked up which have highest rank
       (lowest in magnitude).
    */

    /* The only difference in the INSERTs for categorized and uncategorized resource
       lists, is the TEMP.PARENT_MEMBER_ID = PRLM.PARENT_MEMBER_ID condition.
       Uncategorized resource lists will not have the PARENT_MEMBER_ID populated
    */

    FOR C3REC in C3 LOOP
         IF C3REC.RESOURCE_TYPE_CODE = 'EMPLOYEE' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
               WHERE prlm.person_id              = temp.person_id
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.person_id               is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'JOB' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.job_id = PA_Cross_Business_Grp.IsMappedToJob(temp.job_id,x_rl_job_grp_id)
                AND prlm.resource_format_id       = prfr.resource_format_id
                AND temp.resource_list_id         = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag             = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.job_id                   is not null
                AND temp.resource_list_member_id  is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

               IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                  pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
               END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'ORGANIZATION' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.organization_id         = temp.organization_id
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.organization_id         is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'REVENUE_CATEGORY' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.revenue_category        = temp.revenue_category
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.revenue_category        is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'VENDOR' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.vendor_id               = temp.vendor_id
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.vendor_id               is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EXPENDITURE_TYPE' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.expenditure_type        = temp.expenditure_type
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.expenditure_type        is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EXPENDITURE_CATEGORY' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.expenditure_category    = temp.expenditure_category
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.expenditure_category    is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'EVENT_TYPE' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.event_type              = temp.event_type
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.event_type              is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        ELSIF C3REC.RESOURCE_TYPE_CODE = 'PROJECT_ROLE' THEN

              x_err_stage := ('Inserting into pa_temp_res_maps_tmp for ' || C3REC.RESOURCE_TYPE_CODE);
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || x_err_stage);
              END IF;

              INSERT INTO pa_temp_res_maps_tmp
              (SELECT txn_id
                    , prlm.resource_list_member_id
                    , prlm.resource_id
                    , prfr.rank
                FROM pa_mappable_txns_tmp TEMP
                    ,pa_resource_list_members PRLM
                    ,pa_resource_format_ranks prfr
              WHERE prlm.project_role_id         = temp.project_role_id
                AND prlm.resource_format_id      = prfr.resource_format_id
                AND temp.resource_list_id        = prlm.resource_list_id
		and prlm.resource_list_id = x_res_list_id
                AND prlm.enabled_flag            = 'Y'
                and nvl(prlm.migration_code,'-99') <> 'N'
                AND prlm.project_role_id         is not null
                AND temp.resource_list_member_id is null /* resource is not already determined */
                AND NVL(temp.event_type_classification,temp.system_linkage_function) = prfr.txn_class_code);

              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 pa_debug.debug('ins_temp_res_map_ungrp: ' || 'Inserted ' || sql%rowcount || ' rows ');
              END IF;

        END IF; /* If C3REC.RESOURCE_TYPE_CODE = 'EMPLOYEE' */
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('Procedure Ins_Temp_Res_Map_Ungrp ' || x_err_stage || ' error code = ' || x_err_code);
      END IF;
      RAISE;
  END ins_temp_res_map_ungrp;


END PA_RES_ACCUMS;

/
