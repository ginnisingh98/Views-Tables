--------------------------------------------------------
--  DDL for Package Body GMS_REPORT_SF270
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_REPORT_SF270" AS
--$Header: gmsgrrab.pls 120.1 2006/02/14 01:49:41 lveerubh noship $

Procedure INSERT_GMS_270_HISTORY(X_Award_Id IN NUMBER
				,X_Document_Number IN VARCHAR2
				,X_Total_Program_Outlays IN NUMBER
	 			,X_Version IN NUMBER
				,X_Status_Code IN VARCHAR2
				,X_Report_Start_Date IN DATE
				,X_Report_End_Date   IN DATE
				--,X_Payee_Address_Id IN NUMBER Bug 2537999
				,X_Err_Code OUT NOCOPY VARCHAR2
				,X_Err_Stage OUT NOCOPY VARCHAR2) IS

X_Cum_Program_Income NUMBER := 0;
X_Net_Cash_Outlays   NUMBER := 0;
X_Non_Fed_Share      NUMBER := 0;

Begin

 Begin
 INSERT INTO GMS_270_HISTORY
 (
  AWARD_ID
 ,VERSION
 ,STATUS_CODE
 ,RUN_DATE
 ,DOCUMENT_NUMBER
 ,ACCOUNTING_BASIS
 ,PAYMENT_TYPE
 ,PAYMENT_SCHEDULE
 ,REPORT_START_DATE
 ,REPORT_END_DATE
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,LAST_UPDATE_LOGIN
 ,TOT_PRG_OUTLAY
 ,CUM_PRG_INCOME
 ,NET_CASH_OUTLAY
 ,NON_FED_SHARE
-- ,PAYEE_ADDRESS_ID
 ,REMARKS
   )
values
(
 X_Award_Id
,X_Version
,X_Status_Code
,SYSDATE
,X_Document_Number
,'A'
,'A'
,'F'
,X_Report_Start_Date
,X_Report_End_Date
,SYSDATE
,fnd_global.user_id
,SYSDATE
,fnd_global.user_id
,fnd_global.login_id
,X_Total_Program_Outlays
,X_Cum_Program_Income
,X_Net_Cash_Outlays
,X_Non_Fed_Share
--,X_Payee_Address_Id
,NULL
 );
   commit;
      X_Err_Code := 'S';

        EXCEPTION
             WHEN OTHERS THEN
               X_Err_Code  := 'U';
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_REPORT_270: INSERT_GMS_270_HISTORY');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                     RAISE FND_API.G_EXC_ERROR;
 End;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    RETURN;

End INSERT_GMS_270_HISTORY;

Procedure Populate_270_History(X_Award_Id IN NUMBER,
                               X_Report_Start_Date IN DATE,
                               X_Report_End_Date   IN DATE,
			       RETCODE OUT NOCOPY VARCHAR2,
			       ERRBUF  OUT NOCOPY VARCHAR2) IS

-- Bug Fix 4005830
-- PJ.M:B8:P13:OTH:PERF:INDEX FULL SCAN, NON-MERGABLE VIEW AND HASH JOIN EXISTS
--
cursor c_sum_amount is
Select SUM(nvl(c.amount,0))
  from pa_expenditure_items_all ei,
       pa_cost_distribution_lines_all c,
       gms_award_distributions g
where c.gl_date  between X_Report_Start_Date and  X_Report_End_Date
  and c.expenditure_item_id       = ei.expenditure_item_id
  and g.award_id                  = X_Award_Id
  and g.document_type             = 'EXP'
  and g.adl_line_num              = 1
  and g.adl_status                = 'A'
  and g.expenditure_item_id       = c.expenditure_item_id
  and c.line_type                 = 'R'
  and ei.system_linkage_function <> 'BTC'  -- Put the correct code for system linkage function
  and ei.project_id               in ( select gbv.project_id
                                           from gms_budget_versions gbv
					  where gbv.budget_type_code     = 'AC'
					    and gbv.budget_status_code   in ('S','W' )
					    and gbv.award_id             = X_Award_Id )
  ;

-- Bug Fix 4005830
-- PJ.M:B8:P13:OTH:PERF:INDEX FULL SCAN, NON-MERGABLE VIEW AND HASH JOIN EXISTS
--
/* --Bug Fix 4940833 :SQL repository Issue
cursor c_sum_burden is
Select sum(nvl(bv.burden_cost,0))
  from pa_expenditure_items_all       ei,
       pa_cost_distribution_lines_all c,
       gms_cdl_burden_detail_v        bv
where c.gl_date  between X_Report_Start_Date and  X_Report_End_Date
  and c.expenditure_item_id       = ei.expenditure_item_id
  and bv.award_id                 = X_Award_Id
  and c.line_type                 = 'R'
  and ei.system_linkage_function <> 'BTC'  -- Put the correct code for system linkage function
  and bv.expenditure_item_id      = c.expenditure_item_id
  and bv.line_num                 = c.line_num
  and bv.project_id               = ei.project_id
  and ei.project_id               in  ( select gbv.project_id
                                           from gms_budget_versions gbv
                                          where gbv.budget_type_code     = 'AC'
                                            and gbv.budget_status_code   in ('S','W' )
                                            and gbv.award_id             = X_Award_Id )
  and bv.project_id               in  ( select gbv.project_id
                                           from gms_budget_versions gbv
                                          where gbv.budget_type_code     = 'AC'
                                            and gbv.budget_status_code   in ('S','W' )
                                            and gbv.award_id             = X_Award_Id ) ;
*/
cursor c_sum_burden is
Select sum(nvl(bv.burden_cost,0))
FROM    gms_cdl_burden_detail_v        bv,
	gms_budget_versions gbv
WHERE bv.gl_date  between X_Report_Start_Date and  X_Report_End_Date
  and bv.award_id                 = X_Award_Id
  and bv.line_type                 = 'R'
  and bv.system_linkage_function <> 'BTC'  -- Put the correct code for system linkage function
  and gbv.budget_type_code     = 'AC'
  and gbv.budget_status_code   in ('S','W' )
  and gbv.award_id             = X_Award_Id
  and bv.project_id              =  gbv.project_id;
  --End of Bug fix.4940833

/* Start of changes for BUG : 2357578 */
-- Cursor to fetch Report periods
CURSOR report_period_date_cur IS
SELECT GREATEST(X_Report_Start_Date, start_date_active),
       LEAST(X_Report_End_Date, end_date_active)
FROM gms_awards
WHERE award_id = X_Award_Id;

L_Report_Start_Date gms_270_history.report_start_date%type;
L_Report_End_Date gms_270_history.report_end_date%type;

/* End of changes for BUG : 2357578 */

X_Expenditure_Item_Id  NUMBER := NULL;
X_Line_Num	       NUMBER := NULL;
X_Transfer_Status_Code VARCHAR2(1) := NULL;
X_Raw_Cost         NUMBER(22,5) := 0;
X_Sum_Burden_Cost         NUMBER(22,5) := 0;
X_Document_Number VARCHAR2(30);
X_Status_Code VARCHAR2(1) := NULL;
X_Total_Program_Outlays NUMBER(22,5) := 0;
X_Payee_Address_Id NUMBER := NULL;
X_Version NUMBER;

X_Err_Code VARCHAR2(1);
X_Err_Buff VARCHAR2(2000);
--
-- Bug Fix 4005830
-- PJ.M:B8:P13:OTH:PERF:INDEX FULL SCAN, NON-MERGABLE VIEW AND HASH JOIN EXISTS
--
l_sum_amount       NUMBER ;
l_sum_burden       NUMBER ;

Begin

/* To set project_id NULL to be able to use Suresh's view to derive Burden Components and Burden Cost */
     -- GMS_BURDEN_COSTING.SET_CURRENT_PROJECT_ID(NULL);
     --  The above line has been commented out NOCOPY for bug 2442827

 /* Get Funding Source Award Number as the default document Number */
 Begin
  select
  funding_source_award_number
  into
  X_Document_Number
  from
  GMS_AWARDS
  where
  award_id = X_Award_Id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
 End;

/* This section commented because of
   Bug 2537999 (SF270, A 'ENTERED' PAYEE ADDREESS (FIELD 10) DOES NOT GET SAVED OR PRINTED)
   Get the PAYEE Address Id from AR
*/

 --
 -- Bug Fix 4005830
 -- PJ.M:B8:P13:OTH:PERF:INDEX FULL SCAN, NON-MERGABLE VIEW AND HASH JOIN EXISTS
 --
 l_sum_amount := 0 ;
 l_sum_burden := 0 ;

 open c_sum_amount ;
 fetch c_sum_amount into l_sum_amount ;
 close c_sum_amount ;

 open c_sum_burden ;
 fetch c_sum_burden into l_sum_burden ;
 close c_sum_burden ;

--Added for Bug 2357578
 OPEN  report_period_date_cur;
          FETCH report_period_date_cur INTO L_Report_Start_Date,
          L_Report_End_Date;
          CLOSE report_period_date_cur;

 X_Total_Program_Outlays  := NVL(X_Total_Program_Outlays,0) + NVL(l_sum_amount,0) + NVL(l_sum_burden,0) ;

 /*******************
 Begin
 open Get_Cost_Distribution_Lines;
 LOOP
    Fetch Get_Cost_Distribution_Lines
    into
     X_Expenditure_Item_Id
    ,X_Line_Num
    --,X_Transfer_Status_Code -- Bug 2360732
    ,X_Raw_Cost
    ,X_Sum_Burden_Cost;
         EXIT WHEN Get_Cost_Distribution_Lines%NOTFOUND;

             X_Total_Program_Outlays := (X_Raw_Cost + X_Sum_Burden_Cost) + X_Total_Program_Outlays ;

   End LOOP;
 End;
 **********************/

 --
 -- Bug Fix 4005830
 -- PJ.M:B8:P13:OTH:PERF:INDEX FULL SCAN, NON-MERGABLE VIEW AND HASH JOIN EXISTS
 -- end of the fix.
 Begin
       /* Getting the latest version to be inserted */
       select (nvl(max(version),0) +1)
       into
       X_Version
       from gms_270_history
       where award_id = X_Award_Id
       and status_code = 'O';
 End;

/* Inserting TWO Rows in GMS_270_HISTORY Table, one with a status of 'O' and one with a status of 'D' */
 Begin
   X_Status_Code := 'O';
  INSERT_GMS_270_HISTORY(X_Award_Id
			,X_Document_Number
			,X_Total_Program_Outlays
			,X_Version
			,X_Status_Code
			,L_Report_Start_Date --Bug 2357578
			,L_Report_End_Date --Bug 2357578
		      --  ,X_Payee_Address_Id
			,X_Err_Code
			,X_Err_Buff);
           If X_Err_Code <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
           End If;

  X_Status_Code := 'D';
   INSERT_GMS_270_HISTORY(X_Award_Id
                        ,X_Document_Number
                        ,X_Total_Program_Outlays
                        ,X_Version
                        ,X_Status_Code
                        ,L_Report_Start_Date --Bug 2357578
                        ,L_Report_End_Date --Bug 2357578
		--	,X_Payee_Address_Id
                        ,X_Err_Code
                        ,X_Err_Buff);

           If X_Err_Code <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
           End If;


 End;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   RETCODE := X_Err_Code;
   ERRBUF  := X_Err_Buff;

End Populate_270_History;

End GMS_REPORT_SF270;


/
