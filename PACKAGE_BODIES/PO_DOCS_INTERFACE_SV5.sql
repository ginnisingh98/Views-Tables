--------------------------------------------------------
--  DDL for Package Body PO_DOCS_INTERFACE_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCS_INTERFACE_SV5" AS
/* $Header: POXPIDIB.pls 120.3 2005/12/16 17:18:54 bao noship $ */


d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_DOCS_INTERFACE_SV5');

/*================================================================

  PROCEDURE NAME:   process_po_headers_interface()

==================================================================*/
PROCEDURE process_po_headers_interface(
                        X_selected_batch_id            IN  NUMBER,
                        X_buyer_id                  IN  NUMBER,
                        X_document_type               IN	VARCHAR2,
                        X_document_subtype            IN    VARCHAR2,
                        X_create_items                IN  VARCHAR2,
                        X_create_sourcing_rules_flag  IN  VARCHAR2,
                        X_rel_gen_method            IN   VARCHAR2,
                        X_approved_status            IN  VARCHAR2,
                        X_commit_interval            IN  NUMBER,
                        X_process_code              IN  VARCHAR2, -- can be 'PENDING' or 'NOTIFIED'
                        X_interface_header_id         IN    NUMBER ,
                        X_org_id_param                IN    NUMBER ,
                        X_ga_flag                     IN    VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                        p_sourcing_level          IN    VARCHAR2 DEFAULT NULL,
                        p_inv_org_id               IN    PO_HEADERS_INTERFACE.org_id%type DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>
                        )   -- FPI GA

IS

d_api_name CONSTANT VARCHAR2(30) := 'process_po_headers_interface';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  -- <PO PDOI Rewrite R12>
  -- Removed original content of this procedure. This is now served as a wrapper
  -- to the new PDOI.
  PO_PDOI_GRP.start_process
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    p_commit => FND_API.G_TRUE,
    x_return_status => l_return_status,
    p_gather_intf_tbl_stat => FND_API.G_FALSE,
    p_calling_module => PO_PDOI_CONSTANTS.g_CALL_MOD_UNKNOWN,
    p_selected_batch_id => x_selected_batch_id,
    p_batch_size => PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE,
    p_buyer_id => x_buyer_id,
    p_document_type => x_document_type,
    p_document_subtype => x_document_subtype,
    p_create_items => x_create_items,
    p_create_sourcing_rules_flag => x_create_sourcing_rules_flag,
    p_rel_gen_method => x_rel_gen_method,
    p_sourcing_level => p_sourcing_level,
    p_sourcing_inv_org_id => p_inv_org_id,
    p_approved_status => x_approved_status,
    p_process_code => x_process_code,
    p_interface_header_id => x_interface_header_id,
    p_org_id => x_org_id_param,
    p_ga_flag => x_ga_flag
  );

  d_position := 10;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'l_return_status', l_return_status);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process_po_headers_interface;

END PO_DOCS_INTERFACE_SV5;

/
