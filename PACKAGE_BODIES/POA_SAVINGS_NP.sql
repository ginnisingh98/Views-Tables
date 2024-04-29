--------------------------------------------------------
--  DDL for Package Body POA_SAVINGS_NP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SAVINGS_NP" AS
/* $Header: poasvp3b.pls 120.3 2006/02/13 01:27:01 sdiwakar noship $ */

  /*
    NAME
      populate_npcontract -
    DESCRIPTION
      main function for populating poa_bis_savings fact table
      for Oracle Purchasing with non-contract and potential
      contract purchases information
  */


--
l_from_currency_code    VARCHAR2(150) := NULL;
l_to_currency_code      VARCHAR2(150) := NULL;
l_curr_conv_rate_date   DATE;
l_curr_conv_rate_type   VARCHAR2(150);
l_currency_conv_rate    NUMBER;

  PROCEDURE populate_npcontract (p_start_date IN DATE,
                                 p_end_date IN DATE,
                                 p_start_time IN DATE,
                                 p_batch_no IN NUMBER)
  IS

  v_item_id                 NUMBER;
  v_item_revision           VARCHAR2(3) := NULL;
  v_category_id             NUMBER;
  v_quantity                NUMBER;
  v_unit_meas_lookup_code   VARCHAR2(25) := NULL;
  v_creation_date           DATE;
  v_currency_code           VARCHAR2(15) := NULL;
  v_po_distribution_id      NUMBER;
  v_ship_to_location_id     NUMBER;
  v_price_override          NUMBER;
  v_need_by_date            DATE;
  v_org_id                  NUMBER;


  v_matching_agreement      BINARY_INTEGER := 0;

  v_lowest_possible_price   NUMBER;
  v_buf                     VARCHAR2(240) := NULL;
  v_count		    NUMBER := 0;

  x_iteration               BINARY_INTEGER := 0;
  x_progress                VARCHAR2(3) := NULL;

  e_error                   EXCEPTION;
  l_start_time              DATE;
  l_end_time                DATE;
  v_ship_to_organization_id po_line_locations_all.ship_to_organization_id%type;
  v_ship_to_ou              NUMBER;
  v_rate_date               DATE;
  v_edw_global_rate_type    edw_local_system_parameters.rate_type%type;
  v_edw_global_currency_code EDW_LOCAL_SYSTEM_PARAMETERS.warehouse_currency_code%type;
  --
  /* cursor to look at all standard POs which non-one-time-items that exist
   * in blankets. We still need to check whether all the criteria
   * for the item match those stated in the blankets.
   */
  CURSOR C_STD_PO (c_batch_no NUMBER) IS
  SELECT    /*+ cardinality (inc, 1) */ plc.item_id
  ,     plc.item_revision
  ,     plc.category_id
  ,     psc.quantity
  ,     plc.unit_meas_lookup_code
  ,     pod.creation_date
  ,     phc.currency_code
  ,     pod.po_distribution_id
  ,     psc.ship_to_location_id
  ,     psc.price_override
  ,     psc.need_by_date
  ,     phc.org_id
  ,     psc.ship_to_organization_id
  ,     to_number(hro.org_information3) org_information3
  ,     nvl(pod.rate_date,pod.creation_date) rate_date
  ,     phc.rate_type
  FROM  poa_edw_po_dist_inc   inc,
        po_distributions_all  pod
  ,     po_line_locations_all psc
  ,     po_lines_all          plc
  ,     po_doc_style_headers  style
  ,     po_headers_all        phc
  ,     po_headers_all        ga
  ,     hr_organization_information  hro
  WHERE inc.primary_key         = pod.PO_DISTRIBUTION_ID
  and   phc.po_header_id        = plc.po_header_id
  and   plc.po_line_id          = psc.po_line_id
  and   psc.line_location_id    = pod.line_location_id
  and   psc.shipment_type       = 'STANDARD'
  and   phc.style_id            = style.style_id
  and   nvl(style.progress_payment_flag,'N') = 'N'
  and   psc.approved_flag       = 'Y'
  and   plc.contract_id        is null
    and   plc.from_header_id      = ga.po_header_id(+)
    AND   Nvl(ga.global_agreement_flag, 'N') = 'N'
  and   plc.item_id             is not null
  and   pod.creation_date       is not null
  and   inc.batch_id            = c_batch_no
  and   to_number(hro.organization_id) = psc.ship_to_organization_id
  and   hro.org_information_context = 'Accounting Information'
  and   nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
  and   exists (SELECT 'blanket item'
                FROM po_lines_all pl
                ,    po_headers_all ph
                WHERE ph.type_lookup_code = 'BLANKET'
                and   ph.po_header_id = pl.po_header_id
                and   nvl(pl.unit_meas_lookup_code,
                                 nvl(plc.unit_meas_lookup_code, '-1'))
                               = nvl(plc.unit_meas_lookup_code, '-1')
                and   pod.creation_date between
                                        nvl(ph.start_date, pod.creation_date)
                                    and nvl(ph.end_date, pod.creation_date)
                and   trunc(pod.creation_date) <= nvl(pl.expiration_date, pod.creation_date)
                and   pl.item_id = plc.item_id
                and   nvl(pl.item_revision, nvl(plc.item_revision, '-1'))
                                 = nvl(plc.item_revision, '-1')
                and (
                     (nvl(ph.global_agreement_flag,'N') = 'N'
                      and ph.org_id = to_number(hro.org_information3)
                     )
                     or
                     (ph.global_agreement_flag = 'Y'
                      and exists
                      (select 'enabled'
                       from po_ga_org_assignments poga
                       where poga.po_header_id = ph.po_header_id
                       and poga.enabled_flag = 'Y'
                       and ((poga.purchasing_org_id in
                             (select /*+ leading(tfh) */ tfh.start_org_id
                              from mtl_transaction_flow_headers tfh,
                                   financials_system_params_all fsp1,
                                   financials_system_params_all fsp2
                              where pod.creation_date between nvl(tfh.start_date,pod.creation_date)
                                                            and nvl(tfh.end_date,pod.creation_date)
                              and tfh.flow_type = 2
                              and fsp1.org_id = tfh.start_org_id
                              and fsp1.purch_encumbrance_flag = 'N'
                              and fsp2.org_id = tfh.end_org_id
                              and fsp2.purch_encumbrance_flag = 'N'
                              and (
                                   (tfh.qualifier_code is null) or
                                   (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id)
                                  )
                              and tfh.end_org_id = to_number(hro.org_information3)
                              and (
                                   (tfh.organization_id = psc.ship_to_organization_id) or
                                   (tfh.organization_id is null)
                                  )
                             )
                            )
                            or poga.purchasing_org_id = to_number(hro.org_information3)
                           )
                      )
                     )
                    )
             );

  BEGIN

    POA_LOG.debug_line('Populate_noncontract: entered');
    POA_LOG.debug_line(' ');


    /* Delete from poa_bis_savings all rows which will is approved
     * and was modified in the date range specified.
     * These rows will be reinserted with the new modified information.
     */


    x_progress := '015';

      DELETE FROM poa_bis_savings poa
      WHERE distribution_transaction_id IN
            (SELECT primary_key FROM poa_edw_po_dist_inc WHERE batch_id = p_batch_no);

    /* Insert rows for POs created for one-time items in which no blankets
     * exists  (non-contracts)
     */

    x_progress := '020';
    INSERT INTO poa_bis_savings
       (    purchase_amount
       ,    contract_amount
       ,    non_contract_amount
       ,    pot_contract_amount
       ,    potential_saving
       ,    total_purchase_qty
       ,    distribution_transaction_id
       ,    document_type_code
       ,    purchase_creation_date
       ,    item_id
       ,    item_description
       ,    category_id
       ,    supplier_site_id
       ,    supplier_id
       ,    requestor_id
       ,    ship_to_location_id
       ,    ship_to_organization_id
       ,    operating_unit_id
       ,    buyer_id
       ,    project_id
       ,    task_id
       ,    currency_code
       ,    rate_type
       ,    rate_date
       ,    cost_center_id
       ,    account_id
       ,    company_id
       ,    rate
       ,    approved_date
       ,    Currency_Conv_Rate
       ,    created_by
       ,    creation_date
       ,    last_updated_by
       ,    last_update_date
       ,    last_update_login
       ,    request_id
       ,    program_application_id
       ,    program_id
       ,    program_update_date)
       (SELECT /*+ cardinality (inc, 1) */
             decode(psc.consigned_flag ,'Y'
                    ,null
                    ,decode(psc.matching_basis,'AMOUNT'
                            ,decode(psc.closed_code,'FINALLY_CLOSED'
                                    ,decode(sign(nvl(pod.amount_delivered,0) -nvl(pod.amount_billed,0)) ,1
                                             ,nvl(pod.amount_delivered,0)
                                             ,nvl(pod.amount_billed,0)
                                           ) *nvl(pod.rate,1)
                                    ,(nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0)) * nvl(pod.rate,1)
                                   )
                            ,decode(psc.closed_code,'FINALLY_CLOSED'
                                    ,decode(sign(nvl(pod.quantity_delivered,0) -nvl(pod.quantity_billed,0)) ,1
                                            ,nvl(pod.quantity_delivered,0)
                                            ,nvl(pod.quantity_billed,0)
                                           ) * nvl(psc.price_override,0) * nvl(pod.rate,1)
                                    ,(nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0)) * nvl(psc.price_override,0) * nvl(pod.rate,1)
                                   )
                           )
                   )
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     decode(psc.consigned_flag
                   ,'Y'
                   ,null
                   ,decode(psc.matching_basis
                          ,'AMOUNT'
                          ,(decode(psc.closed_code
                                  ,'FINALLY_CLOSED'
                                  ,(decode(sign(nvl(pod.amount_delivered,0)
                                               -nvl(pod.amount_billed,0))
                                          ,1
                                          ,nvl(pod.amount_delivered,0)
                                          ,nvl(pod.amount_billed,0))) * nvl(pod.rate,1)
                          ,(nvl(pod.amount_ordered,0)
                           -nvl(pod.amount_cancelled,0))
                           *nvl(pod.rate,1)))
                          ,(decode(psc.closed_code
                                 ,'FINALLY_CLOSED'
                                 ,(decode(sign(nvl(pod.quantity_delivered,0)
                                              -nvl(pod.quantity_billed,0))
                                         ,1
                                         ,nvl(pod.quantity_delivered,0)
                                         ,nvl(pod.quantity_billed,0)))
                                         *nvl(psc.price_override,0)
                                         *nvl(pod.rate,1)
                                 ,(nvl(pod.quantity_ordered,0)
                                  -nvl(pod.quantity_cancelled,0))
                                  *nvl(psc.price_override,0)
                                  *nvl(pod.rate,1)))
                          )
                    )
       ,    Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,    Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,    decode(psc.consigned_flag
                  ,'Y'
                  ,null
                  ,decode(psc.value_basis
                         ,'QUANTITY'
                         ,pod.quantity_ordered
                         ,null)
                  )
       ,    pod.po_distribution_id
       ,    phc.type_lookup_code
       ,    pod.creation_date
       ,    plc.item_id
       ,    plc.item_description
       ,    plc.category_id
       ,    phc.vendor_site_id
       ,    phc.vendor_id
       ,    pod.deliver_to_person_id
       ,    psc.ship_to_location_id
       ,    psc.ship_to_organization_id
       ,    psc.org_id
       ,    phc.agent_id
       ,    pod.project_id
       ,    pod.task_id
       ,    gl.currency_code
       ,    phc.rate_type
       ,    nvl(phc.rate_date, pod.creation_date)
       ,    pod.code_combination_id
       ,    NULL
       ,    NULL
       ,    pod.rate
       ,    NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
		      phc.approved_date)
       ,    POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code, gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,    fnd_global.user_id
       ,    p_start_time
       ,    fnd_global.user_id
       ,    p_start_time
       ,    fnd_global.login_id
       ,    fnd_global.conc_request_id
       ,    fnd_global.prog_appl_id
       ,    fnd_global.conc_program_id
       ,    p_start_time
       FROM poa_edw_po_dist_inc   inc,
            gl_sets_of_books      gl
       ,    po_distributions_all  pod
       ,    po_doc_style_headers  style
       ,    po_line_locations_all psc
       ,    po_lines_all          plc
      ,    po_headers_all        phc
      , po_headers_all ga
       WHERE inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and   phc.po_header_id        = plc.po_header_id
       and   plc.po_line_id          = psc.po_line_id
       and   psc.line_location_id    = pod.line_location_id
       and   psc.shipment_type       = 'STANDARD'
       and   phc.style_id            = style.style_id
       and   nvl(style.progress_payment_flag,'N') = 'N'
      	 AND   plc.from_header_id        = ga.po_header_id(+)
	 AND   Nvl(ga.global_agreement_flag, 'N') = 'N'
       and   psc.approved_flag       = 'Y'
       and   nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
       and   plc.contract_id        is null
       and   gl.set_of_books_id      = pod.set_of_books_id
       and   plc.item_id             is null
       and   pod.creation_date       is not null
       and   inc.batch_id            = p_batch_no);

    x_progress := '025';

    /* Insert rows for POs created for non-one-time items in which no blankets
     * exists  (non-contracts). These are considered leakage.  So, for
     * each of these rows, we still need to calculate their potential
     * savings.
     */

    INSERT INTO poa_bis_savings
       (    purchase_amount
       ,    contract_amount
       ,    non_contract_amount
       ,    pot_contract_amount
       ,    potential_saving
       ,    total_purchase_qty
       ,    distribution_transaction_id
       ,    document_type_code
       ,    purchase_creation_date
       ,    item_id
       ,    item_description
       ,    category_id
       ,    supplier_site_id
       ,    supplier_id
       ,    requestor_id
       ,    ship_to_location_id
       ,    ship_to_organization_id
       ,    operating_unit_id
       ,    buyer_id
       ,    project_id
       ,    task_id
       ,    currency_code
       ,    rate_type
       ,    rate_date
       ,    cost_center_id
       ,    account_id
       ,    company_id
       ,    rate
       ,    approved_date
       ,    Currency_Conv_Rate
       ,    created_by
       ,    creation_date
       ,    last_updated_by
       ,    last_update_date
       ,    last_update_login
       ,    request_id
       ,    program_application_id
       ,    program_id
       ,    program_update_date)
       (SELECT /*+ cardinality(inc, 1) */ decode(psc.consigned_flag
                     ,'Y'
                     ,null
                     ,decode(psc.matching_basis
                           ,'AMOUNT'
                           ,(decode(psc.closed_code
                                  ,'FINALLY_CLOSED'
                                  ,(decode(sign(nvl(pod.AMOUNT_delivered,0)
                                               -nvl(pod.AMOUNT_billed,0))
                                          ,1
                                          ,nvl(pod.AMOUNT_delivered,0)
                                          ,nvl(pod.AMOUNT_billed,0))) * nvl(pod.rate,1)
                                  ,(nvl(pod.amount_ordered,0)
                                   -nvl(pod.amount_cancelled,0))
                                   * nvl(pod.rate,1)))
                           ,(decode(psc.closed_code
                                   ,'FINALLY_CLOSED'
                                   ,(decode(sign(nvl(pod.quantity_delivered,0)
                                                -nvl(pod.quantity_billed,0))
                                           ,1
                                           ,nvl(pod.quantity_delivered,0)
                                           ,nvl(pod.quantity_billed,0)))
                                           *nvl(psc.price_override,0) * nvl(pod.rate,1)
                                   ,(nvl(pod.quantity_ordered,0)
                                    -nvl(pod.quantity_cancelled,0))
                                    *nvl(psc.price_override,0)
                                    *nvl(pod.rate,1)))
                            )
                     )
       ,      Decode(psc.consigned_flag, 'Y', NULL, 0)
	   ,      decode(psc.consigned_flag
	                ,'Y'
	                ,null
	                ,decode(psc.matching_basis
	                      ,'AMOUNT'
	                       ,(decode(psc.closed_code
	                              ,'FINALLY_CLOSED'
	                              ,(decode(sign(nvl(pod.AMOUNT_delivered,0)
	                                           -nvl(pod.AMOUNT_billed,0))
	                                      ,1
	                                      ,nvl(pod.AMOUNT_delivered,0)
	                                      ,nvl(pod.AMOUNT_billed,0))) * nvl(pod.rate,1)
	                              ,(nvl(pod.AMOUNT_ordered,0)
	                               -nvl(pod.AMOUNT_cancelled,0))
	                               *nvl(pod.rate,1)))
	                       ,(decode(psc.closed_code
	                              ,'FINALLY_CLOSED'
	                              ,(decode(sign(nvl(pod.quantity_delivered,0)
	                                           -nvl(pod.quantity_billed,0))
	                                      ,1
	                                      ,nvl(pod.quantity_delivered,0)
	                                      ,nvl(pod.quantity_billed,0)))
	                                      *nvl(psc.price_override,0)
	                                      *nvl(pod.rate,1)
	                              ,(nvl(pod.quantity_ordered,0)
	                              -nvl(pod.quantity_cancelled,0))
	                              *nvl(psc.price_override,0)
	                              *nvl(pod.rate,1)))
	                         )
	                   )
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
	   ,    decode(psc.consigned_flag
	              ,'Y'
	              ,null
	              ,decode(psc.value_basis
	                    ,'QUANTITY'
	                    ,pod.quantity_ordered
	                    ,null
	                    )
	              )
       ,    pod.po_distribution_id
       ,    phc.type_lookup_code
       ,    pod.creation_date
       ,    plc.item_id
       ,    plc.item_description
       ,    plc.category_id
       ,    phc.vendor_site_id
       ,    phc.vendor_id
       ,    pod.deliver_to_person_id
       ,    psc.ship_to_location_id
       ,    psc.ship_to_organization_id
       ,    psc.org_id
       ,    phc.agent_id
       ,    pod.project_id
       ,    pod.task_id
       ,    gl.currency_code
       ,    phc.rate_type
       ,    nvl(phc.rate_date, pod.creation_date)
       ,    pod.code_combination_id
       ,    NULL
       ,    NULL
       ,    pod.rate
       ,    NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
		      phc.approved_date)
       ,    POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,    fnd_global.user_id
       ,    p_start_time
       ,    fnd_global.user_id
       ,    p_start_time
       ,    fnd_global.login_id
       ,    fnd_global.conc_request_id
       ,    fnd_global.prog_appl_id
       ,    fnd_global.conc_program_id
       ,    p_start_time
       FROM poa_edw_po_dist_inc   inc,
            gl_sets_of_books      gl
       ,    po_distributions_all  pod
       ,    po_line_locations_all psc
       ,    po_lines_all          plc
       ,    po_headers_all        phc
       ,    po_headers_all        ga
       ,    po_doc_style_headers  style
       ,    hr_organization_information  hro
       WHERE inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and   phc.po_header_id        = plc.po_header_id
       and   plc.po_line_id          = psc.po_line_id
       and   psc.line_location_id    = pod.line_location_id
       and   psc.shipment_type       = 'STANDARD'
       and   phc.style_id            = style.style_id
       and   nvl(style.progress_payment_flag,'N') = 'N'
       and   psc.approved_flag       = 'Y'
       and   plc.contract_id        is NULL
	 AND   plc.from_header_id        = ga.po_header_id(+)
	 AND   Nvl(ga.global_agreement_flag, 'N') = 'N'
       and   gl.set_of_books_id      = pod.set_of_books_id
       and   plc.item_id             is not null
       and   pod.creation_date       is not null
       and   inc.batch_id            = p_batch_no
       and   to_number(hro.organization_id) = psc.ship_to_organization_id
       and   hro.org_information_context = 'Accounting Information'
       and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
       and   not exists (SELECT 'blanket item'
                FROM po_lines_all pl
                ,    po_headers_all ph
                WHERE ph.type_lookup_code = 'BLANKET'
                and   ph.po_header_id = pl.po_header_id
                and   nvl(pl.unit_meas_lookup_code,
                                 nvl(plc.unit_meas_lookup_code, '-1'))
                               = nvl(plc.unit_meas_lookup_code, '-1')
                and   pod.creation_date between
                                        nvl(ph.start_date, pod.creation_date)
                                    and nvl(ph.end_date, pod.creation_date)
                and   trunc(pod.creation_date) <= nvl(pl.expiration_date, pod.creation_date)
                and   pl.item_id = plc.item_id
                and   nvl(pl.item_revision, nvl(plc.item_revision, '-1'))
                                 = nvl(plc.item_revision, '-1')
                and (
                     (nvl(ph.global_agreement_flag,'N') = 'N'
                      and ph.org_id = to_number(hro.org_information3)
                     )
                     or
                     (ph.global_agreement_flag = 'Y'
                      and exists
                      (select 'enabled'
                       from po_ga_org_assignments poga
                       where poga.po_header_id = ph.po_header_id
                       and poga.enabled_flag = 'Y'
                       and ((poga.purchasing_org_id in
                             (select  tfh.start_org_id
                              from mtl_transaction_flow_headers tfh,
                                   financials_system_params_all fsp1,
                                   financials_system_params_all fsp2
                              where pod.creation_date between nvl(tfh.start_date,pod.creation_date)
                                                            and nvl(tfh.end_date,pod.creation_date)
                              and tfh.flow_type = 2
                              and fsp1.org_id = tfh.start_org_id
                              and fsp1.purch_encumbrance_flag = 'N'
                              and fsp2.org_id = tfh.end_org_id
                              and fsp2.purch_encumbrance_flag = 'N'
                              and (
                                   (tfh.qualifier_code is null) or
                                   (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id)
                                  )
                              and tfh.end_org_id = to_number(hro.org_information3)
                              and (
                                   (tfh.organization_id = psc.ship_to_organization_id) or
                                   (tfh.organization_id is null)
                                  )
                             )
                            )
                            or poga.purchasing_org_id = to_number(hro.org_information3)
                           )
                      )
                     )
                    )
             )
      );


    /* Go through all the rows which we considered as leakages to
     * calculate their potential savings
     */

    POA_LOG.debug_line('Opening cursor c_std_po');
    POA_LOG.debug_line(' ');

    select sysdate into l_start_time from dual;
    begin
      select warehouse_currency_code,
             rate_type
             into
             v_edw_global_currency_code,
             v_edw_global_rate_type
      from edw_local_system_parameters;
      if( v_edw_global_currency_code is null
          or v_edw_global_rate_type is null
        )
      then
          v_edw_global_currency_code := 'USD';
          v_edw_global_rate_type := 'Corporate';
      end if;
    exception
    when others then
      v_edw_global_currency_code := 'USD';
      v_edw_global_rate_type := 'Corporate';
    end;
    FOR v_cursor_inst IN c_std_po(p_batch_no) LOOP

        x_iteration := x_iteration + 1;

        v_item_id := v_cursor_inst.item_id;
        v_item_revision := v_cursor_inst.item_revision;
        v_category_id := v_cursor_inst.category_id;
        v_quantity := v_cursor_inst.quantity;
        v_unit_meas_lookup_code := v_cursor_inst.unit_meas_lookup_code;
        v_creation_date := v_cursor_inst.creation_date;
        v_currency_code := v_cursor_inst.currency_code;
        v_po_distribution_id := v_cursor_inst.po_distribution_id;
        v_ship_to_location_id := v_cursor_inst.ship_to_location_id;
        v_price_override := v_cursor_inst.price_override;
        v_need_by_date := v_cursor_inst.need_by_date;
        v_org_id := v_cursor_inst.org_id;
        v_ship_to_organization_id := v_cursor_inst.ship_to_organization_id;
        v_ship_to_ou := v_cursor_inst.org_information3;
        v_rate_date := v_cursor_inst.rate_date;
        --v_rate_type := v_cursor_inst.rate_type;

      v_lowest_possible_price := poa_savings_sav.get_lowest_possible_price(
                    v_creation_date,
                    v_quantity,
                    v_unit_meas_lookup_code,
                    v_currency_code,
                    v_item_id,
                    v_item_revision,
                    v_category_id,
                    v_ship_to_location_id,
                    v_need_by_date,
                    v_org_id,
                    v_ship_to_organization_id,
                    v_ship_to_ou,
                    v_rate_date,
                    v_edw_global_rate_type,
                    v_edw_global_currency_code);

      v_lowest_possible_price := v_lowest_possible_price
                                 * get_currency_conv_rate(v_edw_global_currency_code,
                                                                v_currency_code,
                                                                v_rate_date,
                                                                v_edw_global_rate_type);
--      POA_LOG.debug_line('Lowest price determined using: creation_date=' ||
--                    v_creation_date || ', quantity=' ||
--                    v_quantity || ', unit of measure=' ||
--                    v_unit_meas_lookup_code || ', currency=' ||
--                    v_currency_code || ', item id=' ||
--                    v_item_id || ', item revision=' ||
--                    v_item_revision || ', category id=' ||
--                    v_category_id || ', ship to location_id=' ||
--                    v_ship_to_location_id);
--      POA_LOG.debug_line(' ');

      poa_savings_np.insert_npcontract(v_po_distribution_id,
                                       v_lowest_possible_price, p_start_time);

--      POA_LOG.debug_line('Inserting np contract for distribution_id=' ||
--                 v_po_distribution_id || ', lowest possible price=' ||
--                 v_lowest_possible_price);
--      POA_LOG.debug_line(' ');

    END LOOP;

    select sysdate into l_end_time from dual;
    POA_LOG.put_line('Populate_npcontract: non one-time items with open blankets in batch '||p_batch_no || ' are ' || x_iteration);

    POA_LOG.put_line('Populate_npcontract: time to calculate lowest price: '||
    poa_log.duration(l_end_time - l_start_time) || ', start time: ' ||
    to_char(l_start_time, 'MM/DD/YYYY HH24:MI:SS') || ', end time: ' ||
    to_char(l_end_time, 'MM/DD/YYYY HH24:MI:SS'));

    POA_LOG.debug_line('Populate_npcontract exit');
  --
  EXCEPTION
    WHEN others THEN
     v_buf := 'Non Contract function: ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;
      ROLLBACK;

      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');

      RAISE;
  --
  END populate_npcontract;

  /*
    NAME
     insert_npcontract -
    DESCRIPTION

  */
  --
  PROCEDURE insert_npcontract (p_po_distribution_id IN NUMBER,
                   p_lowest_price IN NUMBER,
                   p_start_time IN DATE)
  IS
  --

  v_npcontract_purchase_amount  NUMBER;
  v_npcontract_purchase_amount2  NUMBER;
  v_potential_savings           NUMBER;
  v_quantity_ordered            NUMBER;
  v_po_distribution_id          NUMBER;
  v_type_lookup_code            VARCHAR2(25) := NULL;
  v_creation_date               DATE;

  v_item_id                     NUMBER;
  v_item_description            VARCHAR2(240) := NULL;
  v_category_id                 NUMBER;
  v_vendor_site_id              NUMBER;
  v_vendor_id                   NUMBER;
  v_deliver_to_person_id        NUMBER;
  v_ship_to_location_id         NUMBER;
  v_ship_to_organization_id     NUMBER;
  v_org_id                      NUMBER;
  v_agent_id                    NUMBER;
  v_project_id                  NUMBER;
  v_task_id                     NUMBER;
  v_rate_type                   VARCHAR2(30) := NULL;
  v_rate_date                   DATE;
  v_rowcount                    BINARY_INTEGER := 0;
  v_currency_code               VARCHAR2(15) := NULL;
  v_approved_date               DATE;
  v_rate                        NUMBER;
  v_Currency_Conv_Rate          NUMBER;
  v_cost_center_id              NUMBER;

  v_buf                         VARCHAR2(240) := NULL;
  x_progress                    VARCHAR2(3) := NULL;


  BEGIN

    POA_LOG.debug_line('Insert_npcontract: entered');
    x_progress := '030';

    SELECT  decode(psc.consigned_flag, 'Y', null, decode(psc.closed_code, 'FINALLY_CLOSED',
                (decode(sign(nvl(pod.quantity_delivered,0)
                           - nvl(pod.quantity_billed,0)),
                   1, nvl(pod.quantity_delivered,0), nvl(pod.quantity_billed,0)))
                * nvl(psc.price_override,0) * nvl(pod.rate, 1),
                (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                * nvl(psc.price_override,0) * nvl(pod.rate,1)))
      ,     decode(psc.consigned_flag, 'Y', null, decode(psc.closed_code, 'FINALLY_CLOSED',
                (decode(sign(nvl(pod.quantity_delivered,0)
                           - nvl(pod.quantity_billed,0)),
                    1, nvl(pod.quantity_delivered,0), nvl(pod.quantity_billed,0)))
                * (nvl(psc.price_override,0)-(decode(nvl(p_lowest_price,0),0,
                                                    nvl(psc.price_override,0),
                                                    nvl(p_lowest_price,0))))
                * nvl(pod.rate,1),
                (nvl(pod.quantity_ordered,0) - nvl(pod.quantity_cancelled,0))
                * (nvl(psc.price_override,0)-(decode(nvl(p_lowest_price,0), 0,
                                                nvl(psc.price_override,0),
                                                nvl(p_lowest_price,0))))
                * nvl(pod.rate,1)))
      ,    decode(psc.consigned_flag, 'Y', null, pod.quantity_ordered)
      ,    pod.po_distribution_id
      ,    phc.type_lookup_code
      ,    pod.creation_date
      ,    plc.item_id
      ,    plc.item_description
      ,    plc.category_id
      ,    phc.vendor_site_id
      ,    phc.vendor_id
      ,    pod.deliver_to_person_id
      ,    psc.ship_to_location_id
      ,    psc.ship_to_organization_id
      ,    psc.org_id
      ,    phc.agent_id
      ,    pod.project_id
      ,    pod.task_id
      ,    gl.currency_code
      ,    phc.rate_type
      ,    nvl(phc.rate_date, pod.creation_date)
      ,    pod.code_combination_id
      ,    pod.rate
      ,    NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
		      phc.approved_date)
      ,    POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
      INTO v_npcontract_purchase_amount,
        v_potential_savings,
        v_quantity_ordered,
        v_po_distribution_id,
        v_type_lookup_code,
        v_creation_date,
        v_item_id,
        v_item_description,
        v_category_id,
        v_vendor_site_id,
        v_vendor_id,
        v_deliver_to_person_id,
        v_ship_to_location_id,
        v_ship_to_organization_id,
        v_org_id,
        v_agent_id,
        v_project_id,
        v_task_id,
        v_currency_code,
        v_rate_type,
        v_rate_date,
        v_cost_center_id,
        v_rate,
        v_approved_date,
        v_Currency_Conv_Rate
      FROM  gl_sets_of_books gl
      ,     po_distributions_all pod
      ,     po_line_locations_all psc
      ,     po_lines_all plc
      ,     po_headers_all phc
      WHERE pod.po_distribution_id  = p_po_distribution_id
      and   pod.line_location_id    = psc.line_location_id
      and   psc.po_line_id          = plc.po_line_id
      and   plc.po_header_id        = phc.po_header_id
      and   gl.set_of_books_id      = pod.set_of_books_id
      and   nvl(pod.distribution_type,'-99') <> 'AGREEMENT';


      x_progress := '040';

      SELECT count(*) INTO v_rowcount FROM poa_bis_savings
      WHERE distribution_transaction_id = v_po_distribution_id;

      --If a row already exists, then delete it and reinsert the
      --row with the updated information

      IF (v_rowcount > 0) THEN
--        POA_LOG.debug_line('  v_rowcount is: ' || v_rowcount);

        x_progress := '050';
        DELETE FROM poa_bis_savings
        WHERE distribution_transaction_id = v_po_distribution_id;
      END IF;

      x_progress := '060';

      if (v_npcontract_purchase_amount IS NOT NULL) then
	  v_npcontract_purchase_amount2 := 0;
      else
	  v_npcontract_purchase_amount2 := NULL;
      end if;

      INSERT INTO poa_bis_savings
       (    purchase_amount
       ,    contract_amount
       ,    non_contract_amount
       ,    pot_contract_amount
       ,    potential_saving
       ,    total_purchase_qty
       ,    distribution_transaction_id
       ,    document_type_code
       ,    purchase_creation_date
       ,    item_id
       ,    item_description
       ,    category_id
       ,    supplier_site_id
       ,    supplier_id
       ,    requestor_id
       ,    ship_to_location_id
       ,    ship_to_organization_id
       ,    operating_unit_id
       ,    buyer_id
       ,    project_id
       ,    task_id
       ,    currency_code
       ,    rate_type
       ,    rate_date
       ,    cost_center_id
       ,    account_id
       ,    company_id
       ,    rate
       ,    approved_date
       ,    Currency_Conv_Rate
       ,    created_by
       ,    creation_date
       ,    last_updated_by
       ,    last_update_date
       ,    last_update_login
       ,    request_id
       ,    program_application_id
       ,    program_id
       ,    program_update_date)
       VALUES
       (v_npcontract_purchase_amount
       ,v_npcontract_purchase_amount2
       ,v_npcontract_purchase_amount2
       ,v_npcontract_purchase_amount
       ,v_potential_savings
       ,v_quantity_ordered
       ,v_po_distribution_id
       ,v_type_lookup_code
       ,v_creation_date
       ,v_item_id
       ,v_item_description
       ,v_category_id
       ,v_vendor_site_id
       ,v_vendor_id
       ,v_deliver_to_person_id
       ,v_ship_to_location_id
       ,v_ship_to_organization_id
       ,v_org_id
       ,v_agent_id
       ,v_project_id
       ,v_task_id
       ,v_currency_code
       ,v_rate_type
       ,v_rate_date
       ,v_cost_center_id
       ,NULL
       ,NULL
       ,v_rate
       ,v_approved_date
       ,v_Currency_Conv_Rate
       ,fnd_global.user_id
       ,p_start_time
       ,fnd_global.user_id
       ,p_start_time
       ,fnd_global.login_id
       ,fnd_global.conc_request_id
       ,fnd_global.prog_appl_id
       ,fnd_global.conc_program_id
       ,p_start_time);


  --
  EXCEPTION
    WHEN others THEN
     v_buf := 'Insert non contract function: ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;

      ROLLBACK;
      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');

      RAISE;
  END insert_npcontract;

 FUNCTION get_currency_conv_rate  (p_from_currency_code po_headers_all.currency_code%type,
                                   p_to_currency_code   VARCHAR2,
                                   p_rate_date          DATE,
                                   p_rate_type          edw_local_system_parameters.rate_type%type)  RETURN NUMBER
 IS
 BEGIN

   if(p_from_currency_code = l_from_currency_code
      and p_to_currency_code = l_to_currency_code
      and p_rate_date = l_curr_conv_rate_date
      and p_rate_type = l_curr_conv_rate_type)
   then
     return l_currency_conv_rate;
   else
     l_from_currency_code := p_from_currency_code;
     l_to_currency_code := p_to_currency_code;
     l_curr_conv_rate_date := p_rate_date;
     l_curr_conv_rate_type := p_rate_type;
     l_currency_conv_rate := gl_currency_api.get_rate_sql(l_from_currency_code,
                                                          l_to_currency_code,
                                                          l_curr_conv_rate_date,
                                                          l_curr_conv_rate_type
                                                         );
    return l_currency_conv_rate;
  end if;

 END get_currency_conv_rate;

END poa_savings_np;

/
