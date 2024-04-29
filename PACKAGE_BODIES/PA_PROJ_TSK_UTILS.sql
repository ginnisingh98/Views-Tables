--------------------------------------------------------
--  DDL for Package Body PA_PROJ_TSK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_TSK_UTILS" as
-- $Header: PAXPTUTB.pls 120.8.12010000.2 2008/09/28 18:58:47 kjai ship $


--
--  FUNCTION
--              get_task_project_id
--  PURPOSE
--              This function retrieves the project id of a task.
--              If no project id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function get_task_project_id (x_task_id  IN number) return number
is
    cursor c1 is
	select project_id
	from pa_tasks
	where task_id = x_task_id;

    c1_rec c1%rowtype;

begin
	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
           close c1;
	   return( null);
	else
           close c1;
	   return( c1_rec.project_id );
        end if;

exception
   when others then
	return(SQLCODE);

end get_task_project_id;


--  FUNCTION
--	 	check_event_exists
--  PURPOSE
--	        This function returns 1 if event exists for project id or
--              task id and returns 0 if no event is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Event can exist at project and
--		top tasks level.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_event_exists (x_project_id  IN number
			   , x_task_id     IN number ) return number
is
	x_proj_id number;

	cursor c1 is
		select 1
		from sys.dual
		where exists (select event_num
		from pa_events
			where project_id = x_proj_id
			and (x_task_id is null or
			     task_id = x_task_id));

	c1_rec c1%rowtype;

begin
	if (x_task_id is null and x_project_id is null) then
		return(null);
	end if;

	if (x_task_id is not null ) then
	    x_proj_id := get_task_project_id(x_task_id);
        else
            x_proj_id := x_project_id;
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
        	return (SQLCODE);
end check_event_exists;


--  FUNCTION
--	 	check_exp_item_exists
--  PURPOSE
--		This function returns 1 if expenditure item exists for
--              a project or a task and returns 0 if no expenditure item
--		is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Expenditure items exist
--		at lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                              1. Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--                              2. Removed join to PA_TASKS in cursor c3
--                                 as task_id is a not null column in
--                                 pa_expenditures_all
--                              3. Added reference to pa_ei_denorm for
--                                 checking if expenditures exist
--
--   01-JAN-97	     T. Saifee     Modified
--      Condition project id = null incorporated into the task id = null
--      body. Bug 434421.
--   20-OCT-95      R. Chiu       Created
--
function check_exp_item_exists (x_project_id  IN number
	  		      , x_task_id     IN number
			      , x_check_subtasks IN boolean default TRUE)
				return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM    pa_expenditure_items_all i
                        WHERE   i.project_id = x_project_id)
                OR  EXISTS
                       (SELECT NULL
                        FROM    pa_ei_denorm e
                        WHERE   e.project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EXPENDITURE_ITEMS_all
                        WHERE  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID))
                or exists      (SELECT NULL
                        FROM    PA_EI_DENORM
                        WHERE   TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));
        cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EXPENDITURE_ITEMS_all
                        WHERE  TASK_ID = x_TASK_ID)
                or exists    (SELECT NULL
                        FROM   PA_EI_DENORM
                        WHERE  TASK_ID = x_TASK_ID);

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EXPENDITURE_ITEMS_all
                        WHERE  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));

        cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EXPENDITURE_ITEMS_all
                        WHERE  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
				WHERE TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
        c3_rec c3%rowtype;

begin
	if (x_task_id is null) then
	    if (x_project_id is null) then
		     return (null);
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
	elsif (x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_exp_item_exists;


--  FUNCTION
--	 	check_po_dist_exists
--  PURPOSE
--		This function returns 1 if purchase order distribution exists
--		for a project or a task and returns 0 if no purchase order
--		distribution is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Purchase order exists
--		at lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   28-JUN-07      prabsing       added encumbered_flag to where clause of c1, c2
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_po_dist_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE) -- Added for Performance Fix 4903460
			      return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM po_distributions_all
                        WHERE  project_id = x_project_id
                        AND    nvl(encumbered_flag,'N') = 'Y');    -- Bug 6153950: added encumbered_flag

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_distributions_all
                        where  project_id = x_proj_id
                        AND    nvl(encumbered_flag,'N') = 'Y'      -- Bug 6153950: added encumbered_flag
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
		SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_TASK_ID);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	-- Performance Fix 4903460 : By default this flag is TRUE
	elsif (x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
		fetch c3 into c3_rec;
		if c3%notfound then
			close c3;
			return(0);
		else
			close c3;
			return(1);
		end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_po_dist_exists;


--  FUNCTION
--	 	check_po_req_dist_exists
--  PURPOSE
--		This function returns 1 if purchase requisition exists
--		for a project or a task and returns 0 if no purchase
--		requisition is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Purchase requisition exists
--		at lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   28-JUN-07      prabsing       added encumbered_flag to where clause of c1, c2
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_po_req_dist_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			      ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM po_req_distributions_all
                        WHERE  project_id = x_project_id
                        AND    nvl(encumbered_flag,'N') = 'Y');    -- Bug 6153950: added encumbered_flag

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_req_distributions_all
                        where  project_id = x_proj_id
                        AND    nvl(encumbered_flag,'N') = 'Y'      -- Bug 6153950: added encumbered_flag
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_req_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   po_req_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_TASK_ID);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	-- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_po_req_dist_exists;


--  FUNCTION
--	 	check_ap_invoice_exists
--  PURPOSE
--		This function returns 1 if supplier invoice exists
--		for a project or a task and returns 0 if no supplier
--		invoice is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Supplier invoice exists
--		at lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_ap_invoice_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			      ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM ap_invoices_all
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoices_all
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoices_all
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoices_all
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_task_id);
	c3_rec c3%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	-- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_ap_invoice_exists;


--  FUNCTION
--	 	check_ap_inv_dist_exists
--  PURPOSE
--		This function returns 1 if supplier invoice distribution
--		exists for a project or a task and returns 0 if no supplier
--		invoice distribution is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Supplier invoice distribution
--		exists at lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   28-JUN-07      prabsing       added encumbered_flag to where clause of c1, c2
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_ap_inv_dist_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			        ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM ap_invoice_distributions_all
                        WHERE  project_id = x_project_id
                        AND    nvl(encumbered_flag,'N') = 'Y');      -- Bug 6153950: added encumbered_flag

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoice_distributions_all
                        where  project_id = x_proj_id
                        AND    nvl(encumbered_flag,'N') = 'Y'        -- Bug 6153950: added encumbered_flag
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoice_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   ap_invoice_distributions_all
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_TASK_ID);
	c3_rec c3%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	-- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_ap_inv_dist_exists;


--  FUNCTION
--	 	check_funding_exists
--  PURPOSE
--		This function returns 1 if funding exists for a project
--              or a task and returns 0 if no funding is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Funding can exist at project
--		and top task levels.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_funding_exists (x_project_id  IN number
	  		      , x_task_id     IN number ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_project_fundings
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM  pa_project_fundings
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_task_id);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_funding_exists;


--  FUNCTION
--              check_cdl_exists
--  PURPOSE
--              This function returns 1 if cost distribution lines exists
--		for a specified project or task and returns 0 if no
--		cost distribution line is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_cdl_exists (x_project_id  IN number
			 , x_task_id  IN number ) return number
is
        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT NULL
                FROM PA_EXPENDITURE_ITEMS_all PAI,
                     PA_COST_DISTRIBUTION_LINES_all PCD
                WHERE PAI.PROJECT_ID = x_PROJECT_ID
                AND PAI.EXPENDITURE_ITEM_ID = PCD.EXPENDITURE_ITEM_ID); -- Bug 3461664


        cursor c2 is
                select 1
                from sys.dual
                where exists (SELECT  NULL
                        FROM    PA_EXPENDITURE_ITEMS_all PAI,
                                PA_COST_DISTRIBUTION_LINES_all PCD
                        WHERE   PAI.EXPENDITURE_ITEM_ID
                                = PCD.EXPENDITURE_ITEM_ID
                        AND PAI.TASK_ID = x_TASK_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_cdl_exists;


--  FUNCTION
--              check_rdl_exists
--  PURPOSE
--              This function returns 1 if revenue distribution lines exists
--		for a specified project or task and returns 0 if no
--		revenue distribution line is found.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_rdl_exists (x_project_id  IN number
			 , x_task_id  IN number ) return number
is

        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT  NULL
                              FROM     pa_cust_rev_dist_lines rdl
                              where    rdl.project_id = x_project_id);

       cursor c2 is
                select 1
                from sys.dual
                where exists (SELECT  NULL
                      from pa_cust_rev_dist_lines rdl
                      ,    pa_expenditure_items i
                      where i.expenditure_item_id = rdl.expenditure_item_id
                      and i.task_id = x_task_Id);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_rdl_exists;


--  FUNCTION
--              check_erdl_exists
--  PURPOSE
--              This function returns 1 if event revenue distribution
-- 		lines exists for a specified project or task and returns 0
--		if no event revenue distribution line is found for project
--		or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  User can also pass in a
--		specific event number.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_erdl_exists (x_project_id  IN number
			 , x_task_id  IN number
			 , x_event_num IN number ) return number
is

	x_proj_id 	number;

        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT  NULL
                        FROM  pa_cust_event_rev_dist_lines
                        where   PROJECT_ID = x_PROJECT_ID
                        AND nvl(x_event_num, event_num) = event_num );

        cursor c2 is
                select 1
                from sys.dual
                where exists (SELECT  NULL
                        FROM  pa_cust_event_rev_dist_lines
                        where project_id = x_proj_id
                        AND TASK_ID = x_TASK_ID
                        AND nvl(x_event_num, event_num) = event_num );

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_erdl_exists;


--  FUNCTION
--	 	check_draft_inv_item_exists
--  PURPOSE
--		This function returns 1 if draft invoice item exists
--		for a project or a task and returns 0 if no draft
--		invoice item is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Draft invoice item can exist
--		at project or lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_draft_inv_item_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			      ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_draft_invoice_items
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_invoice_items
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR PARENT_TASK_ID = TASK_ID /* Bug 6511941 */
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_invoice_items
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_invoice_items
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_TASK_ID);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	-- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
		fetch c3 into c3_rec;
		if c3%notfound then
			close c3;
			return(0);
		else
			close c3;
			return(1);
		end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_draft_inv_item_exists;

--  FUNCTION
--    check_draft_inv_details_exists
--  PURPOSE
--    This function returns 1 if draft invoice details exists
--    for a task and returns 0 if no draft
--    invoice details is found for that task.
--
--    User can pass task id.Draft invoice details can exist
--    at lowest level tasks. If Oracle error occured,
--    Oracle error code is returned.
--
--  HISTORY
--   28-AUG-99      sbalasub       Created
--
function check_draft_inv_details_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
					)return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_invoice_details_all
                        where  CC_TAX_TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR PARENT_TASK_ID = TASK_ID /* Bug 6511941 */
                                START WITH TASK_ID = x_TASK_ID));

        c1_rec c1%rowtype;
	-- New cursor c2 added for Performance Fix 4903460
	cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_invoice_details_all
                        where  CC_TAX_TASK_ID = x_TASK_ID);
        c2_rec c2%rowtype;

begin

   if (x_task_id is null) then
      return(null);
   -- Performance Fix 4903460 : By default this flag is TRUE
   elsif(x_check_subtasks) then

	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
	   close c1;
	   return(0);
	else
	   close c1;
	   return(1);
	end if;
   else  -- Newly added for Performance Fix 4903460
	open c2;
	fetch c2 into c2_rec;
	if c2%notfound then
	   close c2;
	   return(0);
	else
	   close c2;
	   return(1);
	end if;
   end if;
exception
   when others then
      return(SQLCODE);
end check_draft_inv_details_exists;

--  FUNCTION
--    check_project_customer_exists
--  PURPOSE
--    This function returns 1 if project_customer_exists
--    for a task and returns 0 if no project_customer_exists
--    is found for that task.
--
--    User can pass task id. Project_customer_exists
--    at lowest level tasks. If Oracle error occured,
--    Oracle error code is returned.
--
--  HISTORY
--   28-AUG-99      sbalasub       Created
--
function check_project_customer_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
					) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_project_customers
                        where  receiver_task_id IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = X_TASK_ID));

        c1_rec c1%rowtype;
	-- New cursor c2 added for Performance Fix 4903460
	cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_project_customers
                        where  receiver_task_id = X_TASK_ID);
        c2_rec c2%rowtype;

begin

   if (x_task_id is null) then
      return(null);
   -- Performance Fix 4903460 : By default this flag is TRUE
   elsif(x_check_subtasks) then

   open c1;
   fetch c1 into c1_rec;
   if c1%notfound then
      close c1;
      return(0);
   else
      close c1;
      return(1);
   end if;

   else  -- Newly added for Performance Fix 4903460
	open c2;
	fetch c2 into c2_rec;
	if c2%notfound then
	   close c2;
	   return(0);
	else
	   close c2;
	   return(1);
	end if;
   end if;
exception
   when others then
      return(SQLCODE);
end check_project_customer_exists;

--  FUNCTION
--    check_projects_exists
--  PURPOSE
--    This function returns 1 if projects_exists
--    for a task and returns 0 if no projects_exists
--    is found for that task.
--
--    User can pass task id.projects can exist
--    at lowest level tasks. If Oracle error occured,
--    Oracle error code is returned.
--
--  HISTORY
--   28-AUG-99      sbalasub       Created
--   07-Feb-03      gjain          Bug 2784241: Modified the cursor c1
--				   for performance improvement
function check_projects_exists (x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
				)return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_projects_all          -- Modified pa_projects to pa_projects_all for bug#3512486
                        where  project_id = (select project_id from pa_tasks where task_id=X_TASK_ID)
			  and CC_TAX_TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = X_TASK_ID));

        c1_rec c1%rowtype;
	-- New cursor c2 added for Performance Fix 4903460
	x_proj_id NUMBER;
        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_projects_all
                        where  project_id = x_proj_id
			  and CC_TAX_TASK_ID = x_task_id);
	c2_rec c2%rowtype;

begin

   if (x_task_id is null) then
      return(null);
   else
	x_proj_id := get_task_project_id(x_task_id);
      -- Performance Fix 4903460 : By default this flag is TRUE
      if (x_check_subtasks) then
	   open c1;
	   fetch c1 into c1_rec;
	   if c1%notfound then
	      close c1;
	      return(0);
	   else
	      close c1;
	      return(1);
	   end if;
      else -- Newly added for Performance Fix 4903460
	   open c2;
	   fetch c2 into c2_rec;
	   if c2%notfound then
	      close c2;
	      return(0);
	   else
	      close c2;
	      return(1);
	   end if;
     end if;
   end if;
exception
   when others then
      return(SQLCODE);
end check_projects_exists;

--  FUNCTION
--	 	check_draft_rev_item_exists
--  PURPOSE
--		This function returns 1 if draft revenue item exists
--		for a project or a task and returns 0 if no draft
--		revenue item is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Draft revenue item can exist
--		at project or lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_draft_rev_item_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			      ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_draft_revenue_items
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_revenue_items
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR PARENT_TASK_ID = TASK_ID /* Bug 6511941 */
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_revenue_items
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_draft_revenue_items
                        where  project_id = x_proj_id
                        AND  TASK_ID =x_task_id);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

      -- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_draft_rev_item_exists;


--  FUNCTION
--	 	check_commitment_txn_exists
--  PURPOSE
--		This function returns 1 if commitment transaction exists
--		for a project or a task and returns 0 if no commitment
--		transaction is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  commitment transaction can
--		exist at project or lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_commitment_txn_exists (x_project_id  IN number
	  		      , x_task_id     IN number
                              , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
			      ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_commitment_txns
                        WHERE  project_id = x_project_id);

     cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_commitment_txns
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));


/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_commitment_txns
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
        cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_commitment_txns
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_TASK_ID);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
      -- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_commitment_txn_exists;


--  FUNCTION
--	 	check_comp_rule_set_exists
--  PURPOSE
--		This function returns 1 if compensation rule set exists
--		for a project or a task and returns 0 if no compensation
--		rule set is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Compensation rule set can
--		exist at project or lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_comp_rule_set_exists (x_project_id  IN number
	  		           , x_task_id     IN number
                                   , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
				   ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM  pa_comp_rule_ot_defaults_all -- Bug 4680097:  pa_compensation_rule_sets
                        WHERE  project_id = x_project_id)
                UNION
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_org_labor_sch_rule
                        WHERE  overtime_project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_comp_rule_ot_defaults_all -- Bug 4680097:  pa_compensation_rule_sets
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID))
                UNION
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_org_labor_sch_rule
                        where  overtime_project_id = x_proj_id
                        AND  overtime_TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_compensation_rule_sets
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
	cursor c3 is
                 SELECT 1
                 FROM   sys.dual
                 WHERE
                   exists (SELECT NULL
                             FROM   pa_comp_rule_ot_defaults_all
                             where  project_id = x_proj_id
                               AND  TASK_ID = x_task_id)
                  or exists (SELECT NULL
                             FROM   pa_org_labor_sch_rule
                             where  overtime_project_id = x_proj_id
                               AND  overtime_TASK_ID = x_task_id);
	c3_rec c3%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
        -- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_comp_rule_set_exists;


--  FUNCTION
--	 	check_asset_assignmt_exists
--  PURPOSE
--		This function returns 1 if asset assignment exists
--		for a specific project or task and returns 0 if no asset
--		assignment is found for that project or task.
--
--              Note that for a 'Common Cost' capital project/task function returns zero
--              since records would exist in pa_project_asset_assignment even
--              when there are assets without being assigne to specific proj or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.  Asset assignment can
--		exist at project or lowest level tasks.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   09-FEB-99       Ri.Singh      Modified.
--                                 Removed comments in cursor c2
--                                 done during bugfix 773604. CONNECT BY
--                                 clause is required for task deletion
--   20-OCT-95      R. Chiu       Created
--
function check_asset_assignmt_exists (x_project_id  IN number
	  		           , x_task_id     IN number
                                   , x_check_subtasks IN boolean default TRUE -- Added for Performance Fix 4903460
				   ) return number
is
	x_proj_id 	number;

        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE   EXISTS (SELECT NULL
                        FROM pa_project_asset_assignments
                        WHERE  project_id = x_project_id);

/*Added for bug 6063643*/
Cursor c2 is
         select 1 from pa_tasks
         where task_id = x_task_id
         and wbs_level > 1
         and exists (select null from pa_project_asset_assignments
                     where task_id = x_task_id
		     and project_asset_id <> 0); /* Added for bug 6245714 */

/*Commented for bug6063643

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_project_asset_assignments
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

commented for bug6063643*/

/*        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_project_asset_assignments
                        where  project_id = x_proj_id
                        AND  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                WHERE  TASK_ID = x_TASK_ID));
*/
        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

	-- New cursor c3 added for Performance Fix 4903460
        cursor c3 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM pa_project_asset_assignments
                        where  project_id = x_proj_id
                        AND  TASK_ID = x_task_id);
	c3_rec c3%rowtype;
begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is not null) then
		if x_project_id IS NULL THEN -- 4903460
			x_proj_id := get_task_project_id(x_task_id);
		else
			x_proj_id := x_project_id;
		END IF;
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
        -- Performance Fix 4903460 : By default this flag is TRUE
	elsif(x_check_subtasks) then
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	else -- Newly introduced for Performance Fix 4903460
		open c3;
                fetch c3 into c3_rec;
                if c3%notfound then
                   close c3;
                   return(0);
                else
                   close c3;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_asset_assignmt_exists;


--  FUNCTION
--	 	check_job_bill_rate_override
--  PURPOSE
--		This function returns 1 if job bill rate override exists
--		for a specific project or task and returns 0 if no
--		job bill rate override is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_bill_rate_override (x_project_id  IN number
	  		           , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_BILL_RATE_OVERRIDES
                        WHERE  project_id = x_project_id
                        and task_id is null);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_BILL_RATE_OVERRIDES
                        WHERE  TASK_ID = x_task_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_job_bill_rate_override;


--  FUNCTION
--	 	check_burden_sched_override
--  PURPOSE
--		This function returns 1 if burden schedule override exists
--		for a specific project or task and returns 0 if no
--		burden schedule override is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_burden_sched_override (x_project_id  IN number
	  		           , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_ind_rate_schedules
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_ind_rate_schedules
                        WHERE  TASK_ID = x_task_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_burden_sched_override;


--  FUNCTION
--	 	check_emp_bill_rate_override
--  PURPOSE
--		This function returns 1 if emp bill rate override exists
--		for a specific project or task and returns 0 if no
--		emp bill rate override is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--   05-SEP-02	    GJAIN	  For bug 2550288 changed cursor c2 to refer PA_EMP_BILL_RATE_OVERRIDES
--				  instead of PA_JOB_BILL_RATE_OVERRIDES
--
function check_emp_bill_rate_override (x_project_id  IN number
	  		           , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EMP_BILL_RATE_OVERRIDES
                        WHERE  project_id = x_project_id);

/* bug 2550288 changed below cursor to refer PA_EMP_BILL_RATE_OVERRIDES instead of PA_JOB_BILL_RATE_OVERRIDES */
        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_EMP_BILL_RATE_OVERRIDES
                        WHERE  TASK_ID = x_task_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;
	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
	end if;

exception
	when others then
		return(SQLCODE);
end check_emp_bill_rate_override;


--  FUNCTION
--	 	check_labor_multiplier
--  PURPOSE
--		This function returns 1 if labor multiplier exists
--		for a specific project or task and returns 0 if no
--		labor multiplier is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_labor_multiplier (x_project_id  IN number
	  		           , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_LABOR_MULTIPLIERS
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_LABOR_MULTIPLIERS
                        WHERE  TASK_ID = x_task_id);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;

begin
	if (x_project_id is null and x_task_id is null) then
		return(null);
	end if;

	if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

	else
		open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;

	end if;

exception
	when others then
		return(SQLCODE);
end check_labor_multiplier;


--  FUNCTION
--	 	check_transaction_control
--  PURPOSE
--		This function returns 1 if transaction control exists
--		for a specific project or task and returns 0 if no
--		transaction control is found for that project or task.
--
--	        User can pass either project id or task id.  If both
--		project id and task id are provided, function treated
--		as if only task were passed.
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_transaction_control (x_project_id  IN number
                                   , x_task_id     IN number ) return number
is
	task_project_id number;
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_TRANSACTION_CONTROLS
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_TRANSACTION_CONTROLS
                        WHERE  TASK_ID = x_task_ID
			AND    PROJECT_ID = task_project_id);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
begin
        if (x_project_id is null and x_task_id is null) then
                return(null);
        end if;

        if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

        else
		task_project_id :=
			pa_proj_tsk_utils.get_task_project_id(x_task_id);
		if (   (task_project_id < 0)
		    or (task_project_id is null)) then
		    return(null);
		end if;

                open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;

        end if;

exception
        when others then
                return(SQLCODE);
end check_transaction_control;


--  FUNCTION
--              check_nl_bill_rate_override
--  PURPOSE
--              This function returns 1 if non-labor bill rate override
--              exists for a specific project or task and returns 0 if no
--              non-labor bill rate override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_nl_bill_rate_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_NL_BILL_RATE_OVERRIDES
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_NL_BILL_RATE_OVERRIDES
                        WHERE  TASK_ID = x_task_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
begin
        if (x_project_id is null and x_task_id is null) then
                return(null);
        end if;

        if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

        else
                open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
        end if;

exception
        when others then
                return(SQLCODE);
end check_nl_bill_rate_override;

--  FUNCTION
--              check_job_bill_title_override
--  PURPOSE
--              This function returns 1 if job bill title override
--              exists for a specific project or task and returns 0 if no
--              job bill title override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_bill_title_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_BILL_TITLE_OVERRIDES
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_BILL_TITLE_OVERRIDES
                        WHERE  TASK_ID = x_task_ID);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
begin
        if (x_project_id is null and x_task_id is null) then
                return(null);
        end if;

        if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

        else
                open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;

        end if;

exception
        when others then
                return(SQLCODE);
end check_job_bill_title_override;


--  FUNCTION
--              check_job_assignmt_override
--  PURPOSE
--              This function returns 1 if job assignment override
--              exists for a specific project or task and returns 0 if no
--              job assignment override is found for that project or task.
--
--              User can pass either project id or task id.  If both
--              project id and task id are provided, function treated
--              as if only task were passed.
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_job_assignmt_override (x_project_id  IN number
                                   , x_task_id     IN number ) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_ASSIGNMENT_OVERRIDES
                        WHERE  project_id = x_project_id);

        cursor c2 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   PA_JOB_ASSIGNMENT_OVERRIDES
                        WHERE  TASK_ID = x_task_id);

        c1_rec c1%rowtype;
        c2_rec c2%rowtype;
begin
        if (x_project_id is null and x_task_id is null) then
                return(null);
        end if;

        if (x_task_id is null) then
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;
                   return(0);
                else
                   close c1;
                   return(1);
                end if;

        else
                open c2;
                fetch c2 into c2_rec;
                if c2%notfound then
                   close c2;
                   return(0);
                else
                   close c2;
                   return(1);
                end if;
        end if;

exception
        when others then
                return(SQLCODE);
end check_job_assignmt_override;

/* below function added for bug 2367945 */
FUNCTION check_iex_task_charged( x_task_id IN NUMBER) return NUMBER
is
x_exist NUMBER := 0;
l_task_cdate date;        /* Added for bug 4060239*/
begin
-- anlee
/* Commented out for bug 2790785
	select 1 into x_exist
	from dual
	where EXISTS (select * from ap_expense_report_lines_all a, ap_expense_report_headers_all b
		  		  where a.task_id = x_task_id
				    and a.REPORT_HEADER_ID = b.REPORT_HEADER_ID
					and b.source <> 'Oracle Project Accounting');
*/
/* Commented for bug 4060239
  -- Fix from bug 2790785
        SELECT 1 into x_exist
        FROM DUAL
        WHERE EXISTS (SELECT * FROM AP_EXPENSE_REPORT_LINES_ALL A, AP_EXPENSE_REPORT_HEADERS_ALL B
                                  WHERE A.TASK_ID = x_task_id
                                    AND A.REPORT_HEADER_ID = B.REPORT_HEADER_ID
                                    AND B.SOURCE <> 'Oracle Project Accounting'
                                    AND B.VOUCHNO = 0);
*/
-- Added for bug 4060239

/* fetch task creation_date into l_task_cdate */
/* start of bug 4060239 */
  select trunc(creation_date) into l_task_cdate
    from pa_tasks
   where task_id =  x_task_id;

/* Commented and modfied for Bug#5839405
       SELECT 1
         INTO x_exist
         FROM AP_EXPENSE_REPORT_LINES_ALL A,
              AP_EXPENSE_REPORT_HEADERS_ALL B
        WHERE A.TASK_ID = x_task_id
          AND A.REPORT_HEADER_ID = B.REPORT_HEADER_ID
	  AND A.CREATION_DATE >= l_task_cdate
          AND B.CREATION_DATE >= l_task_cdate
          AND B.SOURCE <> 'Oracle Project Accounting'
          AND B.VOUCHNO = 0
          AND rownum = 1;
*/

       SELECT 1
         INTO x_exist
         FROM AP_EXPENSE_REPORT_LINES_ALL A
        WHERE A.TASK_ID IS NOT NULL
	  AND A.TASK_ID = x_task_id
	  AND A.CREATION_DATE >= l_task_cdate
	  AND EXISTS ( SELECT 1 FROM AP_EXPENSE_REPORT_HEADERS_ALL B
              WHERE A.REPORT_HEADER_ID = B.REPORT_HEADER_ID
                AND B.CREATION_DATE >= l_task_cdate
                AND B.SOURCE <> 'Oracle Project Accounting'
                AND B.VOUCHNO = 0)
          AND rownum = 1;
/* Changes end for Bug#5839405 */

/* end of bug 4060239 */

	If x_exist = 1
	then
		return (1);
	else
		return(0);
	end if;
exception
        when others then
                return(SQLCODE);
end check_iex_task_charged;

END PA_PROJ_TSK_UTILS;

/
