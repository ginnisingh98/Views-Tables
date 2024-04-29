--------------------------------------------------------
--  DDL for Package Body ITG_SYNCPOINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCPOINBOUND_PVT" AS
/* ARCS: $Header: itgvspib.pls 120.7 2006/08/29 16:35:19 pvaddana noship $
 * CVS:  itgvspib.pls,v 1.20 2002/12/23 21:20:30 ecoe Exp
 */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncPoInbound_PVT';
  g_action VARCHAR2(400);

  /* This is a single-line cache of the PO header id. */
  g_po_id   NUMBER;
  g_po_code VARCHAR2(20);
  g_org_id  NUMBER;

  /* Private function to make sure that the g_po_id value is correct. */
  PROCEDURE lookup_po_header(
    p_po_code VARCHAR2, /* width 20 */
    p_org_id  NUMBER,
    p_release_id VARCHAR2,
    p_doc_type IN OUT NOCOPY VARCHAR2) IS
	l_var VARCHAR2(50);
  BEGIN
    IF g_po_id   IS NULL      OR
       p_po_code <> g_po_code OR
       p_org_id  <> g_org_id  THEN

      /* Clear first. */
      g_po_code := NULL;
      g_po_id   := NULL;
      g_org_id  := NULL;

      /* Lookup po_id from p_po_code (segment1). */
      /* Exceptions here get thrown to caller. */
      SELECT po_header_id, type_lookup_code
      INTO   g_po_id, p_doc_type                /* The value we were looking for. */
      FROM   po_headers_all
      WHERE  segment1 = p_po_code
      AND    org_id   = p_org_id;

      /* Save the keys for repeated lookups. */
      g_po_code := p_po_code;
      g_org_id  := p_org_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ITG_MSG.no_po_found(p_po_code, p_org_id);
      RAISE FND_API.G_EXC_ERROR;
  END lookup_po_header;

  PROCEDURE Update_PoLine(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,

    p_po_code          IN         VARCHAR2,
    p_org_id           IN         VARCHAR2,
    p_release_id       IN         VARCHAR2 := NULL,
    p_line_num         IN         NUMBER,
    p_doc_type         IN         VARCHAR2,
    p_quantity         IN         NUMBER,
    p_amount           IN         NUMBER
  ) AS

    /* Business object constants. */
    l_api_name    CONSTANT VARCHAR2(30) := 'Update_PoLine';
    l_api_version CONSTANT NUMBER       := 1.0;

    /* rec_po_line_locations */
    TYPE lloc_rec IS RECORD (
      line_location_id        po_line_locations.line_location_id%TYPE,
      quantity                po_line_locations.quantity%TYPE,
      quantity_received       po_line_locations.quantity_received%TYPE,
      quantity_accepted       po_line_locations.quantity_accepted%TYPE,
      quantity_billed         po_line_locations.quantity_billed%TYPE,
      qty_rcv_tolerance       po_line_locations.qty_rcv_tolerance%TYPE,
      qty_rcv_exception_code  po_line_locations.qty_rcv_exception_code%TYPE,
      closed_code             po_line_locations.closed_code%TYPE,
      receive_close_tolerance po_line_locations.receive_close_tolerance%TYPE,
      process_date            po_line_locations.creation_date%TYPE,
      new_quantity            NUMBER,
      changed                 NUMBER
    );
    /* table_po_line_locations_ot */
    TYPE lloc_tab IS TABLE OF lloc_rec
      INDEX BY BINARY_INTEGER;

    CURSOR po_line_csr IS
      SELECT po_line_id,closed_code
      FROM   po_lines_all
      WHERE  po_header_id = g_po_id
      AND    line_num     = p_line_num;

    CURSOR po_relid_csr(p_header_id 	IN VARCHAR2,
				p_org 		IN VARCHAR2,
				p_release_num 	IN VARCHAR2) IS
	SELECT po_release_id
	FROM	 po_releases_all
	WHERE  po_header_id = p_header_id
	AND 	 release_num  = p_release_num
	AND	 org_id       = p_org;

    l_rec           po_line_csr%ROWTYPE;
    l_notfound      BOOLEAN;
    l_release_id    NUMBER;
    l_doc_typ       VARCHAR2(50);

    /* getClosedCodeForLineLocation */
    FUNCTION get_closed_code(
      p_lloc     IN lloc_rec,
      p_qty_oper IN NUMBER
    ) RETURN VARCHAR2 IS
    BEGIN
      ITG_Debug.msg('GCC', 'Entering ...');
      ITG_Debug.msg('GCC', 'Quantity',    p_lloc.quantity);
      ITG_Debug.msg('GCC', 'Quantity operation', p_qty_oper);
      ITG_Debug.msg('GCC', 'Tolerance',   p_lloc.receive_close_tolerance);
      ITG_Debug.msg('GCC', 'Closed code', p_lloc.closed_code);
      IF p_qty_oper >= (p_lloc.quantity - ROUND(
         p_lloc.quantity * p_lloc.receive_close_tolerance/100)) THEN
	IF NVL(p_lloc.closed_code, 'OPEN') = 'OPEN' THEN
	  IF p_doc_type = 'RECEIPT' THEN
	    RETURN 'RECEIVE CLOSE';
	  ELSE
	    RETURN 'INVOICE CLOSE';
	  END IF;
	ELSIF p_lloc.closed_code = 'CLOSED FOR INVOICE' THEN
	  IF p_doc_type = 'RECEIPT' THEN
	    RETURN 'CLOSE';
	  END IF;
	ELSIF p_lloc.closed_code = 'CLOSED FOR RECEIVING' THEN
	  IF p_doc_type = 'INVOICE' THEN
	    RETURN 'CLOSE';
	  END IF;
	END IF;
      ELSE
	IF p_lloc.closed_code = 'CLOSED' THEN
	  IF p_doc_type = 'RECEIPT' THEN
	    RETURN 'INVOICE OPEN';
	  ELSE
	    RETURN 'RECEIVE OPEN';
	  END IF;
	ELSIF p_lloc.closed_code = 'CLOSED FOR INVOICE' THEN
	  IF p_doc_type = 'INVOICE' THEN
	    RETURN 'INVOICE OPEN';
	  END IF;
	ELSIF p_lloc.closed_code = 'CLOSED FOR RECEIVING' THEN
	  IF p_doc_type = 'RECEIPT' THEN
	    RETURN 'RECEIPT OPEN';
	  END IF;
	END IF;
      END IF;
      RETURN NULL;
    END get_closed_code;

    /* allocateAcrossLineLocations */
    FUNCTION aa_llocs(
      l_lltab IN OUT NOCOPY lloc_tab
    ) RETURN BOOLEAN /* leftover */ AS

      TYPE line_loc_csr_typ IS REF CURSOR RETURN lloc_rec;

      line_loc_csr line_loc_csr_typ;
      l_tmp        lloc_rec;
      l_subj_qty   NUMBER;
      l_base_qty   NUMBER;
      l_qty        NUMBER;
      l_tmp_qty    NUMBER;
      l_last       NUMBER;
      l_tot_rec_qty number :=0; -- Added following 3 declarations to  fix bug 4882347
      l_tot_bill_qty number :=0;
      l_tot_insp_qty number :=0;
      PROCEDURE setup_doctype_qtys(x_rec IN OUT NOCOPY lloc_rec) IS
      BEGIN
        IF    p_doc_type = 'RECEIPT'    THEN
	  l_subj_qty := x_rec.quantity_received;
	  l_base_qty := x_rec.quantity;
	ELSIF p_doc_type = 'INSPECTION' THEN
	  l_subj_qty := x_rec.quantity_accepted;
	  l_base_qty := x_rec.quantity_received;
	ELSIF p_doc_type = 'INVOICE'    THEN
	  l_subj_qty := x_rec.quantity_billed;
	  l_base_qty := x_rec.quantity;
        END IF;
      END;

      PROCEDURE change_doctype_qtys(x_rec IN OUT NOCOPY lloc_rec) IS
      BEGIN
	/* Set the newly allocated value for this line to the
         * appropriate PLS table field, based on doctype.
	 */
        IF    p_doc_type = 'RECEIPT'    THEN
	  x_rec.quantity_received := l_subj_qty;
	ELSIF p_doc_type = 'INSPECTION' THEN
	  x_rec.quantity_accepted := l_subj_qty;
        ELSIF p_doc_type = 'INVOICE'    THEN
	  x_rec.quantity_billed   := l_subj_qty;
	END IF;
        x_rec.changed := 1;
      END;

    BEGIN
      ITG_Debug.msg('AALL', 'Entering...');

      l_lltab.delete;
      l_qty := p_quantity;
      IF l_release_id IS NULL THEN
        /* This is a standard PO. */
	IF l_qty > 0 THEN
	  /* Positive quantity, this is a RECEIPT against standard POs */
	  OPEN line_loc_csr FOR
	    SELECT   line_location_id,
		     quantity,
		     quantity_received,
		     quantity_accepted,
		     quantity_billed,
		     qty_rcv_tolerance,
		     qty_rcv_exception_code,
		     closed_code,
		     receive_close_tolerance,
		     NVL(need_by_date, promised_date) process_date,
		     0                                new_quantity,
		     0                                changed
	    FROM     po_line_locations_all
	    WHERE    po_line_id = l_rec.po_line_id
	    ORDER BY process_date;
	ELSE
	  /* Negative quantity, this is a RETURN against standard POs.
	   * The only difference is reverse sort order.
	   */
	  OPEN line_loc_csr FOR
	    SELECT   line_location_id,
		     quantity,
		     quantity_received,
		     quantity_accepted,
		     quantity_billed,
		     qty_rcv_tolerance,
		     qty_rcv_exception_code,
		     closed_code,
		     receive_close_tolerance,
		     NVL(promised_date, need_by_date) process_date,
		     0                                new_quantity,
		     0                                changed
	    FROM     po_line_locations_all
	    WHERE    po_line_id = l_rec.po_line_id
	    ORDER BY process_date DESC;
	END IF;
      ELSE
        /* This is a RELEASE against a BPO. */
	IF l_qty > 0 THEN

	  /* Positive quantity, this is a RECEIPT against blanket PO
	   * releases.
	   */
	  OPEN line_loc_csr FOR
	    SELECT   line_location_id,
		     quantity,
		     quantity_received,
		     quantity_accepted,
		     quantity_billed,
		     qty_rcv_tolerance,
		     qty_rcv_exception_code,
		     closed_code,
		     receive_close_tolerance,
		     NVL(need_by_date, promised_date) process_date,
		     0                                new_quantity,
		     0                                changed
	    FROM     po_line_locations_all
	    WHERE    po_release_id = l_release_id
	    AND      po_header_id  = g_po_id
	    ORDER BY process_date;
	ELSE
	  /* Negative quantity, this is a RETURN against blanket PO releases.
	   * The only difference is reverse sort order.
	   */
	  OPEN line_loc_csr FOR
	    SELECT   line_location_id,
		     quantity,
		     quantity_received,
		     quantity_accepted,
		     quantity_billed,
		     qty_rcv_tolerance,
		     qty_rcv_exception_code,
		     closed_code,
		     receive_close_tolerance,
		     NVL(promised_date, need_by_date) process_date,
		     0                                new_quantity,
		     0                                changed
	    FROM     po_line_locations_all
	    WHERE    po_release_id = l_release_id
	    AND      po_header_id  = g_po_id
	    ORDER BY process_date DESC;
        END IF;
      END IF;

      /* Read the data. */
      ITG_Debug.msg('AALL', 'Reading the data.');
      LOOP
        FETCH line_loc_csr INTO l_tmp;
	IF line_loc_csr%NOTFOUND THEN
	  EXIT;
	END IF;
	l_lltab(line_loc_csr%ROWCOUNT) := l_tmp; /* Added following assignments to fix bug 4882347 */
        l_tot_rec_qty  := l_tot_rec_qty  + l_lltab(line_loc_csr%ROWCOUNT).quantity_received;
        l_tot_bill_qty := l_tot_bill_qty + l_lltab(line_loc_csr%ROWCOUNT).quantity_billed;
        l_tot_insp_qty := l_tot_insp_qty + l_lltab(line_loc_csr%ROWCOUNT).quantity_accepted;
      END LOOP;
      CLOSE line_loc_csr;
   /* Added if-else block  to check whether Invoice and Inspection qty is more than  allowable qty, to fix 4882347 bug*/
      IF  p_doc_type = 'INVOICE'    THEN
       IF  ( l_tot_rec_qty  - l_tot_bill_qty ) < l_qty THEN
           ITG_MSG.inv_qty_larg_than_exp;
	   RAISE FND_API.G_EXC_ERROR;
       END IF;
      ELSIF p_doc_type = 'INSPECTION' THEN
        IF ( l_tot_rec_qty - l_tot_insp_qty )  < l_qty THEN
          ITG_MSG.insp_qty_larg_than_exp;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

      l_last := -1;
      /* Distrubute the quantity. */
      ITG_Debug.msg('AALL', 'Distributing the quantity.');
      FOR i in 1 .. l_lltab.count LOOP
        l_last := i;
        setup_doctype_qtys(l_lltab(i));
	IF l_qty > 0 THEN
	  IF l_base_qty - l_subj_qty >= l_qty THEN
	    /* Additional quantity available to allocate is greater than or
	     * equal to the Quantity to allocate, thus total quantity can be
	     * allocated here.
	     */
	    ITG_Debug.msg('AALL', 'Full allocate.');
	    l_subj_qty              := l_subj_qty + l_qty;
	    l_lltab(i).new_quantity := l_qty;
	    l_qty                   := 0;
	  ELSE
	    /* Quantity to allocate is more than the additional Quantity
	     * available to allocate, thus allocate the max available without
	     * tolerance.
	     */
	    ITG_Debug.msg('AALL', 'Partial allocate.');
	    l_lltab(i).new_quantity := l_base_qty - l_subj_qty;
	    l_subj_qty              := l_base_qty;
	    l_qty                   := l_qty - l_lltab(i).new_quantity;
	  END IF;
	ELSE
	  /* Negative l_qty for RETURNs or CR INVOICEs, no NEG INSPECTIONs. */
	  IF l_subj_qty >= ABS(l_qty) THEN
	    /* Quantity previously received and available to return is
             * greater than or equal to the Quantity to allocate, thus
             * total quantity can be allocated here.
	     */
	    ITG_Debug.msg('AALL', 'Full CR allocate.');
	    l_subj_qty              := l_subj_qty + l_qty;
	    l_lltab(i).new_quantity := l_qty;
	    l_qty                   := 0;
	  ELSE
	    /* Quantity to allocate is more than the Quantity previously
             * received, thus allocate the max available without tolerance.
	     */
	    ITG_Debug.msg('AALL', 'Partial CR allocate.');
	    l_lltab(i).new_quantity := 0 - l_subj_qty;
	    l_subj_qty              := 0;
	    l_qty                   := l_qty - l_lltab(i).new_quantity;
	  END IF;
	END IF;
        ITG_Debug.msg('AALL', 'l_qty',      l_qty);
	ITG_Debug.msg('AALL', 'l_subj_qty', l_subj_qty);
	change_doctype_qtys(l_lltab(i));
	EXIT WHEN l_qty = 0;
      END LOOP;

      /* If p_qty isn't 0, then we need to check for error or continue with
       * tolerance processing.  (Note that the last used index value is
       * carried forward from the loop as 'l_last'.)
       */
      IF    l_qty < 0 THEN
        /* Trying to RETURN or CREDIT more than received or billed. */
	ITG_MSG.allocship_toomany_rtn;
	RAISE FND_API.G_EXC_ERROR;
      ELSIF l_qty > 0 THEN
        ITG_Debug.msg('AALL', 'More quantity', l_qty);
        /* Still have more?  Lets try put those in the last shipment line.
         * We need to worry about the tolerance level while trying to
         * allocate remaining l_qty if exception code is REJECT.  Calculate
         * the maximum additional tolerance quantity receiveable on this
         * line.
	 */
	IF l_last < 0 THEN
	  ITG_MSG.no_line_locs_found;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	l_tmp := l_lltab(l_last);
	l_tmp_qty := ROUND(l_base_qty * NVL(l_tmp.qty_rcv_tolerance, 0) / 100);

	IF  l_tmp.qty_rcv_exception_code = 'REJECT'
	AND l_tmp_qty < l_qty
        THEN
          /* Allocate the additional quantity, even though it's not enough.
	   * (The non-zero l_qty will cause the aa_llocs function to return
	   *  TRUE, indicating a leftover quantity problem).
	   */
	  l_subj_qty         := l_subj_qty         + l_tmp_qty;
	  l_tmp.new_quantity := l_tmp.new_quantity + l_tmp_qty;
	  l_qty              := l_qty              - l_tmp_qty;
	  ITG_Debug.msg('AALL', 'Partial DB tolerance.');
	ELSE
	  /* Exception code is not REJECT or the tolerance quantity is
           * enough to cover the extra needed, put everything in last
           * shipment line.
	   */
	  l_subj_qty         := l_subj_qty         + l_qty;
	  l_tmp.new_quantity := l_tmp.new_quantity + l_qty;
	  l_qty              := 0;
	  IF l_tmp.qty_rcv_exception_code = 'REJECT' THEN
	    ITG_Debug.msg('AALL', 'Full DB tolerance.');
          ELSE
	    ITG_Debug.msg('AALL', 'Partial DB no tolerance.');
	  END IF;
	END IF;
        ITG_Debug.msg('AALL', 'l_qty',      l_qty);
	ITG_Debug.msg('AALL', 'l_subj_qty', l_subj_qty);
	change_doctype_qtys(l_tmp);
	l_lltab(l_last) := l_tmp;
      END IF;
      ITG_Debug.msg('AALL', 'Leaving with leftover', l_qty);
      /* Indicate any leftover quantity problem. */
      RETURN l_qty <> 0;
    END aa_llocs;

    /* allocateAcrossDistributions */
    PROCEDURE aa_dists(
      p_line_loc_id  NUMBER,
      p_quantity     NUMBER,
      p_total_amount NUMBER
    ) IS

      CURSOR po_dist_csr IS
        SELECT po_distribution_id,
	       quantity_ordered,
	       quantity_billed,
	       quantity_delivered,
	       amount_billed
	FROM   po_distributions_all
	WHERE  line_location_id = p_line_loc_id;

      TYPE po_dist_rec IS RECORD (
	   po_distribution_id po_distributions_all.po_distribution_id%TYPE,
	   quantity_ordered   po_distributions_all.quantity_ordered%TYPE,
	   quantity_billed    po_distributions_all.quantity_billed%TYPE,
	   quantity_delivered po_distributions_all.quantity_delivered%TYPE,
	   amount_billed      po_distributions_all.amount_billed%TYPE);

      TYPE po_dist_tab IS TABLE OF po_dist_rec
	INDEX BY BINARY_INTEGER;

      i          NUMBER;
      l_oper     NUMBER;
      l_quantity NUMBER;
      l_disttab po_dist_tab;

    BEGIN
      ITG_Debug.msg('AAD', 'Entering..');
      ITG_Debug.msg('AAD', 'line_loc_id', p_line_loc_id);
      ITG_Debug.msg('AAD', 'quantity',    p_quantity);
      l_quantity := p_quantity;
      l_disttab.DELETE;
      FOR rec IN po_dist_csr LOOP
        /* Determine how much to allocate to each distribution line. */
	i := po_dist_csr%ROWCOUNT;
	l_disttab(i) := rec;
	ITG_Debug.msg('AAD', 'i', i);
	ITG_Debug.msg('AAD', 'po_distribution_id',
	                     l_disttab(i).po_distribution_id);
	ITG_Debug.msg('AAD', 'quantity_ordered',
                             l_disttab(i).quantity_ordered);
	ITG_Debug.msg('AAD', 'quantity_billed',
	                     l_disttab(i).quantity_billed);
	ITG_Debug.msg('AAD', 'quantity_delivered',
	                     l_disttab(i).quantity_delivered);
	ITG_Debug.msg('AAD', 'amount_billed',
	                     l_disttab(i).amount_billed);

	/* Get the appropriate quantity to compare, based on doctype. */
	IF p_doc_type = 'RECEIPT' THEN
	  l_oper := l_disttab(i).quantity_delivered;
	ELSIF p_doc_type = 'INVOICE' THEN
	  l_oper := l_disttab(i).quantity_billed;
	END IF;
	ITG_Debug.msg('AAD', 'quantity_ordered',l_disttab(i).quantity_ordered);
	ITG_Debug.msg('AAD', 'quantity_operate',l_oper);
	ITG_Debug.msg('AAD', 'quantity',        l_quantity);

	IF l_quantity > 0 THEN
	  IF l_disttab(i).quantity_ordered - l_oper >= l_quantity THEN
	    /* Additional quantity which can be allocated is greater than or
	     * equal to the quantity to allocate, thus total quantity can be
	     * allocated here.
	     */
	    l_oper     := l_oper + l_quantity;
	    l_quantity := 0;
	    ITG_Debug.msg('AAD', 'Full allocate ...');
	  ELSE
	    /* Quantity to allocate is more than the additional quantity
	     * available to allocate, thus allocate the max available.
	     */
	    l_quantity := l_quantity -
	                  (l_disttab(i).quantity_ordered - l_oper);
	    l_oper     := l_disttab(i).quantity_ordered;
	    ITG_Debug.msg('AAD', 'Partial allocate ...');
	  END IF;  /* Full or Partial allocation to this line? */
	ELSIF l_quantity < 0 THEN
	  IF l_oper >= ABS(l_quantity) THEN
	    /* Quantity previously received and available to return is
	     * greater than or equal to the quantity to allocate, thus
	     * total quantity can be allocated here.
	     */
	    l_oper     := l_oper + l_quantity;
	    l_quantity := 0;
	    ITG_Debug.msg('AAD', 'Full CR allocate ...');
	  ELSE
	    /* Quantity to allocate is more than the quantity previously
	     * received, thus allocate the max available without tolerance.
	     */
	    l_quantity := l_quantity + l_oper;
	    l_oper     := 0;
	    ITG_Debug.msg('AAD', 'Partial CR allocate ...');
	  END IF;  /* Full or Partial allocation to this line? */
	END IF;  /* POS or NEG totalQuantity? */
        ITG_Debug.msg('AAD', 'quantity_operate', l_oper);
	ITG_Debug.msg('AAD', 'quantity',         l_quantity);

	/* Return the newly allocated value for this line to the appropriate
	 * PLS table field, based on doctype.
	 */
	IF p_doc_type = 'RECEIPT' THEN
	  l_disttab(i).quantity_delivered := l_oper;
	ELSIF p_doc_type = 'INVOICE' THEN
	  l_disttab(i).quantity_billed    := l_oper;
	END IF;
	EXIT WHEN l_quantity = 0;
      END LOOP;

      /* If there is more to allocate, then allocate all to the LAST
       * distribution, as there is no tolerance processing for distributions.
       */
      IF l_quantity > 0 THEN
	IF p_doc_type = 'RECEIPT' THEN
	  l_disttab(i).quantity_delivered := l_disttab(i).quantity_delivered +
	                                     l_quantity;
	  l_quantity := 0;
	  ITG_Debug.msg('AAD', 'Recv. DB no tolerance ...');
	ELSIF p_doc_type = 'INVOICE' THEN
	  l_disttab(i).quantity_billed := l_disttab(i).quantity_billed +
	                                  l_quantity;
	  l_quantity := 0;
	  ITG_Debug.msg('AAD', 'Invoice DB no tolerance ...');
	END IF;
        ITG_Debug.msg('AAD', 'quantity_operate', l_oper);
	ITG_Debug.msg('AAD', 'quantity',         l_quantity);
      ELSIF l_quantity < 0 THEN
        /* Trying to distribute a RETURN and more is needed to RETURN than
	 * was initially distributed.  This should NOT be able to happen.
	 */
	ITG_MSG.allocdist_toomany_rtn;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Ok time to update the table.. */
      ITG_Debug.msg('AAD', 'Update po_distributions_all ...');
      IF p_doc_type = 'RECEIPT' THEN
	FOR i IN 1 .. l_disttab.COUNT LOOP
	  UPDATE po_distributions_all
	  SET    quantity_delivered = l_disttab(i).quantity_delivered,
		 last_update_date   = SYSDATE,
		 last_updated_by    = FND_GLOBAL.user_id
	  WHERE  po_distribution_id = l_disttab(i).po_distribution_id;
	  ITG_Debug.msg('AAD', 'po_distribution_id',
	                       l_disttab(i).po_distribution_id);
	  ITG_Debug.msg('AAD', 'quantity_delivered',
			       l_disttab(i).quantity_delivered);
	END LOOP;
      ELSIF p_doc_type = 'INVOICE' THEN
	FOR i IN 1 .. l_disttab.COUNT LOOP
	  UPDATE po_distributions_all
	  SET    quantity_billed  = l_disttab(i).quantity_billed,
		 amount_billed    = NVL(amount_billed,0) +
		   (l_disttab(i).quantity_billed / p_quantity) *
		   p_total_amount,
		 last_update_date = SYSDATE,
		 last_updated_by  = FND_GLOBAL.user_id
	  WHERE  po_distribution_id = l_disttab(i).po_distribution_id;
	  ITG_Debug.msg('AAD', 'po_distribution_id',
					l_disttab(i).po_distribution_id);
	  ITG_Debug.msg('AAD', 'quantity_billed',
					l_disttab(i).quantity_billed);
	END LOOP;
      END IF;
      ITG_Debug.msg('AAD', 'Leaving.');
    END aa_dists;

    /* allocateAcrossReqLineLocs */
    PROCEDURE aa_rllocs(
      p_new_quantity  NUMBER
    ) IS
      /* There is not a 1:1 match between Requisition lines and Shipment
       * lines, nor is the PO Line ID stored in the requisition line...
       * the shipment line is... even though there could be more than 1
       * shipment line for this req line. Thus, the requisition line is
       * matched in this cursor against any of the shipment lines for the
       * PO line.
       */
      CURSOR po_req_lines_csr IS
	SELECT requisition_line_id,
	       quantity,
	       quantity_delivered
	FROM   po_requisition_lines_all
	WHERE  line_location_id IN (
	  SELECT line_location_id
	  FROM   po_line_locations_all
	  WHERE  po_line_id  = l_rec.po_line_id)
	ORDER  BY need_by_date;

      TYPE po_req_lines_rec IS RECORD (
	requisition_line_id po_requisition_lines_all.requisition_line_id%TYPE,
	quantity            po_requisition_lines_all.quantity%TYPE,
	quantity_delivered  po_requisition_lines_all.quantity_delivered%TYPE
      );

      TYPE po_req_lines_tab IS TABLE OF po_req_lines_rec
	INDEX BY BINARY_INTEGER;

      l_reqlltab po_req_lines_tab;
      i          NUMBER := 0;
      l_qty      NUMBER;

    BEGIN
      ITG_Debug.msg('ARL', 'Entering...');
      ITG_Debug.msg('ARL', 'new_quantity', p_new_quantity);
      l_qty := p_new_quantity;
      l_reqlltab.DELETE;

      FOR rec IN po_req_lines_csr LOOP
        /* Determine how much to allocate to each requisition line */
	i := po_req_lines_csr%ROWCOUNT;
	l_reqlltab(i) := rec;
	ITG_Debug.msg('ARL', 'i', i);

	IF l_qty > 0 THEN
	  IF l_reqlltab(i).quantity -
	     l_reqlltab(i).quantity_delivered >= l_qty THEN
	    /* Additional quantity which can be allocated is greater than
	     * or to the quantity to allocate, thus totalQuantity can be
	     * allocated here.
	     */
	    ITG_Debug.msg('ARL', 'Allocating full ...');
	    l_reqlltab(i).quantity_delivered :=
	      l_reqlltab(i).quantity_delivered + l_qty;
	    l_qty := 0;
	  ELSE
	    /* Quantity to allocate is more than the additional Quantity to
	     * allocate, thus allocate the max available.
	     */
	    ITG_Debug.msg('ARL', 'Allocating max ...');
	    l_qty := l_qty -
	      (l_reqlltab(i).quantity - l_reqlltab(i).quantity_delivered);
	    l_reqlltab(i).quantity_delivered := l_reqlltab(i).quantity;
	  END IF;  /* Full or Partial allocation to this line? */
	  ITG_Debug.msg('ARL', 'quantity',           l_reqlltab(i).quantity);
	  ITG_Debug.msg('ARL', 'quantity_delivered',
	                                   l_reqlltab(i).quantity_delivered);
	  ITG_Debug.msg('ARL', 'quantity need',      l_qty);
	ELSIF l_qty < 0 THEN
	  IF l_reqlltab(i).quantity_delivered >= ABS(l_qty) THEN
	    /* Quantity previously received and available to return is greater
	     * than or equal to the quantity to allocate, thus totalQuantity
	     * can be allocated here.
	     */
	    ITG_Debug.msg('ARL', 'Allocating CR full ...');
	    l_reqlltab(i).quantity_delivered :=
	      l_reqlltab(i).quantity_delivered + l_qty;
	    l_qty := 0;
	  ELSE
	    /* Quantity to allocate is more than the additional quantity to
	     * allocate, thus allocate the max available.
	     */
	    ITG_Debug.msg('ARL', 'Allocating CR Partial ...');
	    l_qty := l_qty + l_reqlltab(i).quantity_delivered;
	    l_reqlltab(i).quantity_delivered := 0;
	  END IF;  /* Full or Partial CR allocation to this line? */
	ELSE  /* l_qty = 0, so all have been allocated */
	  EXIT;
	END IF;  /* POS or NEG totalQuantity? */
	EXIT WHEN l_qty = 0;
      END LOOP;  /* For each requisition line */

      ITG_Debug.msg('ARL', '# of req. ship lines', i);
      /* IF no lines were found, THEN return. */
      IF i = 0 THEN
        ITG_Debug.msg('ARL', 'NO req. ship lines found ...');
	RETURN;
      END IF;

      /* If there is more to allocate, the allocate all to the LAST
       * requisition line, as there is no tolerance processing for
       * requisitions.
       */
      IF l_qty > 0 THEN
	ITG_Debug.msg('ARL', 'Over-allocating to the last ...');
	l_reqlltab(i).quantity_delivered := l_reqlltab(i).quantity_delivered +
					  l_qty;
	l_qty := 0;
      ELSIF l_qty < 0 THEN
        /* Trying to distribute a RETURN and more is needed to RETURN than
	 * was initially distributed.  This should NOT be able to happen.
	 */
	ITG_MSG.allocreqn_toomany_rtn;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Time to update the table */
      ITG_Debug.msg('ARL', 'Updating po_requisition_lines_all ...');
      ITG_Debug.msg('ARL', 'l_reqlltab.COUNT', l_reqlltab.COUNT);
      FOR i IN 1 .. l_reqlltab.COUNT LOOP
	UPDATE po_requisition_lines_all
	SET    quantity_delivered = l_reqlltab(i).quantity_delivered,
	       last_update_date   = SYSDATE,
	       last_updated_by    = FND_GLOBAL.user_id
	WHERE  requisition_line_id = l_reqlltab(i).requisition_line_id;
	ITG_Debug.msg('ARL', 'requisition_line_id',
			     l_reqlltab(i).requisition_line_id);
	ITG_Debug.msg('ARL', 'quantity_delivered',
			     l_reqlltab(i).quantity_delivered);
      END LOOP;
      ITG_Debug.msg('ARL', 'Leaving.');
    END aa_rllocs;

    /* ~processReceipt */
    PROCEDURE process_receipt_doc IS
      i             NUMBER;
      l_closed_code po_line_locations.closed_code%TYPE;
      l_doc_type    VARCHAR2(10);
      l_doc_subtype VARCHAR2(10);
      l_return_code VARCHAR2(25) := ' ';
      l_lltab       lloc_tab;
    BEGIN
	g_action := 'processing receipt information';
      ITG_Debug.msg('PRD', 'Entering...');
      IF p_quantity > 0 AND (l_rec.closed_code = 'CLOSED FOR RECEIVING' OR
                             l_rec.closed_code = 'CLOSED') THEN
        ITG_MSG.poline_closed_rcv;
	RAISE FND_API.G_EXC_ERROR;
      /*Added p_quantiyy < 0  to fix bug 5438268 */
      ELSIF p_quantity < 0 THEN
        ITG_MSG.poline_negqty_rcv;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF p_quantity = 0 THEN
        ITG_MSG.poline_zeroqty_rcv;
        RAISE FND_API.G_EXC_ERROR;

      ELSE
        /* processReceipt */
	IF aa_llocs(l_lltab) THEN
          ITG_MSG.receipt_tol_exceeded;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_release_id IS NULL THEN
	  l_doc_type    := 'PO';
	  l_doc_subtype := 'STANDARD';
	ELSE
	  l_doc_type    := 'RELEASE';
	  l_doc_subtype := 'BLANKET';
	END IF;

	FOR i IN 1 .. l_lltab.count LOOP
          ITG_Debug.msg('PRD', 'Line location id',l_lltab(i).line_location_id);
          IF l_lltab(i).changed <> 0 THEN
	     ITG_Debug.msg('PRD', 'Call distributions', i);
	     ITG_Debug.msg('PRD', 'New quantity',
				  l_lltab(i).new_quantity);
             aa_dists(l_lltab(i).line_location_id,
	              l_lltab(i).new_quantity, 0);
             aa_rllocs(l_lltab(i).new_quantity);
          END IF;

	  ITG_Debug.msg('PRD', 'update po_line_locations_all');
          UPDATE po_line_locations_all
          SET    quantity_received = l_lltab(i).quantity_received,
                 last_update_date  = SYSDATE,
                 last_updated_by   = FND_GLOBAL.user_id
          WHERE  line_location_id  = l_lltab(i).line_location_id;
	  ITG_Debug.msg('PRD', 'quantity_received',
			       l_lltab(i).quantity_received);

          l_closed_code := get_closed_code(
            l_lltab(i), l_lltab(i).quantity_received);
	  ITG_Debug.msg('PRD', 'closed_code', l_closed_code);
	  IF l_closed_code IS NOT NULL THEN
	    ITG_Debug.msg('PRD', 'close PO called...');
	    ITG_Debug.msg('PRD', 'doc ID',   g_po_id);
	    ITG_Debug.msg('PRD', 'doc type', l_doc_type);
	    ITG_Debug.msg('PRD', 'line ID',  l_rec.po_line_id);
	    ITG_Debug.msg('PRD', 'ship ID',  l_lltab(i).line_location_id);

          /*Added following if <cond> and else part to fix bug :5258514 */
          IF p_release_id IS  NULL or p_release_id =0 THEN

            IF NOT PO_ACTIONS.close_po(
	      p_docID        => g_po_id,
	      p_doctyp       => l_doc_type,
	      p_docsubtyp    => l_doc_subtype,
	      p_lineid       => l_rec.po_line_id,
	      p_shipid       => l_lltab(i).line_location_id,
	      p_action       => l_closed_code,
	      p_calling_mode => 'RCV',
	      p_return_code  => l_return_code,
	      p_auto_close   => 'Y'
            ) THEN
	      ITG_Debug.msg('PRD', 'Close PO failed...');
	      ITG_Debug.msg('PRD', 'return code', l_return_code);
	      ITG_MSG.receipt_closepo_fail(l_return_code);
	      RAISE FND_API.G_EXC_ERROR;
	    ELSE
	      ITG_Debug.msg('PRD', 'Close PO succeded');
	      ITG_Debug.msg('PRD', 'return code', l_return_code);
	    END IF;
        ELSE
        IF NOT PO_ACTIONS.close_po(
	      p_docID        => l_release_id,
	      p_doctyp       => l_doc_type,
	      p_docsubtyp    => l_doc_subtype,
	      p_lineid       => l_rec.po_line_id,
	      p_shipid       => l_lltab(i).line_location_id,
	      p_action       => l_closed_code,
	      p_calling_mode => 'RCV',
	      p_return_code  => l_return_code,
	      p_auto_close   => 'Y'
            ) THEN
	      ITG_Debug.msg('PRD', 'Close Release failed...');
	      ITG_Debug.msg('PRD', 'return code', l_return_code);
	      ITG_MSG.receipt_closerelease_fail(l_return_code);
	      RAISE FND_API.G_EXC_ERROR;
	    ELSE
	      ITG_Debug.msg('PRD', 'Close Release succeded');
	      ITG_Debug.msg('PRD', 'return code', l_return_code);
	    END IF;
        END IF; --END FOR  P_RELAESE_ID BLOCK
      END IF; --END FOR L_CLOSED_CODE BLOCK
	END LOOP;
      END IF;
    END process_receipt_doc;

    /* ~processInspection */
    PROCEDURE process_inspection_doc IS
      i           NUMBER;
      l_lltab     lloc_tab;
    BEGIN
	g_action := 'processing inspection information';
      ITG_Debug.msg('PID', 'Entering...');
      IF p_quantity > 0 THEN
        /* processInspection */
        IF aa_llocs(l_lltab) THEN
          ITG_MSG.inspect_tol_exceeded;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

        FOR i IN 1 .. l_lltab.count LOOP
          UPDATE po_line_locations_all
          SET    quantity_accepted = l_lltab(i).quantity_accepted,
                 last_update_date  = SYSDATE,
                 last_updated_by   = FND_GLOBAL.user_id
          WHERE  line_location_id  = l_lltab(i).line_location_id;
	  ITG_Debug.msg('PID', 'Update po_line_locations_all');
	  ITG_Debug.msg('PID', 'quantity_accepted',
			       l_lltab(i).quantity_accepted);
	  ITG_Debug.msg('PID', 'line_location_id',
			       l_lltab(i).line_location_id);
	END LOOP;
      ELSIF p_quantity < 0 THEN
        ITG_MSG.poline_negqty_ins;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        ITG_MSG.poline_zeroqty_ins;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END process_inspection_doc;

    /* ~processInvoice */
    PROCEDURE process_invoice_doc IS
      i              NUMBER;
      l_closed_code  po_line_locations.closed_code%TYPE;
      l_doc_type     VARCHAR2(10);
      l_doc_subtype  VARCHAR2(10);
      l_return_code  VARCHAR2(25) := ' ';
      l_qty          NUMBER;
      l_lltab        lloc_tab;
    BEGIN
	g_action := 'processing invoice information';
      ITG_Debug.msg('PI', 'Entering...');
      IF p_amount = 0 THEN
        ITG_MSG.poline_zeroamt_inv;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF SIGN(p_quantity) <> SIGN(p_amount) AND
            SIGN(p_quantity) <> 0              THEN
        ITG_MSG.poline_badsign_inv;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_rec.closed_code = 'CLOSED FOR INVOICE' OR
            l_rec.closed_code = 'CLOSED'             THEN
        ITG_MSG.poline_closed_inv;
	RAISE FND_API.G_EXC_ERROR;
      ELSE
        /* processInvoice */
	IF aa_llocs(l_lltab) THEN
	  /* If there more stuff to allocate, then we got a problem, send a
           * message: 'Receipt Tolerance Exceeded'
	   */
	  ITG_MSG.invoice_tol_exceeded;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	/* Process the distributions */
	FOR i IN 1 .. l_lltab.COUNT LOOP
	  IF l_lltab(i).changed <> 0 THEN
	    aa_dists(l_lltab(i).line_location_id,
	             l_lltab(i).quantity_billed, p_amount);
	  END IF;

	  /* Get the closed code for each line_location. */
	  l_closed_code := get_closed_code(
            l_lltab(i), l_lltab(i).quantity_billed);

	  /* Update the table for the quantity billed */
	  ITG_Debug.msg('PI', 'Update po_line_locations_all ...');
	  ITG_Debug.msg('PI', 'quantity_billed',  l_lltab(i).quantity_billed);
	  ITG_Debug.msg('PI', 'line_location_id', l_lltab(i).line_location_id);
	  UPDATE po_line_locations_all
	  SET    quantity_billed  = l_lltab(i).quantity_billed,
		 last_update_date = SYSDATE,
		 last_updated_by  = FND_GLOBAL.user_id
	  WHERE line_location_id  = l_lltab(i).line_location_id;

	  IF l_release_id IS NULL THEN
	    l_doc_type    := 'PO';
	    l_doc_subtype := 'STANDARD';
	  ELSE
	    l_doc_type    := 'RELEASE';
	    l_doc_subtype := 'BLANKET';
	  END IF;
	  IF l_closed_code IS NOT NULL THEN
	    ITG_Debug.msg('PI', 'Close po called ...');
	    ITG_Debug.msg('PI', 'po_id',            g_po_id);
	    ITG_Debug.msg('PI', 'doc_type',         l_doc_type);
	    ITG_Debug.msg('PI', 'po_line_id',       l_rec.po_line_id);
	    ITG_Debug.msg('PI', 'line_location_id',
				l_lltab(i).line_location_id);
	    ITG_Debug.msg('PI', 'closed_code',      l_closed_code);

          /*Added following if <cond> and else part to fix bug :5258514 */
          IF p_release_id IS  NULL or p_release_id =0 THEN

            IF NOT PO_ACTIONS.close_po(
	      p_docID        => g_po_id,
	      p_doctyp       => l_doc_type,
	      p_docsubtyp    => l_doc_subtype,
	      p_lineid       => l_rec.po_line_id,
	      p_shipid       => l_lltab(i).line_location_id,
	      p_action       => l_closed_code,
	      p_calling_mode => 'AP',
	      p_return_code  => l_return_code,
	      p_auto_close   => 'Y'
            ) THEN
	      ITG_Debug.msg('PI', 'Close PO failed ...');
	      ITG_Debug.msg('PI', 'return_code', l_return_code);
	      ITG_MSG.invoice_closepo_fail(l_return_code);
	      RAISE FND_API.G_EXC_ERROR;
	    ELSE
	      ITG_Debug.msg('PI', 'Close PO succeded');
	      ITG_Debug.msg('PI', 'return_code', l_return_code);
	    END IF;
         ELSE
          IF NOT PO_ACTIONS.close_po(
	      p_docID        => l_release_id,
	      p_doctyp       => l_doc_type,
	      p_docsubtyp    => l_doc_subtype,
	      p_lineid       => l_rec.po_line_id,
	      p_shipid       => l_lltab(i).line_location_id,
	      p_action       => l_closed_code,
	      p_calling_mode => 'AP',
	      p_return_code  => l_return_code,
	      p_auto_close   => 'Y'
            ) THEN
	      ITG_Debug.msg('PI', 'Close Release failed ...');
	      ITG_Debug.msg('PI', 'return_code', l_return_code);
	      ITG_MSG.invoice_closerelease_fail(l_return_code);
	      RAISE FND_API.G_EXC_ERROR;
	    ELSE
	      ITG_Debug.msg('PI', 'Close Release succeded');
	      ITG_Debug.msg('PI', 'return_code', l_return_code);
	    END IF;

          END IF; --end p_release_id block

        END IF ;--end l_closed_code block
	END LOOP;
      END IF;
    END process_invoice_doc;

  BEGIN
    /* Initialize return status */
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_action :='updating PO line';

    BEGIN
      SAVEPOINT Update_PoLine_PVT;

      BEGIN
  	    FND_Client_Info.set_org_context(p_org_id); /*bug 4073707*/
          MO_GLOBAL.set_policy_context('S', p_org_id); -- MOAC
      EXCEPTION
	  WHEN OTHERS THEN
		itg_msg.invalid_org(p_org_id);
		RAISE FND_API.G_EXC_ERROR;
      END;

      ITG_Debug.setup(
        p_reset     => TRUE,
	p_pkg_name  => G_PKG_NAME,
	p_proc_name => l_api_name);

	--now in wrapper, FND_MSG_PUB.Initialize;

      ITG_Debug.msg('UPL', 'Top of procedure.');

      /* Setup header id: g_po_id */
      lookup_po_header(p_po_code, p_org_id,p_release_id,l_doc_typ);

      IF p_release_id = 0 THEN
		l_release_id := NULL;
		IF l_doc_typ = 'BLANKET' THEN
			-- Release no is a must for blanket PO
			itg_debug.msg('UPL','No po line found.');
			itg_msg.no_po_line(p_org_id,p_po_code || ':' ||p_release_id,p_line_num);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
      ELSE
		OPEN po_relid_csr(g_po_id,p_org_id,p_release_id);
		FETCH po_relid_csr INTO l_release_id;
		l_notfound := po_relid_csr%NOTFOUND;
		IF l_notfound THEN
			itg_debug.msg('UPL','No po line found.');
			itg_msg.no_po_line(p_org_id,p_po_code || ':' ||p_release_id,p_line_num);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
      END IF;

      OPEN  po_line_csr;
      FETCH po_line_csr INTO l_rec;
      l_notfound := po_line_csr%NOTFOUND;
      CLOSE po_line_csr;
      IF l_notfound THEN
	  ITG_Debug.msg('UPL', 'No po line found.');
	  itg_msg.no_po_line(p_org_id,p_po_code || ':' ||p_release_id,p_line_num);
	  RAISE FND_API.G_EXC_ERROR;
      END IF;

      ITG_Debug.msg('UPL', 'PO Code',          p_po_code);
      ITG_Debug.msg('UPL', 'Org ID',           p_org_id);
      ITG_Debug.msg('UPL', 'PO ID',            g_po_id);
      ITG_Debug.msg('UPL', 'Release ID',       l_release_id);
      ITG_Debug.msg('UPL', 'PO Line Num',      p_line_num);
      ITG_Debug.msg('UPL', 'PO Line ID',       l_rec.po_line_id);
      ITG_Debug.msg('UPL', 'Closed Code',      l_rec.closed_code);
      ITG_Debug.msg('UPL', 'PO Line Doctype',  p_doc_type);
      ITG_Debug.msg('UPL', 'PO Line Quantity', p_quantity);
      ITG_Debug.msg('UPL', 'PO Line Amount',   p_amount);

      IF l_rec.closed_code = 'FINALLY CLOSED' THEN
        ITG_MSG.poline_closed_final;
    	  RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF    upper(p_doc_type) = 'RECEIPT'    THEN
	process_receipt_doc;
      ELSIF upper(p_doc_type) = 'INSPECTION' THEN
	process_inspection_doc;
      ELSIF upper(p_doc_type) = 'INVOICE'    THEN
	process_invoice_doc;
      ELSE
        ITG_MSG.poline_invalid_doctype;
	  RAISE FND_API.G_EXC_ERROR;
      END IF;

	COMMIT WORK;
      ITG_Debug.msg('UPL', 'Done.');

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_PoLine_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		ITG_msg.checked_error(g_action);


      WHEN OTHERS THEN
		ROLLBACK TO Update_PoLine_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		itg_debug.msg('Unexpected error (PO sync) - ' || substr(SQLERRM,1,255),true);
	      ITG_msg.unexpected_error(g_action);
    END;

    -- Removed FND_MSG_PUB.Count_And_Get
  END Update_PoLine;

END ITG_SyncPoInbound_PVT;

/
