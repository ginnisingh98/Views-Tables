--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_TRANSFER" AS
-- $Header: PAXVTRXB.pls 120.4.12010000.2 2008/10/01 03:46:37 arbandyo ship $

Procedure Validate_Tax_Id ( P_Project_ID            IN      Number,
                            P_Draft_Invoice_Num     IN      Number,
                            P_Trx_Date              IN      Date,
                            X_Reject_Code           OUT     NOCOPY Varchar2) IS --File.Sql.39 bug 4440895

  pl_dummy   varchar2(1);

BEGIN

  X_Reject_Code := NULL;

  -- Check any invoice line has invalid tax id

  Select 'x'
  Into   pl_dummy
  from   pa_draft_invoice_items dii
  where  draft_invoice_num    = P_Draft_Invoice_Num
  and    project_id           = P_Project_ID
--  and    output_vat_tax_id is not null
  and    output_tax_classification_code is not null
  and    not exists ( select 'x'
                      from   pa_output_tax_code_txn_v tax
		      where  tax.tax_code = dii.output_tax_classification_code)
                      /* where  P_Trx_Date >= start_date_active
                      and    P_Trx_Date <= nvl(end_date_active,P_Trx_Date) */  /* commented for bug 5484859 */
--                      and    vat_tax_id  = output_vat_tax_id)
  and    rownum = 1;

  X_Reject_Code  := 'INVALID_TAX_CODE';

Exception

  When NO_DATA_FOUND
  Then
       Null;

  When Others
  Then
       Raise;

END Validate_Tax_Id;

Procedure Client_Extn_Driver( 	P_Project_ID		IN	Number,
				P_Draft_Invoice_Num	IN	Number,
				P_Draft_Invoice_Type 	IN	Varchar2,
				P_AR_Trx_Type		IN	Varchar2,
				X_AR_Trx_Type		OUT	NOCOPY Varchar2, --File.Sql.39 bug 4440895
				X_Reject_Code		OUT	NOCOPY Varchar2 ) IS --File.Sql.39 bug 4440895

Invoice_Class Varchar2(15);
Invoice_Amount Number;
Project_Amount Number;
Invoice_Date   Date;
Inv_Currency_Code Varchar2(15);
Project_Currency_Code Varchar2(15);
Err_Status Number;
Reject_Code Varchar2(30);
P_AR_Trx_Type_ID Number := to_number(P_AR_Trx_Type);
	-- Trx type ID is passed as character string.
AR_Trx_Type Varchar2(30);
AR_Trx_Type_ID Number;

BEGIN

X_Reject_Code := NULL;
X_AR_Trx_Type := NULL;
Reject_Code := NULL;
AR_Trx_Type := NULL;

-- Determine the Invoice Date

Select I.Invoice_Date, I.Inv_Currency_Code, P.Project_Currency_Code
Into   Invoice_date, Inv_Currency_Code, Project_Currency_Code
From   PA_Draft_Invoices I, PA_Projects P
WHERE  P.Project_id = P_Project_ID
AND    I.Project_id = P_Project_ID
AND    Draft_Invoice_Num = P_Draft_Invoice_Num;

-- Determine the invoice amount

Select Sum(Item.Amount), Sum(Item.Inv_Amount)
Into  Project_Amount, Invoice_Amount
From  PA_Draft_Invoice_Items Item
Where Item.Project_ID = P_Project_ID
And   Item.Draft_Invoice_Num = P_Draft_Invoice_Num
And   Item.Invoice_Line_Type <> 'NET ZERO ADJUSTMENT';

-- Determine the Invoice Class

IF P_Draft_Invoice_Type = 'P' then
	Invoice_Class := 'INVOICE';
ELSIF P_Draft_Invoice_Type = 'WO' then
	Invoice_Class := 'WRITE_OFF';
ELSE
	Select decode(Orig.Canceled_Flag,'Y','CANCEL','CREDIT_MEMO')
	Into	Invoice_Class
	From	PA_Draft_Invoices Orig,
		PA_Draft_Invoices Curr
	Where	Curr.Project_ID = P_Project_ID
	AND	Curr.Draft_Invoice_Num = P_Draft_Invoice_Num
	AND	Orig.Project_ID = Curr.Project_ID
	AND	Orig.Draft_Invoice_Num = Curr.Draft_Invoice_Num_Credited;
END IF;

-- Call the Client Extn

PA_Client_Extn_Inv_Transfer.Get_AR_Trx_Type( P_Project_ID,
					P_Draft_Invoice_Num,
					Invoice_Class,
                                        Project_Amount,
                                        Project_Currency_Code,
                                        Inv_Currency_Code,
					Invoice_Amount,
					P_AR_Trx_Type_ID,
					AR_Trx_Type_ID,
					Err_Status );

-- Validate the Returned AR Trx Type and Null Tax id in Invoice Line

IF (Err_Status = 0) AND (AR_Trx_Type_ID IS NULL) then
-- Validate the orig AR Trx Type,Null Tax id in Invoice Line and return
	Validate_AR_Trx_Type( P_AR_Trx_Type_ID,P_Project_ID,P_Draft_Invoice_Num,
                              Invoice_Date, AR_Trx_Type, Reject_Code );
	X_Reject_Code := Reject_Code;
	X_AR_Trx_Type := P_AR_Trx_Type;
Elsif (Err_Status < 0) then
	X_Reject_Code := 'PA_CLIENT_EXTN_ORACLE_ERROR';
	X_AR_Trx_Type := NULL;
Elsif (Err_Status > 0) then
	X_Reject_Code := 'PA_CLIENT_EXTN_APP_ERROR';
	X_AR_Trx_Type := NULL;
Else
-- Validate the client AR Trx Type,Null Tax id in Invoice Line and return
	Validate_AR_Trx_Type( AR_Trx_Type_ID,P_Project_ID,P_Draft_Invoice_Num,
                              Invoice_Date, AR_Trx_Type, Reject_Code );
	X_Reject_Code := Reject_Code;
	X_AR_Trx_Type := to_char(AR_Trx_Type_ID); -- return ID as character string.
END IF;

-- If Invoice line has invalid tax code , error out the invoice

Validate_Tax_Id ( P_Project_ID,
                  P_Draft_Invoice_Num,
                  Invoice_Date,
                  Reject_Code);
If  Reject_Code Is not Null
Then
    X_Reject_Code := Reject_Code;
End If;

EXCEPTION

When OTHERS then

 /* ATG Changes */
     X_AR_Trx_Type := null;

	RAISE;

END Client_Extn_Driver;

-------------------------------

Procedure Validate_AR_Trx_Type ( 	P_AR_Trx_Type_ID IN	Number,
                                        P_Project_Id     IN     Number,
                                        P_Draft_Inv_Num  IN     Number,
                                        P_Invoice_Date   IN     Date,
					X_AR_Trx_Type	OUT 	NOCOPY Varchar2, --File.Sql.39 bug 4440895
					X_Reject_Code	OUT	NOCOPY Varchar2 ) IS --File.Sql.39 bug 4440895

AR_Trx_Type Varchar2(30) := NULL;
/* AR_Tax_Flag Varchar2(1)  := NULL; Commented for bug 7348841 */
l_dummy     Varchar2(1) ;
l_step      Number       := 0;

BEGIN

X_Reject_Code := NULL;
X_AR_Trx_Type := NULL;

/* Included for Bug#2423626 to check creation_sign */
-- Validate AR Trx Sign
l_step   := 5;

Select  Name
        /* Tax_Calculation_Flag Commented for bug 7348841 */
Into    AR_Trx_Type
        /* AR_Tax_Flag commented for bug 7348841 */
From    RA_Cust_Trx_Types
Where   Cust_Trx_Type_ID = P_AR_Trx_Type_ID
AND     Type IN ('INV','CM')
AND     Creation_Sign = 'A'
AND     Start_Date <= P_Invoice_Date
AND     NVL(End_Date, P_Invoice_Date+1) >= P_Invoice_Date
AND     Rownum = 1;
/* end of code fix for Bug#2423626 */

-- Validate AR Trx Type
l_step   := 10;

Select 	Name
        /* Tax_Calculation_Flag commented for bug 7348841 */
Into 	AR_Trx_Type
        /* AR_Tax_Flag coomented for bug 7348841 */
From 	RA_Cust_Trx_Types
Where	Cust_Trx_Type_ID = P_AR_Trx_Type_ID
AND	Type IN ('INV','CM')
AND	Accounting_Affect_Flag = 'Y'
AND	Creation_Sign = 'A'
AND	POST_TO_GL = 'Y'
AND     Start_Date <= P_Invoice_Date
AND     NVL(End_Date, P_Invoice_Date+1) >= P_Invoice_Date
AND	Rownum = 1;

-- Validation OK for AR Transaction type

-- Validate whether any line with null tax id is to be transferred

l_step   := 20;

/* Added the check draft_inv_line_num_credited is null as the
following check is necessary only for invoices and not for credit memos - For bug 2973011 */

/* If  AR_Tax_Flag = 'Y'
Then
    Select 'x'
    Into   l_dummy
    From   PA_Draft_Invoice_Items
    Where  Project_id    = P_Project_Id
    And    Draft_Invoice_num = P_Draft_Inv_Num
    AND    output_tax_classification_code IS NULL
--    And    Output_vat_tax_id is Null
    AND    draft_inv_line_num_credited is null    /* For bug 2973011
    And    Invoice_Line_type <>  'NET ZERO ADJUSTMENT'
    And    rownum  = 1;

    X_Reject_Code := 'NO_OUTPUT_TAX_CODE';

End if; commented for bug 7348841 */

EXCEPTION

-- Error

When NO_DATA_FOUND then
    If l_step = 5                                   /* Bug#2423626 */
    Then                                            /* Bug#2423626 */
        X_Reject_Code := 'INVALID_AR_TRX_SIGN';     /* Bug#2423626 */
        X_AR_Trx_Type := NULL;                      /* Bug#2423626 */
    Elsif l_step = 10
    Then
        X_Reject_Code := 'INVALID_AR_TRX_TYPE';
        X_AR_Trx_Type := NULL;
    Elsif l_step = 20
    Then
        X_Reject_Code := NULL;
    End If;

   /* ATG Changes */
       X_AR_Trx_Type := null;


When OTHERS then

    /* ATG Changes */
       X_AR_Trx_Type := null;

	RAISE;

END Validate_AR_Trx_Type;

-------------------------------

END PA_Invoice_Transfer;

/
