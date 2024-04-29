--------------------------------------------------------
--  DDL for Package Body PJM_TRANSFER_SPEC_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TRANSFER_SPEC_CHARGES_PKG" AS
/* $Header: PJMTSPCB.pls 115.31 2004/08/18 19:24:10 yliou ship $ */

--
-- Private Functions and Procedures
--
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
--   Transfer_Spec_Charges_to_PA
--
-- DESCRIPTION
--   This procedure will get the expenditure and costing data for
--   Freight, Tax, and other special chargs from AP invoices with
--   destination type of INVENTORY or SHOP FLOOR, and push these
--   data to PA_TRANSACTION_INTERFACES.
--
-- PARAMETERS
--   X_Project_Id               IN
--   X_Start_Date               IN
--   X_End_Date                 IN
--   ERRBUF                     OUT
--   RETCODE                    OUT
--
---------------------------------------------------------------------------

PROCEDURE Transfer_Spec_Charges_to_PA
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
  l_expenditure_type    VARCHAR2(30);
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

  l_Freight_Exp_Comment PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Tax_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Misc_Exp_Comment    PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
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
  l_trx_status_code          VARCHAR2(30);

  CURSOR Inv_WP_Curs IS
    SELECT
            INV.Invoice_id                      Invoice_Id
    ,       DIST.Distribution_Line_Number       Distribution_Line_Number
    ,       DIST.Amount                         Amount
    ,       DIST.Base_Amount                    Base_Amount
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                         Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Line_Type_Lookup_Code          Distribution_Type
    ,       POD.Po_Distribution_Id              Po_Distribution_Id
    ,       POD.Destination_Type_Code           Destination_Type_Code
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    FROM
            AP_Invoices INV
    ,     (
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,AID.Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,AID.Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID.RCV_Transaction_Id
            ,      AID.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            WHERE NOT EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions AID2
               WHERE  AID2.Invoice_Id = AID.Invoice_ID
               AND    AID2.Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            UNION ALL
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,ACA.Allocated_Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,ACA.Allocated_Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID2.RCV_Transaction_Id
            ,      AID2.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            ,      AP_Invoice_Distributions AID2
            ,      AP_Chrg_Allocations ACA
            WHERE EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions
               WHERE  Invoice_Id = AID.Invoice_ID
               AND    Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            AND    AID.Invoice_Distribution_Id = ACA.Charge_Dist_Id
            AND    ACA.Item_Dist_Id = AID2.Invoice_Distribution_Id
          ) DIST
    ,       PO_Distributions POD
    ,       PA_Projects_ALL PAP
    WHERE   DIST.Invoice_Id = INV.Invoice_Id
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     POD.Destination_Type_Code IN ( 'INVENTORY' , 'SHOP FLOOR' )
    AND     PAP.Project_Id = POD.Project_Id
    AND     PAP.Project_Id = X_Project_Id
    AND     DIST.Po_Distribution_Id = POD.Po_Distribution_Id
    UNION ALL
    SELECT
            INV.Invoice_id                      Invoice_Id
    ,       DIST.Distribution_Line_Number       Distribution_Line_Number
    ,       DIST.Amount                         Amount
    ,       DIST.Base_Amount                    Base_Amount
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                         Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Line_Type_Lookup_Code          Distribution_Type
    ,       POD.Po_Distribution_Id              Po_Distribution_Id
    ,       POD.Destination_Type_Code           Destination_Type_Code
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    FROM
            AP_Invoices INV
    ,     (
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,AID.Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,AID.Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID.RCV_Transaction_Id
            ,      AID.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            WHERE NOT EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions AID2
               WHERE  AID2.Invoice_Id = AID.Invoice_ID
               AND    AID2.Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            UNION ALL
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,ACA.Allocated_Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,ACA.Allocated_Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID2.RCV_Transaction_Id
            ,      AID2.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            ,      AP_Invoice_Distributions AID2
            ,      AP_Chrg_Allocations ACA
            WHERE EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions
               WHERE  Invoice_Id = AID.Invoice_ID
               AND    Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            AND    AID.Invoice_Distribution_Id = ACA.Charge_Dist_Id
            AND    ACA.Item_Dist_Id = AID2.Invoice_Distribution_Id
          ) DIST
    ,       PO_Distributions POD
    ,       PA_Projects_ALL PAP
    ,       PJM_Org_Parameters POP
    WHERE   DIST.Invoice_Id = INV.Invoice_Id
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     POD.Destination_Type_Code IN ( 'INVENTORY' , 'SHOP FLOOR' )
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = POP.Common_Project_Id
    AND     POD.Project_Id is null
    AND     PAP.Project_Id = X_Project_Id
    AND     DIST.Po_Distribution_Id = POD.Po_Distribution_Id
    ORDER BY 9,1,2;

  CURSOR Inv_NP_Curs IS
    SELECT
            INV.Invoice_id                      Invoice_Id
    ,       DIST.Distribution_Line_Number       Distribution_Line_Number
    ,       DIST.Amount                         Amount
    ,       DIST.Base_Amount                    Base_Amount
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                         Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Line_Type_Lookup_Code          Distribution_Type
    ,       POD.Po_Distribution_Id              Po_Distribution_Id
    ,       POD.Destination_Type_Code           Destination_Type_Code
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    FROM
            AP_Invoices INV
    ,     (
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,AID.Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,AID.Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID.RCV_Transaction_Id
            ,      AID.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            WHERE NOT EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions AID2
               WHERE  AID2.Invoice_Id = AID.Invoice_ID
               AND    AID2.Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            UNION ALL
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,ACA.Allocated_Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,ACA.Allocated_Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID2.RCV_Transaction_Id
            ,      AID2.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            ,      AP_Invoice_Distributions AID2
            ,      AP_Chrg_Allocations ACA
            WHERE EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions
               WHERE  Invoice_Id = AID.Invoice_ID
               AND    Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            AND    AID.Invoice_Distribution_Id = ACA.Charge_Dist_Id
            AND    ACA.Item_Dist_Id = AID2.Invoice_Distribution_Id
          ) DIST
    ,       PO_Distributions POD
    ,       PA_Projects_ALL PAP
    WHERE   DIST.Invoice_Id = INV.Invoice_Id
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     POD.Destination_Type_Code IN ( 'INVENTORY' , 'SHOP FLOOR' )
    AND     PAP.Project_Id = POD.Project_Id
    AND     DIST.Po_Distribution_Id = POD.Po_Distribution_Id
    UNION ALL
    SELECT
            INV.Invoice_id                      Invoice_Id
    ,       DIST.Distribution_Line_Number       Distribution_Line_Number
    ,       DIST.Amount                         Amount
    ,       DIST.Base_Amount                    Base_Amount
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                         Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Line_Type_Lookup_Code          Distribution_Type
    ,       POD.Po_Distribution_Id              Po_Distribution_Id
    ,       POD.Destination_Type_Code           Destination_Type_Code
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    FROM
            AP_Invoices INV
    ,     (
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,AID.Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,AID.Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID.RCV_Transaction_Id
            ,      AID.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            WHERE NOT EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions AID2
               WHERE  AID2.Invoice_Id = AID.Invoice_ID
               AND    AID2.Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            UNION ALL
            SELECT
                   AID.Invoice_Id
            ,      AID.Distribution_Line_Number
            ,      nvl(AID.invoice_price_variance,ACA.Allocated_Amount) Amount
            ,      nvl(AID.base_invoice_price_variance,ACA.Allocated_Base_Amount) Base_Amount
            ,      AID.Accounting_Date
            ,      AID.Pa_Quantity
            ,      AID.Dist_Code_Combination_Id
            ,      AID.Accts_Pay_Code_Combination_Id
            ,      AID.Line_Type_Lookup_Code
            ,      AID2.RCV_Transaction_Id
            ,      AID2.Po_Distribution_Id
            FROM   AP_Invoice_Distributions AID
            ,      AP_Invoice_Distributions AID2
            ,      AP_Chrg_Allocations ACA
            WHERE EXISTS (
               SELECT 'x'
               FROM   AP_Invoice_Distributions
               WHERE  Invoice_Id = AID.Invoice_ID
               AND    Line_Type_Lookup_Code = 'ITEM' )
            AND    nvl(AID.Tax_Recoverable_Flag, 'N') = 'N'
            AND    AID.Posted_Flag = 'Y'
            AND    AID.pa_addition_flag in
                    ( 'N' , 'S' , 'A' , 'B' , 'C' , 'D' , 'E' , 'I'
                    , 'J' , 'K' , 'M' , 'P' , 'Q' , 'V' , 'X' , 'W' )
            AND  (( l_Start_Date is null and l_End_Date is null)
               OR ( l_Start_Date is not null and l_End_Date is not null
                    and AID.Accounting_Date between l_Start_Date and l_End_Date)
               OR ( l_Start_Date is not null and l_End_Date is null
                    and AID.Accounting_Date >= l_Start_Date )
               OR ( l_Start_Date is null and l_End_Date is not null
                    and AID.Accounting_Date <= l_End_Date ))
            AND    AID.Invoice_Distribution_Id = ACA.Charge_Dist_Id
            AND    ACA.Item_Dist_Id = AID2.Invoice_Distribution_Id
          ) DIST
    ,       PO_Distributions POD
    ,       PA_Projects_ALL PAP
    ,       PJM_Org_Parameters POP
    WHERE   DIST.Invoice_Id = INV.Invoice_Id
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     POD.Destination_Type_Code IN ( 'INVENTORY' , 'SHOP FLOOR' )
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = POP.Common_Project_Id
    AND     POD.Project_Id is null
    AND     DIST.Po_Distribution_Id = POD.Po_Distribution_Id
    ORDER BY 9,1,2;

  InvRec                   Inv_WP_Curs%ROWTYPE;


BEGIN

  l_curr_invoice_id := -1;
  l_first_invoice := TRUE;
  l_progress := 0;
  if (X_trx_status_code is NULL)
  then l_trx_status_code := 'P';
  else l_trx_status_code := X_trx_status_code;
  end if;

  fnd_message.set_name('PJM','CONC-APINV Spechrg Transfer');
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

  l_Freight_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV FREIGHT');
  l_Tax_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV TAX');
  l_Misc_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV MISC');

  l_Batch_Name := PJM_Transfer_IPV_Pkg.batch_name;

  PJM_CONC.put_line('Batch_Name = ' || l_batch_name);
  PJM_CONC.new_line(1);

  ----------------------------------------------------------------------------------
  -- Get Accounting Currency Code
  ----------------------------------------------------------------------------------

  select  ap.base_currency_code
  into    l_base_currency_code
  from    gl_sets_of_books gl
    ,     ap_system_parameters ap
  where   gl.set_of_books_id = ap.set_of_books_id;

  -----------------------------------------------------------------------------------
  -- Loop for transfering Special Charge from Invoice_Distribution to
  -- PA_Transaction_Interfaces
  -----------------------------------------------------------------------------------

  fnd_message.set_name('PJM','CONC-APINV Start Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');

  Timestamp;

IF (X_Project_Id is not null) THEN

   OPEN Inv_WP_Curs;

   LOOP

     l_progress := 10;

     FETCH Inv_WP_Curs INTO InvRec;
     EXIT WHEN Inv_WP_Curs%NOTFOUND;

     --
     -- If Task not available, use Task AutoAssignment Rules to assign task
     --
     l_progress := 15;

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
     PJM_CONC.put_line('   line_type ............. '||
                           InvRec.Distribution_Type);
     PJM_CONC.new_line(1);

     Timestamp;

     ---------------------------------------------------------------------
     -- We commit for each invoice.
     ---------------------------------------------------------------------

     -- if (l_curr_invoice_id <> InvRec.Invoice_Id AND NOT l_first_invoice) then
     --    COMMIT;
     -- end if;

     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ---------------------------------------------------------------------
     -- Check Project Status
     ---------------------------------------------------------------------

     l_progress := 20;

     select decode(InvRec.Distribution_Type,
                        'FREIGHT', nvl(ppp.freight_expenditure_type,
                                       pop.freight_expenditure_type),
                        'TAX',     nvl(ppp.tax_expenditure_type,
                                       pop.tax_expenditure_type),
                        'MISC',    nvl(ppp.misc_expenditure_type,
                                       pop.misc_expenditure_type),
                                   nvl(ppp.misc_expenditure_type,
                                       pop.misc_expenditure_type))
     into   l_expenditure_type
     from   pjm_project_parameters ppp
     ,      pjm_org_parameters     pop
     where  pop.organization_id = InvRec.Expenditure_Organization_Id
     and    ppp.organization_id (+) = pop.organization_id
     and    ppp.project_id (+) = InvRec.Project_Id;

     PJM_CONC.put_line('   expenditure_type ...... '||l_expenditure_type);
     PJM_CONC.put_line('   amount ................ '||
                           nvl(InvRec.Base_Amount, InvRec.Amount));
     PJM_CONC.new_line(1);

     l_progress := 30;

    if ( l_expenditure_type is not null ) then

     l_progress := 40;

     UPDATE  AP_Invoice_distributions DIST
     SET     DIST.PA_Addition_Flag =
             DECODE(l_proj_status, 'PA_EX_PROJECT_CLOSED', 'P',
                                   'PA_EX_PROJECT_DATE',   'D',
                                   'PA_EXP_TASK_STATUS',   'C',
                                   'PA_EXP_TASK_EFF',      'I',
                                   'PA_EXP_PJ_TC',         'J',
                                   'PA_EXP_TASK_TC',       'K',
                                   'PA_EXP_INV_PJTK',      'M',
                                    NULL,                  'S',
                                                           'Q')
     ,       DIST.Last_Update_Date = SYSDATE
     ,       DIST.Last_Updated_By  = l_user_id
     ,       DIST.Request_Id       = l_request_id
     WHERE
             DIST.Invoice_Id               = InvRec.Invoice_Id
     AND     DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number;

     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 50;

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

     l_progress := 55;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     end if;

     -----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     -----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     BEGIN

        l_progress := 60;

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
        ,  l_Expenditure_Type
        ,  InvRec.PA_Quantity
        ,  decode(InvRec.Distribution_Type,
                  'FREIGHT', l_Freight_Exp_Comment,
                  'TAX',     l_Tax_Exp_Comment,
                  'MISC',    l_Misc_Exp_Comment,
                             l_Misc_Exp_Comment)
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  'INV'
        ,  l_trx_status_code
        ,  InvRec.Invoice_Currency_Code /* denom_currency_code */
        ,  InvRec.Amount                /* denom_raw_cost */
        ,  InvRec.Amount                /* denom_burdened_cost */
        ,  InvRec.Exchange_Date         /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate         /* acct_exchange_rate */
        ,  nvl(InvRec.Base_Amount, InvRec.Amount) /* acct_raw_cost */
        ,  nvl(InvRec.Base_Amount, InvRec.Amount) /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        FROM
           AP_Invoice_Distributions DIST
        ,  AP_Invoices INV
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number
        AND  DIST.PA_Addition_Flag = 'S'
        AND  INV.Invoice_ID = DIST.Invoice_Id
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     ------------------------------------------------------------------------
     -- Update pa_addition_flag to 'Y' for successful invoice distributions
     ------------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Flag Comp');
     PJM_CONC.put_line('... ' || fnd_message.get);
     PJM_CONC.new_line(1);


     l_progress := 70;

     UPDATE AP_Invoice_Distributions
     SET    Pa_Addition_Flag = 'Y'
     WHERE  Pa_Addition_Flag = 'S'
     AND    Invoice_Id = InvRec.Invoice_Id
     AND    Distribution_Line_Number = InvRec.Distribution_Line_Number;

    ELSE /* l_expenditure_type is not null */

     UPDATE AP_Invoice_Distributions
     SET    Pa_Addition_Flag = 'Y'
     ,      Request_ID       = l_request_id
     WHERE  Invoice_Id = InvRec.Invoice_Id
     AND    Distribution_Line_Number = InvRec.Distribution_Line_Number;

    END IF;

  END LOOP;

  CLOSE Inv_WP_Curs;

ELSE /* X_Project_Id is null */

   OPEN Inv_NP_Curs;

   LOOP

     l_progress := 10;

     FETCH Inv_NP_Curs INTO InvRec;
     EXIT WHEN Inv_NP_Curs%NOTFOUND;

     --
     -- If Task not available, use Task AutoAssignment Rules to assign task
     --
     l_progress := 15;

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
     PJM_CONC.put_line('   line_type ............. '||
                           InvRec.Distribution_Type);
     PJM_CONC.new_line(1);

     Timestamp;

     ---------------------------------------------------------------------
     -- We commit for each invoice.
     ---------------------------------------------------------------------

     -- if (l_curr_invoice_id <> InvRec.Invoice_Id AND NOT l_first_invoice) then
     --    COMMIT;
     -- end if;

     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ---------------------------------------------------------------------
     -- Check Project Status
     ---------------------------------------------------------------------

     l_progress := 20;

     select decode(InvRec.Distribution_Type,
                        'FREIGHT', nvl(ppp.freight_expenditure_type,
                                       pop.freight_expenditure_type),
                        'TAX',     nvl(ppp.tax_expenditure_type,
                                       pop.tax_expenditure_type),
                        'MISC',    nvl(ppp.misc_expenditure_type,
                                       pop.misc_expenditure_type),
                                   nvl(ppp.misc_expenditure_type,
                                       pop.misc_expenditure_type))
     into   l_expenditure_type
     from   pjm_project_parameters ppp
     ,      pjm_org_parameters     pop
     where  pop.organization_id = InvRec.Expenditure_Organization_Id
     and    ppp.organization_id (+) = pop.organization_id
     and    ppp.project_id (+) = InvRec.Project_Id;

     PJM_CONC.put_line('   expenditure_type ...... '||l_expenditure_type);
     PJM_CONC.put_line('   amount ................ '||
                           nvl(InvRec.Base_Amount, InvRec.Amount));
     PJM_CONC.new_line(1);

     l_progress := 30;

    if ( l_expenditure_type is not null ) then

     l_progress := 40;

     UPDATE  AP_Invoice_distributions DIST
     SET     DIST.PA_Addition_Flag =
             DECODE(l_proj_status, 'PA_EX_PROJECT_CLOSED', 'P',
                                   'PA_EX_PROJECT_DATE',   'D',
                                   'PA_EXP_TASK_STATUS',   'C',
                                   'PA_EXP_TASK_EFF',      'I',
                                   'PA_EXP_PJ_TC',         'J',
                                   'PA_EXP_TASK_TC',       'K',
                                   'PA_EXP_INV_PJTK',      'M',
                                    NULL,                  'S',
                                                           'Q')
     ,       DIST.Last_Update_Date = SYSDATE
     ,       DIST.Last_Updated_By  = l_user_id
     ,       DIST.Request_Id       = l_request_id
     WHERE
             DIST.Invoice_Id               = InvRec.Invoice_Id
     AND     DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number;

     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 50;

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

     l_progress := 55;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     end if;

     -----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     -----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     BEGIN

        l_progress := 60;

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
        ,  l_Expenditure_Type
        ,  InvRec.PA_Quantity
        ,  decode(InvRec.Distribution_Type,
                  'FREIGHT', l_Freight_Exp_Comment,
                  'TAX',     l_Tax_Exp_Comment,
                  'MISC',    l_Misc_Exp_Comment,
                             l_Misc_Exp_Comment)
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  'INV'
        ,  l_trx_status_code
        ,  InvRec.Invoice_Currency_Code /* denom_currency_code */
        ,  InvRec.Amount                /* denom_raw_cost */
        ,  InvRec.Amount                /* denom_burdened_cost */
        ,  InvRec.Exchange_Date         /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate         /* acct_exchange_rate */
        ,  nvl(InvRec.Base_Amount, InvRec.Amount) /* acct_raw_cost */
        ,  nvl(InvRec.Base_Amount, InvRec.Amount) /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        FROM
           AP_Invoice_Distributions DIST
        ,  AP_Invoices INV
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Distribution_Line_Number = InvRec.Distribution_Line_Number
        AND  DIST.PA_Addition_Flag = 'S'
        AND  INV.Invoice_ID = DIST.Invoice_Id
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     ------------------------------------------------------------------------
     -- Update pa_addition_flag to 'Y' for successful invoice distributions
     ------------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Flag Comp');
     PJM_CONC.put_line('... ' || fnd_message.get);
     PJM_CONC.new_line(1);


     l_progress := 70;

     UPDATE AP_Invoice_Distributions
     SET    Pa_Addition_Flag = 'Y'
     WHERE  Pa_Addition_Flag = 'S'
     AND    Invoice_Id = InvRec.Invoice_Id
     AND    Distribution_Line_Number = InvRec.Distribution_Line_Number;

    ELSE /* l_expenditure_type is not null */

     UPDATE AP_Invoice_Distributions
     SET    Pa_Addition_Flag = 'Y'
     ,      Request_ID       = l_request_id
     WHERE  Invoice_Id = InvRec.Invoice_Id
     AND    Distribution_Line_Number = InvRec.Distribution_Line_Number;

    END IF;

  END LOOP;

  CLOSE Inv_NP_Curs;

END IF;

  COMMIT;

  fnd_message.set_name('PJM','CONC-APINV Finish Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');
  PJM_CONC.new_line(1);

  Timestamp;

  l_progress := 80;

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
       errbuf := 'SPC-'||l_progress||': '||sqlerrm;
       retcode := PJM_CONC.G_conc_failure;
       return;

END Transfer_Spec_Charges_to_PA;


END PJM_TRANSFER_SPEC_CHARGES_PKG;

/
