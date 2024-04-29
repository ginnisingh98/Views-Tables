--------------------------------------------------------
--  DDL for Package Body MRP_CANCEL_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CANCEL_PO" AS
/*$Header: MRPCNPOB.pls 120.1.12010000.1 2008/07/28 04:47:23 appldev ship $ */
-- -------------------------------------------------
-- Bug#4013684 - 16-dec-2004.
-- Added new parameters p_doc_type and p_doc_subtype
-- Which will be passed to PO api.
-- -------------------------------------------------
PROCEDURE cancel_po_program
(
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_po_ship_num IN NUMBER,
p_doc_type    IN VARCHAR2,
p_doc_subtype IN VARCHAR2
) IS

l_original_org_context  VARCHAR2(10);
l_document_org_id       NUMBER;
l_release_number NUMBER;
l_po_line_id NUMBER;
l_pos_lbrace NUMBER;
l_pos_rbrace NUMBER;
x_return_status VARCHAR2(1);
l_access_mode VARCHAR2(1);
l_current_org_id NUMBER;

BEGIN
        BEGIN
			-- Remember the current org context.
			l_original_org_context := SUBSTRB(USERENV('CLIENT_INFO'),1,10);

			-- Before calling the PO Cancel API (which uses org-striped views),
			-- We need to retrieve and set the org context to the document's operating unit.
			SELECT org_id
			INTO l_document_org_id
			FROM po_headers_all
			WHERE po_header_id = p_po_header_id;

            l_access_mode := mo_global.Get_access_mode();
            l_current_org_id := mo_global.get_current_org_id();

			--FND_CLIENT_INFO.set_org_context(to_char(l_document_org_id));
			mo_global.set_policy_context('S',l_document_org_id);--MOAC changes

            l_po_line_id := p_po_line_id;
            IF p_doc_type = 'RELEASE' THEN
                l_pos_lbrace := instr(p_po_number,'(');
                l_pos_rbrace := instr(p_po_number,')');
                l_release_number := substr(p_po_number, l_pos_lbrace +1,(l_pos_rbrace -(l_pos_lbrace+1)));
                l_po_line_id := NULL;
            END IF;
			--call the Cancel API
			PO_Document_Control_GRP.control_document(
				p_api_version  => 1.0,
				p_init_msg_list => FND_API.G_TRUE,
				p_commit     => FND_API.G_TRUE,
				x_return_status  => x_return_status,
				p_doc_type    =>  p_doc_type,
				p_doc_subtype  => p_doc_subtype,
				p_doc_id    => p_po_header_id,
				p_doc_num    => null,
				p_release_id  => null,
				p_release_num  => l_release_number,
				p_doc_line_id  => l_po_line_id,
				p_doc_line_num  => null,
				p_doc_line_loc_id  => NULL,
				p_doc_shipment_num => p_po_ship_num ,
				p_source     => null,
				p_action      => 'CANCEL',
				p_action_date   => SYSDATE,
				p_cancel_reason  => null,
				p_cancel_reqs_flag  => null,
				p_print_flag     => null,
				p_note_to_vendor  =>null);

	 -- Set the org context back to the original operating unit.
	  --FND_CLIENT_INFO.set_org_context(l_original_org_context);

	  Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,
	                                p_org_id => l_current_org_id);

	  EXCEPTION
              WHEN OTHERS THEN
                  --FND_CLIENT_INFO.set_org_context(l_original_org_context);

                  Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,
	                                            p_org_id => l_current_org_id);
	  END;

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'cancellation succeeds');
          else
             FND_FILE.PUT_LINE(FND_FILE.LOG,'cancellation fails');
          end if;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'header: '||p_po_header_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'line: '||p_po_line_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'po number: '||p_po_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'shipment number: '||p_po_ship_num);

END cancel_po_program;

END mrp_cancel_po;

/
