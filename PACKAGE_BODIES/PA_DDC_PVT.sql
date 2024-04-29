--------------------------------------------------------
--  DDL for Package Body PA_DDC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DDC_PVT" AS
--$Header: PAXUDDCB.pls 120.1 2005/08/19 17:21:56 mwasowic noship $

-- ----------------------------------------------------
-- FORWARD DECLARATION
-- ----------------------------------------------------

FUNCTION Check_Alias (x_alias         IN VARCHAR2
                      , x_folder_code IN VARCHAR2
                      )     RETURN VARCHAR2;


-- ----------------------------------------------------
-- PROCEDURES
-- ----------------------------------------------------


--
-- Name:		Create_View_DDL
-- Type:		PL/SQL Procedure
--
-- Description:	        This is the main view generation procedure for
--                      Project Status Columns.
--
-- Note:
--                      This package assumes that the appropriate Apps environment
--                      globals have been instantiated before running this procedure.
--
--			!!! The AD_DDL.DO_DDL API call does an implicit COMMIT !!!
--
--
--
-- Called Subprograms:  AD_DDL.DO_DDL
--
-- History:
--    31-OCT-2001	jwhite      Created.
--

PROCEDURE Create_View_DDL
(p_view_name    		IN	VARCHAR2
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS


   l_api_name		CONSTANT VARCHAR2(30)	:= 'Create_View_DDL';

   l_ddl_stmt           VARCHAR2(7000) := NULL;
   l_stmt               VARCHAR2(5000) := NULL;
   l_from_clause        VARCHAR2(1000) := NULL;
   l_where_clause       VARCHAR2(1000) := NULL;

   l_applsys            VARCHAR2(80) := NULL;
   l_status             VARCHAR2(1);
   l_industry           VARCHAR2(1);
   l_return             BOOLEAN;


    CURSOR proj_csr IS
                SELECT format_code, column_name, currency_format_flag
                FROM
                pa_status_column_setup
                WHERE folder_code = 'P'
                order by folder_code, format_code, column_order;

    CURSOR task_csr IS
                SELECT format_code, column_name, currency_format_flag
                FROM pa_status_column_setup
                WHERE folder_code = 'T'
                order by folder_code, format_code, column_order;

     CURSOR rsrc_csr IS
                SELECT format_code, column_name, currency_format_flag
                FROM pa_status_column_setup
                WHERE folder_code = 'R'
                order by folder_code, format_code, column_order;


BEGIN



           x_return_status := FND_API.G_RET_STS_SUCCESS;


--
-- Build SQL Strings by View ------------------------------------
--

IF (p_view_name = 'PA_STATUS_PROJ_GENERIC_V')
   THEN
    -- Project Status Base View ----------------------------------

    -- SELECT: First Part --------------------------

     l_ddl_stmt := 'CREATE OR REPLACE  FORCE VIEW   PA_STATUS_PROJ_GENERIC_V
(       PROJECT_ID
        , VIEW_LABOR_COSTS_ALLOWED
        , COST_BUDGET_TYPE_CODE
        , REV_BUDGET_TYPE_CODE
        , COLUMN1
        , COLUMN2
        , COLUMN3
        , COLUMN4
        , COLUMN5
        , COLUMN6
        , COLUMN7
        , COLUMN8
        , COLUMN9
        , COLUMN10
        , COLUMN11
        , COLUMN12
        , COLUMN13
        , COLUMN14
        , COLUMN15
        , COLUMN16
        , COLUMN17
        , COLUMN18
        , COLUMN19
        , COLUMN20
        , COLUMN21
        , COLUMN22
        , COLUMN23
        , COLUMN24
        , COLUMN25
        , COLUMN26
        , COLUMN27
        , COLUMN28
        , COLUMN29
        , COLUMN30
        , COLUMN31
        , COLUMN32
        , COLUMN33
)  as SELECT
        p.project_id
        , SUBSTR(pa_security.view_labor_costs(p.project_id),1,1)
        , c.budget_type_code
        , r.budget_type_code';

        -- FROM_CLAUSE: ------------------------------------------

        l_from_clause := 'pa_projects p,pa_project_accum_headers pah,pa_status_proj_bgt_rev_v r,pa_status_proj_bgt_cost_v c';

        -- WHERE_CLAUSE: -----------------------------------------

l_where_clause := '''Y'''||' in (SELECT pa_security.allow_query(p.project_id) from sys.dual) AND p.project_id = pah.project_id AND pah.task_id = 0 AND pah.resource_list_id = 0
 AND pah.project_id = r.project_id AND pah.project_id = c.project_id';

       -- Append Basic From- and Where-Clauses as Required -------------------

        -- Actuals
        IF (Check_Alias('A.','P') = 'Y')
            THEN

                l_from_clause := l_from_clause||',pa_project_accum_actuals a';

                l_where_clause := l_where_clause||' AND pah.project_accum_id = a.project_accum_id (+)';

        END IF;

        -- Commitments
        IF (Check_Alias('M.','P') = 'Y')
           THEN

                l_from_clause := l_from_clause||',pa_project_accum_commitments m';

                l_where_clause := l_where_clause||' AND pah.project_accum_id = m.project_accum_id (+)';

        END IF;

        -- SELECT: Last Part -------------------------------------

        FOR proj_csrrec IN proj_csr LOOP
                IF (proj_csrrec.format_code = 'C')
                   THEN
                   -- Character Column

                        IF (proj_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',null';
                        ELSE
                               l_stmt :=l_stmt||','||proj_csrrec.column_name;
                        END IF;
                ELSE
                -- Numeric Column
                        IF (proj_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',0';
                        ELSE
                          IF (proj_csrrec.currency_format_flag IS NULL) THEN
                               l_stmt :=l_stmt||','||proj_csrrec.column_name;
                          ELSE
                               l_stmt := l_stmt||',('||proj_csrrec.column_name||')/(PA_STATUS.Get_factor)';
                          END IF;
                        END IF;
                END IF;
        END LOOP;


ELSIF (p_view_name = 'PA_STATUS_TASK_GENERIC_V')
     THEN

     -- Task Status Base View -------------------------------------------

     -- SELECT: First Part -------------------


l_ddl_stmt := 'CREATE OR REPLACE  FORCE VIEW   PA_STATUS_TASK_GENERIC_V
(       PROJECT_ID
        , TASK_ID
        , PARENT_TASK_ID
        , WBS_LEVEL
        , COST_BUDGET_TYPE_CODE
        , REV_BUDGET_TYPE_CODE
        , CHILD_EXIST_FLAG
        , COLUMN1
        , COLUMN2
        , COLUMN3
        , COLUMN4
        , COLUMN5
        , COLUMN6
        , COLUMN7
        , COLUMN8
        , COLUMN9
        , COLUMN10
        , COLUMN11
        , COLUMN12
        , COLUMN13
        , COLUMN14
        , COLUMN15
        , COLUMN16
        , COLUMN17
        , COLUMN18
        , COLUMN19
        , COLUMN20
        , COLUMN21
        , COLUMN22
        , COLUMN23
        , COLUMN24
        , COLUMN25
        , COLUMN26
        , COLUMN27
        , COLUMN28
        , COLUMN29
        , COLUMN30
        , COLUMN31
        , COLUMN32
        , COLUMN33
)  as SELECT
      t.project_id
        , t.task_id
        , t.parent_task_id
        , t.wbs_level
        , c.budget_type_code
        , r.budget_type_code
        , decode(pa_task_utils.check_child_exists(t.task_id),1,
         ''+'' ,0,'' '' )  ';


        -- FROM_CLAUSE: ----------------------

        l_from_clause := 'pa_tasks t,pa_status_task_bgt_cost_high_v c,pa_status_task_bgt_rev_high_v r';

        -- WHERE_CLAUSE: ----------------------

l_where_clause :='t.project_id = PA_STATUS.GetProjId AND t.task_id = c.task_id (+) AND t.task_id = r.task_id (+)';

        -- Append Basic From- and Where-Clauses as Required -------------------

        -- Actuals
        IF (Check_Alias('A.','T') = 'Y') THEN

                l_from_clause := l_from_clause||', pa_status_task_act_v a';

                l_where_clause := l_where_clause||' AND t.task_id = a.task_id (+)';

        END IF;

        -- Commitments
        IF (Check_Alias('M.','T') = 'Y') THEN

                l_from_clause := l_from_clause||', pa_status_task_cmt_v  m';

                l_where_clause := l_where_clause||' AND t.task_id = m.task_id (+)';

        END IF;

        -- SELECT: Last Part -----------------------------------------

        FOR task_csrrec IN task_csr LOOP
                IF (task_csrrec.format_code = 'C')
                   THEN
                    -- Character Column
                        IF (task_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',null';
                        ELSE
                               l_stmt :=l_stmt||','||task_csrrec.column_name;
                        END IF;
                ELSE
                 -- Numeric Column
                        IF (task_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',0';
                        ELSE
                          IF (task_csrrec.currency_format_flag IS NULL) THEN
                               l_stmt :=l_stmt||','||task_csrrec.column_name;
                          ELSE
                               l_stmt := l_stmt||',('||task_csrrec.column_name||')/(PA_STATUS.Get_factor)';
                          END IF;
                        END IF;
                END IF;
        END LOOP;

ELSIF (p_view_name = 'PA_STATUS_RSRC_GENERIC_V')
   THEN


       -- Resource Status Base View  ----------------------------------


       -- SELECT: First Part


l_ddl_stmt := 'CREATE OR REPLACE  FORCE VIEW   PA_STATUS_RSRC_GENERIC_V
(       PROJECT_ID
        , RESOURCE_LIST_MEMBER_ID
        , PARENT_MEMBER_ID
        , MEMBER_LEVEL
        , SORT_ORDER
        , TASK_ID
        , RESOURCE_LIST_ID
        , RESOURCE_LIST_ASSIGNMENT_ID
        , PROJECT_LEVEL_FLAG
        , CHILD_EXIST_FLAG
        , COLUMN1
        , COLUMN2
        , COLUMN3
        , COLUMN4
        , COLUMN5
        , COLUMN6
        , COLUMN7
        , COLUMN8
        , COLUMN9
        , COLUMN10
        , COLUMN11
        , COLUMN12
        , COLUMN13
        , COLUMN14
        , COLUMN15
        , COLUMN16
        , COLUMN17
        , COLUMN18
        , COLUMN19
        , COLUMN20
        , COLUMN21
        , COLUMN22
        , COLUMN23
        , COLUMN24
        , COLUMN25
        , COLUMN26
        , COLUMN27
        , COLUMN28
        , COLUMN29
        , COLUMN30
        , COLUMN31
        , COLUMN32
        , COLUMN33
)  as SELECT
        pah.project_id
        , pah.resource_list_member_id
        , rlm1.parent_member_id
        , rlm1.member_level
        , rlm1.sort_order
        , pah.task_id
        , pah.resource_list_id
        , pah.resource_list_assignment_id
        , decode(pah.task_id, 0, ''Y'',''N'')
        , decode(pa_get_resource.child_resource_exists(pah.resource_list_member_id,
          pah.task_id,pah.project_id),
          ''Y'',''+'',''N'','' '')';

        -- FROM_CLAUSE: --------------------------------

        l_from_clause := 'pa_status_proj_accum_headers_v pah,pa_resource_list_members rlm1';

        -- WHERE_CLAUSE: ---------------------------------

l_where_clause :='pah.project_id = PA_STATUS.GetProjId AND pah.resource_list_id = PA_STATUS.GetRsrcListId AND pah.task_id = PA_STATUS.GetTaskId AND pah.resource_list_member_id = rlm1.resource_list_member_id';

        -- Append Basic From- and Where-Clauses as Required -------------------

        -- Resources
        IF (Check_Alias('RES.','R') = 'Y') THEN

                l_from_clause := l_from_clause||',pa_resources res';

                l_where_clause := l_where_clause||' AND rlm1.resource_id = res.resource_id';

        END IF;



        -- Actuals
        IF (Check_Alias('A.','R') = 'Y') THEN

                l_from_clause := l_from_clause||',pa_status_rsrc_act_high_v a';

                l_where_clause := l_where_clause||' AND pah.resource_list_member_id = a.resource_list_member_id (+)';

        END IF;


        -- Commitments
        IF (Check_Alias('M.','R') = 'Y') THEN

                l_from_clause := l_from_clause||',pa_status_rsrc_cmt_high_v m';

                l_where_clause := l_where_clause||' AND pah.resource_list_member_id = m.resource_list_member_id (+)';

        END IF;


        -- Cost Budgets
        IF (Check_Alias('C.','R') = 'Y') THEN

                l_from_clause := l_from_clause||',pa_status_rsrc_bgt_cost_high_v c';

                l_where_clause := l_where_clause||' AND pah.resource_list_member_id = c.resource_list_member_id (+)';

        END IF;


        -- Revenue Budgets
        IF (Check_Alias('R.','R') = 'Y') THEN

                l_from_clause := l_from_clause||',pa_status_rsrc_bgt_rev_high_v r';

                l_where_clause := l_where_clause||' AND pah.resource_list_member_id = r.resource_list_member_id (+)';

        END IF;


        -- SELECT: Last Part  --------------------------------------

        FOR rsrc_csrrec IN rsrc_csr LOOP

                IF (rsrc_csrrec.format_code = 'C')
                   THEN
                    -- Character Column

                        IF (rsrc_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',null';
                        ELSE
                               l_stmt :=l_stmt||','||rsrc_csrrec.column_name;
                        END IF;
                ELSE
                    -- Numeric Column
                        IF (rsrc_csrrec.column_name IS NULL) THEN
                               l_stmt :=l_stmt||',0';
                        ELSE
                          IF (rsrc_csrrec.currency_format_flag IS NULL) THEN
                               l_stmt :=l_stmt||','||rsrc_csrrec.column_name;
                          ELSE
                               l_stmt := l_stmt||',('||rsrc_csrrec.column_name||')/(PA_STATUS.Get_factor)';
                          END IF;
                        END IF;
                END IF;
        END LOOP;



ELSIF (p_view_name = 'PA_STATUS_PROJ_LIST_V')
   THEN



   -- Project Status PROJECT LIST View ----------------------------------

    -- SELECT: First Part --------------------------

     l_ddl_stmt := 'CREATE OR REPLACE FORCE VIEW PA_STATUS_PROJ_LIST_V
(       PROJECT_ID
        , PROJFUNC_CURRENCY_CODE
        , COLUMN4
        , COLUMN5
        , COLUMN6
        , COLUMN7
        , COLUMN8
        , COLUMN9
        , COLUMN10
        , COLUMN11
        , COLUMN12
        , COLUMN13
        , COLUMN14
        , COLUMN15
        , COLUMN16
        , COLUMN17
        , COLUMN18
        , COLUMN19
        , COLUMN20
        , COLUMN21
        , COLUMN22
        , COLUMN23
        , COLUMN24
        , COLUMN25
        , COLUMN26
        , COLUMN27
        , COLUMN28
        , COLUMN29
        , COLUMN30
        , COLUMN31
        , COLUMN32
        , COLUMN33
)  as SELECT
        p.project_id,
        p.projfunc_currency_code';



        -- BASE FROM_CLAUSE: ------------------------------------------
        -- Must join to pa_projects_all since myoracle portal queries ACROSS
        -- operating units.

        l_from_clause := 'pa_projects_all p,pa_project_accum_headers pah';



        -- BASE WHERE_CLAUSE: -----------------------------------------

        l_where_clause := ' p.project_id = pah.project_id AND pah.task_id = 0 AND pah.resource_list_member_id = 0';


        -- Append Basic From- and Where-Clauses as Required -------------------



        -- Actuals
        IF (Check_Alias('A.','P') = 'Y')
            THEN

                l_from_clause := l_from_clause||',pa_project_accum_actuals a';

                l_where_clause := l_where_clause||' AND pah.project_accum_id = a.project_accum_id';

        END IF;


        -- Commitments
        IF (Check_Alias('M.','P') = 'Y')
           THEN

                l_from_clause := l_from_clause||',pa_project_accum_commitments m';

                l_where_clause := l_where_clause||' AND pah.project_accum_id = m.project_accum_id';

        END IF;


       -- Cost Budgets
        IF (Check_Alias('C.','P') = 'Y')
           THEN

                l_from_clause := l_from_clause||',PA_PROJECT_ACCUM_BUDGETS_V c';

 l_where_clause := l_where_clause||' AND pah.project_accum_id = c.project_accum_id AND C.BUDGET_TYPE_CODE = '||'''AC''';

        END IF;


        -- Revenue Budgets
        IF (Check_Alias('R.','P') = 'Y')
             THEN

                l_from_clause := l_from_clause||',PA_PROJECT_ACCUM_BUDGETS_V r';

 l_where_clause := l_where_clause||' AND pah.project_accum_id = r.project_accum_id AND R.BUDGET_TYPE_CODE = '||'''AR''';


        END IF;


        -- SELECT: Last Part: ONLY Map Numeric Columns! -------------------------------------
        -- For now, do NOT implement Factoring as this will not be used by the myportal
        -- Project List.

        FOR proj_csrrec IN proj_csr LOOP
                IF (proj_csrrec.format_code = 'N')
                   THEN
                -- Numeric Column
                        IF (proj_csrrec.column_name IS NULL)
                           THEN
                               l_stmt :=l_stmt||',0';
                        ELSE
                               l_stmt :=l_stmt||','||proj_csrrec.column_name;
                        END IF;
                END IF;
        END LOOP;


END IF;  -- CASE for p_view_name


--
-- Generate View (p_view_name) -----------------------------------------
--

   l_ddl_stmt := l_ddl_stmt||l_stmt;
   l_ddl_stmt := l_ddl_stmt||' FROM '||l_from_clause;
   l_ddl_stmt := l_ddl_stmt||' WHERE '||l_where_clause;


-- Get Client Specific Schema Name

   l_return := FND_INSTALLATION.Get_App_Info(
                        application_short_name => 'FND'
                        , status => l_status
                        , industry => l_industry
                        , oracle_schema => l_applsys
                );

-- Call AOL API to Generate View

   AD_DDL.DO_DDL(l_applsys,'PA', 2,l_ddl_stmt, 'VIEW');






 EXCEPTION

        WHEN OTHERS THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => G_PKG_NAME,
                    p_procedure_name   => l_api_name);



END Create_View_DDL;

--
-- Name:		Update_Ak_Item_Long_Label
-- Type:		PL/SQL Procedure
--
-- Description:	        This procedure updates the AK PSI Project List column labels
--                      with the user-defined prompts from the pa_status_column_setup
--                      table.
--
--                      This procedure is called from two places:
--                      1) The Project Status Column Setup form (PAXURDDC.fmb)
--                      2) An upgrade script
--
-- Note:
--
--
--
-- Called Subprograms:  AK_REGIONS_UTIL_PKG.Update_Item_Long_Label
--
-- History:
--    31-OCT-2001	jwhite      Created.
--


PROCEDURE Update_Ak_Item_Long_Label
(x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS


l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Ak_Item_Long_Label';

l_counter    			NUMBER          := 0;
l_col_prompt_val                VARCHAR2(30)	:=NULL;
l_attribute_code                VARCHAR2(30)	:=NULL;


       CURSOR  prompt_csr
       IS
       SELECT  column_prompt
       FROM    pa_status_column_setup
       WHERE folder_code = 'P'
       order by column_order;



BEGIN

        SAVEPOINT AK_Label_Pvt;

	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

        l_counter := 1;

      /* Commenting the call to Update_Item_Long_Label for bug 3684384
        OPEN  prompt_csr;

        LOOP

            FETCH prompt_csr INTO l_col_prompt_val;
            EXIT  WHEN prompt_csr%NOTFOUND;

            IF (l_counter > 3)
                THEN

             IF (l_col_prompt_val is NOT NULL)
               THEN

                l_attribute_code  :=  'PSI_COLUMN'||to_char(l_counter);



                AK_REGIONS_UTIL_PKG.Update_Item_Long_Label
                ( x_region_application_id	=> 275
                , x_region_code                 	=> 'PA_MY_PROJECTS_RESULT_LIST'
                , x_attribute_application_id    	=> 275
                , x_attribute_code              	=> l_attribute_code
                , x_attribute_label_long        	=> l_col_prompt_val
                , x_last_update_date            	=> sysdate
                , x_last_updated_by             	=> G_last_updated_by
                , x_last_update_login           	=> G_last_update_login
                );



             END IF; -- l_col_prompt_val is NOT NULL

           END IF;  --(l_counter > 3)

           l_counter := l_counter +1;

       END LOOP;

      CLOSE  prompt_csr;
   Bug 3684384 End */

EXCEPTION

        WHEN OTHERS THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK TO AK_Label_Pvt;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => G_PKG_NAME,
                    p_procedure_name   => l_api_name);


END Update_Ak_Item_Long_Label;



-- ----------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------

--
-- Name:		Check_Alias
-- Type:		Function
--
-- Description:	        For a given view, find if of IN-parameter
--                      alias is used.
--
-- Note:
--
-- Called Subprograms:  None.
--
-- History:
--    31-OCT-2001	jwhite      Created.
--

FUNCTION Check_Alias (x_alias         IN VARCHAR2
                      , x_folder_code IN VARCHAR2
                     )     RETURN VARCHAR2
IS

        l_found    VARCHAR(1) := 'Y';

        CURSOR check_csr
        IS
        SELECT  'Y'
        FROM    dual
        WHERE EXISTS (select '1'
                      FROM    pa_status_column_setup
                      WHERE   folder_code = x_folder_code
                      AND     INSTR(column_name,x_alias) > 0
                      );

BEGIN

        OPEN check_csr;
        FETCH check_csr INTO l_found;
        IF check_csr%NOTFOUND
          THEN
                l_found := 'N';
        END IF;
        CLOSE check_csr;

        RETURN l_found;

END Check_Alias;



END pa_ddc_pvt;

/
