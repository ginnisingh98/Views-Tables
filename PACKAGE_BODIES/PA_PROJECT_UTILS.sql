--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_UTILS" as
-- $Header: PAXPUTLB.pls 120.8 2007/02/06 10:19:48 dthakker ship $


--
--  PROCEDURE
--              get_project_status_code
--  PURPOSE
--              This procedure retrieves project status code for a specified
--              project status.
--  HISTORY
--   16-OCT-95      R. Chiu       Created
--
l_pkg_name    VARCHAR2(30) := 'PA_PROJECT_UTILS';
procedure get_project_status_code (x_project_status  IN varchar2
                                  , x_project_status_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is
    cursor c1 is
           select project_status_code
             from pa_project_statuses
            where project_status_name = x_project_status;

    c1_rec      c1%rowtype;
    old_stack   varchar2(630);

begin
        x_err_code := 0;
        old_stack := x_err_stack;
        x_err_stack := x_err_stack || '->get_project_status_code';

        x_err_stage := 'get status code of project status '|| x_project_status;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           raise NO_DATA_FOUND;
        else
           x_project_status_code := c1_rec.project_status_code ;
        end if;
        close c1;

        x_err_stack := old_stack;

exception

   when NO_DATA_FOUND then
        x_err_code := 10;
        x_err_stage := 'PA_PROJ_NO_STATUS_CODE';
   when others then
        x_err_code := SQLCODE;

end get_project_status_code;


--  PROCEDURE
--              get_distribution_rule_code
--  PURPOSE
--              This function retrieves distribution rule name given the
--              user-friendly name that describes the distribution rule.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure get_distribution_rule_code ( x_dist_name        IN varchar2
                                  , x_dist_code         OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is
    cursor c1 is
                select distribution_rule
                from pa_distribution_rules
                where meaning = x_dist_name;

    c1_rec      c1%rowtype;
    old_stack   varchar2(630);

begin
        x_err_code := 0;
        old_stack := x_err_stack;
        x_err_stack := x_err_stack || '->get_distribution_rule_code';

        x_err_stage := 'get distribution rule code of '|| x_dist_name;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           raise NO_DATA_FOUND;
        else
           x_dist_code := c1_rec.distribution_rule ;
        end if;
        close c1;

        x_err_stack := old_stack;

exception

   when NO_DATA_FOUND then
        x_err_code := 10;
        x_err_stage := 'PA_PROJ_NO_DIST_RULE';
   when others then
        x_err_code := SQLCODE;

end get_distribution_rule_code;

--
--  PROCEDURE
--              get_proj_type_class_code
--  PURPOSE
--              This procedure retrieves project type class code for
--              a given project type or project id.  If both project type
--              and project id are passed, then procedure treated it as if
--              only project id were passed.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
procedure get_proj_type_class_code ( x_project_type     IN varchar2
                                  , x_project_id        IN number
                                  , x_proj_type_class_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is
    cursor c1 is
                select project_type_class_code
                from pa_project_types
                where project_type = x_project_type;

    cursor c2 is
                select project_type_class_code
                from pa_project_types_all t, pa_projects_all p  -- Modified pa_projects and pa_project_types to pa_projects_all and pa_project_types_all for bug#3512486
                where p.project_id = x_project_id
                and p.project_type = t.project_type
                -- and nvl(p.org_id, -99) = nvl(t.org_id, -99);   -- Added the and condition for bug#3512486
                and  p.org_id  =   t.org_id ;

    c1_rec      c1%rowtype;
    c2_rec      c2%rowtype;
    old_stack   varchar2(630);

begin
        x_err_code := 0;
        old_stack := x_err_stack;
        x_err_stack := x_err_stack || '->get_proj_type_class_code';

        if (x_project_type is null and x_project_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_TYPE_AND_ID';
                return;
        end if;

        x_err_stage := 'get proj type class code of '|| x_project_type;

        if (x_project_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   raise NO_DATA_FOUND;
                else
                   x_proj_type_class_code := c1_rec.project_type_class_code ;
                end if;
                close c1;
        else
                open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   raise NO_DATA_FOUND;
                else
                   x_proj_type_class_code := c2_rec.project_type_class_code ;
                end if;
                close c2;
        end if;

        x_err_stack := old_stack;

exception

   when NO_DATA_FOUND then
        x_err_code := 10;
        x_err_stage := 'PA_NO_PROJ_TYPE_CLASS';
   when others then
        x_err_code := SQLCODE;

end get_proj_type_class_code;


--
--  FUNCTION
--              check_unique_project_name
--  PURPOSE
--              This function returns 1 if a project name is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_project_name (x_project_name  IN varchar2,
                                    x_rowid       IN varchar2 ) return number
is
    cursor c1 is
          select project_id
          from pa_projects_all
          where name = x_project_name
          AND  (x_ROWID IS NULL OR x_ROWID <> pa_projects_all.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_project_name is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);

end check_unique_project_name;


--
--  FUNCTION
--              check_unique_long_name
--  PURPOSE
--              This function returns 1 if a long name is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   26-OCT-02      MUMOHAN          Created
--
function check_unique_long_name (x_long_name  IN varchar2,
                                 x_rowid      IN varchar2 ) return number
is
    cursor c1 is
          select project_id
          from pa_projects_all
          where long_name = x_long_name
          AND  (x_ROWID IS NULL OR x_ROWID <> pa_projects_all.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_long_name is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);

end check_unique_long_name;

--
--  FUNCTION
--              check_unique_project_number
--  PURPOSE
--              This function returns 1 if a project number is not already
--              used in PA system and returns 0 if number is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_project_number (x_project_number  IN varchar2,
                                    x_rowid       IN varchar2 ) return number
is
    cursor c1 is
          select project_id
          from pa_projects_all
          where segment1 = x_project_number
          AND  (x_ROWID IS NULL OR x_ROWID <> pa_projects_all.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_project_number is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);

end check_unique_project_number;


--
--  FUNCTION
--              check_unique_proj_class
--  PURPOSE
--              This function returns 1 if a project class code is
--              not already used for a specified project and class
--              category in PA system and returns 0 otherwise.
--              If a user does not supply all the values for project id,
--              x_class_category, and x_class_code, then null will
--              be returned.
--              If Oracle error occurs, Oracle error number is returned.
--
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_proj_class (x_project_id  IN number
                                  , x_class_category  IN varchar2
                                  , x_class_code     IN varchar2
                                  , x_rowid       IN varchar2 ) return number
is
        cursor c1 is
                select 1
                from pa_project_classes
                where project_id = x_project_id
                AND  class_category = x_class_category
                AND  class_code = x_class_code
                AND (x_rowid is null
                        or x_rowid <> pa_project_classes.rowid);

    c1_rec c1%rowtype;

begin
        if (x_project_id is null or x_class_category is null or
            x_class_code is null ) then
            return (null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);
end check_unique_proj_class;


--
--  FUNCTION
--              check_unique_customer
--  PURPOSE
--               This function returns 1 if a customer is unique for
--               the specified project and returns 0 if that customer
--               already exists for that project.  If a user does not
--               supply all the values, then null is returned. If Oracle
--               error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_customer (x_project_id  IN number
                                  , x_customer_id  IN varchar2
                                  , x_rowid       IN varchar2 ) return number
is
        cursor c1 is
                select 1
                from pa_project_customers
                where project_id = x_project_id
                AND  customer_id = x_customer_id
                AND (x_rowid is null
                        or x_rowid <> pa_project_customers.rowid);

    c1_rec c1%rowtype;

begin
        if (x_project_id is null or x_customer_id is null ) then
            return (null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);
end check_unique_customer;

--
--  FUNCTION
--              check_project_type_valid
--  PURPOSE
--              This function returns 1 if a project type is valid in
--              PA system and returns 0 if it's not valid.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_project_type_valid (x_project_type  IN varchar2 ) return number
is
        cursor c1 is
                select project_type from pa_project_types
                where project_type = x_project_type ;

        c1_rec c1%rowtype;

begin
        if (x_project_type is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(0);
        else
           close c1;
           return(1);
        end if;

exception
   when others then
        return(SQLCODE);
end check_project_type_valid;


--
--  FUNCTION
--              check_manager_exists
--  PURPOSE
--              This function returns 1 if a project has an acting
--              manager and returns 0  if no manage is found.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_manager_exists (x_project_id  IN number ) return number
is
        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT person_id
                        FROM pa_project_players
                        WHERE  project_id = x_project_id
                        and project_role_type = 'PROJECT MANAGER'
                        AND    TRUNC(sysdate) BETWEEN start_date_active
                        AND NVL(end_date_active, TRUNC(sysdate)));

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
               close c1;
               return (0);
        else
               close c1;
               return(1);
        end if;


exception
        when others then
            return (SQLCODE);
end check_manager_exists;


--  FUNCTION
--              check_bill_split
--  PURPOSE
--              This function returns 1 if a project has total customer
--              contribution of 100% and returns 0 if total contribution
--              is less than 100%.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_bill_split (x_project_id  IN number ) return number
is
        cursor c1 is
                SELECT NULL
                FROM    PA_PROJECT_CUSTOMERS
                WHERE   PROJECT_ID = x_PROJECT_ID
                GROUP   BY PROJECT_ID
                HAVING SUM(CUSTOMER_BILL_SPLIT) = 100;

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
               close c1;
               return (0);
        else
               close c1;
               return(1);
        end if;

exception
        when others then
                return (SQLCODE);
end check_bill_split;


--  FUNCTION
--              check_bill_contact_exists
--  PURPOSE
--              This function returns 1 if a project has a billing contact
--              for a customer whose contribution is greater than 0 and
--              returns 0 if this condition is not met for that project.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_bill_contact_exists (x_project_id  IN number ) return number
is
        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT NULL
                  FROM    PA_PROJECT_CUSTOMERS CUST
                  WHERE   CUST.PROJECT_ID = x_project_id
                  AND     CUST.CUSTOMER_BILL_SPLIT > 0
                  AND     EXISTS (SELECT NULL
                    FROM    PA_PROJECT_CONTACTS CONT
                    WHERE   CONT.PROJECT_ID = x_project_id
                    AND     CONT.CUSTOMER_ID=  CUST.CUSTOMER_ID
                    AND     CONT.PROJECT_CONTACT_TYPE_CODE = 'BILLING'));

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
               close c1;
               return (0);
        else
               close c1;
               return(1);
        end if;

exception
        when others then
                return (SQLCODE);
end check_bill_contact_exists;


--  FUNCTION
--              check_class_category
--  PURPOSE
--              This function returns 1 if a project has all the mandatory
--              class categories and returns 0 if mandatory class category
--              is missing.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_class_category (x_project_id  IN number ) return number
is
        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT NULL
-- anlee - modified for Classifications enhancements
/*
                FROM    PA_CLASS_CATEGORIES CC
                  WHERE   MANDATORY_FLAG = 'Y'
                  AND     TRUNC(SYSDATE) BETWEEN TRUNC(START_DATE_ACTIVE)
                       AND     TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
*/
                FROM    PA_VALID_CATEGORIES_V VC,
                        PA_PROJECTS_ALL PPA,
                        PA_PROJECT_TYPES_ALL PPTA
                WHERE   VC.MANDATORY_FLAG = 'Y'
                AND     PPA.PROJECT_ID = x_project_id
                AND     PPA.PROJECT_TYPE = PPTA.PROJECT_TYPE
                --AND     nvl(PPA.ORG_ID, -99) = nvl(PPTA.ORG_ID, -99)
                 AND     PPA.org_id  =  PPTA.org_id
                AND     VC.OBJECT_TYPE_ID = PPTA.PROJECT_TYPE_ID
                  AND     NOT EXISTS (SELECT NULL
                    FROM    PA_PROJECT_CLASSES PC
                    WHERE   PC.PROJECT_ID = x_PROJECT_ID
--                    AND     PC.CLASS_CATEGORY = CC.CLASS_CATEGORY));
                    AND     PC.CLASS_CATEGORY = VC.CLASS_CATEGORY));

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
               close c1;
               return (1);
        else
               close c1;
               return(0);
        end if;

exception
        when others then
                return (SQLCODE);
end check_class_category;


--  FUNCTION
--              check_draft_inv_exists
--  PURPOSE
--              This function returns 1 if draft invoice exists for a project
--              and returns 0 if no draft invoice is found.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_inv_exists (x_project_id  IN number ) return number
is
        x_proj_id       number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_draft_invoices
                        WHERE  project_id = x_project_id);

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
             close c1;
             return(0);
        else
             close c1;
             return(1);
        end if;


exception
        when others then
                return(SQLCODE);
end check_draft_inv_exists;


--  FUNCTION
--              check_draft_rev_exists
--  PURPOSE
--              This function returns 1 if draft revenue exists for a project
--              and returns 0 if no draft revenue is found.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_draft_rev_exists (x_project_id  IN number ) return number
is
        x_proj_id       number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_draft_revenues
                        WHERE  project_id = x_project_id);

        c1_rec c1%rowtype;

begin
        if (x_project_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
             close c1;
             return(0);
        else
             close c1;
             return(1);
        end if;

exception
        when others then
                return(SQLCODE);
end check_draft_rev_exists;


--  FUNCTION
--              check_created_proj_reference
--  PURPOSE
--              This function returns 1 if a project is referenced
--              by another project in pa_projects.created_from_project_id
--              and returns 0 if a project is not referenced.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_created_proj_reference (x_project_id  IN number ) return number
is
        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT null
                        FROM pa_projects
                        where  created_from_project_id = x_project_id);

        c1_rec c1%rowtype;

begin
        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
             close c1;
             return(0);
        else
             close c1;
             return(1);
        end if;

exception
        when others then
                return(SQLCODE);

end check_created_proj_reference;


--
--  PROCEDURE
--              check_delete_project_ok
--  PURPOSE
--              This objective of this API is to check if it is OK to
--              delete a project
--
--              In order to delete a project, a project must NOT
--              have any of the following:
--
--                     * Event
--                     * Expenditure item
--                     * Puchase order line
--                     * Requisition line
--                     * Supplier invoice (ap invoice)
--                     * Funding
--                     * Budget
--                     * Committed transactions
--                     * Compensation rule sets
--                     * Project is referenced by others
--                     * Project is used in allocations
--                     * Contract
--                     * Sourcing

procedure check_delete_project_ok ( x_project_id          IN number
                          , x_validation_mode   IN        VARCHAR2  DEFAULT 'U'   --Bug 2947492
                          , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                          , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                          , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    old_stack      varchar2(630);
    status_code    number;
    l_return_val     varchar2(1);
    dummy_null     varchar2(30) default null;
    cursor p1 is select 1 from pa_project_types
                 where burden_sum_dest_project_id = x_project_id;
    temp           number;
--Ansari
    x_used_in_OTL         BOOLEAN;   --To pass to OTL API.
    --For org fc
    l_return_status       VARCHAR2(30);
    l_err_code            VARCHAR2(2500);
    --For org fc
--Ansari

-- Ram Namburi
-- Bug Fix 4759187
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);

    -- Bug 5750591: Cursor to check whether the project_id passed is PJR Unassigned time project
    l_temp_char		VARCHAR2(1);
    CURSOR c_is_unassigned_time_proj(l_project_id IN NUMBER) IS
    SELECT 'Y'
    FROM pa_projects_all ppa, pa_forecasting_options_all pfoa
    WHERE ppa.project_id = l_project_id
    AND   ppa.org_id = pfoa.org_id
    AND  (pfoa.bill_unassign_proj_id = ppa.project_id OR pfoa.nonbill_unassign_proj_id = ppa.project_id);

    -- Bug 5750624: Cursor to check the project is allowed to deleted from PJR assignments
    -- We should not allow to delete project with Confirmed Assignment or if it had any Confirmed assignments in the past which is not Confirmed now.
    CURSOR c_is_pjr_delete_allowed(l_project_id IN NUMBER) IS
    SELECT 'N'
    FROM pa_project_assignments ppa, pa_project_statuses pps
    WHERE ppa.project_id = l_project_id
    AND ppa.assignment_type = 'STAFFED_ASSIGNMENT'
    AND pps.status_type = 'STAFFED_ASGMT'
    AND ppa.status_code = pps.project_status_code
    AND pps.project_system_status_code = 'STAFFED_ASGMT_CONF'
    UNION
    SELECT 'N'
    FROM pa_project_assignments ppa, pa_assignments_history pph, pa_project_statuses pps, pa_project_statuses pps1
    WHERE ppa.project_id = l_project_id
    AND ppa.assignment_id = pph.assignment_id
    AND ppa.assignment_type = 'STAFFED_ASSIGNMENT'
    -- AND pph.assignment_type = 'STAFFED_ASSIGNMENT'    -- Not required since a staffed assignment in present is checked with staffed assignment in the past
    AND pps.status_type = 'STAFFED_ASGMT'
    AND pph.status_code = pps.project_status_code
    AND pps.project_system_status_code = 'STAFFED_ASGMT_CONF'
    AND pps1.status_type = 'STAFFED_ASGMT'
    AND ppa.status_code = pps1.project_status_code
    AND pps1.project_system_status_code <> 'STAFFED_ASGMT_CANCEL';

begin
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->check_delete_project_ok';

        -- Check project id
        if (x_project_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_PROJ_ID';
                return;
        end if ;

        open p1;
        fetch p1 into temp;
        if p1%notfound then
           close p1; -- 5374313 removed null statement and added code to close cursor p1
        else
           close p1; -- 5374313 added code to close cursor p1
           x_err_code := 250;
           x_err_stage := 'PA_PROJ_BURDEN_SUM_DEST';
           return;
        end if;

        -- Check if project has event
        x_err_stage := 'check event for '|| x_project_id;
        status_code :=
                pa_proj_tsk_utils.check_event_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 20;
            x_err_stage := 'PA_PROJ_EVENT_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has expenditure item
        x_err_stage := 'check expenditure item for '|| x_project_id;
        status_code :=
                pa_proj_tsk_utils.check_exp_item_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 30;
            x_err_stage := 'PA_PROJ_EXP_ITEM_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has purchase order distribution
        x_err_stage := 'check purchase order for '|| x_project_id;
        status_code :=
                pa_proj_tsk_utils.check_po_dist_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 40;
            x_err_stage := 'PA_PROJ_PO_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has purchase order requisition
        x_err_stage := 'check purchase order requisition for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_po_req_dist_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 50;
            x_err_stage := 'PA_PROJ_PO_REQ_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has supplier invoices
        x_err_stage := 'check supplier invoice for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_ap_invoice_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 60;
            x_err_stage := 'PA_PROJ_AP_INV_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has supplier invoice distribution
        x_err_stage := 'check supplier inv distribution for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_ap_inv_dist_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 70;
            x_err_stage := 'PA_PROJ_AP_INV_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has funding
        x_err_stage := 'check funding for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_funding_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 80;
            x_err_stage := 'PA_PROJ_FUND_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has any budget
        x_err_stage := 'check budget for '|| x_project_id;
        status_code :=
             pa_budget_utils.check_proj_budget_exists(x_project_id, 'A',
                        dummy_null);
        if ( status_code = 1 ) then
            x_err_code := 90;
            x_err_stage := 'PA_PROJ_BUDGET_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has any FP options
        x_err_stage := 'check FP for '|| x_project_id;
        status_code :=
             PA_FIN_PLAN_UTILS.check_proj_fp_options_exists(p_project_id => x_project_id);
        if ( status_code = 1 ) then
            x_err_code := 95;
            x_err_stage := 'PA_PROJ_FP_OPTIONS_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;


        -- Check if project has commitment transaction
        x_err_stage := 'check commitment transaction for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_commitment_txn_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 100;
            x_err_stage := 'PA_PROJ_CMT_TXN_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project has compensation rule set
        x_err_stage := 'check compensation rule set for '|| x_project_id;
        status_code :=
             pa_proj_tsk_utils.check_comp_rule_set_exists(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 110;
            x_err_stage := 'PA_PROJ_COMP_RULE_SET_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project id is referenced by other projects
        x_err_stage := 'check project reference for '|| x_project_id;
        status_code :=
             pa_project_utils.check_created_proj_reference(x_project_id);
        if ( status_code = 1 ) then
            x_err_code := 120;
            x_err_stage := 'PA_PROJ_CREATED_REF_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project is in use in an external system
        x_err_stage := 'check for project used in external system for'|| x_project_id;
        status_code :=
             pjm_projtask_deletion.CheckUse_ProjectTask(x_project_id, null);
        if ( status_code = 1 ) then
            x_err_code := 130;
            /* Commented the existing error message and modified it to 'PA_PROJ_TASK_IN_USE_MFG' as below for bug 3600806
            x_err_stage := 'PA_PROJ_IN_USE_EXTERNAL'; */
            x_err_stage := 'PA_PROJ_TASK_IN_USE_MFG';
            return;
        elsif ( status_code = 2 ) THEN         -- Added elseif condition for bug 3600806.
            x_err_code := 130;
            x_err_stage := 'PA_PROJ_TASK_IN_USE_AUTO';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        elsif ( status_code <> 0) then        -- Added else condition for bug 3600806 to display a generic error message.
            x_err_code := 130;
            x_err_stage := 'PA_PROJ_TASK_IN_USE_EXTERNAL';
            return;
        end if;

        -- Check task
        for task_rec in (select task_id
                         from   pa_tasks
                         where  project_id = x_project_id
                         and    task_id = top_task_id) loop

            pa_task_utils.check_delete_task_ok(
                                        x_task_id      => task_rec.task_id,
                                        x_validation_mode     => x_validation_mode,   --Bug 2947492
                                        x_err_code            => x_err_code,
                                        x_err_stage           => x_err_stage,
                                        x_err_stack           => x_err_stack);
            if (x_err_code <> 0) then
                return;
            end if;

        end loop;

        -- Check if project is used in allocation rules
        x_err_stage := 'check if allocations use project  '|| x_project_id;
        l_return_val :=
             pa_alloc_utils.Is_Project_In_Allocations(x_project_id);
        if ( l_return_val = 'Y' ) then
            x_err_code := 150;
            x_err_stage := 'PA_PROJ_IN_ALLOC';
            return;
        end if;

        -- Check if project has cc organization relations
        x_err_stage := 'Check cc organization relations for '|| x_project_id;
        status_code :=
             pa_cc_utils.check_pvdr_rcvr_control_exist(x_project_id);
        if ( status_code = 1 ) then
            x_err_code := 160;
            x_err_stage := 'PA_PRJ_CC_ORG_REL_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if project contract is installed.
        -- IF CONTRACT_IS_INSTALLED THEN

        -- HSIU added.
        -- Check if contract is associated to the project
        IF ( pa_install.is_product_installed('OKE')) THEN
          x_err_stage := 'Check contract association for project '||x_project_id;
          IF (PA_PROJ_STRUCTURE_PUB.CHECK_SUBPROJ_CONTRACT_ASSO(x_project_id) <>
              FND_API.G_RET_STS_SUCCESS) THEN
            x_err_code := 170;
            x_err_stage := 'PA_STRUCT_PJ_HAS_CONTRACT';
            return;
          END IF;
        END IF;
        -- Finished checking if project contract is installed.
--Ansari
        --Check to see if the project has been used in OTL--Added by Ansari
          PA_OTC_API.ProjectTaskUsed( p_search_attribute => 'PROJECT',
                                      p_search_value     => x_project_id,
                                      x_used             => x_used_in_OTL );
          --If exists in OTL
          IF x_used_in_OTL
          THEN
            x_err_code := 180;
            x_err_stage := 'PA_PROJ_EXP_ITEM_EXIST';
            return;
          END IF;

        --end of OTL check.
--Ansari
        --Check to see if the project is in use Org Forecasting
         IF PA_FP_ORG_FCST_UTILS.check_org_proj_template
                   (  p_project_id      => x_project_id
                     ,x_return_status   => l_return_status
                     ,x_err_code        => l_err_code ) = 'Y'
         THEN
            x_err_code := 190;
            x_err_stage := 'PA_FP_PROJ_REF_FCST_OPTIONS';
            return;
         END IF;
        --end of ORG-FORECASTING check.

--PA K Build 3
        x_err_stage := 'Check Control items exist for project '|| x_project_id;
        IF PA_CONTROL_ITEMS_UTILS.check_control_item_exists( p_project_id    => x_project_id ) <> 0
        THEN
            x_err_code := 200;
            x_err_stage := 'PA_CI_PROJ_TASK_IN_USE';
            return;
        end if;

        x_err_stage := 'Check Non Draft Control items exist for project '|| x_project_id;
        IF PA_CONTROL_ITEMS_UTILS.CheckNonDraftCI( p_project_id    => x_project_id ) = 'Y'
        THEN
            x_err_code := 210;
            x_err_stage := 'PA_CI_ITEMS_EXIST';
            return;
        end if;

--PA K Build 3

        -- Ram Namburi
        -- Bug Fix 4759187

        -- Check to see if the project has been used in Sourcing i.e PON

          PON_PROJECTS_INTEGRATION_GRP.CHECK_DELETE_PROJECT_OK(
                                      p_api_version      => 1.0,
                                      p_init_msg_list    => FND_API.G_TRUE,
                                      p_project_id       => x_project_id,
                                      x_return_status    => l_return_status,
                                      x_msg_count        => l_msg_count,
                                      x_msg_data         => l_msg_data );

          --If the project is used in sourcing then the return status is an error.
          -- so check the return status and if it is not success then the message data string contains appropriate
          -- message as well.
          -- The message is also set in the message stack. All we need to do is return from here as we are doing
          -- for other earlier checks.

          IF NVL(l_return_status , FND_API.G_RET_STS_SUCCESS)  <> FND_API.G_RET_STS_SUCCESS THEN
            x_err_code := 300;
            x_err_stage := l_msg_data; -- 'PON_PROJECT_USED_NO_DELETE';
            return;
          END IF;

        -- End of Bug Fix 4759187

	-- Start Bug 5750591: Cursor to check whether the project_id passed is PJR Unassigned time project
        OPEN c_is_unassigned_time_proj(x_project_id);
        FETCH c_is_unassigned_time_proj INTO l_temp_char;
        IF c_is_unassigned_time_proj%NOTFOUND THEN
           CLOSE c_is_unassigned_time_proj;
        ELSE
           CLOSE c_is_unassigned_time_proj;
           x_err_code := 310;
           x_err_stage := 'PA_PROJ_IS_UNASSIGNED_TIME';
           RETURN;
        END IF;
	-- End Bug 5750591: Cursor to check whether the project_id passed is PJR Unassigned time project

	-- Start Bug 5750624: Cursor to check the project is allowed to deleted from PJR assignments
	-- We should not allow to delete project with Confirmed Assignment or any assignment which had been in confirmed state previously
	OPEN c_is_pjr_delete_allowed(x_project_id);
	FETCH c_is_pjr_delete_allowed INTO l_temp_char;
	IF c_is_pjr_delete_allowed%NOTFOUND THEN
           CLOSE c_is_pjr_delete_allowed;
	ELSE
           CLOSE c_is_pjr_delete_allowed;
           x_err_code := 320;
           x_err_stage := 'PA_PJR_CONFIRMED_ASSIGNMENT';
           RETURN;
	END IF;
	-- End Bug 5750624: Cursor to check the project is allowed to deleted from PJR assignments

	x_err_stack := old_stack;

exception
        when others then
                x_err_code := SQLCODE;
                rollback;
                return;
end check_delete_project_ok;

--
--  PROCEDURE
--              change_pt_org_ok
--  PURPOSE
--              This procedure checks if a project  has CDLs,Rev  or
--              Draft invoices.If project has any of
--              these information, then it's not ok to change the project
--              type or org and specific reason will be returned.
--              If it's ok to change project type or org,
--              the x_err_code will be 0.
--
--  HISTORY
--   13-JAN-96      R.Krishnamurthy  Created
--
procedure change_pt_org_ok        ( x_project_id        IN        number
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2)  --File.Sql.39 bug 4440895
is
    old_stack      varchar2(630);
    status_code    number;
begin
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->change_pt_org_ok';

        -- Check project id
        if (x_project_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_PROJ_ID';
                return;
        end if ;
        -- Check for cdls for the project
        x_err_stage := 'check cdls for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_cdl_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 20;
           x_err_stage := 'PA_PR_CANT_CHG_PROJ_TYPE';
           return;
        end if;

        -- Check for draft revenue items  for the project
        x_err_stage := 'check draft rev for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_draft_rev_item_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 30;
           x_err_stage := 'PA_PR_CANT_CHG_PROJ_TYPE';
           return;
        end if;

        -- Check for draft inv items for the project
        x_err_stage := 'check draft inv for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_draft_inv_item_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 40;
           x_err_stage := 'PA_PR_CANT_CHG_PROJ_TYPE';
           return;
        end if;

        x_err_stack := old_stack;

exception
        when others then
                x_err_code := SQLCODE;
                rollback;
                return;
end change_pt_org_ok;

--
--  PROCEDURE
--              change_proj_num_ok
--  PURPOSE
--              This procedure checks if a project  has exp items,po reqs,
--              Draft invoices,po dists,ap invoices and ap inv dists .
--              If project has any of
--              these information, then it's not ok to change the project
--              number If it's ok to change project number
--              the x_err_code will be 0.
--
--  HISTORY
--   15-JAN-96      R.Krishnamurthy  Created
--

procedure change_proj_num_ok      ( x_project_id        IN        number
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    old_stack      varchar2(630);
    status_code    number;
begin
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->change_proj_num_ok';

        -- Check project id
        if (x_project_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_PROJ_ID';
                return;
        end if ;

        -- Check for exp items for the project
        x_err_stage := 'check exp items for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_exp_item_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 20;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_EXP';
           return;
        end if;

        -- Check for invoices for the project
        x_err_stage := 'check invoices for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_draft_inv_item_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 30;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_INV';
           return;
        end if;

        -- Check for po reqs for the project
        x_err_stage := 'check po reqs for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_po_req_dist_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 40;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_EXP';
           return;
        end if;

        -- Check for po dist  for the project
        x_err_stage := 'check po dist for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_po_dist_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 50;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_EXP';
           return;
        end if;

        -- Check for ap inv for the project
        x_err_stage := 'check ap inv for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_ap_invoice_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 60;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_INV';
           return;
        end if;

        -- Check for ap inv dist for the project
        x_err_stage := 'check ap inv dist for project '|| x_project_id;
        status_code := pa_proj_tsk_utils.check_ap_inv_dist_exists
                       (x_project_id,Null);
        if status_code <> 0 Then
           x_err_code  := 70;
           x_err_stage := 'PA_PR_NO_UPD_SEGMENT1_INV';
           return;
        end if;

        x_err_stack := old_stack;

exception
        when others then
                x_err_code := SQLCODE;
                rollback;
                return;

end change_proj_num_ok;


--  FUNCTION
--              check_option_child_exists
--  PURPOSE
--              This function returns Y if child for the option  exists
--              and N otherwise
--
--  HISTORY
--   13-DEC-96      D.Roy        Created

Function check_option_child_exists
(p_option_code  varchar2)
return varchar2 is
  rv varchar2(1) ;
  temp number;
begin
  begin
    select 1
    into   temp
    from  sys.dual where
  exists ( select 1 from pa_options  where parent_option_code = p_option_code);
    rv := 'Y';
  exception
    when NO_DATA_FOUND then
      rv := 'N';
  end;
  return rv;
end check_option_child_exists;

--  FUNCTION
--              check_proj_funding
--  PURPOSE
--              This function returns 1 if funding exists for a project
--              with allocated amount > 0.Returns 0 if allocated amount <- 0
--              or there are no fundings for that project. If fundings
--              exist and allocated amount > 0 then , function returns 1.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   16-JAN-96      R. Krishnamurthy       Created
--
function check_proj_funding (x_project_id  IN number ) return number
is

        cursor c1 is
                SELECT NVL(SUM(NVL(allocated_amount,0)),0) allocated_amount
                FROM    pa_project_fundings
                WHERE   project_id = x_project_id;
        c1_rec  c1%rowtype;
begin
        if (x_project_id is null ) then
                return(null);
        end if;
        open c1;
        fetch c1 into c1_rec;
        If c1%notfound or
           c1_rec.allocated_amount <= 0 then
           close c1;
           return(0);
        end if;
        if c1_rec.allocated_amount > 0 then
           close c1;
           return(1);
        end if;
exception
        when others then
                return(SQLCODE);

end check_proj_funding;

--  PROCEDURE
--              check_dist_rule_chg_ok
--  PURPOSE
--              This procedure checks whether it is ok
--              to change the Distribution rule
--              If it's ok to change Distribution rule
--              the x_err_code will be 0.
--
--  HISTORY
--   17-APR-96      R.Krishnamurthy  Created
--      Right now the procedure does nothing. The rules shall be added later.
--   02-DEC-97      C.Hung           Added validation


procedure check_dist_rule_chg_ok  ( x_project_id        IN        number
                                  , x_old_dist_rule     IN        varchar2
                                  , x_new_dist_rule     IN        varchar2
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) Is --File.Sql.39 bug 4440895
    old_stack      varchar2(630);
    status_code    number;
    dummy varchar2(1);
Begin
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->check_dist_rule_chg_ok';

        -- Check project id
        if (x_project_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_PROJ_ID';
                return;
        end if ;

        -- Check if x_old_dist_rule and x_new_dist_rule are the same
        if x_old_dist_rule <> x_new_dist_rule then

          -- Check if exp item exists
          x_err_stage := 'check expenditure items for project '|| x_project_id;

          begin
            select null
            into dummy
            from sys.dual
            where not exists (
              select null
              from pa_expenditure_items_all pai
               /* Bug#3461661 : removed join with pa_tasks
                * ,pa_tasks t
                */
                  ,pa_cost_distribution_lines_all pcd
              where
               /* Bug#3461661 : removed join condition
                * pai.task_id = t.task_id
                * and
                */
                    pai.expenditure_item_id = pcd.expenditure_item_id
                and pai.project_id = x_project_id);
          exception
            when no_data_found then
              x_err_code := 20;
/* Changed message name trailing under_score since that is the way
   it is stored in FND_NEW_MESSAGES - Bug# 1718782
              x_err_stage := 'PA_HAS_REV/INV';
*/
              x_err_stage := 'PA_HAS_REV/INV_';
              return;
            when others then
              x_err_code := SQLCODE;
              return;
          end;

          -- Check if draft revenue exists
          x_err_stage := 'check draft revenue for project '|| x_project_id;

          begin
            select null
            into dummy
            from sys.dual
            where not exists (
              select null
              from pa_draft_revenues_all
              where project_id = x_project_id);
          exception
            when no_data_found then
              x_err_code := 30;
/* Changed message name trailing under_score since that is the way
   it is stored in FND_NEW_MESSAGES - Bug# 1718782
              x_err_stage := 'PA_HAS_REV/INV';
*/
              x_err_stage := 'PA_HAS_REV/INV_';
              return;
            when others then
              x_err_code := SQLCODE;
              return;
          end;

          -- Check if draft invoice exists
          x_err_stage := 'check draft invoices for project '|| x_project_id;

          begin
            select null
            into dummy
            from sys.dual
            where not exists (
              select null
              from pa_draft_invoices_all
              where project_id = x_project_id);
          exception
            when no_data_found then
              x_err_code := 40;
/* Changed message name trailing under_score since that is the way
   it is stored in FND_NEW_MESSAGES - Bug# 1718782
              x_err_stage := 'PA_HAS_REV/INV';
*/
              x_err_stage := 'PA_HAS_REV/INV_';
              return;
            when others then
              x_err_code := SQLCODE;
              return;
          end;
        end if;

        x_err_stack := old_stack;

-- Included Exception Block for 4537865
EXCEPTION
WHEN OTHERS THEN
        x_err_code := SQLCODE;
        return; -- Used Return instead of a RAISE because in this API ,everywhere it is so.
End check_dist_rule_chg_ok;

FUNCTION GetProjNumMode RETURN VARCHAR2 IS
-- This function returns the implementation-defined Project number
-- generation mode . The mode could either be 'AUTOMATIC' which implies
-- automatic numbering by PA or 'MANUAL' which implies that project
-- number is to be assigned by users

-- If using server side PL/SQL or a client side PL/SQL through Oracle forms,
-- the best way to make use of this function is to define a package variable
-- in your package specification and assign the default value.
-- For example in the package specification
-- G_Proj_number_Gen_Mode  Varchar2(30) := PA_PROJECT_UTILS.GetProjNumMode;

l_proj_number_mode   VARCHAR2(30);
CURSOR l_get_proj_number_csr IS
SELECT user_defined_project_num_code
FROM pa_implementations;

BEGIN
     OPEN l_get_proj_number_csr;
     FETCH l_get_proj_number_csr INTO l_proj_number_mode;
     CLOSE l_get_proj_number_csr;
     RETURN l_proj_number_mode;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END GetProjNumMode;

FUNCTION GetProjNumType RETURN VARCHAR2 IS
-- This function returns the implementation-defined Project number
-- type. The mode could either be 'NUMERIC' or 'ALPHANUMERIC'

-- If using server side PL/SQL or a client side PL/SQL through Oracle forms,
-- the best way to make use of this function is to define a package variable
-- in your package specification and assign the default value.
-- For example in the package specification
-- G_Proj_number_Gen_Type  Varchar2(30) := PA_PROJECT_UTILS.GetProjNumType;

l_proj_number_type   VARCHAR2(30);
CURSOR l_get_proj_type_csr IS
SELECT manual_project_num_type
FROM pa_implementations;

BEGIN
     OPEN l_get_proj_type_csr;
     FETCH l_get_proj_type_csr INTO l_proj_number_type;
     CLOSE l_get_proj_type_csr;
     RETURN l_proj_number_type;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END GetProjNumType;

FUNCTION Check_project_action_allowed
                          (x_project_id  IN NUMBER,
                           x_action_code IN VARCHAR2 ) return VARCHAR2
IS
--
-- Bug 940541
-- modified the cusror to select from pa_projects_all
-- since project_id is unique across operating units, it should
-- be fine to select from pa_projects_all table.

CURSOR l_project_csr IS
SELECT project_status_code
FROM pa_projects_all pap
WHERE pap.project_id = x_project_id;
l_project_status_code   VARCHAR2(30);
l_action_allowed   VARCHAR2(1) := 'N';

BEGIN
     OPEN l_project_csr;
     FETCH l_project_csr INTO l_project_status_code;
     IF l_project_csr%NOTFOUND THEN
        CLOSE l_project_csr;
        RETURN 'N';
     END IF;
     l_action_allowed :=
     Check_prj_stus_action_allowed (x_project_status_code =>
                                    l_project_status_code,
                                    x_action_code => x_action_code );
      RETURN (NVL(l_action_allowed,'N'));
EXCEPTION
  WHEN OTHERS THEN
      RETURN 'N';

END Check_project_action_allowed;

FUNCTION Check_prj_stus_action_allowed
                          (x_project_status_code IN VARCHAR2,
                           x_action_code     IN VARCHAR2 ) return VARCHAR2
IS
/*Added project_system_status_code for bug 2125791*/
CURSOR l_prjstus_csr IS
SELECT enabled_flag ,project_system_status_code
FROM pa_project_status_controls
WHERE project_status_code = x_project_status_code
AND   action_code         = x_action_code;
l_action_allowed  VARCHAR2(1) := 'N';
x_proj_sys_status_code  VARCHAR2(30);/*Added for bug 2125791*/
BEGIN

/* Added for bug 2125791*/
    For curr_rec in 1..glob_total_rec
    LOOP
      IF   glob_project_status_code(curr_rec) = x_project_status_code
      AND  glob_action_code(curr_rec)         = x_action_code THEN
         return(nvl(glob_enabled_flag(curr_rec),'N'));
      END IF;
    END LOOP;
/* End for bug 2125791*/

       OPEN l_prjstus_csr;
       FETCH l_prjstus_csr INTO l_action_allowed,x_proj_sys_status_code;
       IF l_prjstus_csr%NOTFOUND THEN
          CLOSE l_prjstus_csr;
          RETURN 'N';
       END IF;
       CLOSE l_prjstus_csr;

/*Added for bug 2125791*/
       if glob_total_rec >10 then
          glob_total_rec := 0;
          glob_project_status_code   := null_pointer;
          glob_action_code           := null_pointer;
          glob_proj_sys_status_code  := null_pointer;
          glob_enabled_flag          := null_pointer1;
        end if;

       glob_total_rec := glob_total_rec +1;
       glob_project_status_code(glob_total_rec) := x_project_status_code;
       glob_action_code(glob_total_rec)         := x_action_code;
       glob_proj_sys_status_code(glob_total_rec) := x_proj_sys_status_code;
       glob_enabled_flag(glob_total_rec)        := l_action_allowed;
/*End for bug 2125791*/

       RETURN (NVL(l_action_allowed,'N'));
EXCEPTION
  WHEN OTHERS THEN
      RETURN 'N';
END Check_prj_stus_action_allowed;
/* Bug 1512933 : Assignment Approval Changes */

FUNCTION Check_sys_action_allowed
                          (x_project_system_status_code IN VARCHAR2,
                           x_action_code     IN VARCHAR2 ) return VARCHAR2
IS
/*Added project_status_code for bug 2125791*/
CURSOR l_prjstus_csr IS
SELECT enabled_flag,project_status_code
FROM pa_project_status_controls
WHERE project_system_status_code = x_project_system_status_code
AND   action_code         = x_action_code;
l_action_allowed  VARCHAR2(1) := 'N';
x_project_status_code  VARCHAR2(30);/* Added for bug 2125791*/
BEGIN
/*Added for bug 2125791 */
    For curr_rec in 1..glob_total_rec
    LOOP
      IF glob_proj_sys_status_code(curr_rec) = x_project_system_status_code
      AND  glob_action_code(curr_rec)         = x_action_code THEN
         return(nvl(glob_enabled_flag(curr_rec),'N'));
      END IF;
    END LOOP;
/*End for bug 2125791 */

       OPEN l_prjstus_csr;
       FETCH l_prjstus_csr INTO l_action_allowed,x_project_status_code;
       IF l_prjstus_csr%NOTFOUND THEN
          RETURN 'Y';
       END IF;
       CLOSE l_prjstus_csr;

/*Added for bug 2125791*/
       if glob_total_rec >10 then
          glob_total_rec := 0;
          glob_project_status_code   := null_pointer;
          glob_action_code           := null_pointer;
          glob_proj_sys_status_code  := null_pointer;
          glob_enabled_flag          := null_pointer1;
        end if;

       glob_total_rec := glob_total_rec +1;
       glob_project_status_code(glob_total_rec) := x_project_status_code;
       glob_action_code(glob_total_rec)         := x_action_code;
       glob_proj_sys_status_code(glob_total_rec):= x_project_system_status_code;
       glob_enabled_flag(glob_total_rec)        := l_action_allowed;
/*End for bug 2125791*/

       RETURN (NVL(l_action_allowed,'N'));
EXCEPTION
  WHEN OTHERS THEN
      RETURN 'N';
END Check_sys_action_allowed;

FUNCTION is_tp_schd_proj_task(p_tp_schedule_id in number)
                                         return varchar2
IS
CURSOR  C_schedule_in_use IS
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  PA_PROJECTS_ALL PP
               WHERE  PP.labor_tp_schedule_id=p_tp_schedule_id
                OR    PP.nl_tp_schedule_id=p_tp_schedule_id
               )
      OR EXISTS
               (SELECT 'Y'
               FROM   PA_TASKS PT
               WHERE  PT.labor_tp_schedule_id=p_tp_schedule_id
                OR   PT.nl_tp_schedule_id=p_tp_schedule_id
               );
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_schedule_in_use ;
  FETCH  C_schedule_in_use INTO v_dummy;
  IF  C_schedule_in_use%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE  C_schedule_in_use;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_tp_schd_proj_task ;


--  FUNCTION
--              Is_Admin_Project
--  PURPOSE
--              This function checks if a given project_id is
--              an Admin Project.  If it is an Admin project
--              then the function returns 'Y'.  If not, then the
--              function returns 'N'.
--
--  HISTORY
--   21-NOV-00      A.Layton       Created
--
FUNCTION Is_Admin_Project (p_project_id  IN pa_projects_all.project_id%TYPE)
                              RETURN VARCHAR2
IS

l_admin_flag    VARCHAR2(1);

BEGIN

   SELECT administrative_flag INTO l_admin_flag
   FROM   pa_project_types_all pt,
          pa_projects_all proj
   WHERE  pt.project_type = proj.project_type
     --AND  nvl(pt.org_id, -99) = nvl(proj.org_id, -99)
        AND pt.org_id = proj.org_id  --avajain
     AND  proj.project_id = p_project_id;

   RETURN l_admin_flag;

EXCEPTION
        WHEN OTHERS THEN
          RAISE;

END Is_Admin_Project;

--  FUNCTION
--              Is_Unassigned_Time_Project
--  PURPOSE
--              This function checks if a given project_id is
--              an Unassigned Time project.  If it is an Unassigned Time project
--              then the function returns 'Y'.  If not, then the
--              function returns 'N'.
--
--  HISTORY
--   25-SEP-00      A.Layton       Created
--
FUNCTION Is_Unassigned_Time_Project (p_project_id  IN pa_projects_all.project_id%TYPE)
                                    RETURN VARCHAR2
IS

l_unassigned_time_flag    VARCHAR2(1) := 'N';

BEGIN

   SELECT pt.unassigned_time INTO l_unassigned_time_flag
   FROM   pa_project_types_all pt,
          pa_projects_all proj
   WHERE  pt.project_type = proj.project_type
     --AND  nvl(pt.org_id, -99) = nvl(proj.org_id, -99)
        AND  pt.org_id = proj.org_id
     AND  proj.project_id = p_project_id;

   RETURN l_unassigned_time_flag;

EXCEPTION
        WHEN OTHERS THEN
          RAISE;

END Is_Unassigned_Time_Project;

FUNCTION IsUserProjectManager(p_project_id       IN  NUMBER,
                               p_user_id         IN  NUMBER) RETURN VARCHAR2 IS
   x_val       varchar2(1) := 'N';
BEGIN

    select 'Y'
      into x_val
     from pa_project_parties_v
    where project_id = p_project_id
      and project_role_id = 1
      and user_id = p_user_id
      and trunc(sysdate) between trunc(start_date_active) and trunc(nvl(end_date_active,sysdate)); ----- Project Manager

    return x_val;

exception when others then
    return 'N';

END IsUserProjectManager;

--  PROCEDURE
--              check_delete_project_type_ok
--  PURPOSE
--              This objective of this API is to check if it is OK to
--              delete a proejct type
--
procedure check_delete_project_type_ok (
    p_project_type_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS
   l_return_value VARCHAR2(1) := 'N';
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF NVL( PA_CONTROL_ITEMS_UTILS.check_project_type_in_use(
                                   p_project_type_id  => p_project_type_id ), 0 ) <> 0
     THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message_code :='PA_CI_PROJ_TYPE_IN_USE';
     END IF;

-- 4537865
EXCEPTION
WHEN OTHERS THEN
        x_error_message_code := SQLERRM ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end check_delete_project_type_ok;

/*Start: Addition of code for bug 2682806 */

Procedure check_delete_class_catg_ok (
    p_class_category                    IN  VARCHAR2
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS

BEGIN
     x_return_status :='S';
     IF NVL(Pa_Control_items_utils.Check_Class_Category_In_Use
                                  (p_class_category=>p_class_category),0)=1
     THEN
         x_return_status := 'F' ;
         x_error_message_code := 'PA_CI_CLASS_CAT_IN_USE';
     END IF;

-- 4537865
EXCEPTION
WHEN OTHERS THEN
        x_error_message_code := SQLERRM ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end check_delete_class_catg_ok;

Procedure check_delete_class_code_ok (
    p_class_category                    IN  VARCHAR2
   ,p_class_code                        IN  VARCHAR2
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

BEGIN
     x_return_status :='S';
     IF NVL(Pa_Control_items_utils.Check_Class_Code_In_Use
                                  (p_class_category=>p_class_category,
                                   P_class_code => p_class_code ),0)=1
     THEN
         x_return_status := 'F' ;
         x_error_message_code := 'PA_CI_CLASS_CODE_IN_USE';
     END IF;

-- 4537865
EXCEPTION
WHEN OTHERS THEN
        x_error_message_code := SQLERRM ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end check_delete_class_code_ok;


/*End: Addition of code for bug 2682806 */

--
--  FUNCTION
--              check_unique_project_reference
--  PURPOSE
--              This function returns 1 if a project reference is not already
--              used in PA system and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   16-JUL-2003      zahid.khan          Created
--   11-Dec-2005      sunkalya            Bug Fix:4870305. Added parameter p_prod_code.
--
function check_unique_project_reference (p_proj_ref  IN varchar2,
                                        p_prod_code IN varchar2, -- added for bug 4870305
                                 p_rowid      IN varchar2 ) return number
is
    cursor c1 is
     select project_id
          from pa_projects_all
          where pm_project_reference = p_proj_ref
          and pm_product_code = p_prod_code      -- added for bug 4870305
          AND  (p_ROWID IS NULL OR p_ROWID <> pa_projects_all.ROWID);

    c1_rec c1%rowtype;

begin
        if (p_proj_ref is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);

end check_unique_project_reference;

--bug#2984611
--This fucntion checks if the change in project type to
--inter company project type is allowed or not.If the
--primary ct/ship to ct. and bill to. customer are not
--same then change to IC project type is not allowed.
--This function takes the project type also as input
--and performs the validation only when project type
--is a IC project type i.e cc_prvdr_flag is 'Y'

function check_ic_proj_type_allowed(p_project_id IN NUMBER
                                   ,p_cc_prvdr_flag IN VARCHAR2 )
RETURN NUMBER
IS
CURSOR c1 is
   SELECT 'Y'
     FROM DUAL
     WHERE EXISTS (SELECT 'Y'
                     FROM  PA_PROJECT_CUSTOMERS
                    WHERE project_id = p_project_id
                      AND (customer_id <> bill_to_customer_id
                       OR customer_id <> ship_to_customer_id )) ;
c1_rec c1%rowtype ;

BEGIN
if p_project_id is NULL then
     return(null);
end if ;

if nvl(p_cc_prvdr_flag,'N') = 'Y' then
     open c1 ;
     fetch c1 into c1_rec ;

     if c1%notfound then
        close c1 ;
        return(0);
     else
        close c1 ;
        return (1);
     end if ;
else
    return(0) ;
end if ;

EXCEPTION
WHEN OTHERS THEN
  if c1%ISOPEN THEN
    close c1 ;
  end if ;
  return(sqlcode) ;
END check_ic_proj_type_allowed ;

/* Function added for bug 3738892 */
FUNCTION is_flex_enabled ( appl_id IN NUMBER, flex_name IN varchar2)
RETURN NUMBER
IS
flex_setup boolean;
BEGIN
 flex_setup := Fnd_Flex_Apis.is_descr_setup(appl_id,flex_name);
 IF (flex_setup) THEN
   RETURN 1;
 ELSE
   RETURN 0;
 end if;

exception
   when others then
        return(SQLCODE);
end is_flex_enabled;

/*
   Bug 5647964 Added the generic API which can be used for DFF Validations.
   The Procedure validates if the user has passed the required values for the various segments if they are required
*/


PROCEDURE VALIDATE_DFF
(   p_application_id               IN  NUMBER,
    p_flexfield_name               IN VARCHAR2,
    p_attribute_category           IN VARCHAR2,
    p_calling_module               IN VARCHAR2,
    p_attribute1                   IN VARCHAR2,
    p_attribute2                   IN VARCHAR2,
    p_attribute3                   IN VARCHAR2,
    p_attribute4                   IN VARCHAR2,
    p_attribute5                   IN VARCHAR2,
    p_attribute6                   IN VARCHAR2,
    p_attribute7                   IN VARCHAR2,
    p_attribute8                   IN VARCHAR2,
    p_attribute9                   IN VARCHAR2,
    p_attribute10                  IN VARCHAR2,
    p_attribute11                  IN VARCHAR2,
    p_attribute12                  IN VARCHAR2,
    p_attribute13                  IN VARCHAR2,
    p_attribute14                  IN VARCHAR2,
    p_attribute15                  IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
 IS


l_flex_required                          BOOLEAN;
l_is_context_segment_required            BOOLEAN;
l_global_req_segs_info1                  Fnd_Flex_Apis.dff_required_segments_info;
l_context_req_segs_info1                 Fnd_Flex_Apis.dff_required_segments_info;
l_segment_name                           VARCHAR2(30);

TYPE application_names IS VARRAY(15) of  VARCHAR2(240);

v_application_names                      application_names;
l_index                                  NUMBER;
i                                        NUMBER;
x_error_code                             NUMBER := 0;
l_count                                  NUMBER;
BEGIN
v_application_names := application_names();

l_flex_required := Fnd_Flex_Apis.is_descr_required(p_application_id,p_flexfield_name);
IF (l_flex_required) THEN
    Fnd_Flex_Apis.get_dff_global_req_segs_info(p_application_id              => p_application_id,
                                               p_flexfield_name              => p_flexfield_name,
                                               x_is_context_segment_required => l_is_context_segment_required,
                                               x_global_req_segs_info        => l_global_req_segs_info1) ;

    IF (l_is_context_segment_required) THEN
        IF p_attribute_category IS NULL THEN
            x_error_code :=100 ;
            l_segment_name := NULL;
        ELSE
            Fnd_Flex_Apis.get_dff_context_req_segs_info(p_application_id      => p_application_id,
                                                      p_flexfield_name        => p_flexfield_name,
			                                          p_context_code          => p_attribute_category,
                                                      x_context_req_segs_info => l_context_req_segs_info1);
        END IF;
    END IF;
END IF;
/* GET APPL_COLUMN_NAMES FOR x_global_req_segs_info1 AND x_global_req_segs_info2
None of these columns should be null */
l_count := l_global_req_segs_info1.required_segment_names.count + l_context_req_segs_info1.required_segment_names.count ;
v_application_names.EXTEND(l_count);
l_index :=v_application_names.FIRST ;

if l_global_req_segs_info1.required_segment_names.first is not null then
    for x in l_global_req_segs_info1.required_segment_names.first..l_global_req_segs_info1.required_segment_names.last loop
        select APPLICATION_COLUMN_NAME
        into
        v_application_names(l_index)
        from fnd_descr_flex_column_usages
        where END_USER_COLUMN_NAME = l_global_req_segs_info1.required_segment_names(x)
        and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
        and DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements' ;
        l_index := v_application_names.NEXT(l_index);
    End Loop;
end if;

if l_context_req_segs_info1.required_segment_names.first is not null then
    for y in l_context_req_segs_info1.required_segment_names.first..l_context_req_segs_info1.required_segment_names.last loop
        select APPLICATION_COLUMN_NAME
        into
        v_application_names(l_index)
        from fnd_descr_flex_column_usages
        where END_USER_COLUMN_NAME = l_context_req_segs_info1.required_segment_names(y)  --x_context_req_segs_info1(l_index)
        and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
        and DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attribute_category ;
        l_index := v_application_names.NEXT(l_index);
    End Loop;
end if;

if x_error_code <> 100 then
    i := v_application_names.FIRST ;
    WHILE i IS NOT NULL LOOP

    if v_application_names(i) = 'ATTRIBUTE1' then
        if p_attribute1 is null then
            x_error_code   := 100;
            l_segment_name := 'ATTRIBUTE1';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE2' then
        if p_attribute2 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE2';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE3' then
        if p_attribute3 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE3';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE4' then
        if p_attribute4 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE4';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE5' then
        if p_attribute5 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE5';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE6' then
        if p_attribute6 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE6';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE7' then
        if p_attribute7 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE7';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE8' then
        if p_attribute8 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE8';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE9' then
        if p_attribute9 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE9';
        end if;  /*error here */
    end if;

    if v_application_names(i) = 'ATTRIBUTE10' then
        if p_attribute10 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE10';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE11' then
        if p_attribute11 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE11';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE12' then
        if p_attribute12 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE12';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE13' then
        if p_attribute13 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE13';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE14' then
        if p_attribute14 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE14';
        end if;
    end if;

    if v_application_names(i) = 'ATTRIBUTE15' then
        if p_attribute15 is null then
            x_error_code := 100;
            l_segment_name := 'ATTRIBUTE15';
        end if;
    end if;

    i := v_application_names.NEXT(i);
    END LOOP;
end if;


IF x_error_code = 100 THEN
    if p_calling_module = 'ADD_CLASS_CATEGORIES' then
       l_segment_name := null;   /* Added this code to throw the error message for self-service without reference to Application column name.*/
    end if;
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                         p_msg_name       => 'FLEX-MISSING SEGMENT VALUE',
                         p_token1         => 'SEGMENT',
                         p_value1         => l_segment_name,
                         p_token2         => 'FLEXFIELD',
                         p_value2         => p_flexfield_name);
--    x_msg_data := 'FLEX-MISSING SEGMENT VALUE';
    x_return_status := FND_API.G_RET_STS_ERROR ;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_UTILS',
                          p_procedure_name => 'VALIDATE_DFF',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
  raise;
END VALIDATE_DFF;

END PA_PROJECT_UTILS;

/
