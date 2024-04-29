--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_PARALLEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_PARALLEL_PKG" AS
/*  $Header: glalpllb.pls 120.9 2004/02/28 02:28:29 djogg ship $  */


PROCEDURE diagn_msg (message_string   IN  VARCHAR2) IS

BEGIN
  IF diagn_msg_flag THEN
     --dbms_output.put_line (message_string);
    null;
  END IF;
EXCEPTION
WHEN OTHERS THEN
    NULL;
END diagn_msg;



Procedure Start_Auto_Allocation_Parallel(p_request_Id       IN NUMBER) IS
 l_allocation_set_id           Number ;
 l_allocation_set_name         Varchar2(40);
 l_allocation_set_type_code    Varchar2(1);
 l_ledger_id                   Number;
 l_access_set_id               Number;
 l_description                 Varchar2(240);
 l_period_name                 Varchar2(15);
 l_budget_version_id           Number;
 l_ledger_currency             Varchar2(15);
 l_balancing_segment_value     Varchar2(25);
 l_journal_effective_date      Date;
 l_calculation_effective_date  Date;
 l_usage_code                  Varchar2(1);
 l_gl_period_name              Varchar2(15);
 l_pa_period_name              Varchar2(15);
 l_expenditure_item_date       Date;
 l_last_updated_by	       Number;
 l_created_by                  Number;
 l_last_update_login           Number;
 l_batch_id                    Number;
 l_batch_type_code             Varchar2(1);
 l_allocation_method_code      Varchar2(1);
 l_owner                       Varchar2(50);
 l_batch_name                  Varchar2(60);
 l_step_number                 Number;
 l_enable_avg_balances_flag    Varchar2(1);
 l_program_name_code           Varchar2(30);
 req_id                        Number;
 t_allocation_method_code      Varchar2(1);
 l_usage_num                   Number;
err_num         Number;
err_msg         Varchar2(100);

 Cursor c_set_name IS
    Select
      ALLOCATION_SET_NAME
     ,ALLOCATION_SET_ID
     ,ALLOCATION_SET_TYPE_CODE
     ,ACCESS_SET_ID
     ,LEDGER_ID
     ,LEDGER_CURRENCY
     ,DESCRIPTION
     ,PERIOD_NAME
     ,BUDGET_VERSION_ID
     ,BALANCING_SEGMENT_VALUE
     ,JOURNAL_EFFECTIVE_DATE
     ,CALCULATION_EFFECTIVE_DATE
     ,USAGE_CODE
     ,GL_PERIOD_NAME
     ,PA_PERIOD_NAME
     ,EXPENDITURE_ITEM_DATE
     ,LAST_UPDATED_BY
     ,CREATED_BY
     ,LAST_UPDATE_LOGIN
    From GL_AUTO_ALLOC_SET_HISTORY
    Where REQUEST_ID = p_request_Id;

 Cursor c_batches IS
      Select
           STEP_NUMBER
         ,  BATCH_ID
         ,  BATCH_TYPE_CODE
         ,  ALLOCATION_METHOD_CODE
         ,  OWNER
   From   GL_AUTO_ALLOC_BATCH_HISTORY
   Where REQUEST_ID  = p_request_Id ;

Begin
   diagn_msg('Executing Start_Auto_Allocation_Parallel for request_id '||
                                  to_char(p_request_Id));
   Open c_set_name;
   Fetch c_set_name into
     l_allocation_set_name
    ,l_allocation_set_id
    ,l_allocation_set_type_code
    ,l_access_set_id
    ,l_ledger_id
    ,l_ledger_currency
    ,l_description
    ,l_period_name
    ,l_budget_version_id
    ,l_balancing_segment_value
    ,l_journal_effective_date
    ,l_calculation_effective_date
    ,l_usage_code
    ,l_gl_period_name
    ,l_pa_period_name
    ,l_expenditure_item_date
    ,l_last_updated_by
    ,l_created_by
    ,l_last_update_login;

   Close c_set_name;

    If l_allocation_set_id IS NULL Then
      diagn_msg('Fatal error:No Allocation set for '||to_char(p_request_Id));
      Return;
    End If;

    Open c_batches;
    Loop
     Fetch c_batches into
      l_step_number
     ,l_batch_id
     ,l_batch_type_code
     ,l_allocation_method_code
     ,l_owner;

      Exit When c_batches%NOTFOUND;

      l_batch_name := gl_auto_alloc_vw_pkg.Get_Batch_Name(
                                    BATCH_TYPE_CODE => l_batch_type_code
                                   ,BATCH_ID        => l_batch_id);

      -- Fix for bug1863250
      If l_allocation_method_code = 'I' Then
           t_allocation_method_code := 'Y' ;
      Else
           t_allocation_method_code := 'N';
      End If;

      If l_usage_code = 'Y' Then
           l_usage_num := 1;
      Else
           l_usage_num := 0;
      End If;

      If l_batch_type_code = 'R' Then
             --recurring Batch
             l_program_name_code := 'GLPRJE';
             diagn_msg('Line Number:'||to_char(l_STEP_NUMBER)||
                       ' Submitting Recurring Journal');
               req_id := fnd_request.submit_request(
                  'SQLGL',
                  'GLPRJE',
                  '',
                  '',
                  FALSE,
                  to_char(l_batch_id),
                  l_PERIOD_NAME,
                  to_char(l_access_set_id),
                  to_char(l_budget_version_id),
                  to_char(l_calculation_effective_date, 'YYYY/MM/DD'),
                  to_char(l_journal_effective_date, 'YYYY/MM/DD'),
                  nvl(l_usage_code, 'N'),
                  chr(0), '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '');

         Elsif l_BATCH_TYPE_CODE in ('A','B','E') Then
               -- if batch is massallocation, massbudget or massencumbrances
               l_program_name_code := 'GLAMAS';
               diagn_msg('Line Number:'||to_char(l_STEP_NUMBER)||
                      ' Submitting MassAllocations_'||l_BATCH_TYPE_CODE);
               req_id :=  FND_REQUEST.SUBMIT_REQUEST(
                     'SQLGL',
                     'GLAMAS',
                     '',
                     '',
                     FALSE,
                     'C',
                     to_char(l_access_set_id),
                     nvl(t_allocation_method_code ,'N'),
                     to_char(l_usage_num),
                     to_char(l_ledger_id),
                     l_ledger_currency,
                     l_balancing_segment_value,
                     to_char(l_batch_id),
                     l_period_name  ,
                     to_char(l_journal_effective_date,'YYYY/MM/DD HH24:MI:SS'),
                     to_char(l_calculation_effective_date,'YYYY/MM/DD HH24:MI:SS'),
                     chr(0),
                      '','','','','','','','','','',
                      '','','','','','','','','','','','','','','',
                      '','','','','','','','','','','','','','','',
                      '','','','','','','','','','','','','','','',
                      '','','','','','','','','','','','','','','',
                      '','','','','','','','','','','','','','','',
                      '','','');

         Elsif l_BATCH_TYPE_CODE = 'P' Then
            diagn_msg('Line Number:'||to_char(l_STEP_NUMBER)||
                    ' Submitting Project Allocations_'||l_BATCH_TYPE_CODE);

             l_program_name_code := 'PAXALGAT';

             req_id := GL_PA_AUTOALLOC_PKG.Submit_Alloc_Request(
                               l_batch_id
                              ,l_expenditure_item_date
                              ,l_pa_period_name
                              ,l_gl_period_name );

         End If ;
         If (req_id = 0) Then
              -- submission failed
             diagn_msg('Request submission failed for batch '||l_batch_name);
         Else
            -- insert record into GL_AUTO_ALLOC_BAT_HIST_DET for view status form
              diagn_msg('Request_Id:'||to_char(req_id)||
                       'Inserting into GL_AUTO_ALLOC_BAT_HIST_DET');
              Insert Into GL_AUTO_ALLOC_BAT_HIST_DET (
                     REQUEST_ID
                    ,PARENT_REQUEST_ID
                    ,STEP_NUMBER
                    ,PROGRAM_NAME_CODE
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,STATUS_CODE
                    ,RUN_MODE )
                Values
                   (  req_id
                     ,p_request_Id
                     ,l_step_number
                     ,l_program_name_code
                     ,sysdate
                     ,l_last_updated_by
                     ,l_last_update_login
                     ,sysdate
                     ,l_created_by
                     ,NULL
                     ,'P'
                     );
         End If;
         Commit;
         End Loop;
   diagn_msg('Completed parallel submission successfully');

EXCEPTION
        WHEN OTHERS THEN
                err_num := SQLCODE;
                err_msg := SUBSTR(SQLERRM, 1, 100);
--                dbms_output.put_line('Error: ' || err_num);
--                dbms_output.put_line(err_msg);
End Start_Auto_Allocation_Parallel;


End GL_AUTO_ALLOC_PARALLEL_PKG;

/
