--------------------------------------------------------
--  DDL for Package Body POA_EDW_SPEND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_SPEND_PKG" AS
/* $Header: POASPNDB.pls 120.0 2005/06/01 23:32:09 appldev noship $ */


  FUNCTION CONTRACT_AMT_RELEASED(p_contract_id	IN NUMBER,
 		    	         p_org_id	IN NUMBER,
	                         p_contract_type in VARCHAR2) RETURN NUMBER
  IS
	v_amt_released		NUMBER := 0;
	v_stdpo_amt		NUMBER := 0;
  BEGIN

	    IF (p_contract_type = 'BLANKET') THEN
	      IF (poa_ga_util_pkg.is_global_agreement(p_contract_id) = 'Y') THEN
              SELECT SUM(decode( pol.matching_basis
                               , 'AMOUNT'
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , ( decode( sign( nvl(pod.amount_delivered,0)
                                                        - nvl(pod.amount_billed,0))
                                                  , 1
                                                  , nvl(pod.amount_delivered,0)
                                                  , nvl(pod.amount_billed,0)))
                                          , ( nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) ))
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , ( decode( sign( nvl(pod.quantity_delivered,0)
                                                        - nvl(pod.quantity_billed,0))
                                                  , 1
                                                  , nvl(pod.quantity_delivered,0)
                                                  , nvl(pod.quantity_billed,0)))
                                          * nvl(pll.price_override,0)
                                        , ( nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                                          * nvl(pll.price_override,0) ))
                               )
                        )
	        INTO v_stdpo_amt
		FROM	po_headers_all		poh,
                        po_lines_all            pol,
	                po_line_locations_all	pll,
	                po_distributions_all	pod
		WHERE   pod.po_header_id	= poh.po_header_id
		and	pod.line_location_id	= pll.line_location_id
                and     pol.po_header_id        = poh.po_header_id
                and     pll.po_line_id          = pol.po_line_id
		and	pll.from_header_id	= p_contract_id
		and	nvl(pll.approved_flag, 'N')		= 'Y'
                and     nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';
	      END IF;
              SELECT SUM(decode( pol.matching_basis
                               , 'AMOUNT'
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , ( decode( sign( nvl(pod.amount_delivered,0)
                                                        - nvl(pod.amount_billed,0))
                                                  , 1
                                                  , nvl(pod.amount_delivered,0)
                                                  , nvl(pod.amount_billed,0)))
                                        , ( nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) ))
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , ( decode( sign( nvl(pod.quantity_delivered,0)
                                                        - nvl(pod.quantity_billed,0))
                                                  , 1
                                                  , nvl(pod.quantity_delivered,0)
                                                  , nvl(pod.quantity_billed,0)))
                                           * nvl(pll.price_override,0)
                                         , ( nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                                           * nvl(pll.price_override,0) ))
                               )
		      )
	        INTO v_amt_released
		FROM	po_releases_all		por,
	                po_headers_all		poh,
	                po_line_locations_all	pll,
                        po_distributions_all    pod,
                        po_lines_all            pol
		WHERE   pod.po_release_id	= por.po_release_id
		and	pod.po_header_id	= poh.po_header_id
                and     pod.po_line_id          = pol.po_line_id
		and	pod.line_location_id	= pll.line_location_id
		and	poh.po_header_id	= p_contract_id
		and	pod.org_id		= p_org_id
		and	nvl(pll.approved_flag,
				'N')		= 'Y'
                and     nvl(pod.distribution_type,'-99')   <> 'AGREEMENT';

	   v_amt_released := nvl(v_amt_released, 0) + nvl(v_stdpo_amt, 0);

	    ELSE
              SELECT SUM(decode( plc.matching_basis
                               , 'AMOUNT'
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , (decode( sign( nvl(pod.amount_delivered,0)
                                                       - nvl(pod.amount_billed,0))
                                                 , 1
                                                 , nvl(pod.amount_delivered,0)
                                                 , nvl(pod.amount_billed,0)))
                                        , ( nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) ))
                               , (decode( pll.closed_code
                                        , 'FINALLY_CLOSED'
                                        , (decode( sign( nvl(pod.quantity_delivered,0)
                                                       - nvl(pod.quantity_billed,0))
                                                 , 1
                                                 , nvl(pod.quantity_delivered,0)
                                                 , nvl(pod.quantity_billed,0)))
                                          * nvl(pll.price_override,0)
                                        , ( nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                                          * nvl(pll.price_override,0) ))
                               )
		       )
	        INTO v_amt_released
	        FROM    po_headers_all		poh,
			po_headers_all		poh2,
			po_lines_all		plc,
	                po_line_locations_all	pll,
	                po_distributions_all	pod
		WHERE   pod.po_header_id	= poh.po_header_id
	        and 	pod.po_line_id		= plc.po_line_id
		and	pod.line_location_id	= pll.line_location_id
		and 	plc.contract_id    	= poh2.po_header_id
		and	poh2.po_header_id	= p_contract_id
		and	pod.org_id		= p_org_id
		and	nvl(pll.approved_flag,
	    			'N')		= 'Y'
                and     nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';
	    END IF;

	    RETURN nvl(v_amt_released,0);

  END CONTRACT_AMT_RELEASED;

  FUNCTION LINE_AMT_RELEASED(p_contract_id      IN NUMBER,
	                     p_org_id           IN NUMBER,
	                     p_line_id	    IN NUMBER) RETURN NUMBER
  IS
	        v_amt_released            NUMBER := 0;
	        v_stdpo_amt            NUMBER := 0;
  BEGIN

	      IF (poa_ga_util_pkg.is_global_agreement(p_contract_id) = 'Y') THEN
                SELECT SUM(decode( pol.matching_basis
                                 , 'AMOUNT'
                                 , (decode( pll.closed_code
                                          , 'FINALLY_CLOSED'
                                          , (decode( sign( nvl(pod.amount_delivered,0)
                                                         - nvl(pod.amount_billed,0))
                                                   , 1
                                                   , nvl(pod.amount_delivered,0)
                                                   , nvl(pod.amount_billed,0)))
                                          , ( nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) ))
                                 , (decode( pll.closed_code
                                          , 'FINALLY_CLOSED'
                                          , (decode( sign( nvl(pod.quantity_delivered,0)
                                                         - nvl(pod.quantity_billed,0))
                                                   , 1
                                                   , nvl(pod.quantity_delivered,0)
                                                   , nvl(pod.quantity_billed,0)))
                                            * nvl(pll.price_override,0)
                                          , ( nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                                            * nvl(pll.price_override,0) ))
                                 )
			  )
	        INTO v_stdpo_amt
		FROM            po_headers_all		poh,
                                po_lines_all            pol,
	                        po_line_locations_all	pll,
	                        po_distributions_all	pod
	        WHERE   	pod.po_header_id	= poh.po_header_id
	   	and	        pod.line_location_id	= pll.line_location_id
                and             pol.po_header_id        = poh.po_header_id
                and             pll.po_line_id          = pol.po_line_id
		and	        pol.from_header_id	= p_contract_id
	        and             pol.from_line_id        = p_line_id
		and	        nvl(pll.approved_flag, 'N')		= 'Y'
                and             nvl(pod.distribution_type,'-99')   <> 'AGREEMENT';
	      END IF;

                SELECT    SUM(decode( pol.matching_basis
                                    , 'AMOUNT'
                                    , (decode( pll.closed_code
                                             , 'FINALLY_CLOSED'
                                             , (decode( sign( nvl(pod.amount_delivered,0)
                                                            - nvl(pod.amount_billed,0))
                                                      , 1
                                                      , nvl(pod.amount_delivered,0),nvl(pod.amount_billed,0)))
                                             , ( nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) ))
                                    , (decode( pll.closed_code
                                             , 'FINALLY_CLOSED'
                                             , (decode( sign( nvl(pod.quantity_delivered,0)
                                                            - nvl(pod.quantity_billed,0))
                                                      , 1
                                                      , nvl(pod.quantity_delivered,0),nvl(pod.quantity_billed,0)))
                                               * nvl(pll.price_override,0)
                                             , ( nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                                               * nvl(pll.price_override,0) ))
                                    )
			     )
	        INTO v_amt_released
	        FROM    po_distributions_all    pod,
	                po_line_locations_all   pll,
	                po_headers_all          poh,
                        po_releases_all         por,
                        po_lines_all            pol
	        WHERE   pod.po_release_id       = por.po_release_id
	        and     pod.po_header_id        = poh.po_header_id
                and     pod.po_line_id          = pol.po_line_id
	        and     pod.line_location_id    = pll.line_location_id
	        and     poh.po_header_id        = p_contract_id
	        and     pod.org_id              = p_org_id
		and	pod.po_line_id		= p_line_id
	        and     nvl(pll.approved_flag,
				'N')		= 'Y'
                and     nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';

		RETURN nvl(v_stdpo_amt, 0) + nvl(v_amt_released,0);

  END LINE_AMT_RELEASED;


  FUNCTION LINE_QTY_RELEASED(p_contract_id      IN NUMBER,
	                     p_org_id           IN NUMBER,
                             p_line_id          IN NUMBER) RETURN NUMBER
  IS
	        v_qty_released           NUMBER := 0;
	        v_stdpo_qty              NUMBER := 0;
   BEGIN

	      IF (poa_ga_util_pkg.is_global_agreement(p_contract_id) = 'Y') THEN
	        SELECT SUM(decode(pll.closed_code, 'FINALLY_CLOSED',
	                  (decode(sign(nvl(pod.quantity_delivered,0)
	                             - nvl(pod.quantity_billed,0)),
	                    1, nvl(pod.quantity_delivered,0),nvl(pod.quantity_billed,0)))
	                   ,
	                  (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
	                   ))
	        INTO v_stdpo_qty
		FROM	        po_headers_all		poh,
                                po_lines_all            pol,
	                        po_line_locations_all	pll,
	                        po_distributions_all	pod
	        WHERE   	pod.po_header_id	= poh.po_header_id
	   	and	        pod.line_location_id	= pll.line_location_id
                and             pol.po_header_id        = poh.po_header_id
                and             pll.po_line_id          = pol.po_line_id
		and	        pll.from_header_id	= p_contract_id
	        and             pll.from_line_id        = p_line_id
		and	        nvl(pll.approved_flag, 'N')		= 'Y'
                and             nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';
	       END IF;

	        SELECT    SUM(decode(pll.closed_code, 'FINALLY_CLOSED',
	                  (decode(sign(nvl(pod.quantity_delivered,0)
	                             - nvl(pod.quantity_billed,0)),
	                    1, nvl(pod.quantity_delivered,0),           nvl(pod.quantity_billed,0))),
	                  (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))))
	        INTO v_qty_released
	        FROM    po_distributions_all    pod,
	                po_line_locations_all   pll,
	                po_headers_all          poh,
	                po_releases_all         por
	        WHERE   pod.po_release_id       = por.po_release_id
	        and     pod.po_header_id        = poh.po_header_id
	        and     pod.line_location_id    = pll.line_location_id
	        and     poh.po_header_id        = p_contract_id
	        and     pod.org_id              = p_org_id
	        and     pod.po_line_id          = p_line_id
	        and     nvl(pll.approved_flag,
	                        'N')            = 'Y'
                and     nvl(pod.distribution_type,'-99')   <> 'AGREEMENT';

	        RETURN nvl(v_stdpo_qty, 0) + nvl(v_qty_released,0);

  END LINE_QTY_RELEASED;


  FUNCTION      APPROVED_BY(p_po_header_id  	IN NUMBER)
                                RETURN NUMBER
  IS
  	v_employee_id		NUMBER := 0;
	v_sequence_num		NUMBER := 0;

  BEGIN

	SELECT max(pah.sequence_num)
	INTO 	v_sequence_num
	FROM	po_action_history 	pah
	WHERE	object_id		= p_po_header_id
	and	object_type_code	in ('PO', 'PA')
	and	action_code		= 'APPROVE';

	SELECT pah.employee_id
	INTO 	v_employee_id
	FROM	po_action_history	pah
	WHERE	pah.sequence_num 	= v_sequence_num
	and	pah.object_id		= p_po_header_id
	and	pah.object_type_code	in ('PO', 'PA')
	and	pah.action_code		= 'APPROVE'
        and     rownum < 2;


	RETURN v_employee_id;

  END APPROVED_BY;


  FUNCTION      GET_ACCEPTANCE_DATE(p_doc_id      IN NUMBER,
                                    p_type           IN VARCHAR2)
                                RETURN DATE
  IS
          v_accept_date		DATE := to_date(NULL);
  BEGIN

        IF (p_type = 'P') THEN
          SELECT max(pac.action_date)
          INTO 	v_accept_date
          FROM 	po_acceptances         pac
          WHERE   pac.po_header_id     = p_doc_id
          and     pac.accepted_flag    = 'Y';
        ELSE
          SELECT max(pac.action_date)
          INTO 	v_accept_date
          FROM 	po_acceptances         pac
          WHERE   pac.po_release_id    = p_doc_id
          and     pac.accepted_flag    = 'Y';

        END IF;

        RETURN v_accept_date;

  EXCEPTION when others then
    v_accept_date := to_date(NULL);
    RETURN v_accept_date;


  END GET_ACCEPTANCE_DATE;

  FUNCTION      GET_REQ_APPROVAL_DATE(p_req_dist_id      IN NUMBER)
                                RETURN DATE
  IS
          v_approval_date         DATE := to_date(NULL);
          v_req_header_id         NUMBER := 0;

  BEGIN

        SELECT prh.requisition_header_id
        INTO    v_req_header_id
        FROM    po_requisition_headers_all  prh,
                po_requisition_lines_all    prl,
                po_req_distributions_all    prd
        WHERE   prd.distribution_id         = p_req_dist_id
        and     prl.requisition_line_id     = prd.requisition_line_id
        and     prh.requisition_header_id   = prl.requisition_header_id;


	SELECT max(pah.action_date)
	INTO 	v_approval_date
	FROM	po_action_history 	    pah
	WHERE	pah.object_id		    = v_req_header_id
	and	pah.object_type_code	    = 'REQUISITION'
        and     pah.object_sub_type_code    = 'PURCHASE'
	and	pah.action_code		    = 'APPROVE';


        RETURN v_approval_date;

  EXCEPTION when others then
    v_approval_date := to_date(NULL);
    RETURN v_approval_date;


  END GET_REQ_APPROVAL_DATE;

  FUNCTION      GET_SUPPLIER_APPROVED(p_po_dist_id      IN NUMBER)
                                RETURN VARCHAR2
  IS
          v_supp_approved	VARCHAR2(3) := NULL;
  BEGIN


	SELECT decode(max('Y'), 'Y', 'Y', 'N')
	INTO v_supp_approved
	FROM   	po_distributions_all pod,
       		po_line_locations_all pll,
       		po_lines_all pol,
       		po_headers_all poh,
       		po_asl_status_rules pasr,
       		po_asl_statuses pas,
       		po_approved_supplier_list pasl
	WHERE  pod.po_header_id     = poh.po_header_id
	and    pod.po_line_id       = pol.po_line_id
	and    pod.line_location_id = pll.line_location_id
	and    poh.vendor_id        = pasl.vendor_id
	and    (poh.vendor_site_id  = pasl.vendor_site_id
        	OR
        	pasl.vendor_site_id is null)
	and    ((pll.ship_to_organization_id = pasl.using_organization_id)
       		 OR
        	(pasl.using_organization_id = -1
         	and not exists
			(SELECT 'local exists with global record'
                 	FROM   	po_line_locations_all pll2,
				po_lines_all          pol2,
				po_headers_all        poh2,
				po_approved_supplier_list pasl2
		 	WHERE  pll2.ship_to_organization_id =
				pasl.using_organization_id
                 	and    pll2.po_header_id = poh2.po_header_id
		 	and    pol2.po_header_id = poh2.po_header_id
                 	and    poh2.vendor_id    = pasl2.vendor_id
                 	and    ((pol2.item_id is not null
                        	  and pol2.item_id = pasl2.item_id)
                         	OR
			  	(pol2.item_id is null
                           	and pol2.category_id = pasl2.category_id)))))
	and    ((pol.item_id is not null
       		and pol.item_id = pasl.item_id)
        	OR
        	(pol.item_id is null
         	and pol.category_id  = pasl.category_id))
	and    pasl.asl_status_id     = pas.status_id
	and    pasr.status_id         = pas.status_id
	and    pasr.business_rule     = '1_PO_APPROVAL'
	and    pasr.allow_action_flag = 'Y'
	and    pod.po_distribution_id = p_po_dist_id
        and    nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';

	RETURN v_supp_approved;

  EXCEPTION when others THEN
    v_supp_approved := 'N';
    RETURN v_supp_approved;

  END GET_SUPPLIER_APPROVED;

  FUNCTION      GET_SUPPLIER_APPROVED(p_po_dist_id      IN NUMBER,
                                      p_vendor_id       IN NUMBER,
                                      p_vendor_site_id  IN NUMBER,
                                      p_ship_to_org_id  IN NUMBER,
                                      p_item_id         IN NUMBER,
                                      p_category_id     IN NUMBER)
                                RETURN VARCHAR2
  IS
          v_supp_approved       VARCHAR2(3) := NULL;
  BEGIN

  select decode(max('Y'), 'Y', 'Y', 'N')
      into v_supp_approved
      from po_asl_status_rules pasr,
          po_asl_statuses pas,
          po_approved_supplier_list pasl
    where pasl.vendor_id = p_vendor_id
      and (pasl.vendor_site_id is null or
            pasl.vendor_site_id = p_vendor_site_id)
      and pasl.using_organization_id in (-1,p_ship_to_org_id)
      and ((p_item_id is not null and pasl.item_id = p_item_id) or
            (p_item_id is null and pasl.category_id = p_category_id))
      and pasl.asl_status_id    = pas.status_id
      and    pasr.status_id        = pas.status_id
      and    pasr.business_rule    = '1_PO_APPROVAL'
    having count(pasr.allow_action_flag)
            = count(decode(pasr.allow_action_flag,'Y','Y',null));

  return v_supp_approved;

  EXCEPTION when others THEN
    v_supp_approved := 'N';
    RETURN v_supp_approved;

  END GET_SUPPLIER_APPROVED;

-- get_check_cut_date
-- Gets min check_cut date from ap_invoices for a given distribution ID

FUNCTION get_check_cut_date(p_po_dist_id	NUMBER)
  RETURN DATE
IS
  cc_date	DATE := NULL;

BEGIN

  select min(ack.check_date)
    into cc_date
    from ap_checks_all 		 		ack,
         ap_invoice_payments_all	        aip,
         ap_invoice_distributions_all    	aid
   where aip.check_id = ack.check_id
     and aip.invoice_id = aid.invoice_id
     and aid.po_distribution_id      = p_po_dist_id;

RETURN(cc_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	RETURN (cc_date);
  WHEN OTHERS THEN
	RAISE;

END get_check_cut_date;

-- get_invoice_received_date
-- Gets min invoice_received_date from ap_invoices for a given distribution_id

FUNCTION get_invoice_received_date(p_po_dist_id	NUMBER)
 RETURN DATE
IS

inv_rec_date	DATE := NULL;

BEGIN

  select min(ain.invoice_received_date)
   into inv_rec_date
   from ap_invoices_all 		ain,
        ap_invoice_distributions_all   	aid
  where ain.invoice_id = aid.invoice_id
    and aid.po_distribution_id      = p_po_dist_id;

RETURN(inv_rec_date);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  RETURN(inv_rec_date);
 WHEN OTHERS THEN
  RAISE;

END get_invoice_received_date;

-- get_invoice_creation_date
-- Gets min invoice_creation_date from ap_invoice_creation_all
-- for a given distribution_id

FUNCTION get_invoice_creation_date(p_po_dist_id		NUMBER)
  RETURN DATE
IS

inv_creation_date	DATE := NULL;

BEGIN

  select min(aid.creation_date)
    into inv_creation_date
    from ap_invoice_distributions_all    aid
   where aid.po_distribution_id      = p_po_dist_id;

RETURN(inv_creation_date);

EXCEPTION

 WHEN NO_DATA_FOUND THEN
  RETURN(inv_creation_date);
 WHEN OTHERS THEN
  RAISE;

END get_invoice_creation_date;

-- get_goods_received_date
-- gets min good_received_date from rcv_transactions for given line_location_id
-- and transaction_type is RECEIVE

FUNCTION get_goods_received_date(p_po_line_loc_id	NUMBER)
  RETURN DATE
IS

goods_rcvd_date		DATE := NULL;

BEGIN

  select trunc(min(transaction_date))
   into goods_rcvd_date
   from  rcv_transactions 		rct
   where transaction_type = 'RECEIVE'
     and rct. po_line_location_id = p_po_line_loc_id;

RETURN(goods_rcvd_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN(goods_rcvd_date);
  WHEN OTHERS THEN
   RAISE;

END get_goods_received_date;

-- get_ipv
-- get the sum ipv for given distribution ID

FUNCTION get_ipv(p_po_dist_id	NUMBER)
  RETURN NUMBER
IS
v_ipv         NUMBER := 0;

BEGIN

  select  SUM(base_invoice_price_variance) into v_ipv
    from  ap_invoice_distributions_all
   where  po_distribution_id = p_po_dist_id;

RETURN(v_ipv);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(0);
  WHEN OTHERS THEN
    RAISE;

END get_ipv;

END POA_EDW_SPEND_PKG;

/
