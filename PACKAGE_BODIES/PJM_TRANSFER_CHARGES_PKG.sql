--------------------------------------------------------
--  DDL for Package Body PJM_TRANSFER_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TRANSFER_CHARGES_PKG" AS
/* $Header: PJMTFCGB.pls 120.14.12010000.3 2009/06/26 16:05:46 huiwan ship $ */

-- Start of comments
--	API name 	: Batch_Name
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the batch name for the batch process
--	Parameters	:
--	IN		: N/A
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

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

End Batch_Name;

/*
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

End;  */

-- Start of comments
--	API name 	: Get_Charges_Expenditure_Type
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the expenture type for IPV,ERV and special
--			: charges
--	Parameters	:
--      IN		: X_Type		VARCHAR2
--	IN		: X_Project_ID	        NUMBER
--      IN	        : X_Org_ID		NUMBER
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

Function get_charges_expenditure_type
( X_Type	IN VARCHAR2
, X_Project_Id  IN NUMBER
, X_Org_Id      IN NUMBER
) RETURN VARCHAR2 IS
l_expenditure_type VARCHAR2(30);

/* added NONREC_TAX in the decode statement for bug 7482789*/
cursor c is
select decode(X_Type,
                  'FREIGHT',       nvl(ppp.freight_expenditure_type,
                                       pop.freight_expenditure_type),
                  'MISCELLANEOUS', nvl(ppp.misc_expenditure_type,
                                       pop.misc_expenditure_type),
		  'TIPV',          nvl(ppp.tax_expenditure_type,
                                       pop.tax_expenditure_type),
		  'TERV',          nvl(ppp.erv_expenditure_type,
                                       pop.erv_expenditure_type),
		  'IPV',           nvl(ppp.ipv_expenditure_type,
                                       pop.ipv_expenditure_type),
	          'ERV',           nvl(ppp.erv_expenditure_type,
                                       pop.erv_expenditure_type),
		  'TRV',           nvl(ppp.tax_expenditure_type,
                                       pop.tax_expenditure_type),
                  'NONREC_TAX',     nvl(ppp.tax_expenditure_type,
                                       pop.tax_expenditure_type),
                  null)
     into   l_expenditure_type
     from   pjm_project_parameters ppp
     ,      pjm_org_parameters     pop
     where  pop.organization_id = X_Org_ID
     and    ppp.organization_id (+) = pop.organization_id
     and    ppp.project_id (+) = X_Project_Id;

Begin

  if X_Type is not null then
    open c;
    fetch c into l_expenditure_type;
    close c;
  end if;

  return l_expenditure_type;

End get_charges_expenditure_type;

-- Start of comments
--	API name 	: Assign_Task
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: Assign tasks for common projects
--	Parameters	:
--      IN		: X_PO_Distribution_ID  	NUMBER
--	IN		: X_Destination_Type_Code       VARCHAR2
--      IN	        : X_Project_ID			NUMBER
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

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
  FROM   PO_Distributions_All POD
  ,      PO_Lines_All POL
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
  FROM   PO_Distributions_All POD
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

-- Start of comments
--	API name 	: Timestamp
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: Set time stamp for log file
--	Parameters	: N/A
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

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

-- Start of comments
--	API name 	: Transfer_Charges_To_PA
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Get the expenditure and costing data from invoice
--			: distributions which has amount for IPV, ERV and
--			: special charges, and the destination type is
--			: INVENTORY or SHOP FLOOR, then push data to PA
--	Parameters	:
--	IN		: X_Project_ID	        NUMBER
--      IN	        : X_Start_Date		DATE
--      IN 		: X_End_Date		DATE
--      IN 		: X_Submit_Trx_Import   VARCHAR2
--      IN 		: X_Trx_Status_Code	VARCHAR2
--      OUT		: ERRBUF	        NUMBER
--      OUT 		: RETCODE		NUMBER
--	Version	        : Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

PROCEDURE Transfer_Charges_to_PA
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
  l_Exp_Type        	VARCHAR2(30);
  l_curr_invoice_id     NUMBER;
  l_first_invoice       BOOLEAN;
  l_imp_req_id          NUMBER;
  l_base_currency_code  AP_System_parameters_all.base_currency_code%TYPE;

--  l_msg_application     VARCHAR2(30) := 'PA';
--  l_msg_type            VARCHAR2(30);
--  l_msg_token1          VARCHAR2(30);
--  l_msg_token2          VARCHAR2(30);
--  l_msg_token3          VARCHAR2(30);
--  l_msg_count           NUMBER;

  l_IPV_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_ERV_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Freight_Exp_Comment PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Tax_Exp_Comment     PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Misc_Exp_Comment    PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Exp_Comment		PA_Transaction_Interface_All.Expenditure_Comment%TYPE;
  l_Batch_Name          PA_Transaction_Interface_All.Batch_Name%TYPE;
  l_Receipt_Num         RCV_Shipment_Headers.Receipt_Num%TYPE;
  l_User_Conv_Type      GL_Daily_Conversion_Types.User_Conversion_Type%TYPE;
  l_Start_Date          DATE;
  l_End_Date            DATE;
  l_Task_Id             NUMBER;
  l_Uom			VARCHAR2(25);
  l_linkage		VARCHAR2(25);
  l_burdened_amount 	NUMBER;
  l_progress            NUMBER;
  l_blue_print_enabled_flag  VARCHAR2(1);
  l_autoaccounting_flag      VARCHAR2(1);
  l_transaction_source       VARCHAR2(30);
  l_trx_status_code              VARCHAR2(30);
  l_week_ending       DATE;
  l_week_ending_day   VARCHAR2(80);
  l_week_ending_day_index   number;
  l_denom_raw_cost      NUMBER;
  l_denom_burdened_cost NUMBER;
  l_acct_raw_cost       NUMBER;
  l_acct_burdened_cost  NUMBER;
  /* Bug 8506213, system reference is default to null and will be changed to
     'PJM' if transaction source is either Inventory or Work In Process.
     Later in this procedure, when inserting into pa_transaction_interface_all
     table, l_system_reference will be used to populate the
     cdl_system_reference4 column (4 places) */
  l_system_reference    VARCHAR2(30);


    CURSOR IPV_NP_Curs IS
    SELECT  INV.Invoice_id                      Invoice_Id
    ,       DIST.Invoice_Distribution_Id        Invoice_Distribution_Id
    ,       PAP.Org_Id                          Proj_Org_Id
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                        Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       POD.Org_Id                          Org_Id
    ,       DIST.description                    Expenditure_Comment
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Amount                         Charge_Amount
    ,       DIST.Base_Amount                    Base_Charge_Amount
    ,       DIST.PO_Distribution_Id             PO_Distribution_Id
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    ,       DIST.Line_Type_Lookup_Code	      Line_Type_Lookup_Code
    FROM    AP_Invoices_All INV,
            (SELECT Invoice_Distribution_Id
            ,       Invoice_Id
            ,       Project_Id
            ,       Task_id
            ,       Accounting_Date
            ,       Expenditure_Organization_Id
            ,       description
            ,       Pa_Quantity
            ,       Dist_Code_Combination_Id
            ,       Accts_Pay_Code_Combination_Id
            ,       Amount
            ,       Base_Amount
            ,       PO_Distribution_Id
            ,       RCV_Transaction_Id
            ,       Line_Type_Lookup_Code
            FROM    AP_Invoice_Distributions_all
            WHERE   LINE_TYPE_LOOKUP_CODE IN ('IPV', 'ERV', 'TIPV', 'TERV', 'TRV')
            AND     PA_ADDITION_FLAG in ('E', 'M', 'N')
            AND     POSTED_FLAG = 'Y'
            ) DIST,
            PA_Projects_ALL PAP,
            PJM_Org_Parameters POP,
            PO_Distributions_All POD
    WHERE   INV.INVOICE_TYPE_LOOKUP_CODE <> 'EXPENSE REPORT'
    AND     POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
    AND     DIST.Invoice_Id = INV.Invoice_Id
    AND  (( l_Start_Date is null and l_End_Date is null)
      OR ( l_Start_Date is not null and l_End_Date is not null
            and DIST.Accounting_Date between l_Start_Date and l_End_Date)
       OR ( l_Start_Date is not null and l_End_Date is null
            and DIST.Accounting_Date >= l_Start_Date )
       OR ( l_Start_Date is null and l_End_Date is not null
            and DIST.Accounting_Date <= L_End_Date  ))
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     DIST.po_distribution_id = POD.po_distribution_id
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = NVL(POD.Project_Id , POP.Common_Project_Id)
    ORDER BY 9,1,2
    for update;

    CURSOR SPC_NP_Curs IS
    SELECT  INV.Invoice_id                      Invoice_Id
    ,       DIST.Invoice_Distribution_Id        Invoice_Distribution_Id
    ,       PAP.Org_Id                          Proj_Org_Id
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                        Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       POD.Org_Id                          Org_Id
    ,       DIST.description                    Expenditure_Comment
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Amount                         Charge_Amount
    ,       DIST.Base_Amount                    Base_Charge_Amount
    ,       DIST.PO_Distribution_Id             PO_Distribution_Id
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    ,       DIST.Line_Type_Lookup_Code	      Line_Type_Lookup_Code
    FROM    AP_Invoices_All INV,
            (SELECT C.Invoice_Distribution_Id
            ,      C.Invoice_Id
            ,      P.Project_Id
            ,      P.Task_Id
            ,      C.Accounting_Date
            ,      C.Expenditure_Organization_Id
            ,      C.description
            ,      C.Pa_Quantity
            ,      C.Dist_Code_Combination_Id
            ,      C.Accts_Pay_Code_Combination_Id
            ,      C.Amount
            ,      C.Base_Amount
            ,      NVL(P.PO_Distribution_Id,(SELECT PO_Distribution_Id FROM AP_Invoice_Distributions_all P1
                                              WHERE  P1.invoice_distribution_id = P.charge_applicable_to_dist_id)) PO_Distribution_Id -- bugfix 7482789
            ,      C.RCV_Transaction_Id
            ,      C.Line_Type_Lookup_Code
            FROM    AP_Invoice_Distributions_all C, AP_Invoice_Distributions_all P
            WHERE   C.LINE_TYPE_LOOKUP_CODE IN ('FREIGHT','MISCELLANEOUS','NONREC_TAX') -- bugfix 7482789
            AND     C.PA_ADDITION_FLAG in ('E', 'M', 'N')
            AND     C.POSTED_FLAG = 'Y'
            AND     C.charge_applicable_to_dist_id = P.invoice_distribution_id
            AND     (P.charge_applicable_to_dist_id IS NOT NULL OR C.LINE_TYPE_LOOKUP_CODE IN ('FREIGHT','MISCELLANEOUS')) -- bugfix 7482789
            ) DIST,
            PA_Projects_ALL PAP,
            PJM_Org_Parameters POP,
            PO_Distributions_All POD
    WHERE   INV.INVOICE_TYPE_LOOKUP_CODE <> 'EXPENSE REPORT'
    AND     POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
    AND     DIST.Invoice_Id = INV.Invoice_Id
    AND  (( l_Start_Date is null and l_End_Date is null)
      OR ( l_Start_Date is not null and l_End_Date is not null
            and DIST.Accounting_Date between l_Start_Date and l_End_Date)
       OR ( l_Start_Date is not null and l_End_Date is null
            and DIST.Accounting_Date >= l_Start_Date )
       OR ( l_Start_Date is null and l_End_Date is not null
            and DIST.Accounting_Date <= L_End_Date  ))
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     DIST.po_distribution_id = POD.po_distribution_id
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = NVL(POD.Project_Id , POP.Common_Project_Id)
    ORDER BY 9,1,2
    for update;


    CURSOR IPV_WP_Curs IS
    SELECT  INV.Invoice_id                      Invoice_Id
    ,       DIST.Invoice_Distribution_Id        Invoice_Distribution_Id
    ,       PAP.Org_Id                          Proj_Org_Id
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                        Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       POD.Org_Id                          Org_Id
    ,       DIST.description                    Expenditure_Comment
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Amount                         Charge_Amount
    ,       DIST.Base_Amount                    Base_Charge_Amount
    ,       DIST.PO_Distribution_Id             PO_Distribution_Id
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    ,       DIST.Line_Type_Lookup_Code	      Line_Type_Lookup_Code
    FROM    AP_Invoices_All INV,
            (SELECT Invoice_Distribution_Id
            ,       Invoice_Id
            ,       Project_Id
            ,       Task_id
            ,       Accounting_Date
            ,       Expenditure_Organization_Id
            ,       description
            ,       Pa_Quantity
            ,       Dist_Code_Combination_Id
            ,       Accts_Pay_Code_Combination_Id
            ,       Amount
            ,       Base_Amount
            ,       PO_Distribution_Id
            ,       RCV_Transaction_Id
            ,       Line_Type_Lookup_Code
            FROM    AP_Invoice_Distributions_all
            WHERE   LINE_TYPE_LOOKUP_CODE IN ('IPV', 'ERV', 'TIPV', 'TERV', 'TRV')
            AND     PA_ADDITION_FLAG in ('E', 'M', 'N')
            AND     POSTED_FLAG = 'Y'
            ) DIST,
            PA_Projects_ALL PAP,
            PJM_Org_Parameters POP,
            PO_Distributions_All POD
    WHERE   INV.INVOICE_TYPE_LOOKUP_CODE <> 'EXPENSE REPORT'
    AND     POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
    AND     DIST.Invoice_Id = INV.Invoice_Id
    AND  (( l_Start_Date is null and l_End_Date is null)
      OR ( l_Start_Date is not null and l_End_Date is not null
            and DIST.Accounting_Date between l_Start_Date and l_End_Date)
       OR ( l_Start_Date is not null and l_End_Date is null
            and DIST.Accounting_Date >= l_Start_Date )
       OR ( l_Start_Date is null and l_End_Date is not null
            and DIST.Accounting_Date <= L_End_Date  ))
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     DIST.po_distribution_id = POD.po_distribution_id
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = NVL(POD.Project_Id , POP.Common_Project_Id)
    AND     PAP.Project_Id = X_Project_ID
    ORDER BY 9,1,2
    for update;

    CURSOR SPC_WP_Curs IS
    SELECT  INV.Invoice_id                      Invoice_Id
    ,       DIST.Invoice_Distribution_Id        Invoice_Distribution_Id
    ,       PAP.Org_Id                          Proj_Org_Id
    ,       PAP.Project_Id                      Project_Id
    ,       PAP.Segment1                        Project_Number
    ,       POD.Task_id                        Task_Id
    ,       DIST.Accounting_Date                Expenditure_Item_Date
    ,       INV.Vendor_Id                       Vendor_Id
    ,       INV.Created_By                      Created_By
    ,       POD.Destination_Organization_Id     Expenditure_Organization_Id
    ,       POD.Org_Id                          Org_Id
    ,       DIST.description                    Expenditure_Comment
    ,       NVL(DIST.Pa_Quantity, 1 )           PA_Quantity
    ,       DIST.Dist_Code_Combination_Id       Dist_Code_Combination_Id
    ,       nvl( DIST.Accts_Pay_Code_Combination_Id
               , INV.Accts_Pay_Code_Combination_Id)
                                                Accts_Pay_Code_Combination_Id
    ,       INV.Invoice_Currency_Code           Invoice_Currency_Code
    ,       INV.Exchange_Rate_Type              Exchange_Rate_Type
    ,       INV.Exchange_Date                   Exchange_Date
    ,       INV.Exchange_Rate                   Exchange_Rate
    ,       DIST.Amount                         Charge_Amount
    ,       DIST.Base_Amount                    Base_Charge_Amount
    ,       DIST.PO_Distribution_Id             PO_Distribution_Id
    ,       DIST.RCV_Transaction_Id             RCV_Transaction_Id
    ,       DIST.Line_Type_Lookup_Code	      Line_Type_Lookup_Code
    FROM    AP_Invoices_All INV,
            (SELECT C.Invoice_Distribution_Id
            ,      C.Invoice_Id
            ,      P.Project_Id
            ,      P.Task_Id
            ,      C.Accounting_Date
            ,      C.Expenditure_Organization_Id
            ,      C.description
            ,      C.Pa_Quantity
            ,      C.Dist_Code_Combination_Id
            ,      C.Accts_Pay_Code_Combination_Id
            ,      C.Amount
            ,      C.Base_Amount
            ,      NVL(P.PO_Distribution_Id,(SELECT PO_Distribution_Id FROM AP_Invoice_Distributions_all P1
                                              WHERE  P1.invoice_distribution_id = P.charge_applicable_to_dist_id)) PO_Distribution_Id -- bugfix 7482789
            ,      C.RCV_Transaction_Id
            ,      C.Line_Type_Lookup_Code
            FROM    AP_Invoice_Distributions_all C, AP_Invoice_Distributions_all P
            WHERE   C.LINE_TYPE_LOOKUP_CODE IN ('FREIGHT','MISCELLANEOUS','NONREC_TAX') -- bugfix 7482789
            AND     C.PA_ADDITION_FLAG in ('E', 'M', 'N')
            AND     C.POSTED_FLAG = 'Y'
            AND     C.charge_applicable_to_dist_id = P.invoice_distribution_id
            AND     (P.charge_applicable_to_dist_id IS NOT NULL OR C.LINE_TYPE_LOOKUP_CODE IN ('FREIGHT','MISCELLANEOUS')) -- bugfix 7482789
            ) DIST,
            PA_Projects_ALL PAP,
            PJM_Org_Parameters POP,
            PO_Distributions_All POD
    WHERE   INV.INVOICE_TYPE_LOOKUP_CODE <> 'EXPENSE REPORT'
    AND     POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
    AND     DIST.Invoice_Id = INV.Invoice_Id
    AND  (( l_Start_Date is null and l_End_Date is null)
      OR ( l_Start_Date is not null and l_End_Date is not null
            and DIST.Accounting_Date between l_Start_Date and l_End_Date)
       OR ( l_Start_Date is not null and l_End_Date is null
            and DIST.Accounting_Date >= l_Start_Date )
       OR ( l_Start_Date is null and l_End_Date is not null
            and DIST.Accounting_Date <= L_End_Date  ))
    AND     NVL(INV.Source, 'XX' ) <> 'Oracle Project Accounting'
    AND     DIST.po_distribution_id = POD.po_distribution_id
    AND     POP.Organization_Id = POD.Destination_Organization_Id
    AND     PAP.Project_Id = NVL(POD.Project_Id , POP.Common_Project_Id)
    AND     PAP.Project_Id = X_Project_ID
    ORDER BY 9,1,2
    for update;

  InvRec   IPV_WP_Curs%ROWTYPE;

  CURSOR Po_Data ( P_Distribution_ID NUMBER ) IS
  SELECT  POD.Destination_Type_Code
  , POL.Item_ID
  , POD.Bom_Resource_ID Wip_Resource_Id
  , POD.Destination_Organization_ID
  FROM po_distributions_all pod
  , po_lines_all pol
  WHERE POD.PO_Distribution_ID = P_Distribution_ID
  AND POL.Po_line_ID = POD.Po_Line_ID;

  PoRec Po_Data%ROWTYPE;
  l_dummy NUMBER;


BEGIN

  l_curr_invoice_id := -1;
  l_first_invoice := TRUE;
   l_progress := 0;
  if (X_trx_status_code is NULL) then
    l_trx_status_code := 'P';
  else
    l_trx_status_code := X_trx_status_code;
  end if;
  l_uom := 'DOLLARS'; -- bug 4145856


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
  l_Freight_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV FREIGHT');
  l_Tax_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV TAX');
  l_Misc_Exp_Comment := fnd_message.get_string('PJM','CONC-APINV MISC');
  l_Batch_Name := Batch_Name;

  PJM_CONC.put_line('Batch_Name = ' || l_batch_name);
  PJM_CONC.new_line(1);

  ----------------------------------------------------------------------
  -- Loop for transfering Variances from Invoice_Distribution_All to
  -- PA_Transaction_Interface_All
  ----------------------------------------------------------------------

  fnd_message.set_name('PJM','CONC-APINV Start Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');

  Timestamp;

  if (x_project_id is not null) then

  OPEN IPV_WP_Curs; -- Process IPV, ERV, and Tax Variances first

  LOOP  -- Start process data with project info

     l_progress := 10;

     FETCH IPV_WP_Curs INTO InvRec;
     EXIT WHEN IPV_WP_Curs%NOTFOUND;

     l_progress := 20;

     ----------------------------------------------------------------------
     -- Get Accounting Currency Code
     ----------------------------------------------------------------------
     if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
     then
       select  ap.base_currency_code
       into    l_base_currency_code
       from    ap_system_parameters_all ap
       where   ap.org_id = InvRec.Org_Id;
     else
       l_base_currency_code := InvRec.Invoice_Currency_Code;
     end if;

     --------------------------------------------------------------------
     -- Get PO Value
     ---------------------------------------------------------------------

     OPEN Po_Data ( InvRec.Po_Distribution_ID );
     FETCH Po_Data INTO PoRec;
     CLOSE Po_Data;


     IF ( InvRec.Task_Id IS NOT NULL ) THEN
       l_Task_Id := InvRec.Task_Id;
     ELSE
       l_Task_Id := Assign_Task( InvRec.PO_Distribution_Id
                               , PoRec.Destination_Type_Code
                               , InvRec.Project_Id );
     END IF;

     PJM_CONC.put_line('   invoice_id ............ '||InvRec.Invoice_Id);
     PJM_CONC.put_line('   line_num .............. '||
                           InvRec.Invoice_Distribution_Id);
     PJM_CONC.put_line('   project_id ............ '||InvRec.Project_ID);
     PJM_CONC.put_line('   task_id ............... '||l_Task_Id);
     PJM_CONC.put_line('   expenditure_org_id .... '||
                           InvRec.Expenditure_Organization_ID);

     Timestamp;


     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ----------------------------------------------------------------------
     -- Get Expenditure Type
     ----------------------------------------------------------------------

     l_progress := 30;

     l_exp_type := Get_Charges_Expenditure_Type
		( invrec.line_type_lookup_code
		, invrec.project_id
		, invrec.expenditure_organization_id );

     PJM_CONC.put_line('   Invoice line type is .. '||invrec.line_type_lookup_code);
     PJM_CONC.put_line('   Charge amount ............ '||
                           InvRec.charge_amount);
     PJM_CONC.put_line('   Charge expenditure_type .. '||l_exp_type);
     PJM_CONC.put_line('   expenditure_comment ... '||
                           InvRec.Expenditure_Comment);
     PJM_CONC.new_line(1);


     ---------------------------------------------------------------------
     -- Set Expenditure Comment
     ---------------------------------------------------------------------
     l_progress := 40;

     select decode(invrec.line_type_lookup_code, 'IPV', l_IPV_Exp_Comment,
				'ERV', l_ERV_Exp_Comment,
				'FREIGHT', l_Freight_Exp_Comment,
				'TIPV', l_Tax_Exp_Comment,
				'TERV', l_ERV_Exp_Comment,
				'TRV', l_Tax_Exp_Comment,
				'MISCELLANEOUS', l_Misc_Exp_Comment, null)
     into l_exp_comment
     from dual;


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

     l_progress := 60;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     else 	-- bug 4219497
       l_user_conv_type := null;

     end if;

     ----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     if not ( InvRec.Dist_Code_Combination_Id is not null AND
              nvl(nvl(InvRec.Base_Charge_Amount,
                  InvRec.Charge_Amount) , 0) <> 0 ) then

        PJM_CONC.put_line('...... Charge amount not available, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     elsif ( l_Exp_Type is null) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer charges, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     else

     BEGIN

        l_progress := 70;

     ---------------------------------------------------------------------
     -- For Blue Print org, setting Transaction Source according to
     -- destination_type_code, pa_posting_flag and pa_autoaccounting_flag
     ---------------------------------------------------------------------

        select NVL(pa_posting_flag,'N'),
               NVL(pa_autoaccounting_flag,'N')
        into l_blue_print_enabled_flag,
             l_autoaccounting_flag
        from pjm_org_parameters
        where organization_id = InvRec.Expenditure_Organization_Id;

        l_system_reference := NULL;
        if PoRec.destination_type_code = 'INVENTORY' then 	-- bug 4184314
   	  l_linkage := 'INV';
          If l_blue_print_enabled_flag = 'Y' then

            If l_autoaccounting_flag = 'Y' then
               /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_INV_NO_ACCOUNTS';
            else
               /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_INV_ACCOUNTS';

            end if; /* end of check for auto accounting */

          else
            l_transaction_source := 'Inventory';
            l_system_reference := 'PJM';
          end if;

        elsif PoRec.destination_type_code = 'SHOP FLOOR' then
  	  l_linkage := 'WIP';
          If l_blue_print_enabled_flag = 'Y' then
            If l_autoaccounting_flag = 'Y' then
              /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_WIP_NO_ACCOUNTS';
            else
              /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_WIP_ACCOUNTS';

            end if; /* end of check for auto accounting */
          else
            l_transaction_source := 'Work In Progress';
            l_system_reference := 'PJM';
	  end if;

        END IF; /* check for BP org */


        -------------------------------------------------
        -- Set the denom amount for bug 4169096
        -------------------------------------------------

        if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
        then
          l_denom_raw_cost := InvRec.Base_Charge_Amount;
          l_acct_raw_cost  := InvRec.Base_Charge_Amount;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Base_Charge_Amount;
            l_acct_burdened_cost  := InvRec.Base_Charge_Amount;
          end if;
        else
          l_denom_raw_cost := InvRec.Charge_Amount;
          select nvl(InvRec.Base_Charge_Amount, InvRec.Charge_Amount) into l_acct_raw_cost from dual;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Charge_Amount;
            l_acct_burdened_cost  := l_acct_raw_cost;
          end if;
        end if;


        -- Get Week Ending of Expenditure Item Date
        SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
        into l_week_ending_day_index
        FROM pa_implementations_all WHERE org_id = InvRec.Proj_Org_Id;

        select to_char(to_date('01-01-1950','DD-MM-YYYY') + l_week_ending_day_index - 1, 'Day')
        into l_week_ending_day from dual;

        select  next_day( trunc(InvRec.Expenditure_Item_Date)-1, l_week_ending_day )
        into    l_week_ending
        from    dual;

        PJM_CONC.put_line('...... Processing IPV, ERV, Tax Variances');

        -- Insert for all the charges

        INSERT INTO pa_transaction_interface_all
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
         last_updated_by,
	 inventory_item_id,
	 unit_of_measure,
	 wip_resource_id,
         org_id,
         cdl_system_reference4
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  l_week_ending  --pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  l_linkage
        ,  l_trx_status_code
        ,  l_base_currency_code          /* denom_currency_code */
        ,  l_denom_raw_cost              /* denom_raw_cost */
        ,  l_denom_burdened_cost         /* denom_burdened_cost */
        ,  InvRec.Exchange_Date          /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate          /* acct_exchange_rate */
        ,  l_acct_raw_cost               /* acct_raw_cost */
        ,  l_acct_burdened_cost          /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        ,  PoRec.item_id
	,  l_uom
 	,  PoRec.wip_resource_id
        ,  InvRec.Org_Id
        ,  l_system_reference
        FROM
           AP_Invoice_Distributions_all DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;


        ----------------------------------------------------------------------
        -- Update pa_addition_flag to 'Y' for successful invoice distributions
        ----------------------------------------------------------------------

        fnd_message.set_name('PJM','CONC-APINV Flag Comp');
        PJM_CONC.put_line('... ' || fnd_message.get);
        PJM_CONC.new_line(1);

        l_progress := 80;

        UPDATE AP_Invoice_Distributions_all
        SET    Pa_Addition_Flag = 'Y',
               Request_Id = l_request_id
        WHERE  Invoice_Id = InvRec.Invoice_Id
        AND    Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     end if;

  END LOOP; -- End process data with project info

  CLOSE IPV_WP_Curs;

  OPEN SPC_WP_Curs; -- Process Freight and Misc charges

  LOOP  -- Start process special charges with project info

     l_progress := 81;

     FETCH SPC_WP_Curs INTO InvRec;
     EXIT WHEN SPC_WP_Curs%NOTFOUND;

     l_progress := 82;

     ----------------------------------------------------------------------
     -- Get Accounting Currency Code
     ----------------------------------------------------------------------
     l_base_currency_code := InvRec.Invoice_Currency_Code;


     --------------------------------------------------------------------
     -- Get PO Value
     ---------------------------------------------------------------------

     OPEN Po_Data ( InvRec.Po_Distribution_ID );
     FETCH Po_Data INTO PoRec;
     CLOSE Po_Data;


     IF ( InvRec.Task_Id IS NOT NULL ) THEN
       l_Task_Id := InvRec.Task_Id;
     ELSE
       l_Task_Id := Assign_Task( InvRec.PO_Distribution_Id
                               , PoRec.Destination_Type_Code
                               , InvRec.Project_Id );
     END IF;

     PJM_CONC.put_line('   invoice_id ............ '||InvRec.Invoice_Id);
     PJM_CONC.put_line('   line_num .............. '||
                           InvRec.Invoice_Distribution_Id);
     PJM_CONC.put_line('   project_id ............ '||InvRec.Project_ID);
     PJM_CONC.put_line('   task_id ............... '||l_Task_Id);
     PJM_CONC.put_line('   expenditure_org_id .... '||
                           InvRec.Expenditure_Organization_ID);

     Timestamp;


     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ----------------------------------------------------------------------
     -- Get Expenditure Type
     ----------------------------------------------------------------------

     l_progress := 83;

     l_exp_type := Get_Charges_Expenditure_Type
		( invrec.line_type_lookup_code
		, invrec.project_id
		, invrec.expenditure_organization_id );

     PJM_CONC.put_line('   Invoice line type is .. '||invrec.line_type_lookup_code);
     PJM_CONC.put_line('   Charge amount ............ '||
                           InvRec.charge_amount);
     PJM_CONC.put_line('   Charge expenditure_type .. '||l_exp_type);
     PJM_CONC.put_line('   expenditure_comment ... '||
                           InvRec.Expenditure_Comment);
     PJM_CONC.new_line(1);


     ---------------------------------------------------------------------
     -- Set Expenditure Comment
     ---------------------------------------------------------------------
     l_progress := 84;

     select decode(invrec.line_type_lookup_code, 'IPV', l_IPV_Exp_Comment,
				'ERV', l_ERV_Exp_Comment,
				'FREIGHT', l_Freight_Exp_Comment,
				'TIPV', l_Tax_Exp_Comment,
				'TERV', l_ERV_Exp_Comment,
				'TRV', l_Tax_Exp_Comment,
				'MISCELLANEOUS', l_Misc_Exp_Comment,
                                'NONREC_TAX', l_Tax_Exp_Comment,null) --bugfix 7482789
     into l_exp_comment
     from dual;


     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 85;

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

     l_progress := 86;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     else 	-- bug 4219497
       l_user_conv_type := null;

     end if;

     ----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     if not ( InvRec.Dist_Code_Combination_Id is not null AND
              nvl(nvl(InvRec.Base_Charge_Amount,
                  InvRec.Charge_Amount) , 0) <> 0 ) then

        PJM_CONC.put_line('...... Charge amount not available, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     elsif ( l_Exp_Type is null) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer charges, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     else

     BEGIN

        l_progress := 87;

     ---------------------------------------------------------------------
     -- For Blue Print org, setting Transaction Source according to
     -- destination_type_code, pa_posting_flag and pa_autoaccounting_flag
     ---------------------------------------------------------------------

        select NVL(pa_posting_flag,'N'),
               NVL(pa_autoaccounting_flag,'N')
        into l_blue_print_enabled_flag,
             l_autoaccounting_flag
        from pjm_org_parameters
        where organization_id = InvRec.Expenditure_Organization_Id;

        l_system_reference := NULL;
        if PoRec.destination_type_code = 'INVENTORY' then 	-- bug 4184314
   	  l_linkage := 'INV';
          If l_blue_print_enabled_flag = 'Y' then

            If l_autoaccounting_flag = 'Y' then
               /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_INV_NO_ACCOUNTS';
            else
               /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_INV_ACCOUNTS';

            end if; /* end of check for auto accounting */

          else
            l_transaction_source := 'Inventory';
            l_system_reference := 'PJM';
          end if;

        elsif PoRec.destination_type_code = 'SHOP FLOOR' then
  	  l_linkage := 'WIP';
          If l_blue_print_enabled_flag = 'Y' then
            If l_autoaccounting_flag = 'Y' then
              /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_WIP_NO_ACCOUNTS';
            else
              /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_WIP_ACCOUNTS';

            end if; /* end of check for auto accounting */
          else
            l_transaction_source := 'Work In Progress';
            l_system_reference := 'PJM';
	  end if;

        END IF; /* check for BP org */


        -------------------------------------------------
        -- Set the denom amount for bug 4169096
        -------------------------------------------------

        if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
        then
          l_denom_raw_cost := InvRec.Base_Charge_Amount;
          l_acct_raw_cost  := InvRec.Base_Charge_Amount;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Base_Charge_Amount;
            l_acct_burdened_cost  := InvRec.Base_Charge_Amount;
          end if;
        else
          l_denom_raw_cost := InvRec.Charge_Amount;
          select nvl(InvRec.Base_Charge_Amount, InvRec.Charge_Amount) into l_acct_raw_cost from dual;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Charge_Amount;
            l_acct_burdened_cost  := l_acct_raw_cost;
          end if;
        end if;


        -- Get Week Ending of Expenditure Item Date
        SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
        into l_week_ending_day_index
        FROM pa_implementations_all WHERE org_id = InvRec.Proj_Org_Id;

        select to_char(to_date('01-01-1950','DD-MM-YYYY') + l_week_ending_day_index - 1, 'Day')
        into l_week_ending_day from dual;

        select  next_day( trunc(InvRec.Expenditure_Item_Date)-1, l_week_ending_day )
        into    l_week_ending
        from    dual;

        PJM_CONC.put_line('...... Processing Special Charge');

        -- Insert for all the charges

        INSERT INTO pa_transaction_interface_all
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
         last_updated_by,
	 inventory_item_id,
	 unit_of_measure,
	 wip_resource_id,
         org_id,
         cdl_system_reference4
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  l_week_ending  --pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  l_linkage
        ,  l_trx_status_code
        ,  l_base_currency_code          /* denom_currency_code */
        ,  l_denom_raw_cost              /* denom_raw_cost */
        ,  l_denom_burdened_cost         /* denom_burdened_cost */
        ,  InvRec.Exchange_Date          /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate          /* acct_exchange_rate */
        ,  l_acct_raw_cost               /* acct_raw_cost */
        ,  l_acct_burdened_cost          /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
        ,  PoRec.item_id
	,  l_uom
 	,  PoRec.wip_resource_id
        ,  InvRec.Org_Id
        ,  l_system_reference
        FROM
           AP_Invoice_Distributions_all DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;


        ----------------------------------------------------------------------
        -- Update pa_addition_flag to 'Y' for successful invoice distributions
        ----------------------------------------------------------------------

        fnd_message.set_name('PJM','CONC-APINV Flag Comp');
        PJM_CONC.put_line('... ' || fnd_message.get);
        PJM_CONC.new_line(1);

        l_progress := 88;

        UPDATE AP_Invoice_Distributions_all
        SET    Pa_Addition_Flag = 'Y',
               Request_Id = l_request_id
        WHERE  Invoice_Id = InvRec.Invoice_Id
        AND    Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     end if;

  END LOOP; -- End process special charges with project info

  CLOSE SPC_WP_Curs;

  else  	-- without project specified

  OPEN IPV_NP_Curs;

  LOOP  -- Start process IPV/ERV/Tax without project specified

     l_progress := 90;

     FETCH IPV_NP_Curs INTO InvRec;
     EXIT WHEN IPV_NP_Curs%NOTFOUND;

     l_progress := 100;

     --------------------------------------------------------------------
     -- Get PO Value
     ---------------------------------------------------------------------

     OPEN Po_Data ( InvRec.Po_Distribution_ID );
     FETCH Po_Data INTO PoRec;
     CLOSE Po_Data;

     ----------------------------------------------------------------------
     -- Get Accounting Currency Code
     ----------------------------------------------------------------------
     if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
     then
       select  ap.base_currency_code
       into    l_base_currency_code
       from    ap_system_parameters_all ap
       where   ap.org_id = InvRec.Org_Id;
     else
       l_base_currency_code := InvRec.Invoice_Currency_Code;
     end if;


     IF ( InvRec.Task_Id IS NOT NULL ) THEN
       l_Task_Id := InvRec.Task_Id;
     ELSE
       l_Task_Id := Assign_Task( InvRec.PO_Distribution_Id
                               , PoRec.Destination_Type_Code
                               , InvRec.Project_Id );
     END IF;

     PJM_CONC.put_line('   invoice_id ............ '||InvRec.Invoice_Id);
     PJM_CONC.put_line('   line_num .............. '||
                           InvRec.Invoice_Distribution_Id);
     PJM_CONC.put_line('   project_id ............ '||InvRec.Project_ID);
     PJM_CONC.put_line('   task_id ............... '||l_Task_Id);
     PJM_CONC.put_line('   expenditure_org_id .... '||
                           InvRec.Expenditure_Organization_ID);

     Timestamp;


     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ----------------------------------------------------------------------
     -- Get Expenditure Type
     ----------------------------------------------------------------------

     l_progress := 110;

     l_exp_type := Get_Charges_Expenditure_Type
		( invrec.line_type_lookup_code
		, invrec.project_id
		, invrec.expenditure_organization_id );

     PJM_CONC.put_line('   Invoice line type is .. '||invrec.line_type_lookup_code);
     PJM_CONC.put_line('   Charge amount ............ '||
                           InvRec.charge_amount);
     PJM_CONC.put_line('   Charge expenditure_type .. '||l_exp_type);
     PJM_CONC.put_line('   expenditure_comment ... '||
                           InvRec.Expenditure_Comment);
     PJM_CONC.new_line(1);

     ---------------------------------------------------------------------
     -- Set Expenditure Comment
     ---------------------------------------------------------------------
     l_progress := 120;

     select decode(invrec.line_type_lookup_code, 'IPV', l_IPV_Exp_Comment,
				'ERV', l_ERV_Exp_Comment,
				'FREIGHT', l_Freight_Exp_Comment,
				'TAX', l_Tax_Exp_Comment,
				'TIPV', l_Tax_Exp_Comment,
				'TERV', l_Tax_Exp_Comment,
				'TRV', l_Tax_Exp_Comment,
				'MISCELLANEOUS', l_Misc_Exp_Comment, null)
     into l_exp_comment
     from dual;

     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 130;

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

     l_progress := 140;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     else 	-- bug 4219497
       l_user_conv_type := null;

     end if;

     ----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     if not ( InvRec.Dist_Code_Combination_Id is not null AND
              nvl(nvl(InvRec.Base_Charge_Amount,
                  InvRec.Charge_Amount) , 0) <> 0 ) then

        PJM_CONC.put_line('...... Charge amount not available, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     elsif ( l_Exp_Type is null) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer charges, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     else  -- Start proecess

     BEGIN

        l_progress := 150;

     ---------------------------------------------------------------------
     -- For Blue Print org, setting Transaction Source , system linkage
     -- according to pa_posting_flag and pa_autoaccounting_flag
     ---------------------------------------------------------------------

        select NVL(pa_posting_flag,'N'),
               NVL(pa_autoaccounting_flag,'N')
        into l_blue_print_enabled_flag,
             l_autoaccounting_flag
        from pjm_org_parameters
        where organization_id = InvRec.Expenditure_Organization_Id;

        l_system_reference := NULL;
         if PoRec.destination_type_code = 'INVENTORY' then
   	  l_linkage := 'INV';
          If l_blue_print_enabled_flag = 'Y' then

            If l_autoaccounting_flag = 'Y' then
               /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_INV_NO_ACCOUNTS';
            else
               /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_INV_ACCOUNTS';

            end if; /* end of check for auto accounting */

          else
            l_transaction_source := 'Inventory';
            l_system_reference := 'PJM';
          end if;

        elsif PoRec.destination_type_code = 'SHOP FLOOR' then
  	  l_linkage := 'WIP';
          If l_blue_print_enabled_flag = 'Y' then
            If l_autoaccounting_flag = 'Y' then
              /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_WIP_NO_ACCOUNTS';
            else
              /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_WIP_ACCOUNTS';

            end if; /* end of check for auto accounting */
          else
            l_transaction_source := 'Work In Progress';
            l_system_reference := 'PJM';
	  end if;

        END IF; /* check for BP org */


        -------------------------------------------------
        -- Set the denom amount for bug 4169096
        -------------------------------------------------

        if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
        then
          l_denom_raw_cost := InvRec.Base_Charge_Amount;
          l_acct_raw_cost  := InvRec.Base_Charge_Amount;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Base_Charge_Amount;
            l_acct_burdened_cost  := InvRec.Base_Charge_Amount;
          end if;
        else
          l_denom_raw_cost := InvRec.Charge_Amount;
          select nvl(InvRec.Base_Charge_Amount, InvRec.Charge_Amount) into l_acct_raw_cost from dual;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Charge_Amount;
            l_acct_burdened_cost  := l_acct_raw_cost;
          end if;
        end if;


        -- Get Week Ending of Expenditure Item Date
        SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
        into l_week_ending_day_index
        FROM pa_implementations_all WHERE org_id = InvRec.Proj_Org_Id;

        select to_char(to_date('01-01-1950','DD-MM-YYYY') + l_week_ending_day_index - 1, 'Day')
        into l_week_ending_day from dual;

        select  next_day( trunc(InvRec.Expenditure_Item_Date)-1, l_week_ending_day )
        into    l_week_ending
        from    dual;

        PJM_CONC.put_line('...... Processing IPV, ERV, Tax Variances');

        -- Insert for Charges
        INSERT INTO pa_transaction_interface_all
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
         last_updated_by,
	 Inventory_Item_Id,
	 Unit_Of_Measure,
	 Wip_Resource_Id,
         Org_Id,
         cdl_system_reference4
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  l_week_ending  -- pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  l_linkage
        ,  l_trx_status_code
        ,  l_base_currency_code          /* denom_currency_code */
        ,  l_denom_raw_cost              /* denom_raw_cost */
        ,  l_denom_burdened_cost         /* denom_burdened_cost */
        ,  InvRec.Exchange_Date          /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate          /* acct_exchange_rate */
        ,  l_acct_raw_cost               /* acct_raw_cost */
        ,  l_acct_burdened_cost          /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
	,  PoRec.Item_Id
	,  l_uom
	,  PoRec.Wip_Resource_Id
        ,  InvRec.Org_Id
        ,  l_system_reference
        FROM
           AP_Invoice_Distributions_all DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id
--        AND  DIST.PA_Addition_Flag = 'S'
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     ----------------------------------------------------------------------
     -- Update pa_addition_flag to 'Y' for successful invoice distributions
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Flag Comp');
     PJM_CONC.put_line('... ' || fnd_message.get);
     PJM_CONC.new_line(1);

     l_progress := 160;

     UPDATE AP_Invoice_Distributions_all
     SET    Pa_Addition_Flag = 'Y',
            Request_Id = l_request_id
     WHERE  Invoice_Id = InvRec.Invoice_Id
     AND    Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     end if;  -- no project parameter

  END LOOP; -- End process data without project specified

  CLOSE IPV_NP_Curs;

  OPEN SPC_NP_Curs;

  LOOP  -- Start process Freight and Misc charge without project specified

     l_progress := 161;

     FETCH SPC_NP_Curs INTO InvRec;
     EXIT WHEN SPC_NP_Curs%NOTFOUND;

     l_progress := 162;

     ----------------------------------------------------------------------
     -- Get Accounting Currency Code
     ----------------------------------------------------------------------
     l_base_currency_code := InvRec.Invoice_Currency_Code;

     --------------------------------------------------------------------
     -- Get PO Value
     ---------------------------------------------------------------------

     OPEN Po_Data ( InvRec.Po_Distribution_ID );
     FETCH Po_Data INTO PoRec;
     CLOSE Po_Data;


     IF ( InvRec.Task_Id IS NOT NULL ) THEN
       l_Task_Id := InvRec.Task_Id;
     ELSE
       l_Task_Id := Assign_Task( InvRec.PO_Distribution_Id
                               , PoRec.Destination_Type_Code
                               , InvRec.Project_Id );
     END IF;

     PJM_CONC.put_line('   invoice_id ............ '||InvRec.Invoice_Id);
     PJM_CONC.put_line('   line_num .............. '||
                           InvRec.Invoice_Distribution_Id);
     PJM_CONC.put_line('   project_id ............ '||InvRec.Project_ID);
     PJM_CONC.put_line('   task_id ............... '||l_Task_Id);
     PJM_CONC.put_line('   expenditure_org_id .... '||
                           InvRec.Expenditure_Organization_ID);

     Timestamp;


     l_curr_invoice_id := InvRec.Invoice_Id;
     l_first_invoice := FALSE;

     ----------------------------------------------------------------------
     -- Get Expenditure Type
     ----------------------------------------------------------------------

     l_progress := 163;

     l_exp_type := Get_Charges_Expenditure_Type
		( invrec.line_type_lookup_code
		, invrec.project_id
		, invrec.expenditure_organization_id );

     PJM_CONC.put_line('   Invoice line type is .. '||invrec.line_type_lookup_code);
     PJM_CONC.put_line('   Charge amount ............ '||
                           InvRec.charge_amount);
     PJM_CONC.put_line('   Charge expenditure_type .. '||l_exp_type);
     PJM_CONC.put_line('   expenditure_comment ... '||
                           InvRec.Expenditure_Comment);
     PJM_CONC.new_line(1);

     ---------------------------------------------------------------------
     -- Set Expenditure Comment
     ---------------------------------------------------------------------
     l_progress := 164;

     select decode(invrec.line_type_lookup_code, 'IPV', l_IPV_Exp_Comment,
				'ERV', l_ERV_Exp_Comment,
				'FREIGHT', l_Freight_Exp_Comment,
				'TAX', l_Tax_Exp_Comment,
				'TIPV', l_Tax_Exp_Comment,
				'TERV', l_Tax_Exp_Comment,
				'TRV', l_Tax_Exp_Comment,
				'MISCELLANEOUS', l_Misc_Exp_Comment,
                                'NONREC_TAX', l_Tax_Exp_Comment,null) --bugfix 7482789
     into l_exp_comment
     from dual;

     ----------------------------------------------------------------------
     -- Getting Receipt Num from RCV_TRANSACTION_ID if exists
     ----------------------------------------------------------------------

     l_progress := 165;

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

     l_progress := 166;

     if ( InvRec.Exchange_Rate_Type is not null ) then

       SELECT User_Conversion_Type
       INTO   l_User_Conv_Type
       FROM   gl_daily_conversion_types
       WHERE  conversion_type = InvRec.Exchange_Rate_Type;

     else 	-- bug 4219497
       l_user_conv_type := null;

     end if;

     ----------------------------------------------------------------------
     -- Insert into PA_TRANSACTION_INTERFACES table
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Insert');
     PJM_CONC.put_line('... ' || fnd_message.get);

     if not ( InvRec.Dist_Code_Combination_Id is not null AND
              nvl(nvl(InvRec.Base_Charge_Amount,
                  InvRec.Charge_Amount) , 0) <> 0 ) then

        PJM_CONC.put_line('...... Charge amount not available, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     elsif ( l_Exp_Type is null) then

        PJM_CONC.put_line('...... Inv Org not setup to transfer charges, skipping...');
        -- Mark skipped record to 'G'
        UPDATE AP_Invoice_Distributions_all
        SET pa_addition_flag = 'G'
        WHERE invoice_distribution_id = ( select nvl(related_id, charge_applicable_to_dist_id)
			from ap_invoice_distributions_all
			where Invoice_Id = InvRec.Invoice_Id
                        and Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id);

     else  -- Start proecess

     BEGIN

        l_progress := 167;

     ---------------------------------------------------------------------
     -- For Blue Print org, setting Transaction Source , system linkage
     -- according to pa_posting_flag and pa_autoaccounting_flag
     ---------------------------------------------------------------------

        select NVL(pa_posting_flag,'N'),
               NVL(pa_autoaccounting_flag,'N')
        into l_blue_print_enabled_flag,
             l_autoaccounting_flag
        from pjm_org_parameters
        where organization_id = InvRec.Expenditure_Organization_Id;

        l_system_reference := NULL;
         if PoRec.destination_type_code = 'INVENTORY' then
   	  l_linkage := 'INV';
          If l_blue_print_enabled_flag = 'Y' then

            If l_autoaccounting_flag = 'Y' then
               /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_INV_NO_ACCOUNTS';
            else
               /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_INV_ACCOUNTS';

            end if; /* end of check for auto accounting */

          else
            l_transaction_source := 'Inventory';
            l_system_reference := 'PJM';
          end if;

        elsif PoRec.destination_type_code = 'SHOP FLOOR' then
  	  l_linkage := 'WIP';
          If l_blue_print_enabled_flag = 'Y' then
            If l_autoaccounting_flag = 'Y' then
              /* BP and autoaccounting  */
              l_transaction_source := 'PJM_CSTBP_WIP_NO_ACCOUNTS';
            else
              /* BP and no autoaccounting -- Send Account to PA */
              l_transaction_source := 'PJM_CSTBP_WIP_ACCOUNTS';

            end if; /* end of check for auto accounting */
          else
            l_transaction_source := 'Work In Progress';
            l_system_reference := 'PJM';
	  end if;

        END IF; /* check for BP org */


        -------------------------------------------------
        -- Set the denom amount for bug 4169096
        -------------------------------------------------

        if InvRec.Line_Type_Lookup_Code in ('ERV','TERV')
        then
          l_denom_raw_cost := InvRec.Base_Charge_Amount;
          l_acct_raw_cost  := InvRec.Base_Charge_Amount;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Base_Charge_Amount;
            l_acct_burdened_cost  := InvRec.Base_Charge_Amount;
          end if;
        else
          l_denom_raw_cost := InvRec.Charge_Amount;
          select nvl(InvRec.Base_Charge_Amount, InvRec.Charge_Amount) into l_acct_raw_cost from dual;
          if l_blue_print_enabled_flag = 'Y'
          then
            l_denom_burdened_cost := NULL;
            l_acct_burdened_cost  := NULL;
          else
            l_denom_burdened_cost := InvRec.Charge_Amount;
            l_acct_burdened_cost  := l_acct_raw_cost;
          end if;
        end if;


        -- Get Week Ending of Expenditure Item Date
        SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
        into l_week_ending_day_index
        FROM pa_implementations_all WHERE org_id = InvRec.Proj_Org_Id;

        select to_char(to_date('01-01-1950','DD-MM-YYYY') + l_week_ending_day_index - 1, 'Day')
        into l_week_ending_day from dual;

        select  next_day( trunc(InvRec.Expenditure_Item_Date)-1, l_week_ending_day )
        into    l_week_ending
        from    dual;

        PJM_CONC.put_line('...... Processing Special Charges');

        -- Insert for Charges
        INSERT INTO pa_transaction_interface_all
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
         last_updated_by,
	 Inventory_Item_Id,
	 Unit_Of_Measure,
	 Wip_Resource_Id,
         Org_Id,
         cdl_system_reference4
        )
        SELECT
           l_transaction_source
        ,  l_Batch_Name
        ,  l_week_ending  -- pa_utils.GetWeekEnding(InvRec.Expenditure_Item_Date)
        ,  NULL
        ,  ORG.Name
        ,  InvRec.Expenditure_Item_Date
        ,  InvRec.Project_Number
        ,  TASK.Task_Number
        ,  l_Exp_Type
        ,  InvRec.PA_Quantity
        ,  NVL( InvRec.Expenditure_Comment , l_Exp_Comment )
        ,  DIST.Invoice_Distribution_Id
        ,  'Y'
        ,  InvRec.Dist_Code_Combination_Id
        ,  InvRec.Accts_Pay_Code_Combination_Id
        ,  InvRec.PO_Distribution_Id
        ,  InvRec.RCV_Transaction_Id
        ,  l_receipt_num
        ,  DIST.Accounting_Date
        ,  l_linkage
        ,  l_trx_status_code
        ,  l_base_currency_code          /* denom_currency_code */
        ,  l_denom_raw_cost              /* denom_raw_cost */
        ,  l_denom_burdened_cost         /* denom_burdened_cost */
        ,  InvRec.Exchange_Date          /* acct_rate_date */
        ,  l_User_Conv_Type              /* acct_rate_type */
        ,  InvRec.Exchange_Rate          /* acct_exchange_rate */
        ,  l_acct_raw_cost               /* acct_raw_cost */
        ,  l_acct_burdened_cost          /* acct_burdened_cost */
        ,  SYSDATE
        ,  l_user_id
        ,  SYSDATE
        ,  l_user_id
	,  PoRec.Item_Id
	,  l_uom
	,  PoRec.Wip_Resource_Id
        ,  InvRec.Org_Id
        ,  l_system_reference
        FROM
           AP_Invoice_Distributions_all DIST
        ,  PA_Tasks TASK
        ,  HR_Organization_Units ORG
        WHERE
             DIST.Invoice_Id = InvRec.Invoice_Id
        AND  DIST.Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id
--        AND  DIST.PA_Addition_Flag = 'S'
        AND  ORG.Organization_Id = InvRec.Expenditure_Organization_Id
        AND  TASK.Task_Id = l_Task_Id;

     ----------------------------------------------------------------------
     -- Update pa_addition_flag to 'Y' for successful invoice distributions
     ----------------------------------------------------------------------

     fnd_message.set_name('PJM','CONC-APINV Flag Comp');
     PJM_CONC.put_line('... ' || fnd_message.get);
     PJM_CONC.new_line(1);

     l_progress := 168;

     UPDATE AP_Invoice_Distributions_all
     SET    Pa_Addition_Flag = 'Y',
            Request_Id = l_request_id
     WHERE  Invoice_Id = InvRec.Invoice_Id
     AND    Invoice_Distribution_Id = InvRec.Invoice_Distribution_Id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN DUP_VAL_ON_INDEX THEN
             NULL;
     END;

     end if;  -- no project parameter

  END LOOP; -- End process special charge without project specified

  CLOSE SPC_NP_Curs;


  END IF; -- End of both with project specified or without conditions

  COMMIT;
  fnd_message.set_name('PJM','CONC-APINV Finish Loop');
  PJM_CONC.put_line(fnd_message.get || ' ...');
  PJM_CONC.new_line(1);

  Timestamp;

  l_progress := 169;

  if (X_Submit_Trx_Import = 'Y') then
     l_imp_req_id := fnd_request.submit_request('PA','PAXTRTRX',
                                 'PRC: Transaction Import',
                                 NULL, FALSE,
                                 l_transaction_source,
                                 l_Batch_Name);
  end if;

  retcode := PJM_CONC.G_conc_success;
  return;


EXCEPTION
  when OTHERS then
       errbuf := 'IPV-'||l_progress||': '||sqlerrm;
       retcode := PJM_CONC.G_conc_failure;
       return;

END Transfer_Charges_TO_PA;


END PJM_TRANSFER_CHARGES_PKG;

/
