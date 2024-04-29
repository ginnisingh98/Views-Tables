--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_MAINT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_MAINT_UTILS" AS
/* $Header: PARMPRUB.pls 120.4 2005/08/25 02:01:18 avaithia noship $ */
-- API name     : check_org_name_or_id
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_organization_id    IN hr_organization_units.organization_id%TYPE  Required
-- p_name               IN hr_organization_units.name%TYPE             Required
-- p_check_id_flag      IN VARCHAR2    Required
-- x_organization_id    OUT hr_organization_units.organization_id%TYPE Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
procedure Check_org_name_Or_Id
    (p_organization_id     IN hr_organization_units.organization_id%TYPE
    ,p_name                IN hr_organization_units.name%TYPE
    ,p_check_id_flag       IN VARCHAR2
    ,x_organization_id     OUT NOCOPY hr_organization_units.organization_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
      IF (p_organization_id IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT organization_id
          INTO x_organization_id
          FROM hr_organization_units
          WHERE organization_id = p_organization_id;
        ELSE
            x_organization_id := p_organization_id;
        END IF;
      ELSE
          SELECT organization_id
          INTO x_organization_id
          FROM hr_organization_units
          WHERE name  = p_name;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
	 x_organization_id := NULL ; -- 4537865
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_INVALID_ORG';
       WHEN too_many_rows THEN
         x_organization_id := NULL ; -- 4537865
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_ORG_NOT_UNIQUE';
       WHEN OTHERS THEN
         x_organization_id := NULL ; -- 4537865
	 x_error_msg_code := SQLCODE ; -- 4537865
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_org_name_Or_Id;

-- API name             : check_check_project_status_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_status_code IN pa_project_statuses.project_status_code%TYPE      Required
-- p_project_status_name IN pa_project_statuses.project_status_name%TYPE     Required
-- p_check_id_flag       IN VARCHAR2    Required
-- x_project_status_code OUT pa_project_statuses.project_status_code%TYPE     Required
-- x_return_status       OUT VARCHAR2   Required
-- x_error_msg_code      OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
procedure Check_project_status_or_id
    (p_project_status_code IN pa_project_statuses.project_status_code%TYPE
    ,p_project_status_name IN pa_project_statuses.project_status_name%TYPE
    ,p_check_id_flag       IN VARCHAR2
    ,x_project_status_code OUT NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
     IS
BEGIN
      IF (p_project_status_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT project_status_code
          INTO x_project_status_code
          FROM pa_project_statuses
          WHERE project_status_code = p_project_status_code;
        ELSE
            x_project_status_code := p_project_status_code;
        END IF;
      ELSE
          SELECT project_status_code
          INTO x_project_status_code
          FROM pa_project_statuses
          WHERE project_status_name = p_project_status_name;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
	 -- 4537865 : RESET x_project_status_code value also
	 x_project_status_code := NULL ;

         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PROJECT_STATUS_INVALID';
       WHEN too_many_rows THEN
         -- 4537865 : RESET x_project_status_code value also
         x_project_status_code := NULL ;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PROJECT_STATUS_NOT_UNIQUE';
       WHEN OTHERS THEN
         -- 4537865 : RESET x_project_status_code and x_error_msg_code  value also
         x_project_status_code := NULL ;
	 x_error_msg_code := SQLCODE ;

         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_project_status_Or_Id;

-- API name             : check_customer_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_customer_id         IN ra_customers.customer_id%TYPE      Required
-- p_customer_name       IN ra_customers.customer_name%TYPE    Required
-- p_check_id_flag       IN VARCHAR2    Required
-- x_return_status       OUT VARCHAR2   Required
-- x_error_msg_code      OUT VARCHAR2   Required
--
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
procedure Check_customer_name_or_id
   ( p_customer_id         IN hz_cust_accounts.cust_account_id%TYPE -- ra_customers.customer_id%TYPE -- for 4363092 TCA changes
    ,p_customer_name       IN hz_parties.party_name%TYPE -- ra_customers.customer_name%TYPE -- for 4363092 TCA changes
    ,p_check_id_flag       IN VARCHAR2
    ,x_customer_id         OUT NOCOPY hz_cust_accounts.cust_account_id%TYPE -- ra_customers.customer_id%TYPE -- for 4363092 TCA changes --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
      IF (p_customer_id IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN

          -- 4363092 TCA changes, replaced RA views with HZ tables
          /*
          SELECT customer_id
          INTO x_customer_id
          FROM ra_customers
          WHERE customer_id = p_customer_id;
          */

          SELECT cust_acct.cust_account_id
                INTO x_customer_id
          FROM
                hz_parties party,
                hz_cust_accounts cust_acct
          WHERE
                cust_acct.party_id = party.party_id
            and cust_acct.cust_account_id = p_customer_id;

          -- 4363092 end

        ELSE
            x_customer_id := p_customer_id;
        END IF;
      ELSE
          -- 4363092 TCA changes, replaced RA views with HZ tables
          /*
          SELECT customer_id
          INTO x_customer_id
          FROM ra_customers
          WHERE customer_name = p_customer_name;
          */

          SELECT cust_acct.cust_account_id
            INTO x_customer_id
          FROM
                hz_parties party,
                hz_cust_accounts cust_acct
          WHERE
                cust_acct.party_id = party.party_id
            and substrb(party.party_name,1,50) = p_customer_name;

          -- 4363092 end

      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN

	 -- 4537865 : RESET x_customer_id also
	 x_customer_id := NULL ;

         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_CUSTOMER_ID_INVALID';
       WHEN too_many_rows THEN

         -- 4537865 : RESET x_customer_id also
         x_customer_id := NULL ;

         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_CUS_NAME_NOT UNIQUE';
       WHEN OTHERS THEN

         -- 4537865 : RESET x_customer_id and x_error_msg_code  also
         x_customer_id := NULL ;
	 x_error_msg_code := SQLCODE;

         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_customer_name_Or_Id;

-- API name             : check_probability_code_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_probability_member_id  IN pa_probability_members.probability_member_id%TYPE   Required
-- p_probability_percentage IN pa_probability_members.probability_percentage%TYPE  Required
-- p_project_type           IN pa_projects_all.project_type%TYPE
-- p_probability_list_id    IN pa_probability_lists.probability_list_id%TYPE
-- p_check_id_flag      IN VARCHAR2    Required
-- x_probability_member_id  OUT pa_probability_members.probability_member_id%TYPE  Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           18-MAR-2002 --   xxlu  Added IN parameter p_probability_list_id.
--
PROCEDURE CHECK_PROBABILITY_CODE_OR_ID
 (p_probability_member_id   IN pa_probability_members.probability_member_id%TYPE
,p_probability_percentage IN pa_probability_members.probability_percentage%TYPE
, p_project_type          IN pa_projects_all.project_type%TYPE
,p_probability_list_id    IN pa_probability_lists.probability_list_id%TYPE:=NULL
  ,p_check_id_flag       IN VARCHAR2
  ,x_probability_member_id OUT NOCOPY pa_probability_members.probability_member_id%TYPE --File.Sql.39 bug 4440895
  ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
            select  probability_member_id
            from    pa_probability_members
            where probability_list_id =
                 (select probability_list_id from pa_project_types where
                  project_type = p_project_type)
            and probability_percentage = p_probability_percentage;

--MOAC Changes: Bug 4363092: removed nvl usage with org_id
   CURSOR c_ids1 IS      -- Added the cursor for Bug#3807805
            select  probability_member_id
        from    pa_probability_members
        where probability_list_id =
          (select probability_list_id from pa_project_types_all
           where project_type = p_project_type
           and org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID )
        and probability_percentage = p_probability_percentage;

BEGIN
      IF (p_probability_member_id IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT probability_member_id
          INTO x_probability_member_id
          FROM pa_probability_members
          WHERE probability_member_id = p_probability_member_id;

        ELSIF (p_check_id_flag='N') THEN
            x_probability_member_id := p_probability_member_id;


        ELSIF (p_check_id_flag = 'A') THEN
               IF (p_probability_percentage IS NULL) THEN
                   -- Return a null ID since the probability is null.
                   x_probability_member_id := NULL;
               ELSE

           -- Find the ID which matches the Name passed
           If PA_PROJECT_REQUEST_PVT.G_ORG_ID is null then  -- Added the if condition for Bug#3807805
                     OPEN c_ids;
                       LOOP
                          FETCH c_ids INTO l_current_id;
                          EXIT WHEN c_ids%NOTFOUND;
                          IF (l_current_id = p_probability_member_id) THEN
                              l_id_found_flag := 'Y';
                              x_probability_member_id := p_probability_member_id;
                          END IF;
                       END LOOP;
                       l_num_ids := c_ids%ROWCOUNT;
                     CLOSE c_ids;
                   else -- Added the else block for Bug#3807805
                     OPEN c_ids1;
                       LOOP
                          FETCH c_ids1 INTO l_current_id;
                          EXIT WHEN c_ids1%NOTFOUND;
                          IF (l_current_id = p_probability_member_id) THEN
                              l_id_found_flag := 'Y';
                              x_probability_member_id := p_probability_member_id;
                          END IF;
                      END LOOP;
                      l_num_ids := c_ids1%ROWCOUNT;
                     CLOSE c_ids1;
                   end if;

                   IF (l_num_ids = 0) THEN
                       -- No IDs for name
                       RAISE NO_DATA_FOUND;
                   ELSIF (l_num_ids = 1) THEN
                       -- Since there is only one ID for the name use it.
                       x_probability_member_id := l_current_id;
                   ELSIF (l_id_found_flag = 'N') THEN
                       -- More than one ID for the name and none of the IDs matched
                       -- the ID passed in.
                          RAISE TOO_MANY_ROWS;
                   END IF;
               END IF;

        END IF;

      ELSE
     IF (p_probability_percentage IS NOT NULL) THEN

     IF (p_probability_list_id IS NULL) THEN
              If PA_PROJECT_REQUEST_PVT.G_ORG_ID is null then  -- Added the if condition for Bug#3807805
            select  probability_member_id
            into x_probability_member_id
            from    pa_probability_members
            where probability_list_id =
                 (select probability_list_id from pa_project_types where
                  project_type = p_project_type)
            and probability_percentage = p_probability_percentage;
              else  -- Added the else block for Bug#3807805
            select  probability_member_id
            into x_probability_member_id
            from    pa_probability_members
            where probability_list_id =
                 (select probability_list_id from pa_project_types_all where
                  project_type = p_project_type
              and org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID ) --MOAC Changes: Bug 4363092: removed nvl usage with org_id
            and probability_percentage = p_probability_percentage;
              end if;
     ELSE
         SELECT probability_member_id
         INTO x_probability_member_id
         FROM pa_probability_members
         WHERE probability_list_id = p_probability_list_id
         AND probability_percentage = p_probability_percentage;
     END IF;

     ELSE
        x_probability_member_id := NULL;
     END IF;

      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
       WHEN no_data_found THEN
     x_probability_member_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PROBABILITY_ID_INVALID';
       WHEN too_many_rows THEN
     x_probability_member_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PROBABILITY_NOT_UNIQUE';
       WHEN OTHERS THEN
	-- 4537865 : RESET x_error_msg_code also
	x_error_msg_code := SQLCODE ;

     x_probability_member_id := NULL;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECTS_MAINT_UTILS', p_procedure_name  => 'CHECK_PROBABILITY_CODE_OR_ID');
         RAISE;
END CHECK_PROBABILITY_CODE_OR_ID;

-- API name             : check_calendar_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_calendar_id        IN jtf_calendars_tl.calendar_id%TYPE    Required
-- p_calendar_name      IN jtf_calendars_tl.calendar_name%TYPE  Required
-- p_check_id_flag      IN VARCHAR2    Required
-- x_calendar_id        OUT jtf_calendars_tl.calendar_id%TYPE   Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_CALENDAR_NAME_OR_ID
 (p_calendar_id     IN jtf_calendars_vl.calendar_id%TYPE
  ,p_calendar_name  IN jtf_calendars_vl.calendar_name%TYPE
  ,p_check_id_flag  IN VARCHAR2
  ,x_calendar_id    OUT NOCOPY jtf_calendars_vl.calendar_id%TYPE --File.Sql.39 bug 4440895
  ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
      IF (p_calendar_id IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT calendar_id
          INTO x_calendar_id
          FROM jtf_calendars_b --Used _b table:Bug 4352162
          WHERE calendar_id = p_calendar_id;
        ELSE
            x_calendar_id := p_calendar_id;
        END IF;
      ELSE
          SELECT calendar_id
          INTO x_calendar_id
          FROM jtf_calendars_vl
          WHERE calendar_name = p_calendar_name;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
	 -- 4537865 : RESET x_calendar_id also
	 x_calendar_id := NULL ;

         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_CALENDAR_ID_INVALID';
       WHEN too_many_rows THEN

         -- 4537865 : RESET x_calendar_id also
         x_calendar_id := NULL ;

         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_CALENDAR_NOT_UNIQUE';
       WHEN OTHERS THEN

         -- 4537865 : RESET x_calendar_id and x_error_msg_code: also
         x_calendar_id := NULL ;
	 x_error_msg_code := SQLCODE ;

         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END CHECK_CALENDAR_NAME_OR_ID;

-- API name             : get_project_manager
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PROJECT_MANAGER( p_project_id  IN NUMBER)
RETURN NUMBER
IS
CURSOR C1  (c_project_id NUMBER)
IS
Select PPP.RESOURCE_SOURCE_ID
FROM PA_PROJECT_PARTIES         PPP  ,
     PA_PROJECT_ROLE_TYPES      PPRT
WHERE
    PPP.PROJECT_ID                      = c_project_id
AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
AND trunc(sysdate)  between trunc(PPP.start_date_active)
AND                         NVL(trunc(PPP.end_date_active),sysdate);
l_return_value    NUMBER(10);
BEGIN
OPEN C1 (p_project_id);
FETCH C1 INTO l_return_value;
CLOSE C1;
RETURN l_return_value;
END;

-- API name             : get_project_manager_name
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_person_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PROJECT_MANAGER_NAME (p_person_id IN NUMBER)
RETURN VARCHAR2
IS

/*
CURSOR C1( p_person_id NUMBER)
IS
Select PE.full_name
FROM PA_EMPLOYEES PE
WHERE PE.PERSON_ID = p_person_id;
*/

CURSOR C1( p_person_id NUMBER)
IS
Select PE.full_name
FROM per_all_people_f PE
WHERE PE.PERSON_ID = p_person_id
  AND trunc(sysdate) between PE.EFFECTIVE_START_DATE AND nvl(PE.EFFECTIVE_END_DATE,sysdate+1); --Included by avaithia for Bug 3448680

l_manager_id    NUMBER(10);
l_return_value  VARCHAR2(250);
BEGIN
 l_manager_id := get_project_manager(p_person_id);
 IF l_manager_id IS NOT NULL
 THEN
    OPEN C1 (l_manager_id);
    FETCH C1 INTO l_return_value;
    CLOSE C1;
 END IF;
 RETURN l_return_value;
END;

-- API name             : get_primary_customer
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           21-MAR-2001      anlee
--                            Modified to remove join
--                            with PA_LOOKUPS
--                            The designation "Primary"
--                            is not always applicable
--
FUNCTION GET_PRIMARY_CUSTOMER( p_project_id  IN NUMBER)
RETURN NUMBER
IS

-- 3703272 Included substrb in the Cursor select statement while retrieving Customer Name
CURSOR C1  (c_project_id NUMBER)
IS
Select PPC.customer_id, NVL(PPC.customer_bill_split,0) bill_split, substrb(PCV.customer_name,1,50)
FROM PA_PROJECT_CUSTOMERS       PPC,
     PA_CUSTOMERS_V             PCV
WHERE PPC.project_id    = c_project_id
AND   PPC.customer_id   = PCV.customer_id
ORDER BY bill_split DESC, customer_name;

l_return_value    NUMBER(10);
l_bill_split      NUMBER(10);
l_customer_name   VARCHAR2(250);

BEGIN

  OPEN C1 (p_project_id);
  FETCH C1 INTO l_return_value, l_bill_split, l_customer_name;
  CLOSE C1;

  RETURN l_return_value;

END;

-- API name             : get_primary_customer_name
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PRIMARY_CUSTOMER_NAME( p_project_id IN NUMBER)
RETURN VARCHAR2
IS

--3645993 : Included substrb in the Cursor select statement while retrieving Customer Name

CURSOR C1  (c_project_id NUMBER)
IS
Select PPC.customer_id, NVL(PPC.customer_bill_split,0) bill_split, substrb(PCV.customer_name,1,50)
FROM PA_PROJECT_CUSTOMERS       PPC,
     PA_CUSTOMERS_V             PCV
WHERE PPC.project_id    = c_project_id
AND   PPC.customer_id   = PCV.customer_id
ORDER BY bill_split DESC, customer_name;

l_customer_id    NUMBER(10);
l_bill_split     NUMBER(10);
l_return_value   VARCHAR2(250);
BEGIN

  OPEN C1 (p_project_id);
  FETCH C1 INTO l_customer_id, l_bill_split, l_return_value;
  CLOSE C1;

  RETURN l_return_value;

END;

-- API name             : class_check_trans
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION CLASS_CHECK_TRANS (p_project_id NUMBER)
RETURN VARCHAR2 IS
CURSOR class_cdl (c_project_id NUMBER)
IS
     SELECT '1'
     FROM pa_expenditure_items pai, --Bug#3088387pa_tasks t,
          pa_cost_distribution_lines pcd
     WHERE pai.project_id=c_project_id AND --Bug#3088387t.task_id AND
           pai.expenditure_item_id=pcd.expenditure_item_id ;
           -- Bug#3088387AND t.project_id=c_project_id;

CURSOR class_draft_revenue (p_project_id NUMBER)
IS
     SELECT '1'
     FROM pa_draft_revenues
     WHERE project_id=p_project_id;

CURSOR class_draft_invoice (p_project_id NUMBER)
IS
     SELECT '1'
     FROM pa_draft_invoices
     WHERE project_id=p_project_id;

     rec_class_cdl VARCHAR2(1);
     rec_class_draft_rev VARCHAR2(1);
     rec_class_draft_inv VARCHAR2(1);
     l_return            VARCHAR2(1);
Begin
     OPEN class_cdl(p_project_id);
     FETCH class_cdl INTO rec_class_cdl;

     OPEN class_draft_revenue(p_project_id);
     FETCH class_draft_revenue INTO rec_class_draft_rev;

     OPEN class_draft_invoice(p_project_id);
     FETCH class_draft_invoice INTO rec_class_draft_inv;

     IF class_cdl%notfound AND class_draft_invoice%NOTFOUND
          AND class_draft_revenue%notfound THEN
            l_return:='N';
     ELSE
            l_return:='Y';
     END IF;
     CLOSE class_cdl;
     CLOSE class_draft_invoice;
     CLOSE class_draft_revenue;
     RETURN l_return;
END CLASS_CHECK_TRANS;

-- API name             : check_class_catg_can_delete
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_CLASS_CATG_CAN_DELETE (p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR class_delrec (c_class_category VARCHAR2)
IS
SELECT  autoaccounting_flag
FROM   pa_class_categories
WHERE  class_category = c_class_category;

l_dummy VARCHAR2(1);
l_rec_Status_flag VARCHAR2(1);
l_project_id NUMBER;
BEGIN
x_return_status := 'S';
if p_object_type = 'PA_TASKS' then
  SELECT project_id
  INTO l_project_id
  FROM pa_tasks
  WHERE task_id = p_object_id;
else
  l_project_id := p_object_id;
end if;

/* changes for bug 2681127 */
IF pa_projects_maint_utils.class_check_mandatory (p_class_category, l_project_id) = 'Y' THEN
   x_error_msg_code := 'PA_CLASS_CATEGORY_MANDATORY';
   x_return_status := 'E' ;
   RETURN;
END IF;
/* changes for bug 2681127 end */

l_dummy := PA_PROJECTS_MAINT_UTILS.CLASS_CHECK_TRANS(l_project_id);
   IF l_dummy ='Y'
   THEN
       OPEN  class_delrec(p_class_category);
       FETCH class_delrec INTO l_rec_status_flag;
       IF (l_rec_status_flag = 'Y')
       THEN
         CLOSE class_delrec;
         x_error_msg_code := 'PA_PRJ_TRAN_ERR';
         x_return_Status := 'E' ;
       ELSE
         CLOSE class_delrec;
       END IF;
   END IF;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'U';
		x_error_msg_code := SQLCODE;
		fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_CLASS_CATG_CAN_DELETE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    		raise;
END CHECK_CLASS_CATG_CAN_DELETE;


-- API name             : check_duplicate_class_catg
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_class_code         IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_DUPLICATE_CLASS_CATG  (p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       p_class_code     VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR l_duplicate_cur (c_object_id      NUMBER,
                        c_object_type    VARCHAR2,
                        c_class_category VARCHAR2,
                        c_class_code     VARCHAR2)
IS
SELECT 'x'
FROM PA_PROJECT_CLASSES
WHERE object_id     = c_object_id
AND   object_type   = c_object_type
AND   class_category = c_class_category
AND   class_code     = c_class_code;
l_dummy   VARCHAR2(1);
BEGIN
   x_return_status := 'S';
   OPEN  l_duplicate_cur(p_object_id, p_object_type, p_class_category,p_class_code);
   FETCH l_duplicate_cur INTO l_dummy;
   IF l_duplicate_cur%FOUND
   THEN
          x_error_msg_code := 'PA_DUPLICATE_CLASS_CATG';
          x_return_status := 'E';
   END IF;
   CLOSE l_duplicate_cur;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLCODE;
                fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_DUPLICATE_CLASS_CATG',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
                raise;
END CHECK_DUPLICATE_CLASS_CATG;


-- API name             : check_class_catg_one_only_code
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE   CHECK_CLASS_CATG_ONE_ONLY_CODE (
                                       p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR Check_One_code_only_cur (c_object_id NUMBER,
                                c_object_type VARCHAR2,
                                c_class_category VARCHAR2)
IS
SELECT 'x'
FROM PA_PROJECT_CLASSES_V PAC,
     PA_CLASS_CATEGORIES  PCC
WHERE PAC.object_id = c_object_id AND
PAC.object_type = c_object_type AND
PAC.class_category = c_class_category AND
PAC.class_category = PCC.class_category AND
PCC.pick_one_code_only_flag = 'Y';
l_dummy VARCHAR2(1);
BEGIN
   x_return_status := 'S';
   OPEN Check_One_code_only_cur(p_object_id, p_object_type, p_class_category);
   Fetch Check_One_code_only_cur into  l_dummy;
   IF Check_One_code_only_cur%FOUND THEN
          x_error_msg_code:= 'PA_ONE_CODE_ONLY_CLASS';
          x_return_status := 'E';
   ElSE
      CLOSE Check_One_code_only_cur;
   END IF;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLCODE;
                fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_CLASS_CATG_ONE_ONLY_CODE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
                raise;
END CHECK_CLASS_CATG_ONE_ONLY_CODE;


-- API name             : check_class_catg_can_override
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- p_class_category     IN VARCHAR2
-- p_class_code         IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE   CHECK_CLASS_CATG_CAN_OVERRIDE (
                                       p_project_id     NUMBER,
                                       p_class_category VARCHAR2,
                                       p_class_code     VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR l_project_template (c_project_id NUMBER)
IS
SELECT created_from_project_id
FROM PA_PROJECTS
WHERE project_id = c_project_id;

CURSOR l_override (c_created_from_project_id NUMBER, c_class_category VARCHAR2)
IS
SELECT 'x'
FROM PA_OVERRIDE_FIELDS_V
WHERE pa_source_template_id = c_created_from_project_id
AND   pa_field_name            = 'CLASSIFICATION'
AND   UPPER(type)           = c_class_category;
l_dummy    VARCHAR2(1);
l_created_from_project_id  pa_projects.created_from_project_id%TYPE;
BEGIN
   x_return_status := 'S';
   OPEN  l_project_template(p_project_id);
   FETCH l_project_template INTO l_created_from_project_id;
   CLOSE l_project_template;

   OPEN  l_override (l_created_from_project_id,p_class_category);
   FETCH l_override INTO l_dummy;
   IF l_override%NOTFOUND
   THEN
       x_error_msg_code:= 'PA_CLASS_CAT_NOT_OVERRIDABLE';
       x_return_status := 'E';
   ELSE
        IF PA_PROJECT_PVT.CHECK_CLASS_CODE_VALID(p_class_category,
                                                 p_class_code) = 'N'
        THEN
           x_error_msg_code:= 'PA_INVALID_CLASS_CATEGORY';
           x_return_status := 'E';
        END IF;
   END IF;
   CLOSE l_override;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLCODE;
                fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_CLASS_CATG_CAN_OVERRIDE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
                raise;
END CHECK_CLASS_CATG_CAN_OVERRIDE;

-- API name             : check_probability_can_change
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_status_code IN VARCHAR2
-- x_return_status       OUT VARCHAR2
-- x_error_msg_code      OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_PROBABILITY_CAN_CHANGE (
                                       p_project_status_code VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR   l_project_system_status_csr(c_project_status_code VARCHAR2)
IS
SELECT project_system_status_code
FROM   PA_PROJECT_STATUSES
WHERE  project_status_code = c_project_status_code;
l_project_system_Status VARCHAR(250);
BEGIN
    x_return_status := 'S';
    OPEN  l_project_system_status_csr(p_project_status_code);
    FETCH l_project_system_status_csr into l_project_system_status;
    CLOSE l_project_system_status_csr;
    IF PA_PROJECT_UTILS.check_prj_stus_action_allowed
         (l_project_system_status,'CHANGE_PROJECT_PROBABILITY') <> 'Y'
    THEN
            x_error_msg_code:= 'PA_PRJ_PROB_CANNOT_CHNG';
               --new message
            x_return_status := 'E' ;
    END IF;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLCODE;
                fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_PROBABILITY_CAN_CHANGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
                raise;
END CHECK_PROBABILITY_CAN_CHANGE;

-- API name             : check_bill_job_grp_req
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_type       IN VARCHAR2
-- p_bill_job_group     IN NUMBER
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_BILL_JOB_GRP_REQ(    p_project_type      IN VARCHAR2,
                                     p_bill_job_group_id IN NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR l_project_type_csr
       (l_project_type VARCHAR2)
IS
SELECT project_type_class_code
FROM pa_project_types
WHERE project_type = l_project_type;

l_project_type_class_code  pa_project_types.project_type_class_code%TYPE;
BEGIN
x_return_status := 'S';
OPEN  l_project_type_csr(p_project_type);
FETCH l_project_type_csr INTO l_project_type_class_code;
CLOSE l_project_type_csr;
IF  l_project_type_class_code = 'CONTRACT' AND
     (p_bill_job_group_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
      p_bill_job_group_id = NULL )
THEN
      x_error_msg_code := 'PA_BILL_JOB_GROUP_NOT_NULL';
      --new message
      x_return_status := 'E';
END IF;
-- 4537865 : Based on this API usage I have Included ths exception block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_error_msg_code := SQLCODE;
                fnd_msg_pub.add_exc_msg(p_pkg_name  => 'PA_PROJECTS_MAINT_UTILS',
                            p_procedure_name => 'CHECK_BILL_JOB_GRP_REQ',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
                raise;
END CHECK_BILL_JOB_GRP_REQ;

-- API name             : get_cost_job_group_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           : None.
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_COST_JOB_GROUP_ID RETURN NUMBER IS

Cursor implementation_csr is
 select business_group_id,
        org_id
   from pa_implementations;

 Cursor job_group_csr  (p_business_group_id number) is
 select jobs.job_group_id
   from per_job_groups           jobs
  where jobs.business_group_id = p_business_group_id
    and jobs.internal_name = 'HR_'||to_char(jobs.business_group_id);

 t_business_group_id    NUMBER(15);
 t_org_id               NUMBER(15);
 t_job_group_id         NUMBER(25);

 BEGIN

  open implementation_csr;
  fetch implementation_csr into t_business_group_id, t_org_id;
  close implementation_csr;

  open job_group_csr (t_business_group_id);
  fetch job_group_csr into t_job_group_id;
  close job_group_csr;
  Return t_job_group_id;
END GET_COST_JOB_GROUP_ID;

-- API name             : check_bill_rate_rate_schl_exists
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN  NUMBER
--
--  History
--
--           08-SEP-2000 --   Sakthi/William    - Created.
--
FUNCTION CHECK_BILL_RATE_SCHL_EXISTS (p_project_id IN NUMBER)
RETURN VARCHAR2 IS

Cursor c1 (c_project_id NUMBER)
Is
Select bill_job_group_id,
       labor_std_bill_rate_schdl,
       non_labor_std_bill_rate_schdl
from pa_projects
where project_id = c_project_id;

Cursor c2 (c_bill_job_group_id NUMBER,
           c_lab_std_bill_rate_schdl VARCHAR2,
           c_non_lab_std_bill_rate_schdl VARCHAR2)
IS
SELECT 'Y' FROM pa_std_bill_rate_schedules
 WHERE SCHEDULE_TYPE = 'JOB'
   AND JOB_GROUP_ID  = c_bill_job_group_id
   AND (STD_BILL_RATE_SCHEDULE = c_lab_std_bill_rate_schdl
        or STD_BILL_RATE_SCHEDULE = c_non_lab_std_bill_rate_schdl);

l_bill_job_group_id pa_projects.bill_job_group_id%TYPE;
l_lab_std_bill_rate_schdl  pa_projects.labor_std_bill_rate_schdl%TYPE;
l_non_lab_std_bill_rate_schdl  pa_projects.non_labor_std_bill_rate_schdl%TYPE;
l_return       VARCHAR2(1) :='N';
BEGIN
OPEN c1 (p_project_id);
FETCH c1 INTO l_bill_job_group_id,l_lab_std_bill_rate_schdl,
              l_non_lab_std_bill_rate_schdl;
CLOSE c1;
IF l_bill_job_group_id is not null and
   ( l_lab_std_bill_rate_schdl is not null or
     l_non_lab_std_bill_rate_schdl is not null)
Then
    OPEN c2(l_bill_job_group_id,l_lab_std_bill_rate_schdl,
            l_non_lab_std_bill_rate_schdl);
    FETCH c2 INTO l_return;
    IF c2%NOTFOUND then
      l_return := 'N';
    ELSE
      l_return := 'Y';
    END IF;
    CLOSE c2;
End If;
Return l_return;
END CHECK_BILL_RATE_SCHL_EXISTS;

-- API name             : check_project_option_exists
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- p_option_code        IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           01-JUN-2001 --   Sakthi    - Created.
--
--
FUNCTION   CHECK_PROJECT_OPTION_EXISTS( p_project_id     NUMBER,
                                        p_option_code    VARCHAR2)
RETURN VARCHAR2 IS
CURSOR l_project_template (c_project_id NUMBER)
IS
SELECT created_from_project_id
FROM PA_PROJECTS_ALL
WHERE project_id = p_project_id;

CURSOR l_project_option (p_template_id NUMBER, p_option_code VARCHAR2)
IS
SELECT 'x'
FROM PA_OPTIONS OPT1, PA_PROJECT_OPTIONS OPT2
/* Commented for Bug 2499051
, PA_PROJECTS_ALL PROJ
*/
WHERE opt1.option_code          = opt2.option_code
AND   opt1.OPTION_FUNCTION_NAME = p_option_code
AND   opt2.project_id           = p_template_id;

l_dummy    VARCHAR2(1);
x_return_status    VARCHAR2(1);
l_created_from_project_id  pa_projects.created_from_project_id%TYPE;

BEGIN

   x_return_status := 'S';

   OPEN  l_project_template (p_project_id);
   FETCH l_project_template INTO l_created_from_project_id;
   CLOSE l_project_template;

   OPEN  l_project_option (l_created_from_project_id, p_option_code);
   FETCH l_project_option INTO l_dummy;
   CLOSE l_project_option;

   IF l_dummy = 'x' then
      x_return_status := 'S';
   ELSE
      x_return_status := 'E';
   END IF;

   RETURN (x_return_status);

END CHECK_PROJECT_OPTION_EXISTS;


-- API name             : check_category_total_valid
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_rowid              IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_code_percentage    IN NUMBER
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_CATEGORY_TOTAL_VALID  (p_object_id         NUMBER,
                                       p_object_type       VARCHAR2,
                                       p_class_category    VARCHAR2,
                                       p_rowid             VARCHAR2 := FND_API.G_MISS_CHAR,
                                       p_code_percentage   NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_sum   NUMBER;
l_old_percentage NUMBER;
l_old_category VARCHAR2(30);

CURSOR get_sum
IS
SELECT sum(pc.code_percentage)
FROM PA_PROJECT_CLASSES pc
WHERE pc.object_id = p_object_id
AND   pc.object_type = p_object_type
AND   pc.class_category = p_class_category;

CURSOR get_old_percentage
IS
SELECT pc.class_category, pc.code_percentage
FROM   PA_PROJECT_CLASSES pc
WHERE  rowid = p_rowid;

BEGIN
   x_return_status := 'S';
   l_sum := 0;

   OPEN get_sum;
   FETCH get_sum INTO l_sum;
   CLOSE get_sum;

   if((p_rowid is not null) AND (p_rowid <> FND_API.G_MISS_CHAR)) then
     OPEN get_old_percentage;
     FETCH get_old_percentage INTO l_old_category, l_old_percentage;
     CLOSE get_old_percentage;

     if l_old_category = p_class_category then
       if l_old_percentage is not null then
         l_sum := l_sum - l_old_percentage;
       end if;
     end if;
   end if;

   if p_code_percentage is not null then
     l_sum := l_sum + p_code_percentage;
   end if;

   if((l_sum < 0) OR (l_sum > 100)) then
     x_return_status := 'E';
     x_error_msg_code := 'PA_CLASS_CATG_TOTAL_INVALID';
   end if;
EXCEPTION
  WHEN OTHERS THEN
   x_return_status := 'U';
   x_error_msg_code := SQLCODE ; -- 4537865
   raise;
END CHECK_CATEGORY_TOTAL_VALID;


-- API name             : check_category_valid
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_type_id     IN NUMBER
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_CATEGORY_VALID        (p_object_type_id    NUMBER,
                                       p_class_category    VARCHAR2,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

CURSOR check_valid_catg_csr(c_class_category VARCHAR2, c_object_type_id NUMBER)
IS
SELECT 'Y'
FROM PA_VALID_CATEGORIES_V
WHERE class_category = c_class_category
AND   object_type_id = c_object_type_id;

l_dummy VARCHAR2(1);
BEGIN
   x_return_status := 'S';

   OPEN check_valid_catg_csr(p_class_category, p_object_type_id);
   FETCH check_valid_catg_csr INTO l_dummy;
   if check_valid_catg_csr%NOTFOUND then
     x_return_status := 'E';
     x_error_msg_code := 'PA_CLASS_CATG_INVALID';
   end if;
   CLOSE check_valid_catg_csr; -- Added for Bug#3876212
EXCEPTION
  WHEN OTHERS THEN
   x_return_status := 'U';
   x_error_msg_code := SQLCODE; -- 4537865
   raise;
END CHECK_CATEGORY_VALID;


-- API name             : check_percentage_allowed
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_PERCENTAGE_ALLOWED    (p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_allow_percent_flag   VARCHAR2(1);

BEGIN
   x_return_status := 'S';

   SELECT allow_percent_flag
   INTO l_allow_percent_flag
   FROM pa_class_categories
   WHERE class_category = p_class_category;

   if l_allow_percent_flag = 'N' then
     x_return_status := 'E';
     x_error_msg_code := 'PA_CODE_PERCENT_NOT_ALLOWED';
   end if;
EXCEPTION
 WHEN OTHERS THEN
   x_return_status := 'U';
   x_error_msg_code := SQLCODE ; -- 4537865
   raise;
END CHECK_PERCENTAGE_ALLOWED;


-- API name             : check_mandatory_classes
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_MANDATORY_CLASSES            (p_object_id VARCHAR2,
                                              p_object_type VARCHAR2,
                                              x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                              x_error_msg_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

CURSOR C1(c_object_id NUMBER, c_object_type VARCHAR2)
IS
SELECT pcc.class_category, mandatory_flag
FROM   pa_class_categories pcc,
       pa_project_classes ppc
WHERE pcc.class_category <> ppc.class_category
AND   ppc.object_id = c_object_id
AND   ppc.object_type = c_object_type
AND  trunc(sysdate) between trunc(pcc.start_date_active)
     and trunc(nvl(pcc.end_date_active, sysdate));

CURSOR C2(c_object_id NUMBER, c_class_category VARCHAR2)
IS
SELECT 1
FROM PA_VALID_CATEGORIES vc,
     PA_PROJECTS_ALL ppa,
     PA_PROJECT_TYPES_ALL ppta
WHERE vc.mandatory_flag = 'Y'
AND  vc.class_category = c_class_category
AND  ppa.project_id = p_object_id
AND  ppa.project_type = ppta.project_type
AND  ppa.org_id = ppta.org_id --MOAC Changes: Bug 4363092: removed nvl usage with org_id
AND  vc.object_type_id = ppta.project_type_id
AND  trunc(sysdate) between trunc(ppta.start_date_active)
     and trunc(nvl(ppta.end_date_active, sysdate));

l_class_category pa_class_categories.class_category%TYPE;
l_dummy NUMBER;
l_mandatory_flag VARCHAR2(1);
BEGIN
   x_return_status := 'S';

   OPEN C1(p_object_id, p_object_type);
   LOOP
     FETCH C1 INTO l_class_category, l_mandatory_flag;
     EXIT WHEN C1%NOTFOUND;

     if(p_object_type = 'PA_PROJECTS') then
       OPEN C2(p_object_id, l_class_category);
       FETCH C2 INTO l_dummy;
       if C2%FOUND then
         x_return_status := 'E';
         x_error_msg_code := 'PA_MANDATORY_CATG_REQD';
         CLOSE C1; -- Added for Bug#3876212
     CLOSE C2; -- Added for Bug#3876212
         return;
       elsif l_mandatory_flag = 'Y' then
         x_return_status := 'E';
         x_error_msg_code := 'PA_MANDATORY_CATG_REQD';
         CLOSE C1; -- Added for Bug#3876212
         CLOSE C2; -- Added for Bug#3876212
         return;
       end if;
       CLOSE C2; -- Added for Bug#3876212
     end if;
   end LOOP;
   CLOSE C1; -- Added for Bug#3876212
EXCEPTION
 WHEN OTHERS THEN
   x_return_status := 'U';
   -- 4537865
   x_error_msg_code := SQLCODE ;
   raise;
END CHECK_MANDATORY_CLASSES;


-- API name             : check_currency_name_or_code
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_agreement_currency            IN FND_CURRENCIES_VL.currency_code%TYPE      Required
-- p_agreement_currency_name       IN FND_CURRENCIES_VL.name%TYPE    Required
-- p_check_id_flag                 IN VARCHAR2    Required
-- x_agreement_currency            OUT VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2   Required
-- x_error_msg_code                OUT VARCHAR2   Required
--
--
--  History
--
--           12-OCT-2001 --   anlee    created
--           01-MAR-2002 --   MAansari Modified SQL to include start_date_active, end_date_active
--                                     and enabled_flag in the where clause.
--
--
procedure Check_currency_name_or_code
   ( p_agreement_currency      IN FND_CURRENCIES_VL.currency_code%TYPE
    ,p_agreement_currency_name IN FND_CURRENCIES_VL.name%TYPE
    ,p_check_id_flag           IN VARCHAR2
    ,x_agreement_currency      OUT NOCOPY FND_CURRENCIES_VL.currency_code%TYPE --File.Sql.39 bug 4440895
    ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code          OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
      IF (p_agreement_currency IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT currency_code
          INTO x_agreement_currency
          FROM fnd_currencies --Used base table:Bug 4352162
          WHERE currency_code = p_agreement_currency
            AND nvl(enabled_flag, 'Y') = 'Y'
            AND sysdate between decode(start_date_active, null, sysdate, start_date_active)
                            AND decode (end_date_active, null, sysdate, end_date_active);
        ELSE
            x_agreement_currency := p_agreement_currency;
        END IF;
      ELSE
          SELECT currency_code
          INTO x_agreement_currency
          FROM fnd_currencies_vl
          WHERE name = p_agreement_currency_name
            AND nvl(enabled_flag, 'Y') = 'Y'
            AND sysdate between decode(start_date_active, null, sysdate, start_date_active)
                            AND decode (end_date_active, null, sysdate, end_date_active);
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_AGREEMENT_CURR_INVALID';
	 -- 4537865
	 x_agreement_currency := NULL ;

       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_CURR_NAME_NOT UNIQUE';
	 -- 4537865
         x_agreement_currency := NULL ;

       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	 -- 4537865
         x_agreement_currency := NULL ;
	 x_error_msg_code:= SQLCODE ;

         RAISE;
END Check_currency_name_or_code;


-- API name             : check_agreement_org_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_agreement_org_id            IN pa_organizations_project_v.organization_id%TYPE      Required
-- p_agreement_org_name          IN pa_organizations_project_v.name%TYPE    Required
-- p_check_id_flag               IN VARCHAR2      Required
-- x_agreement_org_id             OUT NUMBER      Required
-- x_return_status                 OUT VARCHAR2   Required
-- x_error_msg_code                OUT VARCHAR2   Required
--
--
--  History
--
--           12-OCT-2001 --   anlee    created
--
--
procedure Check_agreement_org_name_or_id
   ( p_agreement_org_id        IN pa_organizations_project_v.organization_id%TYPE
    ,p_agreement_org_name      IN pa_organizations_project_v.name%TYPE
    ,p_check_id_flag           IN VARCHAR2
    ,x_agreement_org_id        OUT NOCOPY pa_organizations_project_v.organization_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code          OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
      IF (p_agreement_org_id IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT organization_id
          INTO x_agreement_org_id
          FROM pa_organizations_project_v
          WHERE organization_id = p_agreement_org_id;
        ELSE
            x_agreement_org_id := p_agreement_org_id;
        END IF;
      ELSE
          SELECT organization_id
          INTO x_agreement_org_id
          FROM pa_organizations_project_v
          WHERE name = p_agreement_org_name;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_INVALID_ORG';
	 -- 4537865
	 x_agreement_org_id := NULL ;

       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_ORG_NOT UNIQUE';
         -- 4537865
         x_agreement_org_id := NULL ;
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         -- 4537865
         x_agreement_org_id := NULL ;
	 x_error_msg_code:= SQLCODE ;

         RAISE;
END Check_agreement_org_name_or_id;


-- API name             : get_class_codes
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id         IN NUMBER
-- p_object_type       IN VARCHAR2
-- p_class_category    IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_CLASS_CODES(p_object_id  IN NUMBER, p_object_type IN VARCHAR2, p_class_category IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR C1(c_object_id NUMBER, c_object_type VARCHAR2, c_class_category VARCHAR2)
IS
SELECT class_code, code_percentage
FROM   PA_PROJECT_CLASSES
WHERE  object_id = c_object_id
AND    object_type = c_object_type
AND    class_category = c_class_category
ORDER BY class_code;

l_return_value   VARCHAR2(4000);
l_class_code     VARCHAR2(30);
l_code_percentage NUMBER;
BEGIN
  l_return_value :=  null;
  OPEN C1(p_object_id, p_object_type, p_class_category);
  LOOP
    FETCH C1 INTO l_class_code, l_code_percentage;
    EXIT WHEN C1%NOTFOUND;

    if l_return_value is not null then
      if l_code_percentage is null then
        l_return_value := l_return_value || ' <BR>' || l_class_code;
      else
        l_return_value := l_return_value || ' <BR>' || l_class_code || ' (' || to_char(l_code_percentage) || '%)';
      end if;
    else
      if l_code_percentage is null then
        l_return_value := l_class_code;
      else
        l_return_value := l_class_code || ' (' || to_char(l_code_percentage) || '%)';
      end if;
    end if;
  END LOOP;
  CLOSE C1;

  RETURN l_return_value;

END GET_CLASS_CODES;


-- API name             : get_class_exceptions
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_mandatory          IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_CLASS_EXCEPTIONS(p_object_id IN NUMBER, p_object_type IN VARCHAR2, p_class_category IN VARCHAR2, p_mandatory IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR C1
IS
SELECT sum(code_percentage)
FROM   PA_PROJECT_CLASSES
WHERE  object_id = p_object_id
AND    object_type = p_object_type
AND    class_category = p_class_category;

-- 3690967 For performance bug changed below cursor select query
-- removed below cursor definition

/*
CURSOR C2
IS
SELECT total_100_percent_flag
FROM   PA_VALID_CATEGORIES_V vc,
       PA_PROJECTS_ALL ppa,
       PA_PROJECT_TYPES_ALL ppta
WHERE  ppa.project_id = p_object_id
AND    ppa.project_type = ppta.project_type
AND    nvl(ppa.org_id, -99) = nvl(ppta.org_id, -99)
AND    vc.object_type_id = ppta.project_type_id
AND    vc.class_category = p_class_category;
*/

-- 3690967  added below select for above cursor

CURSOR C2
IS
SELECT total_100_percent_flag
  FROM  PA_CLASS_CATEGORIES
  WHERE object_type     = p_object_type
  AND   class_category  = p_class_category;

-- 3690967 end

l_total_percentage  NUMBER;
l_return_value      VARCHAR2(4000);
l_total_100_percent_flag VARCHAR2(1);
BEGIN

  if p_mandatory = 'Y' then
    FND_MESSAGE.set_name('PA', 'PA_MANDATORY_CATG_REQD');
    l_return_value := FND_MESSAGE.GET;
    return l_return_value;
  end if;

  OPEN C1;
  FETCH C1 INTO l_total_percentage;
  CLOSE C1;

  OPEN C2;
  FETCH C2 INTO l_total_100_percent_flag;
  CLOSE C2;

  l_return_value := NULL;
  if l_total_100_percent_flag = 'Y' then
    if l_total_percentage <> 100 then
      FND_MESSAGE.set_name('PA', 'PA_CLASS_CATG_NOT_100');
      l_return_value := FND_MESSAGE.GET;
      return l_return_value;
    end if;
  end if;

  return l_return_value;
END GET_CLASS_EXCEPTIONS;


-- API name             : get_object_type_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- Return               : NUMBER
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_OBJECT_TYPE_ID(p_object_id IN NUMBER, p_object_type IN VARCHAR2)
RETURN NUMBER
IS
CURSOR C1
IS
SELECT ppta.project_type_id
FROM   PA_PROJECT_TYPES_ALL ppta,
       PA_PROJECTS_ALL ppa
WHERE  ppa.project_id = p_object_id
AND    ppa.project_type = ppta.project_type
AND    ppa.org_id = ppta.org_id; --MOAC Changes: Bug 4363092: removed nvl usage with org_id

l_object_type_id   NUMBER;
BEGIN
  if p_object_type = 'PA_PROJECTS' then
    OPEN C1;
    FETCH C1 INTO l_object_type_id;
    CLOSE C1;
  end if;
  return l_object_type_id;
END GET_OBJECT_TYPE_ID;


-- API name             : populate_class_exception
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project            : IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           16-NOV-2001 --   Sakthi/Ansari    - Created
--
--

PROCEDURE POPULATE_CLASS_EXCEPTION (p_project_id NUMBER) IS

   l_exception          VARCHAR2(4000); /* 3102753-Modified length for variable from 2500 to 4000 */

   CURSOR l_message_name IS
   SELECT message_name
     FROM FND_NEW_MESSAGES
    WHERE message_text = l_exception
/* added for Bug 2634995 */
    AND  application_id = fnd_global.resp_appl_id
    AND language_code = userenv('LANG');
/* Bug 2634995 ends */
   CURSOR l_class_exception IS
   SELECT CLASS_CATEGORY, CLASS_CODES, TOTAL_PERCENTAGE, EXCEPTIONS, SORT_ORDER
     FROM pa_project_class_totals_v
    WHERE project_id = p_project_id
      AND SORT_ORDER IN ('A','B')
    ORDER BY sort_order;

/* 3102753 - Modified the length of the variables. Made l_class_category 30 from 50, l_class_codes 4000 from 50
and l_total_percentage Number from Number(10,2) */

   l_class_category     VARCHAR2(30);
   l_class_codes        VARCHAR2(4000);
   l_total_percentage   NUMBER;   /* Modified to NUMBER and commented NUMBER(10,2) for bug 3102753 */
   l_message_code       VARCHAR2(30);
   l_sort_order         VARCHAR2(1);

BEGIN
   OPEN l_class_exception;
   LOOP
       FETCH l_class_exception INTO l_class_category,
                                    l_class_codes,
                                    l_total_percentage,
                                    l_exception,
                                    l_sort_order;
       EXIT WHEN l_class_exception%NOTFOUND;

       if l_sort_order = 'A' then
          FND_MESSAGE.SET_NAME('PA', 'PA_TOT_PERCENT_MISSING');
          FND_MESSAGE.SET_TOKEN('CLASS_CATEGORY', l_class_category);
          FND_MESSAGE.SET_TOKEN('TOTAL_PERCENTAGE', to_char(l_total_percentage));
          FND_MSG_PUB.ADD;
       elsif l_sort_order = 'B' then
          FND_MESSAGE.SET_NAME('PA', 'PA_MANDATORY_CLASS_CATEGORY');
          FND_MESSAGE.SET_TOKEN('CLASS_CATEGORY', l_class_category);
          FND_MSG_PUB.ADD;
       end if;

   END LOOP;
   CLOSE l_class_exception; -- Added for Bug#3876212
END POPULATE_CLASS_EXCEPTION;


-- API name             : check_proj_recalc
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN NUMBER
-- p_organization_id     IN NUMBER
-- p_organization_name   IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           22-MAY-2002 --   anlee    - Created
--
--
FUNCTION CHECK_PROJ_RECALC (p_project_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_organization_name IN VARCHAR2)
RETURN VARCHAR2
IS

  cursor cdl_exist_csr
  IS
  SELECT count(*)
  FROM sys.dual
  WHERE EXISTS
  (SELECT NULL
   FROM   pa_expenditure_items_all pai,
          pa_tasks t,
          pa_cost_distribution_lines_all pcd
   WHERE  pai.task_id = t.task_id
   AND    pai.expenditure_item_id = pcd.expenditure_item_id
   AND    t.project_id = p_project_id);

  cursor template_csr
  IS
  SELECT template_flag
  FROM   pa_projects_all
  WHERE  project_id = p_project_id;

  cursor org_csr
  IS
  SELECT carrying_out_organization_id
  FROM   PA_PROJECTS_ALL
  WHERE  project_id = p_project_id;

  l_cdl_exist                   NUMBER;
  l_template_flag               VARCHAR2(1);
  l_organization_id             NUMBER;
  l_old_organization_id         NUMBER;
  l_return_status               VARCHAR2(1);
  l_error_msg_code              VARCHAR2(250);
BEGIN

   -- First check if the organization has changed
   IF (p_organization_id is not null AND p_organization_id <> FND_API.G_MISS_NUM) OR
      (p_organization_name is not null AND p_organization_name <> FND_API.G_MISS_CHAR) THEN

      pa_hr_org_utils.Check_OrgName_Or_Id
      (p_organization_id     => p_organization_id
      ,p_organization_name   => p_organization_name
      ,p_check_id_flag       => 'A'
      ,x_organization_id     => l_organization_id
      ,x_return_status       => l_return_status
      ,x_error_msg_code      => l_error_msg_code);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         return 'N';
      END IF;
   END IF;

   OPEN org_csr;
   FETCH org_csr INTO l_old_organization_id;
   CLOSE org_csr;

   if l_old_organization_id <> l_organization_id then
      OPEN cdl_exist_csr;
      FETCH cdl_exist_csr INTO l_cdl_exist;
      CLOSE cdl_exist_csr;

      if l_cdl_exist > 0 then
         OPEN template_csr;
         FETCH template_csr INTO l_template_flag;
         CLOSE template_csr;

         if fnd_function.test('PA_PAXTRAPE_ADJ_RECALC_CST_REV') AND (l_template_flag = 'N') then
            -- recalc
            return 'Y';
         end if;
      end if;
   end if;

   return 'N';

EXCEPTION
   WHEN OTHERS THEN
      return 'N';
END CHECK_PROJ_RECALC;


-- API name             : validate_pipeline_info
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           26-JUN-2002 --   anlee    - Created
--
--
FUNCTION VALIDATE_PIPELINE_INFO (p_project_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR C1 IS
  SELECT probability_member_id, expected_approval_date
  FROM   PA_PROJECTS_ALL
  WHERE  project_id = p_project_id;

  l_probability_member_id  NUMBER;
  l_expected_approval_date DATE;
BEGIN

  OPEN C1;
  FETCH C1 INTO l_probability_member_id, l_expected_approval_date;
  CLOSE C1;

  IF l_probability_member_id is not null and l_expected_approval_date is null THEN
    return 'PA_EXP_APP_DATE_REQUIRED';
  END IF;

  IF l_probability_member_id is null and l_expected_approval_date is not null THEN
    return 'PA_PROBA_PERCENT_REQUIRED';
  END IF;

  return NULL;
EXCEPTION
   WHEN OTHERS THEN
      return NULL;
END VALIDATE_PIPELINE_INFO;


-- API name             : check_classcode_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : It validates and returns the class code id
--                        from the class code and class category combination
--  History
--
--       20-Nov-2002   -- adabdull     - Created

PROCEDURE Check_ClassCode_Name_Or_Id(
        p_classcode_id           IN pa_class_codes.class_code_id%TYPE
       ,p_classcode_name         IN pa_class_codes.class_code%TYPE
       ,p_classcategory          IN pa_class_codes.class_category%TYPE
       ,p_check_id_flag          IN VARCHAR2
       ,x_classcode_id          OUT NOCOPY pa_class_codes.class_code_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

    CURSOR c_ids IS
       SELECT class_code_id
       FROM   pa_class_codes
       WHERE  class_category  = p_classcategory
         AND  class_code      = p_classcode_name;

    l_current_id       NUMBER     := NULL;
    l_num_ids          NUMBER     := 0;
    l_id_found_flag    VARCHAR(1) := 'N';

BEGIN

    pa_debug.init_err_stack ('pa_projects_maint_utils.Check_ClassCode_Name_Or_Id');

    IF p_classcode_id IS NOT NULL AND p_classcode_id <> FND_API.G_MISS_NUM THEN

       IF p_check_id_flag = 'Y' THEN
          SELECT class_code_id
          INTO   x_classcode_id
          FROM  pa_class_codes
          WHERE class_category = p_classcategory
            AND class_code_id  = p_classcode_id;

       ELSIF (p_check_id_flag = 'N') then
          x_classcode_id := p_classcode_id;

       ELSIF (p_check_id_flag = 'A') THEN

          IF p_classcode_name IS NULL THEN
              -- return a null since since the name is null
              x_classcode_id := NULL;
          ELSE
          -- fine the ID which matches the name
          OPEN c_ids;
          LOOP
                  FETCH c_ids INTO l_current_id;
          EXIT WHEN c_ids%notfound;
          IF (l_current_id = p_classcode_id) THEN
             l_id_found_flag := 'Y';
             x_classcode_id := p_classcode_id;
          END IF;
           END LOOP;
           l_num_ids := c_ids%rowcount;
           CLOSE c_ids;

           IF l_num_ids = 0 THEN
          -- No IDS for the name
          RAISE no_data_found;
           ELSIF(l_num_ids = 1) THEN
          -- there is only one
          x_classcode_id := l_current_id;
           ELSIF (l_id_found_flag = 'N') THEN
          -- more than one ID found for the name
          RAISE too_many_rows;
           END IF;
        END IF;

        END IF;

    ELSE

        IF (p_classcode_name IS NOT NULL) then
             SELECT class_code_id
             INTO   x_classcode_id
             FROM   pa_class_codes
             WHERE  class_category  = p_classcategory
             AND    class_code      = p_classcode_name;

        ELSE
         x_classcode_id := NULL;
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       x_classcode_id := null;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_CLASS_CATG_CODE_INVALID';

    WHEN TOO_MANY_ROWS THEN
       x_classcode_id := null;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_CLASS_CATG_CODE_INVALID';

    WHEN OTHERS THEN
       x_classcode_id := null;
       fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_PROJECTS_MAINT_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	-- 4537865
	x_error_message_code := SQLCODE ;
       RAISE;

END Check_Classcode_Name_Or_Id;


-- API name             : check_classcategory_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : It validates and returns the class category id
--                        from the class category name.
--  History
--
--       20-Nov-2002   -- adabdull     - Created

PROCEDURE Check_ClassCategory_Name_Or_Id(
        p_class_category_id      IN pa_class_categories.class_category_id%TYPE
       ,p_class_category_name    IN pa_class_categories.class_category%TYPE
       ,p_check_id_flag          IN VARCHAR2
       ,x_class_category_id     OUT NOCOPY pa_class_categories.class_category_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

    CURSOR c_ids IS
       SELECT class_category_id
       FROM   pa_class_categories
       WHERE  class_category  = p_class_category_name;

    l_current_id       NUMBER     := NULL;
    l_num_ids          NUMBER     := 0;
    l_id_found_flag    VARCHAR(1) := 'N';

BEGIN

    pa_debug.init_err_stack ('pa_projects_maint_utils.Check_ClassCategory_Name_Or_Id');

    IF p_class_category_id IS NOT NULL AND p_class_category_id <> FND_API.G_MISS_NUM THEN

       IF p_check_id_flag = 'Y' THEN
          SELECT class_category_id
          INTO   x_class_category_id
          FROM  pa_class_categories
          WHERE class_category_id = p_class_category_id;

       ELSIF (p_check_id_flag = 'N') then
          x_class_category_id := p_class_category_id;

       ELSIF (p_check_id_flag = 'A') THEN

          IF p_class_category_name IS NULL THEN
              -- return a null since since the name is null
              x_class_category_id := NULL;
          ELSE
          -- fine the ID which matches the name
          OPEN c_ids;
          LOOP
                  FETCH c_ids INTO l_current_id;
          EXIT WHEN c_ids%notfound;
          IF (l_current_id = p_class_category_id) THEN
             l_id_found_flag := 'Y';
             x_class_category_id := p_class_category_id;
          END IF;
           END LOOP;
           l_num_ids := c_ids%rowcount;
           CLOSE c_ids;

           IF l_num_ids = 0 THEN
          -- No IDS for the name
          RAISE no_data_found;
           ELSIF(l_num_ids = 1) THEN
          -- there is only one
          x_class_category_id := l_current_id;
           ELSIF (l_id_found_flag = 'N') THEN
          -- more than one ID found for the name
          RAISE too_many_rows;
           END IF;
        END IF;

        END IF;

    ELSE

        IF (p_class_category_name IS NOT NULL) then
             SELECT class_category_id
             INTO   x_class_category_id
             FROM   pa_class_categories
             WHERE  class_category  = p_class_category_name;

        ELSE
         x_class_category_id := NULL;
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       x_class_category_id := null;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_CLASS_CATG_INVALID';

    WHEN TOO_MANY_ROWS THEN
       x_class_category_id := null;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_CLASS_CATG_INVALID';

    WHEN OTHERS THEN
       x_class_category_id := null;
       fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_PROJECTS_MAINT_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	-- 4537865
	x_error_message_code := SQLCODE ;
       RAISE;

END Check_ClassCategory_Name_Or_Id;

-- API name             : class_check_mandatory
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : Checks whether the class category is mandatory and returns 'Y' or 'N'
--  History
--
--       19-Jan-2003   -- vshastry     - Created
--

FUNCTION CLASS_CHECK_MANDATORY
(
   p_class_category VARCHAR2,
   p_project_id NUMBER) RETURN VARCHAR2
IS
CURSOR C1 IS
SELECT mandatory_flag
FROM   pa_class_categories
WHERE  class_category = p_class_category;

CURSOR C2 IS
SELECT ps.project_system_status_code
FROM   pa_project_statuses ps, pa_projects_all pp
WHERE  pp.project_id = p_project_id
AND    pp.project_status_code = ps.project_status_code;

/* added cursor c3 for bug 2784433 */
CURSOR C3 IS
SELECT mandatory_flag
  FROM pa_valid_categories pvc
 WHERE class_category = p_class_category
   AND EXISTS  (SELECT 'X'
                  FROM pa_project_types_all pta
         WHERE pta.project_type_id = pvc.object_type_id
           AND EXISTS  (SELECT 'X'
                          FROM pa_projects_all ppa
                     WHERE pta.project_type = ppa.project_type
                   AND project_id = p_project_id));

x_mandatory_flag VARCHAR2(1);
l_project_status pa_project_statuses.project_system_status_code%TYPE;

BEGIN
   OPEN C2;
   FETCH C2 INTO l_project_status;
   CLOSE C2;

   IF l_project_status = 'APPROVED' THEN
      OPEN C1;
      FETCH C1 INTO x_mandatory_flag;
      CLOSE C1;

/* added for bug 2784433 */
      IF x_mandatory_flag <> 'Y' THEN
         OPEN C3;
     FETCH C3 INTO x_mandatory_flag;
     CLOSE C3;
      END IF;
/* added till here for bug 2784433 */
   END IF;
   RETURN x_mandatory_flag;
END CLASS_CHECK_MANDATORY;


END PA_PROJECTS_MAINT_UTILS;

/
