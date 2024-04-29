--------------------------------------------------------
--  DDL for Package Body POA_SAVINGS_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SAVINGS_CON" AS
/* $Header: poasvp2b.pls 120.3 2006/02/13 01:21:59 sdiwakar noship $ */

  /*
    NAME
      populate_contract -
    DESCRIPTION
     main function for populating poa_savings fact table
     for Oracle Purchasing with contract purchases information
  */
  --
  PROCEDURE populate_contract (p_start_date IN DATE,
                               p_end_date IN DATE,
                               p_start_time IN DATE,
                               p_batch_no IN NUMBER)
  IS
  --
  x_progress                   VARCHAR2(3) := NULL;
  v_buf                        VARCHAR2(240) := NULL;
  --
  BEGIN

    POA_LOG.debug_line('Populate_contract: entered');

     /* Insert all releases created against blankets and planned
      * agreements
      */

     x_progress := '010';
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
	   (SELECT    decode(psc.consigned_flag
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
	                                          ,nvl(pod.amount_billed,0)))
	                                          *nvl(pod.rate,1)
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
	   ,          decode(psc.consigned_flag
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
	                                  ,nvl(pod.amount_billed,0)))
	                                  *nvl(pod.rate,1)
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
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     decode(psc.consigned_flag
                   ,'Y'
                   ,null
                   ,decode(psc.value_basis
                          ,'QUANTITY'
                          ,pod.quantity_ordered
                          ,null
                          )
                   )
       ,     pod.po_distribution_id
       ,     phc.type_lookup_code
       ,     pod.creation_date
       ,     plc.item_id
       ,     plc.item_description
       ,     plc.category_id
       ,     phc.vendor_site_id
       ,     phc.vendor_id
       ,     pod.deliver_to_person_id
       ,     psc.ship_to_location_id
       ,     psc.ship_to_organization_id
       ,     psc.org_id
       ,     por.agent_id
       ,     pod.project_id
       ,     pod.task_id
       ,     gl.currency_code
       ,     phc.rate_type
       ,     nvl(phc.rate_date, pod.creation_date)
       ,     pod.code_combination_id
       ,     NULL
       ,     NULL
       ,     pod.rate
       ,     NVL(POA_OLTP_GENERIC_PKG.get_approved_date_por(pod.creation_date, por.po_release_id),
		      por.approved_date)
       ,     POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.login_id
       ,     fnd_global.conc_request_id
       ,     fnd_global.prog_appl_id
       ,     fnd_global.conc_program_id
       ,     p_start_time
       FROM  poa_edw_po_dist_inc   inc,
             gl_sets_of_books      gl
       ,     po_distributions_all  pod
       ,     po_line_locations_all psc
       ,     po_lines_all          plc
       ,     po_headers_all        phc
       ,     po_releases_all       por
       WHERE     inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and       phc.po_header_id        = plc.po_header_id
       and       plc.po_line_id          = psc.po_line_id
       and       psc.line_location_id    = pod.line_location_id
       and       pod.po_release_id       = por.po_release_id
       and       gl.set_of_books_id      = pod.set_of_books_id
       and       psc.shipment_type       in ('BLANKET', 'SCHEDULED')
       and       psc.approved_flag 	 = 'Y'
       and       nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
       and       pod.creation_date       is not null
       and       inc.batch_id            = p_batch_no);

     /* Insert standard POs created against contracts */

     x_progress := '020';
     INSERT into poa_bis_savings
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
	   (SELECT decode(psc.consigned_flag
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
	                               ,nvl(pod.amount_billed,0)))
	                               *nvl(pod.rate,1)
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
	                                      ,nvl(pod.amount_billed,0)))
	                                      *nvl(pod.rate,1)
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
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     decode(psc.consigned_flag
                   ,'Y'
                   ,null
                   ,decode(psc.value_basis
                          ,'QUANTITY'
                          ,pod.quantity_ordered
                          ,null
                          )
                   )
       ,     pod.po_distribution_id
       ,     phc.type_lookup_code
       ,     pod.creation_date
       ,     plc.item_id
       ,     plc.item_description
       ,     plc.category_id
       ,     phc.vendor_site_id
       ,     phc.vendor_id
       ,     pod.deliver_to_person_id
       ,     psc.ship_to_location_id
       ,     psc.ship_to_organization_id
       ,     psc.org_id
       ,     phc.agent_id
       ,     pod.project_id
       ,     pod.task_id
       ,     gl.currency_code
       ,     phc.rate_type
       ,     nvl(phc.rate_date, pod.creation_date)
       ,     pod.code_combination_id
       ,     NULL
       ,     NULL
       ,     pod.rate
       ,     NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
		      phc.approved_date)
       ,     POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.login_id
       ,     fnd_global.conc_request_id
       ,     fnd_global.prog_appl_id
       ,     fnd_global.conc_program_id
       ,     p_start_time
       FROM  poa_edw_po_dist_inc   inc,
             gl_sets_of_books      gl
       ,     po_distributions_all  pod
       ,     po_line_locations_all psc
       ,     po_lines_all          plc
       ,     po_headers_all        phc
       WHERE     inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and       phc.po_header_id        = plc.po_header_id
       and       plc.po_line_id          = psc.po_line_id
       and       psc.line_location_id    = pod.line_location_id
       and       gl.set_of_books_id      = pod.set_of_books_id
       and       psc.shipment_type       = 'STANDARD'
       and       plc.contract_id        is not null
       and       psc.approved_flag       = 'Y'
       and       nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
       and       pod.creation_date       is not null
       and       inc.batch_id            = p_batch_no);

     /* Insert standard POs created against global agreements */

     x_progress := '020';
     INSERT into poa_bis_savings
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
	   (SELECT decode(psc.consigned_flag
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
	                              ,nvl(pod.amount_billed,0)))
	                              *nvl(pod.rate,1)
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
	                        *nvl(psc.price_override,0) * nvl(pod.rate,1)))
	                      )
	                  )
	   ,      decode(psc. consigned_flag
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
	                              ,nvl(pod.amount_billed,0)))
	                              *nvl(pod.rate,1)
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
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     decode(psc. consigned_flag
                   ,'Y'
                   ,null
                   ,decode(psc.value_basis
                          ,'QUANTITY'
                          ,pod.quantity_ordered
                          ,null
                         )
                   )
       ,     pod.po_distribution_id
       ,     phc.type_lookup_code
       ,     pod.creation_date
       ,     plc.item_id
       ,     plc.item_description
       ,     plc.category_id
       ,     phc.vendor_site_id
       ,     phc.vendor_id
       ,     pod.deliver_to_person_id
       ,     psc.ship_to_location_id
       ,     psc.ship_to_organization_id
       ,     psc.org_id
       ,     phc.agent_id
       ,     pod.project_id
       ,     pod.task_id
       ,     gl.currency_code
       ,     phc.rate_type
       ,     nvl(phc.rate_date, pod.creation_date)
       ,     pod.code_combination_id
       ,     NULL
       ,     NULL
       ,     pod.rate
       ,     NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
		      phc.approved_date)
       ,     POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.login_id
       ,     fnd_global.conc_request_id
       ,     fnd_global.prog_appl_id
       ,     fnd_global.conc_program_id
       ,     p_start_time
       FROM  poa_edw_po_dist_inc   inc,
             gl_sets_of_books      gl
       ,     po_distributions_all  pod
       ,     po_line_locations_all psc
       ,     po_lines_all          plc
       ,     po_headers_all        phc
       ,     po_headers_all        ga
       WHERE     inc.primary_key         = pod.PO_DISTRIBUTION_ID
       and       phc.po_header_id        = plc.po_header_id
       and       plc.po_line_id          = psc.po_line_id
       and       psc.line_location_id    = pod.line_location_id
       and       gl.set_of_books_id      = pod.set_of_books_id
       and       psc.shipment_type       = 'STANDARD'
       and       plc.from_header_id      = ga.po_header_id
       and       ga.global_agreement_flag = 'Y'
       and       nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
       AND       plc.contract_id IS NULL  -- in case we have both cpa and ga reference
       and       psc.approved_flag       = 'Y'
       and       pod.creation_date       is not null
       and       inc.batch_id            = p_batch_no);

    /* Insert standard POs created for Complex work procurement (R12) */
    x_progress := '020';

     insert into poa_bis_savings
     (
       purchase_amount,
       contract_amount,
       non_contract_amount,
       pot_contract_amount,
       potential_saving,
       total_purchase_qty,
       distribution_transaction_id,
       document_type_code,
       purchase_creation_date,
       item_id,
       item_description,
       category_id,
       supplier_site_id,
       supplier_id,
       requestor_id,
       ship_to_location_id,
       ship_to_organization_id,
       operating_unit_id,
       buyer_id,
       project_id,
       task_id,
       currency_code,
       rate_type,
       rate_date,
       cost_center_id,
       account_id,
       company_id,
       rate,
       approved_date,
       Currency_Conv_Rate,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date
     )
     (
       select /*+ cardinality(inc, 1) */ decode(psc.consigned_flag
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
                                      ,nvl(pod.amount_billed,0)))
                                      *nvl(pod.rate,1)
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
                                *nvl(psc.price_override,0) * nvl(pod.rate,1)))
                              )
                          )
       ,      decode(psc. consigned_flag
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
                                      ,nvl(pod.amount_billed,0)))
                                      *nvl(pod.rate,1)
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
       ,     Decode(psc.consigned_flag, 'Y', NULL, 0)
       ,     decode(psc. consigned_flag
                   ,'Y'
                   ,null
                   ,decode(psc.value_basis
                          ,'QUANTITY'
                          ,pod.quantity_ordered
                          ,null
                         )
                   )
       ,     pod.po_distribution_id
       ,     phc.type_lookup_code
       ,     pod.creation_date
       ,     plc.item_id
       ,     plc.item_description
       ,     plc.category_id
       ,     phc.vendor_site_id
       ,     phc.vendor_id
       ,     pod.deliver_to_person_id
       ,     psc.ship_to_location_id
       ,     psc.ship_to_organization_id
       ,     psc.org_id
       ,     phc.agent_id
       ,     pod.project_id
       ,     pod.task_id
       ,     gl.currency_code
       ,     phc.rate_type
       ,     nvl(phc.rate_date, pod.creation_date)
       ,     pod.code_combination_id
       ,     NULL
       ,     NULL
       ,     pod.rate
       ,     NVL(POA_OLTP_GENERIC_PKG.get_approved_date_poh(pod.creation_date, phc.po_header_id),
                      phc.approved_date)
       ,     POA_CURRENCY_PKG.get_global_currency_rate (phc.rate_type,
                    decode(phc.rate_type, 'User', gl.currency_code,
                           NVL(phc.currency_code,gl.currency_code)),
                    NVL(pod.rate_date, pod.creation_date), phc.rate)
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.user_id
       ,     p_start_time
       ,     fnd_global.login_id
       ,     fnd_global.conc_request_id
       ,     fnd_global.prog_appl_id
       ,     fnd_global.conc_program_id
       ,     p_start_time
       from  poa_edw_po_dist_inc   inc,
             gl_sets_of_books      gl
       ,     po_distributions_all  pod
       ,     po_line_locations_all psc
       ,     po_lines_all          plc
       ,     po_headers_all        phc
       ,     po_doc_style_headers  style
       where     inc.primary_key         = pod.po_distribution_id
       and       phc.po_header_id        = plc.po_header_id
       and       plc.po_line_id          = psc.po_line_id
       and       psc.line_location_id    = pod.line_location_id
       and       gl.set_of_books_id      = pod.set_of_books_id
       and       phc.style_id            = style.style_id
       and       nvl(style.progress_payment_flag,'N') = 'Y'
       and       psc.shipment_type       = 'STANDARD'
       and       plc.from_header_id      is null
       and       nvl(pod.distribution_type,'-99')  <> 'AGREEMENT'
       AND       plc.contract_id IS NULL  -- in case we have both cpa reference
       and       psc.approved_flag       = 'Y'
       and       pod.creation_date       is not null
       and       inc.batch_id            = p_batch_no);

    POA_LOG.debug_line('Populate_contract exit');
  --
  EXCEPTION
    WHEN others THEN
      v_buf := 'Contract function: ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;
      ROLLBACK;

      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');
      RAISE;
  --
  END populate_contract;
--
END poa_savings_con;

/
