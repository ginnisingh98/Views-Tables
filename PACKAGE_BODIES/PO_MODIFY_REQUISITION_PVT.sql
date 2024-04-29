--------------------------------------------------------
--  DDL for Package Body PO_MODIFY_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MODIFY_REQUISITION_PVT" AS
    /* $Header: PO_MODIFY_REQUISITION_PVT.plb 120.7.12010000.5 2010/03/22 11:22:52 dashah ship $ */

    -- Logging global constants
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_MODIFY_REQUISITION_PVT';
    D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);

    --Other constants used in code
    g_REQ_LINES_ENTITY CONSTANT VARCHAR2(20) := 'REQ_LINES';
    g_EXPLODE_REQ_ACTION CONSTANT VARCHAR2(20) :='Explode_Req';
    g_CALLING_PROGRAM_SPLIT   CONSTANT VARCHAR2(20) :='SPLIT';
    g_CALLING_PROGRAM_CATALOG CONSTANT VARCHAR2(20) :='CATALOG';
    g_TAX_ATTRIBUTE_CREATE CONSTANT VARCHAR2(20) :='CREATE';
    /**
    * Private Procedure: split_requisition_lines
    * Requires: API message list has been initialized if p_init_msg_list is
    * false.
    * Modifies:  Inserts  new  req lines and their  distributions, For  parent  .
    * req lines, update requisition_lines table to modified_by_agent_flag = 'Y' .
    * Also sets prevent encumbrace flag to 'Y' in the po_req_distributions table.
    * Effects: This api split the requisition lines, into two lines with specified quantity.
    * This api uses a global temp.table to process the input given by autocreate(HTML) and
    * inserts records into po_requisition_lines_all and po_req_distributions_all table.
    * This api also handles the encumbrace effect of splitting requisition lines. This
    * api would be called from Autocreate HTML.
    *
    * Returns:
    *   x_return_status - FND_API.G_RET_STS_SUCCESS if action succeeds
    *                     FND_API.G_RET_STS_ERROR if  action fails
    *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
    *                     x_msg_count returns count of messages in the stack.
    *                     x_msg_data returns message only if 1 message.
    * Algorithm:
    *                     1. Get the requisition line id of the req line that needs
    *                        to be split
    *                     2. Retrieve the quantity on the given line and split using
    *                        split function.
    *                     3. Calculate the maximum line number of the lines that
    *                        belong to the given requisition.
    *                     4. Using a for loop insert two records into the po_requisition_lines_all
    *                        table and provide the correct line number by incrementing
    *                        max line number by one in each iteration.
    *                     5. Update the split req line and set the modified flag
    *                        and purchasing agent flag.
    *                     6. Copy the attachments from the parent line on to the
    *                        new lines.
    *                     7. Handle tax adjustments for the new lines
    *                     8. Handle encumbrance funds results for the new and old
    *                        lines.
    *
    */

    PROCEDURE split_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_num_of_new_lines IN NUMBER,
                                      p_quantity_tbl     IN PO_TBL_NUMBER,
                                      p_agent_id         IN NUMBER,
                                      p_calling_program  IN VARCHAR2,
                                      p_handle_tax_diff_if_enc  IN VARCHAR2,
                                      x_new_line_ids_tbl OUT NOCOPY PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000
                                      ) IS

        l_module CONSTANT VARCHAR2(100) := 'split_requisition_lines';
        d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(d_PACKAGE_BASE,l_module);

        l_api_version CONSTANT NUMBER := 1.0;
        d_progress NUMBER;
        l_old_org_id           NUMBER;
    BEGIN
        --CREATE A SAVE POINT ON ENTERING THIS PROCEDURE
        SAVEPOINT split_requisition_lines_PVT;

        d_progress := 10;

        IF PO_LOG.d_event THEN
           PO_LOG.event(d_module_base,d_progress,'Starting Requisition Split ');
        END IF;
        --Initialize the error messages table
        x_error_msg_tbl :=po_tbl_varchar2000();
        IF NOT FND_API.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_module,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      --Get the value of current org id. We would set the
      --org context back to this value before leaving the
      --program.
      l_old_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;

      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,d_progress,'l_old_org_id ', l_old_org_id);
         PO_LOG.stmt(d_module_base,d_progress,'Retrieved the value of current orgId');
      END IF;

      d_progress := 20;

      create_requisition_lines(p_api_version        => p_api_version,
                           p_init_msg_list          => p_init_msg_list,
                           p_commit                 => p_commit,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
                           p_req_line_id            => p_req_line_id,
                           p_num_of_new_lines       => p_num_of_new_lines,
                           p_quantity_tbl           => p_quantity_tbl,
                           p_agent_id               => p_agent_id,
                           p_calling_program        => p_calling_program,
                           x_new_line_ids_tbl       => x_new_line_ids_tbl,
                           x_error_msg_tbl          => x_error_msg_tbl);

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'x_return_status',x_return_status);
        END IF;

        IF (x_return_status = FND_API.g_ret_sts_error)
        THEN
            RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error)
        THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF; --x_return_status

      d_progress := 30;

      post_modify_requisition_lines(p_api_version            => p_api_version,
                                    p_init_msg_list          => p_init_msg_list,
                                    p_commit                 => p_commit,
                                    x_return_status          => x_return_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_req_line_id            => p_req_line_id,
                                    p_handle_tax_diff_if_enc => p_handle_tax_diff_if_enc,
                                    p_new_line_ids_tbl       => x_new_line_ids_tbl,
                                    x_error_msg_tbl          => x_error_msg_tbl);


        d_progress:=40;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'x_return_status',x_return_status);
        END IF;

        IF (x_return_status = FND_API.g_ret_sts_error)
        THEN
            RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error)
        THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF; --x_return_status

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Reset the org context to old value');
        END IF;

      --Set the org context back to the original org context
        po_moac_utils_pvt.set_org_context(l_old_org_id);

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_old_org_id',l_old_org_id);
        END IF;

        d_progress:=50;
        x_return_status := FND_API.g_ret_sts_success;
        IF (PO_LOG.d_proc)
        THEN
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
        END IF;
    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO split_requisition_lines_PVT;
            x_return_status := FND_API.g_ret_sts_error;
            po_moac_utils_pvt.set_org_context(l_old_org_id);
            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;
        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO split_requisition_lines_PVT;
            po_moac_utils_pvt.set_org_context(l_old_org_id);

            po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
            FND_MSG_PUB.Add;
            FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());
            x_msg_data      := FND_MESSAGE.get;
            x_error_msg_tbl.extend(1);
            x_error_msg_tbl(x_error_msg_tbl.count) := x_msg_data;
            x_return_status := FND_API.g_ret_sts_error;

            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;
        WHEN OTHERS THEN
            ROLLBACK TO split_requisition_lines_PVT;
            po_moac_utils_pvt.set_org_context(l_old_org_id);

            BEGIN
            -- Log a debug message, add the error the the API message list.
            po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
            FND_MSG_PUB.Add;
            FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());
            x_msg_data      := FND_MESSAGE.get;
            x_error_msg_tbl.extend(1);
            x_error_msg_tbl(x_error_msg_tbl.count) := x_msg_data;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    po_moac_utils_pvt.set_org_context(l_old_org_id);
                    IF (PO_LOG.d_exc)
                    THEN
                        PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                        PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                        PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                        PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
                    END IF;
                    RAISE;
            END;
    END split_requisition_lines;

    PROCEDURE create_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_num_of_new_lines IN NUMBER,
                                      p_quantity_tbl     IN PO_TBL_NUMBER,
                                      p_agent_id         IN NUMBER,
                                      p_calling_program  IN VARCHAR2,
                                      x_new_line_ids_tbl OUT NOCOPY PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000
                                      ) IS

        l_module CONSTANT VARCHAR2(100) := 'create_requisition_lines';
        d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(d_PACKAGE_BASE, l_module);
        l_api_version CONSTANT NUMBER := 1.0;
        d_progress NUMBER;
        --declare the result tables.
        new_req_line_id_rslt_tbl      PO_TBL_NUMBER;
        -- SQL What:This cursor Locks the requisition lines the api is going to
        --          process
        -- SQL Why :This locking ensures that the records are not touched by
        --          any other transactions.Opening the cursor keeps the records
        --          locked till the transaction control happens.
        CURSOR lock_req_lines_cs IS
            SELECT prl.requisition_line_id,
                   prl.org_id
            FROM   po_requisition_lines_all prl
            WHERE  prl.requisition_line_id = p_req_line_id
            FOR    UPDATE OF prl.quantity NOWAIT;
        l_temp_requisition_line_id NUMBER;
        l_serial_num           NUMBER;
        l_line_num_index       NUMBER;
        l_max_line_num         NUMBER;
        l_current_org_id       NUMBER;
        l_requisition_line_id  NUMBER;
        l_old_org_id           NUMBER;
    BEGIN
        --CREATE A SAVE POINT ON ENTERING THIS PROCEDURE
        SAVEPOINT create_requisition_lines_PVT;

        d_progress := 10;

        IF PO_LOG.d_event THEN
           PO_LOG.event(d_module_base,d_progress,'Starting Requisition Split ');
        END IF;
        --Initialize the error messages table
        x_error_msg_tbl :=po_tbl_varchar2000();
        IF NOT FND_API.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_module,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (PO_LOG.d_proc)
        THEN
            PO_LOG.proc_begin(d_module_base);
            PO_LOG.proc_begin(d_module_base,'p_api_version',    p_api_version  );
            PO_LOG.proc_begin(d_module_base,'p_init_msg_list',  p_init_msg_list);
            PO_LOG.proc_begin(d_module_base,'p_commit',         p_commit       );
            PO_LOG.proc_begin(d_module_base,'p_req_line_id',    p_req_line_id  );
            PO_LOG.proc_begin(d_module_base,'p_quantity_tbl',   p_quantity_tbl );
            PO_LOG.proc_begin(d_module_base,'p_agent_id',       p_agent_id     );
        END IF;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Attempting to lock the requisition line ');
        END IF;

        -- Lock the requisition lines the api is going to process
        -- Retrieve the value of requisition org id so that the org
        -- context can be set to this value.

        OPEN lock_req_lines_cs;

        FETCH lock_req_lines_cs
        INTO  l_requisition_line_id,
              l_current_org_id;

        CLOSE lock_req_lines_cs;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Locked the requisition Line Successfully ');
        END IF;

        d_progress := 20;
        --Set the org context to the org id of the parent req line.
        po_moac_utils_pvt.set_org_context(l_current_org_id);

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_current_org_id',l_current_org_id);
           PO_LOG.stmt(d_module_base,d_progress,'Set the org context to the organization in which Requisition was raised.');
        END IF;

        d_progress := 30;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Calculating value of max line number for the given requisition');
        END IF;
        --SQL What:Retrieve the max line number for the given requisition
        --         to which the requisition line belongs
        --SQL Why :This is required to calculate the line numbers when creating
        --         the new requisition lines

        SELECT MAX(prl.line_num)
        INTO   l_max_line_num
        FROM   po_requisition_lines_all prl
        WHERE  prl.requisition_header_id =
               (SELECT requisition_header_id
                FROM   po_requisition_lines_all
                WHERE  requisition_line_id = p_req_Line_id);

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_max_line_num',l_max_line_num);
        END IF;

        d_progress := 40;

        -- Call the function to split the requisition line
        x_new_line_ids_tbl := po_tbl_number(p_quantity_tbl.count);

        FOR l_line_num_index IN 1 .. p_num_of_new_lines
        LOOP
            --ascertain the serial number for each req line created
            --This would be added to max line number to determine the
            --line number for the line being created.

            IF l_line_num_index = 1
            THEN
                l_serial_num := 1;
            ELSE
                l_serial_num := l_serial_num + 1;
            END IF;
            --x_new_line_ids_tbl(l_line_num_index):=l_serial_num;
            --Insert appropriate data into requisition lines all

            IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,d_progress,'Inserting a new row');
               PO_LOG.stmt(d_module_base,d_progress,'l_serial_num',l_serial_num);
            END IF;

            --7835635
            SELECT po_requisition_lines_s.NEXTVAL into l_temp_requisition_line_id FROM dual;

            INSERT INTO po_requisition_lines_all
                (requisition_line_id,
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
                 ussgl_transaction_code,
                 government_context,
                 closed_reason,
                 closed_date,
                 transaction_reason_code,
                 quantity_received,
                 tax_code_id,
                 tax_user_override_flag,
                 oke_contract_header_id,
                 oke_contract_version_id,
                 secondary_unit_of_measure,
                 secondary_quantity,
                 preferred_grade,
                 secondary_quantity_received,
                 secondary_quantity_cancelled,
                 auction_header_id,
                 auction_display_number,
                 auction_line_number,
                 reqs_in_pool_flag,
                 vmi_flag,
                 bid_number,
                 bid_line_number,
                 order_type_lookup_code,
                 purchase_basis,
                 matching_basis,
                 org_id,
                 catalog_type,
                 catalog_source,
		 item_source_id,  --Added for bug 9092341
                 manufacturer_id,
                 manufacturer_name,
                 manufacturer_part_number,
                 requester_email,
                 requester_fax,
                 requester_phone,
                 unspsc_code,
                 other_category_code,
                 supplier_duns,
                 tax_status_indicator,
                 pcard_flag,
                 new_supplier_flag,
                 auto_receive_flag,
                 tax_attribute_update_code)
                (SELECT l_temp_requisition_line_id,
                       prl.requisition_header_id,
                       (l_serial_num + l_max_line_num),
                       prl.line_type_id,
                       prl.category_id,
                       prl.item_description,
                       prl.unit_meas_lookup_code,
                       prl.unit_price,
                       p_quantity_tbl(l_line_num_index),
                       prl.deliver_to_location_id,
                       prl.to_person_id,
		       SYSDATE,             -- Modified for bug 9092341
		       FND_GLOBAL.USER_ID,
                       prl.source_type_code,
                       prl.last_update_login,
		       SYSDATE,             -- Modified for bug 9092341
		       FND_GLOBAL.USER_ID,
                       prl.item_id,
                       prl.item_revision,
                       prl.quantity_delivered,
                       prl.suggested_buyer_id,
                       prl.encumbered_flag,
                       prl.rfq_required_flag,
                       prl.need_by_date,
                       prl.line_location_id,
                       NULL,
                       p_req_line_id,
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
                       decode(p_calling_program,g_CALLING_PROGRAM_SPLIT,
                              prl.un_number_id,null),
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
                       prl.ussgl_transaction_code,
                       prl.government_context,
                       prl.closed_reason,
                       prl.closed_date,
                       prl.transaction_reason_code,
                       prl.quantity_received,
                       prl.tax_code_id,
                       prl.tax_user_override_flag,
                       prl.oke_contract_header_id,
                       prl.oke_contract_version_id,
                       decode(p_calling_program,g_CALLING_PROGRAM_SPLIT,
                              prl.secondary_unit_of_measure,null),
                       prl.secondary_quantity,
                       prl.preferred_grade,
                       prl.secondary_quantity_received,
                       prl.secondary_quantity_cancelled,
                       prl.auction_header_id,
                       prl.auction_display_number,
                       prl.auction_line_number,
                       'Y', --new reqs are placed back in pool after splitting
                       prl.vmi_flag,
                       prl.bid_number,
                       prl.bid_line_number,
                       prl.order_type_lookup_code,
                       prl.purchase_basis,
                       prl.matching_basis,
                       prl.org_id,
                       prl.catalog_type,
                       prl.catalog_source,
		       prl.item_source_id, -- Added for bug 9092341
                       prl.manufacturer_id,
                       prl.manufacturer_name,
                       prl.manufacturer_part_number,
                       prl.requester_email,
                       prl.requester_fax,
                       prl.requester_phone,
                       prl.unspsc_code,
                       prl.other_category_code,
                       prl.supplier_duns,
                       prl.tax_status_indicator,
                       prl.pcard_flag,
                       prl.new_supplier_flag,
                       prl.auto_receive_flag,
                       g_TAX_ATTRIBUTE_CREATE
                FROM   po_requisition_lines_all prl
                WHERE  prl.requisition_line_id = p_req_line_id);

                --7835635

                INSERT INTO por_item_attribute_values(
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
                last_update_login)
                SELECT piav.item_type,
                piav.requisition_header_id,
                l_temp_requisition_line_id ,
                piav.attribute1,
                piav.attribute2,
                piav.attribute3,
                piav.attribute4,
                piav.attribute5,
                piav.attribute6,
                piav.attribute7,
                piav.attribute8,
                piav.attribute9,
                piav.attribute10,
                piav.attribute11,
                piav.attribute12,
                piav.attribute13,
                piav.attribute14,
                piav.attribute15,
                piav.org_id,
                piav.created_by,
                piav.creation_date,
                piav.last_updated_by,
                piav.last_update_date,
                piav.last_update_login
           FROM por_item_attribute_values piav
          WHERE piav.requisition_line_id = p_req_line_id;

        END LOOP;

        --7835635
        d_progress := 50;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Updating the old requisition line to mark it as modified and to push it out of pool');
        END IF;

        -- SQL What:Mark all the parent requisition lines which are split
        --          with modified_by_agent_flag setting 'Y'.
        -- SQL Why :This indicates that this requisition lines have been
        --          modified by the buyer and no longer available for any
        --          operations.
        --          Also implemented the following rules for Catalog Integration.

        --          If the original requisition line has a bid and/or negotiation
        --          reference, the bid and/or negotiation reference from the
        --          original requisition line should be dropped.

        --          If the original requisition line has a value for On RFQ flag
        --          the On RFQ flag from the original requisition line should be
        --          dropped.

        UPDATE po_requisition_lines_all
           SET modified_by_agent_flag    = 'Y',
               purchasing_agent_id       = p_agent_id,
               reqs_in_pool_flag         = NULL, --<REQINPOOL>
               on_rfq_flag               = decode(p_calling_program,
                                                  g_CALLING_PROGRAM_CATALOG,
                                                  null,
                                                  on_rfq_flag),
               bid_number                = decode(p_calling_program,
                                                  g_calling_program_catalog,
                                                  null,
                                                  bid_number),
               bid_line_number           = decode(p_calling_program,
                                                  g_calling_program_catalog,
                                                  null,
                                                  bid_line_number),
               auction_header_id         = decode(p_calling_program,
                                                  g_calling_program_catalog,
                                                  null,
                                                  auction_header_id),
               auction_display_number    = decode(p_calling_program,
                                                  g_calling_program_catalog,
                                                  null,
                                                  auction_display_number),
               auction_line_number       = decode(p_calling_program,
                                                  g_calling_program_catalog,
                                                  null,
                                                  auction_line_number),
               last_update_date          = SYSDATE,
               last_updated_by           = FND_GLOBAL.USER_ID,
               last_update_login         = FND_GLOBAL.LOGIN_ID
         WHERE requisition_line_id = p_req_line_id;

        --Collect all req line id's in a new table.
        --get the ids of the new lines created. This would be returned back as
        --an out parameter
        --Performance fix for bug 4930487
          SELECT PRL1.requisition_line_id
          BULK COLLECT
          INTO   new_req_line_id_rslt_tbl
          FROM   PO_REQUISITION_LINES_ALL PRL1, PO_REQUISITION_LINES_ALL PRL2
          WHERE  PRL1.requisition_header_id = PRL2.requisition_header_id
          AND    PRL1.parent_req_line_id = p_req_line_id
          AND    PRL2.requisition_line_id = p_req_line_id;

          IF PO_LOG.d_stmt THEN
              FOR i in 1..new_req_line_id_rslt_tbl.count LOOP
                 PO_LOG.stmt(d_module_base,d_progress,'new_req_line_id_rslt_tbl('||i||')',new_req_line_id_rslt_tbl(i));
              END LOOP;
          END IF;
        x_new_line_ids_tbl := new_req_line_id_rslt_tbl;

        d_progress := 60;

        IF FND_API.To_Boolean(p_commit)
        THEN
            IF PO_LOG.d_event THEN
               PO_LOG.event(d_module_base,d_progress,'Commiting work');
            END IF;
            COMMIT WORK;
        END IF; --FND_API

        d_progress := 70;
        x_return_status := FND_API.g_ret_sts_success;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_old_org_id',l_old_org_id);
        END IF;

        IF (PO_LOG.d_proc)
        THEN
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO create_requisition_lines_PVT;
            BEGIN
            -- Log a debug message, add the error the the API message list.
            po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
            FND_MSG_PUB.Add;
            FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());
            x_msg_data      := FND_MESSAGE.get;
            x_error_msg_tbl.extend(1);
            x_error_msg_tbl(x_error_msg_tbl.count) := x_msg_data;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    po_moac_utils_pvt.set_org_context(l_old_org_id);
                    IF (PO_LOG.d_exc)
                    THEN
                        PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                        PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                        PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                        PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
                    END IF;
                    RAISE;
            END;
    END create_requisition_lines;

    -------------------------------------------------------------------------------

    PROCEDURE post_modify_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_handle_tax_diff_if_enc  IN VARCHAR2,
                                      p_new_line_ids_tbl IN PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000) IS

        l_module CONSTANT VARCHAR2(100) := 'post_modify_requisition_lines';
        d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(d_PACKAGE_BASE, l_module);
        l_api_version CONSTANT NUMBER := 1.0;
        d_progress NUMBER;
        --declare the result tables.
        l_return_status               VARCHAR2(1);
        l_req_encumbrance_flag financials_system_parameters.req_encumbrance_flag%TYPE;
        l_online_report_id     PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
        l_success              BOOLEAN;
        l_requisition_header_id NUMBER;
        l_req_encumbered_flag VARCHAR2(5);
        l_quantity_table   PO_TBL_NUMBER;
        l_tax_message  FND_NEW_MESSAGES.message_text%type := NULL;
        l_message_text FND_NEW_MESSAGES.message_text%type := NULL;
    BEGIN
        --CREATE A SAVE POINT ON ENTERING THIS PROCEDURE
        SAVEPOINT post_requisition_lines_PVT;

        d_progress := 10;

        IF PO_LOG.d_event THEN
           PO_LOG.event(d_module_base,d_progress,'Post Modify Requisition ');
        END IF;

        --Initialize the error messages table
        x_error_msg_tbl :=po_tbl_varchar2000();

        IF NOT FND_API.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_module,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (PO_LOG.d_proc)
        THEN
            PO_LOG.proc_begin(d_module_base);
            PO_LOG.proc_begin(d_module_base,'p_api_version',    p_api_version  );
            PO_LOG.proc_begin(d_module_base,'p_init_msg_list',  p_init_msg_list);
            PO_LOG.proc_begin(d_module_base,'p_commit',         p_commit       );
            PO_LOG.proc_begin(d_module_base,'p_req_line_id',    p_req_line_id  );
        END IF;

        --update the supply for existing requisition line and create
        --supply for the new lines

        d_progress := 20;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Updating the requisition supply');
        END IF;

        l_success := po_supply.po_req_supply(NULL,
                                             p_req_line_id,
                                             NULL,
                                             g_EXPLODE_REQ_ACTION,
                                             NULL,
                                             NULL,
                                             NULL);

        --copy the attachments from the parent line onto the new req
        --lines created. Also create the distributions for each of the new
        --lines

        d_progress := 40;

        -- Performance fix for bug 4930487
        SELECT PRL1.quantity
        BULK COLLECT
        INTO l_quantity_table
        FROM  po_requisition_lines_all PRL1, po_requisition_lines_all PRL2
        WHERE PRL1.requisition_header_id = PRL2.requisition_header_id
        AND   PRL1.parent_req_line_id = p_req_line_id
        AND   PRL2.requisition_line_id = p_req_line_id;

        FOR l_req_line_index IN 1 .. P_new_line_ids_tbl.COUNT
        LOOP
            IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,d_progress,'l_req_line_index',l_req_line_index);
               PO_LOG.stmt(d_module_base,d_progress,'Coping attachments from old line to newly created lines');
            END IF;

            fnd_attached_documents2_pkg.copy_attachments(
                      X_from_entity_name         => g_REQ_LINES_ENTITY,
                      X_from_pk1_value           => p_req_line_id,
                      X_from_pk2_value           => NULL,
                      X_from_pk3_value           => NULL,
                      X_from_pk4_value           => NULL,
                      X_from_pk5_value           => NULL,
                      X_to_entity_name           => g_REQ_LINES_ENTITY,
                      X_to_pk1_value             => p_new_line_ids_tbl(l_req_line_index),
                      X_to_pk2_value             => NULL,
                      X_to_pk3_value             => NULL,
                      X_to_pk4_value             => NULL,
                      X_to_pk5_value             => NULL,
                      X_created_by               => NULL,
                      X_last_update_login        => NULL,
                      X_program_application_id   => NULL,
                      X_program_id               => NULL,
                      X_request_id               => NULL,
                      X_automatically_added_flag => NULL);

            IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,d_progress,'Creating a new distribution for ',p_new_line_ids_tbl(l_req_line_index));
            END IF;
            d_progress := 50;
            --Create req distributions for the newly created line
            PO_REQ_DIST_SV.create_dist_for_modify(
                               p_new_line_ids_tbl(l_req_line_index),
                               p_req_line_id,
                               l_quantity_table(l_req_line_index));

            IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,d_progress,'Succesfully created a new distribution for',p_new_line_ids_tbl(l_req_line_index));
            END IF;
        END LOOP;

        d_progress := 60;
        --Retrieve the value of l_requisition_header_id first
        select requisition_header_id
        into   l_requisition_header_id
        from po_requisition_lines_all
        where requisition_line_id = p_req_line_id;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_requisition_header_id',l_requisition_header_id);
        END IF;
        --Calculate the tax for the entire document again. The recoverable and non recoverable
        --tax fields need to be updated appropriately.
        PO_TAX_INTERFACE_PVT.calculate_tax_requisition(
                                                   p_requisition_header_id => l_requisition_header_id,
                                                   p_calling_program       => g_CALLING_PROGRAM_SPLIT,
                                                   x_return_status         => l_return_status);

        --<Bug#4765982 Start>
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          l_tax_message := FND_MESSAGE.get_string('PO','PO_TAX_CALCULATION')||' : ' ;

          FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT LOOP
            l_message_text := l_tax_message || po_tax_interface_pvt.G_TAX_ERRORS_TBL.message_text(i);
            FND_MESSAGE.set_name('PO','PO_CUSTOM_MSG');
            FND_MESSAGE.set_token('TRANSLATED_TOKEN',l_message_text);
            FND_MSG_PUB.Add;
          END LOOP;

          RAISE FND_API.G_EXC_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          FND_MESSAGE.set_name('PO','PO_PDOI_TAX_CALCULATION_ERR');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;--l_return_status
        --<Bug#4765982 End>


        --Check if the current org has req encumbrance enabled.
        --If it is enabled then handle funds reversal for the parent
        --line and encumber the newly created line
        d_progress := 70;
        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'Checking if requisition encumbrance is switched on');
        END IF;

        SELECT nvl(req_encumbrance_flag, 'N')
        INTO   l_req_encumbrance_flag
        FROM   financials_system_parameters;

        IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,d_progress,'l_req_encumbrance_flag',l_req_encumbrance_flag);
        END IF;

        --Select all the distribution lines which are to be reserved and
        --unreserved into a plsql table
        IF l_req_encumbrance_flag = 'Y'
        THEN
            begin
                SELECT ENCUMBERED_FLAG
                INTO l_req_encumbered_flag
                FROM PO_REQUISITION_LINES_ALL
                WHERE requisition_line_id = p_req_line_id;
            exception
                when others then
                    l_req_encumbered_flag :='N';
            end;

            if(l_req_encumbered_flag = 'Y')THEN
                d_progress := 80;
                IF PO_LOG.d_stmt THEN
                   PO_LOG.stmt(d_module_base,d_progress,'Calling funds reversal');
                END IF;
                --Pass the distribution ids of the newly created lines to the
                --encumbrance api to reserve funds
                call_funds_reversal(p_api_version            => 1.0,
                                    p_commit                 => p_commit,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_req_line_id            => p_req_line_id,
                                    p_handle_tax_flag        => p_handle_tax_diff_if_enc,
                                    x_online_report_id       => l_online_report_id);

                IF PO_LOG.d_stmt THEN
                   PO_LOG.stmt(d_module_base,d_progress,'l_return_status'||l_return_status);
                END IF;

                IF (l_return_status = FND_API.g_ret_sts_error)
                THEN
                    RAISE FND_API.g_exc_error;
                ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error)
                THEN
                    RAISE FND_API.g_exc_unexpected_error;
                END IF; --l_return_status
            END IF;
        END IF; --l_req_encumbrance_flag

        d_progress := 90;

        IF FND_API.To_Boolean(p_commit)
        THEN
            IF PO_LOG.d_event THEN
               PO_LOG.event(d_module_base,d_progress,'Commiting work');
            END IF;
            COMMIT WORK;
        END IF; --FND_API

        x_return_status := FND_API.g_ret_sts_success;

        IF (PO_LOG.d_proc)
        THEN
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
        END IF;
    EXCEPTION
        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO post_requisition_lines_PVT;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF(x_msg_count>0)THEN
                NULL;
            ELSE
                po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
                FND_MSG_PUB.Add;
            END IF;

            FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());
            x_msg_data      := FND_MESSAGE.get;
            x_error_msg_tbl.extend(1);
            x_error_msg_tbl(x_error_msg_tbl.COUNT) := x_msg_data;

            x_return_status := FND_API.g_ret_sts_unexp_error;

            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO post_requisition_lines_PVT;

            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF l_online_report_id IS NOT NULL THEN
                    PO_Document_Control_PVT.add_online_report_msgs
                                  (
                                  p_api_version      => 1.0
                                 ,p_init_msg_list    => FND_API.G_FALSE
                                 ,x_return_status    => x_return_status
                                 ,p_online_report_id => l_online_report_id);
            END IF;

            FOR i IN 1..FND_MSG_PUB.count_msg loop
              FND_MESSAGE.set_encoded(encoded_message =>
                                                  FND_MSG_PUB.get(p_msg_index => i));
              x_error_msg_tbl.extend(1);
              x_error_msg_tbl(i) := FND_MESSAGE.get;
            END LOOP;
            --<bug#5523323 START>
            --Set the return status at the end so that the call to add
            --online report msgs onto the stack doesn't override the value set
            --by the exception handler.
            x_return_status := FND_API.g_ret_sts_error;
            --<bug#5523323 END>
            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;
        WHEN OTHERS THEN
            ROLLBACK TO post_requisition_lines_PVT;
            BEGIN
            -- Log a debug message, add the error the the API message list.
            po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
            FND_MSG_PUB.Add;
            FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());
            x_msg_data      := FND_MESSAGE.get;
            x_error_msg_tbl.extend(1);
            x_error_msg_tbl(1) := x_msg_data;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (PO_LOG.d_exc)
            THEN
                PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
            END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    IF (PO_LOG.d_exc)
                    THEN
                        PO_LOG.exc(d_module_base,d_progress, SQLCODE || SQLERRM);
                        PO_LOG.proc_end(d_module_base,'x_return_status',  x_return_status);
                        PO_LOG.proc_end(d_module_base,'x_msg_count',      x_msg_count    );
                        PO_LOG.proc_end(d_module_base,'x_msg_data',       x_msg_data     );
                    END IF;
                    RAISE;
            END;
    END post_modify_requisition_lines;

    -------------------------------------------------------------------------------

    -------------------------------------------------------------------------------

  PROCEDURE call_funds_reversal(p_api_version      IN NUMBER,
                                  p_commit           IN VARCHAR2,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2,
                                  p_req_line_id      IN NUMBER,
                                  p_handle_tax_flag  IN VARCHAR2,
                                  x_online_report_id OUT NOCOPY NUMBER) IS
    l_module      CONSTANT VARCHAR2(30) := 'CALL_FUNDS_REVERSAL';
    l_api_version CONSTANT NUMBER := 1.0;
    d_progress NUMBER;
    d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(d_PACKAGE_BASE,
                                                                       l_module);
    --define object type variable for calling encumbrance api.
    l_po_return_code           VARCHAR2(20);

  BEGIN

    d_progress := 10;

    SAVEPOINT CALL_FUNDS_REVERSAL_PVT;

    IF (PO_LOG.d_event) THEN
      PO_LOG.event(d_module_base,d_progress,'Starting calculate CALL_FUNDS_REVERSAL');
    END IF;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module_base, 'p_api_version', p_api_version);
      PO_LOG.proc_begin(d_module_base, 'p_commit', p_commit);
      PO_LOG.proc_begin(d_module_base, 'p_req_line_id', p_req_line_id);
    END IF;

    d_progress := 20;
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_module,
                                       G_PKG_NAME) THEN
      IF (PO_LOG.d_event) THEN
        PO_LOG.event(d_module_base, d_progress, 'Api versions incompatible. Throwing an exception');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    d_progress := 30;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Inserting values into po_req_split_lines_gt');
    END IF;

    -- Performance fix for bug 4930487
    -- Prevented FTS on po_requisition_lines_all by adding an exists clause
    INSERT INTO po_req_split_lines_gt
      (requisition_header_id,
       requisition_line_id,
       allocated_qty,
       new_req_line_id,
       record_status)
      SELECT prl.requisition_header_id,
             p_req_line_id,
             prl.quantity,
             DECODE(prl.requisition_line_id,
                    p_req_line_id,
                    NULL,
                    prl.requisition_line_id),
             DECODE(prl.requisition_line_id, p_req_line_id, 'S', 'N')
        FROM po_requisition_lines prl
       WHERE (prl.requisition_line_id = p_req_line_id OR
             prl.parent_req_line_id = p_req_line_id)
       AND EXISTS(
                   SELECT requisition_header_id
                   FROM po_requisition_lines_all PRL1
                   WHERE PRL1.requisition_header_id = prl.requisition_header_id
                   AND PRL1.requisition_line_id = p_req_line_id);


    IF SQL%ROWCOUNT < 1 THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'No rows inserted into PO_REQ_SPLIT_LINES_GT');
      END IF;

      po_message_s.sql_error('No rows inserted into PO_REQ_SPLIT_LINES_GT', d_progress, sqlcode);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    d_progress := 40;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'Handle Tax Adjustments');
    END IF;

    IF (p_handle_tax_flag = 'Y') THEN
      PO_NEGOTIATIONS4_PVT.handle_tax_adjustments(p_api_version   => 1.0,
                                                  p_commit        => 'F',
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data);
      IF (x_return_status <> 'S') THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'x_return_status',x_return_status);
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF; /*IF (p_handle_tax_flag = 'Y')*/

    d_progress := 50;

    PO_NEGOTIATIONS4_PVT.handle_funds_reversal(p_api_version      => 1.0,
                                               p_commit           => 'F',
                                               x_return_status    => x_return_status,
                                               x_msg_count        => x_msg_count,
                                               x_msg_data         => x_msg_data,
                                               x_online_report_id => x_online_report_id);

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base, d_progress,'x_return_status',x_return_status);
      PO_LOG.stmt(d_module_base, d_progress,'l_po_return_code', l_po_return_code);
      PO_LOG.stmt(d_module_base, d_progress,'x_online_report_id', x_online_report_id);
    END IF;

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    d_progress := 60;

    IF FND_API.To_Boolean(p_commit) THEN
      IF PO_LOG.d_event THEN
        PO_LOG.event(d_module_base, d_progress, 'Commiting work');
      END IF;
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    d_progress := 70;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
      PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
      PO_LOG.proc_end(d_module_base,'x_online_report_id',x_online_report_id);
    END IF;

  EXCEPTION

    WHEN FND_API.g_exc_unexpected_error THEN

      ROLLBACK TO CALL_FUNDS_REVERSAL_PVT;

      x_msg_data      := FND_MSG_PUB.GET();
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
        PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
        PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
        PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
        PO_LOG.proc_end(d_module_base,'x_online_report_id',x_online_report_id);
      END IF;

    WHEN FND_API.g_exc_error THEN

      ROLLBACK TO CALL_FUNDS_REVERSAL_PVT;

      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
        PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
        PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
        PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
        PO_LOG.proc_end(d_module_base,'x_online_report_id', x_online_report_id);
      END IF;

    WHEN OTHERS THEN

      po_message_s.sql_error(g_pkg_name, l_module, d_progress, SQLCODE, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MESSAGE.set_encoded(encoded_message =>FND_MSG_PUB.GET());

      ROLLBACK TO CALL_FUNDS_REVERSAL_PVT;
      x_msg_data      := FND_MESSAGE.get;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
        PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
        PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
        PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
        PO_LOG.proc_end(d_module_base, 'x_online_report_id', x_online_report_id);

      END IF;

  END call_funds_reversal;
    -------------------------------------------------------------------------------
END PO_MODIFY_REQUISITION_PVT;

/
