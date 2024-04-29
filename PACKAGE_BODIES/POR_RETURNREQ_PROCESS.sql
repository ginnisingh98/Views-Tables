--------------------------------------------------------
--  DDL for Package Body POR_RETURNREQ_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_RETURNREQ_PROCESS" AS
/* $Header: PORRETRQB.pls 120.0.12010000.5 2014/11/24 06:57:37 uchennam noship $ */
/*===========================================================================
  FILE NAME    :         PORRETRQB.pls
  PACKAGE NAME:         POR_RETURNREQ_PROCESS

  DESCRIPTION:
      POR_RETURNREQ_PROCESS API creates a new requisition with copy of requisition lines.
      This gets called in Return Req Process in Buyer Work center when user dont want to return
      entire requisition..
 PROCEDURES: RETURNREQPROCESS

==============================================================================*/

 G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;
 G_MODULE_NAME 	       CONSTANT VARCHAR2(30) := 'ICX.PLSQL.POR_RETURNREQ_PROCES';

PROCEDURE insert_gt (p_reqlineid_in_tbl IN po_tbl_number ,p_key IN NUMBER,x_return_status OUT NOCOPY VARCHAR2,x_error_msg OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	FORALL i in 1..p_reqlineid_in_tbl.count
		 INSERT INTO PO_SESSION_GT (KEY,NUM1,NUM2) select p_key,prl.requisition_header_id,p_reqlineid_in_tbl(i)
		 from po_requisition_lines prl
		 where requisition_line_id =p_reqlineid_in_tbl(i);
   commit;
EXCEPTION
 WHEN OTHERS THEN
    x_return_status :='E';
    x_error_msg := ' Unxpected error occured '||SQLERRM;
    po_message_s.sql_error('insert_gt','10',SQLCODE);
   RAISE;
	 --COMMIT;
END;

function get_newreq_number (p_old_req in varchar2) return varchar2
IS
l_new_req_num number;
l_new_req varchar2(100);
l_segment1 varchar2(100);
BEGIN

	select to_char(max(to_number(segment1 )))
	INTO l_segment1
	from po_requisition_headers
	where SUBSTR(SEGMENT1,1,DECODE(INSTR(SEGMENT1,'.',1),0,length(SEGMENT1),INSTR(SEGMENT1,'.',1)-1))= SUBSTR(p_old_req,1,DECODE(INSTR(p_old_req,'.',1),0,length(p_old_req),INSTR(p_old_req,'.',1)-1)) ;


	SELECT SUBSTR(l_segment1,1,decode(instr(l_segment1,'.',1),0,length(l_segment1),instr(l_segment1,'.',1)-1)) ||'.' ||
              (to_number(nvl(substr(l_segment1,decode(instr(l_segment1,'.',1),0,length(l_segment1)+1,instr(l_segment1,'.',1)+1)),0)+1))
  INTO L_new_req from dual;
  return l_new_req;
EXCEPTION
WHEN OTHERS THEN
 NULL;
END;
PROCEDURE unreserve_lines(p_req_lineid IN number,x_error_msg OUT   NOCOPY  VARCHAR2,
                                x_ret_code OUT NOCOPY    VARCHAR2) IS

 CURSOR c_req_line (p_req_line_id NUMBER)
 IS
 SELECT *
 FROM po_requisition_lines
 WHERE requisition_line_id = p_req_line_id;


 l_db_reqline c_req_line%ROWTYPE;
 l_bpa_header_id NUMBER;
 l_return_status    VARCHAR2(10);
 l_doc_level        VARCHAR2(15);
 l_doc_level_id     NUMBER;
 l_po_return_code   VARCHAR2(10);
 l_online_report_id NUMBER;
 l_dist_reserved_flag VARCHAR2(2);
 l_source_enc_flag VARCHAR2(10):='Y';
 D_PACKAGE_BASE varchar2(100):= 'POR_RETURNREQ_PROCESS';
 l_module_name CONSTANT VARCHAR2(100) := 'unreserve_lines';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
BEGIN

 x_ret_code := 'S';
   IF (PO_LOG.d_proc) THEN
    PO_LOG.PROC_BEGIN(D_MODULE_BASE);
    PO_LOG.proc_begin(d_module_base, 'p_req_lineid', p_req_lineid);
   END IF;


   l_doc_level := 'LINE';
   l_doc_level_id := p_req_lineid;

  PO_CORE_S.are_any_dists_reserved(
       p_doc_type => 'REQUISITION'
    ,  p_doc_level => l_doc_level
    ,  p_doc_level_id => l_doc_level_id
    ,  x_some_dists_reserved_flag => l_dist_reserved_flag
   );

   IF NVL(l_dist_reserved_flag,'N')  <> 'Y' THEN
       IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'No eligible distributions exists for unreserve l_dist_reserved_flag',l_dist_reserved_flag);
    END IF;
   ELSE

    OPEN c_req_line(p_req_lineid);
    FETCH c_req_line INTO l_db_reqline;
    CLOSE c_req_line;

     l_bpa_header_id := l_db_reqline.blanket_po_header_id;

     IF (l_bpa_header_id IS NOT NULL) THEN
          PO_DOCUMENT_FUNDS_PVT.is_agreement_encumbered(
             x_return_status               => l_return_status
          ,  p_agreement_id                => l_bpa_header_id
          ,  x_agreement_encumbered_flag   => l_source_enc_flag
          );
     ELSE
          l_source_enc_flag := 'N';
     END IF;

     IF l_source_enc_flag = 'Y' THEN
          PO_DOCUMENT_FUNDS_PVT.do_unreserve(
                       x_return_status     => l_return_status
                    ,  p_doc_type          => 'REQUISITION'
                    ,  p_doc_subtype       => NULL
                    ,  p_doc_level         => l_doc_level
                    ,  p_doc_level_id      => l_doc_level_id
                    ,  p_use_enc_gt_flag   => 'N'
                    ,  p_validate_document => 'N'
                    ,  p_override_funds    => 'N'
                    ,  p_use_gl_date       => 'U'
                    ,  p_override_date     => SYSDATE
                    ,  p_employee_id       => NULL
                    ,  x_po_return_code    => l_po_return_code
                    ,  x_online_report_id  => l_online_report_id
                    );
               IF (l_return_status <> PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS) THEN
                   x_ret_code := 'E';
                   x_error_msg := 'Error Occured during unreserve'||'Online Report Id' ||l_online_report_id ||l_po_return_code;
                   RETURN;
               END IF;
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'l_online_report_id',l_online_report_id);
                PO_LOG.stmt(d_module_base,d_progress,'l_po_return_code',l_po_return_code);
              END IF;
     END IF;
  END IF;

  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  x_error_msg := 'Unhandled Exception'|| SQLERRM;
  X_RET_CODE := 'E';
  po_message_s.sql_error('check_unique','010',SQLCODE);
  RAISE;
END;

PROCEDURE insert_header(p_old_hdr_id NUMBER,p_new_hdr_id number,p_segment1 varchar2,x_return_status OUT NOCOPY  VARCHAR2,x_error_msg OUT NOCOPY  VARCHAR2)
IS

BEGIN
  INSERT INTO po_requisition_headers
        (requisition_header_id,preparer_id,last_update_date,last_updated_by,
         segment1,summary_flag,enabled_flag,segment2,segment3,segment4,
         segment5,last_update_login,creation_date,created_by,description,
         authorization_status,note_to_authorizer,type_lookup_code,
         attribute_category,attribute1,attribute2,attribute3,attribute4,
         attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
         attribute11,attribute12,attribute13,attribute14,attribute15,
   transferred_to_oe_flag,government_context,program_application_id,
   program_id,program_update_date,request_id,
   interface_source_code,interface_source_line_id,closed_code,emergency_po_num
        ,approved_date       /*DBI Req Fulfillment 11.5.11 */
  ,org_id     /*R12 MOAC*/
  ,tax_attribute_update_code /*<R12 eTax Integration>*/
  )    SELECT p_new_hdr_id,preparer_id,SYSDATE,fnd_global.user_id,
         p_Segment1,'N','Y',segment2,segment3,
         segment4,segment5,fnd_global.login_id,
         nvl(creation_date,SYSDATE),fnd_global.user_id,description,authorization_status,
         note_to_authorizer,type_lookup_code,attribute_category,
         attribute1,attribute2,attribute3,
         attribute4,attribute5,attribute6,
         attribute7,attribute8,attribute9,
         attribute10,attribute11,attribute12,
         attribute13,attribute14,attribute15,
         'N',government_context,program_application_id,program_id,
   program_update_date,request_id,
   interface_source_code,interface_source_line_id,NULL,emergency_po_num
   ,approved_date
  ,org_id     /*R12 MOAC*/
  ,'CREATE' /*<R12 eTax Integration>*/
      FROM po_requisition_headers
     WHERE requisition_header_id = p_old_hdr_id;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := 'E';
   po_message_s.sql_error('insert_header','10',SQLCODE);
   raise;
END;


PROCEDURE copy_distributions(p_from_req_line_id IN number,
                             p_to_req_line_id   IN number,
                             x_return_status     OUT NOCOPY   VARCHAR2,
                             x_return_msg        OUT NOCOPY   varchar2)
IS

v_progress VARCHAR2(10);
l_procedure_name VARCHAR2(100) := 'copy_distributions';
l_log_msg VARCHAR2(2000);

BEGIN

  v_progress := '000';
  x_return_status := fnd_api.G_RET_STS_SUCCESS;
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := v_progress||': Inside procedure '||l_procedure_name;
                FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                l_log_msg := 'p_from_req_line_id: ' ||p_from_req_line_id || ' p_to_req_line_id: '||p_to_req_line_id;
                FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_msg := NULL;

      INSERT INTO po_req_distributions_all (
                  distribution_id,
                  last_update_date,
                  last_updated_by,
                  requisition_line_id,
                  set_of_books_id,
                  code_combination_id,
                  req_line_quantity,
                  last_update_login,
                  creation_date,
                  created_by,
                  encumbered_flag,
                  gl_encumbered_date,
                  gl_encumbered_period_name,
                  --gl_cancelled_date,
                  failed_funds_lookup_code,
                  encumbered_amount,
                  budget_account_id,
                  accrual_account_id,
                  variance_account_id,
                  prevent_encumbrance_flag,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13,
                  attribute14,
                  attribute15,
                  ussgl_transaction_code,
                  government_context,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date,
                  project_id,
                  task_id,
                  expenditure_type,
                  project_accounting_context,
                  expenditure_organization_id,
                  --gl_closed_date,
                  source_req_distribution_id,
                  distribution_num,
                  project_related_flag,
                  expenditure_item_date,
                  org_id,
                  allocation_type,
                  allocation_value,
                  award_id,
                  end_item_unit_number,
                  recoverable_tax,
                  nonrecoverable_tax,
                  recovery_rate,
                  tax_recovery_override_flag,
                  oke_contract_line_id,
                  oke_contract_deliverable_id,
                  req_line_amount,
                  req_line_currency_amount,
                  req_award_id,
                  event_id
                 -- line_num_display,
                  )
                 SELECT po_req_distributions_s.NEXTVAL,
                        last_update_date,
                        last_updated_by,
                        p_to_req_line_id,
                        set_of_books_id,
                        code_combination_id,
                        req_line_quantity,
                        last_update_login,
                        creation_date,
                        created_by,
                        'N',
                        trunc(sysdate),
                        gl_encumbered_period_name,
                    --    gl_cancelled_date,
                        failed_funds_lookup_code,
                        encumbered_amount,
                        budget_account_id,
                        accrual_account_id,
                        variance_account_id,
                        prevent_encumbrance_flag,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        ussgl_transaction_code,
                        government_context,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        project_id,
                        task_id,
                        expenditure_type,
                        project_accounting_context,
                        expenditure_organization_id,
                    --    gl_closed_date,
                        source_req_distribution_id,
                        distribution_num,
                        project_related_flag,
                        expenditure_item_date,
                        org_id,
                        allocation_type,
                        allocation_value,
                        award_id,
                        end_item_unit_number,
                        recoverable_tax,
                        nonrecoverable_tax,
                        recovery_rate,
                        tax_recovery_override_flag,
                        oke_contract_line_id,
                        oke_contract_deliverable_id,
                        req_line_amount,
                        req_line_currency_amount,
                        req_award_id,
                        event_id
                  FROM  po_req_distributions_all
                  WHERE requisition_line_id = p_from_req_line_id;

         v_progress := '001';

         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := v_progress||' : After inserting distribution';
                FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

EXCEPTION
WHEN OTHERS THEN

    x_return_msg := SQLERRM;
    x_return_status := FND_API.g_ret_sts_error;

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := v_progress||' : Exception at copy_distributions: '|| SQLERRM;
       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
    RAISE;
END copy_distributions;

PROCEDURE copy_req_lines(p_from_req_header_id  IN  number,
                      p_to_req_header_id   IN  number,
                      x_return_status      OUT   NOCOPY VARCHAR2,
                      x_return_msg         OUT   NOCOPY  varchar2)
IS

v_progress VARCHAR2(10);
l_procedure_name VARCHAR2(100) := 'copy_lines';
l_log_msg VARCHAR2(2000);

CURSOR line_cursor IS
SELECT requisition_line_id
FROM po_requisition_lines_all prl,
po_session_gt psg
WHERE requisition_header_id = p_from_req_header_id
AND prl.requisition_header_id = psg.num1
and prl.requisition_line_id = psg.num2;

from_req_line_id NUMBER;
to_req_line_id NUMBER;

BEGIN

  v_progress := '000';

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := v_progress||': Inside procedure '||l_procedure_name;
                FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                l_log_msg := 'p_from_req_header_id: ' ||p_from_req_header_id || ' p_to_req_header_id: '||p_to_req_header_id;
                FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_return_msg := NULL;

  OPEN line_cursor;

  LOOP
   FETCH line_cursor INTO from_req_line_id;
   EXIT WHEN line_cursor%NOTFOUND;

   SELECT po_requisition_lines_s.NEXTVAL
     INTO to_req_line_id
     FROM dual;


                INSERT INTO po_requisition_lines_all (
                        requisition_line_id,
                        requisition_header_id,
                        line_num,
                        line_type_id,
                        category_id,
                        item_description,
                        unit_meas_lookup_code,
                        unit_price,
                        quantity,
                        deliver_to_location_id,
                        to_person_id,
                        last_update_date,
                        last_updated_by,
                        source_type_code,
                        last_update_login,
                        creation_date,
                        created_by,
                        item_id,
                        item_revision,
                        quantity_delivered,
                        suggested_buyer_id,
                        encumbered_flag,
                        rfq_required_flag,
                        need_by_date,
                        line_location_id,
                        modified_by_agent_flag,
                        parent_req_line_id,
                        justification,
                        note_to_agent,
                        note_to_receiver,
                        purchasing_agent_id,
                        document_type_code,
                        blanket_po_header_id,
                        blanket_po_line_num,
                        currency_code,
                        rate_type,
                        rate_date,
                        rate,
                        currency_unit_price,
                        suggested_vendor_name,
                        suggested_vendor_location,
                        suggested_vendor_contact,
                        suggested_vendor_phone,
                        suggested_vendor_product_code,
                        un_number_id,
                        hazard_class_id,
                        must_use_sugg_vendor_flag,
                        reference_num,
                        on_rfq_flag,
                        urgent_flag,
                        cancel_flag,
                        source_organization_id,
                        source_subinventory,
                        destination_type_code,
                        destination_organization_id,
                        destination_subinventory,
                        quantity_cancelled,
                        cancel_date,
                        cancel_reason,
                        closed_code,
                        agent_return_note,
                        changed_after_research_flag,
                        vendor_id,
                        vendor_site_id,
                        vendor_contact_id,
                        research_agent_id,
                        on_line_flag,
                        wip_entity_id,
                        wip_line_id,
                        wip_repetitive_schedule_id,
                        wip_operation_seq_num,
                        wip_resource_seq_num,
                        attribute_category,
                        destination_context,
                        inventory_source_context,
                        vendor_source_context,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        bom_resource_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        ussgl_transaction_code,
                        government_context,
                        closed_reason,
                        closed_date,
                        transaction_reason_code,
                        quantity_received,
                        source_req_line_id,
                        org_id,
                        global_attribute1,
                        global_attribute2,
                        global_attribute3,
                        global_attribute4,
                        global_attribute5,
                        global_attribute6,
                        global_attribute7,
                        global_attribute8,
                        global_attribute9,
                        global_attribute10,
                        global_attribute11,
                        global_attribute12,
                        global_attribute13,
                        global_attribute14,
                        global_attribute15,
                        global_attribute16,
                        global_attribute17,
                        global_attribute18,
                        global_attribute19,
                        global_attribute20,
                        global_attribute_category,
                        kanban_card_id,
                        catalog_type,
                        catalog_source,
                        manufacturer_id,
                        manufacturer_name,
                        manufacturer_part_number,
                        requester_email,
                        requester_fax,
                        requester_phone,
                        unspsc_code ,
                        other_category_code,
                        supplier_duns,
                        tax_status_indicator,
                        pcard_flag,
                        new_supplier_flag,
                        auto_receive_flag,
                        tax_user_override_flag,
                        tax_code_id,
                        note_to_vendor,
                        oke_contract_version_id,
                        oke_contract_header_id,
                        item_source_id,
                        supplier_ref_number,
                        secondary_unit_of_measure,
                        secondary_quantity,
                        preferred_grade,
                        secondary_quantity_received,
                        secondary_quantity_cancelled,
                        vmi_flag,
                        auction_header_id,
                        auction_display_number,
                        auction_line_number,
                        reqs_in_pool_flag,
                        bid_number,
                        bid_line_number,
                        noncat_template_id,
                        suggested_vendor_contact_fax,
                        suggested_vendor_contact_email,
                        amount,
                        currency_amount,
                        labor_req_line_id,
                        job_id,
                        job_long_description,
                        contractor_status,
                        contact_information,
                        suggested_supplier_flag,
                        candidate_screening_reqd_flag,
                        assignment_end_date,
                        overtime_allowed_flag,
                        contractor_requisition_flag,
                        drop_ship_flag ,
                        candidate_first_name,
                        candidate_last_name,
                        assignment_start_date,
                        order_type_lookup_code,
                        purchase_basis,
                        matching_basis ,
                        negotiated_by_preparer_flag,
                        ship_method,
                        estimated_pickup_date,
                        supplier_notified_for_cancel,
                        base_unit_price,
                        at_sourcing_flag,
                        tax_attribute_update_code,
                        tax_name,
                        line_num_display,
                        group_line_id,
                        clm_info_flag,
                        clm_option_indicator,
                        clm_option_num,
                        clm_option_from_date,
                        clm_option_to_date,
                        clm_funded_flag,
                        clm_base_line_num,
                        conformed_line_id,
                        amendment_type,
                        amendment_status,
                        cost_constraint,
                        contract_type,
                        clm_period_perf_end_date,
    			clm_period_perf_start_date,
    			clm_option_exercised,
                        uda_template_id
                        --,fund_source_not_known,
                        --clm_mipr_obligation_type
                  )
                SELECT  to_req_line_id,
                        p_to_req_header_id,
                        prl.line_num,
                        prl.line_type_id,
                        prl.category_id,
                        prl.item_description,
                        prl.unit_meas_lookup_code,
                        prl.unit_price,
                        prl.quantity,
                        prl.deliver_to_location_id,
                        prl.to_person_id,
                        prl.last_update_date,
                        prl.last_updated_by,
                        prl.source_type_code,
                        prl.last_update_login,
                        prl.creation_date,
                        prl.created_by,
                        prl.item_id,
                        prl.item_revision,
                        prl.quantity_delivered,
                        prl.suggested_buyer_id,
                        prl.encumbered_flag,
                        prl.rfq_required_flag,
                        prl.need_by_date,
                        prl.line_location_id,
                        prl.modified_by_agent_flag,
                        prl.parent_req_line_id,
                        prl.justification,
                        prl.note_to_agent,
                        prl.note_to_receiver,
                        prl.purchasing_agent_id,
                        prl.document_type_code,
                        prl.blanket_po_header_id,
                        prl.blanket_po_line_num,
                        prl.currency_code,
                        prl.rate_type,
                        prl.rate_date,
                        prl.rate,
                        prl.currency_unit_price,
                        prl.suggested_vendor_name,
                        prl.suggested_vendor_location,
                        prl.suggested_vendor_contact,
                        prl.suggested_vendor_phone,
                        prl.suggested_vendor_product_code,
                        prl.un_number_id,
                        prl.hazard_class_id,
                        prl.must_use_sugg_vendor_flag,
                        prl.reference_num,
                        prl.on_rfq_flag,
                        prl.urgent_flag,
                        prl.cancel_flag,
                        prl.source_organization_id,
                        prl.source_subinventory,
                        prl.destination_type_code,
                        prl.destination_organization_id,
                        prl.destination_subinventory,
                        prl.quantity_cancelled,
                        prl.cancel_date,
                        prl.cancel_reason,
                        prl.closed_code,
                        prl.agent_return_note,
                        prl.changed_after_research_flag,
                        prl.vendor_id,
                        prl.vendor_site_id,
                        prl.vendor_contact_id,
                        prl.research_agent_id,
                        prl.on_line_flag,
                        prl.wip_entity_id,
                        prl.wip_line_id,
                        prl.wip_repetitive_schedule_id,
                        prl.wip_operation_seq_num,
                        prl.wip_resource_seq_num,
                        prl.attribute_category,
                        prl.destination_context,
                        prl.inventory_source_context,
                        prl.vendor_source_context,
                        prl.attribute1,
                        prl.attribute2,
                        prl.attribute3,
                        prl.attribute4,
                        prl.attribute5,
                        prl.attribute6,
                        prl.attribute7,
                        prl.attribute8,
                        prl.attribute9,
                        prl.attribute10,
                        prl.attribute11,
                        prl.attribute12,
                        prl.attribute13,
                        prl.attribute14,
                        prl.attribute15,
                        prl.bom_resource_id,
                        prl.request_id,
                        prl.program_application_id,
                        prl.program_id,
                        prl.program_update_date,
                        prl.ussgl_transaction_code,
                        prl.government_context,
                        prl.closed_reason,
                        prl.closed_date,
                        prl.transaction_reason_code,
                        prl.quantity_received,
                        prl.source_req_line_id,
                        prl.org_id,
                        prl.global_attribute1,
                        prl.global_attribute2,
                        prl.global_attribute3,
                        prl.global_attribute4,
                        prl.global_attribute5,
                        prl.global_attribute6,
                        prl.global_attribute7,
                        prl.global_attribute8,
                        prl.global_attribute9,
                        prl.global_attribute10,
                        prl.global_attribute11,
                        prl.global_attribute12,
                        prl.global_attribute13,
                        prl.global_attribute14,
                        prl.global_attribute15,
                        prl.global_attribute16,
                        prl.global_attribute17,
                        prl.global_attribute18,
                        prl.global_attribute19,
                        prl.global_attribute20,
                        prl.global_attribute_category,
                        prl.kanban_card_id,
                        prl.catalog_type,
                        prl.catalog_source,
                        prl.manufacturer_id,
                        prl.manufacturer_name,
                        prl.manufacturer_part_number,
                        prl.requester_email,
                        prl.requester_fax,
                        prl.requester_phone,
                        prl.unspsc_code ,
                        prl.other_category_code,
                        prl.supplier_duns,
                        prl.tax_status_indicator,
                        prl.pcard_flag,
                        prl.new_supplier_flag,
                        prl.auto_receive_flag,
                        prl.tax_user_override_flag,
                        prl.tax_code_id,
                        prl.note_to_vendor,
                        prl.oke_contract_version_id,
                        prl.oke_contract_header_id,
                        prl.item_source_id,
                        prl.supplier_ref_number,
                        prl.secondary_unit_of_measure,
                        prl.secondary_quantity,
                        prl.preferred_grade,
                        prl.secondary_quantity_received,
                        prl.secondary_quantity_cancelled,
                        prl.vmi_flag,
                        prl.auction_header_id,
                        prl.auction_display_number,
                        prl.auction_line_number,
                        prl.reqs_in_pool_flag,
                        prl.bid_number,
                        prl.bid_line_number,
                        prl.noncat_template_id,
                        prl.suggested_vendor_contact_fax,
                        prl.suggested_vendor_contact_email,
                        prl.amount,
                        prl.currency_amount,
                        prl.labor_req_line_id,
                        prl.job_id,
                        prl.job_long_description,
                        prl.contractor_status,
                        prl.contact_information,
                        prl.suggested_supplier_flag,
                        prl.candidate_screening_reqd_flag,
                        prl.assignment_end_date,
                        prl.overtime_allowed_flag,
                        prl.contractor_requisition_flag,
                        prl.drop_ship_flag ,
                        prl.candidate_first_name,
                        prl.candidate_last_name,
                        prl.assignment_start_date,
                        prl.order_type_lookup_code,
                        prl.purchase_basis,
                        prl.matching_basis ,
                        prl.negotiated_by_preparer_flag,
                        prl.ship_method,
                        prl.estimated_pickup_date,
                        prl.supplier_notified_for_cancel,
                        prl.base_unit_price,
                        prl.at_sourcing_flag,
                        prl.tax_attribute_update_code,
                        prl.tax_name,
                        prl.line_num_display,
                        prl.group_line_id,
                        prl.clm_info_flag,
                        prl.clm_option_indicator,
                        prl.clm_option_num,
                        prl.clm_option_from_date,
                        prl.clm_option_to_date,
                        prl.clm_funded_flag,
                        prl.clm_base_line_num,
                        from_req_line_id,
                        prl.amendment_type,
                        prl.amendment_status,
                        prl.cost_constraint,
                        prl.contract_type,
                        prl.clm_period_perf_end_date,
    			prl.clm_period_perf_start_date,
    			prl.clm_option_exercised,
	                prl.uda_template_id
                        --,prl.fund_source_not_known,
                        --clm_mipr_obligation_type
                  FROM  po_requisition_lines_all prl
                  WHERE prl.requisition_line_id = from_req_line_id
                  ;

                  v_progress := '002';

                  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        l_log_msg := v_progress||' : After inserting line: '||to_req_line_id;
                        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                  END IF;

                  /* Copying header level attachments */

                  fnd_attached_documents2_pkg.copy_attachments('REQ_LINES',
                                                                    ''||from_req_line_id,
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    'REQ_LINES',
                                                                    ''||to_req_line_id,
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    fnd_global.user_id,
                                                                    fnd_global.login_id,
                                                                    '',
                                                                    '',
                                                                    '');

                  v_progress := '003';
                  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    l_log_msg := v_progress||' : After copying line level attachments';
                    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                  END IF;

                /* Copying header level attachments - end */

                /* Copying One Time location */
                   v_progress := '004';

                   INSERT INTO por_item_attribute_values (
                                item_type,
                                requisition_header_id,
                                requisition_line_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                org_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                last_update_login
                                )
                        SELECT  item_type,
                                p_to_req_header_id,
                                to_req_line_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                org_id,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date,
                                last_update_login
                           FROM por_item_attribute_values
                          WHERE requisition_header_id = p_from_req_header_id
                            AND requisition_line_id = from_req_line_id
                            AND item_type = 'AD_HOC_LOCATION';

                  v_progress := '005';

                  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        l_log_msg := v_progress||' : After copying one time location for line: '||to_req_line_id;
                        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                  END IF;

                /* Copying One Time location - end */

                      copy_distributions(from_req_line_id,to_req_line_id,x_return_status,x_return_msg);

                      unreserve_lines(from_req_line_id ,l_log_msg ,
                                X_RETURN_STATUS );
									    IF x_return_status <> 'S' THEN
									      return;
									    END IF;

                  v_progress := '006';

                  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        l_log_msg := v_progress||' : After inserting distributions for line: '||to_req_line_id;
                        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
                  END IF;

    END LOOP;

    v_progress := '007';

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        l_log_msg := v_progress||' : After insert into po_requisition_lines_all and po_req_distributions_all';
                        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

EXCEPTION
WHEN OTHERS THEN

    x_return_msg := SQLERRM;
    x_return_status := FND_API.g_ret_sts_error;

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := v_progress||' : Exception at copy_lines: '|| SQLERRM;
       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
	  RAISE;
END copy_req_lines;

PROCEDURE reserve_lines(p_reqlineid_tbl IN po_tbl_number,x_error_msg OUT   NOCOPY  VARCHAR2,
                                x_ret_code OUT NOCOPY    VARCHAR2) IS

 CURSOR c_req_line (p_req_line_id NUMBER)
 IS
 SELECT *
 FROM po_requisition_lines
 WHERE requisition_line_id = p_req_line_id;


 l_db_reqline c_req_line%ROWTYPE;
 l_bpa_header_id NUMBER;
 l_return_status    VARCHAR2(10);
 l_doc_level        VARCHAR2(15);
 l_doc_level_id     NUMBER;
 l_po_return_code   VARCHAR2(10);
 l_online_report_id NUMBER;
 l_dist_reserved_flag VARCHAR2(2);
 l_source_enc_flag VARCHAR2(10):='Y';
 D_PACKAGE_BASE varchar2(100):= 'POR_RETURNREQ_PROCESS';
 l_module_name CONSTANT VARCHAR2(100) := 'reserve_lines';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
BEGIN

 x_ret_code := 'S';
 FOR i in 1..p_reqlineid_tbl.count
 LOOP
 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_reqlineid_tbl(i)', p_reqlineid_tbl(i));
   END IF;

    OPEN c_req_line(p_reqlineid_tbl(i));
    FETCH c_req_line INTO l_db_reqline;
    CLOSE c_req_line;
   l_doc_level := 'HEADER';

   l_doc_level_id := l_db_reqline.requisition_header_id;
/*
  PO_CORE_S.are_any_dists_reserved(
       p_doc_type => 'REQUISITION'
    ,  p_doc_level => l_doc_level
    ,  p_doc_level_id => l_doc_level_id
    ,  x_some_dists_reserved_flag => l_dist_reserved_flag
   );*/

   IF NVL(l_dist_reserved_flag,'N')  <> 'Y' THEN
       IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'No eligible distributions exists for reserve l_dist_reserved_flag',l_dist_reserved_flag);
    END IF;
   ELSE

    OPEN c_req_line(p_reqlineid_tbl(i));
    FETCH c_req_line INTO l_db_reqline;
    CLOSE c_req_line;

     l_bpa_header_id := l_db_reqline.blanket_po_header_id;

     IF (l_bpa_header_id IS NOT NULL) THEN
          PO_DOCUMENT_FUNDS_PVT.is_agreement_encumbered(
             x_return_status               => l_return_status
          ,  p_agreement_id                => l_bpa_header_id
          ,  x_agreement_encumbered_flag   => l_source_enc_flag
          );
     ELSE
          l_source_enc_flag := 'N';
     END IF;

     IF l_source_enc_flag = 'Y' THEN
          PO_DOCUMENT_FUNDS_PVT.do_reserve(
                       x_return_status     => l_return_status
                    ,  p_doc_type          => 'REQUISITION'
                    ,  p_doc_subtype       => NULL
                    ,  p_doc_level         => l_doc_level
                    ,  p_doc_level_id      => l_doc_level_id
                    ,  p_use_enc_gt_flag   => 'N'
                    ,  p_prevent_partial_flag => 'N'
                    ,   P_VALIDATE_DOCUMENT    => 'N'
                    ,  p_override_funds     => fnd_profile.value('PO_REQAPPR_OVERRIDE_FUNDS')
                    ,  p_employee_id       => NULL
                    ,  x_po_return_code    => l_po_return_code
                    ,  x_online_report_id  => l_online_report_id
                    );
               IF (l_return_status <> PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS) THEN
                   x_ret_code := 'E';
                   x_error_msg := 'Error Occured during reserve'||'Online Report Id' ||l_online_report_id ||l_po_return_code;
                   RETURN;
               END IF;
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'l_online_report_id',l_online_report_id);
                PO_LOG.stmt(d_module_base,d_progress,'l_po_return_code',l_po_return_code);
              END IF;
     END IF;
  END IF;
 END LOOP;
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  x_error_msg := 'Unhandled Exception'|| SQLERRM;
  X_RET_CODE := 'E';
  po_message_s.sql_error('check_unique','010',SQLCODE);
  RAISE;
END;


PROCEDURE delete_linesfromreq(p_reqlineid_tbl IN po_tbl_number,x_error_msg OUT NOCOPY  VARCHAR2,x_retcode OUT NOCOPY  VARCHAR2)
is
l_award_ids dbms_sql.NUMBER_TABLE;
l_progress VARCHAR2(4) := '000';
begin

   l_progress := '010';




   -- delete the lines
   FORALL i in 1..p_reqlineid_tbl.COUNT
	   DELETE FROM po_requisition_lines_all
	   WHERE requisition_line_id = p_reqlineid_tbl(i);

   l_progress := '020';

   -- delete the distributions
   FORALL idx IN 1..p_reqlineid_tbl.COUNT
     DELETE FROM po_req_distributions_all
     WHERE requisition_line_id = p_reqlineid_tbl(idx)
      RETURNING award_id
      BULK COLLECT INTO l_award_ids;

    l_progress := '030';

    -- if not working copy, call GMS API to delete award set ids
    -- bluk: commented out for FPJ. Need to add this back in 11iX
    /*
    IF (NOT p_working_copy) THEN
      FOR idx IN 1..l_award_ids.COUNT LOOP
        IF (l_award_ids(idx) IS NOT NULL) THEN
          gms_por_api.delete_adl(l_award_ids(idx), l_status, l_err_msg);
        END IF;
      END LOOP;
    END IF;
    */


    -- delete the line attachments
    FOR idx IN 1..p_reqlineid_tbl.COUNT LOOP
      fnd_attached_documents2_pkg.delete_attachments('REQ_LINES',
                                                     p_reqlineid_tbl(idx),
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     'Y');
    END LOOP;

    l_progress := '050';

    -- delete the orig info template values
    FORALL idx IN 1..p_reqlineid_tbl.COUNT
      DELETE FROM por_template_info
      WHERE requisition_line_id = p_reqlineid_tbl(idx);

    l_progress := '060';

    -- delete the one time locations
    FORALL idx IN 1..p_reqlineid_tbl.COUNT
      DELETE FROM por_item_attribute_values
      WHERE requisition_line_id = p_reqlineid_tbl(idx);

    l_progress := '070';

    -- delete line suppliers
    FORALL idx IN 1..p_reqlineid_tbl.COUNT
      DELETE FROM po_requisition_suppliers
      WHERE requisition_line_id = p_reqlineid_tbl(idx);

    l_progress := '080';

    -- delete price differentials
    FORALL idx IN 1..p_reqlineid_tbl.COUNT
      DELETE FROM po_price_differentials
      WHERE entity_id = p_reqlineid_tbl(idx)
      AND entity_type = 'REQ LINE';

      x_retcode := 'S';

EXCEPTION
  WHEN OTHERS THEN
   RAISE;
END;

PROCEDURE RETURNREQPROCESS(p_reqlineid_in_tbl IN po_tbl_number, p_req_lineid_out_tbl OUT NOCOPY  po_tbl_number,
                           x_retcode OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2)
IS
CURSOR c_req_hdr(p_hdr_id NUMBER)
IS
  SELECT prh.segment1
  from   po_requisition_headers prh
  where  prh.requisition_header_id = p_hdr_id;

    e_exception EXCEPTION;
  l_key number;
  CURSOR c_session_data(p_key NUMBER)
  IS select *
  from po_session_gt
  where key = p_key;


    -- Cursor to get unique Requisition_Header_ID
 CURSOR req_header_id_cur IS
   SELECT po_requisition_headers_s.nextval
   FROM sys.dual;

 -- Cursor to get unique Requisition_Line_ID
 CURSOR req_line_id_cur IS
   SELECT po_requisition_lines_s.nextval
   FROM sys.dual;

 -- Cursor to get unique Distribution_id
 CURSOR dist_line_id_cur IS
   SELECT po_req_distributions_s.nextval
   FROM sys.dual;

 CURSOR c1 IS
 SELECT requisition_line_id
 FROM po_requisition_lines prl
 WHERE requisition_header_id in ( select distinct num3 from po_session_gt);

 CURSOR c_req_line_count (p_hdr_id NUMBER,p_key number)
 IS
 SELECT (select count(distinct num2) from po_session_gt where num1 = p_hdr_id and key =p_key) ret_lines,
 (select count(requisition_line_id) from po_requisition_lines_all where requisition_header_id = p_hdr_id) orig_lines
 from dual;

 CURSOR c_lines_del(p_key NUMBER)
 IS
 SELECT distinct num2
 FROM po_session_gt
 WHERE KEY = p_key
 and num3 <> num1;

   l_header_id number;
   l_line_id number;
   l_segment1 VARCHAR2(100);
   l_new_req varchar2(100);
   x_return_status VARCHAR2(100);
   --x_error_msg VARCHAR2(1000);
   l_new_header_id NUMBER;
   l_new_segment1 VARCHAR2(100);
   l_dummy VARCHAR2(1);
   l_ret_lines number;
   l_orig_lines number;
   l_progress varchar2(50);
   l_rm_lines_tbl po_tbl_number;
   l_module_name CONSTANT VARCHAR2(100) := 'RETURNREQPROCESS';
   D_PACKAGE_BASE varchar2(100):='POR_RETURNREQ_PROCESS';
   d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
   e_userexception exception;
   l_latest_num3 number;
BEGIN



	SAVEPOINT NEW_REQ_CREATION;
	select po_session_gt_s.nextval into l_key from dual;
  insert_gt(p_reqlineid_in_tbl,l_key,x_return_status,x_error_msg);

  IF x_error_msg is not null then
    RAISE e_userexception;
  END IF;

  l_progress := '10';
   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'l_key',l_key);
  END IF;

  FOR i_rec in c_session_data(l_key)
  LOOP

      select 	num3 into l_latest_num3 from po_session_gt where num2 = i_rec.num2 and key=i_rec.key and num1 = i_rec.num1 and rownum=1;


      IF  l_latest_num3 IS NULL THEN

       l_progress := '10';

       OPEN c_req_line_count(i_rec.num1,l_key);
       FETCH c_req_line_count INTO l_ret_lines,l_orig_lines;
       CLOSE c_req_line_count;

         l_progress := 20;
			  IF PO_LOG.d_stmt THEN
			        PO_LOG.stmt(d_module_base,l_progress,'i_rec.num1'||i_rec.num1);
			        PO_LOG.stmt(d_module_base,l_progress,'l_ret_lines'||l_ret_lines);
			        PO_LOG.stmt(d_module_base,l_progress,'l_orig_lines'||l_orig_lines);
			  END IF;

       IF l_ret_lines = l_orig_lines THEN
 	        update po_session_gt
	        set num3 = i_rec.num1
	        where num1 = i_rec.num1
	        and key = i_rec.key;
       ELSE

			       --Get requisition Number
			       OPEN c_req_hdr(i_rec.num1);
			       FETCH c_req_hdr INTO l_segment1;
			       CLOSE c_req_hdr;

			       l_new_segment1 := get_newreq_number(l_segment1);

			       IF length(l_new_segment1) >= 20 then
			       	  x_retcode := 'E';
			       	  x_error_msg:= 'Length of segment is not valid.Maximum Length of Segment1 is 20. Contact Administrator';
			          raise e_userexception;
			       END IF;
			      l_progress := 30;
					  IF PO_LOG.d_stmt THEN
					        PO_LOG.stmt(d_module_base,l_progress,'l_new_segment1'||l_new_segment1);
					  END IF;

			              -- Get Requisition_header_id
			       OPEN req_header_id_cur;
			       FETCH req_header_id_cur into l_new_header_id;
			       CLOSE req_header_id_cur;


			       -- check for uniqueness of requisition_number
			       BEGIN

			         SELECT 'X' INTO l_dummy
			         FROM   DUAL
			         WHERE NOT EXISTS
			           ( SELECT 'X'
			              FROM po_requisition_headers
			              WHERE Segment1 = l_new_segment1);

			        EXCEPTION
			          WHEN NO_DATA_FOUND THEN
			            po_message_s.app_error('PO_ALL_ENTER_UNIQUE_VAL');
			            raise;
			          WHEN OTHERS THEN
			            po_message_s.sql_error('check_unique','010',sqlcode);
			            raise;
			        END;

			        insert_header(i_rec.num1,l_new_header_id,l_new_segment1,x_return_status,x_error_msg);
			        IF x_retcode = 'E' then
			          RAISE e_userexception;
			        END IF;

			        copy_req_lines(i_rec.num1,l_new_header_id,x_return_status,x_error_msg);

			        IF x_return_status <> 'S' THEN
			          RAISE e_userexception;

			          --exit;
			        END IF;

			        update po_session_gt
			        set num3 = l_new_header_id
			        where num1 = i_rec.num1
			        and key = i_rec.key;
			   end if; --Req Line count

    END IF;   -- NUM3 Null condition
   END LOOP ;
   --insert into temp3 values ('debug1');
   OPEN c1;
   l_progress := '50';

   FETCH c1 BULK COLLECT INTO  p_req_lineid_out_tbl;
   CLOSE c1;


   --insert into temp3 values ('debug2');
   OPEN c_lines_del(l_key);
   FETCH c_lines_del BULK COLLECT INTO l_rm_lines_tbl;
   CLOSE c_lines_del;
   l_progress := '60';
   delete_linesfromreq(l_rm_lines_tbl,x_error_msg,x_retcode);
   reserve_lines(p_req_lineid_out_tbl,x_error_msg,x_retcode);
   x_error_msg := NULL;
   x_retcode := 'S';

   commit;
EXCEPTION
WHEN E_USEREXCEPTION THEN
  ROLLBACK TO NEW_REQ_CREATION;
  x_retcode := 'E';
  x_error_msg := x_error_msg||'Error in Return Req Creation '||l_progress||SQLERRM;
  raise;
WHEN OTHERS THEN
  ROLLBACK TO NEW_REQ_CREATION;
  x_retcode := 'E';
  x_error_msg := x_error_msg||'Error in Return Req Creation '||l_progress||SQLERRM;
  raise;

END;

END POR_RETURNREQ_PROCESS ;

/
