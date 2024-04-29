--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_CURRENCY" as
/* $Header: PAXICURB.pls 120.6.12010000.8 2010/03/31 17:24:52 dlella ship $ */

/*-------------------   Private Part of The Package ----------------------*/



/*--------------------------------------------------------------------------+
  function to format the currency for multi radix changes. The currency code
  is fetched from the invoice program (paisql.lpc). This formats the currency
  and updated the pa_invoices table
----------------------------------------------------------------------------*/
FUNCTION format_proj_curr_code
  RETURN VARCHAR2 IS

BEGIN

/* Changed the Field length to 22 from 15 for Bug#2337109 pcchandr 16-May-2002 */

  return(fnd_currency.get_format_mask(pa_invoice_currency.g_currency_code,22));

  -- return(fnd_currency.get_format_mask(pa_invoice_currency.g_currency_code,15));

EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);

END format_proj_curr_code;


/*----------------------------------------------------------------------------+
 | This Private Procedure Insert_Distrbution_Warning Inserts draft Invoice    |
 | distribution warning.                                                      |
 +----------------------------------------------------------------------------*/

Procedure Insert_Distrbution_Warning ( P_Project_ID         in  number,
                                         P_Draft_Invoice_Num  in  number,
                                         P_User_ID            in  number,
                                         P_Request_ID         in  number,
                                         P_Invoice_Set_ID     in  number,
                                         P_Lookup_Type        in  varchar2,
                                         P_Error_Message_Code in  varchar2) is

    l_error_message   pa_lookups.meaning%TYPE;

  g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  BEGIN

    BEGIN
      SELECT Meaning
        INTO l_error_message
        FROM PA_Lookups
       WHERE Lookup_Type = P_Lookup_Type
         AND Lookup_Code = P_Error_Message_Code;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_error_message := P_Error_Message_Code;
    END;

    IF (P_Invoice_Set_ID is NULL) THEN

      INSERT INTO PA_DISTRIBUTION_WARNINGS
      (
      PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
      )
      VALUES
      (
      P_Project_ID, P_Draft_Invoice_Num, sysdate, P_User_ID,
      sysdate, P_User_ID, P_Request_ID, l_error_message
      );

    ELSE

      INSERT INTO PA_DISTRIBUTION_WARNINGS
      (
      PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
      )
      SELECT Project_ID, Draft_Invoice_Num, sysdate, P_User_ID,
             sysdate, P_User_ID, P_Request_ID, l_error_message
        FROM PA_Draft_Invoices_ALL
       WHERE Invoice_Set_ID = P_Invoice_Set_ID
       AND project_id = p_project_id ; /* Fix for Performance bug 4942339 */

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Insert_Distrbution_Warning;


/*-------------------   Public Part of The Package ----------------------*/

PROCEDURE recalculATE ( P_Project_Id         IN   NUMBER,
                        P_Draft_Inv_Num      IN   NUMBER,
                        P_Calling_Module     IN   VARCHAR2,
                        P_Customer_Id        IN   NUMBER,
                        P_Inv_Currency_Code  IN   VARCHAR2,
                        P_Inv_Rate_Type      IN   VARCHAR2,
                        P_Inv_Rate_Date      IN   DATE,
                        P_Inv_Exchange_Rate  IN   NUMBER,
                        P_User_Id            IN   NUMBER,
                        P_Bill_Thru_Date     IN   DATE,
                        X_Status            OUT   NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
as


  g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    l_error_message   pa_lookups.meaning%TYPE;

  cursor get_std_lines
  is
     select dii.rowid row_id, /** Bug 2324299 **/
            dii.line_num line_num,
            dii.amount amount,
	    NVL(di.retention_invoice_flag,'N') retention_invoice_flag
     from   pa_draft_invoice_items dii,
	    pa_draft_invoices_all di
     where  dii.project_id         = P_Project_Id
     and    dii.draft_invoice_num  = P_Draft_Inv_Num
     and    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
     and  dii.project_id         = di.project_id
     and    dii.draft_invoice_num  = di.draft_invoice_num
     AND   NVL(di.retention_invoice_flag,'N') ='N'
   UNION
     select dii.rowid row_id,  /** Bug 2324299 **/
            dii.line_num line_num,
            dii.amount amount,
	    NVL(di.retention_invoice_flag,'N') retention_invoice_flag
     from   pa_draft_invoice_items dii,
	    pa_draft_invoices_all di
     where  dii.project_id         = P_Project_Id
     and    dii.draft_invoice_num  = P_Draft_Inv_Num
     and    dii.invoice_line_type  = 'RETENTION'
     and  dii.project_id         = di.project_id
     and    dii.draft_invoice_num  = di.draft_invoice_num
     AND   NVL(di.retention_invoice_flag,'N') ='Y'
     order by line_num;

  cursor get_ret_lines
  is
     select dii.rowid dii_rowid,
            di.retention_percentage retention,
            dii.amount  amt,
            dii.line_num line,
            dii.projfunc_bill_amount,
	    NVL(di.retention_invoice_flag,'N') retention_invoice_flag
     from   pa_draft_invoices di,
            pa_draft_invoice_items dii
     where  di.project_id          = dii.project_id
     and    di.draft_invoice_num   = dii.draft_invoice_num
     and    di.project_id          = P_Project_Id
     and    di.draft_invoice_num   = P_Draft_Inv_Num
     and    dii.invoice_line_type  = 'RETENTION'
     AND    NVL(di.retention_invoice_flag,'N') ='N' ;


  l_inv_currency_code               VARCHAR2(15);
  l_inv_rate_type                   VARCHAR2(30);
  l_inv_rate_date                   DATE;
  l_inv_exchange_rate               NUMBER;
  l_func_curr                       VARCHAR2(15);
  l_total_inv_amount                NUMBER := 0;
  l_con_amt                         NUMBER := 0;
  l_ret_per                         NUMBER := 0;
  l_ret_amt                         NUMBER := 0;
  l_tot_proj_amt                    NUMBER := 0;
  l_round_off_amt                   NUMBER := 0;
  l_inv_ret_amt                     NUMBER := 0;
  l_max_line_num                    NUMBER := 0;
  l_inv_amt                         NUMBER;
  l_denominator                     NUMBER ;
  l_numerator                       NUMBER ;
  l_rate                            NUMBER;
  l_status                          VARCHAR2(1000);

  -- Mcb Related Changes
  l_invproc_currency_code	    VARCHAR2(30);
  l_project_currency_code	    VARCHAR2(30);
  l_funding_currency_code	    VARCHAR2(30);
  l_invproc_currency_type	    VARCHAR2(30);

  l_invtras_rate_flag		    BOOLEAN := FALSE;


  l_projfunc_invtrans_rate          NUMBER := 0;

  l_invoice_date                    DATE;

  l_total_retn_amount               NUMBER;

  l_projfunc_Exchange_Rate          NUMBER;         -- FP_M changes
  l_ProjFunc_Attr_For_AR_Flag       VARCHAR2(1);    -- FP_M changes
  -- l_func_Exchg_Rate_Date_Code   VARCHAR2(30);
  l_projfunc_Exchg_Rate_type	    VARCHAR2(30);
  l_projfunc_Exchg_Rate_Date	    Date;

  l_sum_projfunc_bill_amount        NUMBER := 0;
  l_sum_inv_amount                  NUMBER := 0; /*Bug 5346566*/

  l_PFC_Exchg_Rate_Date_Code		VARCHAR2(30);  -- FP_M Changes Bug 3836514

  l_retention_invoice_flag  VARCHAR2(1) := 'N';  /* Added for bug 9453939*/

begin

/* Fetch the project currency from the project table */

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message(' Inside Recalculate');
	END IF;

        l_invoice_date := pa_billing.GetInvoiceDate;

/* MCB Related Changes  */

  select PROJFUNC_CURRENCY_CODE,
	 PROJECT_CURRENCY_CODE,
	 INVPROC_CURRENCY_TYPE,
	 PROJFUNC_BIL_EXCHANGE_RATE,   -- FP_M Changes
         PROJFUNC_BIL_RATE_DATE_CODE,
         PROJFUNC_BIL_RATE_TYPE,
         PROJFUNC_BIL_RATE_DATE,
	 ProjFunc_Attr_For_AR_Flag    -- FP_M changes
  into   l_func_curr,
         l_project_currency_code,
	 l_invproc_currency_type,
	 l_projfunc_Exchange_Rate,
	 l_PFC_Exchg_Rate_Date_Code, -- FP_M Changes
	 l_projfunc_Exchg_Rate_type,
	 l_projfunc_Exchg_Rate_Date,
	 l_ProjFunc_Attr_For_AR_Flag
  from   pa_projects_all
  where  project_id = P_Project_Id;

/*Added the following code for bug9453939*/
SELECT NVL(di.retention_invoice_flag,'N')
  INTO l_retention_invoice_flag
  FROM pa_draft_invoices_all di
 WHERE di.project_id = P_Project_Id
   AND di.draft_invoice_num = P_Draft_Inv_Num;

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Retention Invoice Flag ' || l_retention_invoice_flag);
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Project Currency Code ' || l_project_currency_code);
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Project Functional ' || l_func_curr);
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' IPC type ' || l_invproc_currency_type);
	END IF;

  IF l_invproc_currency_type ='PROJECT_CURRENCY' THEN

	l_invproc_currency_code := l_project_currency_code;

  ELSIF l_invproc_currency_type ='PROJFUNC_CURRENCY' THEN

	l_invproc_currency_code := l_func_curr;

  ELSIF l_invproc_currency_type ='FUNDING_CURRENCY' THEN

/*	SELECT funding_currency_code
          INTO l_funding_currency_code
	  FROM  pa_summary_project_fundings
	  WHERE project_id  = p_project_id
           AND rownum=1
	  GROUP BY funding_currency_code
		 HAVING sum(total_baselined_amount) <> 0; Commented for bug 3147272*/

/* added the following select statement for bug 3147272*/
	SELECT	funding_currency_code
        INTO	l_funding_currency_code
	FROM	pa_summary_project_fundings
	WHERE	project_id  = p_project_id
        AND	rownum=1
	AND	NVL(total_baselined_amount,0) > 0;


	l_invproc_currency_code := l_funding_currency_code;

  END IF;

  if   P_Calling_Module = 'PAIGEN' then

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Selecting Inv Trans Currency COde');
	END IF;

  	/* for Invoice generation, select currency code and conversion attribute from pa_project_customers. */

       select  inv_currency_code,
               -- nvl(inv_rate_date,P_Bill_Thru_Date), /* commented for mcb2 to use invoice_date */
                nvl(inv_rate_date,NVL(l_invoice_date,P_Bill_Thru_Date)),
               inv_rate_type,
               inv_exchange_rate
       into    l_inv_currency_code,
               l_inv_rate_date,
               l_inv_rate_type,
               l_inv_exchange_rate
       from    pa_project_customers
       where   project_id          = P_Project_Id
       and     customer_id         = P_Customer_id ;

       /*Start of code changes for bug 9453939*/
       if (PA_RETN_BILLING_PKG.G_INV_BY_BILL_TRANS_CURRENCY = 'Y') and (l_retention_invoice_flag = 'Y') then

          l_inv_currency_code := l_invproc_currency_code;

       end if;

      /*End of code changes for bug 9453939*/

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Invoice by Bill Transaction Currency (BTC) ' || PA_RETN_BILLING_PKG.G_INV_BY_BILL_TRANS_CURRENCY);
        	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Invoice Currency Code ' || l_inv_currency_code);
        	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Invoice rate date ' || l_inv_rate_date);
        	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Invoice rate type ' || l_inv_rate_type);
        	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Invoice exch rate ' || l_inv_exchange_rate);
        END IF;


   else

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Assign Inv Trans Currency COde');
	END IF;

   /* for all other cases , copy the input parameter into local placeholder */

       l_inv_currency_code   := P_Inv_Currency_Code;
       l_inv_rate_type       := P_Inv_Rate_Type;
       l_inv_rate_date       := P_Inv_Rate_Date;
       l_inv_exchange_rate   := P_Inv_Exchange_Rate;

   end if;

   if  (l_invproc_currency_code = l_inv_currency_code) AND (l_inv_currency_code = l_func_curr)

   /* If invoice currency is same as invoice processing currency
      and invoice currency is same as project functional currency */
   then

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_invproc_currency_code = l_inv_currency_code) AND (l_inv_currency_code = l_func_curr)' );
	END IF;
        X_Status  := NULL;

        Update pa_draft_invoices_all
        set    inv_currency_code     		= l_invproc_currency_code
              ,inv_rate_type         		= NULL
              ,inv_rate_date         		= NULL
              ,inv_exchange_rate     		= NULL
              ,projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate     	= NULL
        where project_id             		= P_Project_Id
        and   draft_invoice_num      		= P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

   else

     /* If invoice currency is same as invoice processing currency */

     IF  (l_invproc_currency_code = l_inv_currency_code)   THEN
        X_Status  := NULL;
	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_invproc_currency_code = l_inv_currency_code) ');
	END IF;

        Update pa_draft_invoices_all
        set    inv_currency_code     		= l_invproc_currency_code
              ,inv_rate_type         		= NULL
              ,inv_rate_date         		= NULL
              ,inv_exchange_rate     		= NULL
        where project_id             		= P_Project_Id
        and   draft_invoice_num      		= P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

      END IF;

     -- If invoice processing currency is same as project functional currency

     IF  (l_inv_currency_code = l_func_curr) THEN

        X_Status  := NULL;
	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_inv_currency_code = l_func_curr) ');
	END IF;

/*     The following commented and rewritten for bug#2355135
        invoice currency = projfunc currency <> invproc currency
        copy projfunc amount and null out other attributes as AR expects the amounts to be same
        Update pa_draft_invoices_all
        set    projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate     	= NULL
        where project_id             		= P_Project_Id
        and   draft_invoice_num      		= P_Draft_Inv_Num;
*/
        Update pa_draft_invoices_all
        set    projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate        = NULL
              ,inv_currency_code                = l_inv_currency_code
              ,inv_rate_type                    = NULL
              ,inv_rate_date                    = NULL
              ,inv_exchange_rate                = NULL
        where project_id                        = P_Project_Id
        and   draft_invoice_num                 = P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = projfunc_bill_amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

      END IF;

     /* If invoice currency is different from invoice processing currency */

/*     The following commented and rewritten for bug#2355135
     IF  (l_invproc_currency_code <> l_inv_currency_code)   THEN
*/
     IF  (l_invproc_currency_code <> l_inv_currency_code)   AND  (l_inv_currency_code <> l_func_curr) THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_invproc_currency_code <> l_inv_currency_code) ');
	END IF;

        for cur_get_std_lines in get_std_lines
        loop
   	    IF g1_debug_mode  = 'Y' THEN
   	    	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Standard INV LINES Loop');
   	    END IF;
            if  cur_get_std_lines.line_num = 1
            then

            /* call the api to convert the line amount in Invoice Processing  currency to
               invoice currency for line number = 1 */
                l_rate  := l_inv_exchange_rate;
                pa_multi_currency.convert_amount ( P_from_currency => l_invproc_currency_code,
                                                   P_to_currency => l_Inv_currency_code,
                                                   P_conversion_date => l_inv_rate_date,
                                                   P_conversion_type => l_inv_rate_type,
                                                   P_handle_exception_flag => 'Y',
                                                   P_amount => cur_get_std_lines.amount,
                                                   P_user_validate_flag => 'Y',
                                                   P_converted_amount => l_inv_amt,
                                                   P_denominator => l_denominator,
                                                   P_numerator   => l_numerator,
                                                   P_rate => l_rate,
                                                   X_status => l_status );

   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' After Convert Call status  :' || l_status);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' P_denominator : ' || l_denominator);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' P_numerator : ' || l_numerator);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' P_rate : ' || l_rate);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' l_inv_currency_code : ' || l_inv_currency_code);
   	         END IF;
                if  l_status is not null
                then
                       X_Status  := l_status;
                       return;
                end if;

		l_invtras_rate_flag := TRUE;

                /* Update the invoice header 's invoice currency code and
                   conversion attribute */
   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Update DI ');
   	         END IF;
                Update pa_draft_invoices_all
                set    inv_currency_code   = l_inv_currency_code
                      ,inv_rate_type       = l_inv_rate_type
                      ,inv_rate_date       = l_inv_rate_date
                      ,inv_exchange_rate   = l_rate
                where project_id           = P_Project_Id
                and   draft_invoice_num    = P_Draft_Inv_Num ;

           else

                /* Convert line amount for all lines except line no: 1 */
                l_inv_amt := pa_currency.round_trans_currency_amt(((cur_get_std_lines.amount/
                             l_denominator)* l_numerator),l_inv_currency_code);


           end if;

   	   IF g1_debug_mode  = 'Y' THEN
   	   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Invoice Number :' || p_draft_inv_num);
   	   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Line    Number :' || cur_get_std_lines.line_num);
   	   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Invoice Amount :'  || l_inv_amt);
   	   END IF;

           l_max_line_num      := cur_get_std_lines.line_num;

           l_total_inv_amount  := l_total_inv_amount + l_inv_amt;
           l_tot_proj_amt      := l_tot_proj_amt + cur_get_std_lines.amount;

           /* Update the line 's invoice currency amount*/
   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Update DII ');
   	         END IF;

           update pa_draft_invoice_items
           set    inv_amount  = l_inv_amt
           where  rowid       = cur_get_std_lines.row_id; /** Bug 2324299 **/

         end loop;

         /* Populate invoice currency amount for retention line */

	l_total_retn_amount :=0;

         for  cur_get_ret_lines in get_ret_lines
         loop
              l_ret_per      := cur_get_ret_lines.retention;
              l_ret_amt      := NVL(l_ret_amt,0)+ NVL(cur_get_ret_lines.amt,0);

		if cur_get_ret_lines.retention_invoice_flag ='Y' THEN

              		l_max_line_num := cur_get_ret_lines.line;

		end if;

	     l_inv_ret_amt := pa_currency.round_trans_currency_amt(((cur_get_ret_lines.amt/
                             l_denominator)* l_numerator),l_inv_currency_code);

              /* Commented out for Retention Enhancement changes
		 l_inv_ret_amt  := (-1)*pa_currency.round_trans_currency_amt(
                               ((cur_get_ret_lines.retention/100)*
                               l_total_inv_amount),l_inv_currency_code);  */

   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Update DII for Retention ');
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Retention Amount in IPC  : ' || cur_get_ret_lines.amt);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Retention Amount in ITC  : ' || l_inv_ret_amt);
   	         END IF;

              update pa_draft_invoice_items
              set    inv_amount = l_inv_ret_amt
              where  rowid      = cur_get_ret_lines.dii_rowid;

		l_total_retn_amount :=  NVL(l_total_retn_amount,0) + NVL(l_inv_ret_amt,0);

         end loop;

         /* Adjust Round Off Error */
         l_tot_proj_amt  := l_tot_proj_amt + l_ret_amt;
         l_con_amt := pa_currency.round_trans_currency_amt(((l_tot_proj_amt/
                             l_denominator)* l_numerator),l_inv_currency_code);

         l_total_inv_amount  := l_total_inv_amount + l_total_retn_amount;

         l_round_off_amt     := l_total_inv_amount - l_con_amt;


   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Update DII for Adjustment ');
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Total Invoice Amount : ' || l_total_inv_amount);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Total Retentn Amount : ' || l_total_retn_amount);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Total Calcul  Amount : ' || l_con_amt);
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Total Round Off Amt  : ' || l_round_off_amt);
   	         END IF;

         Update PA_DRAFT_INVOICE_ITEMS dii
         SET    dii.Inv_amount = pa_currency.round_trans_currency_amt(
		      dii.Inv_amount - l_round_off_amt,l_inv_currency_code)
         Where  dii.project_id        = P_Project_Id
         and    dii.Draft_Invoice_num = P_Draft_Inv_Num
         and    dii.Line_Num          = l_max_line_num;


         /* Set invoice currency amount for net zero line to zero */
   	         IF g1_debug_mode  = 'Y' THEN
   	         	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Update DII for net zero ');
   	         END IF;
         update  pa_draft_invoice_items
         set     inv_amount        = 0
         where   project_id        = P_Project_Id
         and     draft_invoice_num = P_Draft_Inv_Num
         and     invoice_line_type = 'NET ZERO ADJUSTMENT';

   end if;

   end if;/* end if for l_inv_currency_code <> l_invproc_currency_code */

   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' PFC          : ' || l_func_curr);
   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Inv Trans    : ' || l_inv_currency_code);
   END IF;

   -- FP_M Changes #1
   IF  (l_func_curr <> l_inv_currency_code) and (l_invproc_currency_code <> l_func_curr)   THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_func_curr <> l_inv_currency_code) ');
	END IF;

	IF l_ProjFunc_Attr_For_AR_Flag <> 'Y' then
	   -- This if condition is added from FP_M changes bug 3693879

/* Start of comment for bug 2544659 : To avoid divide by 0 on 0$ invoices
	SELECT NVL(sum(dii.inv_amount),0)/NVL(sum(dii.projfunc_bill_amount),0)
	INTO l_projfunc_invtrans_rate
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
 End of comment for bug 2544659*/

 /* Code added for bug 2544659 */
 /* Code Commented for bug 3436063
	SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
	INTO l_projfunc_invtrans_rate
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
	 AND  nvl(dii.projfunc_bill_amount,0) <> 0
	 AND  rownum=1;
*/
  /****Code added for 3436063****/

    SELECT sum(NVL(dii.projfunc_bill_amount,0))
    INTO l_sum_projfunc_bill_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;

    /*** For Bug 5346566 ***/
    SELECT sum(NVL(dii.inv_amount,0))
    INTO l_sum_inv_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
    /*** End of code change for Bug 5346566 ***/

    IF l_sum_projfunc_bill_amount <> 0 AND l_sum_inv_amount <> 0  /*** Condition added for bug 5346566 ***/
    THEN
        SELECT sum(NVL(dii.inv_amount,0))/sum(NVL(dii.projfunc_bill_amount,0))
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         having  sum(nvl(dii.projfunc_bill_amount,0)) <> 0;
         ELSE
        SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         AND  nvl(dii.projfunc_bill_amount,0) <> 0
         AND  rownum=1;
     END IF;

 /****End of code added for 3436063****/
    	  Update pa_draft_invoices_all
          set    projfunc_invtrans_rate_type      = 'User'
              /*  ,projfunc_invtrans_rate_date      = sysdate  commented for bug 3485407 and modified as follows ..*/
              ,projfunc_invtrans_rate_date      = invoice_date /* for bug 3485407 */
              ,projfunc_invtrans_ex_rate        = NVL(l_projfunc_invtrans_rate,0)
          where project_id                        = P_Project_Id
          and   draft_invoice_num                 = P_Draft_Inv_Num;
    Else -- If l_ProjFunc_Attr_For_AR_Flag = 'Y' then  bug 3693879
	 -- This change is done for FP_M only

     -- Update the conversion rate for ITC to PFC  : FP_M changes
     --  If the Project is implemented with Project Function Attributes for AR flag is
     --  implemented then update the Project Functional Invoice Transaction
     --  exchange rate as the Project Functional Exchange Rate
     --  otherwise update Project Functional Invoice Transaction exchange rate as the
     --  project functional invoice transaction rate

		  --================================
		  -- Newly added code for bug fix Bug 3836514
		     l_Rate := 0;
                     pa_multi_currency.convert_amount (
				P_from_currency 	=> l_func_curr,
                                P_to_currency 		=> l_invproc_currency_code,
                                P_conversion_date 	=> l_invoice_Date,
                                P_conversion_type 	=> l_projfunc_Exchg_Rate_type,
                                P_Amount	 	=> l_inv_amt,
                                P_user_validate_flag 	=> 'Y',
                                P_handle_exception_flag => 'Y',
                                P_converted_amount 	=> l_inv_amt,
                                P_denominator 		=> l_denominator,
                                P_numerator   		=> l_numerator,
                                P_rate 			=> l_rate,
                                X_status 		=> l_status

             		);

		  --================================

	  PA_MCB_INVOICE_PKG.log_message('recalculATE: If l_ProjFunc_Attr_For_AR_Flag = Y');
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_invoice_date ' || l_invoice_date);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_PFC_Exchg_Rate_Date_Code ' || l_PFC_Exchg_Rate_Date_Code);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_projfunc_Exchg_Rate_Date ' || l_projfunc_Exchg_Rate_Date);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_projfunc_Exchg_Rate_type ' || l_projfunc_Exchg_Rate_type);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_Rate ' || l_Rate);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_Projfunc_Exchange_Rate ' || l_Projfunc_Exchange_Rate);

	  Update pa_draft_invoices_all
          set  projfunc_invtrans_rate_type = l_projfunc_Exchg_Rate_type
              ,projfunc_invtrans_rate_date = DECODE(l_PFC_Exchg_Rate_Date_Code,
	  					'PA_INVOICE_DATE', l_invoice_date,  -- Fix for bug 3836514
						l_projfunc_Exchg_Rate_Date)
              ,projfunc_invtrans_ex_rate   = decode(l_projfunc_Exchg_Rate_type,'User',(1/l_Projfunc_Exchange_Rate),l_Rate)/* Added for bug 7575486*/
						/*DECODE(l_PFC_Exchg_Rate_Date_Code, 'PA_INVOICE_DATE',
                                                  decode(l_projfunc_Exchg_Rate_type,'User',l_Projfunc_Exchange_Rate,l_Rate),
	  					l_Projfunc_Exchange_Rate)Modified for Bug 7417980, commented for bug 7575486*/
          where project_id             = P_Project_Id
          and   draft_invoice_num      = P_Draft_Inv_Num;
	-- End of FP_M changes
     End If; -- of l_ProjFunc_Attr_For_AR_Flag value condition
   ELSIF  (l_func_curr <> l_inv_currency_code) and (l_invproc_currency_code = l_func_curr)   THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_func_curr <> l_inv_currency_code) and (l_invproc_currency_code = l_func_curr) ');
	END IF;

	IF (l_invtras_rate_flag) THEN

		IF g1_debug_mode  = 'Y' THEN
			PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || 'Invoice Transaction Rate is available  ');
		END IF;

		-- FP_M changes
     		--  If the Project is implemented with Project Function Attributes for AR flag is
	  	--  implemented then in draft Invoices, update the Project Functional Invoice Transaction
	       	--  exchange rate as the Project Functional Exchange Rate
		--  otherwise update Project Functional Invoice Transaction exchange rate as the
		--  invoice exchange rate i.e. derived rate

		-- Modified this Update statement for fixing the bug 3693879
                -- Commented the below condition for 3693879; when IPC=PFC and PFC <> ITC,
                -- populate projfunc_invtrans attribute with invoice currency attributes.
		/*If l_ProjFunc_Attr_For_AR_Flag = 'Y' then
		  --================================
		  -- Newly added code for bug fix Bug 3836514
		     l_Rate := 0;
                     pa_multi_currency.convert_amount (
				P_from_currency 	=> l_func_curr,
                                P_to_currency 		=> l_invproc_currency_code,
                                P_conversion_date 	=> l_invoice_Date,
                                P_conversion_type 	=> l_projfunc_Exchg_Rate_type,
                                P_Amount	 	=> l_inv_amt,
                                P_user_validate_flag 	=> 'Y',
                                P_handle_exception_flag => 'Y',
                                P_converted_amount 	=> l_inv_amt,
                                P_denominator 		=> l_denominator,
                                P_numerator   		=> l_numerator,
                                P_rate 			=> l_rate,
                                X_status 		=> l_status

             		);

		  --================================
		  Update pa_draft_invoices_all
        	   set    projfunc_invtrans_rate_type  = l_projfunc_Exchg_Rate_type
              		  ,projfunc_invtrans_rate_date = DECODE(l_PFC_Exchg_Rate_Date_Code,
			  					'PA_INVOICE_DATE', l_invoice_date, -- Fix for Bug 3836514
								l_projfunc_Exchg_Rate_Date)
              		  ,projfunc_invtrans_ex_rate   = DECODE(l_PFC_Exchg_Rate_Date_Code, 'PA_INVOICE_DATE', l_Rate,
			  					l_Projfunc_Exchange_Rate)
        	  where project_id         = P_Project_Id
        	  and   draft_invoice_num  = P_Draft_Inv_Num;
		Else */
		  Update pa_draft_invoices_all
        	   set    projfunc_invtrans_rate_type  = inv_rate_type
              		  ,projfunc_invtrans_rate_date = inv_rate_date
              		  ,projfunc_invtrans_ex_rate   = inv_exchange_rate
        	  where project_id         = P_Project_Id
        	  and   draft_invoice_num  = P_Draft_Inv_Num;
	       /*  End If;  */
	/* Bug fix 2364014 removed the decode */
	END IF;

   END IF;

exception
    when OTHERS
    then
   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Sql Error : ' || sqlerrm);
   END IF;
         RAISE;
end RECALCULATE;

/* This procedure will return the invoice Currency code and Conversion attribute
   for Input Invoice */
PROCEDURE get_inv_curr_info ( P_Project_Id          IN NUMBER,
                              P_Draft_Inv_Num       IN NUMBER,
                              X_Inv_curr_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              X_Inv_rate_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              X_Inv_rate_date      OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                              X_Inv_exchange_rate  OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

    l_error_message   pa_lookups.meaning%TYPE;

 Cursor get_info
 is
   select Inv_Currency_code,
          Inv_rate_date,
          Inv_rate_type,
          Inv_exchange_rate
   from   pa_draft_invoices
   where  project_id        = P_Project_Id
   and    draft_invoice_num = P_Draft_Inv_Num;

  l_inv_curr_code            varchar2(15);
  l_inv_rate_date            date;
  l_inv_rate_type            varchar2(30);
  l_exchange_rate            number;

BEGIN

  open get_info;

  fetch get_info into l_inv_curr_code,l_inv_rate_date,
                          l_inv_rate_type,l_exchange_rate;

  close get_info;

  X_Inv_curr_code     := l_inv_curr_code;
  X_Inv_rate_type     := l_inv_rate_type;
  X_Inv_rate_date     := l_inv_rate_date;
  X_Inv_exchange_rate := l_exchange_rate;

END get_inv_curr_info;

/* This procedure is added for Bug 3051294 */
/* This procedure will return the Conversion attribute
   for project functional currency and invoice currency */

PROCEDURE get_projfunc_inv_curr_info ( P_Project_Id              IN NUMBER,
                                       P_Draft_Inv_Num           IN NUMBER,
                                       X_Projfunc_Inv_rate_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       X_Projfunc_Inv_rate_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                       X_Projfunc_Inv_ex_rate   OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

 Cursor get_info
 is
   select Projfunc_invtrans_rate_date,
          Projfunc_invtrans_rate_type,
          Projfunc_invtrans_ex_rate
   from   pa_draft_invoices
   where  project_id        = P_Project_Id
   and    draft_invoice_num = P_Draft_Inv_Num;

  l_inv_rate_date            date;
  l_inv_rate_type            varchar2(30);
  l_exchange_rate            number;

BEGIN

  open get_info;

  fetch get_info into l_inv_rate_date,l_inv_rate_type,l_exchange_rate;

  close get_info;

  X_Projfunc_Inv_rate_type     := l_inv_rate_type;
  X_Projfunc_Inv_rate_date     := l_inv_rate_date;
  X_Projfunc_Inv_ex_rate       := l_exchange_rate;

END get_projfunc_inv_curr_info;

/* This procedure will fetch the project currency code for input
   Project */
PROCEDURE get_proj_curr_info ( P_Project_Id          IN NUMBER,
                               X_Inv_curr_code      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

    l_error_message   pa_lookups.meaning%TYPE;

 /* Earlier this was referring to project_currency_code because PFC and PC are same.
    This procedure has to return PFC */
  cursor get_proj_cur
  is
     select PROJFUNC_CURRENCY_CODE
     from   PA_PROJECTS_ALL
     where  PROJECT_ID   = P_Project_Id;

  l_proj_curr     PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;

BEGIN

  open get_proj_cur;

  fetch get_proj_cur into l_proj_curr;

  close get_proj_cur;

  X_Inv_curr_code := l_proj_curr;

END get_proj_curr_info;

/*-----------------------------------------------------------------+
 | This procedure is only called from PAIGEN.                      |
 +-----------------------------------------------------------------*/
PROCEDURE Update_CRMemo_Invamt  ( P_Project_Id                IN NUMBER,
                                  P_Draft_Inv_Num             IN NUMBER,
                                  P_Draft_Inv_Num_Credited    IN NUMBER)
IS

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    l_error_message   pa_lookups.meaning%TYPE;

  cursor get_orig_amt
  is
     select sum(dii.amount),
            sum(dii.inv_amount),
            nvl(di.canceled_flag,'N'),max(dii.line_num) /*Added max line for bug 6501526*/
     from   pa_draft_invoice_items dii,
            pa_draft_invoices di
     where  di.project_id             = P_Project_Id
     and    di.draft_invoice_num      = P_Draft_Inv_Num_Credited
     and    di.project_id             = dii.project_id
     and    di.draft_invoice_num      = dii.draft_invoice_num
     group by nvl(di.canceled_flag,'N');

  cursor get_adjust_cm(l_tot_inv_amt   NUMBER,
                       l_tot_amt       NUMBER )
  is
/* commented for bug 1633744 .. select modified  as below this comment
     select cmdii.amount amt,
            pa_currency.round_trans_currency_amt(((l_tot_inv_amt/l_tot_amt)
            *cmdii.amount),cmdi.inv_currency_code) line_amt,
            cmdi.retention_percentage retper,
            cmdi.inv_currency_code curcode,
            cmdii.line_num line_num
     from   pa_draft_invoices cmdi,
            pa_draft_invoice_items cmdii
     where  cmdi.project_id                     = P_Project_Id
     and    cmdi.draft_invoice_num              = P_Draft_Inv_Num
     and    cmdi.project_id                     = cmdii.project_id
     and    cmdi.draft_invoice_num              = cmdii.draft_invoice_num
     and    cmdii.invoice_line_type        not in
                                       ('RETENTION','NET ZERO ADJUSTMENT')
  for update of cmdii.amount
  order by cmdii.line_num;
End of comments for bug 1633744   */
     select cmdii.amount amt,
             pa_currency.round_trans_currency_amt((cmdii.amount* cmdii1.inv_amount/cmdii1.amount ),cmdi.inv_currency_code) line_amt,
            cmdi.retention_percentage retper,
            cmdi.inv_currency_code curcode,
            cmdii.line_num line_num
     from   pa_draft_invoices cmdi,
            pa_draft_invoice_items cmdii,
            pa_draft_invoice_items cmdii1
     where  cmdi.project_id                     = P_Project_Id
     and    cmdi.draft_invoice_num              = P_Draft_Inv_Num
     and    cmdi.project_id                     = cmdii.project_id
     and    cmdi.draft_invoice_num              = cmdii.draft_invoice_num
     and    cmdii.project_id                    = cmdii1.project_id
     and    cmdii1.draft_invoice_num            = cmdi.draft_invoice_num_credited
     and    cmdii.draft_inv_line_num_credited   = cmdii1.line_num
     and    cmdii1.invoice_line_type        not in
                                       ('RETENTION','NET ZERO ADJUSTMENT')
  for update of cmdii.inv_amount
  order by cmdii.line_num;


  cursor get_ret_amt
  is
    select amount,
           line_num
    from   pa_draft_invoice_items
    where  project_id        = P_Project_Id
    and    draft_invoice_num = P_Draft_Inv_Num
    and    invoice_line_type = 'RETENTION'
    for update of amount;
/*
 Cursor get_mult_ret_amt added to take care of new retention model . Now retention percentage can be at
levels other than the project level as it used to be ..in which case retention_percentage at invoice level will be 0
Bug 2689348
*/
Cursor get_mult_ret_amt is
     select cmdii.amount amt,
             pa_currency.round_trans_currency_amt((cmdii.amount* cmdii1.inv_amount/cmdii1.amount ),cmdi.inv_currency_code) line_amt,
            cmdii.line_num line_num
     from   pa_draft_invoices cmdi,
            pa_draft_invoice_items cmdii,
            pa_draft_invoice_items cmdii1
     where  cmdi.project_id                     = P_Project_Id
     and    cmdi.draft_invoice_num              = P_Draft_Inv_Num
     and    cmdi.project_id                     = cmdii.project_id
     and    cmdi.draft_invoice_num              = cmdii.draft_invoice_num
     and    cmdii.project_id                    = cmdii1.project_id
     and    cmdii1.draft_invoice_num            = cmdi.draft_invoice_num_credited
     and    cmdii.draft_inv_line_num_credited   = cmdii1.line_num
     and    cmdii1.invoice_line_type =  'RETENTION'
  for update of cmdii.inv_amount
  order by cmdii.line_num;


  l_total_cnt                 NUMBER := 0;
  l_retper                    NUMBER := 0;
  l_tot_inv_cur_amt           NUMBER := 0;
  l_tot_proj_cur_amt          NUMBER := 0;
  l_inv_cur_amt               NUMBER;
  l_ret_amt                   NUMBER;
  l_line_num                  NUMBER;
  l_max_line_num              NUMBER := 0;
  l_round_off_amt             NUMBER := 0;
  l_ret_proj_cur_amt          NUMBER := 0;
  l_proj_cur_amt              NUMBER;
  l_cancel_flag               VARCHAR2(1);
  l_curcode                   VARCHAR2(16);
  l_dummy                     VARCHAR2(1);
  l_max_line		      NUMBER; /*Added for bug 6501526*/


  /* Added to fix bug 2165379 */
  l_invproc_currency_code           VARCHAR2(30);
  l_project_currency_code           VARCHAR2(30);
  l_funding_currency_code           VARCHAR2(30);
  l_invproc_currency_type           VARCHAR2(30);

  l_projfunc_invtrans_rate          NUMBER := 0;
  l_rate                            NUMBER := 0;

  l_invoice_date                    DATE;

  l_inv_currency_code               VARCHAR2(15);
  l_inv_rate_type                   VARCHAR2(30);
  l_inv_rate_date                   DATE;
  l_inv_exchange_rate               NUMBER;
  l_func_curr                       VARCHAR2(15);

  /* End Add to fix bug 2165379 */
  l_sum_projfunc_bill_amount        NUMBER:=0;
  l_sum_inv_amount                  NUMBER:=0; /*** For bug 5346566 ***/
/* Added for bug 7575486*/
  l_projfunc_Exchange_Rate          NUMBER;
  l_ProjFunc_Attr_For_AR_Flag       VARCHAR2(1);
  l_projfunc_Exchg_Rate_type	    VARCHAR2(30);
  l_projfunc_Exchg_Rate_Date	    Date;
  l_PFC_Exchg_Rate_Date_Code	    VARCHAR2(30);
  l_inv_amt			    NUMBER:=0;
  l_denominator			    NUMBER :=0;
  l_numerator                       NUMBER :=0;
  l_status                          VARCHAR2(1000);
/* End bug 7575486*/
BEGIN


  /* Added to fix bug 2165379 */

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Inside Update cr memo');
  END IF;

  select PROJFUNC_CURRENCY_CODE,
	 PROJECT_CURRENCY_CODE,
	 INVPROC_CURRENCY_TYPE,
 	 PROJFUNC_BIL_EXCHANGE_RATE,   -- Added for bug 7575486
         PROJFUNC_BIL_RATE_DATE_CODE,
         PROJFUNC_BIL_RATE_TYPE,
         PROJFUNC_BIL_RATE_DATE,
	 ProjFunc_Attr_For_AR_Flag     -- bug 7575486

  into   l_func_curr,
         l_project_currency_code,
	 l_invproc_currency_type,
	 l_projfunc_Exchange_Rate,     -- Added for bug 7575486
	 l_PFC_Exchg_Rate_Date_Code,
	 l_projfunc_Exchg_Rate_type,
	 l_projfunc_Exchg_Rate_Date,
	 l_ProjFunc_Attr_For_AR_Flag   -- bug 7575486
  from   pa_projects_all
  where  project_id = P_Project_Id;

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Project Currency Code ' || l_project_currency_code);
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Project Functional ' || l_func_curr);
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' IPC type ' || l_invproc_currency_type);
	END IF;

  IF l_invproc_currency_type ='PROJECT_CURRENCY' THEN

	l_invproc_currency_code := l_project_currency_code;

  ELSIF l_invproc_currency_type ='PROJFUNC_CURRENCY' THEN

	l_invproc_currency_code := l_func_curr;

  ELSIF l_invproc_currency_type ='FUNDING_CURRENCY' THEN

/*	SELECT funding_currency_code
          INTO l_funding_currency_code
	  FROM  pa_summary_project_fundings
	  WHERE project_id  = p_project_id
           AND rownum=1
	  GROUP BY funding_currency_code
		 HAVING sum(total_baselined_amount) <> 0; Commented the code for bug 3147272*/

/* added the following select statement for bug 3147272 */

	SELECT	funding_currency_code
        INTO	l_funding_currency_code
	FROM	pa_summary_project_fundings
	WHERE	project_id  = p_project_id
	AND	rownum=1
	AND	NVL(total_baselined_amount,0) > 0;

	l_invproc_currency_code := l_funding_currency_code;

  END IF;


  get_inv_curr_info ( P_Project_Id         => p_project_id,
                      P_Draft_Inv_Num      => p_draft_inv_num,
                      X_Inv_curr_code      => l_inv_currency_code,
                      X_Inv_rate_type      => l_inv_rate_type,
                      X_Inv_rate_date      => l_inv_rate_date,
                      X_Inv_exchange_rate  => l_inv_exchange_rate);


  /* END Added to fix bug 2165379 */


  /* Added to fix bug 2165379 */

/* All code from here in this procedure has been extensively modified to fix bug 2734504 */


   if  (l_invproc_currency_code = l_inv_currency_code) AND (l_inv_currency_code = l_func_curr)

   /* If invoice currency is same as invoice processing currency
      and invoice currency is same as project functional currency */
   then

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' l_invproc_currency_code = l_inv_currency_code = l_func_curr)' );
	END IF;

        -- X_Status  := NULL;

        Update pa_draft_invoices_all
        set    inv_currency_code     		= l_invproc_currency_code
              ,inv_rate_type         		= NULL
              ,inv_rate_date         		= NULL
              ,inv_exchange_rate     		= NULL
              ,projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate     	= NULL
        where project_id             		= P_Project_Id
        and   draft_invoice_num      		= P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

   else

     IF  (l_invproc_currency_code = l_inv_currency_code)   THEN

     /* If invoice currency is same as invoice processing currency */

        -- X_Status  := NULL;
	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_invproc_currency_code = l_inv_currency_code) ');
	END IF;

        Update pa_draft_invoices_all
        set    inv_currency_code     		= l_invproc_currency_code
              ,inv_rate_type         		= NULL
              ,inv_rate_date         		= NULL
              ,inv_exchange_rate     		= NULL
        where project_id             		= P_Project_Id
        and   draft_invoice_num      		= P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

      END IF;

      IF (l_inv_currency_code = l_func_curr) THEN
        -- If invoice currency is same as project functional currency
        -- X_Status  := NULL;
	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' If  (l_inv_currency_code = l_func_curr) ');
	END IF;

        Update pa_draft_invoices_all
        set    projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate        = NULL
              ,inv_currency_code                = l_inv_currency_code
              ,inv_rate_type                    = NULL
              ,inv_rate_date                    = NULL
              ,inv_exchange_rate                = NULL
        where project_id                        = P_Project_Id
        and   draft_invoice_num                 = P_Draft_Inv_Num;

        Update pa_draft_invoice_items
        set    inv_amount            = projfunc_bill_amount
        where project_id             = P_Project_Id
        and   draft_invoice_num      = P_Draft_Inv_Num;

   END IF;

   IF  (l_invproc_currency_code <> l_inv_currency_code)   AND  (l_inv_currency_code <> l_func_curr) THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' l_invproc_currency_code <> l_inv_currency_code ');
	END IF;

       open get_orig_amt;

       fetch get_orig_amt into l_proj_cur_amt,l_inv_cur_amt,l_cancel_flag,l_max_line; /* Modified for bug 6501526*/

       close get_orig_amt;

       If l_cancel_flag = 'N' Then
          -- Write-off and Credit memo processing

          -- Updation of Non Retention  Line
          for  cur_get_adjust_cm  in get_adjust_cm ( l_inv_cur_amt,
                                                l_proj_cur_amt )
          loop
            Update pa_draft_invoice_items
            set    inv_amount     = cur_get_adjust_cm.line_amt
            where  current of get_adjust_cm;

            l_tot_inv_cur_amt  := l_tot_inv_cur_amt + cur_get_adjust_cm.line_amt;
            l_tot_proj_cur_amt := l_tot_proj_cur_amt + cur_get_adjust_cm.amt;
            l_max_line_num     := cur_get_adjust_cm.line_num;

            If l_retper = 0
            then
               l_retper  := cur_get_adjust_cm.retper;
               l_curcode := cur_get_adjust_cm.curcode;
            end if;
          end loop;

          if l_retper <> 0 then  /* added for 2689348  Carry on with old retention model */
             -- Updation of Retention Line
             l_ret_amt := (-1) * pa_currency.round_trans_currency_amt((l_tot_inv_cur_amt*l_retper)
                             /100,l_curcode);

             open get_ret_amt;

             loop
               fetch get_ret_amt into l_ret_proj_cur_amt,l_line_num;

               exit when get_ret_amt%notfound;

               l_tot_proj_cur_amt := l_tot_proj_cur_amt + l_ret_proj_cur_amt;
               l_tot_inv_cur_amt  := l_tot_inv_cur_amt + l_ret_amt;

               update pa_draft_invoice_items
               set    inv_amount  = l_ret_amt
               where  current of get_ret_amt;

               l_max_line_num := l_line_num;

             end loop;

             close get_ret_amt;

          else    /* added for 2689348  for new retention model */

	     for cur_mult_ret_amt in get_mult_ret_amt
 	     loop
	       update pa_draft_invoice_items dii
	       set  inv_amount= cur_mult_ret_amt.line_amt
	       where current of get_mult_ret_amt;

            l_tot_inv_cur_amt  := l_tot_inv_cur_amt + cur_mult_ret_amt.line_amt;
            l_tot_proj_cur_amt := l_tot_proj_cur_amt + cur_mult_ret_amt.amt;
            l_max_line_num     := cur_mult_ret_amt.line_num;

            end loop;
          end if ; /* End of code change for bug 2689348 */

          if  l_proj_cur_amt <>0 then  /* added to avoid divide by zero : 1633744 */
               -- Adjust Round-Off Error
               l_round_off_amt := l_tot_inv_cur_amt -
                             pa_currency.round_trans_currency_amt((l_inv_cur_amt/l_proj_cur_amt)
                             *l_tot_proj_cur_amt,l_curcode);

               update pa_draft_invoice_items
               set    inv_amount         = inv_amount - l_round_off_amt
               where  project_id         = P_Project_Id
               and    draft_invoice_num  = P_Draft_Inv_Num
               and    line_num           = l_max_line_num
	       and    draft_inv_line_num_credited = l_max_line; /*Added for bug 6501526*/

          end if; /* 1633744   end if for l_proj_cur_amt <>0   */

       Else

          -- For Cancellation Of Invoice
          Update pa_draft_invoice_items dii
          set    dii.inv_amount    = ( select (-1)*dii1.inv_amount
                                       from   pa_draft_invoice_items dii1
                                       where  dii1.project_id           = dii.project_id
                                       and    dii1.draft_invoice_num    = P_Draft_Inv_Num_credited
                                       and    dii1.line_num
                                                              = dii.draft_inv_line_num_credited)
          where dii.project_id          = P_Project_Id
          and   dii.draft_Invoice_Num   = P_Draft_Inv_Num;

       END IF;


       /* Start of comment for bug 2544659 : To avoid divide by 0 on 0$ invoices

	SELECT NVL(sum(dii.inv_amount),0)/NVL(sum(dii.amount),0)
	INTO l_rate
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
End of comments for bug 2544659 */

/* code fix for bug 2544659 */
/*Code commented for 3436063
	SELECT NVL(dii.inv_amount,0)/NVL(dii.amount,0)
	INTO l_rate
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         AND  nvl(dii.amount,0)<>0
         AND  rownum=1 ;
*/
 /****Code added for 3436063****/
 /* commented for bug 6501526
    SELECT sum(NVL(dii.projfunc_bill_amount,0))
    INTO l_sum_projfunc_bill_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
 */
    /*** For Bug 5346566 ***/
    /* commented for bug 6501526
    SELECT sum(NVL(dii.inv_amount,0))
    INTO l_sum_inv_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
   */
   /*** End of code change for Bug 5346566 ***/

/* commented for bug 6501526
    IF l_sum_projfunc_bill_amount <> 0 AND l_sum_inv_amount <> 0 /*** Condtion added for bug 5346566 ***
    THEN
        SELECT sum(NVL(dii.inv_amount,0))/sum(NVL(dii.amount,0))
        INTO l_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         having  sum(nvl(dii.amount,0)) <> 0;
         ELSE
        SELECT NVL(dii.inv_amount,0)/NVL(dii.amount,0)
        INTO l_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         AND  nvl(dii.amount,0) <> 0
         AND  rownum=1;
     END IF;
  */
 /****End of code added for 3436063****/


/* Bug 2689348 */

/* commented for bug 6501526
	SELECT di.inv_rate_type,di.inv_rate_date
	INTO l_inv_rate_type,l_inv_rate_date
	FROM pa_draft_invoices_all di,pa_draft_invoices_all cmdi
	WHERE cmdi.draft_invoice_num_credited= di.draft_invoice_num
	AND   cmdi.project_id=di.project_id
	AND   cmdi.draft_invoice_num=P_Draft_Inv_Num
	AND   cmdi.project_id=P_Project_Id;

     -- Update the conversion rate for ITC to IC

    	Update pa_draft_invoices_all
        set    inv_currency_code     		= l_inv_currency_code
             -- ,inv_rate_type         		= 'User'
              --,inv_rate_date         		= sysdate   Should be picked from main invoice: Bug 2689348
	      -- code changed for bug 2689348
	      ,inv_rate_type			= l_inv_rate_type
	      ,inv_rate_date 			= l_inv_rate_date
              ,inv_exchange_rate     		= l_rate
        where project_id                        = P_Project_Id
        and   draft_invoice_num                 = P_Draft_Inv_Num;
*/
   END IF;
   END IF;

   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' PFC          : ' || l_func_curr);
   	PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' Inv Trans    : ' || l_inv_currency_code);
   END IF;

   IF  (l_func_curr <> l_inv_currency_code) and (l_invproc_currency_code <> l_func_curr)   THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' l_func_curr <> l_inv_currency_code and l_invproc_currency_code <> l_func_curr ');
	END IF;

			IF l_ProjFunc_Attr_For_AR_Flag <> 'Y' then  /* Added for bug 7575486*/

/* Start of comment for bug 2544659 : To avoid divide by 0 on 0$ invoices
	SELECT NVL(sum(dii.inv_amount),0)/NVL(sum(dii.projfunc_bill_amount),0)
	INTO l_projfunc_invtrans_rate
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
 End of comments for bug 2544659 */

 /* Code added for bug 2544659 */
/*Code commented for 3436063
        SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         AND  nvl(dii.projfunc_bill_amount,0) <> 0
         AND  rownum=1;
*/

 /****Code added for 3436063****/
    SELECT sum(NVL(dii.projfunc_bill_amount,0))
    INTO l_sum_projfunc_bill_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;

    /*** For Bug 5346566 ***/
    SELECT sum(NVL(dii.inv_amount,0))
    INTO l_sum_inv_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num;
    /*** End of code change for Bug 5346566 ***/

    IF l_sum_projfunc_bill_amount <> 0 AND l_sum_inv_amount <> 0 /*** Condition added for bug 5346566 ***/
    THEN
        SELECT sum(NVL(dii.inv_amount,0))/sum(NVL(dii.projfunc_bill_amount,0))
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         having  sum(nvl(dii.projfunc_bill_amount,0)) <> 0;
         ELSE
        SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = P_Draft_Inv_Num
         AND  nvl(dii.projfunc_bill_amount,0) <> 0
         AND  rownum=1;
     END IF;
 /****End of code added for 3436063****/

     -- Update the conversion rate for ITC to PFC

    	Update pa_draft_invoices_all
        set    projfunc_invtrans_rate_type      = 'User'
              /*  ,projfunc_invtrans_rate_date      = sysdate  commented for bug 3485407 and modified as follows ..*/
              ,projfunc_invtrans_rate_date      = invoice_date /* for bug 3485407 */
              ,projfunc_invtrans_ex_rate        = NVL(l_projfunc_invtrans_rate,0)
        where project_id                        = P_Project_Id
        and   draft_invoice_num                 = P_Draft_Inv_Num;

/* Added for bug 7575486*/
	ELSE
		     l_Rate := 0;
		     l_inv_amt := 1;
		     select	invoice_date
		     into	l_invoice_date
		     from	pa_draft_invoices_all
                     where	project_id             = P_Project_Id
                     and	draft_invoice_num      = P_Draft_Inv_Num;

                     pa_multi_currency.convert_amount (
				P_from_currency 	=> l_func_curr,
                                P_to_currency 		=> l_invproc_currency_code,
                                P_conversion_date 	=> l_invoice_Date,
                                P_conversion_type 	=> l_projfunc_Exchg_Rate_type,
                                P_Amount	 	=> l_inv_amt,
                                P_user_validate_flag 	=> 'Y',
                                P_handle_exception_flag => 'Y',
                                P_converted_amount 	=> l_inv_amt,
                                P_denominator 		=> l_denominator,
                                P_numerator   		=> l_numerator,
                                P_rate 			=> l_rate,
                                X_status 		=> l_status
             		);


	  PA_MCB_INVOICE_PKG.log_message('recalculATE: If l_ProjFunc_Attr_For_AR_Flag = Y');
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_invoice_date ' || l_invoice_date);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_PFC_Exchg_Rate_Date_Code ' || l_PFC_Exchg_Rate_Date_Code);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_projfunc_Exchg_Rate_Date ' || l_projfunc_Exchg_Rate_Date);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_projfunc_Exchg_Rate_type ' || l_projfunc_Exchg_Rate_type);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_Rate ' || l_Rate);
	  PA_MCB_INVOICE_PKG.log_message('recalculATE: l_Projfunc_Exchange_Rate ' || l_Projfunc_Exchange_Rate);

	Update pa_draft_invoices_all
          set  projfunc_invtrans_rate_type = l_projfunc_Exchg_Rate_type
              ,projfunc_invtrans_rate_date = DECODE(l_PFC_Exchg_Rate_Date_Code,
	  					'PA_INVOICE_DATE', l_invoice_date,
						l_projfunc_Exchg_Rate_Date)
              ,projfunc_invtrans_ex_rate   = decode(l_projfunc_Exchg_Rate_type,'User',(1/l_Projfunc_Exchange_Rate),l_Rate)
          where project_id             = P_Project_Id
          and   draft_invoice_num      = P_Draft_Inv_Num;

	  END IF;
/* Added for bug 7575486*/
   ELSIF  (l_func_curr <> l_inv_currency_code) and (l_invproc_currency_code = l_func_curr)   THEN

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('recalculATE: ' || ' l_func_curr <> l_inv_currency_code and l_invproc_currency_code = l_func_curr ');
	END IF;

    	Update pa_draft_invoices_all
        set    projfunc_invtrans_rate_type      = inv_rate_type
              ,projfunc_invtrans_rate_date      = inv_rate_date
              ,projfunc_invtrans_ex_rate        = inv_exchange_rate
	-- DECODE(NVL(inv_exchange_rate,0),0,0, 1/NVL(inv_exchange_rate,0))
        where project_id                        = P_Project_Id
        and   draft_invoice_num                 = P_Draft_Inv_Num;

	/* Bug fix 2364014 removed the decode */

   END IF;


  /* End Add to fix bug 2165379 */
EXCEPTION
  When OTHERS
  Then Raise;

END Update_CRMemo_Invamt;

/*------------------------------------------------------------------+
 | Added for R11.1 Multi Currency Billing Project . This part will  |
 | will recalculate the invoice in invoice currency for all all     |
 | unapproved invoices and update the appropriate fields of invoice |
 | Header and Details. This procedure is only called from PAIGEN.   |
 |__________________________________________________________________*/

Procedure Recalculate_Driver( P_Request_ID         in  number,
                              P_User_ID            in  number,
                              P_Project_ID         in  number,
			      p_calling_process	   IN  VARCHAR2 DEFAULT 'PROJECT_INVOICES')
IS

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    l_error_message   pa_lookups.meaning%TYPE;

    /* Cursor for Select All Unapproved invoices created in This Run */
    /* Bug 5413168: skip invoices without any invoice line. generation_
       error_flag not stamped yet for this case until paicnl */
    CURSOR UNAPP_INV_CUR is
      SELECT i.project_id,
             i.draft_invoice_num,
             decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                    'CREDIT_MEMO') invoice_class,
             agr.customer_id,
             i.bill_through_date,
             i.draft_invoice_num_credited
        FROM pa_draft_invoices i,
             pa_agreements_all agr
       WHERE i.request_id = P_Request_ID
         AND nvl(i.generation_error_flag, 'N') = 'N'
         AND i.project_id+0 = P_Project_ID
         AND i.agreement_id  = agr.agreement_id
	 AND p_calling_process = 'PROJECT_INVOICES'
         AND EXISTS (SELECT 1 from PA_DRAFT_INVOICE_ITEMS dii
                      WHERE dii.project_id = i.project_id
                        AND dii.draft_invoice_num = i.draft_invoice_num)
	UNION
      SELECT i.project_id,
             i.draft_invoice_num,
             decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                    'CREDIT_MEMO') invoice_class,
             agr.customer_id,
             i.bill_through_date,
             i.draft_invoice_num_credited
        FROM pa_draft_invoices i,
             pa_agreements_all agr
       WHERE i.request_id = P_Request_ID
         AND nvl(i.generation_error_flag, 'N') = 'N'
         AND i.project_id+0 = P_Project_ID
         AND i.agreement_id  = agr.agreement_id
	 AND p_calling_process = 'RETENTION_INVOICES'
	 AND i.retention_invoice_flag ='Y'
         AND EXISTS (SELECT 1 from PA_DRAFT_INVOICE_ITEMS dii
                      WHERE dii.project_id = i.project_id
                        AND dii.draft_invoice_num = i.draft_invoice_num);


    l_out_status         varchar2(1000);
    l_project_id         number;
    l_draft_invoice_num  number;
    l_customer_id        number;
    l_cr_inv_num         number;
    l_bill_thru_date     date;
    l_invoice_class      varchar2(15);
    l_invoice_amount     number;
    l_dummy              number;

BEGIN

    IF g1_debug_mode  = 'Y' THEN
    	PA_MCB_INVOICE_PKG.log_message ('Inside recalculate driver');
    END IF;

    OPEN UNAPP_INV_CUR;

    LOOP
      FETCH UNAPP_INV_CUR into l_project_id,
                             l_draft_invoice_num,
                             l_invoice_class,l_customer_id,
                             l_bill_thru_date,l_cr_inv_num;

      EXIT WHEN UNAPP_INV_CUR%NOTFOUND;

      IF l_invoice_class = 'INVOICE'
      THEN
         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message ('Calling Recalculate');
         END IF;
         PA_INVOICE_CURRENCY.RECALCULATE ( P_Project_Id =>l_project_id,
                                          P_Draft_Inv_Num =>l_draft_invoice_num,
                                           P_Calling_Module =>'PAIGEN',
                                           P_Customer_Id =>l_customer_id,
                                           P_Inv_currency_code =>NULL,
                                           P_Inv_Rate_Type =>NULL,
                                           P_Inv_Rate_Date =>NULL,
                                           P_Inv_Exchange_Rate =>NULL,
                                           P_User_Id =>NULL,
                                           P_Bill_Thru_Date =>l_bill_thru_date,
                                           X_Status =>l_out_status);
         IF l_out_status IS NOT NULL
         THEN
            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message ('recalculATE: ' || 'Insert distribution warning ');
            END IF;
            Insert_Distrbution_Warning ( P_Project_ID =>l_Project_ID,
                                      P_Draft_Invoice_Num =>l_draft_invoice_num,
                                         P_User_ID =>P_User_ID,
                                         P_Request_ID =>P_Request_ID,
                                         P_Invoice_Set_ID =>NULL,
                                         P_Lookup_Type =>'INVOICE_CURRENCY',
                                         P_Error_Message_Code=>l_out_status);

/* Bug 2450414 - Inserted the Invoice Generation Error */
            IF l_out_status = 'PA_NO_EXCH_RATE_EXISTS' OR l_out_status ='PA_CURR_NOT_VALID'
               OR l_out_status = 'PA_USR_RATE_NOT_ALLOWED'
            THEN
               IF g1_debug_mode  = 'Y' THEN
               	PA_MCB_INVOICE_PKG.log_message ('recalculATE: ' || 'Invoice Generation Error is set....'||l_out_status);
               END IF;
               UPDATE pa_draft_invoices_all
               SET generation_error_flag='Y',
                   transfer_rejection_reason= (SELECT meaning FROM pa_lookups
                                               WHERE lookup_type='INVOICE_CURRENCY'
                                               AND lookup_code=l_out_status)
               WHERE project_id=l_Project_ID
               AND   draft_invoice_num=l_Draft_Invoice_Num;
            END IF;
/* Fix for Bug 2450414 Ends here */

         END IF;
      ELSIF l_invoice_class = 'CREDIT_MEMO'
      THEN
            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message ('recalculATE: ' || 'Calling Upddate_crmemo_invamt ');
            END IF;
            PA_INVOICE_CURRENCY.Update_CRMemo_Invamt
                               (P_Project_Id =>l_Project_ID,
                                P_Draft_Inv_Num =>l_draft_invoice_num,
                                P_Draft_Inv_Num_Credited =>l_cr_inv_num );
      END IF;
    END LOOP;

    CLOSE UNAPP_INV_CUR;

EXCEPTION
    WHEN OTHERS
    THEN
         RAISE;
END Recalculate_Driver;

END PA_INVOICE_CURRENCY;

/
