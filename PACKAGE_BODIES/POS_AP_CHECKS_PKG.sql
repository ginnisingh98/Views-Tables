--------------------------------------------------------
--  DDL for Package Body POS_AP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_AP_CHECKS_PKG" AS
/* $Header: POSAPCKB.pls 120.1 2006/03/02 18:04:46 abtrived noship $ */


  ----------------------------------------------------------------------
  -- Procedure to return PO information associated with a payment
  -- Returns:
  --    p_po_switch = S/M/N/E (Single/Multiple/No/Exception)
  --    p_po_num  = <NUM>/'Multiple'
  --    p_header_id = <HEADER_ID>
  --    p_release_id = <RELEASE_ID>
  -- @ABTRIVED
  ----------------------------------------------------------------------
  PROCEDURE get_po_info(l_check_id IN NUMBER,
    				p_po_switch OUT NOCOPY VARCHAR2,
     				p_po_num OUT NOCOPY VARCHAR2,
     				p_header_id OUT NOCOPY VARCHAR2,
     				p_release_id OUT NOCOPY VARCHAR2)
     IS
         po_num2 VARCHAR2(40);
	 header_id2  VARCHAR2(20);
	 release_id2  VARCHAR2(20);

         -- Declare cursor to retrieve the PO number
         CURSOR po_cursor IS
         SELECT DISTINCT (ph.segment1||'-'||pr.release_num), ph.po_header_id, pr.po_release_id
           FROM ap_invoice_distributions_all aid,
                po_distributions_all pd,
                po_headers_all ph,
                po_releases_all	pr
          WHERE aid.invoice_id in (select invoice_id
                                   from ap_invoice_payments_all
                                   where check_id = l_check_id)
            AND aid.po_distribution_id = pd.po_distribution_id
            AND pr.po_release_id = pd.po_release_id
            AND ph.po_header_id	= pr.po_header_id
            AND ph.type_lookup_code = 'BLANKET'
          UNION ALL
         SELECT DISTINCT ph.segment1, ph.po_header_id, null
           FROM ap_invoice_distributions_all aid,
                po_distributions_all pd,
                po_headers_all ph
          WHERE aid.invoice_id in (select invoice_id
                                   from ap_invoice_payments_all
                                   where check_id = l_check_id)
            AND aid.po_distribution_id = pd.po_distribution_id
            AND pd.po_header_id     = ph.po_header_id
            AND ph.type_lookup_code = 'STANDARD';

     BEGIN


        OPEN po_cursor;

	   FETCH po_cursor INTO p_po_num, p_header_id, p_release_id;
           if (po_cursor%NOTFOUND) then
           	-- no po's
           	p_po_switch := 'N';
           else
              --atleast on po
              FETCH po_cursor INTO po_num2, header_id2, release_id2;
              if (po_cursor%NOTFOUND) then
              	 --exactly one PO
              	 p_po_switch := 'S';
              else
              	 -- multiple PO's
              	 p_po_switch := 'M';
              	 p_po_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
              end if;
           end if;

        CLOSE po_cursor;

     EXCEPTION WHEN OTHERS THEN

        p_po_switch := 'E';

     END get_po_info;


  ----------------------------------------------------------------------
  -- Procedure to return Invoice information associated with a payment
  -- Returns:
  --    p_invoice_switch = Po_Single/Po_Multiple/Po_No
  --    p_invoice_num  = <INVOICE_NUM>/'Multiple'
  --    p_invoice_id = <INVOICE_ID>
  -- @ABTRIVED
  ----------------------------------------------------------------------
  PROCEDURE get_invoice_info(l_check_id IN NUMBER,
    				p_invoice_switch OUT NOCOPY VARCHAR2,
     				p_invoice_num OUT NOCOPY VARCHAR2,
     				p_invoice_id OUT NOCOPY VARCHAR2)

  IS
      invoice_num2   VARCHAR2(225);
      invoice_id2    VARCHAR2(225);

      -- Declare cursor to return the Invoice number, Invoice Id
      CURSOR inv_cursor IS
      SELECT distinct ai.invoice_num, ai.invoice_id
      FROM   ap_invoices_all         ai,
             ap_invoice_payments_all aip
      WHERE  aip.check_id   = l_check_id
      AND    aip.invoice_id = ai.invoice_id;

  BEGIN

        OPEN inv_cursor;

 	   FETCH inv_cursor INTO p_invoice_num, p_invoice_id;
            if (inv_cursor%NOTFOUND) then
            	-- no invoices
            	p_invoice_switch := 'N';
            else
               --atleast one invoice
               FETCH inv_cursor INTO invoice_num2, invoice_id2;
               if (inv_cursor%NOTFOUND) then
               	 --exactly one invoice
               	 p_invoice_switch := 'S';
               else
               	 -- multiple
               	 p_invoice_switch := 'M';
               	 p_invoice_num := FND_MESSAGE.GET_STRING('PO','PO_WF_NOTIF_MULTIPLE');
               end if;
            end if;

         CLOSE inv_cursor;

 EXCEPTION
   WHEN OTHERS THEN

     if inv_cursor%isopen then
        close inv_cursor;
     end if;
     p_invoice_switch := 'E';

  END get_invoice_info;

END POS_AP_CHECKS_PKG;

/
