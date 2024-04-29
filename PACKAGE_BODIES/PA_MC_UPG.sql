--------------------------------------------------------
--  DDL for Package Body PA_MC_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_UPG" AS
--$Header: PAXMCUPB.pls 120.5 2005/08/26 11:07:42 skannoji noship $

/* Declare variables */

G_Pri_SOB_NAME		VARCHAR2(30);
G_Pri_SOB_ID		NUMBER(15);
G_Rep_SOB_NAME		VARCHAR2(30);
g_Rep_SOB_ID		NUMBER(15);
G_From_Prj_Num		VARCHAR2(30);
G_To_Prj_Num		VARCHAR2(30);
G_Project_ID		NUMBER (15);
G_Rounding		VARCHAR2(2);
G_Use_Curr_Rate		VARCHAR2(2);
G_Use_Debug_Flag	VARCHAR2(2);
G_User_ID		VARCHAR2(30);
G_MRC_LED		DATE;
G_MRC_Period		VARCHAR2(30);
G_Fixed_Type		VARCHAR2(30);
G_Fixed_Date		DATE;
G_Pri_Curr_Code		VARCHAR2(5);
G_Rep_Curr_Code		VARCHAR2(5);
G_Daily_Type		VARCHAR2(30);
G_Lock_Hndl 		VARCHAR2(128);
G_Num_Rate		NUMBER;
G_Denom_Rate		NUMBER;
G_Fixed_Rate		NUMBER;
G_Application_ID	NUMBER(15);
G_Org_ID		NUMBER(15);
G_Upgrade_Run_ID	NUMBER(15);
G_Program_ID		NUMBER(15);
G_MIN_Exp_Item_ID	NUMBER(15);
G_MAX_Exp_Item_ID	NUMBER(15);
G_MIN_CDL_Exp_Item_ID	NUMBER(15);
G_MAX_CDL_Exp_Item_ID	NUMBER(15);
G_MIN_CCDL_Exp_Item_ID	NUMBER;
G_MAX_CCDL_Exp_Item_ID	NUMBER;
G_MIN_DRAFT_INV_DTL_ID  NUMBER;
G_MAX_DRAFT_INV_DTL_ID  NUMBER;
G_MIN_Dr_Rev_Num	NUMBER(15);
G_MAX_Dr_Rev_Num	NUMBER(15);
G_MIN_Dr_Inv_Num	NUMBER(15);
G_MAX_Dr_Inv_Num	NUMBER(15);
G_MIN_Event_Num		NUMBER(15);
G_MAX_Event_Num		NUMBER(15);
G_MIN_Ast_Line_ID       NUMBER(15);
G_MAX_Ast_Line_ID       NUMBER(15);
G_MIN_Ast_Line_Dtl_ID   NUMBER(15);
G_MAX_Ast_Line_Dtl_ID   NUMBER(15);
G_Err_Stack		VARCHAR2(650);
G_Err_Stage		VARCHAR2 (2000);
G_Err_Code		NUMBER(15);
G_Process		VARCHAR2(5);
G_Validation_Check	VARCHAR2(1);
G_First_MRC_Period_Flag VARCHAR2(1);
G_Token2		VARCHAR2(30);
G_Project_Loop_Count	NUMBER := 0;
G_Org_Loop_Count	NUMBER := 0;
G_Login_ID              Number;
G_InterCompany_Project  Boolean;
G_Prvdr_Recvr_Flag      Varchar2(1) := 'R';
j                       Integer;
G_EI_Array              PA_PLSQL_DATATYPES.IdTabTyp ;
Null_G_EI_Array         PA_PLSQL_DATATYPES.IdTabTyp ;/* Added for bug 1683582 */
G_Future_Record_Found   Boolean;
--*
G_Conversion_Opt        Varchar2(1);
--*

PROCEDURE Upgrade_MRC ( x_errbuf 	OUT NOCOPY  VARCHAR2,
                	x_retcode 	OUT NOCOPY  VARCHAR2,
			x_Pri_SOB	IN	NUMBER,
			x_Rep_SOB	IN	NUMBER,
			x_From_Prj_Num	IN	VARCHAR2,
			x_To_Prj_Num	IN	VARCHAR2,
			x_Rounding	IN	VARCHAR2	DEFAULT 'N',
			x_Use_Curr_Rate	IN	VARCHAR2	DEFAULT 'N',
			x_Debug_Flag	IN	VARCHAR2	DEFAULT 'N',
                        x_include_closed_prj IN VARCHAR2        DEFAULT  'N',
			x_Process	IN	VARCHAR2	DEFAULT 'PLSQL',
			x_Validation_Check IN	VARCHAR2	DEFAULT 'Y'
			)


/** Upgrade_MRC : Main procedure for MRC upgrade.
	Parameters are passed from the script.
	G_Err_Code  0 - Success, -1 - Error ( Abort ).
	G_Err_Stage contains the error msg.
	Ora Errors will be raised as exceptions.
**/
IS

CURSOR C_Org IS
   SELECT org_id
   FROM   PA_IMPLEMENTATIONS_ALL
   WHERE  set_of_books_id = G_Pri_SOB_ID;

CURSOR C_Projects IS
   SELECT Proj.Project_ID
   FROM   PA_PROJECT_STATUSES ST,PA_PROJECTS PROJ
   WHERE  PROJ.segment1 between G_From_Prj_Num and G_To_Prj_Num
   AND    (G_First_MRC_Period_Flag = 'N'
             OR
            (G_First_MRC_Period_Flag = 'Y'
              AND
              (x_include_closed_prj = 'Y'
                 OR
                 (x_include_closed_prj = 'N'
                  AND    ST.project_system_status_code <> 'CLOSED'))))
   AND    ST.Project_Status_Code = Proj.Project_status_code
   AND    ST.status_type = 'PROJECT'
   Order BY Proj.Project_ID;
Cursor C_CC_EI
IS
 SELECT    EI.expenditure_item_id
 FROM      PA_EXPENDITURE_ITEMS_ALL EI,
           PA_IMPLEMENTATIONS_ALL IMP1,
           PA_IMPLEMENTATIONS_ALL IMP2
 WHERE     EI.ORG_ID = G_Org_ID
 AND       EI.ORG_ID <> EI.RECVR_ORG_ID
 AND       IMP1.ORG_ID = EI.ORG_ID
 AND       IMP1.set_of_books_id = G_Pri_SOB_ID
 AND       IMP2.ORG_ID = EI.RECVR_ORG_ID
 AND       IMP1.SET_OF_BOOKS_ID <> IMP2.SET_OF_BOOKS_ID;

v_Old_Stack VARCHAR2(650) := NULL;
v_Project_Count	NUMBER(15) := 0;
v_org_Count	NUMBER(15) := 0;
l_current_org_id NUMBER ;

BEGIN
NULL;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
	Write_Log('*******Exception encountered (NO DATA FOUND): ********');
        Write_Log (G_Err_Stack);
        Write_Log (G_Err_Stage);
	Submit_Report;
        Write_Log('End Run Date and Time: '||to_char(sysdate,'MM/DD/YYYY,HH24:MI:SS'));

   WHEN DUP_VAL_ON_INDEX THEN
	Write_Log('*******Exception encountered (DUP VAL ON INDEX): ********');
        Write_Log (G_Err_Stack);
        Write_Log (G_Err_Stage);
	Submit_Report;
        Write_Log('End Run Date and Time: '||to_char(sysdate,'MM/DD/YYYY,HH24:MI:SS'));

   WHEN OTHERS THEN
	Write_Log('*******Exception encountered (OTHERS): **********');
        Write_Log(SQLERRM);
        Write_Log (G_Err_Stack);
        Write_Log (G_Err_Stage);
	Submit_Report;
        Write_Log('End Run Date and Time: '||to_char(sysdate,'MM/DD/YYYY,HH24:MI:SS'));

END Upgrade_MRC;

-----------------------------------------------------------------

PROCEDURE Validate_Params
IS
/** Validate_Params : Procedure to validate parameters.
	Parameters should be available as global vars.
	While validating certain variables are set.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.
**/
v_Old_Stack	VARCHAR2(650);
l_Currency_Code VARCHAR2(5);

BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack||'->Validate_Params';
   G_Err_Code := 0;
   G_Err_Stage := 'Starting Validate_Params';
   Write_Log(G_Err_Stack);

END Validate_Params;
--------------------------------------------------------------------
/** Init_Upgrade : Procedure to initialize variables.
	Works on global vars. Sets variables as needed.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.
**/

PROCEDURE	Init_Upgrade
IS
--l_Result_Code VARCHAR2(30) ;
v_old_stack VARCHAR2(650);

BEGIN

   v_old_stack := G_Err_Stack;
   G_Err_Code := 0;
   G_Err_Stack := G_Err_Stack || '->Init_Upgrade';
   G_Err_Stage := 'Entering Init_Upgrade';

   Write_Log (G_Err_Stack);

  /* Set Application ID */
   G_Application_ID := 275;

END Init_Upgrade;

-------------------------------------------------------------------------
/** Cache_Exchange_Rates :
    This procedure will cache the exchange rates for various transaction
    Currencies and the Reporting currency before doing the MRC Upgrade. If
    It is unable to find rates for any currency, It will list out those
    currencies, so that the rates for them can be populated and this procedure
    is rerun
**/

PROCEDURE cache_exchange_rates
IS

/* Added UNION for fix of 3159188 */
CURSOR C_currency IS
  (SELECT distinct denom_currency_code
  from pa_expenditure_items_all pei
  where not exists (select null
                    from PA_MC_UPGRADE_RATES
                    where From_currency = pei.denom_currency_code
                    and   To_Currency   = G_Rep_Curr_Code
                    and   Exchange_date = G_Fixed_Date
                    and   Rate_Type     = G_Fixed_Type)
  and denom_currency_code <> G_Rep_Curr_Code
  UNION
  SELECT distinct bill_trans_currency_code
  from pa_events pevt
  where not exists (select null
                    from PA_MC_UPGRADE_RATES
                    where From_currency = pevt.bill_trans_currency_code
                    and   To_Currency   = G_Rep_Curr_Code
                    and   Exchange_date = G_Fixed_Date
                    and   Rate_Type     = G_Fixed_Type)
  and bill_trans_currency_code <> G_Rep_Curr_Code)
  order by 1;

v_Curr_rec		C_currency%rowtype;
v_old_stack 		VARCHAR2(650);
v_currency_code  	VARCHAR2(2000);
v_separator             VARCHAR2(1);
v_err_count		NUMBER := 0;
BEGIN

   v_old_stack := G_Err_Stack;
   G_Err_Code := 0;
   G_Err_Stack := G_Err_Stack || '->Cache_Exchange_Rates';
   G_Err_Stage := 'Entering Cache_Exchange_Rates';

EXCEPTION WHEN OTHERS THEN
  RAISE;

END cache_exchange_rates;

-------------------------------------------------------------------------
/** insert_temp_rates : Procedure to Insert a transaction currency along with its
    Fixed rate on the Initial MRC Date, into the cache table.
    Package modified for Different Conversion Options msundare on 27-06-00
 **/

PROCEDURE insert_temp_rates ( x_currency_code 		IN VARCHAR2 )
IS

v_denominator_rate		NUMBER;
v_numerator_rate		NUMBER;
v_exchange_rate			NUMBER;
v_old_stack 		    VARCHAR2(650);

BEGIN

   v_old_stack := G_Err_Stack;
   G_Err_Code := 0;
   G_Err_Stack := G_Err_Stack || '->insert_temp_rates';
   G_Err_Stage := 'Entering insert_temp_rates';

   G_Err_Stage := 'Before Get Triangulation Rate ';

EXCEPTION WHEN gl_currency_api.NO_RATE THEN
  G_Err_code := -1;

WHEN gl_currency_api.INVALID_CURRENCY THEN
  pa_mc_currency_pkg.raise_error('PA_MRC_INV_CUR','PAMRCUPG',x_currency_code);

WHEN OTHERS THEN
  RAISE;

END insert_temp_rates;

-------------------------------------------------------------------------
/** Validate_SOB_Assign : Procedure to validate if the Primary and Reporting
	Set of books assignment is valid. If yes, then set the variables,
	else return with -1.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.

**/

PROCEDURE Validate_SOB_Assign (	x_Pri_SOB_ID	IN	NUMBER,
				x_Rep_SOB_ID	IN	NUMBER)

IS
v_Old_Stack VARCHAR2(650);
BEGIN

    G_Err_Code := 0;
    v_Old_Stack := G_Err_Stack;
    G_Err_Stack := G_Err_Stack ||'->Validate_SOB_Assign';
    G_Err_Stage := 'Starting Validate_SOB_Assign';


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	G_Err_Code := -1;
	G_Err_Stage := 'PA_MRC_SOB_ASSIGN';
        G_Token2 := '.';

END Validate_SOB_Assign;
------------------------------------------------------------------------

Function 	Check_Future_Record
		Return BOOLEAN
IS
v_table_name VARCHAR2(30);
v_Old_Stack  VARCHAR2(650);

BEGIN

   G_Err_Code := 0;
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack ||'->Check_Future_Record';
   G_Err_Stage := 'Checking Future Record';

   write_log (G_Err_Stage);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      G_Err_Stage := 'No Future Record Found';
      IF G_Use_Debug_Flag = 'Y' THEN
         write_log (G_Err_Stage);
      END IF;
      G_Err_Stack := v_Old_Stack;
      RETURN FALSE;

END;
------------------------------------------------------------------------
Function 	Validate_First_MRC_Period
		RETURN BOOLEAN
IS
v_GL_Period Number;
v_Old_Stack  VARCHAR2(650);
v_Period_Name VARCHAR2(15);

BEGIN

   G_Err_Code := 0;
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack ||'->Validate_First_MRC_Period';
   G_Err_Stage := 'Inside Validate_First_MRC_Period';

  IF G_Use_Debug_Flag = 'Y' THEN
     write_log (G_Err_Stage);
  END IF;

  Return TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF G_Use_Debug_Flag = 'Y' THEN
         write_log ('Validate First MRC Period returning False');
      END IF;
    WHEN OTHERS THEN
    IF G_Use_Debug_Flag = 'Y' THEN
         write_log ('sqlerrm');
      END IF;
    G_Err_Stack := v_Old_Stack;
      Return FALSE;

END;
------------------------------------------------------------------------
/** Insert_History_Rec : Procedure to insert a history rec.
	x_table_name : Table to insert rec for.
	x_Project_ID : Project to insert recoed for.
	x_Status : 'CONVERSION' or 'ROUNDING' status
	x_Status_Value : 'C' Converted, 'S' In Process or NULL.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.

        Ora Errors will be raised as exceptions.
**/

PROCEDURE 	Insert_History_Rec (	x_Table_Name 	IN	VARCHAR2,
					x_Project_ID	IN 	NUMBER,
					x_Status	IN	VARCHAR2,
					x_Status_Value	IN	VARCHAR2)
IS

v_Old_Stack VARCHAR2(650);

BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_History_Rec';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_History_Rec ' ||x_Table_Name ;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX Then
	G_Err_Code := -1;
	G_Err_Stage := 'PA_MRC_HIST_DUP';
        G_Token2 := x_Table_Name;

END Insert_History_Rec;


-----------------------------------------------------------------------
/** Get_Project_Number : Function to get the project number MIN or MAX.
	x_Project_Range can be MIN or MAX. Accordingly, a minimum or
	a maximum project number is returned. Project Number is Unique
	across Orgs. Hence PA_Projects_ALL used.
	Returns Project number if successful.
	Returns -1 if Project number cannot be obtained.

	Returns -2 if MIN or MAX not specified.
        Ora Errors will be raised as exceptions.
**/

FUNCTION Get_Project_Number (	x_Project_Range	IN	VARCHAR2 )
RETURN VARCHAR2 IS

v_project_number varchar2(30);
v_Old_Stack VARCHAR2(650);

BEGIN
   G_Err_Code := 0;
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack||'->Get_Project_Number';
   G_Err_Stage := 'Starting Get_Project_Number: '||x_Project_Range;

   RETURN v_project_number;


END Get_Project_Number;

----------------------------------------------------------------------------
/** Validate_SOB : Function to validate the set of books name passed.
	Returns Set of Books ID, if found, Else -1. ( ABORT )
        Ora Errors will be raised as exceptions.
**/
FUNCTION Validate_SOB (	x_SOB_ID	IN	NUMBER,
			l_Currency_Code	OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS
v_SOB_Name VARCHAR2(30);
v_Old_Stack VARCHAR2(650);

BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack||'->Validate_SOB';
   G_Err_Code := 0;
   G_Err_Stage := 'Starting Validate_SOB' || x_SOB_ID;

   RETURN v_SOB_Name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Validate_SOB;
----------------------------------------------------------------
/** Get_User_Lock : Function to acquire a user lock.
	x_lock_name : name of the lock.
	x_lock_mode : Mode of the lock ( Exclusive,..)
	x_commit_mode : Rls with commit or not
	Returns : lock handle if successful in acquiring lock
	else -1 - Cannot acquire lock.
        Ora Errors will be raised as exceptions.
**/


FUNCTION	Get_User_Lock (	x_Lock_Name	IN	VARCHAR2,
                                x_Lock_Mode	IN	NUMBER default 6,
				x_Commit_Mode	IN	BOOLEAN default FALSE )
RETURN  VARCHAR2
IS
        timeout  number := 100;
        lstatus  number;
	lockhndl varchar2(128);
        v_Old_Stack VARCHAR2(650);

BEGIN
	v_Old_Stack := G_Err_Stack;
	G_Err_Stack := G_Err_Stack || '->Get_User_Lock';
        G_Err_Code := 0;
        G_Err_Stage := 'Entered Get_User_Lock';

        IF G_use_Debug_Flag = 'Y' THEN
           Write_Log (G_Err_Stage);
        END IF;

           Return NULL;  /* Failed to allocate lock */

END Get_User_Lock;

------------------------------------------------------------------
/** Rls_User_Lock : Function to release user lock.
	x_Lock_Hndl : The lock handle obtained earlier.
	Returns 0 - success, -1 - Error. ( Abort ).
**/

FUNCTION	Rls_User_Lock (	x_Lock_Hndl	IN	VARCHAR2 )
		RETURN NUMBER
IS
status number;
v_Old_Stack VARCHAR2(650);

BEGIN
      	v_Old_Stack := G_Err_Stack;
   	G_Err_Stack := G_Err_Stack || '->Rls_User_Lock ';
   	G_Err_Code := 0;
   	G_Err_Stage:= 'Starting Rls_User_Lock';

	status := dbms_lock.release(x_lock_hndl);
        G_Err_Stage := 'Release Lock Status: '||to_char(status);
        IF G_Use_Debug_Flag = 'Y' THEN
           Write_Log (G_Err_Stage);
        END IF;

           Return 0;

END Rls_User_Lock;

------------------------------------------------------------------
/** Get_Table_Status : Function to get the table status for the project from
	the MRC upgrade history table.
	x_table_name : table to be checked for.
	x_Project_ID : Project to be checked for.
	x_Status : Status to check for - Conversion or Rounding.

		   Can have values - CONVERSION or ROUNDING.
	Returns : 'C' = Converted, NULL = Not done yet. '-1' if status
	specified is wrong.
**/

FUNCTION	Get_Table_Status (	x_Table_Name	IN	VARCHAR2,
					x_Project_ID	IN	NUMBER,
					x_Status	IN	VARCHAR2 )
		RETURN	VARCHAR2
IS

v_status VARCHAR2(25);
v_Old_Stack VARCHAR2(650);


BEGIN
	v_Old_Stack := G_Err_Stack;
	G_Err_Stack := G_Err_Stack || '->Get_Table_Status';
        G_Err_Code := 0;
        G_Err_Stage := 'Entered Get_Table_Status'||x_Table_Name;

	Return v_status;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	G_Err_Stack := v_Old_Stack;
      RETURN NULL;

END Get_Table_Status;

-----------------------------------------------------------------

PROCEDURE	Convert_Table (		x_Table_Name	IN	VARCHAR2 )
IS
v_status VARCHAR2(25);
v_Old_Stack VARCHAR2(650);

BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Convert_Table';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Convert_Table '||x_Table_Name ;

END Convert_Table;

-----------------------------------------------------------------

PROCEDURE	Insert_Recs (		x_Table_Name	IN	VARCHAR2)
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_Recs ';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inserting  Records: ' ||x_Table_Name;

END Insert_Recs;

-----------------------------------------------------------------

PROCEDURE	Update_Recs (		x_Table_Name	IN	VARCHAR2)
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_Recs ';
   G_Err_Code := 0;
   G_Err_Stage:= 'Starting Update_Recs: ' ||x_Table_Name;

END Update_Recs;
-----------------------------------------------------------------

PROCEDURE	Insert_CDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_CDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CDL ';

IF G_Use_Debug_Flag = 'Y' THEN
   Write_Log (G_Err_Stage);
END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   -- This Exception will be raised from get_converted_amount,
   -- If  the rate is not found for the Denom Currency in the cache
     Rollback;

     G_Err_code := -10;
     cache_exchange_rates;
     Commit;
   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_CDL;
-----------------------------------------------------------------

PROCEDURE	Insert_CRDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_CRDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CRDL ';


EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_CRDL;
-----------------------------------------------------------------

PROCEDURE	Insert_ERDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_ERDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_ERDL ';

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_ERDL;
-----------------------------------------------------------------

PROCEDURE	Insert_DR
IS
v_Old_Stack VARCHAR2(650);
BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_DR';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_DR ';

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_DR;
-----------------------------------------------------------------

PROCEDURE	Insert_Event
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_Event';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_Event ';

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN

      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_Event;
-----------------------------------------------------------------

PROCEDURE	Insert_AL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_AL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_AL ';

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_AL;
-----------------------------------------------------------------

PROCEDURE	Insert_ALD
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_ALD';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_ALD';

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_ALD;
-----------------------------------------------------------------

Procedure Insert_DINV               (x_Project_ID 	IN	NUMBER,
				     x_Rep_SOB_ID	IN	NUMBER)
IS
/* added di.canceled_flag orig_canceled_flag, di.invoice_date invoice_date
   for bug fix 1924362 */

    CURSOR c_dinv ( rprojectid IN Number ) IS
    SELECT di.draft_invoice_num draft_invoice_num,
           di.draft_invoice_num_credited draft_invoice_num_credited,
	   NVL(di.unbilled_receivable_dr,0) unbilled_receivable_dr,
	   NVL(di.unearned_revenue_cr,0) unearned_revenue_cr,
           di.write_off_flag write_off_flag ,
	   di.customer_bill_split customer_bill_split,
	   NVL(di.retention_percentage,0) retention_percentage,
           NVL(di.retention_invoice_flag,'N') retention_invoice_flag, /* added bug2966251 */
           dic.canceled_flag canceled_flag,
           di.canceled_flag orig_canceled_flag,
           di.invoice_date invoice_date
    FROM   PA_Draft_Invoices dic,
           PA_Draft_Invoices di
    WHERE  di.project_id = rprojectid
    AND    dic.project_id(+) = di.project_id
    AND    dic.draft_invoice_num(+) = di.draft_Invoice_num_credited
    ORDER BY 1;

/* added amount for bug fix 1924362 */
    CURSOR c_inv_items ( rprojectid IN NUMBER, rdinvnum IN NUMBER )  IS
    SELECT decode(invoice_line_type,'RETENTION',2,1) l_type, line_num,
           event_task_id, event_num, invoice_line_type,amount /* added for bug 1946624 */
           , bill_trans_currency_code, bill_trans_bill_amount /* MCB2 */
           , projfunc_bill_amount, retention_rule_id,invproc_currency_code/* added bug 2966251 */
    FROM   pa_draft_invoice_items
    WHERE  project_id = rprojectid
    AND    draft_invoice_num = rdinvnum
    ORDER BY 1,2;

/* decode used and then the order by so as to get the RETENTION lines
   as the last line */



    v_dinv                 c_dinv%ROWTYPE;
    rec_inv_items          c_inv_items%ROWTYPE;
    --currency               VARCHAR2(30);

    --sob                    NUMBER;
    l_transfer_status_code VARCHAR2(1);
    v_Old_Stack 	     VARCHAR2(650);

BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_DINV';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_DINV ';

   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log (G_Err_Stage);
   END IF;

    --currency := G_PRI_CURR_CODE;

    --sob      := G_PRI_SOB_ID;

/* Loop for all Draft invoices for this project */

EXCEPTION
	WHEN OTHERS THEN
	RAISE;
	IF G_Use_Debug_Flag = 'Y' THEN
   	   Write_Log ('Exitting Insert_DINV');
	END IF;

END Insert_DINV;
-----------------------------------------------------------------

PROCEDURE Insert_exp_items(	x_Project_ID	IN	Number,
				x_Rep_SOB_ID	IN	Number)
IS
l_raw_cost                Number := 0;
l_burdened_cost 	  Number := 0;
l_revenue 		  Number := 0;
l_accrued_revenue 	  Number :=0;
l_bill_amount 	 	  Number := 0;
l_raw_revenue             Number := 0;
l_adjusted_revenue        Number := 0;
l_forecast_revenue        Number := 0;
l_exchange_rate_cost      Number :=0;
l_exchange_rate_rev       Number :=0;
l_exchange_rate_type_rev  VARCHAR2(30);
l_exchange_date_rev       DATE;

l_tp_exchange_rate        Number;
l_tp_exchange_date        Date;
l_tp_rate_type            Varchar2(30);

l_transfer_price          Number;
l_exchange_date_cost      Date;
l_exchange_rate_type_cost Varchar2(30) ;
v_Old_Stack               VARCHAR2(650);

l_denominator_rate        NUMBER;
l_numerator_rate          NUMBER;

l_fcst_exchange_date       DATE ;
l_fcst_exchange_rate_type  VARCHAR2(30) ;
l_fcst_exchange_rate       NUMBER := 0 ;

l_inv_exchange_date        DATE ;
l_inv_exchange_rate_type   VARCHAR2(30) ;
l_inv_exchange_rate        NUMBER := 0 ;

l_result_code             VARCHAR2(15);


Cursor C_exp_items IS
	Select expenditure_item_id, Denom_raw_cost,
	        quantity,
		acct_currency_code,
		project_currency_code,
		expenditure_item_date,
		Denom_burdened_cost, raw_revenue, accrued_revenue,
		adjusted_revenue, forecast_revenue,
		bill_amount, net_zero_adjustment_flag,
                bill_trans_bill_amount,
                bill_trans_raw_revenue,
                projfunc_inv_rate_date,
                projfunc_inv_rate_type,
                projfunc_inv_exchange_rate,
                projfunc_rev_rate_type,
                projfunc_rev_exchange_rate,
                projfunc_rev_rate_date,
                bill_trans_forecast_revenue,
                projfunc_fcst_rate_date,
                projfunc_fcst_rate_type,
                projfunc_fcst_exchange_rate,
                bill_trans_currency_code,
		transferred_from_exp_item_id,
		denom_transfer_price,
		cc_cross_charge_code,
		project_exchange_rate,
		recvr_org_id,
		acct_raw_cost,
		acct_burdened_cost,
		acct_rate_type,
		acct_rate_date,
		acct_exchange_rate,
		acct_transfer_price,
		acct_tp_rate_type,
		acct_tp_rate_date,
		acct_tp_exchange_rate,
		denom_currency_code  -- added for MRC enhancement
                ,org_id
   	  From	PA_Expenditure_Items_ALL
     Where  expenditure_item_id < NVL(G_MIN_exp_item_id,G_MAX_exp_item_id)
	   And  Project_Id = x_Project_ID;
		  /* Bug 3961113 : Removing unnecessary join with PA_TASKS
	        and  	Task_id IN (	Select task_id
				        From	PA_Tasks
				        Where	Project_ID = x_Project_ID );
		  */

Begin
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_exp_items';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_exp_items: Max EI['||G_MAX_exp_item_id||']Min EI['||G_MIN_exp_item_id||
                 ']ProjectId['||x_Project_ID||']';
   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log(G_Err_Stage);
   END IF;

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';

END Insert_exp_items;
-----------------------------------------------------------------

PROCEDURE	Update_CDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_CDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_CDL ';
   /** This part is not needed because both original transactions
       and reversed transactions use either expenditure item date
       or G_Fixed_Date for conversion so absolute values of both
       converted amounts should be same **/

END Update_CDL;
-----------------------------------------------------------------

PROCEDURE	Update_CRDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_CRDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_CRDL ';

END Update_CRDL;
-----------------------------------------------------------------
PROCEDURE	Update_ERDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_ERDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_ERDL ';

END Update_ERDL;
-----------------------------------------------------------------

PROCEDURE	Update_DR
IS
BEGIN
G_Err_Code := 0;
END Update_DR;
-----------------------------------------------------------------

PROCEDURE	Update_Event
IS
BEGIN
G_Err_Code := 0;
END Update_Event;
-----------------------------------------------------------------

PROCEDURE	Update_AL
IS
BEGIN
G_Err_Code := 0;
END Update_AL;
-----------------------------------------------------------------

PROCEDURE	Update_ALD
IS
BEGIN

G_Err_Code := 0;

END Update_ALD;
-----------------------------------------------------------------

PROCEDURE	Update_DINV
IS
BEGIN

G_Err_Code := 0;

END Update_DINV;
-----------------------------------------------------------------
PROCEDURE update_exp_items (	x_Project_ID 	IN	Number,
				x_Rep_SOB_ID	IN	Number)
IS

prev_orig_ei Number := 0;
split_flag Varchar2(1) := 'N';
split_amt Number := 0;
split_raw_cost Number := 0;
split_burden_cost Number := 0;

/* Cursor modified for bug 1534858. Explicit hints are given so that even if statisctics
   are not available on mc tables during upgrade it takes this plan only which is the best plan
*/


v_Old_Stack VARCHAR2(650);

Begin
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_exp_items';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_exp_items ';
END Update_exp_items ;
-----------------------------------------------------------------
/** Important: Dependencies: Get_Rate_Type,Get_Rate_Date. If you modify any
	       logic in get_converted_amount check if the logic has any
	       impact on those two dependent functions **/

FUNCTION Get_Converted_Amount ( x_Denom_Cur_Code  IN    Varchar2,
                                x_Acct_Rate_Type  IN    Varchar2,
                                x_Conversion_Date IN	Date,
                                x_Amount	  IN	Number,
                                x_Acct_Amt        IN    Number,
                                x_Rate            IN    Varchar2
							    DEFAULT 'N'
			       )
RETURN NUMBER
IS
Converted_Amount Number;
Sign_Factor      Number (1);

/* 08-20-1998 : Earlier GL_Date was compared against MRC Date to determine if
   the txn is future dated or not. Now it is the txn date, that is compared
   against the MRC date to determine this. Thus the GL Date parameter
   is not used, instead conversion date parameter is used.
   Tsaifee. */

v_curr_code	Varchar2(15):= NULL;
v_denom_rate    NUMBER;
v_num_rate      NUMBER;
v_amount        NUMBER;

BEGIN

    Return (Converted_Amount);

END Get_Converted_Amount;
-------------------------------------------------------------
PROCEDURE Get_Cached_Rate ( x_curr_code		IN	VARCHAR2,
                            x_denom_rate        OUT NOCOPY NUMBER,
                            x_num_rate		OUT NOCOPY NUMBER)
IS
BEGIN

NULL;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END Get_Cached_Rate;
-------------------------------------------------------------
PROCEDURE	Write_Log (		x_Msg	IN	VARCHAR2)
IS
BEGIN

 --r_debug.r_msg('Log:'||x_Msg);

IF G_Process = 'PLSQL' THEN
   FND_FILE.PUT(FND_FILE.LOG,x_Msg);
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
ELSIF G_Process = 'SQL' THEN
   --dbms_output.put_line (x_Msg);
   NULL;
END IF;

EXCEPTION

   WHEN UTL_FILE.INVALID_PATH THEN
        raise_application_error(-20010,'INVALID PATH exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
   WHEN UTL_FILE.INVALID_MODE THEN
        raise_application_error(-20010,'INVALID MODE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        raise_application_error(-20010,'INVALID FILEHANDLE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
   WHEN UTL_FILE.INVALID_OPERATION THEN
        raise_application_error(-20010,'INVALID OPERATION exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
   WHEN UTL_FILE.READ_ERROR THEN
        raise_application_error(-20010,'READ ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
   WHEN UTL_FILE.WRITE_ERROR THEN
        raise_application_error(-20010,'WRITE ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
    WHEN UTL_FILE.INTERNAL_ERROR THEN
        raise_application_error(-20010,'INTERNAL ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

END Write_Log;
-------------------------------------------------------------
PROCEDURE       Write_Out (             x_Msg   IN      VARCHAR2)
IS
BEGIN

IF G_Process = 'PLSQL' THEN
   FND_FILE.PUT(FND_FILE.OUTPUT,x_Msg);
   FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
ELSIF G_Process = 'SQL' THEN
/*  dbms_output.put_line (x_Msg);   */
   NULL;
END IF;

END Write_Out;
-------------------------------------------------------------
PROCEDURE Submit_Report
IS
v_request number;

BEGIN
IF G_Project_Loop_Count >0 THEN
  Write_Log(' ');
  Write_Log('Submitting Request for Report');
  v_request := FND_REQUEST.Submit_Request('PA','PAMRCUPGRPT',NULL,NULL,NULL,
				G_PRI_SOB_ID, G_REP_SOB_ID, G_UPGRADE_RUN_ID );
  if v_request = 0 then
	Write_Log('Error encountered while submitting request for report');
  else
      G_Err_Stage := 'PA_MRC_UPG_REP';
      fnd_message.set_name('PA', G_Err_Stage);
      fnd_message.set_token('MODULE', 'PAXMCUPB');
      fnd_message.set_token('CURRENCY', to_char(v_request));
      G_Err_Stage := fnd_message.get;

      Write_Log (G_Err_Stage);
      Write_Out (' ');
      Write_Out (G_Err_Stage);

  end if;
END IF;
END Submit_Report;
--------------------------------------------------------------
PROCEDURE           Insert_CCDL
IS
	l_rep_rsob_id                 PA_PLSQL_DATATYPES.IDTabTyp;
	l_org_id                      PA_PLSQL_DATATYPES.IDTabTyp;
	l_rcurrency_code              PA_PLSQL_DATATYPES.Char15TabTyp;
	l_cc_dist_line_id             PA_PLSQL_DATATYPES.IDTabTyp;
	l_expenditure_item_id         PA_PLSQL_DATATYPES.IDTabTyp;
	l_line_num                    PA_PLSQL_DATATYPES.IDTabTyp;
	l_cdl_line_num                PA_PLSQL_DATATYPES.NumTabTyp;
	l_acct_tp_rate_type           PA_PLSQL_DATATYPES.Char30TabTyp;
	l_prvdr_cost_reclass_code     PA_PLSQL_DATATYPES.Char240TabTyp;
	l_expenditure_item_date       PA_PLSQL_DATATYPES.DateTabTyp;
	l_acct_tp_exchange_rate       PA_PLSQL_DATATYPES.NumTabTyp;
	l_denom_transfer_price        PA_PLSQL_DATATYPES.NumTabTyp;
        l_denom_currency_code         PA_PLSQL_DATATYPES.Char15TabTyp;
	l_dist_line_id_reversed       PA_PLSQL_DATATYPES.IDTabTyp;
	l_line_type                   PA_PLSQL_DATATYPES.Char2TabTyp;
	v_old_stack                   Varchar2(650);
	i                             Integer;
	l_use_debug_flag              Boolean;


BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_CCDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CCDL ';
   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log (G_Err_Stage);
   END IF;

   i := 1;

END Insert_CCDL;

PROCEDURE	Update_CCDL
IS
BEGIN
G_Err_Code := 0;
END Update_CCDL;
---------------------------------------------------------------------------------
FUNCTION Check_Intercompany_Project (p_project_id IN Number )
RETURN BOOLEAN
IS

Cursor C_Project_Type
IS
SELECT  TYP.CC_PRVDR_FLAG
FROM    PA_PROJECTS PROJ,
        PA_PROJECT_TYPES TYP
WHERE   TYP.PROJECT_TYPE = PROJ.PROJECT_TYPE
AND     PROJ.PROJECT_ID = p_PROJECT_ID;

l_prvdr_flag    Varchar2(1);

BEGIN
   open C_Project_Type;

   fetch C_Project_Type
   into  l_prvdr_flag;

   close c_project_type;

   IF NVL(l_prvdr_flag,'N') = 'Y' THEN
      return True;
   ELSE
      return FALSE;
   END IF;

END Check_Intercompany_Project;
---------------------------------------------------------------------------------

PROCEDURE	Insert_DINVDTLS

IS

I Integer;
v_old_stack                   Varchar2(650);
l_EI_Date                    PA_PLSQL_DATATYPES.DateTabTyp;


INV_REC PA_INVOICE_DETAIL_PKG.inv_rec_tab;

Cursor C_INV_DTLS
IS
SELECT DINVDTLS.DRAFT_INVOICE_DETAIL_ID INVOICE_DETAIL_ID,
       DINVDTLS.EXPENDITURE_ITEM_ID EI_ID,
       DINVDTLS.LINE_NUM LINE_NUM,
       DINVDTLS.PROJECT_ID PROJECT_ID,
       DINVDTLS.DENOM_CURRENCY_CODE DENOM_CURRENCY_CODE,
       DINVDTLS.DENOM_BILL_AMOUNT DENOM_BILL_AMOUNT,
       DINVDTLS.INVOICED_FLAG INVOICED_FLAG,
       DINVDTLS.ACCT_CURRENCY_CODE ACCT_CURRENCY_CODE,
       DINVDTLS.BILL_AMOUNT BILL_AMOUNT,
       DINVDTLS.ACCT_RATE_TYPE ACCT_RATE_TYPE,
       DINVDTLS.ACCT_RATE_DATE ACCT_RATE_DATE,
       DINVDTLS.ACCT_EXCHANGE_RATE ACCT_EXCHANGE_RATE,
       DINVDTLS.CC_PROJECT_ID CC_PROJECT_ID,
       DINVDTLS.CC_TAX_TASK_ID CC_TAX_TASK_ID,
       EI.Expenditure_item_date EI_DATE

FROM   PA_DRAFT_INVOICE_DETAILS_ALL DINVDTLS,
       PA_EXPENDITURE_ITEMS_ALL EI
WHERE  DINVDTLS.project_id = G_Project_ID
AND    DINVDTLS.draft_invoice_detail_id <
	        NVL(G_MIN_DRAFT_INV_DTL_ID,G_MAX_DRAFT_INV_DTL_ID)
AND    EI.expenditure_item_id = DINVDTLS.EXPENDITURE_ITEM_ID;

BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_DINVDTLS';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_DINVDTLS';
   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log (G_Err_Stage);
   END IF;


END Insert_DINVDTLS;

---------------------------------------------------------------------------------

PROCEDURE	Update_DINVDTLS

IS

BEGIN

G_Err_Code := 0;
END Update_DINVDTLS;
--------------------------------------------------------------------------------

FUNCTION Different_SOB (p_prvdr_org_id       IN     Number,
			p_recvr_org_id       IN     Number)
Return Varchar2
IS

l_prvdr_sob Number;
l_recvr_sob Number;
v_old_stack     Varchar2(2000);

Cursor C_SOB
IS
SELECT IMP1.set_of_books_id,
       IMP2.set_of_books_id
FROM   PA_IMPLEMENTATIONS_ALL IMP1,
       PA_IMPLEMENTATIONS_ALL IMP2
WHERE  IMP1.org_id = p_prvdr_org_id
AND    IMP2.org_id = p_recvr_org_id;

BEGIN

   open c_sob;
   fetch c_sob
   into  l_prvdr_sob,l_recvr_sob;
   close c_sob;

   IF NVL(l_prvdr_sob,-99) = NVL(l_recvr_sob,-99)THEN
      return 'N';
   ELSE
      return 'Y';
   END IF;


END Different_SOB;
---------------------------------------------------------------------------------
FUNCTION Prvdr_Proj_Converted
Return Boolean
IS
v_table_name    Varchar2(30);
v_old_stack     Varchar2(2000);

BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Prvdr_Proj_Converted';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Prvdr_Proj_Converted';

      return TRUE;

END;
------------------------------------------------------------------------------
Procedure Insert_CC_CDL
IS

v_old_stack     Varchar2(2000);

/** Create the array element to store the CDL records to be inserted **/

l_expenditure_item_id   PA_PLSQL_DATATYPES.IdTabTyp;
l_line_num              PA_PLSQL_DATATYPES.IdTabTyp;
l_line_type             PA_PLSQL_DATATYPES.Char1TabTyp;
l_transfer_status_code  PA_PLSQL_DATATYPES.Char1TabTyp;
l_quantity              PA_PLSQL_DATATYPES.NumTabTyp;
l_rate_type             PA_PLSQL_DATATYPES.Char30TabTyp;
l_transferred_date      PA_PLSQL_DATATYPES.DateTabTyp;
l_transfer_rejection_reason  PA_PLSQL_DATATYPES.Char250TabTyp;
l_amount                PA_PLSQL_DATATYPES.NumTabTyp;
l_batch_name            PA_PLSQL_DATATYPES.Char30TabTyp;
l_burdened_cost         PA_PLSQL_DATATYPES.NumTabTyp;
l_currency_code         PA_PLSQL_DATATYPES.Char15TabTyp;
l_exchange_rate         PA_PLSQL_DATATYPES.NumTabTyp;
l_conversion_date       PA_PLSQL_DATATYPES.DateTabTyp;
k                       Integer;

Cursor C_CC_CDL
IS
SELECT CDL.expenditure_item_id EI_ID,
       CDL.line_num line_num,
       CDL.line_type line_type,
       decode(sign(NVL(CDL.gl_date,to_date('12/31/4000','MM/DD/YYYY'))-G_MRC_LED),
		  -1,
                 CDL.transfer_status_code,'P') transfer_status_code,
       Get_Converted_Amount(CDL.Denom_currency_code,CDL.Acct_Rate_Type,
			    EI.expenditure_item_date,
                            CDL.Denom_Raw_Cost, CDL.Acct_Raw_Cost,'N') Amount,
       CDL.quantity quantity,
       decode(sign(NVL(CDL.gl_date,to_date('12/31/4000','MM/DD/YYYY'))
                       -G_MRC_LED),-1,CDL.transferred_date,null) transferred_date,
       CDL.transfer_rejection_reason rejection_reason,
       decode(sign(NVL(CDL.gl_date,to_date('12/31/4000','MM/DD/YYYY'))
                                 -G_MRC_LED),-1,
                                 NULL,'CONVERTED') Batch_name,
/*burdening enhancements*/
       --Get_Converted_Amount(CDL.Denom_currency_code,CDL.Acct_Rate_Type,
	--		    EI.expenditure_item_date,
         --                   CDL.Denom_burdened_cost,CDL.Acct_Burdened_Cost,'N')
       Get_Converted_Amount(CDL.Denom_currency_code,CDL.Acct_Rate_Type,
			    EI.expenditure_item_date,
                            CDL.Denom_burdened_cost+NVL(CDL.Denom_burdened_change,0)
                           ,CDL.Acct_Burdened_Cost+NVL(CDL.Acct_Burdened_Change,0),'N')
						   burdened_cost,
       Get_Converted_Amount(CDL.Denom_currency_code,CDL.Acct_Rate_Type,
		  EI.expenditure_item_date,1,1,'Y') exchange_rate,
       decode (G_Use_Curr_rate,'N',G_Fixed_Date,
               'Y', decode(sign(EI.expenditure_item_date - G_MRC_LED),-1 ,
		G_Fixed_Date, EI.expenditure_item_date)
		) conversion_date
FROM   PA_COST_DISTRIBUTION_LINES_ALL CDL,
       PA_EXPENDITURE_ITEMS_ALL       EI
WHERE  CDL.expenditure_item_id = G_EI_Array(k)
AND    CDL.line_type <> 'I' -- burdening enhancements
AND    EI.expenditure_item_id = CDL.expenditure_item_id;


Begin
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_CC_CDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CC_CDL';
   j := 1;

Exception
WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';
END Insert_CC_CDL;
------------------------------------------------------------------------------
PROCEDURE	Update_CC_CDL
IS
v_Old_Stack VARCHAR2(650);
BEGIN
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_CC_CDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_CC_CDL ';
   /** This part is not needed because both original transactions
       and reversed transactions use either expenditure item date
       or G_Fixed_Date for conversion so absolute values of both
       converted amounts should be same **/
END Update_CC_CDL;
-------------------------------------------------------------------------------
PROCEDURE insert_CC_exp_items(	x_Project_ID	IN	Number,
				x_Rep_SOB_ID	IN	Number)
IS
l_raw_cost                      PA_PLSQL_DATATYPES.NumTabtyp;
l_Quantity                      PA_PLSQL_DATATYPES.NumTabTyp;
l_burdened_cost                 PA_PLSQL_DATATYPES.NumTabtyp;
l_raw_revenue                   PA_PLSQL_DATATYPES.NumTabTyp;
l_accrued_revenue               PA_PLSQL_DATATYPES.NumTabTyp;
l_adjusted_revenue              PA_PLSQL_DATATYPES.NumTabTyp;
l_forecast_revenue              PA_PLSQL_DATATYPES.NumTabTyp;
l_bill_amount                   PA_PLSQL_DATATYPES.NumTabTyp;
l_net_zero_adjustment_flag      PA_PLSQL_DATATYPES.Char1TabTyp;
l_transferred_from_exp_item_id  PA_PLSQL_DATATYPES.IdTabTyp;
l_transfer_price                PA_PLSQL_DATATYPES.NumTabtyp;
l_cost_exchange_rate            PA_PLSQL_DATATYPES.NumTabTyp;
l_rev_exchange_rate            PA_PLSQL_DATATYPES.NumTabTyp;
l_cost_conversion_date          PA_PLSQL_DATATYPES.DateTabTyp;
l_cost_rate_type                PA_PLSQL_DATATYPES.Char30TabTyp;
l_raw_cost_rate                 PA_PLSQL_DATATYPES.NumTabtyp;
l_burdened_cost_rate            PA_PLSQL_DATATYPES.NumTabtyp;
l_bill_rate                     PA_PLSQL_DATATYPES.NumTabtyp;
l_accrual_rate                  PA_PLSQL_DATATYPES.NumTabtyp;
l_adjusted_rate                 PA_PLSQL_DATATYPES.NumTabtyp;
l_tp_exchange_rate              PA_PLSQL_DATATYPES.NumTabtyp;
l_tp_exchange_date              PA_PLSQL_DATATYPES.DateTabTyp;
l_tp_rate_type                  PA_PLSQL_DATATYPES.Char30TabTyp;

v_Old_Stack               VARCHAR2(650);
k                         Integer;

Cursor C_exp_items IS
	Select expenditure_item_id,
	       Denom_raw_cost,
	       quantity,
	       Denom_burdened_cost,
	       raw_revenue,
	       accrued_revenue,
	       adjusted_revenue,
	       forecast_revenue,
		bill_amount,
		net_zero_adjustment_flag,
		transferred_from_exp_item_id,
		denom_transfer_price,
		cc_cross_charge_code,
		project_exchange_rate,
		recvr_org_id

	From	PA_Expenditure_Items_ALL
        Where   expenditure_item_id = G_EI_Array(k);

Begin
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_cc_exp_items';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CC_exp_items ';
   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log(G_Err_Stage);
   END IF;

EXCEPTION

   WHEN DUP_VAL_ON_INDEX THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'PA_MRC_INS_DUP';
	Write_Log ('Exception in Insert_CC_exp_items['||SQLCODE||SQLERRM||']');

   WHEN OTHERS THEN
      G_Err_Code := -1;
      G_Err_Stage  := 'Exception in Insert_CC_exp_items['||SQLCODE||SQLERRM||']';
        Write_Log ('Exception in Insert_CC_exp_items['||SQLCODE||SQLERRM||']');


END Insert_CC_exp_items;
-------------------------------------------------------------------------------
PROCEDURE update_cc_exp_items (	x_Project_ID 	IN	Number,
				x_Rep_SOB_ID	IN	Number)
IS

prev_orig_ei Number := 0;
split_flag Varchar2(1) := 'N';
split_amt Number := 0;
split_raw_cost Number := 0;
k integer;
split_burden_cost Number := 0;

v_Old_Stack VARCHAR2(650);

Begin
   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Update_cc_exp_items';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Update_cc_exp_items ';
END Update_cc_exp_items ;
-------------------------------------------------------------------------------
PROCEDURE           Insert_CC_CCDL
IS
	l_rep_rsob_id                 PA_PLSQL_DATATYPES.IDTabTyp;
	l_org_id                      PA_PLSQL_DATATYPES.IDTabTyp;
	l_rcurrency_code              PA_PLSQL_DATATYPES.Char15TabTyp;
	l_cc_dist_line_id             PA_PLSQL_DATATYPES.IDTabTyp;
	l_expenditure_item_id         PA_PLSQL_DATATYPES.IDTabTyp;
	l_line_num                    PA_PLSQL_DATATYPES.IDTabTyp;
	l_cdl_line_num                PA_PLSQL_DATATYPES.NumTabTyp;
	l_acct_tp_rate_type           PA_PLSQL_DATATYPES.Char30TabTyp;
	l_prvdr_cost_reclass_code     PA_PLSQL_DATATYPES.Char240TabTyp;
	l_expenditure_item_date       PA_PLSQL_DATATYPES.DateTabTyp;
	l_acct_tp_exchange_rate       PA_PLSQL_DATATYPES.NumTabTyp;
	l_denom_transfer_price        PA_PLSQL_DATATYPES.NumTabTyp;
        l_denom_currency_code         PA_PLSQL_DATATYPES.Char15TabTyp;
	l_dist_line_id_reversed       PA_PLSQL_DATATYPES.IDTabTyp;
	l_line_type                   PA_PLSQL_DATATYPES.Char2TabTyp;
	v_old_stack                   Varchar2(650);
	i                             Integer;
	l_use_debug_flag              Boolean;
	k                             Integer;



BEGIN

   v_Old_Stack := G_Err_Stack;
   G_Err_Stack := G_Err_Stack || '->Insert_CC_CCDL';
   G_Err_Code := 0;
   G_Err_Stage:= 'Inside Insert_CC_CCDL ';
   IF G_Use_Debug_Flag = 'Y' THEN
      Write_Log (G_Err_Stage);
   END IF;

   i := 1;


END Insert_CC_CCDL;
------------------------------------------------------------------------
Function Get_Rate_Type (x_rate_type        IN       Varchar2,
                        x_conversion_date  IN       Date)

return Varchar2
IS

v_rate_type VARCHAR2(30);

BEGIN

   IF x_rate_type = 'USER' THEN
      v_rate_type := x_rate_type;
   ELSE
      IF G_Use_Curr_Rate = 'N' THEN
             v_rate_type := G_Fixed_Type;
      ELSE
             IF (sign(NVL(x_conversion_date,to_date('12/31/4000',
                                                     'MM/DD/YYYY'))
              - G_MRC_LED )) = -1 THEN
              /** Past transactions **/
                v_rate_type := G_Fixed_Type;
         ELSE
              /** Future Transactions **/
          v_rate_type := G_Daily_Type;
         END IF;
      END IF;
   END IF;
   return v_rate_type;
END Get_Rate_Type;
------------------------------------------------------------------------
Function Get_Rate_Date (x_conversion_date  IN       Date)
return Date
IS
v_rate_date Date;
BEGIN
      IF G_Use_Curr_Rate = 'N' THEN
            v_rate_date := G_Fixed_Date;
      ELSE
            IF (sign(NVL(x_conversion_date,to_date('12/31/4000',
                                                     'MM/DD/YYYY'))
              - G_MRC_LED )) = -1 THEN
              /** Past transactions **/
               v_rate_date := G_Fixed_Date;
        ELSE
              /** Future Transactions **/
              v_rate_date := x_conversion_date;
            END IF;
      END IF;
    return v_rate_date;
END Get_Rate_Date;
------------------------------------------------------------------------

END PA_MC_UPG;

/
