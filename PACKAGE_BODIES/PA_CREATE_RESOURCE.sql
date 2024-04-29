--------------------------------------------------------
--  DDL for Package Body PA_CREATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CREATE_RESOURCE" AS
/* $Header: PACRRESB.pls 120.11.12010000.2 2009/05/27 13:51:28 rmandali ship $*/

FUNCTION chk_plan_rl_unique (p_resource_list_name  IN  VARCHAR2,
                             p_resource_list_id    IN  NUMBER) return BOOLEAN;

  PROCEDURE Create_Resource_group
                                (p_resource_list_id        IN  NUMBER,
                                 p_resource_group          IN  VARCHAR2,
                                 p_resource_name           IN  VARCHAR2,
                                 p_alias                   IN  VARCHAR2,
                                 p_sort_order              IN  NUMBER,
                                 p_display_flag            IN  VARCHAR2,
                                 p_enabled_flag            IN  VARCHAR2,
                                 p_track_as_labor_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_resource_id             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_err_stack            IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_sort_order          NUMBER := 0;
   l_resource_type_id    NUMBER := 0;
   l_org_id	         NUMBER := NULL;

/*bug 1889671 : Resource Mapping Enhancement -- Code changes starts */
   l_person_id              pa_resource_txn_attributes.person_id%TYPE;
   l_job_id                 pa_resource_txn_attributes.job_id%TYPE;
   l_organization_id        pa_resource_txn_attributes.organization_id%TYPE;
   l_vendor_id              pa_resource_txn_attributes.vendor_id%TYPE;
   l_project_role_id        pa_resource_txn_attributes.project_role_id%TYPE;
   l_expenditure_type       pa_resource_txn_attributes.expenditure_type%TYPE;
   l_event_type             pa_resource_txn_attributes.event_type%TYPE;
   l_expenditure_category   pa_resource_txn_attributes.expenditure_category%TYPE;
   l_revenue_category       pa_resource_txn_attributes.revenue_category%TYPE;
   l_nlr_resource           pa_resource_txn_attributes.non_labor_resource%TYPE;
   l_nlr_res_org_id         pa_resource_txn_attributes.non_labor_resource_org_id%TYPE;
   l_event_type_cls         pa_resource_txn_attributes.event_type_classification%TYPE;
   l_system_link_function   pa_resource_txn_attributes.system_linkage_function%TYPE;
   l_resource_format_id     pa_resource_txn_attributes.resource_format_id%TYPE;
   l_res_type_code          pa_resource_types.resource_type_code%TYPE;

   CURSOR Cur_TXn_Attributes(p_resource_id  PA_RESOURCES.RESOURCE_ID%TYPE) IS
   SELECT prta.person_id,
          prta.job_id,
          prta.organization_id,
          prta.vendor_id,
          prta.project_role_id,
          prta.expenditure_type,
          prta.event_type,
          prta.expenditure_category,
          prta.revenue_category,
          prta.non_labor_resource,
          prta.non_labor_resource_org_id,
          prta.event_type_classification,
          prta.system_linkage_function,
          prta.resource_format_id,
          prt.resource_type_id,
          prt.resource_type_code
  FROM    PA_RESOURCE_TXN_ATTRIBUTES PRTA,
          PA_RESOURCES PR,
          PA_RESOURCE_TYPES PRT
  WHERE   prta.resource_id = pr.resource_id
    AND   pr.resource_id =P_RESOURCE_ID
    AND   pr.resource_type_id= prt.resource_type_id;

/*changes end for 1889671 */

   CURSOR c_res_list_csr IS
   SELECT
   group_resource_type_id
   FROM
   pa_resource_lists_all_bg
   WHERE resource_list_id = p_resource_list_id;

   CURSOR c_res_list_member_csr_1 IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   sort_order = p_sort_order;

   CURSOR c_res_list_member_csr_2 IS
   SELECT
   NVL(MAX(sort_order),0)+10
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   sort_order < 999999;

   CURSOR c_res_list_member_csr_3 IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   alias = p_alias;

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_code
   FROM
   pa_resource_types_active_v
   WHERE resource_type_id = l_resource_type_id;

   CURSOR c_revenue_categ_csr IS -- changed for perf bug 4887375
   /*SELECT
   description
   FROM
   pa_revenue_categories_res_v
   WHERE
   revenue_category_code = p_resource_group;*/
   SELECT
      tmp.description
   FROM (
      SELECT
         REVENUE_CATEGORY_CODE
        ,REVENUE_CATEGORY_M description
      FROM PA_REVENUE_CATEGORIES_V RC
      WHERE  DECODE(PA_GET_RESOURCE.INCLUDE_INACTIVE_RESOURCES, 'Y', START_DATE_ACTIVE,TRUNC(SYSDATE))  BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE,TRUNC(SYSDATE))
   ) tmp
   WHERE
     tmp.revenue_category_code = p_resource_group;

   CURSOR c_org_csr IS
   SELECT
   organization_name
   FROM
   pa_organizations_res_v
   WHERE
   organization_id = l_org_id ;

   CURSOR c_res_list_member_seq_csr IS
   SELECT
   pa_resource_list_members_s.NEXTVAL
   FROM SYS.DUAL;

   l_err_code             NUMBER := 0;
   l_old_stack            VARCHAR2(2000);
   l_dummy                VARCHAR2(1);
   l_get_new_sort_order   VARCHAR2(10) := 'FALSE';
   l_resource_name        VARCHAR2(80);
   l_alias                VARCHAR2(30);
   l_Uom                  VARCHAR2(30);
   l_track_as_labor_flag  VARCHAR2(1);
   l_rollup_qty_flag      VARCHAR2(1);
   l_resource_id          NUMBER := NULL;
   l_resource_list_member_id NUMBER := NULL;
   l_resource_type_code   VARCHAR2(100);


BEGIN
    l_old_stack := p_err_stack;
    p_err_code  := 0;
    p_err_stack := p_err_stack ||'->PA_CREATE_RESOURCE.create_resource_group';
    p_err_stage := ' Select group_resource_type_id from pa_resource_lists';

    -- Get Resource List Id ,Group_resource_type_id from
    -- PA_RESOURCE_LISTS with the
    -- X_Resource_list_id.
       OPEN c_res_list_csr;
       FETCH c_res_list_csr INTO
             l_resource_type_id;
       IF c_res_list_csr%NOTFOUND THEN
          p_err_code := 10;
          p_err_stage := 'PA_RL_INVALID';
          CLOSE c_res_list_csr;
          RETURN;
       END IF;

       CLOSE c_res_list_csr;
       -- If group_resource_type_id is 0 , then
       -- the resource list has not been grouped.Hence,cannot create
       -- a resource group

       IF l_resource_type_id = 0 THEN
          p_err_code := 11;
          p_err_stage := 'PA_RL_NOT_GROUPED';
          RETURN;
       END IF;
       IF (p_sort_order IS NULL OR p_sort_order = 0) THEN
           l_get_new_sort_order := 'TRUE';
       END IF;

    p_err_stage := ' Select resource_type_code from pa_resource_types';
       OPEN c_resource_types_csr;
       FETCH c_resource_types_csr INTO
             l_resource_type_code;
       IF c_resource_types_csr%NOTFOUND THEN
          p_err_code := 12;
          p_err_stage := 'PA_RT_INVALID';
          CLOSE c_resource_types_csr;
          RETURN;
       END IF;
       CLOSE c_resource_types_csr;


    p_err_stage := ' Select x  from pa_resource_list_members';

     -- Check whether sort_order is unique
       IF (p_sort_order IS NOT NULL AND p_sort_order > 0 ) THEN
          OPEN c_res_list_member_csr_1;
          FETCH c_res_list_member_csr_1 INTO
                l_dummy;
          IF c_res_list_member_csr_1%FOUND THEN
                l_get_new_sort_order := 'TRUE';
          ELSE
                l_sort_order := p_sort_order;
          END IF;
          CLOSE c_res_list_member_csr_1;
       END IF;

       IF l_get_new_sort_order = 'TRUE' THEN
         p_err_stage := ' Select max(sort_order) from pa_resource_list_members';
         OPEN c_res_list_member_csr_2;
         FETCH c_res_list_member_csr_2 INTO
               l_sort_order;
         CLOSE c_res_list_member_csr_2;
       END IF;


       -- In the case of revenue category,need to get the
       -- revenue_category_name also,since
       -- what is passed is revenue_category_code

       p_err_stage := 'Select description from pa_revenue_categories_res_v';
       IF l_resource_type_code = 'REVENUE_CATEGORY' THEN
          OPEN c_revenue_categ_csr;
          FETCH c_revenue_categ_csr INTO
                l_resource_name;
          IF c_revenue_categ_csr%NOTFOUND THEN
             p_err_code := 13;
             p_err_stage := 'PA_INVALID_REV_CATEG';
             CLOSE c_revenue_categ_csr;
             RETURN;
          ELSE
             CLOSE c_revenue_categ_csr;
          END IF;
       ELSIF l_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
             l_resource_name := p_resource_group;
       ELSIF l_resource_type_code = 'ORGANIZATION' THEN
          l_org_id     := TO_NUMBER(p_resource_group);
          p_err_stage :=
              ' Select organization_name from pa_organizations_res_v';
          -- Need to get the organization_name since what is passed
          -- is the organization id
          OPEN c_org_csr;
          FETCH c_org_csr INTO l_resource_name;
          IF c_org_csr%NOTFOUND THEN
              p_err_code := 14;
              p_err_stage := 'PA_INVALID_ORGANIZATION';
              CLOSE c_org_csr;
              RETURN;
          ELSE
              CLOSE c_org_csr;
          END IF;
       END IF;

       IF LENGTH(p_alias) > 0 THEN
          l_alias := SUBSTR(p_alias,1,30);
       ELSE
          l_alias := p_alias;
       END IF;

      -- Check whether alias is unique
       IF (p_alias IS NOT NULL ) THEN
          OPEN c_res_list_member_csr_3;
          FETCH c_res_list_member_csr_3 INTO
                l_dummy;
          IF c_res_list_member_csr_3%FOUND THEN
             IF l_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
                l_alias := SUBSTR(p_resource_group,1,30);
             ELSIF l_resource_type_code = 'REVENUE_CATEGORY' THEN
                l_alias := SUBSTR(l_resource_name,1,30);
             END IF;
          END IF;
          CLOSE c_res_list_member_csr_3; -- Bug 5347514 - added closing of csr
       END IF;


       IF p_alias IS NULL THEN
          IF l_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
             l_alias := SUBSTR(p_resource_group,1,30);
          ELSIF l_resource_type_code IN ('REVENUE_CATEGORY','ORGANIZATION')
                THEN
             l_alias := SUBSTR(l_resource_name,1,30);
          END IF;
       END IF;

          IF l_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
             l_expenditure_category := p_resource_group;
             l_revenue_category     := NULL;
             l_org_id               := NULL;
          ELSIF l_resource_type_code = 'REVENUE_CATEGORY' THEN
             l_revenue_category         := p_resource_group;
             l_expenditure_category     := NULL;
             l_org_id               := NULL;
          ELSIF l_resource_type_code = 'ORGANIZATION' THEN
             l_revenue_category         := NULL;
             l_expenditure_category     := NULL;
             l_org_id                   := TO_NUMBER(p_resource_group);

          END IF;


       -- Check whether the resource_group has already been created as
       -- a resource in PA_RESOURCE table and get the resource_id.

    PA_GET_RESOURCE.Get_Resource
                 (p_resource_name           => l_resource_name,
                  p_resource_type_Code      => l_resource_type_code,
                  p_person_id               => NULL,
                  p_job_id                  => NULL,
                  p_proj_organization_id    => l_org_id,
                  p_vendor_id               => NULL,
                  p_expenditure_type        => NULL,
                  p_event_type              => NULL,
                  p_expenditure_category    => l_expenditure_category,
                  p_revenue_category_code   => l_revenue_category,
                  p_non_labor_resource      => NULL,
                  p_system_linkage          => NULL,
                  p_project_role_id         => NULL,
                  p_resource_id             => l_resource_id,
                  p_err_code                => l_err_code,
                  p_err_stage               => p_err_stage,
                  p_err_stack               => p_err_stack );

      IF l_err_code <> 0 THEN
         p_err_code := l_err_code;
         RETURN;
      END IF;

     /* For bug # 818076 fix moved this code outside the if condition */
      PA_GET_RESOURCE.Get_Resource_Information
               (p_resource_type_Code   =>  l_resource_type_code,
                p_resource_attr_value  =>  p_resource_group,
                p_unit_of_measure      =>  l_uom,
                p_Rollup_quantity_flag =>  l_rollup_qty_flag,
                p_track_as_labor_flag  =>  l_track_as_labor_flag,
                p_err_code             =>  l_err_code,
                p_err_stage            =>  p_err_stage,
                p_err_stack            =>  p_err_stack);

      IF l_err_code <> 0 THEN
         p_err_code := l_err_code;
         RETURN;
      END IF;

      /* End of bug # 818076 fix */


      IF l_resource_id IS NULL THEN

      -- If the resource_group has not been created as a resource yet,then
      -- need to create the resource.Hence,get the necessary information
      -- from base views

             /* For bug # 818076 fix moved this code outside the if condition
                as track_as_labor flag should be assigned for resource_groups
                being inserted into resource_member_list table */
            /*  Comment starts ********************

            PA_GET_RESOURCE.Get_Resource_Information
               (p_resource_type_Code   =>  l_resource_type_code,
                p_resource_attr_value  =>  p_resource_group,
                p_unit_of_measure      =>  l_uom,
                p_Rollup_quantity_flag =>  l_rollup_qty_flag,
                p_track_as_labor_flag  =>  l_track_as_labor_flag,
                p_err_code             =>  l_err_code,
                p_err_stage            =>  p_err_stage,
                p_err_stack            =>  p_err_stack);

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;
              *********** Comment ends, # 818076   */

             Create_Resource
                (p_resource_name            => l_resource_name,
                 p_resource_type_Code       => l_resource_type_code,
                 p_description              => l_resource_name,
                 p_unit_of_measure          => l_uom,
                 p_rollup_quantity_flag     => l_rollup_qty_flag,
                 p_track_as_labor_flag      => l_track_as_labor_flag,
                 p_start_date               => SYSDATE,
                 p_end_date                 => NULL,
                 p_person_id                => NULL,
                 p_job_id                   => NULL,
                 p_proj_organization_id     => l_org_id,
                 p_vendor_id                => NULL,
                 p_expenditure_type         => NULL,
                 p_event_type               => NULL,
                 p_expenditure_category     => l_expenditure_category,
                 p_revenue_category_code    => l_revenue_category,
                 p_non_labor_resource       => NULL,
                 p_system_linkage           => NULL,
                 p_project_role_id          => NULL,
                 p_resource_id              => l_resource_id,
                 p_err_code                 => l_err_code,
                 p_err_stage                => p_err_stage,
                 p_err_stack                => p_err_stack );

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;
      END IF;  -- (IF l_resource_id IS NULL )

      OPEN c_res_list_member_seq_csr;
      FETCH c_res_list_member_seq_csr INTO
            l_resource_list_member_id;
      IF c_res_list_member_seq_csr%NOTFOUND THEN
         CLOSE c_res_list_member_seq_csr;
         RAISE NO_DATA_FOUND;
      ELSE
         CLOSE c_res_list_member_seq_csr;
      END IF;

    /*Changes done for Resource Mapping Enhancements */

    OPEN Cur_Txn_Attributes(l_resource_id);
    FETCH Cur_Txn_Attributes
    INTO l_person_id,
         l_job_id,
         l_organization_id,
         l_vendor_id,
         l_project_role_id,
         l_expenditure_type,
         l_event_type,
         l_expenditure_category,
         l_revenue_category,
         l_nlr_resource,
         l_nlr_res_org_id,
         l_event_type_cls,
         l_system_link_function,
         l_resource_format_id,
         l_resource_type_id,
         l_res_type_code;
   CLOSE Cur_Txn_Attributes;


      INSERT INTO pa_resource_list_members
      (resource_list_id,
       resource_list_member_id,
       resource_id,
       alias,
       parent_member_id,
       sort_order,
       member_level,
       display_flag,
       enabled_flag,
       track_as_labor_flag,
       last_updated_by,
       last_update_date,
       creation_date,
       created_by,
       last_update_login,
       PERSON_ID,
       JOB_ID,
       ORGANIZATION_ID,
       VENDOR_ID,
       PROJECT_ROLE_ID,
       EXPENDITURE_TYPE,
       EVENT_TYPE,
       EXPENDITURE_CATEGORY,
       REVENUE_CATEGORY,
       NON_LABOR_RESOURCE,
       NON_LABOR_RESOURCE_ORG_ID,
       EVENT_TYPE_CLASSIFICATION,
       SYSTEM_LINKAGE_FUNCTION,
       RESOURCE_FORMAT_ID,
       RESOURCE_TYPE_ID,
       RESOURCE_TYPE_CODE
       )

       SELECT
       p_resource_list_id,
       l_resource_list_member_id,
       l_resource_id,
       l_alias,
       NULL,
       l_sort_order,
       1,
       NVL(p_display_flag,'Y'),
       NVL(p_enabled_flag,'Y'),
       l_track_as_labor_flag,
       g_last_updated_by,
       g_last_update_date,
       g_creation_date,
       g_created_by,
       g_last_update_login,
       l_person_id,
       l_job_id,
       l_organization_id,
       l_vendor_id,
       l_project_role_id,
       l_expenditure_type,
       l_event_type,
       l_expenditure_category,
       l_revenue_category,
       l_nlr_resource,
       l_nlr_res_org_id,
       l_event_type_cls,
       l_system_link_function,
       l_resource_format_id,
       l_resource_type_id,
       l_res_type_code
       FROM
       sys.dual
       WHERE NOT EXISTS
       (SELECT 'x' FROM PA_RESOURCE_LIST_MEMBERS
        WHERE resource_list_id = p_resource_list_id
        AND   resource_id      = l_resource_id
        AND   parent_member_id IS NULL );

        p_resource_list_member_id := l_resource_list_member_id;
        p_track_as_labor_flag     := l_track_as_labor_flag;
        p_resource_id             := l_resource_id;

    p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
        RAISE;
END Create_Resource_group;

--
--    sachin     Bug 2486405. Added a New parameter p_job_group_id to the procedure
--
  PROCEDURE Create_Resource_List
              (p_resource_list_name  IN  VARCHAR2,
               p_description         IN  VARCHAR2,
               p_public_flag         IN  VARCHAR2, -- DEFAULT 'Y',
               p_group_resource_type IN  VARCHAR2,
               p_start_date          IN  DATE, -- DEFAULT SYSDATE,
               p_end_date            IN  DATE, -- DEFAULT NULL,
               p_business_group_id   IN  NUMBER, -- DEFAULT NULL,
               p_job_group_id        IN  NUMBER,     --Added for Bug 2486405.
               p_job_group_name      IN  VARCHAR2 DEFAULT NULL,
               p_use_for_wp_flag     IN  VARCHAR2 DEFAULT NULL,
               p_control_flag        IN  VARCHAR2 DEFAULT NULL,
               p_migration_code      IN  VARCHAR2 DEFAULT NULL,
               p_record_version_number IN NUMBER DEFAULT NULL,
               p_resource_list_id    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
               p_err_code            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
               p_err_stage        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
               p_err_stack        IN OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
   l_err_code             NUMBER := 0;
   l_old_stack            VARCHAR2(2000);
   l_dummy                VARCHAR2(1);
   l_resource_type_id     NUMBER := NULL;
   l_resource_list_id     NUMBER;
   l_resource_name        VARCHAR2(80);
   l_Uom                  VARCHAR2(30);
   l_track_as_labor_flag  VARCHAR2(1);
   l_rollup_qty_flag      VARCHAR2(1);
   l_resource_id          NUMBER := NULL;
   l_resource_type_code   pa_resource_types.resource_type_code%TYPE;
   l_job_group_id         NUMBER := NULL; --Added for Bug 2486405.
   l_msg_count            NUMBER;
   l_record_version_number NUMBER := NULL;
   l_return_status        VARCHAR2(1);
   l_format_id            NUMBER;
   l_res_class_id         NUMBER;
   l_res_class_code       VARCHAR2(30);
   l_etc_method_code      VARCHAR2(30);
   l_spread_curve_id      NUMBER;
   --l_cost_type_id         NUMBER;
   l_plan_rl_format_id    NUMBER;
   --Bug 3501039
   l_resource_list_name   Varchar2(60);

   CURSOR c_res_list_csr IS
   SELECT 'x' FROM
   pa_resource_lists
   WHERE NAME =  p_resource_list_name;

   CURSOR c_res_list_member_seq_csr IS
   SELECT
   pa_resource_list_members_s.NEXTVAL
   FROM SYS.DUAL;

   CURSOR csr_get_formats IS
   SELECT fmt.res_format_id, fmt.resource_class_id, cls.resource_class_code
     FROM pa_res_formats_b fmt, pa_resource_classes_b cls
    WHERE fmt.resource_class_flag = 'Y'
      AND fmt.resource_class_id = cls.resource_class_id;

   CURSOR csr_get_class_def(p_resource_class_id NUMBER) IS
   SELECT def.spread_curve_id, def.etc_method_code --, def.mfc_cost_type_id
     FROM pa_plan_res_defaults def
    WHERE def.resource_class_id = p_resource_class_id
      AND def.object_type       = 'CLASS';

   CURSOR c_resource_groups_csr IS
   SELECT
   group_resource_type_id
   FROM
   pa_resource_groups_valid_v
   WHERE resource_group = p_group_resource_type;

   CURSOR  c_res_list_seq_csr IS
   SELECT pa_resource_lists_s.NEXTVAL
   FROM
   SYS.DUAL;

   -- Added for Bug 2486405.
   CURSOR c_job_group_csr IS
   SELECT 1
   FROM  pa_jobs_v
   WHERE job_group_id = p_job_group_id
   AND   ROWNUM = 1;

-- Following block of code is added for the resolution of bug 1889671
-- Same logic  is used as it is done in PA_GET_RESOURCE.Get_Unclassified_Resource
-- Start of change

    CURSOR Cur_Unclassified_Resource_List IS
    SELECT prt.resource_type_id,prt.resource_type_code
    FROM pa_resources pr, pa_resource_types prt
    WHERE prt.resource_type_code='UNCLASSIFIED'
    AND pr.resource_type_id = prt.resource_type_id;


BEGIN

   l_old_stack := p_err_stack;
   p_err_code  := 0;
   p_err_stack := p_err_stack ||'->PA_CREATE_RESOURCE.create_resource_list';
   p_err_stage := 'Select x from pa_resource_lists ';

   -- First clear the message stack if called from html.
   IF p_migration_code IS NOT NULL THEN
      FND_MSG_PUB.initialize;
      p_err_stack := FND_API.G_RET_STS_SUCCESS;
   END IF;

   IF p_migration_code IS NULL THEN -- Added by RM
      OPEN  c_res_list_csr;
      FETCH c_res_list_csr INTO
            l_dummy;
      IF c_res_list_csr%FOUND THEN
         p_err_code := 10;
         p_err_stage := 'PA_RL_FOUND' ;
         CLOSE c_res_list_csr;
         RETURN;
      END IF;
   -- Added by RM
   ELSE
      IF (chk_plan_rl_unique(p_resource_list_name,
                             p_resource_list_id) = FALSE) THEN
         p_err_code := p_err_code + 1;
         p_err_stage := FND_API.G_RET_STS_ERROR;
         p_err_stack := 'PA_RL_FOUND' ;
         pa_utils.add_message(P_App_Short_Name  => 'PA',
                              P_Msg_Name        => 'PA_RL_FOUND');
         RETURN;
      END IF;

   END IF;

-- Validate Dates
-- Start Date is required -- ERROR MESSAGE NEEDS TO BE DONE
IF (p_start_date is NULL AND p_migration_code = 'N') THEN
    p_err_code := p_err_code + 1;
    p_err_stage := FND_API.G_RET_STS_ERROR;
    p_err_stack := 'PA_IRS_START_NOT_NULL' ;
    pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_IRS_START_NOT_NULL');
    RETURN;
END IF;

IF (p_start_date IS NOT NULL and p_end_date IS NOT NULL
    and p_start_date >= p_end_date) THEN
    p_err_code := p_err_code + 1;
    p_err_stage := FND_API.G_RET_STS_ERROR;
    p_err_stack := 'PA_PR_INVALID_OR_DATES' ;
    pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_PR_INVALID_OR_DATES');
    RETURN;
END IF;

   p_err_stage :=
      'Select group_resource_type_id from pa_resource_groups_valid_v ';

   IF p_migration_code IS NULL THEN -- Added by RM
      OPEN c_resource_groups_csr;
      FETCH c_resource_groups_csr INTO
            l_resource_type_id;
      IF    c_resource_groups_csr%NOTFOUND THEN
            p_err_code := 11;
            p_err_stage := 'PA_GROUPED_RT_INVALID';
            CLOSE c_resource_groups_csr;
            RETURN;
      ELSE
            CLOSE c_resource_groups_csr;
      END IF;
   END IF; -- Added by RM

   p_err_stage := 'Select pa_resource_lists_s.nextval from dual ';
   OPEN  c_res_list_seq_csr;
   FETCH c_res_list_seq_csr INTO
         l_resource_list_id;
   IF c_res_list_seq_csr%NOTFOUND THEN
      CLOSE c_res_list_seq_csr;
      RAISE NO_DATA_FOUND;
   END IF;

   -----------------------Bug 2486405--------------------------
   p_err_stage :=  'Select 1 from pa_jobs_v ';

  If (p_job_group_id IS NULL OR
      p_job_group_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
     l_job_group_id := NULL;
  ELSE
     IF p_migration_code IS NULL THEN
      OPEN c_job_group_csr;
      FETCH c_job_group_csr INTO l_job_group_id;
      IF    c_job_group_csr%NOTFOUND THEN
            p_err_code := 11;
            p_err_stage := 'PA_JOB_GROUP_INVALID';   -- New Error ->The specified Job Group is invalid.
            CLOSE c_job_group_csr;
            RETURN;
      ELSE
            l_job_group_id := p_job_group_id;
            CLOSE c_job_group_csr;
      END IF;
    END IF;
  End If;
   -----------------------Bug 2486405--------------------------

   p_err_stage := 'Insert into pa_resource_lists ';

IF (p_job_group_id IS NOT NULL ) OR (p_job_group_name IS NOT NULL) THEN
   pa_job_utils.Check_Job_GroupName_Or_Id(
                        p_job_group_id          => p_job_group_id,
                        p_job_group_name        => p_job_group_name,
                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
                        x_job_group_id          => l_job_group_id,
                        x_return_status         => p_err_stage,
                        x_error_message_code    => p_err_stack);
   IF p_err_stage = FND_API.G_RET_STS_ERROR THEN
      p_err_code := p_err_code + 1;
      PA_UTILS.Add_Message(p_app_short_name => 'PA'
                          ,p_msg_name       => p_err_stack );
      RETURN;
   END IF;
END IF;
/**************************************************
 * Bug - 3501039
 * Desc - taking a substr of the p_resource_list_name
 *        before inserting into the pa_resource_lists_all_bg
 *        table.
 ************************************************/
   l_resource_list_name := substr(p_resource_list_name,0,58);
   INSERT INTO pa_resource_lists_all_bg (
    resource_list_id,
    name,
    business_group_id,
    description,
    public_flag,
    group_resource_type_id,
    start_date_active,
    end_date_active,
    uncategorized_flag,
    job_group_id,               --Added for Bug 2486405.
    last_updated_by,
    last_update_date,
    creation_date,
    created_by,
    last_update_login,
    control_flag,            -- Added by RM
    use_for_wp_flag,         -- Added by RM
    migration_code,          -- Added by RM
    record_version_number    -- Added by RM
    )
    VALUES
    (l_resource_list_id ,
     --p_resource_list_name,
     l_resource_list_name, --Bug 3501039
     NVL(p_business_group_id,fnd_profile.value('PER_BUSINESS_GROUP_ID')), -- MOAC Changes - get from HR profile
     --NVL(p_description,p_resource_list_name),
     NVL(p_description,l_resource_list_name), --Bug 3501039
     NVL(p_public_flag,'Y'),
     l_resource_type_id,
     NVL(p_start_date,SYSDATE),
     p_end_date,
     'N',
     l_job_group_id,              --Added for Bug 2486405.
     g_last_updated_by,
     g_last_update_date,
     g_creation_date,
     g_created_by,
     g_last_update_login,
     p_control_flag,            -- Added by RM
     p_use_for_wp_flag,         -- Added by RM
     p_migration_code,          -- Added by RM
     1                          -- Added by RM
     );

   /* commented for bug 6079140 IF p_migration_code = 'N' THEN -- Added by RM */
      -- New lists - insert into TL table
      insert into pa_resource_lists_tl (
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         RESOURCE_LIST_ID,
         NAME,
         DESCRIPTION,
         LANGUAGE,
         SOURCE_LANG
  ) select
    g_last_update_login,
    g_creation_date,
    g_created_by,
    g_last_update_date,
    g_last_updated_by,
    L_RESOURCE_LIST_ID,
    p_resource_list_name,
    NVL(p_description,p_resource_list_name),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from pa_resource_lists_tl T
    where T.RESOURCE_LIST_ID = L_RESOURCE_LIST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

 /* commented for bug 6079140   END IF; -- Adding to TL */

   IF p_migration_code IS NULL THEN -- Added by RM
     -- Need to create one Unclassified Resource for the resource list
     PA_GET_RESOURCE.Get_Unclassified_Resource
                            (p_resource_id           => l_resource_id,
                             p_resource_name         => l_resource_name,
                             p_track_as_labor_flag   => l_track_as_labor_flag,
                             p_unit_of_measure       => l_uom,
                             p_rollup_quantity_flag  => l_rollup_qty_flag,
                             p_err_code              => l_err_code,
                             p_err_stage             => p_err_stage,
                             p_err_stack             => p_err_stack );

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;

    p_err_stage := 'Insert into pa_resource_list_members ';

    -- Following block of code is added for the resolution of bug 1889671

    OPEN Cur_Unclassified_Resource_List;
    FETCH Cur_Unclassified_Resource_List INTO  l_resource_type_id , l_resource_type_code;
    CLOSE Cur_Unclassified_Resource_List;

      INSERT INTO pa_resource_list_members
      (resource_list_id,
       resource_list_member_id,
       resource_id,
       alias,
       parent_member_id,
       sort_order,
       member_level,
       display_flag,
       enabled_flag,
       track_as_labor_flag,
       resource_type_id,
       resource_type_code,
       last_updated_by,
       last_update_date,
       creation_date,
       created_by,
       last_update_login )
       VALUES (
       l_resource_list_id,
       pa_resource_list_members_s.NEXTVAL,
       l_resource_id,
       l_resource_name,
       NULL,
       9999999,
       1,
       'N',
       'Y',
        l_track_as_labor_flag,
        l_resource_type_id,
        l_resource_type_code,
        g_last_updated_by,
        g_last_update_date,
        g_creation_date,
        g_created_by,
        g_last_update_login );

        p_resource_list_id := l_resource_list_id;

        p_err_stack := l_old_stack;
   ELSE  -- New Planning Resource Lists
      -- Add the four seeded class formats:
      open csr_get_formats;
      LOOP
         fetch csr_get_formats into l_format_id, l_res_class_id,
                                    l_res_class_code;
         exit when csr_get_formats%NOTFOUND;
         pa_plan_rl_formats_pvt.Create_Plan_RL_Format(
        P_Res_List_Id                    => l_resource_list_id,
        P_Res_Format_Id                  => l_format_id,
        X_Plan_RL_Format_Id              => l_plan_rl_format_id,
        X_Record_Version_Number          => l_record_version_number,
        X_Return_Status                  => p_err_stage,
        X_Msg_Count                      => p_err_code,
        X_Msg_Data                       => p_err_stack);

        IF p_err_stage <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN;
        END IF;
        open csr_get_class_def(l_res_class_id);
        fetch csr_get_class_def into l_spread_curve_id,
                                     l_etc_method_code;
                                     --l_cost_type_id;
        close csr_get_class_def;

      -- New Planning Resource Lists
      -- Add four resources - one for each class.
/***********************************************
 * Defaulting the record version_number to 1
 * and Migration_code = 'N' while doing this insert.
 * *********************************************/
 /*********************************************
 * Bug : 3476765
 * Desc : Defaulting the value of incurred_by_res_flag
 *        to 'N' while doing the insert.
 *********************************************/
 /**********************************************
 * Bug - 3591751
 * Desc - Defaulting the value of wp_eligible_flag
 *        to 'Y' while doing the insert.
 ***********************************************/
   INSERT INTO pa_resource_list_members
      (resource_list_id,
       resource_list_member_id,
       resource_id,
       alias,
       display_flag,
       enabled_flag,
       track_as_labor_flag,
       last_updated_by,
       last_update_date,
       creation_date,
       created_by,
       last_update_login,
       spread_curve_id,
       etc_method_code,
       mfc_cost_type_id,
       object_type,
       object_id,
       res_format_id,
       resource_class_flag,
       resource_class_id,
       resource_class_code,
       Migration_code,
       incurred_by_res_flag,
       Record_version_number,
       wp_eligible_flag,
       --Bug 3636856
       unit_of_measure
       )
       VALUES (
       l_resource_list_id,
       pa_resource_list_members_s.NEXTVAL,
       -99,
       initcap(replace(l_res_class_code, '_', ' ')),
       'Y',
       'Y',
       decode(l_res_class_code, 'PEOPLE', 'Y', 'N'),
       g_last_updated_by,
       g_last_update_date,
       g_creation_date,
       g_created_by,
       g_last_update_login,
       l_spread_curve_id,
       l_etc_method_code,
       NULL,
       'RESOURCE_LIST',
       l_resource_list_id,
       l_format_id,
       'Y',
       l_res_class_id,
       l_res_class_code,
       'N',
       'N',
        1,
        'Y',
        --Bug 3636856
        DECODE(l_res_class_code,'PEOPLE','HOURS','EQUIPMENT','HOURS',
               'MATERIAL_ITEMS','DOLLARS','FINANCIAL_ELEMENTS','DOLLARS'));

      END LOOP;
   END IF;

p_resource_list_id := l_resource_list_id;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
        RAISE;

END Create_Resource_list;

--Name:               Update_Resource_List
--Type:               Procedure
--Description:        This procedure updates header information for a
--                    planning resource list

PROCEDURE Update_Resource_List
              (p_resource_list_name  IN  VARCHAR2 DEFAULT NULL,
               p_description         IN  VARCHAR2 DEFAULT NULL,
               p_start_date          IN  DATE DEFAULT NULL,
               p_end_date            IN  DATE DEFAULT NULL,
               p_job_group_id        IN OUT NOCOPY NUMBER,
               p_job_group_name      IN  VARCHAR2 DEFAULT NULL,
               p_use_for_wp_flag     IN  VARCHAR2 DEFAULT NULL,
               p_control_flag        IN  VARCHAR2 DEFAULT NULL,
               p_migration_code      IN  VARCHAR2 DEFAULT NULL,
               p_record_version_number IN OUT NOCOPY NUMBER,
               p_resource_list_id    IN  NUMBER,
               x_msg_count           OUT NOCOPY  NUMBER,
               x_return_status       OUT NOCOPY  VARCHAR2,
               x_msg_data            OUT NOCOPY  VARCHAR2) IS
/*************************************************************
 * Bug         : 3473679
 * Description : Modified the below cursor to only pick up
 *               those records where the res_type_code
 *               is NAMED_PERSON, INVENTORY_ITEM, BOM_LABOR,
 *               BOM_EQUIPMENT, NON_LABOR_RESOURCE
 *               and the count is more than 1.
 *               Earlier we were not allowing the user to set the
 *               enabled flag to 'Y' if it was already being used
 *               irrespective of the format.
 ***********************************************************/
CURSOR chk_wp_change_allowed IS
select  count(typ.res_type_code)-- , typ.res_type_code
 from pa_plan_rl_formats prl,
      pa_res_formats_b fmt,
      pa_res_types_b typ
 where prl.resource_list_id = p_resource_list_id
 and prl.res_format_id = fmt.res_format_id
 and fmt.res_type_id = typ.res_type_id
 and typ.res_type_code in ('NAMED_PERSON', 'INVENTORY_ITEM', 'BOM_LABOR',
                         'BOM_EQUIPMENT', 'NON_LABOR_RESOURCE')
 group by typ.res_type_code
 having count(typ.res_type_code) > 1;

--Bug 3605602
--Using pa_resource_list_assignments_v instead of
--pa_resource_list_assignments.
CURSOR chk_wp_disable IS
SELECT 'N'
FROM   pa_resource_lists_all_bg rl
WHERE  rl.resource_list_id = p_resource_list_id
AND    rl.use_for_wp_flag <> p_use_for_wp_flag
--AND    exists (select 'Y' from pa_resource_list_assignments rla
AND    exists (select 'Y' from pa_resource_list_assignments_v rla
               where rla.resource_list_id = rl.resource_list_id
                 and rla.use_for_wp_flag = 'Y');

--Bug 3605602
--Using pa_resource_list_assignments_v instead of
--pa_resource_list_assignments.
CURSOR chk_ctrl_changed IS
SELECT 'N'
FROM   pa_resource_lists_all_bg rl
WHERE  rl.resource_list_id = p_resource_list_id
AND    rl.control_flag <> p_control_flag
--AND    exists (select 'Y' from pa_resource_list_assignments rla
AND    exists (select 'Y' from pa_resource_list_assignments_v rla
               where rla.resource_list_id = rl.resource_list_id);

CURSOR chk_job_group_allow IS
SELECT 'N'
FROM   pa_resource_list_members
WHERE  resource_list_id = p_resource_list_id
AND    job_id IS NOT NULL;

CURSOR get_job_group_id IS
SELECT job_group_id
FROM   pa_resource_lists_all_bg
WHERE  resource_list_id = p_resource_list_id;

/********************************************
 * Bug : 3473679
 * Desc : This cursor is being used to get the value of
 *        the enabled flag for the resource list in
 *        the database.
 ********************************************/
CURSOR get_wp_flag IS
SELECT use_for_wp_flag
FROM   pa_resource_lists_all_bg
WHERE  resource_list_id = p_resource_list_id;

CURSOR chk_migrated_list IS
SELECT 'N'
FROM  pa_resource_lists_all_bg rl
WHERE  rl.resource_list_id = p_resource_list_id
AND    rl.control_flag <> p_control_flag
AND    rl.migration_code = 'M';


l_wp_type_count     NUMBER := 0;
l_wp_flag           VARCHAR2(1) := NULL;
l_wp_disable        VARCHAR2(1) := 'Y';
l_ctrl_allowed      VARCHAR2(1) := 'Y';
l_job_allowed       VARCHAR2(1) := 'Y';
l_job_group_id NUMBER;
-- added for bug: 4537865
l_new_job_group_id NUMBER;
-- added for bug: 4537865
BEGIN
-- First clear the message stack.
FND_MSG_PUB.initialize;

x_msg_count  := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check Name uniqueness

IF (chk_plan_rl_unique(p_resource_list_name,
                       p_resource_list_id) = FALSE) THEN

    x_msg_count := x_msg_count + 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'PA_RL_FOUND' ;
    pa_utils.add_message(P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_RL_FOUND');
    RETURN;
END IF;

-- Validate Dates
-- Start Date is required -- ERROR MESSAGE NEEDS TO BE DONE
IF p_start_date is NULL THEN
   x_msg_count := x_msg_count + 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'PA_IRS_START_NOT_NULL' ;
    pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_IRS_START_NOT_NULL');
    RETURN;
END IF;

IF (p_start_date IS NOT NULL and p_end_date IS NOT NULL
     and p_start_date >= p_end_date) THEN
    x_msg_count := x_msg_count + 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'PA_PR_INVALID_OR_DATES' ;
    pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_PR_INVALID_OR_DATES');
    RETURN;
END IF;

/**************************************************
 * This cursor is used to get the enabled_flag for
 * the resource_list from the Database.
 * This will be used in determining if the Value
 * is being changed ot not.
 * *********************************************/
open get_wp_flag;
fetch get_wp_flag into l_wp_flag;
close get_wp_flag;

-- Check if Enable for WP has changed to 'Y'
IF p_use_for_wp_flag = 'Y' and p_use_for_wp_flag <> l_wp_flag THEN
   open chk_wp_change_allowed;
   fetch chk_wp_change_allowed into l_wp_type_count;
   IF chk_wp_change_allowed%FOUND THEN
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'PA_WP_ENABLE_ERR';
       pa_utils.add_message(p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_WP_ENABLE_ERR');
       close chk_wp_change_allowed;
       RETURN;
   END IF;
   close chk_wp_change_allowed;

-- Check if Enable for WP has changed to 'N'
ELSIF p_use_for_wp_flag = 'N' THEN
   open chk_wp_disable;
   fetch chk_wp_disable into l_wp_disable;
   IF chk_wp_disable%FOUND THEN
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'PA_WP_DISABLE_ERR';
       pa_utils.add_message(p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_WP_DISABLE_ERR');
       close chk_wp_disable;
       RETURN;
   END IF;
   close chk_wp_disable;
END IF;

-- Check if control flag has changed to 'Y'
--Bug 3605602
--We should not do the below check just when the flag is changed to
--'Y' but for all cases.
--IF p_control_flag = 'Y' THEN

   open chk_ctrl_changed;
   fetch chk_ctrl_changed into l_ctrl_allowed;
   IF chk_ctrl_changed%FOUND THEN
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'PA_CTRL_FLG_ERR';
       pa_utils.add_message(p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CTRL_FLG_ERR');
       close chk_ctrl_changed;
       RETURN;
   END IF;
   close chk_ctrl_changed;

   -- begin bug 3695571
   open chk_migrated_list;
   fetch chk_migrated_list into l_ctrl_allowed;
   If chk_migrated_list%NotFound Then
       Null;
   Else
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'PA_CTRL_FLG_MIG_ERR';
       pa_utils.add_message(p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CTRL_FLG_MIG_ERR');
       close chk_migrated_list;
       Return;
   End If;
   close chk_migrated_list;
   -- end bug 3695571

--END IF;

-- Validate job group ID and name - convert to ID to synch them up
-- hr_utility.trace_on(NULL, 'RMJOB');
-- hr_utility.trace('before job group id check');
IF (p_job_group_id IS NOT NULL ) OR (p_job_group_name IS NOT NULL) THEN
-- hr_utility.trace('inside job group id check');
   pa_job_utils.Check_Job_GroupName_Or_Id(
                        p_job_group_id          => p_job_group_id,
                        p_job_group_name        => p_job_group_name,
                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
             --         x_job_group_id          => p_job_group_id,		* commented for bug: 4537865
		        x_job_group_id 		=> l_new_job_group_id,          --added for bug :   4537865
                        x_return_status         => x_return_status,
                        x_error_message_code    => x_msg_data);

   --added fopr bug :   4537865
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      p_job_group_id := l_new_job_group_id;
   END IF;
   --added fopr bug :   4537865

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      x_msg_count := x_msg_count + 1;
      PA_UTILS.Add_Message(p_app_short_name => 'PA'
                          ,p_msg_name       => x_msg_data);
      RETURN;
   END IF;
END IF;
   -- check whether any planning resources with jobs exist on the list
   -- if they do, cannot change job group

-- hr_utility.trace('get job group id ');
open get_job_group_id;
fetch get_job_group_id into l_job_group_id;
close get_job_group_id;
-- hr_utility.trace('l_job_group_id is : ' || l_job_group_id);
-- hr_utility.trace('p_job_group_id is : ' || p_job_group_id);
IF (l_job_group_id IS NOT NULL) AND
   ((l_job_group_id <> p_job_group_id) OR (p_job_group_id IS NULL) OR
    (p_job_group_id = FND_API.G_MISS_NUM)) THEN
   open chk_job_group_allow;
   fetch chk_job_group_allow into l_job_allowed;
-- hr_utility.trace('l_job_allowed is : ' || l_job_allowed);
   IF chk_job_group_allow%FOUND THEN
      x_msg_count := x_msg_count + 1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PA_JOB_GROUP_ERR';
      pa_utils.add_message(p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_JOB_GROUP_ERR');
      close chk_job_group_allow;
      RETURN;
   END IF;
   close chk_job_group_allow;

END IF;
--Bug 3501039
update pa_resource_lists_all_bg
set name = substr(nvl(p_resource_list_name, name),0,58),
    description = p_description,
    job_group_id = p_job_group_id,
    start_date_active = nvl(p_start_date, start_date_active),
    end_date_active = p_end_date, --Removed nvl for bug 3787913
    last_updated_by = g_last_updated_by,
    last_update_date = g_last_update_date,
    last_update_login = g_last_update_login,
    control_flag = p_control_flag,
    use_for_wp_flag = p_use_for_wp_flag,
    record_version_number = record_version_number + 1
where resource_list_id = p_resource_list_id
and   nvl(record_version_number, 0) = nvl(p_record_version_number, 0);

IF (SQL%NOTFOUND) THEN
   PA_UTILS.Add_message(p_app_short_name => 'PA'
                       ,p_msg_name => 'PA_XC_RECORD_CHANGED');
   x_msg_count := x_msg_count + 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_data := 'PA_XC_RECORD_CHANGED';
   RETURN;
END IF;

p_record_version_number := p_record_version_number + 1;

  update pa_resource_lists_tl set
    NAME = nvl(p_resource_list_name, name),
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = g_last_update_date,
    LAST_UPDATED_BY = g_last_updated_by,
    LAST_UPDATE_LOGIN = g_last_update_login,
    SOURCE_LANG = userenv('LANG')
  where resource_list_id = p_resource_list_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_Resource_List;

FUNCTION chk_plan_rl_unique (p_resource_list_name  IN  VARCHAR2,
			     p_resource_list_id    IN  NUMBER) return BOOLEAN
IS
   CURSOR check_plan_rl_unique IS
   SELECT 'N' FROM
   pa_resource_lists_tl
   WHERE NAME =  p_resource_list_name
     AND LANGUAGE = userenv('LANG')
     AND ((resource_list_id <> p_resource_list_id
     AND   p_resource_list_id IS NOT NULL)
      OR p_resource_list_id IS NULL);

   CURSOR check_old_lists IS
   SELECT 'N' FROM
   pa_resource_lists_all_bg
   WHERE NAME =  p_resource_list_name
     AND ((resource_list_id <> p_resource_list_id
     AND   p_resource_list_id IS NOT NULL)
      OR p_resource_list_id IS NULL);
l_return BOOLEAN := TRUE;
l_dummy  VARCHAR2(1) := 'Y';
BEGIN
     OPEN check_plan_rl_unique;
     FETCH check_plan_rl_unique into l_dummy;

      IF check_plan_rl_unique%FOUND THEN
         l_return := FALSE;
      ELSE
        -- check against existing old forms created lists
        OPEN check_old_lists;
        FETCH check_old_lists into l_dummy;

         IF check_old_lists%FOUND THEN
            l_return := FALSE;
         ELSE
            l_return := TRUE;
         END IF;
         CLOSE check_old_lists;
      END IF;

     CLOSE check_plan_rl_unique;

RETURN l_return;

END chk_plan_rl_unique;
--Name:               Create_Resource_txn_Attribute
--Type:               Procedure
--Description:        This procedure inserts rows into pa_resource_txn_attributes...
--
--Called subprograms: ?
--
--History:
--	xx-xxx-xxxx	rkrishna		Created
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--						1. New IN-parameter, p_project_role_id, required.
--                                              2. Add project_role_id_flag join to c_res_format_csr
--                                              3. new p_resource_type_code assignment
--						4. modify insert for new project_role_id_flag
--
  PROCEDURE Create_Resource_txn_Attribute
                          ( p_resource_id                 IN  NUMBER,
                            p_resource_type_Code          IN  VARCHAR2,
                            p_person_id                   IN  NUMBER,
                            p_job_id                      IN  NUMBER,
                            p_proj_organization_id         IN  NUMBER,
                            p_vendor_id                   IN  NUMBER,
                            p_expenditure_type            IN  VARCHAR2,
                            p_event_type                  IN  VARCHAR2,
                            p_expenditure_category        IN  VARCHAR2,
                            p_revenue_category_code       IN  VARCHAR2,
                            p_non_labor_resource          IN  VARCHAR2,
                            p_system_linkage              IN  VARCHAR2,
                            p_project_role_id             IN  NUMBER,
                            p_resource_txn_attribute_id   OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            p_err_code                    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            p_err_stage                IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_stack                IN OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
 l_err_code             NUMBER := 0;
 l_old_stack            VARCHAR2(2000);

 l_person_id_flag                   VARCHAR2(1) := 'N';
 l_job_id_flag                      VARCHAR2(1) := 'N';
 l_proj_organization_id_flag         VARCHAR2(1) := 'N';
 l_vendor_id_flag                   VARCHAR2(1) := 'N';
 l_expenditure_type_flag            VARCHAR2(1) := 'N';
 l_event_type_flag                  VARCHAR2(1) := 'N';
 l_expenditure_category_flag        VARCHAR2(1) := 'N';
 l_revenue_category_code_flag       VARCHAR2(1) := 'N';

 /* Added for Bug 6655085 */
 l_system_linkage_flag              VARCHAR2(1) := 'N';

 /* Bug # 932398 Fix : Added flags for non-labor resources */
 l_non_labor_resource_flag          VARCHAR2(1) := 'N';
 l_non_labor_res_org_id_flag        VARCHAR2(1) := 'N';

-- Forecast/Bgt Integration
 l_project_role_id_flag             VARCHAR2(1) := 'N';
 l_project_role_id                  NUMBER := NULL;

 l_resource_txn_attribute_id        NUMBER;
 l_resource_format_id               NUMBER;
 l_resource_class_code              VARCHAR2(30);
 l_person_id                        NUMBER := NULL;
 l_job_id                           NUMBER := NULL;
 l_proj_organization_id             NUMBER := NULL;
 l_vendor_id                        NUMBER := NULL;
 l_expenditure_type                 VARCHAR2(80) := NULL;
 l_event_type                       VARCHAR2(80) := NULL;
 l_expenditure_category             VARCHAR2(80) := NULL;
 l_revenue_category_code            VARCHAR2(80) := NULL;

 CURSOR c_res_types_csr IS
 SELECT
 resource_class_code
 FROM
 pa_resource_types_active_v
 WHERE
 resource_type_code = p_resource_type_code;

 CURSOR c_res_format_csr IS
 SELECT
 resource_format_id
 FROM
 pa_resource_formats
 WHERE person_id_flag            = l_person_id_flag
 AND job_id_flag                 = l_job_id_flag
 AND organization_id_flag        = l_proj_organization_id_flag
 AND vendor_id_flag              = l_vendor_id_flag
 AND expenditure_type_flag       = l_expenditure_type_flag
 AND event_type_flag             = l_event_type_flag
 AND expenditure_category_flag   = l_expenditure_category_flag
 AND revenue_category_flag       = l_revenue_category_code_flag
 AND system_linkage_function_flag   = l_system_linkage_flag     /* Added for Bug 6655085 */
 AND non_labor_resource_flag        = l_non_labor_resource_flag
 AND non_labor_resource_org_id_flag = l_non_labor_res_org_id_flag
 AND project_role_id_flag           = l_project_role_id_flag;

 /* Bug # 932398 Fix : Added flags for non-labor resources in the above cursor */

 CURSOR c_res_txn_attr_seq_csr IS
 SELECT pa_resource_txn_attributes_s.NEXTVAL
 FROM SYS.DUAL;

BEGIN
   l_old_stack := p_err_stack;
   p_err_code  := 0;
   p_err_stack :=
   p_err_stack ||'->PA_CREATE_RESOURCE.Create_Resource_txn_Attribute';


   p_err_stage := 'Select resource_class_code from pa_resource_types_active_v';

   OPEN c_res_types_csr;
   FETCH c_res_types_csr INTO l_resource_class_code;
   IF c_res_types_csr%NOTFOUND THEN
      p_err_code := 10;
      p_err_stage := 'PA_RT_INVALID';
      CLOSE c_res_types_csr;
      RETURN;
   END IF;
   CLOSE c_res_types_csr;

   IF l_resource_class_code = 'USER_DEFINED' THEN
      l_person_id                 := p_person_id;
      l_job_id                    := p_job_id;
      l_proj_organization_id      := p_proj_organization_id;
      l_vendor_id                 := p_vendor_id;
      l_expenditure_type          := p_expenditure_type;
      l_event_type                := p_event_type;
      l_expenditure_category      := p_expenditure_category;
      l_revenue_category_code     := p_revenue_category_code;
      l_project_role_id           := p_project_role_id;
   ELSIF
      l_resource_class_code = 'PRE_DEFINED' THEN
       -- Need to get the resource_format_id from pa_resource_formats
           IF p_resource_type_code = 'EMPLOYEE' THEN
              l_person_id_flag := 'Y';
              l_person_id      := p_person_id;
           ELSIF p_resource_type_code = 'JOB' THEN
              l_job_id_flag := 'Y';
              l_job_id      := p_job_id;
           ELSIF p_resource_type_code = 'ORGANIZATION' THEN
              l_proj_organization_id_flag := 'Y';
              l_proj_organization_id      := p_proj_organization_id;
           ELSIF p_resource_type_code = 'VENDOR' THEN
              l_vendor_id_flag := 'Y';
              l_vendor_id      := p_vendor_id;
           ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
              l_expenditure_type_flag := 'Y';
              l_expenditure_type      := p_expenditure_type;
           ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
              l_event_type_flag := 'Y';
              l_event_type      := p_event_type;
           ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
              l_expenditure_category_flag := 'Y';
              l_expenditure_category      := p_expenditure_category;
           ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
              l_revenue_category_code_flag := 'Y';
              l_revenue_category_code      := p_revenue_category_code;
           ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
              l_project_role_id_flag := 'Y';
              l_project_role_id      := p_project_role_id;
           END IF;
   END IF;

   p_err_stage := 'Select resource_format_id from pa_resource_formats ';

   OPEN c_res_format_csr;
   FETCH c_res_format_csr INTO
         l_resource_format_id;
   IF c_res_format_csr%NOTFOUND THEN
      p_err_code   := 11;
      p_err_stage  := 'PA_RES_FORMAT_INVALID';
      CLOSE c_res_format_csr;
      RETURN;
   ELSE
      CLOSE c_res_format_csr;
   END IF;

   p_err_stage := 'Select pa_resource_txn_attributes_s.nextval from sys.dual ';

   OPEN c_res_txn_attr_seq_csr;
   FETCH c_res_txn_attr_seq_csr INTO
         l_resource_txn_attribute_id;
   IF c_res_txn_attr_seq_csr%NOTFOUND THEN
      CLOSE c_res_txn_attr_seq_csr;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_res_txn_attr_seq_csr;
   END IF;

   p_err_stage := 'Insert into pa_resource_txn_attributes ';

   INSERT INTO pa_resource_txn_attributes
   (
     resource_txn_attribute_id,
     resource_id ,
     person_id,
     job_id ,
     organization_id,
     vendor_id,
     expenditure_type,
     event_type,
     non_labor_resource ,
     expenditure_category,
     revenue_category ,
     non_labor_resource_org_id ,
     event_type_classification,
     system_linkage_function ,
     resource_format_id ,
     last_updated_by ,
     last_update_date,
     creation_date,
     created_by,
     last_update_login,
     project_role_id
     )
     VALUES
     (l_resource_txn_attribute_id,
      p_resource_id,
      l_person_id,
      l_job_id,
      l_proj_organization_id,
      l_vendor_id,
      l_expenditure_type,
      l_event_type,
      p_non_labor_resource,
      l_expenditure_category,
      l_revenue_category_code,
      NULL,
      NULL,
      p_system_linkage,
      l_resource_format_id,
      g_last_updated_by,
      g_last_update_date,
      g_creation_date,
      g_created_by,
      g_last_update_login,
      l_project_role_id
     );

      p_resource_txn_attribute_id :=  l_resource_txn_attribute_id;

      p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
        RAISE;

END Create_Resource_txn_Attribute ;

--Name:               Create_Resource_list_member
--Type:               Procedure
--Description:        This procedure creates resource lists...
--
--Called subprograms: ?
--
--History:
--	xx-xxx-xxxx	rkrishna		Created
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--						1. New IN-parameter, p_project_role_id, required.
--						2. New p_resource_type_code validation and
--                                                 new error message.
--
--  28-JAN-2003  sacgupta  Bug 2486405. Resource List Enhancement.
--                        1. new IN parameter p_job_group_id
--
--

PROCEDURE Create_Resource_list_member
                         (p_resource_list_id          IN  NUMBER,
                          p_resource_name             IN  VARCHAR2,
                          p_resource_type_Code        IN  VARCHAR2,
                          p_alias                     IN  VARCHAR2,
                          p_sort_order                IN  NUMBER,
                          p_display_flag              IN  VARCHAR2,
                          p_enabled_flag              IN  VARCHAR2,
                          p_person_id                 IN  NUMBER,
                          p_job_id                    IN  NUMBER,
                          p_proj_organization_id      IN  NUMBER,
                          p_vendor_id                 IN  NUMBER,
                          p_expenditure_type          IN  VARCHAR2,
                          p_event_type                IN  VARCHAR2,
                          p_expenditure_category      IN  VARCHAR2,
                          p_revenue_category_code     IN  VARCHAR2,
                          p_non_labor_resource        IN  VARCHAR2,
                          p_system_linkage            IN  VARCHAR2,
                          p_project_role_id           IN  NUMBER,
			  p_job_group_id              IN  NUMBER,         --- Added for Bug 2486405.
                          p_parent_member_id         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_track_as_labor_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_stack            IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

 l_err_code                     NUMBER := 0;
 l_old_stack                    VARCHAR2(2000);
 l_grouped_resource_type_id     NUMBER;
 l_grouped_resource_type_code   VARCHAR2(30);
 l_resource_id                  NUMBER;
 l_resource_list_member_id      NUMBER;
 l_track_as_labor_flag          VARCHAR2(1);
 l_group_res_list_member_id     NUMBER;
 l_group_track_as_labor_flag    VARCHAR2(1);
 l_resource_group               VARCHAR2(80);
 l_revenue_category_code        VARCHAR2(80);
 l_resource_group_name          VARCHAR2(80);
 l_org_id	                NUMBER := NULL;
 l_job_exist                    VARCHAR2(1);   -- Added for bug 2486405.

   CURSOR c_resource_lists_csr IS
   SELECT
   group_resource_type_id
   FROM
   pa_resource_lists_all_bg
   WHERE resource_list_id = p_resource_list_id;

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_code
   FROM
   pa_resource_types_active_v
   WHERE resource_type_id = l_grouped_resource_type_id;

   CURSOR c_rev_category_csr IS -- changed for perf bug 4887375
   /*SELECT
   description
   FROM
   pa_revenue_categories_res_v
   WHERE
   revenue_category_code = l_revenue_category_code;*/
   SELECT
      tmp.description
   FROM (
      SELECT
         REVENUE_CATEGORY_CODE
        ,REVENUE_CATEGORY_M description
      FROM PA_REVENUE_CATEGORIES_V RC
      WHERE  DECODE(PA_GET_RESOURCE.INCLUDE_INACTIVE_RESOURCES, 'Y', START_DATE_ACTIVE,TRUNC(SYSDATE))  BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE,TRUNC(SYSDATE))
   ) tmp
   WHERE
     tmp.revenue_category_code = l_revenue_category_code;

   CURSOR c_org_csr IS
   SELECT
   organization_name
   FROM
   pa_organizations_res_v
   WHERE
   organization_id = l_org_id ;

   -- Added for Bug 2486405.
    CURSOR c_job_csr IS
    SELECT
    'X'
    FROM
    pa_jobs_v
    WHERE job_group_id = p_job_group_id
      AND job_id = p_job_id;

BEGIN
   l_old_stack := p_err_stack;
   p_err_code  := 0;
   p_err_stack :=
   p_err_stack ||'->PA_CREATE_RESOURCE.Create_Resource_list_member';

     -- Based on the Resource_type_code Ensure that the corresponding
     -- attribute has a valid value.

    IF (p_resource_type_code = 'EMPLOYEE' AND
        p_person_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_PERSON_ID';
        RETURN;
----------- Changes done for Bug 2486405----------------------
/*    ELSIF (p_resource_type_code = 'JOB' AND
        p_job_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_JOB_ID';
        RETURN;                                        */
    ELSIF p_resource_type_code = 'JOB' THEN
       IF ( p_job_group_id IS NULL OR
            p_job_group_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
          p_err_code := 10;
          p_err_stage := 'PA_NO_JOB_GROUP_ID';  -- New Error -> A valid job Group id is required.
	  RETURN;
       ELSIF
          p_job_id IS NULL THEN
          p_err_code := 10;
          p_err_stage := 'PA_NO_JOB_ID';
          RETURN;
       ELSE
         OPEN c_job_csr;
         FETCH c_job_csr INTO l_job_exist;
         IF c_job_csr%NOTFOUND THEN
            p_err_code  := 11;
            p_err_stage := 'PA_INVALID_JOB_RELATION';
            CLOSE c_job_csr;
            RETURN;
         ELSE
            CLOSE c_job_csr;
         END IF;
	   END IF;
----------------Bug 2486405-----------------------------------
    ELSIF (p_resource_type_code = 'ORGANIZATION' AND
        p_proj_organization_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_PROJ_ORG_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'VENDOR' AND
        p_vendor_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_VENDOR_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'EXPENDITURE_TYPE' AND
        p_expenditure_type IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_EXPENDITURE_TYPE';
        RETURN;
    ELSIF (p_resource_type_code = 'EVENT_TYPE' AND
        p_event_type IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_EVENT_TYPE';
        RETURN;
    ELSIF (p_resource_type_code = 'EXPENDITURE_CATEGORY' AND
        p_expenditure_category IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_EXPENDITURE_CATEGORY';
        RETURN;
    ELSIF (p_resource_type_code = 'REVENUE_CATEGORY' AND
        p_revenue_category_code IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_REVENUE_CATEGORY';
        RETURN;
    ELSIF (p_resource_type_code = 'PROJECT_ROLE' AND
        p_project_role_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_PROJECT_ROLE_ID';
        RETURN;
    END IF;
   p_err_stage := 'Select group_resource_type_id from pa_resource_lists ';
   OPEN c_resource_lists_csr;
   FETCH c_resource_lists_csr INTO
         l_grouped_resource_type_id;
   IF c_resource_lists_csr%NOTFOUND THEN
      p_err_code  := 11;
      p_err_stage := 'PA_RL_INVALID';
      CLOSE c_resource_lists_csr;
      RETURN;
   ELSE
      CLOSE c_resource_lists_csr;
   END IF;
   IF l_grouped_resource_type_id <> 0 THEN
       -- the resource list has been grouped
       -- get the resource_type_code into grouped_by_resource_type_code
       -- from pa_resource_types using group_resource_type_id

         p_err_stage := 'Select resource_type_code from pa_resource_types ';
         OPEN c_resource_types_csr;
         FETCH c_resource_types_csr INTO
               l_grouped_resource_type_code;
         IF c_resource_types_csr%NOTFOUND THEN
            p_err_code    := 12;
            p_err_stage   := 'PA_GROUPED_RT_INVALID';
            CLOSE c_resource_types_csr;
            RETURN;
         ELSE
            CLOSE c_resource_types_csr;
         END IF;
    END IF;
  IF l_grouped_resource_type_id = 0 THEN
           -- since the resource list is not grouped,need only to return
           -- the resource_list_member_id of the input resource.Hence,first
           -- call Get_Resource_list_member to get the resource list member id.

         PA_GET_RESOURCE.Get_Resource_list_member
            (p_resource_list_id           => p_resource_list_id,
             p_resource_name              => p_resource_name,
             p_resource_type_Code         => p_resource_type_code,
             p_group_resource_type_id     => l_grouped_resource_type_id,
             p_person_id                  => p_person_id,
             p_job_id                     => p_job_id,
             p_proj_organization_id       => p_proj_organization_id,
             p_vendor_id                  => p_vendor_id,
             p_expenditure_type           => p_expenditure_type,
             p_event_type                 => p_event_type,
             p_expenditure_category       => p_expenditure_category,
             p_revenue_category_code      => p_revenue_category_code,
             p_non_labor_resource         => p_non_labor_resource,
             p_system_linkage             => p_system_linkage,
             p_parent_member_id           => NULL,
             p_project_role_id 		  => p_project_role_id,
             p_resource_id                => l_resource_id,
             p_resource_list_member_id    => l_resource_list_member_id,
             p_track_as_labor_flag        => l_track_as_labor_flag,
             p_err_code                   => l_err_code,
             p_err_stage                  => p_err_stage,
             p_err_stack                  => p_err_stack);

             IF l_err_code <> 0 THEN
                p_err_code := l_err_code;
                RETURN;
             END IF;

             IF l_resource_list_member_id IS NOT NULL THEN
                -- This means the resource has already been created as a
                -- resource list member. Hence, return the appropriate
                -- values
                p_resource_list_member_id := l_resource_list_member_id;
                p_track_as_labor_flag     := l_track_as_labor_flag;
                p_err_stack := l_old_stack;
                RETURN;
             ELSE
                 -- If the resource_list_member_id returned by
                 -- Get_Resource_list_member is null
                 -- then need to create the member;
                 -- Hence call Add_resource_list_member
                 Add_Resouce_List_Member (
                  p_resource_list_id           =>  p_resource_list_id,
                  p_resource_name              =>  p_resource_name,
                  p_resource_type_Code         =>  p_resource_type_Code,
                  p_alias                      =>  p_alias,
                  p_sort_order                 =>  p_sort_order,
                  p_display_flag               =>  p_display_flag,
                  p_enabled_flag               =>  p_enabled_flag,
                  p_person_id                  =>  p_person_id,
                  p_job_id                     =>  p_job_id,
                  p_proj_organization_id        => p_proj_organization_id,
                  p_vendor_id                  =>  p_vendor_id,
                  p_expenditure_type           =>  p_expenditure_type,
                  p_event_type                 =>  p_event_type,
                  p_expenditure_category       =>  p_expenditure_category,
                  p_revenue_category_code      =>  p_revenue_category_code,
                  p_non_labor_resource         =>  p_non_labor_resource,
                  p_system_linkage             =>  p_system_linkage,
                  p_parent_member_id           =>  NULL,
                  p_project_role_id            =>  p_project_role_id,
                  p_track_as_labor_flag        =>  l_track_as_labor_flag,
                  p_resource_id                =>  l_resource_id,
                  p_resource_list_member_id    =>  l_resource_list_member_id,
                  p_err_code                   =>  l_err_code,
                  p_err_stage                  =>  p_err_stage,
                  p_err_stack                  =>  p_err_stack );

                  IF l_err_code <> 0 THEN
                     p_err_code := l_err_code;
                     RETURN;
                  END IF;
                  p_resource_list_member_id := l_resource_list_member_id;
                  p_track_as_labor_flag     := l_track_as_labor_flag;
                  p_err_stack := l_old_stack;
                  RETURN;
             END IF;    --- IF l_resource_list_member_id IS NOT NULL

  ELSE     --  (IF l_grouped_resource_type_id is not 0 )
           -- If the resource list had been grouped
           -- the grouped_resource_type_code would determine how the
           -- resource_list had been grouped by . Need to check whether
           -- we have the right inputs

        IF (l_grouped_resource_type_code = 'EXPENDITURE_CATEGORY'
           AND p_expenditure_category IS NULL) THEN
           p_err_code    := 13;
           p_err_stage   := 'PA_EXP_CATEG_REQD';
           RETURN;
        ELSIF (l_grouped_resource_type_code = 'REVENUE_CATEGORY'
               AND p_revenue_category_code IS NULL ) THEN
               p_err_code    := 13;
               p_err_stage   := 'PA_REV_CATEG_REQD';
               RETURN;
        ELSIF (l_grouped_resource_type_code = 'ORGANIZATION'
               AND p_proj_organization_id IS NULL ) THEN
               p_err_code    := 13;
               p_err_stage   := 'PA_ORG_ID_REQD';
               RETURN;

        END IF;
        IF l_grouped_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
           l_resource_group   := p_expenditure_category;
        ELSIF
           l_grouped_resource_type_code = 'REVENUE_CATEGORY' THEN
           l_resource_group   := p_revenue_category_code;
        ELSIF
           l_grouped_resource_type_code = 'ORGANIZATION' THEN
           l_resource_group   := TO_CHAR(p_proj_organization_id);
        END IF;

             -- If l_grouped_resource_type_code = input p_resource_type_code
             -- this means this is a resource group. In that case, we
             -- need to return the resource_list_member_id and
             -- track_as_labor_flag.Parent_member_id would be null in this
             -- case. It is possible that the resource group has already
             -- been created. Hence we call Get_resource_group first
        IF l_grouped_resource_type_code = p_resource_type_code THEN
           PA_GET_RESOURCE.Get_Resource_group
                     (p_resource_list_id        => p_resource_list_id,
                      p_resource_group          => l_resource_group,
                      p_resource_list_member_id => l_group_res_list_member_id,
                      p_resource_id             => l_resource_id,
                      p_track_as_labor_flag     => l_group_track_as_labor_flag,
                      p_err_code                => l_err_code,
                      p_err_stage               => p_err_stage,
                      p_err_stack               => p_err_stack );
           IF l_err_code <> 0 THEN
              p_err_code := l_err_code;
              RETURN;
           END IF;
           IF l_group_res_list_member_id IS NOT NULL THEN
              p_resource_list_member_id := l_group_res_list_member_id;
              p_track_as_labor_flag     := l_group_track_as_labor_flag;
              p_err_stack := l_old_stack;
              RETURN;
           ELSE  -- need to create the resource_group
              Create_Resource_group (
                     p_resource_list_id        =>  p_resource_list_id,
                     p_resource_group          =>  l_resource_group,
                     p_resource_name           =>  p_resource_name,
                     p_alias                   =>  p_alias,
                     p_sort_order              =>  p_sort_order,
                     p_display_flag            =>  p_display_flag,
                     p_enabled_flag            =>  p_enabled_flag,
                     p_track_as_labor_flag     =>  l_group_track_as_labor_flag,
                     p_resource_id             =>  l_resource_id,
                     p_resource_list_member_id =>  l_group_res_list_member_id,
                     p_err_code                =>  l_err_code,
                     p_err_stage               =>  p_err_stage,
                     p_err_stack               =>  p_err_stack );
                     IF l_err_code <> 0 THEN
                        p_err_code := l_err_code;
                        RETURN;
                     END IF;
                     p_resource_list_member_id := l_group_res_list_member_id;
                     p_track_as_labor_flag     := l_group_track_as_labor_flag;
                     p_err_stack := l_old_stack;
                     RETURN;
             END IF;
        ELSE --i.e l_grouped_resource_type_code is <> p_resource_type_code
             --this means we need to return the resource_list_member_id,
             --    parent_member_id (resource_list_member_id of the
             --    resource_group) and the track_as_labor_flag of the
             --    child_resource
             -- These are the possibilities
             -- a) The resource group itself has not yet been created hence
             --    need to create the resource group as well as the
             --    child resource
             -- b) The resource_group has been created , hence need to create
             --    only the child_resource
             -- c) Both the resource_group and child_resource have been created
             --    , hence need to just return the information pertaining to
             --    the child_resource
             --Hence,
             -- to determine whether the child resource has been created
             -- we need the parent_member_id (the resource_list_member_id of
             -- the resource_group);So,call Get_resource_group first
             PA_GET_RESOURCE.Get_Resource_group
                     (p_resource_list_id        => p_resource_list_id,
                      p_resource_group          => l_resource_group,
                      p_resource_list_member_id => l_group_res_list_member_id,
                      p_resource_id             => l_resource_id,
                      p_track_as_labor_flag     => l_group_track_as_labor_flag,
                      p_err_code                => l_err_code,
                      p_err_stage               => p_err_stage,
                      p_err_stack               => p_err_stack );
                 ---  This would return the resource_list_member_id of
                 ---  the resource group (Expenditure or revenue category)
                 ---  IF the resource_list_member_id returned by
                 ---  Get_Resource_Group
                 ---  is null then the resource_group as well as
                 ---  the child resource need to be created.Hence,
                 ---  call Create_Resource_group first


              IF l_group_res_list_member_id IS NULL THEN
                 IF l_grouped_resource_type_code = 'REVENUE_CATEGORY' THEN
                 ---  If creating Revenue_category as a group, then need the
                 ---     revenue_category name ,since what is available is
                 ---     the revenue_category_code.Hence,Get the
                 ---     revenue_category_name from pa_revenue_categories_res_v
                 ---  end if;
                     l_revenue_category_code := l_resource_group ;
                     OPEN c_rev_category_csr;
                     FETCH c_rev_category_csr INTO
                           l_resource_group_name;
                     IF c_rev_category_csr%NOTFOUND THEN
                        p_err_code := 14;
                        p_err_stage := 'PA_INVALID_REV_CATEG';
                        CLOSE c_rev_category_csr;
                        RETURN;
                     ELSE
                        CLOSE c_rev_category_csr;
                     END IF;
                 ELSIF l_grouped_resource_type_code =
                         'EXPENDITURE_CATEGORY' THEN
                       l_resource_group_name := l_resource_group;
                 ELSIF l_grouped_resource_type_code = 'ORGANIZATION' THEN
                       l_org_id     := p_proj_organization_id;
                       p_err_stage :=
                       ' Select organization_name from pa_organizations_res_v';
                      -- Need to get the organization_name since what is passed
                      -- is the organization id
                      OPEN c_org_csr;
                      FETCH c_org_csr INTO l_resource_group_name;
                      IF c_org_csr%NOTFOUND THEN
                         p_err_code := 14;
                         p_err_stage := 'PA_INVALID_ORGANIZATION';
                         CLOSE c_org_csr;
                         RETURN;
                      ELSE
                          CLOSE c_org_csr;
                      END IF;
                 END IF;
                 Create_Resource_group (
                     p_resource_list_id        =>p_resource_list_id,
                     p_resource_group          =>l_resource_group,
                     p_resource_name           =>l_resource_group_name,
                     p_alias                   =>SUBSTR(l_resource_group_name,
                                                        1,30),
                     p_sort_order              =>NULL,
                     p_display_flag            =>'Y',
                     p_enabled_flag            =>'Y',
                     p_track_as_labor_flag     =>l_group_track_as_labor_flag,
                     p_resource_id             =>l_resource_id,
                     p_resource_list_member_id =>l_group_res_list_member_id,
                     p_err_code                =>l_err_code,
                     p_err_stage               =>p_err_stage,
                     p_err_stack               =>p_err_stack );
                     IF l_err_code <> 0 THEN
                        p_err_code := l_err_code;
                        RETURN;
                     END IF;
                     ---Now create the child resource,by calling
                     ---add_resource_list_member
                 Add_Resouce_List_Member (
                  p_resource_list_id           =>  p_resource_list_id,
                  p_resource_name              =>  p_resource_name,
                  p_resource_type_Code         =>  p_resource_type_Code,
                  p_alias                      =>  p_alias,
                  p_sort_order                 =>  p_sort_order,
                  p_display_flag               =>  p_display_flag,
                  p_enabled_flag               =>  p_enabled_flag,
                  p_person_id                  =>  p_person_id,
                  p_job_id                     =>  p_job_id,
                  p_proj_organization_id        =>  p_proj_organization_id,
                  p_vendor_id                  =>  p_vendor_id,
                  p_expenditure_type           =>  p_expenditure_type,
                  p_event_type                 =>  p_event_type,
                  p_expenditure_category       =>  p_expenditure_category,
                  p_revenue_category_code      =>  p_revenue_category_code,
                  p_non_labor_resource         =>  p_non_labor_resource,
                  p_system_linkage             =>  p_system_linkage,
                  p_parent_member_id           =>  l_group_res_list_member_id,
                  p_project_role_id            =>  p_project_role_id,
                  p_track_as_labor_flag        =>  l_track_as_labor_flag,
                  p_resource_id                =>  l_resource_id,
                  p_resource_list_member_id    =>  l_resource_list_member_id,
                  p_err_code                   =>  l_err_code,
                  p_err_stage                  =>  p_err_stage,
                  p_err_stack                  =>  p_err_stack );
                  IF l_err_code <> 0 THEN
                     p_err_code := l_err_code;
                     RETURN;
                  END IF;
                  p_parent_member_id         := l_group_res_list_member_id;
                  p_resource_list_member_id  := l_resource_list_member_id;
                  p_track_as_labor_flag      := l_track_as_labor_flag;
                  p_err_stack                := l_old_stack;
                  RETURN;
              ELSE -- If resource_list_member_id returned by
                   -- Get_Resource_Group is not null then
                   -- call Get_Resource_list_member to get
                   -- the resource list member
                   PA_GET_RESOURCE.Get_Resource_list_member
                     (p_resource_list_id        => p_resource_list_id,
                      p_resource_name           => p_resource_name,
                      p_resource_type_Code      => p_resource_type_code,
                      p_group_resource_type_id  => l_grouped_resource_type_id,
                      p_person_id               => p_person_id,
                      p_job_id                  => p_job_id,
                      p_proj_organization_id    => p_proj_organization_id,
                      p_vendor_id               => p_vendor_id,
                      p_expenditure_type        => p_expenditure_type,
                      p_event_type              => p_event_type,
                      p_expenditure_category    => p_expenditure_category,
                      p_revenue_category_code   => p_revenue_category_code,
                      p_non_labor_resource      => p_non_labor_resource,
                      p_system_linkage          => p_system_linkage,
                      p_parent_member_id        => l_group_res_list_member_id,
                      p_project_role_id 	=> p_project_role_id,
                      p_resource_id             => l_resource_id,
                      p_resource_list_member_id => l_resource_list_member_id,
                      p_track_as_labor_flag     => l_track_as_labor_flag,
                      p_err_code                => l_err_code,
                      p_err_stage               => p_err_stage,
                      p_err_stack               => p_err_stack);

                      IF l_err_code <> 0 THEN
                          p_err_code := l_err_code;
                          RETURN;
                      END IF;

                      IF l_resource_list_member_id IS NOT NULL THEN
                       -- This means the resource has already been created as a
                       -- resource list member. Hence, return the appropriate
                       -- values
                       p_parent_member_id        := l_group_res_list_member_id;
                       p_resource_list_member_id := l_resource_list_member_id;
                       p_track_as_labor_flag     := l_track_as_labor_flag;
                       p_err_stack := l_old_stack;
                       RETURN;
                      ELSE -- If the resource_list_member_id returned by
                          -- Get_Resource_list_member is null
                          -- then need to create the member;
                          -- Hence call Add_resource_list_member

                         Add_Resouce_List_Member (
                         p_resource_list_id      =>  p_resource_list_id,
                         p_resource_name         =>  p_resource_name,
                         p_resource_type_Code    =>  p_resource_type_Code,
                         p_alias                 =>  p_alias,
                         p_sort_order            =>  p_sort_order,
                         p_display_flag          =>  p_display_flag,
                         p_enabled_flag          =>  p_enabled_flag,
                         p_person_id             =>  p_person_id,
                         p_job_id                =>  p_job_id,
                         p_proj_organization_id   =>  p_proj_organization_id,
                         p_vendor_id             =>  p_vendor_id,
                         p_expenditure_type      =>  p_expenditure_type,
                         p_event_type            =>  p_event_type,
                         p_expenditure_category  =>  p_expenditure_category,
                         p_revenue_category_code =>  p_revenue_category_code,
                         p_non_labor_resource    =>  p_non_labor_resource,
                         p_system_linkage        =>  p_system_linkage,
                         p_parent_member_id      =>  l_group_res_list_member_id,
                         p_project_role_id       =>  p_project_role_id,
                         p_track_as_labor_flag   =>  l_track_as_labor_flag,
                         p_resource_id           =>  l_resource_id,
                         p_resource_list_member_id => l_resource_list_member_id,
                         p_err_code              =>  l_err_code,
                         p_err_stage             =>  p_err_stage,
                         p_err_stack             =>  p_err_stack );
                        IF l_err_code <> 0 THEN
                           p_err_code := l_err_code;
                           RETURN;
                        END IF;
                        p_parent_member_id        := l_group_res_list_member_id;
                        p_resource_list_member_id := l_resource_list_member_id;
                        p_track_as_labor_flag     := l_track_as_labor_flag;
                        p_err_stack := l_old_stack;
                        RETURN;
                      END IF;--end if for l_resource_list_member_id is not null
              END IF; -- end if for l_group_res_list_member_id IS NULL
        END IF;--end if for l_grouped_resource_type_code = p_resource_type_code
  END IF; -- end if for l_grouped_resource_type_id = 0

  p_err_stack := l_old_stack;

  EXCEPTION
    WHEN VALUE_ERROR THEN
         p_err_code := SQLCODE;
         RAISE;
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
        RAISE;
END Create_Resource_list_member;

      PROCEDURE Create_Resource (p_resource_name             IN  VARCHAR2,
                                 p_resource_type_Code        IN  VARCHAR2,
                                 p_description               IN  VARCHAR2,
                                 p_unit_of_measure           IN  VARCHAR2,
                                 p_rollup_quantity_flag      IN  VARCHAR2,
                                 p_track_as_labor_flag       IN  VARCHAR2,
                                 p_start_date                IN  DATE,
                                 p_end_date                  IN  DATE,
                                 p_person_id                 IN  NUMBER,
                                 p_job_id                    IN  NUMBER,
                                 p_proj_organization_id       IN  NUMBER,
                                 p_vendor_id                 IN  NUMBER,
                                 p_expenditure_type          IN  VARCHAR2,
                                 p_event_type                IN  VARCHAR2,
                                 p_expenditure_category      IN  VARCHAR2,
                                 p_revenue_category_code     IN  VARCHAR2,
                                 p_non_labor_resource        IN  VARCHAR2,
                                 p_system_linkage            IN  VARCHAR2,
                                 p_project_role_id           IN  NUMBER,
                                 p_resource_id              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_err_stack            IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_id
   FROM
   pa_resource_types_active_v
   WHERE resource_type_code = p_resource_type_code;

   CURSOR c_resource_seq_csr IS
   SELECT
   pa_resources_s.NEXTVAL
   FROM
   SYS.DUAL;


 l_err_code                     NUMBER := 0;
 l_old_stack                    VARCHAR2(2000);
 l_resource_type_id             NUMBER;
 l_resource_id                  NUMBER;
 l_resource_txn_attribute_id    NUMBER;
BEGIN

   l_old_stack := p_err_stack;
   p_err_code  := 0;
   p_err_stack := p_err_stack ||'->PA_CREATE_RESOURCE.Create_Resource';

   IF p_resource_type_code IS NULL THEN
      p_err_code   := 10;
      p_err_stage  := 'PA_RL_RES_TYPE_CODE_REQD';
      RETURN;
   END IF;

   p_err_stage := 'Select resource_type_id from pa_resource_types_active_v ';

   OPEN c_resource_types_csr;
   FETCH c_resource_types_csr INTO
         l_resource_type_id;
   IF c_resource_types_csr%NOTFOUND THEN
      p_err_code  := 11;
      p_err_stage := 'PA_RT_INVALID';
      CLOSE c_resource_types_csr;
      RETURN;
    END IF;
    CLOSE c_resource_types_csr;

    IF (p_resource_type_code = 'EMPLOYEE' AND
        p_person_id IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_PERSON_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'JOB' AND
        p_job_id IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_JOB_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'ORGANIZATION' AND
        p_proj_organization_id IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_PROJ_ORG_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'VENDOR' AND
        p_vendor_id IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_VENDOR_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'EXPENDITURE_TYPE' AND
        p_expenditure_type IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_EXPENDITURE_TYPE';
        RETURN;
    ELSIF (p_resource_type_code = 'EVENT_TYPE' AND
        p_event_type IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_EVENT_TYPE';
        RETURN;
    ELSIF (p_resource_type_code = 'EXPENDITURE_CATEGORY' AND
        p_expenditure_category IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_EXPENDITURE_CATEGORY';
        RETURN;
    ELSIF (p_resource_type_code = 'REVENUE_CATEGORY' AND
        p_revenue_category_code IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_REVENUE_CATEGORY';
        RETURN;
    ELSIF (p_resource_type_code = 'PROJECT_ROLE' AND
        p_project_role_id IS NULL) THEN
        p_err_code := 12;
        p_err_stage := 'PA_NO_PROJECT_ROLE_ID';
        RETURN;
    END IF;

    OPEN c_resource_seq_csr;
    FETCH c_resource_seq_csr INTO
          l_resource_id;
    CLOSE c_resource_seq_csr;

   p_err_stage := 'Insert into pa_resources ';

    INSERT INTO pa_resources
    (resource_id,
     name,
     description,
     resource_type_id,
     unit_of_measure,
     rollup_quantity_flag,
     track_as_labor_flag,
     start_date_active,
     end_date_active,
     last_updated_by,
     last_update_date,
     creation_date,
     created_by,
     last_update_login )
     VALUES
      (l_resource_id,
       p_resource_name,
       p_description,
       l_resource_type_id,
       p_unit_of_measure,
       p_rollup_quantity_flag,
       p_track_as_labor_flag,
       NVL(p_start_date,SYSDATE),
       p_end_date,
       g_last_updated_by,
       g_last_update_date,
       g_creation_date,
       g_created_by,
       g_last_update_login );
      -- Need to create resource txn attributes

       Create_Resource_txn_Attribute
                (p_resource_id               => l_resource_id,
                 p_resource_type_Code        => p_resource_type_code,
                 p_person_id                 => p_person_id,
                 p_job_id                    => p_job_id,
                 p_proj_organization_id      => p_proj_organization_id,
                 p_vendor_id                 => p_vendor_id,
                 p_expenditure_type          => p_expenditure_type,
                 p_event_type                => p_event_type,
                 p_expenditure_category      => p_expenditure_category,
                 p_revenue_category_code     => p_revenue_category_code,
                 p_non_labor_resource        => p_non_labor_resource,
                 p_system_linkage            => p_system_linkage,
                 p_project_role_id           => p_project_role_id,
                 p_resource_txn_attribute_id => l_resource_txn_attribute_id,
                 p_err_code                  => l_err_code,
                 p_err_stage                 => p_err_stage,
                 p_err_stack                 => p_err_stack);

         IF l_err_code <> 0 THEN
            p_err_code := l_err_code;
            RETURN;
         END IF;
   p_resource_id := l_resource_id;
   p_err_stack := l_old_stack;

   EXCEPTION
     WHEN OTHERS THEN
       p_err_code := SQLCODE;
       RAISE;

END ;

--Name:               Add_Resouce_list_member (sic)
--Type:               Procedure
--Description:        This procedure creates a resource list member...
--
--Called subprograms: ?
--
--History:
--	xx-xxx-xxxx	rkrishna		Created
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--						1. New IN-parameter, p_project_role_id, required.
--						2. New p_resource_type_code assigment
--

       PROCEDURE Add_Resouce_List_Member
                         (p_resource_list_id          IN  NUMBER,
                          p_resource_name             IN  VARCHAR2,
                          p_resource_type_Code        IN  VARCHAR2,
                          p_alias                     IN  VARCHAR2,
                          p_sort_order                IN  NUMBER,
                          p_display_flag              IN  VARCHAR2,
                          p_enabled_flag              IN  VARCHAR2,
                          p_person_id                 IN  NUMBER,
                          p_job_id                    IN  NUMBER,
                          p_proj_organization_id       IN  NUMBER,
                          p_vendor_id                 IN  NUMBER,
                          p_expenditure_type          IN  VARCHAR2,
                          p_event_type                IN  VARCHAR2,
                          p_expenditure_category      IN  VARCHAR2,
                          p_revenue_category_code     IN  VARCHAR2,
                          p_non_labor_resource        IN  VARCHAR2,
                          p_system_linkage            IN  VARCHAR2,
                          p_parent_member_id          IN  NUMBER,
                          p_project_role_id           IN  NUMBER,
                          p_track_as_labor_flag      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_resource_id              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_resource_list_member_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_code                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_stage             IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_stack             IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_err_code                     NUMBER := 0;
   l_sort_order                   NUMBER := 0;
   l_resource_id                  NUMBER := 0;
   l_resource_list_member_id      NUMBER := 0;
   l_old_stack                    VARCHAR2(2000);
   l_grouped_resource_type_id     NUMBER := 0;
   l_grouped_res_type_code        VARCHAR2(80);
   l_attr_value                   VARCHAR2(80);
   l_exp_category                 VARCHAR2(80);
   l_exp_type                     VARCHAR2(80);
   l_revenue_category_code        VARCHAR2(80);
   l_parent_track_as_labor_flag   VARCHAR2(1);
   l_track_as_labor_flag          VARCHAR2(1);
   l_dummy                        VARCHAR2(1);
   l_Uom                          VARCHAR2(30);
   l_rollup_qty_flag              VARCHAR2(1);
   l_get_new_sort_order           VARCHAR2(10) := 'FALSE';
   l_resource_type_code           VARCHAR2(30);
   l_resource_name                VARCHAR2(80);
   l_alias                        VARCHAR2(30);
   l_new_track_as_labor_flag      VARCHAR2(1);
   l_org_id	                  NUMBER := NULL;
   l_resource_type_id             pa_resource_types.resource_type_id%TYPE;
   l_person_id                    pa_resource_txn_attributes.person_id%TYPE;
   l_job_id                       pa_resource_txn_attributes.job_id%TYPE;
   l_organization_id              pa_resource_txn_attributes.organization_id%TYPE;
   l_vendor_id                    pa_resource_txn_attributes.vendor_id%TYPE;
   l_project_role_id              pa_resource_txn_attributes.project_role_id%TYPE;
   l_expenditure_type             pa_resource_txn_attributes.expenditure_type%TYPE;
   l_event_type                   pa_resource_txn_attributes.event_type%TYPE;
   l_expenditure_category         pa_resource_txn_attributes.expenditure_category%TYPE;
   l_revenue_category             pa_resource_txn_attributes.revenue_category%TYPE;
   l_nlr_resource                 pa_resource_txn_attributes.non_labor_resource%TYPE;
   l_nlr_res_org_id               pa_resource_txn_attributes.non_labor_resource_org_id%TYPE;
   l_event_type_cls               pa_resource_txn_attributes.event_type_classification%TYPE;
   l_system_link_function         pa_resource_txn_attributes.system_linkage_function%TYPE;
   l_resource_format_id           pa_resource_txn_attributes.resource_format_id%TYPE;
   l_res_type_code                pa_resource_types.resource_type_code%TYPE;


   CURSOR c_res_list_csr IS
   SELECT
   group_resource_type_id
   FROM
   pa_resource_lists_all_bg
   WHERE resource_list_id = p_resource_list_id;

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_code
   FROM
   pa_resource_types
   WHERE resource_type_id = l_grouped_resource_type_id;

   CURSOR c_exp_categ_csr IS
   SELECT
   rta.expenditure_category
   FROM
   pa_resource_list_members rlm,
   pa_resources re,
   pa_resource_txn_attributes rta
   WHERE rlm.resource_list_member_id = p_parent_member_id
   AND   rlm.resource_id             = re.resource_id
   AND   re.resource_id              = rta.resource_id;

   CURSOR c_rev_categ_csr IS
   SELECT
   rta.revenue_category
   FROM
   pa_resource_list_members rlm,
   pa_resources re,
   pa_resource_txn_attributes rta
   WHERE rlm.resource_list_member_id = p_parent_member_id
   AND   rlm.resource_id             = re.resource_id
   AND   re.resource_id              = rta.resource_id;

   CURSOR c_exp_types_csr_1 IS
   SELECT
   expenditure_type
   FROM
   pa_expenditure_types_res_v
   WHERE expenditure_type = p_expenditure_type
   AND   expenditure_category =  l_exp_category;


   CURSOR c_exp_types_csr_2 IS
   SELECT
   expenditure_type
   FROM
   pa_expenditure_types_res_v
   WHERE expenditure_type = p_expenditure_type
   AND   revenue_category_code =  l_revenue_category_code;

   CURSOR c_event_types_csr IS
   SELECT
   event_type
   FROM
   pa_event_types_res_v
   WHERE event_type = p_event_type
   AND   revenue_category_code =  l_revenue_category_code;


   CURSOR c_res_list_member_csr_1 IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id = p_parent_member_id
   AND   sort_order = p_sort_order;

   CURSOR c_res_list_member_csr_1a IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   sort_order = p_sort_order;

   CURSOR c_res_list_member_csr_2 IS
   SELECT
   NVL(MAX(sort_order),0)+10
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id = p_parent_member_id
   AND   sort_order < 999999;

   CURSOR c_res_list_member_csr_2a IS
   SELECT
   NVL(MAX(sort_order),0)+10
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   sort_order < 999999;

   CURSOR c_res_list_member_csr_3 IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id = p_parent_member_id
   AND   alias = p_alias;

   CURSOR c_res_list_member_csr_3a IS
   SELECT 'x'
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   alias = p_alias;

   CURSOR c_res_list_member_csr_4 IS
   SELECT track_as_labor_flag
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   resource_list_member_id = p_parent_member_id;

   CURSOR c_res_list_member_seq_csr IS
   SELECT
   pa_resource_list_members_s.NEXTVAL
   FROM SYS.DUAL;

  --Cursor added for resolution of bug 1889671

   CURSOR Cur_TXn_Attributes(p_resource_id  PA_RESOURCES.RESOURCE_ID%TYPE) IS
   SELECT prta.person_id,
         prta.job_id,
         prta.organization_id,
         prta.vendor_id,
         prta.project_role_id,
         prta.expenditure_type,
         prta.event_type,
         prta.expenditure_category,
         prta.revenue_category,
         prta.non_labor_resource,
         prta.non_labor_resource_org_id,
         prta.event_type_classification,
         prta.system_linkage_function,
         prta.resource_format_id,
         prt.resource_type_id,
         prt.resource_type_code
  FROM   PA_RESOURCE_TXN_ATTRIBUTES PRTA,
         PA_RESOURCES PR,
         PA_RESOURCE_TYPES PRT
  WHERE  prta.resource_id = pr.resource_id
    AND  pr.resource_id =P_RESOURCE_ID
    AND  pr.resource_type_id= prt.resource_type_id;

--Outer Join is removed from above cursor as this code is not used to create unclassified
--resource

-- Following block of code is added for the resolution of bug 1889671
-- Same logic  is used as it is done in PA_GET_RESOURCE.Get_Unclassified_Resource
-- Start of change

    CURSOR Cur_Unclassified_Resource_List IS
    SELECT prt.resource_type_id,prt.resource_type_code
    FROM pa_resources pr, pa_resource_types prt
    WHERE prt.resource_type_code='UNCLASSIFIED'
    AND pr.resource_type_id = prt.resource_type_id;

BEGIN
  l_old_stack := p_err_stack;
  p_err_code  := 0;
  p_err_stack := p_err_stack||'->PA_CREATE_RESOURCE.add_resource_list_member';
  p_err_stage := ' Select group_resource_type_id from pa_resource_lists';

    -- Get Resource List Id ,Group_resource_type_id from
    -- PA_RESOURCE_LISTS with the
    -- X_Resource_list_id.
       OPEN c_res_list_csr;
       FETCH c_res_list_csr INTO
             l_grouped_resource_type_id;
       IF c_res_list_csr%NOTFOUND THEN
          p_err_code := 10;
          p_err_stage := 'PA_RL_INVALID';
          CLOSE c_res_list_csr;
          RETURN;
       END IF;

       CLOSE c_res_list_csr;
   --- If grouped_resource_type_id = 0,that means the resource list
   --- is not grouped.In that case,parent member id should be null
   --- else , parent_member_id should not be null

       IF l_grouped_resource_type_id = 0 AND
          p_parent_member_id IS NOT NULL THEN
          p_err_code := 11;
          p_err_stage := 'PA_RL_NOT_GROUPED';
          RETURN;
       ELSIF
          l_grouped_resource_type_id <> 0 AND
          p_parent_member_id IS NULL THEN
          p_err_code := 12;
          p_err_stage := 'PA_RL_GROUPED';
          RETURN;
       END IF;

       IF l_grouped_resource_type_id <> 0 THEN
          p_err_stage := ' Select resource_type_code from pa_resource_types';
          OPEN c_resource_types_csr;
          FETCH c_resource_types_csr INTO
                l_grouped_res_type_code;
          IF c_resource_types_csr%NOTFOUND THEN
             p_err_code := 13;
             p_err_stage := 'PA_RT_INVALID';
             CLOSE c_resource_types_csr;
             RETURN;
          END IF;
          CLOSE c_resource_types_csr;
       END IF;
          --- If parent_member_id is not null then
          --- Based on the resource_type_code get the Expenditure_category or
          --- Revenue_Category_code of the parent
          --- end if;
       IF p_parent_member_id IS NOT NULL THEN
          IF  l_grouped_res_type_code = 'EXPENDITURE_CATEGORY' THEN
              p_err_stage := 'Select expenditure_category from ....';
              OPEN c_exp_categ_csr;
              FETCH c_exp_categ_csr INTO
                    l_exp_category;
              CLOSE c_exp_categ_csr;
          ELSIF l_grouped_res_type_code = 'REVENUE_CATEGORY' THEN
              p_err_stage := 'Select revenue_category_code from ....';
              OPEN c_rev_categ_csr;
              FETCH c_rev_categ_csr INTO
                    l_revenue_category_code;
              CLOSE c_rev_categ_csr;
          END IF;
       END IF;

        ---If the resource_list had been grouped by Expenditure_Category or
        ---Revenue_category
        --- If the p_resource_type_code = 'EXPENDITURE_TYPE'
        ---   then ensure that the input resource (the resource which is
        ---   sought to be created as a resource list member )
        ---   is valid under that Expenditure_Category or Revenue_Category
        ---   If not then
        ---      RAISE_ERROR;
        ---   end if;
        --- end if;
        ---End if;
        --- Eg : An Expenditure_Type of 'Professional' is valid under
        --- Resource_Group 'Labor' but an Expenditure_Type of 'Air Travel'
        --- is invalid.  This is because, the Expenditure_Type of 'Air Travel'
        --- does not have an expenditure_Category of 'Labor' and hence
        --- cannot be specified under the Resource_Group of 'Labor'

        --- If the resource list had been grouped by Revenue Category
        ---     If the p_resource_type_code = 'EVENT_TYPE'
        ---        then ensure that the input resource (the resource which is
        ---   is valid under that Revenue_Category
        ---   If not then
        ---      RAISE_ERROR;
        ---   end if;
        --- end if;
        --- Eg: An Event_Type of 'Surcharge' is valid under
        --- Resource Group 'Fee' but an event Type of 'Bonus'
        --- is invalid. This is because, the Event type of 'Bonus'
        --- does not have a Revenue category of 'Fee' and hence
        --- cannot be specified under the Resource_Group of 'Fee'

       IF p_parent_member_id IS NOT NULL THEN
          p_err_stage :=
          'Select expenditure_type from pa_expenditure_types_res_v';
          IF  l_grouped_res_type_code = 'EXPENDITURE_CATEGORY' AND
              p_resource_type_code    = 'EXPENDITURE_TYPE'     THEN
              OPEN c_exp_types_csr_1;
              FETCH c_exp_types_csr_1 INTO l_exp_type;
              IF c_exp_types_csr_1%NOTFOUND THEN
                 p_err_code := 14;
                 p_err_stage := 'PA_ET_INV_FOR_EXP_CATEG';
                 CLOSE c_exp_types_csr_1;
                 RETURN;
              ELSE
                 CLOSE c_exp_types_csr_1;
              END IF;
          ELSIF l_grouped_res_type_code = 'REVENUE_CATEGORY' AND
                p_resource_type_code    = 'EXPENDITURE_TYPE'     THEN
              OPEN c_exp_types_csr_2;
              FETCH c_exp_types_csr_2 INTO
                    l_exp_type;
              IF c_exp_types_csr_2%NOTFOUND THEN
                 p_err_code := 14;
                 p_err_stage := 'PA_ET_INV_FOR_REV_CATEG';
                 CLOSE c_exp_types_csr_2;
                 RETURN;
              ELSE
                 CLOSE c_exp_types_csr_2;
              END IF;
          ELSIF l_grouped_res_type_code = 'REVENUE_CATEGORY' AND
                p_resource_type_code    = 'EVENT_TYPE'     THEN
          p_err_stage :=
          'Select event_type from pa_event_types_res_v';
              OPEN c_event_types_csr;
              FETCH c_event_types_csr INTO
                    l_event_type;
              IF c_event_types_csr%NOTFOUND THEN
                 p_err_code := 14;
                 p_err_stage := 'PA_EVENT_INV_FOR_REV_CATEG';
                 CLOSE c_event_types_csr;
                 RETURN;
              ELSE
                 CLOSE c_event_types_csr;
              END IF;
          END IF;
       END IF;

    p_err_stage := ' Select x  from pa_resource_list_members';

       IF (p_sort_order IS NULL OR p_sort_order = 0) THEN
           l_get_new_sort_order := 'TRUE';
       END IF;

     -- Check whether sort_order is unique
     IF (p_sort_order IS NOT NULL AND p_sort_order > 0 ) THEN
       IF p_parent_member_id IS NULL THEN
          OPEN c_res_list_member_csr_1a;
          FETCH c_res_list_member_csr_1a INTO
                l_dummy;
          IF c_res_list_member_csr_1a%FOUND THEN
                l_get_new_sort_order := 'TRUE';
          ELSE
                l_sort_order := p_sort_order;
          END IF;
          CLOSE c_res_list_member_csr_1a;
       ELSE
          OPEN c_res_list_member_csr_1;
          FETCH c_res_list_member_csr_1 INTO
                l_dummy;
          IF c_res_list_member_csr_1%FOUND THEN
                l_get_new_sort_order := 'TRUE';
          ELSE
                l_sort_order := p_sort_order;
          END IF;
          CLOSE c_res_list_member_csr_1;
       END IF;
     END IF;

     IF l_get_new_sort_order = 'TRUE' THEN
       p_err_stage := ' Select max(sort_order) from pa_resource_list_members';
       IF p_parent_member_id IS NULL THEN
          OPEN c_res_list_member_csr_2a;
          FETCH c_res_list_member_csr_2a INTO
                l_sort_order;
          CLOSE c_res_list_member_csr_2a;
       ELSE
          OPEN c_res_list_member_csr_2;
          FETCH c_res_list_member_csr_2 INTO
                l_sort_order;
          CLOSE c_res_list_member_csr_2;
       END IF;
     END IF;

       IF LENGTH(p_alias) > 0 THEN
          l_alias := SUBSTR(p_alias,1,30);
       ELSE
          l_alias := p_alias;
       END IF;
     -- Check whether alias is unique

     IF (p_alias IS NOT NULL ) THEN
        p_err_stage := ' Select x  from pa_resource_list_members - alias';
       IF p_parent_member_id IS NULL THEN
          OPEN c_res_list_member_csr_3a;
          FETCH c_res_list_member_csr_3a INTO
                l_dummy;
          IF c_res_list_member_csr_3a%FOUND THEN
                l_alias := SUBSTR(p_resource_name,1,30);
          END IF;
          CLOSE c_res_list_member_csr_3a;
       ELSE
          OPEN c_res_list_member_csr_3;
          FETCH c_res_list_member_csr_3 INTO
                l_dummy;
          IF c_res_list_member_csr_3%FOUND THEN
                l_alias := SUBSTR(p_resource_name,1,30);
          END IF;
          CLOSE c_res_list_member_csr_3;
       END IF;
     ELSE
        l_alias := SUBSTR(p_resource_name,1,30);
     END IF;

     -- Track_as_labor_flag of the child resource is dependent on the parent's
     -- track_as_labor_flag. Hence, need to get the parent's
     -- track_as_labor_flag;

     IF p_parent_member_id IS NOT NULL THEN
        p_err_stage :=
        'Select track_as_labor_flag from pa_resource_list_members';
        OPEN c_res_list_member_csr_4;
        FETCH c_res_list_member_csr_4 INTO
              l_parent_track_as_labor_flag;
        IF  c_res_list_member_csr_4%NOTFOUND THEN
            CLOSE c_res_list_member_csr_4;
            RAISE NO_DATA_FOUND;
        END IF;
     END IF;

     --- Check whether the child resource has already been created as
     --- a resource in PA_RESOURCES table and get the resource_id.

    PA_GET_RESOURCE.Get_Resource
                 (p_resource_name           => p_resource_name,
                  p_resource_type_Code      => p_resource_type_code,
                  p_person_id               => p_person_id,
                  p_job_id                  => p_job_id,
                  p_proj_organization_id    => p_proj_organization_id,
                  p_vendor_id               => p_vendor_id,
                  p_expenditure_type        => p_expenditure_type,
                  p_event_type              => p_event_type,
                  p_expenditure_category    => p_expenditure_category,
                  p_revenue_category_code   => p_revenue_category_code,
                  p_non_labor_resource      => p_non_labor_resource,
                  p_system_linkage          => p_system_linkage,
                  p_project_role_id	    => p_project_role_id,
                  p_resource_id             => l_resource_id,
                  p_err_code                => l_err_code,
                  p_err_stage               => p_err_stage,
                  p_err_stack               => p_err_stack );

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;

       /* For bug # 818076 fix moved this code outside the if condition */

       IF p_resource_type_code = 'EMPLOYEE' THEN
            l_attr_value := TO_CHAR(p_person_id );
         ELSIF p_resource_type_code = 'JOB' THEN
            l_attr_value := TO_CHAR(p_job_id) ;
         ELSIF p_resource_type_code = 'ORGANIZATION' THEN
            l_attr_value := TO_CHAR(p_proj_organization_id) ;
         ELSIF p_resource_type_code = 'VENDOR' THEN
            l_attr_value := TO_CHAR(p_vendor_id) ;
         ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
            l_attr_value := p_expenditure_type ;
         ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
            l_attr_value := p_event_type ;
         ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
            l_attr_value := p_expenditure_category ;
         ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
            l_attr_value := p_revenue_category_code ;
         ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
            l_attr_value := TO_CHAR(p_project_role_id) ;
       END IF;

       PA_GET_RESOURCE.Get_Resource_Information
               (p_resource_type_Code   =>  p_resource_type_code,
                p_resource_attr_value  =>  l_attr_value,
                p_unit_of_measure      =>  l_uom,
                p_Rollup_quantity_flag =>  l_rollup_qty_flag,
                p_track_as_labor_flag  =>  l_track_as_labor_flag,
                p_err_code             =>  l_err_code,
                p_err_stage            =>  p_err_stage,
                p_err_stack            =>  p_err_stack);

        IF l_err_code <> 0 THEN
           p_err_code := l_err_code;
           RETURN;
        END IF;
       /* End of bug # 818076 fix */

      IF l_resource_id IS NULL THEN

      -- If the child resource has not been created as a resource yet,then
      -- need to create the resource.Hence,get the necessary information
      -- from base views. Based on the resource_type_code,need to pass the
      -- person_id or job_id etc. Hence,

         /* For bug # 818076 fix moved this code outside the if condition
            as track_as_labor flag should be assigned for resource_groups
            being inserted into resource_member_list table */
         /*  Comment starts ********************

         IF p_resource_type_code = 'EMPLOYEE' THEN
            l_attr_value := to_char(p_person_id );
         ELSIF p_resource_type_code = 'JOB' THEN
            l_attr_value := to_char(p_job_id) ;
         ELSIF p_resource_type_code = 'ORGANIZATION' THEN
            l_attr_value := to_char(p_proj_organization_id) ;
         ELSIF p_resource_type_code = 'VENDOR' THEN
            l_attr_value := to_char(p_vendor_id) ;
         ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
            l_attr_value := p_expenditure_type ;
         ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
            l_attr_value := p_event_type ;
         ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
            l_attr_value := p_expenditure_category ;
         ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
            l_attr_value := p_revenue_category_code ;
         END IF;

         PA_GET_RESOURCE.Get_Resource_Information
               (p_resource_type_Code   =>  p_resource_type_code,
                p_resource_attr_value  =>  l_attr_value,
                p_unit_of_measure      =>  l_uom,
                p_Rollup_quantity_flag =>  l_rollup_qty_flag,
                p_track_as_labor_flag  =>  l_track_as_labor_flag,
                p_err_code             =>  l_err_code,
                p_err_stage            =>  p_err_stage,
                p_err_stack            =>  p_err_stack);

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;
           *********** Comment ends, # 818076   */

          Create_Resource
                (p_resource_name            => p_resource_name,
                 p_resource_type_Code       => p_resource_type_code,
                 p_description              => p_resource_name,
                 p_unit_of_measure          => l_uom,
                 p_rollup_quantity_flag     => l_rollup_qty_flag,
                 p_track_as_labor_flag      => l_track_as_labor_flag,
                 p_start_date               => SYSDATE,
                 p_end_date                 => NULL,
                 p_person_id                => p_person_id,
                 p_job_id                   => p_job_id,
                 p_proj_organization_id     => p_proj_organization_id,
                 p_vendor_id                => p_vendor_id,
                 p_expenditure_type         => p_expenditure_type,
                 p_event_type               => p_event_type,
                 p_expenditure_category     => p_expenditure_category,
                 p_revenue_category_code    => p_revenue_category_code,
                 p_non_labor_resource       => p_non_labor_resource,
                 p_system_linkage           => p_system_linkage,
                 p_project_role_id          => p_project_role_id,
                 p_resource_id              => l_resource_id,
                 p_err_code                 => l_err_code,
                 p_err_stage                => p_err_stage,
                 p_err_stack                => p_err_stack );

              IF l_err_code <> 0 THEN
                 p_err_code := l_err_code;
                 RETURN;
              END IF;
      END IF;  -- (IF l_resource_id IS NULL )
      -- Tracking a Resource as  Labor within the context of a Resource List
      --   is treated as follows.
      --   If resource's track_as_labor_flag = 'Y' then
      --      if parent_member_id is not null then
      --         if parent_track_as_labor_flag = 'Y'
      --            then Resource List Member Track_As_Labor_Flag = 'Y'
      --         else
      --            Resource List Member Track_As_Labor_Flag = 'N'
      --       end if;
      --    else
      --      Resource List Member Track_As_Labor_Flag = 'Y'
      --    end if;
      -- else
      --      Resource List Member Track_As_Labor_Flag = 'N'
      -- end if ;

      IF l_track_as_labor_flag = 'Y' THEN
         IF p_parent_member_id IS NOT NULL THEN
            IF l_parent_track_as_labor_flag = 'Y' THEN
               l_new_track_as_labor_flag := 'Y';
            ELSE
               l_new_track_as_labor_flag := 'N';
            END IF;
         ELSE -- (if parent member id is null)
            l_new_track_as_labor_flag := 'Y';
         END IF;
      ELSE -- (if l_track_as_labor_flag = 'N')
         l_new_track_as_labor_flag := 'N';
      END IF;

  -- Need to generate the resource_list_member_id
     p_err_stage := 'Select pa_resource_list_members_s.nextval ';

      OPEN c_res_list_member_seq_csr;
      FETCH c_res_list_member_seq_csr INTO
            l_resource_list_member_id;
      IF c_res_list_member_seq_csr%NOTFOUND THEN
         CLOSE c_res_list_member_seq_csr;
         RAISE NO_DATA_FOUND;
      ELSE
         CLOSE c_res_list_member_seq_csr;
      END IF;

     p_err_stage := 'Insert into pa_resource_list_members ';

     /*Changes done for Resource Mapping Enhancements */

    OPEN Cur_Txn_Attributes(l_resource_id);
    FETCH Cur_Txn_Attributes
    INTO l_person_id,
         l_job_id,
         l_organization_id,
         l_vendor_id,
         l_project_role_id,
         l_expenditure_type,
         l_event_type,
         l_expenditure_category,
         l_revenue_category,
         l_nlr_resource,
         l_nlr_res_org_id,
         l_event_type_cls,
         l_system_link_function,
         l_resource_format_id,
         l_resource_type_id,
         l_res_type_code;
   CLOSE Cur_Txn_Attributes;


      INSERT INTO pa_resource_list_members
      (resource_list_id,
       resource_list_member_id,
       resource_id,
       alias,
       parent_member_id,
       sort_order,
       member_level,
       display_flag,
       enabled_flag,
       track_as_labor_flag,
       last_updated_by,
       last_update_date,
       creation_date,
       created_by,
       last_update_login,
       PERSON_ID,
       JOB_ID,
       ORGANIZATION_ID,
       VENDOR_ID,
       PROJECT_ROLE_ID,
       EXPENDITURE_TYPE,
       EVENT_TYPE,
       EXPENDITURE_CATEGORY,
       REVENUE_CATEGORY,
       NON_LABOR_RESOURCE,
       NON_LABOR_RESOURCE_ORG_ID,
       EVENT_TYPE_CLASSIFICATION,
       SYSTEM_LINKAGE_FUNCTION,
       RESOURCE_FORMAT_ID,
       RESOURCE_TYPE_ID,
       RESOURCE_TYPE_CODE
       )
       VALUES (
       p_resource_list_id,
       l_resource_list_member_id,
       l_resource_id,
       l_alias,
       p_parent_member_id,
       l_sort_order,
       DECODE(p_parent_member_id,NULL,1,2),
       NVL(p_display_flag,'Y'),
       NVL(p_enabled_flag,'Y'),
       l_new_track_as_labor_flag,
       g_last_updated_by,
       g_last_update_date,
       g_creation_date,
       g_created_by,
       g_last_update_login,
       l_person_id,
       l_job_id,
       l_organization_id,
       l_vendor_id,
       l_project_role_id,
       l_expenditure_type,
       l_event_type,
       l_expenditure_category,
       l_revenue_category,
       l_nlr_resource,
       l_nlr_res_org_id,
       l_event_type_cls,
       l_system_link_function,
       l_resource_format_id,
       l_resource_type_id,
       l_res_type_code
       );

        p_resource_list_member_id := l_resource_list_member_id;
        p_track_as_labor_flag     := l_new_track_as_labor_flag;
        p_resource_id             := l_resource_id;


        -- Each resource_group needs to have at least one unclassified
        -- resource as a child resource. However, this is true only if
        -- the resource_group has at least one child resource. Hence
        -- need to check whether the unclassified resource has already
        -- been created.
        IF p_parent_member_id IS NOT NULL THEN
           PA_GET_RESOURCE.Get_Unclassified_Resource
                          (p_resource_id            => l_resource_id,
                           p_resource_name          => l_resource_name,
                           p_track_as_labor_flag    => l_track_as_labor_flag,
                           p_unit_of_measure        => l_uom,
                           p_rollup_quantity_flag   => l_rollup_qty_flag,
                           p_err_code               => l_err_code,
                           p_err_stage              => p_err_stage,
                           p_err_stack              => p_err_stack );

           IF l_err_code <> 0 THEN
              p_err_code := l_err_code;
              RETURN;
           END IF;
           PA_GET_RESOURCE.Get_Unclassified_Member
               (p_resource_list_id            => p_resource_list_id,
                p_parent_member_id            => p_parent_member_id,
                p_unclassified_resource_id    => l_resource_id,
                p_resource_list_member_id     => l_resource_list_member_id,
                p_track_as_labor_flag         => l_new_track_as_labor_flag,
                p_err_code                    => l_err_code,
                p_err_stage                   => p_err_stage,
                p_err_stack                   => p_err_stack );

            IF l_err_code <> 0 THEN
               p_err_code := l_err_code;
               RETURN;
            END IF;

            IF l_resource_list_member_id IS NULL THEN
             p_err_stage := 'Insert into pa_resource_list_members ';

             -- Following block of code is added for the resolution of bug 1889671

               OPEN Cur_Unclassified_Resource_List;
               FETCH Cur_Unclassified_Resource_List INTO  l_resource_type_id , l_resource_type_code;
               CLOSE Cur_Unclassified_Resource_List;

               INSERT INTO pa_resource_list_members
               (resource_list_id,
                resource_list_member_id,
                resource_id,
                alias,
                parent_member_id,
                sort_order,
                member_level,
                display_flag,
                enabled_flag,
                track_as_labor_flag,
                resource_type_id,
                resource_type_code,
                last_updated_by,
                last_update_date,
                creation_date,
                created_by,
                last_update_login )

                VALUES (
                p_resource_list_id,
                pa_resource_list_members_s.NEXTVAL,
                l_resource_id,
                l_resource_name,
                p_parent_member_id,
                999999,
                2,
                'N',
                'Y',
                l_track_as_labor_flag,
                l_resource_type_id,
                l_resource_type_code,
                g_last_updated_by,
                g_last_update_date,
                g_creation_date,
                g_created_by,
                g_last_update_login );
            END IF;

        END IF;

    p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
        RAISE;
END Add_Resouce_List_Member;

--##
--  PROCEDURE  Create_Default_Res_List
--
--  This procedure creates default Resource Lists for a specified business
--  group.  If a value is not passed for the X_BUSINESS_GROUP_ID parameter,
--  then the business group used is the business group defined in the
--  implementation options for the current operating unit.
--
--  PA seeds default Resource Lists upon install with a dummy
--  BUSINESS_GROUP_ID of -3113.  Whenever a new operating unit is
--  implemented in PA (ie, a new record is created in PA_IMPLEMENTATIONS),
--  this procedure is called to copy the seeded resource list data to the
--  business group.
--
--  Arguments:
--    X_business_group_id   Identifier of the business group specified for
--                          the Operating Unit.
--
--  History:
--    16-AUG-96  Z. Connors   Created.
--
--    17-OCT-02  jwhite		Bug 2619122
--                              Rewrote logic to populate the following new
--                              columns from the source tables as directed
--                              by Ramesh:
--                              - RESOURCE_TYPE_ID       NUMBER(15)
--                              - RESOURCE_TYPE_CODE     VARCHAR2(30)
--    23-Nov-04  smullapp       Rewrote logic to populate the foll columns
--                              migration_code,use_for_wp_flag,control_flag,
--                              record_version_number(see bug: 4025330).


  PROCEDURE Create_Default_Res_List ( X_business_group_id   IN NUMBER
                                    , X_err_code            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    , X_err_stage           IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    , X_err_stack           IN OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS
    V_old_stack          VARCHAR2(2000);
    X_resource_list_id   NUMBER(15);
    X_user_id            NUMBER(15);
    X_login_id           NUMBER(15);

    CURSOR Seeded_RLs
    IS
    SELECT resource_list_id,
           name, description, public_flag, group_resource_type_id,
           start_date_active, end_date_active, uncategorized_flag,
           control_flag,migration_code,use_for_wp_flag,
           last_updated_by, last_update_date, creation_date,
           created_by, last_update_login
      FROM pa_resource_lists_all_bg
     WHERE business_group_id = -3113;

  BEGIN

    X_user_id := NVL( fnd_global.user_id, 1 );
    X_login_id := NVL( fnd_global.login_id, 0 );

    V_old_stack := X_err_stack;
    X_err_code := 0;
    X_err_stack :=
          X_err_stack ||'->PA_CREATE_RESOURCE.Create_Default_Res_List';

    X_err_stage := 'Select seeded_resource_list From PA_RESOURCE_LISTS';

    FOR  eachRL  IN  Seeded_RLs  LOOP

      X_err_stage := 'Select pa_resource_lists_s.NEXTVAL From Dual';

      SELECT pa_resource_lists_s.NEXTVAL
        INTO X_resource_list_id
        FROM sys.dual;

      X_err_stage := 'Insert Into PA_RESOURCE_LISTS';

      INSERT INTO pa_resource_lists_all_bg (
          resource_list_id
      ,   name
      ,   business_group_id
      ,   description
      ,   public_flag
      ,   group_resource_type_id
      ,   start_date_active
      ,   end_date_active
      ,   uncategorized_flag
      ,   control_flag
      ,   use_for_wp_flag
      ,   migration_code
      ,   last_updated_by
      ,   last_update_date
      ,   creation_date
      ,   created_by
      ,   last_update_login
      ,   record_version_number )
      SELECT
              X_resource_list_id
      ,       eachRL.name
      ,    NVL(X_business_group_id, fnd_profile.value('PER_BUSINESS_GROUP_ID'))
      ,       eachRL.description
      ,       eachRL.public_flag
      ,       eachRL.group_resource_type_id
      ,       eachRL.start_date_active
      ,       eachRL.end_date_active
      ,       eachRL.uncategorized_flag
      ,       eachRL.control_flag
      ,       eachRL.use_for_wp_flag
      ,       eachRL.migration_code
      ,       X_user_id
      ,       SYSDATE
      ,       SYSDATE
      ,       X_user_id
      ,       X_login_id
      ,       1 -- record version number
        FROM
              sys.dual
       WHERE NOT EXISTS (
          SELECT NULL
            FROM pa_resource_lists rl
           WHERE business_group_id =
                 NVL(X_business_group_id,
                     fnd_profile.value('PER_BUSINESS_GROUP_ID'))
             AND rl.name = eachRL.name );

        --Adding to TL
         INSERT into pa_resource_lists_tl (
                             last_update_login,
                             creation_date,
                             created_by,
                             last_update_date,
                             last_updated_by,
                             resource_list_id,
                             name,
                             description,
                             language,
                             source_lang
                       ) SELECT
                             x_login_id,
                             sysdate,
                             x_user_id,
                             sysdate,
                             X_user_id,
                             x_resource_list_id,
                             eachRL.name,
                             NVL(eachRL.description,eachRL.name),
                             L.LANGUAGE_CODE,
                             userenv('LANG')
                        FROM FND_LANGUAGES L
                        WHERE L.INSTALLED_FLAG in ('I', 'B')
                        and not exists
                            (select NULL
                            from pa_resource_lists_tl T
                            where T.RESOURCE_LIST_ID = X_RESOURCE_LIST_ID);

      X_err_stage := 'Insert Into PA_RESOURCE_LIST_MEMBERS';

      INSERT INTO pa_resource_list_members (
          resource_list_member_id
      ,   resource_list_id
      ,   resource_id
      ,   alias
      ,   parent_member_id
      ,   sort_order
      ,   member_level
      ,   display_flag
      ,   enabled_flag
      ,   track_as_labor_flag
      ,   last_updated_by
      ,   last_update_date
      ,   creation_date
      ,   created_by
      ,   last_update_login
      ,   RESOURCE_TYPE_ID
      ,   RESOURCE_TYPE_CODE
      ,   object_type
      ,   object_id
      ,   RESOURCE_CLASS_ID
      ,   RES_FORMAT_ID
      ,   SPREAD_CURVE_ID
      ,   ETC_METHOD_CODE
      ,   RES_TYPE_CODE
      ,   RESOURCE_CLASS_CODE
      ,   RESOURCE_CLASS_FLAG
      ,   MIGRATION_CODE
      ,   RECORD_VERSION_NUMBER
      ,   INCURRED_BY_RES_FLAG
      ,   WP_ELIGIBLE_FLAG
      ,   UNIT_OF_MEASURE
      )
      SELECT pa_resource_list_members_s.NEXTVAL
      ,       X_resource_list_id
      ,       rlm.resource_id
      ,       rlm.alias
      ,       rlm.parent_member_id
      ,       rlm.sort_order
      ,       rlm.member_level
      ,       rlm.display_flag
      ,       rlm.enabled_flag
      ,       rlm.track_as_labor_flag
      ,       X_user_id
      ,       SYSDATE
      ,       SYSDATE
      ,       X_user_id
      ,       X_login_id
              --For bug 4025330
      ,       decode(rlm.resource_id, -99, null,rlm.resource_type_id)
      ,       decode(rlm.resource_id, -99, null,rlm.resource_type_code)
      ,       rlm.object_type
      ,       X_resource_list_id   -- object ID has to be the new resource list ID - that's why we can't copy over the object ID.
      ,       rlm.RESOURCE_CLASS_ID
      ,       rlm.RES_FORMAT_ID
      ,       rlm.SPREAD_CURVE_ID
      ,       rlm.ETC_METHOD_CODE
      ,       rlm.RES_TYPE_CODE
      ,       rlm.RESOURCE_CLASS_CODE
      ,       rlm.RESOURCE_CLASS_FLAG
      ,       rlm.MIGRATION_CODE
      ,       1 -- record version number
      ,       rlm.INCURRED_BY_RES_FLAG
      ,       rlm.WP_ELIGIBLE_FLAG
      ,       rlm.UNIT_OF_MEASURE
      FROM  pa_resource_list_members rlm
      WHERE rlm.resource_list_id = eachRL.resource_list_id
      --begin:bug:5925973:Implementing the logic to restrict the creation of resource list member records when new OU ('Implementation Options' form of the OU)is created for an existing Business Group.
      --The Check:check whether the 'X_RESOURCE_LIST_ID' exists in the 'pa_resource_lists_all_bg' table before inserting records into 'pa_resource_list_members' table
      AND EXISTS
		(SELECT NULL
		FROM pa_resource_lists_all_bg T1
		WHERE T1.RESOURCE_LIST_ID = X_RESOURCE_LIST_ID);
      --end:bug:5925973
    END LOOP;

    X_err_stack := V_old_stack;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      X_err_code := -100;
      X_err_stack := SQLERRM(SQLCODE);
    WHEN  OTHERS  THEN
      X_err_code := SQLCODE;
      X_err_stack := SQLERRM(SQLCODE);

  END Create_Default_Res_List;

-- This procedure deletes a planning resource list, provided that it
-- is not being used anywhere.  It deletes the associated formats and
-- planning resources of the list before deleting the list itself.

PROCEDURE Delete_Plan_Res_List (p_resource_list_id   IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2) IS

CURSOR get_members (p_res_list_id in NUMBER) IS
SELECT resource_list_member_id
  FROM pa_resource_list_members
 WHERE resource_list_id = p_res_list_id;

l_res_list_member_id NUMBER;
l_err_code           NUMBER;

BEGIN

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check for Planning Resource List used anywhere

   l_err_code := 0;

   PA_GET_RESOURCE.delete_resource_list_ok(
          p_resource_list_id,
          'Y',
          l_err_code,
          x_msg_data);
   IF l_err_code <> 0 THEN
      x_msg_count := x_msg_count + 1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      pa_utils.add_message('PA', x_msg_data);
      RETURN;
      --FND_MESSAGE.SET_NAME('PA', x_msg_data);
      --FND_MSG_PUB.ADD;
   END IF;

/*
-- Check for Planning Resources used anywhere
OPEN get_members(p_resource_list_id);
LOOP
   FETCH get_members into l_res_list_member_id;
   EXIT WHEN get_members%NOTFOUND;

   l_err_code := 0;

   PA_GET_RESOURCE.delete_resource_list_member_ok(
         p_resource_list_id,
         l_res_list_member_id,
         l_err_code,
         x_msg_data);

   IF l_err_code <> 0 THEN
      IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         x_msg_count := x_msg_count + 1;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('PA',x_msg_data);
         FND_MSG_PUB.ADD;
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;
END LOOP;
*/

-- Delete Planning resources from the list
delete from pa_resource_list_members
where resource_list_id = p_resource_list_id;

-- Delete resource formats from the list
delete from pa_plan_rl_formats
where resource_list_id = p_resource_list_id;

-- Delete the planning resource list - TL
delete from pa_resource_lists_tl
where resource_list_id = p_resource_list_id;

-- Delete the planning resource list
delete from pa_resource_lists_all_bg
where resource_list_id = p_resource_list_id;

END Delete_Plan_Res_List;

--The Below Code has been added by Archana
/*************************************************************
 * Function    : Check_pl_alias_unique
 * Description : The purpose of this function is to determine
 *               the uniqueness of the resource alias if it is not null.
 *               While inserting when we call this function then if 'N'
 *               is returned then proceed else throw an error.
 *************************************************************/
FUNCTION Check_pl_alias_unique(
          p_resource_list_id      IN VARCHAR2,
          p_resource_alias        IN VARCHAR2,
          p_resource_list_member_id IN VARCHAR2)
  RETURN VARCHAR2
  IS
  l_check_unique_res  varchar2(30) := 'Y';
  BEGIN
     BEGIN
     SELECT 'N'
     INTO l_check_unique_res
     FROM pa_resource_list_members
     WHERE resource_list_id = p_resource_list_id
     AND alias = p_resource_alias
     AND resource_list_member_id <>
      nvl(p_resource_list_member_id,-99);
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_check_unique_res := 'Y';
     END;
return l_check_unique_res;
  END Check_pl_alias_unique;
/***********************************/
/**********************************************
 * Procedure : Add_Language
 **********************************************/
procedure ADD_LANGUAGE
is
begin
  delete from pa_resource_lists_tl T
  where not exists
    (select NULL
    from PA_RESOURCE_LISTS_ALL_BG B
    where B.RESOURCE_LIST_ID = T.resource_list_id
    );

  update pa_resource_lists_tl T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from pa_resource_lists_tl b
    where B.RESOURCE_LIST_ID = T.RESOURCE_LIST_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESOURCE_LIST_ID,
      T.LANGUAGE
  ) in (select
     SUBT.RESOURCE_LIST_ID,
      SUBT.LANGUAGE
    from pa_resource_lists_tl SUBB, pa_resource_lists_tl SUBT
    where SUBB.RESOURCE_LIST_ID = SUBT.RESOURCE_LIST_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into pa_resource_lists_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RESOURCE_LIST_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
 ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.RESOURCE_LIST_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from pa_resource_lists_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from pa_resource_lists_tl T
    where T.RESOURCE_LIST_ID = B.RESOURCE_LIST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
/***************************/
/*******************************************************
 * Procedure : Create_Proj_Resource_List
 * Description : This procedure is used to create resource
 *               list members, whenever we create a project
 *               specific resource list(ie when a resource
 *               list is associated to a project).
 *               We are copying the resource members
 *               from the existing members for the same
 *               resource list.
 *******************************************************/
PROCEDURE Create_Proj_Resource_List
            (p_resource_list_id   IN VARCHAR2,
             p_project_id         IN NUMBER,
             x_return_status      OUT NOCOPY     VARCHAR2,
             x_error_msg_data     OUT NOCOPY     Varchar2,
             x_msg_count          OUT NOCOPY     Number)
IS
  l_exist_record   Varchar2(30);
  l_central_control Varchar2(30);
  l_error_msg_data  Varchar2(30);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_error_msg_data := NULL;
   /*********************************************
    * The below select would check if the resource
    * list is centrally controlled or not.
    * If it is Centrally Controlled then we cannot associate
    * it to a project.
    ************************************************/
   /**************************************************
   * If the Project ID is passed in as NULL then Raise an
   * Unexpected error and Return.
   ***************************************************/
   IF p_project_id IS NULL THEN
       X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
       x_msg_count := x_msg_count + 1;
       x_error_msg_data := Null;
       Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_CREATE_RESOURCE',
                        P_Procedure_Name   => 'Create_Proj_Resource_List');

        Return;

   END IF;

   BEGIN
      SELECT Control_flag
      INTO l_central_control
      FROM pa_resource_lists_all_bg
      where resource_list_id = p_resource_list_id;
   EXCEPTION
   WHEN OTHERS THEN
       X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
       x_msg_count := x_msg_count + 1;
       x_error_msg_data := Null;
       Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_CREATE_RESOURCE',
                        P_Procedure_Name   => 'Create_Proj_Resource_List');

        Return;
   END;

    IF l_central_control = 'Y' THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       RETURN;
   END IF;

  /******************************************************
 * This select would check for the existance of recource
 * members in the pa_resource_list_members table which have the same
 * resource_list_id and project_id.
 * *****************************************************/
   BEGIN
      SELECT 'Y'
      INTO l_exist_record
      FROM dual --For perf bug 4067435
      WHERE EXISTS (SELECT resource_list_id,object_id
                    FROM pa_resource_list_members
                    WHERE object_id = p_project_id
                    AND object_type = 'PROJECT'
                    AND resource_list_id = p_resource_list_id)
      AND ROWNUM = 1;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_exist_record := 'N';
   WHEN OTHERS THEN
      l_exist_record := 'Y';
   END;

   IF l_exist_record = 'Y' THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       RETURN;
   END IF;
  /******************************************************
   * Copying into the Pa_Resource_list_members table based
   * on existing values for the same resource_list_id.
   ******************************************************/
   /*****************************************************
    * Bug - 3591751
    * Desc - While inserting into the Pa_resource_list_members
    *        insert value into the wp_eligible_flag as well.
    *****************************************************/
    /**********************************************************************
    * Bug - 3597011
    * Desc - While inserting we need to check for enabled_flag <> N
    ***********************************************************************/
   INSERT INTO Pa_Resource_List_Members
      ( RESOURCE_LIST_MEMBER_ID,
        RESOURCE_LIST_ID,
        RESOURCE_ID,
        ALIAS,
        DISPLAY_FLAG,
        ENABLED_FLAG,
        TRACK_AS_LABOR_FLAG,
        PERSON_ID,
        JOB_ID,
        ORGANIZATION_ID,
        VENDOR_ID,
        EXPENDITURE_TYPE,
        EVENT_TYPE,
        NON_LABOR_RESOURCE,
        EXPENDITURE_CATEGORY,
        REVENUE_CATEGORY,
        PROJECT_ROLE_ID,
        OBJECT_TYPE,
        OBJECT_ID,
        RESOURCE_CLASS_ID,
        RESOURCE_CLASS_CODE,
        RES_FORMAT_ID,
        SPREAD_CURVE_ID,
        ETC_METHOD_CODE,
        MFC_COST_TYPE_ID,
        COPY_FROM_RL_FLAG,
        RESOURCE_CLASS_FLAG,
        FC_RES_TYPE_CODE,
        INVENTORY_ITEM_ID,
        ITEM_CATEGORY_ID,
        MIGRATION_CODE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3  ,
        ATTRIBUTE4  ,
        ATTRIBUTE5  ,
        ATTRIBUTE6   ,
        ATTRIBUTE7   ,
        ATTRIBUTE8   ,
        ATTRIBUTE9   ,
        ATTRIBUTE10  ,
        ATTRIBUTE11  ,
        ATTRIBUTE12  ,
        ATTRIBUTE13  ,
        ATTRIBUTE14  ,
        ATTRIBUTE15  ,
        ATTRIBUTE16  ,
        ATTRIBUTE17   ,
        ATTRIBUTE18  ,
        ATTRIBUTE19 ,
        ATTRIBUTE20   ,
        ATTRIBUTE21   ,
        ATTRIBUTE22   ,
        ATTRIBUTE23   ,
        ATTRIBUTE24   ,
        ATTRIBUTE25   ,
        ATTRIBUTE26     ,
        ATTRIBUTE27    ,
        ATTRIBUTE28   ,
        ATTRIBUTE29  ,
        ATTRIBUTE30 ,
        RECORD_VERSION_NUMBER,
        PERSON_TYPE_CODE,
        BOM_RESOURCE_ID,
        TEAM_ROLE,
        INCURRED_BY_RES_FLAG,
        INCUR_BY_RES_CLASS_CODE,
        INCUR_BY_ROLE_ID,
        --3591751
        WP_ELIGIBLE_FLAG,
        --Bug 3637045
        UNIT_OF_MEASURE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN)
   SELECT
        pa_resource_list_members_s.NEXTVAL,
        a.RESOURCE_LIST_ID,
        a.RESOURCE_ID,
        a.ALIAS,
        a.DISPLAY_FLAG,
        a.ENABLED_FLAG,
        a.TRACK_AS_LABOR_FLAG,
        a.PERSON_ID,
        a.JOB_ID,
        a.ORGANIZATION_ID,
        a.VENDOR_ID,
        a.EXPENDITURE_TYPE,
        a.EVENT_TYPE,
        a.NON_LABOR_RESOURCE,
        a.EXPENDITURE_CATEGORY,
        a.REVENUE_CATEGORY,
        a.PROJECT_ROLE_ID,
        'PROJECT',
        p_project_id,
        a.RESOURCE_CLASS_ID,
        a.RESOURCE_CLASS_CODE,
        a.RES_FORMAT_ID,
        a.SPREAD_CURVE_ID,
        a.ETC_METHOD_CODE,
        a.MFC_COST_TYPE_ID,
        a.COPY_FROM_RL_FLAG,
        a.RESOURCE_CLASS_FLAG,
        a.FC_RES_TYPE_CODE,
        a.INVENTORY_ITEM_ID,
        a.ITEM_CATEGORY_ID,
        a.MIGRATION_CODE,
        a.ATTRIBUTE_CATEGORY,
        a.ATTRIBUTE1,
        a.ATTRIBUTE2,
        a.ATTRIBUTE3  ,
        a.ATTRIBUTE4  ,
        a.ATTRIBUTE5  ,
        a.ATTRIBUTE6   ,
        a.ATTRIBUTE7   ,
        a.ATTRIBUTE8   ,
        a.ATTRIBUTE9   ,
        a.ATTRIBUTE10  ,
        a.ATTRIBUTE11  ,
        a.ATTRIBUTE12  ,
        a.ATTRIBUTE13  ,
        a.ATTRIBUTE14  ,
        a.ATTRIBUTE15  ,
        a.ATTRIBUTE16  ,
        a.ATTRIBUTE17   ,
        a.ATTRIBUTE18  ,
        a.ATTRIBUTE19 ,
        a.ATTRIBUTE20   ,
        a.ATTRIBUTE21   ,
        a.ATTRIBUTE22   ,
        a.ATTRIBUTE23   ,
        a.ATTRIBUTE24   ,
        a.ATTRIBUTE25   ,
        a.ATTRIBUTE26     ,
        a.ATTRIBUTE27    ,
        a.ATTRIBUTE28   ,
        a.ATTRIBUTE29  ,
        a.ATTRIBUTE30 ,
        a.RECORD_VERSION_NUMBER,
        a.PERSON_TYPE_CODE,
        a.BOM_RESOURCE_ID,
        a.TEAM_ROLE,
        a.INCURRED_BY_RES_FLAG,
        a.INCUR_BY_RES_CLASS_CODE,
        a.INCUR_BY_ROLE_ID,
        --3591751
        a.wp_eligible_flag,
        --Bug 3637045
        a.unit_of_measure,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.LOGIN_ID
    FROM pa_resource_list_members a
    WHERE a.resource_list_id = p_resource_list_id
    AND   a.object_id        = p_resource_list_id
    AND   a.object_type      = 'RESOURCE_LIST'
    -- 3597011
    and   a.enabled_flag     <> 'N';

EXCEPTION
WHEN OTHERS THEN
       X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
       x_msg_count := x_msg_count + 1;
       x_error_msg_data := Null;
       Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_CREATE_RESOURCE',
                        P_Procedure_Name   => 'Create_Proj_Resource_List');

        Return;
END Create_Proj_Resource_List;
/**********************************/


--	History:
--
--      16-MAR-2004     smullapp                created
/*=========================================================================================
This api creates a new resource list and copies its elements from the parent resource list
===========================================================================================*/

-- Procedure            : COPY_RESOURCE_LIST
-- Type                 : Public Procedure
-- Purpose              : This API will be used to create new resource list which will be the copy of existing resource list.
--                      : This API will be called from following page:
--                      : 1.Copy Planning Resource List Page
--			: This API does business validations
--			: 1: The resource list names should be unique
--			: 2: The start date active of resource cannot be null
--			: 3: The start date active cannot be more than end date active
--			: If no errors are encountered it will call the table handler which creates
--			  the new resource list.

-- Note                 : This API will create a new resource list.

-- Assumptions          :

-- Parameters                     Type          Required        Description and Purpose
-- ---------------------------  ------          --------        --------------------------------------------------------
--  p_parent_resource_list_id    NUMBER           Yes            The value will contain the Resource list id of the parent resource list
--  p_name			 VARCHAR2	  Yes		 The value will contain the name of the resource list
--  p_description		 VARCHAR2	  No		 The value will contain the description of the resource list
--  p_start_date_active		 DATE		  Yes		 The value will contain the start date of the resource
--  p_end_date_active		 DATE		  No 		 The value will contain the end date of the resource
--  p_job_group_id		 NUMBER		  No 		 The value will contain the job group id of the resource list
--  p_control_flag		 VARCHAR2	  No 		 The value will contain the control flag of the resource
--  p_use_for_wp_flag		 VARCHAR2	  No		 The value will contain the use for workplan flag


PROCEDURE COPY_RESOURCE_LIST(
			P_Commit             		IN      Varchar2 Default Fnd_Api.G_False,
        		P_Init_Msg_List      		IN      Varchar2 Default Fnd_Api.G_True,
        		P_API_Version_Number 		IN      Number,
                        p_parent_resource_list_id       IN  	PA_RESOURCE_LISTS_ALL_BG.resource_list_id%TYPE,
			p_name				IN 	PA_RESOURCE_LISTS_ALL_BG.name%TYPE,
			p_description			IN 	PA_RESOURCE_LISTS_ALL_BG.description%TYPE,
			p_start_date_active		IN 	PA_RESOURCE_LISTS_ALL_BG.START_DATE_ACTIVE%TYPE,
			p_end_date_active		IN 	PA_RESOURCE_LISTS_ALL_BG.END_DATE_ACTIVE%TYPE,
			p_job_group_id			IN 	PA_RESOURCE_LISTS_ALL_BG.JOB_GROUP_ID%TYPE,
			p_control_flag			IN 	PA_RESOURCE_LISTS_ALL_BG.CONTROL_FLAG%TYPE,
			p_use_for_wp_flag		IN 	PA_RESOURCE_LISTS_ALL_BG.USE_FOR_WP_FLAG%TYPE,
                        x_return_status         	OUT 	NOCOPY	Varchar2,
                        x_msg_data              	OUT 	NOCOPY	Varchar2,
                        x_msg_count             	OUT 	NOCOPY	NUMBER
                )
IS
          p_public_flag                  PA_RESOURCE_LISTS_ALL_BG.public_flag%TYPE;
          p_group_resource_type_id       PA_RESOURCE_LISTS_ALL_BG.group_resource_type_id%TYPE;
          p_uncategorized_flag           PA_RESOURCE_LISTS_ALL_BG.uncategorized_flag%TYPE;
          p_business_group_id            PA_RESOURCE_LISTS_ALL_BG.business_group_id%TYPE;
	  p_adw_notify_flag		 PA_RESOURCE_LISTS_ALL_BG.adw_notify_flag%TYPE;
          p_resource_list_type           PA_RESOURCE_LISTS_ALL_BG.resource_list_type%TYPE;
	  p_migration_code		 PA_RESOURCE_LISTS_ALL_BG.migration_code%TYPE;
	  l_resource_list_member_id      PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
	  x_resource_list_id		 PA_RESOURCE_LISTS_ALL_BG.resource_list_id%TYPE;
	  l_resource_list_id		 NUMBER:=NULL;
          --3596702
          l_res_list_member_id           Number;


        l_msg_count             NUMBER:=0;
        l_msg_data              VARCHAR2(2000):=NULL;
        l_data                  VARCHAR2(2000):=NULL;
        l_msg_index_out         NUMBER;
	l_error_raised          VARCHAR2(1):=NULL;
        l_error                 Exception;

	l_Api_Name              Varchar2(30)    := 'COPY_RESOURCE_LIST';
	l_api_version		NUMBER:=1.0;

BEGIN

-- hr_utility.trace_on(NULL, 'RMCOPY');
-- hr_utility.trace('start');
	--Check for API compatibility
	If Not Fnd_Api.Compatible_API_Call (
                        l_Api_Version,
                        P_Api_Version_Number,
                        l_Api_Name,
                        'PA_CREATE_RESOURCE') Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;


	 --Initialize the message stack if not initialized
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Fnd_Msg_Pub.Initialize;

        End If;

        --Initialize error handling variables
        X_Msg_Count := 0;
        X_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

-- hr_utility.trace('Initialize');

	--Check for the uniquness of resource list names
	IF(chk_plan_rl_unique(p_name,
                             l_resource_list_id) = FALSE) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
         	pa_utils.add_message(P_App_Short_Name  => 'PA',
                              P_Msg_Name        => 'PA_RL_FOUND');
		l_msg_count := FND_MSG_PUB.count_msg;
                IF l_msg_count = 1 THEN
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded      => FND_API.G_TRUE,
                                p_msg_index     => 1,
                                p_msg_count     => l_msg_count,
                                p_msg_data      => l_msg_data,
                                p_data          => l_data,
                                p_msg_index_out => l_msg_index_out);
                                x_msg_data := l_data;
                                x_msg_count := l_msg_count;

                ELSE
                        x_msg_count := l_msg_count;
                END IF;

                pa_debug.reset_curr_function;
-- hr_utility.trace('l_error_raised');
                l_error_raised:='Y';
	END IF;



	-- Validate Dates
	-- Start Date is required
-- hr_utility.trace('Validate Dates');
	IF (p_start_date_active is NULL) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_IRS_START_NOT_NULL');

		l_msg_count := FND_MSG_PUB.count_msg;
                IF l_msg_count = 1 THEN
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded      => FND_API.G_TRUE,
                                p_msg_index     => 1,
                                p_msg_count     => l_msg_count,
                                p_msg_data      => l_msg_data,
                                p_data          => l_data,
                                p_msg_index_out => l_msg_index_out);
                                x_msg_data := l_data;
                                x_msg_count := l_msg_count;

                ELSE
                        x_msg_count := l_msg_count;
                END IF;

                pa_debug.reset_curr_function;
                l_error_raised:='Y';
	END IF;

-- hr_utility.trace('Validate Dates 2');
	--Validation:Start date cannot be greater than end date
	IF (p_start_date_active IS NOT NULL and p_end_date_active IS NOT NULL
	    and p_start_date_active >= p_end_date_active) THEN

		x_return_status := FND_API.G_RET_STS_ERROR;

		pa_utils.add_message(p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_PR_INVALID_OR_DATES');

		l_msg_count := FND_MSG_PUB.count_msg;
                IF l_msg_count = 1 THEN
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded      => FND_API.G_TRUE,
                                p_msg_index     => 1,
                                p_msg_count     => l_msg_count,
                                p_msg_data      => l_msg_data,
                                p_data          => l_data,
                                p_msg_index_out => l_msg_index_out);
                                x_msg_data := l_data;
                                x_msg_count := l_msg_count;

                ELSE
                        x_msg_count := l_msg_count;
                END IF;

                pa_debug.reset_curr_function;
                l_error_raised:='Y';
	END IF;


        IF(l_error_raised ='Y') THEN
-- hr_utility.trace('l_error_raised =Y');
                Raise l_error;
        END IF;

	--Get needed data of parent resource list from pa_resource_lists_all_bg
	 SELECT
                public_flag,
                group_resource_type_id,
                uncategorized_flag,
                business_group_id,
                adw_notify_flag,
                resource_list_type,
		--'N'     --Bug 3695679
		migration_code --Bug 3710189
        INTO
                p_public_flag,
		p_group_resource_type_id,
                p_uncategorized_flag,
                p_business_group_id,
                p_adw_notify_flag,
                p_resource_list_type,
		p_migration_code
        FROM
                pa_resource_lists_all_bg
        WHERE
                resource_list_id=p_parent_resource_list_id;

-- hr_utility.trace('BG insert');

	--Call Insert_row which inserts a row into PA_RESOURCE_LISTS_ALL_BG table
        PA_Resource_List_tbl_Pkg.Insert_Row(
                             p_name,
                             p_description,
                             p_public_flag,
                             p_group_resource_type_id,
                             p_start_date_active,
                             p_end_date_active,
                             p_uncategorized_flag,
                             p_business_group_id,
                             p_adw_notify_flag,
                             p_job_group_id,
                             p_resource_list_type,
                             p_control_flag,
                             p_use_for_wp_flag,
                             p_migration_code,
			     x_resource_list_id,
			     x_return_status,
			     x_msg_data
                        );

-- hr_utility.trace('member insert');


        --Adding to TL
         INSERT into pa_resource_lists_tl (
                             last_update_login,
                             creation_date,
                             created_by,
                             last_update_date,
                             last_updated_by,
                             resource_list_id,
                             name,
                             description,
                             language,
                             source_lang
                       ) SELECT
                             fnd_global.login_id,
                             sysdate,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             x_resource_list_id,
                             p_name,
                             NVL(p_description,p_name),
                             L.LANGUAGE_CODE,
                             userenv('LANG')
                        FROM FND_LANGUAGES L
                        WHERE L.INSTALLED_FLAG in ('I', 'B')
                        and not exists
                            (select NULL
                            from pa_resource_lists_tl T
                            where T.RESOURCE_LIST_ID = X_RESOURCE_LIST_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);


-- hr_utility.trace('TL insert');
	INSERT INTO pa_plan_rl_formats
	(SELECT
		Pa_Plan_RL_Formats_S.nextval,
		X_Resource_List_Id,
		res_format_id,
		1,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id
	FROM
		pa_plan_rl_formats
	WHERE
		resource_list_id=p_parent_resource_list_id
	AND	p_migration_code IN ('N','M')); --Bug 3710189

-- hr_utility.trace('format insert');

	--Start:bug 3710189

        Begin

                Delete
                From Pa_Rbs_Elements_Temp;

        Exception
                When No_Data_Found Then
                        null;

        End;


	Insert Into Pa_Rbs_Elements_Temp(
		New_Element_Id,
		Old_Element_Id,
		Old_Parent_Element_Id,
		New_Parent_Element_Id )
		(Select
			Pa_resource_list_members_S.NextVal,
			resource_list_member_id,
			Parent_member_Id,
			Null
		From Pa_resource_list_members
		Where resource_list_id  = p_parent_resource_list_id
		and    (object_type  = 'RESOURCE_LIST' OR object_type is NULL)
		--don't want to copy proj specific resources
		and enabled_flag <> 'N' );

	--Update the parent member ID for the new child elements:

	Update Pa_Rbs_Elements_Temp Tmp1
	Set New_Parent_Element_Id =
   		(Select New_Element_Id
    		From Pa_Rbs_Elements_Temp Tmp2
    		Where Tmp1.Old_Parent_Element_Id = Tmp2.Old_Element_Id);


	  --Copy all the elements of parent_resource_list to the newly created resource list
        /**********************************************************************
        * Bug - 3597011
        * Desc - While inserting we need to check for enabled_flag <> N
        ***********************************************************************/

-- hr_utility.trace('before copy members insert');
-- hr_utility.trace('p_parent_resource_list_id is : ' || p_parent_resource_list_id);
        INSERT INTO pa_resource_list_members
	(	resource_list_member_id,
		RESOURCE_LIST_ID,
		RESOURCE_ID,
		ALIAS ,
		PARENT_MEMBER_ID,
		SORT_ORDER ,
		MEMBER_LEVEL,
		DISPLAY_FLAG ,
		ENABLED_FLAG  ,
		TRACK_AS_LABOR_FLAG,
		last_updated_by,
		last_update_date,
		creation_date,
		created_by,
		last_update_login,
		ADW_NOTIFY_FLAG,
		FUNDS_CONTROL_LEVEL_CODE,
		PERSON_ID,
		JOB_ID,
		ORGANIZATION_ID,
		VENDOR_ID,
		EXPENDITURE_TYPE,
		EVENT_TYPE,
		NON_LABOR_RESOURCE,
		EXPENDITURE_CATEGORY,
		REVENUE_CATEGORY,
		NON_LABOR_RESOURCE_ORG_ID,
		EVENT_TYPE_CLASSIFICATION,
		SYSTEM_LINKAGE_FUNCTION,
		PROJECT_ROLE_ID,
		RESOURCE_FORMAT_ID,
		RESOURCE_TYPE_ID,
		RESOURCE_TYPE_CODE,
		OBJECT_TYPE,
                --3596702
		object_id,
		RES_FORMAT_ID,
		SPREAD_CURVE_ID,
		ETC_METHOD_CODE,
		MFC_COST_TYPE_ID,
		PERSON_TYPE_CODE,
		RES_TYPE_CODE,
		RESOURCE_CLASS_CODE,
		RESOURCE_CLASS_ID,
		RESOURCE_CLASS_FLAG,
		FC_RES_TYPE_CODE,
		BOM_RESOURCE_ID,
		INVENTORY_ITEM_ID,
		ITEM_CATEGORY_ID,
		TEAM_ROLE,
		MIGRATION_CODE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20,
		ATTRIBUTE21,
		ATTRIBUTE22,
		ATTRIBUTE23,
		ATTRIBUTE24,
		ATTRIBUTE25,
		ATTRIBUTE26,
		ATTRIBUTE27,
		ATTRIBUTE28,
		ATTRIBUTE29,
		ATTRIBUTE30,
		record_version_number,
		INCURRED_BY_RES_FLAG,
		INCUR_BY_RES_CLASS_CODE,
		INCUR_BY_ROLE_ID,
		COPY_FROM_RL_FLAG,
		WP_ELIGIBLE_FLAG,
                --Bug 3636926
                UNIT_OF_MEASURE)
		--MIGRATED_RBS_ELEMENT_ID)
               SELECT /*+ use_nl (tmp, a) */ --For perf bug 4067435
		Tmp.New_Element_Id,
		X_RESOURCE_LIST_ID,
		a.RESOURCE_ID,
		a.ALIAS ,
		Tmp.New_Parent_Element_Id,
		a.SORT_ORDER ,
		a.MEMBER_LEVEL,
		a.DISPLAY_FLAG ,
		a.ENABLED_FLAG  ,
		a.TRACK_AS_LABOR_FLAG,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.LOGIN_ID,
		a.ADW_NOTIFY_FLAG,
		a.FUNDS_CONTROL_LEVEL_CODE,
		a.PERSON_ID,
		a.JOB_ID,
		a.ORGANIZATION_ID,
		a.VENDOR_ID,
		a.EXPENDITURE_TYPE,
		a.EVENT_TYPE,
		a.NON_LABOR_RESOURCE,
		a.EXPENDITURE_CATEGORY,
		a.REVENUE_CATEGORY,
		a.NON_LABOR_RESOURCE_ORG_ID,
		a.EVENT_TYPE_CLASSIFICATION,
		a.SYSTEM_LINKAGE_FUNCTION,
		a.PROJECT_ROLE_ID,
		a.RESOURCE_FORMAT_ID,
		a.RESOURCE_TYPE_ID,
		a.RESOURCE_TYPE_CODE,
		a.OBJECT_TYPE,
                --3596702
		--X_RESOURCE_LIST_ID,
		decode(a.object_type, 'RESOURCE_LIST', X_RESOURCE_LIST_ID, NULL),
		a.RES_FORMAT_ID,
		a.SPREAD_CURVE_ID,
		a.ETC_METHOD_CODE,
		a.MFC_COST_TYPE_ID,
		a.PERSON_TYPE_CODE,
		a.RES_TYPE_CODE,
		a.RESOURCE_CLASS_CODE,
		a.RESOURCE_CLASS_ID,
		a.RESOURCE_CLASS_FLAG,
		a.FC_RES_TYPE_CODE,
		a.BOM_RESOURCE_ID,
		a.INVENTORY_ITEM_ID,
		a.ITEM_CATEGORY_ID,
		a.TEAM_ROLE,
		--'N',--Bug 3695679
		a.MIGRATION_CODE,
		a.ATTRIBUTE_CATEGORY,
		a.ATTRIBUTE1,
		a.ATTRIBUTE2,
		a.ATTRIBUTE3,
		a.ATTRIBUTE4,
		a.ATTRIBUTE5,
		a.ATTRIBUTE6,
		a.ATTRIBUTE7,
		a.ATTRIBUTE8,
		a.ATTRIBUTE9,
		a.ATTRIBUTE10,
		a.ATTRIBUTE11,
		a.ATTRIBUTE12,
		a.ATTRIBUTE13,
		a.ATTRIBUTE14,
		a.ATTRIBUTE15,
		a.ATTRIBUTE16,
		a.ATTRIBUTE17,
		a.ATTRIBUTE18,
		a.ATTRIBUTE19,
		a.ATTRIBUTE20,
		a.ATTRIBUTE21,
		a.ATTRIBUTE22,
		a.ATTRIBUTE23,
		a.ATTRIBUTE24,
		a.ATTRIBUTE25,
		a.ATTRIBUTE26,
		a.ATTRIBUTE27,
		a.ATTRIBUTE28,
		a.ATTRIBUTE29,
		a.ATTRIBUTE30,
		1,
		a.INCURRED_BY_RES_FLAG,
		a.INCUR_BY_RES_CLASS_CODE,
		a.INCUR_BY_ROLE_ID,
		a.COPY_FROM_RL_FLAG,
		a.WP_ELIGIBLE_FLAG,
                -- Bug 3636926
                a.UNIT_OF_MEASURE
		--a.MIGRATED_RBS_ELEMENT_ID
	From 	Pa_resource_list_members a, Pa_Rbs_Elements_Temp Tmp
	Where 	Tmp.Old_Element_Id = a.resource_list_member_id;

	--End: Bug 3710189
/*
        FROM
                pa_resource_list_members a
        WHERE
                a.resource_list_id=p_parent_resource_list_id
	AND
		a.object_type='RESOURCE_LIST'
        -- 3597011
        and     a.enabled_flag <> 'N';

*/

-- hr_utility.trace('after copy members insert');

	IF Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        END IF;

EXCEPTION

        When l_error THEN
-- hr_utility.trace('when others l_error');
                null;

        WHEN OTHERS THEN
-- hr_utility.trace('when others unexp');
                x_return_status :='U';
                x_msg_data      :=sqlerrm;
                x_msg_count     :=1;

END COPY_RESOURCE_LIST;

/******************************************************
 * Procedure : Copy_Resource_Lists
 * Description : This API is used to copy all the
 *               Resource list members for the resource_list_id's
 *               associated to the source project -->
 *               into the destination project.
 *               If the resource_list is Centrally controlled.
 *               Then do nothing. If it is not centrally controlled
 *               then do the copy operation.
 *******************************************************/
 PROCEDURE Copy_Resource_Lists
       (p_source_project_id        IN  Number,
        p_destination_project_id   IN  Number,
        x_return_status            OUT NOCOPY Varchar2)
IS
  /***********************************************
  * Cursor to get all the resource_list_ID's
  * associated to the source project_id.
  **********************************************/
  --Bug 3494461
  -- Changed Pa_resource_list_assignments to pa_resource_list_assignments_v
  Cursor c_get_resource_list
  IS
  SELECT resource_list_id
  FROM pa_resource_list_assignments_v
  WHERE project_id = p_source_project_id;

  l_resource_list_id pa_resource_list_members.resource_list_id%TYPE;
  l_control_flag Varchar2(1);

BEGIN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  /*************************************
  * Open Cursor and fetch values
  * ************************************/
    OPEN c_get_resource_list;
    LOOP
        FETCH c_get_resource_list INTO l_resource_list_id;
        /*************************************************
        * If no values are returned from the cursor, that
        * is no resource lists are found associated to the
        * source project id then
        * raise no unexp error and return.
        ************************************************/
        IF c_get_resource_list%ROWCOUNT = 0 THEN
            /*******************************************************
            * Bug - 3595659
            * Desc - If no resource list found in the source project, then
            *        just close the cursor and return. No UNEXP error needs
            *        to be raised.
            ***********************************************************/
            -- X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
            Close c_get_resource_list;
            Return;
        END IF;
        EXIT WHEN c_get_resource_list%NOTFOUND;
        /***********************************************
         * Check to see if the resource list is centrally
         * controlled. If it is then do nothing.
         * Else do the COPY.
         ***************************************************/
         BEGIN
            SELECT control_flag
            INTO l_control_flag
            FROM pa_resource_lists_all_bg
            WHERE resource_list_id = l_resource_list_id;
         EXCEPTION
         WHEN OTHERS THEN
            X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
            Close c_get_resource_list;
            Return;
         END;
         /******************************************
          * If the resource list is not centrally controlled
          * then do the copy operation from the source
          * project to the destination project.
          **********************************************/
         IF l_control_flag <> 'Y' THEN
             BEGIN
               /************************************************
               * Insert resource list members into the
               * pa_resource_list_members table as those that
               * exist for the p_source_project_id.
               * The project_id should be the destination project id
               * and the resource_list_member_id should be the one from
               * the sequence.
               * *****************************************************/
               /******************************************************
               * Bug - 3591751
               * Desc - Inserting the wp_eligible_flag as in the source
               *        resource_list.
               **********************************************************/
              /**********************************************************************
              * Bug - 3597011
              * Desc - While inserting we need to check for enabled_flag <> N
              ***********************************************************************/
                INSERT INTO PA_RESOURCE_LIST_MEMBERS
                  ( RESOURCE_LIST_MEMBER_ID,
                    RESOURCE_LIST_ID,
                    RESOURCE_ID,
                    ALIAS,
                    DISPLAY_FLAG,
                    ENABLED_FLAG,
                    TRACK_AS_LABOR_FLAG,
                    PERSON_ID,
                    JOB_ID,
                    ORGANIZATION_ID,
                    VENDOR_ID,
                    EXPENDITURE_TYPE,
                    EVENT_TYPE,
                    NON_LABOR_RESOURCE,
                    EXPENDITURE_CATEGORY,
                    REVENUE_CATEGORY,
                    PROJECT_ROLE_ID,
                    OBJECT_TYPE,
                    OBJECT_ID,
                    RESOURCE_CLASS_ID,
                    RESOURCE_CLASS_CODE,
                    RES_FORMAT_ID,
                    SPREAD_CURVE_ID,
                    ETC_METHOD_CODE,
                    MFC_COST_TYPE_ID,
                    COPY_FROM_RL_FLAG,
                    RESOURCE_CLASS_FLAG,
                    FC_RES_TYPE_CODE,
                    INVENTORY_ITEM_ID,
                    ITEM_CATEGORY_ID,
                    MIGRATION_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3  ,
                    ATTRIBUTE4  ,
                    ATTRIBUTE5  ,
                    ATTRIBUTE6   ,
                    ATTRIBUTE7   ,
                    ATTRIBUTE8   ,
                    ATTRIBUTE9   ,
                    ATTRIBUTE10  ,
                    ATTRIBUTE11  ,
                    ATTRIBUTE12  ,
                    ATTRIBUTE13  ,
                    ATTRIBUTE14  ,
                    ATTRIBUTE15  ,
                    ATTRIBUTE16  ,
                    ATTRIBUTE17   ,
                    ATTRIBUTE18  ,
                    ATTRIBUTE19 ,
                    ATTRIBUTE20   ,
                    ATTRIBUTE21   ,
                    ATTRIBUTE22   ,
                    ATTRIBUTE23   ,
                    ATTRIBUTE24   ,
                    ATTRIBUTE25   ,
                    ATTRIBUTE26     ,
                    ATTRIBUTE27    ,
                    ATTRIBUTE28   ,
                    ATTRIBUTE29  ,
                    ATTRIBUTE30 ,
                    RECORD_VERSION_NUMBER,
                    PERSON_TYPE_CODE,
                    BOM_RESOURCE_ID,
                    TEAM_ROLE,
                    INCURRED_BY_RES_FLAG,
                    INCUR_BY_RES_CLASS_CODE,
                    INCUR_BY_ROLE_ID,
                    --3591751
                    wp_eligible_flag,
                    --Bug 3636926
                    unit_of_measure,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN)
                SELECT
                   pa_resource_list_members_s.NEXTVAL,
                   l_resource_list_id,
                   a.RESOURCE_ID,
                   a.ALIAS,
                   a.DISPLAY_FLAG,
                   a.ENABLED_FLAG,
                   a.TRACK_AS_LABOR_FLAG,
                   a.PERSON_ID,
                   a.JOB_ID,
                   a.ORGANIZATION_ID,
                   a.VENDOR_ID,
                   a.EXPENDITURE_TYPE,
                   a.EVENT_TYPE,
                   a.NON_LABOR_RESOURCE,
                   a.EXPENDITURE_CATEGORY,
                   a.REVENUE_CATEGORY,
                   a.PROJECT_ROLE_ID,
                   'PROJECT',
                   p_destination_project_id,
                   a.RESOURCE_CLASS_ID,
                   a.RESOURCE_CLASS_CODE,
                   a.RES_FORMAT_ID,
                   a.SPREAD_CURVE_ID,
                   a.ETC_METHOD_CODE,
                   a.MFC_COST_TYPE_ID,
                   a.COPY_FROM_RL_FLAG,
                   a.RESOURCE_CLASS_FLAG,
                   a.FC_RES_TYPE_CODE,
                   a.INVENTORY_ITEM_ID,
                   a.ITEM_CATEGORY_ID,
                   a.MIGRATION_CODE,
                   a.ATTRIBUTE_CATEGORY,
                   a.ATTRIBUTE1,
                   a.ATTRIBUTE2,
                   a.ATTRIBUTE3  ,
                   a.ATTRIBUTE4  ,
                   a.ATTRIBUTE5  ,
                   a.ATTRIBUTE6   ,
                   a.ATTRIBUTE7   ,
                   a.ATTRIBUTE8   ,
                   a.ATTRIBUTE9   ,
                   a.ATTRIBUTE10  ,
                   a.ATTRIBUTE11  ,
                   a.ATTRIBUTE12  ,
                   a.ATTRIBUTE13  ,
                   a.ATTRIBUTE14  ,
                   a.ATTRIBUTE15  ,
                   a.ATTRIBUTE16  ,
                   a.ATTRIBUTE17   ,
                   a.ATTRIBUTE18  ,
                   a.ATTRIBUTE19 ,
                   a.ATTRIBUTE20   ,
                   a.ATTRIBUTE21   ,
                   a.ATTRIBUTE22   ,
                   a.ATTRIBUTE23   ,
                   a.ATTRIBUTE24   ,
                   a.ATTRIBUTE25   ,
                   a.ATTRIBUTE26     ,
                   a.ATTRIBUTE27    ,
                   a.ATTRIBUTE28   ,
                   a.ATTRIBUTE29  ,
                   a.ATTRIBUTE30 ,
                   a.RECORD_VERSION_NUMBER,
                   a.PERSON_TYPE_CODE,
                   a.BOM_RESOURCE_ID,
                   a.TEAM_ROLE,
                   a.INCURRED_BY_RES_FLAG,
                   a.INCUR_BY_RES_CLASS_CODE,
                   a.INCUR_BY_ROLE_ID,
                   --3591751
                   a.wp_eligible_flag,
                   --Bug 3636926
                   a.unit_of_measure,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   FND_GLOBAL.LOGIN_ID
               FROM pa_resource_list_members a
               WHERE a.resource_list_id = l_resource_list_id
               AND   a.object_id        = p_source_project_id
               AND   a.object_type      = 'PROJECT'
               -- 3597011
               and   a.enabled_flag <> 'N'
               AND
                 (a.resource_id,a.res_format_id,NVL(a.alias,'XXX'))
                IN
	            (SELECT resource_id,res_format_id,NVL(alias,'XXX')
                     FROM   pa_resource_list_members
	             WHERE  resource_list_id = l_resource_list_id
		     AND    object_id = p_source_project_id
		     AND    object_type      = 'PROJECT'
	       	     MINUS
		     SELECT resource_id,res_format_id,NVL(alias,'XXX')
		     FROM   pa_resource_list_members
	             WHERE  resource_list_id  = l_resource_list_id
		     AND    object_id  = p_destination_project_id
        	     AND    object_type      = 'PROJECT');

            EXCEPTION
            WHEN OTHERS THEN
                 Null;
            END;
         END IF;--L_central_control = Y
    END LOOP;--Res_list_ID's
END Copy_Resource_Lists;


--      History:
--
--      03-FEB-2005     smullapp                created
-------------------------------------------------------------------
--For bug 4139144

/******************************************************
 * Procedure : TRANSLATE_ROW
 * Description : This API is used to tranlslate all
 *               translatable colmuns os pa_resource_lits_tl
 *               table. This is called from the lct file.
 * **************************************************/
procedure TRANSLATE_ROW(
  P_RESOURCE_LIST_ID            in NUMBER   ,
  P_OWNER                       in VARCHAR2 ,
  P_NAME                        in VARCHAR2 ,
  P_DESCRIPTION                 in VARCHAR2
) is
begin

  update pa_resource_lists_tl set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(P_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where resource_list_id = P_RESOURCE_LIST_ID
  and   userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;


/******************************************************
 * Procedure : LOAD_ROW
 * Description : This API is used to update or insert rows
 *               into table pa_resource_lists_bg and
 *               pa_resource_lits_tl table. This procedure
 *               is called from the lct file.
 * **************************************************/
procedure LOAD_ROW(
  P_RESOURCE_LIST_ID               in NUMBER,
  P_NAME                           in VARCHAR2,
  P_DESCRIPTION                    in VARCHAR2,
  P_PUBLIC_FLAG                    in VARCHAR2,
  P_GROUP_RESOURCE_TYPE_ID         in NUMBER,
  P_START_DATE_ACTIVE              in DATE,
  P_END_DATE_ACTIVE                in DATE,
  P_UNCATEGORIZED_FLAG             in VARCHAR2,
  P_BUSINESS_GROUP_ID              in NUMBER,
  P_JOB_GROUP_ID                   in NUMBER,
  P_RESOURCE_LIST_TYPE             in VARCHAR2,
  P_OWNER                          in VARCHAR2)
IS
  user_id NUMBER;
  l_row_id VARCHAR2(64);
  l_resource_list_id NUMBER;

  --Bug 4202015: Added this cursor
  CURSOR RES_CUR IS
  Select
  Rowid
  from
  PA_RESOURCE_LISTS_ALL_BG
  Where Resource_List_Id   =  P_Resource_List_Id;

BEGIN

  IF(P_OWNER = 'SEED') THEN
   user_id := 1;
  else
   user_id :=0;
  END IF;

  --Commented the following two  Selects For Bug#5094347. These are not used anywhere in the code.
  /*SELECT ROWID
  INTO l_row_id
  FROM pa_resource_lists_all_bg
  WHERE resource_list_id = P_RESOURCE_LIST_ID;

  SELECT nvl(p_resource_list_id,pa_resource_lists_s.NEXTVAL)
  INTO   l_resource_list_id
  FROM   dual;
  */
  --End of Commenting for Bug#5094347

  /*Bug 4202015 - Changes Start*/
  --If we call PA_Resource_List_tbl_Pkg.Update_Row and then call PA_Resource_List_tbl_Pkg.Insert_Row
  --in case no_data_found exception is returned by previous API, then we get
  --unique constraint (PA.PA_RESOURCE_LISTS_U2) violation error in case table pa_resource_lists_tl
  --is empty. This is due to the fact that although no_data_found has been raised while updating
  --record in table pa_resource_lists_tl, we try to insert the same record in table
  --PA_RESOURCE_LISTS_ALL_BG in call to PA_Resource_List_tbl_Pkg.Insert_Row.
  --Hence we have coded this API to update the records directly in _BG and _TL tables
  --and in case of no_data_found exception we insert records in respective tables.

  Update PA_RESOURCE_LISTS_ALL_BG
  SET
                NAME                    =   P_NAME                   ,
                DESCRIPTION             =   P_DESCRIPTION            ,
                PUBLIC_FLAG             =   P_PUBLIC_FLAG            ,
                GROUP_RESOURCE_TYPE_ID  =   P_GROUP_RESOURCE_TYPE_ID ,
                START_DATE_ACTIVE       =   P_START_DATE_ACTIVE      ,
                END_DATE_ACTIVE         =   P_END_DATE_ACTIVE        ,
                UNCATEGORIZED_FLAG      =   P_UNCATEGORIZED_FLAG     ,
                BUSINESS_GROUP_ID       =   P_BUSINESS_GROUP_ID      ,
                JOB_GROUP_ID            =   P_JOB_GROUP_ID           ,
                RESOURCE_LIST_TYPE      =   P_RESOURCE_LIST_TYPE     ,
                LAST_UPDATED_BY         =   user_id                  ,
                LAST_UPDATE_DATE        =   sysdate                  ,
                LAST_UPDATE_LOGIN       =   0
  WHERE         RESOURCE_LIST_ID        =   P_RESOURCE_LIST_ID;

  If SQL%NOTFOUND Then
     Insert Into PA_RESOURCE_LISTS_ALL_BG
                            (
                             RESOURCE_LIST_ID,
                             NAME         ,
                             DESCRIPTION  ,
                             PUBLIC_FLAG ,
                             GROUP_RESOURCE_TYPE_ID  ,
                             START_DATE_ACTIVE     ,
                             END_DATE_ACTIVE      ,
                             UNCATEGORIZED_FLAG  ,
                             BUSINESS_GROUP_ID  ,
                             JOB_GROUP_ID     ,
                             RESOURCE_LIST_TYPE,
                             LAST_UPDATED_BY ,
                             LAST_UPDATE_DATE,
                             CREATION_DATE ,
                             CREATED_BY   ,
                             LAST_UPDATE_LOGIN,
                             CONTROL_FLAG,
                             USE_FOR_WP_FLAG,
                             MIGRATION_CODE
                             )
                             VALUES
                             (
                             P_RESOURCE_LIST_ID,
                             P_NAME         ,
                             P_DESCRIPTION  ,
                             P_PUBLIC_FLAG ,
                             P_GROUP_RESOURCE_TYPE_ID  ,
                             P_START_DATE_ACTIVE     ,
                             P_END_DATE_ACTIVE      ,
                             P_UNCATEGORIZED_FLAG  ,
                             P_BUSINESS_GROUP_ID  ,
                             P_JOB_GROUP_ID     ,
                             P_RESOURCE_LIST_TYPE,
                             user_id ,
                             sysdate,
                             sysdate ,
                             user_id ,
                             0,
                             'Y',
                             'N', -- open issue
                             NULL);
  end if;


  update pa_resource_lists_tl
  set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.login_id,
    SOURCE_LANG = userenv('LANG')
  where resource_list_id = P_RESOURCE_LIST_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
     insert into pa_resource_lists_tl (
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         RESOURCE_LIST_ID,
         NAME,
         DESCRIPTION,
         LANGUAGE,
         SOURCE_LANG)
      select
         FND_GLOBAL.LOGIN_ID,
         sysdate,
         FND_GLOBAL.USER_ID,
         sysdate,
         FND_GLOBAL.USER_ID,
         P_RESOURCE_LIST_ID,
         P_NAME,
         NVL(P_DESCRIPTION,P_NAME),
         L.LANGUAGE_CODE,
         userenv('LANG')
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
         (select NULL
          from pa_resource_lists_tl T
          where T.RESOURCE_LIST_ID = P_RESOURCE_LIST_ID
            and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;

  Open  Res_Cur;
  Fetch Res_Cur Into l_row_id;
  If (Res_Cur%NOTFOUND)  then
      Close Res_Cur;
      Raise NO_DATA_FOUND;
  End If;
  Close Res_Cur;

  /*Bug 4202015 - Changes End*/

  --Commented the following code for Bug 4202015
  /*PA_Resource_List_tbl_Pkg.Update_Row(
    X_ROW_ID                            =>    l_row_id                ,
    X_RESOURCE_LIST_ID                  =>    P_RESOURCE_LIST_ID      ,
    X_NAME                              =>    P_NAME                  ,
    X_DESCRIPTION                       =>    P_DESCRIPTION           ,
    X_PUBLIC_FLAG                       =>    P_PUBLIC_FLAG           ,
    X_GROUP_RESOURCE_TYPE_ID            =>    P_GROUP_RESOURCE_TYPE_ID,
    X_START_DATE_ACTIVE                 =>    P_START_DATE_ACTIVE     ,
    X_END_DATE_ACTIVE                   =>    P_END_DATE_ACTIVE       ,
    X_UNCATEGORIZED_FLAG                =>    P_UNCATEGORIZED_FLAG    ,
    X_BUSINESS_GROUP_ID                 =>    P_BUSINESS_GROUP_ID     ,
    X_JOB_GROUP_ID                      =>    P_JOB_GROUP_ID          ,
    X_RESOURCE_LIST_TYPE                =>    P_RESOURCE_LIST_TYPE    ,
    X_LAST_UPDATED_BY                   =>    user_id                 ,
    X_LAST_UPDATE_DATE                  =>    sysdate                 ,
    X_LAST_UPDATE_LOGIN                 =>    0                       );

EXCEPTION
  WHEN no_data_found then
        PA_Resource_List_tbl_Pkg.Insert_row(
    X_ROW_ID                          =>  l_row_id                 ,
    X_RESOURCE_LIST_ID                =>  L_RESOURCE_LIST_ID       ,
    X_NAME                            =>  P_NAME                   ,
    X_DESCRIPTION                     =>  P_DESCRIPTION            ,
    X_PUBLIC_FLAG                     =>  P_PUBLIC_FLAG            ,
    X_GROUP_RESOURCE_TYPE_ID          =>  P_GROUP_RESOURCE_TYPE_ID ,
    X_START_DATE_ACTIVE               =>  P_START_DATE_ACTIVE      ,
    X_END_DATE_ACTIVE                 =>  P_END_DATE_ACTIVE        ,
    X_UNCATEGORIZED_FLAG              =>  P_UNCATEGORIZED_FLAG     ,
    X_BUSINESS_GROUP_ID               =>  P_BUSINESS_GROUP_ID      ,
    X_JOB_GROUP_ID                    =>  P_JOB_GROUP_ID           ,
    X_RESOURCE_LIST_TYPE              =>  P_RESOURCE_LIST_TYPE     ,
    X_LAST_UPDATED_BY                 =>  user_id                  ,
    X_LAST_UPDATE_DATE                =>  sysdate                  ,
    X_CREATION_DATE                   =>  sysdate                  ,
    X_CREATED_BY                      =>  user_id                  ,
    X_LAST_UPDATE_LOGIN               =>  0                        );*/

END LOAD_ROW;

END PA_CREATE_RESOURCE;

/
