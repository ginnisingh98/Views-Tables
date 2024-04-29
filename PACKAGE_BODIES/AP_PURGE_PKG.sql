--------------------------------------------------------
--  DDL for Package Body AP_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PURGE_PKG" AS
/* $Header: appurgeb.pls 120.15.12010000.3 2010/04/22 23:27:44 bgoyal ship $ */
--bug5052748
--This bug mainly solves most of the performance related issues reported
--in SQLREP.
--There are two kinds of fixes.
--NO_UNNEST is used in the inner query to prevent FTS on large tables.
--Introduction of AP_INVOICES_ALL,AP_SYSTEM_PARAMETERS_ALL to force an
--access path.
-- Private Variables
-- Declaring the global variables
g_debug_switch         VARCHAR2(1) := 'N';

g_purge_name           VARCHAR2(15);
g_chv_status           VARCHAR2(1) := 'N';
g_payables_status      VARCHAR2(1) := 'N';
g_purchasing_status    VARCHAR2(1) := 'N';
g_pa_status            VARCHAR2(1) := 'N';
g_assets_status        VARCHAR2(1) := 'N';
g_edi_status           VARCHAR2(1) := 'N';
g_mrp_status           VARCHAR2(1) := 'N';
g_activity_date        DATE;
g_category             VARCHAR2(30);
g_organization_id      NUMBER;
g_range_size           NUMBER;


------------------------------------------------------------------
-- Procedure: Print
-- This is a print procedure to split a message string into 132
-- character strings.
------------------------------------------------------------------
PROCEDURE Print
        (P_string                IN      VARCHAR2) IS

  stemp    VARCHAR2(80);
  nlength  NUMBER := 1;

BEGIN

   WHILE(length(P_string) >= nlength)
   LOOP

        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;


------------------------------------------------------------------
-- Procedure: Set_Purge_Status
-- This procedure is used to set the status of the purge process
------------------------------------------------------------------
FUNCTION Set_Purge_Status
         (P_Status           IN  VARCHAR2,
          P_Purge_Name       IN  VARCHAR2,
          P_Debug_Switch     IN  VARCHAR2,
          P_Calling_Sequence IN VARCHAR2)
RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
   current_calling_sequence :=
   'Set_purge_status<-'||P_calling_sequence;
  --
   debug_info := 'Starting Set_purge_status';
   IF (p_debug_switch in ('y','Y')) THEN
      Print('(Updating table financials_purges)'||debug_info);
   END IF;

   UPDATE financials_purges
   SET status = P_Status
   WHERE purge_name = P_Purge_Name;
  --
   debug_info := 'End Set_purge_status';
   IF (g_debug_switch in ('y','Y')) THEN
      Print('(Done updating table financials_purges)'||debug_info);
   END IF;
   RETURN(TRUE);

RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
          IF (SQLCODE < 0 ) then
             Print(SQLERRM);
          END IF;
          RETURN(FALSE);

END;


------------------------------------------------------------------
-- Procedure: Get_Accounting_Method
-- This routine gets the accounting method options
------------------------------------------------------------------

FUNCTION Get_Accounting_Method
         (P_Recon_Acctg_Flag      OUT NOCOPY VARCHAR2,
          P_Using_Accrual_Basis   OUT NOCOPY VARCHAR2,
          P_Using_Cash_Basis      OUT NOCOPY VARCHAR2,
          P_Calling_Sequence      IN  VARCHAR2)

RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
  'Get_accounting_method<-'||P_calling_sequence;
  --
  debug_info := 'Starting Get_Accounting_Method';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Get_Accounting_Method)' ||debug_info);
  END IF;

      /* Bug#2274656 Selecting Recon Accounting Flag also in this program unit */
  SELECT DECODE(ASP.accounting_method_option, 'Accrual',                     'Y',
         DECODE(ASP.secondary_accounting_method,
                   'Accrual', 'Y', 'N')),
         DECODE(ASP.accounting_method_option,'Cash','Y',
         DECODE(ASP.secondary_accounting_method,
                   'Cash',    'Y', 'N')),
         nvl(ASP.RECON_ACCOUNTING_FLAG,'N')
  INTO   p_using_accrual_basis,
         p_using_cash_basis,
         p_recon_acctg_flag
  FROM   ap_system_parameters ASP;

  --
  debug_info := 'End Get_Accounting_Method';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Get_Accounting_Method)' ||debug_info);
  END IF;

  RETURN (TRUE);
  RETURN NULL;

EXCEPTION

  WHEN   OTHERS  THEN
     IF (SQLCODE < 0 ) then
         Print(SQLERRM);
     END IF;
     RETURN (FALSE);

END Get_Accounting_Method;


------------------------------------------------------------------
-- Procedure: Check_no_purge_in_process
-- This process checks if any purge is in process
------------------------------------------------------------------
FUNCTION Check_no_purge_in_process
         (P_Purge_Name          IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN  BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);
invoice_count                   NUMBER;
po_count                        NUMBER;
req_count                       NUMBER;
vendor_count                    NUMBER;

l_status                        VARCHAR2(30);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
  'Check_no_purge_in_process<-'||P_calling_sequence;

  debug_info := 'Starting Check_no_purge_in_process';
  IF p_debug_switch in ('y','Y') THEN
     Print('(Check_no_purge_in_process)' ||debug_info);
  END IF;

  -- count_invs
  select count(1)
  into invoice_count
  from ap_purge_invoice_list
  where double_check_flag = 'Y';

  if (invoice_count = 0) then

     -- count_pos
     select count(1)
     into po_count
     from po_purge_po_list
     where double_check_flag = 'Y';

     if (po_count = 0) then

        -- count_reqs
        select count(1)
        into req_count
        from po_purge_req_list
        where double_check_flag = 'Y';

        if (req_count = 0) then

            -- count_vendors
            select count(1)
            into vendor_count
            from po_purge_vendor_list
            where double_check_flag = 'Y';

            if (vendor_count = 0) then

               null;
            else

               debug_info := 'The PO_PURGE_VENDOR_LIST table contains records. ';
               Print('(Check_no_purge_in_process)' || debug_info);
               Print(' Please make sure no purges are running and clear');
	       Print(' this table. Process terminating.');

               l_status := 'COMPLETED-ABORTED';
	       if (Set_Purge_Status (
                             l_status,
                             p_purge_name,
                             p_debug_switch,
                             'Check_no_purge_in_process') <> TRUE) then
		  Print(' Set_purge_status failed');
                  Return (FALSE);
               end if;

            end if;

        else -- req_count <> 0

	     debug_info := 'The PO_PURGE_REQ_LIST table contains records. ';
	     Print('Check_no_purge_in_process' || debug_info);
             Print('Please make sure no purges are running and clear');
	     Print(' this table. Process terminating.');

             l_status := 'COMPLETED-ABORTED';
	     if (Set_Purge_Status
                        (l_status,
                         p_purge_name,
                         p_debug_switch,
                         'Check_no_purge_in_process') <> TRUE) then
		  Print(' Set_purge_status failed');
                  Return (FALSE);
             end if;

        end if ; -- req_count

     else

        debug_info := 'The PO_PURGE_PO_LIST table contains records. ';
	Print('Check_no_purge_in_process' || debug_info);
        Print('Please make sure no purges are running and clear');
	Print(' this table. Process terminating.');

        l_status := 'COMPLETED-ABORTED';
	if (Set_Purge_Status
                     (l_status,
                      p_purge_name,
                      p_debug_switch,
                      'Check_no_purge_in_process') <> TRUE) then
           Print(' Set_purge_status failed');
           Return (FALSE);
        end if;

     end if;  -- po_count

  else -- invoice_count

      debug_info := 'THe AP_PURGE_INVOICE_LIST table contains records. ';
      Print('Check_no_purge_in_process' || debug_info);
      Print('Please make sure no purges are running and clear');
      Print(' this table. Process terminating.');

      l_status := 'COMPLETED-ABORTED';
      if (Set_Purge_Status
                  (l_status,
                   p_purge_name,
                   p_debug_switch,
                   'Check_no_purge_in_process') <> TRUE) then
           Print(' Set_purge_status failed');
           Return (FALSE);
      end if;

  end if; -- invoice_count

  COMMIT;
  RETURN (TRUE);

RETURN NULL; EXCEPTION
  WHEN OTHERS then
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Check_no_purge_in_process;


------------------------------------------------------------------
-- Procedure: Check_Chv_In_Cum
--
------------------------------------------------------------------
FUNCTION Check_chv_in_cum
         (P_Calling_Sequence  IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'check_chv_in_cum<-'||P_calling_sequence;

  debug_info := 'Starting check_chv_in_cum';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Check_chv_in_cum)' ||debug_info);
  END IF;

  --
  --   test_chv_in_cum

  delete from chv_purge_schedule_list cpsl
  where exists (select null
                from chv_cum_periods ccp,
                     chv_schedule_items csi,
                     chv_schedule_headers csh,
                     chv_org_options coo
                where ccp.organization_id  = g_organization_id
                and   sysdate between ccp.cum_period_start_date and
                                      NVL(ccp.cum_period_end_date,sysdate + 1)
                and  coo.organization_id = ccp.organization_id
                and  coo.enable_cum_flag = 'Y'
                and  csh.schedule_id = csi.schedule_id
                and  csh.schedule_horizon_start >= ccp.cum_period_start_date
                and  csi.schedule_item_id = cpsl.schedule_item_id);

  RETURN (TRUE);
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
       IF (SQLCODE < 0 ) THEN
     	   Print(SQLERRM);
       END IF;
       RETURN (FALSE);
END Check_chv_in_cum;


------------------------------------------------------------------
-- Procedure: Check_Chv_In_EDI
--
------------------------------------------------------------------
FUNCTION Check_chv_in_edi
         (P_Calling_Sequence  IN VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'check_chv_in_edi<-'||P_calling_sequence;

  debug_info := 'Starting check_chv_in_edi';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Check_chv_in_edi)' ||debug_info);
  END IF;

  --
  --	test_chv_in_edi

  delete from chv_purge_schedule_list cpsl
  where exists (select null
                from   chv_schedule_items csi,
                       ece_spso_items esi
                where  csi.schedule_item_id = cpsl.schedule_item_id
                and    csi.schedule_id = esi.schedule_id);

  RETURN (TRUE);
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
       IF (SQLCODE < 0 ) THEN
     	   Print(SQLERRM);
       END IF;
       RETURN (FALSE);
END Check_chv_in_edi;


------------------------------------------------------------------
-- Procedure: Do_Dependent_Inv_Checks
--
------------------------------------------------------------------
FUNCTION DO_DEPENDENT_INV_CHECKS
         (P_Calling_Sequence  IN VARCHAR2)
RETURN BOOLEAN IS

  /* bug2918268 : Created this function instead of do_dependent_inv_checks function.
     Because performance of delete stmt in do_dependent_inv_checks was very poor.
     This function does same check with the delete stmt.
  */

 TYPE tab_status_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
 tab_inv tab_status_type;
 tab_check tab_status_type;
 tab_clear tab_status_type;

 /* bug3136911 added ap_invoice_payments table join in order to check only
               invoices which are related to payment.
  */
 CURSOR c_main IS
  select pl.invoice_id
    from ap_purge_invoice_list pl,
         ap_invoice_payments ip
   where pl.invoice_id = ip.invoice_id;

 CURSOR c_main_check(l_invoice_id NUMBER) IS
  select invoice_id
    from ap_purge_invoice_list
   where invoice_id = l_invoice_id
     and double_check_flag = 'Y';

  p_count   integer;
  p_id   integer;

  l_cnt integer;
  debug_info                      VARCHAR2(200);
  current_calling_sequence  	VARCHAR2(2000);
  l_invoice BOOLEAN ;
  l_dummy NUMBER ;

  Function Check_check(l_invoice_id IN NUMBER ) RETURN BOOLEAN;

/* Get related invoice_id from check_id and check if the invoice_id is
   in purge list. If there is, call check_check to get check_id which
   is related to the invoice_id */
  Function Check_inv(l_check_id IN NUMBER) RETURN BOOLEAN IS

 CURSOR c_inv IS
  select pil.invoice_id
    from ap_invoice_payments ip,
         ap_purge_invoice_list pil
   where ip.check_id = l_check_id
     and ip.invoice_id = pil.invoice_id (+) ;

 l_flag BOOLEAN := FALSE;
 l_inv_id ap_purge_invoice_list.invoice_id%TYPE;

BEGIN

  OPEN c_inv ;
  LOOP

    FETCH c_inv into l_inv_id ;
    EXIT WHEN c_inv%NOTFOUND ;

    /* if related invoice id is not in purge list */
    IF l_inv_id is null THEN
      l_flag := FALSE ;
    ELSE

      /* if the invocie_id is already checked */
      IF tab_inv.exists(l_inv_id) THEN
        l_flag := TRUE ;
      ELSE
        tab_inv(l_inv_id) := 'X' ;
        l_flag := check_check(l_inv_id) ;
      END IF;
    END IF;

    EXIT WHEN (not l_flag) ;

  END LOOP;

  CLOSE C_inv;
  RETURN(l_flag) ;

END ;

/* Get related check_id from invoice_id and call check_invoice
   to check if the invoice is in purge list. */
Function Check_check(l_invoice_id IN NUMBER ) RETURN BOOLEAN IS

 CURSOR c_check IS
  select check_id
    from ap_invoice_payments
   where invoice_id = l_invoice_id ;

  l_flag BOOLEAN := FALSE;
  l_check_id number;

BEGIN

  OPEN c_check ;
  LOOP

    FETCH c_check into l_check_id ;
    EXIT WHEN c_check%NOTFOUND ;

    /* if the check_id is already checked */
    IF tab_check.exists(l_check_id) THEN
      l_flag := TRUE ;
    ELSE
      tab_check(l_check_id) := 'X' ;
      l_flag := check_inv(l_check_id) ;
    END IF;

    EXIT WHEN (not l_flag) ;

  END LOOP;

  CLOSE C_check;
  RETURN(l_flag) ;

END ;

/* main process */
BEGIN
  -- Update the calling sequence
  --
   current_calling_sequence :=
   'Do_dependent_inv_checks<-'||P_calling_sequence;
  --

  debug_info := 'Starting series of debug invoice validations';
  IF g_debug_switch in ('y','Y') THEN
     Print('(do_dependent_inv_checks)' ||debug_info);
  END IF;


  FOR l_main IN c_main
  LOOP

    /* initialization */
    tab_inv := tab_clear ;
    tab_check := tab_clear;

    /* check if this invoice is not checked yet */
    OPEN c_main_check(l_main.invoice_id) ;
    FETCH c_main_check into l_dummy ;
    l_invoice := c_main_check%FOUND ;
    CLOSE c_main_check ;

    /* if this invoice is not checked yet */
    IF (l_invoice) THEN

      tab_inv(l_main.invoice_id) := 'X' ;

      IF check_check(l_main.invoice_id) THEN

        /* if this chain is purgeable,set flag 'S' for all invoices in this chain */
        p_count := tab_inv.count;
        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_inv.next(p_id) ;
            UPDATE ap_purge_invoice_list
               SET double_check_flag = 'S'
             WHERE invoice_id = p_id ;
          END LOOP;

        END IF;
      ELSE

        /* if this chain is not purgeable, delete selected invoice from purge list */
        p_count := tab_inv.count;
        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_inv.next(p_id) ;
            DELETE FROM ap_purge_invoice_list
              WHERE invoice_id = p_id ;
          END LOOP;
        end if;

        /* delete unpurgeable list beforehand for performance */
        p_count := tab_check.count;

        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_check.next(p_id) ;
            DELETE FROM ap_purge_invoice_list
            WHERE invoice_id in ( select invoice_id
                from ap_invoice_payments
                where check_id = p_id);
          END LOOP;
        END IF;

     END IF;

    END IF;

  END LOOP;

  /* Set flag 'Y' back */
  update ap_purge_invoice_list
    set double_check_flag = 'Y'
   where double_check_flag = 'S' ;

  debug_info := 'End Of Invoice Validations';
  IF g_debug_switch in ('y','Y') THEN
     Print('(do_dependent_inv_checks)' ||debug_info);
  END IF;

  commit;
  return(TRUE) ;

RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
       IF (SQLCODE < 0 ) then
         Print(SQLERRM);
      END IF;
      RETURN(FALSE);
END ;

------------------------------------------------------------------
-- Procedure: Do_Independent_Inv_Checks
--
------------------------------------------------------------------
FUNCTION Do_independent_inv_checks
         (P_Using_Accrual_Basis  IN  VARCHAR2,
          P_Using_Cash_Basis     IN  VARCHAR2,
          P_Recon_Acctg_Flag     IN  VARCHAR2,
          P_Calling_Sequence     IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);
l_list_count number;

BEGIN
  -- Update the calling sequence
  --
   current_calling_sequence :=
   'Do_independent_inv_checks<-'||P_calling_sequence;


   debug_info :=
   'Starting independent invoice validations -- Payment Schedules';
   IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
   END IF;

   --
   -- Test Payment Schedules

   DELETE
   FROM ap_purge_invoice_list PL
   WHERE EXISTS (
	SELECT 'payment schedule not purgeable'
	FROM ap_payment_schedules PS,
	     ap_invoices I
	WHERE PS.invoice_id = PL.invoice_id
	AND   PS.invoice_id = I.invoice_id
	AND ((PS.payment_status_flag <> 'Y'
        AND  I.cancelled_date is null)
        OR   PS.last_update_date > g_activity_date));



   IF g_pa_status = 'Y' then
     debug_info := 'Test PA Invoices';
     IF g_debug_switch in ('y','Y') THEN
       Print('(Do_independent_inv_checks)' ||debug_info);
     END IF;
     --
     -- Test PA Invoices

     DELETE
     FROM ap_purge_invoice_list PL
     WHERE EXISTS
	(SELECT /*+ no_unnest */ 'project-related vendor invoices'   -- 7759218
	FROM	ap_invoice_distributions d
	WHERE	d.invoice_id = pl.invoice_id
	AND	d.project_id is not null)   -- bug1746226
        OR EXISTS
	   (SELECT /*+ no_unnest */ 'project-related expense report' -- 7759218
	    FROM   ap_invoices i
	    WHERE  i.invoice_id = pl.invoice_id
	    AND	   i.source = 'Oracle Project Accounting');

   END IF;



   --
   debug_info := 'Test Distributions';
   IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
   END IF;

/*
1897941 fbreslin: If an invoice is cancelled, the ASSETS_ADDTION_FLAG is
                  set to "U" so Mass Additions does not include the
                  distribution.  We are alos not supposed to purge
                  invoices if any of the distributions have ben passed to
                  FA. Adding a check to see if the invoice is cancelled
                  before we remove an invoice with ASSETS_ADDTION_FLAG = U
                  from the purge list.
*/

   IF g_category = 'SIMPLE INVOICES' THEN

      Print('Test Simple Invoice Distributions');
      -- Test Simple Invoice Distributions
      DELETE
      FROM ap_purge_invoice_list PL
      WHERE EXISTS
              (SELECT /*+ no_unnest */ 'distributions not purgeable' -- 7759218
                 FROM ap_invoice_distributions D, ap_invoices I
                WHERE I.invoice_id = D.invoice_id
                  AND PL.invoice_id = D.invoice_id
       	          AND (   D.last_update_date > g_activity_date
       		       OR D.posted_flag <> 'Y'
       		       OR D.accrual_posted_flag  =
       		          DECODE(p_using_accrual_basis,
                                 'Y', 'N',
                                 'Z')
       	               OR D.cash_posted_flag =
       		          DECODE(p_using_cash_basis,
                                 'Y', DECODE(D.cash_posted_flag,
                                             'N', 'N',
		                             'P', 'P',
                                             'Z'),
                                 'Z')
       		       OR D.po_distribution_id IS NOT NULL
       		       OR (    D.assets_addition_flag||'' =
       		               DECODE(g_assets_status,
                               'Y', 'U',
                               'cantequalme')
                           AND I.cancelled_date IS NULL)));

   ELSE
     Print('Test All Invoice Distributions');
     -- Test All Invoice Distributions
     DELETE
     FROM ap_purge_invoice_list PL
     WHERE EXISTS
              (SELECT /*+ no_unnest */ 'distributions not purgeable' -- 7759218
	 	 FROM ap_invoice_distributions D, ap_invoices I
	 	WHERE I.invoice_id = D.invoice_id
                  AND PL.invoice_id = D.invoice_id
         	  AND (   D.last_update_date > g_activity_date
              	       OR D.posted_flag <> 'Y'
                       OR D.accrual_posted_flag =
            	          DECODE(p_using_accrual_basis,
                                 'Y', 'N',
                                 'Z')
              	       OR D.cash_posted_flag =
              	          DECODE(p_using_cash_basis,
                                 'Y', DECODE(D.cash_posted_flag,
                                            'N', 'N',
		                            'P', 'P',
                                            'Z'),
                                 'Z')
                       OR (    D.assets_addition_flag||'' =
       	                       DECODE(g_assets_status,
                                      'Y', 'U',
		                      'cantequalme')
                           AND I.cancelled_date IS NULL)));
   END IF;



   debug_info := 'Test Payments';
   IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
   END IF;

  -- Test Payments
  -- Perf bug 5052674 -- go to base table AP_INVOICE_PAYMENTS_ALL for
  -- main SELECT query and base table CE_STATEMENT_RECONCILS_ALL for sub-query
   	DELETE
   	FROM ap_purge_invoice_list PL
   	WHERE EXISTS
      		(SELECT /*+ no_unnest */'payment not purgeable'  -- 7759218
       		FROM ap_invoice_payments_all P,
                     ap_checks C
       		WHERE P.invoice_id = PL.invoice_id
       		AND P.check_id = C.check_id
       		AND  (((P.posted_flag <> 'Y'
       		OR
                P.accrual_posted_flag =
       		DECODE(p_using_accrual_basis, 'Y','N','Z')
       		OR
                P.cash_posted_flag =
       		DECODE(p_using_cash_basis,'Y',
       		DECODE(P.cash_posted_flag,'N',
		'N','P','P','Z'),'Z')
       		OR
                P.last_update_date > g_activity_date
       		OR
                C.last_update_date > g_activity_date
                OR
                /*Following two conditions added for bug#2274656 to prevent
                  Future Dated checks being purged before they are matured */
                (C.future_pay_due_date is not null
                 AND C.status_lookup_code ='ISSUED')

/* Code Modified by MSWAMINA.
   Bug 2211285.
   Payments should not be considered to in the purge list if it has any reference
   information left in cash management. AP assumes that if a customer uses
   CE, They have already purged the related data in CE before purging the AP
   payments information.
   So Added the following condition back. */
/*  Fix for bug#2274656
   Bug#2211285 hard codes the date in case Cleared Date and Void date are null, to an infinite
   value and makes the condition always true , so the payment records would not
   get purged if it has not been Cleared, but some customers may not be using
   recon accounting at all.  Now the recon accounting flag is selected
   in get_accounting_method()  and we decide based on that */
   		OR
               decode(p_recon_acctg_flag,'Y',nvl(c.cleared_date,
                                     nvl(c.void_date,to_date('12/31/2999','MM/DD/YYYY'))))
                                                                           > g_activity_date
		))
                OR
                EXISTS (SELECT 'Referenced by cashbook'
                        from ce_statement_reconcils_all SR
                        where C.check_id=SR.reference_id
                        AND SR.reference_type= 'PAYMENT'
                        AND SR.org_id = C.org_id )));



  --
  debug_info := 'Test Prepayments';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
  END IF;

  --  	Delete Inoivces that have applied Prepayments
  --    Keep this Statement for Invoices upgrated  from 11.0

   	DELETE
   	FROM ap_purge_invoice_list PL
   	WHERE EXISTS
	       (SELECT  /*+ no_unnest */ 'related to prepayment' -- 7759218
		FROM    ap_invoice_prepays IP
		WHERE	PL.invoice_id = IP.invoice_id
		OR	PL.invoice_id = IP.prepay_id);

  --    Bug 2153132 by ISartawi add the Delete Statement to exclude
  --    invoices with applied Prepayments

        DELETE
        FROM ap_purge_invoice_list PL
        WHERE EXISTS
               (SELECT  'X'
                FROM    ap_invoice_distributions ID
                WHERE   PL.invoice_id = ID.invoice_id
                AND     ID.line_type_lookup_code   = 'PREPAY'
                AND     ID.prepay_distribution_id  IS NOT NULL);

   /* Testing of Payment History moved to this location while fixing bug#2274656
      This doesn't make any difference but testing transaction before transfer
      will reduce number of records tested for Transfer from Acctg tables */

  debug_info := 'Test Payment History';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
  END IF;

  DELETE FROM ap_purge_invoice_list PL
  where EXISTS(
          select 'history not purgeable'
          from ap_invoice_payments aip
          ,       ap_payment_history aph
          where aip.invoice_id = PL.invoice_id
          and aip.check_id = aph.check_id
          -- To check for posted_flag added for bug#2274656
          and nvl(aph.posted_flag,'N') <> 'Y'
          --Bug 1579474
          --and aph.last_update_date >= g_activity_date);
          and aph.last_update_date > g_activity_date);

  debug_info := 'Test Accounting';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
  END IF;


-- Fix for bug 2652768 made changes to below DELETE statement
-- Fix for bug 2963666 Added condition to check description is not MRC upgrade
  DELETE FROM ap_purge_invoice_list PL
  WHERE EXISTS (
          Select /*+ no_unnest */ 'invoice accounting not purgeable' -- 7759218
          from  xla_events xe, --Bug 4588031
                xla_transaction_entities xte, --Bug 4588031
                xla_ae_headers xeh, --Bug 4588031
                ap_invoices_all ai,ap_system_parameters_all asp--bug5052748
          where xte.entity_code = 'AP_INVOICES'
          and xte.source_id_int_1 = PL.invoice_id
          AND pl.invoice_id=ai.invoice_id
          AND ai.org_id=asp.org_id
          AND asp.set_of_books_id=xte.ledger_id
          and xte.entity_id = xe.entity_id
          and xe.event_id = xeh.event_id --Bug6318079
          and xe.application_id = 200
          and xeh.application_id = 200
          and xte.application_id = 200
          and (xeh.gl_transfer_status_code = 'N'
                  OR ( xeh.last_update_date > g_activity_date )))
     OR EXISTS (
          Select /*+ no_unnest */ 'payment accounting not purgeable' -- 7759218
          from  xla_events xe, --Bug 4588031
                xla_transaction_entities xte, --Bug 4588031
                ap_invoice_payments aip,
                ap_system_parameters_all asp,--bug5052478
                xla_ae_headers xeh --Bug 4588031
          where xte.entity_code = 'AP_PAYMENTS'
          and   xte.source_id_int_1 = aip.check_id
          and   xte.entity_id = xe.entity_id
          AND   asp.set_of_books_id=xte.ledger_id
          AND   aip.org_id=asp.org_id
          and   PL.invoice_id = aip.invoice_id
          and   xe.event_id = xeh.event_id
          and   xe.application_id = 200
          and   xeh.application_id = 200
          and   xte.application_id = 200
          and   (xeh.gl_transfer_status_code = 'N'
                  OR ( xeh.last_update_date > g_activity_date)));


  debug_info := 'Test Invoce matching to receipts';
   IF g_debug_switch in ('y','Y') THEN
     Print('(Do_independent_inv_checks)' ||debug_info);
   END IF;

   DELETE FROM ap_purge_invoice_list PL
   WHERE EXISTS (
          select 'matched'
          from ap_invoice_distributions aid, rcv_transactions rcv
          where aid.invoice_id = PL.invoice_id
          and aid.rcv_transaction_id = rcv.transaction_id
          and rcv.last_update_date > g_activity_date);

  DELETE FROM ap_purge_invoice_list PL
  WHERE EXISTS
                (select null
                 from  ap_invoice_distributions ad
                 where ad.invoice_id = PL.invoice_id
                 and   ad.rcv_transaction_id is not null
                 and exists (
                 select 'matching'  from  ap_invoice_distributions ad2
                 where ad2.rcv_transaction_id =  ad.rcv_transaction_id
                 and ad2.invoice_id NOT IN (
                        select invoice_id
			from  ap_purge_invoice_list
			where double_check_flag = 'Y')));

  -- debug info....
  SELECT count(*) INTO l_list_count FROM ap_purge_invoice_list;
  Print(to_char(l_list_count)||' records in ap_purge_invoice_list table');


  RETURN (TRUE);
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
      IF (SQLCODE < 0 ) then
         Print(SQLERRM);
      END IF;
      RETURN(FALSE);

END Do_independent_inv_checks;


------------------------------------------------------------------
-- Procedure: Match_pos_to_invoices_ctrl
--
------------------------------------------------------------------
FUNCTION Match_pos_to_invoices_ctrl
         (P_Purge_Name        IN  VARCHAR2,
          P_Purge_Status      IN  VARCHAR2,
          P_Calling_Sequence  IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);
po_count                        NUMBER;
invoice_count                   NUMBER;
invs_before_po_match            NUMBER;
pos_before_inv_match            NUMBER;
pos_before_dependents           NUMBER;
invs_before_dependents		NUMBER;
start_list_count		NUMBER;
list_count			NUMBER;

l_first_iteration               BOOLEAN;
l_po_docs_filtered_flag         BOOLEAN;

l_po_return_status              VARCHAR2(1);
l_po_msg                        VARCHAR2(2000);
l_po_records_filtered_tmp       VARCHAR2(1);


BEGIN
-- Update the calling sequence
--
current_calling_sequence :=
'Match_pos_to_reqs_ctrl<-'||P_calling_sequence;

debug_info := 'Starting Match_pos_to_invoices_ctrl';
IF g_debug_switch in ('y','Y') THEN
   Print('(Match_pos_to_invoices_ctrl)' ||debug_info);
END IF;


-- count_invs
select count(1)
into invoice_count
from ap_purge_invoice_list
where double_check_flag = 'Y';

l_first_iteration := TRUE;

LOOP   -- <loop 1>

  l_po_docs_filtered_flag := FALSE;

  LOOP   -- <loop 2>

        --
	debug_info := 'LOOP Match_pos_to_invoices_ctrl';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Match_pos_to_invoices_ctrl)' ||debug_info);
        END IF;

	invs_before_po_match := invoice_count;

	debug_info := 'LOOP match_pos_to_invoices';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Match_pos_to_invoices_ctrl)' ||debug_info);
        END IF;

	-- match_pos_to_invoices

        PO_AP_PURGE_GRP.filter_records
        (  p_api_version => 1.0,
           p_init_msg_list => 'T',
           p_commit => 'F',
           x_return_status => l_po_return_status,
           x_msg_data => l_po_msg,
           p_purge_status => p_purge_status,
           p_purge_name => p_purge_name,
           p_purge_category => g_category,
           p_action => 'FILTER DEPENDENT PO AND AP',
           x_po_records_filtered => l_po_records_filtered_tmp
         );

        IF (l_po_return_status <> 'S') THEN
            Print(l_po_msg);
            RETURN FALSE;
        END IF;

        IF (l_po_records_filtered_tmp = 'T') THEN
          l_po_docs_filtered_flag := TRUE;
        END IF;


	-- match_invoices_to_pos
        IF p_purge_status = 'INITIATING' THEN
           delete from ap_purge_invoice_list apl
	   where exists
	        (select /*+ no_unnest */ null -- 7759218
	         from  ap_invoice_distributions ad
	         where ad.invoice_id = apl.invoice_id
                 and   ad.po_distribution_id is not null
	         and not exists (select null
       		   	         from  po_purge_po_list ppl,
				       po_distributions pd
                  	         where ppl.po_header_id =
				       pd.po_header_id
                  	         and   pd.po_distribution_id =
                                       ad.po_distribution_id));
        ELSE
          --bug5052748
          -- re_match_invoices_to_pos
           update ap_purge_invoice_list apl
           set double_check_flag = 'N'
           where double_check_flag = 'Y'
           and   exists (select /*+NO_UNNEST*/ null
                         from  ap_invoice_distributions ad,po_distributions pd
                         where ad.invoice_id = apl.invoice_id
                         AND   pd.po_distribution_id=ad.po_distribution_id
                         and   ad.po_distribution_id is not null
                         and not exists (SELECT null
                                         FROM  po_purge_po_list ppl
                                         WHERE ppl.double_check_flag = 'Y'
                                         AND   ppl.po_header_id =pd.po_header_id));

        END IF;

	COMMIT;

	-- count invs
	select count(1)
	into invoice_count
	from ap_purge_invoice_list
	where double_check_flag = 'Y';

       IF (invoice_count = invs_before_po_match AND
           l_po_records_filtered_tmp <> 'T') THEN

          EXIT;
       END IF;

      if (invoice_count < invs_before_po_match) then

         invs_before_dependents := invoice_count;

         debug_info := 'Starting series of dependent invoice validations';
         IF g_debug_switch in ('y','Y') THEN
            Print('(Match_pos_to_invoices_ctrl)' ||debug_info);
         END IF;


         -- do_dependent_inv_checks

         LOOP  -- <loop3>

           -- Get invoice list count
           SELECT count(*)
           INTO   start_list_count
           FROM   ap_purge_invoice_list
           WHERE  double_check_flag = DECODE(p_purge_status, 'INITIATING', 'Y',
                                                   double_check_flag);

           IF p_purge_status = 'INITIATING' THEN
              -- Test Check Relationships
              DELETE
              FROM ap_purge_invoice_list PL
              WHERE EXISTS (
                         SELECT 'relational problem'
                         FROM ap_invoice_payments IP1,
                              ap_invoice_payments IP2
                         WHERE PL.invoice_id = IP1.invoice_id
                         AND   IP1.check_id = IP2.check_id
                         AND   IP2.invoice_id NOT IN (
                                 SELECT PL2.invoice_id
                                 FROM ap_purge_invoice_list PL2
                                 WHERE PL2.invoice_id =
                                          IP2.invoice_id)
                          );

           ELSE
             --bug5052748
              -- retest_check_relationships
              UPDATE ap_purge_invoice_list PL
              SET PL.double_check_flag = 'N'
              WHERE PL.double_check_flag = 'Y'
              AND EXISTS (
                      SELECT /*+NO_UNNEST*/'relational problem'
                      FROM ap_invoice_payments IP1, ap_invoice_payments IP2
                      WHERE PL.invoice_id = IP1.invoice_id
                      AND   IP1.check_id = IP2.check_id
                      AND   IP2.invoice_id NOT IN (
                              SELECT PL2.invoice_id
                              FROM ap_purge_invoice_list PL2
                              WHERE PL2.invoice_id = IP2.invoice_id
                              AND PL2.double_check_flag ='Y'));

           END IF;

           -- get invoice list count
           SELECT count(*)
           INTO list_count
           FROM ap_purge_invoice_list
           WHERE  double_check_flag = DECODE(p_purge_status, 'INITIATING', 'Y',
                                                   double_check_flag);

           if start_list_count = list_count then
               invoice_count := list_count;
               EXIT;
           end if;
         END LOOP;   -- end <loop 3>
         COMMIT;
       END IF;  -- invoice count < inv_before_po_match
  END LOOP;   -- end <loop 2>

  IF (l_first_iteration OR
      l_po_docs_filtered_flag) THEN

     PO_AP_PURGE_GRP.filter_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_status => p_purge_status,
        p_purge_name => p_purge_name,
        p_purge_category => g_category,
        p_action => 'FILTER DEPENDENT PO AND REQ',
        x_po_records_filtered => l_po_records_filtered_tmp
      );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;
     IF (l_po_records_filtered_tmp <> 'T') THEN
         l_po_docs_filtered_flag := FALSE;
     END IF;
  END IF;

  l_first_iteration := FALSE;

  EXIT WHEN NOT l_po_docs_filtered_flag;

END LOOP;

debug_info := 'End Match_pos_to_invoices_ctrl';
IF g_debug_switch in ('y','Y') THEN
   Print('(Match_pos_to_invoices_ctrl)' ||debug_info);
END IF;

RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);
END Match_pos_to_invoices_ctrl;


------------------------------------------------------------------
-- Procedure: Seed_Chv_By_Cum
--
------------------------------------------------------------------
FUNCTION Seed_chv_by_cum
         (P_Purge_Name         IN  VARCHAR2,
          P_Calling_Sequence   IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'seed_chv_by_cum<-'||P_calling_sequence;

  debug_info := 'Starting seed_chv_by_cum';
  IF g_debug_switch in ('y','Y') THEN
     Print('(seed_chv_by_cum)' ||debug_info);
  END IF;

  --
  insert into chv_purge_cum_list
       	 (cum_period_id,
          purge_name,
          double_check_flag)
  select  ccp.cum_period_id,
          p_purge_name,
          'Y'
  from    chv_cum_periods ccp
  where   ccp.organization_id = g_organization_id
  and     NVL(ccp.cum_period_end_date, sysdate + 1) <= g_activity_date
  and     NVL(ccp.cum_period_end_date,sysdate + 1) < sysdate;

  debug_info := 'Starting seeding items in CUM';
  IF g_debug_switch in ('y','Y') THEN
     Print('(seed_chv_by_cum)' ||debug_info);
  END IF;

  insert into chv_purge_schedule_list
  	 (schedule_item_id,
          purge_name,
          double_check_flag)
  select  csi.schedule_item_id,
          p_purge_name,
          'Y'
  from    chv_schedule_items csi,
          chv_schedule_headers csh,
          chv_purge_cum_list cpcl,
	  chv_cum_periods ccp
  where   csh.schedule_id = csi.schedule_id
  and     csh.schedule_horizon_start between ccp.cum_period_start_date
				       and ccp.cum_period_end_date
  and     ccp.cum_period_id = cpcl.cum_period_id
  and     csi.organization_id = g_organization_id;

  RETURN (TRUE);

RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
       IF (SQLCODE < 0 ) THEN
    	   Print(SQLERRM);
      END IF;
   RETURN (FALSE);
END Seed_chv_by_cum;


------------------------------------------------------------------
-- Procedure: Seed_Chv_By_Org
--
------------------------------------------------------------------
FUNCTION Seed_chv_by_org
         (P_Purge_Name           IN  VARCHAR2,
          P_Calling_Sequence     IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'seed_chv_by_org<-'||P_calling_sequence;

  debug_info := 'Starting seed_chv_by_org';
  IF g_debug_switch in ('y','Y') THEN
     Print('(seed_chv_by_org)' ||debug_info);
  END IF;

   --
  insert into chv_purge_schedule_list
   	 (schedule_item_id,
       	  purge_name,
          double_check_flag)
  select  csi.schedule_item_id,
          p_purge_name,
          'Y'
  from    chv_schedule_items csi,
          chv_schedule_headers csh
  where   csh.schedule_id = csi.schedule_id
  and     csh.last_update_date <= g_activity_date
  and     NVL(csi.item_purge_status,'N') <> 'PURGED'
  and     csi.organization_id = g_organization_id;

  RETURN (TRUE);
  RETURN NULL;

EXCEPTION
	WHEN OTHERS THEN
	   IF (SQLCODE < 0 ) THEN
     	      Print(SQLERRM);
   	   END IF;
     	   RETURN (FALSE);
END seed_chv_by_org;


------------------------------------------------------------------
-- Procedure: Seed_Invoices
--
------------------------------------------------------------------
FUNCTION Seed_Invoices
	 (P_Purge_Name            IN  VARCHAR2,
          P_Using_Accrual_Basis   IN  VARCHAR2,
          P_Using_Cash_Basis      IN  VARCHAR2,
          P_Calling_Sequence      IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);
temp number;

BEGIN
  -- Update the calling sequence
  --
   current_calling_sequence :=
   'Seed_invoices<-'||P_calling_sequence;
  --
   debug_info := 'Starting Seed_invoices';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Inserting into ap_purge_invoice_list)' ||debug_info);
   END IF;

   	INSERT INTO ap_purge_invoice_list
	(invoice_id, purge_name, double_check_flag)
	SELECT 	DISTINCT I.invoice_id, p_purge_name, 'Y'
	FROM 	ap_invoices I, ap_invoice_distributions D
	WHERE	I.invoice_id = D.invoice_id
	AND	I.payment_status_flag || '' = 'Y'
	AND	I.invoice_type_lookup_code <> 'PREPAYMENT'
	AND	D.posted_flag || '' = 'Y'
        AND     D.accrual_posted_flag = DECODE(p_using_accrual_basis, 'Y','Y',
                                                     D.accrual_posted_flag)
        AND     D.cash_posted_flag = DECODE(p_using_cash_basis, 'Y','Y',
                                         D.cash_posted_flag)
	AND	D.last_update_date <= g_activity_date
	AND	I.last_update_date <= g_activity_date
	AND	I.invoice_date <= g_activity_date
	UNION
	SELECT	I.invoice_id, p_purge_name, 'Y'
	FROM	ap_invoices I, ap_invoice_distributions D
	WHERE	I.invoice_id = D.invoice_id (+)
	AND	I.last_update_date <= g_activity_date
	AND	I.invoice_date <= g_activity_date
	AND	I.invoice_amount = 0
	AND	I.invoice_type_lookup_code <> 'PREPAYMENT'
	GROUP BY I.invoice_id
	HAVING	SUM(NVL(D.amount, 0)) = 0;

        select count(*) into temp from ap_purge_invoice_list;

        Print(to_char(temp)||' records in ap_purge_invoice list table');

        debug_info := 'End Seed_invoices';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Done inserting into ap_purge_invoice_list)' ||debug_info);
        END IF;

        RETURN(TRUE);
        RETURN NULL;

EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE < 0 ) then
             Print(SQLERRM);
          END IF;
          RETURN(FALSE);
END Seed_invoices;


------------------------------------------------------------------
-- Procedure: Select_Seed_Vendors
--
------------------------------------------------------------------
FUNCTION Seed_Vendors
         (P_Purge_Name           IN  VARCHAR2,
          P_Calling_Sequence     IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
	current_calling_sequence :=
 	'Seed_Vendors<-'||P_calling_sequence;

	debug_info := 'Starting Seed_Vendors';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Seed_Vendors)' ||debug_info);
        END IF;

   --
	insert into po_purge_vendor_list
       		(vendor_id,
		purge_name,
		double_check_flag)
	select  vnd.vendor_id,
		p_purge_name,
		'Y'
	from 	ap_suppliers vnd
	where   vnd.end_date_active <= g_activity_date
	and not exists (select 'vnd.vendor is a parent of
			another vendor'
                	from ap_suppliers v
                	where v.parent_vendor_id =
			      vnd.vendor_id)
        --Bug 2653578
        and PO_THIRD_PARTY_STOCK_GRP.validate_supplier_purge(
                                                vnd.vendor_id) = 'TRUE';

	-- test vendors
	if g_payables_status = 'Y' then
	   if g_assets_status = 'Y' then
              debug_info := 'test_fa_vendors';
              IF g_debug_switch in ('y','Y') THEN
                 Print('(Seed_Vendors)' ||debug_info);
              END IF;


	      -- test fa vendors
 	      delete from po_purge_vendor_list pvl
	      where exists
	             (select null
		      from  fa_mass_additions fma
		      where fma.po_vendor_id = pvl.vendor_id)
		      or    exists
				(select null
				from  fa_asset_invoices fai
				where fai.po_vendor_id = pvl.vendor_id);
            end if;

            debug_info := 'test_ap_vendors';
            IF g_debug_switch in ('y','Y') THEN
               Print('(Seed_Vendors)' ||debug_info);
            END IF;


		-- test ap vendors
		delete from po_purge_vendor_list pvl
		where exists
			(select null
			from  ap_invoices_all ai
			where ai.vendor_id = pvl.vendor_id)
		or    exists
			(select null
			from ap_selected_invoices_all asi,
                     	     ap_supplier_sites_all pvs
			where asi.vendor_site_id =
		 	      pvs.vendor_site_id
                and   pvs.vendor_id      = pvl.vendor_id)
		or    exists
			(select null
			from ap_recurring_payments_all arp
			where arp.vendor_id = pvl.vendor_id);
	end if;

	if g_purchasing_status = 'Y' then

           debug_info := 'test_po_vendors';
           IF g_debug_switch in ('y','Y') THEN
              Print('(Seed_Vendors)' ||debug_info);
           END IF;


		-- test_po_vendors
		delete from po_purge_vendor_list pvl
		where exists   (select null
				from po_headers_all ph
				where ph.vendor_id =
				      pvl.vendor_id)
		or  exists     (select null
				from rcv_shipment_headers
		        	rcvsh
				where rcvsh.vendor_id =
				      pvl.vendor_id)
		or  exists     (select null
				from po_rfq_vendors rfq
				where rfq.vendor_id =
		 		      pvl.vendor_id);
	end if;

	COMMIT;
	debug_info := 'End Seed_vendors';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Seed_Vendors)' ||debug_info);
        END IF;

	RETURN (TRUE);

RETURN NULL; EXCEPTION
	WHEN OTHERS THEN
	   IF (SQLCODE < 0 ) THEN
     	      Print(SQLERRM);
   	   END IF;
     	   RETURN (FALSE);
END Seed_vendors;


------------------------------------------------------------------
-- Procedure: Test_Vendors
--
------------------------------------------------------------------
FUNCTION Test_Vendors
	 (P_calling_sequence     IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
  'Test_vendors<-'||P_calling_sequence;

  debug_info := 'Starting Test_vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Test_Vendors)' ||debug_info);
  END IF;


  if (g_payables_status = 'Y') then

     if (g_assets_status = 'Y') then

        debug_info := 'test_fa_vendors';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Test_Vendors)' ||debug_info);
        END IF;

	-- test_fa_vendors
	delete from po_purge_vendor_list pvl
	where exists   (select null
	        	from  fa_mass_additions fma
		        where fma.po_vendor_id =
                              pvl.vendor_id)
        or    exists   (select null
		        from  fa_asset_invoices fai
		        where fai.po_vendor_id =
                              pvl.vendor_id);
     end if;

     -- test_ap_vendors


     delete from po_purge_vendor_list pvl
     where exists   (select null
		     from  ap_invoices_all ai
		     where ai.vendor_id = pvl.vendor_id)
     or    exists   (select null
		     from ap_selected_invoices_all asi,
                     ap_supplier_sites_all pvs
		     where asi.vendor_site_id =
                           pvs.vendor_site_id
                     and   pvs.vendor_id  =  pvl.vendor_id)
     or    exists   (select null
		     from ap_recurring_payments_all arp
		     where arp.vendor_id = pvl.vendor_id);
  end if;

  -- check_po_status

  if (g_purchasing_status = 'Y') then

     debug_info := 'check_po_status';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Test_Vendors)' ||debug_info);
     END IF;

     delete from po_purge_vendor_list pvl
     where exists   (select null
		     from po_headers_all ph
		     where ph.vendor_id = pvl.vendor_id)
     or  exists     (select null
		     from rcv_shipment_headers rcvsh
		     where rcvsh.vendor_id = pvl.vendor_id)
     or  exists     (select null
		     from po_rfq_vendors rfq
		     where rfq.vendor_id = pvl.vendor_id)
     or  exists     (select null
                     from rcv_headers_interface rhi
                     where rhi.vendor_id = pvl.vendor_id)
     or  exists     (select null
                     from rcv_transactions_interface rti
                     where rti.vendor_id = pvl.vendor_id);


  end if;

  -- check_vendors_in_chv

  if (g_chv_status = 'Y') then
     debug_info := 'Check_chv_status';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Test_Vendors)' ||debug_info);
     END IF;

     delete from po_purge_vendor_list pvl
     where exists   (select null
        from chv_schedule_headers csh
        where csh.vendor_id = pvl.vendor_id);
  end if;

  -- check_vendors_in_edi

  if (g_edi_status = 'Y') then
     debug_info := 'Check_edi_status';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Test_Vendors)' ||debug_info);
     END IF;

     delete from po_purge_vendor_list pvl
     where exists   (select null
                from  ece_tp_details etd,
                      ap_supplier_sites_all pvs
                where etd.tp_header_id = pvs.tp_header_id
                and pvs.vendor_id = pvl.vendor_id
                and etd.last_update_date > g_activity_date);
--Bug 1781451 Remove from purge list all vendors with last_update_date
--greater than last activity date in Concurrent request parameters
--                and etd.last_update_date <= g_activity_date);

  end if;


  -- check_vendors_in_sourcing_rules

  if (g_mrp_status = 'Y') then
     debug_info := 'Check_vendors_in_sourcing_rules';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Test_Vendors)' ||debug_info);
     END IF;

--1700943, removing the code below that checks for activity
--dates of the sourcing rules.  we should not purge the
--vendor if it is tied to an inactive rule

     delete from po_purge_vendor_list pvl
     where exists   (select null
                     from  mrp_sr_source_org msso
                     where msso.vendor_id = pvl.vendor_id);

  end if;

  COMMIT;

  debug_info := 'End Test_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Test_Vendors)' ||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL;

EXCEPTION
  WHEN OTHERS then
    IF (SQLCODE < 0 ) then
      Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Test_Vendors;


------------------------------------------------------------------
-- Procedure: Seed_Purge_Tables
-- This procedure is used to select the data to be purged and
-- insert into purge tables.
------------------------------------------------------------------
FUNCTION Seed_purge_tables
	 (P_Category          IN  VARCHAR2,
          P_Purge_Name        IN  VARCHAR2,
          P_Activity_Date     IN  DATE,
          P_Organization_ID   IN  NUMBER,
          P_PA_Status         IN  VARCHAR2,
          P_Purchasing_Status IN  VARCHAR2,
          P_Payables_Status   IN  VARCHAR2,
          P_Assets_Status     IN  VARCHAR2,
          P_Chv_Status        IN  VARCHAR2,
          P_EDI_Status        IN  VARCHAR2,
          P_MRP_Status        IN  VARCHAR2,
          P_Debug_Switch      IN  VARCHAR2,
          P_calling_sequence  IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);
l_status                        VARCHAR2(30);

l_recon_acctg_flag              VARCHAR2(1);
l_using_accrual_basis           VARCHAR2(1);
l_using_cash_basis              VARCHAR2(1);

l_po_return_status              VARCHAR2(1);
l_po_msg                        VARCHAR2(2000);
l_po_records_filtered           VARCHAR2(1);

BEGIN

  g_debug_switch := p_debug_switch;

  g_activity_date := P_Activity_Date;
  g_organization_id := P_Organization_ID;
  g_category := P_Category;
  g_pa_status := P_PA_Status;
  g_purchasing_Status := P_Purchasing_Status;
  g_payables_status := P_Payables_Status;
  g_assets_status := P_Assets_Status;
  g_chv_status := P_Chv_Status;
  g_edi_status := P_EDI_Status;
  g_mrp_status := P_MRP_Status;

  -- Update the calling sequence
  --
  current_calling_sequence :=
  'Seed_purge_tables<-'||P_calling_sequence;


  debug_info := 'Get Accounting Methods';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Seed_purge_tables)'||debug_info);
  END IF;

  IF (Get_Accounting_Method(
                  l_recon_acctg_flag,
                  l_using_accrual_basis,
                  l_using_cash_basis,
                  'Get Accounting Method') <> TRUE) THEN
      Print('Seed_simple_invoices failed');
      Return(FALSE);
  END IF;


  debug_info := 'Starting Seed_purge_tables';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Seed_purge_tables)'||debug_info);
  END IF;

  -- Simple Invoices
  if (p_category = 'SIMPLE INVOICES') then

     debug_info := 'Simple Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;


     if (Seed_Invoices(
                 p_purge_name,
                 l_using_accrual_basis,
                 l_using_cash_basis,
                 'Seed_purge_tables') <> TRUE) then
	Print('Seed_simple_invoices failed');
	Return(FALSE);
     end if;

     if (Do_Independent_Inv_Checks(
                       l_using_accrual_basis,
                       l_using_cash_basis,
                       l_recon_acctg_flag,
                       'Seed_purge_tables') <> TRUE) then
	Print('Do_independent_inv_checks failed');
	Return(FALSE);
     end if;

     if (Do_Dependent_inv_checks('Seed_purge_tables')<>
	TRUE) then
	Print('Do_dependent_inv_checks failed');
	Return(FALSE);
     end if;

  elsif (p_category IN ('SIMPLE REQUISITIONS', 'SIMPLE POS')) then

     debug_info := 'Call PO Purge API';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;

     PO_AP_PURGE_GRP.seed_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_last_activity_date => p_activity_date
     );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     PO_AP_PURGE_GRP.filter_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_status => 'INITIATING',
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_action => NULL,
        x_po_records_filtered => l_po_records_filtered
      );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

  elsif (p_category = 'MATCHED POS AND INVOICES') then
     debug_info := 'Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;

     if (Seed_Invoices(
                 p_purge_name,
                 l_using_accrual_basis,
                 l_using_cash_basis,
                 'Seed_purge_tables') <> TRUE) then
	Print('Seed_invoices failed');
	Return(FALSE);
     end if;

     debug_info := 'Purchase Orders';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;


     PO_AP_PURGE_GRP.seed_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_last_activity_date => p_activity_date
     );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;


     PO_AP_PURGE_GRP.filter_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_status => 'INITIATING',
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_action => 'FILTER REF PO AND REQ',
        x_po_records_filtered => l_po_records_filtered
      );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     if (Do_Independent_Inv_Checks(
                       l_using_accrual_basis,
                       l_using_cash_basis,
                       l_recon_acctg_flag,
                       'Seed_purge_tables') <> TRUE) then
	Print('Do_independent_inv_checks failed');
	Return(FALSE);
     end if;

     if (Do_Dependent_Inv_Checks('Seed_purge_tables') <> TRUE) then
	Print('Do_dependent_inv_checks failed');
	Return(FALSE);
     end if;

     debug_info := 'Matching POs to Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;


     if (Match_Pos_To_Invoices_ctrl(
                       P_Purge_Name,
                       'INITIATING',
                       'Seed_purge_tables') <> TRUE) then
	Print('Match_pos_to_Invoices_ctrl failed');
	Return(FALSE);
     end if;

  elsif (p_category = 'VENDORS') then

     debug_info := 'Vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;

     if (Seed_Vendors(
                       P_Purge_Name,
                       'Seed_purge_tables') <> TRUE) then
	Print('Seed_Vendors failed');
	Return(FALSE);
     end if;

     if (Test_Vendors('Seed_purge_tables') <> TRUE) then
	Print('Test_Vendors failed');
	Return(FALSE);
     end if;

  elsif (p_category = 'SCHEDULES BY ORGANIZATION') then

     debug_info := 'Schedules by Org';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;

     if (Seed_Chv_By_Org(
                        p_purge_name,
                        'Seed_purge_tables') <> TRUE) then
         Print('Seed_chv_by_org failed');
	 Return(FALSE);
     end if;

     if (Check_Chv_In_Cum('Seed_purge_tables') <> TRUE) then
         Print('check_chv_in_cum failed');
	 Return(FALSE);
     end if;

     if (Check_Chv_In_Edi('Seed_purge_tables') <> TRUE) then
         Print('check_chv_in_edi failed');
	 Return(FALSE);
     end if;

  elsif (p_category = 'SCHEDULES BY CUM PERIODS') then

     debug_info := 'Schedules by CUM Periods';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Seed_purge_tables)' ||debug_info);
     END IF;

     if (Seed_Chv_By_Cum(
                      p_purge_name,
                      'Seed_purge_tables') <> TRUE) then
         Print('Seed_chv_by_cum failed');
	 Return(FALSE);
     end if;

  else

     debug_info := 'An invalid purge category was entered.';
     Print('(Seed_purge_tables)'||debug_info);
     Print(' Valid Categories are : SIMPLE INVOICES, SIMPLE REQUISITIONS ,');
     Print('SIMPLE POS, MATCHED POS AND INVOICES ,');
     Print('SCHEDULES BY ORGANIZATION and SCHEDULES BY CUM PERIODS');

     l_status := 'COMPLETED-ABORTED';

     if (Set_Purge_Status(l_status,
                          p_purge_name,
                          p_debug_switch,
                          'Seed_Purge_Tables') <> TRUE) then
        Print(' Set_Purge_Status failed.');
        Return(FALSE);
     end if;

     RETURN(TRUE);
  end if;

RETURN NULL; EXCEPTION
  WHEN OTHERS then
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Seed_purge_tables;


/*==========================================================================
  Function: Invoice_Summary

 *==========================================================================*/
FUNCTION Invoice_Summary( p_inv_lower_limit  IN NUMBER,
                          p_inv_upper_limit  IN NUMBER,
                          p_purge_name       IN VARCHAR2,
                          p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

range_low       NUMBER;
range_high      NUMBER;
range_inserted  VARCHAR2(1);
range_size      NUMBER:=10000;

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Invoice_Summary<-'||P_calling_sequence;
  --
  debug_info := 'Starting Invoice_Summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Invoice_Summary)'||debug_info);
  END IF;


  /**** Invoice Loop ****/
  range_size := g_range_size;
  range_high := 0;
  range_low := p_inv_lower_limit;
  range_high := range_low + range_size;

  LOOP
        range_inserted := 'N';

        -- Check_invoice_Summary
       BEGIN
        select 'Y'
        into   range_inserted
        from   sys.dual
        where  exists (select null
                       from   ap_history_invoices
                       where  purge_name = p_purge_name
                        and    invoice_id between range_low and range_high);

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        range_inserted := 'N';
      END;

        if (range_inserted <> 'Y') then
          --
          debug_info := 'Summerizing sub-group from Oracle Purchasing -- Invoices';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Invoice_Summary)'||debug_info);
          END IF;
           -- summarize_invoices
	   -- bug5487843, added org_id and changed to _ALL
          INSERT INTO ap_history_invoices_all
                  (invoice_id, vendor_id, vendor_site_code, invoice_num, invoice_date,
                   invoice_amount, batch_name, purge_name, doc_sequence_id,
                   doc_sequence_value,org_id)
          SELECT  i.invoice_id, i.vendor_id, v.vendor_site_code, i.invoice_num,
                  i.invoice_date, i.invoice_amount, b.batch_name, p_purge_name,
                  i.doc_sequence_id, i.doc_sequence_value,i.org_id
          FROM    ap_invoices_all i, ap_supplier_sites_all v, ap_batches_all b
          WHERE   i.vendor_site_id = v.vendor_site_id
          AND     i.batch_id = b.batch_id (+)
          AND     i.invoice_id IN (SELECT PL.invoice_id
                                   FROM  ap_purge_invoice_list PL
                                   WHERE PL.double_check_flag = 'Y'
                                   AND   PL.invoice_id BETWEEN range_low AND
                                                           range_high);

          --
          debug_info := '    -- Checks';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Invoice_Summary)'||debug_info);
          END IF;

          --5007666, added payment_id
	  -- bug5487843, added org_id and changed to _ALL
          -- summarize_checks
          INSERT INTO ap_history_checks_all
          (check_id, bank_account_id, check_number, check_date, amount,
          currency_code, void_flag, purge_name, doc_sequence_id,
          doc_sequence_value, payment_id,org_id)
          SELECT
          ac.check_id, ac.bank_account_id, ac.check_number, ac.check_date,
          ac.amount, ac.currency_code, DECODE(void_date, null, null, 'Y'),
          p_purge_name, ac.doc_sequence_id, ac.doc_sequence_value, ac.payment_id,
	  ac.org_id
          FROM ap_checks_all AC,
               ap_invoice_payments_all IP,
               ap_purge_invoice_list PL
          WHERE PL.invoice_id        = IP.invoice_id
          AND   IP.check_id          = AC.check_id
          AND   PL.double_check_flag = 'Y'
          AND   PL.invoice_id BETWEEN range_low AND range_high
          AND NOT EXISTS (SELECT null
                          FROM   ap_history_checks_all hc
                          WHERE  hc.check_id = AC.check_id)
          GROUP BY ac.check_id, ac.bank_account_id, ac.check_number,
                   ac.check_date, ac.amount, ac.currency_code,
                   DECODE(void_date, null, null, 'Y'), purge_name,
                   ac.doc_sequence_id, ac.doc_sequence_value, ac.payment_id,
		   ac.org_id; --Bug 6277474 added the org_id in group by clause.

          --
          debug_info := '    -- Invoices Payments';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Invoice_Summary)'||debug_info);
          END IF;

          -- summarize_invoice_payments
	  -- bug5487843, added org_id and changed to _ALL
          INSERT INTO ap_history_inv_payments_all
          (invoice_id, check_id, amount,org_id)
          SELECT
          IP.invoice_id, IP.check_id, SUM(IP.amount),IP.org_id
          FROM  ap_invoice_payments_all IP, ap_purge_invoice_list PL
          WHERE IP.invoice_id = PL.invoice_id
          AND   PL.double_check_flag = 'Y'
          AND   PL.invoice_id BETWEEN range_low AND range_high
          GROUP BY IP.invoice_id, IP.check_id,
		   IP.org_id; --Bug 6277474 added the org_id in group by clause.

          COMMIT;
        end if;

        range_low := range_high + 1;
        range_high := range_high + range_size;

        if (range_low > p_inv_upper_limit) then
                EXIT;
        end if;
  END LOOP;
  --
  debug_info := 'End Invoice_Summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Invoice_Summary)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Invoice_Summary;

/*==========================================================================
  Function: Vendor_Summary

 *==========================================================================*/
FUNCTION Vendor_Summary(  p_purge_name          IN VARCHAR2,
                          p_calling_sequence  IN        VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

range_low       NUMBER;
range_high      NUMBER;
range_inserted  VARCHAR2(1);
range_size      NUMBER:=10000;

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Vendor_Summary<-'||P_calling_sequence;
  --
  debug_info := 'Starting Vendor_Summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Vendor_Summary)'||debug_info);
  END IF;


  range_inserted := 'N';

  -- Check_vendor_Summary

  BEGIN

  select 'Y'
  into   range_inserted
  from   sys.dual
  where  exists (select null
                 from   po_history_vendors vnd
                 where  vnd.purge_name = p_purge_name);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      range_inserted := 'N';
  END;

  if (range_inserted <> 'Y') then
  --
          debug_info := 'Vendors';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Vendor_Summary)'||debug_info);
          END IF;

          -- summarize_Vendor
          insert into po_history_vendors
               (vendor_id,
                vendor_name,
                segment1,
                vendor_type_lookup_code,
                purge_name)
          select  vnd.vendor_id,
                vnd.vendor_name,
                vnd.segment1,
                vnd.vendor_type_lookup_code,
                p_purge_name
          from  po_purge_vendor_list pvl,
                ap_suppliers vnd
          where pvl.vendor_id = vnd.vendor_id
          and   pvl.double_check_flag = 'Y';

          COMMIT;
  end if;

  --
  debug_info := 'End Vendor_Summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Vendor_Summary)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
       Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Vendor_Summary;

/*==========================================================================
  Function: Schedule_Org_Summary

 *==========================================================================*/
FUNCTION Schedule_Org_Summary(
                     p_chv_lower_limit    IN NUMBER,
                     p_chv_upper_limit    IN NUMBER,
                     p_purge_name         IN VARCHAR2,
                     p_category           IN VARCHAR2,
                     p_calling_sequence   IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);
range_low       NUMBER;
range_high      NUMBER;
range_inserted  VARCHAR2(1);
range_size      NUMBER;

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Schedule_Org_Summary<-'||P_calling_sequence;
  --
  debug_info := 'Starting Schedule_Org_Summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Schedule_Org_Summary)'||debug_info);
  END IF;


  /**** Schedule Loop ****/
  range_size :=  g_range_size;
  range_high := 0;
  range_low := p_chv_lower_limit;
  range_high := range_low + range_size;
  Print('(Schedule_Org_Summary-Range Size) '||to_char (range_size));
  Print('(Schedule_Org_Summary-Range Low) '||to_char (range_low));
  Print('(Schedule_Org_Summary-Range High) '||to_char (range_high));

  LOOP
        range_inserted := 'N';

        -- Check_Chv_Summary
        select MAX('Y')
        into   range_inserted
        from   sys.dual
        where  exists (select null
                       from   chv_schedule_items csi,
			      chv_schedule_headers csh,
                              chv_history_schedules chs
                       where  csi.item_id         = chs.item_id
                       and    csi.schedule_id     = chs.schedule_id
		       and    csh.schedule_id     = chs.schedule_id
		       and    csh.vendor_id       = chs.vendor_id
		       and    csh.vendor_site_id  = chs.vendor_site_id
		       and    csi.organization_id = chs.organization_id
                       and    chs.purge_name      = p_purge_name
                       and    csi.schedule_item_id between range_low
                                               and range_high);

        Print('(Range Inserted) ' || range_inserted);
        if (NVL(range_inserted,'N') <> 'Y') then
          --
          debug_info := 'Summerizing sub-group from Oracle Supplier Scheduling';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Schedule_Org_Summary)'||debug_info);
          END IF;

          -- summarize_schedules_by_org
          insert into chv_history_schedules
                (schedule_id,
                 vendor_id,
                 vendor_site_id,
                 schedule_type,
                 schedule_subtype,
		 schedule_horizon_start,
		 bucket_pattern_id,
		 creation_date,
		 schedule_num,
		 schedule_revision,
		 schedule_status,
		 item_id,
		 organization_id,
                 purge_name
                 )
          select  csh.schedule_id,
                  csh.vendor_id,
                  csh.vendor_site_id,
                  csh.schedule_type,
                  csh.schedule_subtype,
		  csh.schedule_horizon_start,
		  csh.bucket_pattern_id,
		  csh.creation_date,
		  csh.schedule_num,
		  csh.schedule_revision,
		  csh.schedule_status,
		  csi.item_id,
		  csi.organization_id,
                  p_purge_name
          from  chv_purge_schedule_list cpsl,
                chv_schedule_headers csh,
                chv_schedule_items csi
          where   cpsl.schedule_item_id = csi.schedule_item_id
	  and     csi.schedule_id = csh.schedule_id
          and     cpsl.double_check_flag     = 'Y'
          and     cpsl.schedule_item_id between range_low and range_high;

          COMMIT;
        end if;

        range_low := range_high + 1;
        range_high := range_high + range_size;

        if (range_low >= p_chv_upper_limit) then
                EXIT;
        end if;
  END LOOP;

  range_inserted := 'N';

  -- Check_Chv_Summary_for_CUMs
  select MAX('Y')
  into   range_inserted
  from   sys.dual
  where  exists (select null
                 from   chv_cum_periods ccp,
                        chv_history_cum_periods chcp
		 where  ccp.cum_period_id   = chcp.cum_period_id
                 and    chcp.purge_name     = p_purge_name);

-- 1783982 fbreslin: Compare using :p_catagory rather than p_purge_name

  if (p_category = 'SCHEDULES BY CUM PERIODS' AND
      NVL(range_inserted,'N') <> 'Y') then
      -- summarize_schedules_by_org
          insert into chv_history_cum_periods
                (cum_period_id,
		 cum_period_name,
		 cum_period_start_date,
		 cum_period_end_date,
		 creation_date,
                 purge_name
                 )
          select  ccp.cum_period_id,
       		  ccp.cum_period_name,
		  ccp.cum_period_start_date,
		  ccp.cum_period_end_date,
		  ccp.creation_date,
                  p_purge_name
          from  chv_purge_cum_list cpcl,
                chv_cum_periods ccp
          where   cpcl.cum_period_id = ccp.cum_period_id
          and     cpcl.double_check_flag     = 'Y';
          COMMIT;
  end if;
  --
  debug_info := 'End schedule_org_summary';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Schedule_Org_Summary)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
      Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END schedule_org_summary;


/*==========================================================================
  Function: Get_Ranges

 *==========================================================================*/
FUNCTION Get_Ranges( p_inv_lower_limit   OUT NOCOPY NUMBER,
                     p_inv_upper_limit   OUT NOCOPY NUMBER,
                     p_req_lower_limit   OUT NOCOPY NUMBER,
                     p_req_upper_limit   OUT NOCOPY NUMBER,
                     p_po_lower_limit    OUT NOCOPY NUMBER,
                     p_po_upper_limit    OUT NOCOPY NUMBER,
                     p_chv_lower_limit   OUT NOCOPY NUMBER,
		     p_chv_upper_limit   OUT NOCOPY NUMBER,
                     p_calling_sequence  IN         VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Get_Ranges<-'||P_calling_sequence;
  --
  debug_info := 'Starting Get_Ranges';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Get_Ranges)'||debug_info);
  END IF;

  -- get_ap_range
  select nvl(min(invoice_id),-1),
         nvl(max(invoice_id),-1)
  into   p_inv_lower_limit, p_inv_upper_limit
  from   ap_purge_invoice_list
  where  double_check_flag = 'Y';

  -- get_po_range
  select nvl(min(po_header_id),-1),
         nvl(max(po_header_id),-1)
  into   p_po_lower_limit, p_po_upper_limit
  from   po_purge_po_list
  where  double_check_flag = 'Y';

  -- get_req_range
  select nvl(min(requisition_header_id),-1),
         nvl(max(requisition_header_id),-1)
  into   p_req_lower_limit, p_req_upper_limit
  from   po_purge_req_list
  where  double_check_flag = 'Y';

  -- get_chv_range
  select nvl(min(schedule_item_id),-1),
         nvl(max(schedule_item_id),-1)
  into   p_chv_lower_limit, p_chv_upper_limit
  from   chv_purge_schedule_list
  where  double_check_flag = 'Y';

  --
  debug_info := 'End Get_Ranges';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Get_Ranges)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Get_Ranges;

/*==========================================================================
  Function: Create_Summary_Records

 *==========================================================================*/
FUNCTION Create_Summary_Records(p_purge_name       IN VARCHAR2,
                                p_category         IN VARCHAR2,
                                p_range_size       IN NUMBER,
                                p_debug_switch     IN VARCHAR2,
                                p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

inv_lower_limit		NUMBER;
inv_upper_limit		NUMBER;
req_lower_limit		NUMBER;
req_upper_limit		NUMBER;
po_lower_limit		NUMBER;
po_upper_limit		NUMBER;
chv_lower_limit         NUMBER;
chv_upper_limit		NUMBER;

l_po_return_status VARCHAR2(1);
l_po_msg VARCHAR2(2000);


BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Create_Summary_Records<-'||P_calling_sequence;
  --
  debug_info := 'Starting Create_Summary_Records';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Create_Summary_Records)'||debug_info);
  END IF;

  g_debug_switch := p_debug_switch;
  g_range_size   := p_range_size;

  --
  if (Get_Ranges( inv_lower_limit,
                  inv_upper_limit,
                  req_lower_limit,
                  req_upper_limit,
                  po_lower_limit,
                  po_upper_limit,
                  chv_lower_limit,
		  chv_upper_limit,
                  'Create_Summary_Records') <> TRUE) then
	Print('Get_Ranges failed.');
        return(FALSE);
  end if;

  --
  debug_info := 'Inserting summary records into history tables';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Create_Summary_Records)'||debug_info);
  END IF;

  if (p_category in ( 'SIMPLE INVOICES', 'MATCHED POS AND INVOICES')) then

        if (invoice_summary(inv_lower_limit,
                            inv_upper_limit,
		            p_purge_name,
                            'Create_Summary_Records') <> TRUE) then
                Print('Invoice_Summary failed.');
 		return(FALSE);
        end if;

        if (p_category = 'MATCHED POS AND INVOICES') then

            PO_AP_PURGE_GRP.summarize_records
            (  p_api_version => 1.0,
               p_init_msg_list => 'T',
               p_commit => 'T',
               x_return_status => l_po_return_status,
               x_msg_data => l_po_msg,
               p_purge_name => p_purge_name,
               p_purge_category => p_category,
               p_range_size => p_range_size
            );

            IF (l_po_return_status <> 'S') THEN
                Print(l_po_msg);
                RETURN FALSE;
            END IF;
        end if;

  elsif (p_category IN ('SIMPLE REQUISITIONS', 'SIMPLE POS')) THEN

            PO_AP_PURGE_GRP.summarize_records
            (  p_api_version => 1.0,
               p_init_msg_list => 'T',
               p_commit => 'T',
               x_return_status => l_po_return_status,
               x_msg_data => l_po_msg,
               p_purge_name => p_purge_name,
               p_purge_category => p_category,
               p_range_size => p_range_size
            );

            IF (l_po_return_status <> 'S') THEN
                Print(l_po_msg);
                RETURN FALSE;
            END IF;
         --

  elsif (p_category = 'VENDORS') then

        if (vendor_summary(p_purge_name,
                       'Create_Summary_Records') <> TRUE) then
                Print('Vendor_Summary failed.');
		return(FALSE);
        end if;
  elsif (p_category IN  ('SCHEDULES BY ORGANIZATION' ,
         'SCHEDULES BY CUM PERIODS')) then

        if (schedule_org_summary(chv_lower_limit,
			chv_upper_limit,
		        p_purge_name,
                        p_category,
                       'Create_Summary_Records') <> TRUE) then
                Print('Schedule_Org_Summary failed.');
		return(FALSE);
        end if;

  end if;
  --
  debug_info := 'End Create_Summary_Records';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Create_Summary_Records)'||debug_info);
  END IF;


  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Create_Summary_Records;



/*==========================================================================
 Function: Retest_Invoice_Independents

 *==========================================================================*/
FUNCTION  Retest_Invoice_Independents(
                         P_Calling_Sequence     VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Invoice_Independents<-'||P_calling_sequence;

  --
  debug_info := 'Reaffirming invoice candidate listing -- Retest Invoices';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;

  --

  -- Retest invoices
  UPDATE ap_purge_invoice_list PL
  SET PL.double_check_flag = 'N'
  WHERE PL.double_check_flag = 'Y'
  AND EXISTS(
                SELECT 'invoice no longer purgeable'
                FROM ap_invoices I
                WHERE PL.invoice_id = I.invoice_id
                AND ((  I.payment_status_flag <> 'Y'
                        AND
                        I.invoice_amount <> 0)
                     OR I.last_update_date > g_activity_date
                     OR I.invoice_date > g_activity_date));

  --

  if g_pa_status = 'Y' then
       debug_info := 'Test PA Invoices';
       Print('(Retest_Invoice_Independens) '||debug_info);


     -- Retest PA Invoices
     UPDATE ap_purge_invoice_list PL
     SET PL.double_check_flag = 'N'
     WHERE PL.double_check_flag = 'Y'
     AND (EXISTS
                (SELECT 'project-related vendor invoices'
                FROM    ap_invoice_distributions d
                WHERE   d.invoice_id = pl.invoice_id
                AND     d.project_id is not null   -- bug1746226
                )
     OR EXISTS
                (SELECT 'project-related expense report'
                FROM    ap_invoices i
                WHERE   i.invoice_id = pl.invoice_id
                AND     i.source = 'Oracle Project Accounting'
                ));
  end if;

  --
  debug_info := 'Payment Schedules';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;

  --

  -- Retest Payment Schedules
--bug5052748
  UPDATE ap_purge_invoice_list PL
  SET PL.double_check_flag = 'N'
  WHERE PL.double_check_flag = 'Y'
  AND EXISTS (
                SELECT /*+NO_UNNEST*/ 'payment schedule no longer purgeable'
                FROM ap_payment_schedules PS,
                     ap_invoices I
                WHERE PS.invoice_id = PL.invoice_id
                AND   PS.invoice_id = I.invoice_id
                AND ((PS.payment_status_flag <> 'Y'
                      AND  I.cancelled_date is null)
                     OR PS.last_update_date > g_activity_date)
                );

  --
  debug_info := 'Distributions';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;

/*
1897941 fbreslin: If an invoice is cancelled, the ASSETS_ADDTION_FLAG is
                  set to "U" so Mass Additions does not include the
                  distribution.  We are alos not supposed to purge
                  invoices if any of the distributions have ben passed to
                  FA. Adding a check to see if the invoice is cancelled
                  before we remove an invoice with ASSETS_ADDTION_FLAG = U
                  from the purge list.
*/
  if g_category = 'SIMPLE INVOICES' then
--bug5052748
   -- Retest simple Invoice Distributions
        UPDATE ap_purge_invoice_list PL
        SET PL.double_check_flag = 'N'
        WHERE PL.double_check_flag = 'Y'
        AND EXISTS
            (SELECT /*+NO_UNNEST*/ 'distribution no longer purgeable'
               FROM ap_invoice_distributions D, ap_invoices I
              WHERE I.invoice_id = D.invoice_id
                AND PL.invoice_id = D.invoice_id
                AND (   D.last_update_date > g_activity_date
                     OR D.posted_flag <> 'Y'
                     OR D.po_distribution_id IS NOT NULL
                     OR (    D.assets_addition_flag||'' =
                             Decode(g_Assets_Status,
                                    'Y', 'U',
                                    'cantequalme')
                         AND I.cancelled_date IS NULL)));
  else
--bug5052748
  -- Retest all Invoice Distributions
        UPDATE ap_purge_invoice_list PL
        SET PL.double_check_flag = 'N'
        WHERE PL.double_check_flag = 'Y'
        AND EXISTS
            (SELECT /*+NO_UNNEST*/'distribution no longer purgeable'
               FROM ap_invoice_distributions D, ap_invoices I
              WHERE I.invoice_id = D.invoice_id
                AND PL.invoice_id = D.invoice_id
                AND (   D.last_update_date > g_activity_date
                     OR D.posted_flag <> 'Y'
                     OR (    D.assets_addition_flag||'' =
                             Decode(g_Assets_Status,
                                    'Y', 'U',
                                    'cantequalme')
                         AND I.cancelled_date IS NULL)));
  end if;

  --
  debug_info := 'Payment Dates';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;

  --
--bug5052748
  -- Retest Payments
        UPDATE ap_purge_invoice_list PL
        SET PL.double_check_flag = 'N'
        WHERE PL.double_check_flag = 'Y'
        AND EXISTS (
                SELECT /*+NO_UNNEST*/'payment no longer purgeable'
                FROM ap_invoice_payments P, ap_checks C
                WHERE P.invoice_id = PL.invoice_id
                AND P.check_id = C.check_id
                AND     (P.posted_flag <> 'Y'
                        OR P.last_update_date > g_activity_date
                        OR C.last_update_date > g_activity_date
                        OR (NVL(C.cleared_date, C.void_date) > g_activity_date
			    AND nvl(C.cleared_date, C.void_date) is not NULL)
		));

  --
  debug_info := 'Prepayments';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;

  --

        UPDATE ap_purge_invoice_list PL
        SET PL.double_check_flag = 'N'
        WHERE PL.double_check_flag = 'Y'
        AND EXISTS (
                SELECT 'recently related to prepayment'
                FROM ap_invoice_prepays IP
                WHERE   PL.invoice_id = IP.invoice_id
                        OR PL.invoice_id = IP.prepay_id);

  --
  debug_info := 'Matched';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;
  --

        UPDATE ap_purge_invoice_list PL
        SET PL.double_check_flag = 'N'
        WHERE EXISTS (
                 SELECT 'matched'
                 FROM  ap_invoice_distributions aid
                 ,      rcv_transactions rcv
                 WHERE aid.invoice_id = PL.invoice_id
                 and  aid.rcv_transaction_id = rcv.transaction_id
                 --Bug 1579474
                 and  rcv.last_update_date > g_activity_date
                 );

  --
  debug_info := 'Matching Invoices to Receipts';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;
  --

        UPDATE ap_purge_invoice_list PL
	SET double_check_flag = 'N'
	WHERE EXISTS (
		SELECT null
		FROM ap_invoice_distributions ad
		WHERE ad.invoice_id = PL.invoice_id
		and ad.rcv_transaction_id IS NOT NULL
		and EXISTS (
			SELECT 'matching'
			FROM ap_invoice_distributions ad2
			where ad2.rcv_transaction_id = ad.rcv_transaction_id
			and ad2.invoice_id NOT IN (
				SELECT invoice_id
				FROM ap_purge_invoice_list
				WHERE double_check_flag = 'Y')));


  --
  debug_info := 'Invoice accounting not purgeable';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;
  -- RETURN (TRUE);
  --
-- Fix for bug 2652768 made changes to below UPDATE statement
-- Fix for bug 2963666 added an check for MRC upgraded data
   UPDATE ap_purge_invoice_list PL
   SET PL.double_check_flag = 'N'
   WHERE EXISTS (
                 SELECT 'invoice accounting not purgeable'
                 FROM   xla_events xe,
                        xla_ae_headers xeh,
                        xla_transaction_entities xte,
                        ap_invoices_all ai,
                        ap_system_parameters_all asp --bug5052748
                 where xte.entity_code = 'AP_INVOICES'
                 and   xte.entity_id = xe.entity_id
                 and   xte.source_id_int_1 =PL.invoice_id
                 AND ai.invoice_id=pl.invoice_id
                 AND ai.org_id=asp.org_id
                 AND asp.set_of_books_id=xte.ledger_id
                 and   xe.event_id = xeh.event_id
                 and   xe.application_id = 200
                 and   xeh.application_id = 200
                 and   xte.application_id = 200
                 and   (xeh.gl_transfer_status_code = 'N'
                        OR ( xeh.last_update_date > g_activity_date)))
   OR EXISTS (
                 SELECT 'payment accounting not purgeable'
                 FROM xla_events xe
                 ,    ap_invoice_payments aip
                 ,    ap_checks apc
                 ,    xla_ae_headers xeh
                 ,    xla_transaction_entities xte
                 WHERE xte.entity_code = 'AP_CHECKS'
                 and  xte.source_id_int_1 = apc.check_id
                 and PL.invoice_id = aip.invoice_id
                 and aip.check_id = apc.check_id
                 and xe.event_id = xeh.event_id
                 and xe.application_id = 200
                 and xeh.application_id = 200
                 and xte.application_id = 200
                 and xe.event_id = xeh.event_id
                 and (xeh.gl_transfer_status_code = 'N'
                      OR ( xeh.last_update_date > g_activity_date)));

  --
  debug_info := 'End Retest_Invoice_Independents';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest Invoice Independents)'||debug_info);
  END IF;
  RETURN (TRUE);
  --

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Invoice_Independents;




/*==========================================================================
 Private Function: Redo_Dependent_inv_checks

 *==========================================================================*/

FUNCTION REDO_DEPENDENT_INV_CHECKS
         (P_Calling_Sequence  IN VARCHAR2)
RETURN BOOLEAN IS

/* bug3057900 : Created this function instead of do_dependent_inv_checks function.
   Because performance of delete stmt in do_dependent_inv_checks was very poor.
   This function does same check with the delete stmt.
*/

 TYPE tab_status_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
 tab_inv tab_status_type;
 tab_check tab_status_type;
 tab_clear tab_status_type;

 CURSOR c_main IS
  select pl.invoice_id
    from ap_purge_invoice_list pl,
         ap_invoice_payments ip
   where pl.invoice_id = ip.invoice_id;

 CURSOR c_main_check(l_invoice_id NUMBER) IS
  select invoice_id
    from ap_purge_invoice_list
   where invoice_id = l_invoice_id
     and double_check_flag = 'Y';

  p_count   integer;
  p_id   integer;

  l_cnt integer;
  debug_info                      VARCHAR2(200);
  current_calling_sequence  	VARCHAR2(2000);
  l_invoice BOOLEAN ;
  l_dummy NUMBER ;

Function Check_check(l_invoice_id IN NUMBER ) RETURN BOOLEAN;

/* Get related invoice_id from check_id and check if the invoice_id is
   in purge list. If there is, call check_check to get check_id which
   is related to the invoice_id */
Function Check_inv(l_check_id IN NUMBER) RETURN BOOLEAN IS

 CURSOR c_inv IS
  select pil.invoice_id
    from ap_invoice_payments ip,
         ap_purge_invoice_list pil
   where ip.check_id = l_check_id
     and ip.invoice_id = pil.invoice_id (+)
     and pil.double_check_flag = 'Y';

 l_flag BOOLEAN := FALSE;
 l_inv_id ap_purge_invoice_list.invoice_id%TYPE;

BEGIN

  OPEN c_inv ;
  LOOP

    FETCH c_inv into l_inv_id ;
    EXIT WHEN c_inv%NOTFOUND ;

    /* if related invoice id is not in purge list */
    IF l_inv_id is null THEN
      l_flag := FALSE ;
    ELSE

      /* if the invocie_id is already checked */
      IF tab_inv.exists(l_inv_id) THEN
        l_flag := TRUE ;
      ELSE
        tab_inv(l_inv_id) := 'X' ;
        l_flag := check_check(l_inv_id) ;
      END IF;
    END IF;

    EXIT WHEN (not l_flag) ;

  END LOOP;

  CLOSE C_inv;
  RETURN(l_flag) ;

END ;

/* Get related check_id from invoice_id and call check_invoice
   to check if the invoice is in purge list. */
Function Check_check(l_invoice_id IN NUMBER ) RETURN BOOLEAN IS

 CURSOR c_check IS
  select check_id
    from ap_invoice_payments
   where invoice_id = l_invoice_id ;

  l_flag BOOLEAN := FALSE;
  l_check_id number;

BEGIN

  OPEN c_check ;
  LOOP

    FETCH c_check into l_check_id ;
    EXIT WHEN c_check%NOTFOUND ;

    /* if the check_id is already checked */
    IF tab_check.exists(l_check_id) THEN
      l_flag := TRUE ;
    ELSE
      tab_check(l_check_id) := 'X' ;
      l_flag := check_inv(l_check_id) ;
    END IF;

    EXIT WHEN (not l_flag) ;

  END LOOP;

  CLOSE C_check;
  RETURN(l_flag) ;

END ;

/* main process */
BEGIN
  -- Update the calling sequence
  --
   current_calling_sequence :=
   'ReDo_Dependent_Inv_Checks<-'||P_calling_sequence;
  --

  debug_info := 'Starting series of dependent invoice validations';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Redo_Dependent_Inv_Checks)'||debug_info);
  END IF;

  FOR l_main IN c_main
  LOOP

    /* initialization */
    tab_inv := tab_clear ;
    tab_check := tab_clear;

    /* check if this invoice is not checked yet */
    OPEN c_main_check(l_main.invoice_id) ;
    FETCH c_main_check into l_dummy ;
    l_invoice := c_main_check%FOUND ;
    CLOSE c_main_check ;

    /* if this invoice is not checked yet */
    IF (l_invoice) THEN

      tab_inv(l_main.invoice_id) := 'X' ;

      IF check_check(l_main.invoice_id) THEN

        /* if this chain is purgeable,set flag 'S' for all invoices in this chain */
        p_count := tab_inv.count;
        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_inv.next(p_id) ;
            UPDATE ap_purge_invoice_list
               SET double_check_flag = 'S'
             WHERE invoice_id = p_id ;
          END LOOP;

        END IF;
      ELSE

        /* if this chain is not purgeable, delete selected invoice from purge list */
        p_count := tab_inv.count;
        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_inv.next(p_id) ;
            UPDATE ap_purge_invoice_list
               SET double_check_flag = 'N'
             WHERE invoice_id = p_id ;
          END LOOP;
        end if;

        /* delete unpurgeable list beforehand for performance */
        p_count := tab_check.count;

        IF p_count <> 0 THEN
          p_id := 0 ;

          FOR y IN 1..p_count LOOP
            p_id := tab_check.next(p_id) ;
            UPDATE ap_purge_invoice_list
               SET double_check_flag = 'N'
            WHERE invoice_id in ( select invoice_id
                from ap_invoice_payments
                where check_id = p_id);
          END LOOP;
        END IF;

     END IF;

    END IF;

  END LOOP;

  /* Set flag 'Y' back */
  update ap_purge_invoice_list
    set double_check_flag = 'Y'
   where double_check_flag = 'S' ;

  debug_info := 'End of Invoice Validations';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Redo_Dependent_Inv_Checks)'||debug_info);
  END IF;

  commit;
  return(TRUE) ;

RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE < 0 ) then
         Print(SQLERRM);
      END IF;
      RETURN(FALSE);
END ;


/*==========================================================================
 Private Function: Count_Ap_Rows

 *==========================================================================*/

FUNCTION Count_Ap_Rows(FP_Check_Rows           OUT NOCOPY NUMBER,
                       FP_Invoice_Payment_Rows OUT NOCOPY NUMBER,
                       FP_Invoice_Rows         OUT NOCOPY NUMBER,
                       P_Calling_Sequence      VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);


BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Count_AP_Rows<-'||P_calling_sequence;

  --

  debug_info := 'ap_checks';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Ap_Rows)'||debug_info);
  END IF;



  --
  SELECT count(*)
  INTO   fp_check_rows
  FROM   ap_checks;

  --
  debug_info := 'ap_invoice_payments';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Ap_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   fp_invoice_payment_rows
  FROM   ap_invoice_payments;

  --
  debug_info := 'ap_invoices';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Ap_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   fp_invoice_rows
  FROM ap_invoices;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Count_Ap_Rows;

/*==========================================================================
 Private Function: Count_Accounting_Rows

 *==========================================================================*/

FUNCTION Count_Accounting_Rows(FP_Ae_Line_Rows              OUT NOCOPY NUMBER,
                       	       FP_Ae_Header_Rows            OUT NOCOPY NUMBER,
                      	       FP_Accounting_Event_Rows     OUT NOCOPY NUMBER,
                               FP_Chrg_Allocation_Rows      OUT NOCOPY NUMBER,
                               FP_Payment_History_Rows      OUT NOCOPY NUMBER,
                               FP_Encumbrance_line_Rows     OUT NOCOPY NUMBER,
                               FP_Rcv_Subledger_Detail_Rows OUT NOCOPY NUMBER,
                       	       P_Calling_Sequence VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);


BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Count_Accounting_Rows<-'||P_calling_sequence;

  -- Removing references to AP tables for bug 4588031

  -- debug_info := 'ap_ae_lines';
  -- IF g_debug_switch in ('y','Y') THEN
  --    Print('(Count_Accounting_Rows)'||debug_info);
  -- END IF;


  -- Removing references to AP tables for bug 4588031
  -- SELECT count(*)
  -- INTO   fp_ae_line_rows
  -- FROM   ap_ae_lines;

  --  Removing references to AP tables for bug 4588031
  -- debug_info := 'ap_ae_headers';
  -- IF g_debug_switch in ('y','Y') THEN
  --    Print('(Count_Accounting_Rows)'||debug_info);
  -- END IF;

  -- Removing references to AP tables for bug 4588031
  -- SELECT count(*)
  -- INTO   fp_ae_header_rows
  -- FROM   ap_ae_headers;

  -- Removing references to AP tables for bug 4588031
  -- debug_info := 'ap_accounting_events';
  -- IF g_debug_switch in ('y','Y') THEN
  --    Print('(Count_Accounting_Rows)'||debug_info);
  -- END IF;

  -- Removing references to AP tables for bug 4588031
  -- SELECT count(*)
  -- INTO   fp_accounting_event_rows
  -- FROM   ap_accounting_events;

  debug_info := 'ap_chrg_allocations';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Accounting_Rows)'||debug_info);
  END IF;

  -- Bug 5118119 -- removed rendundant code as ap_chrg_allocations is obsolete in R12
  --
  -- SELECT count(*)
  -- INTO   fp_chrg_allocation_rows
  -- FROM   ap_chrg_allocations;

  --
  debug_info := 'ap_payment_history';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Accounting_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   fp_payment_history_rows
  FROM   ap_payment_history;

  --
  debug_info := 'ap_encumbrance_lines';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Accounting_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   fp_encumbrance_line_rows
  FROM   ap_encumbrance_lines;

  --
  debug_info := 'rcv_subledger_details';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Accounting_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   fp_rcv_subledger_detail_rows
  FROM   rcv_sub_ledger_details;


  RETURN (TRUE);


RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Count_Accounting_Rows;



/*==========================================================================
  Function: Retest_Seeded_Vendors

 *==========================================================================*/
FUNCTION Retest_Seeded_Vendors(
         p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'Retest_Seeded_Vendors<-'||P_calling_sequence;
  --
  debug_info := 'Starting Retest_Seeded_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Seeded_Vendors)'||debug_info);
  END IF;

  update po_purge_vendor_list pvl
  set double_check_flag = 'N'
  where pvl.double_check_flag = 'Y'
  and   not exists (select null
                    from    ap_suppliers vnd
                    where   vnd.vendor_id = pvl.vendor_id
                    --and   nvl(vnd.vendor_type_lookup_code, 'VENDOR') <> 'EMPLOYEE'
                    and     nvl(vnd.end_date_active,sysdate) <=
                                g_activity_date);

  --
  debug_info := 'End Retest_Seeded_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Seeded_Vendors)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Seeded_Vendors;



/*==========================================================================
  Function: Retest_Vendors

 *==========================================================================*/
FUNCTION Retest_Vendors(
         p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Vendors<-'||P_calling_sequence;
  --
  debug_info := 'Starting Retest_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Vendors)'||debug_info);
  END IF;

  if (g_payables_status = 'Y') then
     if (g_assets_status = 'Y') then

        debug_info := 'retest_fa_vendors';
        IF g_debug_switch in ('y','Y') THEN
           Print('(Retest_Vendors)'||debug_info);
        END IF;

        -- retest_fa_vendors
        update po_purge_vendor_list pvl
        set double_check_flag = 'N'
        where pvl.double_check_flag = 'Y'
        and (exists    (select null
                        from fa_mass_additions fma
                        where fma.po_vendor_id = pvl.vendor_id)
             or
             exists    (select null
                        from fa_asset_invoices fai
                        where fai.po_vendor_id = pvl.vendor_id));
     end if;

     debug_info := 'retest_ap_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Retest_Vendors)'||debug_info);
     END IF;

     -- retest_ap_vendors
     update po_purge_vendor_list pvl
     set double_check_flag = 'N'
     where pvl.double_check_flag = 'Y'
     and  (exists   (select null
                     from ap_invoices_all ai
                     where ai.vendor_id = pvl.vendor_id)
           or
           exists   (select null
                     from ap_selected_invoices_all asi,
                          ap_supplier_sites_all pvs
                     where asi.vendor_site_id = pvs.vendor_site_id
                    and   pvs.vendor_id      = pvl.vendor_id)
           or
           exists   (select null
                     from ap_recurring_payments_all arp
                     where arp.vendor_id = pvl.vendor_id));
  end if;

  if (g_purchasing_status = 'Y') then

     debug_info := 'retest_po_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Retest_Vendors)'||debug_info);
     END IF;


     -- retest_po_vendors
     update po_purge_vendor_list pvl
     set double_check_flag = 'N'
     where pvl.double_check_flag = 'Y'
     and (exists   (select null
                    from po_headers_all ph
                     where ph.vendor_id = pvl.vendor_id)
          or
          exists    (select null
                     from po_rfq_vendors rfq
                     where rfq.vendor_id = pvl.vendor_id)
          or
          exists    (select null
                     from rcv_shipment_headers rcvsh
                     where rcvsh.vendor_id = pvl.vendor_id)
          or
          exists    (select null
                     from rcv_headers_interface rhi
                     where rhi.vendor_id = pvl.vendor_id)
          or
          exists    (select null
                     from rcv_transactions_interface rti
                     where rti.vendor_id = pvl.vendor_id));
  end if;

  if (g_chv_status = 'Y') then

     debug_info := 'retest_chv_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Retest_Vendors)'||debug_info);
     END IF;


     -- retest_chv_vendors

     update po_purge_vendor_list pvl
     set double_check_flag = 'N'
     where pvl.double_check_flag = 'Y'
     and   (exists   (select null
                from chv_schedule_headers csh
                where csh.vendor_id = pvl.vendor_id));

  end if;


  if (g_mrp_status = 'Y') then

     debug_info := 'retest_mrp_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Retest_Vendors)'||debug_info);
     END IF;

     -- retest_mrp_vendors

     --1796376, removed check for inactivity dates on sql below

     update po_purge_vendor_list pvl
     set double_check_flag = 'N'
     where pvl.double_check_flag = 'Y'
     and   (exists   (select null
                from  mrp_sr_source_org msso
                where msso.vendor_id = pvl.vendor_id));

  end if;


  if (g_edi_status = 'Y') then

     debug_info := 'retest_edi_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Retest_Vendors)'||debug_info);
     END IF;


     -- retest_edi_vendors

     update po_purge_vendor_list pvl
     set double_check_flag = 'N'
     where pvl.double_check_flag = 'Y'
     and   (exists   (select null
                from  ece_tp_details etd,
                      ap_supplier_sites_all pvs
                where etd.tp_header_id = pvs.tp_header_id
                and pvs.vendor_id = pvl.vendor_id
                and etd.last_update_date > g_activity_date));
--Bug 1781451 Update purge list to include only vendors with last_update_date
-- less than last activity date in concurrent request parameters
--              and etd.last_update_date <= g_activity_date));

  end if;


  COMMIT;

  debug_info := 'End Retest_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Vendors)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Vendors;



/*==========================================================================
  Function: Retest_Seeded_Chv_by_Org

 *==========================================================================*/

FUNCTION Retest_Seeded_Chv_by_Org(P_Calling_Sequence VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Seeded_Chv_by_Org<-'||P_calling_sequence;

  --

  debug_info := 'Starting Retest Schedules by Org';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Seeded_Chv_by_Org)'||debug_info);
  END IF;

  --

  update chv_purge_schedule_list cpsl
  set double_check_flag = 'N'
  where cpsl.double_check_flag = 'Y'
  and  not exists (select 'schedule not purgeable' from chv_schedule_items csi,
                             chv_schedule_headers csh
            where   csh.schedule_id = csi.schedule_id
            and     csh.last_update_date <= g_activity_date
            and     csi.organization_id = g_organization_id
            and     csi.schedule_item_id = cpsl.schedule_item_id);

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Seeded_Chv_by_Org;

/*==========================================================================
  Function: Retest_Seeded_Chv_by_CUM

 *==========================================================================*/

FUNCTION Retest_Seeded_Chv_by_Cum(P_Calling_Sequence VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Seeded_Chv_by_Cum<-'||P_calling_sequence;

  --

  debug_info := 'Starting Retest Schedules by CUM';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Seeded_Chv_by_CUM)'||debug_info);
  END IF;

  --

  update chv_purge_cum_list cpcl
  set double_check_flag = 'N'
  where cpcl.double_check_flag = 'Y'
  and not exists (select  null from chv_cum_periods ccp
            where   ccp.organization_id = g_organization_id
            and     NVL(ccp.cum_period_end_date, sysdate + 1) <= g_activity_date
            and     NVL(ccp.cum_period_end_date,sysdate + 1) < sysdate
            and     ccp.cum_period_id = cpcl.cum_period_id);

  debug_info := 'Eliminate Items in CUM';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Seeded_Chv_by_CUM)'||debug_info);
  END IF;

  --

  update chv_purge_schedule_list cpsl
  set double_check_flag = 'N'
  where cpsl.double_check_flag = 'Y'
  and not exists (select null from chv_schedule_items csi,
                             chv_schedule_headers csh,
			     chv_cum_periods ccp,
			     chv_purge_cum_list cpcl
            where   csh.schedule_id = csi.schedule_id
	    and     csh.schedule_horizon_start between ccp.cum_period_start_date
						   and ccp.cum_period_end_date
	    and     ccp.cum_period_id = cpcl.cum_period_id
            and     csi.organization_id = g_organization_id
            and     csi.schedule_item_id = cpsl.schedule_item_id);


  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Seeded_Chv_by_Cum;

/*==========================================================================
  Function: Retest_Chv_in_Cum

 *==========================================================================*/

FUNCTION Retest_Chv_in_Cum(P_Calling_Sequence VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Chv_in_Cum<-'||P_calling_sequence;

  --

  debug_info := 'Eliminate Schedules in CUM';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Chv_in_Cum)'||debug_info);
  END IF;

  --
  update chv_purge_schedule_list cpsl
  set double_check_flag = 'N'
  where cpsl.double_check_flag = 'Y'
  and exists   (select null
              from chv_cum_periods ccp,
                   chv_schedule_items csi,
                   chv_schedule_headers csh,
                   chv_org_options coo
              where ccp.organization_id  = g_organization_id
              and   sysdate between ccp.cum_period_start_date and
                                    NVL(ccp.cum_period_end_date,sysdate + 1)
              and  coo.organization_id = ccp.organization_id
              and  coo.enable_cum_flag = 'Y'
              and  csh.schedule_id = csi.schedule_id
              and  csh.schedule_horizon_start >= ccp.cum_period_start_date
              and  csi.schedule_item_id = cpsl.schedule_item_id);


  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
      Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Chv_in_Cum;

/*==========================================================================
  Function: Retest_Chv_in_Edi

 *==========================================================================*/

FUNCTION Retest_Chv_in_Edi(P_Calling_Sequence VARCHAR2) RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Retest_Chv_in_Edi<-'||P_calling_sequence;

  --

  debug_info := 'Eliminate Schedules in EDI';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Retest_Chv_in_edi)'||debug_info);
  END IF;

  --
  update chv_purge_schedule_list cpsl
  set double_check_flag = 'N'
  where cpsl.double_check_flag = 'Y'
  and exists  (select null
              from chv_schedule_items csi,
              ece_spso_items esi
              where csi.schedule_item_id = cpsl.schedule_item_id
              and csi.schedule_id = esi.schedule_id);


  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
      Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Retest_Chv_in_Edi;

/*==========================================================================
  Function: Count_Chv_Rows

 *==========================================================================*/
FUNCTION Count_Chv_Rows
        (chv_auth_rows    OUT NOCOPY NUMBER,
         chv_cum_adj_rows OUT NOCOPY NUMBER,
         chv_cum_rows     OUT NOCOPY NUMBER,
         chv_hor_rows     OUT NOCOPY NUMBER,
         chv_ord_rows     OUT NOCOPY NUMBER,
         chv_head_rows    OUT NOCOPY NUMBER,
         chv_item_rows    OUT NOCOPY NUMBER,
	 P_Calling_Sequence   VARCHAR2)
RETURN BOOLEAN IS

debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);


BEGIN
  -- Update the calling sequence
  --
     current_calling_sequence := 'Count_Chv_Rows<-'||P_calling_sequence;

  debug_info := 'Count Rows in tables affecting Supplier Scheduling';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --

  debug_info := 'chv_auth';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_auth_rows
  FROM   chv_authorizations;

  --

  debug_info := 'chv_cum_adj';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_cum_adj_rows
  FROM   chv_cum_adjustments;

  --

  debug_info := 'chv_cum';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_cum_rows
  FROM   chv_cum_periods;
  --

  debug_info := 'chv_hor';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  end iF;

  --
  SELECT count(*)
  INTO   chv_hor_rows
  FROM   chv_horizontal_schedules;
  --

  debug_info := 'chv_ord';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_ord_rows
  FROM   chv_item_orders;
  --

  debug_info := 'chv_head';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_head_rows
  FROM   chv_schedule_headers;
  --

  debug_info := 'chv_item';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Count_Chv_Rows)'||debug_info);
  END IF;

  --
  SELECT count(*)
  INTO   chv_item_rows
  FROM   chv_schedule_items
  WHERE  NVL(item_purge_status,'N') <> 'PURGED';

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
      Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Count_Chv_Rows;


/*==========================================================================
  Function: Record_Initial_Statistics

 *==========================================================================*/
FUNCTION Record_Initial_Statistics(fp_check_rows                IN NUMBER,
                                   fp_invoice_payment_rows      IN NUMBER,
                                   fp_invoice_rows              IN NUMBER,
                                   fp_po_header_rows            IN NUMBER,
                                   fp_receipt_line_rows         IN NUMBER,
                                   fp_req_header_rows           IN NUMBER,
                                   fp_vendor_rows               IN NUMBER,
                                   fp_po_asl_rows		IN NUMBER,
				   fp_po_asl_attr_rows	 	IN NUMBER,
				   fp_po_asl_doc_rows		IN NUMBER,
				   fp_chv_auth_rows		IN NUMBER,
				   fp_chv_cum_adj_rows	 	IN NUMBER,
				   fp_chv_cum_rows		IN NUMBER,
				   fp_chv_hor_rows		IN NUMBER,
				   fp_chv_ord_rows		IN NUMBER,
				   fp_chv_head_rows		IN NUMBER,
     				   fp_chv_item_rows		IN NUMBER,
				   fp_ae_line_rows		IN NUMBER,
                                   fp_ae_header_rows            IN NUMBER,
                                   fp_accounting_event_rows	IN NUMBER,
                                   fp_chrg_allocation_rows      IN NUMBER,
				   fp_payment_history_rows      IN NUMBER,
                                   fp_encumbrance_line_rows     IN NUMBER,
                                   fp_rcv_subledger_detail_rows IN NUMBER,
                                   fp_purge_name                IN VARCHAR2,
         			   p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);


BEGIN

  -- Update the calling sequence
  --
     current_calling_sequence := 'Record_Initial_Statistics<-'||P_calling_sequence;
  --
  debug_info := 'Starting Record_Initial_Statistics';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Record_Initial_Statistics)'||debug_info);
  END IF;


  UPDATE financials_purges
  SET
  ap_checks                = fp_check_rows,
  ap_invoice_payments      = fp_invoice_payment_rows,
  ap_invoices              = fp_invoice_rows,
  po_headers               = fp_po_header_rows ,
  po_receipts              = fp_receipt_line_rows,
  po_requisition_headers   = fp_req_header_rows,
  po_vendors               = fp_vendor_rows,
  po_approved_supplier_list = fp_po_asl_rows,
  po_asl_attributes 	   = fp_po_asl_attr_rows,
  po_asl_documents 	   = fp_po_asl_doc_rows,
  chv_authorizations 	   = fp_chv_auth_rows,
  chv_cum_adjustments 	   = fp_chv_cum_adj_rows,
  chv_cum_periods 	   = fp_chv_cum_rows,
  chv_horizontal_schedules = fp_chv_hor_rows,
  chv_item_orders	   = fp_chv_ord_rows,
  chv_schedule_headers 	   = fp_chv_head_rows,
  chv_schedule_items 	   = fp_chv_item_rows,
  ap_ae_lines              = fp_ae_line_rows,
  ap_ae_headers		   = fp_ae_header_rows,
  ap_accounting_events	   = fp_accounting_event_rows,
  ap_chrg_allocations      = fp_chrg_allocation_rows,
  ap_payment_history       = fp_payment_history_rows,
  ap_encumbrance_lines     = fp_encumbrance_line_rows,
  rcv_subledger_details    = fp_rcv_subledger_detail_rows
  WHERE purge_name 	   = fp_purge_name ;

  --
  debug_info := 'Starting Record_Initial_Statistics';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Record_Initial_Statistics)'||debug_info);
  END IF;

  --

   UPDATE ap_purge_invoice_list PL
   SET PL.double_check_flag = 'N'
   WHERE EXISTS (
               SELECT 'history not purgeable'
               FROM ap_invoice_payments aip
               ,    ap_payment_history aph
               WHERE aip.invoice_id = PL.invoice_id
               and aip.check_id = aph.check_id
               and aph.last_update_date > g_activity_date);

  --
  debug_info := 'End Record_Initial_Statistics';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Record_Initial_Statistics)'||debug_info);
  END IF;

  --
  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
   RETURN (FALSE);

END Record_Initial_Statistics;


/*==========================================================================
  Function: Confirm_Seeded_Data

 *==========================================================================*/
FUNCTION Confirm_Seeded_Data(P_Status            IN  VARCHAR2,
                             P_Category          IN  VARCHAR2,
                             P_Purge_Name        IN  VARCHAR2,
                             P_Activity_Date     IN  DATE,
                             P_Organization_ID   IN  NUMBER,
                             P_PA_Status         IN  VARCHAR2,
                             P_Purchasing_Status IN  VARCHAR2,
                             P_Payables_Status   IN  VARCHAR2,
                             P_Assets_Status     IN  VARCHAR2,
                             P_Chv_Status        IN  VARCHAR2,
                             P_EDI_Status        IN  VARCHAR2,
                             P_MRP_Status        IN  VARCHAR2,
                             P_Debug_Switch      IN  VARCHAR2,
                             p_calling_sequence  IN  VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

check_rows              	NUMBER;
invoice_payment_rows    	NUMBER;
invoice_rows            	NUMBER;
po_header_rows          	NUMBER;
receipt_line_rows       	NUMBER;
req_header_rows         	NUMBER;
vendor_rows              	NUMBER;
po_asl_rows		 	NUMBER;
po_asl_attr_rows	 	NUMBER;
po_asl_doc_rows		 	NUMBER;
chv_auth_rows		 	NUMBER;
chv_cum_adj_rows		NUMBER;
chv_cum_rows			NUMBER;
chv_hor_rows			NUMBER;
chv_ord_rows			NUMBER;
chv_head_rows		        NUMBER;
chv_item_rows			NUMBER;
ae_line_rows		 	NUMBER;
ae_header_rows		 	NUMBER;
accounting_event_rows		NUMBER;
chrg_allocation_rows            NUMBER;
payment_history_rows            NUMBER;
encumbrance_line_rows           NUMBER;
rcv_subledger_detail_rows       NUMBER;

l_po_return_status              VARCHAR2(1);
l_po_msg                        VARCHAR2(2000);
l_po_records_filtered           VARCHAR2(1);

l_status                        VARCHAR2(30);

BEGIN

  g_debug_switch := p_debug_switch;

  g_activity_date := P_Activity_Date;
  g_organization_id := P_Organization_ID;
  g_category := P_Category;
  g_pa_status := P_PA_Status;
  g_purchasing_Status := P_Purchasing_Status;
  g_payables_status := P_Payables_Status;
  g_assets_status := P_Assets_Status;
  g_chv_status := P_Chv_Status;
  g_edi_status := P_EDI_Status;
  g_mrp_status := P_MRP_Status;

  -- Update the calling sequence
  --
     current_calling_sequence := 'Confirm_Seeded_Data<-'||P_calling_sequence;
  --
  debug_info := 'Starting Confirm_Seeded_Data';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Confirm_Seeded_Data)'||debug_info);
  END IF;

  -- reset_row_counts
  check_rows            := 0;
  invoice_payment_rows  := 0;
  invoice_rows          := 0;
  po_header_rows        := 0;
  receipt_line_rows     := 0;
  req_header_rows       := 0;
  vendor_rows		:= 0;
  po_asl_rows		:= 0;
  po_asl_attr_rows	:= 0;
  po_asl_doc_rows	:= 0;
  chv_auth_rows		:= 0;
  chv_cum_adj_rows	:= 0;
  chv_cum_rows		:= 0;
  chv_hor_rows		:= 0;
  chv_ord_rows		:= 0;
  chv_head_rows		:= 0;
  chv_item_rows		:= 0;
  ae_line_rows          := 0;
  ae_header_rows        := 0;
  accounting_event_rows := 0;
  chrg_allocation_rows  := 0;
  payment_history_rows  := 0;
  encumbrance_line_rows := 0;
  rcv_subledger_detail_rows := 0;


  --
  debug_info := 'Re-validating candidates';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Confirm_Seeded_Data)'||debug_info);
  END IF;

  if (p_category = 'SIMPLE INVOICES') then

     --
     debug_info := '  Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_invoice_independents('Confirm_Seeded_Data') <> TRUE) then
        Print('retest_invoice_independents failed.');
        return(FALSE);
     end if;

     if (redo_dependent_inv_checks('Confirm_Seeded_Data') <> TRUE) then
        Print('redo_dependent_inv_checks failed.' );
        return(FALSE);
     end if;

     --
     debug_info := 'Computing initial table size statistics for Payables';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (count_ap_rows(check_rows,
                       invoice_payment_rows,
                       invoice_rows,
                       'Confirm_Seeded_Data') <> TRUE) then
        Print('count_ap_row failed.' );
        return(FALSE);
     end if;

      --
     debug_info := 'Computing initial table size statistics for Accounting';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (count_accounting_rows(ae_line_rows,
                               ae_header_rows,
                               accounting_event_rows,
                               chrg_allocation_rows,
                               payment_history_rows,
                               encumbrance_line_rows,
                               rcv_subledger_detail_rows,
                               'Confirm_Seeded_Data') <> TRUE) then
        Print('count_accounting_rows failed.' );
        return(FALSE);
     end if;


  ELSIF (p_category IN ('SIMPLE REQUISITIONS', 'SIMPLE POS')) THEN

     debug_info := ' Call PO Purge API';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     PO_AP_PURGE_GRP.confirm_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_last_activity_date => p_activity_date
     );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     PO_AP_PURGE_GRP.filter_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_status => 'REVALIDATING',
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_action => NULL,
        x_po_records_filtered => l_po_records_filtered
      );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     debug_info := 'Computing initial table size statistics for Purchasing';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => receipt_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

     IF (l_po_return_status <> 'S') THEN
        Print(l_po_msg);
        RETURN FALSE;
     END IF;

  elsif (p_category = 'MATCHED POS AND INVOICES') then

     --
     debug_info := '  Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_invoice_independents('Confirm_Seeded_Data') <> TRUE) then
        Print('retest_invoice_independents failed.' );
         return(FALSE);
     end if;

     if (redo_dependent_inv_checks('Confirm_Seeded_Data') <> TRUE) then
        Print('redo_dependent_inv_checks failed.');
        return(FALSE);
     end if;

     --
     debug_info := '  Purchase Orders';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     PO_AP_PURGE_GRP.confirm_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_last_activity_date => p_activity_date
     );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     PO_AP_PURGE_GRP.filter_records
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'F',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_status => 'REVALIDATING',
        p_purge_name => p_purge_name,
        p_purge_category => p_category,
        p_action => 'FILTER REF PO AND REQ',
        x_po_records_filtered => l_po_records_filtered
      );

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN FALSE;
     END IF;

     --
     debug_info := 'Re-matching purchase orders and invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (match_pos_to_invoices_ctrl(
                       P_Purge_Name,
                       'REVALIDATING',
                       'Confirm_Seeded_Data') <> TRUE) then
        Print('match_pos_to_invoices_ctrl failed.' );
        return(FALSE);
     end if;

     --
     debug_info := 'Computing initial table size statistics for Payables';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (count_ap_rows(check_rows,
                       invoice_payment_rows,
                       invoice_rows,
                       'Confirm_Seeded_Data') <> TRUE) then
        Print('count_ap_rows failed.' );
        return(FALSE);
     end if;

     --
     debug_info := 'Computing initial table size statistics for Purchasing';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => receipt_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

     IF (l_po_return_status <> 'S') THEN
        Print(l_po_msg);
        RETURN FALSE;
     END IF;

      --
     debug_info := 'Computing initial table size statistics for Accounting';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (count_accounting_rows(ae_line_rows,
                               ae_header_rows,
                               accounting_event_rows,
                               chrg_allocation_rows,
                               payment_history_rows,
                               encumbrance_line_rows,
                               rcv_subledger_detail_rows,
                               'Confirm_Seeded_Data') <> TRUE) then
        Print('count_accounting_rows failed.' );
        return(FALSE);
     end if;


  elsif (p_category = 'VENDORS') then
     --
     debug_info := '  Vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_seeded_vendors('Confirm_Seeded_Data') <> TRUE) then
        Print(' retest_seeded_vendors failed.');
        return(FALSE);
     end if;

     --
     debug_info := 'retest_vendors';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_vendors('Confirm_Seeded_Data') <> TRUE) then
        Print('retest_vendors failed.' );
        return(FALSE);
     end if;

     --
     debug_info := 'Computing initial table size statistics for Purchasing';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => receipt_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

     IF (l_po_return_status <> 'S') THEN
        Print(l_po_msg);
        RETURN FALSE;
     END IF;


  elsif (p_category = 'SCHEDULES BY ORGANIZATION') then
     --
     debug_info := '  Schedules';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_seeded_chv_by_org('Confirm_Seeded_Data') <> TRUE) then
        Print('retest_seeded_chv_by_org failed.');
        return(FALSE);
     end if;

     --
     debug_info := 'Excluding schedules in cum';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_chv_in_cum('Confirm_Seeded_Data') <> TRUE) then
        Print('Schedules.retest_chv_in_cum failed.' );
        return(FALSE);
     end if;

     --

     debug_info := 'Excluding schedules in edi';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_chv_in_edi('Confirm_Seeded_Data') <> TRUE) then
        Print('Schedules.retest_chv_in_edi failed.' );
        return(FALSE);
     end if;

     --

     debug_info := 'Computing initial table size statistics for Supplier Scheduling';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     -- count_chv_rows
     if (count_chv_rows(chv_auth_rows,
                        chv_cum_adj_rows,
                        chv_cum_rows,
                        chv_hor_rows,
                        chv_ord_rows,
                        chv_head_rows,
                        chv_item_rows,
		        'Delete Seeded Data') <> TRUE) then
          Print('purge_schedules_by_cum failed!');
          RETURN(FALSE);
     end if;

  elsif (p_category = 'SCHEDULES BY CUM PERIODS') then

     --

     debug_info := '  Schedules in CUM Periods';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

     if (retest_seeded_chv_by_cum('Confirm_Seeded_Data') <> TRUE) then
        Print(' Schedules.retest_seeded_chv_by_cum failed.');
        return(FALSE);
     end if;

     --

     debug_info := 'Computing initial table size statistics for Supplier Scheduling';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Confirm_Seeded_Data)'||debug_info);
     END IF;

    -- count_chv_rows
    if (count_chv_rows(chv_auth_rows,
                       chv_cum_adj_rows,
                       chv_cum_rows,
                       chv_hor_rows,
                       chv_ord_rows,
                       chv_head_rows,
                       chv_item_rows,
	  	      'Delete Seeded Data') <> TRUE) then
         Print('purge_schedules_by_cum failed!');
         RETURN(FALSE);
    end if;


  else
     --
     debug_info := 'An invalid purge category was entered';
     Print('(Confirm_Seeded_Data) '||debug_info);
     Print('Valid categories are : SIMPLE INVOICES, SIMPLE REQUISITIONS,');
     Print('SIMPLE POS, MATCHED POS AND INVOICES,VENDORS,');
     Print('SCHEDULES BY ORGANIZATION and SCHEDULES BY CUM PERIODS');

     l_status := 'COMPLETED-ABORTED';

     if (Set_Purge_Status(l_status,
                          p_purge_name,
                          p_debug_switch,
                          'Confirm_Seeded_Data') <> TRUE) then
        Print(' Set_Purge_Status failed.');
        return(FALSE);
     end if;

     RETURN(TRUE);
  end if;

  --
  debug_info := 'record_initial_statistics';

  Print('(Confirm_Seeded_Data) '||debug_info);


  if (record_initial_statistics(check_rows,
                                invoice_payment_rows,
                                invoice_rows,
                                po_header_rows,
                                receipt_line_rows,
                                req_header_rows,
                                vendor_rows,
                                po_asl_rows,
	          		po_asl_attr_rows,
	     			po_asl_doc_rows,
				chv_auth_rows,
	     		     	chv_cum_adj_rows,
				chv_cum_rows,
				chv_hor_rows,
				chv_ord_rows,
				chv_head_rows,
     	 			chv_item_rows,
				ae_line_rows,
				ae_header_rows,
				accounting_event_rows,
                                chrg_allocation_rows,
                                payment_history_rows,
                                encumbrance_line_rows,
                                rcv_subledger_detail_rows,
                                p_purge_name,
                                'Confirm_Seeded_Data') <> TRUE) then
        Print('Confirm_Purge.record_initial_statistics failed.' );
        return(FALSE);
  end if;

  l_status := 'DELETING';

  if (Set_Purge_Status(l_status,
                       p_purge_name,
                       p_debug_switch,
                       'Confirm_Seeded_Data') <> TRUE) then
        Print('Set_Purge_Status failed.');
        return(FALSE);
  end if;

  RETURN (TRUE);

RETURN NULL; EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     Print(SQLERRM);
   END IF;
     RETURN (FALSE);

END Confirm_Seeded_Data;


/*==========================================================================
  Function: Overflow

 *==========================================================================*/
FUNCTION Overflow
         (Overflow_Exist      OUT NOCOPY VARCHAR2,
          range_low           IN  NUMBER,
          range_high          IN  NUMBER,
          P_Calling_Sequence  IN  VARCHAR2)
RETURN BOOLEAN IS

CURSOR overflow_select is
SELECT C.check_stock_id,C.check_number
FROM ap_invoice_payments P, ap_purge_invoice_list PL,
     ap_checks C
WHERE P.invoice_id = PL.invoice_id
AND P.check_id = C.check_id
AND PL.double_check_flag = 'Y'
AND PL.invoice_id BETWEEN range_low AND range_high;

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);
overflow_check_stock_id         NUMBER;
to_be_deleted_check_number      NUMBER;
overflow_check_number           NUMBER;

BEGIN


  -- Update the calling sequence
  --

  current_calling_sequence := 'Overflow<-'||P_Calling_Sequence;
  --
  debug_info := 'Starting Overflow';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Overflow)'||debug_info);
  END IF;

  OPEN overflow_select;

  LOOP

    debug_info := 'Fetch overflow_select  Cursor';
    IF g_debug_switch in ('y','Y') THEN
       Print('(Overflow)'||debug_info);
    END IF;

    FETCH overflow_select into overflow_check_stock_id,
                               to_be_deleted_check_number;
    --
    EXIT WHEN overflow_select%NOTFOUND OR overflow_select%NOTFOUND IS NULL;

    if (g_debug_switch in ('y', 'Y')) then
        Print('------------->overflow_check_stock_id = '
                   ||to_char(overflow_check_stock_id)
                   ||' to_be_deleted_check_number = '
                   ||to_char(to_be_deleted_check_number));
    end if;

    overflow_check_number := to_be_deleted_check_number - 1;

    -- Need to have a Begin - End construct so that we still enter the loop and
    -- exit gracefully, if the select does not return any rows.

    Begin
      SELECT 'exist'
      INTO  overflow_exist
      FROM  ap_checks C
      WHERE C.check_stock_id = overflow_check_stock_id
      AND   C.check_number = overflow_check_number
      AND   C.status_lookup_code = 'OVERFLOW';
    Exception
       WHEN NO_DATA_FOUND THEN
       overflow_exist :='does not exist';
         Null;
    End;


    LOOP

      if (overflow_exist = 'exist') then

          debug_info := 'Delete_Overflow from ap_checks';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Overflow)'||debug_info);
          END IF;

          -- delete_overflow

          DELETE FROM ap_checks C
          WHERE C.check_stock_id     = overflow_check_stock_id
          AND   C.check_number       = overflow_check_number
          AND   C.status_lookup_code = 'OVERFLOW';

          overflow_check_number := overflow_check_number - 1;

          debug_info := 'Overflow_Exists ';
          IF g_debug_switch in ('y','Y') THEN
             Print('(Overflow)'||debug_info);
          END IF;

          -- Need to have a Begin - End construct so that we exit gracefully
          -- once we are done deleting all the overflow checks i.e when
          -- the select does not return any rows.

          Begin
            SELECT 'exist'
            INTO  overflow_exist
            FROM  ap_checks C
            WHERE C.check_stock_id = overflow_check_stock_id
            AND   C.check_number = overflow_check_number
            AND   C.status_lookup_code = 'OVERFLOW';
          Exception
            When NO_DATA_FOUND then
                overflow_exist := 'does not exist';
             Null;
          End;
      else
          EXIT;
      end if;
    END LOOP;
  END LOOP;

  CLOSE overflow_select;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Overflow;


/*==========================================================================
  Function: Setup_Spoil

 *==========================================================================*/
FUNCTION Setup_Spoil
         (P_Calling_Sequence   IN  VARCHAR2)
RETURN BOOLEAN IS

CURSOR setup_spoil_select is
SELECT distinct C.checkrun_name
FROM   ap_checks C, ap_invoice_selection_criteria D
WHERE  D.LAST_UPDATE_DATE <= g_activity_date
AND  C.checkrun_name NOT IN
     (SELECT distinct b.checkrun_name
      FROM   ap_checks a,
             ap_invoice_selection_criteria b
      WHERE  a.checkrun_name = b.checkrun_name
      AND    a.status_lookup_code not in
             ('SET UP', 'SPOILED'))
AND  C.checkrun_name = D.checkrun_name
AND  C.last_update_date <= g_activity_date;


debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);
selected_checkrun               ap_invoice_selection_criteria.checkrun_name%TYPE;

BEGIN

  -- Update the calling sequence
  --

  current_calling_sequence := 'Setup_Spoil<-'||P_Calling_Sequence;

  --

  debug_info := 'Starting Setup_Spoil';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Setup_Spoil)'||debug_info);
  END IF;

  OPEN setup_spoil_select;

  LOOP

    debug_info := 'Fetch setup_spoil_select  Cursor';
    IF g_debug_switch in ('y','Y') THEN
       Print('(Setup_Spoil)'||debug_info);
    END IF;

    FETCH setup_spoil_select into selected_checkrun;
    --
    EXIT WHEN setup_spoil_select%NOTFOUND OR setup_spoil_select%NOTFOUND IS NULL;

    IF g_debug_switch in ('y','Y') THEN
       Print('(Setup_Spoil)'||debug_info);
    END IF;

    -- delete_setup_spoil

    debug_info := 'delete_setup_spoil';
    IF g_debug_switch in ('y','Y') THEN
       Print('(Setup_Spoil)'||debug_info);
    END IF;

    DELETE FROM ap_checks C
    WHERE  C.checkrun_name = selected_checkrun
    AND    C.status_lookup_code in ('SET UP','SPOILED')
    AND    C.last_update_date <= g_activity_date;

    -- delete_invoice_selection

    debug_info := 'delete_invoice_selection';
    IF g_debug_switch in ('y','Y') THEN
       Print('(Setup_Spoil)'||debug_info);
    END IF;

    DELETE FROM ap_invoice_selection_criteria C
    WHERE  C.checkrun_name = selected_checkrun
    AND    C.last_update_date <= g_activity_date;

  END LOOP;

  debug_info := 'End Setup_Spoil';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Setup_Spoil)'||debug_info);
  END IF;

  RETURN (TRUE);

  RETURN NULL;

EXCEPTION

    WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Setup_Spoil;


/*==========================================================================
  Function: Delete_AP_Tables

 *==========================================================================*/
FUNCTION Delete_AP_Tables
	 (P_Calling_Sequence   IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info                   	VARCHAR2(200);
current_calling_sequence     	VARCHAR2(2000);
range_high		     	NUMBER;
range_low		     	NUMBER;
range_size		     	NUMBER;
inv_lower_limit		    	NUMBER;
inv_upper_limit		     	NUMBER;
overflow_exist                  VARCHAR2(200);
overflow_check_stock_id		NUMBER;
to_be_deleted_check_number	NUMBER;
l_key_value_list1               gl_ca_utility_pkg.r_key_value_arr;
l_key_value_list2               gl_ca_utility_pkg.r_key_value_arr;



l_count number := 0;

 CURSOR range (low_inv_id IN NUMBER) IS
    SELECT invoice_id
    FROM ap_purge_invoice_list
    WHERE double_check_flag = 'Y'
    and invoice_id > low_inv_id
    ORDER BY invoice_id asc;

 CURSOR ap_invoice_cur (low_inv_id IN NUMBER,
                        high_inv_id IN NUMBER) IS
        SELECT PL.invoice_id
        FROM ap_purge_invoice_list PL
        WHERE PL.double_check_flag = 'Y'
        AND PL.invoice_id BETWEEN low_inv_id AND high_inv_id;

 l_invoice_id           ap_invoices.invoice_id%TYPE;
 l_invoice_dist_id      ap_invoice_distributions.invoice_distribution_id%TYPE;
 l_check_id             ap_checks.check_id%TYPE;
 l_payment_history_id   ap_payment_history.payment_history_id%TYPE;
 l_invoice_payment_id   ap_invoice_payments.invoice_payment_id%TYPE;

BEGIN

  -- Update the calling sequence
  --

  current_calling_sequence := 'Delete_AP_Tables<-'||P_Calling_Sequence;

  debug_info := 'Starting Delete_AP_Tables';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Delete_AP_Tables)'||debug_info);
  END IF;

  --
  range_high := 0;
  range_size := g_range_size;

  -- get_ap_range

  select nvl(min(invoice_id),-1)
  ,      nvl(max(invoice_id),-1)
  into range_low, range_high
  from ap_purge_invoice_list
  where double_check_flag = 'Y';

 --Bug2382623 Changed the paramter to range_low
 OPEN  range(range_low);
 WHILE l_count < g_range_size
   LOOP
     FETCH range INTO range_high;
     EXIT WHEN range%NOTFOUND;
     l_count := l_count + 1;
   END LOOP;
   CLOSE RANGE;

  LOOP

     debug_info := 'Deleting one subgroup of Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
        Print('ap_doc_sequence_audit, Checks');
     END IF;

/*  Bug 5052709 - removal of obsolete SQL
     -- Move the deletion of ap_chrg_allocations from purge_pos to here.
     -- Since this is now in the loop with range_low and range_high defined,
     -- purge this tables in multiple runs, with each run bounded by range_low
     -- and range_high of invoice_id

     delete from ap_chrg_allocations aca
     where exists (
		select 'allocations'
		from ap_invoice_distributions aid
		,    ap_purge_invoice_list    pil
		where aca.item_dist_id      = aid.invoice_distribution_id
		and   pil.invoice_id        = aid.invoice_id
              and   pil.invoice_id BETWEEN range_low and range_high
		and   pil.double_check_flag = 'Y');
*/
     -- delete_check_sequence_audit

     /* bug3068811 : Changed from EXISTS to IN for performance */
     DELETE FROM ap_doc_sequence_audit AUD
     WHERE (AUD.doc_sequence_id , AUD.doc_sequence_value)
            IN (SELECT C.doc_sequence_id , C.doc_sequence_value
                  FROM ap_purge_invoice_list PL,
                       ap_checks C,
                       ap_invoice_payments IP
                  WHERE PL.double_check_flag = 'Y'
                  AND   PL.invoice_id BETWEEN range_low AND range_high
                  AND   PL.invoice_id = IP.invoice_id
                  AND   IP.check_id = C.check_id ) ;

     -- overflow

     debug_info := 'ap_checks';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;

     if (Overflow(Overflow_Exist,
                  range_low,
                  range_high,
            'delete_ap_tables') <> TRUE) then
         Print( 'Overflow failed!');
         RETURN(FALSE);
     end if;

     debug_info := 'delete_checks';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_checks
     -- bug 5052764 - go to base table ap_checks_all to remove FTS
     DELETE FROM ap_checks_all C
     WHERE C.check_id IN (
	   SELECT P.check_id
	   FROM ap_invoice_payments P, ap_purge_invoice_list PL
	   WHERE P.invoice_id = PL.invoice_id
	   AND PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);

     debug_info := 'setup_spoil';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- setup_spoil

     if (Setup_Spoil('delete_ap_tables') <> TRUE) then
         Print('Setup_Spoil failed!');
         RETURN(FALSE);
     end if;

     debug_info := 'ap_payment_history';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     DELETE FROM ap_payment_history aph
     WHERE EXISTS (
	SELECT 'history purgeable'
	FROM ap_invoice_payments aip
	,    ap_purge_invoice_list PL
	WHERE aip.invoice_id = PL.invoice_id
	and aip.check_id     = aph.check_id
	and PL.double_check_flag = 'Y');

     debug_info := 'ap_invoice_payments';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_invoice_payments

     DELETE FROM ap_invoice_payments
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);


     debug_info := 'ap_payment_schedules';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_payment_schedules

     DELETE FROM ap_payment_schedules
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);


     debug_info := 'ap_trial_balance';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_trial_balance

     DELETE FROM ap_trial_balance
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);

     debug_info := 'ap_holds';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_holds

     DELETE FROM ap_holds
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);

     debug_info := 'ap_inv_aprvl_hist';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete approval history

     DELETE FROM ap_inv_aprvl_hist
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);


     debug_info := 'ap_invoice_distributions';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     DELETE FROM ap_invoice_distributions
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);

     debug_info := 'ap_doc_sequence_audit, Invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;

     -- delete_inv_seq_audit

     /* bug3284915 : Changed from EXISTS to IN for performance */
     DELETE FROM ap_doc_sequence_audit AUD
     WHERE (AUD.doc_sequence_id , AUD.doc_sequence_value)
            IN (SELECT I.doc_sequence_id , I.doc_sequence_value
                   FROM ap_purge_invoice_list PL,
                        ap_invoices I
                   WHERE PL.double_check_flag = 'Y'
                   AND   PL.invoice_id BETWEEN range_low AND range_high
                   AND   PL.invoice_id = I.invoice_id);

     OPEN ap_invoice_cur(range_low, range_high);
     LOOP

     FETCH ap_invoice_cur
     INTO l_invoice_id;
     EXIT WHEN ap_invoice_cur%NOTFOUND;

	--Bug 2840203 DBI logging
	--We are only logging the invoice deletion, as the summary code knows to
	--delete all related transactions: dists, holds, payment shedules, payments
        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'D',
               p_key_value1 => l_invoice_id,
                p_calling_sequence => current_calling_sequence);

     END LOOP;
     CLOSE ap_invoice_cur;

     debug_info := 'ap_invoices';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Delete_AP_Tables)'||debug_info);
     END IF;


     -- delete_invoices

     DELETE FROM ap_invoices
     WHERE invoice_id IN (
	   SELECT PL.invoice_id
	   FROM ap_purge_invoice_list PL
	   WHERE PL.double_check_flag = 'Y'
	   AND PL.invoice_id BETWEEN range_low AND range_high);


     COMMIT;

     l_count :=0;

     range_low := range_high +1;

     OPEN  range(range_low);     --Bug2711759
     WHILE l_count < g_range_size
     LOOP
       FETCH range INTO range_high;
       EXIT WHEN range%NOTFOUND;
       l_count := l_count + 1;
     END LOOP;
     CLOSE RANGE;

     if range_low > range_high then
	EXIT;
     end if;

  END LOOP;

  debug_info := 'deleting from ap_batches';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Delete_AP_Tables)'||debug_info);
  END IF;


  -- delete_batches

  DELETE FROM ap_batches B
  WHERE B.last_update_date <= g_activity_date
  AND NOT EXISTS (
	  SELECT null
	  FROM ap_invoices I
	  WHERE I.batch_id = B.batch_id);

  COMMIT;

  debug_info := 'Completed deleteing from Oracle Payables';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Delete_AP_Tables)'||debug_info);
  END IF;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Delete_AP_Tables;


/*==========================================================================
  Function: PURGE_ACCOUNTING

 *==========================================================================*/
FUNCTION PURGE_ACCOUNTING

    (P_Calling_Sequence   IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info                   	VARCHAR2(200);
current_calling_sequence     	VARCHAR2(2000);
range_high		     	NUMBER;
range_low		     	NUMBER;
range_size		     	NUMBER;
inv_lower_limit		    	NUMBER;
inv_upper_limit		     	NUMBER;
overflow_exist                  VARCHAR2(200);
overflow_check_stock_id		NUMBER;
to_be_deleted_check_number	NUMBER;


l_count number := 0;

 CURSOR range (low_inv_id IN NUMBER) IS
    SELECT invoice_id
    FROM ap_purge_invoice_list
    WHERE double_check_flag = 'Y'
    and invoice_id > low_inv_id
    ORDER BY invoice_id asc;

BEGIN

  range_high := 0;
  range_size := g_range_size;

  -- get_ap_range

  SELECT nvl(min(invoice_id),-1)
  ,      nvl(max(invoice_id),-1)
  into range_low, range_high
  FROM   ap_purge_invoice_list
  WHERE  double_check_flag = 'Y';

     OPEN  range(range_low);   --Bug2711759
 WHILE l_count < g_range_size
    LOOP
       FETCH range INTO range_high;
      EXIT WHEN range%NOTFOUND;
      l_count := l_count + 1;
    END LOOP;
    CLOSE RANGE;


 LOOP

  -- Update calling sequence

  current_calling_sequence := 'Purge Accounting<-'||P_Calling_Sequence;

  --

  debug_info := 'Starting Purge Accounting';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Accounting)'||debug_info);
  END IF;

  -- Bug 2463233
  -- Code Added by MSWAMINA
  -- Added logic to purge the ap_liability_balance
  --
  debug_info := 'ap_liability_balance';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Accounting)'||debug_info);
  END IF;

  DELETE   FROM   ap_liability_balance alb
  WHERE  EXISTS   (
         SELECT   'records exist'
           FROM   ap_purge_invoice_list   pil
	  WHERE   alb.invoice_id          = pil.invoice_id
            AND   pil.double_check_flag   = 'Y'
            AND   pil.invoice_id BETWEEN  range_low
                                     AND  range_high)
  AND             journal_sequence_id IS NULL;


-- Bug 4588031 - Removing code as AP accoutning tables will not be used in R12
/*
 -- Wrote the below 2 delete statements as a fix for bug 2866997
 DELETE FROM ap_ae_lines ael
  WHERE ael.ae_header_id in
      ( SELECT aeh.ae_header_id
          FROM ap_ae_headers          aeh
              ,ap_accounting_events   aae
              ,ap_purge_invoice_list  pil
          WHERE aae.source_id              = pil.invoice_id
           and aae.source_table            = 'AP_INVOICES'
           and aae.accounting_event_id     = aeh.accounting_event_id
           and pil.double_check_flag       = 'Y'
           and pil.invoice_id BETWEEN range_low AND range_high) ;

 DELETE FROM ap_ae_lines ael
  WHERE ael.ae_header_id in
        ( SELECT aeh.ae_header_id
            FROM ap_ae_headers        aeh  -- bug 2153117 added
              ,ap_accounting_events   aae
              ,ap_invoice_payments    aip
              ,ap_purge_invoice_list  pil
        WHERE aae.source_id              = aip.check_id
              and aae.source_table        = 'AP_CHECKS'
              and pil.double_check_flag  = 'Y'
              and aae.accounting_event_id = aeh.accounting_event_id
              and aip.invoice_id          = pil.invoice_id
              and pil.invoice_id BETWEEN range_low AND range_high);

  debug_info := 'ap_ae_headers';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Accounting)'||debug_info);
  END IF;


  DELETE FROM ap_ae_headers aeh
  WHERE aeh.accounting_event_id IN
      ( SELECT  aae.accounting_event_id
	FROM  ap_accounting_events     aae
        ,     ap_purge_invoice_list    pil
	WHERE aae.source_id           = pil.invoice_id
	and   aae.source_table        = 'AP_INVOICES'
	and   pil.double_check_flag   = 'Y'
        -- Commented the below line as a fix for bug 2880690
        -- and   aae.accounting_event_id = aeh.accounting_event_id
        and   pil.invoice_id BETWEEN range_low AND range_high
       ) ;


  DELETE FROM ap_ae_headers aeh
  WHERE  aeh.accounting_event_id in
      ( SELECT aae.accounting_event_id
	FROM  ap_accounting_events   aae
        ,     ap_invoice_payments    aip
 	,     ap_purge_invoice_list  pil
	-- bug2153117 removed
        -- ,     ap_ae_headers          aeh
	WHERE aae.source_id           = aip.check_id
	and   aae.source_table        = 'AP_CHECKS'
	and   pil.double_check_flag   = 'Y'
        -- Commented the below line as a fix for bug 2880690
        -- and   aae.accounting_event_id = aeh.accounting_event_id
 	and   aip.invoice_id          = pil.invoice_id
        and   pil.invoice_id BETWEEN range_low AND range_high) ;

*/ --Bug 4588031

  debug_info := 'ap_encumbrance_lines';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Accounting)'||debug_info);
  END IF;

  DELETE FROM ap_encumbrance_lines aen
  WHERE EXISTS (
	SELECT 'dist'
	FROM  ap_purge_invoice_list    pil
	,     ap_invoice_distributions aid
	WHERE aen.invoice_distribution_id  = aid.invoice_distribution_id
	and   aid.invoice_id               = pil.invoice_id
        and   pil.double_check_flag        = 'Y'
        and   pil.invoice_id BETWEEN range_low AND range_high);


 -- Bug 4588031 - Removing code as AP accounting tables will not be used in R12
/*  -- delete_ap_accounting_events
    -- Fix for bug 2545172 , commented above delete statement and wrote
    -- below 3 delete statement

  DELETE FROM AP_ACCOUNTING_EVENTS AAE
  WHERE aae.source_id in (SELECT PIL.INVOICE_ID
                            FROM AP_PURGE_INVOICE_LIST PIL
                          WHERE  PIL.DOUBLE_CHECK_FLAG = 'Y'
                          AND PIL.INVOICE_ID BETWEEN range_low AND range_high )
        AND AAE.SOURCE_TABLE = 'AP_INVOICES'
        ;

  DELETE FROM AP_ACCOUNTING_EVENTS AAE  WHERE
            aae.source_id in ( SELECT APC.CHECK_ID
                                FROM AP_PURGE_INVOICE_LIST PIL,
                                      AP_CHECKS APC,
                                      AP_INVOICE_PAYMENTS AIP
                                WHERE PIL.DOUBLE_CHECK_FLAG = 'Y'
                                      AND APC.CHECK_ID = AIP.CHECK_ID
                                      AND AIP.INVOICE_ID = PIL.INVOICE_ID
                                      AND PIL.INVOICE_ID BETWEEN range_low
                                          AND range_high )
            AND AAE.SOURCE_TABLE = 'AP_CHECKS' ;


  DELETE FROM AP_ACCOUNTING_EVENTS AAE  WHERE
            AAE.source_id IN ( SELECT APH.CHECK_ID
                               FROM AP_PURGE_INVOICE_LIST PIL,
                                    AP_INVOICE_PAYMENTS AIP,
                                    AP_PAYMENT_HISTORY APH
                              WHERE PIL.DOUBLE_CHECK_FLAG = 'Y'
                                    AND APH.CHECK_ID = AIP.CHECK_ID
                                    AND AIP.INVOICE_ID = PIL.INVOICE_ID
                                    AND PIL.INVOICE_ID BETWEEN range_low
                                        AND range_high )
            and AAE.SOURCE_TABLE = 'AP_PAYMENT_HISTORY'  ;
*/--Bug 4588031

  COMMIT;

     l_count :=0;

     range_low := range_high +1;

       OPEN  range(range_low);  --Bug2711759
     WHILE l_count < g_range_size
     LOOP
       FETCH range INTO range_high;
       EXIT WHEN range%NOTFOUND;
       l_count := l_count + 1;
     END LOOP;
       CLOSE RANGE;

     if range_low > range_high then
	EXIT;
     end if;

 END LOOP;


 RETURN NULL; EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);


END;


/*==========================================================================
  Function: Purge_Schedules_by_Cum

 *==========================================================================*/
FUNCTION Purge_Schedules_by_Cum
         (P_Calling_Sequence     IN   VARCHAR2)
RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);
chv_lower_limit                 NUMBER;
chv_upper_limit                 NUMBER;
range_high			NUMBER;
range_low			NUMBER;
range_size			NUMBER;

l_count number := 0;

 CURSOR range (low_chv_id IN NUMBER) IS
    SELECT schedule_item_id
    FROM chv_purge_schedule_list
    WHERE double_check_flag = 'Y'
    and schedule_item_id > low_chv_id
    ORDER BY schedule_item_id asc;


BEGIN

   --  Update the calling sequence
   --

   current_calling_sequence := 'Purge_Schedules_by_Cum<-'||P_Calling_Sequence;

   --
   debug_info := 'Starting Purge_Schedules_by_Cum';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   range_size := g_range_size;


   range_high := 0;

   debug_info := 'get_chv_range';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- get_chv_range

  select nvl(min(schedule_item_id),-1)
  ,      nvl(max(schedule_item_id),-1)
  into range_low, range_high
  from chv_purge_schedule_list
  where double_check_flag = 'Y';


  OPEN  range(range_low);  --Bug2711759
  WHILE l_count < g_range_size
    LOOP
      FETCH range INTO range_high;
      EXIT WHEN range%NOTFOUND;
      l_count := l_count + 1;
   END LOOP;
   CLOSE RANGE;


 -----new code ends-----------
   LOOP
      debug_info := 'Updating a subgroup of Supplier Schedule Items';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Cum)'||debug_info);
      END IF;

      -- Update chv_schedule_items

      update chv_schedule_items csi
      set csi.item_purge_status = 'PURGED'
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = csi.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

      debug_info := 'chv_item_orders';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Cum)'||debug_info);
      END IF;

      -- delete_chv_item_orders

      delete from chv_item_orders cio
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = cio.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

      debug_info := 'po_lines';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Cum)'||debug_info);
      END IF;

      -- delete_chv_horizontal_schedules

      delete from chv_horizontal_Schedules chs
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = chs.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

     debug_info := 'chv_authorizations';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Purge_Schedules_by_Cum)'||debug_info);
     END IF;

     -- delete_chv_authorizations

     delete from chv_authorizations ca
     where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = ca.reference_id
           and   ca.reference_type = 'SCHEDULE_ITEMS'
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

     COMMIT;

     l_count :=0;

     range_low := range_high +1;

       OPEN  range(range_low);       --Bug2711759
     WHILE l_count < g_range_size
     LOOP
       FETCH range INTO range_high;
       EXIT WHEN range%NOTFOUND;
       l_count := l_count + 1;
     END LOOP;
       CLOSE RANGE;

    if range_low > range_high then
        EXIT;
    end if;

   END LOOP;

   debug_info := 'chv_auth_cum_periods';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- delete_chv_authorizations

   delete from chv_authorizations ca
   where exists
        (select null
         from  chv_purge_cum_list cpcl
         where cpcl.cum_period_id = ca.reference_id
         and   cpcl.double_check_flag = 'Y'
	 and   ca.reference_type = 'CUM_PERIODS');

   debug_info := 'chv_cum_adjustments';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- delete_chv_cum_adjustments

   delete from chv_cum_adjustments cca
   where exists
        (select null
         from  chv_purge_cum_list cpcl
         where cpcl.cum_period_id = cca.cum_period_id
         and   cpcl.double_check_flag = 'Y');

   debug_info := 'chv_cum_periods';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- delete_chv_cum_periods

   delete from chv_cum_periods ccp
   where exists
        (select null
         from  chv_purge_cum_list cpcl
         where cpcl.cum_period_id = ccp.cum_period_id
         and   cpcl.double_check_flag = 'Y');

   debug_info := 'chv_schedule_items';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- delete_chv_schedule_items

/* bug2067536 Performance Bug
*/
   delete from   chv_schedule_items csi
   where not exists (select null
                       from chv_schedule_items cs
                      where csi.schedule_id = cs.schedule_id
                        and nvl(cs.item_purge_status,'ACTIVE') <> 'PURGED');

   debug_info := 'chv_schedule_headers';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;

   -- delete_chv_schedule_headers

/* bug2067536 Performance Bug
*/
   delete from chv_schedule_headers csh
   where not exists (select null
                       from chv_schedule_items csi
                      where csh.schedule_id = csi.schedule_id );

   COMMIT;

   debug_info := 'End Purge_Schedules_by_Org';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Cum)'||debug_info);
   END IF;
   RETURN (TRUE);

RETURN NULL; EXCEPTION
    WHEN OTHERS THEN
     IF (SQLCODE < 0 ) THEN
         Print(SQLERRM);
     END IF;
     RETURN (FALSE);
END Purge_Schedules_by_Cum;


/*==========================================================================
  Function: Purge_Schedules_by_Org

 *==========================================================================*/
FUNCTION Purge_Schedules_by_Org
         (P_Calling_Sequence     IN   VARCHAR2)
RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);
chv_lower_limit                  NUMBER;
chv_upper_limit                  NUMBER;
range_high			NUMBER;
range_low			NUMBER;
range_size			NUMBER;

l_count number := 0;

 CURSOR range (low_chv_id IN NUMBER) IS
    SELECT schedule_item_id
    FROM chv_purge_schedule_list
    WHERE double_check_flag = 'Y'
    and schedule_item_id > low_chv_id
    ORDER BY schedule_item_id asc;


BEGIN

   --  Update the calling sequence
   --

   current_calling_sequence := 'Purge_Schedules_by_Org<-'||P_Calling_Sequence;

   --
   debug_info := 'Starting Purge_Schedules_by_Org';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Org)'||debug_info);
   END IF;

   range_size := g_range_size;


   range_high := 0;

   debug_info := 'get_chv_range';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Org)'||debug_info);
   END IF;

   -- get_chv_range

  select nvl(min(schedule_item_id),-1)
  ,      nvl(max(schedule_item_id),-1)
  into range_low, range_high
  from chv_purge_schedule_list
  where double_check_flag = 'Y';

       OPEN  range(range_low);  --Bug2711759
   WHILE l_count < g_range_size
     LOOP
       FETCH range INTO range_high;
       EXIT WHEN range%NOTFOUND;
       l_count := l_count + 1;
     END LOOP;
       CLOSE RANGE;

   LOOP
      debug_info := 'Updating a subgroup of Supplier Schedule Items';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Org)'||debug_info);
      END IF;

      -- Update chv_schedule_items

      update chv_schedule_items csi
      set csi.item_purge_status = 'PURGED'
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = csi.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

      debug_info := 'chv_item_orders';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Org)'||debug_info);
      END IF;

      -- delete_chv_item_orders

      delete from chv_item_orders cio
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = cio.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

      debug_info := 'po_lines';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Schedules_by_Org)'||debug_info);
      END IF;

      -- delete_chv_horizontal_schedules

      delete from chv_horizontal_Schedules chs
      where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = chs.schedule_item_id
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

     debug_info := 'chv_authorizations';
     IF g_debug_switch in ('y','Y') THEN
        Print('(Purge_Schedules_by_Org)'||debug_info);
     END IF;

     -- delete_chv_authorizations

     delete from chv_authorizations ca
     where exists
          (select null
           from  chv_purge_schedule_list cpsl
           where cpsl.schedule_item_id = ca.reference_id
           and   ca.reference_type = 'SCHEDULE_ITEMS'
           and   cpsl.double_check_flag = 'Y'
           and   cpsl.schedule_item_id between range_low and range_high);

     COMMIT;

     l_count :=0;

     range_low := range_high +1;

       OPEN  range(range_low);  --Bug2711759
     WHILE l_count < g_range_size
     LOOP
       FETCH range INTO range_high;
       EXIT WHEN range%NOTFOUND;
       l_count := l_count + 1;
     END LOOP;
       CLOSE RANGE;

    if range_low > range_high then
        EXIT;
    end if;

   END LOOP;

   COMMIT;

/*  bug2067536 Performance Bug
*/

   delete from   chv_schedule_items csi
   where not exists (select null
                       from chv_schedule_items cs
                      where csi.schedule_id = cs.schedule_id
                        and nvl(cs.item_purge_status,'ACTIVE') <> 'PURGED');

/*  bug2067536 Performance Bug
*/

   delete from chv_schedule_headers csh
   where not exists (select null
                       from chv_schedule_items csi
                      where csh.schedule_id = csi.schedule_id );

   COMMIT;

   debug_info := 'End Purge_Schedules_by_Org';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Purge_Schedules_by_Org)'||debug_info);
   END IF;
   RETURN (TRUE);

RETURN NULL; EXCEPTION
    WHEN OTHERS THEN
     IF (SQLCODE < 0 ) THEN
         Print(SQLERRM);
     END IF;
     RETURN (FALSE);
END Purge_Schedules_by_Org;



/*==========================================================================
  Function: Purge_Vendors

 *==========================================================================*/
FUNCTION Purge_Vendors
	 (P_Calling_Sequence   IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info                   	VARCHAR2(2000);
current_calling_sequence     	VARCHAR2(2000);
l_pos_dynamic_call              VARCHAR2(2000);
l_po_return_status              VARCHAR2(1);

cursor c_purge_vendors IS
select vendor_id
from  po_purge_vendor_list pvl
where  pvl.double_check_flag = 'Y';

cursor c_purge_vendor_sites IS
select vendor_id,
       vendor_site_id
from   po_vendor_sites_all
where  vendor_id in (select vendor_id
                     from   po_purge_vendor_list pvl
                     where  pvl.double_check_flag = 'Y');

BEGIN

  -- Update the calling sequence
  --

  current_calling_sequence := 'Purge_Vendors<-'||P_Calling_Sequence;

  --

  debug_info := 'ap_suppliers';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;

  -- delete_ap_suppliers
  delete from ap_suppliers vnd
  where exists
        (select null
	 from po_purge_vendor_list pvl
	 where pvl.vendor_id = vnd.vendor_id
	 and   pvl.double_check_flag = 'Y');

/* Bug 4602105: Commented out the call to etax preupgrade control packages
  -- Bug 3070584. Added the call to API for etax preupgrade control.
  FOR purge_vendors_rec IN c_purge_vendors
  LOOP

      ZX_UPGRADE_CONTROL_PKG.Sync_Suppliers
              (P_Dml_Type  => 'D',
               P_Vendor_ID => purge_vendors_rec.vendor_id);

  END LOOP;

  debug_info := 'ap_supplier_sites';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;

  -- Bug 3070584. Added the call to API for etax preupgrade control.
  FOR purge_sites_rec IN c_purge_vendor_sites
  LOOP

      ZX_UPGRADE_CONTROL_PKG.Sync_Supplier_Sites
              (P_Dml_Type       => 'D',
               P_Vendor_Site_ID => purge_sites_rec.vendor_site_id,
               P_Vendor_ID      => purge_sites_rec.vendor_id);

  END LOOP;
*/


  /* Added for bug#9645593 Start */
  DELETE
    FROM ap_supplier_contacts pc
   WHERE pc.org_party_site_id IN
         ( SELECT vnd.party_site_id
             FROM ap_supplier_sites_all vnd
                , po_purge_vendor_list pvl
	   WHERE pvl.vendor_id = vnd.vendor_id
             AND pvl.double_check_flag = 'Y'
         );
  /* Commented for bug#9645593 End */

  -- delete_ap_supplier_sites
  delete from ap_supplier_sites_all vnd
  where exists
        (select null
	 from po_purge_vendor_list pvl
	 where pvl.vendor_id = vnd.vendor_id
	 and   pvl.double_check_flag = 'Y');

  debug_info := 'ap_supplier_contacts';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;

  /* Commented for bug#9645593 Start
  Moved the below code before deleting the supplier site
  -- delete_ap_supplier_contacts
  delete from ap_supplier_contacts pc
  where not exists
            (select null
	     from ap_supplier_sites_all ps
	     where ps.vendor_site_id = pc.vendor_site_id);
  Commented for bug#9645593 End */

  -- bug 5008627. ap_bank_account_uses is obsolete
 /*
  debug_info := 'ap_bank_account_uses_all';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;

  delete from ap_bank_account_uses_all abau
  where exists
        (select null
	 from po_purge_vendor_list pvl
	 where pvl.vendor_id = abau.vendor_id
	 and   pvl.double_check_flag = 'Y');
  */
  COMMIT;

  IF g_purchasing_status = 'Y' THEN

      debug_info := 'po_vendor_list_entries';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Vendors)'||debug_info);
      END IF;

      delete from po_vendor_list_entries pvle
      where not exists
            (select null
	     from ap_suppliers vnd
	     where vnd.vendor_id = pvle.vendor_id);

      debug_info := 'po_vendor_list_headers';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Vendors)'||debug_info);
      END IF;

      delete from po_vendor_list_headers h
      where not exists
            (select null
	     from po_vendor_list_entries e
	     where e.vendor_list_header_id =
                   h.vendor_list_header_id);

      debug_info := 'po_asl_attributes';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Vendors)'||debug_info);
      END IF;

      -- delete po_asl_docments

      delete from po_asl_documents pad where
      exists (select null from po_asl_attributes paa,
                          po_purge_vendor_list pvl
	 where pvl.vendor_id = paa.vendor_id
	 and   pvl.double_check_flag = 'Y'
         and   paa.using_organization_id = pad.using_organization_id
         and   paa.asl_id = pad.asl_id);

      -- delete_po_asl_attributes

      delete from po_asl_attributes paa
      where exists
        (select null
	 from po_purge_vendor_list pvl
	 where pvl.vendor_id = paa.vendor_id
	 and   pvl.double_check_flag = 'Y');

      debug_info := 'po_approved_supplier_list';
      IF g_debug_switch in ('y','Y') THEN
         Print('(Purge_Vendors)'||debug_info);
      END IF;

      -- delete_po_approved_supplier_list

      delete from po_approved_supplier_list pasl
      where exists
        (select null
	 from po_purge_vendor_list pvl
	 where pvl.vendor_id = pasl.vendor_id
	 and   pvl.double_check_flag = 'Y');


      COMMIT;
  END IF;

  -- Bug 3603357. Added POS API call to handle purge
  debug_info := 'Call to POS_SUP_PROF_PRG_GRP.handle_purge';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;

  l_pos_dynamic_call :=
     'BEGIN
         POS_SUP_PROF_PRG_GRP.handle_purge (:l_return_status);
      END;';

  BEGIN
      EXECUTE IMMEDIATE l_pos_dynamic_call
      USING  OUT      l_po_return_status;

  debug_info := 'After call to POS handle_purge';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
       IF (SQLCODE = -6550) THEN
           debug_info := 'Ignore exception from POS call. SQLERRM: '|| SQLERRM;
           IF g_debug_switch in ('y','Y') THEN
              Print('(Purge_Vendors)'||debug_info);
           END IF;
       ELSE
           RAISE;
       END IF;
  END;


  IF g_mrp_status = 'Y' THEN
      update mrp_sourcing_rules msr
      set planning_active = 2
      where exists (select null
                    from po_purge_vendor_list pvl,
                    mrp_sr_source_org msso,
                    mrp_sr_receipt_org msro
                    where pvl.vendor_id = msso.vendor_id
                    and msso.sr_receipt_id = msro.sr_receipt_id
                    and msro.sourcing_rule_id = msr.sourcing_rule_id
                    and   pvl.double_check_flag = 'Y');

     update mrp_recommendations mr
     set source_vendor_id = null, source_vendor_site_id = null
     where exists (select null
                   from po_purge_vendor_list pvl
                   where pvl.vendor_id = mr.source_vendor_id
                   and   pvl.double_check_flag = 'Y');

     delete from mrp_sr_source_org msso
     where exists (select null
                   from po_purge_vendor_list pvl
                   where pvl.vendor_id = msso.vendor_id
                   and   pvl.double_check_flag = 'Y');

     delete from mrp_item_sourcing mis
     where exists (select null
                   from po_purge_vendor_list pvl
                   where pvl.vendor_id = mis.vendor_id
                   and   pvl.double_check_flag = 'Y');

     COMMIT;
  END IF;

  debug_info := 'End Purge_Vendors';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Purge_Vendors)'||debug_info);
  END IF;
  RETURN(TRUE);

RETURN NULL; EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);
END Purge_vendors;


/*==========================================================================
  Function: Delete_Seeded_Data

 *==========================================================================*/
FUNCTION Delete_Seeded_Data
	 (P_Purge_Name          IN  VARCHAR2,
          P_Category            IN  VARCHAR2,
          P_activity_Date       IN  DATE,
          P_Range_Size          IN  NUMBER,
          P_Purchasing_Status   IN  VARCHAR2,
          P_MRP_Status          IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info                   	VARCHAR2(200);
current_calling_sequence     	VARCHAR2(2000);
check_rows                      NUMBER;
invoice_payment_rows            NUMBER;
invoice_rows                    NUMBER;
po_header_rows                  NUMBER;
shipment_line_rows              NUMBER;
req_header_rows                 NUMBER;
vendor_rows                     NUMBER;
po_asl_rows			NUMBER;
po_asl_attr_rows		NUMBER;
po_asl_doc_rows			NUMBER;
chv_auth_rows			NUMBER;
chv_cum_adj_rows		NUMBER;
chv_cum_rows			NUMBER;
chv_hor_rows			NUMBER;
chv_ord_rows			NUMBER;
chv_head_rows			NUMBER;
chv_item_rows			NUMBER;
ae_line_rows			NUMBER;
ae_header_rows			NUMBER;
accounting_event_rows		NUMBER;
chrg_allocation_rows            NUMBER;
payment_history_rows            NUMBER;
encumbrance_line_rows           NUMBER;
rcv_subledger_detail_rows       NUMBER;


l_status                        VARCHAR2(30);
l_po_return_status              VARCHAR2(1);
l_po_msg                        VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --

  g_debug_switch := p_debug_switch;
  g_activity_date := p_activity_date;
  g_range_size := p_range_size;
  g_purchasing_status := p_purchasing_status;
  g_mrp_status := p_mrp_status;


  current_calling_sequence := 'Delete_Seeded_Data<-'||P_Calling_Sequence;

  --

  debug_info := 'Starting Delete_Seeded_Data';
  IF g_debug_switch in ('y','Y') THEN
     Print('(Delete_Seeded_Data)'||debug_info);
  END IF;

  IF p_category = 'SIMPLE INVOICES' then

    -- delete_ap_tables

     if (delete_ap_tables('Delete_Seeded_Data') <> TRUE) then
        Print('delete_ap_tables failed!');
        RETURN(FALSE);
     end if;

     -- count_ap_rows
     if (count_ap_rows(check_rows,
                       invoice_payment_rows,
                       invoice_rows,
                       'Confirm_Seeded_Data') <> TRUE) then
        Print('count_ap_row failed.' );
        return(FALSE);
     end if;

   -- purge_accounting
   if (purge_accounting('Delete_Seeded_Data') <> TRUE) then
        Print('purge_accounting failed!');
        RETURN(FALSE);
   end if;

   -- count_accounting_rows

   if (count_accounting_rows(ae_line_rows,
                             ae_header_rows,
                             accounting_event_rows,
                             chrg_allocation_rows,
                             payment_history_rows,
                             encumbrance_line_rows,
                             rcv_subledger_detail_rows,
                             'Confirm_Seeded_Data') <> TRUE) then
       Print('count_accounting_rows failed.' );
       return(FALSE);
   end if;

  ELSIF p_category IN ('SIMPLE REQUISITIONS',
                       'SIMPLE POS') then

     PO_AP_PURGE_GRP.delete_records
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       p_commit => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       p_purge_name => p_purge_name,
       p_purge_category => p_category,
       p_range_size => p_range_size);

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN(FALSE);
     END IF;

     PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => shipment_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

     IF (l_po_return_status <> 'S') THEN
        Print(l_po_msg);
        RETURN FALSE;
     END IF;

  ELSIF p_category = 'MATCHED POS AND INVOICES' then

   -- delete_ap_tables
   if (delete_ap_tables('Delete_Seeded_Data') <> TRUE) then
        Print('delete_ap_tables failed!');
        RETURN(FALSE);
   end if;

   PO_AP_PURGE_GRP.delete_records
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       p_commit => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       p_purge_name => p_purge_name,
       p_purge_category => p_category,
       p_range_size => p_range_size);

     IF (l_po_return_status <> 'S') THEN
         Print(l_po_msg);
         RETURN(FALSE);
     END IF;

   if (count_ap_rows(check_rows,
                     invoice_payment_rows,
                     invoice_rows,
                     'Confirm_Seeded_Data') <> TRUE) then
      Print('count_ap_row failed.' );
      return(FALSE);
   end if;

   -- purge_accounting
   if (purge_accounting('Delete_Seeded_Data') <> TRUE) then
        Print('purge_accounting failed!');
        RETURN(FALSE);
   end if;

  -- count_accounting_rows
   if (count_accounting_rows(ae_line_rows,
                             ae_header_rows,
                             accounting_event_rows,
                             chrg_allocation_rows,
                             payment_history_rows,
                             encumbrance_line_rows,
                             rcv_subledger_detail_rows,
                             'Confirm_Seeded_Data') <> TRUE) then
      Print('count_accounting_rows failed.' );
      return(FALSE);
   end if;


    PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => shipment_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

   IF (l_po_return_status <> 'S') THEN
      Print(l_po_msg);
      RETURN FALSE;
   END IF;

  ELSIF p_category = 'VENDORS' then

   -- purge_vendors
   if (purge_vendors('Delete_Seeded_Data') <> TRUE) then
        Print('purge_vendors failed!');
        RETURN(FALSE);
   end if;


    PO_AP_PURGE_GRP.count_po_rows
     ( p_api_version => 1.0,
       p_init_msg_list => 'T',
       x_return_status => l_po_return_status,
       x_msg_data => l_po_msg,
       x_po_hdr_count => po_header_rows,
       x_rcv_line_count => shipment_line_rows,
       x_req_hdr_count => req_header_rows,
       x_vendor_count => vendor_rows,
       x_asl_count => po_asl_rows,
       x_asl_attr_count => po_asl_attr_rows,
       x_asl_doc_count => po_asl_doc_rows
     );

   IF (l_po_return_status <> 'S') THEN
      Print(l_po_msg);
      RETURN FALSE;
   END IF;

  ELSIF p_category = 'SCHEDULES BY ORGANIZATION' then

   -- purge_schedules

   if (purge_schedules_by_org('Delete_Seeded_Data') <> TRUE) then
        Print('purge_schedules_by_org failed!');
        RETURN(FALSE);
   end if;

   -- count_chv_rows
   if (count_chv_rows(chv_auth_rows,
                      chv_cum_adj_rows,
                      chv_cum_rows,
                      chv_hor_rows,
                      chv_ord_rows,
                      chv_head_rows,
                      chv_item_rows,
		      'Delete Seeded Data')
        <> TRUE) then
        Print('purge_schedules_by_org failed!');
        RETURN(FALSE);
   end if;

  ELSIF p_category = 'SCHEDULES BY CUM PERIODS' then

  -- purge schedules

  if (purge_schedules_by_cum('Delete_Seeded_Data') <> TRUE) then
       Print('purge_schedules_by_cum failed!');
       RETURN(FALSE);
  end if;


   -- count_chv_rows
   if (count_chv_rows(chv_auth_rows,
                      chv_cum_adj_rows,
                      chv_cum_rows,
                      chv_hor_rows,
                      chv_ord_rows,
                      chv_head_rows,
                      chv_item_rows,
		      'Delete Seeded Data')
        <> TRUE) then
        Print('purge_schedules_by_cum failed!');
        RETURN(FALSE);
   end if;
  END IF;

  -- record_final_statistics
  UPDATE financials_purges
  SET
  ap_checks              = nvl(ap_checks, 0) - check_rows,
  ap_invoice_payments    = nvl(ap_invoice_payments, 0) - invoice_payment_rows,
  ap_invoices            = nvl(ap_invoices, 0) - invoice_rows,
  po_headers             = nvl(po_headers, 0) - po_header_rows,
  po_requisition_headers = nvl(po_requisition_headers, 0) - req_header_rows,
  po_vendors             = nvl(po_vendors, 0) - vendor_rows,
  po_receipts            = nvl(po_receipts, 0) - shipment_line_rows,
  po_approved_supplier_list = nvl(po_approved_supplier_list,0) - po_asl_rows,
  po_asl_attributes      = nvl(po_asl_attributes,0) - po_asl_attr_rows,
  po_asl_documents       = nvl(po_asl_documents,0) - po_asl_doc_rows,
  chv_authorizations     = nvl(chv_authorizations,0) - chv_auth_rows,
  chv_cum_adjustments    = nvl(chv_cum_adjustments,0) - chv_cum_adj_rows,
  chv_cum_periods	 = nvl(chv_cum_periods,0) - chv_cum_rows,
  chv_horizontal_Schedules = nvl(chv_horizontal_schedules,0) - chv_hor_rows,
  chv_item_orders        = nvl(chv_item_orders,0) - chv_ord_rows,
  chv_schedule_headers   = nvl(chv_schedule_headers,0) - chv_head_rows,
  chv_schedule_items     = nvl(chv_schedule_items,0) - chv_item_rows,
  ap_ae_lines		 = nvl(ap_ae_lines,0) - ae_line_rows,
  ap_ae_headers		 = nvl(ap_ae_headers,0) - ae_header_rows,
  ap_accounting_events 	 = nvl(ap_accounting_events,0) - accounting_event_rows
  WHERE purge_name = p_purge_name;

  -- reset_row_counts
  check_rows 	       := 0;
  invoice_payment_rows := 0;
  invoice_rows	       := 0;
  req_header_rows      := 0;
  po_header_rows       := 0;
  vendor_rows          := 0;
  shipment_line_rows   := 0;
  po_asl_rows	       := 0;
  po_asl_attr_rows     := 0;
  po_asl_doc_rows      := 0;
  chv_auth_rows	       := 0;
  chv_cum_adj_rows     := 0;
  chv_cum_rows	       := 0;
  chv_hor_rows	       := 0;
  chv_ord_rows         := 0;
  chv_head_rows	       := 0;
  chv_item_rows        := 0;
  ae_line_rows 	       := 0;
  ae_header_rows       := 0;
  accounting_event_rows:= 0;

  -- clear_invoice_purge_list
  delete from ap_purge_invoice_list;

  PO_AP_PURGE_GRP.delete_purge_lists
  (  p_api_version => 1.0,
     p_init_msg_list => 'T',
     p_commit => 'F',
     x_return_status => l_po_return_status,
     x_msg_data => l_po_msg,
     p_purge_name => p_purge_name);

  -- clear_vendor_purge_list
  delete from po_purge_vendor_list;

  -- clear_schedule_list
  delete from chv_purge_schedule_list;

  -- clear_cum_list
  delete from chv_purge_cum_list;

  l_status := 'COMPLETED-PURGED';

  -- set_purge_status
  if (set_purge_status(l_status,
                       p_purge_name,
                       p_debug_switch,
                       'Delete_Seeded_Data')
         <> TRUE) then
        Print('set_purge_status failed!');
        RETURN(FALSE);
  end if;
  COMMIT;
  RETURN(TRUE);

RETURN NULL; EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Delete_Seeded_Data;


/*==========================================================================
  Function: clear_check_history

 *==========================================================================*/
FUNCTION  clear_check_history RETURN BOOLEAN IS

BEGIN

 delete from ap_history_checks
 where purge_name = g_purge_name;

 RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: CLEAR_CHV_CUM_HISTORY

 *==========================================================================*/
FUNCTION CLEAR_CHV_CUM_HISTORY RETURN BOOLEAN IS
BEGIN
  delete from chv_history_schedules
  where purge_name = g_purge_name;

  delete from chv_history_cum_periods
  where purge_name = g_purge_name;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: CLEAR_CHV_CUM_LIST

 *==========================================================================*/
FUNCTION CLEAR_CHV_CUM_LIST RETURN BOOLEAN IS
BEGIN

  delete from chv_purge_schedule_list;
  delete from chv_purge_cum_list;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: CLEAR_CHV_SCHED_HISTORY

 *==========================================================================*/
FUNCTION CLEAR_CHV_SCHED_HISTORY RETURN BOOLEAN IS
BEGIN

  delete from chv_history_schedules
  where purge_name = g_purge_name;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_chv_sched_list

 *==========================================================================*/
FUNCTION  clear_chv_sched_list RETURN BOOLEAN IS

BEGIN

  delete from chv_purge_schedule_list;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_invoice_history

 *==========================================================================*/
FUNCTION  clear_invoice_history RETURN BOOLEAN IS

BEGIN

  delete from ap_history_invoices
  where purge_name = g_purge_name;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_invoice_purge_list

 *==========================================================================*/
FUNCTION  clear_invoice_purge_list RETURN BOOLEAN IS

BEGIN

  delete from ap_purge_invoice_list;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_payment_history

 *==========================================================================*/
FUNCTION  clear_payment_history RETURN BOOLEAN IS

BEGIN

  delete from ap_history_invoice_payments ahp
  where not exists (select null
                  from ap_history_invoices ahi
                  where ahi.invoice_id = ahp.invoice_id);

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_vendor_history

 *==========================================================================*/
FUNCTION  clear_vendor_history RETURN BOOLEAN IS

BEGIN

  delete from po_history_vendors
  where purge_name = g_purge_name;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: clear_vendor_purge_list

 *==========================================================================*/
FUNCTION  clear_vendor_purge_list RETURN BOOLEAN IS

BEGIN

  delete from po_purge_vendor_list;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;


/*==========================================================================
  Function: Abort_Purge

 *==========================================================================*/
FUNCTION Abort_Purge
         (P_Purge_Name          IN  VARCHAR2,
          P_Original_Status     IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

l_status                        VARCHAR2(30);
l_po_return_status              VARCHAR2(1);
l_po_msg                        VARCHAR2(2000);

BEGIN

   -- Update the calling sequence
   --

   current_calling_sequence := 'Abort_Purge<-'||P_Calling_Sequence;

   g_debug_switch := p_debug_switch;
   g_purge_name := p_purge_name;

   --
   debug_info := 'Starting Abort_Purge';
   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;


   IF(clear_invoice_purge_list <> TRUE) THEN
     RETURN (FALSE);
   END IF;
   COMMIT;

   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;

   PO_AP_PURGE_GRP.delete_purge_lists
   (  p_api_version => 1.0,
      p_init_msg_list => 'T',
      p_commit => 'T',
      x_return_status => l_po_return_status,
      x_msg_data => l_po_msg,
      p_purge_name => p_purge_name);

   IF (l_po_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RETURN (FALSE);
   END IF;


   IF(clear_vendor_purge_list <> TRUE) THEN
     RETURN (FALSE);
   END IF;
   COMMIT;

   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;

   IF(clear_chv_sched_list <> TRUE) THEN
     RETURN (FALSE);
   END IF;
   COMMIT;
   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;


   IF(clear_chv_cum_list <> TRUE) THEN
     RETURN (FALSE);
   END IF;
   COMMIT;

   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;

   IF (p_original_status = 'SUMMARIZING' OR
       p_original_status = 'SUMMARIZED') THEN

     PO_AP_PURGE_GRP.delete_history_tables
     (  p_api_version => 1.0,
        p_init_msg_list => 'T',
        p_commit => 'T',
        x_return_status => l_po_return_status,
        x_msg_data => l_po_msg,
        p_purge_name => p_purge_name);

     IF (l_po_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RETURN (FALSE);
     END IF;

     IF(clear_vendor_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;

     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;

     IF(clear_invoice_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;

     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;

     IF(clear_check_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;
     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;

     IF(clear_payment_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;
     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;

     IF(clear_chv_sched_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;
     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;

     IF(clear_chv_cum_history <> TRUE) THEN
        RETURN (FALSE);
     END IF;
     COMMIT;
     IF g_debug_switch in ('y','Y') THEN
        Print('(Abort_Purge)'||debug_info);
     END IF;


   END IF;

   l_status := 'COMPLETED-ABORTED';
   IF(set_purge_status(l_status,
                       p_purge_name,
                       p_debug_switch,
                       'Abort_Purge') <> TRUE) THEN
      RETURN (FALSE);
   END IF;
   COMMIT;
   IF g_debug_switch in ('y','Y') THEN
      Print('(Abort_Purge)'||debug_info);
   END IF;
   Print('ABORT process commenced');

  RETURN(TRUE);

RETURN NULL; EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE < 0 ) then
       Print(SQLERRM);
    END IF;
    RETURN (FALSE);

END Abort_Purge;


END AP_Purge_PKG;

/
