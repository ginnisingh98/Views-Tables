--------------------------------------------------------
--  DDL for Package Body PO_PDOI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_GRP" AS
/* $Header: PO_PDOI_GRP.plb 120.6.12010000.4 2014/03/11 03:47:01 sbontala ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_GRP');

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: start_process
--Function:
--  Group procedure for PDOI, which is used for importing and updating
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
--p_group_lines
-- Indicate whether lines have to be grouped or not
--p_group_shipments
-- Indicate whether lines have to be grouped or not
--IN OUT:
--OUT:
--x_return_status
--  Return status of the API.
--  FND_API.G_RET_STS_SUCCESS if API is successful
--  FND_API.G_RET_STS_ERR if there are user errors
--  FND_API.G_RET_STS_UNEXP_ERR if unexpected error (exception) occurs
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
  --<<PDOI Enhancement Bug#17063664 Start>>
  p_group_lines IN VARCHAR2  DEFAULT 'N',
  p_group_shipments IN VARCHAR2 DEFAULT 'N'
  --<<PDOI Enhancement Bug#17063664 End>>
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'start_process';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_processed_lines_count NUMBER;
l_rejected_lines_count NUMBER;
l_err_tolerance_exceeded VARCHAR2(1);

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (NOT FND_API.Compatible_API_Call
        ( p_current_version_number => d_api_version,
          p_caller_version_number  => p_api_version,
          p_api_name               => d_api_name,
          p_pkg_name               => d_pkg_name
        )
     ) THEN

    d_position := 10;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;  -- not compatible_api

  d_position := 20;

  PO_PDOI_PVT.start_process
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_validation_level => p_validation_level,
    p_commit => p_commit,
    x_return_status => x_return_status,
    p_gather_intf_tbl_stat => p_gather_intf_tbl_stat,
    p_calling_module => p_calling_module,
    p_selected_batch_id => p_selected_batch_id,
    p_batch_size => p_batch_size,
    p_buyer_id => p_buyer_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_create_items => p_create_items,
    p_create_sourcing_rules_flag => p_create_sourcing_rules_flag,
    p_rel_gen_method => p_rel_gen_method,
    p_sourcing_level => p_sourcing_level,
    p_sourcing_inv_org_id => p_sourcing_inv_org_id,
    p_approved_status => p_approved_status,
    p_process_code => p_process_code,
    p_interface_header_id => p_interface_header_id,
    p_org_id => p_org_id,
    p_ga_flag => p_ga_flag,
    p_submit_dft_flag => NULL,
    p_role => PO_GLOBAL.g_ROLE_BUYER,
    p_catalog_to_expire => NULL,
    p_err_lines_tolerance => NULL,
    --<<PDOI Enhancement Bug#17063664 Start>>
    p_group_lines  => p_group_lines,
    p_group_shipments => p_group_shipments,
    --<<PDOI Enhancement Bug#17063664 End>>
    x_processed_lines_count => l_processed_lines_count,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

  d_position := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END start_process;

-- <<PDOI Enhancement Bug#17063664 Start>>
--<<Bug#18265579 : Added default values
--for all the parameters to proceed
--successfully when concurrent program
--launched from backend.
-----------------------------------------------------------------------
--Start of Comments
--Name: start_process
--Function:
--  Group procedure for PDOI, which is used for importing and updating
--  blankets, quotations or standard purchase orders
--Parameters:
--IN:
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
--p_approved_status
--  Intended approval status the document after import. Possible values
--  INCOMPLETE - Incomplete documents
--  INITIATE APPROVAL - This means that the document will be submitted for
--                      approval through approval workflow
--  APPROVED - Import as approved without submitting through approval wf
--p_rel_gen_method
--  Release generation method of the ASL
--p_selected_batch_id
--  Batch id parameter. If this is specified, only the records with this batch
--  id will be processed.
--p_org_id
--  Operating Unit where this PDOI will be running in. If this is not specified,
--  Current operating unit will be the operating unit for PDOI to run.
--p_ga_flag
--  Whether the blanket will be imported as global agreement or not.
--  'Y' if blanekets should be imported as global agreements
--p_enable_sourcing_level
--  Whether the Sourcing level will be enabled or not.
--  'Y' if sourcing level should be enabled
--  'N' otherwise
--p_sourcing_level
--  Level of the sourcing rules assignment. Possible values:
--  ITEM, ITEM-ORGANIZATION
--p_inv_org_enable
--  Whether the inventory org will be enabled or not.
--  'Y' if inventory org should be enabled
--  'N' otherwise
--p_sourcing_inv_org_id
--  If sourcing level is 'ITEM-ORGANIZATION', the organization where the
--  sourcing rule will be created in
--p_group_lines
-- Indicate whether lines have to be grouped or not
--p_batch_size
--  Used for performance tuning. It specifies the number of header interface
--  records that will be processed for each bulk fetching. Default number is
--  PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE
--p_gather_stats
--  Whether PDOI gather table statistics before processing.
--  'Y' if statistics should be gathered. Consider this if a large
--      number of records are being inserted into the interface table
--  'N' otherwise
--IN OUT:
--OUT:
--x_errbuf
-- Message when existing a PL/SQL concurrent request
--x_retcode
-- Exit Status for the concurrent request
--End of Comments
------------------------------------------------------------------------
PROCEDURE start_process
(x_errbuf OUT NOCOPY  VARCHAR2,
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
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'start_process';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_return_status VARCHAR2(1);

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  IF p_batch_size IS NOT NULL THEN
  	PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE := p_batch_size;
  ELSE
  	PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE := 5000;
  END IF;

  IF p_gather_stats IS NOT NULL THEN
  	PO_PDOI_CONSTANTS.g_GATHER_STATS := p_gather_stats;
  ELSE
  	PO_PDOI_CONSTANTS.g_GATHER_STATS := 'N';
  END IF;

  d_position := 20;

  start_process
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    p_commit => FND_API.G_TRUE,
    x_return_status => l_return_status,
    p_gather_intf_tbl_stat => FND_API.G_FALSE,
    p_calling_module => PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM,
    p_selected_batch_id => p_selected_batch_id,
    p_batch_size => PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE,
    p_buyer_id => TO_NUMBER(p_buyer_id),
    p_document_type => UPPER(p_document_type),
    p_document_subtype => UPPER(p_document_subtype),
    p_create_items => UPPER(p_create_items),
    p_create_sourcing_rules_flag => UPPER(p_create_sourcing_rules_flag),
    p_rel_gen_method => UPPER(p_rel_gen_method),
    p_sourcing_level => p_sourcing_level,
    p_sourcing_inv_org_id => p_sourcing_inv_org_id,
    p_approved_status => UPPER(p_approved_status),
    p_process_code => PO_PDOI_CONSTANTS.g_process_code_PENDING,
    p_interface_header_id => NULL,
    p_org_id => p_org_id,
    p_ga_flag => p_ga_flag,
    p_group_lines  => UPPER(p_group_lines)
  );

  d_position := 20;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 30;

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
END start_process;

-- <<PDOI Enhancement Bug#17063664 End>>

-----------------------------------------------------------------------
--Start of Comments
--Name: catalog_upload
--Function:
--  This API will be called by iP during catalog upload process. This API
--  internally calls PDOI to perform import action.
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
--IN OUT:
--OUT:
--x_return_status
--  Return status of the API.
--  FND_API.G_RET_STS_SUCCESS if API is successful
--  FND_API.G_RET_STS_ERR if there are user errors
--  FND_API.G_RET_STS_UNEXP_ERR if unexpected error (exception) occurs
--x_error_message
--  Concatenation of error in case an error exists
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
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'catalog_upload';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_msg_temp VARCHAR2(2000);

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (NOT FND_API.Compatible_API_Call
        ( p_current_version_number => d_api_version,
          p_caller_version_number  => p_api_version,
          p_api_name               => d_api_name,
          p_pkg_name               => d_pkg_name
        )
     ) THEN

    d_position := 10;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;  -- not compatible_api

  d_position := 20;

  PO_PDOI_PVT.start_process
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_validation_level => p_validation_level,
    p_commit => p_commit,
    x_return_status => x_return_status,
    p_gather_intf_tbl_stat => p_gather_intf_tbl_stat,
    p_calling_module => PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD,
    p_selected_batch_id => p_selected_batch_id,
    p_batch_size => p_batch_size,
    p_buyer_id => p_buyer_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_create_items => p_create_items,
    p_create_sourcing_rules_flag => p_create_sourcing_rules_flag,
    p_rel_gen_method => p_rel_gen_method,
    p_sourcing_level => p_sourcing_level,
    p_sourcing_inv_org_id => p_sourcing_inv_org_id,
    p_approved_status => p_approved_status,
    p_process_code => p_process_code,
    p_interface_header_id => p_interface_header_id,
    p_org_id => p_org_id,
    p_ga_flag => p_ga_flag,
    p_submit_dft_flag => p_submit_dft_flag,
    p_role => p_role,
    p_catalog_to_expire => p_catalog_to_expire,
    p_err_lines_tolerance => p_err_lines_tolerance,
    --<<PDOI Enhancement Bug#17063664 Start>>
    p_group_lines  => NULL,
    p_group_shipments => NULL,
    --<<PDOI Enhancement Bug#17063664 End>>
    x_processed_lines_count => x_processed_lines_count,
    x_rejected_lines_count => x_rejected_lines_count,
    x_err_tolerance_exceeded => x_err_tolerance_exceeded
  );

  -- For Catalog Upload, we need to return error messaeg in case
  -- an error occurs.
  IF (x_return_status <> 'S') THEN
    FOR i IN 1..FND_MSG_PUB.count_msg LOOP
      l_msg_temp := FND_MSG_PUB.get
                    ( p_msg_index => i,
                      p_encoded => 'F'
                    );

      x_error_message := SUBSTRB(x_error_message || l_msg_temp || '   ',
                                 2000);
    END LOOP;
  END IF;


  d_position := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_processed_liens_count', x_processed_lines_count);
    PO_LOG.proc_end(d_module, 'x_rejected_lines_count', x_rejected_lines_count);
    PO_LOG.proc_end(d_module, 'x_err_tolerance_exceeded', x_err_tolerance_exceeded);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END catalog_upload;


-----------------------------------------------------------------------
--Start of Comments
--Name: handle_price_tolerance_resp
--Function:
--  This API handles response from buyer about lines that exceed
--  price tolerance
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
--p_selected_batch_id
--  Batch id parameter. If this is specified, only the records with this batch
--  id will be processed.
--p_document_type
--  Type of the document that will be processed. Possible values are:
--  STANDARD, BLANKET, QUOTATION
--p_document_subtype
--  Default document subtype. Use it only if  p_document_type is 'QUOTATION'.
--p_interface_header_id
--  If this is specified, only record with this interface_header_id will be
--  processed
--p_org_id
--  Operating Unit where this PDOI will be running in. If this is not specified,
--  Current operating unit will be the operating unit for PDOI to run.
--IN OUT:
--OUT:
--x_return_status
--  Return status of the API.
--  FND_API.G_RET_STS_SUCCESS if API is successful
--  FND_API.G_RET_STS_ERR if there are user errors
--  FND_API.G_RET_STS_UNEXP_ERR if unexpected error (exception) occurs
--End of Comments
------------------------------------------------------------------------
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
) IS

d_api_version CONSTANT NUMBER := 1.0;
d_api_name CONSTANT VARCHAR2(30) := 'handle_price_tolerance_resp';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_processed_lines_count NUMBER;
l_rejected_lines_count NUMBER;
l_err_tolerance_exceeded VARCHAR2(1);

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  IF (p_init_msg_list = FND_API.G_TRUE) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (NOT FND_API.Compatible_API_Call
        ( p_current_version_number => d_api_version,
          p_caller_version_number  => p_api_version,
          p_api_name               => d_api_name,
          p_pkg_name               => d_pkg_name
        )
     ) THEN

    d_position := 10;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;  -- not compatible_api

  d_position := 20;

  PO_PDOI_PVT.start_process
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_validation_level => p_validation_level,
    p_commit => p_commit,
    x_return_status => x_return_status,
    p_gather_intf_tbl_stat => 'N',
    p_calling_module => PO_PDOI_CONSTANTS.g_call_mod_PRICE_TOL_RESP,
    p_selected_batch_id => p_selected_batch_id,
    p_batch_size => 1,
    p_buyer_id => NULL,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_create_items => 'N',
    p_create_sourcing_rules_flag => 'N',
    p_rel_gen_method => NULL,
    p_sourcing_level => NULL,
    p_sourcing_inv_org_id => NULL,
    p_approved_status => NULL,
    p_process_code => PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED,
    p_interface_header_id => p_interface_header_id,
    p_org_id => p_org_id,
    p_ga_flag => NULL,
    p_submit_dft_flag => NULL,
    p_role => PO_GLOBAL.g_ROLE_BUYER,
    p_catalog_to_expire => NULL,
    p_err_lines_tolerance => NULL,
    x_processed_lines_count => l_processed_lines_count,
    x_rejected_lines_count => l_rejected_lines_count,
    x_err_tolerance_exceeded => l_err_tolerance_exceeded
  );

  d_position := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END handle_price_tolerance_resp;


END PO_PDOI_GRP;

/
