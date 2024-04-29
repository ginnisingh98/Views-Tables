--------------------------------------------------------
--  DDL for Package Body FV_DUE_DATE_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_DUE_DATE_CALCULATION" AS
--$Header: FVXFODDB.pls 120.22.12010000.4 2009/06/05 11:57:00 gaprasad ship $
  g_module_name VARCHAR2(100);
  v_sob			      NUMBER;

/* Select records from ap_invoices which is not of type
   interest */

 CURSOR c1_main_select IS
    SELECT api.invoice_id,
           api.terms_date,
	   api.terms_id,
	   --aid.po_distribution_id,
	   --aid.rcv_transaction_id,
           api.vendor_id,
	   api.invoice_num,
	   aps.discount_date,
           aps.second_discount_date,
           aps.third_discount_date,
           api.goods_received_date,
	   api.invoice_date
    FROM
	ap_invoices  api,
	ap_terms     apt,
	ap_terms_lines		 apl,
	fv_terms_types            fvt,
	--ap_invoice_distributions  aid,
	ap_payment_schedules      aps
    WHERE api.cancelled_amount IS  NULL
    AND   api.invoice_type_lookup_code <> 'INTEREST'
    AND ap_invoices_pkg.get_approval_status(
        api.invoice_id,
        api.invoice_amount,
        api.payment_status_flag,
        api.invoice_type_lookup_code)='APPROVED'
    AND api.wfapproval_status IN ('NOT REQUIRED','MANUALLY APPROVED',
	'WFAPPROVED')
    AND   api.set_of_books_id = v_sob
    AND   api.payment_status_flag <> 'Y'
    AND   NOT EXISTS (SELECT 'x' FROM
			ap_holds aph
			WHERE aph.invoice_id = api.invoice_id
			AND   aph.release_lookup_code IS NULL)
    AND   api.terms_id      = apt.term_id
    AND   apt.term_id       = fvt.term_id
    AND   APL.TERM_ID	    = APT.TERM_ID
    AND   NVL(apl.due_days,0) > 0
    AND   terms_type        = 'PROMPT PAY'
    --AND   api.invoice_id    = aid.invoice_id
    --AND   aid.match_status_flag = 'A'
    AND   1 = ( SELECT COUNT(*)
		FROM ap_payment_schedules aps2
		WHERE aps2.invoice_id = api.invoice_id
                AND checkrun_id IS NULL) -- modified for bug 5454497
    AND   1 = ( SELECT COUNT(*)
		FROM ap_terms_lines
		WHERE term_id = apt.term_id)
    AND   api.invoice_id = aps.invoice_id
    AND   (NOT EXISTS (  SELECT 'x'
			FROM fv_inv_selected_duedate fiv
			WHERE fiv.invoice_id = api.invoice_id)
                        or aps.payment_status_flag <> 'Y'); -- added for bug 5454497;
    -- transaction_type equals to ACCEPT, RECEIVE.
    --LGOEL: Add shipment_header_id in the select list

    CURSOR c2_accept (p_invoice_id NUMBER,
                      p_type VARCHAR2) IS
    SELECT rcv.transaction_id, aid.rcv_transaction_id,
	rcv.parent_transaction_id,
	rcv.quantity,
	rcv.transaction_type,
	rcv.po_line_location_id,
	rcv.transaction_date,
	rcv.po_header_id,
	rcv.shipment_header_id
	--pol.quantity_billed
    FROM ap_invoice_distributions aid,
	 rcv_transactions rcv,
	po_line_locations pol,
	po_distributions  po
    WHERE aid.invoice_id = p_invoice_id
    AND   aid.match_status_flag = 'A'
    AND   po.po_distribution_id   = aid.po_distribution_id
    AND   po.line_location_id  = rcv.po_line_location_id
    AND   po.line_location_id  = pol.line_location_id
    AND   rcv.transaction_type = p_type
    AND   NVL(aid.REVERSAL_FLAG,'N') <> 'Y' --Bug 7646039
--    AND	  rcv.transaction_id = NVL(aid.rcv_transaction_id,rcv.transaction_id)
  --  and not exists (select 'x' from ap_invoice_distributions  aid
  --	              where aid.rcv_transaction_id = rcv.transaction_id)
    ORDER BY    rcv.transaction_type,
		rcv.transaction_date,
	        rcv.po_line_location_id;

  --LGOEL: Declaration of shipment_header_id
  v_shipment_header_id      rcv_transactions.shipment_header_id%TYPE;

  v_po_header_id rcv_transactions.po_header_id%TYPE;

  v_rcv_transaction_id      rcv_transactions.transaction_id%TYPE;

--LGOEL: Declare cursor to fetch acceptance date for receipt matched invoices
--This was done to fix bug 1406383 as there can be multiple occurence of
--acceptance transaction type for same receipt
/* -- Commented out for bug 5454497
  CURSOR c3_receipt_accept(p_po_header_id NUMBER) IS

SELECT DISTINCT transaction_id,transaction_date
FROM rcv_transactions
WHERE
--shipment_header_id=v_shipment_header_id
po_header_id=p_po_header_id
AND transaction_type='ACCEPT'
START WITH transaction_type='RECEIVE'
CONNECT BY parent_transaction_id = PRIOR transaction_id
ORDER BY transaction_date desc;
*/
---------------------------------------------------------------
PROCEDURE get_next_business_day
(
  p_sob           IN  NUMBER,
  p_date_out      IN OUT NOCOPY DATE
) IS
  l_module_name VARCHAR2(200);
  l_error_mesg  VARCHAR2(1024);
  l_date_found  BOOLEAN := FALSE;
  l_dummy       VARCHAR2(1);
  l_hol_day     VARCHAR2(20);
BEGIN
  l_module_name :=  g_module_name || 'get_next_business_day';

  <<HOLIDAY_LOOP>>
  LOOP  --
    BEGIN
      SELECT 'x'
        INTO l_dummy
        FROM fv_holiday_dates
       WHERE TRUNC(holiday_date) = TRUNC(p_date_out)
         AND set_of_books_id = p_sob;

      p_date_out := p_date_out + 1;
      GOTO HOLIDAY_LOOP;
    EXCEPTION
      /* Check for week end */
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_hol_day := TO_CHAR(p_date_out ,'day');
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'YES ' || l_hol_day);
    END IF;

    IF(SUBSTR(l_hol_day,1,8) = 'saturday') THEN
      p_date_out := p_date_out + 2;
    ELSIF(SUBSTR(l_hol_day,1,6) = 'sunday') THEN
      p_date_out := p_date_out + 1;
    ELSE
      EXIT;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    l_error_mesg := 'When others ' || SQLERRM;
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,l_error_mesg);
    END IF;
    RAISE;
END;

---------------------------------------------------------------
PROCEDURE main (errbuf     OUT NOCOPY VARCHAR2,
		retcode    OUT NOCOPY VARCHAR2,
		x_run_mode IN  VARCHAR2)
IS
CURSOR c2_parent_receive (p_po_header_id NUMBER)
IS
SELECT DISTINCT transaction_id, transaction_date
FROM rcv_transactions
WHERE
--shipment_header_id=p_shipment_header_id
po_header_id=p_po_header_id
AND transaction_type='RECEIVE'
START WITH transaction_type='ACCEPT'
CONNECT BY transaction_id = PRIOR parent_transaction_id
ORDER BY transaction_date desc;

    -- CURSOR c1_main_select selects a set of INVOICE_ID records from
    -- AP_SELECTED_INVOICES table. The variable v_invoice_id is to be
    -- used in CURSOR c2_accept.
    v_invoice_id    	      ap_selected_invoices.invoice_id%TYPE;
    v_invoice_num    	      ap_selected_invoices.invoice_num%TYPE;
    v_terms_id      	      ap_invoices.terms_id%TYPE;
    v_terms_date    	      ap_invoices.terms_date%TYPE;
    v_terms_type    	      fv_terms_types.terms_type%TYPE;
    v_po_distribution_id      ap_invoice_distributions.po_distribution_id%TYPE;
    v_transaction_type	      rcv_transactions.transaction_type%TYPE;
    v_po_line_location_id     rcv_transactions.po_line_location_id%TYPE;
    v_transaction_date	      rcv_transactions.transaction_date%TYPE;
    v_transaction_id          rcv_transactions.transaction_id%TYPE;
    v_quantity                rcv_transactions.quantity%TYPE;
    v_quantity_billed         po_line_locations.quantity_billed%TYPE;
    v_due_days                ap_terms_lines.due_days%TYPE;
    --v_receipt_acceptance_days
		--financials_system_parameters.receipt_acceptance_days%TYPE;
    v_vendor_id               NUMBER;
    v_pay_thru_date           ap_invoice_selection_criteria.pay_thru_date%TYPE;
    v_correct_quantity        NUMBER;
    v_total_quantity  	      NUMBER;
    v_total_due_date          DATE;
    x_err_code                NUMBER;
  x_err_stage                 VARCHAR2(255);
  v_sob_name		      VARCHAR2(30);
  v_org_due_date              DATE;
  v_due_date_flag             VARCHAR2(2);
  v_disc_date_flag            VARCHAR2(2);
  v_discount_date             DATE;
  v_new_discount_date         DATE;
  v_rec_transaction_date      DATE;
  v_invoice_date              DATE;
  v_invoice_return_days       NUMBER;
  v_parent_transaction_id     rcv_transactions.transaction_id%TYPE;
  v_diff_days		      NUMBER;
  v_con_acc_days 	      NUMBER;
  v_discount_days 	      NUMBER;
  v_dummy		      VARCHAR2(2);
  v_tot_inv_retn	      NUMBER;
  v_last_transaction_type     rcv_transactions.transaction_type%TYPE;
  v_type     rcv_transactions.transaction_type%TYPE;
  v_transaction_id_org        rcv_transactions.transaction_id%TYPE;
  v_parent_transaction_id_org rcv_transactions.transaction_id%TYPE;
  v_transaction_type_org      rcv_transactions.transaction_type%TYPE;
  v_rec_txn_type              rcv_transactions.transaction_type%TYPE;
  v_transaction_date_org      DATE;
  v_final_shipment_header_id  rcv_transactions.shipment_header_id%TYPE;
  v_final_transaction_date    rcv_transactions.transaction_date%TYPE;
  v_hol_day 		      VARCHAR2(10);
  v_user		      NUMBER;
  v_rec_trxn_flag       	VARCHAR2(1);
  v_exists               VARCHAR2(1);
  v_exists_due_date          date;
  v_exists_1_dis_date        date;
  v_exists_2_dis_date        date;
  v_exists_3_dis_date        date;
  l_module_name         VARCHAR2(200);
  l_save_date           DATE;
  v_second_disc_date    ap_payment_schedules.second_discount_date%TYPE;
  v_third_disc_date     ap_payment_schedules.third_discount_date%TYPE;
  v_discount_days_2     ap_terms_lines.discount_days_2%TYPE;
  v_discount_days_3     ap_terms_lines.discount_days_3%TYPE;
  v_new_second_disc_date date;
  v_new_third_disc_date  date;
  v_2_disc_date_flag     varchar2(1);
  v_3_disc_date_flag     varchar2(1);
  v_goods_rec_date       ap_invoices.goods_received_date%TYPE;
  cnt                   NUMBER ;

  v_rcv_trans_count     NUMBER;
  TYPE v_ref_cur IS REF CURSOR ;
  c3_receipt_accept  v_ref_cur ;
  l_statement           VARCHAR2(2000);
  l_operating_unit      NUMBER ;
  l_ledger_name         GL_LEDGERS.Name%TYPE ;
  v_req_id              NUMBER ;

BEGIN  /* Procedure Due_Date_Calculation */
    -- initialize variables
    l_module_name :=  g_module_name || 'main';
    BEGIN
	-- Delete from Temp table by Org_id
    l_operating_unit := MO_GLOBAL.get_current_org_id ;
    MO_UTILS.get_ledger_info
    (
	p_operating_unit   =>  l_operating_unit ,
	p_ledger_id        =>  v_sob ,
	p_ledger_name      =>  l_ledger_name
    );
    v_sob_name := to_char ( MO_GLOBAL.get_current_org_id );
    v_user     := TO_NUMBER(fnd_profile.value('USER_ID'));

        -- bug 2088857 fix, added nvl around set_of_bks_name
        -- since this holds org_id value which will be null in non-multiorg

	DELETE FROM fv_inv_selected_duedate_temp
	WHERE NVL(set_of_bks_name,-99) = NVL(v_sob_name,-99);
	COMMIT;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    NULL;
    END;
    /*=========================================================
    Fetch records from a set of records with transaction_type equals
    to ACCEPT,RECEIVE
    ========================================================= */
    OPEN c1_main_select;
    LOOP /* C1_main_select */
    	<<INVOICE_FETCH>>
    	FETCH c1_main_select
    	INTO  v_invoice_id,
		v_terms_date,
		v_terms_id,
		--v_po_distribution_id,
		--v_rcv_transaction_id,
		v_vendor_id,
		v_invoice_num,
		v_discount_date,
                v_second_disc_date,
                v_third_disc_date,
                v_goods_rec_date,
		v_invoice_date;
    	EXIT WHEN c1_main_select%NOTFOUND;
    	/* Get the original Due date from ap_payment_schedules */

        --fnd_file.put_line(FND_FILE.LOG,'v_goods_rec_date = '||v_goods_rec_date);
    	SELECT due_date
	INTO v_org_due_date
	FROM ap_payment_schedules
	WHERE invoice_id = v_invoice_id;

	v_total_due_date := v_org_due_date;
  	v_total_quantity := 0;
        v_due_date_flag  := 'N';
	v_disc_date_flag  := 'N';
        v_2_disc_date_flag := 'N';
        v_3_disc_date_flag := 'N';
	v_new_discount_date := v_discount_date;
        v_new_second_disc_date := v_second_disc_date;
        v_new_third_disc_date  := v_third_disc_date;

        /* Fetching Due days and receipt acceptance days,discount_days */
	x_err_code := 1;
        SELECT  due_days,
		discount_days,
                discount_days_2,
                discount_days_3
	INTO    v_due_days,
		v_discount_days,
                v_discount_days_2,
                v_discount_days_3
	FROM AP_TERMS_LINES
	WHERE term_id = v_terms_id;


           FND_FILE.PUT_LINE(FND_FILE.LOG,'Due days are '|| v_due_days);

            ---------------------------------------------------------------
            -- derive the original dates ,discount date ,if the
            -- invoice been already picked up
            ------------------------------------------------------------

           begin
                 v_exists_due_date := null;
                 v_exists_1_dis_date := null;
                 v_exists_2_dis_date := null;
                 v_exists_3_dis_date := null;
                 SELECT new_due_date, new_DISCOUNT_DATE,NEW_SECOND_DISC_DATE,NEW_THIRD_DISC_DATE
                    into v_exists_due_date , v_exists_1_dis_date,v_exists_2_dis_date,v_exists_3_dis_date
                 FROM fv_inv_selected_duedate fiv
                 WHERE fiv.invoice_id = v_invoice_id;

                    v_total_due_date := v_invoice_date + v_due_days;
                   if v_discount_days is not null then
                     v_new_discount_date := v_invoice_date + v_discount_days;
                   End if;
                   if v_discount_days_2 is not null then
                     v_new_second_disc_date := v_invoice_date + v_discount_days_2;
                   End if;
                   if v_discount_days_3 is not null then
                       v_new_third_disc_date  := v_invoice_date + v_discount_days_3;
                   End if;
           exception
           when no_data_found then
           null;
          End;
          ---------------------------------------------------------------------



/*
        x_err_code := 2;
        SELECT NVL(receipt_acceptance_days,0)
	INTO v_receipt_acceptance_days
	FROM AP_SYSTEM_PARAMETERS
	WHERE set_of_books_id = v_sob;
*/

	x_err_code := 3;
 --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Receipt acc days are :' ||v_receipt_acceptance_days);
	SELECT constructive_acceptance_days,
		invoice_return_days
        INTO 	v_con_acc_days,
		v_invoice_return_days
	FROM 	fv_terms_types
	WHERE 	term_id = v_terms_id;

 FND_FILE.PUT_LINE(FND_FILE.LOG,'Cons acceptance days are :'||v_con_acc_days);
	/* Calculating due date for invoice which has po distribution */
        v_rec_trxn_flag := 'N';

	   SELECT SUM(quantity_invoiced) INTO v_quantity_billed
           FROM ap_invoice_distributions
	  WHERE invoice_id = v_invoice_id;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Quantity Invoiced is: ' || v_quantity_billed);

--	if(v_po_distribution_id is not null) then
        v_transaction_date   := null;
        v_shipment_header_id := null;
        cnt := 0;

	FOR type_id IN 1..2
	LOOP
	 v_total_quantity := 0;
	   IF type_id =1 THEN
	      v_type := 'ACCEPT';
	   ELSE
	      v_type := 'RECEIVE';
	   END IF;

	    x_err_code := 4;

	    OPEN c2_accept (v_invoice_id,v_type);
            v_last_transaction_type:=v_type;

       	    LOOP  /* C2_ACCEPT */
		FETCH c2_accept INTO
		v_transaction_id_org,
	        v_rcv_transaction_id,
		v_parent_transaction_id_org,
		v_quantity,
		v_transaction_type_org,
		v_po_line_location_id,
		v_transaction_date_org,
		v_po_header_id,
		v_shipment_header_id;
		--v_quantity_billed;
                IF  c2_accept%NOTFOUND THEN
                   v_transaction_id_org:= null;
                   v_rcv_transaction_id:= null;
                   v_parent_transaction_id_org:= null;
                   v_quantity:= 0 ;
                   v_transaction_type_org:= null;
                   v_po_line_location_id:= null;
                   v_transaction_date_org:= null;
                   v_shipment_header_id:= null;
		   v_po_header_id :=null;
                   v_transaction_id    := null;
                   v_parent_transaction_id := null;
                   v_transaction_type      := null;
                   v_transaction_date         := null;
                   v_correct_quantity      := 0;
		  v_final_transaction_date :=null;
		  v_final_shipment_header_id:=null;

	    	EXIT WHEN c2_accept%NOTFOUND;
                END IF;
        	v_rec_trxn_flag := 'Y';

		v_transaction_id            := v_transaction_id_org;
		v_parent_transaction_id     := v_parent_transaction_id_org;
		v_transaction_type          := v_transaction_type_org;
		v_transaction_date	     := v_transaction_date_org;

		/* Checking for new transaction_date from closed period */
		BEGIN
		    SELECT actual_transaction_date
		    INTO v_transaction_date
		    FROM fv_rcv_transactions
		    WHERE transaction_id = v_transaction_id_org;
		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			v_transaction_date	     := v_transaction_date_org;
		END;

		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ID :' || V_TRANSACTION_ID ||
			'  Type : ' ||  v_transaction_type
			|| ' Qty ' || TO_CHAR(v_quantity) || ' Billed  ' ||
			TO_CHAR(v_quantity_billed) );
		END IF;
		/*FND_FILE.PUT_LINE(FND_FILE.LOG, 'Id :' || v_transaction_id ||
			'  Type : ' ||  v_transaction_type
			|| ' Qty ' || to_char(v_quantity) || ' Billed  ' ||
			to_char(v_quantity_billed) ); */
  		-- summing the corrected qty for transaction type RECEIVE
		-- AND RETURN TO VENDOR  Return to vendor qty sign is
		-- flipped to add instead of subtracting
      		SELECT NVL(SUM(DECODE(transaction_type ,
			'CORRECT',quantity, quantity * -1)),0)
        	INTO   v_correct_quantity
		FROM  rcv_transactions
		WHERE transaction_type IN ('CORRECT','RETURN TO VENDOR')
		AND   parent_transaction_id = v_transaction_id;

     		/* summing total quandity */
		v_total_quantity := v_quantity + v_correct_quantity +
					v_total_quantity;
     		/* Total Qty accepted is greater than equal to the billed qty */
		v_last_transaction_type := v_transaction_type;

--         	IF(v_total_quantity > v_quantity_billed) THEN
--		    EXIT;  /* Because Billed qty = invoiced qty */
--		END IF;

		 if cnt = 0 then
		 v_final_transaction_date := v_transaction_date;
		 v_final_shipment_header_id := v_shipment_header_id;
		 elsif cnt>0 then
		   if v_transaction_date < v_final_transaction_date then
		     v_transaction_date := v_final_transaction_date;
		     v_shipment_header_id := v_final_shipment_header_id;
		    end if;
		 end if;
		 v_final_transaction_date := v_transaction_date;
                  v_final_shipment_header_id := v_shipment_header_id;
            cnt := cnt +1;

              IF(v_total_quantity >= v_quantity_billed) THEN
                  EXIT;  /* Because Billed qty = invoiced qty */
              END IF;


	    END LOOP; /* C2_ACCEPT */
      	    CLOSE C2_ACCEPT;

            IF(v_total_quantity >= v_quantity_billed) THEN
	    EXIT;  /* Because Billed qty = invoiced qty */
	    END IF;
	END LOOP ; /* For accept loop */


    IF(v_rec_trxn_flag = 'Y') or (v_rec_trxn_flag = 'N' and
                v_goods_rec_date is not null) THEN

      IF v_rec_trxn_flag = 'N' THEN

        -- this is for customers who are using the goods_received_date instead
        -- of receiving features in payables to capture the receive date.
        -- bug fix 2178745
        v_transaction_date := v_goods_rec_date;
        -- fnd_file.put_line(FND_FILE.LOG,'v_transaction_date = '||v_transaction_date);

      ELSE

	        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSACTION DATE ' ||
					TO_CHAR(v_transaction_date));
	        END IF;
	        /*FND_FILE.PUT_LINE(FND_FILE.LOG,'Transaction date ' ||
					to_char(v_transaction_date)); */
     	        /* selecting latest  Qty recevied date using
		parent transaction */
	        IF(v_con_acc_days IS NOT NULL )
			AND (v_transaction_type = 'ACCEPT') THEN

		--LGOEL: Change where condition for fetching receipt date in 11i
		--Cannot use parent_transaction_id directly because that may return the
		--'TRANSFER' transaction type
		--Fix bug 1425906
		OPEN c2_parent_receive(v_po_header_id) ;
		FETCH c2_parent_receive INTO v_parent_transaction_id, v_rec_transaction_date ;
		CLOSE c2_parent_receive ;
			IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RECEIPT DATE IS '||TO_CHAR(V_REC_TRANSACTION_DATE));
			END IF;
		      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Receipt date is '||to_char(v_rec_transaction_date));

		    /* Read new transaction date,if any defined on */
		    BEGIN
		        SELECT actual_transaction_date
		    	INTO v_rec_transaction_date
		    	FROM fv_rcv_transactions
		    	WHERE transaction_id = v_parent_transaction_id;
		    EXCEPTION
		    	WHEN NO_DATA_FOUND THEN
			    NULL;
		    END;

		    /* adding constractive acceptence days */
		    v_rec_transaction_date := v_rec_transaction_date
				+ v_con_acc_days;
         	    IF (v_rec_transaction_date < v_transaction_date) THEN
		        v_transaction_date := v_rec_transaction_date;
		    END IF;
	    	END IF;
		--LGOEL: For Receipt matching in 11i, fetch the first
		--occurence of the acceptance date

		IF (v_rcv_transaction_id IS NOT NULL) AND
		   (v_transaction_type = 'RECEIVE') THEN

		  v_rec_transaction_date := v_transaction_date;

		  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DOING RECEIPT MATCHING. ' ||
                  'Trans. Id ' || TO_CHAR(v_rcv_transaction_id)|| ' Rec. date '
                  || TO_CHAR(v_transaction_date,'DD-MON-YYYY'));
		  END IF;
		  -- Modified for bug 5454497
                     v_rcv_trans_count := 0;

                     SELECT count(*)
                     INTO v_rcv_trans_count
                     FROM rcv_transactions acc, rcv_transactions rec
                     WHERE acc.po_header_id = v_po_header_id
                     AND acc.transaction_type='ACCEPT'
                     AND acc.parent_transaction_id = rec.transaction_id
                     AND rec.transaction_type <> 'RECEIVE';

                     IF v_rcv_trans_count > 0 THEN

                        l_statement := ' SELECT DISTINCT transaction_id,transaction_date
                                         FROM rcv_transactions
                                         WHERE po_header_id = :v_po_header_id
                                         AND transaction_type = ''ACCEPT''
                                         START WITH transaction_type =''RECEIVE''
                                         CONNECT BY parent_transaction_id = PRIOR transaction_id
                                         ORDER BY transaction_date DESC ';
                       ELSE

                        l_statement := ' SELECT DISTINCT acc.transaction_id,acc.transaction_date
                                             FROM rcv_transactions rec, rcv_transactions acc
                                             WHERE rec.po_header_id = :v_po_header_id
                                             AND rec.transaction_type = ''RECEIVE''
                                             AND rec.transaction_id = acc.parent_transaction_id
                                             AND acc.transaction_type = ''ACCEPT''
                                             ORDER BY acc.transaction_date DESC ';
                     END IF;

                     OPEN c3_receipt_accept FOR l_statement using v_po_header_id;

                     --OPEN c3_receipt_accept(v_po_header_id);
                     -- End modification for bug 5454497



		  cnt := 0;
		  LOOP

		  FETCH c3_receipt_accept
		    INTO v_transaction_id, v_transaction_date;

		  EXIT WHEN c3_receipt_accept%NOTFOUND OR
			    c3_receipt_accept%NOTFOUND IS NULL;

		    /* Read new transaction date,if any defined on */
		    BEGIN
		        SELECT actual_transaction_date
		    	INTO v_transaction_date
		    	FROM fv_rcv_transactions
		    	WHERE transaction_id = v_transaction_id;
		    EXCEPTION
		    	WHEN NO_DATA_FOUND THEN
			    NULL;
		    END;
                     if cnt = 0 then
		    v_final_transaction_date := v_transaction_date;
		    elsif cnt >0 then
		      if v_transaction_date < v_final_transaction_date then
		          v_transaction_date := v_final_transaction_date;
		      end if;
		    end if;
                      v_final_transaction_date := v_transaction_date;

		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FETCHED ACCEPTANCE DATE IS '
                    || TO_CHAR(v_transaction_date,'DD-MON-YYYY'));
		    END IF;
		    /*FND_FILE.PUT_LINE(FND_FILE.LOG,'Fetched Acceptance Date is '
		    || to_char(v_transaction_date,'DD-MON-YYYY'));*/

		    /* adding constructive acceptence days */
	            IF (v_con_acc_days IS NOT NULL ) THEN
		        v_rec_transaction_date := v_rec_transaction_date
				+ v_con_acc_days;
         	        IF (v_rec_transaction_date < v_transaction_date) THEN
		            v_transaction_date := v_rec_transaction_date;
		        END IF;
		    END IF;
                    cnt := cnt + 1;
                    EXIT;

		  END LOOP; /*c3_receipt_accept*/

		  CLOSE c3_receipt_accept;

 		END IF; --rcv_transaction_id /*LGOEL*/
           END IF;  -- v_rec_trxn_flag

     	    	/* Comparing the transaction date against the due date */
      	    	IF v_transaction_date > v_terms_date THEN
		    v_total_due_date := v_transaction_date +
			v_due_days;-- + v_receipt_acceptance_days;
		    v_due_date_flag  := 'Y';
	    	ELSE

     		    /* Reset the original duedate to check wether due date falls
			on any week end or  Holiday */
		    v_total_due_date := v_ORG_DUE_DATE;
	    	END IF;

	    END IF ;  /* v_rex_trxn_flag */
--	End if; /* Po distribution is null */
        IF(v_discount_date  IS NOT  NULL) THEN
	    IF(v_invoice_date IS NOT NULL) THEN
              v_new_discount_date := v_invoice_date + NVL(v_discount_days,0);
		--	+ NVL(v_receipt_acceptance_days,0);
	      v_disc_date_flag := 'Y';

              IF (v_second_disc_date is not null
                          and v_discount_days_2 is not null) THEN
	     v_new_second_disc_date := v_invoice_date + NVL(v_discount_days_2,0);
		--	+ NVL(v_receipt_acceptance_days,0);
                 v_2_disc_date_flag := 'Y';
              END IF;
              IF (v_third_disc_date is not null
                         and v_discount_days_3 is not null) THEN
	        v_new_third_disc_date :=
                     v_invoice_date + NVL(v_discount_days_3,0);
         	--      + NVL(v_receipt_acceptance_days,0);
                v_3_disc_date_flag := 'Y';
              END IF;

	    END IF;
	END IF;

	v_diff_days := 0;

	SELECT COUNT(*)
	INTO v_tot_inv_retn
	FROM fv_invoice_returns
        WHERE invoice_id = v_invoice_id;

	IF(v_tot_inv_retn > 0) THEN
	    /* Check Invoice return days is null */

	    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING INV RETURN DAYS NOT NULL');
	    END IF;

	    --FND_FILE.put_line(FND_FILE.LOG,'checking inv return days not null');
	    IF(v_invoice_return_days IS NOT NULL ) THEN
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'YES IT IS NOT NULL');
		END IF;
		SELECT  COUNT(*)
		INTO  v_tot_inv_retn
		FROM fv_invoice_return_dates
                WHERE invoice_returned_date > (original_invoice_received_date
					+ v_invoice_return_days)
		AND   invoice_id = v_invoice_id;
		IF(v_tot_inv_retn > 0) THEN /* Total No of Invoice returned */

		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'YES FOUND SOME INVOICE
				returned later THAN the stipulated TIME');
		    END IF;

		    SELECT SUM(invoice_returned_date -
				original_invoice_received_date -
				v_invoice_return_days)
		    INTO v_diff_days
		    FROM fv_invoice_return_dates
		    WHERE  (invoice_returned_date -
			    original_invoice_received_date)
				> v_invoice_return_days
		    AND  invoice_id = v_invoice_id;

		    v_due_date_flag := 'Y';

		    -- Added new line here
		    v_total_due_date := v_total_due_date - v_diff_days;
		ELSE

		    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BUT DO NOT FIND ANY INVOICE
				RETURN later THAN the stipulated TIME');
		    END IF;
		    v_due_date_flag := 'N';
		END IF; /* Total No of Invoice returned */
	    END IF; /* invoice return days is not null */
	END IF;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DUE DATE UPDATE FLAG ' || V_DUE_DATE_FLAG);
	END IF;

	--FND_FILE.PUT_LINE(FND_FILE.LOG,'due date update flag ' || v_due_date_flag);

	---------------------------------------------------------
	/* check whether due_date falls on any weekend or holiday */

  l_save_date := v_total_due_date;
  get_next_business_day
  (
    p_sob           => v_sob,
    p_date_out      => v_total_due_date
  );

  IF (v_total_due_date <> l_save_date) THEN
    v_due_date_flag := 'Y';
  END IF;

  l_save_date := v_new_discount_date;
  get_next_business_day
  (
    p_sob           => v_sob,
    p_date_out      => v_new_discount_date
  );

  IF (v_new_discount_date <> l_save_date) THEN
    v_disc_date_flag := 'Y';
  END IF;

  IF (v_new_second_disc_date is not null) THEN
     l_save_date := v_new_second_disc_date;
     get_next_business_day
     (
       p_sob           => v_sob,
       p_date_out      => v_new_second_disc_date
     );

     IF (v_new_second_disc_date <> l_save_date) THEN
       v_2_disc_date_flag := 'Y';
     END IF;
  END IF;

  IF (v_new_third_disc_date is not null) THEN
     l_save_date := v_new_third_disc_date;
     get_next_business_day
     (
       p_sob           => v_sob,
       p_date_out      => v_new_third_disc_date
     );

     IF (v_new_third_disc_date <> l_save_date) THEN
       v_3_disc_date_flag := 'Y';
     END IF;
  END IF;

  	----------------------------------------------------------
	IF (x_run_mode = 'F') THEN
		BEGIN

		    x_err_code := 5;
		    INSERT INTO fv_inv_selected_duedate
			(INVOICE_ID,
			INVOICE_NUM,
			TERMS_DATE ,
			ORG_DUE_DATE,
			NEW_DUE_DATE,
			VENDOR_ID,
			SET_OF_BKS_NAME,
			ORG_DISCOUNT_DATE,
			NEW_DISCOUNT_DATE,
                        ORG_second_disc_date,
                        new_second_disc_date,
                        org_third_disc_date,
                        new_third_disc_date,
			transaction_id,
			transaction_date,
			po_distribution_id,
			created_by,
			creation_date,
			last_update_date,
			last_updated_by,
       			set_of_books_id)
		    VALUES
			(v_invoice_id,
			v_invoice_num,
			v_terms_date,
			v_ORG_DUE_DATE,
			DECODE(v_due_date_flag,'Y',v_total_due_date,NULL),
			v_vendor_id,
			v_sob_name,
			DECODE(v_disc_date_flag,'Y',v_DISCOUNT_DATE,NULL),
			DECODE(v_disc_date_flag,'Y',v_NEW_DISCOUNT_DATE,NULL),
			DECODE(v_2_disc_date_flag,'Y',v_second_DISC_DATE,NULL),
			DECODE(v_2_disc_date_flag,'Y',v_NEW_second_DISC_DATE,NULL),
			DECODE(v_3_disc_date_flag,'Y',v_third_DISC_DATE,NULL),
			DECODE(v_3_disc_date_flag,'Y',v_NEW_third_DISC_DATE,NULL),
			v_transaction_id,
			v_transaction_date,
			v_po_distribution_id,
			fnd_global.user_id,
			SYSDATE,
			SYSDATE,
			fnd_global.user_id ,
       			v_sob);
		EXCEPTION
		    WHEN DUP_VAL_ON_INDEX THEN
			/* If invoice exist update the duedate,this will happen
			if an invoice have more then one distributions */

			UPDATE fv_inv_selected_duedate
			SET NEW_DUE_DATE = DECODE(v_due_date_flag,'Y',
					v_total_due_date,NULL)
			WHERE invoice_id = v_invoice_id;
		END ;
	END IF; /* run mode = final */

	IF(  v_due_date_flag = 'Y' OR v_disc_date_flag = 'Y') THEN
	    IF (x_run_mode = 'F') THEN
		x_err_code := 6;

		UPDATE ap_payment_schedules
		SET due_date =    DECODE(v_due_date_flag,'Y', v_total_due_date,
			due_date), discount_date = DECODE(v_disc_date_flag,
				'Y',v_new_discount_date,discount_date),
                    second_discount_date = decode(v_2_disc_date_flag,'Y',
                                   v_new_second_disc_date,second_discount_date),
                    third_discount_date = decode(v_3_disc_date_flag,'Y',
                                   v_new_third_disc_date,third_discount_date),
		    last_update_login = fnd_global.login_id,
		    last_updated_by   = fnd_global.user_id,
		    last_update_date  = SYSDATE
		WHERE invoice_id = v_invoice_id;

	    END IF; /* run mode = final */
-------------------------------------------------------------
    -- following lined added  to aovid showing the same date as new
    -- PPA date for invoices that are picked to run in subsequent run
    -- if there is no change
    ----------------------------------------------------------------
     if trunc(v_exists_due_date) =  trunc(v_total_due_date) then
      v_total_due_date := null;
     End if;
      if trunc(v_exists_1_dis_date) = trunc(v_new_discount_date) then
      v_new_discount_date := null;
      End if;
      if trunc(v_exists_2_dis_date) = trunc(v_new_second_disc_date) then
      v_second_disc_date := null;
      End if;
      if trunc(v_exists_3_dis_date) = trunc(v_new_third_disc_date) then
      v_new_third_disc_date := null;
      End if;
     --------------------------------------------------------------

     IF (v_total_due_date IS NOT NULL OR
         v_new_discount_date IS NOT NULL OR
         v_second_disc_date IS NOT NULL OR
         v_new_third_disc_date IS NOT NULL) THEN
    	    BEGIN

		INSERT INTO fv_inv_selected_duedate_temp
		(INVOICE_ID,
		INVOICE_NUM,
		TERMS_DATE ,
		ORG_DUE_DATE,
		NEW_DUE_DATE,
		VENDOR_ID,
		SET_OF_BKS_NAME,
		ORG_DISCOUNT_DATE,
		NEW_DISCOUNT_DATE,
                ORG_second_disc_date,
                new_second_disc_date,
                org_third_disc_date,
                new_third_disc_date,
       		SET_OF_BOOKS_ID)
		VALUES
		(v_invoice_id,
		v_invoice_num,
		v_terms_date,
		v_ORG_DUE_DATE,
		v_total_due_date,
		v_vendor_id,
		v_sob_name,
		v_DISCOUNT_DATE,
		v_NEW_DISCOUNT_DATE,
 		v_second_DISC_DATE,
		v_NEW_second_DISC_DATE,
	        v_third_DISC_DATE,
	        v_NEW_third_DISC_DATE,
       		v_sob );
     	    EXCEPTION
		/* If invoice exist update the duedate,this will happen
		if an invoice have more then one distributions */

		WHEN DUP_VAL_ON_INDEX THEN

		    UPDATE fv_inv_selected_duedate_temp
		    SET NEW_DUE_DATE	 = DECODE(v_due_date_flag,'Y',
					v_total_due_date ,NULL)
		    WHERE invoice_id = v_invoice_id;
	    END ;
         END IF;
	END IF; /* Due date flag or discount flag = 'Y' */
    END LOOP; /* C1_MAIN_SELECT */

    COMMIT;
    retcode := 0;
    errbuf  := '** Due date Calculation Process Completed Sucessfully ** ';
    IF (c3_receipt_accept%isopen) THEN
        CLOSE c3_receipt_accept;
    END IF;
    cleanup;

    fnd_request.set_org_id ( l_operating_unit );
    v_req_id := fnd_request.submit_request
		(
		     application  =>  'FV' ,
		     program      =>  'FVXDUDRP' ,
		     argument1    =>  x_run_mode
		);
    IF ( v_req_id = 0 ) THEN
	errbuf := 'Error in Submit_request Procedure, ' || 'while executing Due Date Calculation Execution Report';

   else
     COMMIT;
    END IF;

    RETURN;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	retcode := -1;
	IF(x_err_code = 1) THEN
	    errbuf := 'No Due date defined in AP_TERMS_LINES';
	ELSIF(x_err_code = 2) THEN
	    errbuf  := 'Receipt acceptance days is not defined in
			FINANCIAL_SYSTEM_PARAMETERS' ;
	ELSIF(x_err_code = 5) THEN
	    errbuf  := 'Update failed in ap_payment_schedules';
	ELSIF(x_err_code = 3) THEN
	    errbuf  := 'Constructive acceptence days is not defined in
			FV_TERMS_LINES';
        ELSIF(x_err_code = 6) THEN
	    errbuf  := 'Insert failed in Fv_inv_selected_duedate_temp';
	ELSIF(x_err_code = 5) THEN
	    errbuf  := 'Main_select' || SQLERRM;
	ELSIF(x_err_code = 4) THEN
	    errbuf  := 'C2_ACCEPT' || SQLERRM;
	END IF;
	cleanup;
	RETURN;
 WHEN OTHERS THEN
          errbuf  := 'When others ' || SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,errbuf);
          RETURN;
END MAIN; /* Procedure Due_Date_Calculation */
-------------------------------------------------------------------------
/* Prcecure to rollback the transactions */
PROCEDURE cleanup IS
l_module_name         VARCHAR2(200);
errbuf   VARCHAR2(200);
BEGIN
    l_module_name :=  g_module_name || 'cleanup';
    IF (c1_main_select%ISOPEN) THEN
	CLOSE c1_main_select;
    END IF;
    IF (c2_accept%isopen) THEN
	CLOSE c2_accept;
    END IF;
/*    IF (c3_receipt_accept%isopen) THEN
	CLOSE c3_receipt_accept;
    END IF; */
    ROLLBACK;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
         errbuf  := 'When others ' || SQLERRM;
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,errbuf);
          END IF;
          RAISE;
END cleanup;
---------------------------------------------------------------------------
BEGIN
  -- global initialization to avoid File.Sql.35
  g_module_name := 'fv.plsql.fv_Due_Date_Calculation.';
END ;

/
