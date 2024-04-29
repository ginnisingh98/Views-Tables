--------------------------------------------------------
--  DDL for Package Body PA_ASSET_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSET_ALLOCATION_PVT" AS
/* $Header: PACASALB.pls 120.4.12010000.2 2008/08/06 11:31:07 atshukla ship $ */

 l_mrc_flag        VARCHAR2(1) := paapimp_pkg.get_mrc_flag;
 PROCEDURE ALLOCATE_UNASSIGNED
	                       (p_project_asset_line_id     IN      NUMBER,
                           p_line_type                  IN      VARCHAR2,
                           p_capital_event_id           IN      NUMBER,
                           p_project_id                 IN      NUMBER,
                           p_task_id 	                IN	    NUMBER,
                           p_asset_allocation_method    IN      VARCHAR2,
			   p_asset_category_id          IN      NUMBER,  /* Added for bug#3211946 */
                           x_asset_or_project_err          OUT NOCOPY VARCHAR2,
                           x_error_code                    OUT NOCOPY VARCHAR2,
                           x_err_asset_id                  OUT NOCOPY NUMBER,
                           x_return_status                 OUT NOCOPY VARCHAR2,
                           x_msg_count                     OUT NOCOPY NUMBER,
                           x_msg_data                      OUT NOCOPY VARCHAR2) IS


    CURSOR all_project_assets_cur(x_line_type  VARCHAR2) IS
    SELECT  project_asset_id,
            0, --asset_basis_amount
            0  --total_basis_amount
    FROM    pa_project_assets_all
    WHERE   project_id = p_project_id
    AND     capital_event_id = p_capital_event_id
    AND     project_asset_type = DECODE(x_line_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT')
    AND     nvl(asset_category_id, -99) = nvl(p_asset_category_id, nvl(asset_category_id, -99))   /* Bug#3211946 */
    AND     capital_hold_flag = 'N';


    CURSOR project_asgn_assets_cur(x_line_type  VARCHAR2) IS
    SELECT  paa.project_asset_id,
            0, --asset_basis_amount
            0  --total_basis_amount
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_asset_id = paa.project_asset_id
    AND     pa.project_id = p_project_id
    AND     paa.project_id = p_project_id
    AND     pa.capital_event_id = p_capital_event_id
    AND     paa.task_id = 0
    AND     pa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT')
    AND     nvl(pa.asset_category_id, -99) = nvl(p_asset_category_id, nvl(pa.asset_category_id, -99))   /* Bug#3211946 */
    AND     pa.capital_hold_flag = 'N';


    CURSOR task_asgn_assets_cur(x_task_id  NUMBER, x_line_type  VARCHAR2) IS
    SELECT  paa.project_asset_id,
            0, --asset_basis_amount
            0  --total_basis_amount
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_asset_id = paa.project_asset_id
    AND     pa.project_id = p_project_id
    AND     paa.project_id = p_project_id
    AND     pa.capital_event_id = p_capital_event_id
    AND     paa.task_id = x_task_id
    AND     pa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT')
    AND     nvl(pa.asset_category_id, -99) = nvl(p_asset_category_id, nvl(pa.asset_category_id, -99))   /* Bug#3211946 */
    AND     pa.capital_hold_flag = 'N';


    v_top_task_id           NUMBER;

    CURSOR top_task_asgn_assets_cur(x_line_type  VARCHAR2) IS
    SELECT  paa.project_asset_id,
            0, --asset_basis_amount
            0  --total_basis_amount
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_asset_id = paa.project_asset_id
    AND     pa.project_id = p_project_id
    AND     paa.project_id = p_project_id
    AND     pa.capital_event_id = p_capital_event_id
    AND     paa.task_id = v_top_task_id
    AND     pa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT')
    AND     nvl(pa.asset_category_id, -99) = nvl(p_asset_category_id, nvl(pa.asset_category_id, -99))   /* Bug#3211946 */
    AND     pa.capital_hold_flag = 'N';


    CURSOR wbs_branch_tasks_cur(x_parent_task_id  NUMBER) IS
    SELECT  task_id,
            task_number
    FROM    pa_tasks
    WHERE   task_id <> x_parent_task_id
    AND     task_id <> p_task_id
    CONNECT BY parent_task_id = PRIOR task_id
    START WITH task_id = x_parent_task_id;

    wbs_branch_tasks_rec    wbs_branch_tasks_cur%ROWTYPE;



    asset_basis_table           PA_ASSET_ALLOCATION_PVT.ASSET_BASIS_TABLE_TYPE;

    v_common_project            VARCHAR2(1) := 'N';
    v_common_task               VARCHAR2(1) := 'N';
    v_common_lowest_task        VARCHAR2(1) := 'N';
    v_assignment_count          NUMBER := 0;
    i                           NUMBER := 1;
    v_return_status             VARCHAR2(1) := 'S';
    v_msg_count                 NUMBER := 0;
    v_msg_data                  VARCHAR2(2000);
    v_asset_count               NUMBER := 0;
    v_project_asset_id          NUMBER;
    v_project_asset_type        PA_PROJECT_ASSETS_ALL.project_asset_type%TYPE;
    v_date_placed_in_service    DATE;
    v_capital_hold_flag         PA_PROJECT_ASSETS_ALL.capital_hold_flag%TYPE;
    v_total_basis_amount        NUMBER := 0;
    v_asset_basis_amount        NUMBER := 0;
    v_init_total_basis_amount   NUMBER := 0;
    v_sum_asset_basis_amount    NUMBER := 0;
    v_project_asset_line_id     NUMBER;

    v_project_asset_line_detail_id NUMBER ; /*Bug 4914051*/
    v_rev_proj_asset_line_id	  NUMBER;

    v_src_project_asset_line_id NUMBER;
    v_project_id                NUMBER;
    v_parent_task_id            NUMBER;
    v_asset_units               NUMBER := 0;
    v_std_cost_count            NUMBER := 0;
    v_std_unit_cost             NUMBER := 0;
    v_asset_category_id         NUMBER;
    v_book_type_code            FA_BOOK_CONTROLS.book_type_code%TYPE;
    v_current_asset_cost        NUMBER := 0;
    v_current_cost              NUMBER := 0;
    v_original_asset_cost       NUMBER := 0;
    v_orig_cost			  NUMBER := 0;
    v_remaining_cost            NUMBER := 0;
    v_user                      NUMBER := FND_GLOBAL.user_id;
    v_login                     NUMBER := FND_GLOBAL.login_id;
    v_request_id                NUMBER := FND_GLOBAL.conc_request_id;
    v_program_application_id    NUMBER := FND_GLOBAL.prog_appl_id;
    v_program_id                NUMBER := FND_GLOBAL.conc_program_id;

    v_err_code                  NUMBER := 0;
    v_err_stage                 VARCHAR2(2000);

    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    no_assignments_exist            EXCEPTION;
    unexp_error_in_client_extn      EXCEPTION;
    error_in_client_extn            EXCEPTION;
    asset_not_on_project            EXCEPTION;
    asset_no_generation             EXCEPTION;
    asset_no_dpis                   EXCEPTION;
    asset_type_mismatch             EXCEPTION;
    null_asset_basis                EXCEPTION;
    negative_asset_basis            EXCEPTION;
    zero_total_basis                EXCEPTION;
    null_total_basis                EXCEPTION;
    negative_total_basis            EXCEPTION;
    inconsistent_total_basis        EXCEPTION;
    asset_basis_sum_error           EXCEPTION;
    standard_cost_not_found         EXCEPTION;
    error_calling_update_cost       EXCEPTION;

 BEGIN

    --Initialize variables
    x_return_status := 'S';
    x_msg_count := 0;
    x_asset_or_project_err := NULL;
    x_error_code := NULL;
    x_err_asset_id := 0;
    v_project_asset_line_id := p_project_asset_line_id;
    v_project_id := p_project_id;


    --If the Asset Allocation Method is 'N' for No Allocation,
    --then simply return and leave line UNASSIGNED
    IF NVL(p_asset_allocation_method,'N') = 'N' THEN
        RETURN;
    END IF;



    --Determine if the line is similar enough to the previous line that
    --the cached G_asset_basis_table can be used
    IF  p_project_id = G_project_id AND -- Fix for bug: 5091281
        p_task_id = G_task_id AND
        p_capital_event_id = G_capital_event_id AND
        p_asset_allocation_method = G_asset_allocation_method AND
        NVL(p_asset_category_id,-99) = NVL(G_asset_category_id,-99) AND --Added for bug 7175027
        p_asset_allocation_method <> 'CE' AND  --Do not use cache when the Client Extension is used to determine basis
        p_line_type = G_line_type THEN

        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG('Using cached Asset Allocation basis table for Project Asset Line ID '||p_project_asset_line_id);
	    END IF;

        asset_basis_table := G_asset_basis_table;
        GOTO allocate_line;
    END IF;


    --Construct the asset basis table
    IF PG_DEBUG = 'Y' THEN
	   PA_DEBUG.DEBUG('Constructing the Asset Allocation basis table for Project Asset Line ID '||p_project_asset_line_id);
	END IF;


    --Determine if entire project has a 'Common' Asset Assignment
    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    v_common_project
    FROM    pa_project_asset_assignments
    WHERE   project_id = p_project_id
    AND     task_id = 0
    AND     project_asset_id = 0;


    IF p_task_id <> 0 THEN

        IF PG_DEBUG = 'Y' THEN
	        PA_DEBUG.DEBUG('Get top and parent task ids for task id '||p_task_id);
        END IF;

        --Get the Top Task ID
        SELECT  top_task_id,
                parent_task_id
        INTO    v_top_task_id,
                v_parent_task_id
        FROM    pa_tasks
        WHERE   task_id = p_task_id;


        IF PG_DEBUG = 'Y' THEN
	        PA_DEBUG.DEBUG('Count top task common assignments');
	    END IF;

        --Determine if top task has a 'Common' Asset Assignment
        --('Common' Asset Assignments at the Top Task level are allocated across
        --ALL project assets, just like Project-level Common assignments)
        SELECT  DECODE(COUNT(*),0,'N','Y')
        INTO    v_common_task
        FROM    pa_project_asset_assignments
        WHERE   project_id = p_project_id
        AND     task_id = v_top_task_id
        AND     project_asset_id = 0;

        IF v_common_task = 'N' THEN
            --Determine if the current task has a Lowest Task Common assignment
            SELECT  DECODE(COUNT(*),0,'N','Y')
            INTO    v_common_lowest_task
            FROM    pa_project_asset_assignments
            WHERE   project_id = p_project_id
            AND     task_id = p_task_id
            AND     task_id <> v_top_task_id  --Only Lowest "Leaf" Tasks that are not also Top Tasks
            AND     project_asset_id = 0;
        END IF;

    END IF;


    --If there is a 'Common' asset assignment for a Lowest Task, then select
    --all assets that are assigned beneath the same Parent (not Top) Task.  For
    --example, if a Common assignment is made at task 2.1, the select any assets
    --assigned to 2.2, 2.3, 2.4.1, 2.4.2, 2.5, etc.  But do NOt select assets assigned
    --to task 3.0, 4.1, and so on, since they reside outside of the current WBS "branch".
    IF v_common_lowest_task = 'Y' THEN

        --Common Lowest Task Assignment
        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG('Lowest Task Common Assignment exists for Project Asset Line ID '||p_project_asset_line_id);
	    END IF;

        FOR wbs_branch_tasks_rec IN wbs_branch_tasks_cur(v_parent_task_id) LOOP

            IF PG_DEBUG = 'Y' THEN
	           PA_DEBUG.DEBUG('Task Number '||wbs_branch_tasks_rec.task_number||' exists beneath Parent Task ID '||v_parent_task_id);
	        END IF;

            --Populate table with all assets in the event assigned to the task
            OPEN task_asgn_assets_cur(wbs_branch_tasks_rec.task_id, p_line_type);
            LOOP
                FETCH task_asgn_assets_cur INTO asset_basis_table(i);
                EXIT WHEN task_asgn_assets_cur%NOTFOUND;
                i := i + 1;
            END LOOP;
            CLOSE task_asgn_assets_cur;

        END LOOP; --WBS Branch Tasks


    END IF; --Common Lowest "Leaf" Assignment



    --If there is a 'Common' asset assignment for the project or top task,
    --then select all assets on the project that belong to the current event,
    --regardless of asset assignment.
    IF (v_common_task = 'Y') OR (v_common_project = 'Y') THEN

        --Common Assignment
        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG('Project or Top Task Common Assignment exists for Project Asset Line ID '||p_project_asset_line_id);
	    END IF;

        OPEN all_project_assets_cur(p_line_type);
        LOOP
            FETCH all_project_assets_cur INTO asset_basis_table(i);
            EXIT WHEN all_project_assets_cur%NOTFOUND;
            i := i + 1;
        END LOOP;
        CLOSE all_project_assets_cur;

    ELSE --Determine the Grouping Level for the current asset line


        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG('Count project level asset assignments');
	    END IF;

        --Check for a project level grouping method
        SELECT  COUNT(*)
        INTO    v_assignment_count
        FROM    pa_project_asset_assignments paa
        WHERE   paa.project_id = p_project_id
        AND     paa.task_id = 0;


        IF v_assignment_count > 0 THEN

            --Project Assignment
            IF PG_DEBUG = 'Y' THEN
	          PA_DEBUG.DEBUG('Project Assignment(s) exist for Project Asset Line ID '||p_project_asset_line_id);
	        END IF;


            --Populate table with all assets in the event assigned to the project
            OPEN project_asgn_assets_cur(p_line_type);
            LOOP
                FETCH project_asgn_assets_cur INTO asset_basis_table(i);
                EXIT WHEN project_asgn_assets_cur%NOTFOUND;
                i := i + 1;
            END LOOP;
            CLOSE project_asgn_assets_cur;

        ELSIF p_task_id <> 0 THEN --Check for task level assignments

            IF PG_DEBUG = 'Y' THEN
	           PA_DEBUG.DEBUG('Count task level asset assignments for task id '||p_task_id);
	        END IF;

            --Check for a task level grouping method
            SELECT  COUNT(*)
            INTO    v_assignment_count
            FROM    pa_project_asset_assignments paa
            WHERE   paa.project_id = p_project_id
            AND     paa.task_id = p_task_id;

            IF v_assignment_count > 0 THEN

                --Task Assignment
                IF PG_DEBUG = 'Y' THEN
	               PA_DEBUG.DEBUG('Task Assignment(s) exist for Project Asset Line ID '||p_project_asset_line_id);
	            END IF;


                --Populate table with all assets in the event assigned to the task
                OPEN task_asgn_assets_cur(p_task_id, p_line_type);
                LOOP
                    FETCH task_asgn_assets_cur INTO asset_basis_table(i);
                    EXIT WHEN task_asgn_assets_cur%NOTFOUND;
                    i := i + 1;
                END LOOP;
                CLOSE task_asgn_assets_cur;

            ELSE --Check for a top task level grouping method

                IF PG_DEBUG = 'Y' THEN
	               PA_DEBUG.DEBUG('Count top task level asset assignments for top task id '||v_top_task_id);
	            END IF;

                SELECT  COUNT(*)
                INTO    v_assignment_count
                FROM    pa_project_asset_assignments paa
                WHERE   paa.project_id = p_project_id
                AND     paa.task_id = v_top_task_id;

                IF v_assignment_count > 0 THEN

                    --Top Task Assignment
                    IF PG_DEBUG = 'Y' THEN
                      PA_DEBUG.DEBUG('Top Task Assignment(s) exist for Project Asset Line ID '||p_project_asset_line_id);
	                END IF;


                    --Populate table with all assets in the event assigned to the top task
                    OPEN top_task_asgn_assets_cur(p_line_type);
                    LOOP
                        FETCH top_task_asgn_assets_cur INTO asset_basis_table(i);
                        EXIT WHEN top_task_asgn_assets_cur%NOTFOUND;
                        i := i + 1;
                    END LOOP;
                    CLOSE top_task_asgn_assets_cur;

                ELSE --No assignments exist, error and exit
                    RAISE no_assignments_exist;

                END IF;  --Top Task assignments

            END IF; --Task assignments

        END IF; --Project assignments

    END IF; --Common Task or Project vs. Grouping Level


    --If the Asset Allocation Method is 'CE' for Client Extension Basis,
    --then call the ASSET_ALLOC_BASIS client extension
    IF p_asset_allocation_method = 'CE' THEN

        --Call the client extension
        PA_CLIENT_EXTN_ASSET_ALLOC.ASSET_ALLOC_BASIS
                           (p_project_asset_line_id => v_project_asset_line_id,
                           p_project_id             => v_project_id,
                           p_asset_basis_table      => asset_basis_table,
                           x_return_status          => v_return_status,
                           x_msg_count              => v_msg_count,
                           x_msg_data               => v_msg_data);

        IF v_return_status = 'E' THEN
            RAISE error_in_client_extn;
        ELSIF v_return_status = 'U' THEN
            RAISE unexp_error_in_client_extn;
        END IF;
    END IF;



	IF PG_DEBUG = 'Y' THEN
	    PA_DEBUG.DEBUG('Initial Asset Allocation basis table for Project Asset Line ID '||p_project_asset_line_id||' Line Type '||p_line_type);
	    PA_DEBUG.DEBUG('Project Asset ID - Asset Basis - Total Basis');
    END IF;

    i := asset_basis_table.FIRST;

    WHILE i IS NOT NULL LOOP

        v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
        v_asset_basis_amount := asset_basis_table(i).ASSET_BASIS_AMOUNT;
        v_total_basis_amount := asset_basis_table(i).TOTAL_BASIS_AMOUNT;

        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG(v_project_asset_id||' - '||v_asset_basis_amount||' - '||v_total_basis_amount);
	    END IF;


        i := asset_basis_table.NEXT(i);
    END LOOP;



    --Perform preliminary validations on the resulting assets and basis amounts

    --NOTE: from here forward, use WHILE loops to process the asset_basis_table,
    --in case the user has deleted index rows from the table in the client extension


    --First, verify that there is at least one asset in the table
    v_asset_count := asset_basis_table.COUNT;

    IF v_asset_count = 0 THEN
        RETURN;
    END IF;


    --Verify that each project asset ID is valid for the project
    i := asset_basis_table.FIRST;

    WHILE i IS NOT NULL LOOP

        SELECT  COUNT(*)
        INTO    v_asset_count
        FROM    pa_project_assets_all pa
        WHERE   pa.project_id = p_project_id
        AND     pa.project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

        IF v_asset_count = 0 THEN

            v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
            RAISE asset_not_on_project;

        ELSIF v_asset_count = 1 THEN

            SELECT  project_asset_type,
                    date_placed_in_service,
                    capital_hold_flag
            INTO    v_project_asset_type,
                    v_date_placed_in_service,
                    v_capital_hold_flag
            FROM    pa_project_assets_all pa
            WHERE   pa.project_id = p_project_id
            AND     pa.project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

            --Verify that the DPIS is NOT NULL
            IF v_date_placed_in_service IS NULL THEN

                v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
                RAISE asset_no_dpis;

            END IF;


            --Verify that the asset is eligible for line generation
            IF NVL(v_capital_hold_flag,'N') = 'Y' THEN

                v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
                RAISE asset_no_generation;

            END IF;


            --Verify that the project asset type matches the line type
            IF p_line_type = 'C' AND v_project_asset_type <> 'AS-BUILT' THEN

                v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
                RAISE asset_type_mismatch;

            ELSIF p_line_type = 'R' AND v_project_asset_type <> 'RETIREMENT_ADJUSTMENT' THEN

                v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
                RAISE asset_type_mismatch;

            END IF;

        END IF;

	    i := asset_basis_table.NEXT(i);
    END LOOP;


    --If there is only asset in the table then skip the basis determination and assign asset line
    v_asset_count := asset_basis_table.COUNT;

    IF v_asset_count = 1 THEN

         i := asset_basis_table.FIRST;

	     IF PG_DEBUG = 'Y' THEN
	         PA_DEBUG.DEBUG('Only one asset in basis table, assigning Project Asset Line ID '||p_project_asset_line_id
                          ||' to Project Asset ID '||asset_basis_table(i).PROJECT_ASSET_ID);
	     END IF;


         --Assign current UNASSIGNED asset line to current project asset

         UPDATE  pa_project_asset_lines_all
         SET     project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID,
                    last_update_date = SYSDATE,
                    last_updated_by = v_user,
                    last_update_login = v_login,
                    request_id = v_request_id,
                    program_application_id = v_program_application_id,
                    program_id = v_program_id,
                    program_update_date = SYSDATE
         WHERE   project_asset_line_id = p_project_asset_line_id;

         --UPDATE Grouped CIP Cost on newly assigned project asset

         --Get the current asset cost of the UNASSIGNED asset line in order to determine the remaining amount
         SELECT  current_asset_cost
         INTO    v_current_asset_cost
         FROM    pa_project_asset_lines_all
         WHERE   project_asset_line_id = p_project_asset_line_id;

         --Call procedure to add this amount to the Grouped CIP Amount of the asset
         PA_FAXFACE.update_asset_cost
                 (asset_basis_table(i).PROJECT_ASSET_ID,
		          v_current_asset_cost,
		          0, --- capitalized_cost
                  v_err_stage,
                  v_err_code);

         IF v_err_code <> 0 THEN
             RAISE error_calling_update_cost;
         END IF;

         RETURN;
    END IF;



    --Populate the Basis Amounts according to the Asset Allocation Method specified


    --If the Asset Allocation Method is 'SE' for Spread Evenly,
    --then give each asset an equal basis amount
    IF p_asset_allocation_method = 'SE' THEN

        --Determine the Total Basis Amount
        v_total_basis_amount := asset_basis_table.COUNT;

        --Loop through each asset and assign the Total and Asset Basis Amounts
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

            --For Spread Evenly method, Asset Basis Amount = 1
            asset_basis_table(i).ASSET_BASIS_AMOUNT := 1;

            i := asset_basis_table.NEXT(i);
        END LOOP;
    END IF; -- 'SE' allocation method


    --If the Asset Allocation Method is 'AU' for Actual Units,
    --then use each asset's Actual Units as the basis amount
    IF p_asset_allocation_method = 'AU' THEN

        --Loop through each asset and assign the Asset Basis Amount and sum up the Total Basis Amount
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            v_asset_basis_amount := NULL;  --Initialize this to NULL in order to trap NULL units as an error

            --For Actual Units method, Asset Basis Amount = Actual Units
            SELECT  asset_units
            INTO    v_asset_basis_amount
            FROM    pa_project_assets_all
            WHERE   project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

            asset_basis_table(i).ASSET_BASIS_AMOUNT := v_asset_basis_amount;

            v_total_basis_amount := v_total_basis_amount + NVL(v_asset_basis_amount,0);

            i := asset_basis_table.NEXT(i);
        END LOOP;

        --Loop through each asset and assign the Total Basis Amounts
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

            i := asset_basis_table.NEXT(i);
        END LOOP;
    END IF; -- 'Q' allocation method


    --If the Asset Allocation Method is 'CC' for Current Asset Cost,
    --then use each asset's Grouped CIP Cost as the basis amount
    IF p_asset_allocation_method = 'CC' THEN

        --Determine the Total Basis Amount
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            --For Current Asset Cost method, Asset Basis Amount = Grouped CIP Cost
            v_asset_basis_amount := NULL;  --Initialize this to NULL in order to trap NULL units as an error

            SELECT  grouped_cip_cost
            INTO    v_asset_basis_amount
            FROM    pa_project_assets_all
            WHERE   project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

            asset_basis_table(i).ASSET_BASIS_AMOUNT := v_asset_basis_amount;

            v_total_basis_amount := v_total_basis_amount + NVL(v_asset_basis_amount,0);

            i := asset_basis_table.NEXT(i);
        END LOOP;

        --Loop through each asset and assign the Total and Asset Basis Amounts
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

            i := asset_basis_table.NEXT(i);
        END LOOP;
    END IF; -- 'CC' allocation method



    --If the Asset Allocation Method is 'EC' for Estimated Cost,
    --then use each asset's Estimated Cost as the basis amount
    IF p_asset_allocation_method = 'EC' THEN

        --Determine the Total Basis Amount
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            --For Estimated Cost method, Asset Basis Amount = Estimated Cost
            v_asset_basis_amount := NULL;  --Initialize this to NULL in order to trap NULL units as an error

            SELECT  estimated_cost
            INTO    v_asset_basis_amount
            FROM    pa_project_assets_all
            WHERE   project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

            asset_basis_table(i).ASSET_BASIS_AMOUNT := v_asset_basis_amount;

            v_total_basis_amount := v_total_basis_amount + NVL(v_asset_basis_amount,0);

            i := asset_basis_table.NEXT(i);
        END LOOP;

        --Loop through each asset and assign the Total and Asset Basis Amounts
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

            i := asset_basis_table.NEXT(i);
        END LOOP;
    END IF; -- 'EC' allocation method


    --If the Asset Allocation Method is 'SC' for Standard Cost,
    --then use each asset's Standard Cost * Actual Units as the basis amount
    IF p_asset_allocation_method = 'SC' THEN

        --Determine the Total Basis Amount
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;

            --For Standard Cost method, Asset Basis Amount = Standard Cost * Actual Units
            v_asset_basis_amount := 0;

            SELECT  NVL(asset_units,0),
                    NVL(asset_category_id,-99),
                    NVL(book_type_code,'X')
            INTO    v_asset_units,
                    v_asset_category_id,
                    v_book_type_code
            FROM    pa_project_assets_all
            WHERE   project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID;

            SELECT  COUNT(*)
            INTO    v_std_cost_count
            FROM    pa_standard_unit_costs
            WHERE   asset_category_id = v_asset_category_id
            AND     book_type_code = v_book_type_code;

            IF v_std_cost_count = 0 THEN
                RAISE standard_cost_not_found;
            ELSE
                SELECT  standard_unit_cost
                INTO    v_std_unit_cost
                FROM    pa_standard_unit_costs
                WHERE   asset_category_id = v_asset_category_id
                AND     book_type_code = v_book_type_code;
            END IF;

            v_asset_basis_amount := v_std_unit_cost * v_asset_units;

            asset_basis_table(i).ASSET_BASIS_AMOUNT := v_asset_basis_amount;

            v_total_basis_amount := v_total_basis_amount + v_asset_basis_amount;

            i := asset_basis_table.NEXT(i);
        END LOOP;

        --Loop through each asset and assign the Total and Asset Basis Amounts
        i := asset_basis_table.FIRST;

        WHILE i IS NOT NULL LOOP

            asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

            i := asset_basis_table.NEXT(i);
        END LOOP;
    END IF; -- 'SC' allocation method



    --Perform final validations on the resulting assets and basis amounts
    i := asset_basis_table.FIRST;
    v_init_total_basis_amount := asset_basis_table(i).TOTAL_BASIS_AMOUNT;
    v_sum_asset_basis_amount := 0;

    --DBMS_OUTPUT.PUT_LINE('Asset Allocation basis table for Project Asset Line ID '||p_project_asset_line_id);
    --DBMS_OUTPUT.PUT_LINE('Project Asset ID - Asset Basis - Total Basis');
	IF PG_DEBUG = 'Y' THEN
	    PA_DEBUG.DEBUG('Asset Allocation basis table for Project Asset Line ID '||p_project_asset_line_id);
	    PA_DEBUG.DEBUG('Project Asset ID - Asset Basis - Total Basis');
    END IF;

    i := asset_basis_table.FIRST;

    WHILE i IS NOT NULL LOOP

        v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;
        v_asset_basis_amount := asset_basis_table(i).ASSET_BASIS_AMOUNT;
        v_total_basis_amount := asset_basis_table(i).TOTAL_BASIS_AMOUNT;
        v_sum_asset_basis_amount := v_sum_asset_basis_amount + v_asset_basis_amount;

        --DBMS_OUTPUT.PUT_LINE(v_project_asset_id||' - '||v_asset_basis_amount||' - '||v_total_basis_amount);
        IF PG_DEBUG = 'Y' THEN
	       PA_DEBUG.DEBUG(v_project_asset_id||' - '||v_asset_basis_amount||' - '||v_total_basis_amount);
	    END IF;

        --Verify that each Asset Basis Amount is NOT NULL and >=0
        IF v_asset_basis_amount IS NULL THEN
            RAISE null_asset_basis;
        ELSIF v_asset_basis_amount < 0 THEN
            RAISE negative_asset_basis;
        END IF;


        --Validate that the total basis amount is not ZERO or negative or NULL
        IF v_total_basis_amount = 0 THEN
            RAISE zero_total_basis;
        ELSIF v_total_basis_amount < 0 THEN
            RAISE negative_total_basis;
        ELSIF v_total_basis_amount IS NULL THEN
            RAISE null_total_basis;
        END IF;


        --Verify that the Total Basis Amount is the same on each row
        IF v_total_basis_amount <> v_init_total_basis_amount THEN
            RAISE inconsistent_total_basis;
        END IF;

        i := asset_basis_table.NEXT(i);
    END LOOP;


    --Verify that the Total Basis Amount equals the sum of the Asset Basis Amounts
    IF v_sum_asset_basis_amount <> v_total_basis_amount THEN
        RAISE asset_basis_sum_error;
    END IF;


    --Validations are complete.  Store values in Globals so that subsequent lines
    --may use the cached value, if appropriate.

    G_project_id := p_project_id;  -- 5091281
    G_task_id := p_task_id;
    G_capital_event_id := p_capital_event_id;
    G_asset_allocation_method := p_asset_allocation_method;
    G_asset_category_id := p_asset_category_id;  --Added for bug 7175027
    G_line_type := p_line_type;
    G_asset_basis_table := asset_basis_table;


    --Use of cached table will begin here
    <<allocate_line>>

    --Get the original Asset Line Amount
    --Get CURRENT and not original cost, in case the user has previously done a manual split on the line
    --This program will allocate the current cost of any UNASSIGNED lines across project assets
    SELECT  current_asset_cost --NOT original_asset_cost, in case of prior manual splits
    INTO    v_original_asset_cost
    FROM    pa_project_asset_lines_all
    WHERE   project_asset_line_id = p_project_asset_line_id;

    --Initialize allocation variables
    v_project_asset_line_id := p_project_asset_line_id;
    v_current_cost := 0;
    v_remaining_cost:= 0;


    IF PG_DEBUG = 'Y' THEN
	    PA_DEBUG.DEBUG('Allocating project asset line '|| v_project_asset_line_id);
    END IF;

    --Allocate the current asset line and assign to each project asset
    i := asset_basis_table.FIRST;

    WHILE i IS NOT NULL LOOP

        v_project_asset_id := asset_basis_table(i).PROJECT_ASSET_ID;

        IF i = asset_basis_table.LAST THEN

            --Assign current UNASSIGNED asset line to current project asset

            UPDATE  pa_project_asset_lines_all
            SET     project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID,
                    last_update_date = SYSDATE,
                    last_updated_by = v_user,
                    last_update_login = v_login,
                    request_id = v_request_id,
                    program_application_id = v_program_application_id,
                    program_id = v_program_id,
                    program_update_date = SYSDATE
            WHERE   project_asset_line_id = v_project_asset_line_id;


            --UPDATE Grouped CIP Cost on newly assigned project asset

            --Get the current asset cost of the UNASSIGNED asset line in order to determine the remaining amount
            SELECT  current_asset_cost
            INTO    v_current_asset_cost
            FROM    pa_project_asset_lines_all
            WHERE   project_asset_line_id = v_project_asset_line_id;

            --Call procedure to add this amount to the Grouped CIP Amount of the asset
            PA_FAXFACE.update_asset_cost
                 (asset_basis_table(i).PROJECT_ASSET_ID,
		          v_current_asset_cost,
		          0, --- capitalized_cost
                  v_err_stage,
                  v_err_code);

            IF v_err_code <> 0 THEN
                RAISE error_calling_update_cost;
            END IF;

        ELSIF asset_basis_table(i).ASSET_BASIS_AMOUNT <> 0 THEN
            --Update the Current Asset Cost on the UNASSIGNED asset line, and assign
            --the UNASSIGNED line to the current project asset.  Then create a new
            --UNASSIGNED line with the same Original Asset Cost and the Current Asset
            --Cost equal to the remainder.

            --When asset basis is zero, do nothing and move on to the next project asset


            --Calculate the allocated cost amount
            v_current_cost := ROUND(v_original_asset_cost *
                    (asset_basis_table(i).ASSET_BASIS_AMOUNT/asset_basis_table(i).TOTAL_BASIS_AMOUNT),2);


            --Get the current asset cost of the UNASSIGNED asset line in order to determine the remaining amount
		  SELECT  current_asset_cost, project_asset_line_detail_id, rev_proj_asset_line_id, original_asset_cost   /*Bug 4914051*/
            INTO    v_current_asset_cost,  v_project_asset_line_detail_id, v_rev_proj_asset_line_id, v_orig_cost
            FROM    pa_project_asset_lines_all
            WHERE   project_asset_line_id = v_project_asset_line_id;


            --Calculate the remaining amount
            v_remaining_cost := v_current_asset_cost - v_current_cost;


            --Update current UNASSIGNED asset line
            UPDATE  pa_project_asset_lines_all
            SET     project_asset_id = asset_basis_table(i).PROJECT_ASSET_ID,
                    current_asset_cost = v_current_cost,
                    last_update_date = SYSDATE,
                    last_updated_by = v_user,
                    last_update_login = v_login,
                    request_id = v_request_id,
                    program_application_id = v_program_application_id,
                    program_id = v_program_id,
                    program_update_date = SYSDATE
            WHERE   project_asset_line_id = v_project_asset_line_id;
		  IF l_mrc_flag = 'Y' THEN /*Bug 4914051*/
				PA_FAXFACE.update_alc_proj_asset_lines(v_project_asset_line_id, v_orig_cost,
				v_current_cost);
		  END IF;


            --UPDATE Grouped CIP Cost on newly assigned project asset

            --Call procedure to add this amount to the Grouped CIP Amount of the asset
            PA_FAXFACE.update_asset_cost
                 (asset_basis_table(i).PROJECT_ASSET_ID,
		          v_current_cost,
		          0, --- capitalized_cost
                  v_err_stage,
                  v_err_code);

            IF v_err_code <> 0 THEN
                RAISE error_calling_update_cost;
            END IF;

            v_src_project_asset_line_id := v_project_asset_line_id;

            --Get the Sequence ID of the new asset line
            SELECT  pa_project_asset_lines_s.NEXTVAL
            INTO    v_project_asset_line_id
            FROM    SYS.DUAL;


            --Create new UNASSIGNED asset line
            INSERT INTO pa_project_asset_lines_all(
               project_asset_line_id,
               description,
               project_asset_id,
               project_id,
               task_id,
               cip_ccid,
               asset_cost_ccid,
               original_asset_cost,
               current_asset_cost,
               project_asset_line_detail_id,
               gl_date,
               transfer_status_code,
	           transfer_rejection_reason,
               amortize_flag,
               asset_category_id,
               last_update_date,
               last_updated_by,
               created_by,
               creation_date,
	           last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date,
               rev_proj_asset_line_id,
	           rev_from_proj_asset_line_id,
               org_id,
               invoice_number,
               vendor_number,
               po_vendor_id,
               po_number,
               invoice_date,
               invoice_created_by,
               invoice_updated_by,
               invoice_id,
               payables_batch_name,
               ap_distribution_line_number,
               original_asset_id,
               line_type,
               capital_event_id,
               retirement_cost_type
               )
            SELECT
               v_project_asset_line_id,
               pal_rec.description,
               0, --project_asset_id
               pal_rec.project_id,
               pal_rec.task_id,
               pal_rec.cip_ccid,
               pal_rec.asset_cost_ccid,
               pal_rec.original_asset_cost,
               v_remaining_cost,
               pal_rec.project_asset_line_detail_id,
               pal_rec.gl_date,
               pal_rec.transfer_status_code,
	           pal_rec.transfer_rejection_reason,
               pal_rec.amortize_flag,
               pal_rec.asset_category_id,
               SYSDATE, --last_update_date
               v_user, --last_updated_by
               v_user, --created_by
               SYSDATE, --creation_date
	           v_login,
               v_request_id,
               v_program_application_id,
               v_program_id,
               SYSDATE, --program_update_date
               pal_rec.rev_proj_asset_line_id,
	           pal_rec.rev_from_proj_asset_line_id,
               pal_rec.org_id,
               pal_rec.invoice_number,
               pal_rec.vendor_number,
               pal_rec.po_vendor_id,
               pal_rec.po_number,
               pal_rec.invoice_date,
               pal_rec.invoice_created_by,
               pal_rec.invoice_updated_by,
               pal_rec.invoice_id,
               pal_rec.payables_batch_name,
               pal_rec.ap_distribution_line_number,
               pal_rec.original_asset_id,
               pal_rec.line_type,
               pal_rec.capital_event_id,
               pal_rec.retirement_cost_type
            FROM    pa_project_asset_lines_all pal_rec
            WHERE   project_asset_line_id = v_src_project_asset_line_id;

		  IF l_mrc_flag = 'Y' THEN   /*Bug 4914051*/
			    PA_FAXFACE.create_alc_proj_asset_lines	(v_project_asset_line_id,
					 v_project_asset_line_detail_id,
					 v_rev_proj_asset_line_id,
					 v_orig_cost,
					 v_remaining_cost,
					 v_err_stage,
					 v_err_code);
		  END IF;

        END IF; --Last project asset ID or not

        i := asset_basis_table.NEXT(i);
    END LOOP;  --Allocate UNASSIGNED lines




 EXCEPTION


    WHEN no_assignments_exist THEN
        x_msg_data := 'No asset assignments exist for project id '||p_project_id;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'NO_ASSIGNMENTS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN error_in_client_extn THEN
        x_msg_data := v_msg_data;
        --x_msg_data := 'Error in ASSET_ALLOC_BASIS client extension for project id '||p_project_id;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'ASSET_ALLOC_BASIS_EXTN';
        x_return_status := 'E';
        x_msg_count := v_msg_count;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN unexp_error_in_client_extn THEN
        x_msg_data := v_msg_data;
        --x_msg_data := 'Unexpected error in ASSET_ALLOC_BASIS client extension for project id '||p_project_id;
        x_return_status := 'U';
        x_msg_count := v_msg_count;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        ROLLBACK;
        RAISE;


    WHEN asset_not_on_project THEN
        x_msg_data := 'Project asset id '||v_project_asset_id||' not valid for project id '||p_project_id;
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'ASSET_INVALID_FOR_PROJECT';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN asset_no_generation THEN
        x_msg_data := 'Project asset id '||v_project_asset_id||' is not eligible for asset line generation';
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'ASSET_NO_GENERATION';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN asset_no_dpis THEN
        x_msg_data := 'Project asset id '||v_project_asset_id||' does not have an asset date specified';
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'ASSET_NO_DPIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN asset_type_mismatch THEN
        x_msg_data := 'Project asset id '||v_project_asset_id||' is not valid for line type '||p_line_type;
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'ASSET_TYPE_MISMATCH';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN zero_total_basis THEN
        x_msg_data := 'Total basis is ZERO for project id '||p_project_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'ZERO_TOTAL_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        x_return_status := 'E';
        RETURN;


    WHEN negative_total_basis THEN
        x_msg_data := 'Total basis is negative for project id '||p_project_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'NEGATIVE_TOTAL_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN null_total_basis THEN
        x_msg_data := 'Total basis is NULL for project id '||p_project_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'NULL_TOTAL_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN null_asset_basis THEN
        x_msg_data := 'Asset basis is NULL for project asset id '||v_project_asset_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'NULL_ASSET_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        x_return_status := 'E';
        RETURN;


    WHEN negative_asset_basis THEN
        x_msg_data := 'Asset basis is negative for project asset id '||v_project_asset_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'NEGATIVE_ASSET_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN inconsistent_total_basis THEN
        x_msg_data := 'Total basis is inconsistent for project id '||p_project_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'INCONSISTENT_TOTAL_BASIS';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        x_return_status := 'E';
        RETURN;


    WHEN asset_basis_sum_error THEN
        x_msg_data := 'Asset basis does not sum to Total basis for project id '||p_project_id||' using method '||p_asset_allocation_method;
        x_asset_or_project_err := 'P';
        x_err_asset_id := 0;
        x_error_code := 'ASSET_BASIS_SUM';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN standard_cost_not_found THEN
        x_msg_data := 'Standard Cost not found for project asset id '||v_project_asset_id;
        x_asset_or_project_err := 'A';
        x_err_asset_id := v_project_asset_id;
        x_error_code := 'STANDARD_COST_MISSING';
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;


    WHEN error_calling_update_cost THEN
        x_return_status := 'U';
        x_msg_count := x_msg_count + 1;
        x_msg_data := v_err_code||' Error calling update_asset_cost for project asset id '||v_project_asset_id||' '||SQLERRM;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        ROLLBACK;
        RAISE;


    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'Unexpected '||SQLCODE||' '||SQLERRM||' in ALLOCATE_UNASSIGNED for PROJECT ID: '||p_project_id;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_ASSET_ALLOCATION_PVT',
                                p_procedure_name => 'ALLOCATE_UNASSIGNED',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        ROLLBACK;
        RAISE;

 END ALLOCATE_UNASSIGNED;


END PA_ASSET_ALLOCATION_PVT;

/
