--------------------------------------------------------
--  DDL for Package Body PA_GET_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GET_RESOURCE" AS
/* $Header: PAGTRESB.pls 120.4 2006/05/10 16:33:20 ramurthy noship $*/

   Procedure Get_Resource_group (p_resource_list_id        In  Number,
                                 p_resource_group          In  Varchar2,
                                 p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_resource_id             Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_track_as_labor_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 p_err_code                Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_err_stage            In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 p_err_stack            In Out NOCOPY Varchar2) IS --File.Sql.39 bug 4440895
   l_resource_type_id       NUMBER;
   l_resource_id            NUMBER;
   l_org_id	            NUMBER := NULL;

   CURSOR c_resource_lists_csr IS
   SELECT
   group_resource_type_id
   FROM
   pa_resource_lists
   WHERE resource_list_id = p_resource_list_id;

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_code
   FROM
   pa_resource_types
   WHERE resource_type_id = l_resource_type_id;

   CURSOR c_resource_list_member_csr IS
   SELECT
   resource_list_member_id,
   track_as_labor_flag
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   resource_id      = l_resource_id;

   CURSOR c_revenue_category_csr IS
   SELECT
   revenue_category_m
   FROM
   pa_revenue_categories_v
   WHERE
   revenue_category_code = p_resource_group;

   CURSOR c_org_csr IS
   SELECT
   organization_name
   FROM
   pa_organizations_res_v
   WHERE
   organization_id = l_org_id ;

   l_err_code             NUMBER := 0;
   l_resource_list_member_id NUMBER ;
   l_old_stack            VARCHAR2(2000);
   l_resource_type_code   VARCHAR2(30);
   l_expenditure_category VARCHAR2(80):= NULL;
   l_revenue_category     VARCHAR2(80):= NULL;
   l_resource_name        VARCHAR2(80);

  BEGIN
       l_old_stack := p_err_stack;
       p_err_code  := 0;
       p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_resource_group';
       p_err_stage := ' Select group_resource_type_id from pa_resource_lists';

     --- Get the group_resource_type_id of the resource_list
     --- from pa_resource_lists using
     --- x_resource_list_id.

       OPEN c_resource_lists_csr;
       FETCH c_resource_lists_csr INTO l_resource_type_id;
       IF c_resource_lists_csr%NOTFOUND THEN
          p_err_code := 10;
          p_err_stage := 'PA_RL_INVALID';
          CLOSE c_resource_lists_csr;
          RETURN;
       ELSE
          CLOSE c_resource_lists_csr;
       END IF;

       -- If group_resource_type_id is 0 , then
       -- the resource list has been grouped by None.Hence, do not proceed
       IF l_resource_type_id = 0 THEN
          p_resource_list_member_id := NULL;
          p_track_as_labor_flag := NULL;
          RETURN;
       END IF;

       p_err_stage := 'Select resource_type_code from pa_resource_types ';

     ---  Get the resource_type_code of the resource_type from
     ---  pa_resource_types using the resource_type_id.

       OPEN c_resource_types_csr;
       FETCH c_resource_types_csr INTO l_resource_type_code;
       IF c_resource_types_csr%NOTFOUND THEN
          p_err_code  := 11;
          p_err_stage := 'PA_RT_INVALID';
          CLOSE c_resource_types_csr;
          RETURN;
       ELSE
          CLOSE c_resource_types_csr;
       END IF;
       IF l_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
          l_expenditure_category := p_resource_group;
          l_resource_name        := p_resource_group;
       ELSIF l_resource_type_code = 'REVENUE_CATEGORY' THEN
          l_revenue_category     := p_resource_group;
          p_err_stage :=
              ' Select revenue_category_m from pa_revenue_categories_v';
          -- Need to get the revenue_category_m (Meaning) since what is passed
          -- is the revenue_category_code
          OPEN c_revenue_category_csr;
          FETCH c_revenue_category_csr INTO l_resource_name;
          IF c_revenue_category_csr%NOTFOUND THEN
              p_err_code := 12;
              p_err_stage := 'PA_INVALID_REV_CATEG';
              CLOSE c_revenue_category_csr;
              RETURN;
          ELSE
              CLOSE c_revenue_category_csr;
          END IF;
       ELSIF l_resource_type_code = 'ORGANIZATION' THEN
          l_org_id     := TO_NUMBER(p_resource_group);
          p_err_stage :=
              ' Select organization_name from pa_organizations_res_v';
          -- Need to get the organization_name since what is passed
          -- is the organization id
          OPEN c_org_csr;
          FETCH c_org_csr INTO l_resource_name;
          IF c_org_csr%NOTFOUND THEN
              p_err_code := 13;
              p_err_stage := 'PA_INVALID_ORGANIZATION';
              CLOSE c_org_csr;
              RETURN;
          ELSE
              CLOSE c_org_csr;
          END IF;
       END IF;

     --- To get the resource_list_member_id , we need the resource_id. hence
     --- Check whether the resource_group has already been created as
     --- a resource in PA_RESOURCE table and get the resource_id.
     --- Hence, call Get_resource
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
                  p_project_role_id	    => NULL,
                  p_resource_id             => l_resource_id,
                  p_err_code                => l_err_code,
                  p_err_stage               => p_err_stage,
                  p_err_stack               => p_err_stack );


      IF l_err_code <> 0 THEN
         p_err_code := l_err_code;
         RETURN;
      END IF;
      --- If the resource_group has not been created as a resource yet,then
      --- it means, it could not have been created as a resource_group yet.
      --- l_Resource_id would be null in this case.
      --- Hence return at this stage  with p_resource_list_member_id as null.
      IF  l_resource_id IS NULL THEN
          p_err_stack := l_old_stack;
          p_resource_list_member_id := NULL;
          p_resource_id             := NULL;
          p_track_as_labor_flag     := NULL;
          RETURN;
      END IF;

      p_err_stage :=
      'Select resource_list_member_id from pa_resource_list_members';
      OPEN c_resource_list_member_csr;
      FETCH c_resource_list_member_csr INTO
            l_resource_list_member_id,
            p_track_as_labor_flag;
      IF    c_resource_list_member_csr%NOTFOUND THEN
            p_resource_list_member_id := NULL;
            p_track_as_labor_flag     := NULL;
      END IF;
      CLOSE c_resource_list_member_csr;
      p_resource_list_member_id := l_resource_list_member_id;
      p_resource_id             := l_resource_id;
      p_err_stack := l_old_stack;

 EXCEPTION
     WHEN OTHERS THEN
          p_err_code := SQLCODE;

	  -- 4537865 : Start : RESET other OUT PARAMS also
	  p_resource_list_member_id   := NULL ;
	  p_resource_id               := NULL ;
	  p_track_as_labor_flag       := NULL ;

	  -- Dont reset p_err_stage as it will already be populated to correct value

	  p_err_stack := p_err_stack || ' : ' ||  SUBSTRB(SQLERRM,1,100);
                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Resource_group'
                    , p_error_text      => p_err_stack);
	  -- 4537865 : End

          RAISE;
  End Get_Resource_group;

--Name:               Get_Resource_list_member
--Type:               Procedure
--Description:        This procedure retrieves the resource_list_member_id for a given
--                    set of transaction attributes...
--
--Called subprograms: ?
--
--History:
--	xx-xxx-xxxx	rkrishna		Created
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--                                              1. New IN-parameter, p_project_role_id, required.
--
   Procedure Get_Resource_list_member (p_resource_list_id        In  Number,
                                       p_resource_name           In  Varchar2,
                                       p_resource_type_Code      In  Varchar2,
                                       p_group_resource_type_id  In  Number,
                                       p_person_id               In  Number,
                                       p_job_id                  In  Number,
                                       p_proj_organization_id    In  Number,
                                       p_vendor_id               In  Number,
                                       p_expenditure_type        In  Varchar2,
                                       p_event_type              In  Varchar2,
                                       p_expenditure_category    In  Varchar2,
                                       p_revenue_category_code   In  Varchar2,
                                       p_non_labor_resource      In  Varchar2,
                                       p_system_linkage          In  Varchar2,
                                       p_parent_member_id        In  Number,
                                       p_project_role_id         IN  NUMBER,
                                       p_resource_id            Out  NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag    Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code               Out  NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage           In Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack           In Out  NOCOPY Varchar2) --File.Sql.39 bug 4440895
   IS
   l_old_stack            VARCHAR2(2000);
   l_err_code             NUMBER := 0;
   l_resource_id          NUMBER;

   CURSOR c_resource_list_member_csr_1 IS
   SELECT
   resource_list_member_id,
   track_as_labor_flag
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id IS NULL
   AND   resource_id      = l_resource_id;

   CURSOR c_resource_list_member_csr_2 IS
   SELECT
   resource_list_member_id,
   track_as_labor_flag
   FROM
   pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
   AND   parent_member_id = p_parent_member_id
   AND   resource_id      = l_resource_id;
  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Resource_list_member';
       IF p_group_resource_type_id = 0 AND
          p_parent_member_id IS NOT NULL THEN
         -- This means the resource list has not been grouped.
         ---Hence,parent_member_id should be null
           p_err_code := 10;
           p_err_stage := 'PA_RL_NOT_GROUPED';
           RETURN;
       ELSIF p_group_resource_type_id <> 0 AND
          p_parent_member_id IS NULL THEN
         -- This means the resource list has been grouped.
         ---Hence,parent_member_id should not be null
           p_err_code := 11;
           p_err_stage := 'PA_RL_GROUPED';
           RETURN;
       END IF;
       -- First need to get the resource_id of the input resource
       -- Hence,call Get_resource

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
                  p_project_role_id         => p_project_role_id,
                  p_resource_id             => l_resource_id,
                  p_err_code                => l_err_code,
                  p_err_stage               => p_err_stage,
                  p_err_stack               => p_err_stack );

      IF l_err_code <> 0 THEN
         p_err_code := l_err_code;
         RETURN;
      END IF;
     --If l_resource_id is null, then the resource itself is yet to be created.
     -- Hence,return resource_list_member_id and track_as_labor_flag as null

      IF  l_resource_id IS NULL THEN
          p_err_stack := l_old_stack;
          p_resource_list_member_id := NULL;
          p_resource_id             := NULL;
          p_track_as_labor_flag     := NULL;
          RETURN;
      END IF;

      p_err_stage :=
      'Select resource_list_member_id from pa_resource_list_members';
      IF p_parent_member_id IS NULL THEN
         OPEN c_resource_list_member_csr_1;
         FETCH c_resource_list_member_csr_1 INTO
               p_resource_list_member_id,
               p_track_as_labor_flag;
         IF    c_resource_list_member_csr_1%NOTFOUND THEN
               p_resource_list_member_id := NULL;
               p_track_as_labor_flag     := NULL;
         END IF;
         CLOSE c_resource_list_member_csr_1;
      ELSIF p_parent_member_id IS NOT NULL THEN
         OPEN c_resource_list_member_csr_2;
         FETCH c_resource_list_member_csr_2 INTO
               p_resource_list_member_id,
               p_track_as_labor_flag;
         IF    c_resource_list_member_csr_2%NOTFOUND THEN
               p_resource_list_member_id := NULL;
               p_track_as_labor_flag     := NULL;
         END IF;
         CLOSE c_resource_list_member_csr_2;
      END IF;
       p_resource_id := l_resource_id;
       p_err_stack := l_old_stack;

 EXCEPTION
     WHEN OTHERS THEN
          p_err_code := SQLCODE;

          -- 4537865 : Start : RESET other OUT PARAMS also
          p_resource_list_member_id   := NULL ;
          p_resource_id               := NULL ;
          p_track_as_labor_flag       := NULL ;

          -- Dont reset p_err_stage as it will already be populated to correct value

          p_err_stack := p_err_stack || ' : ' ||  SUBSTRB(SQLERRM,1,100);
                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Resource_list_member'
                    , p_error_text      => p_err_stack);
          -- 4537865 : End

          RAISE;

  END Get_Resource_list_member;


--Name:               Get_Resource
--Type:               Procedure
--Description:        This procedure...
--
--Called subprograms: ?
--
-- History
--
--	xx-xxx-97	rkrishna		- Created.
--
-- 	22-APR-98	jwhite		- For the Get_Resource procedure,
--					  Converted the Dynamic SQL to hardcoded cursors
--					  to address performance issues related to bug
--					  #606398.
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--						1. New IN-parameter, p_project_role_id, required.
--                                              2. New cursor, resource_project_role_csr, required.
--						3. New p_resource_type_code validation and
--                                                 new error message.
--                                              4. New fetch for new cursor.
--
--

Procedure Get_Resource (p_resource_name           In  Varchar2,
                            p_resource_type_Code      In  Varchar2,
                            p_person_id               In  Number,
                            p_job_id                  In  Number,
                            p_proj_organization_id    In  Number,
                            p_vendor_id               In  Number,
                            p_expenditure_type        In  Varchar2,
                            p_event_type              In  Varchar2,
                            p_expenditure_category    In  Varchar2,
                            p_revenue_category_code   In  Varchar2,
                            p_non_labor_resource      In  Varchar2,
                            p_system_linkage          In  Varchar2,
                            p_project_role_id         IN  NUMBER,
                            p_resource_id            Out  NOCOPY Number, --File.Sql.39 bug 4440895
                            p_err_code               Out  NOCOPY Number, --File.Sql.39 bug 4440895
                            p_err_stage           In Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            p_err_stack           In Out  NOCOPY Varchar2) --File.Sql.39 bug 4440895
   IS

   CURSOR c_resource_types_csr IS
   SELECT
   resource_type_id
   FROM
   pa_resource_types
   WHERE resource_type_code = p_resource_type_code;

--
-- 22-APR-98 ------------------------------------------------
-- Replaced dynamic SQL with hardcoded
-- cursors to enhance performance.

CURSOR              resource_employee_csr (p_person_id NUMBER, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		 pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.person_id = p_person_id;

CURSOR              resource_job_csr (p_job_id  NUMBER, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.job_id = p_job_id ;

CURSOR              resource_org_csr (p_proj_organization_id NUMBER, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.organization_id  = p_proj_organization_id;

CURSOR              resource_vendor_csr (p_vendor_id NUMBER, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.vendor_id = p_vendor_id;

CURSOR              resource_exp_type_csr (p_expenditure_type VARCHAR2
					, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.expenditure_type  = p_expenditure_type;

CURSOR              resource_event_type_csr (p_event_type VARCHAR2, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.event_type = p_event_type;

CURSOR              resource_exp_cat_csr (p_expenditure_category VARCHAR2
					, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND 		b.expenditure_category = p_expenditure_category;


CURSOR              resource_rev_cat_csr (p_revenue_category_code VARCHAR2
					, l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND 		b.revenue_category = p_revenue_category_code;

CURSOR              resource_project_role_csr (p_project_role_id  NUMBER
                                                 , l_resource_type_id NUMBER)
IS
SELECT               a.resource_id
FROM		pa_resources a, pa_resource_txn_attributes b
WHERE               a.resource_type_id = l_resource_type_id
AND                     a.resource_id  = b.resource_id
AND		b.project_role_id = p_project_role_id ;


-- -----------------------------------------------------------------

   l_old_stack            VARCHAR2(2000);
   l_resource_type_id     NUMBER;
   l_resource_id          NUMBER;


  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Resource';

     -- Based on the Resource_type_code Ensure that the corresponding
     -- attribute has a valid value.

    IF (p_resource_type_code = 'EMPLOYEE' AND
        p_person_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_PERSON_ID';
        RETURN;
    ELSIF (p_resource_type_code = 'JOB' AND
        p_job_id IS NULL) THEN
        p_err_code := 10;
        p_err_stage := 'PA_NO_JOB_ID';
        RETURN;
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
       p_err_stage := 'Select resource_type_id from pa_resource_types ';

     ---  Get the resource_type_id of the resource_type from
     ---  pa_resource_types using the resource_type_code.

       OPEN c_resource_types_csr;
       FETCH c_resource_types_csr INTO l_resource_type_id;
       IF c_resource_types_csr%NOTFOUND THEN
          p_err_code  := 11;
          p_err_stage := 'PA_RT_INVALID';
          CLOSE c_resource_types_csr;
          RETURN;
       ELSE
          CLOSE c_resource_types_csr;
       END IF;

-- 22-APR-97, jwhite -----------------------------------------
-- Changed code to FETCH hardcoded cursors.
--

p_err_stage := 'Select resource_id from pa_resource_txn_attributes ';

          IF (p_resource_type_code = 'EMPLOYEE') THEN
	OPEN resource_employee_csr (p_person_id, l_resource_type_id);
	FETCH resource_employee_csr INTO l_resource_id;
	CLOSE resource_employee_csr;
          ELSIF p_resource_type_code = 'JOB' THEN
 	OPEN resource_job_csr(p_job_id, l_resource_type_id);
	FETCH resource_job_csr INTO l_resource_id;
	CLOSE resource_job_csr;
          ELSIF p_resource_type_code = 'ORGANIZATION' THEN
 	OPEN resource_org_csr(p_proj_organization_id, l_resource_type_id);
	FETCH resource_org_csr INTO l_resource_id;
	CLOSE resource_org_csr;
          ELSIF p_resource_type_code = 'VENDOR' THEN
	 OPEN resource_vendor_csr(p_vendor_id, l_resource_type_id);
	FETCH resource_vendor_csr INTO l_resource_id;
	CLOSE resource_vendor_csr;
          ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
	 OPEN resource_exp_type_csr(p_expenditure_type, l_resource_type_id);
	FETCH resource_exp_type_csr INTO l_resource_id;
	CLOSE resource_exp_type_csr;
          ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
 	OPEN resource_event_type_csr(p_event_type, l_resource_type_id );
	FETCH resource_event_type_csr INTO l_resource_id;
	CLOSE resource_event_type_csr;
          ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
 	OPEN resource_exp_cat_csr(p_expenditure_category	, l_resource_type_id );
	FETCH resource_exp_cat_csr INTO l_resource_id;
	CLOSE resource_exp_cat_csr;
          ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
 	OPEN resource_rev_cat_csr(p_revenue_category_code, l_resource_type_id );
	FETCH resource_rev_cat_csr INTO l_resource_id;
	CLOSE resource_rev_cat_csr;
          ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
 	OPEN resource_project_role_csr(p_project_role_id, l_resource_type_id);
	FETCH resource_project_role_csr INTO l_resource_id;
	CLOSE resource_project_role_csr;
          END IF;
  -- ----------------------------------------------------------

       p_resource_id := l_resource_id;
       p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
       p_err_code := SQLCODE;

       -- 4537865
       p_resource_id := NULL ;
       p_err_stack := p_err_stack || ' ' || SUBSTRB(SQLERRM,1,100) ;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Resource'
                    , p_error_text      => p_err_stack);
       -- 4537865 : dont reset p_err_stage as it will be already properly populated.

       RAISE;
 END Get_Resource;

--Name:               Get_Resource_Information
--Type:               Procedure
--Description:        This procedure ...
--
--Called subprograms: ?
--
--History:
--	xx-xxx-xxxx	rkrishna		Created
--
--	16-MAR-2001	jwhite			Bug 1685015: Forecast/Bgt Integration
--						1.	New p_resource_type_code assignment.
--						2. 	Error messaging for NO_DATA_FOUND
--
--
  Procedure Get_Resource_Information  (p_resource_type_Code      In  Varchar2,
                                       p_resource_attr_value     In  Varchar2,
                                       p_unit_of_measure        Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_Rollup_quantity_flag   Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code               Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage           In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack           In Out NOCOPY Varchar2) --File.Sql.39 bug 4440895
IS
   l_old_stack            VARCHAR2(2000);
   l_resource_type_id     NUMBER;
   l_resource_id          NUMBER;
   l_cursor               INTEGER;
   l_statement            VARCHAR2(2000);
   l_rows                 INTEGER;
   l_person_id            NUMBER;
   l_job_id               NUMBER;
   l_organization_id      NUMBER;
   l_vendor_id            NUMBER;
   l_uom                  VARCHAR2(30);
   l_rollup_qty_flag      VARCHAR2(1);
   l_track_as_labor_flag  VARCHAR2(1);
   l_project_role_id      NUMBER := NULL;

  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Resource_Information';

     -- Based on the Resource_type_code form the dynamic SQL statement
     -- to fetch from the appropriate views
     -- Since all the Id fields like person_id,job_id etc are number fields
     -- it is better to convert the value of p_resource_attr_value to
     -- number in case p_resource_type_code is 'EMPLOYEE','JOB' etc
     --  and store in appropriate variables.This is to ensure
     -- that the parser does not do an implicit conversion at runtime
     -- which would affect performance
     -- For eg : if we use ' where person_id = p_resource_attr_value'
     -- it is likely that the parser would interpret it as
     -- ' where to_char(person_id) = p_resource_attr_value '
     -- which might impact the performance

         l_cursor := dbms_sql.open_cursor;

         l_statement := 'Select unit_of_measure,rollup_quantity_flag ,'||
                        ' track_as_labor_flag  from  ';

          IF (p_resource_type_code = 'EMPLOYEE') THEN
              l_person_id := to_number (p_resource_attr_value);
              l_statement :=
              l_statement ||'pa_employees_res_v where person_id = :person_id ';
          ELSIF p_resource_type_code = 'JOB' THEN
              l_job_id := to_number (p_resource_attr_value);
              l_statement :=
              l_statement ||'pa_jobs_res_v where job_id = :job_id ';
          ELSIF p_resource_type_code = 'ORGANIZATION' THEN
              l_organization_id := to_number (p_resource_attr_value);
              l_statement :=
              l_statement ||'pa_organizations_res_v  ' ||
              ' where organization_id = :organization_id ';
          ELSIF p_resource_type_code = 'VENDOR' THEN
              l_vendor_id := to_number (p_resource_attr_value);
              l_statement :=
              l_statement ||'pa_vendors_res_v where vendor_id = :vendor_id ';
          ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
              l_statement :=
              l_statement ||'pa_expenditure_types_res_v ' ||
              ' where expenditure_type = :expenditure_type ';
          ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
              l_statement :=
              l_statement ||'pa_event_types_res_v ' ||
              ' where event_type = :event_type ';
          ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
              l_statement :=
              l_statement ||'pa_expend_categories_res_v ' ||
              ' where expenditure_category = :expenditure_category ';
          ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
              l_statement :=
              l_statement ||'pa_revenue_categories_res_v ' ||
              ' where revenue_category_code = :revenue_category_code ';
          ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
              l_project_role_id := to_number(p_resource_attr_value);
              l_statement :=
              l_statement ||'pa_project_roles_res_v where project_role_id = :project_role_id ';
          END IF;

          dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

          IF (p_resource_type_code = 'EMPLOYEE') THEN
              dbms_sql.bind_variable
              (l_cursor, 'person_id', l_person_id );
          ELSIF p_resource_type_code = 'JOB' THEN
              dbms_sql.bind_variable
              (l_cursor, 'job_id', l_job_id );
          ELSIF p_resource_type_code = 'ORGANIZATION' THEN
              dbms_sql.bind_variable
              (l_cursor, 'organization_id', l_organization_id );
          ELSIF p_resource_type_code = 'VENDOR' THEN
              dbms_sql.bind_variable
              (l_cursor, 'vendor_id', l_vendor_id );
          ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
              dbms_sql.bind_variable
              (l_cursor, 'expenditure_type', p_resource_attr_value );
          ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
              dbms_sql.bind_variable
              (l_cursor, 'event_type', p_resource_attr_value );
          ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
              dbms_sql.bind_variable
              (l_cursor, 'expenditure_category', p_resource_attr_value );
          ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
              dbms_sql.bind_variable
              (l_cursor, 'revenue_category_code', p_resource_attr_value );
          ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
              dbms_sql.bind_variable
              (l_cursor, 'project_role_id', l_project_role_id );
          END IF;
       p_err_stage := 'Select unit_of_measure...from ... ';
       dbms_sql.define_column (l_cursor, 1, l_uom,30);
       dbms_sql.define_column (l_cursor, 2, l_rollup_qty_flag,1);
       dbms_sql.define_column (l_cursor, 3, l_track_as_labor_flag,1);

       l_rows   := dbms_sql.execute(l_cursor);
       IF dbms_sql.fetch_rows( l_cursor ) > 0 THEN
          dbms_sql.column_value (l_cursor, 1, l_uom);
          dbms_sql.column_value (l_cursor, 2, l_rollup_qty_flag);
          dbms_sql.column_value (l_cursor, 3, l_track_as_labor_flag);
          p_unit_of_measure := l_uom;
          p_rollup_quantity_flag := l_rollup_qty_flag;
          p_track_as_labor_flag := l_track_as_labor_flag;
       ELSE   -- if no rows were returned then the input is not a valid
              -- resource for that resource type.Hence, we need to raise
              -- error
          p_unit_of_measure := NULL;
          p_rollup_quantity_flag := NULL;
          p_track_as_labor_flag := NULL;
          IF (p_resource_type_code = 'EMPLOYEE') THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_EMPLOYEE';
          ELSIF p_resource_type_code = 'JOB' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_JOB';
          ELSIF p_resource_type_code = 'ORGANIZATION' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_ORGANIZATION';
          ELSIF p_resource_type_code = 'VENDOR' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_VENDOR';
          ELSIF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_EXPENDITURE_TYPE';
          ELSIF p_resource_type_code = 'EVENT_TYPE' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_EVENT_TYPE';
          ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_EXP_CATEGORY';
          ELSIF p_resource_type_code = 'REVENUE_CATEGORY' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_REV_CATEG';
          ELSIF p_resource_type_code = 'PROJECT_ROLE' THEN
              p_err_code := 10;
              p_err_stage := 'PA_INVALID_PROJECT_ROLE';
          END IF;
          RETURN;
       END IF;
       IF dbms_sql.is_open (l_cursor) THEN
         dbms_sql.close_cursor (l_cursor);
       END IF;
       p_err_stack := l_old_stack;

  -- 4537865 Included Exception Handling - WHEN OTHERS Block
  EXCEPTION
	WHEN OTHERS THEN
	        p_unit_of_measure     := NULL ;
	        p_Rollup_quantity_flag:= NULL ;
       		p_track_as_labor_flag := NULL ;
		p_err_code            := SQLCODE;
		p_err_stack := p_err_stack || ' : ' || SUBSTRB(SQLERRM,1,100);

		Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Resource_Information'
                    , p_error_text      => p_err_stack);
		RAISE;
  End Get_Resource_Information;

  Procedure Get_Uncateg_Resource_Info  (p_resource_list_id        Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_resource_id             Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_track_as_labor_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        p_err_code                Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_err_stage            In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        p_err_stack            In Out NOCOPY Varchar2) --File.Sql.39 bug 4440895

   IS
   l_old_stack            VARCHAR2(2000);

   CURSOR resource_list_uncateg_csr IS
   SELECT
   rl.resource_list_id,
   rlm.resource_list_member_id,
   rlm.resource_id,
   rlm.track_as_labor_flag
   FROM
   pa_resource_lists rl,
   pa_resource_list_members rlm
   WHERE rl.uncategorized_flag = 'Y'
   AND rlm.resource_class_code = 'FINANCIAL_ELEMENTS' -- shelly
   AND rlm.resource_class_flag = 'Y' --shelly
   AND rl.resource_list_id = rlm.resource_list_id
   AND rl.business_group_id = pa_utils.business_group_id; /* Added for Bug 2373165 */

  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Uncateg_Resource_Info';

     OPEN resource_list_uncateg_csr;
     FETCH resource_list_uncateg_csr INTO
           p_resource_list_id,
           p_resource_list_member_id,
           p_resource_id,
           p_track_as_labor_flag;
     IF resource_list_uncateg_csr%NOTFOUND THEN
        CLOSE resource_list_uncateg_csr;
        RAISE NO_DATA_FOUND;
     ELSE
        CLOSE resource_list_uncateg_csr;
     END IF;
     p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
	-- 4537865 : RESET other out params also.

	p_resource_list_member_id := NULL ;
	p_resource_id             := NULL ;
        p_track_as_labor_flag  := NULL ;

	p_err_stack  := p_err_stack || ' : ' || SUBSTRB(SQLERRM,1,100);
                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Uncateg_Resource_Info'
                    , p_error_text      => p_err_stack);
	-- 4537865 : End
        RAISE;

 END Get_Uncateg_Resource_Info;

  Procedure Get_Unclassified_Member  (p_resource_list_id           In Number,
                                      p_parent_member_id           In Number,
                                      p_unclassified_resource_id   In Number,
                                      p_resource_list_member_id   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                      p_track_as_labor_flag       Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      p_err_code                  Out NOCOPY Number, --File.Sql.39 bug 4440895
                                      p_err_stage              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      p_err_stack              In Out NOCOPY Varchar2) --File.Sql.39 bug 4440895

   IS
     l_old_stack varchar2(2000);

     CURSOR res_list_member_csr_1 IS
     SELECT
     resource_list_member_id,
     track_as_labor_flag
     FROM
     pa_resource_list_members
     WHERE  resource_list_id = p_resource_list_id
     AND parent_member_id IS NULL
     AND resource_id = p_unclassified_resource_id;

     CURSOR res_list_member_csr_2 IS
     SELECT
     resource_list_member_id,
     track_as_labor_flag
     FROM
     pa_resource_list_members
     WHERE  resource_list_id = p_resource_list_id
     AND parent_member_id = p_parent_member_id
     AND resource_id = p_unclassified_resource_id;

  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Unclassified_Member';

     ---If parent_member_id is Null, then need to return the
     ---   resource_list_member_id of the Unclassified resource at the Resource
     ---   list level;
     ---else
     ---   return the resource_list_member_id of the unclassified resource
     ---   at the resource_group level

      IF p_parent_member_id IS NULL THEN
         OPEN res_list_member_csr_1;
         FETCH res_list_member_csr_1 INTO
               p_resource_list_member_id,
               p_track_as_labor_flag;
         IF    res_list_member_csr_1%NOTFOUND THEN
               CLOSE res_list_member_csr_1;
               RAISE NO_DATA_FOUND;
         ELSE
               CLOSE res_list_member_csr_1;
         END IF;
      ELSE
         OPEN res_list_member_csr_2;
         FETCH res_list_member_csr_2 INTO
               p_resource_list_member_id,
               p_track_as_labor_flag;
         IF    res_list_member_csr_2%NOTFOUND THEN
               p_resource_list_member_id := NULL;
               p_track_as_labor_flag     := NULL;
         END IF;
         CLOSE res_list_member_csr_2;
      END IF;

      p_err_stack := l_old_stack;

  EXCEPTION
     WHEN OTHERS THEN
        p_err_code := SQLCODE;
	-- 4537865 : Start
	p_resource_list_member_id := NULL;
	p_track_as_labor_flag     := NULL;
	p_err_stack := p_err_stack || ': ' || SUBSTRB(SQLERRM,1,100);

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Unclassified_Member'
                    , p_error_text      => p_err_stack);
	-- 4537865 : ENd
        RAISE;

  END Get_Unclassified_Member;

  Procedure Get_Unclassified_Resource (p_resource_id              Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_resource_name            Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag      Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_unit_of_measure          Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_rollup_quantity_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code                 Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage             In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack             In Out NOCOPY Varchar2) --File.Sql.39 bug 4440895

   IS
   CURSOR unclassified_res_csr  IS
   SELECT par.resource_id,
          par.name,
          par.track_as_labor_flag,
          par.unit_of_measure,
          par.rollup_quantity_flag
   FROM   pa_resources par,
          pa_resource_types part
   WHERE  part.resource_type_code = 'UNCLASSIFIED'
   AND    part.resource_type_id   = par.resource_type_id;

   l_old_stack varchar2(2000);
  BEGIN
     l_old_stack := p_err_stack;
     p_err_code  := 0;
     p_err_stack := p_err_stack ||'->PA_GET_RESOURCE.Get_Unclassified_Resource';

     OPEN unclassified_res_csr;
     FETCH unclassified_res_csr INTO
           p_resource_id,
           p_resource_name,
           p_track_as_labor_flag,
           p_unit_of_measure,
           p_rollup_quantity_flag;
     IF unclassified_res_csr%NOTFOUND THEN
        CLOSE unclassified_res_csr;
        RAISE NO_DATA_FOUND;
     END IF;
     CLOSE unclassified_res_csr;
     p_err_stack := l_old_stack;
  EXCEPTION
     WHEN OTHERS THEN
          p_err_code := SQLCODE;
	 -- 4537865 : Start
	 p_resource_id           := NULL ;
	 p_resource_name         := NULL ;
	 p_track_as_labor_flag   := NULL ;
	 p_unit_of_measure       := NULL ;
	 p_rollup_quantity_flag  := NULL ;
	 p_err_stack             := p_err_stack || ' : ' || SUBSTRB(SQLERRM,1,100);
         Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_GET_RESOURCE'
                    , p_procedure_name  => 'Get_Unclassified_Resource'
                    , p_error_text      => p_err_stack);
         -- 4537865 : End

          RAISE;
  END Get_Unclassified_Resource;

FUNCTION Include_Inactive_Resources RETURN VARCHAR2 IS
-- This function returns the value in the Package variable
-- G_include_inactive_res_flag. It returns 'Y' or 'N'
-- which serves as the basis for some resource views
-- to determine whether to return inactive resources or not

BEGIN
    RETURN G_include_inactive_res_flag;
END Include_Inactive_Resources;

PROCEDURE Set_Inactive_Resources_Flag (p_set_flag IN VARCHAR2)  IS

BEGIN
    G_include_inactive_res_flag := p_Set_Flag;

END Set_Inactive_Resources_Flag;



FUNCTION  Child_resource_exists
-- This function checks existence of child level resource member
-- for a resource member  . It is using pa_project_accum_headers
-- to ensure that for the specified project and task that resource
-- was used for accumulation .This is done because this function is
-- called from project status inquiry
(p_resource_id   number ,
 p_task_id number,
 p_project_id number
)
RETURN VARCHAR2 is
  rv varchar2(1) ;
  temp number;
begin
  begin
    select 1
    into   temp
    from  sys.dual where
  exists ( select 1 from pa_resource_list_members p,pa_project_accum_headers h
    where p.resource_list_member_id = h.resource_list_member_id
      and p.parent_member_id = p_resource_id
      and h.project_id  = p_project_id
      and h.task_id  = p_task_id );
    rv := 'Y';
  exception
    when NO_DATA_FOUND then
      rv := 'N';
  end;
  return rv;
End Child_resource_exists;

-- added by jayashree on sept 24' 98
Procedure delete_resource_list_ok(l_resource_list_id NUMBER,
                                  p_is_plan_res_list  IN VARCHAR2 default 'N',
                                  x_err_code IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_err_stage IN OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_dummy        VARCHAR2(1);

--Check for Resource List Members OTHER THAN UNclassified
CURSOR   l_members_csr (l_resource_list_id NUMBER)
IS
SELECT   'x'
FROM     dual
WHERE    exists
      (select 'x'
      from pa_resource_list_members rlm
         , pa_resources r
         , pa_resource_types rt
                 where
      rlm.resource_list_id = l_resource_list_id
      and rlm.resource_id = r.resource_id
      and r.resource_type_id = rt.resource_type_id
      and rt.resource_type_code <> 'UNCLASSIFIED');


-- Check for Resource List in Resource List Assignments
CURSOR   l_list_assignments_csr (l_resource_list_id NUMBER)
IS
SELECT   'x'
FROM     dual
WHERE    exists
      (select 'x'
        from pa_resource_list_assignments rla
         where    rla.resource_list_id = l_resource_list_id);

-- Check for Resource List in Project Types All

-- Modified for perf bug 4887375
Cursor check_resource_list_csr (l_resource_list_id NUMBER)
IS
Select 'X'
From dual
Where exists
(Select null
 From pa_project_types_all pa
 Where pa.DEFAULT_RESOURCE_LIST_ID     = l_resource_list_id
 Or    pa.COST_BUDGET_RESOURCE_LIST_ID = l_resource_list_id
 Or    pa.REV_BUDGET_RESOURCE_LIST_ID  = l_resource_list_id);

-- Check for Resource List in Budget Version

-- Modified for perf bug 4887375
Cursor check_resource_budget_list (l_resource_list_id NUMBER)
IS
Select 'X'
From dual
Where exists
(Select null
 From pa_budget_versions
 Where resource_list_id = l_resource_list_id);

-- Check for Resource list in Proj_Fp_Options

Cursor check_resource_proj_fp_list (l_resource_list_id NUMBER)
IS
Select 'X'
From   pa_proj_fp_options
Where  all_resource_list_id = l_resource_list_id
      OR cost_resource_list_id = l_resource_list_id
      OR revenue_resource_list_id = l_resource_list_id;

l_resource_list_pa varchar2(1);

BEGIN

x_err_code := 0;

-- VALIDATION LAYER ---------------------------------------------------------

-- Check for Resource List Members OTHER THAN UNclassified

IF p_is_plan_res_list <> 'Y' THEN
   OPEN  l_members_csr (l_resource_list_id);
   FETCH l_members_csr INTO  l_dummy;
   IF l_members_csr%FOUND THEN
      x_err_code := 10;
      x_err_stage :=  'PA_RSRC_LIST_HAS_MEMBERS';
      return;
  END IF;
      CLOSE l_members_csr;
END IF;

-- Check for Resource List in Resource List Assignements

   OPEN  l_list_assignments_csr (l_resource_list_id);
   FETCH    l_list_assignments_csr INTO  l_dummy;
   IF l_list_assignments_csr%FOUND THEN
      x_err_code := 20;
      x_err_stage := 'PA_RSRC_LIST_USED_ASSIGNMENTS';
      return;
   END IF;
      CLOSE l_list_assignments_csr;

-- Check for Resource List in Project Type All

    Open check_resource_list_csr (l_resource_list_id);
    Fetch check_resource_list_csr INTO l_dummy;

    if check_resource_list_csr%FOUND then
       x_err_code := 30;
       x_err_stage := 'PA_RL_PT_USED';
       return;
   end if;
       Close check_resource_list_csr;

-- Check for Resource List in Budget Version

    Open check_resource_budget_list (l_resource_list_id);
    Fetch check_resource_budget_list INTO l_dummy;

    if check_resource_budget_list%FOUND then
       x_err_code := 40;
       x_err_stage := 'PA_RL_BUDGET_USED';
       return;
    end if;
       Close check_resource_budget_list;

-- Check for Resource List in Proj_FP_Options

    Open check_resource_proj_fp_list (l_resource_list_id);
    Fetch check_resource_proj_fp_list INTO l_dummy;

    if check_resource_proj_fp_list%FOUND then
       x_err_code := 45;
       x_err_stage := 'PA_RL_PROJ_FP_USED';
       return;
    end if;
       Close check_resource_proj_fp_list;

--Check for resource list in project allocations
   l_resource_list_pa := PA_ALLOC_UTILS.is_resource_list_in_rules(l_resource_list_id);
   If l_resource_list_pa = 'Y' Then
      x_err_code := 50;
      x_err_stage := 'PA_RES_LIST_EXISTS_PROJ_ALLOC';
      return;
   End If;
Exception
  when others then
    x_err_code := SQLCODE;
    x_err_stage := SQLERRM;
    rollback;
    return;

END delete_resource_list_ok;

Procedure delete_resource_list_member_ok(l_resource_list_id NUMBER,l_resource_list_member_id NUMBER,x_err_code IN OUT NOCOPY NUMBER,x_err_stage IN OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_dummy        VARCHAR2(1);

-- Check for Resource List Member Id in Project Accum Headers

CURSOR   l_accum_headers_csr (l_resource_list_id NUMBER,
               l_resource_list_member_id NUMBER)
IS
SELECT   'x'
FROM     dual
WHERE    exists
      (select 'x'
        from  pa_resource_list_assignments rla, pa_project_accum_headers pah
        where  rla.resource_list_id = l_resource_list_id
        and    rla.project_id = pah.project_id
        and rla.resource_list_id = pah.resource_list_id
        and pah.resource_list_member_id = l_resource_list_member_id);

-- Check for Resource List Member Id in Budgets

CURSOR   l_budgets_csr (l_resource_list_id NUMBER,
               l_resource_list_member_id NUMBER)
IS
/* Modified for perf bug 4887375
SELECT   'x'
FROM     dual
WHERE    exists
      (select 'x'
        from  pa_resource_list_assignments rla
         , pa_budget_versions bv
         , pa_resource_assignments ra
        where  rla.resource_list_id = l_resource_list_id
        and    rla.project_id = bv.project_id
        and rla.resource_list_id = bv.resource_list_id
        and    bv.budget_version_id = ra.budget_version_id
        and bv.project_id  = ra.project_id
        and ra.resource_list_member_id = l_resource_list_member_id);*/
SELECT   'x'
FROM     dual
WHERE    exists
      (select 'x'
        from pa_resource_assignments ra
        where ra.resource_list_member_id = l_resource_list_member_id);

-- Check for Resource List Member Id in Pa_Fp_Elements

-- Bug 5199763 - pa_fp_elements is obsolete in R12.  Hence, commenting out.
-- CURSOR    l_elements_csr
-- IS
-- SELECT 'x'
-- FROM   dual
-- WHERE  exists
     -- (select 'x'
       -- from  pa_fp_elements pfe
      -- where  pfe.resource_list_member_id = l_resource_list_member_id);

l_resource_pa varchar2(1);

BEGIN

x_err_code := 0;

-- VALIDATION LAYER ----------------------------------------------------------
----


-- Check for Resource List Member in Project_Accum_Headers

   OPEN  l_accum_headers_csr (l_resource_list_id,l_resource_list_member_id );

   FETCH l_accum_headers_csr INTO  l_dummy;
   IF l_accum_headers_csr %FOUND THEN
      x_err_code := 10;
      x_err_stage := 'PA_RLM_USED_IN_ACCUM';
      return;
   END IF;
      CLOSE l_accum_headers_csr;

-- Check for Resource List Member in pa_fp_elements
-- Bug 5199763 - pa_fp_elements is obsolete in R12.  Hence, commenting out.

--   OPEN  l_elements_csr;
--   FETCH l_elements_csr INTO  l_dummy;
--   IF l_elements_csr  %FOUND THEN
--      x_err_code := 15;
--      x_err_stage := 'PA_RLM_USED_IN_FP_OPTIONS';
--      return;
--   END IF;
--   CLOSE l_elements_csr;

-- Check for Resource List Member in Budgets

   OPEN  l_budgets_csr (l_resource_list_id,l_resource_list_member_id );

   FETCH l_budgets_csr INTO  l_dummy;
   IF l_budgets_csr %FOUND THEN
      x_err_code := 20;
      x_err_stage := 'PA_RLM_USED_IN_BUDGETS';
      return;
   END IF;
      CLOSE l_budgets_csr;

--Check resource list member in project allocations

  l_resource_pa := PA_ALLOC_UTILS.is_resource_in_rules(l_resource_list_member_id);
  If l_resource_pa = 'Y' Then
     x_err_code := 30;
     x_err_stage := 'PA_RES_EXISTS_PROJ_ALLOC';
     return;
  End If;

EXCEPTION
  when others then
     x_err_code := SQLCODE;
     x_err_stage := SQLERRM;
     rollback;
     return;

END delete_resource_list_member_ok;

END PA_GET_RESOURCE;

/
