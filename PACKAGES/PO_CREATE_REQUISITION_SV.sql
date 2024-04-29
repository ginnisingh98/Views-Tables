--------------------------------------------------------
--  DDL for Package PO_CREATE_REQUISITION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CREATE_REQUISITION_SV" AUTHID CURRENT_USER AS
/* $Header: POXCARQS.pls 120.1 2005/06/10 01:46:43 kpsingh noship $ */
--
-- Purpose: To create approved internal / purchase requisition
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- kperiasa    08/01/01 Created Package
-- davidng     05/24/02 Changed p_Init_Msg_List to be assigned the value FND_API.G_TRUE instead of FND_API.G_FALSE
-- davidng     10/08/03 <SERVICES FPJ> Added order_type_lookup_code, purchase_basis
--                      and matching_basis record type line_rec_type

TYPE Header_Rec_Type IS RECORD
(requisition_header_id		po_requisition_headers_all.requisition_header_id%TYPE
,preparer_id			po_requisition_headers_all.preparer_id%TYPE
,last_update_date		po_requisition_headers_all. last_update_date%TYPE
,last_updated_by		po_requisition_headers_all.last_updated_by%TYPE
,segment1			po_requisition_headers_all.segment1%TYPE
,summary_flag			po_requisition_headers_all.summary_flag%TYPE
,enabled_flag			po_requisition_headers_all.enabled_flag%TYPE
,segment2			po_requisition_headers_all.segment2%TYPE
,segment3			po_requisition_headers_all.segment3%TYPE
,segment4			po_requisition_headers_all.segment4%TYPE
,segment5			po_requisition_headers_all.segment5%TYPE
,start_date_active		po_requisition_headers_all.start_date_active%TYPE
,end_date_active		po_requisition_headers_all.end_date_active%TYPE
,last_update_login		po_requisition_headers_all.last_update_login%TYPE
,creation_date			po_requisition_headers_all.creation_date%TYPE
,created_by			po_requisition_headers_all.created_by%TYPE
,description			po_requisition_headers_all.description%TYPE
,authorization_status		po_requisition_headers_all.authorization_status%TYPE
,note_to_authorizer		po_requisition_headers_all.note_to_authorizer%TYPE
,type_lookup_code		po_requisition_headers_all.type_lookup_code%TYPE
,transferred_to_oe_flag		po_requisition_headers_all.transferred_to_oe_flag%TYPE
,attribute_category		po_requisition_headers_all.attribute_category%TYPE
,attribute1			po_requisition_headers_all.attribute1%TYPE
,attribute2			po_requisition_headers_all.attribute2%TYPE
,attribute3			po_requisition_headers_all.attribute3%TYPE
,attribute4			po_requisition_headers_all.attribute4%TYPE
,attribute5			po_requisition_headers_all.attribute5%TYPE
,on_line_flag			po_requisition_headers_all.on_line_flag%TYPE
,attribute6			po_requisition_headers_all.attribute6%TYPE
,attribute7			po_requisition_headers_all.attribute7%TYPE
,attribute8			po_requisition_headers_all.attribute8%TYPE
,attribute9			po_requisition_headers_all.attribute9%TYPE
,attribute10			po_requisition_headers_all.attribute10%TYPE
,attribute11			po_requisition_headers_all.attribute11%TYPE
,attribute12			po_requisition_headers_all.attribute12%TYPE
,attribute13			po_requisition_headers_all.attribute13%TYPE
,attribute14			po_requisition_headers_all.attribute14%TYPE
,attribute15			po_requisition_headers_all.attribute15%TYPE
,government_context		po_requisition_headers_all.government_context%TYPE
,closed_code			po_requisition_headers_all.closed_code%TYPE
,org_id				org_organization_definitions.organization_id%TYPE
,emergency_po_num		po_requisition_headers_all.emergency_po_num%TYPE
);

TYPE Line_Rec_type IS RECORD
(requisition_line_id 		po_requisition_lines_all.requisition_line_id%TYPE
,requisition_header_id		po_requisition_headers_all.requisition_header_id%TYPE
,line_num	 		po_requisition_lines_all.line_num%TYPE
,line_type_id	 		po_requisition_lines_all.line_type_id%TYPE
,category_id	 		mtl_categories.category_id%TYPE
,item_description	 	mtl_system_items.description%TYPE
,unit_meas_lookup_code		po_requisition_lines_all.unit_meas_lookup_code%TYPE
,unit_price	 		po_requisition_lines_all.unit_price%TYPE
,quantity	 		po_requisition_lines_all.quantity%TYPE
,deliver_to_location_id	 	po_requisition_lines_all.deliver_to_location_id%TYPE
,to_person_id	 		po_requisition_lines_all.to_person_id%TYPE
,last_update_date	 	po_requisition_lines_all.last_update_date%TYPE
,last_updated_by	 	po_requisition_lines_all.last_updated_by%TYPE
,source_type_code	 	po_requisition_lines_all.source_type_code%TYPE
,last_update_login	 	po_requisition_lines_all.last_update_login%TYPE
,creation_date	 		po_requisition_lines_all.creation_date%TYPE
,created_by	 		po_requisition_lines_all.created_by%TYPE
,item_id		 	po_requisition_lines_all.item_id%TYPE
,item_revision	 		po_requisition_lines_all.item_revision%TYPE
,quantity_delivered	 	po_requisition_lines_all.quantity_delivered%TYPE
,suggested_buyer_id	 	po_requisition_lines_all.suggested_buyer_id%TYPE
,encumbered_flag	 	po_requisition_lines_all.encumbered_flag%TYPE
,rfq_required_flag	 	po_requisition_lines_all.rfq_required_flag%TYPE
,need_by_date	 		po_requisition_lines_all.need_by_date%TYPE
,line_location_id	 	po_requisition_lines_all.line_location_id%TYPE
,modified_by_agent_flag	 	po_requisition_lines_all.modified_by_agent_flag%TYPE
,parent_req_line_id	 	po_requisition_lines_all.parent_req_line_id%TYPE
,justification	 		po_requisition_lines_all.justification%TYPE
,note_to_agent	 		po_requisition_lines_all.note_to_agent%TYPE
,note_to_receiver	 	po_requisition_lines_all.note_to_receiver%TYPE
,purchasing_agent_id	 	po_requisition_lines_all.purchasing_agent_id%TYPE
,document_type_code	 	po_requisition_lines_all.document_type_code%TYPE
,blanket_po_header_id	 	po_requisition_lines_all.blanket_po_header_id%TYPE
,blanket_po_line_num	 	po_requisition_lines_all.blanket_po_line_num%TYPE
,currency_code	 		po_requisition_lines_all.currency_code%TYPE
,rate_type	 		po_requisition_lines_all.rate_type%TYPE
,rate_date	 		po_requisition_lines_all.rate_date%TYPE
,rate	 			po_requisition_lines_all.rate%TYPE
,currency_unit_price		po_requisition_lines_all.currency_unit_price%TYPE
,suggested_vendor_name	 	po_requisition_lines_all.suggested_vendor_name%TYPE
,suggested_vendor_location	po_requisition_lines_all.suggested_vendor_location%TYPE
,suggested_vendor_contact	po_requisition_lines_all.suggested_vendor_contact%TYPE
,suggested_vendor_phone	 	po_requisition_lines_all.suggested_vendor_phone%TYPE
,suggested_vendor_product_code	po_requisition_lines_all.suggested_vendor_product_code%TYPE
,un_number_id	 		po_requisition_lines_all.un_number_id%TYPE
,hazard_class_id	 	po_requisition_lines_all.hazard_class_id%TYPE
,must_use_sugg_vendor_flag	po_requisition_lines_all.must_use_sugg_vendor_flag%TYPE
,reference_num	 		po_requisition_lines_all.reference_num%TYPE
,on_rfq_flag	 		po_requisition_lines_all.on_rfq_flag%TYPE
,urgent_flag	 		po_requisition_lines_all.urgent_flag%TYPE
,cancel_flag	 		po_requisition_lines_all.cancel_flag%TYPE
,source_organization_id	 	org_organization_definitions.organization_id%TYPE
,source_subinventory	 	po_requisition_lines_all.source_subinventory%TYPE
,destination_type_code	 	po_requisition_lines_all.destination_type_code%TYPE
,destination_organization_id	org_organization_definitions.organization_id%TYPE
,destination_subinventory	po_requisition_lines_all.destination_subinventory%TYPE
,quantity_cancelled	 	po_requisition_lines_all.quantity_cancelled%TYPE
,cancel_date	 		po_requisition_lines_all.cancel_date%TYPE
,cancel_reason			po_requisition_lines_all.cancel_reason%TYPE
,closed_code	 		po_requisition_lines_all.closed_code%TYPE
,agent_return_note	 	po_requisition_lines_all.agent_return_note%TYPE
,changed_after_research_flag	po_requisition_lines_all.changed_after_research_flag%TYPE
,vendor_id	 		po_vendors.vendor_id%TYPE
,vendor_site_id	 		po_requisition_lines_all.vendor_site_id%TYPE
,vendor_contact_id	 	po_requisition_lines_all.vendor_contact_id%TYPE
,research_agent_id	 	po_requisition_lines_all.research_agent_id%TYPE
,wip_entity_id	 		po_requisition_lines_all.wip_entity_id%TYPE
,wip_line_id	 		po_requisition_lines_all.wip_line_id%TYPE
,wip_repetitive_schedule_id	po_requisition_lines_all.wip_repetitive_schedule_id%TYPE
,wip_operation_seq_num	 	po_requisition_lines_all.wip_operation_seq_num%TYPE
,wip_resource_seq_num	 	po_requisition_lines_all.wip_resource_seq_num%TYPE
,attribute_category	 	po_requisition_lines_all.attribute_category%TYPE
,destination_context	 	po_requisition_lines_all.destination_context%TYPE
,inventory_source_context	po_requisition_lines_all.inventory_source_context%TYPE
,vendor_source_context	 	po_requisition_lines_all.vendor_source_context%TYPE
,attribute1	 		po_requisition_lines_all.attribute1%TYPE
,attribute2	 		po_requisition_lines_all.attribute2%TYPE
,attribute3	 		po_requisition_lines_all.attribute3%TYPE
,attribute4	 		po_requisition_lines_all.attribute4%TYPE
,attribute5	 		po_requisition_lines_all.attribute5%TYPE
,attribute6	 		po_requisition_lines_all.attribute6%TYPE
,attribute7	 		po_requisition_lines_all.attribute7%TYPE
,attribute8	 		po_requisition_lines_all.attribute8%TYPE
,attribute9	 		po_requisition_lines_all.attribute9%TYPE
,attribute10	 		po_requisition_lines_all.attribute10%TYPE
,attribute11	 		po_requisition_lines_all.attribute11%TYPE
,attribute12	 		po_requisition_lines_all.attribute12%TYPE
,attribute13	 		po_requisition_lines_all.attribute13%TYPE
,attribute14	 		po_requisition_lines_all.attribute14%TYPE
,attribute15	 		po_requisition_lines_all.attribute15%TYPE
,bom_resource_id	 	po_requisition_lines_all.bom_resource_id%TYPE
,government_context	 	po_requisition_lines_all.government_context%TYPE
,closed_reason	 		po_requisition_lines_all.closed_reason%TYPE
,closed_date	 		po_requisition_lines_all.closed_date%TYPE
,transaction_reason_code 	po_requisition_lines_all.transaction_reason_code%TYPE
,quantity_received	 	po_requisition_lines_all.quantity_received%TYPE
,source_req_line_id	 	po_requisition_lines_all.source_req_line_id%TYPE
,org_id	 			po_requisition_lines_all.org_id%TYPE
,kanban_card_id	 		po_requisition_lines_all.kanban_card_id%TYPE
,catalog_type	 		po_requisition_lines_all.catalog_type%TYPE
,catalog_source	 		po_requisition_lines_all.catalog_source%TYPE
,manufacturer_id		po_requisition_lines_all.manufacturer_id%TYPE
,manufacturer_name	 	po_requisition_lines_all.manufacturer_name%TYPE
,manufacturer_part_number	po_requisition_lines_all.manufacturer_part_number%TYPE
,requester_email	 	po_requisition_lines_all.requester_email%TYPE
,requester_fax	 		po_requisition_lines_all.requester_fax%TYPE
,requester_phone	 	po_requisition_lines_all.requester_phone%TYPE
,unspsc_code	 		po_requisition_lines_all.unspsc_code%TYPE
,other_category_code	 	po_requisition_lines_all.other_category_code%TYPE
,supplier_duns	 		po_requisition_lines_all.supplier_duns%TYPE
,tax_status_indicator	 	po_requisition_lines_all.tax_status_indicator%TYPE
,pcard_flag	 		po_requisition_lines_all.pcard_flag%TYPE
,new_supplier_flag	 	po_requisition_lines_all.new_supplier_flag%TYPE
,auto_receive_flag	 	po_requisition_lines_all.auto_receive_flag%TYPE
,tax_user_override_flag	 	po_requisition_lines_all.tax_user_override_flag%TYPE
,tax_code_id	 		po_requisition_lines_all.tax_code_id%TYPE
,note_to_vendor	 		po_requisition_lines_all.note_to_vendor%TYPE
,oke_contract_version_id 	po_requisition_lines_all.oke_contract_version_id%TYPE
,oke_contract_header_id	 	po_requisition_lines_all.oke_contract_header_id%TYPE
,item_source_id	 		po_requisition_lines_all.item_source_id%TYPE
,supplier_ref_number	 	po_requisition_lines_all.supplier_ref_number%TYPE
,source_doc_line_reference	number
,uom_code		 	VARCHAR2(3)
,order_type_lookup_code         po_requisition_lines_all.order_type_lookup_code%TYPE
,purchase_basis                 po_requisition_lines_all.purchase_basis%TYPE
,matching_basis                 po_requisition_lines_all.matching_basis%TYPE
);

 TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Dist_Rec_type IS RECORD
(distribution_id 		po_req_distributions_all.distribution_id%TYPE
,last_update_date		po_req_distributions_all.last_update_date%TYPE
,last_updated_by 		po_req_distributions_all.last_updated_by%TYPE
,requisition_line_id		po_req_distributions_all.requisition_line_id%TYPE
,set_of_books_id		po_req_distributions_all.set_of_books_id%TYPE
,code_combination_id		po_req_distributions_all.code_combination_id%TYPE
,req_line_quantity		po_req_distributions_all.req_line_quantity%TYPE
,last_update_login		po_req_distributions_all.last_update_login%TYPE
,creation_date			po_req_distributions_all.creation_date%TYPE
,created_by			po_req_distributions_all.created_by%TYPE
,encumbered_flag		po_req_distributions_all.encumbered_flag%TYPE
,gl_encumbered_date		po_req_distributions_all.gl_encumbered_date%TYPE
,gl_encumbered_period_name	po_req_distributions_all.gl_encumbered_period_name%TYPE
,gl_cancelled_date		po_req_distributions_all.gl_cancelled_date%TYPE
,failed_funds_lookup_code	po_req_distributions_all.failed_funds_lookup_code%TYPE
,encumbered_amount		po_req_distributions_all.encumbered_amount%TYPE
,budget_account_id		po_req_distributions_all.budget_account_id%TYPE
,accrual_account_id		po_req_distributions_all.accrual_account_id%TYPE
,variance_account_id		po_req_distributions_all.variance_account_id%TYPE
,prevent_encumbrance_flag	po_req_distributions_all.prevent_encumbrance_flag%TYPE
,attribute_category		po_req_distributions_all.attribute_category%TYPE
,attribute1			po_req_distributions_all.attribute1%TYPE
,attribute2			po_req_distributions_all.attribute2%TYPE
,attribute3			po_req_distributions_all.attribute3%TYPE
,attribute4			po_req_distributions_all.attribute4%TYPE
,attribute5			po_req_distributions_all.attribute5%TYPE
,attribute6			po_req_distributions_all.attribute6%TYPE
,attribute7			po_req_distributions_all.attribute7%TYPE
,attribute8			po_req_distributions_all.attribute8%TYPE
,attribute9			po_req_distributions_all.attribute9%TYPE
,attribute10			po_req_distributions_all.attribute10%TYPE
,attribute11			po_req_distributions_all.attribute11%TYPE
,attribute12	 		po_req_distributions_all.attribute12%TYPE
,attribute13	 		po_req_distributions_all.attribute13%TYPE
,attribute14	 		po_req_distributions_all.attribute14%TYPE
,attribute15	 		po_req_distributions_all.attribute15%TYPE
,government_context		po_req_distributions_all.government_context%TYPE
,project_id	 		po_req_distributions_all.project_id%TYPE
,task_id	  		po_req_distributions_all.task_id%TYPE
,expenditure_type		po_req_distributions_all.expenditure_type%TYPE
,project_accounting_context	po_req_distributions_all.project_accounting_context%TYPE
,expenditure_organization_id	po_req_distributions_all.expenditure_organization_id%TYPE
,gl_closed_date	 		po_req_distributions_all.gl_closed_date%TYPE
,source_req_distribution_id	po_req_distributions_all.source_req_distribution_id%TYPE
,distribution_num		po_req_distributions_all.distribution_num%TYPE
,project_related_flag		po_req_distributions_all.project_related_flag%TYPE
,expenditure_item_date		po_req_distributions_all.expenditure_item_date%TYPE
,org_id	 	 		po_req_distributions_all.org_id%TYPE
,allocation_type	 	po_req_distributions_all.allocation_type%TYPE
,allocation_value		po_req_distributions_all.allocation_value%TYPE
,award_id	 		po_req_distributions_all.award_id%TYPE
,end_item_unit_number		po_req_distributions_all.end_item_unit_number%TYPE
,recoverable_tax	 	po_req_distributions_all.recoverable_tax%TYPE
,nonrecoverable_tax		po_req_distributions_all.nonrecoverable_tax%TYPE
,recovery_rate	 		po_req_distributions_all.recovery_rate%TYPE
,tax_recovery_override_flag	po_req_distributions_all.tax_recovery_override_flag%TYPE
,oke_contract_line_id		po_req_distributions_all.oke_contract_line_id%TYPE
,oke_contract_deliverable_id	po_req_distributions_all.oke_contract_deliverable_id%TYPE
);


  PROCEDURE process_requisition(
          p_api_version             IN NUMBER       := 1.0
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY po_create_requisition_sv.Header_rec_type
         ,px_line_table             IN OUT NOCOPY po_create_requisition_sv.Line_Tbl_type
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        );

 END; -- Package spec

 

/
