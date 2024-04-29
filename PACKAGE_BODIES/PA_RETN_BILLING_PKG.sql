--------------------------------------------------------
--  DDL for Package Body PA_RETN_BILLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RETN_BILLING_PKG" AS
/* $Header: PAXIRTBB.pls 120.6.12010000.3 2010/02/15 06:21:15 rmandali ship $ */

-- Function to get the Reten Invoice Format
-- Build the retention billing invoice format

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

Function Get_Retn_Billing_Inv_Format(p_project_id NUMBER)
			 RETURN pa_retn_billing_pkg.TabRetnBillingInvFmt IS

CURSOR cur_inv_group_columns IS SELECT  grp.column_code column_code,
                                        fmtdet.text text,
    					fmtdet.start_position start_position,
                                        fmtdet.end_position end_position,
                                        NVL(fmtdet.right_justify_flag,'N') right_justify_flag
                                FROM    pa_invoice_group_columns grp,
                                        pa_invoice_formats fmt,
                                        pa_invoice_format_details fmtdet,
                                        pa_projects_all pr
                                WHERE   pr.retn_billing_inv_format_id = fmt.invoice_format_id
                                  AND   fmt.invoice_format_id = fmtdet.invoice_format_id
                                  AND   grp.invoice_group_column_id = fmtdet.invoice_group_column_id
                                  and   pr.project_id =p_project_id
                                ORDER BY fmtdet.start_position;

Cnt             NUMBER :=0;

InvGroupColumnsRec      cur_Inv_Group_columns%ROWTYPE;

TmpRetnLineFmt          pa_retn_billing_pkg.TabRetnBillingInvFmt;

BEGIN
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Entering pa_retn_billing_pkg.Get_Retn_Billing_Inv_Format');
       END IF;

        OPEN cur_inv_group_columns;
        LOOP

        	FETCH cur_inv_group_columns INTO InvGroupColumnsRec;

        	EXIT WHEN cur_inv_group_columns%NOTFOUND;

        	cnt  := cnt +1;

        	TmpRetnLineFmt(Cnt).column_code :=InvGroupColumnsRec.column_code;

        	TmpRetnLineFmt(Cnt).column_value :='N';

        	TmpRetnLineFmt(Cnt).usertext := InvGroupColumnsRec.text;

        	TmpRetnLineFmt(Cnt).start_position := InvGroupColumnsRec.start_position;
        	TmpRetnLineFmt(Cnt).end_position := InvGroupColumnsRec.end_position;
        	TmpRetnLineFmt(Cnt).right_justify_flag := InvGroupColumnsRec.right_justify_flag;

       		IF g1_debug_mode  = 'Y' THEN
       			pa_retention_util.write_log('Get_Retn_Billing_Inv_Format: ' || 'Format Column : ' || InvGroupColumnsRec.column_code);
       		END IF;

        END LOOP;

        CLOSE cur_inv_group_columns;

       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Leaving pa_retn_billing_pkg.Get_Retn_Billing_Inv_Format');
       END IF;

RETURN TmpRetnLineFmt;
EXCEPTION
WHEN OTHERS THEN
	pa_retn_billing_pkg.G_ERROR_CODE :='E';
	RETURN TmpRetnLineFmt;

END Get_Retn_Billing_Inv_Format;

FUNCTION CheckInvoiceExists(    p_project_id    IN      NUMBER,
                                p_agreement_id  IN      NUMBER,
                                p_request_id    IN      VARCHAR2) RETURN VARCHAR2 IS

ExistsFlag	VARCHAR2(1) := 'N';

BEGIN
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Enterting pa_retn_billing_pkg.CheckInvoiceExists');
       END IF;

	BEGIN
		SELECT  'Y'
		  INTO ExistsFlag
		FROM   DUAL
		WHERE EXISTS(SELECT NULL
			       FROM pa_draft_invoices_all
			      WHERE  project_id = p_project_id
		                AND  agreement_id = p_agreement_id
		  		AND  request_id =   p_request_id
		  		AND  NVL(retention_invoice_flag,'N') = 'Y');
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			ExistsFlag := 'N';
		WHEN OTHERS THEN
			pa_retn_billing_pkg.G_ERROR_CODE :='E';
			RAISE;

	END;
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('CheckInvoiceExists   : ' || ExistsFlag);
       	pa_retention_util.write_log('Leaving pa_retn_billing_pkg.CheckInvoiceExists');
       END IF;

RETURN(ExistsFlag);

END CheckInvoiceExists;

--- Procedure  	Build_Retn_Invoice_Header
--- Purpose 	This is used to Builed the invoice header
--		If the retention level is project level then it will create a
--		Invoice Header for each agreements.
--		If the retention level is Top Task, for an agreement, there will be
--		only one header

PROCEDURE Build_Retn_Invoice_Header(p_project_id 		IN 	NUMBER,
				    p_agreement_id 		IN 	NUMBER,
				    p_customer_id  		IN 	NUMBER,
				    p_request_id 		IN 	NUMBER,
				    x_draft_invoice_num		OUT 	NOCOPY NUMBER, --File.Sql.39 bug 4440895
             			    x_output_tax_code           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             			    X_Output_tax_exempt_flag 	OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             			    X_Output_tax_exempt_number 	OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             			    X_Output_exempt_reason_code OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   ) IS

TmpCustBillSplit	NUMBER;
TmpInvoiceDate		DATE:= TO_DATE(pa_billing.globvars.InvoiceDate , 'YYYY/MM/DD');
TmpBillThruDate		DATE:= TO_DATE(pa_billing.globvars.BillThruDate, 'YYYY/MM/DD');
TmpPADate		DATE:= TO_DATE(pa_billing.globvars.PADate, 'YYYY/MM/DD');
TmpGLDate		DATE:= TO_DATE(pa_billing.globvars.GLDate, 'YYYY/MM/DD');
TmpDraftInvoiceNUm	NUMBER:=0;
TmpInvoiceSetId		NUMBER;
TmpInvoiceComment	VARCHAR2(240);
TmpInvCurrency		VARCHAR2(15);
TmpInvCurrRateType	VARCHAR2(30) :=NULL;
TmpInvCurrRateDate	DATE :=null;
TmpInvCurrRate		NUMBER := null;
TmpInvProcCurrency	VARCHAR2(15);
TmpFundingCurrency	VARCHAR2(15);
TmpBillToAddressID	NUMBER;
TmpShipToAddressID	NUMBER;
TmpRetnTaxCode		VARCHAR2(30);
TmpLanguage		VARCHAR2(30);
TmpCreditHold		VARCHAR2(1);
TmpSiteUSeId1		NUMBER;
TmpSiteUSeId2		NUMBER;
TmpInvoiceNum		NUMBER;


TmpProgId               NUMBER:= fnd_global.conc_program_id;
TmpProgApplId      	NUMBER:= fnd_global.prog_appl_id;
l_program_update_date   DATE  := sysdate;
l_last_update_date      DATE  := sysdate;
l_last_updated_by       NUMBER:= fnd_global.user_id;
l_last_update_login     NUMBER:= fnd_global.login_id;
TmpUserId             	NUMBER:= fnd_global.user_id;

--Tmp_Output_vat_tax_id              NUMBER;
Tmp_output_tax_code                VARCHAR2(30);
Tmp_Output_tax_exempt_flag         VARCHAR2(2);
--Tmp_Output_tax_exempt_number       VARCHAR2(30); --Modified for Bug3128094
Tmp_Output_tax_exempt_number       VARCHAR2(80);
Tmp_Output_exempt_reason_code      VARCHAR2(30);
TmpSetofBooks		NUMBER;

TmpWarningMsg		VARCHAR2(80);
TmpWarningCode		VARCHAR2(30);
TmpInvByBTC		VARCHAR2(1);
TmpRetnBillInvFmtId	NUMBER:=0;
TmpCustomerid           NUMBER;
TmpBilltocustomerid     NUMBER;
TmpShiptocustomerid     NUMBER;  /*Added for customer account relation enhancement 2760630*/
TmpBilltocontactid      NUMBER;
TmpShiptocontactid      NUMBER;
TmpPaymentSetid         NUMBER; /*Federal Changes */

/* Shared services changes: local variable to store org ID from org context */
l_org_id                NUMBER;
BEGIN
       		IF g1_debug_mode  = 'Y' THEN
       			pa_retention_util.write_log('Entering pa_retn_billing_pkg.Build_Retn_Invoice_Header');
       			pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'AgreementId  : ' || p_agreement_id);
       			pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Project Id  : ' || p_project_id);
       			pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Customer Id  : ' || p_customer_id);
       			pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Request Id  : ' || p_request_id);
       		END IF;

/* TCA changes
                select DISTINCT
                       nvl(cp1.credit_hold, cp.credit_hold),
                       to_char(c.customer_bill_split),
                       c.bill_to_address_id,
                       c.ship_to_address_id,
                       ras.site_use_id,
                       ras1.site_use_id,
                       addr.language,
                       a.agreement_currency_code,
		       pr.invoice_comment,
		       pr.retention_tax_code,
		       NVL(pr.inv_by_bill_trans_curr_flag ,'N'),
		       DECODE(pr.invproc_currency_type,
				'PROJECT_CURRENCY',pr.project_currency_code,
			        'PROJFUNC_CURRENCY',pr.projfunc_currency_code,
			        'FUNDING_CURRENCY', a.agreement_currency_code),
		      NVL(pr.retn_billing_inv_format_id,0),
                      c.customer_id,
                      c.bill_to_customer_id,
                      c.ship_to_customer_id
*/
                select DISTINCT
                       DECODE(hz_cp1.credit_hold,NULL,hz_cp.credit_hold,'N',hz_cp.credit_hold,hz_cp1.credit_hold),  /* Modified for bug 9251471 */
                       to_char(c.customer_bill_split),
                       c.bill_to_address_id,
                       c.ship_to_address_id,
                       hz_site.site_use_id,
                       hz_site1.site_use_id,
                       addr.language,
                       a.agreement_currency_code,
		       pr.invoice_comment,
		       pr.retention_tax_code,
		       NVL(pr.inv_by_bill_trans_curr_flag ,'N'),
		       DECODE(pr.invproc_currency_type,
				'PROJECT_CURRENCY',pr.project_currency_code,
			        'PROJFUNC_CURRENCY',pr.projfunc_currency_code,
			        'FUNDING_CURRENCY', a.agreement_currency_code),
		      NVL(pr.retn_billing_inv_format_id,0),
                      c.customer_id,
                      c.bill_to_customer_id,
                      c.ship_to_customer_id,
                      a.payment_set_id
		INTO
		       TmpCreditHold,
		       TmpCustBillSplit,
		       TmpBillToAddressID,
		       TmpShipToAddressID,
		       TmpSiteUSeId1,
		       TmpSiteUseId2,
		       TmpLanguage,
		       TmpFundingCurrency,
		       TmpInvoiceComment,
		       TmpRetnTaxCode,
		       TmpInvByBTC,
		       TmpInvProcCurrency,
		       TmpRetnBillInvFmtId,
                       TmpCustomerid,
                       TmpBilltocustomerid,
                       TmpShiptocustomerid,
                       TmpPaymentSetid
/* TCA changes
                from   ar_customer_profiles cp1,
                       ra_customers rc,
                       ra_customers rc1, --Added for customer account relation
		       ar_customer_profiles cp,
                       ra_site_uses ras,
		       pa_project_customers c,
                       pa_agreements_all a,
                       pa_projects pr,
		       ra_site_uses ras1,
		       ra_addresses addr
*/
                from   hz_customer_profiles hz_cp1,
                       hz_cust_accounts hz_c,
                       hz_cust_accounts hz_c1,
		       hz_customer_profiles hz_cp,
                       hz_cust_site_uses hz_site,
		       pa_project_customers c,
                       pa_agreements_all a,
                       pa_projects pr,
		       hz_cust_site_uses hz_site1,
		       hz_cust_acct_sites addr
     where a.agreement_id = p_agreement_id
                and   pr.project_id = p_project_id
                and   pr.project_id = c.project_id
                and   a.customer_id = c.customer_id
/*              and   c.customer_id = cp.customer_id commented for customer account relation enhancement*/
/* TCA changes
                and   c.bill_to_customer_id = cp.customer_id
                and   c.bill_to_customer_id = rc1.customer_id
                and   nvl(rc1.status,'A') = 'A'
*/
                and   c.bill_to_customer_id = hz_cp.cust_account_id
                and   c.bill_to_customer_id = hz_c1.cust_account_id
                and   nvl(hz_c1.status,'A') = 'A'
/*End of change for customer account relation enhancement*/
/* TCA changes
                and   c.customer_id = rc.customer_id
*/
                and   c.customer_id = hz_c.cust_account_id
                -- and   c.customer_bill_split <> 0 -- commented for FP_M Changes
		and   Decode( pr.Enable_Top_Task_Customer_Flag, 'Y', 100,
                                 decode(pr.date_eff_funds_consumption, 'Y', 100, c.customer_bill_split )) <> 0 -- FP_M changes
/* TCA changes
                and   nvl(rc.status,'A') = 'A'
                and   cp.site_use_id is null
                and   ras.address_id = c.bill_to_address_id
                and   ras.site_use_code  = 'BILL_TO'
                and   ras.status = 'A'
                and   ras1.address_id = c.ship_to_address_id
                and   ras1.site_use_code = 'SHIP_TO'
                and   ras1.status = 'A'
                and   addr.address_id = c.bill_to_address_id
                and   cp1.site_use_id(+) = ras.site_use_id
*/
                and   nvl(hz_c.status,'A') = 'A'
                and   hz_cp.site_use_id is null
                and   hz_site.cust_acct_site_id = c.bill_to_address_id
                and   hz_site.site_use_code  = 'BILL_TO'
                and   hz_site.status = 'A'
                and   hz_site1.cust_acct_site_id = c.ship_to_address_id
                and   hz_site1.site_use_code = 'SHIP_TO'
                and   hz_site1.status = 'A'
                and   addr.cust_acct_site_id = c.bill_to_address_id
                and   hz_cp1.site_use_id(+) = hz_site.site_use_id

/*Added for customer account relation enhancement bug no 2760630*/
                and NOT EXISTS
                        (
/* Removed the existing code for perf bug 3607384 and added the below */
                             SELECT NULL
                               FROM PA_IMPLEMENTATIONS I
                              WHERE I.CUST_ACC_REL_CODE = 'Y'
                                AND exists ( select 1 from HZ_CUST_ACCT_RELATE HZ1,
                                                           PA_PROJECT_CUSTOMERS C
                                              where   C.PROJECT_ID=p_project_id
                                                AND     ( HZ1.CUST_ACCOUNT_ID(+) = C.CUSTOMER_ID
                                                          AND HZ1.RELATED_CUST_ACCOUNT_ID(+) = C.BILL_TO_CUSTOMER_ID
                                                          AND (NVL(HZ1.STATUS,'A') <>'A'
                                                                  OR   NVL(HZ1.BILL_TO_FLAG,'Y') <>'Y')
                                                          AND  C.CUSTOMER_ID <> C.BILL_TO_CUSTOMER_ID
                                                        ))
                             UNION ALL
                             SELECT NULL
                               FROM PA_IMPLEMENTATIONS I
                              WHERE I.CUST_ACC_REL_CODE = 'Y'
                                AND exists ( select 1 from HZ_CUST_ACCT_RELATE HZ1,
                                                           PA_PROJECT_CUSTOMERS C
                                              where   C.PROJECT_ID=p_project_id
                                                AND     ( HZ1.CUST_ACCOUNT_ID(+) = C.CUSTOMER_ID
                                                          AND HZ1.RELATED_CUST_ACCOUNT_ID(+) = C.SHIP_TO_CUSTOMER_ID
                                                          AND (NVL(HZ1.STATUS,'A') <>'A'
                                                                  OR   NVL(HZ1.SHIP_TO_FLAG,'Y') <>'Y')
                                                          AND  C.CUSTOMER_ID <> C.SHIP_TO_CUSTOMER_ID
                                                        ))
                              UNION ALL
                              SELECT NULL
                                FROM PA_IMPLEMENTATIONS I
                               WHERE I.cust_acc_rel_code = 'N'
                                 AND exists (select 1 from PA_PROJECT_CUSTOMERS C
                                              WHERE C.PROJECT_ID = p_project_id
                                                AND ( C.CUSTOMER_ID <> C.BILL_TO_CUSTOMER_ID
                                                               OR  C.CUSTOMER_ID<>C.SHIP_TO_CUSTOMER_ID))

                          );

            SELECT     MIN(PROJCON.Contact_ID),
                      decode(MAX(decode(ROLE.Primary_Flag, 'Y', CONT.Contact_ID, -1)),
                             -1, decode(MIN(CONT.Contact_ID), 0, NULL, MIN(CONT.Contact_ID)),
                             MAX(decode(ROLE.Primary_Flag, 'Y', CONT.Contact_ID, -1)))
              INTO     TmpBilltocontactid,
                       TmpShiptocontactid
              FROM     pa_project_contacts projcon,
                       pa_project_contacts cont,
                       pa_project_customers c,
                       hz_role_responsibility role,
/* TCA changes
                       ra_contact_roles role,
*/
                       pa_agreements_all a  /*Added for bug2984282*/
              WHERE   c.project_id=p_project_id
                and   a.agreement_id=p_agreement_id
                and   c.customer_id=p_customer_id/*Added for bug 2984282*/
                and   projcon.project_contact_type_code  = 'BILLING'
                and   projcon.customer_id  =c.customer_id
                and   projcon.project_ID  = c.project_id
                and   cont.project_ID (+) =  c.project_id
                and   cont.customer_ID (+) = c.customer_id
                and   cont.project_Contact_Type_Code (+) = 'SHIPPING'
/* TCA changes
                and   role.cust_account_role_id (+) = CONT.Contact_ID
                and   role.responsibility_type (+) = 'SHIP_TO'
*/
                and   role.cust_account_role_id (+) = CONT.Contact_ID
                and   role.responsibility_type (+) = 'SHIP_TO'
                and  NOT EXISTS (SELECT    NULL
                            FROM PA_PROJECT_CUSTOMERS c1
                           WHERE c1.project_id=p_project_id
                             AND NOT EXISTS
                                     (
                                       SELECT NULL
                                         FROM     pa_project_contacts projcon
                                        WHERE   projcon.project_contact_type_code  = 'BILLING'
                                          AND   projcon.customer_id  =c1.customer_id
                                          AND   projcon.project_ID  = c1.project_id)
                         );

/* Bug#5689735 -  Retention invoices are not generated if  Billing Contact is not defined
   Fix : Commented the existing code. Now retention invoice will get create if billing contact is not defined */

/*
   IF TmpBilltocontactid IS NULL THEN
      RAISE NO_DATA_FOUND;
   END IF;
*/

/*End of change for customer account relation enhancement bug no 2760630 */
          PA_INVOICE_CURRENCY.get_proj_curr_info(p_project_id,
                                               TmpInvCurrency);

	   pa_retn_billing_pkg.G_Inv_By_Bill_Trans_Currency := TmpInvByBtc;

	  IF pa_billing.Globvars.InvoiceSetId IS NULL THEN

		-- Generate a set id, happens only user run the retention invoice generation

		SELECT PA_DRAFT_INVOICES_S.NEXTVAL
                INTO   TmpInvoiceSetId
                FROM   DUAL;

	  ELSE
		TmpInvoiceSetId := pa_billing.Globvars.InvoiceSetId;
	  END IF;

       	   IF g1_debug_mode  = 'Y' THEN
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'TmpInvoiceSetId   : ' || TmpInvoiceSetId);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Credit Hold       : ' || TmpCreditHold);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'TmpPaymentSetId   : ' || TmpPaymentSetId);
       	   END IF;


	-- Get the new draft invoice num


	 SELECT NVL( MAX(p.draft_invoice_num) + 1, 1)
           INTO TmpInvoiceNum
           FROM pa_draft_invoices_all p
	   WHERE p.project_id = p_project_id;

       	   IF g1_debug_mode  = 'Y' THEN
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'New Invoice Num   : ' || TmpInvoiceNum);
       	   END IF;

	--- Get the set of books id
	 SELECT imp.set_of_books_id
           INTO TmpSetOfBooks
           FROM pa_implementations imp;

       	   IF g1_debug_mode  = 'Y' THEN
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'TmpSetOfBooks   : ' || TmpSetOfBooks);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Call PA_OUTPUT_TAX.GET_DEFAULT_TAX_INFO');
       	   END IF;

	--- Call Tax Information

	PA_OUTPUT_TAX.GET_DEFAULT_TAX_INFO
           ( P_Project_Id=>p_project_id,
             P_Draft_Inv_Num=>TmpInvoiceNum,
             P_Customer_Id  =>p_customer_id,
 /*           P_Bill_to_site_use_id=>TmpBillToAddressID,
             P_Ship_to_site_use_id=>TmpShipToAddressID,  commented for bug 2938422 */
             P_Bill_to_site_use_id=>TmpSiteUSeId1,
             P_Ship_to_site_use_id=>TmpSiteUSeId2,
             P_Sets_of_books_id   =>TmpSetOfBooks,
             P_User_Id  =>TmpUserId,
             P_Request_id =>P_request_id,
--             X_Output_vat_tax_id=>Tmp_Output_vat_tax_id,
             X_output_tax_code => Tmp_output_tax_code,
             X_Output_tax_exempt_flag=>Tmp_Output_tax_exempt_flag ,
             X_Output_tax_exempt_number =>Tmp_Output_tax_exempt_number,
             X_Output_exempt_reason_code =>Tmp_Output_exempt_reason_code,
             Pbill_to_customer_id =>TmpBilltocustomerid,
             Pship_to_customer_id => TmpShiptocustomerid);
/*The last two parameters in the above call added for customer account relation
  enhancement bug no 2760630*/

--             X_Output_vat_tax_id :=Tmp_Output_vat_tax_id;
             X_output_tax_code := Tmp_Output_Tax_Code;
             X_Output_tax_exempt_flag :=Tmp_Output_tax_exempt_flag ;
             X_Output_tax_exempt_number :=Tmp_Output_tax_exempt_number;
             X_Output_exempt_reason_code :=Tmp_Output_exempt_reason_code;

       	   IF g1_debug_mode  = 'Y' THEN
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Tax Information: ');
--       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'X_Output_vat_tax_id : ' || X_Output_vat_tax_id);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'X_Output_tax_code : ' || X_Output_tax_code);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'X_Output_tax_exempt_flag : ' || X_Output_tax_exempt_flag);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'X_Output_tax_exempt_number : ' || X_Output_tax_exempt_number);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'X_Output_exempt_reason_code : ' || X_Output_exempt_reason_code);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Invoice Currency  : ' || TmpInvCurrency );
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Insert into Invoice Header ');
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Invoice Currency  : ' || TmpInvCurrency );
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Bill By Bill Trans Currency  : ' || TmpInvByBTC);
       	   END IF;
	   IF TmpInvByBTC='Y' THEN
		TmpInvCurrency := TmpInvProcCurrency;
       	   	IF g1_debug_mode  = 'Y' THEN
       	   		pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Assing IPC to Invoice Currency  : ' || TmpInvCurrency);
       	   	END IF;
	   END IF;
       	   IF g1_debug_mode  = 'Y' THEN
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Invoice Currency  : ' || TmpInvCurrency);
       	   	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Bill Thru Date    : ' || pa_billing.GetBillThruDate);
       	   END IF;

	    IF TmpCreditHold ='Y' OR NVL(TmpRetnBillInvFmtID,0) = 0 THEN

			IF TmpCreditHold ='Y' THEN
				-- If the customer is on credit-hold, insert a warning
				-- TmpWarningMsg :='Customer has been put on billing hold.
			     --  Invoice cannot be generated.';

				TmpWarningCode :='CREDIT_HOLD';


		        ELSIF TmpRetnBillInvFmtID = 0 THEN

				TmpWarningCode :='NO_RETN_BILL_INVOICE_FORMAT';

			END IF;

       	   	        IF g1_debug_mode  = 'Y' THEN
       	   	        	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Warning : ' || TmpWarningCode);
       	   	        END IF;

	 		SELECT 	lk.meaning
           		  INTO 	TmpWarningMsg
           		  FROM 	pa_lookups lk
	   		  WHERE lk.lookup_code = TmpWarningCode
	     		    AND lk.lookup_type = 'INVOICE DISTRIBUTION WARNING';

       	   	        IF g1_debug_mode  = 'Y' THEN
       	   	        	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Warning Code : ' || TmpWarningCode);
       	   	        	pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Warning Mesg : ' || TmpWarningMsg);
       	   	        END IF;
	   END IF;

/* Shared services changes: get org id from org context, and
   insert it into table pa_draft_invoices as ORG_ID. */
           l_org_id := MO_GLOBAL.get_current_org_id;

	-- Insert a new invoice header
/*Last 5 columns added for customer account relation enhancement bug no 2760630*/
	     INSERT INTO PA_DRAFT_INVOICES (
        	DRAFT_INVOICE_NUM, 	PROJECT_ID,
		AGREEMENT_ID, 		LAST_UPDATE_DATE,
        	LAST_UPDATED_BY, 	CREATION_DATE,
		CREATED_BY, 		TRANSFER_STATUS_CODE,
        	GENERATION_ERROR_FLAG, 	PA_DATE,
		REQUEST_ID, 		PROGRAM_APPLICATION_ID,
        	PROGRAM_ID, 		Program_Update_Date,
		BILL_THROUGH_DATE, 	TRANSFER_REJECTION_REASON,
		RETENTION_PERCENTAGE,   Unearned_Revenue_CR,
		Unbilled_Receivable_DR,
		-- Invoice_Set_ID,
        	DRAFT_INVOICE_NUM_CREDITED, CUSTOMER_BILL_SPLIT,
	 	INVOICE_COMMENT, 	INV_CURRENCY_CODE,
		INV_RATE_TYPE,INV_RATE_DATE,INV_EXCHANGE_RATE,
        	BILL_TO_ADDRESS_ID,SHIP_TO_ADDRESS_ID,
		LANGUAGE, INVPROC_CURRENCY_CODE,
		INVOICE_DATE, GL_DATE,
		PA_PERIOD_NAME,GL_PERIOD_NAME,
		RETENTION_INVOICE_FLAG,
                CUSTOMER_ID,BILL_TO_CUSTOMER_ID,SHIP_TO_CUSTOMER_ID,
                BILL_TO_CONTACT_ID,SHIP_TO_CONTACT_ID,
                ORG_ID, payment_set_id
      		) VALUES
     		(TmpInvoiceNum, p_project_id,
      		p_agreement_id, SYSDATE,
		TmpUserId, SYSDATE,
		TmpUserId, 'P',
		DECODE(TmpCreditHold,'Y','Y','N',DECODE(TmpRetnBillInvFmtId,0,'Y','N')),
		pa_billing.GetPaDate,
      		p_request_id,
		TmpProgApplId,
		TmpProgId, SYSDATE,
      		TO_DATE(pa_billing.GetBillThruDate, 'YYYY/MM/DD'),
		/*DECODE(TmpCreditHold,'Y','Y','N',DECODE(TmpRetnBillInvFmtId,0,
							TmpWarningMsg,Null)),*/
                  DECODE(TmpCreditHold,'Y',TmpWarningMsg,'N',DECODE(TmpRetnBillInvFmtId,0, TmpWarningMsg,Null)),
      		null, NULL,
		NULL,
    --		TmpInvoiceSetId,
      		NULL, TmpCustBillSplit,
      		TmpInvoiceComment,
		TmpInvCurrency,
		TmpInvCurrRateType,TmpInvCurrRateDate,
      		TmpInvCurrRate,TmpBillToAddressID,
		TmpShipToAddressID,
        	TmpLanguage,
        	NVL(TmpInvProcCurrency,TmpFundingCurrency),
        	TRUNC(TmpInvoiceDate),
        	--TRUNC(TO_DATE(TmpInvoiceDate, 'YYYY/MM/DD')),
        	pa_billing.GetGlDate,
        	pa_billing.getpaperiodname,
		pa_billing.getglperiodname,
		'Y',
                TmpCustomerid,
                TmpBilltocustomerid,
                TmpShiptocustomerid,
                TmpBilltocontactid,
                TmpShiptocontactid,
                l_org_id,
                TmpPaymentSetid);

		x_draft_invoice_num := TmpInvoiceNum;

		IF TmpCreditHold ='Y' OR NVL(TmpRetnBillInvFmtID,0) = 0 THEN

       	       		IF g1_debug_mode  = 'Y' THEN
       	       			pa_retention_util.write_log('Build_Retn_Invoice_Header: ' || 'Insert Warning ');
       	       		END IF;


			   INSERT INTO PA_DISTRIBUTION_WARNINGS (
        					DRAFT_INVOICE_NUM, PROJECT_ID,
						LAST_UPDATE_DATE, LAST_UPDATED_BY,
        					CREATION_DATE, CREATED_BY,
						REQUEST_ID, PROGRAM_APPLICATION_ID,
        					PROGRAM_ID, PROGRAM_UPDATE_DATE,
						WARNING_MESSAGE, WARNING_MESSAGE_CODE)
        				  VALUES
        				    (	TmpInvoiceNum, p_project_id,
						SYSDATE, TmpUserId, SYSDATE,
        					TmpUserId, p_request_id, TmpProgApplId,
						TmpProgId, SYSDATE,
        					TmpWarningMsg, TmpWarningCode);

			-- This insert is for project level rejection reason. This will be shown
			-- in the invoice exception report
			IF  NVL(TmpRetnBillInvFmtID,0) = 0  THEN

			   INSERT INTO PA_DISTRIBUTION_WARNINGS (
        					DRAFT_INVOICE_NUM, PROJECT_ID,
						LAST_UPDATE_DATE, LAST_UPDATED_BY,
        					CREATION_DATE, CREATED_BY,
						REQUEST_ID, PROGRAM_APPLICATION_ID,
        					PROGRAM_ID, PROGRAM_UPDATE_DATE,
						WARNING_MESSAGE, WARNING_MESSAGE_CODE)
        				  VALUES
        				    (	null, p_project_id,
						SYSDATE, TmpUserId, SYSDATE,
        					TmpUserId, p_request_id, TmpProgApplId,
						TmpProgId, SYSDATE,
        					TmpWarningMsg, TmpWarningCode);

		       END IF;


		END IF;

       	       IF g1_debug_mode  = 'Y' THEN
       	       	pa_retention_util.write_log('Leaving Build_Retn_Invoice_Header ');
       	       END IF;



EXCEPTION
/*Added for bug no 2760630 */
WHEN NO_DATA_FOUND THEN
        x_output_tax_code         := NULL; --NOCOPY
        X_Output_tax_exempt_flag  := NULL; --NOCOPY
        X_Output_tax_exempt_number := NULL; --NOCOPY
        X_Output_exempt_reason_code:= NULL; --NOCOPY
       RAISE NO_DATA_FOUND;
/*End of change for bug no 2760630 */
WHEN OTHERS THEN
	pa_retn_billing_pkg.G_ERROR_CODE :='E';
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('pa_retn_billing_pkg.Build_Retn_Invoice_Header' || '  Oracle Error :  ' || sqlerrm);
       END IF;
   RAISE;

END Build_Retn_Invoice_Header;

PROCEDURE Update_ProjFunc_Attributes( p_project_id   IN NUMBER,
                                      p_draft_invoice_num IN NUMBER) IS
l_projfunc_invtrans_rate   NUMBER:=0;
l_inv_amount		   NUMBER:=0;
l_pfc_amount  		   NUMBER:=0;
BEGIN

	SELECT 	NVL(sum(dii.inv_amount),0),
       		NVL(sum(dii.projfunc_bill_amount),0)
          INTO  l_inv_amount,
                l_pfc_amount
          FROM pa_draft_invoice_items dii
         WHERE dii.project_id = p_project_id
           AND dii.draft_invoice_num = p_draft_invoice_num;

        IF NVL(l_inv_amount,0) <> 0 AND NVL(l_pfc_amount,0) <> 0 THEN
           l_projfunc_invtrans_rate := NVL(l_inv_amount,0)/NVL(l_pfc_amount,0);
        END IF;

                 UPDATE pa_draft_invoices_all
                        set  inv_rate_date      = NULL,
                             inv_exchange_rate  = NULL,
                     	     projfunc_invtrans_rate_type      = 'User',
                     	     projfunc_invtrans_rate_date      = sysdate,
                     	     projfunc_invtrans_ex_rate        = NVL(l_projfunc_invtrans_rate,0)
                  WHERE project_id                        = P_Project_Id
                  AND   draft_invoice_num                 = p_draft_invoice_num;
EXCEPTION
WHEN OTHERS THEN
	pa_retn_billing_pkg.G_ERROR_CODE :='E';
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('pa_retn_billing_pkg.Update_ProjFunc_Attributes' || '  Oracle Error :  ' || sqlerrm);
       END IF;

END Update_ProjFunc_Attributes;

-- Procedure	Create_Retn_Invoice_Lines
-- Purpose	To Create a retention invoice lines.
--		For project level retention, there will be always one line
--		For Top Task level retention, it could be more than one

PROCEDURE Create_Retn_Invoice_Lines(   p_project_id             IN      NUMBER,
                                        p_customer_id           IN      NUMBER,
                                        /*p_task_id               IN      NUMBER DEFAULT NULL, bug 2681003
					removed the default value from body for GSCC warnings */
                                        p_task_id               IN      NUMBER ,
                                        p_agreement_id          IN      NUMBER,
                                        p_draft_invoice_num     IN      NUMBER,
                                        p_request_id            IN      NUMBER,
					p_invproc_currency	IN 	VARCHAR2,
					p_projfunc_currency	IN 	VARCHAR2,
					p_project_currency	IN	VARCHAR2,
					p_funding_currency	IN	VARCHAR2,
					p_projfunc_amount	IN	NUMBER,
					p_project_amount	IN	NUMBER,
					p_funding_amount	IN	NUMBER,
					p_invproc_amount	IN	NUMBER,
					p_billing_method	IN	VARCHAR2,
					p_billing_method_code	IN	VARCHAR2,
					p_method_value		IN 	VARCHAR2,
					p_total_retained	IN	NUMBER,
					p_billing_percentage    IN	NUMBER,
					p_billing_amount	IN	NUMBER,
                                        p_output_tax_code       IN      VARCHAR2,
             				p_Output_tax_exempt_flag IN    VARCHAR2,
             				p_Output_tax_exempt_number IN  VARCHAR2,
             			        p_Output_exempt_reason_code IN VARCHAR2,
	  				p_comp_percent		IN	NUMBER,
                                        p_bill_cycle_id  	IN 	NUMBER,
                                        p_TotRetenion  		IN	NUMBER,
                                        p_client_extn_flag	IN VARCHAR2) IS
LastLineNum		NUMBER:=0;

LastUpdatedBy           NUMBER:= fnd_global.user_id;
l_created_by            NUMBER:= fnd_global.user_id;
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;

RetnLineText		VARCHAR2(500);
TempText		VARCHAR2(80);
l_RetnInvLineFmt	pa_retn_billing_pkg.TabRetnBillingInvFmt;
LastEndPosition		NUMBER:=0;

l_task_name             VARCHAR2(20);


BEGIN

       	       IF g1_debug_mode  = 'Y' THEN
       	       	pa_retention_util.write_log('Entering Create_Retn_Invoice_Lines ');
       	       	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Project Id : ' || p_project_id);
       	       	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Task    Id : ' || p_task_id);
       	       END IF;

	-- Get task name
       	       IF g1_debug_mode  = 'Y' THEN
       	       	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Get task name');
       	       END IF;

               BEGIN

                   IF NVL(p_task_id,0) <> 0 THEN

                      SELECT LTRIM(RTRIM(task_name)) || ' '  INTO l_task_name FROM pa_tasks
                      WHERE task_id = p_task_id;

                   ELSE

                      l_task_name := NULL;

                   END IF;



               EXCEPTION

                  WHEN OTHERS THEN

                       l_task_name := NULL;

               END;
       	       IF g1_debug_mode  = 'Y' THEN
       	       	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Task    Name : ' || l_task_name);
       	       END IF;
	-- Find out any lines are existing or not
       	       IF g1_debug_mode  = 'Y' THEN
       	       	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'CAll pa_retention_pkg.Get_Invoice_Max_Line');
       	       END IF;

	LastLineNum := pa_retention_pkg.Get_Invoice_Max_Line(p_project_id=>p_project_id,
			p_draft_Invoice_num=>p_draft_invoice_num);

       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'CAll Get_Retn_Billing_Inv_Format');
       	 END IF;

	 l_RetnInvLineFmt := Get_Retn_Billing_Inv_Format(p_project_id=>p_project_id);


	-- Building the retention line text
		RetnLineText :=NULL;

	    IF l_RetnInvLineFmt.count <> 0 THEN

				    	FOR i IN 1..l_RetnInvLineFmt.Count LOOP

                                           -- Set the last end position
                                           IF  NVL(i,0) = 1 THEN
                                               LastEndPosition := l_RetnInvLineFmt(i).end_position;
                                               RetnLineText := RPAD(RetnLineText,
                                                                 l_RetnInvLineFmt(i).start_position-1,' ');
                                           ELSE
                                               RetnLineText :=
                                                        RetnLineText ||
                                                         RPAD(' ',
                                                          l_RetnInvLineFmt(i).start_position-
								LastEndPosition,' ');

                                                    LastEndPosition := l_RetnInvLineFmt(i).end_position;

                                           END IF;

                                       	IF g1_debug_mode  = 'Y' THEN
                                       		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || i || ': Fmt Text : ' || RetnLineText);
                                       	END IF;

					IF l_RetnInvLineFmt(i).column_code = 'RETENTION BILLING PERCENTAGE' THEN

						TempText := NULL;

						IF NVL(p_billing_percentage,0) <> 0 THEN

							TempText := TO_CHAR(p_billing_percentage);
						ELSE
							TempText := TO_CHAR(p_billing_amount);

						END IF;

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                   RetnLineText := RetnLineText ||
                                                     RPAD(TempText,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                     RetnLineText := RetnLineText ||
                                                       LPAD(TempText,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;

                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('% Text : ' || NVL(p_billing_percentage,p_billing_amount));
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'After % Text : ' || RetnLineText);
                                        	END IF;

					ELSIF l_RetnInvLineFmt(i).column_code = 'TEXT' THEN

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                        RetnLineText := RetnLineText ||
                                                        RPAD(l_RetnInvLineFmt(i).UserText,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD( l_RetnInvLineFmt(i).UserText,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;

                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'User Text : ' || l_RetnInvLineFmt(i).UserText);
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'User Text : ' || RetnLineText);
                                        	END IF;

					ELSIF l_RetnInvLineFmt(i).column_code = 'INVPROC CURRENCY CODE' THEN

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                        RetnLineText := RetnLineText ||
                                                        RPAD(p_invproc_currency,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD( p_invproc_currency,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;
                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'IPC  : ' || p_invproc_currency);
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'IPC Text : ' || RetnLineText);
                                        	END IF;

					ELSIF l_RetnInvLineFmt(i).column_code = 'BILLING METHOD' THEN

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                        RetnLineText := RetnLineText ||
                                                        RPAD(p_billing_method,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD(p_billing_method,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;
                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Billing Method : ' || p_billing_method);
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'After BM Text : ' || RetnLineText);
                                        	END IF;

					ELSIF l_RetnInvLineFmt(i).column_code = 'METHOD VALUE' THEN

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                        RetnLineText := RetnLineText ||
                                                        RPAD(p_method_value,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD( p_method_value,
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;
                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Method Value : ' || p_method_value);
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'After MV Text : ' || RetnLineText);
                                        	END IF;


					ELSIF l_RetnInvLineFmt(i).column_code = 'TOTAL RETAINED AMOUNT' THEN

                                                IF l_RetnInvLineFmt(i).right_justify_flag = 'Y' THEN
                                                        RetnLineText := RetnLineText ||
                                                        RPAD(TO_CHAR(p_total_retained),
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD(TO_CHAR(p_total_retained),
                                                        l_RetnInvLineFmt(i).end_position-
                                                        l_RetnInvLineFmt(i).start_position,' ');
                                                END IF;
                                        	IF g1_debug_mode  = 'Y' THEN
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Total Retained : ' || p_total_retained);
                                        		pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'After TR Text : ' || RetnLineText);
                                        	END IF;


					END IF;

					END LOOP;

				   END IF;

       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'RetnLineText : ' || RetnLineText);
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Insert DII');
       	 END IF;

                       INSERT INTO pa_draft_invoice_items
                                  ( PROJECT_ID,
                                  DRAFT_INVOICE_NUM,
                                  LINE_NUM,
                                  AMOUNT,
                                  TEXT,
                                  INVOICE_LINE_TYPE,
                                  PROJFUNC_CURRENCY_CODE,
                                  PROJFUNC_BILL_AMOUNT,
                                  PROJECT_CURRENCY_CODE,
                                  PROJECT_BILL_AMOUNT,
                                  FUNDING_CURRENCY_CODE,
                                  FUNDING_BILL_AMOUNT,
                                  INVPROC_CURRENCY_CODE,
                                  LAST_UPDATE_LOGIN,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  REQUEST_ID,
                                  PROGRAM_APPLICATION_ID,
                                  PROGRAM_ID,
                                  PROGRAM_UPDATE_DATE,
   				  OUTPUT_TAX_CLASSIFICATION_CODE,
				  OUTPUT_TAX_EXEMPT_FLAG,
/* Bug 3087998 Code and number order is different in values list. Changing here to match the same
                                  OUTPUT_TAX_EXEMPT_REASON_CODE,
                                  OUTPUT_TAX_EXEMPT_NUMBER,
*/
                                  OUTPUT_TAX_EXEMPT_NUMBER,
                                  OUTPUT_TAX_EXEMPT_REASON_CODE,
				  INV_AMOUNT,
 				  RETN_BILLING_METHOD,
 				  RETN_PERCENT_COMPLETE,
 				  RETN_TOTAL_RETENTION,
 				  RETN_CLIENT_EXTENSION_FLAG,
 				  RETN_BILLING_CYCLE_ID,
 				  RETN_BILLING_PERCENTAGE,
 				  RETN_BILLING_AMOUNT,
				  task_id)
			VALUES (p_project_id,
				p_draft_invoice_num,
				LastLineNum,
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_invproc_amount,p_invproc_currency),
				SUBSTR(l_task_name || SUBSTR(RetnLineText,1,LastEndPosition),1,240),
				'RETENTION',
				p_projfunc_currency,
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_projfunc_amount,p_projfunc_currency),
				p_project_currency,
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_project_amount,p_project_currency),
				p_funding_currency,
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_funding_amount,p_funding_currency),
				p_invproc_currency,
		  		l_last_update_login,
                                sysdate,
                                l_last_updated_by,
                                sysdate,
                                l_created_by,
                                p_request_id,
                                l_program_application_id,
                                l_program_id,
                                sysdate,
             			p_Output_tax_code,
             			p_Output_tax_exempt_flag ,
             			p_Output_tax_exempt_number ,
             			p_Output_exempt_reason_code,
				DECODE(pa_retn_billing_pkg.G_Inv_By_Bill_Trans_Currency,
				'Y',
			        PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_invproc_amount,
				    p_invproc_currency),
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
					p_projfunc_amount,p_projfunc_currency)),
				p_billing_method_code,
				p_comp_percent,
                                p_TotRetenion,
                                p_client_extn_flag,
                                p_bill_cycle_id,
				p_billing_percentage,
				PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				p_billing_amount,
				p_invproc_currency),
				p_task_id);

	--- Create the retention invoice details
       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Call Create_Retn_Invoice_Details');
       	 END IF;

	Create_Retn_Invoice_Details ( p_project_id=>p_project_id,
                                      p_draft_invoice_num=>p_draft_invoice_num,
				      p_task_id => p_task_id,
                                      p_line_num=>LastLineNum,
                                      p_agreement_id=>p_agreement_id,
                                      p_request_id=>p_request_id);

	-- Update the balances

       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Lines: ' || 'Call  pa_retention_pkg.Update_Retention_Balances');
       	 END IF;

		pa_retention_pkg.Update_Retention_Balances(
                                        p_project_id=>p_project_id,
                                        p_agreement_id=>p_agreement_id,
                                        p_task_id=>p_task_id,
                                        p_customer_id=>p_customer_id,
                                        p_amount      =>p_invproc_amount,
                                        p_change_type =>'BILLED',
                                        p_request_id  =>p_request_id,
                                        p_invproc_currency=>p_invproc_currency,
                                        p_project_currency=>p_project_currency,
                                        p_project_amount  =>p_project_amount,
                                        p_projfunc_currency =>p_projfunc_currency,
                                        p_projfunc_amount  =>p_projfunc_amount,
                                        p_funding_currency =>p_funding_currency,
                                        p_funding_amount   =>p_funding_amount);

       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Leaving pa_retn_billing_pkg.Create_Retn_Invoice_Lines');
       	 END IF;
EXCEPTION
WHEN OTHERS THEN
	pa_retn_billing_pkg.G_ERROR_CODE :='E';
       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('pa_retn_billing_pkg.Create_Retn_Invoice_Lines   : Oracle Error : ' || sqlerrm);
       	 END IF;

END Create_Retn_Invoice_Lines;

--- Procedure  Create_Retn_Invoice_Details
--  Purpose	This process will baseline the retained amount at rule level
--              This detail will become a history of the retention invoice line

PROCEDURE Create_Retn_Invoice_Details (
                                        p_project_id            IN      NUMBER,
					/*p_task_id		IN	NUMBER DEFAULT NULL, bug 2681003
					removed the default value from body for GSCC warnings */
					p_task_id		IN	NUMBER,
                                        p_draft_invoice_num     IN      NUMBER,
                                        p_line_num              IN      NUMBER,
                                        p_agreement_id          IN      NUMBER,
					p_request_id		IN	NUMBER) IS

CURSOR cur_proj_retn IS
		SELECT
			project_retention_id,
			project_id,
			task_id,
			invproc_currency_code,
			total_retained,
		        projfunc_currency_code,
			projfunc_total_retained,
		        project_currency_code,
			project_total_retained,
		        funding_currency_code,
			funding_total_retained
		FROM pa_project_retentions
		WHERE project_id  = p_project_id
		  AND agreement_id = p_agreement_id
		  AND nvl(task_id,-99) = NVL(p_task_id,-99);

ProjRetnRec	cur_proj_retn%ROWTYPE;

LastUpdatedBy           	NUMBER:= fnd_global.user_id;
l_created_by            	NUMBER:= fnd_global.user_id;
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;
l_detail_id		      NUMBER;


BEGIN
       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Entering pa_retn_billing_pkg.Create_Retn_Invoice_Details');
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Details: ' || 'Project Id     : ' || p_project_id);
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Details: ' || 'Task    Id     : ' || p_task_id);
       	 	pa_retention_util.write_log('Create_Retn_Invoice_Details: ' || 'Agreement Id     : ' || p_agreement_id);
       	 END IF;

		OPEN cur_proj_retn;

		LOOP

			FETCH cur_proj_retn INTO ProjRetnRec;

			EXIT WHEN cur_proj_retn%NOTFOUND;


			-- Select the sequence values

			SELECT pa_retn_invoice_details_s.NEXTVAL
			  INTO l_detail_id
			 FROM DUAL;

       	 		IF g1_debug_mode  = 'Y' THEN
       	 			pa_retention_util.write_log('Create_Retn_Invoice_Details: ' || 'Insert pa_retn_invoice_details');
       	 		END IF;

				-- Insert into the Retention Invoice Detail table
				INSERT INTO pa_retn_invoice_details
					( RETN_INVOICE_DETAIL_ID,
 					  PROJECT_ID,
 					  DRAFT_INVOICE_NUM,
 					  LINE_NUM,
 					  PROJECT_RETENTION_ID,
 					  TOTAL_RETAINED,
 					  INVPROC_CURRENCY_CODE,
 					  PROJFUNC_CURRENCY_CODE,
 				          PROJFUNC_TOTAL_RETAINED,
 					  PROJECT_CURRENCY_CODE,
 					  PROJECT_TOTAL_RETAINED,
 					  FUNDING_CURRENCY_CODE,
 					  FUNDING_TOTAL_RETAINED,
 					  PROGRAM_APPLICATION_ID,
					  PROGRAM_ID,
 					  PROGRAM_UPDATE_DATE,
 					  REQUEST_ID,
 					  CREATION_DATE,
 					  CREATED_BY,
 					  LAST_UPDATE_DATE,
 					  LAST_UPDATED_BY)
				VALUES( l_detail_id,
					p_project_id,
					p_draft_invoice_num,
					p_line_num,
					ProjRetnRec.project_retention_id,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(ProjRetnRec.total_retained,
					ProjRetnRec.invproc_currency_code),
					ProjRetnRec.invproc_currency_code,
					ProjRetnRec.projfunc_currency_code,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(ProjRetnRec.projfunc_total_retained,
					ProjRetnRec.projfunc_currency_code),
					ProjRetnRec.project_currency_code,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(ProjRetnRec.project_total_retained,
					ProjRetnRec.project_currency_code),
					ProjRetnRec.funding_currency_code,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(ProjRetnRec.funding_total_retained,
					ProjRetnRec.funding_currency_code),
					l_program_application_id,
					l_program_id,
					l_program_update_date,
					p_request_id,
					sysdate,
					l_created_by,
					l_last_update_date,
					LastUpdatedBy);

		END LOOP;

	CLOSE cur_proj_retn;

       	IF g1_debug_mode  = 'Y' THEN
       		pa_retention_util.write_log('Leaving pa_retn_billing_pkg.Create_Retn_Invoice_Details');
       	END IF;
EXCEPTION
WHEN OTHERS THEN
	pa_retn_billing_pkg.G_ERROR_CODE :='E';
       	IF g1_debug_mode  = 'Y' THEN
       		pa_retention_util.write_log('pa_retn_billing_pkg.Create_Retn_Invoice_Details
   : Oracle Error  : ' || sqlerrm);
       	END IF;

END Create_Retn_Invoice_Details;

-- Procedure 	Retention_Billing_Processing
-- Purpose	This process will be called from paisql
--		Process will list all the project which has to generate the retention
--		invoice

Procedure Retention_Billing_Processing (p_request_id            IN NUMBER,
                                        p_start_proj_number     IN VARCHAR2,
                                        p_end_proj_number       IN VARCHAR2,
                                        x_return_status         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
TmpCustomerId 		NUMBER;
TmpProjectId		NUMBER;

 /* R12 : ATG changes : removed to_date function */

TmpInvoiceDate		DATE:= TO_DATE(pa_billing.globvars.InvoiceDate, 'YYYY/MM/DD');

/* Bug 3258465 Added this temporary variable to fetch the Bill through date*/
TmpBillThruDate         DATE := TO_DATE(pa_billing.globvars.BillThruDate,'YYYY/MM/DD');

CurRetained     	NUMBER:=0;
CurBillAmount     	NUMBER:=0;
TmpBillAmount     	NUMBER:=0;
Tmprelactive            NUMBER:=0;

/* Misc bill enhan modified where clause based on p_project_type_id, p_project_org_id, p_agreement_id,
   p_customer_id, p_mcb_flag */

CURSOR cur_proj_cust_retn IS SELECT 	pc.project_id project_id,
					pc.customer_id customer_id,
					pc.retention_level_code retention_level,
					NVL(pr.RETN_BILLING_INV_FORMAT_ID,0) RETN_BILLING_INV_FORMAT_ID
/* TCA changes
			     FROM pa_project_customers pc, pa_projects_all pr, ra_customers c
*/
			     FROM pa_project_customers pc, pa_projects_all pr, hz_parties hz_p, hz_cust_accounts hz_c
			     WHERE EXISTS(
					SELECT NULL FROM pa_summary_project_retn  spr,
							 pa_proj_retn_bill_rules rt
					 WHERE   rt.project_id = spr.project_id
					   AND   rt.customer_id = spr.customer_id
					   AND   spr.customer_id = pc.customer_id
					   AND   spr.project_id   = pc.project_id
					   AND (NVL(spr.total_retained,0) - NVL(spr.total_billed,0) ) > 0)
				AND pr.project_id = pc.project_id
/* TCA changes
                                AND pc.customer_id = c.customer_id
*/
                                AND pc.customer_id = hz_c.cust_account_id
                                AND hz_p.party_id = hz_c.party_id
				AND pr.segment1 between p_start_proj_number and p_end_proj_number
/*
                                AND ( nvl (p_agreement_id,0) = 0
                                       OR EXISTS (select null
                                                  from pa_summary_project_fundings SPF
                                                  where spf.project_id = pr.project_id
                                                  and  spf.agreement_id = p_agreement_id
                                                  and  spf.total_baselined_amount > 0)
                                    )
                                AND ( nvl(p_customer_id,0) =  0
                                       OR pc.customer_id = p_customer_id
                                    )
                                AND (nvl(p_project_type_id, 0) = 0
                                        OR  EXISTS ( select null
                                                     from pa_project_types pt
                                                     where pr.project_type = pt.project_type
                                                     and pt.project_type_id = p_project_type_id)
                                     )
                                AND ( nvl(p_project_org_id,0) =  0
                                       OR pr.carrying_out_organization_id = p_project_org_id
                                    )
                                AND (p_mcb_flag = 'N'
                                       OR nvl(pr.multi_currency_billing_flag, 'N') = 'Y')
*/
/* TCA changes
order by pr.segment1, c.customer_name;
*/
order by pr.segment1, hz_p.party_name;

ProjCustRec cur_proj_cust_retn%ROWTYPE;

CURSOR cur_retn_billing_rules IS SELECT retn1.billing_method_code billing_method,
					retn1.retn_billing_percentage bill_percentage,
					retn1.retn_billing_amount bill_amount,
					retn1.total_retention_amount total_retention_amount,
					retn1.retn_billing_cycle_id billing_cycle_id,
					retn1.completed_percentage completed_percentage,
					retn1.client_extension_flag client_extn_flag,
					cy.billing_cycle_name billing_cycle_name,
					lk.meaning billingMethodDesc,
					retn1.task_id task_id
				FROM    pa_proj_retn_bill_rules retn1,
					pa_billing_cycles cy,
					pa_lookups lk
				WHERE   retn1.project_id = TmpProjectId
		  		  AND   retn1.customer_id= TmpCustomerId
				  AND   lk.lookup_code   = retn1.billing_method_code
				  AND   lk.lookup_type   ='RETN_BILLING_METHOD'
	  	  		  AND   retn1.billing_method_code <> 'PERCENT_COMPLETE'
				  AND   retn1.retn_billing_cycle_id = cy.billing_cycle_id(+)
				UNION
				SELECT
					retn.billing_method_code billing_method,
					retn.retn_billing_percentage bill_percentage,
					retn.retn_billing_amount bill_amount,
					retn.total_retention_amount total_retention_amount ,
					retn.retn_billing_cycle_id billing_cycle_id,
					retn.completed_percentage completed_percentage,
					retn.client_extension_flag client_extn_flag,
					'NULL' billing_cycle_name,
					lk.meaning billingMethodDesc,
					retn.task_id task_id
				FROM    pa_proj_retn_bill_rules retn,
					pa_lookups lk
				WHERE   retn.project_id = TmpProjectId
		  		  AND   retn.customer_id= TmpCustomerId
				  AND   lk.lookup_code   = retn.billing_method_code
				  AND   lk.lookup_type   ='RETN_BILLING_METHOD'
		  		  AND   retn.billing_method_code = 'PERCENT_COMPLETE'
		 		  AND
		   retn.completed_percentage <=
	  pa_bill_pct.GetPercentComplete(
			   	retn.project_id, retn.task_id,TmpBillThruDate) /*Bug 3258465 Modified the call by passing TmpBillThruDate instead of TmpInvoiceDate*/
			ORDER BY completed_percentage DESC;


RetnRuleRec cur_retn_billing_rules%ROWTYPE;

OldTask	NUMBER;
NewTask Number;
PC_done boolean := FALSE;
TmpCompPercent NUMBER;
TmpBillCycleId NUMBER;
TmpTotRetenion NUMBER;
TmpClientExt   VARCHAR2(1);

CURSOR cur_agr IS SELECT
			spr.agreement_id,
			spr.project_id,
			spr.task_id,
			spr.invproc_currency_code,
			spr.total_retained,
			spr.total_billed,
			spr.projfunc_currency_code,
			spr.projfunc_total_retained,
			spr.projfunc_total_billed,
			spr.project_currency_code,
			spr.project_total_retained,
			spr.project_total_billed,
			spr.funding_currency_code,
			spr.funding_total_retained,
			(NVL(spr.total_retained,0)- NVL(spr.total_billed,0))	Remain_Retained_Amt,
			pr.inv_by_bill_trans_curr_flag inv_by_bill_trans_curr_flag
		FROM pa_summary_project_retn spr,
		     pa_agreements_all agr,
		     pa_projects_all pr
	      WHERE agr.agreement_id = spr.agreement_id
		AND agr.customer_id  = TmpCustomerID
                AND spr.project_id   = TmpProjectId
		AND spr.project_id   = pr.project_id
		AND NVL(spr.task_id,-99)   = NVL(NewTask,-99)
		AND NVL(spr.total_retained,0) <> 0 /*For Bug 7612216*/
	ORDER BY  DECODE(agr.invoice_limit_flag,'Y',1,2), agr.expiration_date;

SPRRec cur_agr%ROWTYPE;

TmpInvoiceNum		NUMBER;
TmpPFCBillAmount	NUMBER;
TmpPCBillAmount		NUMBER;
TmpFCBillAmount		NUMBER;
TmpMethodValue		VARCHAR2(80);

--Tmp_Output_vat_tax_id              NUMBER;
Tmp_output_tax_code                VARCHAR2(30);
Tmp_Output_tax_exempt_flag         VARCHAR2(2);
--Tmp_Output_tax_exempt_number       VARCHAR2(30); --Modified for Bug3128094
Tmp_Output_tax_exempt_number       VARCHAR2(80);
Tmp_Output_exempt_reason_code      VARCHAR2(30);

TmpTaskId	NUMBER:=0;

TmpBillPercentage Number:=0;
TmpBillingAmount  NUMBER:=0;
TmpBillFlag	 VARCHAR2(2);
TmpReturnStatus  VARCHAR2(2);

TmpIPC		VARCHAR2(15);
TmpPFC		VARCHAR2(15);
TmpInvByBTC	VARCHAR2(1);
TmpRetnBillInvFmt Number:=0;

BEGIN
       	IF g1_debug_mode  = 'Y' THEN
       		pa_retention_util.write_log('Entering pa_retn_billing_pkg.Retention_Billing_Processing');
       		pa_retention_util.write_log('Retention_Billing_Processing: ' || 'From Project Number   ' || p_start_proj_number );
       		pa_retention_util.write_log('Retention_Billing_Processing: ' || 'End Project Number    ' || p_end_proj_number);
       	END IF;



	-- List the Project and Customers

	OPEN cur_proj_cust_retn;

	LOOP  -- Project Customer Loop Starts

		FETCH cur_proj_cust_retn INTO ProjCustRec;

		EXIT WHEN cur_proj_cust_retn%NOTFOUND;

			TmpCustomerId := ProjCustRec.Customer_id;
			TmpProjectId  := ProjCustRec.project_id;
			TmpRetnBillInvFmt := ProjCustRec.RETN_BILLING_INV_FORMAT_ID;
       			IF g1_debug_mode  = 'Y' THEN
       				pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpCustomerId : ' || TmpCustomerId);
       				pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpProjectId  : ' || TmpProjectId);
       			END IF;
			TmpTaskId     := 0;
			OldTask     := 0;
			NewTask     := 0;
			PC_done	    := FALSE;
			CurRetained   :=0;
			CurBillAmount :=0;
			TmpBillAmount :=0;

			 -- Project Retention Billing

		  	BEGIN
				OPEN  cur_retn_billing_rules;

				LOOP
					FETCH cur_retn_billing_rules INTO  RetnRuleRec;

					EXIT WHEN cur_retn_billing_rules%NOTFOUND;
					 CurRetained:= 0;
					 TmpTaskId     := RetnRuleRec.Task_id;
					 NewTask     := TmpTaskId;
					 CurRetained   :=0;
					 CurBillAmount :=0;
					 TmpBillAmount :=0;
					 TmpCompPercent :=RetnRuleRec.completed_percentage;
					 TmpBillCycleId :=RetnRuleRec.billing_cycle_id;
					 TmpTotRetenion :=RetnRuleRec.total_retention_amount;
					 TmpClientExt   :=RetnRuleRec.client_extn_flag;

       					IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'retention_level  : ' || ProjCustRec.retention_level);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpProjectId  : ' || TmpProjectId);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'NewTask  : ' || NewTask);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpCompPercent  : ' || TmpCompPercent);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpBillCycleId  : ' || TmpBillCycleId);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpTotRetenion  : ' || TmpTotRetenion);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpClientExt  : ' || TmpClientExt);
       					END IF;

					-- to get current bill amount that is total retained amount - total billed
					-- For Project Level

		    			IF ProjCustRec.retention_level = 'PROJECT' THEN

						SELECT 	SUM(NVL(spr.total_retained,0)) -
							SUM(NVL(spr.total_billed,0))
					  	  INTO CurRetained
					  	  FROM pa_summary_project_retn spr
					         WHERE spr.project_id= TmpProjectId
                                                   AND spr.customer_id= TmpCustomerId;  /*Added for bug 3234999*/

       					IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Sum of Retention Level  : ' || ProjCustRec.retention_level);
       					END IF;

					ELSE

						SELECT 	SUM(NVL(spr.total_retained,0)) -
							SUM(NVL(spr.total_billed,0))
					  	  INTO CurRetained
					  	  FROM pa_summary_project_retn spr
					         WHERE spr.project_id= TmpProjectId
						   AND spr.task_id   = NewTask
                                                   AND spr.customer_id= TmpCustomerId;  /*Added for bug 3234999*/

       					IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Sum of Retention Level  : ' || ProjCustRec.retention_level
								||'  : ' || NewTask);
       					END IF;
					     -- For Percent Complet Case
					      -- Process should execute only once
						IF OldTask <> NewTask THEN

							PC_Done := FALSE;
						        OldTask := NewTask;

						END IF;

					END IF;
       					IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CurRetained     : ' || CurRetained);
       						pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Billing Method  : ' || RetnRuleRec.Billing_Method);
       					END IF;

					IF NVL(CurRetained,0) <> 0 THEN

					   IF rtrim(RetnRuleRec.Billing_Method)='TOTAL_RETENTION_AMOUNT' THEN
       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Processing Method : ' || RetnRuleRec.Billing_Method);
       						END IF;

       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Total Retn Amt  : ' ||
							NVL(RetnRuleRec.total_retention_amount,0));
       						END IF;
						TmpMethodValue := TO_CHAR(
							NVL(RetnRuleRec.total_retention_amount,
0));

						IF NVL(CurRetained,0) >= NVL(RetnRuleRec.total_retention_amount,0) THEN

							RetnRuleRec.bill_percentage :=
							NVL(RetnRuleRec.bill_percentage,0);

							RetnRuleRec.bill_amount :=
								NVL(RetnRuleRec.bill_amount,0);
						ELSE

							RetnRuleRec.bill_percentage :=0;
								RetnRuleRec.bill_amount := 0;

						END IF;
       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('bill_percentage  : ' ||
							NVL(RetnRuleRec.bill_percentage,0));
       						pa_retention_util.write_log('bill_amount  : ' ||
							NVL(RetnRuleRec.bill_amount,0));
       						END IF;

					    ElsIF rtrim(RetnRuleRec.Billing_Method)='CLIENT_EXTENSION' THEN
       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Processing Method : ' || RetnRuleRec.Billing_Method);
       						END IF;

							-- Call Client Extension to get the percent or amount
       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Total Retn Amt  : ' ||
							NVL(RetnRuleRec.total_retention_amount,0));
       						END IF;

							TmpBillPercentage :=0;
							TmpBillingAmount :=0;
							TmpBillFlag 	:='N';
							TmpReturnStatus :='S';

							pa_client_extn_retention.BILL_RETENTION(
 								P_CUSTOMER_ID=>TmpCustomerId,
					                        P_PROJECT_ID =>TmpProjectId,
 							        P_TOP_TASK_ID=>TmpTaskId,
 							        X_BILL_RETENTION_FLAG=>TmpBillFlag,
 							        X_BILL_PERCENTAGE=>TmpBillPercentage,
 							        X_BILL_AMOUNT=>TmpBillingAmount,
 						                X_STATUS=>TmpReturnStatus);

							IF TmpBillFlag = 'Y' THEN

							    IF TmpReturnStatus <> 'E' THEN

								RetnRuleRec.bill_percentage :=
								NVL(TmpBillPercentage,0);

								RetnRuleRec.bill_amount :=
								NVL(TmpBillingAmount,0);

							    ELSIF TmpReturnStatus = 'E' THEN

								RetnRuleRec.bill_percentage :=0;

								RetnRuleRec.bill_amount := 0;


							    END IF;

							ELSIF TmpBillFlag = 'N' THEN

								RetnRuleRec.bill_percentage :=0;

								RetnRuleRec.bill_amount := 0;

						        END IF;
       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('bill_percentage  : ' ||
							NVL(RetnRuleRec.bill_percentage,0));
       						pa_retention_util.write_log('bill_amount  : ' ||
							NVL(RetnRuleRec.bill_amount,0));
       						END IF;

					    ElsIF rtrim(RetnRuleRec.Billing_Method) ='PERCENT_COMPLETE' THEN

       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Processing Method : ' || RetnRuleRec.Billing_Method);
       						pa_retention_util.write_log('Total Retn Amt  : ' ||
							NVL(RetnRuleRec.total_retention_amount,0));
       						END IF;


						IF NOT PC_DONE THEN

							TmpMethodValue := TO_CHAR(
							 RetnRuleRec.completed_percentage);
								RetnRuleRec.bill_percentage :=
								NVL(RetnRuleRec.bill_percentage,0);

								RetnRuleRec.bill_amount :=
								NVL(RetnRuleRec.bill_amount,0);
						        pc_done := true;
						ELSE
							RetnRuleRec.bill_percentage :=0;
							RetnRuleRec.bill_amount := 0;
						END IF;

       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('bill_percentage  : ' ||
							NVL(RetnRuleRec.bill_percentage,0));
       						pa_retention_util.write_log('bill_amount  : ' ||
							NVL(RetnRuleRec.bill_amount,0));
       						END IF;

					    ElsIF RetnRuleRec.Billing_Method='RETENTION_BILLING_CYCLE' THEN
						TmpMethodValue :=
					 RetnRuleRec.Billing_Cycle_Name;


							IF pa_retention_util.IsBillingCycleQualified(
								 p_project_id => TmpProjectId,
								 p_task_id => TmpTaskId,
                                 			          P_bill_thru_date =>
									TO_DATE(pa_billing.globvars.billthrudate,'YYYY/MM/DD'),
                                 				 p_billing_cycle_id =>
										 RetnRuleRec.billing_cycle_id) ='Y'
							THEN

								RetnRuleRec.bill_percentage :=
								NVL(RetnRuleRec.bill_percentage,0);

								RetnRuleRec.bill_amount :=
								NVL(RetnRuleRec.bill_amount,0);
							ELSE

								RetnRuleRec.bill_percentage :=0;

								RetnRuleRec.bill_amount :=0;

							END IF;

						END IF;

       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('Billing Percentage : ' ||
							NVL(RetnRuleRec.bill_percentage,0));

       						pa_retention_util.write_log('Billing Amount : ' ||
							NVL(RetnRuleRec.bill_amount,0));
       						END IF;

						If NVL(RetnRuleRec.bill_percentage,0) <> 0 THEN

							    	CurBillAmount :=  NVL(CurRetained,0) *
								    (NVL(RetnRuleRec.bill_percentage,0)/100);

						ElsIf NVL(RetnRuleRec.bill_amount,0) <> 0 THEN

							    	CurBillAmount := NVL(RetnRuleRec.bill_amount,0);

						END IF;

       						IF g1_debug_mode  = 'Y' THEN
       						pa_retention_util.write_log('CurrBillAmount : ' ||
							NVL(CurBillAmount,0));
       						END IF;

						IF NVL(CurBillAmount,0) <> 0 THEN

       						     IF g1_debug_mode  = 'Y' THEN
       						     	pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Open Cursor CurAgr  ');
       						     END IF;

							OPEN Cur_Agr;

							LOOP

							  FETCH cur_agr INTO SPRRec;

							  EXIT WHEN cur_agr%NOTFOUND OR NVL(CurBillAmount,0)<=0;

							  	TmpBillAmount :=0;
							  	TmpPFCBillAmount  :=0;
							  	TmpPCBillAmount   :=0;
							  	TmpFCBillAmount   :=0;
							        TmpIPC := SprRec.invproc_currency_code;
							        TmpPFC := SprRec.projfunc_currency_code;
							        TmpInvByBtc := SprRec.inv_by_bill_trans_curr_flag;

								IF NVL(SprRec.Remain_Retained_Amt,0) >=
									NVL(CurBillAmount,0) THEN

								    TmpBillAmount := NVL(CurBillAmount,0);

								 /* Bug 2502373 : if the current bill amount is less
                                                                      than the to be billed amount, assign the full
                                                                      bill amount for billing and set the current
                                                                      bill amount is zero */

								    CurBillAmount := 0;

								ELSIF NVL(SprRec.Remain_Retained_Amt,0) <
									NVL(CurBillAmount,0) THEN

								    TmpBillAmount :=
									 NVL(SprRec.Remain_Retained_Amt,0);

								    CurBillAmount := NVL(CurBillAmount,0) -
									NVL(SprRec.Remain_Retained_Amt,0);

								END IF;

       						     		IF g1_debug_mode  = 'Y' THEN
       						     			pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpBillAmount :  '
									|| TmpBillAmount);
       						     		END IF;

								    TmpPFCBillAmount :=
									(NVL(SprRec.projfunc_total_retained,0)/
								         NVL(SprRec.total_retained,0))
									* NVL(TmpBillAmount,0);

								    TmpPCBillAmount :=
									(NVL(SprRec.project_total_retained,0)/
								         NVL(SprRec.total_retained,0))
									* NVL(TmpBillAmount,0);

								    TmpFCBillAmount :=
									(NVL(SprRec.funding_total_retained,0)/
								         NVL(SprRec.total_retained,0))
									* NVL(TmpBillAmount,0);

       						     		IF g1_debug_mode  = 'Y' THEN
       						     			pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpPFCBillAmount :  '
									|| TmpPFCBillAmount);
       						     			pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpPCBillAmount :  '
									|| TmpPCBillAmount);
       						     			pa_retention_util.write_log('Retention_Billing_Processing: ' || 'TmpFCBillAmount :  '
									|| TmpFCBillAmount);
       						     		END IF;

		    			IF (( ProjCustRec.retention_level = 'TOP_TASK'
                                           AND CheckInvoiceExists(p_project_id=>TmpProjectId,
								  p_agreement_id=>SprRec.Agreement_id,
								  p_request_id=>p_request_id)='N' ) OR
						(ProjCustRec.retention_level = 'PROJECT')) THEN

       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Agreement Id : ' || SprRec.Agreement_id);
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Customer Id : ' || TmpCustomerId);
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Project Id : ' || TmpProjectId);
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CAll Build_Retn_Invoice_Header');
/*The exception block has been added for customer account relation change,bug no 2760630 */       						END IF;
  BEGIN
Tmprelactive :=0;
					IF NVL(TmpBillAmount,0) <> 0 THEN

						  Build_Retn_Invoice_Header(
						     p_project_id=>TmpProjectId,
						     p_agreement_id =>SprRec.agreement_id,
						     p_customer_id =>TmpCustomerId,
						     p_request_id =>p_request_id,
						     x_draft_invoice_num=>TmpInvoiceNum,
                                                     X_output_tax_code => Tmp_output_tax_code,
             					     X_Output_tax_exempt_flag=>Tmp_Output_tax_exempt_flag ,
             					     X_Output_tax_exempt_number =>Tmp_Output_tax_exempt_number,
             					     X_Output_exempt_reason_code =>Tmp_Output_exempt_reason_code);
				END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
      Tmprelactive :=1;
END;

				END IF;

				-- If the retention billing invoice format is defined

				IF (TmpRetnBillInvFmt <> 0 AND  Tmprelactive=0) THEN

				IF NVL(TmpBillAmounT,0) <> 0 THEN

       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CAll Create_Retn_Invoice_Lines');
       						END IF;

						Create_Retn_Invoice_Lines(
						   p_project_id=>TmpProjectId,
                                        	   p_customer_id=>TmpCustomerId,
                                        	   p_task_id=>NewTask,
                                        	   p_agreement_id=>SprRec.agreement_id,
                                        	   p_draft_invoice_num=>TmpInvoiceNum,
                                        	   p_request_id =>p_request_id,
						   p_invproc_currency=>SprRec.invproc_currency_code,
						   p_invproc_amount=>TmpBillAmount,
						   p_projfunc_currency=> SprRec.projfunc_currency_code,
						   p_project_currency=> SprRec.project_currency_code,
						   p_funding_currency=>SprRec.funding_currency_code,
						   p_projfunc_amount =>TmpPFCBillAmount,
						   p_project_amount =>TmpPCBillAmount,
						   p_funding_amount=>TmpFCBillAmount,
						   p_billing_method=>RetnRuleRec.BillingMethodDesc,
						   p_billing_method_code=>RetnRuleRec.billing_method,
						   p_method_value=>TmpMethodValue,
						   p_billing_percentage=>RetnRuleRec.bill_percentage,
						   p_billing_amount=>RetnRuleRec.bill_amount,
						   p_total_retained=>CurRetained,
                                                   p_output_tax_code => Tmp_output_tax_code,
             					   p_Output_tax_exempt_flag=>Tmp_Output_tax_exempt_flag ,
             					   p_Output_tax_exempt_number =>Tmp_Output_tax_exempt_number,
             					   p_Output_exempt_reason_code =>Tmp_Output_exempt_reason_code,
					          p_comp_percent=>TmpCompPercent,
						  p_bill_cycle_id=>TmpBillCycleId,
						  p_TotRetenion=>TmpTotRetenion,
						  p_client_extn_flag=>TmpClientExt);

						-- Call the MRC hook

/* MRC elimination bug 4941054
       						IF g1_debug_mode  = 'Y' THEN
       							pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CAll MRC Hook');
       						END IF;

						PA_MC_RETN_INV_DETAIL_PKG.Process_RetnInvDetails(
							p_project_id=>TmpProjectId,
						        p_draft_invoice_num=>TmpInvoiceNum,
							p_action=>'INSERT',
							p_request_id=>p_request_id);
*/

						-- Update only for invoice by bill transaction invoice

						IF (SprRec.invproc_currency_code <> SprRec.projfunc_currency_code)
						  AND (SprRec.inv_by_bill_trans_curr_flag ='Y') THEN

       						     IF g1_debug_mode  = 'Y' THEN
       						     	pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CAll Update_ProjFunc_Attributes');
       						     END IF;

					       		Update_ProjFunc_Attributes(p_project_id=>TmpProjectId,
                                      					   p_draft_invoice_num=>TmpInvoiceNum);

						END IF;

				    END IF;

				END IF;


						END LOOP;

					CLOSE cur_agr;

					END IF;

				      END IF; -- no retained amount to bill

				END LOOP; -- Retention Rule Ends

                                CLOSE cur_retn_billing_rules;

			END;  -- End of Retention Billing

	END LOOP; -- Project Customer Loop Ends

        CLOSE cur_proj_cust_retn;

	-- Update the invoice currency attributes for retention invoices

       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Retention_Billing_Processing: ' || 'CAll Update_Inv_Trans_Attributes');
       END IF;

       Update_Inv_Trans_Attributes(p_request_id=>p_request_id);

	-- create distribution warning if the project is not generated any retention invoices

       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Call Invoice_Generation_Exceptions');
       END IF;

	Invoice_Generation_Exceptions (p_request_id =>p_request_id,
                                         p_start_proj_number=>p_start_proj_number ,
                                         p_end_proj_number=>p_end_proj_number) ;

       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Retention_Billing_Processing: ' || 'Update MRC for Retention Invoices');
       END IF;

	UPDATE PA_DRAFT_INVOICES
            SET CREATION_DATE = sysdate
        WHERE REQUEST_ID = p_request_id
          AND NVL(retention_invoice_flag,'N') = 'Y';


       x_return_status :=FND_API.G_RET_STS_SUCCESS;
       pa_retn_billing_pkg.G_ERROR_CODE :='S';

EXCEPTION
WHEN OTHERS THEN
 x_return_status :='E';
 pa_retn_billing_pkg.G_ERROR_CODE :='E';
       IF g1_debug_mode  = 'Y' THEN
       	pa_retention_util.write_log('Retention_Billing_Processing: Oracle Error : ' || sqlerrm);
       END IF;
END Retention_Billing_Processing;

PROCEDURE Update_Inv_Trans_Attributes (p_request_id	IN NUMBER) IS
CURSOR Retn_Inv_Project IS
	SELECT project_id
	 FROM pa_draft_invoices
	WHERE  request_id = p_request_id
        AND   NVL(GENERATION_ERROR_FLAG,'N') ='N'
	AND NVL(retention_invoice_flag,'N') = 'Y'
       GROUP BY project_id;

TmpUserId               NUMBER:= fnd_global.user_id;

 BEGIN
       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Entering  Update_Inv_Trans_Attributes');
       	 END IF;

	FOR ProjectRec IN Retn_Inv_Project LOOP
       	 IF g1_debug_mode  = 'Y' THEN
       	 	pa_retention_util.write_log('Update_Inv_Trans_Attributes: ' || 'Calling  PA_INVOICE_CURRENCY.Recalculate_Driver for project id : '
					|| ProjectRec.project_id);
       	 END IF;
                PA_INVOICE_CURRENCY.Recalculate_Driver
                             ( P_Request_ID =>p_request_id,
                               P_User_ID    =>TmpUserId,
                               P_Project_ID =>ProjectRec.project_id,
			       p_calling_process=>'RETENTION_INVOICES');
	END LOOP;
EXCEPTION
WHEN OTHERS THEN
 pa_retn_billing_pkg.G_ERROR_CODE :='E';
END Update_Inv_Trans_Attributes;

-- Procedure Invoice_Generation_Exceptions
-- p_request_id        :  Request Id
-- p_start_proj_number :  Start Project Number
-- p_end_proj_number   :  End Project Number
-- Purpose	       :
--			 This procedure will insert the distribution warning
--                       for the project which is not created invoices
PROCEDURE Invoice_Generation_Exceptions (p_request_id           IN NUMBER,
                                         p_start_proj_number    IN VARCHAR2,
                                         p_end_proj_number      IN VARCHAR2) IS
CURSOR cur_select_projects IS
	SELECT pr.project_id project_id
	 FROM  pa_projects pr, pa_project_types t
	WHERE  NOT EXISTS (SELECT  null
			FROM  pa_draft_invoices_all di
		       WHERE  di.request_id =  p_request_id
		         AND  di.project_id = pr.project_id
			 AND  NVL(di.retention_invoice_flag,'N') = 'Y')
        AND EXISTS( SELECT NULL
		      FROM pa_proj_retn_rules  rt
                     WHERE   rt.project_id = pr.project_id)
       AND PA_Project_Utils.Check_prj_stus_action_allowed(pr.Project_Status_Code, 'GENERATE_INV') = 'Y'
       AND pr.project_type = t.project_type
       AND t.Project_type_class_code = 'CONTRACT'
       AND pr.segment1 between p_start_proj_number and p_end_proj_number
 ORDER BY pr.segment1;

RecSelectProjects cur_select_projects%ROWTYPE;

TmpProgId               NUMBER:= fnd_global.conc_program_id;
TmpProgApplId           NUMBER:= fnd_global.prog_appl_id;
l_program_update_date   DATE  := sysdate;
l_last_update_date      DATE  := sysdate;
l_last_updated_by       NUMBER:= fnd_global.user_id;
l_last_update_login     NUMBER:= fnd_global.login_id;
TmpUserId               NUMBER:= fnd_global.user_id;
TmpInvoiceNum		NUMBER:=NULL;
TmpWarningMsg           VARCHAR2(80);
TmpWarningCode          VARCHAR2(30):= 'NO_RETN_BILLING_INVOICES';

BEGIN
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Invoice_Generation_Exceptions: ' || 'Warning : ' || TmpWarningCode);
	END IF;

                        SELECT  lk.meaning
                          INTO  TmpWarningMsg
                          FROM  pa_lookups lk
                          WHERE lk.lookup_code = TmpWarningCode
                            AND lk.lookup_type = 'INVOICE DISTRIBUTION WARNING';

                        IF g1_debug_mode  = 'Y' THEN
                        	pa_retention_util.write_log('Invoice_Generation_Exceptions: ' || 'Warning Code : ' || TmpWarningCode);
                        	pa_retention_util.write_log('Invoice_Generation_Exceptions: ' || 'Warning Mesg : ' || TmpWarningMsg);
                        END IF;


	OPEN cur_select_projects;
	LOOP
	FETCH cur_select_projects INTO RecSelectProjects;
	EXIT WHEN cur_select_projects%NOTFOUND;

   			IF g1_debug_mode  = 'Y' THEN
   				pa_retention_util.write_log('Invoice_Generation_Exceptions: ' || 'Insert Warning ');
   			END IF;


        		INSERT INTO PA_DISTRIBUTION_WARNINGS (
                                    DRAFT_INVOICE_NUM, PROJECT_ID,
                                    LAST_UPDATE_DATE, LAST_UPDATED_BY,
                                    CREATION_DATE, CREATED_BY,
                                    REQUEST_ID, PROGRAM_APPLICATION_ID,
                                    PROGRAM_ID, PROGRAM_UPDATE_DATE,
                                    WARNING_MESSAGE, WARNING_MESSAGE_CODE)
                                    VALUES
                                            (   TmpInvoiceNum, RecSelectProjects.project_id,
                                                SYSDATE, TmpUserId, SYSDATE,
                                                TmpUserId, p_request_id, TmpProgApplId,
                                                TmpProgId, SYSDATE,
                                                TmpWarningMsg, TmpWarningCode);


	END LOOP;
	CLOSE cur_select_projects;
	EXCEPTION
	WHEN OTHERS THEN
      		RAISE;
END Invoice_Generation_Exceptions;

END pa_retn_billing_pkg;

/
