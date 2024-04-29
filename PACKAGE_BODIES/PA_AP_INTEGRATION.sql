--------------------------------------------------------
--  DDL for Package Body PA_AP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AP_INTEGRATION" AS
--$Header: PAAPINTB.pls 120.9.12010000.6 2009/12/23 11:29:22 rrambati ship $

PROCEDURE UPD_PA_DETAILS_SUPPLIER_MERGE
                           ( p_old_vendor_id   IN po_vendors.vendor_id%type,
                             p_new_vendor_id   IN po_vendors.vendor_id%type,
                             p_paid_inv_flag   IN ap_invoices_all.PAYMENT_STATUS_FLAG%type,
                             p_invoice_id      IN ap_invoices_all.invoice_id%TYPE DEFAULT NULL,  /* Bug# 8845025 */
                             x_stage          OUT NOCOPY VARCHAR2,
                             x_status         OUT NOCOPY VARCHAR2)

IS
 /* bug 8845025 start */
  TYPE eiid_tbl IS TABLE OF PA_EXPENDITURE_ITEMS_ALL.expenditure_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE lnum_tbl IS TABLE OF PA_COST_DISTRIBUTION_LINES_ALL.line_num%TYPE INDEX BY BINARY_INTEGER;

  eiid_rec eiid_tbl;
  lnum_rec lnum_tbl;

  type expid_tbl IS TABLE OF PA_EXPENDITURES_ALL.expenditure_id%TYPE INDEX BY BINARY_INTEGER;
  expid_rec expid_tbl;
  /* bug 8845025 end */
Begin
x_stage := 'Updating Pa_implementations Table';
Update pa_implementations_all set  Vendor_Id = p_new_vendor_id
Where  Vendor_Id = p_old_vendor_id;

x_stage := 'Updating Pa_Expenditures_All Table';
   /* Added for bug# 8845025 */
   UPDATE pa_expenditures_all e
   SET   e.vendor_id = p_new_vendor_id
   WHERE e.vendor_id = p_old_vendor_id  and
         orig_exp_txn_reference1 = p_invoice_id and
         exists (
          select 1 from ap_invoices_all i
          where invoice_id = p_invoice_id
          and to_char(invoice_id) = orig_exp_txn_reference1
          and vendor_id = p_new_vendor_id
          and payment_status_flag = DECODE (NVL (p_paid_inv_flag, 'Y'), 'N', 'N',  i.payment_status_flag)
                 )
      returning expenditure_id BULK COLLECT INTO expid_rec;

/*Code change for 	7125912 */
/* commenting for bug 8845025
UPDATE pa_expenditures_all e
   SET e.vendor_id = p_new_vendor_id
 WHERE e.vendor_id = p_old_vendor_id
   AND e.expenditure_id in (
          SELECT ---- /*+ LEADING(ei)
             ei.expenditure_id
            FROM pa_cost_distribution_lines_all c,
                 pa_expenditure_items_all ei,
                 ap_invoices_all i
           WHERE TO_CHAR (i.invoice_id) = c.system_reference2
             AND c.expenditure_item_id = ei.expenditure_item_id
            -- AND ei.expenditure_id = e.expenditure_id
             AND c.system_reference1 = TO_CHAR(p_old_vendor_id)
             AND i.vendor_id = p_new_vendor_id
             AND i.payment_status_flag = DECODE (NVL (p_paid_inv_flag, 'Y'), 'N', 'N', i.payment_status_flag)
                )  ;  */
/*Code change for 	7125912  END */
x_stage := 'Updating Pa_Expenditure_Items_All Table';

/*Changed for Bug:5864959*/
Update pa_expenditure_items_all ei set vendor_id =  p_new_vendor_id
Where  Vendor_Id = p_old_vendor_id
  and exists
       (select 1
        from  pa_cost_distribution_lines_all c,
              ap_invoices_all i
        where i.invoice_id = to_number(c.system_reference2)
        and   c.expenditure_item_id = ei.expenditure_item_id
        and   c.system_reference1 = p_old_vendor_id
        and   i.vendor_id = p_new_vendor_id
        and   i.PAYMENT_STATUS_FLAG =
decode(nvl(p_paid_inv_flag,'Y'),'N','N',i.PAYMENT_STATUS_FLAG)
        );

x_stage := 'Updating Pa_Cost_Distribution_Lines_All Table';
/* Added for bug# 8845025 */

  FORALL I IN 1 .. expid_rec.count
   UPDATE  PA_COST_DISTRIBUTION_LINES_ALL
   SET     System_reference1 = to_char(p_new_vendor_id)
   WHERE   expenditure_item_id IN (
             SELECT expenditure_item_id
             FROM PA_EXPENDITURE_ITEMS_ALL ei
             WHERE ei.expenditure_id = expid_rec(i)
             );

/* Commented for bug# 88845025
If nvl(p_paid_inv_flag,'Y') = 'N' Then

--Code change for 	7125912
 Declare Cursor c1 is
      Select c.rowid row_id, c.expenditure_item_id, c.line_num
      from pa_cost_distribution_lines_all c, ap_invoices_all i
      where to_char(i.invoice_id) = c.system_reference2
      --and i.vendor_id = to_number(c.system_reference1) --Vendor_ID on Invoice is already  changed...so this is not needed
      and c.system_reference1 = to_char(p_old_vendor_id)
      and i.vendor_id = p_new_vendor_id
      and i.PAYMENT_STATUS_FLAG = 'N';

--Code change for 	7125912 END
  Begin

  x_stage := 'Updating Pa_Cost_Distribution_Lines_All Table For UNPAID Invoices';

  For Rec in C1 Loop

	Update pa_cost_distribution_lines_all
	Set    System_reference1 = (p_new_vendor_id)
	Where  rowid = rec.row_id;

  End Loop;
  End;

Else  -- p_paid_inv_flag <> 'N'

  x_stage := 'Updating Pa_Cost_Distribution_Lines_All Table For ALL Invoices';

  Update Pa_Cost_Distribution_Lines_All cdl
  Set    System_Reference1 = to_char(p_new_vendor_id)
  Where  System_Reference1 = to_char(p_old_vendor_id)
  And    system_reference1 is not null
  And    system_reference2 is not null
  And    system_reference3 is not null
  and exists (select 1  -- added this for bug8562065
                   from ap_invoices_all inv
                  where to_char(inv.invoice_id) = cdl.system_reference2
                    and inv.vendor_id = p_new_vendor_id
              );


End If;  for bug 8845025*/

--R12 need to update vendor ID on pa_bc_packets
x_stage := 'Updating Pa_Bc_Packets Table';
Update pa_bc_packets
set  Vendor_Id = p_new_vendor_id
Where  Vendor_Id = p_old_vendor_id
And  Status_Code = 'A';

--R12 need to update vendor ID on pa_bc_commitments
x_stage := 'Updating Pa_Bc_Commitments_All Table';
Update pa_bc_commitments_all
set  Vendor_Id = p_new_vendor_id
Where  Vendor_Id = p_old_vendor_id;

  x_stage := 'Updating Pa_Project_Asset_Lines_All Table For ALL Invoices';

update pa_project_asset_lines_all set po_vendor_id = p_new_vendor_id
where  po_vendor_id = p_old_vendor_id
and    po_vendor_id is not null;

/* Added for bug 2649043  */

  x_stage := 'Updating PA_CI_SUPPLIER_DETAILS Table For ALL Invoices';

update PA_CI_SUPPLIER_DETAILS set vendor_id = p_new_vendor_id
where  vendor_id = p_old_vendor_id
and    vendor_id is not null;

/* Summarization Changes */

-- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------
-- Augmented original code with additional filter

/* -- Original Code
Declare
Cursor c_resource_list is
Select distinct resource_list_id from pa_resource_list_members
where vendor_id = p_old_vendor_id and enabled_flag = 'Y';
*/

-- FP.M Data Model Logic

Declare
Cursor c_resource_list is
Select distinct resource_list_id from pa_resource_list_members
where vendor_id = p_old_vendor_id
and enabled_flag = 'Y'
 and nvl(migration_code,'M')= 'M';

-- End: FP.M Resource LIst Data Model Impact Changes -----------------------------



/*****
l_new_vendor_exists_member varchar2(1) := 'N';
l_new_vendor_exists_resource varchar2(1) := 'N';
*******Bug# 4029384*/

l_new_vendor_exists_member number := 0;      /*Bug# 4029384*/
l_new_vendor_exists_resource number := 0;   /*Bug#  4029384*/

l_new_vendor_name po_vendors.vendor_name%type;

l_expenditure_category pa_resource_list_members.expenditure_category%type;
l_parent_member_id pa_resource_list_members.resource_list_member_id%type;
l_resource_list_member_id pa_resource_list_members.resource_list_member_id%type;
l_track_as_labor_flag varchar2(10);
l_err_code Varchar2(200);
l_err_stage Varchar2(200);
l_err_stack Varchar2(2000);
l_resource_id pa_resources.resource_id%type;

Begin
x_stage := 'Start For Summarization';
for rec1 in c_resource_list loop

   x_stage := 'New Vendor Name';
   Select vendor_name into l_new_vendor_name from po_vendors where vendor_id = p_new_vendor_id;

   Begin
   x_stage:='See whether New vendor exists as resource in PA tables';

   Select nvl(count(a.name),0) into l_new_vendor_exists_resource from pa_resource_types b, pa_resources a
   where  a.RESOURCE_TYPE_ID=b.RESOURCE_TYPE_ID and b.RESOURCE_TYPE_CODE='VENDOR'
   And    a.name = l_new_vendor_name;

   Exception When no_data_found then l_new_vendor_exists_resource := 0;

   End;

   If  l_new_vendor_exists_resource = 0 Then -- Insert New vendor as a resource

   x_stage := 'New Vendor Does Not Exists ... Creating New vendor as resource';

				PA_CREATE_RESOURCE.Create_Resource
				(p_resource_name             =>  l_new_vendor_name,
                                 p_resource_type_Code        =>  'VENDOR',
                                 p_description               =>  l_new_vendor_name,
                                 p_unit_of_measure           =>  NULL,
                                 p_rollup_quantity_flag      =>  NULL,
                                 p_track_as_labor_flag       =>  NULL,
                                 p_start_date                =>  to_date('01/01/1950','DD/MM/YYYY'),
                                 p_end_date                  =>  NULL,
                                 p_person_id                 =>  NULL,
                                 p_job_id                    =>  NULL,
                                 p_proj_organization_id      =>  NULL,
                                 p_vendor_id                 =>  p_new_vendor_id,
                                 p_expenditure_type          =>  NULL,
                                 p_event_type                =>  NULL,
                                 p_expenditure_category      =>  NULL,
                                 p_revenue_category_code     =>  NULL,
                                 p_non_labor_resource        =>  NULL,
                                 p_system_linkage            =>  NULL,
                                 p_project_role_id           =>  NULL,
                                 p_resource_id               =>  l_resource_id,
                                 p_err_code                  =>  l_err_code,
                                 p_err_stage                 =>  x_stage,
                                 p_err_stack                 =>  l_err_stack);
   End If;


       -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------
       -- Augmented original code with additional filter for migration_code


	Begin

/* --Origianal Code

		Select nvl(count(*),0) into l_new_vendor_exists_member from pa_resource_list_members
		where 	resource_list_id = rec1.resource_list_id and VENDOR_ID = p_new_vendor_id;
*/


  -- FP.M Data Model

                Select nvl(count(*),0)
                into l_new_vendor_exists_member
                from pa_resource_list_members
		where 	resource_list_id = rec1.resource_list_id
                and VENDOR_ID = p_new_vendor_id
                    and nvl(migration_code,'M') = 'M';


		exception when no_data_found then l_new_vendor_exists_member := 0;

	End;


/* --Origianal Code

		update pa_resource_list_members set enabled_flag = 'N'
		where  resource_list_id = rec1.resource_list_id
		and    vendor_id = p_old_vendor_id;
*/



  -- FP.M Data Model

                update pa_resource_list_members set
                enabled_flag = 'N'
		where  resource_list_id = rec1.resource_list_id
		and    vendor_id = p_old_vendor_id
                    and nvl(migration_code,'M') = 'M';

       -- End: FP.M Resource LIst Data Model Impact Changes -----------------------------



   If  l_new_vendor_exists_member = 0 Then -- Insert New vendor as a resource list member

	    x_stage:=' New Vendor Does not esists as resource member.. creating resource member';

	Declare

	L_RESOURCE_LIST_ID              PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%TYPE;
	L_RESOURCE_ID			PA_RESOURCE_LIST_MEMBERS.RESOURCE_ID%TYPE;
	L_ORGANIZATION_ID         	PA_RESOURCE_LIST_MEMBERS.ORGANIZATION_ID%TYPE;
	L_EXPENDITURE_CATEGORY		PA_RESOURCE_LIST_MEMBERS.EXPENDITURE_CATEGORY%TYPE;
	L_REVENUE_CATEGORY		PA_RESOURCE_LIST_MEMBERS.REVENUE_CATEGORY%TYPE;
        l_res_grouped                   PA_RESOURCE_LISTS_ALL_BG.group_resource_type_id%TYPE;  /*Bug# 4029384*/
	Begin


 -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------
 -- Augmented original code with additional filter

/* -- Original Logic


	SELECT
	RESOURCE_LIST_ID, RESOURCE_ID, ORGANIZATION_ID, EXPENDITURE_CATEGORY, REVENUE_CATEGORY
 	INTO
 	L_RESOURCE_LIST_ID, L_RESOURCE_ID, L_ORGANIZATION_ID,L_EXPENDITURE_CATEGORY, L_REVENUE_CATEGORY
 	From pa_resource_list_members
 	Where RESOURCE_LIST_ID = rec1.resource_list_id
 	And   resource_list_member_id  = (Select parent_member_id from pa_resource_list_members
				   where RESOURCE_LIST_ID = rec1.resource_list_id
				   and vendor_id= p_old_vendor_id);
*/


 -- FP.M Data Model Logic

/*Bug# 4029384*/
        select group_resource_type_id
        into l_res_grouped
        from pa_resource_lists_all_BG
        where  RESOURCE_LIST_ID = rec1.resource_list_id;

       IF (l_res_grouped <> 0) THEN    /*To check if resource list is grouped */

	SELECT
 	 RESOURCE_LIST_ID, RESOURCE_ID, ORGANIZATION_ID, EXPENDITURE_CATEGORY, REVENUE_CATEGORY
 	INTO
 	 L_RESOURCE_LIST_ID, L_RESOURCE_ID, L_ORGANIZATION_ID,L_EXPENDITURE_CATEGORY, L_REVENUE_CATEGORY
 	From pa_resource_list_members
 	Where RESOURCE_LIST_ID = rec1.resource_list_id
 	And   resource_list_member_id  = (Select parent_member_id from pa_resource_list_members
	     			          where RESOURCE_LIST_ID = rec1.resource_list_id
				           and vendor_id= p_old_vendor_id
                                           and nvl(migration_code,'M') = 'M' );

 -- End: FP.M Resource LIst Data Model Impact Changes -----------------------------

       ELSE /*If resource list is not grouped*/

        SELECT
         RESOURCE_LIST_ID, RESOURCE_ID, ORGANIZATION_ID, EXPENDITURE_CATEGORY, REVENUE_CATEGORY
        INTO
         L_RESOURCE_LIST_ID, L_RESOURCE_ID, L_ORGANIZATION_ID,L_EXPENDITURE_CATEGORY, L_REVENUE_CATEGORY
        From pa_resource_list_members
        Where RESOURCE_LIST_ID = rec1.resource_list_id
         and vendor_id =p_old_vendor_id
         and nvl(migration_code,'M') = 'M';


       END IF;   /*End of changes of Bug# 4029384*/

			PA_CREATE_RESOURCE.Create_Resource_list_member
                         (p_resource_list_id          =>  rec1.resource_list_id,
                          p_resource_name             =>  l_new_vendor_name,
                          p_resource_type_Code        =>  'VENDOR',
                          p_alias                     =>  l_new_vendor_name,
                          p_sort_order                =>  NULL,
                          p_display_flag              =>  'Y',
                          p_enabled_flag              =>  'Y',
                          p_person_id                 =>  NULL,
                          p_job_id                    =>  NULL,
                          p_proj_organization_id      =>  L_ORGANIZATION_ID,
                          p_vendor_id                 =>  p_new_vendor_id,
                          p_expenditure_type          =>  NULL,
                          p_event_type                =>  NULL,
                          p_expenditure_category      =>  l_expenditure_category,
                          p_revenue_category_code     =>  L_REVENUE_CATEGORY,
                          p_non_labor_resource        =>  NULL,
                          p_system_linkage            =>  NULL,
                          p_project_role_id           =>  NULL,
                          p_parent_member_id          =>  l_parent_member_id,
                          p_resource_list_member_id   =>  l_resource_list_member_id,
                          p_track_as_labor_flag       =>  l_track_as_labor_flag,
                          p_err_code                  =>  l_err_code,
                          p_err_stage                 =>  x_stage,
                          p_err_stack                 =>  l_err_stack);
	End;
   End If;


   x_stage := ' Calling Resource List change api to update summarization data';
   /* The following code need to be called from API for resource list merger and refresh summary amounts */

		pa_proj_accum_main.ref_rl_accum(
               		    	l_err_stack,
                   		l_err_code,
                   		NULL,
                   		NULL,
                   		rec1.resource_list_id);

End Loop;



end; /** End Summarization **/

End UPD_PA_DETAILS_SUPPLIER_MERGE;


FUNCTION Allow_Supplier_Merge ( p_vendor_id         IN po_vendors.vendor_id%type
                            )
RETURN varchar2
IS
    l_budget_exists    Varchar2(1);
    l_allow_merge_flg  Varchar2(1); -- FP.M Change
BEGIN

 -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------
 -- Augmented original code with additional filter

/* -- Original Logic

select 'Y' into l_budget_exists
from pa_resource_assignments assign, pa_resource_list_members member, pa_budget_lines budget
where assign.RESOURCE_LIST_MEMBER_ID=member.RESOURCE_LIST_MEMBER_ID
and   member.vendor_id = p_vendor_id
and   budget.resource_assignment_id = assign.resource_assignment_id
and   rownum < 2 ;


*/

   -- FP.M Data Model Logic

    select 'Y'
    into l_budget_exists
    from pa_resource_assignments assign
    , pa_resource_list_members member
    , pa_budget_lines budget
    where assign.RESOURCE_LIST_MEMBER_ID=member.RESOURCE_LIST_MEMBER_ID
    and   member.vendor_id = p_vendor_id
    and   budget.resource_assignment_id = assign.resource_assignment_id
    and   rownum < 2
     and  nvl(member.migration_code,'M') = 'M';


  -- End: FP.M Resource LIst Data Model Impact Changes -----------------------------


-- Since Budget exists for the vendor to be merged Do not allow Supplier merge

Return 'N';

   -- FP.M change.
   -- pa_resource_utils.chk_supplier_in_use function checks to see if the given supplier ID is used by any
   -- planning resource lists or resource breakdown structures.  If it is in use, it returns 'Y'; if not,
   -- it returns 'N'. If the value returned is Y, Supplier merge is not allowed.

Exception
 When no_data_found then
   select decode(pa_resource_utils.chk_supplier_in_use(p_vendor_id),'Y','N','Y')
   into   l_allow_merge_flg
   from   dual;
Return  l_allow_merge_flg;
END Allow_Supplier_Merge;

/***************************************************************************
   Procedure        : get_asset_addition_flag
   Purpose          : When Expense Reports are sent to AP from PA,
                      the intermediate tables ap_expense_report_headers_all
                      and ap_expense_report_lines_all are populated. A Process
                      process in AP then populates the
                      Invoice Distribution tables. As there is no way in the
                      intermediate tables, to find out if the expense report is
                      associated with a 'Capital Project', which should not be
                      interfaced from AP to FA, unlike Invoice Distribution line
                      table, where asset_addition_flag is used. This API is to
                      find out if the given project_id is a 'CAPITAL' project
                      and if so, populate the 'out' vairable to 'P', else 'U'.
   Arguments        : p_project_id            IN - project id
                      x_asset_addition_flag  OUT - asset addition flag
****************************************************************************/


PROCEDURE get_asset_addition_flag
             (p_project_id           IN  pa_projects_all.project_id%TYPE,
              x_asset_addition_flag  OUT NOCOPY ap_invoice_distributions_all.assets_addition_flag%TYPE)
IS

   l_project_type_class_code  pa_project_types_all.project_type_class_code%TYPE;

BEGIN

  /* For Given Project Id, Get the Project_Type_Class_Code depending on the Project_Type */
  SELECT  ptype.project_type_class_code
    INTO  l_project_type_class_code
    FROM  pa_project_types_all ptype,
          pa_projects_all      proj
   WHERE  ptype.project_type     = proj.project_type
     --R12 AND  NVL(ptype.org_id, -99) = NVL(proj.org_id, -99)
     AND  ptype.org_id = proj.org_id
     AND  proj.project_id        = p_project_id;

   /* IF Project is CAPITAL then set asset_addition_flag to 'P' else 'U' */

   IF (l_project_type_class_code = 'CAPITAL') THEN

     x_asset_addition_flag  := 'P';

   ELSE

     x_asset_addition_flag  := 'U';

   END IF;

EXCEPTION

   WHEN OTHERS THEN
     RAISE;

END get_asset_addition_flag;

/***************************************************************************
   Function         : Get_Project_Type
   Purpose          : This function will check if the project id passed to this
                      is a 'CAPITAL' Project.If it is then this will return
                      'P' otherwise 'U'
   Arguments        : p_project_id            IN           - project id
                      Returns 'P' if the project is Capital otherwise 'U'
****************************************************************************/

FUNCTION Get_Project_Type
       (p_project_id IN pa_projects_all.project_id%TYPE)RETURN VARCHAR2 IS
l_project_type VARCHAR2(1);

BEGIN

/* For Given Project Id, Get the Project_Type_Class_Code depending on the Project_Type */

 SELECT decode(ptype.project_type_class_code,'CAPITAL','P','U')
  INTO  l_project_type
  FROM  pa_project_types_all ptype,
        pa_projects_all      proj
 WHERE proj.project_type = ptype.project_type
 -- R12 AND   NVL(ptype.org_id, -99) = NVL(proj.org_id, -99)
 AND   ptype.org_id = proj.org_id
 AND   proj.project_id   = p_project_id ;

 RETURN l_project_type;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
  END Get_Project_Type;

-- ==========================================================================================================================================
-- Bug 5201382 R12.PJ:XB3:DEV:NEW API TO RETRIEVE THE DATES FOR PROFILE PA_AP_EI_DATE_DEFAULT
-- p_transaction_date : API would return transaction date when profile value was set to 'Transaction Date'
--                       a. For Invoice transaction invoice_date should be passed as parameter
--                       b. For PO or Receipt Matched Invoice  Transactions invoice_date should be passed as parameter
--                       c. For RCV Transactions transaction_date should be passed.
--                       d. For payments and discounts ap dist exp_item_date should be passed.
-- p_gl_date          : API would return transaction date when profile value was set to 'Transaction GL Date'
--                      a. For Invoice transactions gl_date should be passed b. For payments and discounts the accounting date must be passed
--                      c. for RCV transactions accounting date should be passed.
-- p_po_exp_item_date : API would return the purchase order expenditure item date for po matched cases when profile value was set to
--                      'PO Expenditure Item Date/Transaction Date'. This is used for PO matched cases. It may be NULL when
--                       p_po_distribution_id was passed to the API.
-- p_po_distribution_id: The parameter value is used to determine the purchase order expenditure item date for po matched cases when profile
--                        value was set to 'PO Expenditure Item Date/Transaction Date'. when p_po_exp_item_date was passed  then
--                        p_po_distribution_id is not used to derive the expenditure item date.
-- p_creation_date : API would return this date when profile value was set to 'Transaction System Date'
-- p_calling_program : a. when called during the PO Match case : PO-MATCH b. When called from Invoice form        : APXINWKB
--                     c. When called from supplier cost xface for discounts : DISCOUNT d. When called from supplier cost xface for Payment: PAYMENT
--                     e. When called from supplier cost xface for Receipts  : RECEIPT
-- ==========================================================================================================================================
FUNCTION Get_si_cost_exp_item_date ( p_transaction_date      IN pa_expenditure_items_all.expenditure_item_date%TYPE,
                                     p_gl_date               IN pa_cost_distribution_lines_all.gl_date%TYPE,
                                     p_po_exp_item_date      IN pa_expenditure_items_all.expenditure_item_date%TYPE,
                                     p_creation_date         IN pa_expenditure_items_all.creation_date%TYPE,
                                     p_po_distribution_id    IN pa_expenditure_items_all.document_distribution_id%TYPE,
                                     p_calling_program       IN varchar2  )
 RETURN date is
    l_return_date          date ;
    l_pa_exp_date_default  varchar2(50) ;
    l_pa_debug_flag        varchar2(1) ;

    cursor c_po_date is
      select expenditure_item_date
        from po_distributions_all
       where po_distribution_id = p_po_distribution_id ;

 BEGIN
    l_pa_debug_flag :=  NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    l_pa_exp_date_default := FND_PROFILE.VALUE('PA_AP_EI_DATE_DEFAULT');

   IF l_pa_debug_flag = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PA_AP_INTEGRATION', 'Default Exp item date profile:'||l_pa_exp_date_default) ;
      END IF ;
   END IF ;

   /* Changes for bug 8289798 : Modified the case statements to handle lookup codes , rather than meanings*/
   CASE l_pa_exp_date_default
         WHEN 'INVTRNSDT' THEN
                l_return_date := p_transaction_date ;
         WHEN 'INVGLDT' THEN
                l_return_date := p_gl_date ;
         WHEN 'INVSYSDT' THEN
                l_return_date := p_creation_date ;
         -- Bug: 5262492 (R12.PJ:XB5:QA:APL: PROJECT EI DATE NULL FOR PO/REC MATCHED INVOICE LINE/DISTRIBU
         WHEN 'POTRNSDT' THEN
              IF p_po_exp_item_date is not NULL then
                 l_return_date := p_po_exp_item_date  ;
              ELSE
                IF l_pa_debug_flag = 'Y' THEN
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PA_AP_INTEGRATION', 'PO expenditure item date is NULL') ;
                   END IF ;
                END IF ;

                IF p_po_distribution_id is not NULL then
                   open c_po_date ;
		   fetch c_po_date into l_return_date ;
		   close c_po_date ;
                   IF l_pa_debug_flag = 'Y' THEN
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PA_AP_INTEGRATION',
			                'Determining the date based on the PO distribution IDL') ;
                      END IF ;
                   END IF ;
		ELSE
		-- Bug : 4940969
		-- In the case of unmatched invoice the Invoice date must get @ defaulted as the EI date.
		   l_return_date := p_transaction_date ;

                END IF ;
	      END IF ;
         ELSE
                l_return_date := NULL ;

   END CASE;

    IF l_pa_debug_flag = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,'PA_AP_INTEGRATION', 'Date returned :'||to_char(l_return_date, 'DD-MON-YYYY')) ;
      END IF ;
   END IF ;

   return l_return_date ;


 End Get_si_cost_exp_item_date ;


FUNCTION Get_si_default_exp_org RETURN varchar2 is
   l_default_exp_org HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE; /* Bug 5555041 */
   l_organization_id HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE; /* Bug 5555041 */
   l_default_exp_org1 HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE; /* Bug 7575377 */

/* Bug 5555041 - Start */
   CURSOR c_get_org_id(p_org_name HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE) IS
   SELECT organization_id
   FROM hr_all_organization_units_tl
   WHERE name = p_org_name;

   CURSOR c_get_org_name(p_organization_id HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE) IS
   SELECT name
   FROM per_organization_units
   WHERE organization_id = p_organization_id;
/* Bug 5555041 - End */
BEGIN
    l_default_exp_org := FND_PROFILE.VALUE('PA_DEFAULT_EXP_ORG');

/* Bug 5555041 - Start */
    OPEN  c_get_org_id(l_default_exp_org);
    FETCH c_get_org_id INTO l_organization_id;
    CLOSE c_get_org_id;

    OPEN c_get_org_name(l_organization_id);
    FETCH c_get_org_name INTO l_default_exp_org1; /* Modified for bug 7575377 */
    CLOSE c_get_org_name;
/* Bug 5555041 - End */

    return l_default_exp_org1 ; /* Modified for bug 7575377 */
END Get_si_default_exp_org ;

END pa_ap_integration;

/
