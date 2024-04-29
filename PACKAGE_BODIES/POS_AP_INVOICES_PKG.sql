--------------------------------------------------------
--  DDL for Package Body POS_AP_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_AP_INVOICES_PKG" AS
/* $Header: POSAPINB.pls 120.13.12010000.3 2013/10/16 09:48:39 ramkandu ship $ */


     -----------------------------------------------------------------------
     -- Function get_po_number_list returns all the PO Numbers matched to
     -- this invoice (comma delimited) or NULL if not matched.
     --
     FUNCTION get_po_number_list(l_invoice_id IN NUMBER)
         RETURN VARCHAR2
     IS
         po_number      VARCHAR2(20);
         po_number_list VARCHAR2(4000) := NULL;
         po_number_list2 VARCHAR2(4000) := NULL;


         ---------------------------------------------------------------------
         -- Declare cursor to retrieve the PO number
         --
         --togeorge 11/15/2000
         --changed org specific views to _all tables
         CURSOR po_number_cursor IS
         SELECT DISTINCT ph.segment1
         FROM   ap_invoice_distributions_all aid,
                po_distributions_all    pd,
                po_headers_all          ph
         WHERE  aid.invoice_id         	= l_invoice_id
         AND    aid.po_distribution_id 	= pd.po_distribution_id
         AND    pd.po_header_id     	= ph.po_header_id
         AND    ph.type_lookup_code 	= 'STANDARD'
         UNION ALL
         SELECT DISTINCT (ph.segment1||'-'||pr.release_num)
         FROM   ap_invoice_distributions_all aid,
                po_distributions_all    pd,
                po_headers_all          ph,
                po_releases_all		pr
         WHERE  aid.invoice_id         	= l_invoice_id
         AND    aid.po_distribution_id 	= pd.po_distribution_id
         AND    pr.po_release_id	= pd.po_release_id
         AND    ph.po_header_id		= pr.po_header_id
         AND    ph.type_lookup_code 	= 'BLANKET';

     BEGIN

         OPEN po_number_cursor;

         LOOP
             FETCH po_number_cursor INTO po_number;
             EXIT WHEN po_number_cursor%NOTFOUND;

             IF (po_number_list IS NOT NULL) THEN
                 po_number_list := po_number_list || ', ';
             END IF;

             po_number_list := po_number_list || po_number;
             po_number_list2 := po_number_list;

         END LOOP;

         CLOSE po_number_cursor;

         RETURN(po_number_list);

      EXCEPTION WHEN OTHERS THEN

         RETURN(po_number_list2); /* for overflow conditions */


     END get_po_number_list;


     FUNCTION get_packing_slip_list(l_invoice_id IN NUMBER,
				    p_invoice_num IN VARCHAR2 )
         RETURN VARCHAR2
     IS
         packing_slip      VARCHAR2(20);
         packing_slip_list VARCHAR2(4000) := NULL;
         packing_slip_list2 VARCHAR2(4000) := NULL;

         ---------------------------------------------------------------------

	CURSOR packing_slip_cursor IS
	select DISTINCT RSH.PACKING_SLIP packing_slip
	FROM   ap_invoice_distributions_all aid,
	  po_distributions_all     pd,
	  rcv_shipment_headers    rsh,
	  rcv_shipment_lines      rsl
	WHERE  aid.invoice_id          = l_invoice_id
	  AND aid.po_distribution_id  = pd.po_distribution_id
	  AND pd.LINE_LOCATION_ID  = rsl.po_line_location_id
	  AND    rsl.shipment_header_id = rsh.shipment_header_id
	  AND    rsh.packing_slip is not null
	union
	select DISTINCT RSL.PACKING_SLIP packing_slip
	FROM   ap_invoice_distributions_all aid,
	  po_distributions_all     pd,
	  rcv_shipment_headers    rsh,
	  rcv_shipment_lines      rsl
	WHERE  aid.invoice_id          = l_invoice_id
	  AND aid.po_distribution_id  = pd.po_distribution_id
	  AND pd.LINE_LOCATION_ID  = rsl.po_line_location_id
	  AND    rsl.shipment_header_id = rsh.shipment_header_id
	  AND    rsl.packing_slip is not null;


     BEGIN
         OPEN packing_slip_cursor;

         LOOP
             FETCH packing_slip_cursor INTO packing_slip;
             EXIT WHEN packing_slip_cursor%NOTFOUND;

             IF (packing_slip_list IS NOT NULL) THEN
                 packing_slip_list := packing_slip_list || ', ';
             END IF;

             packing_slip_list := packing_slip_list || packing_slip;
             packing_slip_list2 := packing_slip_list;

         END LOOP;

         CLOSE packing_slip_cursor;


      RETURN(packing_slip_list);

       EXCEPTION WHEN OTHERS THEN

         RETURN(packing_slip_list2); /* for overflow conditions */


     END get_packing_slip_list;


     FUNCTION get_packing_slip(l_invoice_id IN NUMBER,
				    p_invoice_num IN VARCHAR2 )
         RETURN VARCHAR2
     IS
         packing_slip      VARCHAR2(20);
         packing_slip1      VARCHAR2(20);
	 packing_slip2      VARCHAR2(20);
         ---------------------------------------------------------------------

	CURSOR packing_slip_cursor IS
	select DISTINCT RSH.PACKING_SLIP packing_slip
	FROM   ap_invoice_distributions_all aid,
	  po_distributions_all     pd,
	  rcv_shipment_headers    rsh,
	  rcv_shipment_lines      rsl
	WHERE  aid.invoice_id          = l_invoice_id
	  AND aid.po_distribution_id  = pd.po_distribution_id
	  AND pd.LINE_LOCATION_ID  = rsl.po_line_location_id
	  AND    rsl.shipment_header_id = rsh.shipment_header_id
	  AND    rsh.packing_slip is not null
	union
	select DISTINCT RSL.PACKING_SLIP packing_slip
	FROM   ap_invoice_distributions_all aid,
	  po_distributions_all     pd,
	  rcv_shipment_headers    rsh,
	  rcv_shipment_lines      rsl
	WHERE  aid.invoice_id          = l_invoice_id
	  AND aid.po_distribution_id  = pd.po_distribution_id
	  AND pd.LINE_LOCATION_ID  = rsl.po_line_location_id
	  AND    rsl.shipment_header_id = rsh.shipment_header_id
	  AND    rsl.packing_slip is not null;

     BEGIN

     	 packing_slip := ' ';

         OPEN packing_slip_cursor;

             FETCH packing_slip_cursor INTO packing_slip1;
             if (packing_slip_cursor%NOTFOUND) then
             	--no packing slip
             	packing_slip := ' ';
             else
		--atleast one
		FETCH packing_slip_cursor INTO packing_slip2;
		if (packing_slip_cursor%NOTFOUND) then
		   --single
		   packing_slip := packing_slip1;
		else
		   --multiple
		   packing_slip := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
		end if;
	     end if;

         CLOSE packing_slip_cursor;


      RETURN(packing_slip);

       EXCEPTION WHEN OTHERS THEN

         RETURN(packing_slip);


     END get_packing_slip;


    -------------------------------------------------------------------------------------
    -- Function to return due date for scheduled payments for an invoice
    -- Returns:
    --   due date if single scheduled payment/ 'Multiple' if multiple scheduled payments
    -- @ABTRIVED
    -------------------------------------------------------------------------------------
    FUNCTION get_due_date(l_invoice_id IN NUMBER)
    	RETURN VARCHAR2 IS

    CURSOR scheduled_payment_date_cursor IS
    SELECT due_date
    FROM AP_PAYMENT_SCHEDULES_ALL
    WHERE invoice_id = l_invoice_id;

    due_date1 date;
    due_date2 date;
    due_Date VARCHAR2(255);

    BEGIN

     OPEN scheduled_payment_date_cursor;

     fetch scheduled_payment_date_cursor into due_date1;
     if (scheduled_payment_date_cursor%NOTFOUND) then
    	due_date := '';
     else
        fetch scheduled_payment_date_cursor into due_date2;
        if (scheduled_payment_date_cursor%NOTFOUND) then

		if(fnd_timezones.timezones_enabled()='Y') then
			fnd_date_tz.init_timezones_for_fnd_date(true);
			due_date := fnd_date.date_to_displayDT(due_date1);
		else
			due_date := fnd_date.date_to_displaydate(due_date1,calendar_aware=>1);
		end if;

        else
            	due_date := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
        end if;
     end if;

     CLOSE scheduled_payment_date_cursor;

	Return(due_date);

    EXCEPTION WHEN OTHERS THEN

	Return ('');

    END get_due_date;


    --------------------------------------------------------------------------------------
    -- Procedure for hold status of an invoice
    -- Returns:
    --   p_hold_status returns hold_status = Y/N
    --   hold_reason = '<latest hold name>' if status is on hold, else ''
    -- @ABTRIVED
    --------------------------------------------------------------------------------------
    PROCEDURE get_on_hold_info(l_invoice_id IN NUMBER,
                                    p_hold_status OUT NOCOPY VARCHAR2,
                                    p_hold_reason OUT NOCOPY VARCHAR2)
    IS

     CURSOR hold_reason_cursor IS
     SELECT alc.displayed_field
     from   ap_holds_All aha,
     	    ap_lookup_codes alc
     where  alc.lookup_type = 'HOLD CODE'
	    and aha.hold_lookup_code = alc.lookup_code (+)
            and aha.invoice_id = l_invoice_id
            and aha.release_lookup_code is null
     order by aha.creation_date desc;

    BEGIN

     OPEN hold_reason_cursor;

     FETCH hold_reason_cursor INTO p_hold_reason;

     --bug 4583483
     --Removing Yes/No from hold_reason
     if (p_hold_reason is not null) then
     	--p_hold_reason := FND_MESSAGE.GET_STRING('POS','POS_YES') ||' - '|| p_hold_reason;
     	p_hold_status := 'Y';
     else
     	--p_hold_reason := FND_MESSAGE.GET_STRING('POS','POS_NO');
     	p_hold_reason := '';
     	p_hold_status := 'N';
     end if;


     CLOSE hold_reason_cursor;


    EXCEPTION WHEN OTHERS THEN

       p_hold_status  := 'E';
       p_hold_reason := '';

    END get_on_hold_info;


     ----------------------------------------------------------------------
     -- Procedure to return Receipt information associated with an invoice
     -- Returns:
     -- p_receipt_Switch: S/M/N/E Rcv_Single/Rcv_Multiple/Rcv_No/Exception
     -- p_receipt_num: <RECEIPT_NUM>
     -- p_receipt_id: <RECEIPT_ID>
     -- @ABTRIVED
     ----------------------------------------------------------------------
     PROCEDURE get_receipt_info(l_invoice_id IN NUMBER,
         				p_receipt_switch OUT NOCOPY VARCHAR2,
         				p_receipt_num OUT NOCOPY VARCHAR2,
         				p_receipt_shipment_header_id OUT NOCOPY VARCHAR2)

     IS

     receipt_num2 varchar2(30);
     receipt_shipment_header_id2 varchar2(30);

     ---cursor
     cursor receipt_info_cursor is
--using lines for matching
     select distinct  rsh.receipt_num, rsh.SHIPMENT_HEADER_ID
     from ap_invoice_lines_all al,
		rcv_transactions rt,
		rcv_shipment_headers rsh
     where al.invoice_id = l_invoice_id
        	and al.rcv_transaction_id = rt.transaction_id
		and rt.SHIPMENT_HEADER_ID =  rsh.SHIPMENT_HEADER_ID;

--using distributions for matching
/*	SELECT distinct rsh.SHIPMENT_HEADER_ID, rsh.receipt_num
	FROM   ap_invoice_distributions_all aid,
		rcv_transactions rt,
		rcv_shipment_headers rsh
	WHERE  aid.invoice_id =  l_invoice_id
        	and aid.rcv_transaction_id = rt.transaction_id
		and rt.SHIPMENT_HEADER_ID =  rsh.SHIPMENT_HEADER_ID;
*/

     BEGIN

        OPEN receipt_info_cursor;

	   FETCH receipt_info_cursor INTO p_receipt_num, p_receipt_shipment_header_id;
           if (receipt_info_cursor%NOTFOUND) then
           	-- no receipts
           	p_receipt_switch := 'N';
           else
              --atleast one po
              FETCH receipt_info_cursor INTO receipt_num2, receipt_shipment_header_id2;
              if (receipt_info_cursor%NOTFOUND) then
              	 --exactly one receipt
              	 p_receipt_switch := 'S';
              else
              	 -- multiple receipts
              	 p_receipt_switch := 'M';
              	 p_receipt_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;

        CLOSE receipt_info_cursor;

     EXCEPTION WHEN OTHERS THEN

        p_receipt_switch := 'E';

     END get_receipt_info;


----------------------------------------------------------------------
  -- Procedure to return PO information associated with an invoice
  -- Returns:
  -- p_po_switch: S/M/N/E (Single/Multiple/No/Exception)
  -- p_po_num: <PO_NUM>
  -- p_header_id: <PO_HEADER_ID>
  -- p_release_id: <PO_RELEASE_ID>
  -- @ABTRIVED
  ----------------------------------------------------------------------
  PROCEDURE get_po_info(l_invoice_id IN NUMBER,
                                p_po_switch OUT NOCOPY VARCHAR2,
                                p_po_num OUT NOCOPY VARCHAR2,
                                p_header_id OUT NOCOPY VARCHAR2,
                                p_release_id OUT NOCOPY VARCHAR2)
     IS


        po_num2 VARCHAR2(41);
        header_id2  VARCHAR2(40);
        release_id2  VARCHAR2(40);

         ---------------------------------------------------------------------
         -- Declare cursor to retrieve po_numbers, header id's and release id's
        CURSOR po_info_cursor IS
	--using invoice lines
        select distinct ph.segment1, ph.po_header_id, null
        from ap_invoice_lines_all ail,
             po_headers_all ph
        where ail.invoice_id = l_invoice_id and
              ail.po_release_id is null and
              ph.po_header_id = ail.po_header_id   and
              ph.type_lookup_code       = 'STANDARD'
        union all
        select distinct (ph.segment1||'-'||pr.release_num), ph.po_header_id, pr.po_release_id
        from ap_invoice_lines_all ail,
             po_headers_all          ph,
             po_releases_all            pr
        WHERE  ail.invoice_id           = l_invoice_id and
             pr.po_release_id   =  ail.po_release_id and
             ph.po_header_id            = ail.po_header_id and
             ph.type_lookup_code        = 'BLANKET' ;

	--using invoice distributions
/*       SELECT DISTINCT ph.segment1,ph.po_header_id,null
         FROM   ap_invoice_distributions_all aid,
                po_distributions_all    pd,
                po_headers_all          ph
         WHERE  aid.invoice_id          = l_invoice_id
         AND    aid.po_distribution_id  = pd.po_distribution_id
         AND    pd.po_header_id         = ph.po_header_id
         AND    ph.type_lookup_code     = 'STANDARD'
         UNION ALL
         SELECT DISTINCT (ph.segment1||'-'||pr.release_num),ph.po_header_id, pr.po_release_id
         FROM   ap_invoice_distributions_all aid,
                po_distributions_all    pd,
                po_headers_all          ph,
                po_releases_all         pr
         WHERE  aid.invoice_id          = l_invoice_id
         AND    aid.po_distribution_id  = pd.po_distribution_id
         AND    pr.po_release_id        = pd.po_release_id
         AND    ph.po_header_id         = pr.po_header_id
         AND    ph.type_lookup_code     = 'BLANKET';
*/


     BEGIN

        p_po_num := '';
        p_header_id := '';
        p_release_id := '';

        OPEN po_info_cursor;
           FETCH po_info_cursor INTO p_po_num, p_header_id, p_release_id;
           if (po_info_cursor%NOTFOUND) then
                -- no po's
                p_po_switch := 'N';
           else
              --atleast one po
              FETCH po_info_cursor INTO po_num2, header_id2, release_id2;
              if (po_info_cursor%NOTFOUND) then
                 --exactly one PO
                 p_po_switch := 'S';
              else
                 -- multiple PO's
                 p_po_switch := 'M';
                 p_po_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;
        CLOSE po_info_cursor;

     EXCEPTION WHEN OTHERS THEN
        p_po_switch := 'E';

     END get_po_info;

     -----------------------------------------------------------------------
     -- Function get_amount_withheld returns the AWT withheld amount on
     -- an invoice.
     --
     FUNCTION get_amount_withheld(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         amount_withheld           NUMBER := 0;
     BEGIN

         --togeorge 11/15/2000
         --changed org specific views to _all tables
         select (0 - sum(nvl(amount,0)))
         into   amount_withheld
         from   ap_invoice_distributions_all --ap_invoice_distributions
         where  invoice_id = l_invoice_id
         and    line_type_lookup_code = 'AWT';

         return(amount_withheld);

     END get_amount_withheld;


     ----------------------------------------------------------------------------------
     -- Function to get retainage amount for an invoice
     -- Sum of Retainage Release Lines and Retainage Distributions
     -- bug 4952468
     ----------------------------------------------------------------------------------
     FUNCTION get_retainage_for_invoice(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         retainage_amount1 NUMBER := 0; --Retainage amount from lines
         retainage_amount2 NUMBER := 0; --Retainage amount from distributions
     BEGIN

         select nvl(sum(amount),0)
         INTO retainage_amount1
         from ap_invoice_lines_All
         where invoice_id = l_invoice_id
         and LINE_TYPE_LOOKUP_CODE = 'RETAINAGE RELEASE';

         SELECT nvl(sum(amount),0)
         INTO retainage_amount2
         FROM ap_invoice_distributions_all aid
         WHERE aid.invoice_id = l_invoice_id
         AND aid.line_type_lookup_code = 'RETAINAGE'
         AND EXISTS
           (SELECT 'X' FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ail.line_type_lookup_code <> 'RETAINAGE RELEASE'
           );

         return(retainage_amount1 + retainage_amount2);

     END;

     ----------------------------------------------------------------------------------
     -- Function to get prepayment amount for an invoice
     -- Sum of Prepay Lines and Prepay Distributions
     -- bug 5441740
     ----------------------------------------------------------------------------------
     FUNCTION get_prepay_for_invoice(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         prepay_amount1 NUMBER := 0; --Prepayment amount from lines
         prepay_amount2 NUMBER := 0; --Prepayment amount from distributions
     BEGIN

         select nvl(sum(amount),0)
         INTO prepay_amount1
         from ap_invoice_lines_All
         where invoice_id = l_invoice_id
         and LINE_TYPE_LOOKUP_CODE = 'PREPAY';

         SELECT nvl(sum(amount),0)
         INTO prepay_amount2
         FROM ap_invoice_distributions_all aid
         WHERE aid.invoice_id = l_invoice_id
         AND aid.line_type_lookup_code = 'PREPAY'
         AND EXISTS
           (SELECT 'X' FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ail.line_type_lookup_code <> 'PREPAY'
           );

         return(prepay_amount1 + prepay_amount2);

     END;

     ----------------------------------------------------------------------------------
     -- Function to get tax amount for an invoice
     -- Sum of Lines amount for lines of type tax
     -- bug 5569244
     ----------------------------------------------------------------------------------
     FUNCTION get_tax_for_invoice(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         amount1 NUMBER := 0; -- tax amount from lines
     BEGIN

         select nvl(sum(amount),0)
         INTO amount1
         from ap_invoice_lines_All
         where invoice_id = l_invoice_id
         and LINE_TYPE_LOOKUP_CODE = 'TAX' ;

         return(amount1);

     END;

     ----------------------------------------------------------------------------------
     -- Function to get total amount for an invoice including retainage
     -- Sum of Lines amount and Retainage Distributions and Prepayment distributions
     -- bug 4952468, 5441740
     ----------------------------------------------------------------------------------
     FUNCTION get_total_for_invoice(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         amount1 NUMBER := 0; --amount from lines
         retainage_amount2 NUMBER := 0; --Retainage amount from distributions
         prepay_amount2 NUMBER := 0; --Prepayment amount from distributions
     BEGIN

         select nvl(sum(amount),0)
         INTO amount1
         from ap_invoice_lines_All
         where invoice_id = l_invoice_id;

         SELECT nvl(sum(amount),0)
         INTO retainage_amount2
         FROM ap_invoice_distributions_all aid
         WHERE aid.invoice_id = l_invoice_id
         AND aid.line_type_lookup_code = 'RETAINAGE'
         AND EXISTS
           (SELECT 'X' FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ail.line_type_lookup_code <> 'RETAINAGE RELEASE'
           );

         SELECT nvl(sum(amount),0)
         INTO prepay_amount2
         FROM ap_invoice_distributions_all aid
         WHERE aid.invoice_id = l_invoice_id
         AND aid.line_type_lookup_code = 'PREPAY'
         AND EXISTS
           (SELECT 'X' FROM ap_invoice_lines_all ail
           WHERE ail.invoice_id = l_invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ail.line_type_lookup_code <> 'PREPAY'
           );
         return(amount1 + retainage_amount2 + prepay_amount2);

     END;

    ----------------------------------------------------------------------------------
    -- Function to get list of concated payment numbers for an invoice
    -- Replacement for POS_AP_INVOICE_PAYMENTS_PKG.GET_PAID_BY_LIST
    -- @ABTRIVED
    ----------------------------------------------------------------------------------
    FUNCTION get_payment_list(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN VARCHAR2
    IS

	pay_num varchar2(20);
        pay_id varchar2(20);
        pay_date1 date;
	l_paid_by_list   VARCHAR2(2000) := NULL;
	l_paid_by_list2   VARCHAR2(2000) := NULL;

	cursor payment_cursor_new is
 	SELECT ac.check_number,
 	       ac.check_id,
 	       ac.check_Date
 	FROM   ap_invoice_payments_all aip,
 	       ap_checks_all           ac
 	WHERE  aip.invoice_id       = l_invoice_id
 	AND aip.check_id         = ac.check_id;

    BEGIN

        OPEN payment_cursor_new;

        LOOP
            FETCH payment_cursor_new INTO pay_num, pay_id, pay_date1;
            EXIT WHEN payment_cursor_new%NOTFOUND;

            IF (l_paid_by_list IS NOT NULL) THEN
                l_paid_by_list := l_paid_by_list || ', ';
            END IF;

            l_paid_by_list := l_paid_by_list || pay_num;
	    l_paid_by_list2 := l_paid_by_list;

         END LOOP;

         CLOSE payment_cursor_new;

         RETURN(l_paid_by_list);

    EXCEPTION WHEN OTHERS THEN

         RETURN(l_paid_by_list2); /* for overflow conditions */

    END get_payment_list;


    /*deprecated - should be replaced by method with same name and which passes p_payment_method also*/
     ----------------------------------------------------------------------------------
     -- Function to get payments numbers for an invoice
     -- Return parameters:
     --   p_payment_switch is N - no payments, S - single payment,
     --      M - Multiple payment
     --   p_payment_num is payment number of the payment if only one payment, else null
     --   p_payment_id is check_id if only one payment, else null
     -- @ABTRIVED
     ----------------------------------------------------------------------------------
     PROCEDURE get_payment_info(l_invoice_id IN NUMBER,
     				p_payment_switch OUT NOCOPY VARCHAR2,
  				p_payment_num OUT NOCOPY VARCHAR2,
  				p_payment_id OUT NOCOPY VARCHAR2,
  				p_payment_date OUT NOCOPY VARCHAR2
  				)
    /*deprecated - should be replaced by method with same name and which passes p_payment_method also*/

      IS

         pay_num varchar2(20);
         pay_id varchar2(20);
--         pay_type varchar2(255);
         pay_date1 date;
         pay_date2 date;

         cursor payment_cursor_new is
 	SELECT distinct ac.check_number,
 	       ac.check_id,
 	       ac.check_Date
--, 	       alc2.displayed_field
 	FROM   ap_invoice_payments_all aip,
 	       ap_checks_all           ac
--,  	       ap_lookup_codes     alc2
 	WHERE  aip.invoice_id       = l_invoice_id
 	AND aip.check_id         = ac.check_id;
-- 	AND    alc2.lookup_type     = 'PAYMENT METHOD'
-- 	AND    alc2.lookup_code     = ac.payment_method_lookup_code;

    /*deprecated - should be replaced by method with same name and which passes p_payment_method also*/
      BEGIN

  	 p_payment_switch := 'N';
 	 p_payment_num := '';
 	 p_payment_id := '';
   	 --p_payment_date := '';

          OPEN payment_cursor_new;

   	 FETCH payment_cursor_new INTO p_payment_num, p_payment_id, pay_date1;--, pay_type;
   	 if (payment_cursor_new%NOTFOUND) then
   	    --no payments
   	    p_payment_switch := 'N';
   	 else
   	    --atleast one payment
   	    FETCH payment_cursor_new INTO pay_num, pay_id, pay_date2;--, pay_type;
   	    if (payment_cursor_new%NOTFOUND) then
   	    	--just one payment
   	        p_payment_switch := 'S';

 		if(fnd_timezones.timezones_enabled()='Y') then
 			fnd_date_tz.init_timezones_for_fnd_date(true);
 			p_payment_date := fnd_date.date_to_displayDT(pay_date1);
 		else
 			p_payment_date := to_char(pay_date1,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'));
 		end if;

   	    else
   	    	p_payment_switch := 'M';
   	    	p_payment_date := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
   	    	p_payment_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
   	    end if;
   	 end if;

          CLOSE payment_cursor_new;

       EXCEPTION WHEN OTHERS THEN

           p_payment_switch := 'E';

     END get_payment_info;
    /*deprecated - should be replaced by method with same name and which passes p_payment_method also*/



     ----------------------------------------------------------------------------------
     -- Function to get payments numbers for an invoice
     -- Return parameters:
     --   p_payment_switch is N - no payments, S - single payment,
     --      M - Multiple payment
     --   p_payment_num is payment number of the payment if only one payment, else null
     --   p_payment_id is check_id if only one payment, else null
     -- @ABTRIVED
     ----------------------------------------------------------------------------------
     PROCEDURE get_payment_info(l_invoice_id IN NUMBER,
     				p_payment_switch OUT NOCOPY VARCHAR2,
  				p_payment_num OUT NOCOPY VARCHAR2,
  				p_payment_id OUT NOCOPY VARCHAR2,
  				p_payment_date OUT NOCOPY VARCHAR2,
  				p_payment_method OUT NOCOPY VARCHAR2
  				)

      IS

         pay_num varchar2(20);
         pay_id varchar2(20);
         pay_type varchar2(255);
         pay_date1 date;
         pay_date2 date;

        cursor payment_cursor_new is
 	SELECT distinct ac.check_number,
 	       ac.check_id,
-- 	       ac.check_Date,
 	       alc2.displayed_field
 	FROM   ap_invoice_payments_all aip,
 	       ap_checks_all           ac,
 	       ap_lookup_codes     alc2
 	WHERE  aip.invoice_id       = l_invoice_id
 	AND aip.check_id         = ac.check_id
 	AND    alc2.lookup_type(+)     = 'PAYMENT METHOD'
 	AND    alc2.lookup_code(+)     = ac.payment_method_lookup_code;

        cursor paymentdate_cursor_new is
 	SELECT distinct ac.check_Date
 	FROM   ap_invoice_payments_all aip,
 	       ap_checks_all           ac
 	WHERE  aip.invoice_id       = l_invoice_id
 	AND aip.check_id         = ac.check_id;


      BEGIN

  	 p_payment_switch := 'N';
 	 p_payment_num := '';
 	 p_payment_id := '';
   	 --p_payment_date := '';

          OPEN payment_cursor_new;

   	 FETCH payment_cursor_new INTO p_payment_num, p_payment_id, p_payment_method;
   	 if (payment_cursor_new%NOTFOUND) then
   	    --no payments
   	    p_payment_switch := 'N';
   	 else
   	    --atleast one payment
   	    FETCH payment_cursor_new INTO pay_num, pay_id, pay_type;
   	    if (payment_cursor_new%NOTFOUND) then
   	    	--just one payment
   	        p_payment_switch := 'S';
   	    else
   	    	p_payment_switch := 'M';
   	    	p_payment_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
   	    	p_payment_method := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
   	    end if;
   	 end if;

          CLOSE payment_cursor_new;

          OPEN paymentdate_cursor_new;

    	 FETCH paymentdate_cursor_new INTO pay_date1;
    	 if (paymentdate_cursor_new%NOTFOUND) then
    	    --no payments
    	    p_payment_date := '';
    	 else
    	    --atleast one payment
    	    FETCH paymentdate_cursor_new INTO pay_date2;
    	    if (paymentdate_cursor_new%NOTFOUND) then
    	    	--just one payment
  		if(fnd_timezones.timezones_enabled()='Y') then
  			fnd_date_tz.init_timezones_for_fnd_date(true);
  			p_payment_date := fnd_date.date_to_displayDT(pay_date1);
  		else
  			p_payment_date := to_char(pay_date1,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'));
  		end if;
    	    else
    	    	p_payment_date := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
    	    end if;
    	 end if;

           CLOSE paymentdate_cursor_new;

       EXCEPTION WHEN OTHERS THEN

           p_payment_switch := 'E';

     END get_payment_info;


   FUNCTION get_on_hold_status(l_invoice_id IN NUMBER)
     RETURN VARCHAR2 IS

    l_status VARCHAR2(60) := NULL;
    l_count NUMBER;

    BEGIN

     select count(*)
     into l_count
     from ap_holds_all
     where invoice_id = l_invoice_id
     and release_lookup_code is null;

     if (l_count > 0) then

       l_status := fnd_message.get_string('POS', 'POS_ON_HOLD');

     end if;

      RETURN l_status;

     EXCEPTION WHEN OTHERS THEN

         RETURN l_status;

    END get_on_hold_status;


     /* Function get_validation_status returns the validation status of invoice */

     FUNCTION get_validation_status(l_org_id IN NUMBER, l_invoice_id IN NUMBER)

         RETURN VARCHAR2
     IS

         validation_status VARCHAR2(50);

     BEGIN
	 fnd_client_info.set_org_context(to_char(l_org_id));
         select AP_INVOICES_PKG.GET_APPROVAL_STATUS(INVOICE_ID,INVOICE_AMOUNT, PAYMENT_STATUS_FLAG,INVOICE_TYPE_LOOKUP_CODE)
         into validation_status FROM AP_INVOICES_ALL
         WHERE INVOICE_ID = l_invoice_id;

         RETURN(validation_status);

      EXCEPTION WHEN OTHERS THEN

         RETURN(validation_status);

     END get_validation_status;


END POS_AP_INVOICES_PKG;

/
