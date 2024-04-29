--------------------------------------------------------
--  DDL for Package PO_PDOI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_GRP.pls 120.4.12010000.4 2014/03/11 03:42:26 sbontala ship $ */

PROCEDURE start_process
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_validation_level IN NUMBER,
  p_commit IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_gather_intf_tbl_stat IN VARCHAR2,
  p_calling_module IN VARCHAR2,
  p_selected_batch_id IN NUMBER,
  p_batch_size IN NUMBER,
  p_buyer_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2,
  p_create_items IN VARCHAR2,
  p_create_sourcing_rules_flag IN VARCHAR2,
  p_rel_gen_method IN VARCHAR2,
  p_sourcing_level IN VARCHAR2,
  p_sourcing_inv_org_id IN NUMBER,
  p_approved_status IN VARCHAR2,
  p_process_code IN VARCHAR2,
  p_interface_header_id IN NUMBER,
  p_org_id IN NUMBER,
  p_ga_flag IN VARCHAR2,
  --PDOI Enhancement Bug#17063664
  p_group_lines IN VARCHAR2  DEFAULT 'N',
  p_group_shipments IN VARCHAR2 DEFAULT 'N'
);

-- <<PDOI Enhancement Bug#17063664 Start>>
--<<Bug#18265579 : Added default values
--for all the parameters to proceed
--successfully when concurrent program
--launched from backend.
PROCEDURE start_process
( x_errbuf OUT NOCOPY  VARCHAR2,
  x_retcode OUT NOCOPY VARCHAR2,
  p_buyer_id IN NUMBER DEFAULT NULL,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2 DEFAULT NULL,
  p_create_items IN VARCHAR2,
  p_create_sourcing_rules_flag IN VARCHAR2 DEFAULT NULL,
  p_approved_status IN VARCHAR2 DEFAULT NULL,
  p_rel_gen_method IN VARCHAR2 DEFAULT NULL,
  p_selected_batch_id IN NUMBER DEFAULT NULL,
  p_org_id IN NUMBER DEFAULT NULL,
  p_ga_flag IN VARCHAR2 DEFAULT NULL,
  p_enable_sourcing_level IN VARCHAR2 DEFAULT NULL,
  p_sourcing_level IN VARCHAR2 DEFAULT NULL,
  p_inv_org_enable IN VARCHAR2 DEFAULT NULL,
  p_sourcing_inv_org_id IN NUMBER DEFAULT NULL,
  p_group_lines IN VARCHAR2 DEFAULT 'N',
  p_batch_size IN NUMBER DEFAULT NULL,
  p_gather_stats IN VARCHAR2 DEFAULT NULL
);
-- <<PDOI Enhancement Bug#17063664 End>>

PROCEDURE catalog_upload
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_validation_level IN NUMBER,
  p_commit IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_gather_intf_tbl_stat IN VARCHAR2,
  p_selected_batch_id IN NUMBER,
  p_batch_size IN NUMBER,
  p_buyer_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2,
  p_create_items IN VARCHAR2,
  p_create_sourcing_rules_flag IN VARCHAR2,
  p_rel_gen_method IN VARCHAR2,
  p_sourcing_level IN VARCHAR2,
  p_sourcing_inv_org_id IN NUMBER,
  p_approved_status IN VARCHAR2,
  p_process_code IN VARCHAR2,
  p_interface_header_id IN NUMBER,
  p_org_id IN NUMBER,
  p_ga_flag IN VARCHAR2,
  p_submit_dft_flag IN VARCHAR2,
  p_role IN VARCHAR2,
  p_catalog_to_expire IN VARCHAR2,
  p_err_lines_tolerance IN NUMBER,
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
);

PROCEDURE handle_price_tolerance_resp
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_validation_level IN NUMBER,
  p_commit IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_selected_batch_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2,
  p_interface_header_id IN NUMBER,
  p_org_id IN NUMBER
);


END PO_PDOI_GRP;

/
