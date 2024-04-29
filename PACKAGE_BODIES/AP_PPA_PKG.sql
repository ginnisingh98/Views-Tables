--------------------------------------------------------
--  DDL for Package Body AP_PPA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PPA_PKG" AS
/* $Header: aprddtsb.pls 120.9.12010000.7 2009/12/05 11:55:38 pgayen ship $ */

--==========================================================================
---------------------------------------------------------------------------
-- Private (Non Public) Procedure Specifications
---------------------------------------------------------------------------
--==========================================================================
 --bug 9162299 : Added variables to be used for fnd logging in print procedure
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_PPA_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_PPA_PKG.';

--bug 9162299: forward declaration of private procedure to be used for logging
PROCEDURE Print( p_debug_info IN VARCHAR2,
	         p_api_name   IN VARCHAR2);

PROCEDURE Log(p_msg 	IN VARCHAR2,
	      p_loc	IN VARCHAR2);

PROCEDURE Calc_Pay_Sched(p_invoice_id			IN NUMBER,
			 p_curr_ps_pay_num		IN NUMBER,
			 p_matched  			IN BOOLEAN,
			 p_start_date			IN DATE,
			 p_term_id			IN NUMBER,
			 p_term_name			IN VARCHAR2,
			 p_system_user			IN NUMBER,
          	         p_payment_cross_rate		IN NUMBER,
	  	   	 p_payment_priority		IN NUMBER,
	  	         p_hold_flag			IN VARCHAR2,
          	         p_payment_status_flag		IN VARCHAR2,
	  	         p_batch_id			IN NUMBER,
	  	         p_creation_date		IN DATE,
          	         p_created_by			IN NUMBER,
	  	         p_last_update_login		IN NUMBER,
          	         p_payment_method_code	        IN VARCHAR2, --4552701
			 p_external_bank_account_id	IN NUMBER,
			 p_calling_sequence		IN VARCHAR2,
                         p_sub_total                    IN OUT NOCOPY NUMBER,
                         p_sub_total_inv                IN OUT NOCOPY NUMBER);

PROCEDURE Create_Pay_Scheds(p_invoice_id		IN NUMBER,
			    p_curr_ps_pay_num		IN NUMBER,
	  	   	    p_system_user		IN NUMBER,
			    p_start_date		IN DATE,
			    p_total_gross_amount	IN NUMBER,
                            p_total_inv_curr_gross_amount
                                                        IN NUMBER,        -- R11: Xcurr
		    	    p_amount_applicable_to_disc IN NUMBER,
          	            p_payment_cross_rate	IN NUMBER,
			    p_term_id			IN NUMBER,
			    p_last_term_ps_pay_num	IN NUMBER,
	  	   	    p_payment_priority		IN NUMBER,
	  	            p_hold_flag			IN VARCHAR2,
          	            p_payment_status_flag	IN VARCHAR2,
	  	            p_batch_id			IN NUMBER,
	  	            p_creation_date		IN DATE,
          	            p_created_by		IN NUMBER,
	  	            p_last_update_login		IN NUMBER,
          	            p_payment_method_code       IN VARCHAR2, --4552701
			    p_external_bank_account_id  IN  NUMBER,
				p_percent_remain_vs_gross	IN  NUMBER,
			    p_calling_sequence		IN VARCHAR2);


PROCEDURE Insert_Pay_Sched(p_invoice_id			IN NUMBER,
		  	   p_ps_pay_num			IN NUMBER,
	  		   p_system_user		IN NUMBER,
          		   p_payment_cross_rate		IN NUMBER,
	  		   p_due_date			IN DATE,
	  		   p_1st_discount_date		IN DATE,
	  		   p_2nd_discount_date		IN DATE,
          		   p_3rd_discount_date		IN DATE,
          		   p_gross_amount		IN NUMBER,
                           p_inv_curr_gross_amount      IN NUMBER,    -- R11: Xcurr
	  		   p_1st_disc_amt_available	IN NUMBER,
	  		   p_2nd_disc_amt_available	IN NUMBER,
          		   p_3rd_disc_amt_available	IN NUMBER,
	  		   p_payment_priority		IN NUMBER,
	  		   p_hold_flag			IN VARCHAR2,
          		   p_payment_status_flag	IN VARCHAR2,
	  		   p_batch_id			IN NUMBER,
	  		   p_creation_date		IN DATE,
          		   p_created_by			IN NUMBER,
	  		   p_last_update_login		IN NUMBER,
          		   p_payment_method_code        IN VARCHAR2, --4552701
			   p_external_bank_account_id  IN  NUMBER,
			   p_percent_remain_vs_gross	IN NUMBER,
			   p_calling_sequence		IN VARCHAR2);

PROCEDURE Calc_PS_Dates_Percents_Amts(p_invoice_id		IN NUMBER,
		    		      p_term_id			IN NUMBER,
		    		      p_ps_pay_num		IN NUMBER,
				      p_start_date		IN DATE,
				      p_total_amount		IN NUMBER,
                                      p_total_pay_curr_amount   IN NUMBER,      -- R11: Xcurr
			    	      p_amount_applicable_to_disc IN NUMBER,
				      p_payment_cross_rate	IN NUMBER,
		    		      p_ppa_due_date		IN OUT NOCOPY DATE,
         	    		      p_discount_date		IN OUT NOCOPY DATE,
         	    		      p_second_discount_date	IN OUT NOCOPY DATE,
	 	    		      p_third_discount_date	IN OUT NOCOPY DATE,
         	    		      p_discount_amt_available  IN OUT NOCOPY NUMBER,
	 	    		      p_secnd_disc_amt_available IN OUT NOCOPY NUMBER,
	 	    		      p_third_disc_amt_available IN OUT NOCOPY NUMBER,
	 	    		      p_gross_amount		IN OUT NOCOPY NUMBER,
                                      p_inv_curr_gross_amount   IN OUT NOCOPY NUMBER,   -- R11: Xcurr
         	    		      p_discount_percent_1	IN OUT NOCOPY NUMBER,
         	    		      p_discount_percent_2	IN OUT NOCOPY NUMBER,
         	    		      p_discount_percent_3	IN OUT NOCOPY NUMBER,
         	    		      p_due_amount		IN OUT NOCOPY NUMBER,
         	    		      p_due_percent		IN OUT NOCOPY NUMBER,
				      p_calling_sequence	IN VARCHAR2);

PROCEDURE Delete_PaySchd_Wth_PayNum_Gtr(p_invoice_id		IN NUMBER,
			    		p_payment_num		IN NUMBER,
			    		p_calling_sequence	IN VARCHAR2);

PROCEDURE Update_Pay_Sched(p_invoice_id			IN NUMBER,
			   p_payment_num		IN NUMBER,
			   p_ppa_due_date		IN DATE,
			   p_1st_disc_amt_available 	IN NUMBER,
			   p_2nd_disc_amt_available 	IN NUMBER,
			   p_3rd_disc_amt_available 	IN NUMBER,
			   p_1st_discount_date		IN DATE,
			   p_2nd_discount_date		IN DATE,
			   p_3rd_discount_date		IN DATE,
			   p_system_user		IN NUMBER,
			   p_gross_amount		IN NUMBER,
			   p_inv_curr_gross_amount      IN NUMBER,            -- R11: Xcurr
			   p_percent_remain_vs_gross	IN NUMBER,
			   p_calling_sequence		IN VARCHAR2);


PROCEDURE Get_PaySched_Info(p_invoice_id				IN NUMBER,
							p_term_id					IN NUMBER,
							p_ps_total_gross_amount 	IN OUT NOCOPY NUMBER,
							p_ps_total_inv_curr_gross_amt IN OUT NOCOPY NUMBER,  -- R11: Xcurr
							p_last_inv_ps_pay_num		IN OUT NOCOPY NUMBER,
							p_last_term_ps_pay_num		IN OUT NOCOPY NUMBER,
							p_percent_remain_vs_gross	IN OUT NOCOPY NUMBER,
							p_calling_sequence			IN VARCHAR2);

PROCEDURE Get_Invoice_Info(p_invoice_id				IN  NUMBER,
			   p_invoice_amount			OUT NOCOPY NUMBER,
                           p_pay_curr_invoice_amount            OUT NOCOPY NUMBER,   -- R11: Xcurr
			   p_amount_applicable_to_disc 	 	OUT NOCOPY NUMBER,
			   p_calling_sequence			IN VARCHAR2);

PROCEDURE Get_PO_Terms_Info(p_invoice_id	IN NUMBER,
			    p_po_term_id	IN OUT NOCOPY NUMBER,
			    p_po_rank     	IN OUT NOCOPY NUMBER,
			    p_po_terms_name     IN OUT NOCOPY VARCHAR2,
			    p_calling_sequence	IN VARCHAR2);

PROCEDURE Get_Inv_Start_Date(p_invoice_id	IN NUMBER,
			    p_inv_date		IN DATE,
			    p_receipt_acc_days   IN NUMBER,
			    p_start_date         IN OUT NOCOPY DATE,
			    p_calling_sequence	 IN VARCHAR2);

PROCEDURE Get_Matched_Start_Date(p_invoice_id	     IN NUMBER,
			         p_inv_date	     IN DATE,
			         p_receipt_acc_days  IN NUMBER,
			         p_terms_date        IN DATE,
                                 p_goods_received_date IN DATE,
                                 p_start_date        IN OUT NOCOPY DATE,
				 p_calling_sequence  IN VARCHAR2);

--2189242
Procedure Adj_Pay_Sched_For_Round (p_invoice_id   IN NUMBER,
                                   p_calling_sequence in VARCHAR2);



--==========================================================================
---------------------------------------------------------------------------
-- Procedure Definitions
---------------------------------------------------------------------------
--==========================================================================

--============================================================================
-- DUE_DATE_SWEEPER:  Procedure that calculates the due_date of an
--		      invoice to enforce the prompt payment act.  For a
-- matched invoice, the po and invoice terms are compared bo determine which
-- term is better (rank is lower), and calculates the invoice payment schedule
-- with the better term.
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_matched:  Boolean indicating whether the invoice id matched.
--
-- p_system_user:  Approval Program User Id
--
-- p_receipt_acc_days:  System Recipt Acceptance Days
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--
-- Procedure Flow:
-- ---------------
--
-- FOR each payment schedule line of the upaid invoice without any holds
--     IF (first_record) THEN
--       IF (matched) THEN
--          Get_Matched_Start_Date and Get_PO_Terms_Info
--       ELSE
--          Get_Invoice_Start_Date
--	 END IF
--     END IF
--     IF (invoice not matched OR (po_rank < invoice_rank)) THEN
--	  Calcuulate payment Schedules
--     END IF;
-- END FOR;
--============================================================================

PROCEDURE Due_Date_Sweeper(p_invoice_id		IN NUMBER,
			   p_matched		IN BOOLEAN,
			   p_system_user	IN NUMBER,
			   p_receipt_acc_days   IN NUMBER,
			   p_calling_sequence	IN VARCHAR2) IS
--bug5058982
/*Made the correated subquery mergable by including the p_invoice_id in the
 * sub-query*/
  CURSOR Sweep_Cur IS
   SELECT  DISTINCT ps.invoice_id,
		    ps.payment_num,
     		    i.invoice_date,
		    t.term_id,
		    t.name,
		    nvl(t.rank,999),
     		    nvl(ps.payment_cross_rate,1),
     		    i.invoice_num,
		    nvl(ps.payment_priority,0),
     		    ps.hold_flag,
		    ps.payment_status_flag,
     		    nvl(ps.batch_id,0),
		    ps.creation_date,
		    nvl(ps.created_by,0),
     		    nvl(ps.last_update_login,0),
		    ps.payment_method_code, --4552701
		    ps.external_bank_account_id,
     		    nvl(i.payment_currency_code,i.invoice_currency_code),
                    i.terms_date,
                    i.goods_received_date
   FROM    ap_terms t,
	   ap_invoice_distributions d,
	   ap_invoices i,
     	   ap_payment_schedules ps
   WHERE   i.payment_status_flag = 'N'
   AND	   ps.amount_remaining > 0
   AND	   ps.invoice_id = i.invoice_id
   AND	   i.invoice_id = d.invoice_id
   AND	   i.terms_id = t.term_id
   AND	   i.invoice_type_lookup_code <> 'INTEREST'
   AND     (i.invoice_id = p_invoice_id
   AND      d.invoice_id = p_invoice_id
   AND     NOT EXISTS
	     (SELECT h.invoice_id
	      FROM   ap_holds h, ap_hold_codes c
	      WHERE  h.hold_lookup_code = c.hold_lookup_code
              AND    h.release_lookup_code is null
              AND    c.user_releaseable_flag = 'N'
	      AND    h.invoice_id=p_invoice_id))
   ORDER BY ps.invoice_id, ps.payment_num;

  l_invoice_id			NUMBER(15);
  l_invoice_num			VARCHAR2(50);
  l_term_id			NUMBER(15);
  l_term_name			VARCHAR2(50);
  -- bug 6722079
  l_po_term_id		NUMBER(15);
  l_po_term_name	VARCHAR2(50);
  l_inv_term_id		NUMBER(15);
  l_inv_term_name	VARCHAR2(50);
  -- bug 6722079
  l_inv_date			DATE;
  l_inv_rank			NUMBER(15);
  l_payment_cross_rate		NUMBER;
  l_payment_priority		NUMBER(2);
  l_hold_flag			VARCHAR2(1);
  l_payment_status_flag		VARCHAR2(25);
  l_batch_id			NUMBER(15);
  l_creation_date		DATE;
  l_created_by			NUMBER(15);
  l_last_update_login		NUMBER(15);
  l_payment_method_code	        VARCHAR2(30); --4552701
  l_external_bank_account_id    NUMBER(15);
  l_payment_currency_code	VARCHAR2(15);
  l_start_date			DATE;
  l_po_rank			NUMBER(15);
  l_terms_name			VARCHAR2(50);
  l_payment_num			NUMBER(15);
  l_first_record		BOOLEAN;
  l_debug_loc	 		VARCHAR2(30) := 'Due_Date_Sweeper';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
  l_sub_total                   NUMBER;
  l_sub_total_inv               NUMBER;
  l_terms_date                  DATE;
  l_goods_received_date         DATE;
  l_date_diff                   VARCHAR2(1); -- 4574614 (4271303)

BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  l_first_record := TRUE;
  l_sub_total := 0;
  l_sub_total_inv :=0;
  ---------------------------------
  l_debug_info := 'Open Sweep_Cur';
  ---------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  OPEN Sweep_Cur;

  LOOP

    ----------------------------------
    l_debug_info := 'Fetch Sweep_Cur';
    ---------------------------------
    print(l_debug_info, l_debug_loc); --bug 9162299
    -------------------------------

    FETCH Sweep_Cur INTO l_invoice_id,
			 l_payment_num,
			 l_inv_date,
			 l_inv_term_id,		-- 6722079
			 l_inv_term_name,	-- 6722079
			 l_inv_rank,
			 l_payment_cross_rate,
			 l_invoice_num,
			 l_payment_priority,
			 l_hold_flag,
			 l_payment_status_flag,
			 l_batch_id,
			 l_creation_date,
			 l_created_by,
			 l_last_update_login,
			 l_payment_method_code, --4552701
                         l_external_bank_account_id,
			 l_payment_currency_code,
                         l_terms_date,
                         l_goods_received_date;

    EXIT WHEN Sweep_Cur%NOTFOUND;

    IF (l_first_record) THEN

      l_first_record := FALSE;

      IF (p_matched) THEN  -- Matched --

        -----------------------------------------
        l_debug_info := 'Get Matched Start Date';
        -----------------------------------------
  	print(l_debug_info, l_debug_loc); --bug 9162299
  	-------------------------------
      -- Bug Fix: 1125440 - This call is moved after Get_PO_Terms_Info
      /*  Get_Matched_Start_Date(l_invoice_id,
		      	       l_inv_date,
		               p_receipt_acc_days,
                               l_terms_date,
                               l_goods_received_date,
                               l_start_date,
			       l_curr_calling_sequence);   */

        ------------------------------------
        l_debug_info := 'Get PO Terms Info';
        ------------------------------------
	print(l_debug_info, l_debug_loc); --bug 9162299
  	-------------------------------

        Get_PO_Terms_Info(l_invoice_id,
		          l_po_term_id,		-- 6722079
		          l_po_rank,
		          l_po_term_name,	-- 6722079
			  l_curr_calling_sequence);

      -- 1125440

		 -- bug 6722079 -- assigning the better ranked of the PO payment term
	  -- and Invoice payment term to l_term_id and l_term_name

	  IF (l_po_rank IS NULL 	OR
		  NVL(l_po_rank,999) >= l_inv_rank)
	  THEN
		 l_term_id 		:= l_inv_term_id;
		 l_term_name 	:= l_inv_term_name;
	  ELSE
		 l_term_id		:= l_po_term_id;
		 l_term_name 	:= l_po_term_name;
	  END IF;

	  -- 6722079
/*
4574614 (4271303) fbreslin: Check if any of the relevent dates has different values
*/
      IF l_goods_received_date IS NULL
         THEN IF l_inv_date <> l_terms_date
                 THEN l_date_diff := 'Y';
                 ELSE l_date_diff := 'N';
               END IF;
         ELSE IF l_inv_date   <> l_terms_date          OR
                 l_inv_date   <> l_goods_received_date OR
                 l_terms_date <> l_goods_received_date
                 THEN l_date_diff := 'Y';
                 ELSE l_date_diff := 'N';
              END IF;
      END IF;
/*
4574614 (4271303) fbreslin: If any of the relevent dates has different values, recalculate due date.
*/

-- 6792448 - Commented the following IF condition. Get_Matched_Start_Date
-- should always be called whenever invoice is PO matched.

--      IF l_po_rank < l_inv_rank OR l_date_diff = 'Y' THEN


      Get_Matched_Start_Date(l_invoice_id,
                             l_inv_date,
                             p_receipt_acc_days,
                             l_terms_date,
                             l_goods_received_date,
                             l_start_date,
                             l_curr_calling_sequence);
--      END IF; -- 6792448
             ---------------
      ELSE   -- unmatched --
             ---------------

        ------------------------------------
        l_debug_info := 'Get_Inv_Start_Date';
        ------------------------------------
  	print(l_debug_info, l_debug_loc); --bug 9162299
  	-------------------------------

        Get_Inv_Start_Date(l_invoice_id,
		           l_inv_date,
		           p_receipt_acc_days,
		           l_start_date,
			   l_curr_calling_sequence);

		l_term_id 		:= l_inv_term_id;		--7699697
		l_term_name 	:= l_inv_term_name;     --7699697

      END IF;  -- unmatched --

    END IF;  -- l_first_record --
l_debug_info := 'term id '||l_term_id||' term name '||l_term_name;
	print(l_debug_info, l_debug_loc); --bug 9162299

    -- 6792448 - Commented out this IF condition as this gives rise to
    -- inconsistent behavior. Hence changed the logic so that recalculate
    -- always happpens.

--    IF ((NOT p_matched) OR (l_po_rank < l_inv_rank)) THEN

      ----------------------------------
      l_debug_info := 'Calc_Pay_Scheds';
      ----------------------------------
      print(l_debug_info, l_debug_loc); --bug 9162299
      -------------------------------
      l_start_date := trunc(l_start_date); --bug 8522014

      Calc_Pay_Sched(l_invoice_id,
		     		 l_payment_num,
		     		 p_matched,
		     		 l_start_date,
					 l_term_id,
					 l_term_name,
					 p_system_user,
					 l_payment_cross_rate,
					 l_payment_priority,
					 l_hold_flag,
					 l_payment_status_flag,
					 l_batch_id,
					 l_creation_date,
					 l_created_by,
					 l_last_update_login,
					 l_payment_method_code, --4552701
					 l_external_bank_account_id,
					 l_curr_calling_sequence,
                                         l_sub_total,
                                         l_sub_total_inv);

--    END IF; -- 6792448

  END LOOP;

  ----------------------------------
  l_debug_info := 'Close Sweep_Cur';
  ---------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  CLOSE Sweep_Cur;

--2189242
  Adj_Pay_Sched_For_Round (p_invoice_id ,
                          p_calling_sequence);


  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
               || 'System User  = '|| to_char(p_system_user)
               || 'Receipt Acc Days  = '|| to_char(p_receipt_acc_days));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Due_Date_Sweeper;


--============================================================================
-- GET_MATCHED_START_DATE:  Procedure to return the start_date for a
--			    matched invoice.
--============================================================================

PROCEDURE Get_Matched_Start_Date(p_invoice_id	       IN NUMBER,
			         p_inv_date	       IN DATE,
			         p_receipt_acc_days    IN NUMBER,
			         p_terms_Date          IN DATE,
                                 p_goods_received_date IN DATE,
                                 p_start_date          IN OUT NOCOPY DATE,
				 p_calling_sequence    IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Get_Matched_Start_Date';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
  l_transaction_date            DATE;
  l_goods_received_date         DATE;
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  p_start_date := null;

  -------------------------------------------------
  -- SQL statement to retrieve the start date    --
  -- greatest[ invoice_date, max(accept_date) ]  --
  -- where max(accept_date) =                    --
  --       goods_received_date + receipt_acc_days--
  --------------------------------------------------
/*
  SELECT MAX(greatest(to_date(p_inv_date),
                      i.terms_date,
                      least(to_date(nvl(i.goods_received_date +
                                    nvl(p_receipt_acc_days,0),
                                    nvl(rt.transaction_date,p_inv_date))),
                            to_date(nvl(rt.transaction_date,
                                    nvl(i.goods_received_date +
                                    nvl(p_receipt_acc_days,0),p_inv_date))))))
  INTO   p_start_date
  FROM   ap_invoices i, rcv_transactions rt, rcv_shipment_lines rsl,
         ap_invoice_distributions ad, po_distributions_ap_v d
  WHERE  i.invoice_id = p_invoice_id
  AND    i.invoice_id = ad.invoice_id(+)
  AND    ad.po_distribution_id = d.po_distribution_id
  AND    d.po_header_id = rsl.po_header_id(+)
  AND    rsl.shipment_line_id = rt.shipment_line_id(+)
  AND    decode(rt.transaction_type(+), 'ACCEPT', '1',
                      'REJECT', '1', '0') = '1';
*/

  -- bug1655225. Added the condition 'RECEIVE, 'DELIVER'
  -- because w/o this condition a 3 way match would fail.
  -- Also, added if p_goods_received_date is NULL then
  -- substitute it with l_transaction_date. Chenged the
  -- least to greatest in the select that calculates p_start_date.

  Begin
  SELECT  MIN(rt.transaction_date)
  INTO    l_transaction_date
  FROM    rcv_transactions rt, rcv_shipment_lines rsl,
          ap_invoice_distributions ad, po_distributions d
  WHERE   ad.invoice_id = p_invoice_id
  AND     ad.po_distribution_id = d.po_distribution_id
  AND     d.po_header_id = rsl.po_header_id
  AND     rsl.shipment_line_id = rt.shipment_line_id
  AND     rt.transaction_type IN ('ACCEPT','REJECT','RECEIVE','DELIVER');

  Exception
  WHEN NO_DATA_FOUND THEN
   null;
  End;

  l_goods_received_date := NVL( p_goods_received_date, l_transaction_date );

  SELECT max(greatest(p_inv_date,
                      p_terms_date,
         greatest(nvl(l_goods_received_date + nvl(p_receipt_acc_days,0),
                  nvl(l_transaction_date,p_inv_date)),
         nvl(l_transaction_date,
           nvl(l_goods_received_date + nvl(p_receipt_acc_days,0),p_inv_date)))))
  INTO p_start_date
  FROM dual;

 --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_debug_info := 'Start date should not be null';
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Matched_Start_Date;

--============================================================================
-- GET_INV_START_DATE:  Procedure to retrieve the start_date for an unmatched
--			invoice.
--============================================================================
PROCEDURE Get_Inv_Start_Date(p_invoice_id	IN NUMBER,
			     p_inv_date		IN DATE,
			     p_receipt_acc_days   IN NUMBER,
			     p_start_date         IN OUT NOCOPY DATE,
			     p_calling_sequence	 IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Get_Inv_Start_Date';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
BEGIN

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


SELECT
   greatest(p_inv_date,
            i.terms_date,
            nvl(i.goods_received_date +
                         nvl(p_receipt_acc_days,0), p_inv_date))
   INTO   p_start_date
   FROM   ap_invoices i
   WHERE  i.invoice_id = p_invoice_id;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Inv_Start_Date;


--============================================================================
-- GET_PO_TERMS_INFO:  Procedure to retrieve the po_terms_id, po_rank,
--		       po_terms_name, given a matched invoice_id.
--============================================================================
PROCEDURE Get_PO_Terms_Info(p_invoice_id	IN NUMBER,
			    p_po_term_id	IN OUT NOCOPY NUMBER,
			    p_po_rank     	IN OUT NOCOPY NUMBER,
			    p_po_terms_name     IN OUT NOCOPY VARCHAR2,
			    p_calling_sequence	IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Get_PO_Terms_Info';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  -- Retrieve po terms rank, and terms id and terms name

  SELECT min(h.terms_id)
  INTO   p_po_term_id
  FROM   po_headers h,po_distributions_ap_v d,
         ap_invoice_distributions id
  WHERE  id.invoice_id = p_invoice_id
  AND    id.po_distribution_id = d.po_distribution_id
  AND    d.po_header_id = h.po_header_id;


  SELECT nvl(t.rank, 999), t.name
  INTO   p_po_rank, p_po_terms_name
  FROM   ap_terms t
  WHERE  t.term_id = p_po_term_id;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  --Bug: 735019: PO header could have a null term id.
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_PO_Terms_Info;

--============================================================================
-- CALC_PAY_SCHED:  Procedure to Recalcute a payment schecdule for an
--		    invoice.
--============================================================================
PROCEDURE Calc_Pay_Sched(p_invoice_id			IN NUMBER,
			 p_curr_ps_pay_num		IN NUMBER,
			 p_matched  			IN BOOLEAN,
			 p_start_date			IN DATE,
			 p_term_id			IN NUMBER,
			 p_term_name			IN VARCHAR2,
			 p_system_user			IN NUMBER,
          	         p_payment_cross_rate		IN NUMBER,
	  	   	 p_payment_priority		IN NUMBER,
	  	         p_hold_flag			IN VARCHAR2,
          	         p_payment_status_flag		IN VARCHAR2,
	  	         p_batch_id			IN NUMBER,
	  	         p_creation_date		IN DATE,
          	         p_created_by			IN NUMBER,
	  	         p_last_update_login		IN NUMBER,
          	         p_payment_method_code	        IN VARCHAR2, --4552701
			 p_external_bank_account_id	IN NUMBER,
			 p_calling_sequence		IN VARCHAR2,
                         p_sub_total                    IN OUT NOCOPY NUMBER,
                         p_sub_total_inv                IN OUT NOCOPY NUMBER) IS
  l_total_gross_amount 		 NUMBER;
  l_total_inv_curr_gross_amount  NUMBER;      -- R11: Xcurr
  l_invoice_amount		 NUMBER;
  l_pay_curr_invoice_amount      NUMBER;      -- R11: Xcurr
  l_amount_applicable_to_disc	 NUMBER;
  l_last_inv_ps_pay_num		 NUMBER;
  l_last_term_ps_pay_num	 NUMBER;
  l_ppa_due_date		 DATE;
  l_1st_discount_date		 DATE;
  l_2nd_discount_date		 DATE;
  l_3rd_discount_date		 DATE;
  l_1st_disc_amt_available	 NUMBER;
  l_2nd_disc_amt_available	 NUMBER;
  l_3rd_disc_amt_available	 NUMBER;
  l_gross_amount		 NUMBER;
  l_inv_curr_gross_amount        NUMBER;      -- R11: Xcurr
  l_disc_percent_1		 NUMBER;
  l_disc_percent_2		 NUMBER;
  l_disc_percent_3		 NUMBER;
  l_due_amount			 NUMBER;
  l_due_percent			 NUMBER;
  l_total			 NUMBER;
  l_old_remaining_amount         NUMBER;
  l_inv_old_remaining_amount     NUMBER;
  l_percent_remain_vs_gross     NUMBER;
  l_debug_loc	 		 VARCHAR2(30) := 'Calc_Pay_Scheds';
  l_curr_calling_sequence	 VARCHAR2(2000);
  l_debug_info			 VARCHAR2(100);
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  --------------------------------------------
  l_debug_info := 'Get Payment Schedule Info';
  --------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  Get_PaySched_Info(p_invoice_id,
		    p_term_id,
		    l_total_gross_amount,
            l_total_inv_curr_gross_Amount,    -- R11: Xcurr
		    l_last_inv_ps_pay_num,
		    l_last_term_ps_pay_num,
		    l_percent_remain_vs_gross,
                    l_curr_calling_sequence);

  --------------------------------------------
  l_debug_info := 'Get Invoice Info';
  --------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  Get_Invoice_Info(p_invoice_id,
		   l_invoice_amount,
                   l_pay_curr_invoice_amount,
		   l_amount_applicable_to_disc,
		   l_curr_calling_sequence);


  --------------------------------------------------------------
  l_debug_info := 'Calc Payment Schedule Dates, Percents, Amts';
  --               given invoice_id, term_id and payment num  --
  --------------------------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------
  l_debug_info := ' inv id '||p_invoice_id||' terms '||p_term_id||' payment num '||p_curr_ps_pay_num;
  print(l_debug_info, l_debug_loc); --bug 9162299

  Calc_PS_Dates_Percents_Amts(p_invoice_id,
			      p_term_id,
			      p_curr_ps_pay_num,
			      p_start_date,
			      l_invoice_amount,
                              l_pay_curr_invoice_amount,        -- R11: Xcurr
			      l_amount_applicable_to_disc,
			      p_payment_cross_rate,
			      l_ppa_due_date,
			      l_1st_discount_date,
			      l_2nd_discount_date,
			      l_3rd_discount_date,
			      l_1st_disc_amt_available,
			      l_2nd_disc_amt_available,
			      l_3rd_disc_amt_available,
			      l_gross_amount,
		        	l_inv_curr_gross_amount,         -- R11: Xcurr
			      l_disc_percent_1,
			      l_disc_percent_2,
			      l_disc_percent_3,
			      l_due_amount,
			      l_due_percent,
			      l_curr_calling_sequence);


   l_old_remaining_amount := l_total_gross_amount - p_sub_total;
   l_inv_old_remaining_amount := l_total_inv_curr_gross_Amount - p_sub_total_inv;
   p_sub_total := p_sub_total + l_gross_amount;
   p_sub_total_inv := p_sub_total_inv + l_inv_curr_gross_amount;  -- R11: Xcurr

   l_debug_info := ' old rem amt '||l_old_remaining_amount||' l_inv_old_remaining_amount '||l_inv_old_remaining_amount;
   print(l_debug_info, l_debug_loc); --bug 9162299

 l_debug_info := ' p_sub_total'||p_sub_total||' p_sub_total_inv '||p_sub_total_inv;
 print(l_debug_info, l_debug_loc); --bug 9162299

   IF (((l_due_amount = 0) OR (p_sub_total >= l_total_gross_amount) OR
        (p_sub_total_inv >= l_total_inv_curr_gross_Amount)) AND
        (l_due_percent is NULL)) THEN
    --------------------------------------------------------------------
    -- Set gross_amount to the remainder of the invoice_amount and    --
    -- set the last_term_ps_payment_number to the current payment     --
    -- number as it is the last payment number that will be updated.  --
    -- Also calculate the discount amounts of this line.              --
    --------------------------------------------------------------------
	l_debug_info := ' inside if loop';
        print(l_debug_info, l_debug_loc); --bug 9162299

    -- Make sure we do not over-subtract
    IF ((p_sub_total >= l_total_gross_amount) OR
        (p_sub_total_inv >= l_total_inv_curr_gross_Amount)) THEN
      l_gross_amount := l_old_remaining_amount;
      l_inv_curr_gross_amount := l_inv_old_remaining_amount;
    ELSE
      l_gross_amount := l_total_gross_amount - p_sub_total;
      l_inv_curr_gross_amount := l_total_inv_curr_gross_amount - p_sub_total_inv;   -- R11: Xcurr
    END IF;
    l_1st_disc_amt_available := l_gross_amount * l_disc_percent_1;
    l_2nd_disc_amt_available := l_gross_amount * l_disc_percent_2;
    l_3rd_disc_amt_available := l_gross_amount * l_disc_percent_3;
    l_last_term_ps_pay_num := p_curr_ps_pay_num;


   END IF;

  -------------------------------------------
  l_debug_info := 'Update Payment Schedules';
  -------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------
  -------------------------------------------
  l_debug_info := 'l_gross_amount '||l_gross_amount||' l_last_term_ps_pay_num '||
                   l_last_term_ps_pay_num||' l_last_inv_ps_pay_num '||l_last_inv_ps_pay_num;
  -------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  Update_Pay_Sched(p_invoice_id,
		   p_curr_ps_pay_num,
		   l_ppa_due_date,
		   l_1st_disc_amt_available,
		   l_2nd_disc_amt_available,
		   l_3rd_disc_amt_available,
		   l_1st_discount_date,
		   l_2nd_discount_date,
		   l_3rd_discount_date,
		   p_system_user,
		   l_gross_amount,
           l_inv_curr_gross_amount,    -- R11: Xcurr
		   l_percent_remain_vs_gross,
                   l_curr_calling_sequence);

    --
    -- Check if we need to create/delete payment schedule line.
    --
    IF (l_last_term_ps_pay_num < l_last_inv_ps_pay_num) THEN

       IF (p_curr_ps_pay_num = l_last_term_ps_pay_num) THEN

         -----------------------------------------------------------------
         -- If the term has less payment schedules than the invoice,    --
         -- and the current invoice payment schedule payment number     --
         -- is equal to the last term pay schedule payment number, then --
         l_debug_info := 'Delete Pay Schedules form the invoice';
         --               greater than the current payment number       --
         -----------------------------------------------------------------
  	 print(l_debug_info, l_debug_loc); --bug 9162299
  	 -------------------------------

         Delete_PaySchd_Wth_PayNum_Gtr(p_invoice_id, p_curr_ps_pay_num,
				       l_curr_calling_sequence);

       END IF;

    ELSIF (l_last_term_ps_pay_num > l_last_inv_ps_pay_num) THEN

       IF (p_curr_ps_pay_num = l_last_inv_ps_pay_num) THEN

         -------------------------------------------------------------------
         -- If the term has more payment schedules than the invoice,      --
         -- and the current invoice payment schedule payment number       --
         -- is equal to the last invoice pay schedule payment number then --
         l_debug_info := 'Create Payment Schedules for the invoice';
         --               greater than the current payment number         --
         --		  up until the last term pay sched pay num        --
         -------------------------------------------------------------------
	 print(l_debug_info, l_debug_loc); --bug 9162299
	 -------------------------------

	 Create_Pay_Scheds(p_invoice_id,
			   (p_curr_ps_pay_num + 1),
	  	   	   p_system_user,
			   p_start_date,
            	l_pay_curr_invoice_amount,      -- R11: Xcurr
			   l_invoice_amount,
			   l_amount_applicable_to_disc,
          	           p_payment_cross_rate,
			   p_term_id,
			   l_last_term_ps_pay_num,
	  	   	   p_payment_priority,
	  	           p_hold_flag,
          	           p_payment_status_flag,
	  	           p_batch_id,
	  	           p_creation_date,
          	           p_created_by,
	  	           p_last_update_login,
          	           p_payment_method_code, --4552701
			   p_external_bank_account_id,
			   l_percent_remain_vs_gross,
                           l_curr_calling_sequence);

       END IF;  -- p_curr_ps_pay_num = l_last_inv_ps_pay_num --

    END IF; -- l_last_term_ps_pay_num > l_last_inv_ps_pay_num --


  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
               || 'Curr PS Pay Num  = '|| to_char(p_curr_ps_pay_num)
               || 'Term Id  = '|| to_char(p_term_id)
               || 'Term Name = '|| p_term_name
               || 'System User  = '|| to_char(p_system_user));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Pay_Sched;


--============================================================================
-- GET_INVOICE_INFO:  Procedure to retrieve the invoice_amount,
--		       amount_applicable_to_disc,
--============================================================================
PROCEDURE Get_Invoice_Info(p_invoice_id				IN  NUMBER,
			   p_invoice_amount			OUT NOCOPY NUMBER,
                           p_pay_curr_invoice_amount            OUT NOCOPY NUMBER,    -- R11: Xcurr
			   p_amount_applicable_to_disc	 	OUT NOCOPY NUMBER,
			   p_calling_sequence			IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Get_Invoice_Info';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  ---------------------------------------------------------------------------
  l_debug_info := 'Retrieve invoice_amount and amount_applicable_to_disc';
  ---------------------------------------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  SELECT invoice_amount,
         nvl(pay_curr_invoice_amount,invoice_amount) pay_curr_invoice_amount,            -- R11: Xcurr
	 amount_applicable_to_discount
    INTO p_invoice_amount,
         p_pay_curr_invoice_amount,                              -- R11: Xcurr
	 p_amount_applicable_to_disc
    FROM ap_invoices
   WHERE invoice_id = p_invoice_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Invoice_Info;


--============================================================================
-- GET_PAYSCHED_INFO:  Procedure to retrieve the total_gross_amount,
--		       last_invoice_pay_sched_pay_num,
-- last_term_pay_sched_pay_num given the invoice_id and new terms_id.
--============================================================================

PROCEDURE Get_PaySched_Info(p_invoice_id				IN NUMBER,
							p_term_id					IN NUMBER,
							p_ps_total_gross_amount 	IN OUT NOCOPY NUMBER,
							p_ps_total_inv_curr_gross_amt IN OUT NOCOPY NUMBER, -- R11: Xcurr
							p_last_inv_ps_pay_num		IN OUT NOCOPY NUMBER,
							p_last_term_ps_pay_num		IN OUT NOCOPY NUMBER,
							p_percent_remain_vs_gross	IN OUT NOCOPY NUMBER,
							p_calling_sequence			IN VARCHAR2) IS

  l_debug_loc	 			VARCHAR2(30) := 'Get_PaySched_Info';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info				VARCHAR2(100);
  l_amount_remaining		NUMBER;
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  ----------------------------------------------------------------
  l_debug_info := 'Retrieve last_inv_ps_pay_num and gross_amount';
  ----------------------------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  SELECT count(*), sum(gross_amount),
         sum(nvl(inv_curr_gross_amount, gross_amount)),     -- R11: Xcurr
		 sum(nvl(amount_remaining, gross_amount))
  INTO 	 p_last_inv_ps_pay_num, p_ps_total_gross_amount,
         p_ps_total_inv_curr_gross_amt,                     -- R11: Xcurr
		 l_amount_remaining
  FROM ap_payment_schedules
  WHERE invoice_id = p_invoice_id;

  ------------------------------------------------
  l_debug_info := 'Retrieve last_term_ps_pay_num';
  ------------------------------------------------
  print(l_debug_info, l_debug_loc); --bug 9162299
  -------------------------------

  SELECT count(*)
  INTO   p_last_term_ps_pay_num
  FROM   ap_terms_lines
  WHERE term_id = p_term_id;

  ------------------------------------------------
  -- get percentage of amt_remaining vs gross_amt
  l_debug_info := 'Retrieve percent_remain_vs_gross';
  ------------------------------------------------
  if ( p_ps_total_gross_amount = 0 ) then
	p_percent_remain_vs_gross := 1;
  else
    p_percent_remain_vs_gross := l_amount_remaining/p_ps_total_gross_amount;
  end if;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_PaySched_Info;


--============================================================================
-- UPDATE_PAY_SCHED:  Procedure to update a payment schedule line.
--============================================================================
PROCEDURE Update_Pay_Sched(p_invoice_id			IN NUMBER,
			   p_payment_num		IN NUMBER,
			   p_ppa_due_date		IN DATE,
			   p_1st_disc_amt_available 	IN NUMBER,
			   p_2nd_disc_amt_available 	IN NUMBER,
			   p_3rd_disc_amt_available 	IN NUMBER,
			   p_1st_discount_date		IN DATE,
			   p_2nd_discount_date		IN DATE,
			   p_3rd_discount_date		IN DATE,
			   p_system_user		IN NUMBER,
			   p_gross_amount		IN NUMBER,
               p_inv_curr_gross_amount      IN NUMBER,       -- R11: Xcurr
			   p_percent_remain_vs_gross 	IN NUMBER,
			   p_calling_sequence		IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Update_Pay_Sched';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_pay_sched_total             NUMBER; /* Bug Fix:1237758 */
  l_invoice_sign                NUMBER; /* Bug Fix:1237758 */
  l_pay_curr_invoice_amount     NUMBER; /* Bug Fix:1237758 */
  l_pay_curr_code	VARCHAR2(15);


BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  --
  -- Update the amount_remaining and not updat discount_amount_remaining
  -- per discussion with shira and nnakos, this program will populate
  -- discount_amount_remaining as the same as discount_amount_available
  --
  -- get payment currency code for rounding
  --

  SELECT payment_currency_code
  INTO   l_pay_curr_code
  FROM   ap_invoices
  WHERE  invoice_id = p_invoice_id;

  UPDATE ap_payment_schedules
  SET  due_date = p_ppa_due_date,
       discount_amount_available = p_1st_disc_amt_available,
       discount_amount_remaining = p_1st_disc_amt_available,
       second_disc_amt_available = p_2nd_disc_amt_available,
       third_disc_amt_available = p_3rd_disc_amt_available,
       discount_date = p_1st_discount_date,
       second_discount_date = p_2nd_discount_date,
       third_discount_date = p_3rd_discount_date,
       last_update_date = SYSDATE,
       last_updated_by = p_system_user,
       gross_amount = p_gross_amount,
       inv_curr_gross_amount = p_inv_curr_gross_amount,          -- R11: Xcurr
       amount_remaining = ap_utilities_pkg.ap_round_currency(
							 p_gross_amount * nvl(p_percent_remain_vs_gross,1),
							 l_pay_curr_code)
    WHERE invoice_id = p_invoice_id
    AND   payment_num = p_payment_num;

   --Bug 4539462 DBI logging
   AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value1 => p_invoice_id,
               p_key_value2 => p_payment_num,
                p_calling_sequence => l_curr_calling_sequence);

  --Bug Fix:1237758
  --The following code added to take care of rounding errors
  SELECT SUM(gross_amount)
  INTO l_pay_sched_total
  FROM ap_payment_schedules
  WHERE invoice_id = P_Invoice_Id;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||  'Payment Num  = '|| to_char(p_payment_num)
              ||  'PPA Due Date  = '|| to_char(p_ppa_due_date)
              ||  '1st Disc Amt Avail  = '|| to_char(p_1st_disc_amt_available)
              ||  '2nd Disc Amt Avail  = '|| to_char(p_1st_disc_amt_available)
              ||  '3rd Disc Amt Avail  = '|| to_char(p_1st_disc_amt_available)
              ||  '1st_discount_date  = '|| to_char(p_1st_discount_date)
              ||  '2nd_discount_date  = '|| to_char(p_2nd_discount_date)
              ||  '3rd_discount_date  = '|| to_char(p_3rd_discount_date)
              ||  'System User  = '|| to_char(p_system_user)
              ||  'Gross Amount  = '|| to_char(p_gross_amount));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Pay_Sched;

--============================================================================
-- DELETE_PAYSCHD_WTH_PAYNUM_GTR:  Delete the payment schedules for a invoice
--				   with payment number greater than the
-- one given.
--============================================================================
PROCEDURE Delete_PaySchd_Wth_PayNum_Gtr(p_invoice_id		IN NUMBER,
			    		p_payment_num		IN NUMBER,
			    		p_calling_sequence	IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Delete_PaySchd_Wth_PayNum_Gtr';
  l_curr_calling_sequence	VARCHAR2(2000);
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  DELETE FROM ap_payment_schedules
  WHERE  invoice_id = p_invoice_id
  AND    payment_num > p_payment_num;

  --Bug 4539462 DBI logging
  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'D',
               p_key_value1 => p_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
               || 'Payment Num  = '|| to_char(p_payment_num));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Delete_PaySchd_Wth_PayNum_Gtr;


--============================================================================
-- CALC_PS_DATES_PERCENTS_AMTS:  Procedure to calculate and return the
--			         payment schedule, dates, percents and
-- amounts.
--============================================================================
PROCEDURE Calc_PS_Dates_Percents_Amts(p_invoice_id		IN NUMBER,
		    		      p_term_id			IN NUMBER,
		    		      p_ps_pay_num		IN NUMBER,
				      p_start_date		IN DATE,
				      p_total_amount		IN NUMBER,
                                      p_total_pay_curr_amount   IN NUMBER,      -- R11: Xcurr
				      P_amount_applicable_to_disc IN NUMBER,
				      p_payment_cross_rate	IN NUMBER,
		    		      p_ppa_due_date		IN OUT NOCOPY DATE,
         	    		      p_discount_date		IN OUT NOCOPY DATE,
         	    		      p_second_discount_date	IN OUT NOCOPY DATE,
	 	    		      p_third_discount_date	IN OUT NOCOPY DATE,
         	    		      p_discount_amt_available  IN OUT NOCOPY NUMBER,
	 	    		      p_secnd_disc_amt_available IN OUT NOCOPY NUMBER,
	 	    		      p_third_disc_amt_available IN OUT NOCOPY NUMBER,
	 	    		      p_gross_amount		IN OUT NOCOPY NUMBER,
                                      p_inv_curr_gross_amount   IN OUT NOCOPY NUMBER,    -- R11: Xcurr
         	    		      p_discount_percent_1	IN OUT NOCOPY NUMBER,
         	    		      p_discount_percent_2	IN OUT NOCOPY NUMBER,
         	    		      p_discount_percent_3	IN OUT NOCOPY NUMBER,
         	    		      p_due_amount		IN OUT NOCOPY NUMBER,
         	    		      p_due_percent		IN OUT NOCOPY NUMBER,
				      p_calling_sequence	IN VARCHAR2) IS
  l_min_unit			NUMBER;
  l_precision			NUMBER;
  l_debug_loc	 		VARCHAR2(30) := 'Calc_PS_Dates_Percents_Amts';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
  l_discount_date		DATE;
  l_second_discount_date	DATE;
  l_third_discount_date		DATE;
  l_discount_amt_available	NUMBER;
  l_secnd_disc_amt_available	NUMBER;
  l_third_disc_amt_available	NUMBER;
  l_terms_calendar              VARCHAR2(30);

BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  l_debug_info := 'Get minimum_accountable_unit';
  print(l_debug_info, l_debug_loc); --bug 9162299

  SELECT nvl(minimum_accountable_unit,0), precision
  INTO l_min_unit, l_precision
  FROM fnd_currencies
  WHERE currency_code = ( SELECT payment_currency_code			-- R11: Xcurr
  	 		   FROM ap_invoices
         		   WHERE invoice_id = p_invoice_id);

  l_debug_info := 'l_min_unit '||l_min_unit||'l_precision '||l_precision;
  print(l_debug_info, l_debug_loc); --bug 9162299

  l_debug_info := 'Get calendar for terms lines';
  print(l_debug_info, l_debug_loc); --bug 9162299

  SELECT calendar
  INTO l_terms_calendar
  FROM ap_terms_lines
  WHERE term_id = p_term_id
   AND  sequence_num = p_ps_pay_num;

  l_debug_info := 'l_terms_calendar '||l_terms_calendar;
  print(l_debug_info, l_debug_loc); --bug 9162299

  l_debug_info := 'Get due date info';
  print(l_debug_info, l_debug_loc); --bug 9162299

  p_ppa_due_date := AP_CREATE_PAY_SCHEDS_PKG.Calc_Due_Date (
                                         p_start_date,
                                         p_term_id,
                                         l_terms_calendar,
                                         p_ps_pay_num,
                                         p_calling_sequence);

  l_debug_info := 'Get discount_amount.. etc';
  print(l_debug_info, l_debug_loc); --bug 9162299

  SELECT
  -- for first discount date
         decode(atl.fixed_date, NULL,
	   decode(atl.discount_days, NULL,
	     decode(atl.discount_day_of_month,
	       null, null,
	       to_date(to_char(
		least(nvl(atl.discount_day_of_month,32),    --2936672
		      to_number(to_char(
		       last_day(
			add_months(p_start_date,
		           nvl(atl.discount_months_forward ,0)+    --2936672
				   decode(t.due_cutoff_day,NULL,0,   --2936672
				    decode(
				      greatest(
					  least(NVL(t.due_cutoff_day, 32),
 					        to_number(to_char(last_day(p_start_date),'DD'))
						),
 					  to_number(to_char(p_start_date,'DD'))
					       ),
 				      to_number(to_char(p_start_date,'DD')),
				      1, 0)))
				), 'DD')))) || '-'
	        ||to_char(add_months(p_start_date,
			           nvl(atl.discount_months_forward ,0)+   --2936672
				   decode(t.due_cutoff_day,NULL,0,    --2936672
			              decode(
			               greatest(
			                  least(NVL(t.due_cutoff_day, 32),
 			                        to_number(to_char(last_day(p_start_date),'DD'))
						),
 			      		  to_number(to_char(p_start_date, 'DD'))),
 			   	       to_number(to_char(p_start_date, 'DD')),
			   	       1, 0))), 'MON-RR'),'DD/MM/RRRR')  --Bug 7534693
		),
	     p_start_date + atl.discount_days),
	  atl.fixed_date) DISCOUNT1,
  -- for second discount date
        decode(atl.fixed_date, NULL,
         decode(atl.discount_days_2, null,
	  decode(atl.discount_day_of_month_2, null, null,
	    to_date(to_char(
              least(nvl(atl.discount_day_of_month_2,32),    --2936672
	            to_number(to_char(
                      last_day(
                       add_months(p_start_date,
		           nvl(atl.discount_months_forward_2 ,0)+   --2936672
				   decode(t.due_cutoff_day,NULL,0,   --2936672
	                           decode(
                                    greatest(
                                       least(NVL(t.due_cutoff_day, 32),
	                                     to_number(to_char(last_day(p_start_date), 'DD'))),
	                               to_number(to_char(p_start_date, 'DD'))),
	                            to_number(to_char(p_start_date, 'DD')),
	                            1, 0)))), 'DD')))) || '-'
	    || to_char(add_months(p_start_date,
		           nvl(atl.discount_months_forward_2 ,0)+     --2936672
				   decode(t.due_cutoff_day,NULL,0,   --2936672
	                           decode(
                                     greatest(
                                        least(NVL(t.due_cutoff_day, 32),
	                                      to_number(to_char(last_day(p_start_date),'DD'))),
	                                to_number(to_char(p_start_date, 'DD'))),
	                             to_number(to_char(p_start_date,'DD')), 1, 0))), 'MON-RR'),'DD/MM/RRRR')), --Bug 7534693
	 p_start_date + atl.discount_days_2),
       atl.fixed_date) DISCOUNT2,
 -- for the third discount date
      decode(atl.fixed_date, NULL,
         decode(atl.discount_days_3, null,
	  decode(atl.discount_day_of_month_3, null, null,
	    to_date(to_char(
              least(nvl(atl.discount_day_of_month_3,32),   --2936672
	            to_number(to_char(
                      last_day(
                       add_months(p_start_date,
	                          NVL(atl.discount_months_forward_3,0) +   --2936672
				  decode(t.due_cutoff_day,NULL,0,      --2936672
	                           decode(
                                    greatest(
                                       least(NVL(t.due_cutoff_day, 32),
	                                     to_number(to_char(last_day(p_start_date), 'DD'))),
	                               to_number(to_char(p_start_date, 'DD'))),
	                            to_number(to_char(p_start_date, 'DD')),
	                            1, 0)))), 'DD')))) || '-'
	    || to_char(add_months(p_start_date,
		           nvl(atl.discount_months_forward_3 ,0)+   --2936672
				   decode(t.due_cutoff_day,NULL,0,   --2936672
	                           decode(
                                     greatest(
                                        least(NVL(t.due_cutoff_day, 32),
	                                      to_number(to_char(last_day(p_start_date),'DD'))),
	                                to_number(to_char(p_start_date, 'DD'))),
	                             to_number(to_char(p_start_date,'DD')), 1, 0))), 'MON-RR'),'DD/MM/RRRR')), --Bug 7534693
	 p_start_date + atl.discount_days_3),
       atl.fixed_date) DISCOUNT3,
  -- for discount_amt_available
          (DECODE(l_min_unit,0,
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent/100,
                         atl.due_amount) *
                      atl.discount_percent/100, 0),l_precision),
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent / 100,
                              atl.due_amount) *
                      atl.discount_percent/100, 0) / l_min_unit) * l_min_unit)),
  -- for secnd_disc_amt_available
	 (DECODE(l_min_unit,0,
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent / 100,
                              atl.due_amount) *
                      atl.discount_percent_2/100, 0),l_precision),
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent / 100,
                              atl.due_amount) *
                      atl.discount_percent_2/100, 0) / l_min_unit) * l_min_unit)),
 -- for third_disc_amt_available
	 (DECODE(l_min_unit,0,
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent / 100,
                              atl.due_amount) *
                      atl.discount_percent_3/100, 0),l_precision),
                ROUND(NVL(nvl(P_amount_applicable_to_disc * p_payment_cross_rate * atl.due_percent / 100,
                              atl.due_amount) *
                      atl.discount_percent_3/100, 0) / l_min_unit) * l_min_unit)),
/* Bug fix:1237758 */
         DECODE(l_min_unit,0,
               ROUND(NVL((p_total_pay_curr_amount * due_percent/100),
                              due_amount),l_precision),
               ROUND(NVL((p_total_pay_curr_amount * due_percent/100),
                              due_amount)/l_min_unit) * l_min_unit),
/* Bug fix:1237758 */
         DECODE(l_min_unit,0,
               ROUND(NVL((p_total_amount * due_percent/100),
                              due_amount / p_payment_cross_rate),l_precision),
               ROUND(NVL((p_total_amount * due_percent/100),
                 due_amount / p_payment_cross_rate)/ l_min_unit) * l_min_unit),

/*         nvl((p_total_pay_curr_amount * due_percent/100), due_amount),
         nvl((p_total_amount * due_percent/100), due_amount / p_payment_cross_rate),
*/

         nvl(atl.discount_percent,0),
	 nvl( atl.discount_percent_2,0),
         nvl( atl.discount_percent_3,0),
         nvl(due_amount,0),
         atl.due_percent
  INTO
         l_discount_date,
         l_second_discount_date,
	 l_third_discount_date,
         l_discount_amt_available,
	 l_secnd_disc_amt_available,
	 l_third_disc_amt_available,
	 p_gross_amount,
         p_inv_curr_gross_amount,         -- R11: Xcurr
         p_discount_percent_1,
         p_discount_percent_2,
         p_discount_percent_3,
         p_due_amount,
         p_due_percent
  FROM  ap_terms t, ap_terms_lines atl
  WHERE t.term_id = atl.term_id
  AND   atl.term_id = p_term_id
  AND   atl.sequence_num = p_ps_pay_num;

  l_debug_info := 'p_gross_amount '||p_gross_amount;
  print(l_debug_info, l_debug_loc); --bug 9162299

  --if last payment term is defined as 0 then return sum of due_amounts
  --till before the last term for p_gross_amount and p_inv_curr_gross_amount
  --bug 9162299 begin:
   IF p_due_amount = 0 and p_due_percent is null then

      Select sum(DECODE(l_min_unit,0,
               ROUND(due_amount,l_precision),
               ROUND(due_amount/l_min_unit) * l_min_unit)),
             sum(DECODE(l_min_unit,0,
               ROUND(due_amount / p_payment_cross_rate,l_precision),
               ROUND((due_amount / p_payment_cross_rate)/ l_min_unit) * l_min_unit))
         into p_gross_amount,
              p_inv_curr_gross_amount
      FROM  ap_terms t, ap_terms_lines atl
     WHERE t.term_id = atl.term_id
     AND atl.term_id = p_term_id
     AND atl.sequence_num < p_ps_pay_num;

   end if;
  --bug 9162299 end

  --
  -- Null out NOCOPY the discount infomation if discount amount = 0
  --
  if (l_discount_amt_available = 0) then
   p_discount_amt_available := '';
   p_discount_date := '';
  else
   p_discount_amt_available := l_discount_amt_available;
   p_discount_date :=l_discount_date;
  end if;

  if (l_secnd_disc_amt_available = 0) then
   p_secnd_disc_amt_available := '';
   p_second_discount_date := '';
  else
   p_secnd_disc_amt_available := l_secnd_disc_amt_available;
   p_second_discount_date := l_second_discount_date;
  end if;

  if (l_third_disc_amt_available = 0) then
   p_third_disc_amt_available := '';
   p_third_discount_date := '';
  else
   p_third_disc_amt_available := l_third_disc_amt_available;
   p_third_discount_date := l_third_discount_date;
  end if;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  ' Invoice_id  = '|| to_char(p_invoice_id)
               || ' Term Id  = '|| to_char(p_term_id)
               || ' PS Pay Num  = '|| to_char(p_ps_pay_num)
	       || ' p_start_date  = '|| to_char(p_start_date)
	       || ' p_total_amount  = '|| to_char(p_total_amount)
	       || ' P_amount_applicable_to_disc ='|| to_char(P_amount_applicable_to_disc)
	       || ' p_payment_cross_rate  = '|| to_char(p_payment_cross_rate)
	       || ' l_min_unit  = '|| to_char(l_min_unit)
	       || ' l_precision  = '|| to_char(l_precision));

      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_PS_Dates_Percents_Amts;

--============================================================================
-- INSERT_PAY_SCHED:  Procedure to insert a new payment schedule line
--============================================================================
PROCEDURE Insert_Pay_Sched(p_invoice_id			IN NUMBER,
		  	   p_ps_pay_num			IN NUMBER,
	  		   p_system_user		IN NUMBER,
        		   p_payment_cross_rate		IN NUMBER,
	  		   p_due_date			IN DATE,
	  		   p_1st_discount_date		IN DATE,
	  		   p_2nd_discount_date		IN DATE,
        		   p_3rd_discount_date		IN DATE,
        		   p_gross_amount		IN NUMBER,
                           p_inv_curr_gross_amount      IN NUMBER,    -- R11: Xcurr
	  		   p_1st_disc_amt_available	IN NUMBER,
	  		   p_2nd_disc_amt_available	IN NUMBER,
           		   p_3rd_disc_amt_available	IN NUMBER,
	  	   	   p_payment_priority		IN NUMBER,
	  		   p_hold_flag			IN VARCHAR2,
                 	   p_payment_status_flag	IN VARCHAR2,
	  		   p_batch_id			IN NUMBER,
	  		   p_creation_date		IN DATE,
                	   p_created_by			IN NUMBER,
	  		   p_last_update_login		IN NUMBER,
                 	   p_payment_method_code        IN VARCHAR2, --4552701
			   p_external_bank_account_id	IN NUMBER,
			   p_percent_remain_vs_gross    IN NUMBER,
			   p_calling_sequence		IN VARCHAR2) IS
  l_debug_loc	 		VARCHAR2(30) := 'Insert_Pay_Sched';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
  l_pay_curr_code		VARCHAR2(15);
  /* Bug 3700128. MOAC Project */
  l_org_id                      NUMBER (15);

BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  -- get payment currency code for rounding
  SELECT payment_currency_code, org_id
  INTO	 l_pay_curr_code, l_org_id  /* Bug 3700128. MOAC Project */
  FROM 	 ap_invoices
  WHERE  invoice_id = p_invoice_id;


  INSERT INTO ap_payment_schedules
		(invoice_id,
		payment_num,
		last_updated_by,
		last_update_date,
        	payment_cross_rate,
		due_date,
		discount_date,
		gross_amount,
                inv_curr_gross_amount,         -- R11: Xcurr
   		discount_amount_available,
		amount_remaining,
		discount_amount_remaining,
           	payment_priority,
		hold_flag,
		payment_status_flag,
		batch_id,
         	creation_date,
		created_by,
		last_update_login,
        	payment_method_code,  --4552701
		external_bank_account_id,
		second_discount_date,
        	third_discount_date,
		second_disc_amt_available,
        	third_disc_amt_available,
         	org_id ) /* Bug 3700128. MOAC Project */
  VALUES (p_invoice_id,
	  p_ps_pay_num,
	  p_system_user,
	  sysdate,
          p_payment_cross_rate,
	  p_due_date,
	  p_1st_discount_date,
          p_gross_amount,
          p_inv_curr_gross_amount,            -- R11: Xcurr
	  p_1st_disc_amt_available,
	  ap_utilities_pkg.ap_round_currency(
          p_gross_amount * nvl(p_percent_remain_vs_gross,1),
		 l_pay_curr_code ),
          p_1st_disc_amt_available,
	  p_payment_priority,
	  p_hold_flag,
          p_payment_status_flag,
	  p_batch_id,
	  p_creation_date,
          p_created_by,
	  p_last_update_login,
          p_payment_method_code,  --4552701
          p_external_bank_account_id,
	  p_2nd_discount_date,
          p_3rd_discount_date,
	  p_2nd_disc_amt_available,
          p_3rd_disc_amt_available,
	  l_org_id); /* Bug 3700128. MOAC Project */

   --Bug 4539462 DBI logging
   AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'I',
               p_key_value1 => p_invoice_id,
               p_key_value2 => p_ps_pay_num,
                p_calling_sequence => l_curr_calling_sequence);

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
	       || 'Pay Sched Pay Num = '|| to_char(p_ps_pay_num)
	       || 'System User = '|| to_char(p_system_user)
	       || 'Pay Cross Rate = '|| to_char(p_payment_cross_rate)
	       || 'Due Date = '|| to_char(p_due_date)
	       || '1st Disc Date = '|| to_char(p_1st_discount_date)
	       || '2nd Disc Date = '|| to_char(p_2nd_discount_date)
	       || '3rd Disc Date = '|| to_char(p_3rd_discount_date)
	       || 'Gross Amount = '|| to_char(p_gross_amount)
	       || '1st Disc Amt Avail = '|| to_char(p_1st_disc_amt_available)
	       || '2nd Disc Amt Avail = '|| to_char(p_2nd_disc_amt_available)
	       || '3rd Disc Amt Avail = '|| to_char(p_3rd_disc_amt_available)
	       || 'Payment Priority = '|| to_char(p_payment_priority)
	       || 'Hold Flag = '|| p_hold_flag
	       || 'Payment Status Flag = '|| p_payment_status_flag
               || 'Batch_id  = '|| to_char(p_batch_id)
	       || 'Creation Date = '|| to_char(p_creation_date)
               || 'Created By  = '|| to_char(p_created_by)
               || 'Last Update Login  = '|| to_char(p_last_update_login)
               || 'Payment Method  = '|| p_payment_method_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Insert_Pay_Sched;

--============================================================================
-- CREATE_PAY_SCHEDS:  Procedure to create new payment schedules
--============================================================================

PROCEDURE Create_Pay_Scheds(p_invoice_id		IN NUMBER,
			    p_curr_ps_pay_num		IN NUMBER,
	  	   	    p_system_user		IN NUMBER,
			    p_start_date		IN DATE,
			    p_total_gross_amount	IN NUMBER,
                            p_total_inv_curr_gross_amount
                                                        IN NUMBER,    -- R11: Xcurr
			    p_amount_applicable_to_disc IN NUMBER,
          	            p_payment_cross_rate	IN NUMBER,
			    p_term_id			IN NUMBER,
			    p_last_term_ps_pay_num	IN NUMBER,
	  	   	    p_payment_priority		IN NUMBER,
	  	            p_hold_flag			IN VARCHAR2,
          	            p_payment_status_flag	IN VARCHAR2,
	  	            p_batch_id			IN NUMBER,
	  	            p_creation_date		IN DATE,
          	            p_created_by		IN NUMBER,
	  	            p_last_update_login		IN NUMBER,
          	            p_payment_method_code       IN VARCHAR2, --4552701
			    p_external_bank_account_id	IN NUMBER,
				p_percent_remain_vs_gross	IN NUMBER,
			    p_calling_sequence		IN VARCHAR2) IS
  l_last_inv_ps_pay_num		 NUMBER;
  l_last_term_ps_pay_num	 NUMBER;
  l_ppa_due_date		 DATE;
  l_1st_discount_date		 DATE;
  l_2nd_discount_date		 DATE;
  l_3rd_discount_date		 DATE;
  l_1st_disc_amt_available	 NUMBER;
  l_2nd_disc_amt_available	 NUMBER;
  l_3rd_disc_amt_available	 NUMBER;
  l_gross_amount		 NUMBER;
  l_inv_curr_gross_amount        NUMBER;     -- R11: Xcurr
  l_disc_percent_1		 NUMBER;
  l_disc_percent_2		 NUMBER;
  l_disc_percent_3		 NUMBER;
  l_due_amount			 NUMBER;
  l_due_percent			 NUMBER;
  l_sub_total			 NUMBER := 0; --bug 9162299 :added default value
  l_sub_total_inv                NUMBER := 0; -- R11: Xcurr --bug 9162299: added default value
  l_curr_ps_pay_num		NUMBER;
  l_debug_loc	 		VARCHAR2(30) := 'Create_Pay_Scheds';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(100);
BEGIN

  --AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --
  l_debug_info := 'p_curr_ps_pay_num'||p_curr_ps_pay_num||'p_last_term_ps_pay_num'||p_last_term_ps_pay_num;
  print(l_debug_info,l_debug_loc); --bug 9162299

  l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  l_curr_ps_pay_num := p_curr_ps_pay_num;

  WHILE (l_curr_ps_pay_num <= p_last_term_ps_pay_num) LOOP

  --------------------------------------------------------------
  l_debug_info := 'Calc Payment Schedule Dates, Percents, Amts';
  --               given invoice_id, term_id and payment num  --
  --------------------------------------------------------------
  print(l_debug_info,l_debug_loc); --bug 9162299
  -------------------------------

  Calc_PS_Dates_Percents_Amts(p_invoice_id,
			      p_term_id,
			      l_curr_ps_pay_num,
			      p_start_date,
			      p_total_gross_amount,
				  p_total_inv_curr_gross_amount,    -- R11: Xcurr
			      p_amount_applicable_to_disc,
			      p_payment_cross_rate,
			      l_ppa_due_date,
			      l_1st_discount_date,
			      l_2nd_discount_date,
			      l_3rd_discount_date,
			      l_1st_disc_amt_available,
			      l_2nd_disc_amt_available,
			      l_3rd_disc_amt_available,
			      l_gross_amount,
                  l_inv_curr_gross_amount,         -- R11: Xcurr
			      l_disc_percent_1,
			      l_disc_percent_2,
			      l_disc_percent_3,
			      l_due_amount,
			      l_due_percent,
			      l_curr_calling_sequence);

  l_debug_info := 'l_sub_total'||l_sub_total||'l_gross_amount'||l_gross_amount;
  print(l_debug_info,l_debug_loc); --bug 9162299

  l_debug_info := 'l_sub_total_inv'||l_sub_total_inv||'l_inv_curr_gross_amount'||l_inv_curr_gross_amount;
  print(l_debug_info,l_debug_loc); --bug 9162299

  l_sub_total := l_sub_total + l_gross_amount;
  l_sub_total_inv := l_sub_total_inv + l_inv_curr_gross_amount;   -- R11: Xcurr

  l_debug_info := 'l_due_amount'||l_due_amount||'l_due_percent'||l_due_percent;
  print(l_debug_info,l_debug_loc); --bug 9162299

  IF ((l_due_amount = 0) AND (l_due_percent IS NULL)) THEN

    --------------------------------------------------------------------
    -- Set gross_amount to the remainder of the invoice_amount and    --
    -- set the last_term_ps_payment_number to the current payment     --
    -- number as it is the last payment number that will be updated.  --
    -- Also calculate the discount amounts of this line.              --
    --------------------------------------------------------------------

    l_gross_amount := p_total_gross_amount - l_sub_total;
    l_inv_curr_gross_amount := p_total_inv_curr_gross_amount - l_sub_total_inv;  -- R11: Xcurr
    l_1st_disc_amt_available := l_gross_amount * l_disc_percent_1;
    l_2nd_disc_amt_available := l_gross_amount * l_disc_percent_2;
    l_3rd_disc_amt_available := l_gross_amount * l_disc_percent_3;
    l_last_term_ps_pay_num := l_curr_ps_pay_num;

  END IF;

  l_debug_info := 'l_gross_amount'||l_gross_amount||'l_last_term_ps_pay_num'||l_last_term_ps_pay_num;
  print(l_debug_info,l_debug_loc); --bug 9162299

  -------------------------------------------
  l_debug_info := 'Insert Payment Schedules';
  -------------------------------------------
   print(l_debug_info,l_debug_loc); --bug 9162299
  -------------------------------

  Insert_Pay_Sched(p_invoice_id,
		   l_curr_ps_pay_num,
	  	   p_system_user,
          	   p_payment_cross_rate,
	  	   l_ppa_due_date,
	  	   l_1st_discount_date,
	  	   l_2nd_discount_date,
          	   l_3rd_discount_date,
          	   l_gross_amount,
                   l_inv_curr_gross_amount,    -- R11: Xcurr
	  	   l_1st_disc_amt_available,
	  	   l_2nd_disc_amt_available,
          	   l_3rd_disc_amt_available,
	  	   p_payment_priority,
	  	   p_hold_flag,
          	   p_payment_status_flag,
	  	   p_batch_id,
	  	   p_creation_date,
          	   p_created_by,
	  	   p_last_update_login,
          	   p_payment_method_code, --4552701
		   p_external_bank_account_id,
		   p_percent_remain_vs_gross,
		   l_curr_calling_sequence);

    l_curr_ps_pay_num := l_curr_ps_pay_num + 1;

  END LOOP;

  --AP_LOGGING_PKG.AP_End_Block(l_debug_loc);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
               || 'Cur PS Pay Num  = '|| to_char(p_curr_ps_pay_num)
               || 'System User  = '|| to_char(p_system_user)
               || 'Payment Cross Rate  = '|| to_char(p_payment_cross_rate)
               || 'Term_id  = '|| to_char(p_term_id)
               || 'Last Term PS Pay Num  = '|| to_char(p_last_term_ps_pay_num)
               || 'Pay Priority  = '|| to_char(p_payment_priority)
               || 'Hold Flag  = '|| p_hold_flag
               || 'Payment Status Flag  = '|| p_payment_status_flag
               || 'Batch Id = '|| to_char(p_batch_id)
               || 'Creation Date = '|| to_char(p_creation_date)
               || 'Created By = '|| to_char(p_created_by)
               || 'Last Update Login = '|| to_char(p_last_update_login)
               || 'Payment Method Lookup = '|| p_payment_method_code
		||' p_external_bank_account_id = '||to_char(p_external_bank_account_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Create_Pay_Scheds;


-- Short-named procedure for logging

PROCEDURE Log(p_msg 	IN VARCHAR2,
	      p_loc	IN VARCHAR2) IS
BEGIN
  null;
  --AP_LOGGING_PKG.AP_Log(p_msg, p_loc);
END Log;


--2189242, added procedure below

Procedure Adj_Pay_Sched_For_Round (p_invoice_id in number,
                                   p_calling_sequence varchar2) IS

  l_pay_sched_total             NUMBER;
  l_pay_curr_invoice_amount     NUMBER;
  l_debug_loc                   VARCHAR(200);
  l_curr_calling_sequence       VARCHAR(2000);
  l_key_value			NUMBER;

BEGIN

l_debug_loc := 'Update ap_payment_schedules - set gross_amount';
l_curr_calling_sequence := 'AP_PPA_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

    SELECT SUM(gross_amount)
    INTO l_pay_sched_total
    FROM   ap_payment_schedules
    WHERE invoice_id = P_Invoice_Id;

    SELECT nvl(pay_curr_invoice_amount,invoice_amount) pay_curr_invoice_amount
    INTO l_pay_curr_invoice_amount
    FROM ap_invoices
    WHERE invoice_id = p_invoice_id;

     -- Adjust Payment Schedules for rounding errors
      IF (l_pay_sched_total <> l_Pay_Curr_Invoice_Amount) THEN


         UPDATE AP_PAYMENT_SCHEDULES
             SET gross_amount = gross_amount + TO_NUMBER(l_Pay_Curr_Invoice_Amount) -
             TO_NUMBER(l_pay_sched_total),
                 amount_remaining=amount_remaining + TO_NUMBER(l_Pay_Curr_Invoice_Amount) -
                 TO_NUMBER(l_pay_sched_total)
             WHERE invoice_id = P_Invoice_Id
             AND payment_num = (SELECT MAX(payment_num)
                                    FROM   ap_payment_schedules
                                        WHERE  invoice_id = P_Invoice_Id);

	  --Bug 4539462 DBI logging
     	  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value1 => p_invoice_id,
 	       p_key_value2 => l_key_value,
                p_calling_sequence => l_curr_calling_sequence);

       END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;


END Adj_Pay_Sched_For_Round;

--bug 9162299 : Added private procedure to enhance debugging and replace the log procedure
PROCEDURE Print(p_debug_info IN VARCHAR2,
	        p_api_name   IN VARCHAR2) IS
BEGIN
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,p_debug_info);
  END IF;
END Print;

END AP_PPA_PKG;

/
