--------------------------------------------------------
--  DDL for Package Body PO_PDOI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_PVT" AS
/* $Header: PO_PDOI_PVT.plb 120.6.12010000.6 2014/02/22 11:56:24 srpantha ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_PDOI_PVT');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE log_audsid;

PROCEDURE init_startup_values
( p_calling_module IN VARCHAR2,
  p_validation_level IN NUMBER,
  p_commit IN VARCHAR2,
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
  --PDOI Enhancement Bug#17063664
  p_group_lines  IN VARCHAR2,
  p_group_shipments IN VARCHAR2
);

PROCEDURE init_sys_parameters;

PROCEDURE init_profile_parameters;

PROCEDURE init_product_parameters;

-- PDOI Enhancement Bug#17063664
-- Initially we had when to archive blanket, standard
-- Removing this as it is no longer required.

PROCEDURE gather_interface_table_stat;

PROCEDURE set_draft_errors;

PROCEDURE wrap_up;

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: start_process
--Function:
--  Main procedure for PDOI, which is used for importing and updating
--  blankets, quotations or standard purchase orders
--Parameters:
--IN:
--p_api_version
--  API version of the program caller assumes
--p_init_msg_list
--  FND_API.G_TRUE if caller expects PDOI to initialize the message stack
--                 maintained by FND_MSG_PUB.
--  FND_API.G_FALSE otherwise
--p_validation_level
--  Currently this parameter has no effect. PDOI always does full validation
--p_commit
--  Whether PDOI will issue commits
--  FND_API.G_TRUE if caller expects PDOI to commit data
--  FND_API.G_FALSE otherwise
--p_gather_intf_tbl_stat
--  Whether PDOI gather table statistics before processing.
--  'Y' if statistics should be gathered. Consider this if a large
--      number of records are being inserted into the interface table
--  'N' otherwise
--p_calling_module
--  The module name of the calling program. Value 'CATALOG UPLOAD' is reserved
--  to be used by calling from Calog upload program
--p_selected_batch_id
--  Batch id parameter. If this is specified, only the records with this batch
--  id will be processed.
--p_batch_size
--  Used for performance tuning. It specifies the number of header interface
--  records that will be processed for each bulk fetching. Default number is
--  PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE
--p_buyer_id
--  Default buyer of the document to be imported
--p_document_type
--  Type of the document that will be processed. Possible values are:
--  STANDARD, BLANKET, QUOTATION
--p_document_subtype
--  Default document subtype. Use it only if  p_document_type is 'QUOTATION'.
--p_create_items
--  Specifies whether an item will be created as inventory item if the specified
--  item does not exist in the system.
--  'Y' if item should be created
--  'N' if item should NOT be created
--p_create_sourcing_rules_flag
--  Whether sourcing rules and ASL should be created as part of the creation
--  of blanket and quotation line
--  'Y' if sourcing rules and ASL should be created
--  'N' otherwise
--p_rel_gen_method
--  Release generation method of the ASL
--p_sourcing_level
--  Level of the sourcing rules assignment. Possible values:
--  ITEM, ITEM-ORGANIZATION
--p_sourcing_inv_org_id
--  If sourcing level is 'ITEM-ORGANIZATION', the organization where the
--  sourcing rule will be created in
--p_approved_status
--  Intended approval status the document after import. Possible values
--  INCOMPLETE - Incomplete documents
--  INITIATE APPROVAL - This means that the document will be submitted for
--                      approval through approval workflow
--  APPROVED - Import as approved without submitting through approval wf
--p_process_code
--  Type of interface records to be processed. If this is specified, only
--  records with the specified process code will be processed
--p_interface_header_id
--  If this is specified, only record with this interface_header_id will be
--  processed
--p_org_id
--  Operating Unit where this PDOI will be running in. If this is not specified,
--  Current operating unit will be the operating unit for PDOI to run.
--p_ga_flag
--  Whether the blanket will be imported as global agreement or not.
--  'Y' if blanekets should be imported as global agreements
--p_submit_dft_flag
--  ** Reserved for catalog upload **
--  Determines whether the draft changes should be submitted for buyer's
--  acceptance after they pass PDOI validations
--  'Y' if changes should be submitted
--  'N' otherwise
--p_role
--  ** Reserved for catalog upload ***
--  Role of the user calling PDOI. Possible values:
--  BUYER, SUPPLIER, CAT ADMIN
--p_catalog_to_expire
--  ** Reserved for catalog upload ***
--  If this is specified, all the lines with this value as the catalog name
--  will get expired
--p_err_lines_tolerance
--  ** Reserved for catalog upload **
--  Number of line errors PDOI can take before aborting the program.
--  Note: Even if PDOI is aborted, lines that get accepted will continue to
--        be processed.
-- p_group_lines
-- Indicates whether lines should be grouped or not
-- p_group_shipments
-- Indicates whether lines should be grouped or not
--IN OUT:
--OUT:
--x_return_status
--  Return status of the API.
--  FND_API.G_RET_STS_SUCCESS if API is successful
--  FND_API.G_RET_STS_ERR if there are user errors
--  FND_API.G_RET_STS_UNEXP_ERR if unexpected error (exception) occurs
--x_processed_lines_count
--  ** Populated for catalog upload only **
--  Number of lines being processed
--x_rejected_lines_count
--  ** Populated for catalog upload only **
--  Number of lines being rejected
--x_err_tolerance_exceeded
--  ** Populated for catalog upload only **
--  indicates whether error threshold is exceeded
--  FND_API.G_TRUE if exceeded
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
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
  p_submit_dft_flag IN VARCHAR2,
  p_role IN VARCHAR2,
  p_catalog_to_expire IN VARCHAR2,
  p_err_lines_tolerance IN NUMBER,
  p_group_lines IN VARCHAR2,--PDOI Enhancement Bug#17063664
  p_group_shipments IN VARCHAR2,--PDOI Enhancement Bug#17063664
  x_processed_lines_count OUT NOCOPY NUMBER,
  x_rejected_lines_count OUT NOCOPY NUMBER,
  x_err_tolerance_exceeded OUT NOCOPY VARCHAR2
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'start_process';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_all_headers_processed VARCHAR2(1);

l_validation_level VARCHAR2(10);
l_org_id PO_HEADERS_ALL.org_id%TYPE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin (d_module, 'p_init_msg_list', p_init_msg_list);
    PO_LOG.proc_begin (d_module, 'p_validation_level', p_validation_level);
    PO_LOG.proc_begin (d_module, 'p_commit', p_commit);
    PO_LOG.proc_begin (d_module, 'p_gather_intf_tbl_stat', p_gather_intf_tbl_stat);
    PO_LOG.proc_begin (d_module, 'p_calling_module', p_calling_module);
    PO_LOG.proc_begin (d_module, 'p_selected_batch_id', p_selected_batch_id);
    PO_LOG.proc_begin (d_module, 'p_batch_size', p_batch_size);
    PO_LOG.proc_begin (d_module, 'p_buyer_id', p_buyer_id);
    PO_LOG.proc_begin (d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin (d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin (d_module, 'p_create_items', p_create_items);
    PO_LOG.proc_begin (d_module, 'p_create_sourcing_rules_flag', p_create_sourcing_rules_flag);
    PO_LOG.proc_begin (d_module, 'p_rel_gen_method', p_rel_gen_method);
    PO_LOG.proc_begin (d_module, 'p_sourcing_level', p_sourcing_level);
    PO_LOG.proc_begin (d_module, 'p_sourcing_inv_org_id', p_sourcing_inv_org_id);
    PO_LOG.proc_begin (d_module, 'p_approved_status', p_approved_status);
    PO_LOG.proc_begin (d_module, 'p_process_code', p_process_code);
    PO_LOG.proc_begin (d_module, 'p_interface_header_id', p_interface_header_id);
    PO_LOG.proc_begin (d_module, 'p_org_id', p_org_id);
    PO_LOG.proc_begin (d_module, 'p_ga_flag', p_ga_flag);
    PO_LOG.proc_begin (d_module, 'p_submit_dft_flag', p_submit_dft_flag);
    PO_LOG.proc_begin (d_module, 'p_role', p_role);
    PO_LOG.proc_begin (d_module, 'p_catalog_to_expire', p_catalog_to_expire);
    PO_LOG.proc_begin (d_module, 'p_err_lines_tolerance', p_err_lines_tolerance);
    --<< PDOI Enhancement Bug#17063664 START>--
    PO_LOG.proc_begin (d_module, 'p_group_lines',p_group_lines);
    PO_LOG.proc_begin (d_module, 'p_group_shipments',p_group_shipments);
    --<< PDOI Enhancement Bug#17063664 END>--
  END IF;

  PO_TIMING_UTL.init;
  PO_TIMING_UTL.start_time (PO_PDOI_CONSTANTS.g_T_PDOI_ALL);

  -- put down information about how to get logging messages
  log_audsid;

  IF (NOT FND_API.Compatible_API_Call
        ( p_current_version_number => d_api_version
        , p_caller_version_number  => p_api_version
        , p_api_name               => d_api_name
        , p_pkg_name               => d_pkg_name
        )
   ) THEN
    d_position := 10;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;  -- not compatible_api

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    FND_MSG_PUB.initialize;
  END IF;

  d_position := 20;

  IF (p_org_id IS NOT NULL) THEN
    PO_MOAC_UTILS_PVT.set_org_context (p_org_id);
  END IF;

  d_position := 30;

  l_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;

  d_position := 40;

  PO_INTERFACE_ERRORS_UTL.init_errors_tbl; -- initialize errors tbl

  d_position := 50;

  init_startup_values
  ( p_calling_module             => p_calling_module,
    p_validation_level           => p_validation_level,
    p_commit                     => p_commit,
    p_selected_batch_id          => p_selected_batch_id,
    p_batch_size                 => NVL(p_batch_size, PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE),
    p_buyer_id                   => p_buyer_id,
    p_document_type              => p_document_type,
    p_document_subtype           => p_document_subtype,
    p_create_items               => p_create_items,
    p_create_sourcing_rules_flag => p_create_sourcing_rules_flag,
    p_rel_gen_method             => p_rel_gen_method,
    p_sourcing_level             => p_sourcing_level,
    p_sourcing_inv_org_id        => p_sourcing_inv_org_id,
    p_approved_status            => p_approved_status,
    p_process_code               => p_process_code,
    p_interface_header_id        => p_interface_header_id,
    p_org_id                     => l_org_id,
    p_ga_flag                    => p_ga_flag,
    p_submit_dft_flag            => p_submit_dft_flag,
    p_role                       => p_role,
    p_catalog_to_expire          => p_catalog_to_expire,
    p_err_lines_tolerance        => p_err_lines_tolerance,
    --PDOI Enhancement Bug#17063664
    p_group_lines            => p_group_lines,
    p_group_shipments            => p_group_shipments
  );

  d_position := 60;



  d_position := 70;

  PO_PDOI_PREPROC_PVT.process;  -- pre processing

  --Bug 13343886
    IF (p_gather_intf_tbl_stat = 'Y') THEN
    d_position := 80;
    gather_interface_table_stat;
  END IF;

  LOOP
    d_position := 90;

    BEGIN
      -- looping for each round of header record processing
      PO_PDOI_HEADER_GROUPING_PVT.process  -- header grouping
      ( x_all_headers_processed => l_all_headers_processed
      );

      d_position := 100;
      EXIT WHEN l_all_headers_processed = FND_API.G_TRUE;

      d_position := 110;
      PO_PDOI_MAINPROC_PVT.process;  -- main processing

      d_position := 120;
      PO_PDOI_POSTPROC_PVT.process;  -- post processing

    EXCEPTION
    WHEN OTHERS THEN
      set_draft_errors;
      RAISE;
    END;
  END LOOP;

  d_position := 130;

  x_processed_lines_count  := PO_PDOI_PARAMS.g_out.processed_lines_count;
  x_rejected_lines_count   := PO_PDOI_PARAMS.g_out.rejected_lines_count;
  x_err_tolerance_exceeded := PO_PDOI_PARAMS.g_out.err_tolerance_exceeded;

  d_position := 140;

  PO_PDOI_UTL.commit_work;

  d_position := 150;

  PO_TIMING_UTL.stop_time (PO_PDOI_CONSTANTS.g_T_PDOI_ALL);

  -- do interface errors reporting, log timing, etc.
  wrap_up;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  PO_TIMING_UTL.stop_time (PO_PDOI_CONSTANTS.g_T_PDOI_ALL);

  wrap_up;

END start_process;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ---------------------
-------------------------------------------------------


-----------------------------------------------------------------------
--Start of Comments
--Name: log_audsid
--Function: put audsid to the log file. This id is used to retrieve all
--          pdoi messages from FND_LOG_MESSAGES table
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE log_audsid IS

d_api_name CONSTANT VARCHAR2(30) := 'log_audsid';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_audsid NUMBER := USERENV('SESSIONID');
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'AUDSID = ' || l_audsid);
  END IF;

  FND_FILE.put_line(FND_FILE.log,
                    'To get the log messages for PDOI, please use the ' ||
                    'following id to query against FND_LOG_MESSAGES table:');

  FND_FILE.put_line(FND_FILE.log, 'AUDSID = ' || l_audsid);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END log_audsid;


-----------------------------------------------------------------------
--Start of Comments
--Name: init_startup_values
--Function:
--  Derive startup values (system parameters, profiles, etc.) that will
--  be used throughout PDOI
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_startup_values
( p_calling_module IN VARCHAR2,
  p_validation_level IN NUMBER,
  p_commit IN VARCHAR2,
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
  --PDOI Enhancement Bug#17063664
  p_group_lines  IN VARCHAR2,
  p_group_shipments IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'init_startup_values';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- Setup g_request
  PO_PDOI_PARAMS.g_request.calling_module      := NVL(p_calling_module, PO_PDOI_CONSTANTS.g_call_mod_UNKNOWN);
  PO_PDOI_PARAMS.g_request.validation_level    := p_validation_level;
  PO_PDOI_PARAMS.g_request.commit_work         := p_commit;
  PO_PDOI_PARAMS.g_request.batch_id            := p_selected_batch_id;
  PO_PDOI_PARAMS.g_request.batch_size          := p_batch_size;
  PO_PDOI_PARAMS.g_request.buyer_id            := p_buyer_id;
  PO_PDOI_PARAMS.g_request.document_type       := p_document_type;
  PO_PDOI_PARAMS.g_request.document_subtype    := p_document_subtype;
  PO_PDOI_PARAMS.g_request.create_items        := p_create_items;
  PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag := p_create_sourcing_rules_flag;
  PO_PDOI_PARAMS.g_request.rel_gen_method      := p_rel_gen_method;
  PO_PDOI_PARAMS.g_request.sourcing_level      := p_sourcing_level;
  PO_PDOI_PARAMS.g_request.sourcing_inv_org_id := p_sourcing_inv_org_id;
  PO_PDOI_PARAMS.g_request.approved_status     := p_approved_status;
  PO_PDOI_PARAMS.g_request.process_code        := p_process_code;
  PO_PDOI_PARAMS.g_request.interface_header_id := p_interface_header_id;
  PO_PDOI_PARAMS.g_request.org_id              := p_org_id;
  PO_PDOI_PARAMS.g_request.ga_flag             := p_ga_flag;
  PO_PDOI_PARAMS.g_request.submit_dft_flag     := p_submit_dft_flag;
  PO_PDOI_PARAMS.g_request.role                := p_role;
  PO_PDOI_PARAMS.g_request.catalog_to_expire   := p_catalog_to_expire;
  PO_PDOI_PARAMS.g_request.err_lines_tolerance := p_err_lines_tolerance;
    --PDOI Enhancement Bug#17063664
  PO_PDOI_PARAMS.g_request.group_lines         := p_group_lines;
  PO_PDOI_PARAMS.g_request.group_shipments     := p_group_shipments;

  d_position := 10;

  -- Setup g_sys
  init_sys_parameters;

  d_position := 20;
  -- Setup g_profile
  init_profile_parameters;

  d_position := 30;
  -- Setup g_product
  init_product_parameters;

  d_position := 40;
  -- default processing_id
  SELECT PO_PDOI_PROCESSING_ID_S.nextval
  INTO PO_PDOI_PARAMS.g_processing_id
  FROM DUAL;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'g_processsing_id',
                 PO_PDOI_PARAMS.g_processing_id);
  END IF;

  d_position := 50;
  -- initializing tracking variables for PDOI
  PO_PDOI_PARAMS.g_original_doc_processed := FND_API.G_FALSE;
  PO_PDOI_PARAMS.g_current_round_num := 0;

  -- setup g_out
  PO_PDOI_PARAMS.g_out.processed_lines_count := 0;
  PO_PDOI_PARAMS.g_out.rejected_lines_count := 0;
  PO_PDOI_PARAMS.g_out.err_tolerance_exceeded := FND_API.G_FALSE;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_startup_values;


-----------------------------------------------------------------------
--Start of Comments
--Name: init_sys_parameters
--Function:
--  Derive system paramters and populate the same to
--  PO_PDOI_PARAMS.g_sys record
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_sys_parameters IS

d_api_name CONSTANT VARCHAR2(30) := 'init_sys_parameters';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_enforce_buyer_name
    PO_SYSTEM_PARAMETERS.enforce_buyer_name_flag %TYPE;
l_enforce_buyer_auth_flag
    PO_SYSTEM_PARAMETERS.enforce_buyer_authority_flag%TYPE;
l_security_structure_id
    PO_SYSTEM_PARAMETERS.security_position_structure_id%TYPE;
l_rev_sort_ordering
    FINANCIALS_SYSTEM_PARAMETERS.revision_sort_ordering%TYPE;
l_notify_blanket_flag
    PO_SYSTEM_PARAMETERS.notify_if_blanket_flag%TYPE;
l_budgetary_control_flag
    GL_SETS_OF_BOOKS.enable_budgetary_control_flag%TYPE;
l_user_defined_req_num_code
    PO_SYSTEM_PARAMETERS.user_defined_req_num_code%TYPE;
l_rfq_required_flag
    PO_SYSTEM_PARAMETERS.rfq_required_flag%TYPE;
l_manual_req_num_type
    PO_SYSTEM_PARAMETERS.manual_req_num_type%TYPE;
l_enforce_full_lot_qty
    PO_SYSTEM_PARAMETERS.enforce_full_lot_quantities%TYPE;
l_disposition_warning_flag
    PO_SYSTEM_PARAMETERS.disposition_warning_flag%TYPE;
l_reserve_at_completion_flag
    FINANCIALS_SYSTEM_PARAMETERS.reserve_at_completion_flag%TYPE;
l_user_defined_rcpt_num_code
    PO_SYSTEM_PARAMETERS.user_defined_receipt_num_code%TYPE;
l_manual_rcpt_num_type
    PO_SYSTEM_PARAMETERS.manual_receipt_num_type%TYPE;
l_use_positions_flag
    FINANCIALS_SYSTEM_PARAMETERS.use_positions_flag%TYPE;
l_user_defined_rfq_num_code
    PO_SYSTEM_PARAMETERS.user_defined_rfq_num_code%TYPE;
l_manual_rfq_num_type
    PO_SYSTEM_PARAMETERS.manual_rfq_num_type%TYPE;


BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- po and financials system parameters
  PO_CORE_S.get_po_parameters
  ( x_currency_code           => PO_PDOI_PARAMS.g_sys.currency_code,
    x_coa_id                  => PO_PDOI_PARAMS.g_sys.coa_id,
    x_po_encumberance_flag    => PO_PDOI_PARAMS.g_sys.po_encumbrance_flag,
    x_req_encumberance_flag   => PO_PDOI_PARAMS.g_sys.req_encumbrance_flag,
    x_sob_id                  => PO_PDOI_PARAMS.g_sys.sob_id,
    x_ship_to_location_id     => PO_PDOI_PARAMS.g_sys.ship_to_location_id,
    x_bill_to_location_id     => PO_PDOI_PARAMS.g_sys.bill_to_location_id,
    x_fob_lookup_code         => PO_PDOI_PARAMS.g_sys.fob_lookup_code,
    x_freight_terms_lookup_code => PO_PDOI_PARAMS.g_sys.freight_terms_lookup_code,
    x_terms_id                => PO_PDOI_PARAMS.g_sys.terms_id,
    x_default_rate_type       => PO_PDOI_PARAMS.g_sys.default_rate_type,
    x_taxable_flag            => PO_PDOI_PARAMS.g_sys.taxable_flag,
    x_receiving_flag          => PO_PDOI_PARAMS.g_sys.receiving_flag,
    x_enforce_buyer_name_flag => l_enforce_buyer_name,
    x_enforce_buyer_auth_flag => l_enforce_buyer_auth_flag,
    x_line_type_id            => PO_PDOI_PARAMS.g_sys.line_type_id,
    x_manual_po_num_type      => PO_PDOI_PARAMS.g_sys.manual_po_num_type,
    x_po_num_code             => PO_PDOI_PARAMS.g_sys.user_defined_po_num_code,
    x_price_lookup_code       => PO_PDOI_PARAMS.g_sys.price_type_lookup_code,
    x_invoice_close_tolerance => PO_PDOI_PARAMS.g_sys.invoice_close_tolerance,
    x_receive_close_tolerance => PO_PDOI_PARAMS.g_sys.receive_close_tolerance,
    x_security_structure_id   => l_security_structure_id,
    x_expense_accrual_code    => PO_PDOI_PARAMS.g_sys.expense_accrual_code,
    x_inv_org_id              => PO_PDOI_PARAMS.g_sys.def_inv_org_id,
    x_rev_sort_ordering       => l_rev_sort_ordering,
    x_min_rel_amount          => PO_PDOI_PARAMS.g_sys.min_rel_amount,
    x_notify_blanket_flag     => l_notify_blanket_flag,
    x_budgetary_control_flag  => l_budgetary_control_flag,
    x_user_defined_req_num_code => l_user_defined_req_num_code,
    x_rfq_required_flag       => l_rfq_required_flag,
    x_manual_req_num_type     => l_manual_req_num_type,
    x_enforce_full_lot_qty    => l_enforce_full_lot_qty,
    x_disposition_warning_flag => l_disposition_warning_flag,
    x_reserve_at_completion_flag => l_reserve_at_completion_flag,
    x_user_defined_rcpt_num_code => l_user_defined_rcpt_num_code,
    x_manual_rcpt_num_type    => l_manual_rcpt_num_type,
    x_use_positions_flag       => l_use_positions_flag,
    x_default_quote_warning_delay  => PO_PDOI_PARAMS.g_sys.def_quote_warning_delay,
    x_inspection_required_flag    => PO_PDOI_PARAMS.g_sys.inspection_required_flag,
    x_user_defined_quote_num_code => PO_PDOI_PARAMS.g_sys.user_defined_quote_num_code,
    x_manual_quote_num_type   => PO_PDOI_PARAMS.g_sys.manual_quote_num_type,
    x_user_defined_rfq_num_code => l_user_defined_rfq_num_code,
    x_manual_rfq_num_type     => l_manual_rfq_num_type,
    x_ship_via_lookup_code    => PO_PDOI_PARAMS.g_sys.ship_via_lookup_code,
    x_qty_rcv_tolerance       => PO_PDOI_PARAMS.g_sys.qty_rcv_tolerance,
    x_acceptance_required_flag   => PO_PDOI_PARAMS.g_sys.acceptance_required_flag,           /* Bug 7518967 : Default Acceptance Required Check ER */
    x_group_shipments_flag     => PO_PDOI_PARAMS.g_sys.group_shipments_flag
  );

  d_position := 10;
  SELECT price_break_lookup_code,
         supplier_authoring_acceptance,
         cat_admin_authoring_acceptance
  INTO PO_PDOI_PARAMS.g_sys.price_break_lookup_code,
       PO_PDOI_PARAMS.g_sys.supplier_auth_acc,
       PO_PDOI_PARAMS.g_sys.cat_admin_auth_acc
  FROM po_system_parameters;

  d_position := 20;
  SELECT match_option,
         business_group_id
  INTO   PO_PDOI_PARAMS.g_sys.invoice_match_option,
         PO_PDOI_PARAMS.g_sys.def_business_group_id
  FROM   financials_system_parameters;

  d_position := 30;
  SELECT master_organization_id
  INTO PO_PDOI_PARAMS.g_sys.master_inv_org_id
  FROM mtl_parameters
  WHERE organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id;


-- PDOI Enhancement Bug#17063664
-- Removed the call for rcv paramters as the values
-- fetched here are not being utilized

-- Removed the call to get when to archive PO.
-- This is no longer used.
 --<PDOI Enhancement Bug#17063664 END>--


  d_position := 70;
  SELECT MCSB.structure_id,
         MCSB.category_set_id,
         MCSB.default_category_id
  INTO   PO_PDOI_PARAMS.g_sys.def_structure_id,
         PO_PDOI_PARAMS.g_sys.def_cat_set_id,
         PO_PDOI_PARAMS.g_sys.def_category_id
  FROM   MTL_DEFAULT_CATEGORY_SETS MDCS,
         MTL_CATEGORY_SETS_B MCSB
  WHERE  MDCS.functional_area_id = 2
  AND    MDCS.category_set_id = MCSB.category_set_id;

  d_position := 80;
  PO_PDOI_PARAMS.g_sys.is_federal_instance :=
    PO_CORE_S.check_federal_instance
    ( p_org_id => PO_PDOI_PARAMS.g_request.org_id
    );

  d_position := 90;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'currency_code', PO_PDOI_PARAMS.g_sys.currency_code);
    PO_LOG.stmt (d_module, d_position, 'coa_id', PO_PDOI_PARAMS.g_sys.coa_id);
    PO_LOG.stmt (d_module, d_position, 'po_encumbrance_flag', PO_PDOI_PARAMS.g_sys.po_encumbrance_flag);
    PO_LOG.stmt (d_module, d_position, 'req_encumbrance_flag', PO_PDOI_PARAMS.g_sys.req_encumbrance_flag);
    PO_LOG.stmt (d_module, d_position, 'sob_id', PO_PDOI_PARAMS.g_sys.sob_id);
    PO_LOG.stmt (d_module, d_position, 'ship_to_location_id', PO_PDOI_PARAMS.g_sys.ship_to_location_id);
    PO_LOG.stmt (d_module, d_position, 'bill_to_location_id', PO_PDOI_PARAMS.g_sys.bill_to_location_id);
    PO_LOG.stmt (d_module, d_position, 'fob_lookup_code', PO_PDOI_PARAMS.g_sys.fob_lookup_code);
    PO_LOG.stmt (d_module, d_position, 'freight_terms_lookup_code', PO_PDOI_PARAMS.g_sys.freight_terms_lookup_code);
    PO_LOG.stmt (d_module, d_position, 'terms_id', PO_PDOI_PARAMS.g_sys.terms_id);
    PO_LOG.stmt (d_module, d_position, 'default_rate_type', PO_PDOI_PARAMS.g_sys.default_rate_type);
    PO_LOG.stmt (d_module, d_position, 'taxable_flag', PO_PDOI_PARAMS.g_sys.taxable_flag);
    PO_LOG.stmt (d_module, d_position, 'receiving_flag', PO_PDOI_PARAMS.g_sys.receiving_flag);
    PO_LOG.stmt (d_module, d_position, 'line_type_id', PO_PDOI_PARAMS.g_sys.line_type_id);
    PO_LOG.stmt (d_module, d_position, 'manual_po_num_type', PO_PDOI_PARAMS.g_sys.manual_po_num_type);
    PO_LOG.stmt (d_module, d_position, 'user_defined_po_num_code', PO_PDOI_PARAMS.g_sys.user_defined_po_num_code);
    PO_LOG.stmt (d_module, d_position, 'price_type_lookup_code', PO_PDOI_PARAMS.g_sys.price_type_lookup_code);
    PO_LOG.stmt (d_module, d_position, 'def_inv_org_id', PO_PDOI_PARAMS.g_sys.def_inv_org_id);
    PO_LOG.stmt (d_module, d_position, 'min_rel_amount', PO_PDOI_PARAMS.g_sys.min_rel_amount);
    PO_LOG.stmt (d_module, d_position, 'def_quote_warning_delay', PO_PDOI_PARAMS.g_sys.def_quote_warning_delay);
    PO_LOG.stmt (d_module, d_position, 'inspection_required_flag', PO_PDOI_PARAMS.g_sys.inspection_required_flag);
    PO_LOG.stmt (d_module, d_position, 'user_defined_quote_num_code', PO_PDOI_PARAMS.g_sys.user_defined_quote_num_code);
    PO_LOG.stmt (d_module, d_position, 'manual_quote_num_type', PO_PDOI_PARAMS.g_sys.manual_quote_num_type);
    PO_LOG.stmt (d_module, d_position, 'ship_via_lookup_code', PO_PDOI_PARAMS.g_sys.ship_via_lookup_code);
    PO_LOG.stmt (d_module, d_position, 'qty_rcv_tolerance', PO_PDOI_PARAMS.g_sys.qty_rcv_tolerance);
    PO_LOG.stmt (d_module, d_position, 'price_break_lookup_code', PO_PDOI_PARAMS.g_sys.price_break_lookup_code);
    PO_LOG.stmt (d_module, d_position, 'invoice_close_tolerance', PO_PDOI_PARAMS.g_sys.invoice_close_tolerance);
    PO_LOG.stmt (d_module, d_position, 'receive_close_tolerance', PO_PDOI_PARAMS.g_sys.receive_close_tolerance);
    PO_LOG.stmt (d_module, d_position, 'expense_accrual_code', PO_PDOI_PARAMS.g_sys.expense_accrual_code);
    PO_LOG.stmt (d_module, d_position, 'master_inv_org_id', PO_PDOI_PARAMS.g_sys.master_inv_org_id);
    PO_LOG.stmt (d_module, d_position, 'supplier_auth_acc', PO_PDOI_PARAMS.g_sys.supplier_auth_acc);
    PO_LOG.stmt (d_module, d_position, 'cat_admin_auth_acc', PO_PDOI_PARAMS.g_sys.cat_admin_auth_acc);
    PO_LOG.stmt (d_module, d_position, 'invoice_match_option', PO_PDOI_PARAMS.g_sys.invoice_match_option);
    PO_LOG.stmt (d_module, d_position, 'def_business_group_id', PO_PDOI_PARAMS.g_sys.def_business_group_id);
    PO_LOG.stmt (d_module, d_position, 'def_structure_id', PO_PDOI_PARAMS.g_sys.def_structure_id);
    PO_LOG.stmt (d_module, d_position, 'def_cat_set_id', PO_PDOI_PARAMS.g_sys.def_cat_set_id);
    PO_LOG.stmt (d_module, d_position, 'def_category_id', PO_PDOI_PARAMS.g_sys.def_category_id);
    PO_LOG.stmt (d_module, d_position, 'is_federal_instance', PO_PDOI_PARAMS.g_sys.is_federal_instance);
    -- PDOI Enhancement bug#17063664
    PO_LOG.stmt (d_module, d_position, 'group_shipments_flag', PO_PDOI_PARAMS.g_sys.group_shipments_flag);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_sys_parameters;


-----------------------------------------------------------------------
--Start of Comments
--Name: init_profile_parameters
--Function:
--  Derive necessary profiles and populate the same to PO_PDOI_PARAMS.g_profile
--  record
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_profile_parameters IS

d_api_name CONSTANT VARCHAR2(30) := 'init_profile_parameters';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_PDOI_PARAMS.g_profile.pdoi_write_to_file :=
    NVL(FND_PROFILE.value('PO_PDOI_WRITE_TO_FILE'),'N');

  PO_PDOI_PARAMS.g_profile.service_uom_class :=
    NVL(FND_PROFILE.value('PO_RATE_UOM_CLASS'), '999');

  PO_PDOI_PARAMS.g_profile.override_funds :=
    FND_PROFILE.value('PO_REQAPPR_OVERRIDE_FUNDS');

  PO_PDOI_PARAMS.g_profile.xbg :=  NVL(HR_GENERAL.get_xbg_profile, 'N');

  PO_PDOI_PARAMS.g_profile.po_price_update_tolerance :=
    FND_PROFILE.value('PO_PRICE_UPDATE_TOLERANCE');

  -- bug 5015608
  -- get profile value from eTax. Default the value to 'Y' if NULL
  PO_PDOI_PARAMS.g_profile.allow_tax_rate_override :=
    NVL(FND_PROFILE.value('ZX_ALLOW_TAX_RECVRY_RATE_OVERRIDE'), 'Y');

  PO_PDOI_PARAMS.g_profile.allow_tax_code_override :=
    NVL(FND_PROFILE.value('ZX_ALLOW_TAX_CLASSIF_OVERRIDE'), 'Y');

  --<PDOI Enhancement Bug#17063664 START>--
  PO_PDOI_PARAMS.g_profile.group_by_need_by_date :=
    NVL(FND_PROFILE.VALUE('PO_NEED_BY_GROUPING'),'Y');

  PO_PDOI_PARAMS.g_profile.group_by_ship_to_location :=
    NVL(FND_PROFILE.VALUE('PO_SHIPTO_GROUPING'),'Y');

  PO_PDOI_PARAMS.g_profile.default_promised_date :=
    FND_PROFILE.VALUE('PO_NEED_BY_PROMISE_DEFAULTING');

  FND_PROFILE.GET('PO_AUTOCREATE_DATE',PO_PDOI_PARAMS.g_profile.auto_create_date_option);

  PO_PDOI_PARAMS.g_profile.use_req_num_in_autocreate :=
   FND_PROFILE.VALUE('PO_USE_REQ_NUM_IN_AUTOCREATE');

  BEGIN
    SELECT  organization_id
    INTO    PO_PDOI_PARAMS.g_profile.pa_default_exp_org_id
    FROM    hr_all_organization_units_tl
    WHERE   name = fnd_profile.value('PA_DEFAULT_EXP_ORG')
    AND     language = USERENV('LANG');

    EXCEPTION
    WHEN OTHERS THEN
      PO_PDOI_PARAMS.g_profile.pa_default_exp_org_id := NULL;
  END;

  --<PDOI Enhancement Bug#17063664 END>--

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'pdoi_write_to_file', PO_PDOI_PARAMS.g_profile.pdoi_write_to_file);
    PO_LOG.stmt (d_module, d_position, 'service_uom_class', PO_PDOI_PARAMS.g_profile.service_uom_class);
    PO_LOG.stmt (d_module, d_position, 'override_funds', PO_PDOI_PARAMS.g_profile.override_funds);
    PO_LOG.stmt (d_module, d_position, 'xbg', PO_PDOI_PARAMS.g_profile.xbg);
    PO_LOG.stmt (d_module, d_position, 'po_price_update_tolerance', PO_PDOI_PARAMS.g_profile.po_price_update_tolerance);
    PO_LOG.stmt (d_module, d_position, 'allow_tax_rate_override', PO_PDOI_PARAMS.g_profile.allow_tax_rate_override);
  --<PDOI Enhancement Bug#17063664 START>--
    PO_LOG.stmt (d_module, d_position, 'group_by_need_by_date', PO_PDOI_PARAMS.g_profile.group_by_need_by_date);
    PO_LOG.stmt (d_module, d_position, 'group_by_ship_to_location', PO_PDOI_PARAMS.g_profile.group_by_ship_to_location);
    PO_LOG.stmt (d_module, d_position, 'default_promised_date', PO_PDOI_PARAMS.g_profile.default_promised_date);
    PO_LOG.stmt (d_module, d_position, 'auto_create_date_option', PO_PDOI_PARAMS.g_profile.auto_create_date_option);
    PO_LOG.stmt (d_module, d_position, 'use_req_num_in_autocreate', PO_PDOI_PARAMS.g_profile.use_req_num_in_autocreate);
   --<PDOI Enhancement Bug#17063664 END>--
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_profile_parameters;

-----------------------------------------------------------------------
--Start of Comments
--Name: init_product_parameters
--Function:
--  Derive necessary product installation status and populate the same
--  to PO_PDOI_PARAMS.g_product record
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_product_parameters IS

d_api_name CONSTANT VARCHAR2(30) := 'init_product_parameters';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (PO_CORE_S.get_product_install_status('WIP') = 'I') THEN
    PO_PDOI_PARAMS.g_product.wip_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.wip_installed := FND_API.G_FALSE;
  END IF;

  IF (PO_CORE_S.get_product_install_status('INV') = 'I') THEN
    PO_PDOI_PARAMS.g_product.inv_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.inv_installed := FND_API.G_FALSE;
  END IF;

  IF (PA_PO_INTEGRATION.is_pjc_11i10_enabled <> 'N') THEN
    PO_PDOI_PARAMS.g_product.project_11510_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.project_11510_installed := FND_API.G_FALSE;
  END IF;

  IF (PO_CORE_S.get_product_install_status('PA') = 'I') THEN
    PO_PDOI_PARAMS.g_product.pa_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.pa_installed := FND_API.G_FALSE;
  END IF;

  --<PDOI Enhancement Bug#17063664 Start>
  IF (PO_CORE_S.get_product_install_status('PJM') = 'I') THEN
    PO_PDOI_PARAMS.g_product.pjm_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.pjm_installed := FND_API.G_FALSE;
  END IF;
  --<PDOI Enhancement Bug#17063664 End>

  IF (GMS_PO_API_GRP.gms_enabled) THEN
    PO_PDOI_PARAMS.g_product.gms_enabled := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.gms_enabled := FND_API.G_FALSE;
  END IF;

  IF (PA_PO_INTEGRATION.is_pjc_po_cwk_intg_enab <> 'N') THEN
    PO_PDOI_PARAMS.g_product.project_cwk_installed := FND_API.G_TRUE;
  ELSE
    PO_PDOI_PARAMS.g_product.project_cwk_installed := FND_API.G_FALSE;
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'wip_installed', PO_PDOI_PARAMS.g_product.wip_installed);
    PO_LOG.stmt (d_module, d_position, 'inv_installed', PO_PDOI_PARAMS.g_product.inv_installed);
    PO_LOG.stmt (d_module, d_position, 'project_11510_installed', PO_PDOI_PARAMS.g_product.project_11510_installed);
    PO_LOG.stmt (d_module, d_position, 'pa_installed', PO_PDOI_PARAMS.g_product.pa_installed);
    --<PDOI Enhancement Bug#17063664>
    PO_LOG.stmt (d_module, d_position, 'pjm_installed', PO_PDOI_PARAMS.g_product.pjm_installed);
    PO_LOG.stmt (d_module, d_position, 'gms_enabled', PO_PDOI_PARAMS.g_product.gms_enabled);
    PO_LOG.stmt (d_module, d_position, 'project_cwk_installed', PO_PDOI_PARAMS.g_product.project_cwk_installed);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_product_parameters;

-- PDOI Enhancement Bug#17063664
-- Initially we had when to archive blanket, standard
-- Removing this as it is no longer required.


-----------------------------------------------------------------------
--Start of Comments
--Name: gather_interface_table_stat
--Function:
--  Gather table statistics for interface tables. This is typically used
--  when a large number of records need to be processed and the table
--  stats of interface tables may be significantly changed from the last
--  time the stats were gathered
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE gather_interface_table_stat IS

d_api_name CONSTANT VARCHAR2(30) := 'gather_interface_table_stat';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_schema VARCHAR2(30);

l_return_status BOOLEAN;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_TIMING_UTL.start_time (PO_PDOI_CONSTANTS.g_T_GATHER_TBL_STAT);

  -- Get the schema name of the table
  l_return_status := FND_INSTALLATION.get_app_info
                     ( 'PO',
                       l_status,
                       l_industry,
                       l_schema
                     );

  IF (l_return_status) THEN
    d_position := 10;

    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_HEADERS_INTERFACE'
    );

    d_position := 20;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_LINES_INTERFACE'
    );

    d_position := 30;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_LINE_LOCATIONS_INTERFACE'
    );

    d_position := 40;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_DISTRIBUTIONS_INTERFACE'
    );

    d_position := 50;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_PRICE_DIFF_INTERFACE'
    );

    d_position := 60;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_ATTR_VALUES_INTERFACE'
    );

    d_position := 70;
    FND_STATS.gather_table_stats
    ( ownname => l_schema,
      tabname => 'PO_ATTR_VALUES_TLP_INTERFACE'
    );
  ELSE
    d_position := 80;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Cannot get appl info. ' ||
                  'No stat gathering');
    END IF;
  END IF;

  PO_TIMING_UTL.stop_time (PO_PDOI_CONSTANTS.g_T_GATHER_TBL_STAT);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END gather_interface_table_stat;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_draft_errors
--Function:
--  Mark the drafts that are created in current round as PDOI ERROR.
--  no other program can update the document anymore until the PDOI ERROR is
--  resolved by running PDOI again.
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_draft_errors IS

d_api_name CONSTANT VARCHAR2(30) := 'set_draft_errors';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  --SQL What: Mark the drafts that are processed by the current round as
  --          PDOI ERROR
  --SQL Why:  Since the draft may have incomplete data, we want to prevent
  --          others from updating the document until the drafts are removed.
  --          The way to remove it is by running PDOI against the same document
  --          again.
  UPDATE po_drafts DFT
  SET    DFT.status = PO_DRAFTS_PVT.g_status_PDOI_ERROR
  WHERE  DFT.status = PO_DRAFTS_PVT.g_status_PDOI_PROCESSING
  AND    DFT.draft_id IN
           (SELECT PHI.draft_id
            FROM   po_headers_interface PHI
            WHERE  PHI.processing_id IN (PO_PDOI_PARAMS.g_processing_id,
                                         -PO_PDOI_PARAMS.g_processing_id)
            AND    PHI.processing_round_num=PO_PDOI_PARAMS.g_current_round_num);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END set_draft_errors;

-----------------------------------------------------------------------
--Start of Comments
--Name: wrap_up
--Function:
--  Perform actions to be done right before PDOI quits
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE wrap_up IS

d_api_name CONSTANT VARCHAR2(30) := 'wrap_up';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_timing_info_tbl PO_TBL_VARCHAR4000;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- flush all remaining errors to interface errors table
  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  d_position := 20;

  PO_TIMING_UTL.get_formatted_timing_info
  ( p_cleanup => FND_API.G_TRUE,
    x_timing_info => l_timing_info_tbl
  );

  d_position := 30;

  -- Force Logging
  FOR i IN 1..l_timing_info_tbl.COUNT LOOP
    IF (10 >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string (10, d_module, 'Timing Stat: ' || l_timing_info_tbl(i));
    END IF;
  END LOOP;

--  FOR i IN 1..l_timing_info_tbl.COUNT LOOP
--    PO_LOG.stmt (d_module, d_position, 'Timing Stat: ', l_timing_info_tbl(i));
--  END LOOP;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END wrap_up;

END PO_PDOI_PVT;

/
