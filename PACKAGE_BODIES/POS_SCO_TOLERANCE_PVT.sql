--------------------------------------------------------
--  DDL for Package Body POS_SCO_TOLERANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SCO_TOLERANCE_PVT" AS
/* $Header: POSPTOLB.pls 120.51.12010000.13 2013/11/18 10:22:10 pneralla ship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_SCO_TOLERANCE_PVT';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSPTOLB.pls';
  g_module_prefix CONSTANT VARCHAR2(100) := 'pos.plsql.' || 'POS_SCO_TOLERANCE_PVT'  || '.';
   -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1)   := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE LOG_MESSAGE( p_proc_name IN VARCHAR2,
                       p_text      IN VARCHAR2,
                       p_log_data  IN VARCHAR2)

IS
BEGIN

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'POS_SCO_TOLERANCE_PVT',
                    p_proc_name || ': '
                    || p_text || ': '
                    || p_log_data);
  END IF;
END LOG_MESSAGE;

/* This procedure call the ip API PO_CO_TOLERANCES_GRP.GET_TOLERANCES and sets the Tolerance
   Attributes and Routing Attributes.
*/
PROCEDURE INITIALIZE_TOL_VALUES(      itemtype        IN  VARCHAR2,
  	                              itemkey         IN  VARCHAR2,
  	                              actid           IN  NUMBER,
  	                              funcmode        IN  VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2)
IS

CURSOR getDocType(p_change_request_grp_id_csr IN NUMBER) IS
SELECT DISTINCT document_type
FROM   po_change_requests
WHERE  change_request_group_id = p_change_request_grp_id_csr;

CURSOR getDocSubType(p_po_header_id_csr IN NUMBER) IS
SELECT type_lookup_code
FROM   po_headers_all poha
WHERE  poha.po_header_id = p_po_header_id_csr;

CURSOR getDocSubTypeRel(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER) IS
SELECT distinct(release_type)
FROM   po_releases_all pora
WHERE  pora.po_header_id = p_po_header_id_csr
       AND pora.po_release_id = p_po_release_id_csr;

CURSOR getOrgId(p_po_header_id_csr IN NUMBER) IS
SELECT org_id
FROM po_headers_all
WHERE po_header_id = p_po_header_id_csr;

l_chg_req_grp_id po_change_requests.change_request_group_id%TYPE;
l_po_header_id   po_headers_all.po_header_id%TYPE;
l_po_release_id  po_releases_all.po_release_id%TYPE;
l_doc_type       po_change_requests.document_type%TYPE;
l_po_style       varchar2(10);
l_doc_subtype    varchar2(10);
l_promise_date_incr           NUMBER;
l_promise_date_decr           NUMBER;
l_unit_price_incr             NUMBER;
l_unit_price_decr             NUMBER;
l_shipment_qty_incr           NUMBER;
l_shipment_qty_decr           NUMBER;
l_pay_item_qty_incr           NUMBER;
l_pay_item_qty_decr           NUMBER;
l_doc_amount_incr_val         NUMBER;
l_doc_amount_decr_val         NUMBER;
l_doc_amount_incr_per         NUMBER;
l_doc_amount_decr_per         NUMBER;
l_line_amount_incr_per        NUMBER;
l_line_amount_decr_per        NUMBER;
l_line_amount_incr_val        NUMBER;
l_line_amount_decr_val        NUMBER;
l_ship_amount_incr_val        NUMBER;
l_ship_amount_decr_val        NUMBER;
l_ship_amount_incr_per        NUMBER;
l_ship_amount_decr_per        NUMBER;
l_pay_item_amount_incr_per    NUMBER;
l_pay_item_amount_decr_per    NUMBER;
l_pay_item_amount_incr_val    NUMBER;
l_pay_item_amount_decr_val    NUMBER;
l_prm_date_approval_flag      VARCHAR2(10);
l_ship_qty_approval_flag      VARCHAR2(10);
l_price_approval_flag         VARCHAR2(10);
l_complex_po_style            VARCHAR2(10);
l_org_id                      NUMBER;
x_tol_tab PO_CO_TOLERANCES_GRP.tolerances_tbl_type;
x_return_status varchar2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_progress VARCHAR2(1000);
BEGIN

  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_module_prefix,
                     'Enter Initialize Tol Proc'
                     );
  END IF;

    x_progress := 'INIT_TOL_VALUES:000';

    l_chg_req_grp_id :=   wf_engine.GetItemAttrNumber (  itemtype => itemtype,
            			                         itemkey  => itemkey,
         		                                 aname    => 'CHANGE_REQUEST_GROUP_ID');

    l_po_header_id   :=   wf_engine.GetItemAttrNumber (  itemtype => itemtype,
      						         itemkey  => itemkey,
      		                                         aname    => 'PO_HEADER_ID');

    l_po_release_id  :=   wf_engine.GetItemAttrNumber (  itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'PO_RELEASE_ID');

    x_progress := 'INIT_TOL_VALUES:001';

    -- Getting the Doc types and subtypes coz the flow is valid for Standard PO's and Blanket Releases

    OPEN  getDocType(l_chg_req_grp_id);
    LOOP
    FETCH getDocType
    INTO  l_doc_type;
    EXIT WHEN getDocType%NOTFOUND;
    END LOOP;

    IF getDocType%ISOPEN THEN
       CLOSE getDocType;
    END IF;

   IF(l_doc_type = 'PO') THEN
    OPEN getDocSubType(l_po_header_id);
    LOOP
    FETCH getDocSubType
    INTO l_doc_subtype;
    EXIT WHEN getDocSubType%NOTFOUND;
    END LOOP;

    IF getDocSubType%ISOPEN THEN
       CLOSE getDocSubType;
    END IF;

   ELSIF(l_doc_type = 'RELEASE') THEN
    OPEN getDocSubTypeRel(l_po_header_id,l_po_release_id);
    LOOP
    FETCH getDocSubTypeRel
    INTO l_doc_subtype;
    EXIT WHEN getDocSubTypeRel%NOTFOUND;
    END LOOP;

    IF getDocSubTypeRel%ISOPEN THEN
       CLOSE getDocSubTypeRel;
    END IF;
   END IF;



    -- get the org id and set the item attribute value
    OPEN getOrgId(l_po_header_id);
    LOOP
    FETCH getOrgId
    INTO l_org_id;
    EXIT WHEN getOrgId%NOTFOUND;
    END LOOP;

    IF getOrgId%ISOPEN THEN
       CLOSE getOrgId;
    END IF;


    x_progress := 'INIT_TOL_VALUES:002';



    wf_engine.SetItemAttrText (itemtype => itemtype,
             		       itemkey  => itemkey,
          		       aname    => 'DOCUMENT_TYPE',
      		               avalue   =>  l_doc_type);

    wf_engine.SetItemAttrText (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'DOC_SUB_TYPE',
                               avalue   =>  l_doc_subtype);

   log_message('INITIALIZE_TOL_VALUES','Operating Unit',l_org_id);

   x_progress := 'INIT_TOL_VALUES:003: Call get_tolerances';


   PO_CO_TOLERANCES_GRP.GET_TOLERANCES (1.0,
			                FND_API.G_TRUE,
			                l_org_id,
			                PO_CO_TOLERANCES_GRP.G_SUPP_CHG_APP,
			                x_tol_tab,
			                x_return_status,
			                x_msg_count,
                                        x_msg_data);

   IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_module_prefix,
                       x_progress
                       || 'x_return_status=' || x_return_status);
     END IF;

   ELSE
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_module_prefix,
                       x_progress
                       ||'x_return_status = ' || x_return_status
                       ||'x_msg_count = ' || x_msg_count
                       ||'x_msg_data = ' || x_msg_data);
     END IF;
   END IF;


  x_progress := 'INIT_TOL_VALUES:004';

   -- loop through all the tolerances retrieved
  FOR i in 1..x_tol_tab.count
  LOOP
   IF (x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PROMISED_DATE) THEN
       l_promise_date_incr := x_tol_tab(i).max_increment;
       l_promise_date_decr := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_UNIT_PRICE) THEN
       l_unit_price_incr := x_tol_tab(i).max_increment;
       l_unit_price_decr := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_SHIPMENT_QTY) THEN
       l_shipment_qty_incr := x_tol_tab(i).max_increment;
       l_shipment_qty_decr := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PAY_ITEM_QTY) THEN
       l_pay_item_qty_incr := x_tol_tab(i).max_increment;
       l_pay_item_qty_decr := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_DOCUMENT_AMOUNT_VALUE) THEN
       l_doc_amount_incr_val := x_tol_tab(i).max_increment;
       l_doc_amount_decr_val := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_DOCUMENT_AMOUNT_PERCENT) THEN
       l_doc_amount_incr_per := x_tol_tab(i).max_increment;
       l_doc_amount_decr_per := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_LINE_AMOUNT_PERCENT) THEN
       l_line_amount_incr_per := x_tol_tab(i).max_increment;
       l_line_amount_decr_per := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_LINE_AMOUNT_VALUE) THEN
       l_line_amount_incr_val := x_tol_tab(i).max_increment;
       l_line_amount_decr_val := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_SHIPMENT_AMOUNT_VALUE) THEN
       l_ship_amount_incr_val := x_tol_tab(i).max_increment;
       l_ship_amount_decr_val := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PAY_ITEM_AMOUNT_VALUE) THEN
       l_pay_item_amount_incr_val := x_tol_tab(i).max_increment;
       l_pay_item_amount_decr_val := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_SHIPMENT_AMOUNT_PERCENT) THEN
       l_ship_amount_incr_per := x_tol_tab(i).max_increment;
       l_ship_amount_decr_per := x_tol_tab(i).max_decrement;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PAY_ITEM_AMOUNT_PERCENT) THEN
       l_pay_item_amount_incr_per := x_tol_tab(i).max_increment;
       l_pay_item_amount_decr_per := x_tol_tab(i).max_decrement;


   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PROMISED_DATE_APPROVAL_FLAG) THEN
       l_prm_date_approval_flag := x_tol_tab(i).enabled_flag;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_SHIPMENT_QTY_APPROVAL_FLAG) THEN
       l_ship_qty_approval_flag := x_tol_tab(i).enabled_flag;

   ELSIF(x_tol_tab(i).tolerance_name = PO_CO_TOLERANCES_GRP.G_PRICE_APPROVAL_FLAG) THEN
       l_price_approval_flag := x_tol_tab(i).enabled_flag;

  END IF;
  END LOOP;


  x_progress := 'INIT_TOL_VALUES:005';


    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'PROMISE_DATE_INCR',
      		                     avalue   => l_promise_date_incr);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
          			     itemkey  => itemkey,
      		                     aname    => 'PROMISE_DATE_DEC',
      		                     avalue   => l_promise_date_decr);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'UNIT_PRICE_INCR',
      		                     avalue   => l_unit_price_incr);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'UNIT_PRICE_DEC',
      		                     avalue   => l_unit_price_decr);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'DOC_AMOUNT_INCR_PER',
      		                     avalue   => l_doc_amount_incr_per);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'DOC_AMOUNT_DEC_PER',
      		                     avalue   => l_doc_amount_decr_per);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'DOC_AMOUNT_INCR_VAL',
      		                     avalue   => l_doc_amount_incr_val);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'DOC_AMOUNT_DEC_VAL',
      		                     avalue   => l_doc_amount_decr_val);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'LINE_AMOUNT_INCR_PER',
      		                     avalue   => l_line_amount_incr_per);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'LINE_AMOUNT_DEC_PER',
      		                     avalue   => l_line_amount_decr_per);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'LINE_AMOUNT_INCR_VAL',
      		                     avalue   => l_line_amount_incr_val);

    wf_engine.SetItemAttrNumber (    itemtype => itemtype,
         			     itemkey  => itemkey,
      		                     aname    => 'LINE_AMOUNT_DEC_VAL',
      		                     avalue   => l_line_amount_decr_val);

    wf_engine.SetItemAttrText  (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PROMISE_DATE_APP_FLAG',
                                avalue   => l_prm_date_approval_flag);

    wf_engine.SetItemAttrText  (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'SHIP_QTY_APPROVAL_FLAG',
                                avalue   => l_ship_qty_approval_flag);

    wf_engine.SetItemAttrText  (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PRICE_APPROVAL_FLAG',
                                avalue   => l_price_approval_flag);


    -- Get the PO Style ( COMPLEX or NORMAL and accordingly populating the Tolerance Attributes
    l_po_style :=   wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'PO_STYLE_TYPE');

    log_message('INITIALIZE_TOL_VALUES','PO Style Type',l_po_style);


    IF (l_po_style ='COMPLEX') THEN

       wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			            itemkey  => itemkey,
          		                    aname    => 'PAY_QUANTITY_INCR',
          		                    avalue   => l_pay_item_qty_incr);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'PAY_QUANTITY_DEC',
          		                     avalue   => l_pay_item_qty_decr);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'PAY_AMOUNT_INCR_PER',
          		                     avalue   => l_pay_item_amount_incr_per);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'PAY_AMOUNT_DEC_PER',
          		                     avalue   => l_pay_item_amount_decr_per);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'PAY_AMOUNT_INCR_VAL',
          		                     avalue   => l_pay_item_amount_incr_val);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'PAY_AMOUNT_DEC_VAL',
          		                     avalue   => l_pay_item_amount_decr_val);

       IF (PO_COMPLEX_WORK_PVT.is_financing_po(l_po_header_id)) THEN
          l_complex_po_style := 'FINANCING';

          wf_engine.SetItemAttrText  (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'COMPLEX_PO_STYLE',
                                      avalue   => l_complex_po_style);
       ELSE
          l_complex_po_style := 'ACTUALS';

	  wf_engine.SetItemAttrText  (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'COMPLEX_PO_STYLE',
                                      avalue   => l_complex_po_style);
       END IF;



    ELSIF (l_po_style ='NORMAL') THEN

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_QUANTITY_INCR',
          		                     avalue   => l_shipment_qty_incr);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_QUANTITY_DEC',
          		                     avalue   => l_shipment_qty_decr);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_AMOUNT_INCR_PER',
          		                     avalue   => l_ship_amount_incr_per);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_AMOUNT_DEC_PER',
          		                     avalue   => l_ship_amount_decr_per);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_AMOUNT_INCR_VAL',
          		                     avalue   => l_ship_amount_incr_val);

        wf_engine.SetItemAttrNumber (        itemtype => itemtype,
             			             itemkey  => itemkey,
          		                     aname    => 'SHIP_AMOUNT_DEC_VAL',
          		                     avalue   => l_ship_amount_decr_val);




    END IF;

EXCEPTION
  WHEN OTHERS THEN
       IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         x_progress || ':unexpected error' || Sqlerrm);
        END IF;
 wf_core.context('POSCHORD', 'INITIALIZE_TOL_VALUES', itemtype, itemkey, to_char(actid),funcmode);
 raise;

END INITIALIZE_TOL_VALUES;


/* This procedure checks whether Promise_Date_Change is within the tolerance or not
   Returns 'Y' if within the tolerance
   Returns 'N' if out of tolerance
*/

PROCEDURE PROMISE_DATE_WITHIN_TOL(       itemtype        IN VARCHAR2,
 	                                 itemkey         IN VARCHAR2,
 	                                 actid           IN NUMBER,
 	                                 funcmode        IN VARCHAR2,
                                         resultout       OUT NOCOPY VARCHAR2)

IS

 -- Cursor to pick up old_promised_date and new_promised_date, handles the case when either of them is null
  CURSOR c_promise_date_changes(p_po_header_id_csr IN NUMBER,p_change_group_id_csr IN NUMBER) IS
         SELECT nvl(pcr.old_promised_date,pcr.old_need_by_date) old_promise_date,
                pcr.new_promised_date, pll.promised_date,pll.need_by_date
         FROM   po_change_requests pcr,
	        po_line_locations_all pll
         WHERE  pcr.document_header_id=p_po_header_id_csr
	        AND pcr.document_line_location_id = pll.line_location_id
                AND pcr.CHANGE_REQUEST_GROUP_ID=p_change_group_id_csr
                AND pcr.request_level = 'SHIPMENT'
                AND pcr.action_type = 'MODIFICATION'
                AND pcr.request_status = 'PENDING'
                AND pcr.initiator='SUPPLIER'
                AND ( (pcr.new_promised_date <> old_promised_date)  OR
	              (nvl(pcr.old_promised_date,nvl(pcr.old_need_by_date,pcr.new_promised_date - 1))<>pcr.new_promised_date)
                    );

  l_po_header_id     po_headers_all.po_header_id%type;
  l_change_group_id  po_change_requests.change_request_group_id%type;
  l_prom_date_dec    NUMBER;
  l_prom_date_incr   NUMBER;
  l_old_promise_date po_change_requests.old_promised_date%type;
  l_new_promise_date po_change_requests.new_promised_date%type;
  l_promised_date    po_line_locations_all.promised_date%type;
  l_need_by_date     po_line_locations_all.need_by_date%type;
  x_progress         VARCHAR2(1000);
  l_return_val       VARCHAR2(1):='Y';
  l_po_style_type    VARCHAR2(10);
  l_doc_type         VARCHAR2(10);

BEGIN

  IF ( funcmode = 'RUN' ) THEN

            x_progress := 'PROMISE_DATE_WITHIN_TOL:000';

      	    l_change_group_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						              itemkey  => itemkey,
      		                                              aname    => 'CHANGE_REQUEST_GROUP_ID');

            l_po_header_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						              itemkey  => itemkey,
      		                                              aname    => 'PO_HEADER_ID');

            l_po_style_type   := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						              itemkey  => itemkey,
      		                                              aname    => 'PO_STYLE_TYPE');

      	    l_doc_type        := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						              itemkey  => itemkey,
      		                                              aname    => 'DOCUMENT_TYPE');

      	    x_progress := 'PROMISE_DATE_WITHIN_TOL:001';

        IF (l_change_group_id IS NOT NULL) THEN

      	    -- check only for doc type SPO AND BPA Release (get the value from item attribute DOCUMENT_TYPE)
      		-- DOC_SUB_TYPE is already checked in business rules check

          IF( (l_doc_type = 'PO') OR  (l_doc_type = 'RELEASE')) THEN
      		  -- get the promise date tolerances in days
      		      l_prom_date_dec   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
         			                                        itemkey  => itemkey,
      		                                                        aname    => 'PROMISE_DATE_DEC');
      	              l_prom_date_incr  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
         			                                        itemkey  => itemkey,
      		                                                        aname    => 'PROMISE_DATE_INCR');

      		  log_message('PROMISE_DATE_WITHIN_TOL','Promise Date Incr and decr Values',l_prom_date_incr || ', '|| l_prom_date_dec);

      	      x_progress := 'PROMISE_DATE_WITHIN_TOL:002';

              OPEN c_promise_date_changes(l_po_header_id,l_change_group_id) ;
      		     LOOP
      		     FETCH     c_promise_date_changes
      		     INTO      l_old_promise_date,
      		               l_new_promise_date,
			       l_promised_date,
			       l_need_by_date;
      		     EXIT WHEN c_promise_date_changes%NOTFOUND;

      		     x_progress := 'PROMISE_DATE_WITHIN_TOL:003';
      		      log_message('PROMISE_DATE_WITHIN_TOL','Old & New Promise Date',l_old_promise_date || ', '|| l_new_promise_date);

                        IF (l_promised_date is null AND l_need_by_date is null) THEN
                           CLOSE c_promise_date_changes;
                           l_return_val :='N' ;
                        END IF;


      		         EXIT WHEN (l_return_val = 'N');

      		         IF (NOT change_within_tol_date(l_old_promise_date, l_new_promise_date, l_prom_date_incr, l_prom_date_dec)) THEN
      		         l_return_val := 'N';
      		         END IF;

      		      x_progress := 'PROMISE_DATE_WITHIN_TOL:004';
      		      END LOOP;

      		    IF c_promise_date_changes%ISOPEN THEN
	       CLOSE c_promise_date_changes;
                    END IF;

      	    END IF;  -- DOC_TYPE check
        END IF;  --l_change_group_id IS NOT NULL

      	-- set result value
        resultout :=  wf_engine.eng_completed || ':' || l_return_val ;

        x_progress := 'PROMISE_DATE_WITHIN_TOL:005';

        log_message('PROMISE_DATE_WITHIN_TOL','Result',resultout);

  END IF; -- IF ( funcmode = 'RUN' )


EXCEPTION
   WHEN OTHERS THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                              g_module_prefix,
                              x_progress || ':unexpected error' || Sqlerrm);
     END IF;
     wf_core.context('POSCHORD', 'PROMISE_DATE_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);
     raise;
END PROMISE_DATE_WITHIN_TOL;


/* This procedure checks whether Unit_Price_Change is within the tolerance or not
   Returns 'Y' if within the tolerance
   Returns 'N' if out of tolerance
*/
PROCEDURE UNIT_PRICE_WITHIN_TOL(   itemtype        IN VARCHAR2,
 	                           itemkey         IN VARCHAR2,
 	                           actid           IN NUMBER,
 	                           funcmode        IN VARCHAR2,
                                   resultout       OUT NOCOPY VARCHAR2)

IS
-- This cursor picks up Unit Price chnages for SPO at Line Level
  CURSOR c_unit_price_changes ( p_po_header_id_csr IN NUMBER,p_change_group_id_csr IN NUMBER) IS
	   SELECT old_price,new_price
	   FROM   po_change_requests
	   WHERE  document_header_id=p_po_header_id_csr
	          AND CHANGE_REQUEST_GROUP_ID=p_change_group_id_csr
	          AND request_level = 'LINE'
	          AND new_price IS NOT NULL
	          AND action_type = 'MODIFICATION'
	          AND request_status = 'PENDING'
	          AND initiator='SUPPLIER';

-- This  cursor picks up unit price changes for  BPA release at the shipment level
-- pcr.old_price is added to consider price breaks for release
  CURSOR c_ship_unit_price_rel (p_po_release_id_csr IN NUMBER,p_po_header_id IN NUMBER,p_change_group_id_csr IN NUMBER) IS
          SELECT  plla.price_override,nvl(pcr.new_price,pcr.old_price)
	  	   FROM   po_change_requests  pcr,
	  	          po_line_locations_all plla
	  	   WHERE  pcr.po_release_id= p_po_release_id_csr
	  	          AND pcr.CHANGE_REQUEST_GROUP_ID=p_change_group_id_csr
	  	          AND pcr.request_level = 'SHIPMENT'
	  	          AND pcr.new_price IS NOT NULL
	  	          AND pcr.action_type = 'MODIFICATION'
	  	          AND pcr.request_status = 'PENDING'
	  	          AND pcr.initiator='SUPPLIER'
			      AND pcr.document_line_location_id = plla.line_location_id;

-- cursor to check for the COMPLEX WORK (Financing Case)
CURSOR c_line_unit_price_cw (p_po_release_id_csr IN NUMBER,p_po_header_id IN NUMBER,p_change_group_id_csr IN NUMBER) IS
	           SELECT pl.unit_price,pcr.new_price
	  	  	   FROM   po_change_requests  pcr,
	  	  	          po_lines_all pl
	  	  	   WHERE  pcr.document_header_id= p_po_header_id
	  	  	          AND pcr.CHANGE_REQUEST_GROUP_ID=p_change_group_id_csr
	  	  	          AND pcr.request_level = 'LINE'
	  	  	          AND pcr.new_price IS NOT NULL
	  	  	          AND pcr.action_type = 'MODIFICATION'
	  	  	          AND pcr.request_status = 'PENDING'
	  	  	          AND pcr.initiator='SUPPLIER'
			          AND pcr.document_line_id = pl.po_line_id;


  -- cursor to check for the Complex Work( Actuals Case)


  l_po_header_id            po_headers_all.po_header_id%TYPE;
  l_po_release_id           po_releases_all.po_release_id%TYPE;
  l_change_group_id         po_change_requests.change_request_group_id%type;
  l_unitprice_lower_tol     number;
  l_unitprice_upper_tol     number;
  l_old_price               po_change_requests.old_price%type;
  l_new_price		    po_change_requests.new_price%type;
  x_progress                VARCHAR2(1000);
  l_return_val              VARCHAR2(1):='Y';
  l_po_style_type           VARCHAR2(10);
  l_doc_type                VARCHAR2(10);
  l_complex_po_style        VARCHAR2(10);

BEGIN

  IF ( funcmode = 'RUN' ) THEN

     x_progress := 'UNIT_PRICE_WITHIN_TOL:000';

     l_change_group_id    :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
						           itemkey  => itemkey,
		                                           aname    => 'CHANGE_REQUEST_GROUP_ID');

     l_po_header_id       :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'PO_HEADER_ID');

     l_po_release_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'PO_RELEASE_ID');

     l_po_style_type      :=  wf_engine.GetItemAttrText   (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'PO_STYLE_TYPE');

     l_doc_type           :=  wf_engine.GetItemAttrText   (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'DOCUMENT_TYPE');

     l_complex_po_style   :=   wf_engine.GetItemAttrText   (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'COMPLEX_PO_STYLE');

     x_progress := 'UNIT_PRICE_WITHIN_TOL:001';
 IF (l_change_group_id IS NOT NULL) THEN
     -- check for the DOC types (applicable for  PO unit price( Line level)  and BPA release unit price(Shipment Level)
	 -- if other doc types return true and exit
   IF(l_doc_type = 'PO' OR l_doc_type = 'RELEASE') THEN
	  -- get the unit price percentage tolerances
	  l_unitprice_lower_tol     :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                     itemkey  => itemkey,
      		                                                     aname    => 'UNIT_PRICE_DEC');

	  l_unitprice_upper_tol     :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                     itemkey  => itemkey,
      		                                                     aname    => 'UNIT_PRICE_INCR');
	  x_progress := 'UNIT_PRICE_WITHIN_TOL:002';
      log_message('UNIT_PRICE_WITHIN_TOL','Unit Price Incr & Decr Values',l_unitprice_upper_tol || ', '|| l_unitprice_lower_tol);
    IF(l_doc_type = 'PO' and l_po_style_type='NORMAL' ) THEN
	OPEN c_unit_price_changes(l_po_header_id,l_change_group_id);
	  LOOP
	  FETCH c_unit_price_changes
          INTO  l_old_price,
	        l_new_price;
	  x_progress := 'UNIT_PRICE_WITHIN_TOL:003';
	  log_message('UNIT_PRICE_WITHIN_TOL','Old & New Price Values',l_old_price || ', '|| l_new_price);
	  EXIT WHEN c_unit_price_changes%NOTFOUND;
          EXIT WHEN (l_return_val = 'N');

	    IF (NOT change_within_tol(l_old_price, l_new_price, l_unitprice_upper_tol, l_unitprice_lower_tol,0,0)) THEN
	        l_return_val := 'N';
	    END IF;
	  x_progress := 'UNIT_PRICE_WITHIN_TOL:004';
	  END LOOP;
	CLOSE  c_unit_price_changes;
    ELSIF(l_doc_type = 'RELEASE' and l_po_style_type='NORMAL') THEN
	OPEN c_ship_unit_price_rel(l_po_release_id,l_po_header_id,l_change_group_id);
	   LOOP
	   FETCH c_ship_unit_price_rel
	   INTO  l_old_price,
	   	 l_new_price;
	   x_progress := 'UNIT_PRICE_WITHIN_TOL:005';
	   log_message('UNIT_PRICE_WITHIN_TOL','Old & New Price Values',l_old_price || ', '|| l_new_price);
	   EXIT WHEN c_ship_unit_price_rel%NOTFOUND;
	   EXIT WHEN (l_return_val = 'N');

	     IF (NOT change_within_tol(l_old_price, l_new_price, l_unitprice_upper_tol, l_unitprice_lower_tol,0,0)) THEN
	   	        l_return_val := 'N';
	     END IF;
	   x_progress := 'UNIT_PRICE_WITHIN_TOL:006';
	   END LOOP;
	 CLOSE  c_ship_unit_price_rel;
     END IF;  -- PO Or RELEASE


     IF(l_po_style_type='COMPLEX') THEN
     	    IF(l_complex_po_style = 'FINANCING') THEN
               OPEN c_line_unit_price_cw(l_po_release_id,l_po_header_id,l_change_group_id);
     	   	  LOOP
     	   	  FETCH c_line_unit_price_cw
     	          INTO  l_old_price,
     	   	        l_new_price;
     	   	  x_progress := 'UNIT_PRICE_WITHIN_TOL:007';
     	   	  log_message('UNIT_PRICE_WITHIN_TOL','Old & New Price Values',l_old_price || ', '|| l_new_price);
     	   	  EXIT WHEN c_line_unit_price_cw%NOTFOUND;
     	   	  EXIT WHEN (l_return_val = 'N');
     	   	    IF (NOT change_within_tol(l_old_price, l_new_price, l_unitprice_upper_tol, l_unitprice_lower_tol,0,0)) THEN
     	   	        l_return_val := 'N';
     	   	    END IF;
     	   	  x_progress := 'UNIT_PRICE_WITHIN_TOL:008';
     	   	  END LOOP;
     	   	CLOSE  c_line_unit_price_cw;
             END IF;  -- financing
      END IF; -- po_style_type='COMPLEX'

  END IF;  -- doc_type PO or RELEASE

 END IF;  -- change_group_id is not null

		-- set result value

	resultout := wf_engine.eng_completed|| ':' || l_return_val ;
	x_progress := 'UNIT_PRICE_WITHIN_TOL:009';
        log_message('UNIT_PRICE_WITHIN_TOL','Result',resultout);

 END IF; -- IF ( funcmode = 'RUN' )

EXCEPTION
  WHEN OTHERS THEN

    IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                             g_module_prefix,
                             x_progress || ':unexpected error' || Sqlerrm);
    END IF;


  wf_core.context('POSCHORD', 'UNIT_PRICE_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);

  raise;

END UNIT_PRICE_WITHIN_TOL;


/* This procedure checks whether Shipment_Quantity_Change is within the tolerance or not
   Returns 'Y' if within the tolerance
   Returns 'N' if out of tolerance
*/

PROCEDURE SHIP_QUANTITY_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                            itemkey         IN VARCHAR2,
 	                            actid           IN NUMBER,
 	                            funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2)
IS
-- This cursor picks up shipment quantity changes for SPO and BPA releases
  CURSOR c_ship_qty_changes (p_change_group_id_csr IN NUMBER) IS
	 SELECT pcr.old_quantity,
	        pcr.new_quantity
	 FROM   po_change_requests pcr
	 WHERE  pcr.change_request_group_id=p_change_group_id_csr
	       AND pcr.new_quantity IS NOT NULL
	       AND pcr.action_type='MODIFICATION'
	       AND pcr.request_status= 'PENDING'
	       AND pcr.request_level= 'SHIPMENT'
	       AND pcr.initiator= 'SUPPLIER';

  l_old_ship_qty           po_change_requests.old_quantity%TYPE;
  l_new_ship_qty           po_change_requests.new_quantity%TYPE;
  l_return_val             VARCHAR2(1) :='Y';
  l_ship_qty_max_incr_per  NUMBER;
  l_shipq_ty_max_dec_per   NUMBER;
  l_ship_qty_max_incr_val  NUMBER;
  l_ship_qty_max_dec_val   NUMBER;
  x_progress               VARCHAR2(1000);
  l_po_header_id           po_headers_all.po_header_id%TYPE;
  l_change_group_id        po_change_requests.change_request_group_id%type;
  l_po_style_type          VARCHAR2(10);
  l_doc_type               VARCHAR2(10);

BEGIN

  IF ( funcmode = 'RUN' ) THEN

        x_progress := 'SHIP_QUANTITY_WITHIN_TOL:000';
        l_po_header_id     := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                   itemkey  => itemkey,
	                                                   aname    => 'PO_HEADER_ID');

	l_change_group_id  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
	 					           itemkey  => itemkey,
	                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');

	l_po_style_type    := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'PO_STYLE_TYPE');

        l_doc_type         := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						           itemkey  => itemkey,
      		                                           aname    => 'DOCUMENT_TYPE');
	 x_progress := 'SHIP_QUANTITY_WITHIN_TOL:001';
      IF (l_change_group_id IS NOT NULL) THEN
	 -- get shipment quantity tolerances
	 -- check for the DOC types (applicable for  PO  and BPA release)
	  -- if other doc types return true and exit
        IF (l_po_style_type='NORMAL') THEN

          l_ship_qty_max_incr_per :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                 itemkey  => itemkey,
      		                                                 aname    => 'SHIP_QUANTITY_INCR');

          l_shipq_ty_max_dec_per  :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                 itemkey  => itemkey,
      		                                                 aname    => 'SHIP_QUANTITY_DEC');
        ELSIF (l_po_style_type='COMPLEX') THEN

          l_ship_qty_max_incr_per :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                 itemkey  => itemkey,
      		                                                 aname    => 'PAY_QUANTITY_INCR');

          l_shipq_ty_max_dec_per  :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                 itemkey  => itemkey,
      		                                                 aname    => 'PAY_QUANTITY_DEC');
        END IF;
          x_progress := 'SHIP_QUANTITY_WITHIN_TOL:002';
          log_message('SHIP_QUANTITY_WITHIN_TOL','Ship Quantity Max Incr & dec Values', l_ship_qty_max_incr_per || ', ' || l_shipq_ty_max_dec_per);
	  OPEN c_ship_qty_changes (l_change_group_id);

	    LOOP
	    FETCH c_ship_qty_changes
	    INTO  l_old_ship_qty,
	          l_new_ship_qty;
            EXIT WHEN c_ship_qty_changes%NOTFOUND;
            x_progress := 'SHIP_QUANTITY_WITHIN_TOL:003';
	    log_message('SHIP_QUANTITY_WITHIN_TOL','Old & New Ship Quantity values',l_old_ship_qty || ', ' ||l_new_ship_qty);
	    EXIT WHEN (l_return_val = 'N');

	    IF (NOT change_within_tol(l_old_ship_qty, l_new_ship_qty, l_ship_qty_max_incr_per, l_shipq_ty_max_dec_per,0,0)) THEN
	       l_return_val := 'N';
	    END IF;
	    x_progress:= 'SHIP_QUANTITY_WITHIN_TOL:004';
	    END LOOP;
	  CLOSE  c_ship_qty_changes;
      END IF;  -- change group Id is not null
	-- set result value
	resultout := wf_engine.eng_completed|| ':' || l_return_val ;
	x_progress := 'SHIP_QUANTITY_WITHIN_TOL:005';
	log_message('SHIP_QUANTITY_WITHIN_TOL','Result',resultout);

  END IF; -- IF ( funcmode = 'RUN' )

EXCEPTION
   WHEN OTHERS THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         x_progress || ':unexpected error' || Sqlerrm);
   END IF;
  wf_core.context('POSCHORD', 'SHIP_QUANTITY_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);
  raise;
END SHIP_QUANTITY_WITHIN_TOL;


/* This procedure checks whether Document Amount Change is within the tolerance or not
   Any Line Price change or shipment quantity chnage that affects the amount is also
   taken in to consideration
   Returns 'Y' if within the tolerance
   Returns 'N' if out of tolerance
*/


PROCEDURE DOC_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                         itemkey         IN VARCHAR2,
 	                         actid           IN NUMBER,
 	                         funcmode        IN VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2)
IS

--  Picks up Old Amount for SPO
CURSOR c_old_doc_amt_changes(p_po_header_id_csr IN NUMBER)  IS
	 SELECT  sum(decode(pl.matching_basis, 'AMOUNT', (pll.amount - nvl(pll.amount_cancelled,0)),(pl.unit_price * (pll.quantity - nvl(pll.quantity_cancelled,0)))))
         FROM 	 po_lines_all pl,
                 po_line_locations_all pll
         WHERE   pl.po_header_id = p_po_header_id_csr
	 	 AND pll.po_line_id = pl.po_line_id;
-- Picks up Old Amount For Releases
CURSOR c_old_doc_amt_changes_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER)  IS
	 SELECT  sum(decode(pl.matching_basis, 'AMOUNT', (pll.amount - nvl(pll.amount_cancelled,0)),(pll.price_override * (pll.quantity - nvl(pll.quantity_cancelled,0)))))
         FROM 	 po_lines_all pl,
                 po_line_locations_all pll
         WHERE   pll.po_release_id = p_po_release_id_csr
                 AND pll.po_header_id = p_po_header_id_csr
	 	 AND pll.po_line_id = pl.po_line_id;

 -- Picks up Old Amount for Complex POs ( Actuals case )
 CURSOR c_old_doc_amt_cw_actuals(p_po_header_id_csr IN NUMBER) IS
        SELECT SUM(DECODE(pl.matching_basis,'QUANTITY',
                                          (pll.quantity - NVL(pll.quantity_cancelled,0))* (pll.price_override),
                                             'AMOUNT',
                   DECODE(pll.payment_type,  'LUMPSUM',
                                              (pll.amount - NVL(pll.amount_cancelled,0)),
                                              'MILESTONE',
                                     	      (pll.amount - NVL(pll.amount_cancelled,0)),
                                              'RATE',
                                              (pll.quantity - NVL(pll.quantity_cancelled,0))*(pll.price_override))))
        FROM 	 po_lines_all pl,
                 po_line_locations_all pll
        WHERE    pl.po_header_id = p_po_header_id_csr
	         AND pll.po_line_id = pl.po_line_id;


 -- Picks up Old Doc Amount for Complex Pos( Financing case)
 CURSOR c_old_doc_amt_cw_financing(p_po_header_id_csr IN NUMBER) IS
        SELECT SUM(DECODE(pl.matching_basis,'QUANTITY',
	                                    (pl.quantity*pl.unit_price),
					    'AMOUNT',
					    (pl.amount)))
              FROM po_lines_all pl
	      WHERE pl.po_header_id = p_po_header_id_csr;

  l_po_header_id         po_change_requests.document_header_id%TYPE;
  l_po_release_id        po_change_requests.po_release_id%TYPE;
  l_change_group_id      po_change_requests.change_request_group_id%TYPE;
  l_old_doc_amt          NUMBER;
  l_total_new_doc_amt    NUMBER;
  l_new_doc_amt_rel      NUMBER;
  l_return_val           VARCHAR2(1) :='Y';
  l_doc_amt_max_incr_per NUMBER;
  l_doc_amt_max_dec_per  NUMBER;
  l_doc_amt_max_incr_val NUMBER;
  l_doc_amt_max_dec_val  NUMBER;
  x_progress             VARCHAR2(1000);
  l_po_style_type        VARCHAR2(10);
  l_doc_type             VARCHAR2(10);
  l_complex_po_style     VARCHAR2(10);

BEGIN

  IF ( funcmode = 'RUN' ) THEN

       x_progress := 'DOC_AMOUNT_WITHIN_TOL:000';
       l_po_header_id      := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                           itemkey  => itemkey,
	                                                   aname    => 'PO_HEADER_ID');

       l_change_group_id   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
	 					           itemkey  => itemkey,
	                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');

       l_po_release_id     := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                           itemkey  => itemkey,
	                                                   aname    => 'PO_RELEASE_ID');

       l_po_style_type     :=  wf_engine.GetItemAttrText (itemtype => itemtype,
      						          itemkey  => itemkey,
      		                                          aname    => 'PO_STYLE_TYPE');

       l_doc_type          := wf_engine.GetItemAttrText (itemtype => itemtype,
      						         itemkey  => itemkey,
      		                                         aname    => 'DOCUMENT_TYPE');

       l_complex_po_style  := wf_engine.GetItemAttrText (itemtype => itemtype,
      						         itemkey  => itemkey,
      		                                         aname    => 'COMPLEX_PO_STYLE');

       x_progress := 'DOC_AMOUNT_WITHIN_TOL:001';

  IF (l_change_group_id IS NOT NULL) THEN

	    -- get po document total tolerances
	    -- check for the DOC types (applicable for  PO Amount  and BPA  Release Amount)
	    -- if other doc types return true and exit
      IF(l_doc_type = 'PO' OR l_doc_type = 'RELEASE') THEN

	    l_doc_amt_max_incr_per  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                    itemkey  => itemkey,
      		                                                    aname    => 'DOC_AMOUNT_INCR_PER');
            l_doc_amt_max_dec_per   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                    itemkey  => itemkey,
      		                                                    aname    => 'DOC_AMOUNT_DEC_PER');

	    x_progress := 'DOC_AMOUNT_WITHIN_TOL:002';
	    log_message('DOC_AMOUNT_WITHIN_TOL','Doc Amount Inc & Dec percentage',l_doc_amt_max_incr_per || ', '|| l_doc_amt_max_dec_per);


            l_doc_amt_max_incr_val  :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                   itemkey  => itemkey,
      		                                                   aname    => 'DOC_AMOUNT_INCR_VAL');
            l_doc_amt_max_dec_val   :=wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                   itemkey  => itemkey,
      		                                                   aname    => 'DOC_AMOUNT_DEC_VAL');

	    x_progress := 'DOC_AMOUNT_WITHIN_TOL:003';
	    log_message('DOC_AMOUNT_WITHIN_TOL','Doc Amount Inc & Dec Values',l_doc_amt_max_incr_val|| ', '||l_doc_amt_max_dec_val);


         IF(l_doc_type = 'PO') THEN

           IF(l_po_style_type = 'NORMAL') THEN
	    OPEN c_old_doc_amt_changes(l_po_header_id);
	       FETCH c_old_doc_amt_changes INTO  l_old_doc_amt;
               x_progress:= 'DOC_AMOUNT_WITHIN_TOL:004';
               log_message('DOC_AMOUNT_WITHIN_TOL','Old AMount ',l_old_doc_amt);
	       l_total_new_doc_amt:= CALCULATE_NEW_DOC_AMOUNT(l_po_header_id,l_po_release_id,l_complex_po_style);
	       x_progress := 'DOC_AMOUNT_WITHIN_TOL:008';
	       log_message('DOC_AMOUNT_WITHIN_TOL','New Amount',l_total_new_doc_amt);
	    CLOSE c_old_doc_amt_changes;

	   ELSIF(l_po_style_type = 'COMPLEX') THEN

	     IF(l_complex_po_style = 'ACTUALS') THEN

	       OPEN c_old_doc_amt_cw_actuals(l_po_header_id);
               FETCH c_old_doc_amt_cw_actuals INTO  l_old_doc_amt;
               x_progress:= 'DOC_AMOUNT_WITHIN_TOL:004';
               log_message('DOC_AMOUNT_WITHIN_TOL','Old AMount ',l_old_doc_amt);
	       l_total_new_doc_amt:= CALCULATE_NEW_DOC_AMOUNT(l_po_header_id,l_po_release_id,l_complex_po_style);
	       x_progress := 'DOC_AMOUNT_WITHIN_TOL:008';
	       log_message('DOC_AMOUNT_WITHIN_TOL','New Amount',l_total_new_doc_amt);
	       CLOSE c_old_doc_amt_cw_actuals;

             ELSIF(l_complex_po_style = 'FINANCING') THEN

	       OPEN c_old_doc_amt_cw_financing(l_po_header_id);
               FETCH c_old_doc_amt_cw_financing INTO  l_old_doc_amt;
               x_progress:= 'DOC_AMOUNT_WITHIN_TOL:004';
               log_message('DOC_AMOUNT_WITHIN_TOL','Old AMount ',l_old_doc_amt);
	       l_total_new_doc_amt:= CALCULATE_NEW_DOC_AMOUNT(l_po_header_id,l_po_release_id,l_complex_po_style);
	       x_progress := 'DOC_AMOUNT_WITHIN_TOL:008';
	       log_message('DOC_AMOUNT_WITHIN_TOL','New Amount',l_total_new_doc_amt);
	       CLOSE c_old_doc_amt_cw_financing;

             END IF;

           END IF;
	    IF (NOT change_within_tol(l_old_doc_amt, l_total_new_doc_amt, l_doc_amt_max_incr_per, l_doc_amt_max_dec_per, l_doc_amt_max_incr_val, l_doc_amt_max_dec_val)) THEN
	        l_return_val := 'N';
	    END IF;
	    x_progress := 'DOC_AMOUNT_WITHIN_TOL:009';

	 ELSIF(l_doc_type = 'RELEASE') THEN

	    OPEN c_old_doc_amt_changes_rel(l_po_header_id,l_po_release_id);
	      FETCH c_old_doc_amt_changes_rel INTO  l_old_doc_amt;
	      x_progress := 'DOC_AMOUNT_WITHIN_TOL:010';
              log_message('DOC_AMOUNT_WITHIN_TOL','Old Amount',l_old_doc_amt);
	    CLOSE c_old_doc_amt_changes_rel;

	      l_new_doc_amt_rel :=  CALCULATE_NEW_DOC_AMOUNT(l_po_header_id,l_po_release_id,l_complex_po_style);
              x_progress := 'DOC_AMOUNT_WITHIN_TOL:011';
              log_message('DOC_AMOUNT_WITHIN_TOL','New Amount',l_new_doc_amt_rel);

	      IF (NOT change_within_tol(l_old_doc_amt, l_new_doc_amt_rel, l_doc_amt_max_incr_per, l_doc_amt_max_dec_per, l_doc_amt_max_incr_val, l_doc_amt_max_dec_val)) THEN
	        l_return_val := 'N';
	      END IF;
	 END IF; -- l_doc_type = PO , l_doc_type = RELEASE

	       x_progress := 'DOC_AMOUNT_WITHIN_TOL:012';
     END IF; -- PO Or RELEASE

   END IF; -- change group id is not null

	  -- set result value
	  resultout := wf_engine.eng_completed|| ':' || l_return_val ;

	  x_progress := 'DOC_AMOUNT_WITHIN_TOL:013';
	  log_message('DOC_AMOUNT_WITHIN_TOL','Result',resultout);

 END IF; -- IF ( funcmode = 'RUN' )

EXCEPTION
   WHEN OTHERS THEN
      IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         x_progress || ':unexpected error' || Sqlerrm);
      END IF;
 wf_core.context('POSCHORD', 'DOC_AMOUNT_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);
 raise;
END DOC_AMOUNT_WITHIN_TOL;


FUNCTION CALCULATE_NEW_DOC_AMOUNT(  p_po_header_id IN NUMBER , p_po_release_id IN NUMBER, p_complex_po_style IN VARCHAR2)
RETURN NUMBER
IS
-- Picks up new amount for SPO
CURSOR c_new_doc_amt_changes(p_po_header_id_csr IN NUMBER) IS
	 SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT',(nvl(pcr1.new_amount,pll.amount) - nvl(pll.amount_cancelled,0)),
	          (nvl(pcr.new_price,pl.unit_price) *
	          (nvl(pcr1.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
	          FROM    po_change_requests pcr, --line amount/price change
	 	 	 po_change_requests pcr1, --shipment quantity change
	 	 	 po_lines_all pl,
	 	 	 po_line_locations_all pll
	          WHERE   pl.po_header_id = p_po_header_id_csr
	 	 	 AND pll.po_line_id = pl.po_line_id
	                 AND pcr1.document_header_id (+) = p_po_header_id_csr
	                 AND pcr1.document_line_location_id(+) = pll.line_location_id
	 	         AND pcr1.action_type(+) = 'MODIFICATION'
	 	         AND pcr1.request_status(+) = 'PENDING'
	 	         AND pcr1.request_level (+) = 'SHIPMENT'
	 	         AND pcr1.initiator(+) = 'SUPPLIER'
	                 AND pcr.document_line_id(+) = pl.po_line_id
	 	         AND pcr.action_type(+) = 'MODIFICATION'
	 	         AND pcr.request_status(+) = 'PENDING'
	 	         AND pcr.request_level (+) = 'LINE'
	 	         AND pcr.initiator(+) = 'SUPPLIER'
	 	UNION ALL
	   -- for splitted shipments
	  SELECT   nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount,pll.amount),
	           (nvl(pcr.new_price,pl.unit_price) * pcr2.new_quantity))),0)
	          FROM    po_change_requests pcr, --line amount/price change
	 		 po_change_requests pcr2, --for split shipments
	 	 	 po_lines_all pl,
	 	 	 po_line_locations_all pll
	          WHERE   pl.po_header_id = p_po_header_id_csr
	 	 	 AND pll.po_line_id = pl.po_line_id
	                 AND pcr2.document_header_id = p_po_header_id_csr
	                 AND pcr2.parent_line_location_id = pll.line_location_id
	 	         AND pcr2.action_type = 'MODIFICATION'
	 	         AND pcr2.request_status = 'PENDING'
	 	         AND pcr2.request_level  = 'SHIPMENT'
	 	         AND pcr2.initiator = 'SUPPLIER'
	                 AND pcr.document_line_id(+) = pl.po_line_id
	 	         AND pcr.action_type(+) = 'MODIFICATION'
	 	         AND pcr.request_status(+) = 'PENDING'
	 	         AND pcr.request_level (+) = 'LINE'
	                 AND pcr.initiator(+) = 'SUPPLIER';

  -- Picks up new amount for releases
  -- old_price included for price breaks
 CURSOR c_new_doc_amt_changes_rel(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER ) IS
  SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', (nvl(pcr.new_amount, pll.amount) - nvl(pll.amount_cancelled,0)), (nvl(nvl(pcr.new_price,pcr.old_price),pll.price_override) * (nvl(pcr.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
  	FROM    po_change_requests pcr,
  		po_lines_all pl,
  		po_line_locations_all pll
  	WHERE  pll.po_header_id = p_po_header_id_csr
               AND pll.po_release_id = p_po_release_id_csr
  	       AND pll.po_line_id = pl.po_line_id
  	       AND pcr.po_release_id(+) = p_po_release_id_csr
  	       AND pcr.document_header_id(+) = p_po_header_id_csr
  	       --AND pcr.document_line_id = pl.po_line_id
  	       AND pcr.action_type(+) = 'MODIFICATION'
  	       AND pcr.request_status(+) = 'PENDING'
  	       AND pcr.request_level (+) = 'SHIPMENT'
  	       AND pcr.initiator(+) = 'SUPPLIER'
  	       AND pcr.document_line_location_id(+) = pll.line_location_id
  	 UNION ALL
  SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount, pll.amount), (nvl(pcr2.new_price,pll.price_override) * nvl(pcr2.new_quantity,pll.quantity)))),0)
  	FROM    po_change_requests pcr2, -- for splitted shipments
  		po_lines_all pl,
  		po_line_locations_all pll
  	WHERE  pll.po_header_id = p_po_header_id_csr
  	       AND pll.po_line_id = pl.po_line_id
  	       AND pcr2.po_release_id(+) = p_po_release_id_csr
  	       AND pcr2.document_header_id(+) = p_po_header_id_csr
  	       AND pcr2.document_line_id(+) = pl.po_line_id
  	       AND pcr2.action_type(+) = 'MODIFICATION'
  	       AND pcr2.request_status(+) = 'PENDING'
  	       AND pcr2.request_level (+) = 'SHIPMENT'
  	       AND pcr2.initiator(+) = 'SUPPLIER'
	       AND pcr2.parent_line_location_id = pll.line_location_id;


 -- Picks Up New Amount for Complex Po's ( Actuals Case)
CURSOR c_new_doc_amt_chg_cw_actuals(p_po_header_id_csr IN NUMBER) IS
 SELECT NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                         (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                        'AMOUNT',
               DECODE(pll.payment_type, 'LUMPSUM',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'MILESTONE',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'RATE',
                                         (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
 FROM
    po_change_requests pcr, --shipment changes
    po_lines_all pl,
    po_line_locations_all pll
 WHERE
    pl.po_header_id = p_po_header_id_csr
    AND pll.po_line_id = pl.po_line_id
    AND pcr.document_header_id (+) = p_po_header_id_csr
    AND pcr.document_line_location_id(+) = pll.line_location_id
    AND pcr.action_type(+) = 'MODIFICATION'
    AND pcr.request_status(+) = 'PENDING'
    AND pcr.request_level (+) = 'SHIPMENT'
    AND pcr.initiator(+) = 'SUPPLIER'
UNION ALL
 -- for split shipment changes
SELECT NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                         (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                        'AMOUNT',
               DECODE(nvl(pcr.new_progress_type,pll.payment_type), 'LUMPSUM',
                                                                  (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                  'MILESTONE',
                                                                  (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                  'RATE',
                                                                  (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
FROM
    po_change_requests pcr, --shipment changes
    po_lines_all pl,
    po_line_locations_all pll
WHERE
    pl.po_header_id = p_po_header_id_csr
    AND pll.po_line_id = pl.po_line_id
    AND pcr.document_header_id  = p_po_header_id_csr
    AND pcr.parent_line_location_id = pll.line_location_id
    AND pcr.action_type = 'MODIFICATION'
    AND pcr.request_status = 'PENDING'
    AND pcr.request_level  = 'SHIPMENT'
    AND pcr.initiator = 'SUPPLIER';


-- Picks Up New Amount for Complex Po's ( Financing Case)
CURSOR c_new_doc_amt_chg_cw_financing(p_po_header_id_csr IN NUMBER) IS
  SELECT NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',(pl.quantity*nvl(pcr.new_price,pl.unit_price)),
                                          'AMOUNT',nvl(pcr.new_amount,pl.amount))),0)
  FROM
      po_lines_all pl,
      po_change_requests pcr
  WHERE
      pl.po_header_id = p_po_header_id_csr
      AND pcr.document_header_id (+) = p_po_header_id_csr
      AND pcr.document_line_id(+) = pl.po_line_id
      AND pcr.action_type(+) = 'MODIFICATION'
      AND pcr.request_status(+) = 'PENDING'
      AND pcr.request_level (+) = 'LINE'
      AND pcr.initiator(+) = 'SUPPLIER';



  l_new_doc_amt          NUMBER;
  l_total_new_doc_amt    NUMBER := 0;
  x_progress             VARCHAR2(1000);

  BEGIN

    x_progress := 'CALCULATE_NEW_DOC_AMOUNT:000';
    IF(p_po_release_id is null) THEN

         x_progress := 'CALCULATE_NEW_DOC_AMOUNT:001';
      IF(p_complex_po_style = 'ACTUALS') THEN
       OPEN c_new_doc_amt_chg_cw_actuals(p_po_header_id);
	 LOOP
	 FETCH c_new_doc_amt_chg_cw_actuals INTO  l_new_doc_amt;
	 EXIT WHEN c_new_doc_amt_chg_cw_actuals%NOTFOUND;
	     l_total_new_doc_amt := l_total_new_doc_amt + l_new_doc_amt;
	 END LOOP;
         x_progress:= 'CALCULATE_NEW_DOC_AMOUNT:002';
         log_message('CALCULATE_NEW_DOC_AMOUNT','New AMount ',l_total_new_doc_amt);
       CLOSE   c_new_doc_amt_chg_cw_actuals;
     ELSIF(p_complex_po_style = 'FINANCING') THEN
        OPEN c_new_doc_amt_chg_cw_financing(p_po_header_id);
	 LOOP
	 FETCH c_new_doc_amt_chg_cw_financing INTO  l_new_doc_amt;
	 EXIT WHEN c_new_doc_amt_chg_cw_financing%NOTFOUND;
	     l_total_new_doc_amt := l_total_new_doc_amt + l_new_doc_amt;
	 END LOOP;
         x_progress:= 'CALCULATE_NEW_DOC_AMOUNT:002';
         log_message('CALCULATE_NEW_DOC_AMOUNT','New AMount ',l_total_new_doc_amt);
       CLOSE   c_new_doc_amt_chg_cw_financing;
     ELSE
        OPEN c_new_doc_amt_changes(p_po_header_id);
	 LOOP
	 FETCH c_new_doc_amt_changes INTO  l_new_doc_amt;
	 EXIT WHEN c_new_doc_amt_changes%NOTFOUND;
	     l_total_new_doc_amt := l_total_new_doc_amt + l_new_doc_amt;
	 END LOOP;
         x_progress:= 'CALCULATE_NEW_DOC_AMOUNT:002';
         log_message('CALCULATE_NEW_DOC_AMOUNT','New AMount ',l_total_new_doc_amt);
        CLOSE   c_new_doc_amt_changes;
      END IF;

    ELSIF( p_po_release_id is not null) THEN
         x_progress := 'CALCULATE_NEW_DOC_AMOUNT:003';
         OPEN c_new_doc_amt_changes_rel(p_po_header_id,p_po_release_id);
       	 LOOP
       	 FETCH c_new_doc_amt_changes_rel INTO  l_new_doc_amt;
       	 EXIT WHEN c_new_doc_amt_changes_rel%NOTFOUND;
       	     l_total_new_doc_amt := l_total_new_doc_amt + l_new_doc_amt;
       	 END LOOP;
         x_progress:= 'DOC_AMOUNT_WITHIN_TOL:004';
         log_message('DOC_AMOUNT_WITHIN_TOL','New AMount ',l_total_new_doc_amt);
        CLOSE   c_new_doc_amt_changes_rel;
          x_progress := 'CALCULATE_NEW_DOC_AMOUNT:005';
     END IF;

   return   l_total_new_doc_amt;

  EXCEPTION
    WHEN OTHERS THEN
      IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                               g_module_prefix,
                               x_progress || ':unexpected error' || Sqlerrm);
      END IF;
  raise;

END CALCULATE_NEW_DOC_AMOUNT;

/* This procedure checks whether Line Amount Change is within the tolerance or not
   Any Line Price change or shipment quantity chnage that affects the amount is also
   taken in to consideration
   Returns 'Y' if within the tolerance
   Returns 'N' if out of tolerance
*/


PROCEDURE LINE_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                          itemkey         IN VARCHAR2,
 	                          actid           IN NUMBER,
 	                          funcmode        IN VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2)
IS
-- Picks up Old Line Amount for SPO
  CURSOR c_line_amt_old(p_po_header_id_csr IN NUMBER) IS
         select sum(decode(pol.matching_basis, 'AMOUNT', (pll.amount - nvl(pll.amount_cancelled,0)), (pol.unit_price * (pll.quantity - nvl(pll.quantity_cancelled,0))))),pll.po_line_id
         from po_lines_all pol,
              po_line_locations_all pll
         where pll.po_header_id = p_po_header_id_csr
         AND   pll.po_line_id = pol.po_line_id
         GROUP BY pll.po_line_id;

  CURSOR c_line_amt_old_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) IS
       select sum(decode(pol.matching_basis, 'AMOUNT', (pll.amount - nvl(pll.amount_cancelled,0)), (pol.unit_price * (pll.quantity - nvl(pll.quantity_cancelled,0))))),pll.po_line_id
       from po_lines_all pol,
            po_line_locations_all pll
       where pll.po_release_id =p_po_release_id_csr
       AND   pll.po_header_id = p_po_header_id_csr
       AND   pll.po_line_id = pol.po_line_id
       GROUP BY pll.po_line_id;


 -- Picks up Old Line Amount ( Financing Case)
  CURSOR c_line_amt_old_cw_financing(p_po_header_id_csr IN NUMBER) IS
        SELECT SUM(DECODE(pl.matching_basis,'QUANTITY',pl.unit_price*pl.quantity,'AMOUNT',pl.amount)),pl.po_line_id
        FROM po_lines_all pl
	WHERE pl.po_header_id =  p_po_header_id_csr
	GROUP BY pl.po_line_id;

 -- Picks up Old Line Amount ( Actuals case)
   CURSOR c_line_amt_old_cw_actuals(p_po_header_id_csr IN NUMBER) IS
       SELECT SUM(DECODE(pl.matching_basis,'QUANTITY',
                                          (pll.quantity - NVL(pll.quantity_cancelled,0))* (pll.price_override),
                                           'AMOUNT',
                  DECODE(pll.payment_type, 'LUMPSUM',
                                           (pll.amount - NVL(pll.amount_cancelled,0)),
                                           'MILESTONE',
                                     	   (pll.amount - NVL(pll.amount_cancelled,0)),
                                           'RATE',
                                           (pll.quantity - NVL(pll.quantity_cancelled,0))*(pll.price_override)))),pll.po_line_id
        FROM 	 po_lines_all pl,
                 po_line_locations_all pll
        WHERE    pl.po_header_id = p_po_header_id_csr
	         AND pll.po_line_id = pl.po_line_id
                 GROUP BY pll.po_line_id;


  l_old_lineamt           po_change_requests.old_amount%TYPE;
  l_temp_po_line_id       NUMBER;
  l_return_val            VARCHAR2(1) :='Y';
  l_line_amt_max_incr_per    NUMBER;
  l_line_amt_max_dec_per     NUMBER;
  l_line_amt_max_incr_val    NUMBER;
  l_line_amt_max_dec_val     NUMBER;
  l_temp_total_line_amt_new  NUMBER;
  x_progress              VARCHAR2(1000);
  l_po_header_id          po_change_requests.document_header_id%TYPE;
  l_po_release_id         NUMBER;
  l_po_style_type                 VARCHAR2(10);
  l_doc_type                VARCHAR2(10);
  l_complex_po_style        VARCHAR2(10);

BEGIN

	IF ( funcmode = 'RUN' ) THEN

	 x_progress := 'LINE_AMOUNT_WITHIN_TOL:000';

	 l_po_header_id     :=  wf_engine.GetItemAttrNumber (itemtype =>  itemtype,
					                    itemkey  => itemkey,
	                                                    aname    => 'PO_HEADER_ID');

	 l_po_release_id    :=  wf_engine.GetItemAttrNumber (itemtype =>  itemtype,
					                    itemkey  => itemkey,
	                                                    aname    => 'PO_RELEASE_ID');

	 l_po_style_type    :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
      						            itemkey  => itemkey,
      		                                            aname    => 'PO_STYLE_TYPE');

         l_doc_type         :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
      						            itemkey  => itemkey,
      		                                            aname    => 'DOCUMENT_TYPE');

         l_complex_po_style :=   wf_engine.GetItemAttrText (itemtype => itemtype,
      						            itemkey  => itemkey,
      		                                            aname    => 'COMPLEX_PO_STYLE');


	 x_progress := 'LINE_AMOUNT_WITHIN_TOL:001';

    IF (l_po_header_id IS NOT NULL) THEN
	    -- check for the DOC types (applicable for  PO LINE AMOUNT( Line level)
	    -- if other doc types return true and exit
       IF(l_doc_type = 'PO' OR l_doc_type = 'RELEASE') THEN
	    -- get shipment quantity tolerances
	    l_line_amt_max_incr_per  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                     itemkey  => itemkey,
      		                                                     aname    => 'LINE_AMOUNT_INCR_PER');

	    l_line_amt_max_dec_per   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                     itemkey  => itemkey,
      		                                                     aname    => 'LINE_AMOUNT_DEC_PER');

	    x_progress := 'LINE_AMOUNT_WITHIN_TOL:002';
	    log_message('LINE_AMOUNT_WITHIN_TOL','Line Amount Incr & Decr Tol percentage',l_line_amt_max_incr_per || ', '|| l_line_amt_max_dec_per);


	    l_line_amt_max_incr_val   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                      itemkey  => itemkey,
      		                                                      aname    => 'LINE_AMOUNT_INCR_VAL');

	    l_line_amt_max_dec_val    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                      itemkey  => itemkey,
      		                                                      aname    => 'LINE_AMOUNT_DEC_VAL');

	    x_progress := 'LINE_AMOUNT_WITHIN_TOL:003';
	    log_message('LINE_AMOUNT_WITHIN_TOL','Line Amount Incr & Decr Tol values ',l_line_amt_max_incr_val || ', '|| l_line_amt_max_dec_val);

IF(l_doc_type = 'PO') THEN

	  IF(l_po_style_type = 'NORMAL') THEN
	    OPEN c_line_amt_old(l_po_header_id);

	    LOOP
	      FETCH c_line_amt_old
	        INTO l_old_lineamt,l_temp_po_line_id;
              EXIT WHEN c_line_amt_old%NOTFOUND;

              x_progress := 'LINE_AMOUNT_WITHIN_TOL:004';
              log_message('LINE_AMOUNT_WITHIN_TOL','Line Id ',l_temp_po_line_id);
              log_message('LINE_AMOUNT_WITHIN_TOL','Old Line Amount ',l_old_lineamt);

              EXIT WHEN (l_return_val = 'N');

	      l_temp_total_line_amt_new := CALCULATE_NEW_LINE_AMOUNT(l_po_header_id,l_po_release_id,l_temp_po_line_id,l_complex_po_style);

	      x_progress := 'LINE_AMOUNT_WITHIN_TOL:005';
	      log_message('LINE_AMOUNT_WITHIN_TOL','New line amount',l_temp_total_line_amt_new);

              IF (NOT change_within_tol(l_old_lineamt, l_temp_total_line_amt_new, l_line_amt_max_incr_per, l_line_amt_max_dec_per,l_line_amt_max_incr_val,l_line_amt_max_dec_val)) THEN
	        l_return_val := 'N';
	      END IF;
	      x_progress:= 'LINE_AMOUNT_WITHIN_TOL:006';
	      log_message('LINE_AMOUNT_WITHIN_TOL','Result',l_return_val);
	      END LOOP;
	    CLOSE  c_line_amt_old;
          ELSIF(l_po_style_type = 'COMPLEX') THEN
	    IF(l_complex_po_style = 'ACTUALS') THEN
	       OPEN c_line_amt_old_cw_actuals(l_po_header_id);

	       LOOP
	        FETCH c_line_amt_old_cw_actuals
	        INTO l_old_lineamt,l_temp_po_line_id;
                EXIT WHEN c_line_amt_old_cw_actuals%NOTFOUND;

                x_progress := 'LINE_AMOUNT_WITHIN_TOL:004';
                log_message('LINE_AMOUNT_WITHIN_TOL','Line Id ',l_temp_po_line_id);
                log_message('LINE_AMOUNT_WITHIN_TOL','Old Line Amount ',l_old_lineamt);

                EXIT WHEN (l_return_val = 'N');

	        l_temp_total_line_amt_new := CALCULATE_NEW_LINE_AMOUNT(l_po_header_id,l_po_release_id,l_temp_po_line_id,l_complex_po_style);

	        x_progress := 'LINE_AMOUNT_WITHIN_TOL:005';
	        log_message('LINE_AMOUNT_WITHIN_TOL','New line amount',l_temp_total_line_amt_new);

                IF (NOT change_within_tol(l_old_lineamt, l_temp_total_line_amt_new, l_line_amt_max_incr_per, l_line_amt_max_dec_per,l_line_amt_max_incr_val,l_line_amt_max_dec_val)) THEN
	          l_return_val := 'N';
	        END IF;
	        x_progress:= 'LINE_AMOUNT_WITHIN_TOL:006';
	        log_message('LINE_AMOUNT_WITHIN_TOL','Result',l_return_val);
	        END LOOP;
	        CLOSE  c_line_amt_old_cw_actuals;
           ELSIF(l_complex_po_style = 'FINANCING') THEN
	       OPEN c_line_amt_old_cw_financing(l_po_header_id);

	       LOOP
	        FETCH c_line_amt_old_cw_financing
	        INTO l_old_lineamt,l_temp_po_line_id;
                EXIT WHEN c_line_amt_old_cw_financing%NOTFOUND;

                x_progress := 'LINE_AMOUNT_WITHIN_TOL:004';
                log_message('LINE_AMOUNT_WITHIN_TOL','Line Id ',l_temp_po_line_id);
                log_message('LINE_AMOUNT_WITHIN_TOL','Old Line Amount ',l_old_lineamt);

                EXIT WHEN (l_return_val = 'N');

	        l_temp_total_line_amt_new := CALCULATE_NEW_LINE_AMOUNT(l_po_header_id,l_po_release_id,l_temp_po_line_id,l_complex_po_style);

	        x_progress := 'LINE_AMOUNT_WITHIN_TOL:005';
	        log_message('LINE_AMOUNT_WITHIN_TOL','New line amount',l_temp_total_line_amt_new);
	        END LOOP;
                CLOSE  c_line_amt_old_cw_financing;

               END IF; -- ACTUALS , FINANCING
           END IF; -- po_style_type = NORMAL

            IF (NOT change_within_tol(l_old_lineamt, l_temp_total_line_amt_new, l_line_amt_max_incr_per, l_line_amt_max_dec_per,l_line_amt_max_incr_val,l_line_amt_max_dec_val)) THEN
	          l_return_val := 'N';
	        END IF;
	        x_progress:= 'LINE_AMOUNT_WITHIN_TOL:006';
	        log_message('LINE_AMOUNT_WITHIN_TOL','Result',l_return_val);


 ELSIF(l_doc_type = 'RELEASE') THEN

                  OPEN c_line_amt_old_rel(l_po_header_id,l_po_release_id);
	             LOOP
	                     FETCH c_line_amt_old_rel INTO  l_old_lineamt,l_temp_po_line_id;
                	     EXIT WHEN c_line_amt_old_rel%NOTFOUND;
                	     x_progress := 'LINE_AMOUNT_WITHIN_TOL:010';
                             log_message('LINE_AMOUNT_WITHIN_TOL','Old Line Amount',l_old_lineamt);

                  l_temp_total_line_amt_new :=  CALCULATE_NEW_LINE_AMOUNT(l_po_header_id,l_po_release_id,l_temp_po_line_id,l_complex_po_style);
                  x_progress := 'LINE_AMOUNT_WITHIN_TOL:011';
                  log_message('LINE_AMOUNT_WITHIN_TOL','New Line Amount',l_temp_total_line_amt_new);


                 IF (NOT change_within_tol(l_old_lineamt, l_temp_total_line_amt_new, l_line_amt_max_incr_per,l_line_amt_max_dec_per,l_line_amt_max_incr_val,l_line_amt_max_dec_val)) THEN
	        l_return_val := 'N';
	        END IF;
                   END LOOP;
                   CLOSE c_line_amt_old_rel;

ELSE
	     l_return_val := 'Y';

END IF;

END IF; -- l_doc_type PO Or RELEASE

 END IF; -- l_po_header_id is not null
	  -- set result value
	  resultout := wf_engine.eng_completed|| ':' || l_return_val ;
	  x_progress := 'LINE_AMOUNT_WITHIN_TOL:007';
          log_message('LINE_AMOUNT_WITHIN_TOL','Final result',resultout);
  END IF; -- IF ( funcmode = 'RUN' )

EXCEPTION
   WHEN OTHERS THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                            g_module_prefix,
                            x_progress || ':unexpected error' || Sqlerrm);
   END IF;
   wf_core.context('POSCHORD', 'LINE_AMOUNT_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);
   raise;
END LINE_AMOUNT_WITHIN_TOL;


FUNCTION  CALCULATE_NEW_LINE_AMOUNT( p_po_header_id IN NUMBER, p_po_release_id IN NUMBER, p_po_line_id IN NUMBER,p_complex_po_style IN VARCHAR2)
RETURN NUMBER
IS
-- Picks up new line amount for SPO
CURSOR c_line_amt_new(p_po_header_id_csr IN NUMBER, p_temp_po_line_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
  SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', (nvl(pcr1.new_amount,pll.amount) - nvl(pll.amount_cancelled,0)),
           (nvl(pcr.new_price,pl.unit_price) *
           (nvl(pcr1.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
           FROM    po_change_requests pcr, --line amount/price change
  	 	 po_change_requests pcr1, --shipment quantity change
  	 	 po_lines_all pl,
  	 	 po_line_locations_all pll
           WHERE   pl.po_header_id = p_po_header_id_csr
                   AND pl.po_line_id = p_temp_po_line_id_csr
  	 	   AND pll.po_line_id = pl.po_line_id
                   AND pcr1.document_header_id (+) = p_po_header_id_csr
                   AND pcr1.document_line_location_id(+) = pll.line_location_id
  	           AND pcr1.action_type(+) = 'MODIFICATION'
  	           AND pcr1.request_status(+) = req_status
  	           AND pcr1.request_level (+) = 'SHIPMENT'
  	           AND pcr1.initiator(+) = req_initiator
                   AND pcr.document_line_id(+) = pl.po_line_id
  	           AND pcr.action_type(+) = 'MODIFICATION'
  	           AND pcr.request_status(+) = req_status
  	           AND pcr.request_level (+) = 'LINE'
  	           AND pcr.initiator(+) = req_initiator
  	UNION ALL
    -- for splitted shipments
   SELECT   nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount,pll.amount),
            (nvl(pcr.new_price,pl.unit_price) * pcr2.new_quantity))),0)
           FROM    po_change_requests pcr, --line amount/price change
  		   po_change_requests pcr2, --for split shipments
  	 	   po_lines_all pl,
  	 	   po_line_locations_all pll
           WHERE   pl.po_header_id = p_po_header_id_csr
                   AND pl.po_line_id = p_temp_po_line_id_csr
  	 	   AND pll.po_line_id = pl.po_line_id
                   AND pcr2.document_header_id = p_po_header_id_csr
                   AND pcr2.parent_line_location_id = pll.line_location_id
  	           AND pcr2.action_type = 'MODIFICATION'
  	           AND pcr2.request_status in req_status
  	           AND pcr2.request_level  = 'SHIPMENT'
  	           AND pcr2.initiator = req_initiator
                   AND pcr.document_line_id(+) = pl.po_line_id
  	           AND pcr.action_type(+) = 'MODIFICATION'
  	           AND pcr.request_status in req_status
  	           AND pcr.request_level (+) = 'LINE'
	           AND pcr.initiator(+) = req_initiator;


-- Picks up new line amount for releses
-- old_price is included for price breaks
CURSOR c_line_amt_new_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER, p_temp_po_line_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
   SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', (nvl(pcr.new_amount, pll.amount) - nvl(pll.amount_cancelled,0)),
			  (nvl(nvl(pcr.new_price,pcr.old_price),pll.price_override) *
			   (nvl(pcr.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
     	FROM    po_change_requests pcr,
     		po_lines_all pl,
     		po_line_locations_all pll
     	WHERE  pll.po_header_id = p_po_header_id_csr
     	       AND pll.po_line_id = p_temp_po_line_id_csr
     	       AND pll.po_line_id = pl.po_line_id
     	       AND pll.po_release_id = p_po_release_id_csr
	       AND pcr.po_release_id (+) = p_po_release_id_csr
     	       AND pcr.document_header_id(+) = p_po_header_id_csr
     	       --AND pcr.document_line_id = pl.po_line_id
     	       AND pcr.action_type(+) = 'MODIFICATION'
     	       AND pcr.request_status (+) = req_status
     	       AND pcr.request_level (+) = 'SHIPMENT'
     	       AND pcr.initiator(+) = req_initiator
     	       AND pcr.document_line_location_id(+) = pll.line_location_id
     	 UNION ALL
     SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount, pll.amount), (nvl(nvl(pcr2.new_price,pcr2.old_price),pll.price_override) * nvl(pcr2.new_quantity,pll.quantity)))),0)
     	FROM    po_change_requests pcr2, -- for splitted shipments
     		po_lines_all pl,
     		po_line_locations_all pll
     	WHERE  pll.po_header_id = p_po_header_id_csr
     	       AND pll.po_line_id = p_temp_po_line_id_csr
     	       AND pll.po_line_id = pl.po_line_id
     	       AND pcr2.po_release_id = p_po_release_id_csr
     	       AND pcr2.document_header_id(+) = p_po_header_id_csr
     	       AND pcr2.document_line_id(+) = pl.po_line_id
     	       AND pcr2.action_type(+) = 'MODIFICATION'
     	       AND pcr2.request_status in req_status
     	       AND pcr2.request_level (+) = 'SHIPMENT'
     	       AND pcr2.initiator(+) = req_initiator
	       AND pcr2.parent_line_location_id = pll.line_location_id;


-- Picks up New Line Amount for complex Po( Actuals Case)
 CURSOR c_line_amt_new_cw_actuals(p_po_header_id_csr IN NUMBER, p_temp_po_line_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
   select NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                         (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                        'AMOUNT',
                  DECODE(pll.payment_type, 'LUMPSUM',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'MILESTONE',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'RATE',
                                         (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
 FROM
    po_change_requests pcr, --shipment quantity changes
    po_lines_all pl,
    po_line_locations_all pll
 WHERE
    pl.po_header_id = p_po_header_id_csr
    AND pl.po_line_id = p_temp_po_line_id_csr
    AND pll.po_line_id = pl.po_line_id
    AND pcr.document_header_id (+) = p_po_header_id_csr
    AND pcr.document_line_location_id(+) = pll.line_location_id
    AND pcr.action_type(+) = 'MODIFICATION'
    AND pcr.request_status(+)=req_status
    AND pcr.request_level (+) = 'SHIPMENT'
    AND pcr.initiator(+) = req_initiator
 UNION ALL
 -- for split shipment changes
 select NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                         (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                        'AMOUNT',
                DECODE(nvl(pcr.new_progress_type,pll.payment_type), 'LUMPSUM',
                                                                  (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                  'MILESTONE',
                                                                  (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                  'RATE',
                                                                  (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
 FROM
    po_change_requests pcr, --shipment quantity changes
    po_lines_all pl,
    po_line_locations_all pll
 WHERE
    pl.po_header_id = p_po_header_id_csr
    AND pl.po_line_id = p_temp_po_line_id_csr
    AND pll.po_line_id = pl.po_line_id
    AND pcr.document_header_id  = p_po_header_id_csr
    AND pcr.parent_line_location_id = pll.line_location_id
    AND pcr.action_type = 'MODIFICATION'
    AND pcr.request_status(+)=req_status
    AND pcr.request_level  = 'SHIPMENT'
    AND pcr.initiator = req_initiator;


-- Picks up New Line Amount for Complex POs( Financing Case)
CURSOR c_line_amt_new_cw_financing(p_po_header_id_csr IN NUMBER, p_temp_po_line_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
  SELECT NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',(pl.quantity*nvl(pcr.new_price,pl.unit_price)),
                                          'AMOUNT',nvl(pcr.new_amount,pl.amount))),0)
  FROM
      po_lines_all pl,
      po_change_requests pcr
  WHERE
      pl.po_header_id = p_po_header_id_csr
      AND pl.po_line_id = p_temp_po_line_id_csr
      AND pcr.document_header_id (+) = p_po_header_id_csr
      AND pcr.document_line_id(+) = pl.po_line_id
      AND pcr.action_type(+) = 'MODIFICATION'
      AND pcr.request_status(+)=req_status
      AND pcr.request_level (+) = 'LINE'
      AND pcr.initiator(+) = req_initiator;

l_new_line_amt          NUMBER;
l_total_new_line_amt    NUMBER := 0;
x_progress             VARCHAR2(1000);
req_status              po_change_requests.request_status%TYPE;
req_initiator           po_change_requests.initiator%TYPE;

BEGIN
  /* Code Changes for Bug - 11794109 Start */
  BEGIN

    IF(p_po_release_id is null) THEN
        select distinct request_status ,initiator into req_status,req_initiator from po_change_requests
        where document_header_id=p_po_header_id AND document_type = 'PO'
              and change_active_flag='Y'
              and rownum=1;
    ELSE
        select distinct request_status ,initiator into req_status,req_initiator from po_change_requests
        where document_header_id=p_po_header_id AND document_type = 'RELEASE'
              and po_release_id = p_po_release_id
              and change_active_flag='Y'
              and rownum=1;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return   l_total_new_line_amt;
  END;
  /* Code Changes for Bug - 11794109 End */

    x_progress := 'CALCULATE_NEW_LINE_AMOUNT:000';
    IF(p_po_release_id is null) THEN
     IF(p_complex_po_style = 'ACTUALS')  THEN
        OPEN c_line_amt_new_cw_actuals(p_po_header_id,p_po_line_id,req_status,req_initiator);
	 LOOP
	 FETCH c_line_amt_new_cw_actuals INTO  l_new_line_amt;
	 EXIT WHEN c_line_amt_new_cw_actuals%NOTFOUND;
	     l_total_new_line_amt := l_total_new_line_amt + l_new_line_amt;
	 END LOOP;
         x_progress:= 'LINE_AMOUNT_WITHIN_TOL:005';
         log_message('LINE_AMOUNT_WITHIN_TOL','New AMount ',l_total_new_line_amt);
        CLOSE   c_line_amt_new_cw_actuals;
     ELSIF(p_complex_po_style = 'FINANCING') THEN
        OPEN c_line_amt_new_cw_financing(p_po_header_id,p_po_line_id,req_status,req_initiator);
	 LOOP
	 FETCH c_line_amt_new_cw_financing INTO  l_new_line_amt;
	 EXIT WHEN c_line_amt_new_cw_financing%NOTFOUND;
	     l_total_new_line_amt := l_total_new_line_amt + l_new_line_amt;
	 END LOOP;
         x_progress:= 'LINE_AMOUNT_WITHIN_TOL:005';
         log_message('LINE_AMOUNT_WITHIN_TOL','New AMount ',l_total_new_line_amt);
        CLOSE   c_line_amt_new_cw_financing;

     ELSE

        OPEN c_line_amt_new(p_po_header_id,p_po_line_id,req_status,req_initiator);
	 LOOP
	 FETCH c_line_amt_new INTO  l_new_line_amt;
	 EXIT WHEN c_line_amt_new%NOTFOUND;
	     l_total_new_line_amt := l_total_new_line_amt + l_new_line_amt;
	 END LOOP;
         x_progress:= 'LINE_AMOUNT_WITHIN_TOL:005';
         log_message('LINE_AMOUNT_WITHIN_TOL','New AMount ',l_total_new_line_amt);
        CLOSE   c_line_amt_new;
     END IF;
    ELSIF( p_po_release_id is not null) THEN

       OPEN c_line_amt_new_rel(p_po_header_id,p_po_release_id,p_po_line_id,req_status,req_initiator);
       	 LOOP
       	 FETCH c_line_amt_new_rel INTO  l_new_line_amt;
       	 EXIT WHEN c_line_amt_new_rel%NOTFOUND;
       	     l_total_new_line_amt := l_total_new_line_amt + l_new_line_amt;
       	 END LOOP;
         x_progress:= 'LINE_AMOUNT_WITHIN_TOL:005';
         log_message('LINE_AMOUNT_WITHIN_TOL','New AMount ',l_total_new_line_amt);
        CLOSE   c_line_amt_new_rel;
    END IF;

   return   l_total_new_line_amt;

  EXCEPTION
    WHEN OTHERS THEN
      IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                               g_module_prefix,
                               x_progress || ':unexpected error' || Sqlerrm);
      END IF;
  raise;
 END CALCULATE_NEW_LINE_AMOUNT;


PROCEDURE SHIP_AMOUNT_WITHIN_TOL( itemtype        IN VARCHAR2,
 	                          itemkey         IN VARCHAR2,
 	                          actid           IN NUMBER,
 	                          funcmode        IN VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2)
IS

-- Calculates the old shipment amount
 CURSOR c_old_ship_amt(p_po_header_id_csr IN NUMBER) IS
        select sum(decode(pol.matching_basis,'AMOUNT',(nvl(pll.amount,0) - nvl(pll.amount_cancelled,0)),(pol.unit_price *(pll.quantity-nvl(pll.quantity_cancelled,0))))),pll.line_location_id
	from    po_line_locations_all pll,
	        po_lines_all pol
	where pll.po_header_id = p_po_header_id_csr
	      AND pll.po_line_id = pol.po_line_id
	      GROUP BY pll.line_location_id;

-- Calculate Old Shipment amount for the BPA Release
 CURSOR c_old_ship_amt_rel(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER) IS
        SELECT  sum(decode(pl.matching_basis, 'AMOUNT', (pll.amount - nvl(pll.amount_cancelled,0)),(pll.price_override * (pll.quantity - nvl(pll.quantity_cancelled,0))))),
                pll.line_location_id
	FROM 	po_lines_all pl,
	        po_line_locations_all pll
	WHERE   pll.po_release_id = p_po_release_id_csr
                AND pll.po_header_id = p_po_header_id_csr
		AND pll.po_line_id = pl.po_line_id
		GROUP BY pll.line_location_id;

-- Calculate Old Shipment amount for the Complex work POs ( Actuals And Financing Case)
 CURSOR c_old_ship_amt_cw(p_po_header_id_csr IN NUMBER) IS
        SELECT SUM(DECODE(pl.matching_basis,'QUANTITY',
                                          (pll.quantity - NVL(pll.quantity_cancelled,0))* (pll.price_override),
                                            'AMOUNT',
                   DECODE(pll.payment_type, 'LUMPSUM',
                                            (pll.amount - NVL(pll.amount_cancelled,0)),
                                            'MILESTONE',
                                     	    (pll.amount - NVL(pll.amount_cancelled,0)),
                                            'RATE',
                                            (pll.quantity - NVL(pll.quantity_cancelled,0))*(pll.price_override)))),pll.line_location_id
         FROM 	 po_lines_all pl,
                 po_line_locations_all pll
         WHERE   pl.po_header_id = p_po_header_id_csr
	         AND pll.po_line_id = pl.po_line_id
                 GROUP BY pll.line_location_id;






  l_po_header_id          po_change_requests.document_header_id%TYPE;
  l_po_release_id         po_change_requests.po_release_id%TYPE;
  l_po_line_id            po_change_requests.document_line_id%TYPE;
  l_change_group_id       po_change_requests.change_request_group_id%type;
  l_matching_basis        po_lines_all.matching_basis%TYPE;
  l_old_shipamt           po_change_requests.old_amount%TYPE;
  l_new_shipamt           po_change_requests.new_amount%TYPE;
  l_old_ship_amt_rel      NUMBER;
  l_new_ship_amt_rel      NUMBER;
  l_old_ship_amt_cw       NUMBER;
  l_new_ship_amt_cw       NUMBER;
  l_return_val            VARCHAR2(1) :='Y';
  l_shipamt_max_incr_per  NUMBER;
  l_shipamt_max_dec_per   NUMBER;
  l_shipamt_max_incr_val  NUMBER;
  l_shipamt_max_dec_val   NUMBER;
  l_old_ship_amt          NUMBER;
  l_new_ship_amt          NUMBER := 0;
  l_new_ship_amt_no_change NUMBER := 0;
  l_line_location_id      NUMBER;
  l_po_style_type         VARCHAR2(10);
  l_doc_type              VARCHAR2(10);
  x_progress              VARCHAR2(1000);


  BEGIN

  IF ( funcmode = 'RUN' ) THEN
           x_progress := 'SHIP_AMOUNT_WITHIN_TOL:000';

	   l_po_header_id       := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                        itemkey  => itemkey,
	                                                        aname    => 'PO_HEADER_ID');

	   l_po_release_id      := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                        itemkey  => itemkey,
	                                                        aname    => 'PO_RELEASE_ID');

	   l_change_group_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                        itemkey  => itemkey,
	                                                        aname    => 'CHANGE_REQUEST_GROUP_ID');

	   l_po_style_type      := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						                itemkey  => itemkey,
      		                                                aname    => 'PO_STYLE_TYPE');

           l_doc_type           := wf_engine.GetItemAttrText   (itemtype => itemtype,
      						                itemkey  => itemkey,
      		                                                aname    => 'DOCUMENT_TYPE');
      	   x_progress := 'SHIP_AMOUNT_WITHIN_TOL:001';

   IF (l_change_group_id IS NOT NULL) THEN
	        -- check for the DOC types (applicable for  PO LINE AMOUNT( Line level)
	        -- if other doc types return true and exit
	IF(l_doc_type = 'PO' OR l_doc_type = 'RELEASE') THEN

	   IF (l_po_style_type='NORMAL') THEN

 	 	-- get shipment quantity tolerances
	  	l_shipamt_max_incr_per := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                       itemkey  => itemkey,
      		                                                       aname    => 'SHIP_AMOUNT_INCR_PER');

	  	l_shipamt_max_dec_per  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                       itemkey  => itemkey,
      		                                                       aname    => 'SHIP_AMOUNT_DEC_PER');

	  	x_progress := 'SHIP_AMOUNT_WITHIN_TOL:002';
	  	log_message('SHIP_AMOUNT_WITHIN_TOL','Ship amount Incr & decr Percentage',l_shipamt_max_incr_per ||', '|| l_shipamt_max_dec_per);
	        -- get shipment quantity tolerances
	  	l_shipamt_max_incr_val := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                       itemkey  => itemkey,
      		                                                       aname    => 'SHIP_AMOUNT_INCR_VAL');

	  	l_shipamt_max_dec_val  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
      						                       itemkey  => itemkey,
      		                                                       aname    => 'SHIP_AMOUNT_DEC_VAL');

      		x_progress := 'SHIP_AMOUNT_WITHIN_TOL:003';
	  	log_message('SHIP_AMOUNT_WITHIN_TOL','Ship amount Incr & decr value', l_shipamt_max_incr_val ||', '|| l_shipamt_max_dec_val);

	   ELSIF (l_po_style_type='COMPLEX') THEN
	        -- Complex Work PO Chack  -- COMPLEX WORK
	        -- get shipment quantity tolerances
		l_shipamt_max_incr_per := wf_engine.GetItemAttrNumber (itemtype => itemtype,
		      						       itemkey  => itemkey,
		      		                                       aname    => 'PAY_AMOUNT_INCR_PER');

		l_shipamt_max_dec_per  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
		      						       itemkey  => itemkey,
		      		                                       aname    => 'PAY_AMOUNT_DEC_PER');

		x_progress := 'SHIP_AMOUNT_WITHIN_TOL:004';
	  	log_message('SHIP_AMOUNT_WITHIN_TOL','Ship amount Incr & decr Percentage',l_shipamt_max_incr_per ||', '|| l_shipamt_max_dec_per);
	        -- get shipment quantity tolerances
		l_shipamt_max_incr_val := wf_engine.GetItemAttrNumber (itemtype => itemtype,
		    				                       itemkey  => itemkey,
		      		                                       aname    => 'PAY_AMOUNT_INCR_VAL');

                l_shipamt_max_dec_val  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
       						                       itemkey  => itemkey,
		      		                                       aname    => 'PAY_AMOUNT_DEC_VAL');
	        x_progress := 'SHIP_AMOUNT_WITHIN_TOL:005';
	  	log_message('SHIP_AMOUNT_WITHIN_TOL','Ship amount Incr & decr value', l_shipamt_max_incr_val ||', '|| l_shipamt_max_dec_val);
	   END IF;  --l_po_style_type='NORMAL'/'COMPLEX'



	   IF(l_doc_type = 'PO' and l_po_style_type='NORMAL') THEN
	       OPEN c_old_ship_amt(l_po_header_id);
	             LOOP
	      	     FETCH c_old_ship_amt
	             INTO l_old_ship_amt,l_line_location_id;
	             x_progress := 'SHIP_AMOUNT_WITHIN_TOL:006';
	             log_message('SHIP_AMOUNT_WITHIN_TOL','Old Ship Amount',l_old_ship_amt);
	             EXIT WHEN (l_return_val='N');
                     EXIT WHEN c_old_ship_amt%NOTFOUND;

	             l_new_ship_amt := CALCULATE_NEW_SHIP_AMOUNT(l_po_header_id,l_po_release_id,l_line_location_id,'N',l_po_style_type,null);

	             x_progress := 'SHIP_AMOUNT_WITHIN_TOL:007';
	             IF (NOT change_within_tol(l_old_ship_amt, l_new_ship_amt, l_shipamt_max_incr_per, l_shipamt_max_dec_per,l_shipamt_max_incr_val   , l_shipamt_max_dec_val)) THEN
                         l_return_val := 'N';
                     END IF;
                     x_progress := 'SHIP_AMOUNT_WITHIN_TOL:009';
                     log_message('SHIP_AMOUNT_WITHIN_TOL','Result',l_return_val);
                     END LOOP;
	        CLOSE  c_old_ship_amt;

	        IF (l_return_val = 'Y') THEN
                    wf_engine.SetItemAttrText( itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'NOTIF_USAGE',
                                               avalue     => 'BUYER_AUTO_FYI');
                END IF;
           ELSIF ((l_doc_type = 'RELEASE') and (l_po_style_type='NORMAL')) THEN
                OPEN c_old_ship_amt_rel(l_po_header_id,l_po_release_id);
	      	     LOOP
	      	     FETCH c_old_ship_amt_rel
	      	     INTO l_old_ship_amt,l_line_location_id;
	      	     x_progress := 'SHIP_AMOUNT_WITHIN_TOL:006';
	      	     log_message('SHIP_AMOUNT_WITHIN_TOL','Old Ship Amount',l_old_ship_amt);
	      	     EXIT WHEN (l_return_val='N');
	             EXIT WHEN c_old_ship_amt_rel%NOTFOUND;

	      	     l_new_ship_amt := CALCULATE_NEW_SHIP_AMOUNT(l_po_header_id,l_po_release_id,l_line_location_id,'N',l_po_style_type,null);

	      	     x_progress := 'SHIP_AMOUNT_WITHIN_TOL:007';
	             IF (NOT change_within_tol(l_old_ship_amt, l_new_ship_amt, l_shipamt_max_incr_per, l_shipamt_max_dec_per,l_shipamt_max_incr_val   , l_shipamt_max_dec_val)) THEN
	                 l_return_val := 'N';
	             END IF;
	             x_progress := 'SHIP_AMOUNT_WITHIN_TOL:009';
	             log_message('SHIP_AMOUNT_WITHIN_TOL','Result',l_return_val);
	             END LOOP;
	         CLOSE  c_old_ship_amt_rel;

              IF (l_return_val = 'Y') THEN
	         wf_engine.SetItemAttrText( itemtype  => itemtype,
	                                    itemkey   => itemkey,
	                                    aname     => 'NOTIF_USAGE',
	                                    avalue     => 'BUYER_AUTO_FYI');
              END IF;
         ELSIF (l_po_style_type='COMPLEX') THEN

	       OPEN c_old_ship_amt_cw(l_po_header_id);
	             LOOP
	      	     FETCH c_old_ship_amt_cw
	             INTO l_old_ship_amt,l_line_location_id;
	             x_progress := 'SHIP_AMOUNT_WITHIN_TOL:006';
	             log_message('SHIP_AMOUNT_WITHIN_TOL','Old Ship Amount',l_old_ship_amt);
	             EXIT WHEN (l_return_val='N');
                     EXIT WHEN c_old_ship_amt_cw%NOTFOUND;

	             l_new_ship_amt := CALCULATE_NEW_SHIP_AMOUNT(l_po_header_id,l_po_release_id,l_line_location_id,'N',l_po_style_type,null);

	             x_progress := 'SHIP_AMOUNT_WITHIN_TOL:007';
	             IF (NOT change_within_tol(l_old_ship_amt, l_new_ship_amt, l_shipamt_max_incr_per, l_shipamt_max_dec_per,l_shipamt_max_incr_val   , l_shipamt_max_dec_val)) THEN
                         l_return_val := 'N';
                     END IF;
                     x_progress := 'SHIP_AMOUNT_WITHIN_TOL:009';
                     log_message('SHIP_AMOUNT_WITHIN_TOL','Result',l_return_val);
                     END LOOP;
	        CLOSE  c_old_ship_amt_cw;

	        IF (l_return_val = 'Y') THEN
                    wf_engine.SetItemAttrText( itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'NOTIF_USAGE',
                                               avalue     => 'BUYER_AUTO_FYI');
                END IF;

         END IF; -- PO Or RELEASE or complex work POs
      END IF;  -- l_doc_type PO or RELEASE
        -- set result value
      resultout := wf_engine.eng_completed|| ':' || l_return_val ;
   END IF; -- change_group_id is not null
        x_progress :=  'SHIP_AMOUNT_WITHIN_TOL:016';
        log_message('SHIP_AMOUNT_WITHIN_TOL','Result',resultout);
 END IF; -- IF ( funcmode = 'RUN' )
EXCEPTION
  WHEN OTHERS THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;
  wf_core.context('POSCHORD', 'SHIP_AMOUNT_WITHIN_TOL', itemtype, itemkey, to_char(actid),funcmode);
  raise;
END SHIP_AMOUNT_WITHIN_TOL;


FUNCTION CALCULATE_NEW_SHIP_AMOUNT( p_po_header_id         IN NUMBER,
                                    p_po_release_id        IN NUMBER,
                                    p_line_location_id     IN NUMBER,
                                    p_split_flag           IN VARCHAR2,
				    p_po_style_type        IN VARCHAR2,
                                    p_po_shipment_num      IN NUMBER)
RETURN NUMBER
IS

--- picks up new shipment amount for SPO
CURSOR c_new_shipment_amount (p_po_header_id_csr IN NUMBER,p_line_location_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
    SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', (nvl(pcr1.new_amount,pll.amount) - nvl(pll.amount_cancelled,0)),
            (nvl(pcr.new_price,pl.unit_price) *
            (nvl(pcr1.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
            FROM    po_change_requests pcr, --line amount/price change
   	 	 po_change_requests pcr1, --shipment quantity change
   	 	 po_lines_all pl,
   	 	 po_line_locations_all pll
            WHERE   pl.po_header_id = p_po_header_id_csr
                 AND pll.line_location_id = p_line_location_id_csr
   	 	 AND pll.po_line_id = pl.po_line_id
                    AND pcr1.document_header_id (+) = p_po_header_id_csr
                    AND pcr1.document_line_location_id(+) = pll.line_location_id
   	         AND pcr1.action_type(+) = 'MODIFICATION'
   	         AND pcr1.request_status(+) = req_status
   	         AND pcr1.request_level (+) = 'SHIPMENT'
   	         AND pcr1.initiator(+) = req_initiator
                    AND pcr.document_line_id(+) = pl.po_line_id
   	         AND pcr.action_type(+) = 'MODIFICATION'
   	         AND pcr.request_status(+) = req_status
   	         AND pcr.request_level (+) = 'LINE'
   	         AND pcr.initiator(+) =  req_initiator;

CURSOR c_new_shipment_amount_split (p_po_header_id_csr IN NUMBER,p_line_location_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR,p_po_shipment_num IN NUMBER) IS
     -- for splitted shipments
    SELECT   nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount,pll.amount),
             (nvl(pcr.new_price,pl.unit_price) * pcr2.new_quantity))),0)
            FROM    po_change_requests pcr, --line amount/price change
   		 po_change_requests pcr2, --for split shipments
   	 	 po_lines_all pl,
   	 	 po_line_locations_all pll
            WHERE   pl.po_header_id = p_po_header_id_csr
                 AND pll.line_location_id = p_line_location_id_csr
   	 	 AND pll.po_line_id = pl.po_line_id
                    AND pcr2.document_header_id = p_po_header_id_csr
                    AND pcr2.parent_line_location_id = pll.line_location_id
   	         AND pcr2.action_type = 'MODIFICATION'
   	         AND pcr2.request_status = req_status
   	         AND pcr2.request_level  = 'SHIPMENT'
   	         AND pcr2.initiator =  req_initiator
                 AND pcr2.document_shipment_number = p_po_shipment_num
                    AND pcr.document_line_id(+) = pl.po_line_id
   	         AND pcr.action_type(+) = 'MODIFICATION'
   	         AND pcr.request_status(+) =  req_status
   	         AND pcr.request_level (+) =  'LINE'
	         AND pcr.initiator(+) =  req_initiator;

--- picks up new shipment amount for releses
-- old_price is included for price breaks
CURSOR c_new_shipment_amount_rel(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER, p_line_location_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR) IS
   SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', (nvl(pcr.new_amount, pll.amount) - nvl(pll.amount_cancelled,0)),
			  (nvl(nvl(pcr.new_price,pcr.old_price),pll.price_override) *
			   (nvl(pcr.new_quantity,pll.quantity) - nvl(pll.quantity_cancelled,0))))),0)
    	FROM    po_change_requests pcr,
    		po_lines_all pl,
    		po_line_locations_all pll
    	WHERE  pll.po_header_id = p_po_header_id_csr
    	       AND pll.line_location_id = p_line_location_id_csr
	       AND pll.po_release_id = p_po_release_id_csr
    	       AND pll.po_line_id = pl.po_line_id
    	      -- AND pcr.po_release_id = p_po_release_id_csr
    	       AND pcr.document_header_id(+) = p_po_header_id_csr
    	       AND pcr.document_line_id = pl.po_line_id
    	       AND pcr.action_type(+) = 'MODIFICATION'
    	       AND pcr.request_status(+) = req_status
    	       AND pcr.request_level (+) = 'SHIPMENT'
    	       AND pcr.initiator(+) = req_initiator
    	       AND pcr.document_line_location_id(+) = pll.line_location_id;

CURSOR c_new_ship_amt_rel_split(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER, p_line_location_id_csr IN NUMBER,req_status IN VARCHAR,req_initiator IN VARCHAR,p_po_shipment_num IN NUMBER) IS
    SELECT  nvl(sum(decode(pl.matching_basis, 'AMOUNT', nvl(pcr2.new_amount, pll.amount), (nvl(nvl(pcr2.new_price,pcr2.old_price),pll.price_override) * nvl(pcr2.new_quantity,pll.quantity)))),0)
    	FROM    po_change_requests pcr2, -- for splitted shipments
    		po_lines_all pl,
    		po_line_locations_all pll
    	WHERE  pll.po_header_id = p_po_header_id_csr
    	       AND pll.line_location_id = p_line_location_id_csr
    	       AND pll.po_line_id = pl.po_line_id
    	       AND pcr2.po_release_id = p_po_release_id_csr
    	       AND pcr2.document_header_id(+) = p_po_header_id_csr
    	       AND pcr2.document_line_id(+) = pl.po_line_id
    	       AND pcr2.action_type(+) = 'MODIFICATION'
    	       AND pcr2.request_status(+)=  req_status
    	       AND pcr2.request_level (+) = 'SHIPMENT'
    	       AND pcr2.initiator(+) = req_initiator
    	       AND pcr2.parent_line_location_id = pll.line_location_id
               AND pcr2.document_shipment_number = p_po_shipment_num;

-- Picks up New Shipment Amount for complex work Po's (Actuals And Financing Case)
CURSOR c_new_shipment_amount_cw (p_po_header_id_csr IN NUMBER,p_line_location_id_csr IN NUMBER) IS
    select NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                         (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                        'AMOUNT',
                   DECODE(pll.payment_type, 'LUMPSUM',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'MILESTONE',
                                         (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                        'RATE',
                                         (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
    FROM
        po_change_requests pcr, --shipment quantity changes
        po_lines_all pl,
        po_line_locations_all pll
    WHERE
        pl.po_header_id = p_po_header_id_csr
        AND pll.line_location_id = p_line_location_id_csr
        AND pll.po_line_id = pl.po_line_id
        AND pcr.document_header_id (+) = p_po_header_id_csr
        AND pcr.document_line_location_id(+) = pll.line_location_id
        AND pcr.action_type(+) = 'MODIFICATION'
        AND pcr.request_status(+) = 'PENDING'
        AND pcr.request_level (+) = 'SHIPMENT'
        AND pcr.initiator(+) = 'SUPPLIER';

-- Picks up New Shipment Amount for complex work Po's (Actuals And Financing Case) for split cases
CURSOR c_new_shipment_amount_split_cw (p_po_header_id_csr IN NUMBER,p_line_location_id_csr IN NUMBER,p_po_shipment_num IN NUMBER) IS
    select NVL(SUM(DECODE(pl.matching_basis,'QUANTITY',
                                            (pll.quantity - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override)),
                                            'AMOUNT',
                   DECODE(nvl(pcr.new_progress_type,pll.payment_type), 'LUMPSUM',
                                                                       (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                       'MILESTONE',
                                                                       (nvl(pcr.new_amount,pll.amount) -  NVL(pll.amount_cancelled,0)),
                                                                       'RATE',
                                                                       (nvl(pcr.new_quantity,pll.quantity) - NVL(pll.quantity_cancelled,0))*(nvl(pcr.new_price,pll.price_override))))),0)
    FROM
       po_change_requests pcr, --shipment quantity changes
       po_lines_all pl,
       po_line_locations_all pll
    WHERE
       pl.po_header_id = p_po_header_id_csr
       AND pll.line_location_id = p_line_location_id_csr
       AND pll.po_line_id = pl.po_line_id
       AND pcr.document_header_id  = p_po_header_id_csr
       AND pcr.parent_line_location_id = pll.line_location_id
       AND pcr.action_type = 'MODIFICATION'
       AND pcr.request_status = 'PENDING'
       AND pcr.request_level  = 'SHIPMENT'
       AND pcr.initiator = 'SUPPLIER'
       AND pcr.document_shipment_number = p_po_shipment_num;

l_new_ship_amt          NUMBER;
x_progress             VARCHAR2(1000);
req_status              po_change_requests.request_status%TYPE;
req_initiator           po_change_requests.initiator%TYPE;

BEGIN
  /* Code Changes for Bug - 11794109 Start */
  BEGIN

    IF(p_po_release_id is null) THEN
        select distinct request_status ,initiator into req_status,req_initiator from po_change_requests
        where document_header_id=p_po_header_id AND document_type = 'PO'
              and change_active_flag='Y'
              and rownum=1;
    ELSE
        select distinct request_status ,initiator into req_status,req_initiator from po_change_requests
        where document_header_id=p_po_header_id AND document_type = 'RELEASE'
              and po_release_id = p_po_release_id
              and change_active_flag='Y'
              and rownum=1;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         l_new_ship_amt := 0;
         return   l_new_ship_amt;
  END;
  /* Code Changes for Bug - 11794109 End */

   IF(p_po_release_id is null) THEN
     IF(p_split_flag = 'N') THEN
       IF(p_po_style_type = 'NORMAL') THEN
          OPEN c_new_shipment_amount(p_po_header_id,p_line_location_id,req_status,req_initiator);
	   LOOP
	   FETCH c_new_shipment_amount INTO  l_new_ship_amt;
	   EXIT WHEN c_new_shipment_amount%NOTFOUND;
	   END LOOP;
          CLOSE   c_new_shipment_amount;
       ELSIF(p_po_style_type = 'COMPLEX') THEN
          OPEN c_new_shipment_amount_cw(p_po_header_id,p_line_location_id);
	   LOOP
	   FETCH c_new_shipment_amount_cw INTO  l_new_ship_amt;
	   EXIT WHEN c_new_shipment_amount_cw%NOTFOUND;
	   END LOOP;
          CLOSE   c_new_shipment_amount_cw;
       END IF;
     ELSIF(p_split_flag = 'Y') THEN
       IF(p_po_style_type = 'NORMAL') THEN
         OPEN c_new_shipment_amount_split(p_po_header_id,p_line_location_id,req_status,req_initiator,p_po_shipment_num);
          LOOP
          FETCH c_new_shipment_amount_split INTO  l_new_ship_amt;
          EXIT WHEN c_new_shipment_amount_split%NOTFOUND;
          END LOOP;
         CLOSE   c_new_shipment_amount_split;
       ELSIF(p_po_style_type = 'COMPLEX') THEN
          OPEN c_new_shipment_amount_split_cw(p_po_header_id,p_line_location_id,p_po_shipment_num);
          LOOP
          FETCH c_new_shipment_amount_split_cw INTO  l_new_ship_amt;
          EXIT WHEN c_new_shipment_amount_split_cw%NOTFOUND;
          END LOOP;
         CLOSE   c_new_shipment_amount_split_cw;
       END IF;
     END IF;
   ELSIF( p_po_release_id is not null) THEN
     IF(p_split_flag = 'N') THEN
       OPEN c_new_shipment_amount_rel(p_po_header_id,p_po_release_id,p_line_location_id,req_status,req_initiator);
       	 LOOP
       	 FETCH c_new_shipment_amount_rel INTO  l_new_ship_amt;
       	 EXIT WHEN c_new_shipment_amount_rel%NOTFOUND;
       	 END LOOP;
       CLOSE   c_new_shipment_amount_rel;
     ELSIF (p_split_flag = 'Y') THEN
        OPEN c_new_ship_amt_rel_split(p_po_header_id,p_po_release_id,p_line_location_id,req_status,req_initiator,p_po_shipment_num);
         LOOP
         FETCH c_new_ship_amt_rel_split INTO  l_new_ship_amt;
         EXIT WHEN c_new_ship_amt_rel_split%NOTFOUND;
         END LOOP;
        CLOSE   c_new_ship_amt_rel_split;
     END IF;
    END IF;

   return   l_new_ship_amt;

  EXCEPTION
    WHEN OTHERS THEN
      IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                               g_module_prefix,
                               x_progress || ':unexpected error' || Sqlerrm);
      END IF;
  raise;
END CALCULATE_NEW_SHIP_AMOUNT;

FUNCTION CHANGE_WITHIN_TOL( p_oldValue         IN NUMBER,
	                    p_newValue         IN NUMBER,
	                    p_maxIncrement_per IN NUMBER,
	                    p_maxDecrement_per IN NUMBER,
	                    p_maxIncrement_val IN NUMBER,
	                    p_maxDecrement_val IN NUMBER)
RETURN boolean

IS

  l_changePercent NUMBER;
  l_changeValue   NUMBER;
  x_progress varchar2(1000);

BEGIN

   x_progress := 'CHANGE_WITHIN_TOL:000';
   -- First Check whether Buyer has Set Tolerance Values or Not( If Not Set Then No Auto-Approval)
   /* bug 9884700 , Consider p_oldValue=0 condition also */
IF((p_oldValue >= 0) AND (p_newValue > 0)) THEN
  IF((p_newValue > p_oldValue) AND (nvl(p_maxIncrement_per,0) = 0 AND nvl(p_maxIncrement_val,0) = 0)) THEN
   return FALSE;
  ELSIF((p_newValue < p_oldValue) AND (nvl(p_maxDecrement_per,0) = 0 AND nvl(p_maxDecrement_val,0) = 0)) THEN
   return FALSE;
  END IF;
END IF;
  x_progress := 'CHANGE_WITHIN_TOL:001';
  IF (p_oldValue <> p_newValue) THEN
      IF (p_oldValue >= 0 AND p_newValue > 0) THEN
      --- Checking for the Value change
         l_changeValue := abs(p_oldValue - p_newValue);
	 x_progress := 'CHANGE_WITHIN_TOL:002';
	 -- value has increased
          IF (p_maxIncrement_val <> 0 AND p_oldValue < p_newValue) THEN
	      IF(l_changeValue > p_maxIncrement_val) THEN
		  return FALSE;
	      END IF;
	  END IF;
	 -- value has decreased
          IF (p_maxDecrement_val <> 0 AND p_oldValue > p_newValue) THEN
	      IF(l_changeValue > p_maxDecrement_val) THEN
		  return FALSE;
	      END IF;
	  END IF;
       --- Checking for the percentage change
       /* bug 9884700 */
          if p_oldValue=0 then
	  l_changePercent:=p_newValue*100;
          else
	  l_changePercent := ((p_oldValue - p_newValue)/p_oldValue)*100;
	  end if;
	  x_progress := 'CHANGE_WITHIN_TOL:003';
	  -- value has increased
	  IF (p_maxIncrement_per <> 0 AND p_oldValue < p_newValue) THEN
	      IF((abs(l_changePercent)) > p_maxIncrement_per) THEN
	      return FALSE;
	      END IF;
	  END IF;
	 -- value has decreased
          IF (p_maxDecrement_per <> 0 AND p_oldValue > p_newValue) THEN
	      IF(l_changePercent > p_maxDecrement_per) THEN
	         return FALSE;
	      END IF;
	  END IF;
       END IF;
 END IF;

 return TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                             g_module_prefix,
                             x_progress || ':unexpected error' || Sqlerrm);
    END IF;
raise;

END CHANGE_WITHIN_TOL;
------------------------------------------------------------------------------
FUNCTION CHANGE_WITHIN_TOL_DATE(p_oldValue     IN DATE,
		                p_newValue     IN DATE,
                                p_maxIncrement IN NUMBER,
		                p_maxDecrement IN NUMBER)
RETURN boolean

IS
x_progress varchar2(1000);
BEGIN

 x_progress := 'CHANGE_WITHIN_TOL_DATE:000';
 -- First Check whether Buyer has Set Tolerance Values or Not( If Not Set Then No Auto-Approval)
 IF( (p_newValue > p_oldValue) AND (nvl(p_maxIncrement,0) = 0)) THEN
   return FALSE;
 ELSIF( (p_newValue < p_oldValue) AND(nvl(p_maxDecrement,0) = 0)) THEN
   return FALSE;
 END IF;

 x_progress := 'CHANGE_WITHIN_TOL_DATE:001';

  IF(p_oldValue <> p_newValue) THEN

		     -- check for upper tol
			 IF (p_maxIncrement <> 0 AND p_oldValue < p_newValue)THEN
			    IF(p_newValue - p_maxIncrement > p_oldValue) THEN
			      return FALSE;
			    END IF;
		        END IF;

			 -- check for lower tol
			 IF(p_maxDecrement <> 0 AND p_oldValue > p_newValue) THEN
			    IF(p_newValue + p_maxDecrement < p_oldValue) THEN
			      return FALSE;
			    END IF;
			 END IF;
  END IF;

  x_progress := 'CHANGE_WITHIN_TOL_DATE:002';

		  return TRUE;
EXCEPTION
 WHEN OTHERS THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                             g_module_prefix,
                             x_progress || ':unexpected error' || Sqlerrm);
    END IF;
raise;


END CHANGE_WITHIN_TOL_DATE;

PROCEDURE ROUTE_TO_REQUESTER( itemtype        IN VARCHAR2,
 	                      itemkey         IN VARCHAR2,
 	                      actid           IN NUMBER,
 	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2)

IS
 l_return_val            VARCHAR2(1) ;
 l_po_header_id          po_headers_all.po_header_id%TYPE;
 l_change_group_id       po_change_requests.change_request_group_id%type;
 x_progress              VARCHAR2(1000);
 l_po_style_type         VARCHAR2(10);
 l_doc_type               VARCHAR2(10);
 l_doc_subtype            VARCHAR2(10);
 l_prmdate_app_flag       VARCHAR2(10);
 l_shi_qty_app_flag       VARCHAR2(10);
 l_unit_price_app_flag    VARCHAR2(10);

BEGIN
  x_progress := 'ROUTE_TO_REQUESTER:000';
  l_po_header_id      := wf_engine.GetItemAttrNumber (itemtype => itemtype,
  					              itemkey  => itemkey,
  	                                              aname    => 'PO_HEADER_ID');

  l_change_group_id   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
  					              itemkey  => itemkey,
  	                                              aname    => 'CHANGE_REQUEST_GROUP_ID');

  l_po_style_type     :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
      						      itemkey  => itemkey,
      		                                      aname    => 'PO_STYLE_TYPE');

  l_doc_type          :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
      					              itemkey  => itemkey,
      		                                      aname    => 'DOCUMENT_TYPE');

  l_doc_subtype       :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'DOC_SUB_TYPE');

  l_prmdate_app_flag  :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'PROMISE_DATE_APP_FLAG');

  l_shi_qty_app_flag  :=  wf_engine.GetItemAttrText  (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'SHIP_QTY_APPROVAL_FLAG');

  l_unit_price_app_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'PRICE_APPROVAL_FLAG');

  x_progress := 'ROUTE_TO_REQUESTER:001';

IF((l_doc_type = 'PO' AND l_doc_subtype = 'STANDARD') OR (l_doc_type = 'RELEASE' AND l_doc_subtype = 'BLANKET')) THEN


  IF ( ROUTETOREQUESTER ( l_po_header_id,l_change_group_id,l_doc_type,l_prmdate_app_flag,l_shi_qty_app_flag,l_unit_price_app_flag)=TRUE) THEN
     l_return_val:= 'Y' ;
     x_progress := 'ROUTE_TO_REQUESTER:002';
  ELSE
    -- send the notification to buyer
    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'NOTIF_USAGE',
                              avalue => 'BUYER');
     l_return_val:= 'N' ;
     x_progress := 'ROUTE_TO_REQUESTER:003';
   END IF;

ELSE
     wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'NOTIF_USAGE',
                              avalue => 'BUYER');
     l_return_val:= 'N' ;
     x_progress := 'ROUTE_TO_REQUESTER:004';
END IF;
  resultout := wf_engine.eng_completed|| ':' || l_return_val ;
  x_progress := 'ROUTE_TO_REQUESTER:005';
  log_message('ROUTE_TO_REQUESTER','Result',resultout);
EXCEPTION
  WHEN OTHERS THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                            g_module_prefix,
                            x_progress || ':unexpected error' || Sqlerrm);
   END IF;
   wf_core.context('POSCHORD', 'ROUTE_TO_REQUESTER', itemtype, itemkey, to_char(actid),funcmode);
   raise;
END ROUTE_TO_REQUESTER;


FUNCTION ROUTETOREQUESTER (p_po_header_id IN NUMBER ,p_change_group_id IN NUMBER, p_doc_type IN VARCHAR2, p_prm_date_app_flag IN VARCHAR2, p_ship_qty_app_flag IN VARCHAR2, p_unit_price_app_flag IN VARCHAR2)
return boolean is

cursor c_promise_date_changed (p_po_header_id_csr_pd IN NUMBER,p_change_group_id_csr_pd IN NUMBER) is
       select count(1) from po_change_requests pcr
       where pcr.document_header_id=p_po_header_id_csr_pd
	     AND pcr.change_request_group_id=p_change_group_id_csr_pd
	     AND pcr.new_promised_date IS NOT NULL
	     AND pcr.action_type='MODIFICATION'
	     AND pcr.request_status= 'PENDING'
	     AND pcr.request_level= 'SHIPMENT'
	     AND pcr.initiator= 'SUPPLIER';



cursor c_ship_qty_changed(p_po_header_id_csr IN NUMBER,p_change_group_id_csr IN NUMBER)  is
       select count(1) from po_change_requests pcr
       where  pcr.document_header_id=p_po_header_id_csr
	      AND pcr.change_request_group_id=p_change_group_id_csr
	      AND pcr.new_quantity IS NOT NULL
	      AND pcr.action_type='MODIFICATION'
	      AND pcr.request_status= 'PENDING'
	      AND pcr.request_level= 'SHIPMENT'
	      AND pcr.initiator= 'SUPPLIER';


cursor c_price_changed(p_po_header_id_csr IN NUMBER,p_change_group_id_csr IN NUMBER)  is
select count(1) from po_change_requests pcr
where  pcr.document_header_id=p_po_header_id_csr
       AND pcr.change_request_group_id=p_change_group_id_csr
       AND nvl(pcr.new_price,pcr.new_amount) IS NOT NULL
       AND pcr.action_type='MODIFICATION'
       AND pcr.request_status= 'PENDING'
       AND pcr.request_level IN ('LINE','SHIPMENT')
       AND pcr.initiator= 'SUPPLIER';

cursor c_price_changed_rel(p_po_header_id_csr IN NUMBER,p_change_group_id_csr IN NUMBER)  is
select count(1) from po_change_requests pcr
where  pcr.document_header_id = p_po_header_id_csr
       AND pcr.change_request_group_id=p_change_group_id_csr
       AND nvl(pcr.new_price,pcr.new_amount) IS NOT NULL
       AND pcr.action_type='MODIFICATION'
       AND pcr.request_status= 'PENDING'
       AND pcr.request_level= 'SHIPMENT'
       AND pcr.initiator= 'SUPPLIER';

l_progress varchar2(50) := '000';
l_promise_date_changed number;
l_ship_qty_changed     number;
l_price_changed        number;
l_ret_val              varchar2(10) := 'N';
l_ret_val_prom_date_ch              varchar2(10) := 'N';
l_ret_val_ship_qty_ch              varchar2(10) := 'N';
l_ret_val_line_price_ch              varchar2(10) := 'N';
l_ret_val_ship_price_ch              varchar2(10) := 'N';
l_api_name varchar2(50) := 'ROUTE_TO_REQUESTER';
x_progress varchar2(1000);


BEGIN
     x_progress := 'ROUTETOREQUESTER:000';
     -- Checking whether there is a promise data change
    log_message('ROUTETOREQUESTER','Checking for Promise Date Changes','.');

     OPEN c_promise_date_changed(p_po_header_id ,p_change_group_id ) ;
        FETCH c_promise_date_changed INTO l_promise_date_changed;
        log_message('ROUTETOREQUESTER','l_promise_date_changed',l_promise_date_changed);

        IF ( l_promise_date_changed >= 1) THEN
           CLOSE c_promise_date_changed;
           x_progress := 'ROUTETOREQUESTER:001';
           log_message('ROUTETOREQUESTER','Promise Date Changed','Yes');
            IF( p_prm_date_app_flag = 'Y') THEN
	            log_message('ROUTETOREQUESTER','Promise Date Changed Retrun Value','Yes');
              l_ret_val_prom_date_ch := 'Y';
	            ELSE
              log_message('ROUTETOREQUESTER','Promise Date Changed Retrun Value','No');
	            l_ret_val_prom_date_ch := 'N';
	          END IF;
        END IF;

     IF c_promise_date_changed%ISOPEN THEN
        CLOSE c_promise_date_changed;
     END IF;

     log_message('ROUTETOREQUESTER','Checking for Ship Qty Changes','.');

     -- Checking whether there is a Shipment quantity  change

     OPEN c_ship_qty_changed(p_po_header_id ,p_change_group_id );
        FETCH c_ship_qty_changed INTO l_ship_qty_changed;
        log_message('ROUTETOREQUESTER','l_ship_qty_changed',l_ship_qty_changed);
        IF (l_ship_qty_changed >= 1) THEN
           CLOSE c_ship_qty_changed;
           x_progress := 'ROUTETOREQUESTER:002';
           log_message('ROUTETOREQUESTER','Ship Qty changed','Yes');
           IF( p_ship_qty_app_flag = 'Y') THEN
              log_message('ROUTETOREQUESTER','Shipment Qty Retrun Value','Yes');
	            l_ret_val_ship_qty_ch := 'Y';
	         ELSE
              log_message('ROUTETOREQUESTER','Shipment Qty Retrun Value','No');
	            l_ret_val_ship_qty_ch := 'N';
	         END IF;
        END IF;

     IF c_ship_qty_changed%ISOPEN THEN
        CLOSE c_ship_qty_changed;
     END IF;

     -- Checking whether there is a Line price change
    log_message('ROUTETOREQUESTER','Checking for Line Price Changes','.');


    IF ( p_doc_type = 'PO') THEN
      OPEN c_price_changed(p_po_header_id ,p_change_group_id );
      FETCH c_price_changed INTO l_price_changed;
      log_message('ROUTETOREQUESTER','l_price_changed',l_price_changed);
        IF(l_price_changed >= 1) THEN
           CLOSE c_price_changed;
           x_progress := 'ROUTETOREQUESTER:003';
           log_message('ROUTETOREQUESTER','Line Price Changed','Yes');
           IF( p_unit_price_app_flag = 'Y') THEN
               log_message('ROUTETOREQUESTER','Line Price Return Value','Yes');
	             l_ret_val_line_price_ch := 'Y';
	         ELSE
               log_message('ROUTETOREQUESTER','Line Price Return Value','No');
	             l_ret_val_line_price_ch := 'N';
	        END IF;
       END IF;

      IF c_price_changed%ISOPEN THEN
          CLOSE c_price_changed;
      END IF;
   log_message('ROUTETOREQUESTER','Checking for Shipment Price Changes','.');


   ELSIF( p_doc_type = 'RELEASE') THEN
       OPEN c_price_changed_rel(p_po_header_id ,p_change_group_id );
       FETCH c_price_changed_rel INTO l_price_changed;
       log_message('ROUTETOREQUESTER','l_price_changed',l_price_changed);
          IF(l_price_changed >= 1) THEN
             CLOSE c_price_changed_rel;
             x_progress := 'ROUTETOREQUESTER:004';
             log_message('ROUTETOREQUESTER','Shipment Price Changed','Yes');
	           IF(p_unit_price_app_flag = 'Y') THEN
                 log_message('ROUTETOREQUESTER','Shipment Price Return Value','Yes');
	               l_ret_val_ship_price_ch := 'Y';
             ELSE
                 log_message('ROUTETOREQUESTER','Shipment Price Return Value','No');
	               l_ret_val_ship_price_ch := 'N';
	          END IF;
          END IF;

       IF c_price_changed_rel%ISOPEN THEN
           CLOSE c_price_changed_rel;
       END IF;

   END IF; -- END ELSIF

  x_progress := 'ROUTETOREQUESTER:005';
  IF(l_ret_val_line_price_ch = 'Y' OR l_ret_val_ship_qty_ch = 'Y' OR l_ret_val_prom_date_ch = 'Y' OR l_ret_val_ship_price_ch = 'Y')
  THEN
  l_ret_val := 'Y';
  ELSE
  l_ret_val := 'N';
  END IF;
  log_message('ROUTETOREQUESTER','l_ret_val - ',l_ret_val);
  log_message('ROUTETOREQUESTER','l_ret_val_line_price_ch - ',l_ret_val_line_price_ch);
  log_message('ROUTETOREQUESTER','l_ret_val_ship_qty_ch - ',l_ret_val_ship_qty_ch);
  log_message('ROUTETOREQUESTER','l_ret_val_prom_date_ch - ',l_ret_val_prom_date_ch);

  IF( l_ret_val = 'Y') THEN
    log_message('ROUTETOREQUESTER','Returning - ','True');
    return TRUE;
  ELSIF(l_ret_val = 'N') THEN
    log_message('ROUTETOREQUESTER','Returning - ','False');
    return FALSE;
 ELSE RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                            g_module_prefix,
                            x_progress || ':unexpected error' || Sqlerrm);
   END IF;
 raise;
END ROUTETOREQUESTER;




PROCEDURE ROUTE_SCO_BIZ_RULES( itemtype        IN VARCHAR2,
 	                       itemkey         IN VARCHAR2,
 	                       actid           IN NUMBER,
 	                       funcmode        IN VARCHAR2,
                               resultout       OUT NOCOPY VARCHAR2)

IS

-- curosr to get the ReqHeaderId
cursor c_getReqHdrId(p_po_header_id_csr IN NUMBER) is
        select distinct porh.requisition_header_id
        from   po_requisition_headers_all porh,
               po_requisition_lines_all porl,
               po_headers_all poh,
               po_line_locations_all poll
        where  porh.requisition_header_id = porl.requisition_header_id AND
               porl.line_location_id = poll.line_location_id  AND
               poh.po_header_id = poll.po_header_id AND
               poh.po_header_id = p_po_header_id_csr;

cursor c_getReqHdrId_r(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
        select distinct porh.requisition_header_id
        from   po_requisition_headers_all porh,
               po_requisition_lines_all porl,
               po_headers_all poh,
               po_line_locations_all poll
        where  porh.requisition_header_id = porl.requisition_header_id AND
               porl.line_location_id = poll.line_location_id  AND
               poh.po_header_id = poll.po_header_id AND
               poh.po_header_id = p_po_header_id_csr AND
               poll.po_release_id = p_po_release_id_csr;

l_po_header_id          po_headers_all.po_header_id%TYPE;
l_po_release_id         po_releases_all.po_release_id%TYPE;
l_doc_type              VARCHAR2(10);
l_return_val            VARCHAR2(1);
l_change_group_id       po_change_requests.change_request_group_id%TYPE;
l_req_hdr_id            po_requisition_headers_all.requisition_header_id%TYPE;
x_progress              VARCHAR2(1000);
l_auto_app_flag         VARCHAR2(1);

BEGIN

x_progress := 'ROUTE_SCO_BIZ_RULES:000';

l_po_header_id     := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                               itemkey  => itemkey,
	                                               aname    => 'PO_HEADER_ID');

l_po_release_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
  					           itemkey  => itemkey,
  	                                           aname    => 'PO_RELEASE_ID');

l_doc_type         := wf_engine.GetItemAttrText   (itemtype => itemtype,
      					           itemkey  => itemkey,
      		                                   aname    => 'DOCUMENT_TYPE');

l_change_group_id  := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'CHANGE_REQUEST_GROUP_ID');

l_auto_app_flag     :=  wf_engine.GetItemAttrText   (itemtype => itemtype,
      					            itemkey   => itemkey,
      		                                    aname     => 'AUTO_APP_BIZ_RULES_FLAG');

  x_progress := 'ROUTE_SCO_BIZ_RULES:001';

IF(l_auto_app_flag = 'Y') THEN

  IF (ROUTE_SCO_BIZ_RULES_CHECK(l_po_header_id,l_po_release_id,l_doc_type,l_change_group_id)=FALSE)  THEN
      l_return_val:= 'N';
      x_progress := 'ROUTE_SCO_BIZ_RULES:002';
      -- Set the Notif Usage for the notification to be sent to Buyer
      wf_engine.SetItemAttrText   (itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'NOTIF_USAGE',
                                   avalue =>'BUYER');
  ELSE
      l_return_val:= 'Y';
      x_progress := 'ROUTE_SCO_BIZ_RULES:003';

       IF( PROMISEDATECHANGE(l_po_header_id,l_change_group_id) = FALSE) THEN    -- lock the corresponding req if there are price or quantity changes

        if l_po_release_id is not null then
          OPEN c_getReqHdrId_r(l_po_header_id,l_po_release_id);
          LOOP
          FETCH c_getReqHdrId_r INTO l_req_hdr_id;
          EXIT WHEN c_getReqHdrId_r%NOTFOUND;
          x_progress:= 'ROUTE_SCO_BIZ_RULES:004';
          log_message('ROUTE_SCO_BIZ_RULES','Locking the Req',l_req_hdr_id);

          update po_requisition_headers_all
          set change_pending_flag = 'Y'
          where requisition_header_id = l_req_hdr_id;

          END LOOP;
          CLOSE c_getReqHdrId_r;

        else
          OPEN c_getReqHdrId(l_po_header_id);
          LOOP
          FETCH c_getReqHdrId INTO l_req_hdr_id;
          EXIT WHEN c_getReqHdrId%NOTFOUND;
          x_progress:= 'ROUTE_SCO_BIZ_RULES:004a';
          log_message('ROUTE_SCO_BIZ_RULES','Locking the Req',l_req_hdr_id);

          update po_requisition_headers_all
          set change_pending_flag = 'Y'
          where requisition_header_id = l_req_hdr_id;

          END LOOP;
          CLOSE c_getReqHdrId;
        end if;

      END IF;

  END IF;

ELSIF( l_auto_app_flag = 'N') THEN
  l_return_val:= 'N';
  -- Set the Notif Usage for the notification to be sent to Buyer
        wf_engine.SetItemAttrText(   itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'NOTIF_USAGE',
                                     avalue =>'BUYER');
END IF;


 resultout := wf_engine.eng_completed|| ':' || l_return_val ;

 x_progress := 'ROUTE_SCO_BIZ_RULES:005';
 log_message('ROUTE_SCO_BIZ_RULES','Result',resultout);


EXCEPTION
  WHEN OTHERS THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
   END IF;
   wf_core.context('POSCHORD', 'ROUTE_SCO_BIZ_RULES', itemtype, itemkey, to_char(actid),funcmode);
   raise;
END ROUTE_SCO_BIZ_RULES;


PROCEDURE AUTO_APP_BIZ_RULES(itemtype        IN VARCHAR2,
   	                     itemkey         IN VARCHAR2,
   	                     actid           IN NUMBER,
   	                     funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2)

IS

l_po_header_id          po_headers_all.po_header_id%TYPE;
l_po_release_id         po_releases_all.po_release_id%TYPE;
l_return_val            VARCHAR2(1);
x_progress              VARCHAR2(1000);
l_po_style_type         VARCHAR2(10);
l_doc_type              VARCHAR2(10);
l_doc_subtype           VARCHAR2(10);

BEGIN
  x_progress := 'AUTO_APP_BIZ_RULES:000';

  l_po_header_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
  					               itemkey  => itemkey,
  	                                               aname    => 'PO_HEADER_ID');

  l_po_release_id     := wf_engine.GetItemAttrNumber  (itemtype => itemtype,
  					               itemkey  => itemkey,
  	                                               aname    => 'PO_RELEASE_ID');

  l_po_style_type     := wf_engine.GetItemAttrText    (itemtype => itemtype,
      					               itemkey  => itemkey,
      		                                       aname    => 'PO_STYLE_TYPE');

  l_doc_type          := wf_engine.GetItemAttrText    (itemtype => itemtype,
      					               itemkey  => itemkey,
      		                                       aname    => 'DOCUMENT_TYPE');

  l_doc_subtype       := wf_engine.GetItemAttrText    (itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'DOC_SUB_TYPE');

  x_progress := 'AUTO_APP_BIZ_RULES:001';

IF((l_doc_type = 'PO' AND l_doc_subtype = 'STANDARD') OR (l_doc_type = 'RELEASE' AND l_doc_subtype = 'BLANKET')) THEN
    IF ( AUTO_APP_BIZ_RULES_CHECK(l_po_header_id,l_po_release_id,l_doc_type)=FALSE) THEN

         wf_engine.SetItemAttrText(     itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname => 'NOTIF_USAGE',
                                        avalue => 'BUYER');

         wf_engine.SetItemAttrText(     itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname => 'AUTO_APP_BIZ_RULES_FLAG',
                                        avalue => 'N');

         x_progress := 'AUTO_APP_BIZ_RULES:002';

         l_return_val:= 'N';
     ELSE
         wf_engine.SetItemAttrText(     itemtype => itemtype,
	                                itemkey => itemkey,
	                                aname => 'AUTO_APP_BIZ_RULES_FLAG',
                                        avalue => 'Y');

         l_return_val:= 'Y';

     END IF;
ELSE
     l_return_val := 'N';
END IF;

  resultout := wf_engine.eng_completed|| ':' || l_return_val ;
  x_progress := 'AUTO_APP_BIZ_RULES:003';

  log_message('AUTO_APP_BIZ_RULES','Result',resultout);

EXCEPTION
 WHEN OTHERS THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;
  wf_core.context('POSCHORD', 'AUTO_APP_BIZ_RULES', itemtype, itemkey, to_char(actid),funcmode);
  raise;
END AUTO_APP_BIZ_RULES;


FUNCTION ROUTE_SCO_BIZ_RULES_CHECK (p_po_header_id IN NUMBER,p_po_release_id IN NUMBER,p_doc_type IN VARCHAR2, p_change_group_id IN NUMBER)
RETURN BOOLEAN
IS

 --  Cursor for Checking for the multipe backing reqs is mapped to the PO

 CURSOR c_reqs_count(p_po_header_id_csr IN NUMBER) is
  SELECT count(distinct porl.requisition_header_id)
  FROM   po_requisition_lines_all porl,  -- <Shared Proc FPJ>
         po_line_locations_all poll
  WHERE  poll.line_location_id = porl.line_location_id AND
         NVL(poll.cancel_flag, 'N') = 'N' AND
         NVL(poll.CLOSEd_code, 'OPEN') <> 'FINALLY CLOSED' AND
         poll.shipment_type IN('STANDARD', 'BLANKET')
         AND poll.po_header_id=p_po_header_id_csr;

  --  Cursor for Checking for the multipe backing reqs is mapped to the releases

 CURSOR c_reqs_count_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
  SELECT count(distinct porl.requisition_header_id)
  FROM   po_requisition_lines_all porl,  -- <Shared Proc FPJ>
         po_line_locations_all poll
  WHERE  poll.line_location_id = porl.line_location_id AND
         NVL(poll.cancel_flag, 'N') = 'N' AND
         NVL(poll.CLOSEd_code, 'OPEN') <> 'FINALLY CLOSED' AND
         poll.shipment_type IN('STANDARD', 'BLANKET')
         AND poll.po_header_id=p_po_header_id_csr
         AND poll.po_release_id = p_po_release_id_csr;


 -- Cursor for checking all shipments should be mappped to one req.

 CURSOR c_req_map_ship(p_po_header_id_csr IN NUMBER) is
 SELECT count(1)
 FROM   po_line_locations_all plla
 WHERE  plla.po_header_id = p_po_header_id_csr
        AND plla.line_location_id NOT IN (SELECT plla2.line_location_id
                                          FROM   po_requisition_lines_all  porla,
                                                 po_line_locations_all plla2
                                          WHERE  plla2.po_header_id = p_po_header_id_csr
                                                 AND porla.line_location_id = plla2.line_location_id);


 -- Cursor for checking all shipments should be mappped to one req for the releases
  CURSOR c_req_map_ship_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) IS
  SELECT count(1)
  FROM   po_line_locations_all plla
  WHERE  plla.po_header_id = p_po_header_id_csr
         AND plla.po_release_id = p_po_release_id_csr
         AND plla.line_location_id NOT IN (   SELECT plla2.line_location_id
                                              FROM   po_requisition_lines_all  porla,
                                                     po_line_locations_all plla2
                                              WHERE  plla2.po_header_id = p_po_header_id_csr
                                              AND    plla2.po_release_id = p_po_release_id_csr
                                              AND    porla.line_location_id = plla2.line_location_id);


 -- Cursor for checking whether there is a price change for Catalog  item.

 cursor c_cat_price_change(p_po_header_id_csr IN NUMBER)  is
        select count(1)
        from   po_change_requests pcr,
	       po_requisition_lines_all porl1,
	       po_line_locations_all pll
        where  pcr.document_header_id = p_po_header_id_csr
               AND pcr.REQUEST_LEVEL = 'LINE'
               AND pcr.new_price is not NULL
               AND pcr.request_status = 'PENDING'
	       AND porl1.line_location_id = pll.line_location_id
	       AND pcr.document_line_id = pll.po_line_id
	       AND porl1.item_id is not null;


-- Curosr for getting the  Releases Price changes for Catlog request should go to the buyer
 cursor c_ship_price_change(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER)  is
        select count(1)
        from   po_change_requests pcr,
	       po_requisition_lines_all porl1,
	       po_line_locations_all pll
        where  pcr.document_header_id = p_po_header_id_csr
	       AND pcr.po_release_id = p_po_release_id_csr
               AND pcr.REQUEST_LEVEL = 'SHIPMENT'
               AND nvl(pcr.new_price,pcr.new_amount) is not NULL   -- NEW_AMOUNT in case of FPS
               AND pcr.request_status = 'PENDING'
	       AND pcr.document_line_location_id = porl1.line_location_id
	       AND porl1.line_location_id = pll.line_location_id
	       AND porl1.item_id is NOT NULL;

-- Cursor for checking the FPS price changes for catalog requests
cursor c_fps_price_change(p_po_header_id_csr IN NUMBER) IS
    select count(1)
        from   po_change_requests pcr,
	       po_requisition_lines_all porl1,
	       po_line_locations_all pll
	where  pcr.document_header_id = p_po_header_id_csr
	       AND pcr.REQUEST_LEVEL = 'SHIPMENT'
               AND pcr.new_amount is not NULL
               AND pcr.request_status = 'PENDING'
  	       AND pcr.document_line_location_id = porl1.line_location_id
	       AND porl1.line_location_id = pll.line_location_id
	       AND porl1.item_id IS NOT NULL;


-- Check whether that Requisition is Locked or not

 cursor c_req_locks(p_po_header_id_csr IN NUMBER) is
        select count(1)
        from   po_requisition_headers_all porh,
               po_requisition_lines_all porl,
               po_headers_all poh,
               po_line_locations_all poll
        where  porh.requisition_header_id = porl.requisition_header_id AND
               porl.line_location_id = poll.line_location_id  AND
               poh.po_header_id = poll.po_header_id AND
               poh.po_header_id = p_po_header_id_csr AND
               porh.change_pENDing_flag = 'Y' ;


 -- Check whether that Requisition is Locked or not for the releases

 cursor c_req_locks_rel(p_po_header_id_csr IN NUMBER, p_po_release_id_csr IN NUMBER) is
        select count(1)
        from   po_requisition_headers_all porh,
               po_requisition_lines_all porl,
               po_headers_all poh,
               po_line_locations_all poll
        where  porh.requisition_header_id = porl.requisition_header_id AND
               porl.line_location_id = poll.line_location_id  AND
               poh.po_header_id = poll.po_header_id AND
               poh.po_header_id = p_po_header_id_csr AND
               poll.po_release_id = p_po_release_id_csr AND
               porh.change_pENDing_flag = 'Y' ;

  --Cursor to test whether changes are done on lines from multiple requesters
   CURSOR l_requestors_csr(c_grp_id_csr IN NUMBER)
  IS
  select UNIQUE(pda.deliver_to_person_id)
  from
  	po_change_requests pcr,
  	po_distributions_all pda
  where pcr.change_request_group_id = c_grp_id_csr
  AND pcr.request_level = 'LINE'
  AND pcr.document_line_id = pda.po_line_id
  and pda.deliver_to_person_id is not null
  union
  select UNIQUE(pda.deliver_to_person_id)
  from
  	po_change_requests pcr,
  	po_distributions_all pda
  where pcr.change_request_group_id = c_grp_id_csr
  AND pcr.request_level = 'SHIPMENT'
  AND pcr.document_line_location_id = pda.line_location_id
  AND pda.deliver_to_person_id is not null;



 -- Check whether there is a quantity change from a shipment which is made up of two dIFferent req lines

 -- will be taken care of INIsProrateNeeded function

 l_backing_req_count  number;
 l_catp_change_count  number;
 l_fps_change_count   number;
 l_ship_change_count  number;
 l_req_lock_cnt       number;
 l_temp_line_loc_id   number;
 l_ship_map           number;
 l_api_name           varchar2(50) := 'ROUTE_SCO_BIZ_RULES_FUNC';
 x_progress           varchar2(1000);

 l_change_group_id NUMBER;
 l_requester_id NUMBER;
 l_count_req NUMBER;

 BEGIN

 x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:000';

 --Bug 11732340
--Check for unique requestor
    l_count_req := 0;
    OPEN l_requestors_csr(p_change_group_id);
    LOOP
	 FETCH l_requestors_csr INTO l_requester_id;
     EXIT WHEN l_requestors_csr%NOTFOUND;
     l_count_req := l_count_req + 1;
    END LOOP;

    close l_requestors_csr;

    IF(l_count_req <> 1)
    THEN
        RETURN FALSE;
    END IF;




 --- Po should have one backing req and all shipments should be mapped to the req line
 IF(p_doc_type = 'PO') THEN
              /*OPEN c_reqs_count(p_po_header_id);
              FETCH c_reqs_count INTO l_backing_req_count;

              x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:001';
              log_message('ROUTE_SCO_BIZ_RULES_CHECK','Backing Req Count',l_backing_req_count);

              IF ((l_backing_req_count > 1) or (l_backing_req_count = 0)) THEN
                  CLOSE c_reqs_count;
                  return FALSE;
              ELSIF (l_backing_req_count = 1) THEN
                  OPEN c_req_map_ship(p_po_header_id);
                  FETCH c_req_map_ship INTO l_ship_map;
                  x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:002';
                  log_message('ROUTE_SCO_BIZ_RULES_CHECK','Shipment Mapped',l_ship_map);
                  IF (l_ship_map >= 1) THEN
 		     CLOSE c_req_map_ship;
 	             return FALSE;
                  END IF;
 	          CLOSE c_req_map_ship;
              END IF;

              IF c_req_map_ship%ISOPEN THEN
                CLOSE c_req_map_ship;
              END IF;
              IF c_reqs_count%ISOPEN THEN
                 CLOSE c_reqs_count;
              END IF;    */

  x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:003';
  ---- Price changes for NCR should go to the buyer

             OPEN c_cat_price_change(p_po_header_id);
             FETCH c_cat_price_change INTO l_catp_change_count;
             log_message('ROUTE_SCO_BIZ_RULES_CHECK','Cat Price Change Count',l_catp_change_count);
             IF (l_catp_change_count >= 1)  THEN
               CLOSE c_cat_price_change;
               return FALSE;
             END IF;

             IF c_cat_price_change%ISOPEN THEN
                 CLOSE c_cat_price_change;
             END IF;

 ---- FPS Price Changes for NCR should go to the buyer
             OPEN c_fps_price_change(p_po_header_id);
             FETCH c_fps_price_change INTO l_fps_change_count;
             log_message('ROUTE_SCO_BIZ_RULES_CHECK','Cat Price Change Count',l_fps_change_count);
             IF (l_fps_change_count >= 1)  THEN
               CLOSE c_fps_price_change;
               return FALSE;
             END IF;

             IF c_fps_price_change%ISOPEN THEN
                 CLOSE c_fps_price_change;
             END IF;

  x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:004';
  --- Check whether Requisition is locked or not if the SCO involves more than Promise Date change

             OPEN c_req_locks(p_po_header_id);
             FETCH c_req_locks INTO l_req_lock_cnt;
             log_message('ROUTE_SCO_BIZ_RULES_CHECK','Req Lock Count',l_req_lock_cnt);

             IF( PROMISEDATECHANGE(p_po_header_id,p_change_group_id) = FALSE) THEN
                IF(l_req_lock_cnt >= 1) THEN
                   CLOSE c_req_locks;
                   log_message('ROUTE_SCO_BIZ_RULES_CHECK','Req Locking Biz Rule','Failed');
                   return FALSE;
                END IF;
             END IF;
             IF c_req_locks%ISOPEN THEN
                 CLOSE c_req_locks;
             END IF;

  x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:005';

  return TRUE;


ELSIF(p_doc_type = 'RELEASE') THEN
            --- Po should have one backing req and all shipments should be mapped to the req line
           /* x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:006';
            OPEN c_reqs_count_rel(p_po_header_id,p_po_release_id);
            FETCH c_reqs_count_rel INTO l_backing_req_count;
            x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:007';
            log_message('ROUTE_SCO_BIZ_RULES_CHECK','Backing Req Count',l_backing_req_count);

            IF ((l_backing_req_count > 1) or (l_backing_req_count = 0)) THEN
                CLOSE c_reqs_count_rel;
                return FALSE;

            ELSIF l_backing_req_count = 1 THEN
                OPEN c_req_map_ship_rel(p_po_header_id,p_po_release_id);
                FETCH c_req_map_ship_rel INTO l_ship_map;
                x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:008';
                log_message('ROUTE_SCO_BIZ_RULES_CHECK','Shipment Mapped',l_ship_map);
                IF l_ship_map >= 1 THEN
 		   CLOSE c_req_map_ship_rel;
 	           return FALSE;
                END IF;
 	        CLOSE c_req_map_ship_rel;
    	    END IF;

            IF c_req_map_ship_rel%ISOPEN THEN
                CLOSE c_req_map_ship_rel;
            END IF;
            IF c_reqs_count_rel%ISOPEN THEN
                CLOSE c_reqs_count_rel;
            END IF;          */

--- Ship Price Changes for the NCR releases should go to the buyer
        OPEN c_ship_price_change(p_po_header_id,p_po_release_id);
             FETCH c_ship_price_change INTO l_ship_change_count;
             log_message('ROUTE_SCO_BIZ_RULES_CHECK','Cat Price Change Count',l_ship_change_count);
             IF (l_ship_change_count >= 1)  THEN
               CLOSE c_ship_price_change;
               return FALSE;
             END IF;

             IF c_ship_price_change%ISOPEN THEN
                 CLOSE c_ship_price_change;
             END IF;



 x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:009';
  --- Check whether Requisition is locked or not if the SCO involves more than Promise Date change

            OPEN c_req_locks_rel(p_po_header_id,p_po_release_id);
            FETCH c_req_locks_rel INTO l_req_lock_cnt;
            log_message('ROUTE_SCO_BIZ_RULES_CHECK','Req Lock Count',l_req_lock_cnt);

            IF( PROMISEDATECHANGE(p_po_header_id,p_change_group_id) = FALSE) THEN
                IF(l_req_lock_cnt >= 1) THEN
                   CLOSE c_req_locks_rel;
                   log_message('ROUTE_SCO_BIZ_RULES_CHECK','Req Locking Biz Rule','Failed');
                   return FALSE;
                END IF;
            END IF;
            IF c_req_locks_rel%ISOPEN THEN
                 CLOSE c_req_locks_rel;
            END IF;

  x_progress := 'ROUTE_SCO_BIZ_RULES_CHECK:010';

  return TRUE;
END IF;  -- IF p_doc_type = PO or RELEASE
RETURN TRUE;
EXCEPTION
 WHEN OTHERS THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         x_progress || ':unexpected error' || Sqlerrm);
  END IF;
  raise;
END ROUTE_SCO_BIZ_RULES_CHECK;

------------------------------------------------------------------------------


FUNCTION AUTO_APP_BIZ_RULES_CHECK (p_po_header_id IN NUMBER,p_po_release_id IN NUMBER,p_doc_type IN VARCHAR2)
return boolean

IS

-- Split shipment check

  cursor c_split_ships(p_po_header_id_csr IN NUMBER) is
         select count(1)
         from   po_change_requests
         where  parent_line_location_id is not null
         AND    action_type = 'MODIFICATION'
         AND    document_header_id = p_po_header_id_csr
         AND    request_level = 'SHIPMENT'
         AND    request_status = 'PENDING';


-- Split shipment check for releses
  cursor c_split_ships_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
           select count(1)
           from   po_change_requests
           where  parent_line_location_id is not null
           AND    action_type = 'MODIFICATION'
           AND    document_header_id = p_po_header_id_csr
           AND    po_release_id      = p_po_release_id_csr
           AND    request_level = 'SHIPMENT'
           AND    request_status = 'PENDING';

--   Cancellation request should go to buyer

  cursor c_cancel_requests(p_po_header_id_csr IN NUMBER) is
         SELECT count(1)
         from   po_change_requests
         where  action_type = 'CANCELLATION'
         AND    request_status = 'PENDING'
         AND    document_header_id = p_po_header_id_csr;


--   Cancellation request should go to buyer for the releases
  cursor c_cancel_requests_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
           SELECT count(1)
           from   po_change_requests
           where  action_type = 'CANCELLATION'
           AND    request_status = 'PENDING'
           AND    document_header_id = p_po_header_id_csr
           AND    po_release_id    =   p_po_release_id_csr;


--Additional Change Request  the unstructured change request

  cursor c_add_changes(p_po_header_id_csr IN NUMBER) is
        select count(1)
        from   po_change_requests
        where  action_type = 'MODIFICATION'
        AND    ADDITIONAL_CHANGES is not NULL
        AND    request_status = 'PENDING'
        AND    document_header_id = p_po_header_id_csr;

--Additional Change Request  the unstructured change request for the releases
  cursor c_add_changes_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
        select count(1)
        from   po_change_requests
        where  action_type = 'MODIFICATION'
        AND    ADDITIONAL_CHANGES is not NULL
        AND    request_level = 'HEADER'
        AND    request_status = 'PENDING'
        AND    document_header_id = p_po_header_id_csr
        AND    po_release_id    =   p_po_release_id_csr;




-- SCO created during Acknowledgement AND the supplier has rejected at least one shipment
-- Cursor for checking whether sco is created during Acknowledgement or not.
  cursor c_sco_ack_ship(p_po_header_id_csr IN NUMBER) is
  SELECT acceptance_required_flag,revision_num
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id_csr;

-- Cursor for checking the acknowledgement status of the shipment
  cursor c_sco_ack_rej_ship(p_po_header_id_csr IN NUMBER, c_revision_num IN NUMBER) is
  SELECT count(1)
  FROM   po_acceptances pa,
         po_lines_archive_all pla,
         po_line_locations_archive_all plla
  WHERE  plla.po_header_id = p_po_header_id_csr
         AND pa.accepted_flag = 'N'
         AND plla.po_line_id = pla.po_line_id
         AND pa.po_line_location_id = plla.line_location_id
         AND pa.revision_num = c_revision_num
	 AND plla.revision_num = (SELECT max(plla2.revision_num)
	                          FROM   po_line_locations_archive_all plla2
	                          WHERE  plla2.line_location_id = plla.line_location_id
                                  AND    plla.revision_num <= c_revision_num);


 -- SCO created during Acknowledgement AND the supplier has rejected at least one shipment for the releases
  -- Cursor for checking whether sco is created during Acknowledgement or not.
     cursor c_sco_ack_ship_rel(p_po_header_id_csr IN NUMBER,p_po_release_id_csr IN NUMBER) is
     SELECT acceptance_required_flag,revision_num
     FROM   po_releases_all
     WHERE  po_header_id = p_po_header_id_csr
     AND    po_release_id = p_po_release_id_csr;

    -- Cursor for checking the acknowledgement status of the shipment
  cursor c_sco_ack_rej_ship_rel(p_po_header_id_csr IN NUMBER, c_revision_num IN NUMBER, p_po_release_id_csr IN NUMBER ) is
  SELECT count(1)
  FROM   po_acceptances pa,
         po_lines_archive_all pla,
         po_line_locations_archive_all plla
  WHERE  plla.po_header_id = p_po_header_id_csr
         AND pa.po_release_id = p_po_release_id_csr
         AND pa.accepted_flag = 'N'
         AND plla.po_release_id = pa.po_release_id
         AND plla.po_line_id = pla.po_line_id
         AND pa.po_line_location_id = plla.line_location_id
         AND pa.revision_num = c_revision_num
	 AND plla.revision_num = (SELECT max(plla2.revision_num)
	                          FROM   po_line_locations_archive_all plla2
	                          WHERE  plla2.line_location_id = plla.line_location_id
                                  AND    plla.revision_num <= c_revision_num);

-- Cursor for checking whether the signature is required or not
 /*  5550515
  cursor c_sgn_req_flag(p_po_header_id_csr IN NUMBER) IS
  SELECT acceptance_required_flag
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id_csr;
*/
 cursor c_sgn_req_flag_po(p_po_header_id_csr IN NUMBER,c_revision_num IN NUMBER ) IS
  SELECT count(1)
  FROM   po_acceptances
  WHERE  po_header_id = p_po_header_id_csr
  and revision_num=c_revision_num
  and signature_flag='Y';
/*
cursor c_sgn_req_flag_rel(p_po_release_id_csr IN NUMBER, c_revision_num IN NUMBER) IS
SELECT count(1)
  FROM   po_acceptances
  WHERE  po_release_id =p_po_release_id_csr
  and revision_num=c_revision_num
  and signature_flag='Y';
*/
-- Cursor for checking for a supplier Item Change
   CURSOR c_supp_item_chg(p_po_header_id_csr IN NUMBER) IS
   SELECT count(1)
   FROM   po_change_requests
   WHERE  action_type = 'MODIFICATION'
   AND    request_status = 'PENDING'
   AND    request_level = 'LINE'
   AND    new_supplier_part_number is not null
   AND    document_header_id = p_po_header_id_csr;

  l_split_shipment_request      number;
  l_cancel_requests             number;
  l_additional_change_requests  number;
  l_ack_reject_cnt              number;
  l_supp_item_chg_cnt           number;
  l_temp                        number;
  l_accpt_req_flag              po_headers_all.acceptance_required_flag%type;
  l_revision_num                number;
  l_signature_required          number :=0;
  l_ack_status_flag_count       number;
  l_api_name                    varchar2(50) := 'AUTO_APP_BIZ_RULES';
  x_progress                    varchar2(1000);
BEGIN

x_progress := 'AUTO_APP_BIZ_RULES_CHECK:000';

IF(p_doc_type = 'PO') THEN
        -- Split shipment check
        /*As part of 7697043 when spiltment occures is always sending todo to buyer to avoid that commented this code*/
       /*
        x_progress := 'AUTO_APP_BIZ_RULES_CHECK:001';
        OPEN c_split_ships(p_po_header_id);
        FETCH c_split_ships INTO l_split_shipment_request;
        log_message('AUTO_APP_BIZ_RULES_CHECK','Split Shipment Check',l_split_shipment_request);
        IF(l_split_shipment_request > 0) THEN
             CLOSE c_split_ships;
             return FALSE;
        END IF;
        IF c_split_ships%ISOPEN THEN
             CLOSE c_split_ships;
        END IF;
       */
      /*As part of 7697043 when spiltment occures is always sending todo to buyer to avoid that commented this code*/
   x_progress := 'AUTO_APP_BIZ_RULES_CHECK:002';
        --   Cancellation request should go to buyer
        OPEN c_cancel_requests(p_po_header_id);
        FETCH c_cancel_requests INTO l_cancel_requests;
        log_message('AUTO_APP_BIZ_RULES_CHECK','Cancellation Request Check',l_cancel_requests);
        IF(l_cancel_requests>0) THEN
             CLOSE c_cancel_requests;
             return FALSE;
        END IF;
        IF c_cancel_requests%ISOPEN THEN
             CLOSE c_cancel_requests;
        END IF;

   x_progress := 'AUTO_APP_BIZ_RULES_CHECK:003';
        -- additional changes should go to the buyer
        OPEN c_add_changes(p_po_header_id);
        FETCH c_add_changes INTO l_additional_change_requests;
        log_message('AUTO_APP_BIZ_RULES_CHECK','Additional Change Request Check',l_additional_change_requests);
        IF(l_additional_change_requests > 0 ) THEN
             CLOSE c_add_changes;
             return FALSE;
        END IF;
        IF c_add_changes%ISOPEN THEN
             CLOSE c_add_changes;
        END IF;

   x_progress := 'AUTO_APP_BIZ_RULES_CHECK:004';
        --Reject IF the SCO is created during acknowledgment, AND the supplier has rejected
        -- at least one shipment, the SCO should be rOUTed to the buyer.
        OPEN c_sco_ack_ship(p_po_header_id);
        FETCH c_sco_ack_ship INTO l_accpt_req_flag,l_revision_num;
        IF(l_accpt_req_flag = 'Y') THEN
             OPEN c_sco_ack_rej_ship(p_po_header_id,l_revision_num);
             FETCH c_sco_ack_rej_ship INTO l_ack_status_flag_count;
             log_message('AUTO_APP_BIZ_RULES_CHECK','Shipments rejected during ack',l_ack_status_flag_count);
             IF(l_ack_status_flag_count >= 1) THEN
                 CLOSE c_sco_ack_rej_ship;
                 CLOSE c_sco_ack_ship;
                 log_message('AUTO_APP_BIZ_RULES_CHECK','Shipments rejected during ack Check','Failed');
                 return FALSE;
             END IF;
        END IF;
        IF c_sco_ack_ship%ISOPEN THEN
            CLOSE c_sco_ack_ship;
        END IF;
        IF c_sco_ack_rej_ship%ISOPEN THEN
            CLOSE c_sco_ack_rej_ship;
        END IF;

    x_progress := 'AUTO_APP_BIZ_RULES_CHECK:005';
    -- check whether the document requires signature or not
        OPEN c_sgn_req_flag_po(p_po_header_id,l_revision_num);
        FETCH c_sgn_req_flag_po INTO l_signature_required;
        log_message('AUTO_APP_BIZ_RULES_CHECK','Signature Required ',l_signature_required);

        IF(l_signature_required >=1) THEN
            CLOSE c_sgn_req_flag_po;
            return FALSE;
        END IF;

        IF c_sgn_req_flag_po%ISOPEN THEN
            CLOSE c_sgn_req_flag_po;
        END IF;

    -- check whether the supplier item change is requested or not
        OPEN c_supp_item_chg(p_po_header_id);
        FETCH c_supp_item_chg INTO l_supp_item_chg_cnt;
        log_message('AUTO_APP_BIZ_RULES_CHECK','Supplie Item Chnage ',l_supp_item_chg_cnt);

        IF(l_supp_item_chg_cnt > 0) THEN
            CLOSE c_supp_item_chg;
            return FALSE;
        END IF;
        IF c_supp_item_chg%ISOPEN THEN
            CLOSE c_supp_item_chg;
        END IF;

  return TRUE;

ELSIF(p_doc_type = 'RELEASE') THEN
   /*As part of 7697043 when spiltment occures is always sending todo to buyer to avoid that commented this code*/
   /*
    x_progress := 'AUTO_APP_BIZ_RULES_CHECK:006';
      OPEN c_split_ships_rel(p_po_header_id,p_po_release_id);
      FETCH c_split_ships_rel INTO l_split_shipment_request;
      log_message('AUTO_APP_BIZ_RULES_CHECK','Split Shipment Check',l_split_shipment_request);
      IF(l_split_shipment_request > 0) THEN
         CLOSE c_split_ships_rel;
         return FALSE;
      END IF;
      IF c_split_ships_rel%ISOPEN THEN
         CLOSE c_split_ships_rel;
      END IF;
   */
  /*As part of 7697043 when spiltment occures is always sending todo to buyer to avoid that commented this code*/
    x_progress := 'AUTO_APP_BIZ_RULES_CHECK:007';
    --   Cancellation request should go to buyer
      OPEN c_cancel_requests_rel(p_po_header_id,p_po_release_id);
      FETCH c_cancel_requests_rel INTO l_cancel_requests;
      log_message('AUTO_APP_BIZ_RULES_CHECK','Cancellation Request Check',l_cancel_requests);
      IF(l_cancel_requests>0) THEN
         CLOSE c_cancel_requests_rel;
         return FALSE;
      END IF;
      IF c_cancel_requests_rel%ISOPEN THEN
         CLOSE c_cancel_requests_rel;
      END IF;

    x_progress := 'AUTO_APP_BIZ_RULES_CHECK:008';
    -- Additional chnages requested should go to the buyer
       OPEN c_add_changes_rel(p_po_header_id,p_po_release_id);
       FETCH c_add_changes_rel INTO l_additional_change_requests;
       log_message('AUTO_APP_BIZ_RULES_CHECK','Additional Change Request Check',l_additional_change_requests);
       IF(l_additional_change_requests > 0 ) THEN
          CLOSE c_add_changes_rel;
          return FALSE;
       END IF;
       IF c_add_changes_rel%ISOPEN THEN
          CLOSE c_add_changes_rel;
       END IF;

     x_progress := 'AUTO_APP_BIZ_RULES_CHECK:009';
     --Reject IF the SCO is created during acknowledgment, AND the supplier has rejected
     -- at least one shipment, the SCO should be rOUTed to the buyer.
        OPEN c_sco_ack_ship_rel(p_po_header_id,p_po_release_id);
        FETCH c_sco_ack_ship_rel INTO l_accpt_req_flag,l_revision_num;
        IF(l_accpt_req_flag = 'Y') THEN
            OPEN c_sco_ack_rej_ship_rel(p_po_header_id,l_revision_num,p_po_release_id);
            FETCH c_sco_ack_rej_ship_rel INTO l_ack_status_flag_count;
            log_message('AUTO_APP_BIZ_RULES_CHECK','Shipments rejected during ack',l_ack_status_flag_count);
            IF(l_ack_status_flag_count >= 1) THEN
               CLOSE c_sco_ack_rej_ship_rel;
               CLOSE c_sco_ack_ship_rel;
               log_message('AUTO_APP_BIZ_RULES_CHECK','Shipments rejected during ack Check','Failed');
               return FALSE;
             END IF;
        END IF;

        IF c_sco_ack_ship_rel%ISOPEN THEN
          CLOSE c_sco_ack_ship_rel;
        END IF;
        IF c_sco_ack_rej_ship_rel%ISOPEN THEN
          CLOSE c_sco_ack_rej_ship_rel;
        END IF;
/*
-- check whether the document requires signature or not
        OPEN c_sgn_req_flag_rel(p_po_release_id,l_revision_num);
        FETCH c_sgn_req_flag_rel INTO l_signature_required;

        log_message('AUTO_APP_BIZ_RULES_CHECK','Signature Required ',l_signature_required);

        IF(l_signature_required <1) THEN
            CLOSE c_sgn_req_flag_rel;
            return FALSE;
        END IF;

        IF c_sgn_req_flag_rel%ISOPEN THEN
            CLOSE c_sgn_req_flag_rel;
        END IF;
 */

     x_progress := 'AUTO_APP_BIZ_RULES_CHECK:010';
return TRUE;

END IF; -- If po_doc_type = PO or RELEASE

EXCEPTION
   WHEN OTHERS THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                              g_module_prefix,
                              x_progress || ':unexpected error' || Sqlerrm);
     END IF;
raise;

END AUTO_APP_BIZ_RULES_CHECK;

------------------------------------------------------------------------------
PROCEDURE PROMISE_DATE_CHANGE(itemtype        IN VARCHAR2,
  	                      itemkey         IN VARCHAR2,
  	                      actid           IN NUMBER,
  	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2)
IS

l_po_header_id          po_headers_all.po_header_id%TYPE;
x_progress              VARCHAR2(1000);
l_change_group_id       po_change_requests.change_request_group_id%TYPE;

BEGIN


IF (funcmode = 'RUN') THEN

  x_progress := 'PROMISE_DATE_CHANGE:000';

  l_po_header_id      :=  wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'PO_HEADER_ID');

  l_change_group_id   :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
  					               itemkey  => itemkey,
  	                                               aname    => 'CHANGE_REQUEST_GROUP_ID');
  -- IF only a promise date change return yes otherwise no

  IF PROMISEDATECHANGE(l_po_header_id,l_change_group_id)=TRUE THEN
    resultout := wf_engine.eng_completed || ':' || 'Y';
  ELSE
    resultout := wf_engine.eng_completed || ':' || 'N';
  END IF;
  x_progress:= 'PROMISE_DATE_CHANGE:001';
  log_message('PROMISE_DATE_CHANGE','Only promised date changed',resultout);
  return;
END IF;

EXCEPTION
 WHEN OTHERS THEN
-- The line below records this function call INthe error
-- system INthe case of an exception.

 IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                          g_module_prefix,
                          x_progress || ':unexpected error' || Sqlerrm);
  END IF;

wf_core.context('POSCHORD', 'PROMISE_DATE_CHANGE',itemtype, itemkey, to_char(actid),funcmode);

raise;

END PROMISE_DATE_CHANGE;


FUNCTION PROMISEDATECHANGE(p_po_header_id IN NUMBER, p_change_group_id IN NUMBER)
return boolean
is

CURSOR c_shipment_change(l_po_header_id IN NUMBER,l_change_group_id_csr IN NUMBER) IS
       select  OLD_QUANTITY,
               NEW_QUANTITY,
               OLD_PROMISED_DATE,
               NEW_PROMISED_DATE,
               OLD_PRICE,
               NEW_PRICE,
	       OLD_AMOUNT,
	       NEW_AMOUNT
       from    po_change_requests
       where   initiator='SUPPLIER'
	       AND action_type='MODIFICATION'
	       AND request_level='SHIPMENT'
               AND change_request_group_id = l_change_group_id_csr
               AND request_status IN('PENDING','BUYER_APP')
               AND document_header_id=l_po_header_id
               AND  ( (nvl(new_promised_date,sysdate) <> nvl(old_promised_date,sysdate-1)) OR
	              (nvl(new_promised_date,old_promised_date-1)<>old_promised_date) OR
	              (nvl(old_promised_date,new_promised_date-1)<>new_promised_date)
                    );

CURSOR c_line_change(l_po_header_id IN NUMBER,l_change_group_id_csr IN NUMBER) IS
        select  count(1)
        from   po_change_requests
        where  initiator='SUPPLIER'
	       AND action_type='MODIFICATION'
               AND change_request_group_id = l_change_group_id_csr
	       AND request_level='LINE'
               AND request_status IN('PENDING','BUYER_APP')
               AND document_header_id=l_po_header_id;


l_only_promised_date_change      boolean :=TRUE;
l_old_quantity              	 po_change_requests.old_quantity%type;
l_new_quantity 		    	 po_change_requests.new_quantity%type;
l_old_promised_date	    	 po_change_requests.old_promised_date%type;
l_new_promised_date 	    	 po_change_requests.new_promised_date%type;
l_old_price 		    	 po_change_requests.old_price%type;
l_new_price 		    	 po_change_requests.new_price%type;
l_old_amount 		  	 po_change_requests.old_amount%type;
l_new_amount 			 po_change_requests.new_amount%type;
x_progress                       VARCHAR2(1000);
l_line_changes_counter           number:=0;
l_api_name                       varchar2(50) := 'PROMISEDATECHANGE';


BEGIN

 x_progress:='PROMISEDATECHANGE:000';

  IF (c_line_change%ISOPEN) THEN
     CLOSE c_line_change;
  ELSE
      OPEN c_line_change(p_po_header_id,p_change_group_id);
  END IF;
  FETCH c_line_change INTO l_line_changes_counter ;
  x_progress:='PROMISEDATECHANGE:001';
  log_message('PROMISEDATECHANGE','Price Changes Line Level',l_line_changes_counter);

  IF l_line_changes_counter >0 THEN
     CLOSE c_line_change;
     return FALSE;
  END IF;

  IF (c_line_change%ISOPEN) THEN
  CLOSE c_line_change;
  END IF;

 x_progress:='PROMISEDATECHANGE:002';

  IF (c_shipment_change%ISOPEN) THEN
  CLOSE c_shipment_change;
  else
  OPEN c_shipment_change(p_po_header_id,p_change_group_id);
  END IF;
  LOOP
  FETCH c_shipment_change INTO
        l_old_quantity,
        l_new_quantity,
        l_old_promised_date,
        l_new_promised_date,
        l_old_price,
        l_new_price,
        l_old_amount,
        l_new_amount;
  x_progress:='PROMISEDATECHANGE:003';
  log_message('PROMISEDATECHANGE','Quantity Changes',l_old_quantity || ', '||l_new_quantity);
  log_message('PROMISEDATECHANGE','Promise date Changes',l_old_promised_date || ', '||l_new_promised_date);
  log_message('PROMISEDATECHANGE','Shipment Price Changes',l_old_promised_date || ', '||l_new_promised_date);
  -- IF only a promise date change return TRUE otherwise return FALSE
  EXIT WHEN c_shipment_change%NOTFOUND;
  EXIT WHEN (l_only_promised_date_change=FALSE);

    IF nvl(l_old_quantity,0)<>nvl(l_new_quantity,0) THEN
           l_only_promised_date_change:= FALSE;
    ELSIF nvl(l_old_price,0)<>nvl(l_new_price,nvl(l_old_price,0)) THEN
           l_only_promised_date_change:= FALSE;
    ELSIF nvl(l_old_amount,0)<>nvl(l_new_amount,0) THEN
           l_only_promised_date_change:= FALSE;
    ELSIF (l_new_promised_date is null AND l_old_promised_date is null) THEN
           l_only_promised_date_change:= FALSE;
    END IF;
  END LOOP;
  CLOSE c_shipment_change;
  x_progress:='PROMISEDATECHANGE:004';
return l_only_promised_date_change;
exception
 when others THEN
   IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         x_progress || ':unexpected error' || Sqlerrm);
   END IF;
raise;
END PROMISEDATECHANGE;

------------------------------------------------------------------------------

PROCEDURE INITIATE_RCO_FLOW (itemtype        IN VARCHAR2,
   	                     itemkey         IN VARCHAR2,
   	                     actid           IN NUMBER,
   	                     funcmode        IN VARCHAR2,
                             resultout       OUT NOCOPY VARCHAR2)
IS
l_change_group_id PO_CHANGE_REQUESTS.CHANGE_REQUEST_GROUP_ID%type;
l_po_header_id    po_headers_all.po_header_id%type;
l_po_release_id   po_releases_all.po_release_id%type;
x_progress        VARCHAR2(1000);

BEGIN
x_progress := 'INITIATE_RCO_FLOW:000';
l_po_header_id   :=  wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'PO_HEADER_ID');
l_po_release_id   :=  wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'PO_RELEASE_ID');


x_progress := 'INITIATE_RCO_FLOW:001';
log_message('INITIATE_RCO_FLOW','Po Header Id',l_po_header_id);
INITIATERCOFLOW (l_po_header_id,l_po_release_id,l_change_group_id);
-- set the x_change_request_group_id number
x_progress:= 'INITIATE_RCO_FLOW:002';
log_message('INITIATE_RCO_FLOW','Change Req Group Id',l_change_group_id);

wf_engine.SetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQ_CHANGE_REQUEST_GROUP_ID',
                             avalue    => l_change_group_id);

resultout:=wf_engine.eng_completed;
x_progress := 'INITIATE_RCO_FLOW:003';

EXCEPTION

when others THEN

  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;
  wf_core.context('POSCHORD', 'INITIATE_RCO_FLOW', itemtype, itemkey, to_char(actid), funcmode);
  raise;
END INITIATE_RCO_FLOW;


PROCEDURE   INITIATERCOFLOW(p_po_header_id IN NUMBER, p_po_release_id IN NUMBER, x_change_group_id OUT NOCOPY NUMBER)
IS

  --- this also should hANDle non sync values
CURSOR  c_change_request(p_po_header_id_csr IN NUMBER) IS
SELECT  pcr.change_request_group_id,
	pcr.new_price new_price,
	pcr.new_quantity,
	pcr.new_start_date,
	pcr.new_expiration_date,
	pcr.new_amount,
	pcr.request_level,
        --pcr.new_promised_date,
	nvl(pcr.new_need_by_date,decode(prla.need_by_date,plla.need_by_date,null,plla.need_by_date)),
        pcr.request_reason,
	prla.requisition_line_id,
	prla.requisition_header_id,
	prla.line_location_id,
	prda.distribution_id
FROM    po_change_requests pcr,
        po_requisition_lines_all prla,
	po_req_distributions_all prda,
	po_line_locations_all plla
WHERE   document_header_id= p_po_header_id_csr
        AND request_status='BUYER_APP'
        AND change_active_flag='Y'
        AND initiator='SUPPLIER'
      --AND pcr.document_line_location_id = prla.line_location_id(+)
        AND prda.requisition_line_id=prla.requisition_line_id
        AND pcr.request_level='SHIPMENT'
        AND plla.line_location_id = prla.line_location_id
	AND plla.po_line_id=pcr.document_line_id
	AND plla.po_header_id=pcr.document_header_id
	AND (   pcr.new_price    is not null    --New change JAI
	     OR pcr.new_quantity is not null
	     OR pcr.new_start_date is not null
	     OR pcr.new_expiration_date is not null
	     OR pcr.new_amount is not null
	    )
UNION
SELECT  pcr.change_request_group_id,
	pcr.new_price,
	null new_quantity,
	null new_start_date ,
	null new_expiration_date,
	null new_amount,
	pcr.request_level,
      --null new_promised_date,
	null new_need_by_date,
        pcr.request_reason,
	prla.requisition_line_id,
	prla.requisition_header_id,
	prla.line_location_id,
	null distribution_id
FROM    po_change_requests pcr,
	po_line_locations_all plla,
	po_requisition_lines_all prla
WHERE   document_header_id=p_po_header_id_csr
        AND request_status='BUYER_APP'
        AND change_active_flag='Y'
        AND initiator='SUPPLIER'
	AND pcr.request_level='LINE'
	AND plla.line_location_id = prla.line_location_id
	AND plla.po_line_id=pcr.document_line_id
	AND plla.po_header_id=pcr.document_header_id;

--for releases

CURSOR  c_change_request_rel(p_po_release_id_csr IN NUMBER) IS
SELECT  pcr.change_request_group_id,
	pcr.new_price new_price,
	pcr.new_quantity,
	pcr.new_start_date,
	pcr.new_expiration_date,
	pcr.new_amount,
	pcr.request_level,
        --pcr.new_promised_date,
	nvl(pcr.new_need_by_date,decode(prla.need_by_date,plla.need_by_date,null,plla.need_by_date)),
        pcr.request_reason,
	prla.requisition_line_id,
	prla.requisition_header_id,
	prla.line_location_id,
	prda.distribution_id
FROM    po_change_requests pcr,
        po_requisition_lines_all prla,
	po_req_distributions_all prda,
	po_line_locations_all plla
WHERE   pcr.po_release_id= p_po_release_id_csr
        AND request_status='BUYER_APP'
        AND change_active_flag='Y'
        AND initiator='SUPPLIER'
      --AND pcr.document_line_location_id = prla.line_location_id(+)
        AND prda.requisition_line_id=prla.requisition_line_id
        AND pcr.request_level='SHIPMENT'
        AND plla.line_location_id = prla.line_location_id
	AND plla.po_line_id=pcr.document_line_id
	AND plla.po_header_id=pcr.document_header_id
    AND plla.po_release_id =pcr.po_release_id
	AND (   pcr.new_price    is not null    --New change JAI
         OR pcr.new_quantity is not null
	     OR pcr.new_start_date is not null
	     OR pcr.new_expiration_date is not null
	     OR pcr.new_amount is not null
	    )
UNION
SELECT  pcr.change_request_group_id,
	pcr.new_price,
	null new_quantity,
	null new_start_date ,
	null new_expiration_date,
	null new_amount,
	pcr.request_level,
      --null new_promised_date,
	null new_need_by_date,
        pcr.request_reason,
	prla.requisition_line_id,
	prla.requisition_header_id,
	prla.line_location_id,
	null distribution_id
FROM    po_change_requests pcr,
	po_line_locations_all plla,
	po_requisition_lines_all prla
WHERE   pcr.po_release_id=p_po_release_id_csr
        AND request_status='BUYER_APP'
        AND change_active_flag='Y'
        AND initiator='SUPPLIER'
	AND pcr.request_level='LINE'
	AND plla.line_location_id = prla.line_location_id
	AND plla.po_line_id=pcr.document_line_id
	AND plla.po_header_id=pcr.document_header_id;



--l_change_group_id         po_change_requests.change_request_group_id%type ;
l_change_group_id         po_change_requests.change_request_group_id%type ;
l_new_price               po_change_requests.new_price%type ;
l_new_quantity            po_change_requests.new_quantity%type ;
l_new_start_date          po_change_requests.new_start_date%type  ;
l_new_expiration_date     po_change_requests.new_expiration_date%type ;
l_new_amount              po_change_requests.new_amount%type ;
l_request_level           po_change_requests.request_level%type ;
l_new_promised_date       po_change_requests.new_promised_date%type ;
l_new_need_by_date        po_change_requests.new_need_by_date%type ;
l_request_reason          po_change_requests.request_reason%type ;
l_requisition_line_id     po_requisition_lines_all.requisition_line_id%type ;
l_requisition_header_id   po_requisition_lines_all.requisition_header_id%type ;
l_line_location_id        po_requisition_lines_all.line_location_id%type ;
l_req_distribution_id     po_req_distributions_all.distribution_id%type ;
l_change_table            PO_REQ_CHANGE_TABLE;
l_cancel_table            PO_REQ_CANCEL_TABLE:=null;
l_rec_count number :=0;
l_req_hdr_id number;
l_api_version number := 1.0;
l_api_name varchar2(100) := 'INITIATERCOFLOW';
x_progress varchar2(1000);
l_po_line_id  number;
x_return_status VARCHAR2(10);
x_retMsg VARCHAR2(2000):='';
x_errTable PO_REQ_CHANGE_ERR_TABLE;
x_errCode VARCHAR2(10);
l_dummy_table_number    po_tbl_number := po_tbl_number();

/* Bug 7422622 - Added the following variables to check whether AME
the setup is done.  If yes then clear the approval list. - Start*/

l_application_id     number :=201;
l_ame_transaction_type po_document_types.ame_transaction_type%TYPE;

/* Bug 7422622 -  End */

BEGIN

    x_retMsg :='';
    x_progress  := 'INITIATERCOFLOW:000';

    l_change_table:=PO_REQ_CHANGE_TABLE(
               req_line_id   =>   po_tbl_number(),
    	       req_dist_id   =>   po_tbl_number(),
    	       price         =>   po_tbl_number(),
    	       quantity      =>   po_tbl_number(),
    	       need_by       =>   po_tbl_date(),
    	       start_date    =>   po_tbl_date(),
    	       END_date      =>   po_tbl_date(),
    	       amount        =>   po_tbl_number(),
    	       type          =>   po_tbl_varchar60(),
               change_reason =>   po_tbl_VARCHAR2000());

    if  p_po_release_id is not null then

     OPEN c_change_request_rel (p_po_release_id);
          l_rec_count :=1;
         loop


         FETCH c_change_request_rel INTO
                        l_change_group_id,
                        l_new_price ,
	 		l_new_quantity,
	 		l_new_start_date,
	 		l_new_expiration_date,
	 		l_new_amount,
	 		l_request_level,
	 		--l_new_promised_date,
	 		l_new_need_by_date,
	 	        l_request_reason,
	 		l_requisition_line_id,
	 		l_requisition_header_id,
	 		l_line_location_id,
	                l_req_distribution_id;


       EXIT WHEN c_change_request_rel%NOTFOUND;
   x_progress  := 'INITIATERCOFLOW:001';

--Filling the table with data

     l_change_table.req_line_id.extend(1);
     l_change_table.req_line_id(l_rec_count):=l_requisition_line_id;
     l_change_table.req_dist_id.extend(1);
     l_change_table.req_dist_id(l_rec_count):=l_req_distribution_id;
     l_change_table.price.extend(1);
     l_change_table.price(l_rec_count):=l_new_price;
     l_change_table.quantity.extend(1);
     l_change_table.quantity(l_rec_count):=l_new_quantity;
     l_change_table.need_by.extend(1);
     l_change_table.start_date.extend(1);
     l_change_table.END_date.extend(1);
     l_change_table.amount.extend(1);
     l_change_table.amount(l_rec_count):=l_new_amount;
     l_change_table.type.extend(1);
     l_change_table.change_reason.extend(1);
     l_change_table.change_reason(l_rec_count):=l_request_reason;

     l_rec_count:=l_rec_count+1;

     END  loop;

     CLOSE c_change_request_rel;

     else

      OPEN c_change_request(p_po_header_id);
               l_rec_count :=1;
              loop


              FETCH c_change_request INTO
                             l_change_group_id,
                             l_new_price ,
     	 		l_new_quantity,
     	 		l_new_start_date,
     	 		l_new_expiration_date,
     	 		l_new_amount,
     	 		l_request_level,
     	 		--l_new_promised_date,
     	 		l_new_need_by_date,
     	 	        l_request_reason,
     	 		l_requisition_line_id,
     	 		l_requisition_header_id,
     	 		l_line_location_id,
     	                l_req_distribution_id;


            EXIT WHEN c_change_request%NOTFOUND;
        x_progress  := 'INITIATERCOFLOW:001';

     --Filling the table with data

          l_change_table.req_line_id.extend(1);
          l_change_table.req_line_id(l_rec_count):=l_requisition_line_id;
          l_change_table.req_dist_id.extend(1);
          l_change_table.req_dist_id(l_rec_count):=l_req_distribution_id;
          l_change_table.price.extend(1);
          l_change_table.price(l_rec_count):=l_new_price;
          l_change_table.quantity.extend(1);
          l_change_table.quantity(l_rec_count):=l_new_quantity;
          l_change_table.need_by.extend(1);
          l_change_table.start_date.extend(1);
          l_change_table.END_date.extend(1);
          l_change_table.amount.extend(1);
          l_change_table.amount(l_rec_count):=l_new_amount;
          l_change_table.type.extend(1);
          l_change_table.change_reason.extend(1);
          l_change_table.change_reason(l_rec_count):=l_request_reason;

          l_rec_count:=l_rec_count+1;

          END  loop;

     CLOSE c_change_request;

     end if;

    x_progress  := 'INITIATERCOFLOW:002 Call Save Req Change';

    PO_RCO_VALIDATION_PVT.Save_ReqChange( l_api_version,
    		                          x_return_status,
      		           	          l_requisition_header_id,
     	                                  l_change_table ,
     	                                  l_cancel_table ,
     			                  x_change_group_id,
     			      	          x_retMsg ,
      			                  x_errTable);

   IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_module_prefix,
                       x_progress
                       || 'x_return_status=' || x_return_status
                       || 'x_change_group_id = '|| x_change_group_id);
     END IF;

   ELSE
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_module_prefix,
                       x_progress
                       ||'x_return_status = ' || x_return_status
                       ||'x_retMsg = ' || x_retMsg);
     END IF;
   END IF;

   x_progress  := 'INITIATERCOFLOW:003';

   /* Bug 7422622 -- Check whether AME is setup for Requistion flow. If
   the setup is done then clear the approval list.*/

   SELECT ame_transaction_type
   INTO   l_ame_transaction_type
   FROM   po_document_types
   WHERE  document_type_code = 'CHANGE_REQUEST' and
          document_subtype = 'REQUISITION';

   if(l_ame_transaction_type is not null) then

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'POS_SCO_TOLERANCE_PVT.INITIATERCOFLOW.invoked','l_ame_transaction_type = ' ||l_ame_transaction_type);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'POS_SCO_TOLERANCE_PVT.INITIATERCOFLOW.invoked','l_requisition_header_id = ' ||l_requisition_header_id);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'POS_SCO_TOLERANCE_PVT.INITIATERCOFLOW.invoked','applicationId = ' ||l_application_id);
     END IF;

     ame_api2.clearAllApprovals( applicationIdIn   => l_application_id,
                                 transactionIdIn   => l_requisition_header_id,
                                 transactionTypeIn => l_ame_transaction_type
                                );
   end if;
   /* Bug 7422622 -  End */
--- Ip requirement
     update PO_CHANGE_REQUESTS
     set Parent_change_request_id = x_change_group_id
     where change_request_group_id= l_change_group_id;

 Exception

 when others THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;

 raise;


END INITIATERCOFLOW;
------------------------------------------------------------------------------


PROCEDURE START_RCO_WORKFLOW (itemtype        IN VARCHAR2,
   	                      itemkey         IN VARCHAR2,
   	                      actid           IN NUMBER,
   	                      funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2) is

l_change_group_id PO_CHANGE_REQUESTS.CHANGE_REQUEST_GROUP_ID%type;
x_progress        VARCHAR2(1000);
x_apprv_status    VARCHAR2(1);

BEGIN

  x_progress := 'START_RCO_WORKFLOW:000';

    l_change_group_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'REQ_CHANGE_REQUEST_GROUP_ID');

  x_progress := 'START_RCO_WORKFLOW:001';

  /* Call the ip API with change_request_group_id to set the approval_required_flag */

  PO_RCOTOLERANCE_GRP.SET_APPROVAL_REQUIRED_FLAG(l_change_group_id,x_apprv_status);


  STARTRCOWORKFLOW (l_change_group_id);

  resultout:=wf_engine.eng_completed;

  x_progress := 'START_RCO_WORKFLOW:002';


exception
when others THEN

  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;

 -- The line below records this function call INthe error
 -- system INthe case of an exception.
wf_core.context('POSCHORD', 'START_RCO_WORKFLOW', itemtype, itemkey, to_char(actid), funcmode);

 raise;


END START_RCO_WORKFLOW;
------------------------------------------------------------------------------

PROCEDURE   STARTRCOWORKFLOW(p_change_request_group_id IN NUMBER) is



    l_api_version number := 1.0;
    l_api_name  varchar2(100) := 'STARTRCOWF';
    x_return_status VARCHAR2(10);
    x_change_request_group_id number;
    x_retMsg VARCHAR2(2000):='';
    x_errTable PO_REQ_CHANGE_ERR_TABLE;
    x_errCode VARCHAR2(10);
    x_progress varchar2(1000);
    l_dummy_table_number    po_tbl_number := po_tbl_number();


BEGIN

    x_retMsg :='';
    x_progress  := 'STARTRCOWORKFLOW:000 Call Submit Req Change';

 --   get the x_change_request_group_id

    PO_RCO_VALIDATION_PVT.Submit_ReqChange (l_api_version ,
                                            x_return_status,
                                            p_change_request_group_id,--x_change_request_group_id,
                                            'N',-- p_fundscheck_flag IN VARCHAR2,
                                            'Please',
                                            'SUPPLIER',
                                             x_retMsg ,
                                             x_errCode ,
                                             x_errTable );

   IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_module_prefix,
                       x_progress
                       || ' x_return_status=' || x_return_status);
     END IF;

   ELSE
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_module_prefix,
                       x_progress
                       ||' x_return_status = ' || x_return_status
                       ||' x_retMsg = ' || x_retMsg
                       ||' x_errCode = ' || x_errCode);
     END IF;
   END IF;

   x_progress  := 'STARTRCOWORKFLOW:001';



Exception

 when others THEN
  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;


  raise;


END STARTRCOWORKFLOW;
------------------------------------------------------------------------------

PROCEDURE MARK_SCO_FOR_REQ(itemtype        IN VARCHAR2,
		           itemkey         IN VARCHAR2,
        		   actid           IN NUMBER,
	            	   funcmode        IN VARCHAR2,
                           resultout       OUT NOCOPY VARCHAR2)
IS

 CURSOR  l_planners_csr(c_po_header_id IN NUMBER)
 IS
  select UNIQUE(porh.PREPARER_ID)
  from   po_requisition_headers_all porh,
         po_requisition_lines_all porl,
         po_headers_all poh,
         po_line_locations_all poll
  where  porh.requisition_header_id = porl.requisition_header_id AND
         porl.line_location_id = poll.line_location_id  AND
         poh.po_header_id = poll.po_header_id AND
         poh.po_header_id = c_po_header_id;
--Bug 5053593.
  CURSOR l_requestors_csr(c_grp_id_csr IN NUMBER)
  IS
  select pda.deliver_to_person_id
  from
  	po_change_requests pcr,
  	po_distributions_all pda
  where pcr.change_request_group_id = c_grp_id_csr
  AND pcr.request_level = 'LINE'
  AND pcr.document_line_id = pda.po_line_id
  union
  select pda.deliver_to_person_id
  from
  	po_change_requests pcr,
  	po_distributions_all pda
  where pcr.change_request_group_id = c_grp_id_csr
  AND pcr.request_level = 'SHIPMENT'
  AND pcr.document_line_location_id = pda.line_location_id;

  l_change_group_id PO_CHANGE_REQUESTS.CHANGE_REQUEST_GROUP_ID%type;
  x_progress        VARCHAR2(1000);
  l_planner_username fnd_user.user_name%type;
  l_planner_disp_name VARCHAR2(2000);
  l_requester_username fnd_user.user_name%type;
  l_requester_disp_name VARCHAR2(2000);
  l_requester_id number;
  l_planner_id 	number;
  l_po_header_id PO_HEADERS_ALL.PO_HEADER_ID%TYPE;

  count_rec NUMBER;
BEGIN

  x_progress :='MARK_SCO_FOR_REQ:000';

--Bug 11732340
--Change group id to get the requester
    l_change_group_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');

  /*
  OPEN l_planners_csr(l_change_group_id );
     */
    l_po_header_id :=wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 aname => 'PO_HEADER_ID');

     count_rec := 0;
     OPEN l_planners_csr(l_po_header_id);

     LOOP

     FETCH l_planners_csr INTO l_planner_id;
     EXIT WHEN l_planners_csr%NOTFOUND;
     count_rec := count_rec + 1;

     END LOOP;


     IF (count_rec <> 1 )--Means there are more than 1 planners for the req
     THEN
     l_planner_id := NULL;
     END IF;


     close l_planners_csr;

  IF(l_planner_id is not null)  THEN

    x_progress:= 'MARK_SCO_FOR_REQ:001';



     -- Set the notIFication to be sent to the Requester
     wf_directory.GetUserName( p_orig_system    => 'PER',
                               p_orig_system_id => l_planner_id,
                               p_name           => l_planner_username,
                               p_display_name   => l_planner_disp_name);

    x_progress:= 'MARK_SCO_FOR_REQ:002';
    log_message('MARK_SCO_FOR_REQ','Planner User Name ',l_planner_username);



       wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'PREPARER_USERNAME',
                                avalue => l_planner_username);
  ELSE
    OPEN l_requestors_csr(l_change_group_id);
     FETCH l_requestors_csr INTO l_requester_id;
    close l_requestors_csr;
     x_progress:= 'MARK_SCO_FOR_REQ:003';



     wf_directory.GetUserName( p_orig_system    => 'PER',
                               p_orig_system_id => l_requester_id,
                               p_name           => l_requester_username,
                               p_display_name   => l_requester_disp_name);

     x_progress:= 'MARK_SCO_FOR_REQ:004';
     log_message('MARK_SCO_FOR_REQ','Requester User Name ',l_requester_username);


     wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'PREPARER_USERNAME',
                                avalue => l_requester_username);
  END IF;
      wf_engine.SetItemAttrText(itemtype => itemtype,
	                        itemkey => itemkey,
	                        aname => 'NOTIF_USAGE',
	                        avalue =>'REQ');
       update po_change_requests
        set request_status ='REQ_APP',
            responded_by = fnd_global.user_id,
            response_date = sysdate
        where change_request_group_id = l_change_group_id
              AND request_status = 'PENDING';


  resultout:=wf_engine.eng_completed;

  x_progress := 'MARK_SCO_FOR_REQ:005';



exception

when others THEN

  IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                           g_module_prefix,
                           x_progress || ':unexpected error' || Sqlerrm);
  END IF;
   wf_core.context('POSCHORD', 'MARK_SCO_FOR_REQ', itemtype, itemkey, to_char(actid), funcmode);

  raise;

END MARK_SCO_FOR_REQ;

------------------------------------------------------------------------------


END POS_SCO_TOLERANCE_PVT;

/
