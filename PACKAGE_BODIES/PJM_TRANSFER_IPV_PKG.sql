--------------------------------------------------------
--  DDL for Package Body PJM_TRANSFER_IPV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TRANSFER_IPV_PKG" AS
/* $Header: PJMTIPVB.pls 115.52 2004/08/18 04:30:08 yliou ship $ */

Function batch_name
RETURN VARCHAR2 IS
l_Batch_Name    PA_Transaction_Interface_All.Batch_Name%TYPE;
l_Batch_ID      NUMBER;

Begin
  --
  -- Batch Name can only be 10 characters long so we take the last
  -- 7 digits of the request id instead of the full id
  --
  l_Batch_ID := mod(fnd_global.conc_request_id , 10000000);
  if (l_Batch_ID < 0) then
    l_Batch_ID := 0;
  end if;

  l_Batch_Name := 'PJM' ||
                  lpad(to_char(l_Batch_ID), 7 ,'0');

  return ( l_Batch_Name );

End;


Function get_ipv_expenditure_type
( X_Project_Id  IN NUMBER
, X_Org_Id      IN NUMBER
) RETURN VARCHAR2 IS
l_ipv_expenditure_type  VARCHAR2(30);

Begin

   select nvl(ppp.ipv_expenditure_type, pop.ipv_expenditure_type)
   into   l_ipv_expenditure_type
   from   pjm_project_parameters ppp
   ,      pjm_org_parameters     pop
   where  pop.organization_id = X_Org_Id
   and    ppp.organization_id (+) = pop.organization_id
   and    ppp.project_id (+) = X_Project_Id;

   return (l_ipv_expenditure_type);

End;

Function get_erv_expenditure_type
( X_Project_Id  IN NUMBER
, X_Org_Id      IN NUMBER
) RETURN VARCHAR2 IS
l_erv_expenditure_type  VARCHAR2(30);

Begin

   select nvl(ppp.erv_expenditure_type, pop.erv_expenditure_type)
   into   l_erv_expenditure_type
   from   pjm_project_parameters ppp
   ,      pjm_org_parameters     pop
   where  pop.organization_id = X_Org_Id
   and    ppp.organization_id (+) = pop.organization_id
   and    ppp.project_id (+) = X_Project_Id;

   return (l_erv_expenditure_type);

End;


FUNCTION Assign_Task
( X_PO_Distribution_Id    IN   NUMBER
, X_Destination_Type_Code IN   VARCHAR2
, X_Project_Id            IN   NUMBER
) RETURN VARCHAR2 IS

CURSOR c_inv IS
  SELECT PJM_TASK_AUTO_ASSIGN.Inv_Task_WNPS
         ( POD.Destination_Organization_Id
         , X_Project_Id
         , POL.Item_Id
         , POD.Po_Header_Id
         , Null
         , Null )
  FROM   PO_Distributions POD
  ,      PO_Lines POL
  WHERE  POD.PO_Distribution_Id = X_PO_Distribution_Id
  AND    POL.PO_Line_Id = POD.PO_Line_Id;

CURSOR c_wip IS
  SELECT PJM_TASK_AUTO_ASSIGN.WIP_Task_WNPS
         ( wo.organization_id
         , X_Project_Id
         , wo.standard_operation_id
         , wdj.wip_entity_id
         , wdj.primary_item_id
         , wo.department_id )
  FROM   PO_Distributions POD
  ,      WIP_Discrete_Jobs WDJ
  ,      WIP_Operations WO
  WHERE  POD.PO_Distribution_Id = X_PO_Distribution_Id
  AND    WO.WIP_Entity_Id = POD.WIP_Entity_Id
  AND    WO.Operation_Seq_Num = POD.WIP_Operation_Seq_Num
  AND    WDJ.WIP_Entity_Id = WO.Wip_Entity_Id;

L_Task_ID  NUMBER;

BEGIN

  L_Task_ID := NULL;

  IF ( X_Destination_Type_Code = 'INVENTORY' ) THEN

    OPEN c_inv;
    FETCH c_inv INTO L_Task_ID;
    CLOSE c_inv;

  ELSIF ( X_Destination_Type_Code = 'SHOP FLOOR' ) THEN

    OPEN c_wip;
    FETCH c_wip INTO L_Task_ID;
    CLOSE c_wip;

  END IF;

  RETURN ( L_Task_ID );

END Assign_Task;


PROCEDURE Timestamp IS
Current_Time   DATE;
BEGIN
  Current_Time := sysdate;
  fnd_message_cache.set_name('FND' , 'UTIL-CURRENT TIME');
  fnd_message_cache.set_token('DATE' , fnd_date.date_to_displaydate(Current_Time));
  fnd_message_cache.set_token('TIME' , to_char(Current_Time , 'HH24:MI:SS'));
  PJM_CONC.put_line(fnd_message_cache.get);
  PJM_CONC.new_line(1);
EXCEPTION
WHEN OTHERS THEN
  NULL;
END Timestamp;


---------------------------------------------------------------------------
-- PUBLIC PROCEDURE
--   Transfer_IPV_to_PA
--
-- DESCRIPTION
--   This procedure will get the expenditure and costing data from Invoice
--   Distributions which has IPV amount and the destination type is
--   INVENTORY. And then push these data to PA_TRANSACTION_INTERFACES.
--
-- PARAMETERS
--   X_Project_Id                IN
--   X_Start_Date                IN
--   X_End_Date                  IN
--   ERRBUF                      OUT
--   RETCODE                     OUT
--
---------------------------------------------------------------------------

PROCEDURE Transfer_IPV_to_PA
( ERRBUF              OUT NOCOPY VARCHAR2
, RETCODE             OUT NOCOPY NUMBER
, X_Project_Id        IN         NUMBER
, X_Start_Date        IN         VARCHAR2
, X_End_Date          IN         VARCHAR2
, X_Submit_Trx_Import IN         VARCHAR2
, X_Trx_Status_Code   IN         VARCHAR2
) IS

  l_proj_status         VARCHAR2(30);
  l_billable_flag       VARCHAR2(1);
  l_request_id          NUMBER;
  l_user_id             NUMBER;
  l_IPV_Exp_Type        VARCHAR2(30);
  l_ERV_Exp_Type        VARCHAR2(30);
  l_curr_invoice_id     NUMBER;
  l_first_invoice       BOOLEAN;
  l_imp_req_id          NUMBER;
  l_base_currency_code  AP_System_parameters.base_currency_code%TYPE;

--  l_msg_application     VARCHAR2(30) := 'PA';
--  l_msg_type            VARCHAR2(30);
--  l_msg_token1          VARCHAR2(30);
--  l_msg_token2          VARCHAR2(30);
--  l_msg_token3          VARCHAR2(30);
--  l_msg_count           NUMBER;

  l_IPV_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_ERV_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Batch_Name          PA_Transaction_Interface_All.Batch_Name%TYPE;
  l_Receipt_Num         RCV_Shipment_Headers.Receipt_Num%TYPE;
  l_User_Conv_Type      GL_Daily_Conversion_Types.User_Conversion_Type%TYPE;
  l_Start_Date          DATE;
  l_End_Date            DATE;
  l_Task_Id             NUMBER;

  l_progress            NUMBER;
  l_blue_print_enabled_flag  VARCHAR2(1);
  l_autoaccounting_flag      VARCHAR2(1);
  l_transaction_source       VARCHAR2(30);
  l_trx_status_code              VARCHAR2(30);

  CURSOR Inv_Curs IS
    SELECT
            INV.Invoice_id                      Invoice_Id
    ,       DIST.Distribution_Line_Number       Distribution_Line_Number
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                         Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       NVL( DIST.description
               , POL.Item_Description)          Expenditure_Comment
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Rate_Var_Code_Combination_Id   Rate_Var_Code_Combination_Id
    ,       DIST.Price_Var_Code_Combination_Id  Price_Var_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Invoice_Price_Variance         Invoice_Price_Variance
    ,       DIST.Base_Invoice_Price_Variance    Base_Invoice_Price_Variance
    ,       DIST.Exchange_Rate_Variance         Exchange_Rate_Variance
    ,       POD.PO_Distribution_Id              PO_Distribution_Id
    ,       POD.Destination_Type_Code           Destination_Type_Code
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    FROM
            AP_Invoices INV,
            AP_Invoice_Distributions DIST,
            PO_Distributions POD,
            PO_Lines POL,
            PA_Projects_ALL PAP,
            PJM_Org_Parameters POP
    WHERE   DIST.Pa_Addition_Flag  IN ( 'N','S','A','B','C','D','E','I',
                                 'J','K','M','P','Q','V','X','W'  )
    AND     DIST.Posted_Flag = 'Y'
    AND DIST.LINE_TYPE_LOOKUP_CODE = 'ITEM'
    AND INV.INVOICE_TYPE_LOOKUP_CODE <> 'EXPENSE REPORT'
    AND     DIST.Invoice_Id = INV.Invoice_Id
    AND  (( l_Start_Date is null and l_End_Date is null)
       OR ( l_Start_Date is not null and l_End_Date is not null
            and DIST.Accounting_Date between l_Start_Date and l_End_Date)
       OR ( l_Start_Date is not null and l_End_Date is null
            and DIST.Accounting_Date >= l_Start_Date )
       OR ( l_Start_Date is null and l_End_Date is not null
            and DIST.Accounting_Date <= l_End_Date ))
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     POD.Destination_Type_Code in ( 'INVENTORY' , 'SHOP FLOOR' )
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = NVL(POD.Project_Id , POP.Common_Project_Id)
    AND     PAP.Project_Id = NVL(X_Project_Id, PAP.Project_Id)
    AND     DIST.Po_Distribution_Id = POD.Po_Distribution_Id
    AND     POD.Po_Line_Id = POL.Po_Line_Id
    ORDER BY 9,1,2
    for update;


  InvRec                   Inv_Curs%ROWTYPE;

BEGIN

  l_curr_invoice_id := -1;
  l_first_invoice := TRUE;
  l_progress := 0;
  if (X_trx_status_code is NULL)
  then l_trx_status_code := 'P';
  else l_trx_status_code := X_trx_status_code;
  end if;

  fnd_message.set_name('PJM','CONC-APINV IPV Transfer');
  PJM_CONC.put_line(fnd_message.get || ' ...');
  PJM_CONC.new_line(1);

  PJM_CONC.put_line('[PROJECT_ID]        = ' || X_Project_Id);
  PJM_CONC.put_line('[START_DATE]        = ' || X_Start_Date);
  PJM_CONC.put_line('[END_DATE]          = ' || X_End_Date);
  PJM_CONC.put_line('[SUBMIT_TRX_IMPORT] = ' || X_Submit_Trx_Import);

  l_request_id := fnd_global.conc_request_id;
  l_user_id    := fnd_global.user_id;
  l_Start_Date := fnd_date.canonical_to_date(X_Start_Date);
  l_End_Date   := fnd_date.canonical_to_date(X_End_Date);

  PJM_CONC.put_line('[REQUEST_ID]        = ' || l_request_id);
  PJM_CONC.new_line(1);

  l_IPV_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV IPV');
  l_ERV_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV ERV');

  l_Batch_Name := PJM_Transfer_IPV_Pkg.batch_name;

  PJM_CONC.put_line('Batch_Name = ' || l_batch_name);
  PJM_CONC.new_line(1);

  ----------------------------------------------------------------------
  -- Get Accounting Currency Code
  ----------------------------------------------------------------------

  l_progress := 10;

  select  ap.base_currency_code
  into    l_base_currency_code
  from    gl_sets_of_books gl,
          ap_system_parameters ap
  where   gl.set_of_books_id = ap.set_of_books_id;

  ----------------------------------------------------------------------
  -- Set pa_addition_flag of all eligible invoice distributions
  ----------------------------------------------------------------------

  ----------------------------------------------------------------------
  -- Bug 1876773
  -- Due to potential high cost of flagging eligible invoice
  -- distributions based on PA_ADDITION_FLAG, net zero elimination
  -- logic will be performed after flagging all eligible invoice
  -- distributions.
  --
  -- Bug 2195329
  -- Only flag ITEM invoice lines.  TAX/FREIGHT/MISC may also result
  -- in IPV, causing the processing of such lines in the IPV/ERV
  -- cycle.
  ----------------------------------------------------------------------
  fnd_message.set_name('PJM', 'CONC-APINV Flag Inv Dists');
  PJM_CONC.put_line(fnd_message.get || ' ...');

  l_progress := 20;

--  UPDATE  /*+ index(DIST AP_INVOICE_DISTRIBUTIONS_N14) */
--          AP_Invoice_Distributions DIST
--  SET     DIST.Pa_Addition_Flag = 'S'
--  ,       DIST.Request_Id       = l_request_id
--  ,       DIST.Last_Update_Date = SYSDATE
--  ,       DIST.Last_Updated_By  = l_user_id
--  WHERE   DIST.Posted_Flag = 'Y'
--  AND     DIST.Pa_Addition_Flag in
--            ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
--            , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
--  AND     DIST.Line_Type_Lookup_Code = 'ITEM'
--  AND     exists (
--      select 'X'
--      from   ap_invoices inv
--      where  inv.invoice_id = dist.invoice_id
--      and    inv.invoice_type_lookup_code <> 'EXPENSE REPORT')
--  AND     DIST.Accounting_Date <=
--          NVL(l_Trx_Thru_Date, DIST.Accounting_Date)
--  AND     exists (
--      Select 'X'
--      from   Po_Distributions POD
--      ,      PJM_Org_Parameters POP
--      where  DIST.Po_Distribution_Id = POD.Po_Distribution_ID
--      and    POP.Organization_Id = POD.Destination_Organization_Id
--      and    NVL(POD.Project_Id , POP.Common_Project_Id) =
--             NVL(X_Project_Id , NVL(POD.Project_Id , POP.Common_Project_Id))
--      and    POD.Destination_Type_Code in ( 'INVENTORY' , 'SHOP FLOOR' )
--  );

  ----------------------------------------------------------------------
  -- Eliminate all pairing of reversed invoice distributions
  ----------------------------------------------------------------------

--  fnd_message.set_name('PJM', 'CONC-APINV Elim NetZero');
--  PJM_CONC.put_line(fnd_message.get || ' ...');

  l_progress := 30;

  ----------------------------------------------------------------------
  -- Bug 1876773
  -- Net Zero elimination logic simplified based on similar changes
  -- in PAAPIMP_PKG.
  -- > Removed NVL() from pa_addition_flag
  -- > Removed where condition with project_accounting_context column
  -- > Restructured and simplified subquery
  ----------------------------------------------------------------------
/*  Bug 3495426 has taken care of the reversed transactions.
    Net Zero is no longer needed.

  UPDATE ap_invoice_distributions apd
  SET    apd.pa_addition_flag = 'Z'
  WHERE  apd.pa_addition_flag = 'S'
  AND    apd.request_id       = l_request_id
  AND    0 = (
      SELECT SUM( nvl(apd2.base_amount , apd2.amount) )
      FROM po_distributions pod
      ,    ap_invoice_distributions apd2
      WHERE pod.po_distribution_id  = apd.po_distribution_id
      AND   apd2.po_distribution_id = pod.po_distribution_id
      AND   apd2.pa_addition_flag   = apd.pa_addition_flag
      AND   apd2.request_id         = apd.request_id
      AND   apd2.dist_code_combination_id = apd.dist_code_combination_id
      AND   apd2.invoice_id         = apd.invoice_id
      AND   apd2.accounting_date    = apd.accounting_date
  );
*/

  ----------------------------------------------------------------------
  -- Loop for transfering IPV from Invoice_Distribution to
  -- PA_Transaction_Interfaces
  ----------------------------------------------------------------------

  fnd_message.set_name('PJM','CONC-APINV Start Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');

  Timestamp;

  OPEN Inv_Curs;

  LOOP

     l_progress := 50;

     FETCH Inv_Curs INTO InvRec;
     EXIT WHEN Inv_Curs%NOTFOUND;

     l_progress := 55;

     IF ( InvRec.Task_Id IS NOT NULL ) THEN
       l_Task_Id := InvRec.Task_Id;
     ELSE
       l_Task_Id := Assign_Task( InvRec.PO_Distribution_Id
                               , InvRec.Destination_Type_Code
                               , InvRec.Project_Id );
     END IF;

     PJM_CONC.put_line('   invoice_id ............ '||InvRec.Invoice_Id);
     PJM_CONC.put_line('   line_num .............. '||
                           InvRec.Distribution_Line_Number);
     PJM_CONC.put_line('   project_id ............ '||InvRec.Project_ID);
     PJM_CONC.put_line('   task_id ............... '||l_Task_Id);
     PJM_CONC.put_line('   expenditure_org_id .... '||
                           InvRec.Expenditure_Organization_ID);

     Timestamp;

     ----------------------------------------------------------------------
     -- We commit for each invoice.
     ----------------------------------------------------------------------

     -- if (l_curr_invoice_id <> InvRec.Invoice_Id AND NOT l_first_invoice) then
     --    COMMIT;
     -- end if;

     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ----------------------------------------------------------------------
     -- Check Project Status
     ----------------------------------------------------------------------

     l_progress := 60;

     l_IPV_Exp_Type := Get_IPV_Expenditure_Type
                               ( InvRec.Project_Id
                               , InvRec.Expenditure_Organization_Id );

     l_progress := 70;

     l_ERV_Exp_Type := Get_ERV_Expenditure_Type
                               ( InvRec.Project_Id
                               , InvRec.Expenditure_Organization_Id );

     PJM_CONC.put_line('   ipv_expenditure_type .. '||l_ipv_exp_type);
     PJM_CONC.put_line('   ipv_amount ............ '||
                           InvRec.Invoice_Price_Variance);
     PJM_CONC.put_line('   erv_expenditure_type .. '||l_erv_exp_type);
     PJM_CONC.put_line('   erv_amount ............ '||
                           InvRec.Exchange_Rate_Variance);
     PJM_CONC.put_line('   expenditure_comment ... '||
                           InvRec.Expenditure_Comment);
     PJM_CONC.new_line(1);

     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 100;

     if ( InvRec.RCV_Transaction_Id is not null ) then

       SELECT rsh.receipt_num
       INTO   l_receipt_num
       FROM   rcv_shipment_headers rsh
       ,      rcv_transactions     rt
       WHERE  rt.transaction_id = InvRec.RCV_Transaction_Id
       AND    rsh.shipment_header_id = rt.shipment_header_id;

     end if;

     ----------------------------------------------------------------------
     -- Converting System RATE_TYPE to User RATE_TYPE if exists
     ----------------------------------------------------------------------

     l_progress := 105;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     end if;

     ----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     if not ( InvRec.Price_Var_Code_Combination_Id is not null AND
              nvl(nvl(InvRec.Base_Invoice_Price_Variance,
                  InvRec.Invoice_Price_Variance) , 0) <> 0 ) then

        PJM_CONC.put_line('...... IPV amount not available, skipping...');

     elsif ( l_IPV_Exp_Type is null) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer IPV, skipping...');

     else

     BEGIN

        l_progress := 110;

     ---------------------------------------------------------------------
     -- For Blue Print org, setting Transaction Source according to
     -- pa_posting_flag and pa_autoaccounting_flag
     ---------------------------------------------------------------------

        select NVL(pa_posting_flag,'N'),
               NVL(pa_autoaccounting_flag,'N')
        into l_blue_print_enabled_flag,
             l_autoaccounting_flag
        from pjm_org_parameters
        where organization_id = InvRec.Expenditure_Organization_Id;

        If l_blue_print_enabled_flag = 'Y' then
               If l_autoaccounting_flag = 'Y' then
               /* BP and autoaccounting  */
                  l_transaction_source := 'PJM_CSTBP_INV_NO_ACCOUNTS';
               else
               /* BP and no autoaccounting -- Send Account to PA */
                  l_transaction_source := 'PJM_CSTBP_INV_ACCOUNTS';

               end if; /* end of check for auto accounting */

        ELSE /* non BP org */
                  l_transaction_source := 'Inventory';
        END IF; /* check for BP org */


        PJM_CONC.put_line('...... Processing IPV');

        -- Insert for IPV
        INSERT INTO pa_transaction_interface
        (transaction_source,
         batch_name,
         expenditure_ending_date,
         employee_number,
         organization_name,
         expenditure_item_date,
         project_number,
         task_number,
         expenditure_type,
         quantity,
         expenditure_comment,
         orig_transaction_reference,
         unmatched_negative_txn_flag,
         dr_code_combination_id,
         cr_code_combination_id,
         orig_exp_txn_reference1,
         orig_exp_txn_reference2,
         orig_exp_txn_reference3,
         gl_date,
         system_linkage,
         transaction_status_code,
         denom_currency_code,
         denom_raw_cost,
         denom_burdened_cost,
         acct_rate_date,
         acct_rate_type,
         acct_exchange_rate,
         acct_raw_cost,
         acct_burdened_cost,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_IPV_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_IPV_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Price_Var_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  'INV'
        ,  l_trx_status_code
        ,  InvRec.Invoice_Currency_Code  /* denom_currency_code */
        ,  InvRec.Invoice_Price_Variance /* denom_raw_cost */
        ,  InvRec.Invoice_Price_Variance /* denom_burdened_cost */
        ,  InvRec.Exchange_Date          /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate          /* acct_exchange_rate */
        ,  nvl(InvRec.Base_Invoice_Price_Variance,
               InvRec.Invoice_Price_Variance) /* acct_raw_cost */
        ,  nvl(InvRec.Base_Invoice_Price_Variance,
               InvRec.Invoice_Price_Variance) /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        FROM
           AP_Invoice_Distributions DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number
--        AND  DIST.PA_Addition_Flag = 'S'
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     end if;

     -- Insert for ERV
     if not ( InvRec.Rate_Var_Code_Combination_Id is not null AND
              InvRec.Exchange_Rate_Variance <> 0 ) then

        PJM_CONC.put_line('...... ERV amount not available, skipping...');

     elsif ( l_ERV_Exp_Type is null ) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer ERV, skipping...');

     else

     BEGIN

        l_progress := 120;

        PJM_CONC.put_line('...... Processing ERV');

        INSERT INTO pa_transaction_interface
        (transaction_source,
         batch_name,
         expenditure_ending_date,
         employee_number,
         organization_name,
         expenditure_item_date,
         project_number,
         task_number,
         expenditure_type,
         quantity,
         expenditure_comment,
         orig_transaction_reference,
         unmatched_negative_txn_flag,
         dr_code_combination_id,
         cr_code_combination_id,
         orig_exp_txn_reference1,
         orig_exp_txn_reference2,
         orig_exp_txn_reference3,
         gl_date,
         system_linkage,
         transaction_status_code,
         denom_currency_code,
         denom_raw_cost,
         denom_burdened_cost,
         acct_rate_date,
         acct_rate_type,
         acct_exchange_rate,
         acct_raw_cost,
         acct_burdened_cost,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_ERV_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_ERV_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Rate_Var_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  'INV'
        ,  l_trx_status_code
        ,  l_base_currency_code          /* denom_currency_code */
        ,  InvRec.Exchange_Rate_Variance /* denom_raw_cost */
        ,  InvRec.Exchange_Rate_Variance /* denom_burdened_cost */
        ,  NULL                          /* acct_rate_date */
        ,  NULL                          /* acct_rate_type */
        ,  NULL                          /* acct_exchange_rate */
        ,  InvRec.Exchange_Rate_Variance /* acct_raw_cost */
        ,  InvRec.Exchange_Rate_Variance /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        FROM
           AP_Invoice_Distributions DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number
--        AND  DIST.PA_Addition_Flag = 'S'
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;
     end if;

     ----------------------------------------------------------------------
     -- Update pa_addition_flag to 'Y' for successful invoice distributions
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Flag Comp');
     PJM_CONC.put_line('... ' || fnd_message.get);
     PJM_CONC.new_line(1);

     l_progress := 130;

     UPDATE AP_Invoice_Distributions
     SET    Pa_Addition_Flag = 'Y',
            Request_Id = l_request_id
     WHERE  -- Pa_Addition_Flag = 'S' AND
            Invoice_Id = InvRec.Invoice_Id
     AND    Distribution_Line_Number = InvRec.Distribution_Line_Number;

  END LOOP;

  CLOSE Inv_Curs;

  COMMIT;
  fnd_message.set_name('PJM','CONC-APINV Finish Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');
  PJM_CONC.new_line(1);

  Timestamp;

  l_progress := 140;

  if (X_Submit_Trx_Import = 'Y') then
     l_imp_req_id := fnd_request.submit_request('PA','PAXTRTRX',
                                 'PRC: Transaction Import',
                                 NULL, FALSE,
                                 'Inventory',
                                 l_Batch_Name);
  end if;

  retcode := PJM_CONC.G_conc_success;
  return;


EXCEPTION
  when OTHERS then
       errbuf := 'IPV-'||l_progress||': '||sqlerrm;
       retcode := PJM_CONC.G_conc_failure;
       return;

END Transfer_IPV_to_PA;


END PJM_TRANSFER_IPV_PKG;

/
