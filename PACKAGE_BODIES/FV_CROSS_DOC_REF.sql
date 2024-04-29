--------------------------------------------------------
--  DDL for Package Body FV_CROSS_DOC_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CROSS_DOC_REF" as
/* $Header: FVDOCCRB.pls 120.12 2003/12/17 21:20:05 ksriniva ship $  */
  g_module_name VARCHAR2(100) := 'fv.plsql.fv_cross_doc_ref.';

	vp_vendor_id      po_vendors.vendor_id%TYPE;
	vp_vendor_site_id po_vendor_sites.vendor_site_id%TYPE;
	vp_po_header_id	  po_headers.po_header_id%TYPE;
	vp_po_date po_headers.creation_date%TYPE;
	vp_requisition_header_id po_requisition_headers.requisition_header_id%TYPE;
	vp_requisition_line_id po_requisition_lines.requisition_line_id%TYPE;
	vp_req_date po_requisition_headers.creation_date%TYPE;
	vp_shipment_header_id rcv_shipment_headers.shipment_header_id%TYPE;
	vp_rec_date rcv_shipment_headers.creation_date%TYPE;
	vp_buyer po_headers.agent_id%TYPE;
	vp_invoice_id ap_invoices.invoice_id%TYPE;
	vp_invoice_date ap_invoices.invoice_date%TYPE;
	vp_invoice_amount ap_invoices.invoice_amount%TYPE;
	vp_invoice_type ap_invoices.invoice_type_lookup_code%TYPE;
	vp_check_id ap_checks.check_id%TYPE;
	vp_check_date ap_checks.creation_date%TYPE;
	vp_amount ap_checks.amount%TYPE;
	vp_treasury_pay_number ap_checks.treasury_pay_number%TYPE;
	vp_treasury_pay_date ap_checks.treasury_pay_date%TYPE;
	vp_valid_req_supplier NUMBER;
	vp_supplier_name po_vendors.vendor_name%TYPE;
	vp_supplier_site po_vendor_sites.vendor_site_code%TYPE;
        vp_session_id NUMBER;

 PROCEDURE po_master;
 PROCEDURE req_master;
 PROCEDURE rec_master;
 PROCEDURE inv_master;
 PROCEDURE pay_master;


-----------------------------------------------------------------------
--				MAIN
----------------------------------------------------------------------

PROCEDURE main
	(
		p_vendor_id		  IN po_vendors.vendor_id%TYPE ,
		p_vendor_site_id	  IN po_vendor_sites.vendor_site_id%TYPE ,
		p_po_header_id		  IN  po_headers.po_header_id%TYPE,
		p_po_date		  IN po_headers.creation_date%TYPE,
		p_requisition_header_id   IN po_requisition_headers.requisition_header_id%TYPE,
		p_requisition_line_id     IN po_requisition_lines.requisition_line_id%TYPE,
		p_req_date		  IN po_requisition_headers.creation_date%TYPE,
		p_shipment_header_id	  IN rcv_shipment_headers.shipment_header_id%TYPE,
		p_receipt_date		  IN rcv_shipment_headers.creation_date%TYPE,
		p_buyer			  IN po_headers.agent_id%TYPE,
		p_invoice_id		  IN ap_invoices.invoice_id%TYPE,
		p_invoice_date		  IN ap_invoices.invoice_date%TYPE ,
		p_invoice_amount	  IN ap_invoices.invoice_amount%TYPE ,
		p_invoice_type	          IN ap_invoices.invoice_type_lookup_code%TYPE ,
		p_check_id	          IN ap_checks.check_id%TYPE,
		p_check_date		  IN ap_checks.creation_date%TYPE,
		p_amount		  IN ap_checks.amount%TYPE,
		p_treasury_pay_number     IN ap_checks.treasury_pay_number%TYPE,
		p_treasury_pay_date       IN ap_checks.treasury_pay_date%TYPE,
		p_valid_req_supplier      IN NUMBER,
		p_supplier_name           IN po_vendors.vendor_name%TYPE,
		p_supplier_site           IN po_vendor_sites.vendor_site_code%TYPE,
		p_result 		  IN VARCHAR2,
		p_err_code    		  OUT NOCOPY NUMBER,
	        p_session_id	          IN  NUMBER


 	) IS
  l_module_name VARCHAR2(200) := g_module_name || 'main';
  l_errbuf      VARCHAR2(1024);

BEGIN

	vp_vendor_id	         :=  p_vendor_id;
	vp_vendor_site_id	 := p_vendor_site_id;
	vp_po_header_id		 := p_po_header_id;
	vp_po_date		 := p_po_date;
	vp_requisition_header_id := p_requisition_header_id;
	vp_req_date		 := p_req_date;
	vp_shipment_header_id    := p_shipment_header_id;
	vp_rec_date		 := p_receipt_date;
	vp_buyer		 := p_buyer;
	vp_invoice_id := p_invoice_id;
	vp_invoice_date := p_invoice_date;
	vp_invoice_amount := p_invoice_amount;
	vp_invoice_type := p_invoice_type;
	vp_check_id :=	p_check_id;
	vp_check_date := p_check_date;
	vp_amount := p_amount;
	vp_treasury_pay_number := p_treasury_pay_number;
	vp_treasury_pay_date :=	p_treasury_pay_date;
	vp_valid_req_supplier	 :=	p_valid_req_supplier;
	vp_supplier_name := p_supplier_name;
	vp_supplier_site := p_supplier_site;
	vp_session_id := p_session_id;
	IF    p_result = 'PO'  THEN
	   po_master;
	ELSIF p_result = 'REQ' THEN
	   req_master;
	ELSIF p_result = 'REC' THEN
	   rec_master;
	ELSIF p_result = 'INV' THEN
	   inv_master;
	ELSIF p_result = 'PAY' THEN
	   pay_master;
	END IF;
EXCEPTION
   WHEN OTHERS THEN
     p_err_code := -1;
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);

END MAIN;


PROCEDURE po_master  IS
  l_module_name VARCHAR2(200) := g_module_name || 'po_master';
  l_errbuf      VARCHAR2(1024);

	CURSOR po_cur IS
	SELECT ph.po_header_id,pl.po_line_id,pll.line_location_id
	FROM po_headers ph,po_lines pl,po_line_locations pll
	WHERE ph.po_header_id = pl.po_header_id
	AND pl.po_line_id = pll.po_line_id
	AND vendor_id = vp_vendor_id
	AND vendor_site_id = vp_vendor_site_id
	AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
	AND TRUNC(ph.creation_date) = nvl(vp_po_date,TRUNC(ph.creation_date))
	AND ph.agent_id = nvl(vp_buyer,ph.agent_id)
	AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	UNION
	SELECT ph.po_header_id,pl.po_line_id,pll.line_location_id
	FROM po_headers ph,po_lines pl,po_line_locations pll
	WHERE ph.po_header_id = pl.po_header_id
	AND pl.po_line_id = pll.po_line_id
	AND vendor_id = vp_vendor_id
	AND vendor_site_id = vp_vendor_site_id
	AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
	AND TRUNC(ph.creation_date) = nvl(vp_po_date,TRUNC(ph.creation_date))
	AND ph.agent_id = nvl(vp_buyer,ph.agent_id)
	AND  EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id
		    AND po_header_id = ph.po_header_id AND po_line_id = pl.po_line_id);
	po_rec    po_cur%ROWTYPE;

	 CURSOR req_cur IS
	SELECT ph.po_header_id,pl.po_line_id, pll.line_location_id
	FROM po_headers ph,po_lines pl,po_line_locations pll
	WHERE ph.po_header_id = pl.po_header_id
	AND pl.po_line_id = pll.po_line_id
	AND EXISTS(SELECT   prh.requisition_header_id,prl.requisition_line_id
		FROM po_requisition_headers prh,po_requisition_lines prl
		WHERE prh.requisition_header_id = prl.requisition_header_id
		AND authorization_status = 'APPROVED'
		AND prl.line_location_id = pll.line_location_id
		AND prl.suggested_vendor_location = vp_supplier_site
		AND prl.suggested_vendor_name = vp_supplier_name
		AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id)
		AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))
     UNION
	SELECT  rh.requisition_header_id,rh.requisition_line_id
	FROM (SELECT DISTINCT  prh.requisition_header_id,
		prl.requisition_line_id,prl.line_location_id
		FROM po_requisition_headers prh,po_requisition_lines prl
		WHERE prl.requisition_header_id = prh.requisition_header_id
		AND authorization_status = 'APPROVED'
		AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id)
		AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))) rh,
	po_line_locations plx,po_headers ph
	WHERE  plx.line_location_id = rh.line_location_id
	AND plx.po_header_id = ph.po_header_id
	AND ph.vendor_id = vp_vendor_id
	AND rh.line_location_id = pll.line_location_id
	AND ph.vendor_site_id = vp_vendor_site_id
	AND NOT EXISTS (SELECT 1 FROM po_vendors pv,po_requisition_lines prl,po_vendor_sites pvs
          WHERE prl.suggested_vendor_name = pv.vendor_name
          AND prl.suggested_vendor_location = pvs.vendor_site_code
          AND prl.requisition_line_id = rh.requisition_line_id ));


      req_rec    req_cur%ROWTYPE;

     CURSOR rec_cur IS
		SELECT ph.po_header_id,pll.po_line_id,pll.line_location_id
			FROM po_headers ph,po_line_locations pll
		WHERE ph.po_header_id = pll.po_header_id
		AND vendor_id = vp_vendor_id
		AND vendor_site_id = vp_vendor_site_id
		AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
		AND EXISTS (SELECT 1 FROM rcv_transactions rt
		    WHERE rt.po_header_id = ph.po_header_id
		    AND rt.po_line_id = pll.po_line_id
		    AND rt.po_line_location_id = pll.line_location_id
		    AND EXISTS (SELECT 1 from rcv_shipment_headers rsh
		       WHERE rsh.shipment_header_id = rt.shipment_header_id
		       AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
		       AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date))))
			UNION
		SELECT ph.po_header_id,pll.po_line_id ,pll.line_location_id
			FROM po_headers ph,po_line_locations pll
		WHERE ph.po_header_id = pll.po_header_id
		AND vendor_id = vp_vendor_id
		AND vendor_site_id = vp_vendor_site_id
		AND EXISTS (SELECT 1 FROM fv_doc_cr_temp  fst
		   WHERE fst.po_header_id = ph.po_header_id
		   AND fst.po_line_id = pll.po_line_id
		   AND fst.po_line_location_id = pll.line_location_id
                   AND fst.session_id = vp_session_id)
		AND EXISTS (SELECT 1 FROM rcv_transactions rt
		    WHERE rt.po_header_id = ph.po_header_id
		    AND rt.po_line_id = pll.po_line_id
		    AND rt.po_line_location_id = pll.line_location_id
		    AND EXISTS (SELECT 1 from rcv_shipment_headers rsh
		       WHERE rsh.shipment_header_id = rt.shipment_header_id
		       AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
		       AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date))));

		     rec_rec    rec_cur%ROWTYPE;
     CURSOR inv_cur IS
	SELECT ph.po_header_id,pll.po_line_id,pll.line_location_id FROM po_headers ph,po_line_locations pll
	WHERE ph.po_header_id = pll.po_header_id
	 AND vendor_id = vp_vendor_id
	 AND vendor_site_id = vp_vendor_site_id
	 AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	 AND (EXISTS (SELECT 1 FROM po_distributions pd
	   WHERE pd.po_header_id = ph.po_header_id
	   AND pd.line_location_id = pll.line_location_id
	   AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
	    WHERE ia.po_distribution_id= pd.po_distribution_id
	    AND EXISTS (SELECT 1 FROM ap_invoices ap
	     WHERE invoice_id = ia.invoice_id
	     AND invoice_id = NVL(vp_invoice_id,invoice_id)
	     AND TRUNC(ap.invoice_date) = NVL(vp_invoice_date,TRUNC(ap.invoice_date))
	     AND invoice_type_lookup_code = NVL(vp_invoice_type,invoice_type_lookup_code)
	     AND invoice_amount = nvl(vp_invoice_amount,invoice_amount))))
	     OR EXISTS (SELECT 1 FROM rcv_transactions rt
		WHERE rt.po_header_id = ph.po_header_id
		AND rt.po_line_location_id = pll.line_location_id
		AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
		 WHERE ia.rcv_transaction_id= rt.transaction_id
		 AND EXISTS (SELECT 1 FROM ap_invoices ap
		  WHERE invoice_id = ia.invoice_id
		  AND invoice_id = NVL(vp_invoice_id,invoice_id)
		  AND TRUNC(ap.invoice_date) = NVL(vp_invoice_date,TRUNC(ap.invoice_date))
		  AND invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
		  AND invoice_amount = nvl(vp_invoice_amount,invoice_amount)))))
	UNION
	SELECT ph.po_header_id,pll.po_line_id ,pll.line_location_id FROM po_headers ph,po_line_locations pll
	WHERE vendor_id = vp_vendor_id
	AND ph.po_header_id = pll.po_header_id
	AND vendor_site_id = vp_vendor_site_id
	AND EXISTS (SELECT 1 FROM fv_doc_cr_temp  fst
	 WHERE fst.po_header_id = ph.po_header_id
	 AND fst.po_line_id = pll.po_line_id
	 AND fst.po_line_location_id = pll.line_location_id
	 AND fst.session_id = vp_session_id)
	 AND (EXISTS (SELECT 1 FROM po_distributions pd
	  WHERE pd.po_header_id = ph.po_header_id
	  AND pd.line_location_id = pll.line_location_id
	  AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
	   WHERE ia.po_distribution_id= pd.po_distribution_id
	   AND EXISTS (SELECT 1 FROM ap_invoices ap
	    WHERE invoice_id = ia.invoice_id
	    AND invoice_id = NVL(vp_invoice_id,invoice_id)
	    AND TRUNC(ap.invoice_date) =NVL(vp_invoice_date,TRUNC(ap.invoice_date))
	    AND invoice_type_lookup_code =NVL(vp_invoice_type,invoice_type_lookup_code)
	    AND invoice_amount = nvl(vp_invoice_amount,invoice_amount))))
	    OR EXISTS (SELECT 1 FROM rcv_transactions rt
	     WHERE rt.po_header_id = ph.po_header_id
	     AND rt.po_line_location_id = pll.line_location_id
	     AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
	      WHERE ia.rcv_transaction_id= rt.transaction_id
	      AND EXISTS (SELECT 1 FROM ap_invoices ap
	       WHERE invoice_id = ia.invoice_id
	       AND invoice_id = NVL(vp_invoice_id,invoice_id)
	       AND TRUNC(ap.invoice_date) = nvl(vp_invoice_date,TRUNC(ap.invoice_date))
	       AND invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
	       AND invoice_amount = nvl(vp_invoice_amount,invoice_amount)))));

      inv_rec inv_cur%ROWTYPE;

      CURSOR pay_cur IS
      SELECT ph.po_header_id,pll.po_line_id,pll.line_location_id
	FROM po_headers ph,po_line_locations pll
	WHERE ph.po_header_id = pll.po_header_id
	AND vendor_id = vp_vendor_id
	AND vendor_site_id = vp_vendor_site_id
	AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp
                       WHERE session_id = vp_session_id)
	AND EXISTS (SELECT   1 from po_distributions pd
	 WHERE pd.po_header_id = ph.po_header_id
	 AND pd.line_location_id = pll.line_location_id
	 AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	   WHERE aid.po_distribution_id = pd.po_distribution_id
	   AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	    WHERE aip.invoice_id = aid.invoice_id
	    AND EXISTS (SELECT 1 FROM ap_checks ac
	     WHERE ac.check_id = aip.check_id
	     AND ac.check_id =  NVL(vp_check_id,ac.check_id)
	     AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
	     AND ac.amount = nvl(vp_amount,ac.amount)
	     AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
	     AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                  OR vp_treasury_pay_date IS NULL)))))
	    OR EXISTS (SELECT   1 from rcv_transactions rt
	    WHERE rt.po_header_id = ph.po_header_id
	    AND rt.po_line_location_id = pll.line_location_id
	    AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	     WHERE aid.rcv_transaction_id = rt.transaction_id
	     AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	      WHERE aip.invoice_id = aid.invoice_id
	      AND EXISTS (SELECT 1 FROM ap_checks ac
	       WHERE ac.check_id = aip.check_id
	       AND ac.check_id =  NVL(vp_check_id,ac.check_id)
	       AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
	       AND ac.amount = nvl(vp_amount,ac.amount)
	       AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
	       AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                    OR vp_treasury_pay_date IS NULL))))))
      UNION
	SELECT ph.po_header_id,pll.po_line_id,pll.line_location_id
	FROM po_headers ph,po_line_locations pll
	WHERE ph.po_header_id = pll.po_header_id
	AND EXISTS (SELECT 1 FROM fv_doc_cr_temp  fst
	 WHERE fst.po_header_id = ph.po_header_id
	 AND fst.po_line_id = pll.po_line_id
         AND fst.po_line_location_id = pll.line_location_id
         AND fst.session_id = vp_session_id)
	AND vendor_id = vp_vendor_id
	AND vendor_site_id = vp_vendor_site_id
	AND EXISTS (SELECT   1 from po_distributions pd
	 WHERE pd.po_header_id = ph.po_header_id
	 AND pd.line_location_id = pll.line_location_id
	 AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	      WHERE aid.po_distribution_id = pd.po_distribution_id
	      AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	       WHERE aip.invoice_id = aid.invoice_id
	       AND EXISTS (SELECT 1 FROM ap_checks ac
	        WHERE ac.check_id = aip.check_id
		AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
		AND ac.amount = nvl(vp_amount,ac.amount)
		AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
		AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                      OR vp_treasury_pay_date IS NULL)))))
	OR EXISTS (SELECT   1 from rcv_transactions rt
	    WHERE rt.po_header_id = ph.po_header_id
	    AND rt.po_line_location_id = pll.line_location_id
	    AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.rcv_transaction_id = rt.transaction_id
		AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	         WHERE aip.invoice_id = aid.invoice_id
		 AND EXISTS (SELECT 1 FROM ap_checks ac
		  WHERE ac.check_id = aip.check_id
		  AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		  AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
		  AND ac.amount = nvl(vp_amount,ac.amount)
		  AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
	          AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                       OR vp_treasury_pay_date IS NULL))))));

	pay_rec  pay_cur%ROWTYPE;
  BEGIN
     DELETE FROM fv_doc_cr_temp
	WHERE session_id = vp_session_id;
 	LOOP
          IF (vp_requisition_header_id  IS NOT NULL OR  vp_req_date IS NOT NULL) THEN
	      OPEN req_cur;
	      DELETE FROM fv_doc_cr_temp
		WHERE session_id = vp_session_id;
	         LOOP
	              FETCH req_cur INTO req_rec;
	              EXIT WHEN   req_cur%NOTFOUND;
		     INSERT INTO fv_doc_cr_temp (po_header_id,po_line_id,po_line_location_id,session_id)
		     VALUES (req_rec.po_header_id,req_rec.po_line_id,req_rec.line_location_id,vp_session_id);
	         END LOOP;
	         IF NOT (req_cur%rowcount <> 0 ) THEN
		    DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
		    CLOSE req_cur;
		    EXIT;
	         END IF;
	         CLOSE req_cur;
	      END IF;
	  IF  (vp_po_header_id   IS NOT NULL OR vp_po_date IS NOT NULL OR  vp_buyer IS NOT NULL) THEN
  	    OPEN po_cur;
    	    DELETE FROM fv_doc_cr_temp
	    WHERE session_id = vp_session_id;
	    LOOP
	       FETCH po_cur INTO po_rec;
	       EXIT WHEN po_cur%NOTFOUND;
	       INSERT INTO fv_doc_cr_temp (po_header_id,po_line_id,po_line_location_id,session_id)
		 VALUES(po_rec.po_header_id,po_rec.po_line_id,po_rec.line_location_id,vp_session_id);
	    END LOOP;
	    IF  (po_cur%rowcount = 0 ) THEN
	        DELETE FROM fv_doc_cr_temp
		 WHERE session_id = vp_session_id;
		 CLOSE po_cur;
		 EXIT;
	    END IF;
	    CLOSE po_cur;
	   END IF ;

	      IF  (vp_shipment_header_id  IS NOT NULL OR  vp_rec_date  is NOT NULL) THEN
	          OPEN rec_cur;
	          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	          LOOP
	               FETCH rec_cur INTO rec_rec;
	               EXIT WHEN   rec_cur%NOTFOUND;
	              INSERT INTO fv_doc_cr_temp (po_header_id,po_line_id,po_line_location_id,session_id)
		      VALUES (rec_rec.po_header_id,rec_rec.po_line_id,rec_rec.line_location_id,vp_session_id);
 	          END LOOP;
	          IF NOT (rec_cur%rowcount <> 0 ) THEN
			   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
			   CLOSE rec_cur;
		           EXIT;
	           END IF;
	           CLOSE rec_cur;
	     END IF;
	    IF  (vp_invoice_id  IS NOT NULL OR vp_invoice_date  IS NOT NULL OR  vp_invoice_type  IS NOT NULL
	              OR  vp_invoice_amount IS NOT NULL) THEN
	          OPEN inv_cur;
	          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	          LOOP
	               FETCH inv_cur INTO inv_rec;
	               EXIT WHEN   inv_cur%NOTFOUND;
	               INSERT INTO fv_doc_cr_temp (po_header_id,po_line_id,po_line_location_id,session_id)
			VALUES (inv_rec.po_header_id,inv_rec.po_line_id,inv_rec.line_location_id,vp_session_id);
 	         END LOOP;
	         IF (inv_cur%rowcount = 0 ) THEN
		     DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
		     CLOSE inv_cur;
		     EXIT;
	        END IF;
	        CLOSE inv_cur;
	     END IF;
	     IF (vp_check_id IS NOT NULL  OR vp_check_date  IS NOT NULL
	        OR   vp_amount   IS NOT NULL OR  vp_treasury_pay_number  IS NOT NULL
	        OR   vp_treasury_pay_date IS NOT NULL) THEN
	        OPEN pay_cur;
	        DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	        LOOP
	             FETCH pay_cur INTO pay_rec;
	             EXIT WHEN   pay_cur%NOTFOUND;
	             INSERT INTO fv_doc_cr_temp (po_header_id,po_line_id,po_line_location_id,session_id)
		     VALUES (pay_rec.po_header_id,pay_rec.po_line_id,pay_rec.line_location_id,vp_session_id);
 	         END LOOP;
	         IF NOT  (pay_cur%rowcount <> 0 ) THEN
		   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
     	           CLOSE pay_cur;
 	           EXIT;
 	         END IF;
 	         CLOSE pay_cur;
	      END IF;
	      EXIT;
        END LOOP;
EXCEPTION
   WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
     RAISE;

END po_master;

PROCEDURE req_master  IS
  l_module_name VARCHAR2(200) := g_module_name || 'req_master';
  l_errbuf      VARCHAR2(1024);

	CURSOR po_cur IS
	SELECT prh.requisition_header_id ,prl.requisition_line_id
	FROM po_requisition_headers  prh,po_requisition_lines  prl,po_line_locations pll,po_headers ph
	WHERE 	prh.requisition_header_id =prl.requisition_header_id
	AND pll.line_location_id = prl.line_location_id
        AND ph.po_header_id = pll.po_header_id
	AND ph.vendor_id = vp_vendor_id
	AND ph.vendor_site_id = vp_vendor_site_id
	AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
	AND TRUNC(ph.creation_date) = NVL(vp_po_date,TRUNC(ph.creation_date))
	AND ph.agent_id = nvl(vp_buyer,ph.agent_id)
	AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
		UNION
	SELECT prh.requisition_header_id ,prl.requisition_line_id
	FROM po_requisition_headers  prh,po_requisition_lines  prl,po_line_locations pll,po_headers ph
	WHERE 	prh.requisition_header_id = prl.requisition_header_id
	AND pll.line_location_id = prl.line_location_id
        AND ph.po_header_id = pll.po_header_id
	AND ph.vendor_id = vp_vendor_id
	AND ph.vendor_site_id = vp_vendor_site_id
	AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
	AND TRUNC(ph.creation_date) = NVL(vp_po_date,TRUNC(ph.creation_date))
	AND ph.agent_id = nvl(vp_buyer,ph.agent_id)
	AND EXISTS (SELECT 1 FROM fv_doc_cr_temp  fst
		 WHERE  fst.requisition_header_id = prh.requisition_header_id
		 AND  requisition_line_id = prl.requisition_line_id
		 AND fst.session_id = vp_session_id);

	po_rec    po_cur%ROWTYPE;


      CURSOR req_cur IS
	SELECT   prh.requisition_header_id,prl.requisition_line_id
		FROM po_requisition_headers prh,po_requisition_lines prl
		WHERE prh.requisition_header_id = prl.requisition_header_id
		AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id)
		AND authorization_status = 'APPROVED'
		AND prl.suggested_vendor_location = vp_supplier_site
		AND prl.suggested_vendor_name = vp_supplier_name
		AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))
     UNION
	SELECT  rh.requisition_header_id,rh.requisition_line_id
	FROM (SELECT DISTINCT  prh.requisition_header_id,
		prl.requisition_line_id,prl.line_location_id
		FROM po_requisition_headers prh,po_requisition_lines prl
		WHERE prl.requisition_header_id = prh.requisition_header_id
		AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id)
		AND authorization_status = 'APPROVED'
		AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))) rh,
	po_line_locations plx,po_headers ph
	WHERE  plx.line_location_id = rh.line_location_id
	AND plx.po_header_id = ph.po_header_id
	AND ph.vendor_id = vp_vendor_id
	AND ph.vendor_site_id = vp_vendor_site_id
	AND NOT EXISTS (SELECT 1 FROM po_vendors pv,po_requisition_lines prl,po_vendor_sites pvs
          WHERE prl.suggested_vendor_name = pv.vendor_name
          AND prl.suggested_vendor_location = pvs.vendor_site_code
          AND prl.requisition_line_id = rh.requisition_line_id );


      req_rec    req_cur%ROWTYPE;

    CURSOR rec_cur IS
	SELECT requisition_header_id,prl.requisition_line_id FROM po_requisition_lines prl
	WHERE NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	AND (EXISTS (SELECT 1 FROM po_req_distributions prd
		WHERE prd.requisition_line_id = prl.requisition_line_id
		AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
		   WHERE rt.po_header_id = ph.po_header_id
		   AND rt.req_distribution_id = prd.distribution_id
		   AND ph.vendor_site_id = vp_vendor_site_id
		   AND 	EXISTS (SELECT 1 FROM rcv_shipment_headers rsh
		   	WHERE rsh.vendor_id = vp_vendor_id
		    	AND rsh.shipment_header_id = rt.shipment_header_id
   		    	AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
			AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date)))))
	   OR EXISTS (SELECT 1 FROM po_distributions pd
		WHERE pd.line_location_id = prl.line_location_id
		AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
		   WHERE rt.po_header_id = ph.po_header_id
		   AND rt.po_line_location_id = pd.line_location_id
		   AND ph.vendor_site_id = vp_vendor_site_id
		   AND 	EXISTS (SELECT 1 FROM rcv_shipment_headers rsh
		   	WHERE rsh.vendor_id = vp_vendor_id
		    	AND rsh.shipment_header_id = rt.shipment_header_id
   		    	AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
			AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date))))))

			UNION
	SELECT requisition_header_id,prl.requisition_line_id   FROM po_requisition_lines prl
	WHERE  EXISTS(SELECT 1 FROM fv_doc_cr_temp
		WHERE requisition_header_id = prl.requisition_header_id
		AND  requisition_line_id = prl.requisition_line_id
		AND  session_id = vp_session_id)
	AND (EXISTS (SELECT 1 FROM po_req_distributions prd
		WHERE prd.requisition_line_id = prl.requisition_line_id
		AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
		   WHERE rt.po_header_id = ph.po_header_id
		   AND rt.req_distribution_id = prd.distribution_id
		   AND ph.vendor_site_id = vp_vendor_site_id
		   AND 	EXISTS (SELECT 1 FROM rcv_shipment_headers rsh
		   	WHERE rsh.vendor_id = vp_vendor_id
		    	AND rsh.shipment_header_id = rt.shipment_header_id
   		    	AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
			AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date)))))
	   OR EXISTS (SELECT 1 FROM po_distributions pd
		WHERE pd.line_location_id = prl.line_location_id
		AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
		   WHERE rt.po_header_id = ph.po_header_id
		   AND rt.po_line_location_id = pd.line_location_id
		   AND ph.vendor_site_id = vp_vendor_site_id
		   AND 	EXISTS (SELECT 1 FROM rcv_shipment_headers rsh
		   	WHERE rsh.vendor_id = vp_vendor_id
		    	AND rsh.shipment_header_id = rt.shipment_header_id
   		    	AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id)
			AND TRUNC(rsh.creation_date) = NVL(vp_rec_date,TRUNC(rsh.creation_date))))));


       rec_rec rec_cur%ROWTYPE;


      CURSOR inv_cur IS
	SELECT prl.requisition_header_id,prl.requisition_line_id FROM po_requisition_lines prl
	WHERE  NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM po_req_distributions prd
	    WHERE prd.requisition_line_id = prl.requisition_line_id
	    AND EXISTS (SELECT 1 FROM po_distributions pd
	        WHERE pd.req_distribution_id = prd.distribution_id
	        AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	 		WHERE aid.po_distribution_id= pd.po_distribution_id
			AND EXISTS (SELECT 1 FROM ap_invoices ai
			    WHERE ai.invoice_id = aid.invoice_id
			    AND ai.vendor_id = vp_vendor_id
 	                    AND ai.vendor_site_id = vp_vendor_site_id
			    AND ai.invoice_id = NVL(vp_invoice_id,invoice_id)
			    AND TRUNC(ai.invoice_date) = nvl(vp_invoice_date,TRUNC(ai.invoice_date))
			    AND ai.invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
			    AND ai.invoice_amount = nvl(vp_invoice_amount,invoice_amount)))
	            OR EXISTS (SELECT 1 FROM po_line_locations pll
	             	WHERE  pll.line_location_id  = pd.line_location_id
	               	AND EXISTS ( SELECT 1 FROM rcv_transactions rt
	               	    WHERE rt.po_line_location_id = pll.line_location_id
	                    AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	                        WHERE aid.rcv_transaction_id = rt.transaction_id
	                	AND EXISTS (SELECT 1 FROM ap_invoices ai
				    WHERE ai.invoice_id = aid.invoice_id
				    AND ai.vendor_id = vp_vendor_id
 	                            AND ai.vendor_site_id = vp_vendor_site_id
				    AND ai.invoice_id = NVL(vp_invoice_id,invoice_id)
				    AND TRUNC(ai.invoice_date) = nvl(vp_invoice_date,TRUNC(ai.invoice_date))
				    AND ai.invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
				    AND ai.invoice_amount = nvl(vp_invoice_amount,invoice_amount))))))))
		UNION
	SELECT prl.requisition_header_id,prl.requisition_line_id FROM po_requisition_lines prl
	WHERE   EXISTS(SELECT 1 FROM fv_doc_cr_temp
	  WHERE requisition_header_id = prl.requisition_header_id
	  AND  requisition_line_id = prl.requisition_line_id
	  AND session_id = vp_session_id)
	  AND EXISTS (SELECT 1 FROM po_req_distributions prd
            WHERE prd.requisition_line_id = prl.requisition_line_id
	    AND EXISTS (SELECT 1 FROM po_distributions pd
	     WHERE pd.req_distribution_id = prd.distribution_id
	     AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	      WHERE aid.po_distribution_id= pd.po_distribution_id
	      AND EXISTS (SELECT 1 FROM ap_invoices ai
		WHERE ai.invoice_id = aid.invoice_id
		AND ai.vendor_id = vp_vendor_id
 		AND ai.vendor_site_id = vp_vendor_site_id
		AND ai.invoice_id = NVL(vp_invoice_id,invoice_id)
		AND trunc(ai.invoice_date) = nvl(vp_invoice_date,trunc(ai.invoice_date))
		AND ai.invoice_type_lookup_code = NVL(vp_invoice_type,invoice_type_lookup_code)
                AND ai.invoice_amount = nvl(vp_invoice_amount,invoice_amount)))
                OR EXISTS (SELECT 1 FROM po_line_locations pll
		   WHERE pll.line_location_id  = pd.line_location_id
               	   AND EXISTS (SELECT 1 FROM rcv_transactions rt
		    WHERE rt.po_line_location_id = pll.line_location_id
                    AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		     WHERE aid.rcv_transaction_id = rt.transaction_id
		     AND EXISTS (SELECT 1 FROM ap_invoices ai
		      WHERE ai.invoice_id = aid.invoice_id
		      AND ai.vendor_id = vp_vendor_id
 		      AND ai.vendor_site_id = vp_vendor_site_id
		      AND ai.invoice_id = NVL(vp_invoice_id,invoice_id)
		      AND TRUNC(ai.invoice_date) = NVL(vp_invoice_date,TRUNC(ai.invoice_date))
		      AND ai.invoice_type_lookup_code =NVL(vp_invoice_type,invoice_type_lookup_code)
		      AND ai.invoice_amount = nvl(vp_invoice_amount,invoice_amount))))))));

            inv_rec inv_cur%ROWTYPE;

	CURSOR pay_cur IS
	SELECT prl.requisition_header_id,prl.requisition_line_id FROM po_requisition_lines prl
	WHERE   NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM po_req_distributions prd WHERE prd.requisition_line_id = prl.requisition_line_id
	AND EXISTS (SELECT 1 FROM po_distributions pd
	 WHERE pd.req_distribution_id = prd.distribution_id
	 AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	  WHERE aid.po_distribution_id = pd.po_distribution_id
	  AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	   WHERE aip.invoice_id = aid.invoice_id
	   AND EXISTS (SELECT 1 FROM ap_checks ac
	    WHERE ac.check_id = aip.check_id
	    AND ac.vendor_id = vp_vendor_id
	    AND ac.vendor_site_id = vp_vendor_site_id
	    AND ac.check_id =  NVL(vp_check_id,ac.check_id)
	    AND ac.check_date = NVL(vp_check_date,ac.check_date)
            AND ac.amount = nvl(vp_amount,ac.amount)
	    AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
 	    AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
		 OR vp_treasury_pay_date IS NULL))))
	    OR EXISTS (SELECT 1 FROM po_line_locations pll
	     WHERE  pll.line_location_id  = pd.line_location_id
	     AND EXISTS (SELECT 1 FROM rcv_transactions rt
	      WHERE rt.po_line_location_id = pll.line_location_id
              AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
               WHERE aid.rcv_transaction_id = rt.transaction_id
	       AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	        WHERE aip.invoice_id = aid.invoice_id
	        AND EXISTS (SELECT 1 FROM ap_checks ac
		 WHERE ac.check_id = aip.check_id
		 AND ac.vendor_id = vp_vendor_id
		 AND ac.vendor_site_id = vp_vendor_site_id
		 AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		 AND ac.check_date = NVL(vp_check_date,ac.check_date)
	         AND ac.amount = nvl(vp_amount,ac.amount)
		 AND NVL(ac.treasury_pay_number,-1) = NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
 		 AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                      OR vp_treasury_pay_date IS NULL)))))))))
				UNION
		SELECT prl.requisition_header_id,prl.requisition_line_id  FROM po_requisition_lines prl
		WHERE EXISTS(SELECT 1 FROM fv_doc_cr_temp
		     WHERE requisition_header_id = prl.requisition_header_id
		     AND  requisition_line_id = prl.requisition_line_id
		     AND session_id = vp_session_id)
		AND EXISTS (SELECT 1 FROM po_req_distributions prd
		 WHERE prd.requisition_line_id = prl.requisition_line_id
		 AND EXISTS (SELECT 1 FROM po_distributions pd
		  WHERE pd.req_distribution_id = prd.distribution_id
		  AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
 		   WHERE aid.po_distribution_id = pd.po_distribution_id
	           AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		    WHERE aip.invoice_id = aid.invoice_id
		    AND EXISTS (SELECT 1 FROM ap_checks ac
		     WHERE ac.check_id = aip.check_id
		     AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		     AND ac.check_date = NVL(vp_check_date,ac.check_date)
		     AND ac.amount = nvl(vp_amount,ac.amount)
		     AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
	   	     AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
                         OR vp_treasury_pay_date IS NULL))))
		   OR EXISTS (SELECT 1 FROM po_line_locations pll
		    WHERE  pll.line_location_id  = pd.line_location_id
		    AND EXISTS (SELECT 1 FROM rcv_transactions rt
		     WHERE rt.po_line_location_id = pll.line_location_id
		     AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		      WHERE aid.rcv_transaction_id = rt.transaction_id
		      AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		       WHERE aip.invoice_id = aid.invoice_id
		       AND EXISTS (SELECT 1 FROM ap_checks ac
			WHERE ac.check_id = aip.check_id
			AND ac.vendor_id = vp_vendor_id
			AND ac.vendor_site_id = vp_vendor_site_id
			AND ac.check_id =  NVL(vp_check_id,ac.check_id)
			AND ac.check_date = NVL(vp_check_date,ac.check_date)
			AND ac.amount = nvl(vp_amount,ac.amount)
			AND NVL(ac.treasury_pay_number,-1) =NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
 			AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date)
			     OR vp_treasury_pay_date IS NULL)))))))));
        pay_rec pay_cur%ROWTYPE;
     BEGIN
        DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	LOOP

	IF (vp_requisition_header_id  IS NOT NULL OR  vp_req_date is NOT NULL) THEN
	      OPEN req_cur;
	      DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	      LOOP
		  FETCH req_cur INTO req_rec;
		  EXIT WHEN  req_cur%NOTFOUND;
		  INSERT INTO fv_doc_cr_temp (requisition_header_id,requisition_line_id,session_id )
			      VALUES (req_rec.requisition_header_id,req_rec.requisition_line_id,vp_session_id );
	      END LOOP;
	      IF NOT (req_cur%rowcount <> 0 ) THEN
		DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
		CLOSE req_cur;
		EXIT;
	      END IF;
	      CLOSE req_cur;
        END IF;

     IF  (vp_po_header_id   IS NOT NULL OR vp_po_date IS NOT NULL OR  vp_buyer IS NOT NULL) THEN
	  OPEN po_cur;
	  LOOP
	      FETCH po_cur INTO po_rec;
	      EXIT WHEN po_cur%NOTFOUND;
	      INSERT INTO fv_doc_cr_temp (requisition_header_id ,requisition_line_id,session_id)
			VALUES (po_rec.requisition_header_id,po_rec.requisition_line_id,vp_session_id );
	   END LOOP;
	   IF NOT (po_cur%rowcount <> 0 ) THEN
	      DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	      CLOSE po_cur;
	      EXIT;
	   END IF;
	   CLOSE po_cur;
      END IF ;

      IF  (vp_shipment_header_id  IS NOT NULL OR  vp_rec_date  is NOT NULL) THEN
	      OPEN rec_cur;
              DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	      LOOP
		  FETCH rec_cur INTO rec_rec;
		  EXIT WHEN   rec_cur%NOTFOUND;
	          INSERT INTO fv_doc_cr_temp (requisition_header_id ,requisition_line_id,session_id)
				VALUES (rec_rec.requisition_header_id,rec_rec.requisition_line_id,vp_session_id );
	      END LOOP;
	      IF NOT (rec_cur%rowcount <> 0 ) THEN
		   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
		   CLOSE rec_cur;
 		   EXIT;
              END IF;
              CLOSE rec_cur;
      END IF;

      IF  (vp_invoice_id  IS NOT NULL OR vp_invoice_date  IS NOT NULL OR  vp_invoice_type  IS NOT NULL
              OR  vp_invoice_amount IS NOT NULL) THEN
              OPEN inv_cur;
              DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
              LOOP
                  FETCH inv_cur INTO inv_rec;
                  EXIT WHEN   inv_cur%NOTFOUND;
	          INSERT INTO fv_doc_cr_temp (requisition_header_id ,requisition_line_id,session_id)
	   		      VALUES (inv_rec.requisition_header_id,inv_rec.requisition_line_id,vp_session_id);
       	      END LOOP;
              IF (inv_cur%rowcount = 0 ) THEN
                  CLOSE inv_cur;
                  DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
                  EXIT;
              END IF;
              CLOSE inv_cur;
	END IF;
	IF (vp_check_id IS NOT NULL  OR vp_check_date  IS NOT NULL OR   vp_amount   IS NOT NULL
	    OR  vp_treasury_pay_number  IS NOT NULL OR  vp_treasury_pay_date IS NOT NULL) THEN
	    OPEN pay_cur;
	    DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	    LOOP
		  FETCH pay_cur INTO pay_rec;
		  EXIT WHEN   pay_cur%NOTFOUND;
	          INSERT INTO fv_doc_cr_temp (requisition_header_id ,requisition_line_id,session_id)
			VALUES (pay_rec.requisition_header_id,pay_rec.requisition_line_id,vp_session_id );
	      END LOOP;
	      IF NOT (pay_cur%rowcount <> 0 ) THEN
		   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	           CLOSE pay_cur;
		   EXIT;
	      END IF;
	      CLOSE pay_cur;
	   END IF;
	   EXIT;
    END LOOP;
EXCEPTION
   WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
     RAISE;

END req_master;

PROCEDURE rec_master  IS
  l_module_name VARCHAR2(200) := g_module_name || 'rec_master';
  l_errbuf      VARCHAR2(1024);

  CURSOR rec_cur IS
     SELECT shipment_header_id FROM fv_receipt_master_v frm
     WHERE shipment_header_id = NVL(vp_shipment_header_id,shipment_header_id)
     AND TRUNC(receipt_date) = NVL(vp_rec_date,TRUNC(receipt_date))
     AND vendor_id = vp_vendor_id
     AND  vendor_site_id = vp_vendor_site_id;
   rec_rec rec_cur%ROWTYPE;

   CURSOR po_cur IS
    SELECT rsh.shipment_header_id FROM rcv_shipment_headers rsh
          WHERE EXISTS (SELECT 1 FROM rcv_transactions rt
          	WHERE rt.shipment_header_id = rsh.shipment_header_id
          	AND EXISTS (select 1 FROM po_headers ph
	     	    WHERE ph.po_header_id = rt.po_header_id
	   	    AND vendor_id = vp_vendor_id
		    AND vendor_site_id = vp_vendor_site_id
		    AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
		    AND TRUNC(ph.creation_date) = nvl(vp_po_date,TRUNC(ph.creation_date))
		    AND ph.agent_id = NVL(vp_buyer,ph.agent_id)))
		AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
			UNION
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
          WHERE EXISTS (SELECT 1 FROM rcv_transactions rt
          	WHERE rt.shipment_header_id = rsh.shipment_header_id
          	AND EXISTS (select 1 FROM po_headers ph
	     	    WHERE ph.po_header_id = rt.po_header_id
	   	    AND vendor_id = vp_vendor_id
		    AND vendor_site_id = vp_vendor_site_id
		    AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id)
		    AND TRUNC(ph.creation_date) = nvl(vp_po_date,TRUNC(ph.creation_date))
		    AND ph.agent_id = NVL(vp_buyer,ph.agent_id)))
     	       AND  EXISTS(SELECT 1 FROM fv_doc_cr_temp
		   WHERE shipment_header_id = rsh.shipment_header_id
		   AND session_id = vp_session_id);
      po_rec rec_cur%ROWTYPE;
  CURSOR req_cur IS
  SELECT rsh.shipment_header_id FROM rcv_shipment_headers rsh
	 WHERE  rsh.vendor_id = vp_vendor_id
	 AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	 AND EXISTS(SELECT 1 FROM rcv_transactions rt,po_headers ph
	     WHERE ph.po_header_id = rt.po_header_id
	     AND rt.shipment_header_id = rsh.shipment_header_id
	     AND ph.vendor_site_id = vp_vendor_site_id
	     AND (EXISTS (SELECT 1 FROM po_req_distributions prd
	          WHERE prd.distribution_id = rt.req_distribution_id
	          AND EXISTS (SELECT 1 FROM po_requisition_lines prl,po_requisition_headers prh
	              WHERE prl.requisition_header_id = prh.requisition_header_id
		      AND prl.requisition_line_id  = prd.requisition_line_id
      		      AND prh.requisition_header_id = NVL(vp_requisition_header_id ,prh.requisition_header_id)
      		      AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))
	       OR EXISTS (SELECT 1 FROM po_requisition_lines prl ,po_requisition_headers prh
	              WHERE prl.requisition_header_id = prh.requisition_header_id
		      AND prl.line_location_id  = rt.po_line_location_id
      		      AND prh.requisition_header_id = NVL(vp_requisition_header_id ,prh.requisition_header_id)
      		      AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date)))))

	UNION
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
	 WHERE  rsh.vendor_id = vp_vendor_id
	 AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp fdct
		WHERE fdct.shipment_header_id = rsh.shipment_header_id
		AND fdct.session_id = vp_session_id)
	 AND EXISTS(SELECT 1 FROM rcv_transactions rt,po_headers ph
	     WHERE rt.po_header_id = ph.po_header_id
	     AND rt.shipment_header_id = rsh.shipment_header_id
	     AND ph.vendor_site_id = vp_vendor_site_id
	     AND (EXISTS (SELECT 1 FROM po_req_distributions prd
	          WHERE prd.distribution_id = rt.req_distribution_id
	          AND EXISTS (SELECT 1 FROM po_requisition_lines prl ,po_requisition_headers prh
	              WHERE prl.requisition_header_id = prh.requisition_header_id
		      AND prl.requisition_line_id  = prd.requisition_line_id
      		      AND prh.requisition_header_id = NVL(vp_requisition_header_id ,prh.requisition_header_id)
	              AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))
	       OR EXISTS (SELECT 1 FROM po_requisition_lines prl ,po_requisition_headers prh
	              WHERE prl.requisition_header_id = prh.requisition_header_id
		      AND prl.line_location_id  = rt.po_line_location_id
      		      AND prh.requisition_header_id = NVL(vp_requisition_header_id ,prh.requisition_header_id)
	              AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date)))));


    req_rec req_cur%ROWTYPE;


  CURSOR inv_cur IS
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
  	WHERE vendor_id = vp_vendor_id
	AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
	    WHERE ph.po_header_id = rt.po_header_id
            AND rt.shipment_header_id = rsh.shipment_header_id
	    AND ph.vendor_site_id = vp_vendor_site_id
	    AND EXISTS (SELECT 1 FROM po_distributions pd WHERE pd.line_location_id = rt.po_line_location_id
	    	AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
	    	    WHERE ia.po_distribution_id= pd.po_distribution_id
		    AND EXISTS (SELECT 1 FROM ap_invoices ap
			WHERE invoice_id = ia.invoice_id
			AND invoice_id = NVL(vp_invoice_id,invoice_id)
			AND TRUNC(ap.invoice_date) = nvl(vp_invoice_date,TRUNC(ap.invoice_date))
			AND invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
			AND invoice_amount = nvl(vp_invoice_amount,invoice_amount)))))
		UNION
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
	WHERE vendor_id = vp_vendor_id
	AND  EXISTS(SELECT 1 FROM fv_doc_cr_temp
		WHERE shipment_header_id = rsh.shipment_header_id
		AND session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM rcv_transactions rt ,po_headers ph
	    WHERE rt.po_header_id = ph.po_header_id
	    AND rt.shipment_header_id = rsh.shipment_header_id
	    AND ph.vendor_site_id = vp_vendor_site_id
	    AND EXISTS (SELECT 1 FROM po_distributions pd WHERE pd.line_location_id = rt.po_line_location_id
	    	AND EXISTS (SELECT 1 FROM ap_invoice_distributions ia
	    	    WHERE ia.po_distribution_id= pd.po_distribution_id
		    AND EXISTS (SELECT 1 FROM ap_invoices ap
			WHERE invoice_id = ia.invoice_id
			AND invoice_id = NVL(vp_invoice_id,invoice_id)
			AND TRUNC(ap.invoice_date) = nvl(vp_invoice_date,TRUNC(ap.invoice_date))
			AND invoice_type_lookup_code = nvl(vp_invoice_type,invoice_type_lookup_code)
			AND invoice_amount = nvl(vp_invoice_amount,invoice_amount)))));

       inv_rec inv_cur%ROWTYPE;
     CURSOR pay_cur IS
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
	WHERE vendor_id = vp_vendor_id
	AND NOT EXISTS(SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
     	    WHERE rt.po_header_id = ph.po_header_id
	    AND rt.shipment_header_id = rsh.shipment_header_id
     	    AND ph.vendor_site_id = vp_vendor_site_id
	    AND EXISTS (SELECT 1  FROM po_distributions pd WHERE pd.line_location_id = rt.po_line_location_id
	    	AND EXISTS( SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.po_distribution_id= pd.po_distribution_id
		AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		    WHERE aip.invoice_id = aid.invoice_id
		    AND EXISTS (SELECT 1 FROM ap_checks ac
			WHERE ac.check_id = aip.check_id
			AND ac.check_id =  NVL(vp_check_id,ac.check_id)
			AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
			AND ac.amount = nvl(vp_amount,ac.amount)
			AND NVL(ac.treasury_pay_number,-1) = nvl(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
			AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date) OR vp_treasury_pay_date IS NULL))))))
	   UNION
	SELECT shipment_header_id FROM rcv_shipment_headers rsh
  	WHERE vendor_id = vp_vendor_id
	AND EXISTS(SELECT 1 FROM fv_doc_cr_temp
		WHERE shipment_header_id = rsh.shipment_header_id
		AND session_id = vp_session_id)
	AND EXISTS (SELECT 1 FROM rcv_transactions rt,po_headers ph
     	    WHERE rt.po_header_id = ph.po_header_id
	    AND rt.shipment_header_id = rsh.shipment_header_id
     	    AND ph.vendor_site_id = vp_vendor_site_id
	    AND EXISTS (SELECT 1  FROM po_distributions pd
                WHERE pd.line_location_id = rt.po_line_location_id
	    	AND EXISTS( SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.po_distribution_id= pd.po_distribution_id
		AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		    WHERE aip.invoice_id = aid.invoice_id
		    AND EXISTS (SELECT 1 FROM ap_checks ac
			WHERE ac.check_id = aip.check_id
			AND ac.check_id =  NVL(vp_check_id,ac.check_id)
			AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
			AND ac.amount = nvl(vp_amount,ac.amount)
			AND NVL(ac.treasury_pay_number,-1) = NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
			AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date) OR vp_treasury_pay_date IS NULL))))));


    pay_rec pay_cur%ROWTYPE;
BEGIN
      DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
      LOOP
     IF  (vp_shipment_header_id  IS NOT NULL OR  vp_rec_date  is NOT NULL) THEN
         OPEN rec_cur;
         DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
         LOOP
             FETCH rec_cur INTO rec_rec;
             EXIT WHEN  rec_cur%NOTFOUND;
             INSERT INTO fv_doc_cr_temp (shipment_header_id,session_id)
				VALUES (rec_rec.shipment_header_id,vp_session_id);
         END LOOP;
         IF NOT (rec_cur%rowcount <> 0 ) THEN
	   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
           CLOSE rec_cur;
           EXIT;
         END IF;
         CLOSE rec_cur;
    END IF;
    IF  (vp_po_header_id   IS NOT NULL OR vp_po_date IS NOT NULL OR  vp_buyer IS NOT NULL) THEN
        OPEN po_cur;
        LOOP
            FETCH po_cur INTO po_rec;
            EXIT WHEN po_cur%NOTFOUND;
            INSERT INTO fv_doc_cr_temp (shipment_header_id,session_id)
			VALUES	  (po_rec.shipment_header_id,vp_session_id);
        END LOOP;
        IF NOT (po_cur%rowcount <> 0 ) THEN
          DELETE from fv_doc_cr_temp WHERE session_id = vp_session_id;
          CLOSE po_cur;
          EXIT;
        END IF;
        CLOSE po_cur;
     END IF ;
     IF (vp_requisition_header_id  IS NOT NULL OR  vp_req_date is NOT NULL) THEN
        OPEN req_cur;
        DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
        LOOP
             FETCH req_cur INTO req_rec;
             EXIT WHEN   req_cur%NOTFOUND;
             INSERT INTO fv_doc_cr_temp (shipment_header_id,session_id)
			VALUES (req_rec.shipment_header_id,vp_session_id);
        END LOOP;
        IF NOT (req_cur%rowcount <> 0 ) THEN
          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	  CLOSE req_cur;
	  EXIT;
	END IF;
	CLOSE req_cur;
    END IF;
    IF  (vp_invoice_id  IS NOT NULL OR vp_invoice_date  IS NOT NULL OR  vp_invoice_type  IS NOT NULL
             OR  vp_invoice_amount IS NOT NULL) THEN
        OPEN inv_cur;
        DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
        LOOP
           FETCH inv_cur INTO inv_rec;
           EXIT WHEN   inv_cur%NOTFOUND;
           INSERT INTO fv_doc_cr_temp (shipment_header_id,session_id)
			VALUES (inv_rec.shipment_header_id,vp_session_id);
        END LOOP;
        IF NOT (inv_cur%rowcount <> 0 ) THEN
           DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	   CLOSE inv_cur;
 	   EXIT;
	END IF;
	CLOSE inv_cur;
    END IF;
   IF (vp_check_id IS NOT NULL  OR vp_check_date  IS NOT NULL
      OR   vp_amount   IS NOT NULL OR  vp_treasury_pay_number  IS NOT NULL
      OR   vp_treasury_pay_date IS NOT NULL) THEN
      OPEN pay_cur;
      DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
      LOOP
          FETCH pay_cur INTO pay_rec;
          EXIT WHEN   pay_cur%NOTFOUND;
          INSERT INTO fv_doc_cr_temp (shipment_header_id,session_id)
		VALUES (pay_rec.shipment_header_id,vp_session_id);
      END LOOP;
      IF NOT (pay_cur%rowcount <> 0 ) THEN
        DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
        CLOSE pay_cur;
        EXIT;
     END IF;
     CLOSE pay_cur;
  END IF;
  EXIT;
 END LOOP;
EXCEPTION
   WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
     RAISE;

END rec_master;


PROCEDURE inv_master  IS
  l_module_name VARCHAR2(200) := g_module_name || 'inv_master';
  l_errbuf      VARCHAR2(1024);

CURSOR req_cur IS
   SELECT invoice_id FROM ap_invoices ai
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
   AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	WHERE aid.invoice_id = ai.invoice_id
	AND EXISTS (SELECT 1 FROM po_distributions pd
	    WHERE pd.po_distribution_id = aid.po_distribution_id
	    AND EXISTS(SELECT 1 FROM po_req_distributions prd
		WHERE prd.distribution_id = pd.req_distribution_id
		AND EXISTS (SELECT 1 FROM po_requisition_lines prl
		    WHERE prl.requisition_line_id = prd.requisition_line_id
		    AND EXISTS (SELECT 1 FROM po_requisition_headers prh
			WHERE prh.requisition_header_id = prl.requisition_header_id
			AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id )
			AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))
	OR EXISTS (SELECT 1 FROM rcv_transactions rt
	           WHERE rt.transaction_id = aid.rcv_transaction_id
	           AND EXISTS (SELECT 1 FROM po_line_locations pll
	           	WHERE rt.po_line_location_id = pll.line_location_id
	           	AND EXISTS(SELECT 1 FROM po_distributions pd
	           	      WHERE pd.line_location_id = pll.line_location_id
	           	      AND EXISTS (SELECT 1 FROM po_req_distributions prd
			WHERE prd.distribution_id = pd.req_distribution_id
			AND EXISTS (SELECT 1 FROM po_requisition_lines prl
				WHERE prl.requisition_line_id = prd.requisition_line_id
				AND EXISTS (SELECT 1 FROM po_requisition_headers prh
					WHERE prh.requisition_header_id = prl.requisition_header_id
					AND prh.requisition_header_id =     NVL(vp_requisition_header_id,prh.requisition_header_id )
					AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))))))
     UNION
   SELECT invoice_id FROM ap_invoices ai
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
          WHERE invoice_id= ai.invoice_id
	  AND session_id = vp_session_id)
   AND (EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	WHERE aid.invoice_id = ai.invoice_id
	AND EXISTS (SELECT 1 FROM po_distributions pd
	   WHERE pd.po_distribution_id = aid.po_distribution_id
	   AND EXISTS(SELECT 1 FROM po_req_distributions prd
	     WHERE prd.distribution_id = pd.req_distribution_id
	     AND EXISTS (SELECT 1 FROM po_requisition_lines prl
		WHERE prl.requisition_line_id = prd.requisition_line_id
		AND EXISTS (SELECT 1 FROM po_requisition_headers prh
		   WHERE prh.requisition_header_id = prl.requisition_header_id
		   AND prh.requisition_header_id =NVL(vp_requisition_header_id,prh.requisition_header_id )
		   AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))
	OR EXISTS (SELECT 1 FROM rcv_transactions rt
	           WHERE rt.transaction_id = aid.rcv_transaction_id
	           AND EXISTS (SELECT 1 FROM po_line_locations pll
	           	WHERE rt.po_line_location_id = pll.line_location_id
	           	AND EXISTS(SELECT 1 FROM po_distributions pd
	           	      WHERE pd.line_location_id = pll.line_location_id
	           	      AND EXISTS (SELECT 1 FROM po_req_distributions prd
			WHERE prd.distribution_id = pd.req_distribution_id
			AND EXISTS (SELECT 1 FROM po_requisition_lines prl
				WHERE prl.requisition_line_id = prd.requisition_line_id
				AND EXISTS (SELECT 1 FROM po_requisition_headers prh
					WHERE prh.requisition_header_id = prl.requisition_header_id
					AND prh.requisition_header_id =     NVL(vp_requisition_header_id,prh.requisition_header_id )
					AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))))));

req_rec req_cur%ROWTYPE;

CURSOR po_cur IS
   SELECT invoice_id FROM ap_invoices ai
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
   AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.invoice_id = ai.invoice_id
		AND EXISTS (SELECT 1 FROM po_distributions pd
			WHERE pd.po_distribution_id = aid.po_distribution_id
   			AND EXISTS(SELECT 1 FROM po_headers ph
			WHERE ph.po_header_id = pd.po_header_id
			AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
			AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date))))
	        OR EXISTS (SELECT 1 FROM rcv_transactions rt
			WHERE rt.transaction_id = aid.rcv_transaction_id
   			AND EXISTS(SELECT 1 FROM po_headers ph
			WHERE ph.po_header_id = rt.po_header_id
			AND ph.po_header_id = NVL(vp_po_header_id,rt.po_header_id )
			AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date)))))
	UNION
   SELECT invoice_id FROM ap_invoices ai
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
	WHERE invoice_id = ai.invoice_id
        AND session_id = vp_session_id)
   AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.invoice_id = ai.invoice_id
		AND EXISTS (SELECT 1 FROM po_distributions pd
			WHERE pd.po_distribution_id = aid.po_distribution_id
   			AND EXISTS(SELECT 1 FROM po_headers ph
			WHERE ph.po_header_id = pd.po_header_id
			AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
			AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date))))
	        OR EXISTS (SELECT 1 FROM rcv_transactions rt
			WHERE rt.transaction_id = aid.rcv_transaction_id
   			AND EXISTS(SELECT 1 FROM po_headers ph
			WHERE ph.po_header_id = rt.po_header_id
			AND ph.po_header_id = NVL(vp_po_header_id,rt.po_header_id )
			AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date)))));




 po_rec po_cur%ROWTYPE;

CURSOR rec_cur IS
   SELECT invoice_id FROM ap_invoices ai
	   WHERE vendor_id = vp_vendor_id
	   AND vendor_site_id = vp_vendor_site_id
	   AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	   AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.invoice_id = ai.invoice_id
		AND (EXISTS (SELECT 1 FROM rcv_transactions rt
		    WHERE rt.transaction_id = aid.rcv_transaction_id
		    AND EXISTS(SELECT 1 FROM rcv_shipment_headers rsh
			WHERE rt.shipment_header_id = rsh.shipment_header_id
			AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
			AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date))))
		OR EXISTS (SELECT 1 FROM po_distributions pd
		    WHERE pd.po_distribution_id = aid.po_distribution_id
		    AND EXISTS(SELECT 1 FROM rcv_shipment_lines rsl,rcv_shipment_headers rsh
			WHERE rsl.po_line_location_id = pd.line_location_id
			AND rsl.shipment_header_id = rsh.shipment_header_id
			AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
			AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date))))))
	UNION
	 SELECT invoice_id FROM ap_invoices ai
	   WHERE vendor_id = vp_vendor_id
	   AND vendor_site_id = vp_vendor_site_id
	   AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
                WHERE invoice_id = ai.invoice_id
		AND session_id = vp_session_id)
	   AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		WHERE aid.invoice_id = ai.invoice_id
		AND (EXISTS (SELECT 1 FROM rcv_transactions rt
		    WHERE rt.transaction_id = aid.rcv_transaction_id
		    AND EXISTS(SELECT 1 FROM rcv_shipment_headers rsh
			WHERE rt.shipment_header_id = rsh.shipment_header_id
			AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
			AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date))))
		OR EXISTS (SELECT 1 FROM po_distributions pd
		    WHERE pd.po_distribution_id = aid.po_distribution_id
		    AND EXISTS(SELECT 1 FROM rcv_shipment_lines rsl,rcv_shipment_headers rsh
			WHERE rsl.po_line_location_id = pd.line_location_id
			AND rsl.shipment_header_id = rsh.shipment_header_id
			AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
			AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date))))));

      rec_rec  rec_cur%ROWTYPE;


 CURSOR inv_cur IS
  SELECT invoice_id FROM ap_invoices
	   WHERE vendor_id = vp_vendor_id
	   AND vendor_site_id = vp_vendor_site_id
	   AND  invoice_id = NVL(vp_invoice_id,invoice_id)
	   AND invoice_type_lookup_code = NVL(vp_invoice_type,invoice_type_lookup_code)
	   AND invoice_amount = NVL(vp_invoice_amount,invoice_amount)
	   AND   TRUNC(invoice_date) = NVL(TRUNC(vp_invoice_date), TRUNC(invoice_date)) ;
  inv_rec inv_cur%ROWTYPE;

CURSOR pay_cur IS
 SELECT invoice_id FROM ap_invoices ai
	   WHERE vendor_id = vp_vendor_id
	   AND vendor_site_id = vp_vendor_site_id
	   AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
           AND EXISTS ( SELECT 1 FROM ap_invoice_payments aip
		WHERE aip.invoice_id = ai.invoice_id
		AND EXISTS (SELECT 1 FROM ap_checks ac
		    WHERE ac.check_id = aip.check_id
		    AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		    AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
		    AND ac.amount = nvl(vp_amount,ac.amount)
		    AND NVL(ac.treasury_pay_number,-1) = nvl(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
		    AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date) OR vp_treasury_pay_date IS NULL)
				))
UNION
 SELECT invoice_id FROM ap_invoices ai
	   WHERE vendor_id = vp_vendor_id
	   AND vendor_site_id = vp_vendor_site_id
	   AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
		WHERE invoice_id = ai.invoice_id
		AND session_id = vp_session_id)
           AND EXISTS ( SELECT 1 FROM ap_invoice_payments aip
		WHERE aip.invoice_id = ai.invoice_id
		AND EXISTS (SELECT 1 FROM ap_checks ac
			WHERE ac.check_id = aip.check_id
			AND ac.check_id =  NVL(vp_check_id,ac.check_id)
			AND TRUNC(ac.check_date) = NVL(vp_check_date,TRUNC(ac.check_date))
			AND ac.amount = nvl(vp_amount,ac.amount)
			AND NVL(ac.treasury_pay_number,-1) = nvl(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1))
			AND (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date) OR vp_treasury_pay_date IS NULL)
					));
pay_rec  pay_cur%ROWTYPE;


BEGIN
     DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
     LOOP
     IF  (vp_invoice_id  IS NOT NULL OR vp_invoice_date  IS NOT NULL OR
	  vp_invoice_type  IS NOT NULL OR  vp_invoice_amount IS NOT NULL) THEN
       OPEN inv_cur;
       LOOP
             FETCH inv_cur INTO inv_rec;
             EXIT WHEN   inv_cur%NOTFOUND;
            INSERT INTO fv_doc_cr_temp (invoice_id,session_id)
			VALUES (inv_rec.invoice_id,vp_session_id);
       END LOOP;
       IF  (inv_cur%rowcount = 0 ) THEN
	   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	   CLOSE inv_cur;
           EXIT;
        END IF;
        CLOSE inv_cur;
    END IF;
    IF  (vp_po_header_id   IS NOT NULL OR vp_po_date IS NOT NULL OR  vp_buyer IS NOT NULL) THEN
         OPEN po_cur;
         LOOP
             FETCH po_cur INTO po_rec;
             EXIT WHEN po_cur%NOTFOUND;
             INSERT INTO fv_doc_cr_temp (invoice_id,session_id)
			VALUES  (po_rec.invoice_id,vp_session_id);
          END LOOP;
          IF  (po_cur%rowcount = 0 ) THEN
               DELETE from fv_doc_cr_temp WHERE session_id = vp_session_id;
	       CLOSE po_cur;
	       EXIT;
	   END IF;
	   CLOSE po_cur;
      END IF ;
      IF (vp_requisition_header_id  IS NOT NULL OR  vp_req_date is NOT NULL) THEN
          OPEN req_cur;
          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
          LOOP
              FETCH req_cur INTO req_rec;
              EXIT WHEN   req_cur%NOTFOUND;
              INSERT INTO fv_doc_cr_temp (invoice_id,session_id)
					VALUES (req_rec.invoice_id,vp_session_id);
          END LOOP;
          IF  (req_cur%rowcount =0 ) THEN
             DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	     CLOSE req_cur;
	     EXIT;
	   END IF;
	   CLOSE req_cur;
      END IF;
      IF  (vp_shipment_header_id  IS NOT NULL OR  vp_rec_date  is NOT NULL) THEN
          OPEN rec_cur;
          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
          LOOP
               FETCH rec_cur INTO rec_rec;
               EXIT WHEN   rec_cur%NOTFOUND;
               INSERT INTO fv_doc_cr_temp (invoice_id,session_id)
				VALUES (rec_rec.invoice_id,vp_session_id);
          END LOOP;
          IF  (rec_cur%rowcount = 0 ) THEN
	     DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	     CLOSE rec_cur;
	     EXIT;
	  END IF;
	  CLOSE rec_cur;
       END IF;
       IF (vp_check_id IS NOT NULL  OR vp_check_date  IS NOT NULL
          OR   vp_amount   IS NOT NULL OR  vp_treasury_pay_number  IS NOT NULL
          OR  vp_treasury_pay_date IS NOT NULL) THEN
           OPEN pay_cur;
           DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
           LOOP
               FETCH pay_cur INTO pay_rec;
               EXIT WHEN   pay_cur%NOTFOUND;
               INSERT INTO fv_doc_cr_temp (invoice_id,session_id)
			VALUES (pay_rec.invoice_id,vp_session_id);
            END LOOP;
            IF  (pay_cur%rowcount = 0 ) THEN
               DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	       CLOSE pay_cur;
 	       EXIT;
	    END IF;
	    CLOSE pay_cur;
       END IF;
       EXIT;
    END LOOP;
EXCEPTION
   WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
     RAISE;

END inv_master;


PROCEDURE pay_master  IS
  l_module_name VARCHAR2(200) := g_module_name || 'pay_master';
  l_errbuf      VARCHAR2(1024);

CURSOR req_cur IS
   SELECT check_id FROM ap_checks ac
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
   AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
       WHERE aip.check_id = ac.check_id
       AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	   WHERE aid.invoice_id = aip.invoice_id
	   AND (EXISTS (SELECT 1 FROM po_distributions pd
		WHERE pd.po_distribution_id = aid.po_distribution_id
		AND EXISTS(SELECT 1 FROM po_req_distributions prd
			WHERE prd.distribution_id = pd.req_distribution_id
			AND EXISTS (SELECT 1 FROM po_requisition_lines prl
				WHERE prl.requisition_line_id = prd.requisition_line_id
				AND EXISTS (SELECT 1 FROM po_requisition_headers prh
				    WHERE prh.requisition_header_id = prl.requisition_header_id
				    AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id )
				    AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))
		OR EXISTS (SELECT 1 FROM rcv_transactions rt
			WHERE rt.transaction_id = aid.rcv_transaction_id
			AND EXISTS (SELECT 1 FROM po_line_locations pll
			    WHERE pll.line_location_id = rt.po_line_location_id
			    AND EXISTS (SELECT 1 FROM  po_distributions pd
			        WHERE pd.line_location_id = pll.line_location_id
				AND EXISTS(SELECT 1 FROM po_req_distributions prd
				    WHERE prd.distribution_id = pd.req_distribution_id
				    AND EXISTS (SELECT 1 FROM po_requisition_lines prl
					WHERE prl.requisition_line_id = prd.requisition_line_id
					AND EXISTS (SELECT 1 FROM po_requisition_headers prh
				    	  WHERE prh.requisition_header_id = prl.requisition_header_id
				    	  AND prh.requisition_header_id =     NVL(vp_requisition_header_id,prh.requisition_header_id )
				          AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date)))))))))))

UNION
   SELECT check_id FROM ap_checks ac
   WHERE vendor_id = vp_vendor_id
   AND vendor_site_id = vp_vendor_site_id
   AND EXISTS (SELECT 1 FROM fv_doc_cr_temp
		WHERE check_id = ac.check_id
		AND session_id = vp_session_id)
      AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
       WHERE aip.check_id = ac.check_id
       AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
	   WHERE aid.invoice_id = aip.invoice_id
	   AND (EXISTS (SELECT 1 FROM po_distributions pd
		WHERE pd.po_distribution_id = aid.po_distribution_id
		AND EXISTS(SELECT 1 FROM po_req_distributions prd
			WHERE prd.distribution_id = pd.req_distribution_id
			AND EXISTS (SELECT 1 FROM po_requisition_lines prl
				WHERE prl.requisition_line_id = prd.requisition_line_id
				AND EXISTS (SELECT 1 FROM po_requisition_headers prh
				    WHERE prh.requisition_header_id = prl.requisition_header_id
				    AND prh.requisition_header_id = NVL(vp_requisition_header_id,prh.requisition_header_id )
				    AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date))))))
		OR EXISTS (SELECT 1 FROM rcv_transactions rt
			WHERE rt.transaction_id = aid.rcv_transaction_id
			AND EXISTS (SELECT 1 FROM po_line_locations pll
			    WHERE pll.line_location_id = rt.po_line_location_id
			    AND EXISTS (SELECT 1 FROM  po_distributions pd
			        WHERE pd.line_location_id = pll.line_location_id
				AND EXISTS(SELECT 1 FROM po_req_distributions prd
				    WHERE prd.distribution_id = pd.req_distribution_id
				    AND EXISTS (SELECT 1 FROM po_requisition_lines prl
					WHERE prl.requisition_line_id = prd.requisition_line_id
					AND EXISTS (SELECT 1 FROM po_requisition_headers prh
				    	  WHERE prh.requisition_header_id = prl.requisition_header_id
				    	  AND prh.requisition_header_id =     NVL(vp_requisition_header_id,prh.requisition_header_id )
				          AND TRUNC(prh.creation_date) = NVL(vp_req_date,TRUNC(prh.creation_date)))))))))));
req_rec req_cur%ROWTYPE;

CURSOR po_cur IS
	SELECT check_id FROM ap_checks ac
	 WHERE  vendor_id =  vp_vendor_id
	 AND vendor_site_id = vp_vendor_site_id
	 AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	 AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	      WHERE aip.check_id = ac.check_id
 	      AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		    WHERE aid.invoice_id = aip.invoice_id
		    AND (EXISTS (SELECT 1 FROM po_distributions pd
			   WHERE pd.po_distribution_id = aid.po_distribution_id
			   AND EXISTS(SELECT 1 FROM po_headers ph
				WHERE ph.po_header_id = pd.po_header_id
				AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
				AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date))))
		        OR EXISTS (SELECT 1 FROM rcv_transactions rt
			   WHERE rt.transaction_id = aid.rcv_transaction_id
			   AND EXISTS(SELECT 1 FROM po_headers ph
				WHERE ph.po_header_id = rt.po_header_id
				AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
				AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date)))))))

	UNION
	SELECT check_id FROM ap_checks ac
         WHERE  vendor_id =  vp_vendor_id
	 AND vendor_site_id = vp_vendor_site_id
	 AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
		WHERE  check_id= ac.check_id
		AND session_id = vp_session_id)
	 AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	      WHERE aip.check_id = ac.check_id
 	      AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		    WHERE aid.invoice_id = aip.invoice_id
		    AND (EXISTS (SELECT 1 FROM po_distributions pd
			   WHERE pd.po_distribution_id = aid.po_distribution_id
			   AND EXISTS(SELECT 1 FROM po_headers ph
				WHERE ph.po_header_id = pd.po_header_id
				AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
				AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date))))
		        OR EXISTS (SELECT 1 FROM rcv_transactions rt
			   WHERE rt.transaction_id = aid.rcv_transaction_id
			   AND EXISTS(SELECT 1 FROM po_headers ph
				WHERE ph.po_header_id = rt.po_header_id
				AND ph.po_header_id = NVL(vp_po_header_id,ph.po_header_id )
				AND TRUNC(ph.creation_date) = NVL( vp_po_date,TRUNC(ph.creation_date)))))));

  po_rec po_cur%ROWTYPE;

  CURSOR rec_cur IS
	SELECT check_id FROM ap_checks ac
	 WHERE  vendor_id =  vp_vendor_id
	 AND vendor_site_id = vp_vendor_site_id
	 AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	 AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	        WHERE aip.check_id = ac.check_id
	 	AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		    WHERE aid.invoice_id = aip.invoice_id
		    AND EXISTS (SELECT 1 FROM po_distributions pd WHERE pd.po_distribution_id = aid.po_distribution_id
		    	AND EXISTS( SELECT 1 FROM rcv_transactions rt
			      WHERE rt.po_line_location_id = pd.line_location_id
			      AND EXISTS(SELECT 1 FROM rcv_shipment_headers rsh
					WHERE rt.shipment_header_id = rsh.shipment_header_id
					AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
					AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date)))))))
	UNION
	SELECT check_id FROM ap_checks ac
	 WHERE  vendor_id =  vp_vendor_id
	 AND vendor_site_id = vp_vendor_site_id
	 AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
		WHERE check_id = ac.check_id
		AND session_id = vp_session_id)
	 AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
	        WHERE aip.check_id = ac.check_id
	 	AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
		    WHERE aid.invoice_id = aip.invoice_id
		    AND EXISTS (SELECT 1 FROM po_distributions pd WHERE pd.po_distribution_id = aid.po_distribution_id
		    	AND EXISTS( SELECT 1 FROM rcv_transactions rt
			      WHERE rt.po_line_location_id = pd.line_location_id
			      AND EXISTS(SELECT 1 FROM rcv_shipment_headers rsh
					WHERE rt.shipment_header_id = rsh.shipment_header_id
					AND rsh.shipment_header_id = NVL(vp_shipment_header_id,rsh.shipment_header_id )
					AND TRUNC(rsh.creation_date) = NVL( vp_rec_date,TRUNC(rsh.creation_date)))))));

rec_rec rec_cur%ROWTYPE;


      CURSOR inv_cur IS
      SELECT check_id FROM ap_checks ac
	   WHERE  vendor_id =  vp_vendor_id
		 AND vendor_site_id = vp_vendor_site_id
		 AND NOT EXISTS (SELECT 1 FROM fv_doc_cr_temp WHERE session_id = vp_session_id)
	         AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		             WHERE aip.check_id = ac.check_id
			     AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
			         WHERE aid.invoice_id = aip.invoice_id
			         AND EXISTS (SELECT 1 FROM ap_invoices ai
			  	     WHERE  ai.invoice_id = aid.invoice_id
			  	     AND invoice_type_lookup_code = NVL(vp_invoice_type,invoice_type_lookup_code)
				     AND ai.invoice_id = NVL(vp_invoice_id,ai.invoice_id )
				     AND ai.invoice_amount = NVL(vp_invoice_amount,ai.invoice_amount)
				     AND TRUNC(ai.invoice_date) = NVL( vp_invoice_date,TRUNC(ai.invoice_date)))))
	UNION
	SELECT check_id FROM ap_checks ac
	   WHERE  vendor_id =  vp_vendor_id
		 AND vendor_site_id = vp_vendor_site_id
		 AND  EXISTS (SELECT 1 FROM fv_doc_cr_temp
			WHERE check_id = ac.check_id
			AND session_id = vp_session_id)
	         AND EXISTS (SELECT 1 FROM ap_invoice_payments aip
		     WHERE aip.check_id = ac.check_id
		     AND EXISTS (SELECT 1 FROM ap_invoice_distributions aid
			WHERE aid.invoice_id = aip.invoice_id
			AND EXISTS (SELECT 1 FROM ap_invoices ai
			    WHERE  ai.invoice_id = aid.invoice_id
			    AND invoice_type_lookup_code = NVL(vp_invoice_type,invoice_type_lookup_code)
			    AND ai.invoice_id = NVL(vp_invoice_id,ai.invoice_id )
			    AND ai.invoice_amount = NVL(vp_invoice_amount,ai.invoice_amount)
			    AND TRUNC(ai.invoice_date) = NVL(    TRUNC(vp_invoice_date),TRUNC(ai.invoice_date)))));
     inv_rec inv_cur%ROWTYPE;

     CURSOR pay_cur IS
	SELECT check_id FROM ap_checks ac
		WHERE vendor_id =  vp_vendor_id
		AND vendor_site_id = vp_vendor_site_id
		AND ac.check_id =  NVL(vp_check_id,ac.check_id)
		AND ac.check_date = NVL(vp_check_date,ac.check_date)
		AND ac.amount = nvl(vp_amount,ac.amount)
		AND  (TRUNC(ac.treasury_pay_date) = TRUNC(vp_treasury_pay_date) OR vp_treasury_pay_date IS NULL)
		AND  NVL(ac.treasury_pay_number,-1) = NVL(vp_treasury_pay_number,NVL(ac.treasury_pay_number,-1));
   pay_rec pay_cur%ROWTYPE;

BEGIN
	DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
 	LOOP
	IF (vp_check_id IS NOT NULL  OR vp_check_date  IS NOT NULL
	   OR vp_amount   IS NOT NULL OR  vp_treasury_pay_date IS NOT NULL OR vp_treasury_pay_number IS NOT NULL) THEN
	   OPEN pay_cur;
	   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	   LOOP
	       FETCH pay_cur INTO pay_rec;
	       EXIT WHEN   pay_cur%NOTFOUND;
	       INSERT INTO fv_doc_cr_temp (check_id,session_id)
			VALUES (pay_rec.check_id,vp_session_id);
	  END LOOP;
	  IF NOT (pay_cur%rowcount <> 0 ) THEN
	     DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	     CLOSE pay_cur;
	     EXIT;
	  END IF;
	  CLOSE pay_cur;
        END IF;
      	IF  (vp_po_header_id   IS NOT NULL OR vp_po_date IS NOT NULL OR  vp_buyer IS NOT NULL) THEN
             OPEN po_cur;
             LOOP
                FETCH po_cur INTO po_rec;
                EXIT WHEN po_cur%NOTFOUND;
                INSERT INTO fv_doc_cr_temp (check_id,session_id)
			VALUES	  (po_rec.check_id,vp_session_id);
	    END LOOP;
	   IF NOT (po_cur%rowcount <> 0 ) THEN
	       DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	       CLOSE po_cur;
	       EXIT;
	   END IF;
	   CLOSE po_cur;
       END IF ;
       IF (vp_requisition_header_id  IS NOT NULL OR  vp_req_date is NOT NULL) THEN
          OPEN req_cur;
          DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
          LOOP
               FETCH req_cur INTO req_rec;
               EXIT WHEN   req_cur%NOTFOUND;
               INSERT INTO fv_doc_cr_temp (check_id,session_id)
			VALUES (req_rec.check_id,vp_session_id);
	  END LOOP;
	  IF NOT (req_cur%rowcount <> 0 ) THEN
	       DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
	       CLOSE req_cur;
	       EXIT;
	  END IF;
      	  CLOSE req_cur;
       END IF;
       IF  (vp_shipment_header_id  IS NOT NULL OR  vp_rec_date  is NOT NULL) THEN
	      OPEN rec_cur;
              DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
              LOOP
                  FETCH rec_cur INTO rec_rec;
                  EXIT WHEN   rec_cur%NOTFOUND;
  		  INSERT INTO fv_doc_cr_temp (check_id,session_id)
				VALUES (rec_rec.check_id,vp_session_id);
 	       END LOOP;
               IF NOT (rec_cur%rowcount <> 0 ) THEN
		   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
                   CLOSE rec_cur;
                   EXIT;
               END IF;
               CLOSE rec_cur;
        END IF;
        IF  (vp_invoice_id  IS NOT NULL OR vp_invoice_date  IS NOT NULL
	           OR  vp_invoice_type  IS NOT NULL OR  vp_invoice_amount IS NOT NULL) THEN
              OPEN inv_cur;
              DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
              LOOP
                    FETCH inv_cur INTO inv_rec;
                    EXIT WHEN   inv_cur%NOTFOUND;
 		   INSERT INTO fv_doc_cr_temp (check_id,session_id)
				VALUES (inv_rec.check_id,vp_session_id);
 	      END LOOP;
	      IF NOT (inv_cur%rowcount <> 0 ) THEN
		   DELETE FROM fv_doc_cr_temp WHERE session_id = vp_session_id;
		   CLOSE inv_cur;
 	           EXIT;
	      END IF;
	      CLOSE inv_cur;
        END IF;
        EXIT;
    END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     l_errbuf := SQLERRM;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
     RAISE;

 end pay_master;


END fv_cross_doc_ref;


----------------------------------------------------------------------
--				END OF PACKAGE BODY
----------------------------------------------------------------------


/
