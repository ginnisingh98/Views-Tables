--------------------------------------------------------
--  DDL for Package Body PA_ACC_GEN_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACC_GEN_WF_PKG" AS
/* $Header: PAXWFACB.pls 120.11.12010000.2 2008/08/22 16:20:06 mumohan ship $ */

/***Bug 3182416 :Moved the declaration of g_ variables to spec .
g_error_message VARCHAR2(1000) :='';
g_error_stack   VARCHAR2(500) :='';
g_error_stage   VARCHAR2(100) :='';
*************************************************************/

/* Bug 5233487 - g_error_stack_history will store all the messages in the error stack */
TYPE ErrorStack IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
g_error_stack_history ErrorStack;

----------------------------------------------------------------------
-- Procedure pa_acc_gen_wf_pkg.wf_acc_derive_params
-- Definition of procedure in package specifications
----------------------------------------------------------------------

 PROCEDURE wf_acc_derive_params (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN
					    pa_expenditure_items_all.expenditure_item_date%TYPE,
	x_class_code			OUT NOCOPY pa_class_codes.class_code%TYPE,
	x_direct_flag			OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
	x_expenditure_category		OUT
					    NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
	x_expenditure_org_name		OUT NOCOPY hr_organization_units.name%TYPE,
	x_project_number		OUT NOCOPY pa_projects_all.segment1%TYPE,
	x_project_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
	x_project_organization_id	OUT NOCOPY hr_organization_units.organization_id %TYPE,
	x_project_type			OUT NOCOPY pa_project_types_all.project_type%TYPE,
	x_public_sector_flag		OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
	x_revenue_category		OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
	x_task_number			OUT NOCOPY pa_tasks.task_number%TYPE,
	x_task_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
	x_task_organization_id		OUT NOCOPY hr_organization_units.organization_id %TYPE,
	x_task_service_type		OUT NOCOPY pa_tasks.service_type_code%TYPE,
	x_top_task_id			OUT NOCOPY pa_tasks.task_id%TYPE,
	x_top_task_number		OUT NOCOPY pa_tasks.task_number%TYPE,
	x_vendor_employee_id		OUT NOCOPY per_people_f.person_id%TYPE,
	x_vendor_employee_number	OUT NOCOPY per_people_f.employee_number%TYPE,
	x_vendor_type			OUT NOCOPY po_vendors.vendor_type_lookup_code%TYPE)
AS

l_person_effective_date	DATE;

BEGIN

  set_error_stack('-->wf_acc_derive_params'); /* Bug 5233487 */
  g_encoded_error_message := NULL; /* Bug 5233487 */
  g_error_message := '';
---------------------------------------------------
-- If EI date is not passed, consider system date
---------------------------------------------------
   g_error_stage := '10';

    IF p_expenditure_item_date is null
    THEN
	l_person_effective_date := sysdate;
    ELSE
	l_person_effective_date := p_expenditure_item_date;
    END IF;

 ----------------------------------------------------------
 -- Derive vendor information if the vendor id is present
 ----------------------------------------------------------
   g_error_stage := '20';

   IF p_vendor_id IS NOT NULL
   THEN  /* Commented for Bug# 4007983
     SELECT
	    VEND.employee_id			VENDOR_EMPLOYEE_ID,
	    EMP.employee_number			VENDOR_EMPLOYEE_NUMBER,
	    VEND.vendor_type_lookup_code	VENDOR_TYPE
	INTO
	    x_vendor_employee_id,
	    x_vendor_employee_number,
	    x_vendor_type
	FROM
	     po_vendors			VEND,
	     per_people_f		EMP
       WHERE
		VEND.vendor_id		=  p_vendor_id
 	AND	VEND.employee_id 	=  EMP.person_id (+)
	AND	l_person_effective_date
	   between EMP.effective_start_date(+)
	       and nvl(EMP.effective_end_date(+),sysdate);   */

     /* Start of Bug# 4007983 - Replaced the above query by these 2 queries */
     SELECT
         VEND.employee_id      VENDOR_EMPLOYEE_ID,
         VEND.vendor_type_lookup_code  VENDOR_TYPE
     INTO
         x_vendor_employee_id,
         x_vendor_type
     FROM
           po_vendors      VEND
     WHERE
           VEND.vendor_id    =  p_vendor_id;

     IF x_vendor_employee_id IS NOT NULL
     THEN
       BEGIN                          -- Bug 6053374
          SELECT
              EMP.employee_number      VENDOR_EMPLOYEE_NUMBER
          INTO
              x_vendor_employee_number
          FROM
              per_people_f    EMP
          WHERE   x_vendor_employee_id = EMP.person_id
            AND l_person_effective_date between EMP.effective_start_date
                          and NVL (EMP.effective_end_date, sysdate);

       /* Bug 6053374: Added the Exception block. Exception would be thrown only for a
         Standard Invoice, as the case would be taken care in PAXTTXCB itself, for an Expense Report.
         And for Standard Invoices, System should not throw an error even if the EI date does not fall
         between effective_start_date and effective_end_date of the employee */
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             null;
       END;                          -- Bug 6053374: End
     END IF;
     /* End of Bug# 4007983 */
   END IF;

  ---------------------------------------------------------------
  -- Derive project information
  ---------------------------------------------------------------
  g_error_stage := '30';

  pa_acc_gen_wf_pkg.wf_acc_derive_pa_params(
                p_project_id                ,
                p_task_id                   ,
                p_expenditure_type          ,
                p_expenditure_organization_id ,
                p_expenditure_item_date     ,
                x_class_code                ,
                x_direct_flag               ,
                x_expenditure_category      ,
                x_expenditure_org_name      ,
                x_project_number            ,
                x_project_organization_name ,
                x_project_organization_id   ,
                x_project_type              ,
                x_public_sector_flag        ,
                x_revenue_category          ,
                x_task_number               ,
                x_task_organization_name    ,
                x_task_organization_id      ,
                x_task_service_type         ,
                x_top_task_id               ,
                x_top_task_number           );

   reset_error_stack; /* Bug 5233487 */

 EXCEPTION WHEN others THEN
/* Bug 5233487 - Start */
      IF g_encoded_error_message IS NULL THEN
          g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
      END IF;
      reset_error_stack;
/* Bug 5233487 - End */
   g_error_message := SQLERRM;
   raise;
 END wf_acc_derive_params;

------------------- End of procedure wf_acc_Derive_params ---------------------

----------------------------------------------------------------------
-- Procedure pa_acc_gen_wf_pkg.wf_acc_derive_er_params
-- Definition of procedure in package specifications
----------------------------------------------------------------------

 PROCEDURE wf_acc_derive_er_params (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN
					    pa_expenditure_items_all.expenditure_item_date%TYPE,
        p_calling_module                IN  VARCHAR2,
        p_employee_id                   IN  per_people_f.person_id%TYPE,
        p_employee_ccid                 IN OUT  NOCOPY gl_code_combinations.code_combination_id%TYPE,
        p_expense_type                  IN  ap_expense_report_lines_all.web_parameter_id%TYPE,
        p_expense_cc                    IN  ap_expense_report_headers_all.flex_concatenated%TYPE,
	x_class_code			OUT NOCOPY pa_class_codes.class_code%TYPE,
	x_direct_flag			OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
	x_expenditure_category		OUT NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
	x_expenditure_org_name		OUT NOCOPY hr_organization_units.name%TYPE,
	x_project_number		OUT NOCOPY pa_projects_all.segment1%TYPE,
	x_project_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
	x_project_organization_id	OUT NOCOPY hr_organization_units.organization_id%TYPE,
	x_project_type			OUT NOCOPY pa_project_types_all.project_type%TYPE,
	x_public_sector_flag		OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
	x_revenue_category		OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
	x_task_number			OUT NOCOPY pa_tasks.task_number%TYPE,
	x_task_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
	x_task_organization_id		OUT NOCOPY hr_organization_units.organization_id%TYPE,
	x_task_service_type		OUT NOCOPY pa_tasks.service_type_code%TYPE,
	x_top_task_id			OUT NOCOPY pa_tasks.task_id%TYPE,
	x_top_task_number		OUT NOCOPY pa_tasks.task_number%TYPE,
	x_employee_number		OUT NOCOPY per_people_f.employee_number%TYPE,
	x_vendor_type			OUT NOCOPY po_vendors.vendor_type_lookup_code%TYPE,
        x_person_type                   OUT NOCOPY VARCHAR2 )
AS

l_person_effective_date	DATE;
l_employee_ccid	  Number;

BEGIN
  set_error_stack('-->wf_acc_derive_er_params'); /* Bug 5233487 */
  g_encoded_error_message := NULL; /* Bug 5233487 */
  g_error_message := '';

---------------------------------------------------
-- If EI date is not passed, consider system date
---------------------------------------------------
    g_error_stage := '10';

    IF p_expenditure_item_date is null
    THEN
	l_person_effective_date := sysdate;
    ELSE
	l_person_effective_date := p_expenditure_item_date;
    END IF;

 ----------------------------------------------------------
 -- Derive vendor information if the vendor id is present
 ----------------------------------------------------------
   g_error_stage := '20';

   IF p_vendor_id IS NOT NULL
   THEN
     SELECT
	    VEND.vendor_type_lookup_code	VENDOR_TYPE
	INTO
	    x_vendor_type
	FROM
	     po_vendors			VEND
       WHERE
		VEND.vendor_id		=  p_vendor_id	;
   END IF;

  ---------------------------------------------------------------
  -- Derive employee information if employee id is present
  ---------------------------------------------------------------
  g_error_stage := '30';

  IF p_employee_id IS NOT NULL
  THEN
    BEGIN
    /**  Commented out below SQL to accommodate CWK changes **/

  /*  SELECT
	   EMP.employee_num, EMP.default_code_combination_id
      INTO
           x_employee_number, l_employee_ccid
      FROM
   	   hr_employees_current_v 	EMP
     WHERE
	   EMP.employee_id = p_employee_id; */

     SELECT DECODE(p.current_npw_flag,'Y',p.npw_number, p.employee_number) employee_number, a.default_code_comb_id,
            DECODE(p.current_npw_flag,'Y','CWK','EMP') person_type
     INTO   x_employee_number, l_employee_ccid, x_person_type
     FROM   per_people_f p,
            per_assignments_f a,
            per_assignment_status_types past
     WHERE  p.person_id = p_employee_id
     AND    p.business_group_id + 0 = (SELECT nvl(max(fsp.business_group_id),0)
                                       FROM financials_system_parameters fsp)
     AND    a.person_id = p.person_id
     AND    a.primary_flag = 'Y'
     AND    TRUNC(l_person_effective_date) BETWEEN p.effective_start_date and p.effective_end_date
     AND    TRUNC(l_person_effective_date) BETWEEN a.effective_start_date and a.effective_end_date
     AND    ((p.current_employee_flag = 'Y')
            OR (p.current_npw_flag = 'Y') )
     AND    a.assignment_type in ('E','C')
     AND    a.assignment_status_type_id = past.assignment_status_type_id
     AND    past.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN','ACTIVE_CWK');

     EXCEPTION WHEN no_data_found THEN     /* added for bug 6954412 */
     fnd_message.set_name('PA','PA_NO_ASSIGNMENT');
     app_exception.raise_exception;

     END;

     IF p_employee_ccid is NULL then
       p_employee_ccid := l_employee_ccid;
     END IF;

  END IF;


  ---------------------------------------------------------------
  -- Derive project information
  ---------------------------------------------------------------
  g_error_stage := '40';

  pa_acc_gen_wf_pkg.wf_acc_derive_pa_params(
                p_project_id                ,
                p_task_id                   ,
                p_expenditure_type          ,
                p_expenditure_organization_id ,
                p_expenditure_item_date     ,
                x_class_code                ,
                x_direct_flag               ,
                x_expenditure_category      ,
                x_expenditure_org_name      ,
                x_project_number            ,
                x_project_organization_name ,
                x_project_organization_id   ,
                x_project_type              ,
                x_public_sector_flag        ,
                x_revenue_category          ,
                x_task_number               ,
                x_task_organization_name    ,
                x_task_organization_id      ,
                x_task_service_type         ,
                x_top_task_id               ,
                x_top_task_number           );

  reset_error_stack; /* Bug 5233487 */

 EXCEPTION WHEN others THEN
/* Bug 5233487 - Start */
      IF g_encoded_error_message IS NULL THEN
          g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
      END IF;
      reset_error_stack;
/* Bug 5233487 - End */
    g_error_message := SQLERRM;
    raise;

 END wf_acc_derive_er_params;

------------------- End of procedure wf_acc_Derive_er_params ------------------

----------------------------------------------------------------------
-- Procedure pa_acc_gen_wf_pkg.wf_acc_derive_pa_params
-- Definition of package body and function in package specifications
----------------------------------------------------------------------


PROCEDURE wf_acc_derive_pa_params (
                p_project_id                    IN  pa_projects_all.project_id%TYPE,
                p_task_id                       IN  pa_tasks.task_id%TYPE,
                p_expenditure_type              IN  pa_expenditure_types.expenditure_type%TYPE,
                p_expenditure_organization_id   IN  hr_organization_units.organization_id%TYPE,
                p_expenditure_item_date         IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
                x_class_code                    OUT NOCOPY pa_class_codes.class_code%TYPE,
                x_direct_flag                   OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
                x_expenditure_category          OUT NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
                x_expenditure_org_name          OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_number                OUT NOCOPY pa_projects_all.segment1%TYPE,
                x_project_organization_name     OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_organization_id       OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_project_type                  OUT NOCOPY pa_project_types_all.project_type%TYPE,
                x_public_sector_flag            OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
                x_revenue_category              OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
                x_task_number                   OUT NOCOPY pa_tasks.task_number%TYPE,
                x_task_organization_name        OUT NOCOPY hr_organization_units.name%TYPE,
                x_task_organization_id          OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_task_service_type             OUT NOCOPY pa_tasks.service_type_code%TYPE,
                x_top_task_id                   OUT NOCOPY pa_tasks.task_id%TYPE,
                x_top_task_number               OUT NOCOPY pa_tasks.task_number%TYPE)
AS

BEGIN
  set_error_stack('-->wf_acc_derive_pa_params'); /* Bug 5233487 */
  g_encoded_error_message := NULL; /* Bug 5233487 */
  g_error_message := '';
  g_error_stage := '10';
  -----------------------------------------------------
  --  Project id will always be there.
  --  Get all project-related derived parameters


    SELECT
        PTYPE.direct_flag               DIRECT_FLAG,
        PROJ.segment1                   PROJECT_NUMBER,
        ORG.Name                        PROJECT_ORGANIZATION_NAME,
        ORG.Organization_ID             PROJECT_ORGANIZATION_ID,
        PROJ.project_type               PROJECT_TYPE,
        PROJ.public_sector_flag         PUBLIC_SECTOR_FLAG
    INTO
        x_direct_flag,
        x_project_number,
        x_project_organization_name,
        x_project_organization_id,
        x_project_type,
        x_public_sector_flag
    FROM
             HR_Organization_Units      ORG,
             PA_Project_Types_all       PTYPE,
             PA_Projects_all            PROJ
    WHERE
                PROJ.project_id         =  p_project_id
        AND     ORG.organization_id     =  PROJ.carrying_out_organization_id
        AND     nvl(PTYPE.org_id,-99)   =  nvl(PROJ.org_id,-99)
        AND     PTYPE.Project_Type      =  PROJ.Project_Type;

  ----------------------------------------------------------------
  -- Derive the expenditure category and revenue category if the
  -- expenditure type is defined
  ----------------------------------------------------------------
 g_error_stage := '20';

 IF p_expenditure_type is not null
 THEN
   SELECT
        ETYPE.Expenditure_Category      EXPENDITURE_CATEGORY,
        ETYPE.revenue_category_code     REVENUE_CATEGORY
     INTO
        x_expenditure_category,
        x_revenue_category
     FROM
             PA_Expenditure_Types       ETYPE
    WHERE
          ETYPE.expenditure_type        =  p_expenditure_type;
 END IF;

  ----------------------------------------------------------
  -- Derive the project class code if it exists; otherwise
  -- set the parameter to null
  -- Bug 998553: Added clause to select class category row
  --             valid for sysdate
  ----------------------------------------------------------
   g_error_stage := '30';

   BEGIN
        SELECT  a.class_code
          INTO  x_class_code
          FROM  pa_project_classes  a,
		pa_class_categories b
         WHERE  a.project_id          = p_project_id
           AND  a.class_category      = b.class_category
           AND  b.autoaccounting_flag = 'Y'
	   AND  sysdate BETWEEN b.start_date_active
			    AND nvl(b.end_date_active, sysdate);

   EXCEPTION
     WHEN no_data_found
       THEN
          x_class_code := null;
   END;

 ------------------------------------------------------------
 -- Derive Expenditure organization name is Expenditure org
 -- id has been passed
 ------------------------------------------------------------
   g_error_stage := '40';

   IF p_expenditure_organization_id IS NOT NULL
   THEN
        SELECT  ORG.name   EXP_ORG_NAME
          INTO  x_expenditure_org_name
          FROM  hr_organization_units   ORG
         WHERE  ORG.organization_id =  p_expenditure_organization_id;
   END IF;

 --------------------------------------------------------
 -- Derive parameters related to the task id if task id
 -- has been passed
 --------------------------------------------------------
   g_error_stage := '50';

   IF  p_task_id IS NOT NULL
   THEN
        SELECT
                TASK.task_number        TASK_NUMBER,
                ORG.Name                TASK_ORGANIZATION_NAME,
                ORG.Organization_id     TASK_ORGANIZATION_ID,
                TASK.Service_Type_Code  TASK_SERVICE_TYPE,
                TOP_TASK.Task_ID        TOP_TASK_ID,
                TOP_TASK.Task_Number    TOP_TASK_NUMBER
          INTO
                x_task_number,
                x_task_organization_name,
                x_task_organization_id,
                x_task_service_type,
                x_top_task_id,
                x_top_task_number
      FROM
               HR_Organization_Units ORG,
               PA_Tasks TOP_TASK,
               PA_Tasks TASK
      WHERE
                TASK.task_id            =  p_task_id
        AND     ORG.organization_id     =  TASK.carrying_out_organization_id
        AND     TASK.Top_Task_ID        =  TOP_TASK.Task_ID;
 END IF;

 reset_error_stack; /* Bug 5233487 */

 EXCEPTION WHEN OTHERS THEN
/* Bug 5233487 - Start */
      IF g_encoded_error_message IS NULL THEN
          g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
      END IF;
      reset_error_stack;
/* Bug 5233487 - End */
     g_error_message := SQLERRM;
     raise;
 END wf_acc_derive_pa_params;

------------------- End of procedure wf_acc_Derive_pa_params -------------------

  ----------------------------------------------------------------------
  -- Procedure pa_acc_gen_wf_pkg.SetPa_Item_Attr
  -- Definition of package body and procedure in package specifications
  ----------------------------------------------------------------------
   PROCEDURE Set_Pa_Item_Attr
   (
	p_itemtype 			IN  VARCHAR2,
	p_itemkey			IN  VARCHAR2,
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
        p_expenditure_item_date         IN  DATE,       /* Added For Bug 1629411 */
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
        p_class_code                    IN pa_class_codes.class_code%TYPE,
        p_direct_flag                   IN pa_project_types_all.direct_flag%TYPE,
        p_expenditure_category          IN pa_expenditure_categories.expenditure_category%TYPE,
        p_expenditure_org_name          IN hr_organization_units.name%TYPE,
        p_project_number                IN pa_projects_all.segment1%TYPE,
        p_project_organization_name     IN hr_organization_units.name%TYPE,
        p_project_organization_id       IN hr_organization_units.organization_id %TYPE,
        p_project_type                  IN pa_project_types_all.project_type%TYPE,
        p_public_sector_flag            IN pa_projects_all.public_sector_flag%TYPE,
        p_revenue_category              IN pa_expenditure_types.revenue_category_code%TYPE,
        p_task_number                   IN pa_tasks.task_number%TYPE,
        p_task_organization_name        IN hr_organization_units.name%TYPE,
        p_task_organization_id          IN hr_organization_units.organization_id %TYPE,
        p_task_service_type             IN pa_tasks.service_type_code%TYPE,
        p_top_task_id                   IN pa_tasks.task_id%TYPE,
        p_top_task_number               IN pa_tasks.task_number%TYPE) AS



   BEGIN
       set_error_stack('-->Set_Pa_Item_Attr'); /* Bug 5233487 */
       g_encoded_error_message := NULL; /* Bug 5233487 */
       g_error_message := '';
       g_error_stage := '10';

	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PROJECT_ID',
				   avalue	=> p_project_id);
	g_error_stage := '20';


	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TASK_ID',
				   avalue	=> p_task_id);
        g_error_stage := '30';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'EXPENDITURE_TYPE',
				   avalue	=> p_expenditure_type);
        g_error_stage := '40';

	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'EXPENDITURE_ORGANIZATION_ID',
				   avalue	=> p_expenditure_organization_id);
        g_error_stage := '50';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'BILLABLE_FLAG',
				   avalue	=> p_billable_flag);
        g_error_stage := '60';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'CLASS_CODE',
				   avalue	=> p_class_code);
        g_error_stage := '70';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'DIRECT_FLAG',
				   avalue	=> p_direct_flag);
        g_error_stage := '80';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'EXPENDITURE_CATEGORY',
				   avalue	=> p_expenditure_category);
        g_error_stage := '90';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'EXPENDITURE_ORG_NAME',
				   avalue	=> p_expenditure_org_name);
        g_error_stage := '100';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PROJECT_NUMBER',
				   avalue	=> p_project_number);
        g_error_stage := '110';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PROJECT_ORGANIZATION_NAME',
				   avalue	=> p_project_organization_name);
        g_error_stage := '120';

	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PROJECT_ORGANIZATION_ID',
				   avalue	=> p_project_organization_id);
        g_error_stage := '130';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PROJECT_TYPE',
				   avalue	=> p_project_type);
        g_error_stage := '140';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'PUBLIC_SECTOR_FLAG',
				   avalue	=> p_public_sector_flag);
        g_error_stage := '150';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'REVENUE_CATEGORY',
				   avalue	=> p_revenue_category);
        g_error_stage := '160';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TASK_NUMBER',
				   avalue	=> p_task_number);
        g_error_stage := '170';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TASK_ORGANIZATION_NAME',
				   avalue	=> p_task_organization_name);
        g_error_stage := '180';

	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TASK_ORGANIZATION_ID',
				   avalue	=> p_task_organization_id);
        g_error_stage := '190';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TASK_SERVICE_TYPE',
				   avalue	=> p_task_service_type);
        g_error_stage := '200';

	wf_engine.SetItemAttrNumber( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TOP_TASK_ID',
				   avalue	=> p_top_task_id);
        g_error_stage := '210';

	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TOP_TASK_NUMBER',
				   avalue	=> p_top_task_number);

        /* Added for bug 1629411 */

        g_error_stage := '220';

        wf_engine.SetItemAttrText( itemtype     => p_itemtype,
                                   itemkey      => p_itemkey,
                                   aname        => 'EXPENDITURE_ITEM_DATE',
                                   avalue       => to_char(p_expenditure_item_date));

   reset_error_stack; /* Bug 5233487 */

   EXCEPTION WHEN OTHERS THEN
/* Bug 5233487 - Start */
      IF g_encoded_error_message IS NULL THEN
          g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
      END IF;
      reset_error_stack;
/* Bug 5233487 - End */
      g_error_message := SQLERRM;
      RAISE;
   END set_pa_item_attr;
------------------- End pa_acc_gen_wf_pkg.Set_pa_item_attr --------------------

----------------------------------------------------------------------
-- Procedure pa_acc_gen_wf_pkg.ap_er_generate_account
-- Definition of package body and function in package specifications
----------------------------------------------------------------------

  FUNCTION ap_er_generate_account
  (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN
					    pa_expenditure_items_all.expenditure_item_date%TYPE,
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
	p_chart_of_accounts_id		IN  NUMBER,
        p_calling_module		IN  VARCHAR2,
	p_employee_id			IN  per_people_f.person_id%TYPE,
	p_employee_ccid			IN  gl_code_combinations.code_combination_id%TYPE,
	p_expense_type			IN  ap_expense_report_lines_all.web_parameter_id%TYPE,
	p_expense_cc			IN  ap_expense_report_headers_all.flex_concatenated%TYPE,
        p_attribute_category            IN  ap_expense_report_headers_all.attribute_category%TYPE,
        p_attribute1                    IN  ap_expense_report_headers_all.attribute1%TYPE,
        p_attribute2                    IN  ap_expense_report_headers_all.attribute2%TYPE,
        p_attribute3                    IN  ap_expense_report_headers_all.attribute3%TYPE,
        p_attribute4                    IN  ap_expense_report_headers_all.attribute4%TYPE,
        p_attribute5                    IN  ap_expense_report_headers_all.attribute5%TYPE,
        p_attribute6                    IN  ap_expense_report_headers_all.attribute6%TYPE,
        p_attribute7                    IN  ap_expense_report_headers_all.attribute7%TYPE,
        p_attribute8                    IN  ap_expense_report_headers_all.attribute8%TYPE,
        p_attribute9                    IN  ap_expense_report_headers_all.attribute9%TYPE,
        p_attribute10                   IN  ap_expense_report_headers_all.attribute10%TYPE,
        p_attribute11                   IN  ap_expense_report_headers_all.attribute11%TYPE,
        p_attribute12                   IN  ap_expense_report_headers_all.attribute12%TYPE,
        p_attribute13                   IN  ap_expense_report_headers_all.attribute13%TYPE,
        p_attribute14                   IN  ap_expense_report_headers_all.attribute14%TYPE,
        p_attribute15                   IN  ap_expense_report_headers_all.attribute15%TYPE,
        p_line_attribute_category       IN  ap_expense_report_lines_all.attribute_category%TYPE,
        p_line_attribute1               IN  ap_expense_report_lines_all.attribute1%TYPE,
        p_line_attribute2               IN  ap_expense_report_lines_all.attribute2%TYPE,
        p_line_attribute3               IN  ap_expense_report_lines_all.attribute3%TYPE,
        p_line_attribute4               IN  ap_expense_report_lines_all.attribute4%TYPE,
        p_line_attribute5               IN  ap_expense_report_lines_all.attribute5%TYPE,
        p_line_attribute6               IN  ap_expense_report_lines_all.attribute6%TYPE,
        p_line_attribute7               IN  ap_expense_report_lines_all.attribute7%TYPE,
        p_line_attribute8               IN  ap_expense_report_lines_all.attribute8%TYPE,
        p_line_attribute9               IN  ap_expense_report_lines_all.attribute9%TYPE,
        p_line_attribute10              IN  ap_expense_report_lines_all.attribute10%TYPE,
        p_line_attribute11              IN  ap_expense_report_lines_all.attribute11%TYPE,
        p_line_attribute12              IN  ap_expense_report_lines_all.attribute12%TYPE,
        p_line_attribute13              IN  ap_expense_report_lines_all.attribute13%TYPE,
        p_line_attribute14              IN  ap_expense_report_lines_all.attribute14%TYPE,
        p_line_attribute15              IN  ap_expense_report_lines_all.attribute15%TYPE,
	p_input_ccid			IN  gl_code_combinations.code_combination_id%TYPE default null, /* Bug 5378579 */
	x_return_ccid			OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
	x_concat_segs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_ids			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_descrs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_error_message			OUT NOCOPY VARCHAR2,
/* R12 Changes Start - Added two new parameters Award_Id and Expenditure Item ID */
	X_award_set_id			IN  NUMBER DEFAULT NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL )
/* R12 Changes End */
      RETURN BOOLEAN IS

  l_itemtype  			CONSTANT VARCHAR2(30) := 'PAAPWEBX';
  l_itemkey			VARCHAR2(30);
  l_result 			BOOLEAN;
  l_concat_segs 		VARCHAR2(200);
  l_concat_ids			VARCHAR2(200);
  l_concat_descrs		VARCHAR2(500);
  l_return_ccid 		gl_code_combinations.code_combination_id%TYPE;
  l_employee_ccid 		gl_code_combinations.code_combination_id%TYPE;
  l_class_code			pa_class_codes.class_code%TYPE;
  l_direct_flag			pa_project_types_all.direct_flag%TYPE;
  l_expenditure_category	pa_expenditure_categories.expenditure_category%TYPE;
  l_expenditure_organization_id          hr_organization_units.organization_id%TYPE;
  l_expenditure_org_name	hr_organization_units.name%TYPE;
  l_project_number		pa_projects_all.segment1%TYPE;
  l_project_organization_name	hr_organization_units.name%TYPE;
  l_project_organization_id	hr_organization_units.organization_id %TYPE;
  l_project_type		pa_project_types_all.project_type%TYPE;
  l_public_sector_flag		pa_projects_all.public_sector_flag%TYPE;
  l_revenue_category		pa_expenditure_types.revenue_category_code%TYPE;
  l_task_number			pa_tasks.task_number%TYPE;
  l_task_organization_name	hr_organization_units.name%TYPE;
  l_task_organization_id	hr_organization_units.organization_id %TYPE;
  l_task_service_type		pa_tasks.service_type_code%TYPE;
  l_top_task_id			pa_tasks.task_id%TYPE;
  l_top_task_number		pa_tasks.task_number%TYPE;
  l_employee_number		per_people_f.employee_number%TYPE;
  l_vendor_type			po_vendors.vendor_type_lookup_code%TYPE;
  l_error_message		VARCHAR2(1000) := '';
  l_org_id                      hr_organization_units.organization_id %TYPE; -- Workflow Enhancement

  l_code_combination            BOOLEAN;
  l_person_type			VARCHAR2(10);

/* R12 Changes Start */
/* Local variable used to set WF AWARD ID attribute */
  l_award_id                    NUMBER;
/* R12 Changes End */

  l_input_ccid 			gl_code_combinations.code_combination_id%TYPE; /* Bug 5378579 */

  BEGIN
  ---------------------------------------------------------------
  -- Derive Organization id if employee id is present and
  -- organization id is null
  ---------------------------------------------------------------
  set_error_stack('-->pa_acc_gen_wf_pkg.ap_er_generate_account'); /* Bug 5233487 */
  g_encoded_error_message := NULL; /* Bug 5233487 */
  g_error_stage := '10';
  g_error_message := '';

  IF p_expenditure_organization_id IS NULL
  THEN
    IF p_employee_id IS NOT NULL
    THEN
      l_expenditure_organization_id := pa_utils.GetEmpOrgId(p_employee_id,
					 nvl(p_expenditure_item_date,sysdate));
    END IF;
  ELSE
    l_expenditure_organization_id := p_expenditure_organization_id;
  END IF;
---------------------------------------------------------------------
-- Call the procedure to obtain the derived parameters from the raw
-- parameters
---------------------------------------------------------------------
   g_error_stage := '20';
   l_employee_ccid := p_employee_ccid;

	pa_acc_gen_wf_pkg.wf_acc_derive_er_params
		(
		p_project_id			=> p_project_id,
		p_task_id			=> p_task_id,
		p_expenditure_type		=> p_expenditure_type,
		p_vendor_id			=> p_vendor_id,
		p_expenditure_organization_id	=> l_expenditure_organization_id,
		p_expenditure_item_date		=> p_expenditure_item_date,
  		p_calling_module                => p_calling_module,
                p_employee_id                   => p_employee_id,
                p_employee_ccid                 => l_employee_ccid,
                p_expense_type                  => p_expense_type,
                p_expense_cc                    => p_expense_cc,
		x_class_code			=> l_class_code,
		x_direct_flag			=> l_direct_flag,
		x_expenditure_category		=> l_expenditure_category,
		x_expenditure_org_name		=> l_expenditure_org_name,
		x_project_number		=> l_project_number,
		x_project_organization_name	=> l_project_organization_name,
		x_project_organization_id	=> l_project_organization_id,
		x_project_type			=> l_project_type,
		x_public_sector_flag		=> l_public_sector_flag,
		x_revenue_category		=> l_revenue_category,
		x_task_number			=> l_task_number,
		x_task_organization_name	=> l_task_organization_name,
		x_task_organization_id		=> l_task_organization_id,
		x_task_service_type		=> l_task_service_type,
		x_top_task_id			=> l_top_task_id,
		x_top_task_number		=> l_top_task_number,
		x_employee_number		=> l_employee_number,
		x_vendor_type			=> l_vendor_type,
                x_person_type			=> l_person_type);

   -------------------------------------
   -- Call the FND initialize function
   -------------------------------------
     g_error_stage := '30';

     l_itemkey := fnd_flex_workflow.initialize
				(appl_short_name => 'SQLGL',
				 code 		 => 'GL#',
				 num 		 =>  p_chart_of_accounts_id,
			         itemtype 	 =>l_itemtype);

	---------------------------------------------
	-- Initialize the workflow item attributes
	---------------------------------------------
        g_error_stage := '40';

	pa_acc_gen_wf_pkg.Set_Pa_Item_Attr(
		p_itemtype 			=> l_itemtype,
	        p_itemkey			=> l_itemkey,
	        p_project_id    		=> p_project_id,
      		p_task_id			=> p_task_id,
      		p_expenditure_type		=> p_expenditure_type,
      		p_expenditure_organization_id   => l_expenditure_organization_id,
                p_expenditure_item_date         => p_expenditure_item_date,
      		p_billable_flag 		=> p_billable_flag,
      		p_class_code    		=> l_class_code,
     	 	p_direct_flag  	 		=> l_direct_flag,
      		p_expenditure_category		=> l_expenditure_category,
      		p_expenditure_org_name  	=> l_expenditure_org_name,
      		p_project_number		=> l_project_number,
      		p_project_organization_name  	=> l_project_organization_name,
      		p_project_organization_id    	=> l_project_organization_id,
      		p_project_type			=> l_project_type,
      		p_public_sector_flag		=> l_public_sector_flag,
      		p_revenue_category		=> l_revenue_category,
      		p_task_number			=> l_task_number,
      		p_task_organization_name 	=> l_task_organization_name,
      		p_task_organization_id		=> l_task_organization_id,
      		p_task_service_type		=> l_task_service_type,
      		p_top_task_id			=> l_top_task_id,
      		p_top_task_number		=> l_top_task_number);

	g_error_stage := '50';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_ID',
				   avalue	=> p_vendor_id);

/* R12 Changes Start - Commented for R12; workflow will use award id instead
                       of award set id
	g_error_stage := '55';
	-- ---------------------------------------------------------------
	-- OGM_0.0 : Vertical application OGM may use award_set_id to
	-- derive award_id, which can be used to derive segments for
	-- the account generator.
	-- ---------------------------------------------------------------
	IF x_award_set_id is not NULL THEN
		wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
					   itemkey 	=> l_itemkey,
					   aname	=> 'AWARD_SET_ID',
					   avalue	=> x_award_set_id);
	END IF ;
   R12 Changes End */

	g_error_stage := '60';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'EMPLOYEE_ID',
				   avalue	=> p_employee_id);
	g_error_stage := '70';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'EMPLOYEE_NUMBER',
				   avalue	=> l_employee_number);

        g_error_stage := '71';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'PERSON_TYPE',
				   avalue	=> l_person_type);

	g_error_stage := '80';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_TYPE',
				   avalue	=> l_vendor_type);
	g_error_stage := '90';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'CHART_OF_ACCOUNTS_ID',
				   avalue	=> p_chart_of_accounts_id);
	g_error_stage := '100';

        wf_engine.SetItemAttrText( itemtype   => l_itemtype,
                                   itemkey      => l_itemkey,
                                   aname        => 'CALLING_MODULE',
                                   avalue       => p_calling_module);
	g_error_stage := '110';

	wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                                   itemkey      => l_itemkey,
                                   aname        => 'EMPLOYEE_CCID',
                                   avalue       => l_employee_ccid);
	g_error_stage := '120';

	wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                                   itemkey      => l_itemkey,
                                   aname        => 'EXPENSE_TYPE',
                                   avalue       => p_expense_type);
	g_error_stage := '130';

	wf_engine.SetItemAttrText( itemtype   => l_itemtype,
                                   itemkey      => l_itemkey,
                                   aname        => 'EXPENSE_CC',
                                   avalue       => p_expense_cc);
	g_error_stage := '140';

  IF p_attribute_category IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE_CATEGORY',
				   avalue	=> p_attribute_category);
  END IF;

	g_error_stage := '150';

  IF p_attribute1 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE1',
				   avalue	=> p_attribute1);
  END IF;

	g_error_stage := '160';

  IF p_attribute2 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE2',
				   avalue	=> p_attribute2);
  END IF;


	g_error_stage := '170';

  IF p_attribute3 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE3',
				   avalue	=> p_attribute3);
  END IF;

	g_error_stage := '180';

  IF p_attribute4 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE4',
				   avalue	=> p_attribute4);
  END IF;

	g_error_stage := '190';

  IF p_attribute5 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE5',
				   avalue	=> p_attribute5);
  END IF;

        g_error_stage := '200';

  IF p_attribute6 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE6',
				   avalue	=> p_attribute6);
  END IF;

        g_error_stage := '210';

  IF p_attribute7 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE7',
				   avalue	=> p_attribute7);
  END IF;
        g_error_stage := '220';

  IF p_attribute8 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE8',
				   avalue	=> p_attribute8);
  END IF;
        g_error_stage := '230';

  IF p_attribute9 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE9',
				   avalue	=> p_attribute9);
  END IF;
        g_error_stage := '240';

  IF p_attribute10 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE10',
				   avalue	=> p_attribute10);
  END IF;
        g_error_stage := '250';

  IF p_attribute11 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE11',
				   avalue	=> p_attribute11);
  END IF;
        g_error_stage := '260';

  IF p_attribute12 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE12',
				   avalue	=> p_attribute12);
  END IF;
        g_error_stage := '270';

  IF p_attribute13 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE13',
				   avalue	=> p_attribute13);
  END IF;
        g_error_stage := '280';

  IF p_attribute14 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE14',
				   avalue	=> p_attribute14);
  END IF;
        g_error_stage := '290';

  IF p_attribute15 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE15',
				   avalue	=> p_attribute15);
  END IF;
        g_error_stage := '300';

  IF p_line_attribute1 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE1',
				   avalue	=> p_line_attribute1);

  END IF;
        g_error_stage := '310';

  IF p_line_attribute2 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE2',
				   avalue	=> p_line_attribute2);

  END IF;
        g_error_stage := '320';

  IF p_line_attribute3 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE3',
				   avalue	=> p_line_attribute3);

  END IF;
        g_error_stage := '330';

  IF p_line_attribute4 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE4',
				   avalue	=> p_line_attribute4);

  END IF;
        g_error_stage := '340';

  IF p_line_attribute5 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE5',
				   avalue	=> p_line_attribute5);

  END IF;
        g_error_stage := '350';

  IF p_line_attribute6 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE6',
				   avalue	=> p_line_attribute6);

  END IF;
        g_error_stage := '360';

  IF p_line_attribute7 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE7',
				   avalue	=> p_line_attribute7);

  END IF;
        g_error_stage := '370';

  IF p_line_attribute8 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE8',
				   avalue	=> p_line_attribute8);

  END IF;
        g_error_stage := '380';

  IF p_line_attribute9 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE9',
				   avalue	=> p_line_attribute9);

  END IF;
        g_error_stage := '390';

  IF p_line_attribute10 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE10',
				   avalue	=> p_line_attribute10);

  END IF;
        g_error_stage := '400';

  IF p_line_attribute11 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE11',
				   avalue	=> p_line_attribute11);

  END IF;
        g_error_stage := '410';

  IF p_line_attribute12 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE12',
				   avalue	=> p_line_attribute12);

  END IF;
        g_error_stage := '420';

  IF p_line_attribute13 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE13',
				   avalue	=> p_line_attribute13);

  END IF;
        g_error_stage := '430';

  IF p_line_attribute14 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE14',
				   avalue	=> p_line_attribute14);

  END IF;
        g_error_stage := '440';

  IF p_line_attribute15 IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE15',
				   avalue	=> p_line_attribute15);

  END IF;
        g_error_stage := '450';

  IF p_line_attribute_category IS NOT NULL
  THEN
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'LINE_ATTRIBUTE_CATEGORY',
				   avalue	=> p_line_attribute_category);
  END IF;

 --- Following section has been added as a part of enhancement request where
 --- Users can have workflow(PAAPINVW) setup accross orgs.
 --- Workflow Enhancement

      BEGIN
        SELECT org_id
        INTO   l_org_id
        FROM   PA_IMPLEMENTATIONS;
     END;

	g_error_stage := '451';

        wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'ORG_ID',
				     avalue	=> l_org_id);

/* Bug 5935019 - Changes start */
  -- We cannot directly assign this to attribute
  -- 'FND_FLEX_SEGMENTS' as workflow will take care of this.
  IF x_concat_segs IS NOT NULL THEN
    g_error_stage := '382';

    wf_engine.SetItemAttrText( itemtype => l_itemtype,
       itemkey => l_itemkey,
       aname => 'CONCAT_SEGMENTS',
       avalue => x_concat_segs);
  END IF;
/* Bug 5935019 - Changes end  */

/* R12 Changes Start - Setting attributes Award ID and Expenditure Item ID
   for Workflow */
  g_error_stage := '452';

  IF x_award_set_id IS NOT NULL THEN

    l_award_id := PA_GMS_API.VERT_GET_AWARD_ID(x_award_set_id,NULL,NULL);

  ELSE

    l_award_id := p_award_id;

  END IF;

  IF l_award_id IS NOT NULL THEN

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'AWARD_ID',
				     avalue	=> l_award_id);

  END IF;

  g_error_stage := '453';

  IF p_expenditure_item_id IS NOT NULL THEN

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'EXPENDITURE_ITEM_ID',
				     avalue	=> p_expenditure_item_id);

  END IF;
/* R12 Changes End */

/* Bug 5378579 - Start */
    g_error_stage := '454';

    IF p_input_ccid IS NULL THEN
       l_input_ccid := 0;
    ELSE
       l_input_ccid := p_input_ccid;
    END IF;

    wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
                                 itemkey 	=> l_itemkey,
				 aname	        => 'DIST_CODE_COMBINATION_ID',
				 avalue	        => l_input_ccid);
/* Bug 5378579 - End */

    -----------------------------------------------------------
    -- Call the workflow Generate function to trigger off the
    -- workflow account generation
    -----------------------------------------------------------
     g_error_stage := '460';

     l_result := fnd_flex_workflow.generate(	l_itemtype,
						l_itemkey,
                                                TRUE,
						l_return_ccid,
						x_concat_segs,   -- Bug 5935019
						x_concat_ids,    -- Bug 5935019
						x_concat_descrs, -- Bug 5935019
						l_error_message,
                                                l_code_combination);

    ---Added this section for Workflow error handling.
    -- Workflow Enhancement
/*  IF (l_result and ( l_return_ccid is null or l_return_ccid = 0 or l_return_ccid = -1 ))  OR
       (NOT l_result) THEN  ** commenting this out for bug 2802847 */

/* Added the check for l_error_message for bug 2694601 */
	IF l_error_message is null THEN
        fnd_message.set_name('PA','PA_WF_SETUP_ERROR');
        x_error_message := fnd_message.get_encoded;
	ELSE
	x_error_message := l_error_message;
	END IF;
/* 2694601 */

/*     return(FALSE);
    END IF; ** bug 2802847 */

	 ------------------------------------------------------------------
	 -- Copy the return values to the corresponding output parameters
	 ------------------------------------------------------------------
/* Bug 5935019 - Changes start -- commented 3 lines
	 x_concat_segs 	:= l_concat_segs;
	 x_concat_ids 	:= l_concat_ids;
	 x_concat_descrs:= l_concat_descrs;
   Bug 5935019 - Changes start */
--	 x_error_message:= l_error_message;   bug 2802847
	 x_return_ccid	:= l_return_ccid;

        -------------------------------------------------------------------
        -- Reset the error stack.
        -------------------------------------------------------------------

        reset_error_stack;

	--------------------------------------------------------------------
	-- Return the return value of the Generate function as the return
	-- value for the process
	--------------------------------------------------------------------

  	RETURN l_result;

     EXCEPTION

     WHEN OTHERS
       THEN

  -----------------------------------------------------------------------
  -- Record error using generic error message routine for debugging and
  -- raise it
  -----------------------------------------------------------------------
/* Bug 5233487 - Start */
        IF g_encoded_error_message IS NULL THEN
            g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
        END IF;
        x_error_message := g_encoded_error_message;
        reset_error_stack;
/* Bug 5233487 - End */

        wf_core.context( pkg_name	=> 'pa_acc_gen_wf_pkg',
			 proc_name	=> 'ap_er_generate_account',
			 arg1		=>  'Project id: '||p_project_id,
			 arg2		=>  'Task id: '||p_task_id,
			 arg3		=>  'Vendor id: '||p_vendor_id,
			 arg4		=>  'Exp type: '||p_expenditure_type,
			 arg5		=>  'Exp Org id: '||p_expenditure_organization_id);

        RETURN FALSE;

  END ap_er_generate_account;

----------------------------------------------------------------------
-- Procedure pa_acc_gen_wf_pkg.ap_inv_generate_account
-- Definition of package body and function in package specifications
----------------------------------------------------------------------

  FUNCTION ap_inv_generate_account
  (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN
					    pa_expenditure_items_all.expenditure_item_date%TYPE,
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
	p_chart_of_accounts_id		IN  NUMBER,
	p_attribute_category		IN  ap_invoices_all.attribute_category%TYPE,
	p_attribute1			IN  ap_invoices_all.attribute1%TYPE,
	p_attribute2			IN  ap_invoices_all.attribute2%TYPE,
	p_attribute3			IN  ap_invoices_all.attribute3%TYPE,
	p_attribute4			IN  ap_invoices_all.attribute4%TYPE,
	p_attribute5			IN  ap_invoices_all.attribute5%TYPE,
	p_attribute6			IN  ap_invoices_all.attribute6%TYPE,
	p_attribute7			IN  ap_invoices_all.attribute7%TYPE,
	p_attribute8			IN  ap_invoices_all.attribute8%TYPE,
	p_attribute9			IN  ap_invoices_all.attribute9%TYPE,
	p_attribute10			IN  ap_invoices_all.attribute10%TYPE,
	p_attribute11			IN  ap_invoices_all.attribute11%TYPE,
	p_attribute12			IN  ap_invoices_all.attribute12%TYPE,
	p_attribute13			IN  ap_invoices_all.attribute13%TYPE,
	p_attribute14			IN  ap_invoices_all.attribute14%TYPE,
	p_attribute15			IN  ap_invoices_all.attribute15%TYPE,
	p_dist_attribute_category	IN
					    ap_invoice_distributions_all.attribute_category%TYPE,
	p_dist_attribute1		IN  ap_invoice_distributions_all.attribute1%TYPE,
	p_dist_attribute2		IN  ap_invoice_distributions_all.attribute2%TYPE,
	p_dist_attribute3		IN  ap_invoice_distributions_all.attribute3%TYPE,
	p_dist_attribute4		IN  ap_invoice_distributions_all.attribute4%TYPE,
	p_dist_attribute5		IN  ap_invoice_distributions_all.attribute5%TYPE,
	p_dist_attribute6		IN  ap_invoice_distributions_all.attribute6%TYPE,
	p_dist_attribute7		IN  ap_invoice_distributions_all.attribute7%TYPE,
	p_dist_attribute8		IN  ap_invoice_distributions_all.attribute8%TYPE,
	p_dist_attribute9		IN  ap_invoice_distributions_all.attribute9%TYPE,
	p_dist_attribute10		IN  ap_invoice_distributions_all.attribute10%TYPE,
	p_dist_attribute11		IN  ap_invoice_distributions_all.attribute11%TYPE,
	p_dist_attribute12		IN  ap_invoice_distributions_all.attribute12%TYPE,
	p_dist_attribute13		IN  ap_invoice_distributions_all.attribute13%TYPE,
	p_dist_attribute14		IN  ap_invoice_distributions_all.attribute14%TYPE,
	p_dist_attribute15		IN  ap_invoice_distributions_all.attribute15%TYPE,
/* Adding parameter p_input_ccid for bug 2348764 */
	p_input_ccid			IN gl_code_combinations.code_combination_id%TYPE default NULL,
	x_return_ccid			OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
	x_concat_segs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_ids			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_descrs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_error_message			OUT NOCOPY VARCHAR2,
	X_award_set_id			IN  NUMBER DEFAULT NULL,
/* R12 Changes Start - Added two new parameters Award_Id and Expenditure Item ID */
        p_accounting_date               IN ap_invoice_distributions_all.accounting_date%TYPE default NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL )
/* R12 Changes End */

      RETURN BOOLEAN IS
  l_itemtype  			CONSTANT VARCHAR2(30) := 'PAAPINVW';
  l_itemkey			VARCHAR2(30);
  l_result 			BOOLEAN;
  l_concat_segs 		VARCHAR2(200);
  l_concat_ids			VARCHAR2(200);
  l_concat_descrs		VARCHAR2(500);
/* Adding parameter l_input_ccid for bug 2348764 */
  l_input_ccid 			gl_code_combinations.code_combination_id%TYPE;
  l_return_ccid 		gl_code_combinations.code_combination_id%TYPE;
  l_class_code			pa_class_codes.class_code%TYPE;
  l_direct_flag			pa_project_types_all.direct_flag%TYPE;
  l_expenditure_category	pa_expenditure_categories.expenditure_category%TYPE;
  l_expenditure_org_name	hr_organization_units.name%TYPE;
  l_project_number		pa_projects_all.segment1%TYPE;
  l_project_organization_name	hr_organization_units.name%TYPE;
  l_project_organization_id	hr_organization_units.organization_id %TYPE;
  l_project_type		pa_project_types_all.project_type%TYPE;
  l_public_sector_flag		pa_projects_all.public_sector_flag%TYPE;
  l_revenue_category		pa_expenditure_types.revenue_category_code%TYPE;
  l_task_number			pa_tasks.task_number%TYPE;
  l_task_organization_name	hr_organization_units.name%TYPE;
  l_task_organization_id	hr_organization_units.organization_id %TYPE;
  l_task_service_type		pa_tasks.service_type_code%TYPE;
  l_top_task_id			pa_tasks.task_id%TYPE;
  l_top_task_number		pa_tasks.task_number%TYPE;
  l_vendor_employee_id		per_people_f.person_id%TYPE;
  l_vendor_employee_number	per_people_f.employee_number%TYPE;
  l_vendor_type			po_vendors.vendor_type_lookup_code%TYPE;
  l_error_message		VARCHAR2(1000) :='';
  l_accounting_date             DATE;
  l_org_id                      hr_organization_units.organization_id %TYPE; -- Workflow Enhancement

  l_code_combination            BOOLEAN;

/* R12 Changes Start */
/* Local variable used to set WF AWARD ID attribute */
  l_award_id                    NUMBER;
/* R12 Changes End */

  BEGIN
---------------------------------------------------------------------
-- Call the procedure to obtain the derived parameters from the raw
-- parameters
---------------------------------------------------------------------
        set_error_stack('-->pa_acc_gen_wf_pkg.ap_inv_generate_account'); /* Bug 5233487 */
        g_encoded_error_message := NULL; /* Bug 5233487 */
        g_error_stage := '10';
        g_error_message := '';

	pa_acc_gen_wf_pkg.wf_acc_derive_params
		(
		p_project_id			=> p_project_id,
		p_task_id			=> p_task_id,
		p_expenditure_type		=> p_expenditure_type,
		p_vendor_id			=> p_vendor_id,
		p_expenditure_organization_id	=> p_expenditure_organization_id,
		p_expenditure_item_date		=> p_expenditure_item_date,
		x_class_code			=> l_class_code,
		x_direct_flag			=> l_direct_flag,
		x_expenditure_category		=> l_expenditure_category,
		x_expenditure_org_name		=> l_expenditure_org_name,
		x_project_number		=> l_project_number,
		x_project_organization_name	=> l_project_organization_name,
		x_project_organization_id	=> l_project_organization_id,
		x_project_type			=> l_project_type,
		x_public_sector_flag		=> l_public_sector_flag,
		x_revenue_category		=> l_revenue_category,
		x_task_number			=> l_task_number,
		x_task_organization_name	=> l_task_organization_name,
		x_task_organization_id		=> l_task_organization_id,
		x_task_service_type		=> l_task_service_type,
		x_top_task_id			=> l_top_task_id,
		x_top_task_number		=> l_top_task_number,
		x_vendor_employee_id		=> l_vendor_employee_id,
		x_vendor_employee_number	=> l_vendor_employee_number,
		x_vendor_type			=> l_vendor_type);

   -------------------------------------
   -- Call the FND initialize function
   -------------------------------------
     g_error_stage := '20';

     l_itemkey := fnd_flex_workflow.initialize
				(appl_short_name => 'SQLGL',
				 code 		 => 'GL#',
				 num 		 =>  p_chart_of_accounts_id,
			         itemtype 	 =>l_itemtype);

	---------------------------------------------
	-- Initialize the workflow item attributes
	---------------------------------------------
	g_error_stage := '30';

	pa_acc_gen_wf_pkg.Set_Pa_Item_Attr(
		p_itemtype 			=> l_itemtype,
	        p_itemkey			=> l_itemkey,
	        p_project_id    		=> p_project_id,
      		p_task_id			=> p_task_id,
      		p_expenditure_type		=> p_expenditure_type,
      		p_expenditure_organization_id   => p_expenditure_organization_id,
                p_expenditure_item_date         => p_expenditure_item_date,
      		p_billable_flag 		=> p_billable_flag,
      		p_class_code    		=> l_class_code,
     	 	p_direct_flag  	 		=> l_direct_flag,
      		p_expenditure_category		=> l_expenditure_category,
      		p_expenditure_org_name  	=> l_expenditure_org_name,
      		p_project_number		=> l_project_number,
      		p_project_organization_name  	=> l_project_organization_name,
      		p_project_organization_id    	=> l_project_organization_id,
      		p_project_type			=> l_project_type,
      		p_public_sector_flag		=> l_public_sector_flag,
      		p_revenue_category		=> l_revenue_category,
      		p_task_number			=> l_task_number,
      		p_task_organization_name 	=> l_task_organization_name,
      		p_task_organization_id		=> l_task_organization_id,
      		p_task_service_type		=> l_task_service_type,
      		p_top_task_id			=> l_top_task_id,
      		p_top_task_number		=> l_top_task_number);

 	g_error_stage := '40';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_ID',
				   avalue	=> p_vendor_id);

/*Added for bug2100489 */

        g_error_stage :='45';

        wf_engine.SetItemAttrText( itemtype     => l_itemtype,
                                   itemkey      => l_itemkey,
                                   aname        => 'ACCOUNTING_DATE',
                                   avalue       => to_char(NVL(p_accounting_date,sysdate)));

	g_error_stage := '50';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_EMPLOYEE_ID',
				   avalue	=> l_vendor_employee_id);

/* R12 changes Start - Commented for R12; workflow will use award id instead
                       of award set id
	g_error_stage := '55';
	-- ---------------------------------------------------------------
	-- OGM_0.0 : Vertical application OGM may use award_set_id to
	-- derive award_id, which can be used to derive segments for
	-- the account generator.
	-- ---------------------------------------------------------------
	IF x_award_set_id is not NULL THEN

		wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
					   itemkey 	=> l_itemkey,
					   aname	=> 'AWARD_SET_ID',
					   avalue	=> x_award_set_id);
	END IF ;
   R12 Changes End */

	g_error_stage := '60';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_EMPLOYEE_NUMBER',
				   avalue	=> l_vendor_employee_number);

	g_error_stage := '70';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'VENDOR_TYPE',
				   avalue	=> l_vendor_type);

	g_error_stage := '80';

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'CHART_OF_ACCOUNTS_ID',
				   avalue	=> p_chart_of_accounts_id);

  IF p_attribute_category IS NOT NULL
  THEN
	g_error_stage := '90';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE_CATEGORY',
				   avalue	=> p_attribute_category);
  END IF;

  IF p_attribute1 IS NOT NULL
  THEN
	g_error_stage := '100';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE1',
				   avalue	=> p_attribute1);
  END IF;

  IF p_attribute2 IS NOT NULL
  THEN
	g_error_stage := '110';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE2',
				   avalue	=> p_attribute2);
  END IF;

  IF p_attribute3 IS NOT NULL
  THEN
	g_error_stage := '120';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE3',
				   avalue	=> p_attribute3);
  END IF;

  IF p_attribute4 IS NOT NULL
  THEN
	g_error_stage := '130';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE4',
				   avalue	=> p_attribute4);
  END IF;

  IF p_attribute5 IS NOT NULL
  THEN
	g_error_stage := '140';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE5',
				   avalue	=> p_attribute5);
  END IF;

  IF p_attribute6 IS NOT NULL
  THEN
	g_error_stage := '150';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE6',
				   avalue	=> p_attribute6);
  END IF;

  IF p_attribute7 IS NOT NULL
  THEN
	g_error_stage := '160';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE7',
				   avalue	=> p_attribute7);
  END IF;

  IF p_attribute8 IS NOT NULL
  THEN
	g_error_stage := '170';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE8',
				   avalue	=> p_attribute8);
  END IF;

  IF p_attribute9 IS NOT NULL
  THEN
	g_error_stage := '180';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE9',
				   avalue	=> p_attribute9);
  END IF;

  IF p_attribute10 IS NOT NULL
  THEN
	g_error_stage := '190';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE10',
				   avalue	=> p_attribute10);
  END IF;

  IF p_attribute11 IS NOT NULL
  THEN
	g_error_stage := '200';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE11',
				   avalue	=> p_attribute11);
  END IF;

  IF p_attribute12 IS NOT NULL
  THEN
	g_error_stage := '210';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE12',
				   avalue	=> p_attribute12);
  END IF;

  IF p_attribute13 IS NOT NULL
  THEN
	g_error_stage := '220';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE13',
				   avalue	=> p_attribute13);
  END IF;

  IF p_attribute14 IS NOT NULL
  THEN
	g_error_stage := '230';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE14',
				   avalue	=> p_attribute14);
  END IF;

  IF p_attribute15 IS NOT NULL
  THEN
	g_error_stage := '240';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'ATTRIBUTE15',
				   avalue	=> p_attribute15);
  END IF;

  IF p_dist_attribute1 IS NOT NULL
  THEN
	g_error_stage := '250';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE1',
				   avalue	=> p_dist_attribute1);

  END IF;

  IF p_dist_attribute2 IS NOT NULL
  THEN
	g_error_stage := '260';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE2',
				   avalue	=> p_dist_attribute2);

  END IF;

  IF p_dist_attribute3 IS NOT NULL
  THEN
	g_error_stage := '270';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE3',
				   avalue	=> p_dist_attribute3);

  END IF;

  IF p_dist_attribute4 IS NOT NULL
  THEN
	g_error_stage := '280';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE4',
				   avalue	=> p_dist_attribute4);

  END IF;

  IF p_dist_attribute5 IS NOT NULL
  THEN
	g_error_stage := '290';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE5',
				   avalue	=> p_dist_attribute5);

  END IF;

  IF p_dist_attribute6 IS NOT NULL
  THEN
	g_error_stage := '280';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE6',
				   avalue	=> p_dist_attribute6);

  END IF;

  IF p_dist_attribute7 IS NOT NULL
  THEN
	g_error_stage := '290';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE7',
				   avalue	=> p_dist_attribute7);

  END IF;

  IF p_dist_attribute8 IS NOT NULL
  THEN
	g_error_stage := '300';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE8',
				   avalue	=> p_dist_attribute8);

  END IF;

  IF p_dist_attribute9 IS NOT NULL
  THEN
	g_error_stage := '310';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE9',
				   avalue	=> p_dist_attribute9);

  END IF;

  IF p_dist_attribute10 IS NOT NULL
  THEN
	g_error_stage := '320';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE10',
				   avalue	=> p_dist_attribute10);

  END IF;

  IF p_dist_attribute11 IS NOT NULL
  THEN
	g_error_stage := '330';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE11',
				   avalue	=> p_dist_attribute11);

  END IF;

  IF p_dist_attribute12 IS NOT NULL
  THEN
	g_error_stage := '340';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE12',
				   avalue	=> p_dist_attribute12);

  END IF;

  IF p_dist_attribute13 IS NOT NULL
  THEN
	g_error_stage := '350';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE13',
				   avalue	=> p_dist_attribute13);

  END IF;

  IF p_dist_attribute14 IS NOT NULL
  THEN
	g_error_stage := '360';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE14',
				   avalue	=> p_dist_attribute14);

  END IF;

  IF p_dist_attribute15 IS NOT NULL
  THEN
	g_error_stage := '370';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE15',
				   avalue	=> p_dist_attribute15);

  END IF;

  IF p_dist_attribute_category IS NOT NULL
  THEN
	g_error_stage := '380';

	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
				   itemkey 	=> l_itemkey,
				   aname	=> 'DIST_ATTRIBUTE_CATEGORY',
				   avalue	=> p_dist_attribute_category);
  END IF;

 --- Following section has been added as a part of enhancement request where
 --- Users can have workflow(PAAPINVW) setup accross orgs.
 --- Workflow Enhancement

      BEGIN
        SELECT org_id
        INTO   l_org_id
        FROM   PA_IMPLEMENTATIONS;
     END;

	g_error_stage := '381';

        wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'ORG_ID',
				     avalue	=> l_org_id);

/* Bug 5935019 - Changes start */
  -- We cannot directly assign this to attribute
  -- 'FND_FLEX_SEGMENTS' as workflow will take care of this.
  IF x_concat_segs IS NOT NULL THEN
    g_error_stage := '382';

    wf_engine.SetItemAttrText( itemtype => l_itemtype,
       itemkey => l_itemkey,
       aname => 'CONCAT_SEGMENTS',
       avalue => x_concat_segs);
  END IF;
/* Bug 5935019 - Changes end  */

/* changes for bug 2348764 - passing the value of user entered ccid to
   the workflow */

	g_error_stage := '383';

IF p_input_ccid IS NULL THEN
l_input_ccid := 0;
ELSE
l_input_ccid := p_input_ccid;
END IF;
        wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'DIST_CODE_COMBINATION_ID',
				     avalue	=> l_input_ccid);
/* changes for bug 2348764 end */


/* R12 Changes Start - Setting attributes Award ID and Expenditure Item ID
   for Workflow */
  g_error_stage := '384';

  IF x_award_set_id IS NOT NULL THEN

    l_award_id := PA_GMS_API.VERT_GET_AWARD_ID(x_award_set_id,NULL,NULL);

  ELSE

    l_award_id := p_award_id;

  END IF;

  IF l_award_id IS NOT NULL THEN

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'AWARD_ID',
				     avalue	=> l_award_id);

  END IF;

  g_error_stage := '385';

  IF p_expenditure_item_id IS NOT NULL THEN

	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
				     itemkey 	=> l_itemkey,
				     aname	=> 'EXPENDITURE_ITEM_ID',
				     avalue	=> p_expenditure_item_id);

  END IF;
/* R12 Changes End */

    -----------------------------------------------------------
    -- Call the workflow Generate function to trigger off the
    -- workflow account generation
    -----------------------------------------------------------

	  g_error_stage := '390';

     l_result := fnd_flex_workflow.generate(	l_itemtype,
						l_itemkey,
                                                TRUE,
						l_return_ccid,
						x_concat_segs,   -- Bug 5935019
						x_concat_ids,    -- Bug 5935019
						x_concat_descrs, -- Bug 5935019
						l_error_message,
                                                l_code_combination);

    ---Added this section for Workflow error handling.
    -- Workflow Enhancement
/*  IF (l_result and ( l_return_ccid is null or l_return_ccid = 0 or l_return_ccid = -1 ))  OR
       (NOT l_result) THEN ** Commenting this out for bug 2802847 */

/* Added the check for l_error_message for bug 2694601 */
	IF l_error_message is null THEN
        fnd_message.set_name('PA','PA_WF_SETUP_ERROR');
        x_error_message := fnd_message.get_encoded;
	ELSE
	x_error_message := l_error_message;
	END IF;
/* 2694601*/

/*     return(FALSE);
    END IF; ** bug 2802947 */

	 ------------------------------------------------------------------
	 -- Copy the return values to the corresponding output parameters
	 ------------------------------------------------------------------
    g_error_stage := '400';

/* Bug 5935019 - Changes start -- commented 3 lines
	 x_concat_segs 	:= l_concat_segs;
	 x_concat_ids 	:= l_concat_ids;
	 x_concat_descrs:= l_concat_descrs;
   Bug 5935019 - Changes end   */
--	 x_error_message:= l_error_message; bug 2802847
	 x_return_ccid	:= l_return_ccid;

        --------------------------------------------------------------------
        --  Reset the error stack because there were no errors
        --------------------------------------------------------------------

        reset_error_stack;

	--------------------------------------------------------------------
	-- Return the return value of the Generate function as the return
	-- value for the process
	--------------------------------------------------------------------

  	RETURN l_result;

     EXCEPTION

     WHEN OTHERS
       THEN

  -----------------------------------------------------------------------
  -- Record error using generic error message routine for debugging and
  -- raise it
  -----------------------------------------------------------------------

/* Bug 5233487 - Start */
        IF g_encoded_error_message IS NULL THEN
            g_encoded_error_message := show_error(g_error_stack,g_error_stage,NULL);
        END IF;
	x_error_message := g_encoded_error_message;
        reset_error_stack;
/* Bug 5233487 - End */


        wf_core.context( pkg_name	=> 'pa_acc_gen_wf_pkg',
			 proc_name	=> 'ap_inv_generate_account',
			 arg1		=>  'Project id: '||p_project_id,
			 arg2		=>  'Task id: '||p_task_id,
			 arg3		=>  'Vendor id: '||p_vendor_id,
			 arg4		=>  'Exp type: '||p_expenditure_type,
			 arg5		=>  'Exp Org id: '||p_expenditure_organization_id);

        RETURN FALSE;

  END ap_inv_generate_account;
----------------------------------------------------------------------
-- Start of procedure upgrade_flexbuilder_account.  Procedure level
-- comments with specifications
----------------------------------------------------------------------

  PROCEDURE ap_inv_upgrade_flex_account (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2)
  AS

	l_project_id			  pa_projects_all.project_id%TYPE;
	l_task_id			  pa_tasks.task_id%TYPE;
	l_expenditure_type		  pa_expenditure_types.expenditure_type%TYPE;
	l_vendor_id 			  po_vendors.vendor_id%type;
	l_expenditure_organization_id	  hr_organization_units.organization_id%TYPE;
	l_expenditure_item_date  pa_expenditure_items_all.expenditure_item_date%TYPE;
	l_billable_flag			  pa_tasks.billable_flag%TYPE;
	l_chart_of_accounts_id		  NUMBER;
	l_fb_error_msg		  	  VARCHAR2(2000);
	l_fb_flex_seg			  VARCHAR2(500);
	l_build_account_result		  BOOLEAN;
        l_award_set_id                    NUMBER; /* Added to fix bug 1612877 */

  BEGIN

-----------------------------------------------------------------------
-- Check the Workflow mode in which this function has been called. If
-- it is not in the RUN mode, then exit out of this function
-----------------------------------------------------------------------

 IF p_funcmode <> 'RUN'
 THEN
   x_result := null;
   return;
 END IF;

--------------------------------------------------------------
-- Get the values of the attributes that were defined as raw
-- parameters in Flexbuilder
--------------------------------------------------------------

  l_project_id		:= wf_engine.GetItemAttrNumber	( itemtype => p_itemtype,
				  			  itemkey  => p_itemkey,
				  			  aname	   => 'PROJECT_ID');

  l_task_id		:= wf_engine.GetItemAttrNumber	( itemtype => p_itemtype,
				  			  itemkey  => p_itemkey,
				  			  aname	   => 'TASK_ID');

  l_expenditure_type	:= wf_engine.GetItemAttrText	( itemtype => p_itemtype,
				  			  itemkey  => p_itemkey,
				  			  aname	   => 'EXPENDITURE_TYPE');

  l_expenditure_item_date:= wf_engine.GetItemAttrDate	( itemtype => p_itemtype,
				  			  itemkey  => p_itemkey,
				  			  aname	   => 'EXPENDITURE_ITEM_DATE');

  l_expenditure_organization_id	:=
		wf_engine.GetItemAttrNumber	( itemtype => p_itemtype,
						  itemkey  => p_itemkey,
						  aname	   => 'EXPENDITURE_ORGANIZATION_ID');


  /* l_vendor_id populated for bug 2037544 */

  l_vendor_id :=   wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => 'VENDOR_ID');

  l_billable_flag	:= wf_engine.GetItemAttrText	( itemtype => p_itemtype,
				  			  itemkey  => p_itemkey,
				  			  aname	   => 'BILLABLE_FLAG');

  l_chart_of_accounts_id:=
		wf_engine.GetItemAttrNumber	( itemtype => p_itemtype,
			  			  itemkey  => p_itemkey,
			  			  aname	   => 'CHART_OF_ACCOUNTS_ID');

  /*  Added to fix bug 1612877 */
  l_award_set_id:=
                wf_engine.GetItemAttrNumber     ( itemtype => p_itemtype,
                                                  itemkey  => p_itemkey,
                                                  aname    => 'AWARD_SET_ID');


-----------------------------------------------------------------------
-- Call the build function to derive the account based on Flexbuilder
-- rules
-----------------------------------------------------------------------
/* Added the call for award_set_id in this function to fix bug 1612877 */

  l_build_account_result :=   pa_vend_inv_charge_account.build (
	fb_flex_num			=> l_chart_of_accounts_id,
	expenditure_organization_id	=> l_expenditure_organization_id,
	expenditure_type		=> l_expenditure_type,
	pa_billable_flag		=> l_billable_flag,
	project_id			=> l_project_id,
	task_id				=> l_task_id,
	vendor_id			=> l_vendor_id,
	fb_flex_seg			=> l_fb_flex_seg,
	fb_error_msg			=> l_fb_error_msg) ;

  	/*  Removed to fix bug 1612877 */
        -- award_set_id                    => l_award_set_id );
	-- =====================================================

--------------------------------------------------------------------
-- Call the FND procedure to load the values into the concatenated
-- segments
--------------------------------------------------------------------

  fnd_flex_workflow.load_concatenated_segments ( p_itemtype,
						 p_itemkey,
						 l_fb_flex_seg );

 -------------------------------------------------------------------------
 -- Check the result of the Build function and return success or failure
 -- accordingly
 -------------------------------------------------------------------------

  IF l_build_account_result
  THEN
	x_result := 'COMPLETE:SUCCESS';
	RETURN;
  ELSE
    ---------------------------
    -- Set error message here
    ---------------------------
	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'ERROR_MESSAGE',
				   avalue	=> l_fb_error_msg);

	x_result := 'COMPLETE:FAILURE';
	RETURN;
  END IF;

  EXCEPTION

  WHEN OTHERS
    THEN

-----------------------------------------------------------------------
-- Record error using generic error message routine for debugging and
-- raise it
-----------------------------------------------------------------------

        wf_core.context( pkg_name	=> 'pa_acc_gen_wf_pkg',
			 proc_name	=> 'ap_inv_upgrade_flex_account',
			 arg1		=>  'Project Id: ' ||l_project_id,
			 arg2		=>  'Task Id: ' ||l_task_id,
			 arg3		=>  'Vendor Id: ' ||l_vendor_id,
			 arg4		=>  'Exp type: ' ||l_expenditure_type,
			 arg5		=>  'Exp Org Id: ' ||l_expenditure_organization_id);

        raise;


 END ap_inv_upgrade_flex_account;

----------------------------------------------------------------------
-- Start of procedure ap_inv_acc_undefined_rules.  Function level
-- comments with specifications
----------------------------------------------------------------------

 PROCEDURE ap_inv_acc_undefined_rules (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2)
 IS
 l_fb_error_msg		VARCHAR2(400);
 BEGIN

-----------------------------------------------------------------------
-- Check the Workflow mode in which this function has been called. If
-- it is not in the RUN mode, then exit out of this function
-----------------------------------------------------------------------

 IF p_funcmode <> 'RUN'
 THEN
   x_result := null;
   return;
 END IF;

-----------------------------------------
-- Set the appropriate message and exit
-----------------------------------------

	fnd_message.set_name('PA','FLEXWF-DEFAULT MISSING');
	l_fb_error_msg	:= fnd_message.get_encoded;
	wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'ERROR_MESSAGE',
				   avalue	=> l_fb_error_msg);

	x_result := 'COMPLETE:FAILURE';
	RETURN;

     EXCEPTION

     WHEN OTHERS
       THEN

-----------------------------------------------------------------------
-- Record error using generic error message routine for debugging and
-- raise it
-----------------------------------------------------------------------

        wf_core.context( pkg_name	=> 'pa_acc_gen_wf_pkg ',
			 proc_name	=> 'ap_inv_acc_undefined_rules',
			 arg1		=>  'Error: Default workflow not defined',
			 arg2		=>  null,
			 arg3		=>  null,
			 arg4		=>  null,
			 arg5		=>  null);

        raise;
 END ap_inv_acc_undefined_rules;

----------------------------------------------------------------------

----------------------------------------------------------------------
-- Start of procedure pa_seg_lookup_set_value.  Procedure level
-- comments with specifications
----------------------------------------------------------------------

PROCEDURE pa_seg_lookup_set_value (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2)
 AS

 l_seg_value_lookup_set_name
	pa_segment_value_lookup_sets.segment_value_lookup_set_name%TYPE;

 l_intermediate_value
	pa_segment_value_lookups.segment_value_lookup%TYPE;

 l_segment_value pa_segment_value_lookups.segment_value%TYPE;

 no_lookup_type		EXCEPTION;
 no_lookup_code		EXCEPTION;
 l_error_message        VARCHAR2(2000);

 BEGIN

-----------------------------------------------------------------------
-- Check the Workflow mode in which this function has been called. If
-- it is not in the RUN mode, then exit out of this function
-----------------------------------------------------------------------

 set_error_stack('-->pa_seg_lookup_set_value'); /* Bug 5233487 */
 g_error_stage := '10';

 IF p_funcmode <> 'RUN'
 THEN
   x_result := null;
   return;
 END IF;

---------------------------------------------------
-- Retrieve the current value for the lookup type
---------------------------------------------------
 g_error_stage := '20';

 l_seg_value_lookup_set_name :=
	wf_engine.GetActivityAttrText
			(	itemtype	=> p_itemtype,
				itemkey		=> p_itemkey,
				actid		=> p_actid,
				aname		=> 'LOOKUP_TYPE' );

------------------------------------------------------------------------
-- Raise the appropriate exception if the lookup type has not been set
------------------------------------------------------------------------

 IF l_seg_value_lookup_set_name IS NULL
 THEN
   RAISE no_lookup_type;
 END IF;

---------------------------------------------------
-- Retrieve the current value for the lookup code
---------------------------------------------------
 g_error_stage := '30';

 l_intermediate_value :=
	wf_engine.GetActivityAttrText
			(	itemtype	=> p_itemtype,
				itemkey		=> p_itemkey,
				actid		=> p_actid,
				aname		=> 'LOOKUP_CODE' );

------------------------------------------------------------------------
-- Raise the appropriate exception if the lookup code has not been set
------------------------------------------------------------------------

 IF l_intermediate_value IS NULL
 THEN
   RAISE no_lookup_code;
 END IF;


-------------------------------------------
-- Select the lookup value from the table
-------------------------------------------
 g_error_stage := '40';

 SELECT  segment_value
   INTO  l_segment_value
   FROM  pa_segment_value_lookups 	valuex,
	 pa_segment_value_lookup_sets 	sets
  WHERE  sets.segment_value_lookup_set_id   =
		valuex.segment_value_lookup_set_id
    AND  sets.segment_value_lookup_set_name = l_seg_value_lookup_set_name
    AND  valuex.segment_value_lookup 	    = l_intermediate_value;


-----------------------------------------------------------------------
-- If the retrieval was successful, then set the appropriate item
-- attribute to the value retrieved. Otherwise, raise the appropriate
-- error message
-----------------------------------------------------------------------
  g_error_stage := '50';

  wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
			     itemkey 	=> p_itemkey,
			     aname	=> 'LOOKUP_SET_VALUE',
			     avalue	=> l_segment_value);


 x_result := 'COMPLETE:SUCCESS';

-- If you are here then there were no errors. Reset the error stack.

 reset_error_stack;

 EXCEPTION

------------------------------------------------------------------
-- User defined exception raised when lookup type is not defined
------------------------------------------------------------------

   WHEN no_lookup_type
   THEN
        reset_error_stack; /* Bug 5233487 */
	-- Record standard workflow debugging message
        wf_core.context( pkg_name	=> 'PA_ACC_GEN_WF_PKG ',
			 proc_name	=> 'PA_SEG_LOOKUP_SET_VALUE',
			 arg1		=>  'Lookup Set:' || l_seg_value_lookup_set_name,
			 arg2		=>  'Intermediate Value: ' || l_intermediate_value,
			 arg3		=>  'Lookup type null',
			 arg4		=>  null,
			 arg5		=>  null);


	-- Error requires an error message to be set so that it can be
	-- displayed on the form.


      fnd_message.set_name('PA','WF_ACC_LOOKUP_TYPE_FAIL');
        l_error_message  := fnd_message.get_encoded;
        wf_engine.SetItemAttrText( itemtype     => p_itemtype,
                                   itemkey      => p_itemkey,
                                   aname        => 'ERROR_MESSAGE',
                                   avalue       => l_error_message);


    -- Return a failure so that the abort generation End function is called

	x_result := 'COMPLETE:FAILURE';
	RETURN;

------------------------------------------------------------------
-- User defined exception raised when lookup code is not defined
------------------------------------------------------------------

   WHEN no_lookup_code
   THEN
        reset_error_stack; /* Bug 5233487 */
	-- Record standard workflow debugging message
        wf_core.context( pkg_name	=> 'PA_ACC_GEN_WF_PKG ',
			 proc_name	=> 'PA_SEG_LOOKUP_SET_VALUE',
			 arg1		=>  'Lookup Set:' || l_seg_value_lookup_set_name,
			 arg2		=>  'Intermediate Value: ' || l_intermediate_value,
			 arg3		=>  'Lookup code null',
			 arg4		=>  null,
			 arg5		=>  null);


	-- Error requires an error message to be set so that it can be
	-- displayed on the form. The error message name is defined in
	-- Applications.

      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey => p_itemkey,
		  aname	  => 'ERROR_MESSAGE',
		  avalue  => 'WF_ACC_LOOKUP_CODE_FAIL');

      fnd_message.set_name('PA','WF_ACC_LOOKUP_CODE_FAIL');
      l_error_message  := fnd_message.get_encoded;
      wf_engine.SetItemAttrText( itemtype     => p_itemtype,
                                   itemkey      => p_itemkey,
                                   aname        => 'ERROR_MESSAGE',
                                   avalue       => l_error_message);


    -- Return a failure so that the abort generation End function is called

	x_result := 'COMPLETE:FAILURE';
	RETURN;

------------------------------------------------------------------------
-- If data is not found after the SELECT, it indicates that the
-- combination of the lookup type and lookup code has not been defined
------------------------------------------------------------------------

   WHEN no_data_found
   THEN
        reset_error_stack; /* Bug 5233487 */
	-- Record standard workflow debugging message
        wf_core.context( pkg_name	=> 'PA_ACC_GEN_WF_PKG ',
			 proc_name	=> 'PA_SEG_LOOKUP_SET_VALUE',
			 arg1		=>  'Lookup Set:' || l_seg_value_lookup_set_name,
			 arg2		=>  'Intermediate Value: ' || l_intermediate_value,
			 arg3		=>  'Lookup code null',
			 arg4		=>  null,
			 arg5		=>  null);


	-- Error requires an error message to be set so that it can be
	-- displayed on the form.

      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey => p_itemkey,
		  aname	  => 'ERROR_MESSAGE',
		  avalue  => 'WF_ACC_LOOKUP_NODATA_FAIL');

      fnd_message.set_name('PA','WF_ACC_LOOKUP_NODATA_FAIL');
      l_error_message  := fnd_message.get_encoded;
      wf_engine.SetItemAttrText( itemtype     => p_itemtype,
                                   itemkey      => p_itemkey,
                                   aname        => 'ERROR_MESSAGE',
                                   avalue       => l_error_message);


    -- Return a failure so that the abort generation End function is called

	x_result := 'COMPLETE:FAILURE';
	RETURN;

-----------------------------------------------------------
-- All other exceptions are raised to the calling program
-----------------------------------------------------------

   WHEN others
   THEN
        g_error_message := SQLERRM;
--
-- Call the show error function, this function should be used for handling
-- fatal errors.  It accepts 5 arguments, we have used this function to
-- pin point the exact error section. Customers can user p_arg1, p_arg2 for
-- more specific debugging, we have used these 2 arguments to identify the
-- record in error( i.e. lookup_set_name and intermediate_value).
--

	l_error_message := pa_acc_gen_wf_pkg.show_error(p_error_stack => g_error_stack,
		p_error_stage => g_error_stage,
		p_error_message => g_error_message,
		p_arg1 => 'Lookup Set:'||l_seg_value_lookup_set_name,
		p_arg2 => 'Intermediate Value: ' || l_intermediate_value);
        reset_error_stack; /* Bug 5233487 */

-- populate the error message wf attribute and return failure.

	wf_engine.SetItemAttrText
                ( itemtype=> p_itemtype,
                  itemkey => p_itemkey,
                  aname   => 'ERROR_MESSAGE',
                  avalue  => l_error_message);

    -- Return a failure so that the abort generation End function is called

        x_result := 'COMPLETE:FAILURE';

	-- Record standard workflow debugging message
        wf_core.context( pkg_name	=> 'PA_ACC_GEN_WF_PKG ',
			 proc_name	=> 'PA_SEG_LOOKUP_SET_VALUE',
			 arg1		=>  'Lookup Set:' || l_seg_value_lookup_set_name,
			 arg2		=>  'Intermediate Value: ' || l_intermediate_value,
			 arg3		=>  null,
			 arg4		=>  null,
			 arg5		=>  null);

        RETURN;

 END pa_seg_lookup_set_value;

----------------------------------------------------------------------
-- Start of procedure pa_aa_function_transaction.  Procedure level
-- comments with specifications
----------------------------------------------------------------------
/*
PROCEDURE pa_aa_function_transaction (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT VARCHAR2)
 AS

 CURSOR c_ft_code(p_ft_code IN VARCHAR2,
		p_ptype_ft_code IN VARCHAR2)
 IS
    Select function_transaction_code ft_code,
           decode(function_transaction_code,'ALL',10,'CON',9,'CAP',8,'IND',7,5) ft_order
    from   pa_function_transactions
    where  function_transaction_code in
        ('ALL',p_ft_code,p_ptype_ft_code)
    and    application_id = 275
    and    function_code = 'BER'
    and    enabled_flag = 'Y'
    order by 2;

 ft_rec  c_ft_code%ROWTYPE;

 l_project_id
        pa_projects_all.project_id%TYPE;

 l_ptype_class_code
	pa_project_types_all.project_type_class_code%TYPE;

 l_public_sector_flag
	pa_projects_all.public_sector_flag%TYPE;

 l_billable_flag pa_tasks.billable_flag%TYPE;

 l_ft_code pa_function_transactions_all.function_transaction_code%TYPE;

 l_ptype_ft_code pa_function_transactions_all.function_transaction_code%TYPE;


 l_old_error_stack VARCHAR2(500);

 l_error_message        VARCHAR2(2000);

 BEGIN

-----------------------------------------------------------------------
-- Check the Workflow mode in which this function has been called. If
-- it is not in the RUN mode, then exit out of this function
-----------------------------------------------------------------------

 l_old_error_stack := g_error_stack;
 g_error_stack := g_error_stack||'-->'||'pa_aa_function_transaction';
 g_error_stage := '10';

 IF p_funcmode <> 'RUN'
 THEN
   x_result := null;
   return;
 END IF;

---------------------------------------------------
-- Retrieve the current value for the lookup type
---------------------------------------------------
 g_error_stage := '20';

 l_project_id :=
        wf_engine.GetItemAttrNumber
                        (       itemtype        => p_itemtype,
                                itemkey         => p_itemkey,
                                aname           => 'PROJECT_ID' );

 select a.project_type_class_code
 into l_ptype_class_code
 from pa_project_types_all a,
      pa_projects_all b
 where a.project_type = b.project_type
 and   nvl(a.org_id,-99) = nvl(b.org_id, -99)
 and   b.project_id = l_project_id;

----------------------------------------------------------
-- Retrieve the current value for the public sector flag
----------------------------------------------------------
 g_error_stage := '30';

 l_public_sector_flag :=
        wf_engine.GetItemAttrText
                        (       itemtype        => p_itemtype,
                                itemkey         => p_itemkey,
                                aname           => 'PUBLIC_SECTOR_FLAG' );

--------------------------------------------------------------
-- Retrieve the current value for billable flag
--------------------------------------------------------------
 g_error_stage := '40';

 l_billable_flag :=
        wf_engine.GetItemAttrText
                        (       itemtype        => p_itemtype,
                                itemkey         => p_itemkey,
                                aname           => 'BILLABLE_FLAG' );

---------------------------------------------------------
-- derive the AutoAccounting function transaction code
-- from project_type_class_code, public_sector_flag and
-- billable_flag
---------------------------------------------------------

  g_error_stage := '50';

  IF ( l_ptype_class_code = 'CONTRACT' ) THEN

     l_ptype_ft_code := 'CON';

        IF ( l_public_sector_flag = 'Y' ) THEN

           IF ( l_billable_flag = 'Y' ) THEN

 	      l_ft_code := 'PUB-BILL';
	   ELSE

	      l_ft_code := 'PUB-NOBIL';
	   END IF;
        ELSE

	   IF ( l_billable_flag = 'Y' ) THEN

	      l_ft_code := 'PRV-BILL';
	   ELSE

	      l_ft_code := 'PRV-NOBIL';
	   END IF;
	END IF;

     ELSIF ( l_ptype_class_code = 'CAPITAL' ) THEN

     l_ptype_ft_code := 'CAP';

        IF ( l_public_sector_flag = 'Y' ) THEN

           IF ( l_billable_flag = 'Y' ) THEN

              l_ft_code := 'PUB-CAP';
           ELSE

              l_ft_code := 'PUB-NOCAP';
           END IF;
        ELSE

           IF ( l_billable_flag = 'Y' ) THEN

              l_ft_code := 'PRV-CAP';
           ELSE

              l_ft_code := 'PRV-NOCAP';
           END IF;
        END IF;

     ELSIF ( l_ptype_class_code = 'INDIRECT' ) THEN

     l_ptype_ft_code := 'IND';

        IF ( l_public_sector_flag = 'Y' ) THEN

              l_ft_code := 'IND-PUB';
           ELSE

              l_ft_code := 'IND-PRV';
        END IF;

     END IF;

----------------------------------------------------------------
-- Now we have all the function transaction codes
-- lookup the pa_function_transactions_all table and
-- get the code that applies to this transaction
----------------------------------------------------------------
   g_error_stage := '60';

   OPEN c_ft_code(l_ft_code,
		  l_ptype_ft_code);

   g_error_stage := '70';

   FETCH c_ft_code INTO ft_rec;

   CLOSE c_ft_code;

  g_error_stage := '80';

  wf_engine.SetItemAttrText( itemtype	=> p_itemtype,
			     itemkey 	=> p_itemkey,
			     aname	=> 'TRANSACTION_CODE',
			     avalue	=> ft_rec.ft_code);


 x_result := 'COMPLETE:SUCCESS';

-- If you are here then there were no errors. Reset the error stack.

 g_error_stack := l_old_error_stack;

 EXCEPTION

-----------------------------------------------------------
-- All other exceptions are raised to the calling program
-----------------------------------------------------------

   WHEN others
   THEN
        g_error_message := SQLERRM;
--
-- Call the show error function, this function should be used for handling
-- fatal errors.  It accepts 5 arguments, we have used this function to
-- pin point the exact error location. Customers can user p_arg1, p_arg2 for
-- more specific debugging, we have used these 2 arguments to identify the
-- record in error( i.e. l_function_transaction_c and l_ptype_class_code).
--

	l_error_message := pa_acc_gen_wf_pkg.show_error(p_error_stack => g_error_stack,
		p_error_stage => g_error_stage,
		p_error_message => g_error_message,
		p_arg1 => 'Function Transaction code:'||l_ft_code,
		p_arg2 => 'Project Type Class Code: ' || l_ptype_class_code);

-- populate the error message wf attribute and return failure.

	wf_engine.SetItemAttrText
                ( itemtype=> p_itemtype,
                  itemkey => p_itemkey,
                  aname   => 'ERROR_MESSAGE',
                  avalue  => l_error_message);

    -- Return a failure so that the abort generation End function is called

        x_result := 'COMPLETE:FAILURE';

	-- Record standard workflow debugging message
        wf_core.context( pkg_name	=> 'PA_ACC_GEN_WF_PKG ',
			 proc_name	=> 'PA_AA_FUNCTION_TRANSACTION',
			 arg1		=>  'Function Transaction Code' || l_ft_code,
			 arg2		=>  'Project Type Class Code: ' || l_ptype_class_code,
			 arg3		=>  null,
			 arg4		=>  null,
			 arg5		=>  null);

        RETURN;

 END pa_aa_function_transaction;

*/
----------------------------------------------------------------------
-- Start of function show_error.  Procedure level
-- comments with specifications
----------------------------------------------------------------------
FUNCTION show_error(p_error_stack IN VARCHAR2,
		p_error_stage     IN VARCHAR2,
		p_error_message   IN VARCHAR2,
		p_arg1		  IN VARCHAR2 DEFAULT null,
		p_arg2		  IN VARCHAR2 DEFAULT null) RETURN VARCHAR2
IS

l_result FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
   g_error_message := nvl(p_error_message,SUBSTRB(SQLERRM,1,1000));

   fnd_message.set_name('PA','PA_WF_FATAL_ERROR');
   fnd_message.set_token('ERROR_STACK',p_error_stack);
   fnd_message.set_token('ERROR_STAGE',p_error_stage);
   fnd_message.set_token('ERROR_MESSAGE',g_error_message);
   fnd_message.set_token('ERROR_ARG1',p_arg1);
   fnd_message.set_token('ERROR_ARG2',p_arg2);

   l_result  := fnd_message.get_encoded;

   g_error_message := NULL;

   RETURN l_result;
EXCEPTION WHEN OTHERS
THEN
   raise;
END show_error;

/* Bug 5233487 - Start */
PROCEDURE set_error_stack(p_error_stack_msg IN VARCHAR2) IS
BEGIN
    IF g_error_stack_history.COUNT = 0 THEN
        g_error_stack_history(0) := g_error_stack;
    ELSE
        g_error_stack_history(g_error_stack_history.LAST + 1) := g_error_stack;
    END IF;
    g_error_stack := SUBSTR(g_error_stack || p_error_stack_msg, 0, 500);
END set_error_stack;

PROCEDURE reset_error_stack IS
BEGIN
    IF g_error_stack_history.COUNT > 0 THEN
        g_error_stack := g_error_stack_history(g_error_stack_history.LAST);
        g_error_stack_history.DELETE(g_error_stack_history.LAST);
    END IF;
END reset_error_stack;
/* Bug 5233487 - End */

END pa_acc_gen_wf_pkg ;

/
