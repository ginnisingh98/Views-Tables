--------------------------------------------------------
--  DDL for Package Body PA_MULTI_CURRENCY_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MULTI_CURRENCY_TXN" AS
--$Header: PAXMCTXB.pls 120.4.12010000.10 2009/05/11 07:54:30 srathi ship $

/** This is a global Record structure used as a cache for FI calls **/

   TYPE FI_REC_ATTRB_TYPE IS RECORD (
          prev_project_id          pa_projects_all.project_id%type := NULL
         ,prev_exp_org_id          number := NULL
         ,prev_ei_date             date := null
         ,prev_attribute           varchar2(200) := null
         ,project_rate_type        varchar2(100) := null
         ,project_rate_date        date := NULL
         ,projfunc_cost_rate_type  varchar2(100) := null
         ,projfunc_cost_rate_date  date := NULL
         ,acct_rate_type           varchar2(100) := null
         ,acct_rate_date           date := NULL
         ,project_currency_code    varchar2(100) := null
         ,projfunc_currency_code   varchar2(100) := null
         ,acct_currency_code       varchar2(100) := null
         ,denom_currency_code      varchar2(100) := null
                );

        G_REC_FI_ATTRB FI_REC_ATTRB_TYPE;


P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode ;

PROCEDURE print_message(p_msg  varchar2) IS
BEGIN
	--r_debug.r_msg('Log: '||p_msg);
	--hsk.print_msg('Log: '|| p_msg);
	NULL;
END print_message;

/** This procedure initializes the global record for each get_currency_amounts call **/

   PROCEDURE initialize_global_rec IS

   BEGIN
         G_REC_FI_ATTRB.prev_project_id          := null;
         G_REC_FI_ATTRB.prev_exp_org_id          := null;
         G_REC_FI_ATTRB.prev_ei_date             := null;
         G_REC_FI_ATTRB.prev_attribute           := null;
         G_REC_FI_ATTRB.project_rate_type        := null;
         G_REC_FI_ATTRB.project_rate_date        := NULL;
         G_REC_FI_ATTRB.projfunc_cost_rate_type  := null;
         G_REC_FI_ATTRB.projfunc_cost_rate_date  := NULL;
         G_REC_FI_ATTRB.acct_rate_type           := null;
         G_REC_FI_ATTRB.acct_rate_date           := NULL;
         G_REC_FI_ATTRB.project_currency_code    := null;
         G_REC_FI_ATTRB.projfunc_currency_code   := null;
         G_REC_FI_ATTRB.acct_currency_code       := null;
         G_REC_FI_ATTRB.denom_currency_code      := null;

   END initialize_global_rec;


/** This api is created to derive project/Acct/Projfunc attributes for
 *  forcasting modules
 **/
PROCEDURE  derive_fi_curr_attributes
	( P_project_id 		        IN number
	 ,P_exp_org_id 		        IN number
     ,P_ei_date    		        IN date
	 ,P_attribute               IN varchar2
     ,x_project_rate_type 	    IN OUT NOCOPY varchar2
     ,x_project_rate_date 	    IN OUT NOCOPY date
     ,x_projfunc_cost_rate_type IN OUT NOCOPY varchar2
     ,x_projfunc_cost_rate_date IN OUT NOCOPY date
     ,x_acct_rate_type          IN OUT NOCOPY varchar2
     ,x_acct_rate_date          IN OUT NOCOPY date)

IS

	/**  Bug fix :2322364
	 *  Derivation of currency attributes are based on the following logic This holds good only
         *  For Labor Transactions ie, system linkage function = ST / OT and calling module = FORECAST
	 *  Logic : If the x_project_rate_type / x_project_rate_date / x_projfunc_cost_rate_type is NULL
	 *  Then derive the attributes at the projects OU ie. receiver org
         *  If x_acct_rate_type / x_acct_rate_date / x_projfunc_cost_rate_date is NULL then derive the
         *  attributes at the Expenditure OU .
	 **/

	CURSOR cur_attrib IS
     	SELECT    proj.project_currency_code  PROJECT_CURRENCY_CODE
                  ,NVL(x_project_rate_type,
		      NVL(proj.project_rate_type,imp_recvr.default_rate_type)) PROJECT_RATE_TYPE
                  ,NVL(proj.project_rate_date,DECODE(imp_recvr.default_rate_date_code,
		       'E', P_EI_date, 'P'
			,pa_utils2.get_pa_date(P_EI_date,sysdate, imp_recvr.org_id))) PROJECT_RATE_DATE
                  ,NVL(x_acct_rate_type, imp_prvdr.default_rate_type) ACCT_RATE_TYPE
		  ,NVL(x_acct_rate_date,DECODE(imp_prvdr.default_rate_date_code,
                       'E', P_EI_date, 'P'
                        ,pa_utils2.get_pa_date(P_EI_date,sysdate, imp_prvdr.org_id))) ACCT_RATE_DATE
                  ,proj.projfunc_currency_code  PROJFUNC_CURRENCY_CODE
                  ,NVL(x_projfunc_cost_rate_type,
		      NVL( proj.projfunc_cost_rate_type,imp_recvr.default_rate_type)) PROJFUNC_COST_RATE_TYPE
		  ,NVL(proj.projfunc_cost_rate_date, DECODE(imp_prvdr.default_rate_date_code,
                       'E', P_EI_date, 'P'
                       ,pa_utils2.get_pa_date(P_EI_date,sysdate, imp_prvdr.org_id))) PROJFUNC_COST_RATE_DATE
       FROM    pa_projects_all proj
               ,pa_implementations_all imp_prvdr
	       ,pa_implementations_all imp_recvr  /* bug fix :2322364 */
      WHERE    proj.project_id       = P_project_id
        AND    imp_prvdr.org_id      = P_exp_org_id
        AND    proj.org_id           = imp_recvr.org_id; /* bug fix :2322364 */

	l_project_currency_code   VARCHAR2(100);
	l_project_rate_type       VARCHAR2(100);
	l_project_rate_date       DATE;
	l_acct_rate_type          VARCHAR2(100);
	l_acct_rate_date          DATE;
	l_projfunc_currency_code  VARCHAR2(100);
	l_projfunc_cost_rate_type VARCHAR2(100);
	l_projfunc_cost_rate_date DATE;

    -- begin r12 nocopy changes
    l_temp_project_rate_type VARCHAR2(100);
    l_temp_project_rate_date date;
    l_temp_projfunc_cost_rate_type VARCHAR2(100);
    l_temp_projfunc_cost_rate_date date;
    l_temp_acct_rate_type VARCHAR2(100);
    l_temp_acct_rate_date date;

BEGIN

    l_temp_project_rate_type := x_project_rate_type;
    l_temp_project_rate_date := x_project_rate_date;
    l_temp_projfunc_cost_rate_type := x_projfunc_cost_rate_type;
    l_temp_projfunc_cost_rate_date := x_projfunc_cost_rate_date;
    l_temp_acct_rate_type := x_acct_rate_type;
    l_temp_acct_rate_date := x_acct_rate_date;
    -- end r12 nocopy changes

	--Initialize the error stack
	--Note : pa_debug calls are commented out as it voilates get_currency_attrib pragma excpetions
	--PA_DEBUG.init_err_stack('PA_MULTI_CURRENCY_TXN.derive_currency_attributes_fi');
	print_message('Inside derive_fi_curr_attributes api');

    IF (G_REC_FI_ATTRB.prev_project_id is NULL OR
	    G_REC_FI_ATTRB.prev_project_id <> P_project_id ) OR
	   (G_REC_FI_ATTRB.prev_exp_org_id is NULL OR
        G_REC_FI_ATTRB.prev_exp_org_id <> p_exp_org_id ) OR
       (G_REC_FI_ATTRB.prev_ei_date is NULL OR
        TRUNC(G_REC_FI_ATTRB.prev_ei_date) <> Trunc(p_ei_date) ) OR
       (G_REC_FI_ATTRB.prev_attribute is NULL OR
        G_REC_FI_ATTRB.prev_attribute <> P_attribute ) Then

	   print_message('Opening cursor to fetch attributes');


	   OPEN cur_attrib;
	   FETCH cur_attrib
	   INTO  l_project_currency_code
    	    ,l_project_rate_type
	        ,l_project_rate_date
	        ,l_acct_rate_type
            ,l_acct_rate_date
	        ,l_projfunc_currency_code
	        ,l_projfunc_cost_rate_type
	        ,l_projfunc_cost_rate_date ;

	   If cur_attrib%found then
		   print_message('Cursor fetch 1 records');
	   Else
		   print_message('Cursor fetch NO rcords');
	   End if;
	   ClOSE cur_attrib;

	   print_message('End of Fetch');
	   print_message('Assigning to OUT variables');

	   -- Assign to OUT variables
       x_project_rate_type       := l_project_rate_type;
       x_project_rate_date       := l_project_rate_date;
       x_projfunc_cost_rate_type := l_projfunc_cost_rate_type;
       x_projfunc_cost_rate_date := l_projfunc_cost_rate_date;
       x_acct_rate_type          := l_acct_rate_type;
       x_acct_rate_date          := l_acct_rate_date;
	   G_REC_FI_ATTRB.prev_project_id := P_project_id;
       G_REC_FI_ATTRB.prev_exp_org_id := P_exp_org_id;
	   G_REC_FI_ATTRB.prev_ei_date    := P_ei_date;
	   G_REC_FI_ATTRB.prev_attribute  := P_attribute;
	   G_REC_FI_ATTRB.project_rate_type := l_project_rate_type;
	   G_REC_FI_ATTRB.project_rate_date := l_project_rate_date;
	   G_REC_FI_ATTRB.projfunc_cost_rate_type := l_projfunc_cost_rate_type;
	   G_REC_FI_ATTRB.projfunc_cost_rate_date := l_projfunc_cost_rate_date;
	   G_REC_FI_ATTRB.acct_rate_type  := l_acct_rate_type;
	   G_REC_FI_ATTRB.acct_rate_date  := l_acct_rate_date;
	   G_REC_FI_ATTRB.project_currency_code := l_project_currency_code;
	   G_REC_FI_ATTRB.projfunc_currency_code := l_projfunc_currency_code;

    ELSE  -- Retrieve from the cache

	   print_message('Retrieve from the cache ');

       x_project_rate_type       := G_REC_FI_ATTRB.project_rate_type;
       x_project_rate_date       := G_REC_FI_ATTRB.project_rate_date;
       x_projfunc_cost_rate_type := G_REC_FI_ATTRB.projfunc_cost_rate_type;
       x_projfunc_cost_rate_date := G_REC_FI_ATTRB.projfunc_cost_rate_date;
       x_acct_rate_type          := G_REC_FI_ATTRB.acct_rate_type;
       x_acct_rate_date          := G_REC_FI_ATTRB.acct_rate_date;

    END IF;

	-- reset the error stack;
	--PA_DEBUG.reset_err_stack;
	Return;

EXCEPTION
    WHEN OTHERS THEN
         IF cur_attrib%isopen then
              close cur_attrib;
         END IF;
		 print_message('Failed in derive_fi_curr_attributes :'||sqlerrm||sqlcode);
         x_project_rate_type := l_temp_project_rate_type;
         x_project_rate_date := l_temp_project_rate_date;
         x_projfunc_cost_rate_type := l_temp_projfunc_cost_rate_type;
         x_projfunc_cost_rate_date := l_temp_projfunc_cost_rate_date;
         x_acct_rate_type := l_temp_acct_rate_type;
         x_acct_rate_date := l_temp_acct_rate_date;
         RAISE;

END  derive_fi_curr_attributes;


PROCEDURE get_projfunc_cost_rate_type (
               P_task_id                 IN NUMBER ,
               P_project_id              IN pa_projects_all.project_id%TYPE DEFAULT NULL,
               P_calling_module          IN VARCHAR2 ,
               p_structure_version_id    IN NUMBER DEFAULT NULL,
               P_projfunc_currency_code  IN OUT NOCOPY VARCHAR2 ,
               P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 )

IS

BEGIN
--
-- This procedure derives project functional currency code and
-- project functional currency conversion rate type
--
-- Logic: if the user provides a projfunc_cost_rate_type, use it.
-- Otherwise derive it from the task, if taskfunc_cost_rate_type is not
-- defined at task level then get it from project level. If projfunc_cost_rate_type
-- is not defined at project level also then derive the
-- project_rate_type value from default_rate_type column in
-- project owning operating units implementation options table.
-- projfunc_currency_code is derived from projects table

   IF (p_calling_module <> 'WORKPLAN')
   THEN
     SELECT    proj.projfunc_currency_code,
               NVL(P_projfunc_cost_rate_type, NVL(NVL(task.taskfunc_cost_rate_type,
                   proj.projfunc_cost_rate_type), imp.default_rate_type))
       INTO    P_projfunc_currency_code,
               P_projfunc_cost_rate_type
       FROM    pa_projects_all proj,
               pa_tasks task,
               pa_implementations_all imp
      WHERE    proj.project_id       = task.project_id
        AND    task.task_id          = P_task_id
        AND    NVL(proj.org_id, -99) = NVL(imp.org_id, -99);
   ELSE
/***********************
     SELECT    proj.projfunc_currency_code,
               NVL(P_projfunc_cost_rate_type, NVL(NVL(task.taskfunc_cost_rate_type,
                   proj.projfunc_cost_rate_type), imp.default_rate_type))
       INTO    P_projfunc_currency_code,
               P_projfunc_cost_rate_type
       FROM    pa_projects_all proj,
               pa_tasks task,
               pa_map_wp_to_fin_tasks_v map_wp_fin,
               pa_implementations_all imp
      WHERE    proj.project_id             = map_wp_fin.project_id
        AND    task.task_id(+)             = map_wp_fin.mapped_fin_task_id
        AND    map_wp_fin.proj_element_id  = p_task_id
        AND    NVL(proj.org_id, -99) = NVL(imp.org_id, -99);
******************/
           BEGIN
               SELECT    proj.projfunc_currency_code,
                         NVL(P_projfunc_cost_rate_type, NVL(NVL(task.taskfunc_cost_rate_type,
                             proj.projfunc_cost_rate_type), imp.default_rate_type))
                 INTO    P_projfunc_currency_code,
                         P_projfunc_cost_rate_type
                 FROM    pa_projects_all proj,
                         pa_tasks task,
                         pa_map_wp_to_fin_tasks_v map_wp_fin,
                         pa_implementations_all imp
                WHERE    proj.project_id          = p_project_id
                  AND    task.task_id             = map_wp_fin.mapped_fin_task_id
                  AND    map_wp_fin.proj_element_id  = p_task_id
                  AND    map_wp_fin.parent_structure_version_id  = p_structure_version_id
                  AND    NVL(proj.org_id, -99) = NVL(imp.org_id, -99);
           EXCEPTION
             WHEN NO_DATA_FOUND
                  THEN
                      SELECT    proj.projfunc_currency_code,
                                NVL(P_projfunc_cost_rate_type, NVL(proj.projfunc_cost_rate_type
                                             , imp.default_rate_type))
                        INTO    P_projfunc_currency_code,
                                P_projfunc_cost_rate_type
                        FROM    pa_projects_all proj,
                                pa_implementations_all imp
                       WHERE    proj.project_id       = p_project_id
                         AND    NVL(proj.org_id, -99) = NVL(imp.org_id, -99);
           END; -- anonymous
   END IF;

EXCEPTION
   WHEN no_data_found THEN
      P_projfunc_currency_code  := NULL;
      P_projfunc_cost_rate_type := NULL;

   WHEN others THEN
      P_projfunc_currency_code  := NULL;
      P_projfunc_cost_rate_type := NULL;
      RAISE ;

END get_projfunc_cost_rate_type ;


PROCEDURE get_def_projfunc_cst_rate_type   (
               P_task_id                 IN NUMBER ,
               P_projfunc_currency_code  IN OUT NOCOPY VARCHAR2 ,
               P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 )

IS

BEGIN
--
-- This procedure derives project functional currency code and
-- project functional currency conversion rate type
--
-- Logic: if the user provides a projfunc_cost_rate_type, use it.
-- Otherwise derive it from the task, if taskfunc_cost_rate_type is not
-- defined at task level then get it from project level. If projfunc_cost_rate_type
-- is not defined at project level also then derive the
-- project_rate_type value from default_rate_type column in
-- expenditure owning operating units implementation options table.
-- projfunc_currency_code is derived from projects table

     SELECT    proj.projfunc_currency_code,
               NVL(P_projfunc_cost_rate_type, NVL(NVL(task.taskfunc_cost_rate_type,
                   proj.projfunc_cost_rate_type), imp.default_rate_type))
       INTO    P_projfunc_currency_code,
               P_projfunc_cost_rate_type
       FROM    pa_projects_all proj,
               pa_tasks task,
               pa_implementations_all imp       -- bug 8265941 changed to pa_implementations_all
      WHERE    proj.project_id       = task.project_id
        AND    task.task_id          = P_task_id
        AND    NVL(proj.org_id,-99)  = NVL(imp.org_id,-99);  -- bug 7579126

EXCEPTION
   WHEN no_data_found THEN
      P_projfunc_currency_code  := NULL;
      P_projfunc_cost_rate_type := NULL;

   WHEN others THEN
      P_projfunc_currency_code  := NULL;
      P_projfunc_cost_rate_type := NULL;
      RAISE ;

END get_def_projfunc_cst_rate_type ;

FUNCTION get_proj_curr_code_sql   ( P_project_id  NUMBER) RETURN VARCHAR2 IS

l_project_currency_code  VARCHAR2(30) ;
BEGIN
--
--   This function returns the Project Currency Code from the
--   pa_projects_all table based on the project_id which is a
--   parameter for this function
--   Since, the Project Currency Code column is a NOT NULL column
--   in the pa_projects_all table, we need not handle the no_data_found
--   exception nor do we need to go to the Project owning OU to get the
--   currency Code from the Set of Books Id.

     SELECT    project_currency_code
     INTO   l_project_currency_code
     FROM   pa_projects_all
     WHERE   project_id = P_project_id ;

     RETURN l_project_currency_code ;

EXCEPTION
     WHEN others THEN
       RAISE ;

END get_proj_curr_code_sql ;

-- fix for bug # 910659. Changed from clause to select from
-- pa_projects_all instead of pa_projects

PROCEDURE get_projfunc_cost_rate_date (
               P_task_id                 IN NUMBER ,
               P_project_id              IN pa_projects_all.project_id%TYPE DEFAULT NULL   ,
               P_EI_date                 IN DATE   ,
               p_structure_version_id    IN NUMBER DEFAULT NULL,
               P_calling_module          IN VARCHAR2   ,
               P_projfunc_cost_rate_date IN OUT NOCOPY DATE )

IS

BEGIN

--
-- This procedure derives project functional currency conversion rate date
--
-- Logic:  If user provides a project functional currency conversion date, Use it.
-- Otherwise derive it from task( identified bt P_task_id),
-- if taskfunc_cost_rate_date is not defined at task level then derive it from
-- projects table.  If the projfunc_cost_rate_date is not defined at project
-- level also then the projfunc_cost_rate_date will be derived using the
-- default_rate_date_code from expenditure operating units implementation
-- options. If the default_rate_date_code is E then return the expenditure
-- item date(P_EI_date), if default_rate_date_code is P then return the
-- PA period ending date.

    IF ( P_projfunc_cost_rate_date IS NULL )
    THEN
      IF (p_calling_module <> 'WORKPLAN')
      THEN
        SELECT  NVL(NVL(task.taskfunc_cost_rate_date,
                proj.projfunc_cost_rate_date),
                                         DECODE(imp.default_rate_date_code,
                                         'E', P_EI_date, 'P',
                                         pa_utils2.get_pa_date(P_EI_date,
                                         sysdate, imp.org_id)))           /**CBGA**/
        INTO   P_projfunc_cost_rate_date
        FROM   pa_projects_all proj,
          pa_tasks task,
               pa_implementations_all imp     -- bug 8265941 changed to pa_implementations_all
        WHERE  task.task_id = P_task_id
     AND  proj.project_id = task.project_id
     AND  NVL(proj.org_id,-99) = NVL(imp.org_id,-99);  -- bug 7579126
      ELSE
          BEGIN
              SELECT  task.taskfunc_cost_rate_date
                INTO  P_projfunc_cost_rate_date
                FROM  pa_tasks task
                      ,pa_map_wp_to_fin_tasks_v map_wp_fin
               WHERE  task.task_id = map_wp_fin.mapped_fin_task_id
                 AND  map_wp_fin.proj_element_id = P_task_id
                 AND  map_wp_fin.parent_structure_version_id = p_structure_version_id;
          EXCEPTION
                 WHEN NO_DATA_FOUND THEN NULL;
          END; -- anonymous
          IF ( P_projfunc_cost_rate_date IS NULL )
          THEN
                SELECT  NVL(proj.projfunc_cost_rate_date,
                                                 DECODE(imp.default_rate_date_code,
                                                 'E', P_EI_date, 'P',
                                                 pa_utils2.get_pa_date(P_EI_date,
                                                 sysdate, imp.org_id)))
                  INTO  P_projfunc_cost_rate_date
                  FROM  pa_projects_all proj
                       ,pa_implementations_all imp        -- bug 8265941 changed to pa_implementations_all
                 WHERE  proj.project_id = p_project_id
                   AND  NVL(proj.org_id,-99) = NVL(imp.org_id,-99);  -- bug 7579126
          END IF;
      END IF; -- calling_module
   END IF ;


EXCEPTION
     WHEN no_data_found THEN
          P_projfunc_cost_rate_date := NULL ;

     WHEN others THEN
          P_projfunc_cost_rate_date := NULL ;
          RAISE ;

END get_projfunc_cost_rate_date ;


PROCEDURE get_def_projfunc_cst_rate_date (
               P_task_id                 IN NUMBER ,
               P_project_id              IN pa_projects_all.project_id%TYPE DEFAULT NULL,
               P_EI_date                 IN DATE   ,
               P_structure_version_id    IN NUMBER DEFAULT NULL,
               P_calling_module          IN VARCHAR2   ,
               P_projfunc_cost_rate_date IN OUT NOCOPY DATE )
IS

BEGIN

--
-- This procedure derives project functional currency conversion rate date
--
-- Logic:  If user provides a project functional currency conversion date, Use it.
-- Otherwise derive it from task( identified bt P_task_id),
-- if taskfunc_cost_rate_date is not defined at task level then derive it from
-- projects table.  If the projfunc_cost_rate_date is not defined at project
-- level also then the project_rate_date will be derived using the
-- default_rate_date_code from expenditure operating units implementation
-- options. If the default_rate_date_code is E then return the expenditure
-- item date(P_EI_date), if default_rate_date_code is P then return
-- null.

     IF ( P_projfunc_cost_rate_date IS NULL )
     THEN
       IF (p_calling_module <> 'WORKPLAN')
       THEN
        SELECT  NVL(NVL(task.taskfunc_cost_rate_date,
                proj.projfunc_cost_rate_date),
                                         DECODE(imp.default_rate_date_code,
                                         'E', P_EI_date, 'P',
                                         NULL))
        INTO   P_projfunc_cost_rate_date
        FROM   pa_projects_all proj,
          pa_tasks task,
               pa_implementations_all imp          -- bug 8265941 changed to pa_implementations_all
        WHERE  task.task_id = P_task_id
     AND  proj.project_id = task.project_id
     AND  NVL(proj.org_id,-99) = NVL(imp.org_id,-99); -- bug 7579126
       ELSE
/************************
        SELECT  NVL(NVL(task.taskfunc_cost_rate_date,
                proj.projfunc_cost_rate_date),
                                         DECODE(imp.default_rate_date_code,
                                         'E', P_EI_date, 'P',
                                         NULL))
        INTO   P_projfunc_cost_rate_date
        FROM   pa_projects_all proj,
               pa_tasks task,
               pa_map_wp_to_fin_tasks_v map_wp_fin,
               pa_implementations imp
       WHERE   proj.project_id = map_wp_fin.project_id
         AND   task.task_id(+) = map_wp_fin.mapped_fin_task_id
         AND   map_wp_fin.proj_element_id = p_task_id;
*********************/
            BEGIN
                SELECT  task.taskfunc_cost_rate_date
                  INTO  P_projfunc_cost_rate_date
                  FROM  pa_tasks task
                       ,pa_map_wp_to_fin_tasks_v map_wp_fin
                 WHERE  task.task_id = map_wp_fin.mapped_fin_task_id
                   AND  map_wp_fin.proj_element_id = p_task_id
                   AND  map_wp_fin.parent_structure_version_id = p_structure_version_id;
            EXCEPTION
              WHEN NO_DATA_FOUND
                  THEN
                      NULL;
            END; -- anonymous

            IF ( P_projfunc_cost_rate_date IS NULL )
            THEN
                SELECT  NVL(proj.projfunc_cost_rate_date,
                                                 DECODE(imp.default_rate_date_code,
                                                 'E', P_EI_date, 'P', NULL))
                  INTO  P_projfunc_cost_rate_date
                  FROM  pa_projects_all proj
                       ,pa_implementations_all imp       -- bug 8265941 changed to pa_implementations_all
                 WHERE  proj.project_id = p_project_id
		  AND   NVL(proj.org_id,-99) = NVL(imp.org_id,-99);  -- bug 7579126
            END IF;
       END IF; -- calling_module
    END IF ;


EXCEPTION
    WHEN no_data_found THEN
        P_projfunc_cost_rate_date := NULL ;

    WHEN others THEN
        P_projfunc_cost_rate_date := NULL ;
        RAISE ;

END get_def_projfunc_cst_rate_date ;

PROCEDURE get_acct_rate_date (
               P_EI_date        IN DATE   ,
               P_acct_rate_date IN OUT NOCOPY DATE )
IS

BEGIN

-- This procedure derives the Functional currency conversion date
-- Logic:  If user provides a acct_rate_date, Use it.
-- otherwise derive derive using the default_rate_date_code from expenditure
-- operating units implementation options. If the default_rate_date_code is E
-- then return the expenditure item date(P_EI_date), if default_rate_date_code
-- is P then return the PA period ending date.

         SELECT  NVL(P_acct_rate_date,DECODE(default_rate_date_code,
                                      'E', P_EI_date, 'P',
                                     pa_utils2.get_pa_date(P_EI_date,
                                                        sysdate, org_id)))  /**CBGA**/
        INTO   P_acct_rate_date
        FROM   pa_implementations ;

EXCEPTION
   WHEN no_data_found THEN
        P_acct_rate_date := NULL ;

   WHEN others THEN
        P_acct_rate_date := NULL ;
        RAISE ;

END get_acct_rate_date ;

PROCEDURE get_default_acct_rate_date (
              P_EI_date        IN DATE   ,
              P_acct_rate_date IN OUT NOCOPY DATE )
IS

BEGIN

-- This procedure derives the Functional currency conversion date
-- Logic:  If user provides a acct_rate_date, Use it.
-- otherwise derive derive using the default_rate_date_code from expenditure
-- operating units implementation options. If the default_rate_date_code is E
-- then return the expenditure item date(P_EI_date), if default_rate_date_code
-- is P then return null.

         SELECT  NVL(P_acct_rate_date,DECODE(default_rate_date_code,
                                      'E', P_EI_date, 'P',
                                    NULL))
        INTO   P_acct_rate_date
        FROM   pa_implementations ;

EXCEPTION

   WHEN no_data_found THEN
        P_acct_rate_date := NULL ;

   WHEN others THEN
        P_acct_rate_date := NULL ;
        RAISE ;

END get_default_acct_rate_date ;

/** The same API is called from Transactions Adjustments and Forecast Items
 *  so new parameters are added to handle the same API when it is called from
 *  Forecast module
 *  The P_calling_module = 'GET_CURR_AMOUNTS' for Transactions
 *      P_calling_module = 'FORECAST' for FIs
 *      P_calling_module = 'WORKPLAN' for Workplan
 *
 *      Defaulting System_Linkage_Function to 'NER' meaning Not-ER. Special
 *      handling is required only for ER transactions. Hence the above.
 **/
PROCEDURE get_currency_amounts (
	  /** Added the following new params for the FI calls **/
	   P_project_id        IN  NUMBER DEFAULT NULL,
	   P_exp_org_id        IN  NUMBER DEFAULT NULL,
	   P_calling_module    IN  VARCHAR2 DEFAULT 'GET_CURR_AMOUNTS',
	  /** End of FI changes **/
       P_task_id                 IN NUMBER,
       P_EI_date                 IN DATE,
       P_denom_raw_cost          IN NUMBER,
       P_denom_curr_code         IN VARCHAR2,
       P_acct_curr_code          IN VARCHAR2,
       P_accounted_flag          IN VARCHAR2 DEFAULT 'N',
       P_acct_rate_date          IN OUT NOCOPY DATE,
       P_acct_rate_type          IN OUT NOCOPY VARCHAR2,
       P_acct_exch_rate          IN OUT NOCOPY NUMBER,
       P_acct_raw_cost           IN OUT NOCOPY NUMBER,
       P_project_curr_code       IN VARCHAR2,
       P_project_rate_type       IN OUT NOCOPY VARCHAR2 ,
       P_project_rate_date       IN OUT NOCOPY DATE,
       P_project_exch_rate       IN OUT NOCOPY NUMBER,
       P_project_raw_cost        IN OUT NOCOPY NUMBER,
       P_projfunc_curr_code      IN VARCHAR2,
       P_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2 ,
       P_projfunc_cost_rate_date IN OUT NOCOPY DATE,
       P_projfunc_cost_exch_rate IN OUT NOCOPY NUMBER,
       P_projfunc_raw_cost       IN OUT NOCOPY NUMBER,
       P_system_linkage          IN pa_expenditure_items_all.system_linkage_function%TYPE DEFAULT 'NER',
       P_structure_version_id    IN NUMBER DEFAULT NULL,
       P_status                  OUT NOCOPY VARCHAR2,
       P_stage                   OUT NOCOPY NUMBER,
	   P_Po_Line_ID              IN NUMBER DEFAULT NULL)   /* Bug : 3535935 */
IS

    l_project_currency_code              VARCHAR2(15);
    l_numerator                   NUMBER;
    l_denominator                        NUMBER;
    V_allow_user_rate_type               VARCHAR2(1);
    l_calling_module                VARCHAR2(100);


    l_acct_rate_date date;
    l_acct_rate_type varchar2(100);
    l_acct_exch_rate number;
    l_acct_raw_cost number;
    l_project_rate_type varchar2(100);
    l_project_rate_date date;
    l_project_exch_rate number;
    l_project_raw_cost number;
    l_projfunc_cost_rate_type varchar2(100);
    l_projfunc_cost_rate_date date;
    l_projfunc_cost_exch_rate number;
    l_projfunc_raw_cost number;

Begin

    l_acct_rate_date :=  P_acct_rate_date;
    l_acct_rate_type := P_acct_rate_type;
    l_acct_exch_rate := P_acct_exch_rate;
    l_acct_raw_cost := P_acct_raw_cost;
    l_project_rate_type := P_project_rate_type;
    l_project_rate_date := P_project_rate_date;
    l_project_exch_rate := P_project_exch_rate;
    l_project_raw_cost := P_project_raw_cost;
    l_projfunc_cost_rate_type := P_projfunc_cost_rate_type;
    l_projfunc_cost_rate_date := P_projfunc_cost_rate_date;
    l_projfunc_cost_exch_rate := P_projfunc_cost_exch_rate;
    l_projfunc_raw_cost := P_projfunc_cost_exch_rate;

    P_stage := 1 ;

    -- This procedure derives the project and functional amounts
    -- for unaccounted/accounted transactions.
    -- For accounted transactions, it derives only the project currency
    -- amounts.  It also derives the currency conversion attributes
    -- if they are not provided when this procedure is called.
    -- If project and functional currencies are same, then this
    -- procedure forces the project and functional currencies conversion
    -- attributes to be identical by using the logic described in
    -- procedure get_currency_attributes.
    --

    IF p_calling_module IS NULL Then
	     l_calling_module := 'GET_CURR_AMOUNTS';
    ELSE
	     l_calling_module := p_calling_module;
    End if;

    If l_calling_module = 'FORECAST' then
        -- Initialize the global record for cache logic
	initialize_global_rec;
    else
       if l_calling_module = 'WORKPLAN' then /* bug 6058074 */

          G_calling_module := 'WORKPLAN'; /* bug 6058074 */
       End if;

    End if;

    -- print_message('Inisde get_currency amount api IN PARAMS:P_project_id :'||P_project_id );
    -- print_message('P_exp_org_id: ['||P_exp_org_id);
    -- print_message('P_calling_module['||l_calling_module);
    -- print_message('P_task_id['||P_task_id);
    -- print_message('P_EI_date['||P_EI_date);
    -- print_message('P_denom_raw_cost['||P_denom_raw_cost);
    -- print_message('P_system_linkage['||P_system_linkage);
    -- print_message('P_denom_curr_code['||P_denom_curr_code);
    -- print_message('P_project_curr_code['||P_project_curr_code);
    -- print_message('P_acct_curr_code['||P_acct_curr_code);
    -- print_message('P_accounted_flag['||P_accounted_flag);
    -- print_message('P_projfunc_curr_code['||P_projfunc_curr_code||']' );
    -- print_message('p_acct_rate_date ['||p_acct_rate_date||']');
    -- print_message('p_acct_rate_type ['||p_acct_rate_type ||']');
    -- print_message('p_acct_exch_rate  ['||p_acct_exch_rate ||']');
    -- print_message('p_project_rate_type ['||p_project_rate_type||']');
    -- print_message('p_project_exch_rate ['||p_project_exch_rate||']');
    -- print_message('p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']');
    -- print_message('p_projfunc_cost_rate_type ['||p_projfunc_cost_rate_type||']');
    -- print_message('p_projfunc_cost_exch_rate ['||p_projfunc_cost_exch_rate||']');

	print_message(' Calling pa_multi_currency_txn.get_currency_attributes ');

    pa_multi_currency_txn.get_currency_attributes
                       ( P_project_id => P_project_id
			,P_exp_org_id => P_exp_org_id
			,P_calling_module => l_calling_module
                        ,P_task_id => P_task_id
                        ,P_ei_date => P_ei_date
                        ,P_denom_curr_code => P_denom_curr_code
                        ,P_accounted_flag => P_accounted_flag
                        ,P_acct_curr_code => P_acct_curr_code
                        ,X_acct_rate_date => P_acct_rate_date
                        ,X_acct_rate_type => P_acct_rate_type
                        ,X_acct_exch_rate => P_acct_exch_rate
                        ,P_project_curr_code => P_project_curr_code
                        ,X_project_rate_date => P_project_rate_date
                        ,X_project_rate_type => P_project_rate_type
                        ,X_project_exch_rate => P_project_exch_rate
                        ,P_projfunc_curr_code => P_projfunc_curr_code
                        ,X_projfunc_cost_rate_date => P_projfunc_cost_rate_date
                        ,X_projfunc_cost_rate_type => P_projfunc_cost_rate_type
                        ,X_projfunc_cost_exch_rate => P_projfunc_cost_exch_rate
                        ,P_system_linkage => P_system_linkage
                        ,P_structure_version_id => P_structure_version_id
                        ,X_status => P_status
                        ,X_stage => P_stage
                       );

        print_message('p_acct_rate_date ['||p_acct_rate_date||']');
        print_message('p_acct_rate_type ['||p_acct_rate_type ||']');
        print_message('p_acct_exch_rate  ['||p_acct_exch_rate ||']');
        print_message('p_project_rate_date ['||p_project_rate_date||']');
        print_message('p_project_rate_type ['||p_project_rate_type||']');
        print_message('p_project_exch_rate ['||p_project_exch_rate||']');
        print_message('p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']');
        print_message('p_projfunc_cost_rate_type ['||p_projfunc_cost_rate_type||']');
        print_message('p_projfunc_cost_exch_rate ['||p_projfunc_cost_exch_rate||']');

/**********
        dbms_output.put_line('Values after get currency attributes api'||
                      'p_acct_rate_date ['||p_acct_rate_date||']'||
                      'p_acct_rate_type ['||p_acct_rate_type ||']'||
                      'p_acct_exch_rate  ['||p_acct_exch_rate ||']'||
                      'p_project_rate_date ['||p_project_rate_date||']'|| '}');
        dbms_output.put_line('Values after get currency attributes api'||
                      'p_project_rate_type ['||p_project_rate_type||']'||
                      'p_project_exch_rate ['||p_project_exch_rate||']'||
                      'p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']'||
                      'p_projfunc_cost_rate_type ['||p_projfunc_cost_rate_type||']'||
                      'p_projfunc_cost_exch_rate ['||p_projfunc_cost_exch_rate||']');
***********/

	print_message('End of get_currency_attributes api call ');
   IF ( P_status IS NOT NULL ) THEN
      -- Error in get_currency_attributes
      RETURN;
   END IF;

   -- Now we have the conversion attributes, derive the
   -- project raw cost for both accounted and unaccounted txns.
   -- derive functional raw cost for unaccounted txns.

   IF ( nvl(P_accounted_flag,'N') = 'Y' ) THEN
      IF ( P_projfunc_curr_code = P_denom_curr_code )
      THEN
          P_projfunc_raw_cost := P_denom_raw_cost ;
          P_projfunc_cost_exch_rate := NULL ;
      ELSIF ( P_projfunc_curr_code = P_acct_curr_code )
      THEN
          /*
           * If a transaction is accounted - it should have
           * acct_raw_cost.
           */
          P_projfunc_raw_cost := P_acct_raw_cost ;
          P_projfunc_cost_exch_rate := P_acct_exch_rate ;
      ELSE
         <<Calculate_projfunc_raw_cost>>
         BEGIN
         --
         --
	 print_message('Calling convert_amount for projfunc raw cost');
         pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                  P_to_currency =>P_projfunc_curr_code,
                                  P_conversion_date =>P_projfunc_cost_rate_date,
                                  P_conversion_type =>P_projfunc_cost_rate_type,
                                  P_amount =>P_denom_raw_cost,
                                  P_user_validate_flag =>'N',
                                  P_handle_exception_flag =>'N',
                                  P_converted_amount =>P_projfunc_raw_cost,
                                  P_denominator =>l_denominator,
                                  P_numerator =>l_numerator,
                                  P_rate =>P_projfunc_cost_exch_rate,
                                  X_status =>P_status ) ;

         IF ( P_status IS NOT NULL ) THEN
             -- Error in convert amount
             RETURN;
         END IF;

         EXCEPTION
         WHEN pa_multi_currency.no_rate THEN
            P_status := 'PA_NO_PROJFUNC_CURR_RATE';
            RETURN;
         WHEN pa_Multi_currency.invalid_currency THEN
            P_status := 'PA_INVALID_PROJFUNC_CURR';
            RETURN;
         WHEN others THEN
            raise;
         END Calculate_projfunc_raw_cost;
      END IF ; --P_projfunc_curr_code = P_denom_curr_code

      IF ( P_project_curr_code = P_denom_curr_code )
      THEN
          P_project_raw_cost := P_denom_raw_cost ;
          P_project_exch_rate := NULL ;
      ELSIF ( P_project_curr_code = P_acct_curr_code )
      THEN
          P_project_raw_cost := P_acct_raw_cost ;
          P_project_exch_rate := P_acct_exch_rate ;
      ELSIF (P_project_curr_code = P_projfunc_curr_code )
      THEN
         P_project_raw_cost := P_projfunc_raw_cost;
         P_project_exch_rate := P_projfunc_cost_exch_rate;
      ELSE
         <<Calculate_project_raw_cost>>
         BEGIN
         --
         --
         pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                  P_to_currency =>P_project_curr_code,
                                  P_conversion_date =>P_project_rate_date,
                                  P_conversion_type =>P_project_rate_type,
                                  P_amount =>P_denom_raw_cost,
                                  P_user_validate_flag =>'N',
                                  P_handle_exception_flag =>'N',
                                  P_converted_amount =>P_project_raw_cost,
                                  P_denominator =>l_denominator,
                                  P_numerator =>l_numerator,
                                  P_rate =>P_project_exch_rate,
                                  X_status =>P_status ) ;

         IF ( P_status IS NOT NULL ) THEN
             -- Error in convert amount
             RETURN;
         END IF;

         EXCEPTION
         WHEN pa_multi_currency.no_rate THEN
            P_status := 'PA_NO_PROJECT_CURR_RATE';
            RETURN;
         WHEN pa_Multi_currency.invalid_currency THEN
            P_status := 'PA_INVALID_PROJ_CURR';
            RETURN;
         WHEN others THEN
            raise;
         END Calculate_project_raw_cost;

      END IF; -- P_project_curr_code = P_denom_curr_code

   ELSE -- P_accounted_flag = 'N'
     /* EPP */
       IF ( P_system_linkage = 'ER' )
       THEN
         IF ( P_acct_curr_code = P_denom_curr_code )
         THEN
             P_acct_raw_cost := P_denom_raw_cost ;
             P_acct_exch_rate := NULL ;
         ELSE
           -- derive P_acct_raw_cost ;
           <<Calculate_acct_raw_cost>>
           BEGIN

	   print_message('Calculate_acct_raw_cost');
           pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                      P_to_currency =>P_acct_curr_code,
                                      P_conversion_date =>P_acct_rate_date,
                                      P_conversion_type =>P_acct_rate_type,
                                      P_amount =>P_denom_raw_cost,
                                      P_user_validate_flag =>'N',
                                      P_handle_exception_flag =>'N',
                                      P_converted_amount =>P_acct_raw_cost,
                                      P_denominator =>l_denominator,
                                      P_numerator =>l_numerator,
                                      P_rate =>P_acct_exch_rate,
                                      X_status =>P_status ) ;

           IF ( P_status IS NOT NULL ) THEN
              -- Error in convert amount
              RETURN;
           END IF;

           EXCEPTION
           WHEN pa_multi_currency.no_rate THEN
              P_status := 'PA_NO_ACCT_CURR_RATE';
              RETURN;
           WHEN pa_multi_currency.invalid_currency THEN
              P_status := 'PA_INVALID_ACCT_CURR';
              RETURN;
           WHEN others THEN
              raise;
           END Calculate_acct_raw_cost;
         END IF; --P_acct_curr_code = P_denom_curr_code

           IF ( P_projfunc_curr_code = P_denom_curr_code )
           THEN
               P_projfunc_raw_cost := P_denom_raw_cost ;
               P_projfunc_cost_exch_rate := NULL ;
           ELSIF ( P_projfunc_curr_code = P_acct_curr_code )
           THEN
               P_projfunc_raw_cost := P_acct_raw_cost ;
               P_projfunc_cost_exch_rate := P_acct_exch_rate ;
           ELSE
               -- derive P_projfunc_raw_cost ;
               <<Calculate_projfunc_raw_cost>>
               BEGIN
               --
               --
		print_message('Calculate_projfunc_raw_cost');
               pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                        P_to_currency =>P_projfunc_curr_code,
                                        P_conversion_date =>P_projfunc_cost_rate_date,
                                        P_conversion_type =>P_projfunc_cost_rate_type,
                                        P_amount =>P_denom_raw_cost,
                                        P_user_validate_flag =>'N',
                                        P_handle_exception_flag =>'N',
                                        P_converted_amount =>P_projfunc_raw_cost,
                                        P_denominator =>l_denominator,
                                        P_numerator =>l_numerator,
                                        P_rate =>P_projfunc_cost_exch_rate,
                                        X_status =>P_status ) ;

               IF ( P_status IS NOT NULL ) THEN
                   -- Error in convert amount
                   RETURN;
               END IF;

               EXCEPTION
               WHEN pa_multi_currency.no_rate THEN
                  P_status := 'PA_NO_PROJFUNC_CURR_RATE';
                  RETURN;
               WHEN pa_Multi_currency.invalid_currency THEN
                  P_status := 'PA_INVALID_PROJFUNC_CURR';
                  RETURN;
               WHEN others THEN
                  raise;
               END Calculate_projfunc_raw_cost;

           END IF; --P_projfunc_curr_code = P_denom_curr_code

           IF ( P_project_curr_code = P_denom_curr_code )
           THEN
               P_project_raw_cost := P_denom_raw_cost ;
               P_project_exch_rate := NULL ;
           ELSIF ( P_project_curr_code = P_acct_curr_code )
           THEN
               P_project_raw_cost := P_acct_raw_cost ;
               P_project_exch_rate := P_acct_exch_rate ;
           ELSIF ( P_project_curr_code = P_projfunc_curr_code )
           THEN
               P_project_raw_cost := P_projfunc_raw_cost ;
               P_project_exch_rate := P_projfunc_cost_exch_rate ;
           ELSE
               -- derive P_project_raw_cost ;
               <<Calculate_project_raw_cost>>
               BEGIN
               --
               --
		print_message('Calculate_project_raw_cost');
               pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                        P_to_currency =>P_project_curr_code,
                                        P_conversion_date =>P_project_rate_date,
                                        P_conversion_type =>P_project_rate_type,
                                        P_amount =>P_denom_raw_cost,
                                        P_user_validate_flag =>'N',
                                        P_handle_exception_flag =>'N',
                                        P_converted_amount =>P_project_raw_cost,
                                        P_denominator =>l_denominator,
                                        P_numerator =>l_numerator,
                                        P_rate =>P_project_exch_rate,
                                        X_status =>P_status ) ;

               IF ( P_status IS NOT NULL ) THEN
                   -- Error in convert amount
                   RETURN;
               END IF;

               EXCEPTION
               WHEN pa_multi_currency.no_rate THEN
                  P_status := 'PA_NO_PROJECT_CURR_RATE';
                  RETURN;
               WHEN pa_Multi_currency.invalid_currency THEN
                  P_status := 'PA_INVALID_PROJ_CURR';
                  RETURN;
               WHEN others THEN
                  raise;
               END Calculate_project_raw_cost;

           END IF; -- P_project_curr_code = P_denom_curr_code
       END IF; -- P_system_linkage = 'ER'

       IF ( P_system_linkage <> 'ER' )
       THEN
         IF( P_projfunc_curr_code = P_denom_curr_code )
         THEN
           P_projfunc_raw_cost := P_denom_raw_cost ;
           P_projfunc_cost_exch_rate := NULL ;
         ELSE
           -- derive P_projfunc_raw_cost ;
           <<Calculate_projfunc_raw_cost>>
              BEGIN
              --
              --
		--dbms_output.put_line('Calculate_projfunc_raw_cost for <> ER');

	   print_message('Before Call to Calculate_acct_raw_cost');

--	   print_message('P_denom_raw_cost ['||P_denom_raw_cost||']');
--	   print_message('P_projfunc_raw_cost ['||P_projfunc_raw_cost||']');
--         print_message('p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']');
--         print_message('p_projfunc_cost_rate_type ['||p_projfunc_cost_rate_type||']');
--         print_message('p_projfunc_cost_exch_rate ['||p_projfunc_cost_exch_rate||']');

--         print_message('Calculate_projfunc_raw_cost for <> ER');

           /* S.N. Bug 3535935 : Typical Case of CWK. Where all currency attributes are derived from PO */

	   IF ( P_PO_Line_ID IS NOT NULL)
	   And ( P_acct_curr_code = P_projfunc_curr_code )
	   /* Bug 3889122 : Calculate only if Non Cross Charnge Txn as in CWK NCC, the PFC should be from PO and FC also */
	   THEN

	   P_projfunc_raw_cost := PA_CURRENCY.round_trans_currency_amt
                              (P_denom_raw_cost * P_projfunc_cost_exch_rate, P_projfunc_curr_code) ;
                              l_denominator := 1 ;
                              l_numerator := P_projfunc_cost_exch_rate ;
          ELSE

           /* E.N. Bug 3535935 : Typical Case of CWK. Where all currency attributes are derived from PO */

	      pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                       P_to_currency =>P_projfunc_curr_code,
                                       P_conversion_date =>P_projfunc_cost_rate_date,
                                       P_conversion_type =>P_projfunc_cost_rate_type,
                                       P_amount =>P_denom_raw_cost,
                                       P_user_validate_flag =>'N',
                                       P_handle_exception_flag =>'N',
                                       P_converted_amount =>P_projfunc_raw_cost,
                                       P_denominator =>l_denominator,
                                       P_numerator =>l_numerator,
                                       P_rate =>P_projfunc_cost_exch_rate,
                                       X_status =>P_status ) ;
                --dbms_output.put_line('pfrc = ['|| to_char(P_projfunc_raw_cost) || ']');

           /* S.N. Bug 3535935 : Typical Case of CWK. Where all currency attributes are derived from PO */
	   END IF;
           /* E.N. Bug 3535935 : Typical Case of CWK. Where all currency attributes are derived from PO */

	   print_message('After Call to Calculate_acct_raw_cost');

--	   print_message('P_denom_raw_cost ['||P_denom_raw_cost||']');
--	   print_message('P_projfunc_raw_cost ['||P_projfunc_raw_cost||']');
--         print_message('p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']');
--         print_message('p_projfunc_cost_rate_type ['||p_projfunc_cost_rate_type||']');
--         print_message('p_projfunc_cost_exch_rate ['||p_projfunc_cost_exch_rate||']');

              IF ( P_status IS NOT NULL ) THEN
                  -- Error in convert amount
                --dbms_output.put_line('Error in convert amount');
                  RETURN;
              END IF;

              EXCEPTION
              WHEN pa_multi_currency.no_rate THEN
		 print_message('Exception Raised in GL currency api');
		 --dbms_output.put_line('Exception Raised in GL currency api');
                 P_status := 'PA_NO_PROJFUNC_CURR_RATE';
                 RETURN;
              WHEN pa_Multi_currency.invalid_currency THEN
		 --dbms_output.put_line('PA_INVALID_PROJFUNC_CURR');
                 P_status := 'PA_INVALID_PROJFUNC_CURR';
                 RETURN;
              WHEN others THEN
                 raise;
              END Calculate_projfunc_raw_cost;
           END IF; --P_projfunc_curr_code = P_denom_curr_code

           IF ( P_acct_curr_code = P_denom_curr_code )
           THEN
               P_acct_raw_cost := P_denom_raw_cost ;
               P_acct_exch_rate := NULL ;
           ELSIF ( P_acct_curr_code = P_projfunc_curr_code )
           THEN
               P_acct_raw_cost := P_projfunc_raw_cost ;
               P_acct_exch_rate := P_projfunc_cost_exch_rate ;
           ELSE
               -- derive P_acct_raw_cost ;
			   If P_PO_Line_ID Is Null Then
				/* Bug 3889122 Calculate FC from GL rates if it is non-cwk transaction */
					   <<Calculate_acct_raw_cost>>
					   BEGIN
							print_message('Calculate_acct_raw_cost for <> ER');
					   pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
												  P_to_currency =>P_acct_curr_code,
												  P_conversion_date =>P_acct_rate_date,
												  P_conversion_type =>P_acct_rate_type,
												  P_amount =>P_denom_raw_cost,
												  P_user_validate_flag =>'N',
												  P_handle_exception_flag =>'N',
												  P_converted_amount =>P_acct_raw_cost,
												  P_denominator =>l_denominator,
												  P_numerator =>l_numerator,
												  P_rate =>P_acct_exch_rate,
												  X_status =>P_status ) ;

					   IF ( P_status IS NOT NULL ) THEN
						  -- Error in convert amount
						  RETURN;
					   END IF;

					   EXCEPTION
					   WHEN pa_multi_currency.no_rate THEN
						  P_status := 'PA_NO_ACCT_CURR_RATE';
						  RETURN;
					   WHEN pa_multi_currency.invalid_currency THEN
						  P_status := 'PA_INVALID_ACCT_CURR';
						  RETURN;
					   WHEN others THEN
						  raise;
					   END Calculate_acct_raw_cost;
			  Else

				/* Bug 3889122 : Calculate FC From PO for CWK transaction */
					P_acct_raw_cost := PA_CURRENCY.round_trans_currency_amt
                              (P_denom_raw_cost * P_acct_exch_rate, P_acct_curr_code) ;
                              l_denominator := 1 ;
                              l_numerator := P_acct_exch_rate ;

			  End If;

           END IF; --P_acct_curr_code = P_denom_curr_code

           IF ( P_project_curr_code = P_denom_curr_code )
           THEN
               P_project_raw_cost := P_denom_raw_cost ;
               P_project_exch_rate := NULL ;
           ELSIF ( P_project_curr_code = P_projfunc_curr_code )
           THEN
               P_project_raw_cost := P_projfunc_raw_cost ;
               P_project_exch_rate := P_projfunc_cost_exch_rate ;
           ELSIF ( P_project_curr_code = P_acct_curr_code )
           THEN
               P_project_raw_cost := P_acct_raw_cost ;
               P_project_exch_rate := P_acct_exch_rate ;
           ELSE
               -- derive P_project_raw_cost ;
               <<Calculate_project_raw_cost>>
               BEGIN
               --
               --
		--dbms_output.put_line('Calculate_project_raw_cost for <> ER');
		print_message('Calculate_project_raw_cost for <> ER');
               pa_multi_currency.convert_amount( P_from_currency =>P_denom_curr_code,
                                        P_to_currency =>P_project_curr_code,
                                        P_conversion_date =>P_project_rate_date,
                                        P_conversion_type =>P_project_rate_type,
                                        P_amount =>P_denom_raw_cost,
                                        P_user_validate_flag =>'N',
                                        P_handle_exception_flag =>'N',
                                        P_converted_amount =>P_project_raw_cost,
                                        P_denominator =>l_denominator,
                                        P_numerator =>l_numerator,
                                        P_rate =>P_project_exch_rate,
                                        X_status =>P_status ) ;
		--dbms_output.put_line('P_project_raw_cost = [' || to_char(P_project_raw_cost) || ']');

               IF ( P_status IS NOT NULL ) THEN
                   -- Error in convert amount
		--dbms_output.put_line('Error in convert amount');
                   RETURN;
               END IF;

               EXCEPTION
               WHEN pa_multi_currency.no_rate THEN
		--dbms_output.put_line('PA_NO_PROJECT_CURR_RATE');
                  P_status := 'PA_NO_PROJECT_CURR_RATE';
                  RETURN;
               WHEN pa_Multi_currency.invalid_currency THEN
		--dbms_output.put_line('PA_INVALID_PROJ_CURR');
                  P_status := 'PA_INVALID_PROJ_CURR';
                  RETURN;
               WHEN others THEN
                  raise;
               END Calculate_project_raw_cost;

           END IF; --P_project_curr_code = P_denom_currency_code
       END IF; -- P_system_linkage <> 'ER'
     /* EPP */

   END IF; -- End p_accounted_flag = 'Y'
   print_message('Converted Amounts are: P_denom_raw_cost ['||P_denom_raw_cost||']P_acct_raw_cost['||
		      P_acct_raw_cost||']P_project_raw_cost['||P_project_raw_cost||']P_projfunc_raw_cost['||
		      P_projfunc_raw_cost ||']' );
   print_message('end of get currency amounts');

   --dbms_output.put_line('from gca prd is [' || to_char(P_project_rate_date) || ']');
   --dbms_output.put_line('from gca pfrd is [' || to_char(P_projfunc_cost_rate_date) || ']');


if l_calling_module = 'WORKPLAN' then /* bug 6058074 */
   G_calling_module := NULL; /* bug 6058074 */
end if;

EXCEPTION
   WHEN others THEN
       P_acct_rate_date :=  l_acct_rate_date;
       P_acct_rate_type := l_acct_rate_type;
       P_acct_exch_rate := l_acct_exch_rate;
       P_acct_raw_cost := l_acct_raw_cost;
       P_project_rate_type := l_project_rate_type;
       P_project_rate_date := l_project_rate_date;
       P_project_exch_rate := l_project_exch_rate;
       P_project_raw_cost := l_project_raw_cost;
       P_projfunc_cost_rate_type := l_projfunc_cost_rate_type;
       P_projfunc_cost_rate_date := l_projfunc_cost_rate_date;
       P_projfunc_cost_exch_rate := l_projfunc_cost_exch_rate;
       P_projfunc_raw_cost := l_projfunc_cost_exch_rate;
       RAISE ;

END get_currency_amounts ;

PROCEDURE Perform_MC_and_IC_processing(
            P_Sys_Link            IN  VARCHAR2,
            P_Request_Id          IN  NUMBER,
            P_Source              OUT NOCOPY VARCHAR2,
            P_MC_IC_status        OUT NOCOPY NUMBER,
            P_Update_Count        OUT NOCOPY NUMBER)
IS

 /*
  *  Variable Declarations
  */

  V_loop_index                NUMBER := 1;
  V_acct_raw_cost             PA_EXPENDITURE_ITEMS.ACCT_RAW_COST%TYPE;
  V_acct_rate_date            PA_EXPENDITURE_ITEMS.ACCT_RATE_DATE%TYPE;
  V_acct_rate_type            PA_EXPENDITURE_ITEMS.ACCT_RATE_TYPE%TYPE;
  V_acct_exchange_rate        PA_EXPENDITURE_ITEMS.ACCT_EXCHANGE_RATE%TYPE;
  V_projfunc_raw_cost         PA_EXPENDITURE_ITEMS.RAW_COST%TYPE;
  V_projfunc_cost_rate_date        PA_EXPENDITURE_ITEMS.projfunc_cost_rate_DATE%TYPE;
  V_projfunc_cost_rate_type        PA_EXPENDITURE_ITEMS.projfunc_cost_rate_TYPE%TYPE;
  V_projfunc_cost_exchange_rate    PA_EXPENDITURE_ITEMS.projfunc_cost_exchANGE_RATE%TYPE;
  V_project_raw_cost          PA_EXPENDITURE_ITEMS.RAW_COST%TYPE;
  V_project_rate_date         PA_EXPENDITURE_ITEMS.PROJECT_RATE_DATE%TYPE;
  V_project_rate_type         PA_EXPENDITURE_ITEMS.PROJECT_RATE_TYPE%TYPE;
  V_project_exchange_rate     PA_EXPENDITURE_ITEMS.PROJECT_EXCHANGE_RATE%TYPE;
  V_system_linkage            PA_EXPENDITURE_ITEMS.SYSTEM_LINKAGE_FUNCTION%TYPE;
  V_status                    VARCHAR2(150);
  V_stage                     NUMBER;
  V_denominator               NUMBER;
  V_numerator                 NUMBER;
  V_cur_status                NUMBER;
  V_errorstage                VARCHAR2(150);
  V_errorcode                 NUMBER;
  V_related_Item              VARCHAR2(1);
  E_local_exception           Exception;
  l_debug_mode        VARCHAR2(1);

  /*
   * 2048868
   */
  l_er_expenditure_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  l_exp_acct_exch_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_exp_already_exists             VARCHAR2(1) := 'N' ;
  l_er_exp_count                   NUMBER := 1 ;

  l_cc_dist_count_tab              PA_PLSQL_DATATYPES.NumTabTyp; /* added for bug#2919885 */

/** CBGA Table Declaration....  to be removed later...
 ** will be declared in PA_Cross_Business_Grp
 ** Will be uncommented when rates-model is decided.
 **         JobIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
 **         JobGroupIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
 **         CostJobIdTab            PA_PLSQL_DATATYPES.IdTabTyp;
 **         V_status_code           VARCHAR2(150);
 **         ErrorStageTab           VARCHAR2(150);
 **         ErrorCodeTab            NUMBER;
**/

  /*
   * This cursor is used to get all the Expenditure Item records
   * Which are being processed by the Cost distribute program.
   * For getting such records, we rely on cost_distributed_flag to be 'S'
   * and use the request_id as passed by the distribute program.
   * This cursor picks up all columns required by the MC/IC APIs
   * and Client Extn. for creating related items. ( in case of labor )
   * The parameter to this cursor is used to process regular and related items
   * separately. This is required to take care of the adjustment of a regular
   * item which has got some related items. In this case, we should not process
   * regular and its related items in the same pass since the cost of the related
   * item is calculated only in the client extension of the regular item
   *
   * Note: denom_currency_code should not be null under normal circumstances.
   * The check is included for safety purpose only.
   * If denom_currency_code is null then acct_currency_code is used.
   *
   * Expenditure organization is passed as incurred_by_organization_id of
   * expenditure if override_to_organization_id in expenditure item
   * doesn't exist. The incurred_by_organization_id value is passed from the
   * cost distribute program.
   *
   * Note: Special processing is done for expenditure items of type
   * 'BTC'. For These type of Txns, the conversion of burden cost
   * in Functional and Project currencies are carried out exactly in the
   * similar manner in which the corresponding conversions are done for raw
   * cost in case of Txns of other type.
   */

    CURSOR  expenditure_item_cursor(l_related_item VARCHAR2) is
	 SELECT
           ITEM.expenditure_item_id,
           ITEM.expenditure_item_date,
           ITEM.Task_Id,
           EXP.expenditure_id,
           NVL(ITEM.Denom_Currency_Code,ITEM.Acct_Currency_Code) Denom_Currency_Code,
           DECODE(ITEM.System_Linkage_Function,'BTC',
                  ITEM.Denom_Burdened_Cost,ITEM.Denom_Raw_Cost) Denom_Raw_Cost,
           ITEM.Acct_Raw_Cost,
           ITEM.Acct_Currency_Code,
           DECODE(ITEM.system_linkage_function, 'ER', EXP.Acct_Rate_Date, ITEM.Acct_Rate_Date) Acct_Rate_Date,
           DECODE(ITEM.system_linkage_function, 'ER', EXP.Acct_Rate_Type, ITEM.Acct_Rate_Type) Acct_Rate_Type,
           DECODE(ITEM.system_linkage_function, 'ER', EXP.Acct_Exchange_Rate, ITEM.Acct_Exchange_Rate) Acct_Exchange_Rate,
           ITEM.Raw_Cost,
           ITEM.Projfunc_Currency_Code,
           ITEM.Projfunc_Cost_Rate_Date,
           ITEM.Projfunc_Cost_Rate_Type,
           ITEM.Projfunc_Cost_Exchange_Rate,
           ITEM.Project_Raw_Cost,
           ITEM.Project_Currency_Code,
           ITEM.Project_Rate_Date,
           ITEM.Project_Rate_Type,
           ITEM.Project_Exchange_Rate,
           ITEM.Source_Expenditure_Item_ID Source_Id,
			  ITEM.Net_Zero_Adjustment_Flag   Net_zero,
           ITEM.org_id,
           ITEM.expenditure_type,
           ITEM.system_linkage_function,
           ITEM.transaction_source,
           TXN.GL_Accounted_Flag, /* Bug #1824407 */
           NVL(ITEM.override_to_organization_id,EXP.incurred_by_organization_id) exp_organization_id,
           ITEM.Organization_Id  nlr_organization_id,
           EXP.incurred_by_person_id,
           ITEM.Cc_Cross_Charge_Type,
           ITEM.Cc_Cross_Charge_Code,
           ITEM.Cc_Prvdr_Organization_Id,
           ITEM.Cc_Recvr_Organization_Id,
           ITEM.Recvr_Org_Id
          ,ITEM.PO_Line_Id                                                   --3535935 hkulkarn
/**CBGA select job_id and project_group_id using API GetProjectGroupId().
 ** To be uncommented after decing upon rates-model.
 **        ITEM.Job_Id,
 **        ITEM.Cost_Job_Id,
 **        PA_Cross_Business_Grp.GetProjectGroupId(TASK.Project_Id, 'C') job_group_id
**/
	 FROM   PA_Expenditure_Items ITEM,
                PA_Expenditures EXP,
                PA_Transaction_Sources TXN  /* Bug 1824407 */
/** To be uncommented after decing upon rates-model.
 ** CBGA Join pa_tasks with pa_expenditure_items_all.
 **        PA_Tasks TASK
**/
    WHERE  ITEM.Cost_Distributed_Flag = 'S'
    AND    ITEM.Cost_Dist_Rejection_Code IS NULL
    AND    ITEM.Request_id = P_request_id
    AND    ITEM.expenditure_id = EXP.expenditure_id
    AND    ITEM.Transaction_Source = TXN.Transaction_Source (+)/*Bug1824407*/
    AND    (( ITEM.Source_Expenditure_Item_Id IS NULL
              AND l_related_item = 'N')
            OR
            ( ITEM.Source_Expenditure_Item_Id IS NOT NULL
              AND l_related_item = 'Y'))
/** To be uncommented after decing upon rates-model.
 ** CBGA Joining pa_tasks with EIs.
 ** AND    ITEM.task_id = TASK.task_id
 **/
;
/******
 * Right now, I cant find out any reason to put this order by,
 * if necessary, i will come back and change this.
    ORDER BY ITEM.Expenditure_Item_Id;
******/
BEGIN
     if pa_cc_utils.g_debug_mode then
       l_debug_mode := 'Y';
     else
       l_debug_mode := 'N';
     end if;
     pa_debug.set_process(
          x_process    => 'PLSQL',
			 x_debug_mode => l_debug_mode);
    pa_cc_utils.set_curr_function('Perform_MC_and_IC_processing');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Start ');
    END IF;
   P_MC_IC_status       := 0;
   P_update_count := 0;

     /*
      * The init procedure is called to set the global variables
      * to be used by the MC API
      */
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before Call to PA_MULTI_CURRENCY.INIT');
     END IF;
     PA_MULTI_CURRENCY.INIT;
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After Call to PA_MULTI_CURRENCY.INIT');
     END IF;
     /*
      * Loop through all expenditure items and set the required
      * Parameter tables with the appropriate values.
      * There is an outer loop of two passes, in the first pass all
      * regular items are processed and in the next all related items are
      * processed. This is done to take care of the case of adjustment
      * of a regular item containing related items. ( in this case, the
      * cost of the related items is calculated only during the client extension
      * call of the regular item and hence we shouldnot fetch the regular items
      * and related items together; otherwise the calculated cost wont be visible to the
      * cursor )
      *
      * We call the MC API within this loop because it doesnt accept
      * array parameters currently. The output values are stored into arrays
      * for later use in the update. The IC API is called outside this loop
      * since array parameters are accepted by it. The final update
      * takes care of both MC and IC.
      */

     FOR  loop_control in 1 .. 2
     LOOP
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'In outer Loop');
     END IF;
       IF ( loop_control = 1 ) THEN
         V_Related_Item := 'N';
       ELSE
         V_Related_Item := 'Y';
       END IF;
       FOR  expenditure_item_rec in expenditure_item_cursor(V_Related_Item)
       LOOP
       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'In related Items Loop');
       END IF;

          P_Source := 'Assignment';
          /*
           * Set the array variables with the appropriate values.
           * Project Org ID is populated with the recvr_org_id value available in EI
           * so that the Identification process doesnt update this value.
           */
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before setting Array variables');
         END IF;

          PA_CC_IDENT.ProjectIdTab(v_loop_index)         := NULL;
          PA_CC_IDENT.PrjOrganizationIdTab(v_loop_index) := NULL;
          PA_CC_IDENT.PrjOrgIdTab(v_loop_index)          := expenditure_item_rec.recvr_org_id;
          PA_CC_IDENT.PrvdrLEIdTab(v_loop_index)         := NULL;
          PA_CC_IDENT.RecvrLEIdTab(v_loop_index)         := NULL;
          PA_CC_IDENT.ExpItemDateTab(v_loop_index)       := expenditure_item_rec.expenditure_item_date;
          PA_CC_IDENT.TaskIdTab(v_loop_index)            := expenditure_item_rec.task_id;
          PA_CC_IDENT.ExpItemIdTab(v_loop_index)         := expenditure_item_rec.expenditure_item_id;
          PA_CC_IDENT.ExpOrgIdTab(v_loop_index)          := expenditure_item_rec.org_id;
          PA_CC_IDENT.ExpTypeTab(v_loop_index)           := expenditure_item_rec.expenditure_type;
          PA_CC_IDENT.SysLinkTab(v_loop_index)           := expenditure_item_rec.system_linkage_function;
          PA_CC_IDENT.TransSourceTab(v_loop_index)       := expenditure_item_rec.transaction_source;
          PA_CC_IDENT.ExpOrganizationIdTab(v_loop_index) := expenditure_item_rec.exp_organization_id;
          PA_CC_IDENT.NLROrganizationIdTab(v_loop_index) := expenditure_item_rec.nlr_organization_id;
          PA_CC_IDENT.PersonIdTab(v_loop_index)          := expenditure_item_rec.incurred_by_person_id;
          PA_CC_IDENT.CrossChargeTypeTab(v_loop_index)   := expenditure_item_rec.cc_cross_charge_type;
          PA_CC_IDENT.CrossChargeCodeTab(v_loop_index)   := expenditure_item_rec.cc_cross_charge_code;
          PA_CC_IDENT.PrvdrOrganizationIdTab(v_loop_index):= expenditure_item_rec.cc_prvdr_organization_id;
          PA_CC_IDENT.RecvrOrganizationIdTab(v_loop_index):= expenditure_item_rec.cc_recvr_organization_id;
          PA_CC_IDENT.RecvrOrgIdTab(v_loop_index)        := expenditure_item_rec.recvr_org_id;
          V_acct_rate_date                               := expenditure_item_rec.acct_rate_date;
          V_acct_rate_type                               := expenditure_item_rec.acct_rate_type;
          V_acct_exchange_rate                           := expenditure_item_rec.acct_exchange_rate;
          V_projfunc_cost_rate_type                      := expenditure_item_rec.projfunc_cost_rate_type;
          V_projfunc_cost_rate_date                      := expenditure_item_rec.projfunc_cost_rate_date;
          V_projfunc_cost_exchange_rate                  := expenditure_item_rec.projfunc_cost_exchange_rate;
          V_project_rate_type                            := expenditure_item_rec.project_rate_type;
          V_project_rate_date                            := expenditure_item_rec.project_rate_date;
          V_project_exchange_rate                        := expenditure_item_rec.project_exchange_rate;
          V_status                                       := NULL; -- Bug 4142911

/** To be uncommented after decing upon rates-model.
 ** CBGA The array variables for GetMappedToJobs () are populated here.
 **
 **         JobIdTab     (v_loop_index)       := expenditure_item_rec.job_id;
 **         JobGroupIdTab(v_loop_index)       := expenditure_item_rec.job_group_id;
 **         CostJobIdTab (v_loop_index)       := expenditure_item_rec.cost_job_id;
 **         V_status_code                     := NULL;        -- x_status_code
 **         ErrorStageTab(v_loop_index)       := NULL;        -- x_error_stage_tab
 **         ErrorCodeTab (v_loop_index)       := NULL;        -- x_error_code_tab
 **
**/
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After setting Array variables');
         END IF;

          /*
           * MC API is to be called ( for getting Acct/Project raw cost )
           * only when any of the three buckets are empty.
           */
          IF ( expenditure_item_rec.acct_raw_cost  IS NULL
               OR
               expenditure_item_rec.raw_cost IS NULL
               OR
               expenditure_item_rec.project_raw_cost IS NULL) THEN
                  /*
                   * Set the source. Its value is used by the calling program
                   * only when the status <> 0
                   */
                  P_Source := 'MC Error';
             IF P_DEBUG_MODE  THEN
                pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before Call to PA_MULTI_CURRENCY_TXN.GET_CURRENCY_AMOUNTS');
             END IF;
                  If nvl(expenditure_item_rec.GL_Accounted_Flag,'N') = 'Y' THEN

                     V_acct_raw_cost := expenditure_item_rec.acct_raw_cost ;
                     V_acct_rate_date := expenditure_item_rec.acct_rate_date ;
                     V_acct_exchange_rate := expenditure_item_rec.acct_exchange_rate ;
                     V_acct_rate_type :=  expenditure_item_rec.acct_rate_type ;
                  End If;

            IF expenditure_item_rec.Po_Line_Id IS NOT NULL THEN    --3535935 hkulkarn

               V_project_rate_date       := V_acct_rate_date;
               V_project_rate_type       := V_acct_rate_type;
               V_project_exchange_rate   := V_acct_exchange_rate;

               V_projfunc_cost_rate_date       := V_acct_rate_date;
               V_projfunc_cost_rate_type       := V_acct_rate_type;
               V_projfunc_cost_exchange_rate   := V_acct_exchange_rate;

--                       print_message('P_denom_curr_code['||expenditure_item_rec.denom_currency_code);
--                       print_message('P_project_curr_code['||expenditure_item_rec.project_currency_code);
--                       print_message('P_acct_curr_code['||expenditure_item_rec.acct_currency_code);
--                       print_message('P_accounted_flag['||nvl(expenditure_item_rec.GL_Accounted_Flag,'N'));
--                       print_message('P_projfunc_curr_code['||expenditure_item_rec.projfunc_currency_code||']' );
--                       print_message('p_acct_rate_date ['||V_acct_rate_date||']');
--                       print_message('p_acct_rate_type ['||V_acct_rate_type ||']');
--                       print_message('p_acct_exch_rate  ['||V_acct_exchange_rate ||']');
--                       print_message('p_project_rate_type ['||V_project_rate_type||']');
--                       print_message('p_project_exch_rate ['||V_project_rate_date||']');
--                       print_message('p_projfunc_cost_rate_date ['||V_projfunc_cost_rate_date||']');
--                       print_message('p_projfunc_cost_rate_type ['||V_projfunc_cost_rate_type||']');
--                       print_message('p_projfunc_cost_exch_rate ['||V_projfunc_cost_exchange_rate||']');


            END IF ;  --3535935 hkulkarn

                  PA_MULTI_CURRENCY_TXN.GET_CURRENCY_AMOUNTS(
		      p_project_id          =>  null,
		      p_exp_org_id          =>  null,
		      p_calling_module      =>  null,
                      P_task_id             =>  expenditure_item_rec.task_id,
                      P_Ei_date             =>  expenditure_item_rec.expenditure_item_date,
                      P_denom_raw_cost      =>  expenditure_item_rec.denom_raw_cost,
                      P_denom_curr_code     =>  expenditure_item_rec.denom_currency_code,
                      P_acct_curr_code      =>  expenditure_item_rec.acct_currency_code,
                      P_accounted_flag      => nvl(expenditure_item_rec.GL_Accounted_Flag,'N'), /*Bug 1824407 */
                      P_acct_rate_date      =>  V_acct_rate_date,
                      P_acct_rate_type      =>  V_acct_rate_type,
                      P_acct_exch_rate      =>  V_acct_exchange_rate,
                      P_acct_raw_cost       =>  V_acct_raw_cost,
                      P_project_curr_code   =>  expenditure_item_rec.project_currency_code,
                      P_project_rate_type   =>  V_project_rate_type,
                      P_project_rate_date   =>  V_project_rate_date,
                      P_project_exch_rate   =>  V_project_exchange_rate,
                      P_project_raw_cost   =>  V_project_raw_cost,
                      P_projfunc_curr_code  =>  expenditure_item_rec.projfunc_currency_code,
                      P_projfunc_cost_rate_type  =>  V_projfunc_cost_rate_type,
                      P_projfunc_cost_rate_date  =>  V_projfunc_cost_rate_date,
                      P_projfunc_cost_exch_rate  =>  V_projfunc_cost_exchange_rate,
                      P_projfunc_raw_cost   =>  V_projfunc_raw_cost,
                      P_system_linkage      =>  expenditure_item_rec.system_linkage_function,
                      P_status              =>  V_status,
                      P_stage               =>  V_stage,
		      P_Po_Line_ID          =>  expenditure_item_rec.Po_Line_Id);
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After Call to PA_MULTI_CURRENCY_TXN.GET_CURRENCY_AMOUNTS');

         END IF;
               /*
                * 2048868
                */
                    IF ( expenditure_item_rec.system_linkage_function = 'ER' )
                    THEN
                        IF ( l_er_expenditure_id_tab.count > 0 )
                        THEN
                          IF P_DEBUG_MODE  THEN
                             pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Size of the ER table [' || to_char(l_er_expenditure_id_tab.count) || ']');
                          END IF;
                            /*
                             * The table is not expty.
                             * Check whether this expenditure_id is already available in
                             * the table. If it already exists, set l_exp_already_exists to 'Y'.
                             */
                            l_exp_already_exists := 'N' ;
                            FOR LOOP_INDEX IN l_er_expenditure_id_tab.first..l_er_expenditure_id_tab.last
                            LOOP
                              IF P_DEBUG_MODE  THEN
                                 pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Comparing [' || to_char(expenditure_item_rec.expenditure_id) ||
                                                     '] with [' || to_char(l_er_expenditure_id_tab(LOOP_INDEX)) || ']' );
                              END IF;
                                IF ( expenditure_item_rec.expenditure_id = l_er_expenditure_id_tab(LOOP_INDEX) )
                                THEN
                                    l_exp_already_exists := 'Y' ;
                                    exit ;
                                END IF ;
                            END LOOP ;
                        END IF;

                        IF P_DEBUG_MODE  THEN
                           pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Already exists [' || l_exp_already_exists || ']');
                        END IF;
                        IF ( nvl(l_exp_already_exists, 'N') = 'N' )
                        THEN
                            /*
                             * The current expenditure is not in the table.
                             * So, add it.
                             */
                            l_er_expenditure_id_tab(l_er_exp_count) := expenditure_item_rec.expenditure_id ;
                            l_exp_acct_exch_rate_tab(l_er_exp_count) := V_acct_exchange_rate ;
                            IF P_DEBUG_MODE  THEN
                               pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'New id [' || to_char(l_er_expenditure_id_tab(l_er_exp_count)) ||
                                      '] rate [' || to_char(l_exp_acct_exch_rate_tab(l_er_exp_count)) || ']' );
                            END IF;
                            l_er_exp_count := l_er_exp_count + 1 ;
                        END IF;
                    END IF ; -- 'ER'
               /*
                * 2048868
                */

           END IF;
           /*
            * The output values are stored into array for later use in the update.
            *
            * Note: These assigments need not to be kept within the previous if statement
            *       because the variables are initialized with the existing values
            *       of the EIs before the MC Call. So even if MC call is not made
            *       ( because of the existence of both the buckets ) the old
            *       values will be assigned to the array elelemnts. So, final update
            *       will update the columns with the existing values only and that is fine.
            */
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before storing in Array ');
         END IF;

           PA_CC_IDENT.DenomCurrCodeTab(v_loop_index)        := expenditure_item_rec.denom_currency_code;
           PA_CC_IDENT.AcctRawCostTab(v_loop_index)          := V_acct_raw_cost;
  /* This needs to be changed later bug951161 */
           PA_CC_IDENT.AcctRateDateTab(v_loop_index)         := to_char(V_acct_rate_date,
                                                                 'dd-mon-yyyy hh:mi:ss');
           PA_CC_IDENT.AcctRateTypeTab(v_loop_index)         := V_acct_rate_type;
           PA_CC_IDENT.AcctRateTab(v_loop_index)             := V_acct_exchange_rate;

           PA_CC_IDENT.ProjFuncRawCostTab(v_loop_index)      := V_projfunc_raw_cost;
           PA_CC_IDENT.ProjFuncRateDateTab(v_loop_index)     := to_char(V_projfunc_cost_rate_date,
                                                                  'dd-mon-yyyy hh:mi:ss');
           PA_CC_IDENT.ProjFuncRateTypeTab(v_loop_index)     := V_projfunc_cost_rate_type;
           PA_CC_IDENT.ProjFuncRateTab(v_loop_index)         := V_projfunc_cost_exchange_rate;

           PA_CC_IDENT.ProjRawCostTab(v_loop_index)          := V_project_raw_cost;
  /* This needs to be changed later bug951161 */
           PA_CC_IDENT.ProjRateDateTab(v_loop_index)         := to_char(V_project_rate_date,
                                                                  'dd-mon-yyyy hh:mi:ss');
           PA_CC_IDENT.ProjRateTypeTab(v_loop_index)         := V_project_rate_type;
           PA_CC_IDENT.ProjRateTab(v_loop_index)             := V_project_exchange_rate;
           PA_CC_IDENT.StatusTab(v_loop_index)               := V_status;
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After storing in Array ');
         END IF;
           /*
            * Call the client extn. for creating related items
            * ( for labor )
            *
            * If Oracle error is retured ( v_cur_status < 0) then
            * an exception is raised and processing is halted. The
            * control goes back to the calling program and appropriate error
            * handling is done based on the output status variable as set.
            *
            * If application error is retured ( v_cur_status > 0) then
            * appropriate cost_dist_rejection_code is populated in the status array and
            * processing continues with the next record.
            * Here the same status variable as MC is reused.
            */

	        IF (   expenditure_item_rec.Source_Id IS NULL
		        /*AND (NVL(expenditure_item_rec.net_zero, 'N') = 'N') */ /*Bug 4460518*/
              AND P_Sys_Link = 'LABOR')  THEN
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before call to PA_Costing_Client_Extns.Add_Transactions_Hook');
         END IF;

	               PA_Costing_Client_Extns.Add_Transactions_Hook(
                      expenditure_item_rec.expenditure_item_id,
                      expenditure_item_rec.system_linkage_function,
				          v_cur_status);
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After call to PA_Costing_Client_Extns.Add_Transactions_Hook');
         END IF;
              IF  ( v_cur_status < 0 ) THEN
                 P_Source := 'Client Extn';
                 P_MC_IC_status := v_cur_status;
                 RAISE E_local_exception;
              END IF;
              IF  ( v_cur_status > 0 ) THEN
                PA_CC_IDENT.StatusTab(v_loop_index)               := 'ADD_TRANSACTIONS_EXT_FAIL';
              END IF;
	        END IF;

          V_loop_index   := V_loop_index + 1;
       END LOOP;
     END LOOP;


     /*
      * Subtract 1 from loop index to get the
      * actual no of times the previous loop is executed
      */
     V_loop_index := V_loop_index -1;

     /*
      * Set the source. Its value is used by the calling program
      * only when the status <> 0
      */
     P_Source := 'IC Error';

     /*
      * Call IC API to get the provider-receiver org
      * and cross-charge code
      */
     IF V_loop_index > 0 THEN
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before call to PA_CC_IDENT.PA_CC_IDENTIFY_TXN');
         END IF;
       PA_CC_IDENT.PA_CC_IDENTIFY_TXN(
            P_ExpOrganizationIdTab           => PA_CC_IDENT.ExpOrganizationIdTab,
            P_ExpOrgIdTab                    => PA_CC_IDENT.ExpOrgIdTab,
            P_ProjectIdTab                   => PA_CC_IDENT.ProjectIdTab,
            P_TaskIdTab                      => PA_CC_IDENT.TaskIdTab,
            P_ExpItemDateTab                 => PA_CC_IDENT.ExpItemDateTab,
            P_ExpItemIdTab                   => PA_CC_IDENT.ExpItemIdTab,
            P_PersonIdTab                    => PA_CC_IDENT.PersonIdTab,
            P_ExpTypeTab                     => PA_CC_IDENT.ExpTypeTab,
            P_SysLinkTab                     => PA_CC_IDENT.SysLinkTab,
            P_PrjOrganizationIdTab           => PA_CC_IDENT.PrjOrganizationIdTab,
            P_PrjOrgIdTab                    => PA_CC_IDENT.PrjOrgIdTab,
            P_TransSourceTab                 => PA_CC_IDENT.TransSourceTab,
            P_NLROrganizationIdTab           => PA_CC_IDENT.NLROrganizationIdTab,
            P_PrvdrLEIdTab                   => PA_CC_IDENT.PrvdrLEIdTab,
            P_RecvrLEIdTab                   => PA_CC_IDENT.RecvrLEIdTab,
            X_StatusTab                      => PA_CC_IDENT.StatusTab,
            X_CrossChargeTypeTab             => PA_CC_IDENT.CrossChargeTypeTab,
            X_CrossChargeCodeTab             => PA_CC_IDENT.CrossChargeCodeTab,
            X_PrvdrOrganizationIdTab         => PA_CC_IDENT.PrvdrOrganizationIdTab,
            X_RecvrOrganizationIdTab         => PA_CC_IDENT.RecvrOrganizationIdTab,
            X_RecvrOrgIdTab                  => PA_CC_IDENT.RecvrOrgIdTab,
            X_Error_Stage                    => V_Errorstage,
            X_Error_Code                     => V_Errorcode);
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After Call to PA_CC_IDENT.PA_CC_IDENTIFY_TXN');
         END IF;
     END IF;

/** To be uncommented after decing upon rates-model.
 ** CBGA Call to GetMappedToJobs ().
 **
 **  IF V_loop_index > 0 THEN
 **      pa_cc_utils.log_message('Before call to GetMappedToJobs');
 **      PA_Cross_Business_Grp.GetMappedToJobs (
 **         p_from_job_id_tab             => JobIdTab,
 **         p_to_job_group_id_tab         => JobGroupIdTab,
 **         x_to_job_id_tab               => CostJobIdTab,
 **         x_status_code                 => V_Statuscode,
 **         x_error_stage_tab             => ErrorStageTab,
 **         x_error_code_tab              => ErrorCodeTab
 **                       );
 **      pa_cc_utils.log_message('After Call to GetMappedToJobs');
 **  END IF;
 **
**/

      /*
       * Set the source. Its value is used by the calling program
       * only when the status <> 0
       */
      P_Source := 'Update Error';
      /*
       * Bug2048868
       */
      l_er_exp_count := l_er_exp_count - 1 ;
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before updating Expenditures. Count to update [' || to_char(l_er_exp_count) || ']');
      END IF;
      IF ( l_er_exp_count > 0 )
      THEN
        FORALL i IN 1..l_er_exp_count
            UPDATE pa_expenditures exp
               SET exp.Acct_Exchange_rate = l_exp_acct_exch_rate_tab(i)
             WHERE exp.expenditure_id = l_er_expenditure_id_tab(i)
            ;
      END IF; -- l_er_exp_count
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After updating Expenditures with exchange rate.');
      END IF;
      /*
       * End Bug2048868
       */
      /*
       * Final update statement to update all the relevant columns for
       * MC as well as IC. ( arrays are used for that )
       *
       * Note: The MC related column are updated only when the cost in the
       *       appropriate currency is not available and the MC/IC API hasnot returned
       *       any error.
       *       The IC related columns are updated only when the MC/IC API hasnot returned
       *       any error.
       *
       *       Denom_Currency_Code shouldn't be null under normal circumstances,
       *       for safety purpose it is set to accounting currency code if it's value
       *       is null.
       */
      IF V_loop_index > 0 THEN


         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'Before Final update statement');
         END IF;

       /* added for bug#2919885 */
      FOR LOOP_INDEX IN 1..V_loop_index LOOP
        select count(*) into l_cc_dist_count_tab(loop_index)
         from pa_cc_dist_lines_all
         where expenditure_item_id = PA_CC_IDENT.ExpItemIdTab(loop_index)
          and line_type = 'BL' ;    /*Bug# 3184731 :Excluding line_type ='PC' here */
      END LOOP;


      FORALL  LOOP_INDEX IN 1..V_loop_index


      UPDATE   Pa_Expenditure_Items ITEM
        SET    ITEM.Denom_Currency_Code =
                 DECODE(ITEM.Denom_Currency_Code, NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.DenomCurrCodeTab(loop_index),
                     ITEM.Denom_Currency_Code),
                   ITEM.Denom_Currency_Code),

               ITEM.Cost_Dist_Rejection_Code =
                 PA_CC_IDENT.StatusTab(loop_index),

/** To be uncommented after decing upon rates-model.
 ** CBGA StatusTab contains the status information for the call pa_cc_identify_txn.
 **     ErrorStageTab contains the status information for the call GetMappedToJobs.
 **     The rejection code is set - when either of them is NOT NULL.
 **
 **            ITEM.Cost_Dist_Rejection_Code =
 **              decode ( PA_CC_IDENT.StatusTab(loop_index), NULL,
 **                       ErrorStageTab(loop_index) ,
 **                       PA_CC_IDENT.StatusTab(loop_index)
 **                     ),
**/
               ITEM.Burden_Cost                =
                 DECODE(ITEM.Burden_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       PA_CC_IDENT.ProjFuncRawCostTab(loop_index),   /* Replaced ProjRawCostTab by ProjFuncRawCostTab for bug 3285759 */
                       ITEM.Burden_Cost),
                     ITEM.Burden_Cost),
                   ITEM.Burden_Cost),
/***** Added for 3285759 */
               ITEM.Project_Burdened_Cost                =
                 DECODE(ITEM.Project_Burdened_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       PA_CC_IDENT.ProjRawCostTab(loop_index),
                       ITEM.Project_Burdened_Cost),
                     ITEM.Project_Burdened_Cost),
                   ITEM.Project_Burdened_Cost),
/***** Added for 3285759 End */
               ITEM.Acct_Burdened_Cost         =
                 DECODE(ITEM.Acct_Burdened_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       PA_CC_IDENT.AcctRawCostTab(loop_index),
                       ITEM.Acct_Burdened_Cost),
                     ITEM.Acct_Burdened_Cost),
                   ITEM.Acct_Burdened_Cost),
               ITEM.Raw_Cost                 =
                 DECODE(ITEM.Raw_Cost, NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       0,
                       PA_CC_IDENT.ProjFuncRawCostTab(loop_index)),
                     ITEM.Raw_Cost),
                   ITEM.Raw_Cost),
               ITEM.ProjFunc_Cost_Exchange_Rate    =
                 DECODE(ITEM.Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.ProjFuncRateTab(loop_index),
                     ITEM.ProjFunc_Cost_Exchange_Rate),
                   ITEM.ProjFunc_Cost_exchange_Rate),
               ITEM.projfunc_cost_rate_Date        =
                 DECODE(ITEM.Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     to_date(PA_CC_IDENT.ProjFuncRateDateTab(loop_index),'dd-mm-yyyy hh:mi:ss'),
                     ITEM.projfunc_cost_rate_Date),
                   ITEM.projfunc_cost_rate_Date),
               ITEM.projfunc_cost_rate_Type        =
                 DECODE(ITEM.Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.ProjFuncRateTypeTab(loop_index),
                     ITEM.projfunc_cost_rate_Type),
                   ITEM.projfunc_cost_rate_Type),
               ITEM.Project_Raw_Cost                 =
                 DECODE(ITEM.Project_Raw_Cost, NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       0,
                       PA_CC_IDENT.ProjRawCostTab(loop_index)),
                     ITEM.Project_Raw_Cost),
                   ITEM.Project_Raw_Cost),
               ITEM.Project_Exchange_Rate    =
                 DECODE(ITEM.Project_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.ProjRateTab(loop_index),
                     ITEM.Project_Exchange_Rate),
                   ITEM.Project_exchange_Rate),
               ITEM.Project_Rate_Date        =
                 DECODE(ITEM.Project_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     to_date(PA_CC_IDENT.ProjRateDateTab(loop_index),'dd-mm-yyyy hh:mi:ss'),
                     ITEM.Project_Rate_Date),
                   ITEM.Project_Rate_Date),
               ITEM.Project_Rate_Type        =
                 DECODE(ITEM.Project_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.ProjRateTypeTab(loop_index),
                     ITEM.Project_Rate_Type),
                   ITEM.Project_Rate_Type),
               ITEM.Acct_Raw_Cost            =
                 DECODE(ITEM.Acct_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     DECODE(ITEM.System_Linkage_Function,'BTC',
                       0,
                       PA_CC_IDENT.AcctRawCostTab(loop_index)),
                     ITEM.Acct_Raw_Cost),
                   ITEM.Acct_Raw_Cost),
               ITEM.Acct_Exchange_Rate       =
                 DECODE(ITEM.Acct_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.AcctRateTab(loop_index),
                     ITEM.Acct_Exchange_Rate),
                   ITEM.Acct_Exchange_Rate),
               ITEM.Acct_Rate_Date           =
                 DECODE(ITEM.Acct_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                      to_date(PA_CC_IDENT.AcctRateDateTab(loop_index),'dd-mm-yyyy hh:mi:ss'),
                     ITEM.Acct_Rate_Date),
                   ITEM.Acct_Rate_Date),
               ITEM.Acct_Rate_Type           =
                 DECODE(ITEM.Acct_Raw_Cost,NULL,
                   DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                     PA_CC_IDENT.AcctRateTypeTab(loop_index),
                     ITEM.Acct_Rate_Type),
                   ITEM.Acct_Rate_Type),
               ITEM.Cc_Cross_Charge_Code     =
                Decode(ITEM.Cc_Cross_Charge_Code,'P',         -- Added Decode wrapper to update only for P case 3173932
                 DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                   PA_CC_IDENT.CrossChargeCodeTab(loop_index),
                   ITEM.Cc_Cross_Charge_Code),ITEM.Cc_Cross_Charge_Code),
               ITEM.Cc_Cross_Charge_Type     =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                   PA_CC_IDENT.CrossChargeTypeTab(loop_index),
                   ITEM.Cc_Cross_Charge_Type),
               ITEM.Cc_Bl_Distributed_Code        =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index), NULL,
                   DECODE(PA_CC_IDENT.CrossChargeCodeTab(loop_index),'B',
                     'N',
                     DECODE(l_cc_dist_count_tab(loop_index),0,'X','N')), /* bug#2919885 */
                   ITEM.Cc_Bl_Distributed_Code),
               ITEM.Cc_IC_Processed_Code        =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index), NULL,
                   DECODE(PA_CC_IDENT.CrossChargeCodeTab(loop_index),'I',
                     'N',
                     'X'),
                   ITEM.Cc_IC_processed_Code),
               ITEM.Cc_Prvdr_Organization_Id =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                   PA_CC_IDENT.PrvdrOrganizationIdTab(loop_index),
                   ITEM.Cc_Prvdr_Organization_Id),
               ITEM.Cc_Recvr_Organization_Id =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                   PA_CC_IDENT.RecvrOrganizationIdTab(loop_index),
                   ITEM.Cc_Recvr_Organization_Id),
               ITEM.Recvr_Org_Id =
                 DECODE(PA_CC_IDENT.StatusTab(loop_index),NULL,
                   PA_CC_IDENT.RecvrOrgIdTab(loop_index),
                   ITEM.Recvr_Org_Id)

/** To be uncommented after decing upon rates-model.
 ** CBGA Updating Cost_Job_Id in EI.
 **            ITEM.cost_job_id =
 **              DECODE(ErrorStageTab(loop_index),NULL,
 **                CostJobIdTab(loop_index),
 **                ITEM.cost_job_id)
 **/
        WHERE  ITEM.Expenditure_Item_Id      = PA_CC_IDENT.ExpItemIdTab(loop_index);

	/*Code Changes for Bug No.2984871 start */
	P_Update_Count := SQL%ROWCOUNT;
	/*Code Changes for Bug No.2984871 end */

        END IF;
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'After Final Update Statement');
         END IF;
        /*
         * No of records updated is set to the output parameter.
         */
	/* Commented for Bug 2984871
	P_Update_Count := SQL%ROWCOUNT;	*/

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('Perform_MC_and_IC_processing: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

EXCEPTION
  /*
   * This exception is raised in case of Oracle error in
   * the client extn. The control is retured back to the calling
   * program. Error handling to be done over there.
   */
  WHEN E_local_exception THEN
   RAISE;
 /*
  * Commented during bug 1943559
  * NULL;
  */

/*
   * Any other error encountered either in MC or IC processing.
   * Set the status variable and control is returned back to the
   * calling program.
   * Note: Source is already populated in the processing part.
   */
  WHEN OTHERS THEN
    IF V_errorcode IS NOT NULL THEN
      P_MC_IC_STATUS := V_errorcode;
    ELSE
      P_MC_IC_Status := SQLCODE;
    END IF;

END Perform_MC_and_IC_processing;

/*---------------------------------------------------------------------*/
PROCEDURE get_proj_rate_type   ( P_task_id               IN NUMBER
                                ,p_project_id            IN pa_projects_all.project_id%TYPE DEFAULT NULL
                                ,p_structure_version_id  IN NUMBER DEFAULT NULL
                                ,p_calling_module        IN VARCHAR2
                                ,P_project_currency_code IN OUT NOCOPY VARCHAR2
                                ,P_project_rate_type     IN OUT NOCOPY VARCHAR2
                               )
IS

BEGIN

   --
   -- This procedure derives project currency code and
   -- project currency conversion rate type
   --
   -- Logic: if the user provides a proj_rate_type, use it.
   -- Otherwise derive it from the task, if project_rate_type is not
   -- defined at task level then get it from project level. If project_rate_type
   -- is not defined at project level also then derive the
   -- project_rate_type value from default_rate_type column in
   -- project owning operating units implementation options table.
   -- proj_currency_code is derived from projects table

  IF (p_calling_module <> 'WORKPLAN') THEN

     SELECT    proj.project_currency_code,
               NVL(P_project_rate_type, NVL(NVL(task.project_rate_type,
                   proj.project_rate_type), imp.default_rate_type))
       INTO    P_project_currency_code,
               P_project_rate_type
       FROM    pa_projects_all proj,
               pa_tasks task,
               pa_implementations_all imp
      WHERE    proj.project_id       = task.project_id
        AND    task.task_id          = P_task_id
        AND    proj.org_id = imp.org_id;

  ELSE

         BEGIN

              SELECT    proj.project_currency_code,
                        NVL(P_project_rate_type, NVL(NVL(task.project_rate_type,
                            proj.project_rate_type), imp.default_rate_type))
                INTO    P_project_currency_code,
                        P_project_rate_type
                FROM    pa_projects_all proj,
                        pa_tasks task,
                        pa_map_wp_to_fin_tasks_v map_wp_fin,
                        pa_implementations_all imp
               WHERE    proj.project_id            = p_project_id
                 AND    task.task_id               = map_wp_fin.mapped_fin_task_id
                 AND    map_wp_fin.proj_element_id = p_task_id
                 AND    map_wp_fin.parent_structure_version_id = p_structure_version_id
                 AND    proj.org_id = imp.org_id;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                      SELECT    proj.project_currency_code,
                                NVL(NVL(P_project_rate_type, proj.project_rate_type)
                                    , imp.default_rate_type)
                        INTO    P_project_currency_code,
                                P_project_rate_type
                        FROM    pa_projects_all proj,
                                pa_implementations_all imp
                       WHERE    proj.project_id            = p_project_id
                         AND    proj.org_id = imp.org_id;
         END ; -- anonymous

  END IF;


EXCEPTION
   WHEN no_data_found THEN
      P_project_currency_code := NULL;
      P_project_rate_type     := NULL;

   WHEN others THEN
      RAISE ;

END get_proj_rate_type ;

/*---------------------------------------------------------------------*/
PROCEDURE get_proj_rate_date ( P_task_id              IN NUMBER ,
                               P_project_id           IN pa_projects_all.project_id%TYPE DEFAULT NULL   ,
                               P_EI_date              IN DATE   ,
                               p_structure_version_id IN NUMBER DEFAULT NULL,
                               p_calling_module       IN VARCHAR2,
                               P_project_rate_date    IN OUT NOCOPY DATE )
IS

BEGIN

--
-- This procedure derives project currency conversion rate date
--
-- Logic:  If user provides a project currency conversion date, Use it.
-- Otherwise derive it from task( identified bt P_task_id),
-- if project_rate_date is not defined at task level then derive it from
-- projects table.  If the project_rate_date is not defined at project
-- level also then the proj_rate_date will be derived using the
-- default_rate_date_code from expenditure operating units implementation
-- options. If the default_rate_date_code is E then return the expenditure
-- item date(P_EI_date), if default_rate_date_code is P then return the
-- PA period ending date.

    IF ( P_project_rate_date IS NULL )
    THEN
      IF (p_calling_module <> 'WORKPLAN')
      THEN
        SELECT  NVL(NVL(task.project_rate_date,
                proj.project_rate_date),
                                         DECODE(imp.default_rate_date_code,
                                         'E', P_EI_date, 'P',
                                         pa_utils2.get_pa_date(P_EI_date,
                                         sysdate, imp.org_id)))           /**CBGA**/
        INTO   P_project_rate_date
        FROM   pa_projects_all proj,
               pa_tasks task,
               pa_implementations_all imp
        WHERE  task.task_id = P_task_id
          AND  proj.project_id = task.project_id
          AND  nvl(proj.org_id, -99) = nvl(imp.org_id, -99);
      ELSE
        BEGIN
              SELECT task.project_rate_date
                INTO P_project_rate_date
                FROM pa_tasks task
                    ,pa_map_wp_to_fin_tasks_v map_wp_fin
              WHERE task.task_id = map_wp_fin.mapped_fin_task_id
                AND map_wp_fin.proj_element_id = p_task_id
                AND map_wp_fin.parent_structure_version_id = p_structure_version_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                      NULL;
        END ; -- anonymous
        IF ( P_project_rate_date IS NULL )
        THEN
              SELECT  NVL(proj.project_rate_date,
                                               DECODE(imp.default_rate_date_code,
                                               'E', P_EI_date, 'P',
                                               pa_utils2.get_pa_date(P_EI_date,
                                               sysdate, imp.org_id)))
                INTO  P_project_rate_date
                FROM  pa_projects_all proj
                     ,pa_implementations_all imp
               WHERE  proj.project_id = p_project_id
                 AND  nvl(proj.org_id, -99) = nvl(imp.org_id, -99);
        END IF;
      END IF; -- calling_module
   END IF ;


EXCEPTION
   WHEN no_data_found THEN
        P_project_rate_date := NULL ;

   WHEN others THEN
        P_project_rate_date := NULL ;
        RAISE ;

END get_proj_rate_date ;


/** The following new parameters are added for the FI changes
 *  p_project_id   IN pa_projects_all.project_id%type
 *  p_exp_org_id   IN pa_projects_all.org_id%type
 **/
PROCEDURE get_currency_attributes
          (P_project_id              IN pa_projects_all.project_id%type default NULL,
	       P_exp_org_id              IN pa_projects_all.org_id%type  default NULL,
	       P_task_id                 IN pa_expenditure_items_all.task_id%TYPE,
           P_ei_date                 IN pa_expenditure_items_all.expenditure_item_date%TYPE,
           P_calling_module          IN VARCHAR2,
           P_denom_curr_code         IN pa_expenditure_items_all.denom_currency_code%TYPE,
           P_accounted_flag          IN VARCHAR2 DEFAULT 'N',
           P_acct_curr_code          IN pa_expenditure_items_all.acct_currency_code%TYPE,
           X_acct_rate_date          IN OUT NOCOPY pa_expenditure_items_all.acct_rate_date%TYPE,
           X_acct_rate_type          IN OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE,
           X_acct_exch_rate          IN OUT NOCOPY pa_expenditure_items_all.acct_exchange_rate%TYPE,
           P_project_curr_code       IN pa_expenditure_items_all.project_currency_code%TYPE,
           X_project_rate_date       IN OUT NOCOPY pa_expenditure_items_all.project_rate_date%TYPE,
           X_project_rate_type       IN OUT NOCOPY pa_expenditure_items_all.project_rate_type%TYPE ,
           X_project_exch_rate       IN OUT NOCOPY pa_expenditure_items_all.project_exchange_rate%TYPE,
           P_projfunc_curr_code      IN pa_expenditure_items_all.projfunc_currency_code%TYPE,
           X_projfunc_cost_rate_date IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_date%TYPE,
           X_projfunc_cost_rate_type IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_type%TYPE ,
           X_projfunc_cost_exch_rate IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_exchange_rate%TYPE,
           P_system_linkage          IN pa_expenditure_items_all.system_linkage_function%TYPE,
           P_structure_version_id    IN NUMBER DEFAULT NULL,
           X_status                  OUT NOCOPY VARCHAR2,
           X_stage                   OUT NOCOPY NUMBER)
IS

	  l_dummy_char  varchar2(100);
	  l_dummy_date  Date;


      TYPE UserSuppliedType IS RECORD (
            acct_rate_type      VARCHAR2(1) := 'N'
           ,acct_rate_date      VARCHAR2(1) := 'N'
           ,projfunc_cost_rate_type  VARCHAR2(1) := 'N'
           ,projfunc_cost_rate_date  VARCHAR2(1) := 'N');

      usersupplied UserSuppliedType;

      l_temp_acct_rate_date date;
      l_temp_acct_rate_type varchar2(100);
      l_temp_acct_exch_rate number;
      l_temp_project_rate_date date;
      l_temp_project_rate_type varchar2(100);
      l_temp_project_exch_rate number;
      l_temp_projfunc_cost_rate_date date;
      l_temp_projfunc_cost_rate_type varchar2(100);
      l_temp_projfunc_cost_exch_rate number;


--------------------------------------
--Forward bodies

----------------------------------------------------------------------
Procedure derive_project_attributes( P_task_id              IN pa_expenditure_items_all.task_id%TYPE
                                    ,P_project_id           IN pa_projects_all.project_id%TYPE DEFAULT NULL
                                    ,P_ei_date              IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                    ,P_structure_version_id IN NUMBER DEFAULT NULL
                                    ,P_calling_module       IN VARCHAR2
                                    ,x_project_rate_type    IN OUT NOCOPY pa_expenditure_items_all.project_rate_type%TYPE
                                    ,x_project_rate_date    IN OUT NOCOPY pa_expenditure_items_all.project_rate_date%TYPE
                                   )
is

  l_char_dummy pa_expenditure_items_all.project_currency_code%TYPE;

begin

--dbms_output.put_line('deriving project attributes');
            /*
             * Project_rate_type.
             */
            IF ( x_project_rate_type IS NULL )
            THEN --{
                pa_multi_currency_txn.get_proj_rate_type( P_task_id => P_task_id
                                   ,p_project_id => p_project_id
                                   ,p_structure_version_id => p_structure_version_id
                                   ,p_calling_module => p_calling_module
                                   ,P_project_currency_code => l_char_dummy
                                   ,P_project_rate_type => x_project_rate_type
                                  );
            END IF ; --} x_project_rate_type IS NULL

            /*
             * Project_rate_date.
             */
            IF ( x_project_rate_date IS NULL )
            THEN --{
                pa_multi_currency_txn.get_proj_rate_date( P_task_id => P_task_id
                                   ,P_project_id => P_project_id
                                   ,P_ei_date => P_ei_date
                                   ,P_structure_version_id => p_structure_version_id
                                   ,P_calling_module => p_calling_module
                                   ,P_project_rate_date => x_project_rate_date
                                  );
            END IF ; --} x_project_rate_date IS NULL
/***
         dbms_output.put_line('t [' || to_char(P_task_id) ||
                                  '] dt [' || to_char(P_ei_date) ||
                                  '] cm [' || P_calling_module ||
                                  '] prt [' || x_project_rate_type ||
                                  '] prd [' || to_char(x_project_rate_date) || ']');
*********/
end derive_project_attributes ;

-----------------------------------------------------------------------
procedure derive_acct_attributes( P_calling_module      IN VARCHAR2
                                 ,P_ei_date             IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                 ,P_attribute           IN VARCHAR2
                                 ,x_acct_rate_type      IN OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE
                                 ,x_acct_rate_date      IN OUT NOCOPY pa_expenditure_items_all.acct_rate_date%TYPE
                                )
is
begin

     IF ( P_attribute = 'TYPE' OR P_attribute = 'BOTH' )
     THEN
         x_acct_rate_type := NVL(x_acct_rate_type, pa_multi_currency.G_rate_type);
     END IF; -- P_attribute = 'TYPE'

     IF ( P_attribute = 'DATE' OR P_attribute = 'BOTH' )
     THEN
         IF ( P_calling_module = 'TRANSFER' )
         THEN --{

            pa_multi_currency_txn.get_default_acct_rate_date( P_ei_date => P_ei_date
                                       ,P_acct_rate_date => X_acct_rate_date
                                      );

         ELSE  --}{

            pa_multi_currency_txn.get_acct_rate_date( P_ei_date => P_ei_date
                               ,P_acct_rate_date => X_acct_rate_date
                              ) ;

         END IF; --} End  P_calling_module = 'TRANSFER'
     END IF; -- P_attribute = 'DATE'
end derive_acct_attributes ;

-----------------------------------------------------------------------
procedure derive_projfunc_attributes
                      ( P_calling_module          IN VARCHAR2
                       ,P_ei_date                 IN pa_expenditure_items_all.expenditure_item_date%TYPE
                       ,P_task_id                 IN pa_expenditure_items_all.task_id%TYPE
                       ,P_project_id              IN pa_projects_all.project_id%TYPE
                       ,P_attribute               IN VARCHAR2
                       ,P_structure_version_id    IN NUMBER DEFAULT NULL
                       ,x_projfunc_cost_rate_type IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_type%TYPE
                       ,x_projfunc_cost_rate_date IN OUT NOCOPY pa_expenditure_items_all.projfunc_cost_rate_date%TYPE
                      )
is

  l_char_dummy pa_expenditure_items_all.projfunc_currency_code%TYPE;

begin

      --dbms_output.put_line('deriving projfunc attributes');
      IF ( P_attribute = 'TYPE' OR P_attribute = 'BOTH')
      THEN --{
      pa_multi_currency_txn.get_projfunc_cost_rate_type
                        ( P_task_id =>P_task_id ,
                          P_project_id => p_project_id ,
                          P_structure_version_id => p_structure_version_id ,
                          P_calling_module => p_calling_module ,
                          P_projfunc_currency_code =>l_char_dummy ,
                          P_projfunc_cost_rate_type =>x_projfunc_cost_rate_type
                        ) ;
      END IF; --} P_attribute = 'TYPE' OR P_attribute = 'BOTH'

      IF ( P_attribute = 'DATE' OR P_attribute = 'BOTH' )
      THEN --{
          IF ( P_calling_module = 'TRANSFER' ) THEN

             pa_multi_currency_txn.get_def_projfunc_cst_rate_date
                             ( P_task_id =>P_task_id ,
                               P_project_id => p_project_id ,
                               P_structure_version_id => p_structure_version_id ,
                               P_calling_module => p_calling_module ,
                               P_ei_date =>P_ei_date ,
                               P_projfunc_cost_rate_date =>x_projfunc_cost_rate_date
                             ) ;
          ELSE --}{

--dbms_output.put_line('calling get_projfunc_cost_rate_date');

             pa_multi_currency_txn.get_projfunc_cost_rate_date
                            ( P_task_id =>P_task_id ,
                              P_project_id =>P_project_id ,
                              P_ei_date =>P_ei_date ,
                              P_structure_version_id =>p_structure_version_id ,
                              P_calling_module =>p_calling_module ,
                              P_projfunc_cost_rate_date =>x_projfunc_cost_rate_date
                            ) ;

          END IF; --} end P_calling_module = 'TRANSFER'
      END IF; --} P_attribute = 'DATE' OR P_attribute = 'BOTH'

         /*********
dbms_output.put_line('t [' || to_char(P_task_id) ||
                                  '] dt [' || to_char(P_ei_date) ||
                                  '] cm [' || P_calling_module ||
                                  '] att [' || P_attribute ||
                                  '] pfrt [' || x_projfunc_cost_rate_type ||
                                  '] pfrd [' || to_char(x_projfunc_cost_rate_date) || ']');
*****/

end derive_projfunc_attributes ;
--Forward bodies end
--------------------------------------

BEGIN

    l_temp_acct_rate_date :=  x_acct_rate_date;
    l_temp_acct_rate_type := x_acct_rate_type;
    l_temp_acct_exch_rate := x_acct_exch_rate;
    l_temp_project_rate_date := x_project_rate_date;
    l_temp_project_rate_type := x_project_rate_type;
    l_temp_project_exch_rate := x_project_exch_rate;
    l_temp_projfunc_cost_rate_date := x_projfunc_cost_rate_date;
    l_temp_projfunc_cost_rate_type := x_projfunc_cost_rate_type;
    l_temp_projfunc_cost_exch_rate := x_projfunc_cost_exch_rate;

    IF ( P_projfunc_curr_code = P_acct_curr_code )
    THEN -- {
      IF ( P_projfunc_curr_code = P_denom_curr_code )
      THEN --{
          X_acct_rate_date := NULL;
          X_acct_rate_type := NULL;
          X_acct_exch_rate := NULL;

          X_projfunc_cost_rate_date := NULL ;
          X_projfunc_cost_rate_type := NULL ;
          X_projfunc_cost_exch_rate := NULL ;
      ELSE --}{

        IF ( P_accounted_flag = 'Y' )
        THEN -- {
            /*
             * At this point it is assumed that - if the txn is accounted
             * the account attributes will be NOT NULL.
             */
            X_projfunc_cost_rate_date := X_acct_rate_date ;
            X_projfunc_cost_rate_type := X_acct_rate_type ;
            X_projfunc_cost_exch_rate := X_acct_exch_rate ;

        END IF; -- } P_accounted_flag = 'Y'

        IF ( P_system_linkage = 'ER' AND P_accounted_flag <> 'Y' )
        THEN -- {
            /*
             * IF its an Expense Report, Functional gets the highest precedence.
             */
            IF ( X_acct_rate_type IS NULL )
            THEN --{

	       IF p_calling_module =  'FORECAST' Then
 			derive_fi_curr_attributes
        		( P_project_id             => p_project_id
         		,P_exp_org_id              => p_exp_org_id
         		,P_ei_date                 => p_ei_date
         		,P_attribute               => 'FORECAST'
         		,x_project_rate_type       => l_dummy_char
         		,x_project_rate_date       => l_dummy_date
         		,x_projfunc_cost_rate_type => l_dummy_char
         		,x_projfunc_cost_rate_date => l_dummy_date
         		,x_acct_rate_type          => X_acct_rate_type
         		,x_acct_rate_date          => l_dummy_date  --X_acct_rate_date
        		);
		Else
                        derive_acct_attributes
			( P_calling_module => P_calling_module
                         ,P_ei_date => P_ei_date
                         ,P_attribute => 'TYPE'
                         ,x_acct_rate_type => X_acct_rate_type
                         ,x_acct_rate_date=> X_acct_rate_date
                        );
		End If;

            ELSE -- }{ X_acct_rate_type IS NOT NULL
                usersupplied.acct_rate_type := 'Y' ;
            END IF; --} X_acct_rate_type IS NULL
            /*
             * For Expense Report, Project Functional is overridden by the Functional
             * even if its user supplied.
             */
            X_projfunc_cost_rate_type := X_acct_rate_type ;

            IF ( X_acct_rate_date IS NULL)
            THEN --{
               IF p_calling_module =  'FORECAST' Then
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => l_dummy_char
                        ,x_projfunc_cost_rate_date => l_dummy_date
                        ,x_acct_rate_type          => l_dummy_char --X_acct_rate_type
                        ,x_acct_rate_date          => X_acct_rate_date
                        );
                Else

                	derive_acct_attributes
			( P_calling_module => P_calling_module
                         ,P_ei_date => P_ei_date
                         ,P_attribute => 'DATE'
                         ,x_acct_rate_type => X_acct_rate_type
                         ,x_acct_rate_date=> X_acct_rate_date
                        );
		End If;
            ELSE -- }{ X_acct_rate_date IS NOT NULL
                usersupplied.acct_rate_date := 'Y' ;
            END IF; --} X_acct_rate_date IS NULL
            X_projfunc_cost_rate_date := X_acct_rate_date ;

            IF ( X_acct_rate_type = 'User' )
            THEN --{
                IF ( pa_multi_currency.is_user_rate_type_allowed(
                        P_from_currency => P_denom_curr_code,
                        P_to_currency => P_acct_curr_code,
                        P_conversion_date => X_acct_rate_date)='Y'
                   )
                THEN --{
                    IF (X_acct_exch_rate IS NOT NULL)
                    THEN --{
                        X_projfunc_cost_exch_rate := X_acct_exch_rate ;
                    ELSE --}{
                        X_status := 'PA_ACCT_USER_RATE_NOT_DEFINED' ;
                        RETURN ;
                    END IF; --}
                ELSE -- }{
                    X_status := 'PA_NO_ACCT_USER_RATE_TYPE';
                    RETURN ;
                END IF; --}
            END IF; --} X_acct_rate_type = 'User'
        END IF; -- } P_system_linkage = 'ER' AND P_accounted_flag <> 'Y'
        print_message('account flag <> N and syslinkage <> ER');
        IF ( NVL(P_accounted_flag, 'N') <> 'Y' AND P_system_linkage <> 'ER' )
        THEN --{
            IF ( X_projfunc_cost_rate_type IS NOT NULL )
            THEN --{
                /*
                 * Functional Attribute is overridden by Project Functional -
                 * if Project Functional is supplied.
                 */
                usersupplied.projfunc_cost_rate_type := 'Y' ;
                X_acct_rate_type := X_projfunc_cost_rate_type ;
            ELSE -- }{ X_projfunc_cost_rate_type IS NULL
                /*
                 * <2822867> If Functional Rate Type is available, override Project Functional Rate Type
                 * with it - but only for non-Timecards. For Time-cards derive Project
                 * Functional attributes afresh.
                 * <7680781> No need of putting the check for ST,OT transactions here, if the acct_rate is
                 * passed we need to use the same for calculating projfunc rate
                 */
               /* IF ( X_acct_rate_type IS NOT NULL AND P_system_linkage <> 'ST' AND P_system_linkage <> 'OT' )*/
                IF ( X_acct_rate_type IS NOT NULL )
                THEN --{
                    usersupplied.acct_rate_type := 'Y' ;
                    X_projfunc_cost_rate_type := X_acct_rate_type ;
                ELSE --}{ X_acct_rate_type IS NULL
                    /*
                     * Both Project Functional rate type and Functional rate type
                     * are NULL. Derive Project Functional and copy it to Functional.
                     */
		    print_message('Both Project Functional rate type and Functional rate type are NULL');
               	    IF p_calling_module =  'FORECAST' Then
			print_message('Calling derive_fi_curr_attributes for projfunc rate type');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => X_projfunc_cost_rate_type
                        ,x_projfunc_cost_rate_date => l_dummy_date --X_projfunc_cost_rate_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else
                        derive_projfunc_attributes
                                ( P_calling_module => P_calling_module
                                 ,P_ei_date => P_ei_date
                                 ,P_task_id => P_task_id
                                 ,P_project_id => P_project_id
                                 ,P_attribute => 'TYPE'
                                 ,P_structure_version_id => p_structure_version_id
                                 ,x_projfunc_cost_rate_type => X_projfunc_cost_rate_type
                                 ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                               );
		    End if;

                    X_acct_rate_type := X_projfunc_cost_rate_type ;
                    X_acct_exch_rate := X_projfunc_cost_exch_rate; --2822867
                END IF; --} X_acct_rate_type IS NOT NULL
            END IF; --} X_projfunc_cost_rate_type IS NOT NULL

            IF ( X_projfunc_cost_rate_date IS NOT NULL )
            THEN --{
                /*
                 * Functional Attribute is overridden by Project Functional -
                 * if Project Functional is supplied.
                 */
                usersupplied.projfunc_cost_rate_date := 'Y' ;
                X_acct_rate_date := X_projfunc_cost_rate_date ;
            ELSE -- }{ X_projfunc_cost_rate_date IS NULL
                /*
                 * <2822867> If Functional Rate Date is available, override Project Functional Rate Date
                 * with it - but only for non-Timecards. For Time-cards derive Project
                 * Functional attributes afresh.
                 * <7680781> No need of putting the check for ST,OT transactions here, if the acct_rate is
                 * passed we need to use the same for calculating projfunc rate
                 */
                /*IF ( X_acct_rate_date IS NOT NULL AND P_system_linkage <> 'ST' AND P_system_linkage <> 'OT' )*/
		IF ( X_acct_rate_type IS NOT NULL )
                THEN --{
                    usersupplied.acct_rate_date := 'Y' ;
                    X_projfunc_cost_rate_date := X_acct_rate_date ;
                ELSE --}{ X_acct_rate_date IS NULL
                    /*
                     * Both Project Functional rate date and Functional rate date
                     * are NULL. Derive Project Functional and copy it to Functional.
                     */
                    IF p_calling_module =  'FORECAST' Then
			print_message('Calling derive_fi_curr_attributes for projfunc rate date');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => l_dummy_char --X_projfunc_cost_rate_type
                        ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else
                         derive_projfunc_attributes
                               (  P_calling_module => P_calling_module
                                 ,P_ei_date => P_ei_date
                                 ,P_task_id => P_task_id
                                 ,P_project_id => P_project_id
                                 ,P_attribute => 'DATE'
                                 ,P_structure_version_id => P_structure_version_id
                                 ,x_projfunc_cost_rate_type => X_projfunc_cost_rate_type
                                 ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                               );
		    End If;
                    X_acct_rate_date := X_projfunc_cost_rate_date ;
                END IF; --} X_acct_rate_date IS NOT NULL
            END IF; --} X_projfunc_cost_rate_date IS NOT NULL

            /*
             * Exchange Rate.
             * If either project functional was provided or neither of them was provided
             * - user project functional.
             */
            IF ( ( usersupplied.projfunc_cost_rate_type = 'Y' ) OR
                 ( usersupplied.acct_rate_type <> 'Y' AND usersupplied.projfunc_cost_rate_type <> 'Y' )
               )
            THEN --{
                /*
                 * If projfunc is supplied (1) or neither of them is given (2)
                 * In both the cases (1)(2) projfunc takes precedence.
                 */
                IF (X_projfunc_cost_rate_type = 'User')
                THEN --{
                    IF ( pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_projfunc_curr_code,
                             P_conversion_date => X_projfunc_cost_rate_date) = 'Y'
                       )
                    THEN --{
                        IF (X_projfunc_cost_exch_rate IS NOT NULL)
                        THEN --{
                            X_acct_exch_rate := X_projfunc_cost_exch_rate ;
                        ELSE -- }{
                            X_status := 'PA_NO_PROJFUNC_USER_RATE' ; /* bug#2855640 */
                            RETURN ;
                        END IF; --} X_projfunc_cost_exch_rate IS NOT NULL
                    ELSE -- }{
                        X_status := 'PA_NO_PROJFUNC_USER_RATE_TYPE';
                        RETURN ;
                    END IF; --} -- user_allowed
                END IF; --}
            ELSIF (usersupplied.acct_rate_type ='Y')
            THEN -- }{
                IF ( X_acct_rate_type = 'User')
                THEN --{
                    IF (pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_acct_curr_code,
                             P_conversion_date => X_acct_rate_date) ='Y')
                    THEN --{
                        IF ( X_acct_exch_rate IS NOT NULL)
                        THEN --{
                            X_projfunc_cost_exch_rate := X_acct_exch_rate ;
                        ELSE --}{
                            X_status := 'PA_ACCT_USER_RATE_NOT_DEFINED' ;
                            RETURN ;
                        END IF; -- } X_acct_exch_rate IS NOT NULL
                    ELSE --}{
                        X_status := 'PA_NO_ACCT_USER_RATE_TYPE';
                        RETURN ;
                    END IF; --} user_allowed
                END IF; --} X_acct_rate_type = 'User'
            END IF ; --} usersupplied.projfunc_cost_rate_type = 'Y'
        END IF; --}  NVL(P_accounted_flag, 'N') = 'N' AND P_system_linkage <> 'ER'
      END IF; --} P_projfunc_curr_code = P_denom_curr_code
        /*
         * All projfunc and acct attributes are derived.
         * The following code derives the project attributes.
         * projfunc = acct.
         */
      IF ( P_project_curr_code = P_denom_curr_code )
      THEN --{
          X_project_rate_type := NULL ;
          X_project_rate_date := NULL ;
          X_project_exch_rate := NULL ;
      ELSE --}{
        IF (P_project_curr_code = P_projfunc_curr_code)
        THEN --{
            /*
             * Project_rate_type.
             */
            IF (X_project_rate_type IS NOT NULL)
            THEN --{
                IF ( usersupplied.acct_rate_type <> 'Y' AND usersupplied.projfunc_cost_rate_type <> 'Y' )
                THEN --{
                    X_acct_rate_type := X_project_rate_type ;
                    X_projfunc_cost_rate_type := X_project_rate_type ;
                END IF; --} usersupplied.acct_rate_type <> 'Y' AND usersupplied.projfunc_cost_rate_type <> 'Y'
            ELSE --}{
                X_project_rate_type := X_projfunc_cost_rate_type ;
            END IF; --} X_project_rate_type IS NOT NULL

            /*
             * Project_rate_date.
             */
            IF (X_project_rate_date IS NOT NULL)
            THEN --{
                IF ( usersupplied.acct_rate_date <> 'Y' AND usersupplied.projfunc_cost_rate_date <> 'Y' )
                THEN --{
                    X_acct_rate_date := X_project_rate_date ;
                    X_projfunc_cost_rate_date := X_project_rate_date ;
                END IF; --} usersupplied.acct_rate_date <> 'Y' AND usersupplied.projfunc_cost_rate_date <> 'Y'
            ELSE --}{
                X_project_rate_date := X_projfunc_cost_rate_date ;
            END IF; --} X_project_rate_date IS NOT NULL

            /*
             * Project_exch_rate.
             */
            IF ( X_projfunc_cost_rate_type = 'User')
            THEN --{
                X_project_exch_rate := X_projfunc_cost_exch_rate ;
            ELSE --}{
                IF ( X_project_rate_type = 'User')
                THEN --{
                    IF ( pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_project_curr_code,
                             P_conversion_date => X_project_rate_date) = 'Y' )
                    THEN --}{
                        IF ( X_project_exch_rate IS NOT NULL )
                        THEN --{
                            X_projfunc_cost_exch_rate := X_project_exch_rate ;
                            X_acct_exch_rate := X_project_exch_rate ;
                        ELSE --}{
                            X_status := 'PA_PROJ_USER_RATE_NOT_DEFINED' ;
                            RETURN ;
                        END IF;
                    ELSE --}{
                        X_status := 'PA_NO_PROJ_USER_RATE_TYPE';
                        RETURN ;
                    END IF; --}
                ELSE --}{
                    X_project_exch_rate := X_projfunc_cost_exch_rate ;
                END IF; --}
            END IF; --} X_projfunc_cost_rate_type = 'User'

        ELSE --}{
                    IF p_calling_module =  'FORECAST' Then
			print_message('calling derive_fi_curr_attributes for project rate type');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => X_project_rate_type
                        ,x_project_rate_date       => X_project_rate_date
                        ,x_projfunc_cost_rate_type => l_dummy_char
                        ,x_projfunc_cost_rate_date => l_dummy_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else
            		derive_project_attributes( P_task_id => P_task_id
                                      ,P_project_id => P_project_id
                                      ,P_ei_date => P_ei_date
                                      ,P_structure_version_id => P_structure_version_id
                                      ,P_calling_module => P_calling_module
                                      ,x_project_rate_type => X_project_rate_type
                                      ,x_project_rate_date => X_project_rate_date
                                     );
		    End If;

        END IF; --} P_project_curr_code = P_projfunc_curr_code
      END IF; --} P_project_curr_code = P_denom_curr_code
    END IF; -- } P_projfunc_curr_code = P_acct_curr_code

    IF ( P_projfunc_curr_code <> P_acct_curr_code )
    THEN --{

      IF ( P_projfunc_curr_code = P_denom_curr_code )
      THEN --{
          X_projfunc_cost_rate_type := NULL ;
          X_projfunc_cost_rate_date := NULL ;
          X_projfunc_cost_exch_rate := NULL ;
      ELSE --}{

        IF ( X_projfunc_cost_rate_type IS NULL )
        THEN --{
                    IF p_calling_module =  'FORECAST' Then
		     print_message('calling derive_fi_curr_attributes for project rate date ');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => X_projfunc_cost_rate_type
                        ,x_projfunc_cost_rate_date => l_dummy_date --X_projfunc_cost_rate_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else

                    	derive_projfunc_attributes
                                ( P_calling_module => P_calling_module
                                 ,P_ei_date =>  P_ei_date
                                 ,P_task_id =>  P_task_id
                                 ,P_project_id =>  P_project_id
                                 ,P_attribute => 'TYPE'
                                 ,P_structure_version_id =>  P_structure_version_id
                                 ,x_projfunc_cost_rate_type =>  X_projfunc_cost_rate_type
                                 ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                               );
		    End if;
        ELSE --}{
            usersupplied.projfunc_cost_rate_type := 'Y' ;
        END IF; --} X_projfunc_cost_rate_type IS NULL

        IF ( X_projfunc_cost_rate_date IS NULL )
        THEN --{
                    IF p_calling_module =  'FORECAST' Then
			print_message('calling derive_fi_curr_attributes for projfunc rate type');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => l_dummy_char --X_projfunc_cost_rate_type
                        ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else
                         derive_projfunc_attributes
                                ( P_calling_module => P_calling_module
                                 ,P_ei_date =>  P_ei_date
                                 ,P_task_id =>  P_task_id
                                 ,P_project_id =>  P_project_id
                                 ,P_attribute => 'DATE'
                                 ,P_structure_version_id => P_structure_version_id
                                 ,x_projfunc_cost_rate_type =>  X_projfunc_cost_rate_type
                                 ,x_projfunc_cost_rate_date => X_projfunc_cost_rate_date
                               );
		    End if;
        ELSE --}{
            usersupplied.projfunc_cost_rate_date := 'Y' ;
        END IF; --} X_projfunc_cost_rate_date IS NULL

        IF (X_projfunc_cost_rate_type = 'User')
        THEN --{
            IF (pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_projfunc_curr_code,
                             P_conversion_date => X_projfunc_cost_rate_date) = 'Y')
            THEN  --{
                IF ( X_projfunc_cost_exch_rate IS NULL )
                THEN --{
                    X_status := 'PA_NO_PROJFUNC_USER_RATE' ; /* bug#2855640 */
                    RETURN ;
                END IF; --} X_projfunc_cost_exch_rate IS NOT NULL
            ELSE --}{
                X_status := 'PA_NO_PROJFUNC_USER_RATE_TYPE';
                RETURN ;
            END IF; --} user_allowed <> 'Y'
        END IF; --} X_projfunc_cost_rate_type = 'User'
      END IF; --} P_projfunc_curr_code = P_denom_curr_code


      IF ( P_acct_curr_code = P_denom_curr_code )
      THEN --{
          X_acct_rate_type := NULL ;
          X_acct_rate_date := NULL ;
          X_acct_exch_rate := NULL ;
      ELSE --}{
        IF ( X_acct_rate_type IS NULL )
        THEN --{
                    IF p_calling_module =  'FORECAST' Then
			print_message('calling derive_fi_curr_attributes for acct rate type');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => l_dummy_char
                        ,x_projfunc_cost_rate_date => l_dummy_date
                        ,x_acct_rate_type          => X_acct_rate_type
                        ,x_acct_rate_date          => l_dummy_date --X_acct_rate_date
                        );
                    Else
                	derive_acct_attributes( P_calling_module => P_calling_module
                                       ,P_ei_date => P_ei_date
                                       ,P_attribute => 'TYPE'
                                       ,x_acct_rate_type => X_acct_rate_type
                                       ,x_acct_rate_date=> X_acct_rate_date
                                      );
		    End if;

        ELSE --}{
            usersupplied.acct_rate_type := 'Y' ;
        END IF; --} X_acct_rate_type IS NULL

        IF ( X_acct_rate_date IS NULL )
        THEN --{
                    IF p_calling_module =  'FORECAST' Then
			print_message('calling derive_fi_curr_attributes for acct rate date');
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => l_dummy_char
                        ,x_project_rate_date       => l_dummy_date
                        ,x_projfunc_cost_rate_type => l_dummy_char
                        ,x_projfunc_cost_rate_date => l_dummy_date
                        ,x_acct_rate_type          => l_dummy_char --X_acct_rate_type
                        ,x_acct_rate_date          => X_acct_rate_date
                        );
                    Else
                        derive_acct_attributes( P_calling_module => P_calling_module
                                       ,P_ei_date => P_ei_date
                                       ,P_attribute => 'DATE'
                                       ,x_acct_rate_type => X_acct_rate_type
                                       ,x_acct_rate_date=> X_acct_rate_date
                                      );
		    End if;
        ELSE --}{
            usersupplied.acct_rate_date := 'Y' ;
        END IF; --} X_acct_rate_date IS NULL

        IF (X_acct_rate_type = 'User')
        THEN --{
            IF (pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_acct_curr_code,
                             P_conversion_date => X_acct_rate_date) = 'Y')
            THEN  --{
                IF ( X_acct_exch_rate IS NULL )
                THEN --{
                    X_status := 'PA_ACCT_USER_RATE_NOT_DEFINED' ;
                    RETURN ;
                END IF; --} X_acct_exch_rate IS NOT NULL
            ELSE --}{
                X_status := 'PA_NO_ACCT_USER_RATE_TYPE';
                RETURN ;
            END IF; --} user_allowed <> 'Y'
        END IF; --} X_acct_rate_type = 'User'
      END IF ; --} P_acct_curr_code = P_denom_curr_code

        /*
         * Projfunc and acct rates are ready.
         */
      IF ( P_project_curr_code = P_denom_curr_code )
      THEN --{
          X_project_rate_type := NULL ;
          X_project_rate_date := NULL ;
          X_project_exch_rate := NULL ;
      ELSE --}{
        IF ( P_project_curr_code = P_projfunc_curr_code )
        THEN --{

            /*
             * Project_rate_type
             */
            IF ( usersupplied.projfunc_cost_rate_type = 'Y' )
            THEN --{
                   --dbms_output.put_line('moving pfrt to prt');
                X_project_rate_type := X_projfunc_cost_rate_type ;
            ELSE --}{
               IF ( X_project_rate_type IS NOT NULL)
               THEN -- {
                   X_projfunc_cost_rate_type := X_project_rate_type ;
               ELSE --}{
                   X_project_rate_type := X_projfunc_cost_rate_type ;
               END IF; --} X_project_rate_type IS NOT NULL
            END IF; --} usersupplied.projfunc_cost_rate_type = 'Y'

            /*
             * Project_rate_date
             */
            IF ( usersupplied.projfunc_cost_rate_date = 'Y' )
            THEN --{
                X_project_rate_date := X_projfunc_cost_rate_date ;
            ELSE --}{
               IF ( X_project_rate_date IS NOT NULL)
               THEN -- {
                   X_projfunc_cost_rate_date := X_project_rate_date ;
               ELSE --}{
                   --dbms_output.put_line('b4 moving pfrd to prd');
                  --dbms_output.put_line('pfrd ['|| to_char(X_projfunc_cost_rate_date) || ']');
                  --dbms_output.put_line('prd ['|| to_char(X_project_rate_date) || ']');
                   X_project_rate_date := X_projfunc_cost_rate_date ;
                   --dbms_output.put_line('after moving pfrd to prd');
                  --dbms_output.put_line('pfrd ['|| to_char(X_projfunc_cost_rate_date) || ']');
                  --dbms_output.put_line('prd ['|| to_char(X_project_rate_date) || ']');
               END IF; --} X_project_rate_date IS NOT NULL
            END IF; --} usersupplied.projfunc_cost_rate_date = 'Y'

            /*
             * Project exch rate.
             */
            IF ( X_projfunc_cost_rate_type = 'User')
            THEN --{
                X_project_exch_rate := X_projfunc_cost_exch_rate ;
            ELSE --}{
                IF ( X_project_rate_type = 'User')
                THEN --{
                    IF ( pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_project_curr_code,
                             P_conversion_date => X_project_rate_date) ='Y' )
                    THEN --}{
                        IF ( X_project_exch_rate IS NOT NULL )
                        THEN --{
                            X_projfunc_cost_exch_rate := X_project_exch_rate ;
                        ELSE --}{
                            X_status := 'PA_PROJ_USER_RATE_NOT_DEFINED' ;
                            RETURN ;
                        END IF;
                    ELSE --}{
                        X_status := 'PA_NO_PROJ_USER_RATE_TYPE';
                        RETURN ;
                    END IF; --}
                ELSE --}{
                   --dbms_output.put_line('moving pfer to per');
                    X_project_exch_rate := X_projfunc_cost_exch_rate ;
                END IF; --}
            END IF; --} X_projfunc_cost_rate_type = 'User'
        END IF; --} P_project_curr_code = P_projfunc_curr_code

        IF ( P_project_curr_code = P_acct_curr_code )
        THEN --{

            /*
             * Project_rate_type
             */
            IF ( usersupplied.acct_rate_type = 'Y' )
            THEN --{
                X_project_rate_type := X_acct_rate_type ;
            ELSE --}{
               IF ( X_project_rate_type IS NOT NULL)
               THEN -- {
                   X_acct_rate_type := X_project_rate_type ;
               ELSE --}{
                   X_project_rate_type := X_acct_rate_type ;
               END IF; --} X_project_rate_type IS NOT NULL
            END IF; --} usersupplied.acct_rate_type = 'Y'

            /*
             * Project_rate_date
             */
            IF ( usersupplied.acct_rate_date = 'Y' )
            THEN --{
                X_project_rate_date := X_acct_rate_date ;
            ELSE --}{
               IF ( X_project_rate_date IS NOT NULL)
               THEN -- {
                   X_acct_rate_date := X_project_rate_date ;
               ELSE --}{
                   X_project_rate_date := X_acct_rate_date ;
               END IF; --} X_project_rate_date IS NOT NULL
            END IF; --} usersupplied.acct_rate_date = 'Y'

            /*
             * Project exch rate.
             */
            IF ( X_acct_rate_type = 'User')
            THEN --{
                X_project_exch_rate := X_acct_exch_rate ;
            ELSE --}{
                IF ( X_project_rate_type = 'User')
                THEN --{
                    IF ( pa_multi_currency.is_user_rate_type_allowed(
                             P_from_currency => P_denom_curr_code,
                             P_to_currency => P_project_curr_code,
                             P_conversion_date => X_project_rate_date) ='Y' )
                    THEN --}{
                        IF ( X_project_exch_rate IS NOT NULL )
                        THEN --{
                            X_acct_exch_rate := X_project_exch_rate ;
                        ELSE --}{
                            X_status := 'PA_PROJ_USER_RATE_NOT_DEFINED' ;
                            RETURN ;
                        END IF;
                    ELSE --}{
                        X_status := 'PA_NO_PROJ_USER_RATE_TYPE';
                        RETURN ;
                    END IF; --}
                ELSE --}{
                    X_project_exch_rate := X_acct_exch_rate ;
                END IF; --}
            END IF; --} X_acct_rate_type = 'User'
        END IF; --} P_project_curr_code = P_acct_curr_code

        IF ( P_project_curr_Code <> P_acct_curr_code AND P_project_curr_code <> P_projfunc_curr_code)
        THEN --{
                    IF p_calling_module =  'FORECAST' Then
                        derive_fi_curr_attributes
                        ( P_project_id             => p_project_id
                        ,P_exp_org_id              => p_exp_org_id
                        ,P_ei_date                 => p_ei_date
                        ,P_attribute               => 'FORECAST'
                        ,x_project_rate_type       => X_project_rate_type
                        ,x_project_rate_date       => X_project_rate_date
                        ,x_projfunc_cost_rate_type => l_dummy_char
                        ,x_projfunc_cost_rate_date => l_dummy_date
                        ,x_acct_rate_type          => l_dummy_char
                        ,x_acct_rate_date          => l_dummy_date
                        );
                    Else
            		derive_project_attributes( P_task_id => P_task_id
                                      ,P_project_id => P_project_id
                                      ,P_ei_date => P_ei_date
                                      ,P_structure_version_id => P_structure_version_id
                                      ,P_calling_module => P_calling_module
                                      ,x_project_rate_type => X_project_rate_type
                                      ,x_project_rate_date  => X_project_rate_date
                                     );
		    End If;
        END IF;--}
     END IF ; --} P_project_curr_code = P_denom_curr_code

    END IF; --} P_projfunc_curr_code <> P_acct_curr_code

EXCEPTION
  WHEN OTHERS THEN
        x_acct_rate_date := l_temp_acct_rate_date;
        x_acct_rate_type :=  l_temp_acct_rate_type;
        x_acct_exch_rate :=  l_temp_acct_exch_rate;
        x_project_rate_date :=  l_temp_project_rate_date;
        x_project_rate_type :=  l_temp_project_rate_type;
        x_project_exch_rate :=  l_temp_project_exch_rate;
        x_projfunc_cost_rate_date :=  l_temp_projfunc_cost_rate_date;
        x_projfunc_cost_rate_type :=  l_temp_projfunc_cost_rate_type;
        x_projfunc_cost_exch_rate :=  l_temp_projfunc_cost_exch_rate;
        RAISE;
END get_currency_attributes;
/*---------------------------------------------------------------------*/

END pa_multi_currency_txn ;

/
