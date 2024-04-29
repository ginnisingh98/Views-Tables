--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_PVT" AS
/* $Header: PO_R12_CAT_UPG_PVT.plb 120.16.12010000.3 2009/07/27 15:01:50 rojain ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_PVT';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;
g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

-- Value of IP_CATEGORY_ID column if no category mappings exist
g_NULL_IP_CATEGORY_ID CONSTANT NUMBER := -2;

PROCEDURE initialize_system_values
(
   p_batch_id           IN NUMBER
,  p_batch_size         IN NUMBER default 2500
,  p_commit             IN VARCHAR2 default FND_API.G_FALSE
,  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE pre_process
(
  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE migrate_document_headers
(
  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE migrate_document_lines
(
  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
);

PROCEDURE transfer_doc_headers
(
  x_doc_headers_rec  IN OUT NOCOPY record_of_headers_type
);

PROCEDURE insert_doc_headers
(
  x_doc_headers_rec IN OUT NOCOPY record_of_headers_type
);

PROCEDURE update_doc_headers
(
  p_doc_headers_rec IN record_of_headers_type
);

PROCEDURE delete_doc_headers
(
  p_doc_headers_rec IN record_of_headers_type
);

PROCEDURE transfer_doc_lines
(
  p_doc_lines_rec    IN record_of_lines_type
);

PROCEDURE insert_doc_lines
(
  p_doc_lines_rec IN record_of_lines_type
);

PROCEDURE update_doc_lines
(
  p_doc_lines_rec    IN record_of_lines_type
);

PROCEDURE delete_doc_lines
(
  p_doc_lines_rec IN record_of_lines_type
);

PROCEDURE transfer_attributes
(
  p_attrib_values_tbl    IN record_of_attr_values_type
);

PROCEDURE insert_attributes
(
  p_attr_values_tbl IN record_of_attr_values_type
);

PROCEDURE update_attributes
(
  p_attr_values_tbl    IN record_of_attr_values_type
);

PROCEDURE delete_attributes
(
  p_attr_values_tbl IN record_of_attr_values_type
);

PROCEDURE transfer_attributes_tlp
(
  p_attrib_tlp_values_tbl    IN record_of_attr_values_tlp_type
);

PROCEDURE insert_attributes_tlp
(
  p_attr_values_tlp_tbl IN record_of_attr_values_tlp_type
);

PROCEDURE update_attributes_tlp
(
  p_attr_values_tlp_tbl    IN record_of_attr_values_tlp_type
);

PROCEDURE delete_attributes_tlp
(
  p_attr_values_tlp_tbl IN record_of_attr_values_tlp_type
);

PROCEDURE update_req_template_batch
(
  p_rt_lines_rec    IN record_of_rt_lines_type
);

--Bug 4865553: Start>
--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_ip_tables_hdr
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
-- If all lines for a header have errors, then delete the header.
-- Clean up the header from the txn table.
  -- This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_ip_tables_hdr
(
  p_doc_headers_table RECORD_OF_HEADERS_TYPE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_ip_tables_hdr';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_return_status VARCHAR2(100);
  l_intf_hdr_id_list  DBMS_SQL.NUMBER_TABLE;
  l_count NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN
    IF (p_doc_headers_table.interface_header_id IS NOT NULL) THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_table.COUNT='||p_doc_headers_table.interface_header_id.COUNT);
    ELSE
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_table.interface_header_id IS NULL');
    END IF;
  END IF;

  IF ( (p_doc_headers_table.interface_header_id IS NOT NULL) AND
       (p_doc_headers_table.interface_header_id.COUNT > 0) ) THEN

    -- Filter out the error records
    l_count := 0;
    FOR i IN 1..p_doc_headers_table.interface_header_id.COUNT
    LOOP
      IF (p_doc_headers_table.has_errors(i) <> 'Y') THEN
        l_count := l_count + 1;
        l_intf_hdr_id_list(l_count) := p_doc_headers_table.interface_header_id(i);
      END IF;
    END LOOP;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of non-errored headers being sent to IP='||l_count); END IF;

    IF (l_intf_hdr_id_list.COUNT > 0) THEN
      ICX_CAT_R12_UPGRADE_GRP.updatePOHeaderId
      (
        p_api_version         => 1.0                        -- NUMBER IN
      , p_commit              => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
      , p_init_msg_list       => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
      , p_validation_level    => FND_API.G_VALID_LEVEL_FULL -- VARCHAR2 IN DEFAULT
      , x_return_status       => l_return_status            -- VARCHAR2 OUT
      , p_interface_header_id => l_intf_hdr_id_list         -- TABLE OF NUMBER IN DBMS_SQL.NUMBER_TABLE
      );
    END IF;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_ip_tables_hdr;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_ip_tables_line
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
-- If all lines for a header have errors, then delete the header.
-- Clean up the header from the txn table.
  -- This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_ip_tables_line
(
  p_doc_lines_table RECORD_OF_LINES_TYPE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_ip_tables_line';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_return_status VARCHAR2(100);
  l_intf_line_id_list DBMS_SQL.NUMBER_TABLE;
  l_count NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN
    IF (p_doc_lines_table.interface_line_id IS NOT NULL) THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_table.COUNT='||p_doc_lines_table.interface_line_id.COUNT);
    ELSE
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_table.interface_line_id IS NULL');
    END IF;
  END IF;

  IF ( (p_doc_lines_table.interface_line_id IS NOT NULL) AND
       (p_doc_lines_table.interface_line_id.COUNT > 0) ) THEN

    -- Filter out the error records
    l_count := 0;
    FOR i IN 1..p_doc_lines_table.interface_line_id.COUNT
    LOOP
      IF (p_doc_lines_table.has_errors(i) <> 'Y') THEN
        l_count := l_count + 1;
        l_intf_line_id_list(l_count) := p_doc_lines_table.interface_line_id(i);
      END IF;
    END LOOP;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of non-errored lines being sent to IP='||l_count); END IF;

    IF (l_intf_line_id_list.COUNT > 0) THEN
      ICX_CAT_R12_UPGRADE_GRP.updatePOLineId
      (
        p_api_version         => 1.0                        -- NUMBER IN
      , p_commit              => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
      , p_init_msg_list       => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
      , p_validation_level    => FND_API.G_VALID_LEVEL_FULL -- VARCHAR2 IN DEFAULT
      , x_return_status       => l_return_status            -- VARCHAR2 OUT
      , p_interface_line_id   => l_intf_line_id_list        -- TABLE OF NUMBER IN DBMS_SQL.NUMBER_TABLE
      );
    END IF;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_ip_tables_line;
--Bug 4865553: End>

--------------------------------------------------------------------------------
--Start of Comments
  --Name: cleanup_err_docs
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
-- If all lines for a header have errors, then delete the header.
-- Clean up the header from the txn table.
  -- This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE cleanup_err_docs
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'cleanup_err_docs';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to load headers whose lines have all failed
  -- SQL Why : To perform cleanup.
  -- SQL Join: processing_id, process_code, po_header_id
  CURSOR load_err_headers_csr(request_processing_id NUMBER) IS
    SELECT intf_headers.interface_header_id,
           intf_headers.po_header_id
    FROM   PO_HEADERS_INTERFACE intf_headers,
           PO_HEADERS_ALL POH
    WHERE  intf_headers.processing_id = request_processing_id
    AND    intf_headers.process_code <> g_PROCESS_CODE_REJECTED
    AND    POH.po_header_id = intf_headers.po_header_id
    AND    NOT EXISTS
            (SELECT 'At least one line in Txn tables'
             FROM po_lines_all POL
             WHERE  POL.po_header_id = POH.po_header_id);

--  -- SQL What: Orphan PO Lines: Cursor to load PO lines for which the header
--  --           does not exist.
--  -- SQL Why : To perform cleanup.
--  -- SQL Join: processing_id, process_code, po_header_id
--  CURSOR load_orphan_lines_csr IS
--    SELECT POL.po_line_id
--    FROM   PO_LINES_ALL POL
--    WHERE  POL.created_by = g_R12_UPGRADE_USER
--    AND    NOT EXISTS
--            (SELECT 'Corresponding PO Header exists'
--             FROM PO_HEADERS_ALL POH
--             WHERE  POH.po_header_id = POL.po_header_id);
--
--  -- SQL What: Orphan PO Attr: Cursor to load PO Attr for which the Line
--  --           does not exist.
--  -- SQL Why : To perform cleanup.
--  -- SQL Join: processing_id, process_code, po_header_id
--  CURSOR load_orphan_attr_csr IS
--    SELECT POATTR.attribute_values_id
--    FROM   PO_ATTRIBUTE_VALUES POATTR
--    WHERE  POATTR.created_by = g_R12_UPGRADE_USER
--    AND    NOT EXISTS
--            (SELECT 'Corresponding PO Line exists'
--             FROM PO_LINES_ALL POL
--             WHERE  POL.po_line_id = POATTR.po_line_id);
--
--  -- SQL What: Orphan PO Attr TLP: Cursor to load PO Attr TLP for which the
--  --            Line does not exist.
--  -- SQL Why : To perform cleanup.
--  -- SQL Join: processing_id, process_code, po_header_id
--  CURSOR load_orphan_tlp_csr IS
--    SELECT POTLP.attribute_values_tlp_id
--    FROM   PO_ATTRIBUTE_VALUES_TLP POTLP
--    WHERE  POTLP.created_by = g_R12_UPGRADE_USER
--    AND    NOT EXISTS
--            (SELECT 'Corresponding PO Line exists'
--             FROM PO_LINES_ALL POL
--             WHERE  POL.po_line_id = POTLP.po_line_id);

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_po_header_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_return_status VARCHAR2(100);
  l_intf_hdr_id_list DBMS_SQL.NUMBER_TABLE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'g_processing_id='||g_processing_id); END IF;

  IF ( (g_processing_id IS NULL) OR
       (g_processing_id <= 0)) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'g_processing_id is invalid. Early return...'); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
    RETURN;
  END IF;

  OPEN load_err_headers_csr(g_processing_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';

      FETCH load_err_headers_csr
      BULK COLLECT INTO l_interface_header_ids, l_err_po_header_ids
      LIMIT g_job.batch_size;

      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_interface_header_ids.COUNT='||l_interface_header_ids.COUNT); END IF;

      EXIT WHEN l_interface_header_ids.COUNT = 0;

      l_progress := '040';
      -- Record error message in interface errors table
      -- Insert record in interface_errors_table
      FOR i IN 1.. l_interface_header_ids.COUNT
      LOOP
        -- Note: Exceptions pages should not show this message (Action for IP IDC).
        PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_CAT_UPG_ALL_LINES_FAILED',
            p_error_message_name  => 'ICX_CAT_UPG_ALL_LINES_FAILED',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'PO_HEADER_ID',
            p_column_value        => l_err_po_header_ids(i)
            );
      END LOOP;

      l_progress := '050';
      -- SQL What: Update process_code and processing_id in interface_table
      -- SQL Why : To mark them as error rows
      -- SQL Join: interface_header_id
      FORALL i IN 1.. l_interface_header_ids.COUNT
        UPDATE po_headers_interface headers
        SET    process_code = g_PROCESS_CODE_REJECTED,
               processing_id = -processing_id,
               po_header_id = NULL -- Bug 4865553: Null out the PO_HEADER_ID before calling IP's API
        WHERE  interface_header_id = l_interface_header_ids(i);

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of records marked as error in headers interface='||SQL%rowcount); END IF;

      l_progress := '060';
      -- SQL What: Delete header from txn tables
      -- SQL Why : To cleanup corrupt data
      -- SQL Join: po_header_id
      FORALL i IN 1.. l_err_po_header_ids.COUNT
        DELETE FROM PO_HEADERS_ALL
        WHERE po_header_id = l_err_po_header_ids(i);

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of records deleted from txn Headers='||SQL%rowcount); END IF;

      l_progress := '070';
      COMMIT;

      --<Bug 4865553: Start>
      IF (l_interface_header_ids.COUNT > 0) THEN
        -- Copy the list into the DBMS_SQL.NUMBER_TABLE type required by IP
        FOR i IN 1.. l_interface_header_ids.COUNT LOOP
          l_intf_hdr_id_list(i) := l_interface_header_ids(i);
        END LOOP;

        ICX_CAT_R12_UPGRADE_GRP.updatePOHeaderId
        (
          p_api_version         => 1.0                        -- NUMBER IN
        , p_commit              => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
        , p_init_msg_list       => FND_API.G_TRUE             -- VARCHAR2 IN DEFAULT
        , p_validation_level    => FND_API.G_VALID_LEVEL_FULL -- VARCHAR2 IN DEFAULT
        , x_return_status       => l_return_status            -- VARCHAR2 OUT
        , p_interface_header_id => l_intf_hdr_id_list         -- TABLE OF NUMBER IN DBMS_SQL.NUMBER_TABLE
        );
      END IF;
      --<Bug 4865553: End>

      IF (l_interface_header_ids.COUNT < g_job.batch_size) THEN
        EXIT;
      END IF;
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_err_headers_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '080';
        COMMIT;

        l_progress := '090';
        CLOSE load_err_headers_csr;

        l_progress := '100';
        OPEN load_err_headers_csr(g_processing_id);
        l_progress := '110';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP; -- batch loop

  l_progress := '120';

  IF (load_err_headers_csr%ISOPEN) THEN
    CLOSE load_err_headers_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_err_headers_csr%ISOPEN) THEN
      CLOSE load_err_headers_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END cleanup_err_docs;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: migrate_documents
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows,
  --     back to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the iP Catalog Data related to PO Documents (GBPA, BPA and
  --  Quotations). This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_batch_id
  --  Batch ID to identify the data in interface tables that needs to be
  --  migrated.
  --p_batch_size
  --  The maximum number of rows that should be processed at a time, to avoid
  --  exceeding rollback segment. The transaction would be committed after
  --  processing each batch.
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --x_return_status
  -- Apps API Std
  --  FND_API.g_ret_sts_success - if the procedure completed successfully
  --  FND_API.g_ret_sts_error - if an error occurred
  --  FND_API.g_ret_sts_unexp_error - unexpected error occurred
  --x_msg_count
  -- Apps API Std
  -- The number of error messages returned in the FND error stack in case
  -- x_return_status returned FND_API.G_RET_STS_ERROR or
  -- FND_API.G_RET_STS_UNEXP_ERROR
  --x_msg_data
  -- Apps API Std
  --  Contains error msg in case x_return_status returned
  --  FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_documents
(
   p_batch_id           IN NUMBER
,  p_batch_size         IN NUMBER default 2500
,  p_commit             IN VARCHAR2 default FND_API.G_FALSE
,  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_documents';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
  l_return_status VARCHAR2(1);
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_progress := '010';
  -- Initializes the global variables to hold input parameters.
  -- Initializes startup values by calling PO_CORE_S.get_po_parameters().
  -- Sets the global variable of g_processing_id from a sequence.
  initialize_system_values(
                      p_batch_id           => p_batch_id
                    , p_commit             => p_commit
                    , p_batch_size         => p_batch_size
                    , p_validate_only_mode => p_validate_only_mode);

  l_progress := '020';
  -- Pre-process the interface table data. Assign processing_ids, validates
  -- ACTION, validate if document already exists (for UPDATE cases), etc. Some
  -- of it will be rejected in pre-processing itself.
  pre_process(p_validate_only_mode => p_validate_only_mode);

  l_progress := '030';
  -- Migrate headers
  migrate_document_headers(p_validate_only_mode => p_validate_only_mode);

  l_progress := '040';
  -- Migrate lines
  migrate_document_lines(p_validate_only_mode => p_validate_only_mode);

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END migrate_documents;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: initialize_system_values
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Initializes the PDOI engine:
  --      * Initializes errors table.
  --      * Sets the batch_id and batch_size into PDOI global variables
  --      * Sets startup values (system parameters, profile values, etc.)
  --      * Initializes the counts to zero (success rows count, failed rows count).
  --      * Fetches the next processing_id from sequence.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_batch_id
  --  Batch ID to identify the data in interface tables that needs to be migrated.
  --p_batch_size
  --  The maximum number of rows that should be processed at a time, to avoid
  --  exceeding rollback segment. The transaction would be committed after
  --  processing each batch.
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE initialize_system_values
(
   p_batch_id           IN NUMBER
,  p_batch_size         IN NUMBER default 2500
,  p_commit             IN VARCHAR2 default FND_API.G_FALSE
,  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'initialize_system_values';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  PO_R12_CAT_UPG_UTL.init_startup_values
  ( p_commit => p_commit,
    p_selected_batch_id => p_batch_id,
    p_batch_size => p_batch_size,
    p_buyer_id => NULL,
    p_document_type => NULL,
    p_document_subtype => NULL,
    p_create_items => NULL,
    p_create_sourcing_rules_flag => NULL,
    p_rel_gen_method => NULL,
    p_approved_status => NULL,
    p_process_code => NULL,
    p_interface_header_id => NULL,
    p_org_id => NULL, -- TODO: call MOAC API to get the current org id
    p_ga_flag => NULL,
    p_role => NULL,
    p_error_threshold => NULL,
    p_validate_only_mode => p_validate_only_mode
  );

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END initialize_system_values;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: pre_process
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  This procedure is a copy of the following PDOI procedure:
  --        PO_PREPROC_PVT.process
  --  It executes only a subset of actions that are required for the Catalog Upgrade.
  --
  --  Performs some pre-processing tasks on the interface data:
  --    * Assigns processing ID's to the interface tables.
  --    * Validates interface data for ORIGINAL or ADD actions (same as CREATE)
  --    * Validates interface data for UPDATE action
  --    * Validates interface data for DELETE action
  --    * Flushes errors table.
  --    * Commits transaction.
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE pre_process
(
  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'pre_process';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Updates all records that will be processed by the current request with a
  -- single processing_id. Each time PDOI is called, a new processing_id is
  -- generated. All operations afterwards will only look at records with this
  -- processing id.

  PO_R12_CAT_UPG_UTL.assign_processing_id;

  l_progress := '020';
  -- Migration specific validations. Reject invalid rows upfront so that we
  -- avoid called derive+default+validate on these rows. There procedures
  -- validate at all levels - header, line, attribute and TLP levels

  -- Bug 5389286: Commented out the 'integration-time-only' validations.
  -- We dont need them anymore, as we are in xbuild#7 now, and the
  -- integration flows have all been tested between PO and IP for
  -- this program.
  --PO_R12_CAT_UPG_VAL_PVT.validate_create_action
  --                          (p_validate_only_mode => p_validate_only_mode);
  --
  --l_progress := '030';
  --PO_R12_CAT_UPG_VAL_PVT.validate_add_action
  --                          (p_validate_only_mode => p_validate_only_mode);
  --
  --l_progress := '040';
  --PO_R12_CAT_UPG_VAL_PVT.validate_update_action
  --                          (p_validate_only_mode => p_validate_only_mode);
  --
  --l_progress := '050';
  --PO_R12_CAT_UPG_VAL_PVT.validate_delete_action
  --                          (p_validate_only_mode => p_validate_only_mode);
  -- Bug 5389286: End

  l_progress := '060';
  COMMIT;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END pre_process;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: migrate_document_headers
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the document headers for GBPA/BPA/Quotations.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_document_headers
(
   p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_document_headers';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
  l_return_status VARCHAR2(1);

  -- SQL What: Cursor to load headers
  -- SQL Why : To migrate data to PO txn tables
  -- SQL Join: processing_id, action
  CURSOR load_headers_csr(request_processing_id NUMBER) IS
    SELECT headers.interface_header_id,
           headers.batch_id,
           headers.interface_source_code,
           headers.process_code,
           headers.action,
           headers.group_code,
           headers.org_id,
           headers.document_type_code,
           headers.document_subtype,
           headers.document_num,
           headers.po_header_id,
           headers.release_num,
           headers.po_release_id,
           headers.release_date,
           headers.currency_code,
           headers.rate_type,
           headers.rate_type_code,
           headers.rate_date,
           headers.rate,
           headers.agent_name,
           headers.agent_id,
           headers.vendor_name,
           headers.vendor_id,
           headers.vendor_site_code,
           headers.vendor_site_id,
           headers.vendor_contact,
           headers.vendor_contact_id,
           headers.ship_to_location,
           headers.ship_to_location_id,
           headers.bill_to_location,
           headers.bill_to_location_id,
           headers.payment_terms,
           headers.terms_id,
           headers.freight_carrier,
           headers.fob,
           headers.freight_terms,
           headers.approval_status,
           headers.approved_date,
           headers.revised_date,
           headers.revision_num,
           headers.note_to_vendor,
           headers.note_to_receiver,
           headers.confirming_order_flag,
           headers.comments,
           headers.acceptance_required_flag,
           headers.acceptance_due_date,
           headers.amount_agreed,
           headers.amount_limit,
           headers.min_release_amount,
           headers.effective_date,
           headers.expiration_date,
           headers.print_count,
           headers.printed_date,
           headers.firm_flag,
           headers.frozen_flag,
           headers.closed_code,
           headers.closed_date,
           headers.reply_date,
           headers.reply_method,
           headers.rfq_close_date,
           headers.quote_warning_delay,
           headers.vendor_doc_num,
           headers.approval_required_flag,
           headers.vendor_list,
           headers.vendor_list_header_id,
           headers.from_header_id,
           headers.from_type_lookup_code,
           headers.ussgl_transaction_code,
           headers.attribute_category,
           headers.attribute1,
           headers.attribute2,
           headers.attribute3,
           headers.attribute4,
           headers.attribute5,
           headers.attribute6,
           headers.attribute7,
           headers.attribute8,
           headers.attribute9,
           headers.attribute10,
           headers.attribute11,
           headers.attribute12,
           headers.attribute13,
           headers.attribute14,
           headers.attribute15,
           headers.creation_date,
           headers.created_by,
           headers.last_update_date,
           headers.last_updated_by,
           headers.last_update_login,
           headers.request_id,
           headers.program_application_id,
           headers.program_id,
           headers.program_update_date,
           headers.reference_num,
           headers.load_sourcing_rules_flag,
           headers.vendor_num,
           headers.from_rfq_num,
           headers.wf_group_id,
           headers.pcard_id,
           headers.pay_on_code,
           headers.global_agreement_flag,
           headers.consume_req_demand_flag,
           NULL, --headers.shipping_control, TODO: Not present in 11.5.9
           NULL, --headers.amount_to_encumber, TODO: Not present in 11.5.9
           NULL, --headers.change_summary, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment1, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment2, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment3, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment4, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment5, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment6, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment7, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment8, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment9, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment10, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment11, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment12, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment13, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment14, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment15, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment16, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment17, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment18, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment19, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment20, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment21, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment22, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment23, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment24, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment25, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment26, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment27, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment28, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment29, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_segment30, TODO: Not present in 11.5.9
           NULL, --headers.budget_account, TODO: Not present in 11.5.9
           NULL, --headers.budget_account_id, TODO: Not present in 11.5.9
           NULL, --headers.gl_encumbered_date, TODO: Not present in 11.5.9
           NULL, --headers.gl_encumbered_period_name, TODO: Not present in 11.5.9
           NULL, --headers.style_id, TODO: Not present in 11.5.9
           NULL, --headers.draft_id, TODO: Not present in 11.5.9
           headers.processing_id,
           NULL, --headers.processing_round_num, TODO: Not present in 11.5.9
           NULL, --headers.original_po_header_id, TODO: Not present in 11.5.9
           headers.created_language,
           headers.cpa_reference,
           'N' -- has_errors
    FROM   po_headers_interface headers
    WHERE  headers.processing_id = request_processing_id
    AND    headers.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW
    AND    headers.action IN (PO_R12_CAT_UPG_PVT.g_action_header_create, 'UPDATE', 'DELETE');

  l_doc_headers_table record_of_headers_type;
  l_err_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_count NUMBER := NULL;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Algorithm:
  -- 1. Load Headers batch (batch_size) into pl/sql table.
  -- 2. Call PDOI modules to process data in batches (default, derive, validate).
  -- 3. Get the validated pl/sql table for the batch from PDOI.
  -- 4. Transfer directly to Transaction tables

  OPEN load_headers_csr(g_processing_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      FETCH load_headers_csr BULK COLLECT INTO
        l_doc_headers_table.interface_header_id,
        l_doc_headers_table.batch_id,
        l_doc_headers_table.interface_source_code,
        l_doc_headers_table.process_code,
        l_doc_headers_table.action,
        l_doc_headers_table.group_code,
        l_doc_headers_table.org_id,
        l_doc_headers_table.document_type_code,
        l_doc_headers_table.document_subtype,
        l_doc_headers_table.document_num,
        l_doc_headers_table.po_header_id,
        l_doc_headers_table.release_num,
        l_doc_headers_table.po_release_id,
        l_doc_headers_table.release_date,
        l_doc_headers_table.currency_code,
        l_doc_headers_table.rate_type,
        l_doc_headers_table.rate_type_code,
        l_doc_headers_table.rate_date,
        l_doc_headers_table.rate,
        l_doc_headers_table.agent_name,
        l_doc_headers_table.agent_id,
        l_doc_headers_table.vendor_name,
        l_doc_headers_table.vendor_id,
        l_doc_headers_table.vendor_site_code,
        l_doc_headers_table.vendor_site_id,
        l_doc_headers_table.vendor_contact,
        l_doc_headers_table.vendor_contact_id,
        l_doc_headers_table.ship_to_location,
        l_doc_headers_table.ship_to_location_id,
        l_doc_headers_table.bill_to_location,
        l_doc_headers_table.bill_to_location_id,
        l_doc_headers_table.payment_terms,
        l_doc_headers_table.terms_id,
        l_doc_headers_table.freight_carrier,
        l_doc_headers_table.fob,
        l_doc_headers_table.freight_terms,
        l_doc_headers_table.approval_status,
        l_doc_headers_table.approved_date,
        l_doc_headers_table.revised_date,
        l_doc_headers_table.revision_num,
        l_doc_headers_table.note_to_vendor,
        l_doc_headers_table.note_to_receiver,
        l_doc_headers_table.confirming_order_flag,
        l_doc_headers_table.comments,
        l_doc_headers_table.acceptance_required_flag,
        l_doc_headers_table.acceptance_due_date,
        l_doc_headers_table.amount_agreed,
        l_doc_headers_table.amount_limit,
        l_doc_headers_table.min_release_amount,
        l_doc_headers_table.effective_date,
        l_doc_headers_table.expiration_date,
        l_doc_headers_table.print_count,
        l_doc_headers_table.printed_date,
        l_doc_headers_table.firm_flag,
        l_doc_headers_table.frozen_flag,
        l_doc_headers_table.closed_code,
        l_doc_headers_table.closed_date,
        l_doc_headers_table.reply_date,
        l_doc_headers_table.reply_method,
        l_doc_headers_table.rfq_close_date,
        l_doc_headers_table.quote_warning_delay,
        l_doc_headers_table.vendor_doc_num,
        l_doc_headers_table.approval_required_flag,
        l_doc_headers_table.vendor_list,
        l_doc_headers_table.vendor_list_header_id,
        l_doc_headers_table.from_header_id,
        l_doc_headers_table.from_type_lookup_code,
        l_doc_headers_table.ussgl_transaction_code,
        l_doc_headers_table.attribute_category,
        l_doc_headers_table.attribute1,
        l_doc_headers_table.attribute2,
        l_doc_headers_table.attribute3,
        l_doc_headers_table.attribute4,
        l_doc_headers_table.attribute5,
        l_doc_headers_table.attribute6,
        l_doc_headers_table.attribute7,
        l_doc_headers_table.attribute8,
        l_doc_headers_table.attribute9,
        l_doc_headers_table.attribute10,
        l_doc_headers_table.attribute11,
        l_doc_headers_table.attribute12,
        l_doc_headers_table.attribute13,
        l_doc_headers_table.attribute14,
        l_doc_headers_table.attribute15,
        l_doc_headers_table.creation_date,
        l_doc_headers_table.created_by,
        l_doc_headers_table.last_update_date,
        l_doc_headers_table.last_updated_by,
        l_doc_headers_table.last_update_login,
        l_doc_headers_table.request_id,
        l_doc_headers_table.program_application_id,
        l_doc_headers_table.program_id,
        l_doc_headers_table.program_update_date,
        l_doc_headers_table.reference_num,
        l_doc_headers_table.load_sourcing_rules_flag,
        l_doc_headers_table.vendor_num,
        l_doc_headers_table.from_rfq_num,
        l_doc_headers_table.wf_group_id,
        l_doc_headers_table.pcard_id,
        l_doc_headers_table.pay_on_code,
        l_doc_headers_table.global_agreement_flag,
        l_doc_headers_table.consume_req_demand_flag,
        l_doc_headers_table.shipping_control, --TODO: Not present in 11.5.9
        l_doc_headers_table.amount_to_encumber, --TODO: Not present in 11.5.9
        l_doc_headers_table.change_summary, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment1, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment2, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment3, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment4, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment5, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment6, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment7, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment8, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment9, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment10, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment11, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment12, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment13, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment14, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment15, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment16, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment17, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment18, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment19, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment20, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment21, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment22, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment23, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment24, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment25, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment26, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment27, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment28, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment29, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_segment30, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account, --TODO: Not present in 11.5.9
        l_doc_headers_table.budget_account_id, --TODO: Not present in 11.5.9
        l_doc_headers_table.gl_encumbered_date, --TODO: Not present in 11.5.9
        l_doc_headers_table.gl_encumbered_period_name, --TODO: Not present in 11.5.9
        l_doc_headers_table.style_id, --TODO: Not present in 11.5.9
        l_doc_headers_table.draft_id, --TODO: Not present in 11.5.9
        l_doc_headers_table.processing_id,
        l_doc_headers_table.processing_round_num, --TODO: Not present in 11.5.9
        l_doc_headers_table.original_po_header_id, --TODO: Not present in 11.5.9
        l_doc_headers_table.created_language,
        l_doc_headers_table.cpa_reference,
        l_doc_headers_table.has_errors
      LIMIT g_job.batch_size;

      l_progress := '030';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_doc_headers_table.interface_header_id.COUNT='||l_doc_headers_table.interface_header_id.COUNT); END IF;

      IF (l_doc_headers_table.interface_header_id.COUNT > 0) THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_doc_headers_table.po_header_id(1)='||l_doc_headers_table.po_header_id(1)); END IF;
      END IF;

      EXIT WHEN l_doc_headers_table.interface_header_id.COUNT = 0;

      l_progress := '040';

      -- The derive+default+validate modules are being re-used from PDOI
      -- derive logic
      --PO_PROCESS_HEADER_PVT.derive_headers(l_doc_headers_table);

      l_progress := '050';
      -- default logic
      PO_R12_CAT_UPG_DEF_PVT.default_headers(l_doc_headers_table);

      l_progress := '060';
      -- validate logic
      PO_R12_CAT_UPG_VAL_PVT.validate_headers(l_doc_headers_table);

      l_progress := '070';
      -- Skip transfer if running in Validate Only mode.
      IF (p_validate_only_mode = FND_API.G_FALSE) THEN
        -- Transfer Headers
        transfer_doc_headers(x_doc_headers_rec => l_doc_headers_table);

        l_progress := '080';
        -- cascade rejected status to lines and other levels
        l_count := 0;
        FOR i IN 1..l_doc_headers_table.interface_header_id.COUNT
        LOOP
          IF (l_doc_headers_table.has_errors(i) = 'Y') THEN
            l_count := l_count + 1;
            l_err_interface_header_ids(l_count) := l_doc_headers_table.interface_header_id(i);
          END IF;
        END LOOP;

        l_progress := '110';
        IF (l_count > 0) THEN
          PO_R12_CAT_UPG_UTL.reject_headers_intf
                                 (p_id_param_type => 'INTERFACE_HEADER_ID',
                                  p_id_tbl        => l_err_interface_header_ids,
                                  p_cascade       => FND_API.G_TRUE);
        END IF;

      END IF; -- IF (p_validate_only_mode = FND_API.G_FALSE)

      l_progress := '120';
      COMMIT;

      -- Call IP's API to update the header ID in IP's tables
      update_ip_tables_hdr
      (
        p_doc_headers_table => l_doc_headers_table
      );

      l_progress := '130';
      IF (l_doc_headers_table.interface_header_id.COUNT
                  < g_job.batch_size) THEN
        EXIT;
      END IF;
      l_progress := '140';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_headers_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '150';
        COMMIT;

        l_progress := '160';
        CLOSE load_headers_csr;

        l_progress := '170';
        OPEN load_headers_csr(g_processing_id);
        l_progress := '180';
    END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP;

  l_progress := '190';
  IF (load_headers_csr%ISOPEN) THEN
    CLOSE load_headers_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_headers_csr%ISOPEN) THEN
      CLOSE load_headers_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END migrate_document_headers;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: transfer_doc_headers
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Transfers a batch of document headers given in a plsql table, into the
  --  transaction tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_headers_rec
  --  A table of plsql records containing a batch of header information for
  --  creating a new header.
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE transfer_doc_headers
(
   x_doc_headers_rec  IN OUT NOCOPY record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'transfer_doc_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Insert Headers
  insert_doc_headers(x_doc_headers_rec => x_doc_headers_rec);

  l_progress := '020';
  -- Update Headers
  update_doc_headers(p_doc_headers_rec => x_doc_headers_rec);

  l_progress := '030';
  -- Delete Headers
  delete_doc_headers(p_doc_headers_rec => x_doc_headers_rec);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END transfer_doc_headers;

--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_cpa_attachments
--Pre-reqs:
--  The iP catalog data is populated in PO Interface tables.
--Modifies:
--  a) FND_ATTCHMENTS table: Inserts copied attchments.
--  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
--     failed the migration.
--  c) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Copies the attchments from the CPA Header to the new GBPA header.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_valid_po_hdr_ids
--  List of valid PO_HEADER_ID's for which attachments may be copied
--p_valid_intf_hdr_ids
--  List of valid INTERFACE_HEADER_ID's for which attachments may be copied
--p_valid_cpa_references
--  The list of CPA references (segment1's) from which the attchment needs
--  to be copied into the new GBPA.
--p_valid_org_ids
--  The org_id's for the CPA (segment1+org_id) will form a unique key for the CPA
--p_valid_vndr_site_ids
--  List of vendor_site_id's for each of the headers
--IN/OUT:
-- x_doc_headers_rec
--  A table of plsql records containing a batch of header information for
--  creating a new GBPA header. If the copy attachment fails, then the record for
--  that header will be marked as errored.
--OUT:
--x_remaining_val_po_hdr_ids
--  List of PO_HEADER_ID for which copy attachment did not fail.
--x_remaining_val_intf_hdr_ids
--  List of INTERFACE_HEADER_ID for which copy attachment did not fail.
--x_remaining_val_vndr_site_ids
--  List of vendor_site_id's for each of the remaining successful headers.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_cpa_attachments
(
  p_valid_po_hdr_ids            IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_intf_hdr_ids          IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_cpa_references        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_org_ids               IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_vndr_site_ids         IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_doc_headers_rec             IN OUT NOCOPY record_of_headers_type
, x_remaining_val_po_hdr_ids    IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_remaining_val_intf_hdr_ids  IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_remaining_val_vndr_site_ids IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'copy_cpa_attachments';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
  j NUMBER;
  l_count NUMBER := 0;
  l_err_count NUMBER;
  l_is_attach_err_intf_hdr_id PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR1;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  l_err_count := 0;
  FOR i IN 1 .. p_valid_po_hdr_ids.COUNT
  LOOP
    IF (p_valid_cpa_references(i) IS NOT NULL) THEN
      BEGIN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
        (
          x_from_entity_name         => 'PO_HEADERS',              -- IN VARCHAR2
          x_from_pk1_value           => p_valid_cpa_references(i), -- IN VARCHAR2
          x_from_pk2_value           => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_from_pk3_value           => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_from_pk4_value           => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_from_pk5_value           => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_to_entity_name           => 'PO_HEADERS',              -- IN VARCHAR2
          x_to_pk1_value             => p_valid_po_hdr_ids(i),     -- IN VARCHAR2
          x_to_pk2_value             => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_to_pk3_value             => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_to_pk4_value             => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_to_pk5_value             => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_created_by               => FND_GLOBAL.user_id,        -- IN NUMBER DEFAULT NULL
          x_last_update_login        => FND_GLOBAL.login_id,       -- IN NUMBER DEFAULT NULL
          x_program_application_id   => '',                        -- IN NUMBER DEFAULT NULL
          x_program_id               => '',                        -- IN NUMBER DEFAULT NULL
          x_request_id               => '',                        -- IN NUMBER DEFAULT NULL
          x_automatically_added_flag => '',                        -- IN VARCHAR2 DEFAULT NULL
          x_from_category_id         => '',                        -- IN NUMBER DEFAULT NULL
          x_to_category_id           => ''                         -- IN NUMBER DEFAULT NULL
        );
      EXCEPTION
        WHEN OTHERS THEN
          -- Mark record as Rejected and proceed with other records

          l_err_count := l_err_count + 1;
          l_is_attach_err_intf_hdr_id(p_valid_intf_hdr_ids(i)) := 'Y'; -- sparse collection

          IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Copy attachment error for INTF_HDR_ID='||p_valid_intf_hdr_ids(i)||', PO_HEADER_ID='||p_valid_po_hdr_ids(i)); END IF;

          FOR j IN 1 .. x_doc_headers_rec.interface_header_id.COUNT
          LOOP
            l_progress := '140';
            IF (x_doc_headers_rec.interface_header_id(j) = p_valid_intf_hdr_ids(i)) THEN
              x_doc_headers_rec.has_errors(j) := 'Y';

              l_progress := '150';
              -- ICX_CAT_ERR_IN_COPY_ATTCHMNTS:
              -- "An error occurred in the call to API_NAME while copying attachments."
              PO_R12_CAT_UPG_UTL.add_fatal_error(
                  p_interface_header_id => p_valid_intf_hdr_ids(i),
                  p_error_message_name  => 'ICX_CAT_ERR_IN_COPY_ATTCHMNTS',
                  p_table_name          => 'PO_HEADERS_INTERFACE',
                  p_column_name         => 'INTERFACE_HEADER_ID',
                  p_column_value        => x_doc_headers_rec.interface_header_id(j),
                  p_token1_name         => 'API_NAME',
                  p_token1_value        => 'FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments'
                  );
            END IF;
          END LOOP;
      END; -- exception block
    END IF; -- IF (p_valid_cpa_references(i) IS NOT NULL)
  END LOOP; -- copy attachment loop

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of err in copy attach='||l_err_count); END IF;

  -- Now subtract the attachment errored records so that Org Assignments are created
  -- only for the successfully inserted ones.
  l_count := 0;
  FOR i IN 1 .. p_valid_po_hdr_ids.COUNT
  LOOP
    IF (l_is_attach_err_intf_hdr_id.exists(p_valid_intf_hdr_ids(i))) THEN
      -- DELETE the attachment copy errored header from txn table
      DELETE FROM PO_HEADERS_ALL
      WHERE PO_HEADER_ID = p_valid_po_hdr_ids(i);

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO Header deleted for '||i); END IF;
    ELSE
      l_count := l_count + 1;
      x_remaining_val_intf_hdr_ids(l_count) := p_valid_intf_hdr_ids(i);
      x_remaining_val_po_hdr_ids(l_count) := p_valid_po_hdr_ids(i);
      x_remaining_val_vndr_site_ids(l_count) := p_valid_vndr_site_ids(i);
    END IF;
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of success copy attach='||l_count); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END copy_cpa_attachments;

--------------------------------------------------------------------------------
--Start of Comments
--Name: manage_copy_cpa
--Pre-reqs:
--  The iP catalog data is populated in PO Interface tables.
--Modifies:
--  a) FND_ATTCHMENTS table: Inserts copied attchments.
--  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
--     failed the migration.
--  c) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This procedure manages the flow when a CPA is being copied to become a
--  new GBPA.
--   1. It copies the attchments from the CPA Header to the new GBPA header.
--   2. It copies some of the extra attributes from the CPA Header to GBPA
--      header. These are those attributes that are not present in the
--      PO_HEADERS_INTERFACE table. So IP has not mechanism to provide
--      these values during catalog migration. Therefore, we directly copy
--      these values during a CPA-GBPA flow.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_valid_po_hdr_ids
--  List of valid PO_HEADER_ID's for which attachments may be copied
--p_valid_intf_hdr_ids
--  List of valid INTERFACE_HEADER_ID's for which attachments may be copied
--p_valid_cpa_references
--  The list of CPA references (segment1's) from which the attchment needs
--  to be copied into the new GBPA.
--p_valid_org_ids
--  The org_id's for the CPA (segment1+org_id) will form a unique key for the CPA
--p_valid_vndr_site_ids
--  List of vendor_site_id's for each of the headers
--IN/OUT:
-- x_doc_headers_rec
--  A table of plsql records containing a batch of header information for
--  creating a new GBPA header. If the copy attachment fails, then the record for
--  that header will be marked as errored.
--OUT:
--x_remaining_val_po_hdr_ids
--  List of PO_HEADER_ID for which copy attachment did not fail.
--x_remaining_val_intf_hdr_ids
--  List of INTERFACE_HEADER_ID for which copy attachment did not fail.
--x_remaining_val_vndr_site_ids
--  List of vendor_site_id's for each of the remaining successful headers.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE manage_copy_cpa
(
  p_valid_po_hdr_ids            IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_intf_hdr_ids          IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_cpa_references        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_org_ids               IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_valid_vndr_site_ids         IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_doc_headers_rec             IN OUT NOCOPY record_of_headers_type
, x_remaining_val_po_hdr_ids    IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_remaining_val_intf_hdr_ids  IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_remaining_val_vndr_site_ids IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'manage_copy_cpa';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
  j NUMBER;
  l_is_valid_cpa VARCHAR2(1);
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- First copy the CPA attachments into the new GBPA.
  copy_cpa_attachments
  (
    p_valid_po_hdr_ids            => p_valid_po_hdr_ids
  , p_valid_intf_hdr_ids          => p_valid_intf_hdr_ids
  , p_valid_cpa_references        => p_valid_cpa_references
  , p_valid_org_ids               => p_valid_org_ids
  , p_valid_vndr_site_ids         => p_valid_vndr_site_ids
  , x_doc_headers_rec             => x_doc_headers_rec
  , x_remaining_val_po_hdr_ids    => x_remaining_val_po_hdr_ids
  , x_remaining_val_intf_hdr_ids  => x_remaining_val_intf_hdr_ids
  , x_remaining_val_vndr_site_ids => x_remaining_val_vndr_site_ids
  );

  -- There could have been some exception while copying the attachment.
  -- We filter out those records. So process the remaining.

  l_progress := '020';
  -- ECO bug 4554461:
  -- COPY OF CPA ATTRIBUTES TO THE NEW GBPA DURING THE UPGRADE
  FOR i IN 1 .. x_remaining_val_po_hdr_ids.COUNT
  LOOP
    l_progress := '030';
    FOR j IN 1 .. x_doc_headers_rec.interface_header_id.COUNT
    LOOP
      l_progress := '040';
      IF (x_doc_headers_rec.interface_header_id(j) = x_remaining_val_intf_hdr_ids(i) AND
          x_doc_headers_rec.cpa_reference(j) IS NOT NULL AND
          x_remaining_val_po_hdr_ids(i) IS NOT NULL AND
          x_doc_headers_rec.has_errors(j) <> 'Y' ) THEN

        l_progress := '050';
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'cpa_reference('||j||')='||x_doc_headers_rec.cpa_reference(j)); END IF;

        -- Validate the CPA
        l_is_valid_cpa := 'N';

        l_progress := '055';
        BEGIN
          SELECT 'Y'
          INTO l_is_valid_cpa
          FROM PO_HEADERS_ALL
          WHERE po_header_id = x_doc_headers_rec.cpa_reference(j)
            AND type_lookup_code = 'CONTRACT';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_is_valid_cpa := 'N';
        END;

        l_progress := '060';
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_is_valid_cpa='||l_is_valid_cpa); END IF;

        IF (l_is_valid_cpa = 'Y') THEN
          l_progress := '070';
          UPDATE PO_HEADERS_ALL GBPA
          SET
          (
            attribute_category
          , attribute1
          , attribute2
          , attribute3
          , attribute4
          , attribute5
          , attribute6
          , attribute7
          , attribute8
          , attribute9
          , attribute10
          , attribute11
          , attribute12
          , attribute13
          , attribute14
          , attribute15
          , global_attribute_category
          , global_attribute1
          , global_attribute2
          , global_attribute3
          , global_attribute4
          , global_attribute5
          , global_attribute6
          , global_attribute7
          , global_attribute8
          , global_attribute9
          , global_attribute10
          , global_attribute11
          , global_attribute12
          , global_attribute13
          , global_attribute14
          , global_attribute15
          , global_attribute16
          , global_attribute17
          , global_attribute18
          , global_attribute19
          , global_attribute20
          , vendor_contact_id
          , ship_to_location_id
          , bill_to_location_id
          , agent_id
          , blanket_total_amount
          , comments
          , rate_type
          , rate_date
          , rate
          , terms_id
          , freight_terms_lookup_code
          , ship_via_lookup_code
          , fob_lookup_code
          , pay_on_code
          , shipping_control -- transportation_arranged_by: Open Issue: As per Puneet this column is the same
                             -- as shipping_control. PO will decide if this column is needed or not
          , confirming_order_flag
          , acceptance_required_flag
          , acceptance_due_date
          , note_to_vendor
          , note_to_receiver
          , amount_limit
          , min_release_amount
          , price_update_tolerance
          --, approved_flag -- This will be set in final upgrade
          , ussgl_transaction_code
          , mrc_rate_type
          , mrc_rate_date
          , mrc_rate
          , summary_flag
          , enabled_flag
          , start_date_active
          , end_date_active
          , start_date
          , end_date
          --, authorization_status -- This will be set in final upgrade
          , note_to_authorizer
          , vendor_order_num
          , approval_required_flag
          , firm_status_lookup_code
          , firm_date
          , government_context
          , supply_agreement_flag
          , xml_flag
          , xml_send_date
          , xml_change_send_date
          , cbc_accounting_date
          ) = ( SELECT
            attribute_category
          , attribute1
          , attribute2
          , attribute3
          , attribute4
          , attribute5
          , attribute6
          , attribute7
          , attribute8
          , attribute9
          , attribute10
          , attribute11
          , attribute12
          , attribute13
          , attribute14
          , attribute15
          , global_attribute_category
          , global_attribute1
          , global_attribute2
          , global_attribute3
          , global_attribute4
          , global_attribute5
          , global_attribute6
          , global_attribute7
          , global_attribute8
          , global_attribute9
          , global_attribute10
          , global_attribute11
          , global_attribute12
          , global_attribute13
          , global_attribute14
          , global_attribute15
          , global_attribute16
          , global_attribute17
          , global_attribute18
          , global_attribute19
          , global_attribute20
          , vendor_contact_id
          , ship_to_location_id
          , bill_to_location_id
          , agent_id
          , blanket_total_amount
          , substr(comments,1,210) || ' (CPA #' || segment1 || ')'
          , rate_type
          , rate_date
          , rate
          , terms_id
          , freight_terms_lookup_code
          , ship_via_lookup_code
          , fob_lookup_code
          , pay_on_code
          , shipping_control -- transportation_arranged_by: Open Issue: As per Puneet this column is the same
                             -- as shipping_control. PO will decide if this column is needed or not
          , confirming_order_flag
          , acceptance_required_flag
          , acceptance_due_date
          , note_to_vendor
          , note_to_receiver
          , amount_limit
          , min_release_amount
          , price_update_tolerance
          --, approved_flag -- This will be set in final upgrade
          , ussgl_transaction_code
          , mrc_rate_type
          , mrc_rate_date
          , mrc_rate
          , summary_flag
          , enabled_flag
          , start_date_active
          , end_date_active
          , start_date
          , end_date
          --, authorization_status -- This will be set in final upgrade
          , note_to_authorizer
          , vendor_order_num
          , approval_required_flag
          , firm_status_lookup_code
          , firm_date
          , government_context
          , supply_agreement_flag
          , xml_flag
          , xml_send_date
          , xml_change_send_date
          , cbc_accounting_date
          FROM PO_HEADERS_ALL CPA
          WHERE CPA.po_header_id = x_doc_headers_rec.cpa_reference(j))
          WHERE GBPA.po_header_id = x_remaining_val_po_hdr_ids(i);

          IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Copied attributes of CPA header_id='||x_doc_headers_rec.cpa_reference(j)||' into GBPA header_id='||x_remaining_val_po_hdr_ids(i)); END IF;
        END IF; -- IF (l_is_valid_cpa = 'Y')
      END IF;
    END LOOP;
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END manage_copy_cpa;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: insert_doc_headers
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Inserts a batch of document headers given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN/OUT:
  -- x_doc_headers_rec
  --  A table of plsql records containing a batch of header information for
  --  creating a new GBPA header. If the MRC API fails, then the record for
  --  that header will be marked as errored.
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_doc_headers
(
   x_doc_headers_rec IN OUT NOCOPY record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_doc_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
  j NUMBER;
  l_valid_headers record_of_headers_type;
  l_count NUMBER := 0;
  l_num_valid_headers NUMBER;

  l_return_status VARCHAR2(1);

  l_remaining_val_po_hdr_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_remaining_val_intf_hdr_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_remaining_val_vndr_site_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  -- Find the number of valid headers so that we can initialize the size of
  -- the arrays.
  l_num_valid_headers := 0;
  FOR i IN 1 .. x_doc_headers_rec.interface_header_id.COUNT
  LOOP
    IF (x_doc_headers_rec.has_errors(i) = 'N' AND
        x_doc_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create) THEN
      l_num_valid_headers := l_num_valid_headers + 1;
    END IF;
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_num_valid_headers='||l_num_valid_headers); END IF;

  l_progress := '030';
  -- Get the valid rows into l_valid_headers array.
  l_count := 0;
  FOR i IN 1 .. x_doc_headers_rec.interface_header_id.COUNT
  LOOP
    l_progress := '040';
    IF (x_doc_headers_rec.has_errors(i) = 'N'
        AND x_doc_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create) THEN
      l_count := l_count + 1;

      l_progress := '050';
      SELECT PO_HEADERS_S.nextval
      INTO l_valid_headers.po_header_id(l_count)
      FROM dual;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'From sequence, next po_header_id='||l_valid_headers.po_header_id(l_count)); END IF;

      l_progress := '060';
      l_valid_headers.interface_header_id(l_count) := x_doc_headers_rec.interface_header_id(i);
      l_progress := '061';
      l_valid_headers.batch_id(l_count) := x_doc_headers_rec.batch_id(i);
      l_valid_headers.interface_source_code(l_count) := x_doc_headers_rec.interface_source_code(i);
      l_valid_headers.process_code(l_count) := x_doc_headers_rec.process_code(i);
      l_valid_headers.action(l_count) := x_doc_headers_rec.action(i);
      l_valid_headers.group_code(l_count) := x_doc_headers_rec.group_code(i);
      l_valid_headers.org_id(l_count) := x_doc_headers_rec.org_id(i);
      l_valid_headers.document_type_code(l_count) := x_doc_headers_rec.document_type_code(i);
      l_valid_headers.document_subtype(l_count) := x_doc_headers_rec.document_subtype(i);
      l_valid_headers.document_num(l_count) := x_doc_headers_rec.document_num(i);
      l_valid_headers.release_num(l_count) := x_doc_headers_rec.release_num(i);
      l_valid_headers.po_release_id(l_count) := x_doc_headers_rec.po_release_id(i);
      l_valid_headers.release_date(l_count) := x_doc_headers_rec.release_date(i);
      l_valid_headers.currency_code(l_count) := x_doc_headers_rec.currency_code(i);
      l_valid_headers.rate_type(l_count) := x_doc_headers_rec.rate_type(i);
      l_progress := '062';
      l_valid_headers.rate_type_code(l_count) := x_doc_headers_rec.rate_type_code(i);
      l_valid_headers.rate_date(l_count) := x_doc_headers_rec.rate_date(i);
      l_valid_headers.rate(l_count) := x_doc_headers_rec.rate(i);
      l_valid_headers.agent_name(l_count) := x_doc_headers_rec.agent_name(i);
      l_valid_headers.agent_id(l_count) := x_doc_headers_rec.agent_id(i);
      l_valid_headers.vendor_name(l_count) := x_doc_headers_rec.vendor_name(i);
      l_valid_headers.vendor_id(l_count) := x_doc_headers_rec.vendor_id(i);
      l_valid_headers.vendor_site_code(l_count) := x_doc_headers_rec.vendor_site_code(i);
      l_valid_headers.vendor_site_id(l_count) := x_doc_headers_rec.vendor_site_id(i);
      l_valid_headers.vendor_contact(l_count) := x_doc_headers_rec.vendor_contact(i);
      l_valid_headers.vendor_contact_id(l_count) := x_doc_headers_rec.vendor_contact_id(i);
      l_progress := '063';
      l_valid_headers.ship_to_location(l_count) := x_doc_headers_rec.ship_to_location(i);
      l_valid_headers.ship_to_location_id(l_count) := x_doc_headers_rec.ship_to_location_id(i);
      l_valid_headers.bill_to_location(l_count) := x_doc_headers_rec.bill_to_location(i);
      l_valid_headers.bill_to_location_id(l_count) := x_doc_headers_rec.bill_to_location_id(i);
      l_valid_headers.payment_terms(l_count) := x_doc_headers_rec.payment_terms(i);
      l_valid_headers.terms_id(l_count) := x_doc_headers_rec.terms_id(i);
      l_valid_headers.freight_carrier(l_count) := x_doc_headers_rec.freight_carrier(i);
      l_valid_headers.fob(l_count) := x_doc_headers_rec.fob(i);
      l_valid_headers.freight_terms(l_count) := x_doc_headers_rec.freight_terms(i);
      l_valid_headers.approval_status(l_count) := x_doc_headers_rec.approval_status(i);
      l_progress := '064';
      l_valid_headers.approved_date(l_count) := x_doc_headers_rec.approved_date(i);
      l_valid_headers.revised_date(l_count) := x_doc_headers_rec.revised_date(i);
      l_valid_headers.revision_num(l_count) := x_doc_headers_rec.revision_num(i);
      l_valid_headers.note_to_vendor(l_count) := x_doc_headers_rec.note_to_vendor(i);
      l_valid_headers.note_to_receiver(l_count) := x_doc_headers_rec.note_to_receiver(i);
      l_valid_headers.confirming_order_flag(l_count) := x_doc_headers_rec.confirming_order_flag(i);
      l_valid_headers.comments(l_count) := x_doc_headers_rec.comments(i);
      l_valid_headers.acceptance_required_flag(l_count) := x_doc_headers_rec.acceptance_required_flag(i);
      l_valid_headers.acceptance_due_date(l_count) := x_doc_headers_rec.acceptance_due_date(i);
      l_valid_headers.amount_agreed(l_count) := x_doc_headers_rec.amount_agreed(i);
      l_valid_headers.amount_limit(l_count) := x_doc_headers_rec.amount_limit(i);
      l_progress := '065';
      l_valid_headers.min_release_amount(l_count) := x_doc_headers_rec.min_release_amount(i);
      l_valid_headers.effective_date(l_count) := x_doc_headers_rec.effective_date(i);
      l_valid_headers.expiration_date(l_count) := x_doc_headers_rec.expiration_date(i);
      l_valid_headers.print_count(l_count) := x_doc_headers_rec.print_count(i);
      l_valid_headers.printed_date(l_count) := x_doc_headers_rec.printed_date(i);
      l_valid_headers.firm_flag(l_count) := x_doc_headers_rec.firm_flag(i);
      l_valid_headers.frozen_flag(l_count) := x_doc_headers_rec.frozen_flag(i);
      l_valid_headers.closed_code(l_count) := x_doc_headers_rec.closed_code(i);
      l_valid_headers.closed_date(l_count) := x_doc_headers_rec.closed_date(i);
      l_valid_headers.reply_date(l_count) := x_doc_headers_rec.reply_date(i);
      l_valid_headers.reply_method(l_count) := x_doc_headers_rec.reply_method(i);
      l_valid_headers.rfq_close_date(l_count) := x_doc_headers_rec.rfq_close_date(i);
      l_valid_headers.quote_warning_delay(l_count) := x_doc_headers_rec.quote_warning_delay(i);
      l_valid_headers.vendor_doc_num(l_count) := x_doc_headers_rec.vendor_doc_num(i);
      l_valid_headers.approval_required_flag(l_count) := x_doc_headers_rec.approval_required_flag(i);
      l_valid_headers.vendor_list(l_count) := x_doc_headers_rec.vendor_list(i);
      l_valid_headers.vendor_list_header_id(l_count) := x_doc_headers_rec.vendor_list_header_id(i);
      l_valid_headers.from_header_id(l_count) := x_doc_headers_rec.from_header_id(i);
      l_valid_headers.from_type_lookup_code(l_count) := x_doc_headers_rec.from_type_lookup_code(i);
      l_valid_headers.ussgl_transaction_code(l_count) := x_doc_headers_rec.ussgl_transaction_code(i);
      l_progress := '066';
      l_valid_headers.attribute_category(l_count) := x_doc_headers_rec.attribute_category(i);
      l_valid_headers.attribute1(l_count) := x_doc_headers_rec.attribute1(i);
      l_valid_headers.attribute2(l_count) := x_doc_headers_rec.attribute2(i);
      l_valid_headers.attribute3(l_count) := x_doc_headers_rec.attribute3(i);
      l_valid_headers.attribute4(l_count) := x_doc_headers_rec.attribute4(i);
      l_valid_headers.attribute5(l_count) := x_doc_headers_rec.attribute5(i);
      l_valid_headers.attribute6(l_count) := x_doc_headers_rec.attribute6(i);
      l_valid_headers.attribute7(l_count) := x_doc_headers_rec.attribute7(i);
      l_valid_headers.attribute8(l_count) := x_doc_headers_rec.attribute8(i);
      l_valid_headers.attribute9(l_count) := x_doc_headers_rec.attribute9(i);
      l_valid_headers.attribute10(l_count) := x_doc_headers_rec.attribute10(i);
      l_valid_headers.attribute11(l_count) := x_doc_headers_rec.attribute11(i);
      l_valid_headers.attribute12(l_count) := x_doc_headers_rec.attribute12(i);
      l_valid_headers.attribute13(l_count) := x_doc_headers_rec.attribute13(i);
      l_valid_headers.attribute14(l_count) := x_doc_headers_rec.attribute14(i);
      l_valid_headers.attribute15(l_count) := x_doc_headers_rec.attribute15(i);
      l_valid_headers.creation_date(l_count) := x_doc_headers_rec.creation_date(i);
      l_valid_headers.created_by(l_count) := x_doc_headers_rec.created_by(i);
      l_valid_headers.last_update_date(l_count) := x_doc_headers_rec.last_update_date(i);
      l_valid_headers.last_updated_by(l_count) := x_doc_headers_rec.last_updated_by(i);
      l_valid_headers.last_update_login(l_count) := x_doc_headers_rec.last_update_login(i);
      l_valid_headers.request_id(l_count) := x_doc_headers_rec.request_id(i);
      l_valid_headers.program_application_id(l_count) := x_doc_headers_rec.program_application_id(i);
      l_valid_headers.program_id(l_count) := x_doc_headers_rec.program_id(i);
      l_valid_headers.program_update_date(l_count) := x_doc_headers_rec.program_update_date(i);
      l_progress := '067';
      l_valid_headers.reference_num(l_count) := x_doc_headers_rec.reference_num(i);
      l_valid_headers.load_sourcing_rules_flag(l_count) := x_doc_headers_rec.load_sourcing_rules_flag(i);
      l_valid_headers.vendor_num(l_count) := x_doc_headers_rec.vendor_num(i);
      l_valid_headers.from_rfq_num(l_count) := x_doc_headers_rec.from_rfq_num(i);
      l_valid_headers.wf_group_id(l_count) := x_doc_headers_rec.wf_group_id(i);
      l_valid_headers.pcard_id(l_count) := x_doc_headers_rec.pcard_id(i);
      l_valid_headers.pay_on_code(l_count) := x_doc_headers_rec.pay_on_code(i);
      l_valid_headers.global_agreement_flag(l_count) := x_doc_headers_rec.global_agreement_flag(i);
      l_valid_headers.consume_req_demand_flag(l_count) := x_doc_headers_rec.consume_req_demand_flag(i);
      l_valid_headers.shipping_control(l_count) := x_doc_headers_rec.shipping_control(i);
      l_valid_headers.encumbrance_required_flag(l_count) := NULL; --x_doc_headers_rec.encumbrance_required_flag(i);
      l_valid_headers.amount_to_encumber(l_count) := x_doc_headers_rec.amount_to_encumber(i);
      l_valid_headers.change_summary(l_count) := x_doc_headers_rec.change_summary(i);
      l_progress := '068';
      l_valid_headers.budget_account_segment1(l_count) := x_doc_headers_rec.budget_account_segment1(i);
      l_valid_headers.budget_account_segment2(l_count) := x_doc_headers_rec.budget_account_segment2(i);
      l_valid_headers.budget_account_segment3(l_count) := x_doc_headers_rec.budget_account_segment3(i);
      l_valid_headers.budget_account_segment4(l_count) := x_doc_headers_rec.budget_account_segment4(i);
      l_valid_headers.budget_account_segment5(l_count) := x_doc_headers_rec.budget_account_segment5(i);
      l_valid_headers.budget_account_segment6(l_count) := x_doc_headers_rec.budget_account_segment6(i);
      l_valid_headers.budget_account_segment7(l_count) := x_doc_headers_rec.budget_account_segment7(i);
      l_valid_headers.budget_account_segment8(l_count) := x_doc_headers_rec.budget_account_segment8(i);
      l_valid_headers.budget_account_segment9(l_count) := x_doc_headers_rec.budget_account_segment9(i);
      l_valid_headers.budget_account_segment10(l_count) := x_doc_headers_rec.budget_account_segment10(i);
      l_valid_headers.budget_account_segment11(l_count) := x_doc_headers_rec.budget_account_segment11(i);
      l_valid_headers.budget_account_segment12(l_count) := x_doc_headers_rec.budget_account_segment12(i);
      l_valid_headers.budget_account_segment13(l_count) := x_doc_headers_rec.budget_account_segment13(i);
      l_valid_headers.budget_account_segment14(l_count) := x_doc_headers_rec.budget_account_segment14(i);
      l_valid_headers.budget_account_segment15(l_count) := x_doc_headers_rec.budget_account_segment15(i);
      l_valid_headers.budget_account_segment16(l_count) := x_doc_headers_rec.budget_account_segment16(i);
      l_valid_headers.budget_account_segment17(l_count) := x_doc_headers_rec.budget_account_segment17(i);
      l_valid_headers.budget_account_segment18(l_count) := x_doc_headers_rec.budget_account_segment18(i);
      l_valid_headers.budget_account_segment19(l_count) := x_doc_headers_rec.budget_account_segment19(i);
      l_valid_headers.budget_account_segment20(l_count) := x_doc_headers_rec.budget_account_segment20(i);
      l_valid_headers.budget_account_segment21(l_count) := x_doc_headers_rec.budget_account_segment21(i);
      l_valid_headers.budget_account_segment22(l_count) := x_doc_headers_rec.budget_account_segment22(i);
      l_valid_headers.budget_account_segment23(l_count) := x_doc_headers_rec.budget_account_segment23(i);
      l_valid_headers.budget_account_segment24(l_count) := x_doc_headers_rec.budget_account_segment24(i);
      l_valid_headers.budget_account_segment25(l_count) := x_doc_headers_rec.budget_account_segment25(i);
      l_valid_headers.budget_account_segment26(l_count) := x_doc_headers_rec.budget_account_segment26(i);
      l_valid_headers.budget_account_segment27(l_count) := x_doc_headers_rec.budget_account_segment27(i);
      l_valid_headers.budget_account_segment28(l_count) := x_doc_headers_rec.budget_account_segment28(i);
      l_valid_headers.budget_account_segment29(l_count) := x_doc_headers_rec.budget_account_segment29(i);
      l_valid_headers.budget_account_segment30(l_count) := x_doc_headers_rec.budget_account_segment30(i);
      l_valid_headers.budget_account(l_count) := x_doc_headers_rec.budget_account(i);
      l_valid_headers.budget_account_id(l_count) := x_doc_headers_rec.budget_account_id(i);
      l_progress := '069';
      l_valid_headers.gl_encumbered_date(l_count) := x_doc_headers_rec.gl_encumbered_date(i);
      l_valid_headers.gl_encumbered_period_name(l_count) := x_doc_headers_rec.gl_encumbered_period_name(i);
      l_valid_headers.style_id(l_count) := x_doc_headers_rec.style_id(i);
      l_valid_headers.draft_id(l_count) := x_doc_headers_rec.draft_id(i);
      l_valid_headers.processing_id(l_count) := x_doc_headers_rec.processing_id(i);
      l_valid_headers.processing_round_num(l_count) := x_doc_headers_rec.processing_round_num(i);
      l_valid_headers.original_po_header_id(l_count) := x_doc_headers_rec.original_po_header_id(i);
      l_valid_headers.created_language(l_count) := x_doc_headers_rec.created_language(i);
      l_valid_headers.cpa_reference(l_count) := x_doc_headers_rec.cpa_reference(i);
      l_progress := '269';
    END IF;
  END LOOP;

  l_progress := '070';
  -- SQL What: Insert Rows that do not have errors, and where action
  --           is PO_R12_CAT_UPG_PVT.g_action_header_create
  -- SQL Why : To migrate data to txn tables
  -- SQL Join: none
  FORALL i IN 1 .. l_valid_headers.po_header_id.COUNT
    INSERT INTO po_headers_all POH
                         (po_header_id,
                          agent_id,
                          type_lookup_code,
                          last_update_date,
                          last_updated_by,
                          segment1,
                          summary_flag,
                          enabled_flag,
                          segment2,
                          segment3,
                          segment4,
                          segment5,
                          start_date_active,
                          end_date_active,
                          last_update_login,
                          creation_date,
                          created_by,
                          vendor_id,
                          vendor_site_id,
                          vendor_contact_id,
                          ship_to_location_id,
                          bill_to_location_id,
                          terms_id,
                          ship_via_lookup_code,
                          fob_lookup_code,
                          freight_terms_lookup_code,
                          status_lookup_code,
                          currency_code,
                          rate_type,
                          rate_date,
                          rate,
                          from_header_id,
                          from_type_lookup_code,
                          start_date,
                          end_date,
                          blanket_total_amount,
                          authorization_status,
                          revision_num,
                          revised_date,
                          approved_flag,
                          approved_date,
                          amount_limit,
                          min_release_amount,
                          note_to_authorizer,
                          note_to_vendor,
                          note_to_receiver,
                          print_count,
                          printed_date,
                          vendor_order_num,
                          confirming_order_flag,
                          comments,
                          reply_date,
                          reply_method_lookup_code,
                          rfq_close_date,
                          quote_type_lookup_code,
                          quotation_class_code,
                          quote_warning_delay_unit,
                          quote_warning_delay,
                          quote_vendor_quote_number,
                          acceptance_required_flag,
                          acceptance_due_date,
                          closed_date,
                          user_hold_flag,
                          approval_required_flag,
                          cancel_flag,
                          firm_status_lookup_code,
                          firm_date,
                          frozen_flag,
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
                          closed_code,
                          ussgl_transaction_code,
                          government_context,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          org_id,
                          supply_agreement_flag,
                          edi_processed_flag,
                          edi_processed_status,
                          global_attribute_category,
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
                          interface_source_code,
                          reference_num,
                          wf_item_type,
                          wf_item_key,
                          mrc_rate_type,
                          mrc_rate_date,
                          mrc_rate,
                          pcard_id,
                          price_update_tolerance,
                          pay_on_code,
                          xml_flag,
                          xml_send_date,
                          xml_change_send_date,
                          global_agreement_flag,
                          consigned_consumption_flag,
                          cbc_accounting_date,
                          consume_req_demand_flag,
                          change_requested_by,
                          --shipping_control,
                          --conterms_exist_flag, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --conterms_articles_upd_date, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --conterms_deliv_upd_date, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --encumbrance_required_flag, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --pending_signature_flag, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --change_summary, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --document_creation_method, TODO: Not present in 11.5.9. For 11.5.10, default CATALOG_MIGRATION (Open issue)
                          --submit_date, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --supplier_notif_method, Not present in 11.5.9, 11.5.10
                          --fax, Not present in 11.5.9, 11.5.10
                          --email_address, Not present in 11.5.9, 11.5.10
                          --retro_price_comm_updates_flag, Not present in 11.5.9, 11.5.10
                          --retro_price_apply_updates_flag, Not present in 11.5.9, 11.5.10
                          --update_sourcing_rules_flag, Not present in 11.5.9, 11.5.10
                          --auto_sourcing_flag, Not present in 11.5.9, 11.5.10
                          created_language,
                          cpa_reference,
                          last_updated_program
                          /*PO_UC12*/
                          , style_id
                          /*/PO_UC12*/
                          --supplier_auth_enabled_flag
                         )
    VALUES
    (
      l_valid_headers.po_header_id(i),
      l_valid_headers.agent_id(i),
      'BLANKET',
      sysdate, -- last_update_date
      FND_GLOBAL.user_id, -- last_updated_by
      PO_R12_CAT_UPG_FINAL_GRP.get_next_po_number(l_valid_headers.org_id(i)),
      'N', -- summary_flag (Key flexfield related, for future use)
      'Y', -- enabled_flag (Key flexfield related, for future use)
      NULL, -- segment2,
      NULL, -- segment3,
      NULL, -- segment4,
      NULL, -- segment5,
      NULL, -- start_date_active (Key Flexfield start date)
      NULL, -- end_date_active (Key Flexfield start date)
      FND_GLOBAL.login_id, -- last_update_login
      sysdate, -- creation_date
      g_R12_UPGRADE_USER, -- created_by = -12
      l_valid_headers.vendor_id(i),
      l_valid_headers.vendor_site_id(i),
      l_valid_headers.vendor_contact_id(i),
      l_valid_headers.ship_to_location_id(i),
      l_valid_headers.bill_to_location_id(i),
      l_valid_headers.terms_id(i),
      l_valid_headers.freight_carrier(i), -- ship_via_lookup_code
      l_valid_headers.fob(i),
      l_valid_headers.freight_terms(i),
      NULL, -- status_lookup_code (Only used for Quotations)
      l_valid_headers.currency_code(i),
      l_valid_headers.rate_type_code(i),
      l_valid_headers.rate_date(i),
      l_valid_headers.rate(i),
      NULL, -- from_header_id,
      NULL, -- from_type_lookup_code,
      l_valid_headers.effective_date(i), -- start_date
      l_valid_headers.expiration_date(i), -- end_date
      l_valid_headers.amount_agreed(i), -- blanket_total_amount
      'IN PROCESS', -- authorization_status
      0, -- revision_num
      sysdate, -- revised_date
      'N', -- approved_flag
      NULL, -- approved_date
      l_valid_headers.amount_limit(i),
      l_valid_headers.min_release_amount(i),
      NULL, -- note_to_authorizer
      NULL, -- note_to_vendor
      NULL, -- note_to_receiver
      0, -- print_count
      NULL, -- printed_date
      NULL, -- vendor_order_num
      'N', -- confirming_order_flag
      l_valid_headers.comments(i), -- comments
      NULL, -- reply_date
      NULL, -- reply_method_lookup_code
      NULL, -- rfq_close_date
      NULL, -- quote_type_lookup_code
      NULL, -- quotation_class_code
      NULL, -- quote_warning_delay_unit
      NULL, -- quote_warning_delay
      NULL, -- quote_vendor_quote_number
      'N', -- acceptance_required_flag
      NULL, -- acceptance_due_date
      NULL, -- closed_date
      NULL, -- user_hold_flag
      NULL, -- approval_required_flag
      'N', -- cancel_flag
      'N', -- firm_status_lookup_code
      NULL, -- firm_date
      'N', -- frozen_flag
      NULL, -- attribute_category
      NULL, -- attribute1
      NULL, -- attribute2
      NULL, -- attribute3
      NULL, -- attribute4
      NULL, -- attribute5
      NULL, -- attribute6
      NULL, -- attribute7
      NULL, -- attribute8
      NULL, -- attribute9
      NULL, -- attribute10
      NULL, -- attribute11
      NULL, -- attribute12
      NULL, -- attribute13
      NULL, -- attribute14
      NULL, -- attribute15
      NULL, -- closed_code
      NULL, -- ussgl_transaction_code
      NULL, -- government_context
      NULL, -- request_id
      NULL, -- program_application_id
      NULL, -- program_id
      NULL, -- program_update_date
      l_valid_headers.org_id(i),
      'N', -- supply_agreement_flag
      NULL, -- edi_processed_flag
      NULL, -- edi_processed_status
      NULL, -- global_attribute_category
      NULL, -- global_attribute1
      NULL, -- global_attribute2
      NULL, -- global_attribute3
      NULL, -- global_attribute4
      NULL, -- global_attribute5
      NULL, -- global_attribute6
      NULL, -- global_attribute7
      NULL, -- global_attribute8
      NULL, -- global_attribute9
      NULL, -- global_attribute10
      NULL, -- global_attribute11
      NULL, -- global_attribute12
      NULL, -- global_attribute13
      NULL, -- global_attribute14
      NULL, -- global_attribute15
      NULL, -- global_attribute16
      NULL, -- global_attribute17
      NULL, -- global_attribute18
      NULL, -- global_attribute19
      NULL, -- global_attribute20
      NULL, -- interface_source_code
      NULL, -- reference_num
      NULL, -- wf_item_type
      NULL, -- wf_item_key
      NULL, -- mrc_rate_type
      NULL, -- mrc_rate_date
      NULL, -- mrc_rate
      NULL, -- pcard_id
      NULL, -- price_update_tolerance
      l_valid_headers.pay_on_code(i),
      NULL, -- xml_flag,
      NULL, -- xml_send_date,
      NULL, -- xml_change_send_date,
      'Y', -- global_agreement_flag,
      NULL, -- consigned_consumption_flag,
      NULL, -- cbc_accounting_date,
      NULL, -- consume_req_demand_flag,
      NULL, -- change_requested_by,
      --l_valid_headers.shipping_control(i),
      --NULL, -- conterms_exist_flag,
      --NULL, -- conterms_articles_upd_date,
      --NULL, -- conterms_deliv_upd_date,
      --NULL, -- encumbrance_required_flag,
      --NULL, -- pending_signature_flag,
      --NULL, -- change_summary,
      --NULL, -- document_creation_method, TODO: Not present in 11.5.9. For 11.5.10, default CATALOG_MIGRATION
      --NULL, -- submit_date, TODO: Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- supplier_notif_method, -- Not present in 11.5.9, 11.5.10
      --NULL, -- fax, -- Not present in 11.5.9, 11.5.10
      --NULL, -- email_address, -- Not present in 11.5.9, 11.5.10
      --NULL, -- retro_price_comm_updates_flag, -- Not present in 11.5.9, 11.5.10
      --NULL, -- retro_price_apply_updates_flag, -- Not present in 11.5.9, 11.5.10
      --NULL, -- update_sourcing_rules_flag, -- Not present in 11.5.9, 11.5.10
      --NULL, -- auto_sourcing_flag, -- Not present in 11.5.9, 11.5.10
      l_valid_headers.created_language(i),
      l_valid_headers.cpa_reference(i),
      g_R12_MIGRATION_PROGRAM -- last_updated_program,
      /*PO_UC12*/
      , 1 -- style_id
      /*/PO_UC12*/
      --NULL, -- supplier_auth_enabled_flag  -- Not present in 11.5.9, 11.5.10
    );

  l_progress := '080';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of txn headers inserted='||SQL%rowcount); END IF;


  manage_copy_cpa
  (
    p_valid_po_hdr_ids            => l_valid_headers.po_header_id
  , p_valid_intf_hdr_ids          => l_valid_headers.interface_header_id
  , p_valid_cpa_references        => l_valid_headers.cpa_reference
  , p_valid_org_ids               => l_valid_headers.org_id
  , p_valid_vndr_site_ids         => l_valid_headers.vendor_site_id
  , x_doc_headers_rec             => x_doc_headers_rec
  , x_remaining_val_po_hdr_ids    => l_remaining_val_po_hdr_ids
  , x_remaining_val_intf_hdr_ids  => l_remaining_val_intf_hdr_ids
  , x_remaining_val_vndr_site_ids => l_remaining_val_vndr_site_ids
  );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'After manage_copy_cpa(), l_remaining_val_po_hdr_ids.COUNT='||l_remaining_val_po_hdr_ids.COUNT); END IF;

  -- SQL What: For each GBPA Header inserted above, insert the default
  --           Org Assignments Row.
  -- SQL Why : To migrate data to txn tables
  -- SQL Join: none
  FORALL i IN 1 .. l_remaining_val_po_hdr_ids.COUNT
    INSERT INTO PO_GA_ORG_ASSIGNMENTS(
                                      /*PO_UC12*/
                                      org_assignment_id,
                                      /*/PO_UC12*/
                                      po_header_id,
                                      organization_id,
                                      --delete_flag,
                                      --change_acceptance_flag,
                                      enabled_flag,
                                      vendor_site_id,
                                      purchasing_org_id,
                                      last_update_date,
                                      last_updated_by,
                                      last_update_login,
                                      creation_date,
                                      created_by)
    VALUES(
           /*PO_UC12*/
           PO_GA_ORG_ASSIGNMENTS_S.nextval,
           /*/PO_UC12*/
           l_remaining_val_po_hdr_ids(i),
           g_job.org_id,
           --'N', --g_job.delete_flag,
           --'Y', --g_job.change_acceptance_flag,
           'Y',
           l_remaining_val_vndr_site_ids(i),
           g_job.org_id,
           sysdate,
           FND_GLOBAL.user_id,
           FND_GLOBAL.login_id,
           sysdate,
           g_R12_UPGRADE_USER);

  l_progress := '170';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of txn Org Assignments inserted='||SQL%rowcount); END IF;

  l_progress := '180';
  -- SQL What: Insert the PO_HEADER_ID back into Interface table for
  --           successfull header creation
  -- SQL Why : To make it available to the calling program of the migration API.
  -- SQL Join: interface_header_id
  FORALL i IN 1 .. l_remaining_val_intf_hdr_ids.COUNT
    UPDATE PO_HEADERS_INTERFACE
    SET PO_HEADER_ID = l_remaining_val_po_hdr_ids(i),
        PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_header_id = l_remaining_val_intf_hdr_ids(i);

  l_progress := '190';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of interface headers records updated with po_header_id='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END insert_doc_headers;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_doc_headers
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Updates a batch of document headers given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_headers_rec
  --  A table of plsql records containing a batch of header information for
  --  creating a new GBPA header.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_doc_headers
(
   p_doc_headers_rec IN record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_doc_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Update Rows that do not have errors, and action = 'UPDATE'

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_rec.po_header_id.COUNT='||p_doc_headers_rec.po_header_id.COUNT); END IF;

  IF (p_doc_headers_rec.po_header_id.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_rec.po_header_id(1)='||p_doc_headers_rec.po_header_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_rec.has_errors(1)='||p_doc_headers_rec.has_errors(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_headers_rec.action(1)='||p_doc_headers_rec.action(1)); END IF;
  END IF;

  -- SQL What: Update all the headers that were created by the Catalog Upgrade.
  --           For these, only the CPA_REFERENCE is allowed to be updated. The
  --           other columns, if provided in the interface tables, will be
  --           ignored - including the CREATED_LANGUAGE.
  -- SQL Why : To update the header columns
  -- SQL Join: po_header_id
  FORALL i IN 1.. p_doc_headers_rec.po_header_id.COUNT
    UPDATE po_headers_all
    SET cpa_reference = DECODE(p_doc_headers_rec.cpa_reference(i),
                               g_NULLIFY_NUM, NULL,
                               NULL, cpa_reference,
                               p_doc_headers_rec.cpa_reference(i))
    WHERE po_header_id = p_doc_headers_rec.po_header_id(i)
      AND p_doc_headers_rec.has_errors(i) = 'N'
      AND p_doc_headers_rec.action(i) = 'UPDATE';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of headers updated with CPA_REFERENCE='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Update the Headers Interface Table for process_code as 'PROCESSED'
  -- SQL What: Update the Headers Interface Table for process_code as 'PROCESSED'
  --           for all the headers that were successfully updated.
  -- SQL Why : To mark them as successfully processed
  -- SQL Join: interface_header_id
  FORALL i IN 1.. p_doc_headers_rec.po_header_id.COUNT
    UPDATE po_headers_interface
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_header_id = p_doc_headers_rec.interface_header_id(i)
      AND p_doc_headers_rec.has_errors(i) = 'N'
      AND p_doc_headers_rec.action(i) = 'UPDATE';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of interface headers PROCESSED='||SQL%rowcount); END IF;


  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_doc_headers;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: delete_doc_headers
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Deletes a batch of document headers given in a plsql table, from the transaction
  --  tables:
  --Parameters:
  --IN:
  -- p_doc_headers_rec
  --  A table of plsql records containing a batch of header information for
  --  creating a new GBPA header.
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_doc_headers
(
   p_doc_headers_rec IN record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_doc_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_return_status VARCHAR2(1);

  l_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_po_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Delete Rows that do not have errors and action = 'DELETE',
  FORALL i IN 1.. p_doc_headers_rec.po_header_id.COUNT
    DELETE FROM po_headers_all
    WHERE po_header_id = p_doc_headers_rec.po_header_id(i)
      AND p_doc_headers_rec.has_errors(i) = 'N'
      AND p_doc_headers_rec.action(i) = 'DELETE'
    RETURNING po_header_id
    BULK COLLECT INTO l_po_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of headers deleted='||SQL%rowcount); END IF;

  l_progress := '020';

  -- For each of the above GBPA Header, delete the default Org Assignments Row
  FORALL i IN 1.. l_po_header_ids.COUNT
    DELETE FROM PO_GA_ORG_ASSIGNMENTS
    WHERE po_header_id = l_po_header_ids(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Org Assignments deleted='||SQL%rowcount); END IF;

  l_progress := '030';

  -- Delete from PO Lines
  FORALL i IN 1.. l_po_header_ids.COUNT
    DELETE FROM PO_LINES_ALL
    WHERE po_header_id = l_po_header_ids(i)
    RETURNING po_line_id
    BULK COLLECT INTO l_po_line_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines deleted='||SQL%rowcount); END IF;

  l_progress := '040';

  -- Delete from Attribute tables
  FORALL i IN 1.. l_po_line_ids.COUNT
    DELETE FROM PO_ATTRIBUTE_VALUES
    WHERE PO_LINE_ID = l_po_line_ids(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Attr deleted='||SQL%rowcount); END IF;

  l_progress := '050';

  -- Delete from Attribute TLP tables
  FORALL i IN 1.. l_po_line_ids.COUNT
    DELETE FROM PO_ATTRIBUTE_VALUES_TLP
    WHERE PO_LINE_ID = l_po_line_ids(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP deleted='||SQL%rowcount); END IF;

  l_progress := '100';
  -- Mark headers interface as PROCESSED
  FORALL i IN 1.. p_doc_headers_rec.po_header_id.COUNT
    UPDATE po_headers_interface
    SET process_code = g_PROCESS_CODE_PROCESSED
    WHERE interface_header_id = p_doc_headers_rec.interface_header_id(i)
      AND p_doc_headers_rec.has_errors(i) = 'N'
      AND p_doc_headers_rec.action(i) = 'DELETE';

  l_progress := '110';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Headers Interface records PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END delete_doc_headers;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: migrate_document_lines
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the document lines for GBPA/BPA/Quotations.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_document_lines
(
   p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_document_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to load lines
  -- SQL Why : To migrate data to PO txn tables
  -- SQL Join: processing_id, action
  CURSOR load_lines_csr(request_processing_id NUMBER) IS
    SELECT lines.interface_line_id,
           lines.interface_header_id,
           lines.action,
           lines.group_code,
           lines.line_num,
           lines.po_line_id,
           lines.shipment_num,
           lines.line_location_id,
           lines.shipment_type,
           lines.requisition_line_id,
           lines.document_num,
           lines.release_num,
           lines.po_header_id,
           lines.po_release_id,
           lines.source_shipment_id,
           lines.contract_num,
           lines.line_type,
           lines.line_type_id,
           lines.item,
           lines.item_id,
           lines.item_revision,
           lines.category,
           lines.category_id,
           lines.item_description,
           lines.vendor_product_num,
           lines.uom_code,
           lines.unit_of_measure,
           lines.quantity,
           lines.committed_amount,
           lines.min_order_quantity,
           lines.max_order_quantity,
           lines.unit_price,
           lines.list_price_per_unit,
           lines.market_price,
           lines.allow_price_override_flag,
           lines.not_to_exceed_price,
           lines.negotiated_by_preparer_flag,
           lines.un_number,
           lines.un_number_id,
           lines.hazard_class,
           lines.hazard_class_id,
           lines.note_to_vendor,
           lines.transaction_reason_code,
           lines.taxable_flag,
           lines.tax_name,
           lines.type_1099,
           lines.capital_expense_flag,
           lines.inspection_required_flag,
           lines.receipt_required_flag,
           lines.payment_terms,
           lines.terms_id,
           lines.price_type,
           lines.min_release_amount,
           lines.price_break_lookup_code,
           lines.ussgl_transaction_code,
           lines.closed_code,
           lines.closed_reason,
           lines.closed_date,
           lines.closed_by,
           lines.invoice_close_tolerance,
           lines.receive_close_tolerance,
           lines.firm_flag,
           lines.days_early_receipt_allowed,
           lines.days_late_receipt_allowed,
           lines.enforce_ship_to_location_code,
           lines.allow_substitute_receipts_flag,
           lines.receiving_routing,
           lines.receiving_routing_id,
           lines.qty_rcv_tolerance,
           lines.over_tolerance_error_flag,
           lines.qty_rcv_exception_code,
           lines.receipt_days_exception_code,
           lines.ship_to_organization_code,
           lines.ship_to_organization_id,
           lines.ship_to_location,
           lines.ship_to_location_id,
           lines.need_by_date,
           lines.promised_date,
           lines.accrue_on_receipt_flag,
           lines.lead_time,
           lines.lead_time_unit,
           lines.price_discount,
           lines.freight_carrier,
           lines.fob,
           lines.freight_terms,
           lines.effective_date,
           lines.expiration_date,
           lines.from_header_id,
           lines.from_line_id,
           lines.from_line_location_id,
           lines.line_attribute_category_lines,
           lines.line_attribute1,
           lines.line_attribute2,
           lines.line_attribute3,
           lines.line_attribute4,
           lines.line_attribute5,
           lines.line_attribute6,
           lines.line_attribute7,
           lines.line_attribute8,
           lines.line_attribute9,
           lines.line_attribute10,
           lines.line_attribute11,
           lines.line_attribute12,
           lines.line_attribute13,
           lines.line_attribute14,
           lines.line_attribute15,
           lines.shipment_attribute_category,
           lines.shipment_attribute1,
           lines.shipment_attribute2,
           lines.shipment_attribute3,
           lines.shipment_attribute4,
           lines.shipment_attribute5,
           lines.shipment_attribute6,
           lines.shipment_attribute7,
           lines.shipment_attribute8,
           lines.shipment_attribute9,
           lines.shipment_attribute10,
           lines.shipment_attribute11,
           lines.shipment_attribute12,
           lines.shipment_attribute13,
           lines.shipment_attribute14,
           lines.shipment_attribute15,
           lines.last_update_date,
           lines.last_updated_by,
           lines.last_update_login,
           lines.creation_date,
           lines.created_by,
           lines.request_id,
           lines.program_application_id,
           lines.program_id,
           lines.program_update_date,
           lines.invoice_close_tolerance,
           lines.organization_id,
           lines.item_attribute_category,
           lines.item_attribute1,
           lines.item_attribute2,
           lines.item_attribute3,
           lines.item_attribute4,
           lines.item_attribute5,
           lines.item_attribute6,
           lines.item_attribute7,
           lines.item_attribute8,
           lines.item_attribute9,
           lines.item_attribute10,
           lines.item_attribute11,
           lines.item_attribute12,
           lines.item_attribute13,
           lines.item_attribute14,
           lines.item_attribute15,
           lines.unit_weight,
           lines.weight_uom_code,
           lines.volume_uom_code,
           lines.unit_volume,
           lines.template_id,
           lines.template_name,
           lines.line_reference_num,
           lines.sourcing_rule_name,
           lines.tax_status_indicator,
           lines.process_code,
           lines.price_chg_accept_flag,
           lines.price_break_flag,
           lines.price_update_tolerance,
           lines.tax_user_override_flag,
           lines.tax_code_id,
           lines.note_to_receiver,
           lines.oke_contract_header_id,
           lines.oke_contract_header_num,
           lines.oke_contract_version_id,
           lines.secondary_unit_of_measure,
           lines.secondary_uom_code,
           lines.secondary_quantity,
           lines.preferred_grade,
           lines.vmi_flag,
           lines.auction_header_id,
           lines.auction_line_number,
           lines.auction_display_number,
           lines.bid_number,
           lines.bid_line_number,
           lines.orig_from_req_flag,
           lines.consigned_flag,
           NULL, --lines.supplier_ref_number, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.contract_id, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.job_id, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.amount, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.job_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.contractor_first_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.contractor_last_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.drop_ship_flag, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.base_unit_price, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.transaction_flow_header_id, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.job_business_group_id, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.job_business_group_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.tracking_quantity_ind, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.secondary_default_ind, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.dual_uom_deviation_high, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           NULL, --lines.dual_uom_deviation_low, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           lines.processing_id,
           NULL, --lines.line_loc_populated_flag, TODO: Not present in 11.5.9. For 11.5.10, default NULL
           lines.catalog_name,
           lines.supplier_part_auxid,
           lines.ip_category_id,
           NULL, --lines.ip_category_name
           'N',  -- has_errors
           NULL, -- org_id: Not present in interface tables. Just initialize the collection
           NULL, -- order_type_lookup_code: Not present in interface tables. Just initialize the collection
           NULL, -- purchase_basis: Not present in interface tables. Just initialize the collection
           NULL  -- matching_basis: Not present in interface tables. Just initialize the collection
    FROM   po_lines_interface lines
    WHERE  lines.processing_id = request_processing_id
    AND    lines.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW
    AND    lines.action IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE', 'DELETE');

  l_doc_lines_table record_of_lines_type;
  l_err_interface_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_count NUMBER := NULL;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Algorithm:
  -- 1. Load Lines batch (batch_size) into pl/sql table.
  -- 2. Call PDOI modules to process data in batches (default, derive, validate).
  -- 3. Get the validated pl/sql table for the batch from PDOI.
  -- 4. Transfer directly to Transaction tables

  OPEN load_lines_csr(g_processing_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      FETCH load_lines_csr BULK COLLECT INTO
        l_doc_lines_table.interface_line_id,
        l_doc_lines_table.interface_header_id,
        l_doc_lines_table.action,
        l_doc_lines_table.group_code,
        l_doc_lines_table.line_num,
        l_doc_lines_table.po_line_id,
        l_doc_lines_table.shipment_num,
        l_doc_lines_table.line_location_id,
        l_doc_lines_table.shipment_type,
        l_doc_lines_table.requisition_line_id,
        l_doc_lines_table.document_num,
        l_doc_lines_table.release_num,
        l_doc_lines_table.po_header_id,
        l_doc_lines_table.po_release_id,
        l_doc_lines_table.source_shipment_id,
        l_doc_lines_table.contract_num,
        l_doc_lines_table.line_type,
        l_doc_lines_table.line_type_id,
        l_doc_lines_table.item,
        l_doc_lines_table.item_id,
        l_doc_lines_table.item_revision,
        l_doc_lines_table.category,
        l_doc_lines_table.category_id,
        l_doc_lines_table.item_description,
        l_doc_lines_table.vendor_product_num,
        l_doc_lines_table.uom_code,
        l_doc_lines_table.unit_of_measure,
        l_doc_lines_table.quantity,
        l_doc_lines_table.committed_amount,
        l_doc_lines_table.min_order_quantity,
        l_doc_lines_table.max_order_quantity,
        l_doc_lines_table.unit_price,
        l_doc_lines_table.list_price_per_unit,
        l_doc_lines_table.market_price,
        l_doc_lines_table.allow_price_override_flag,
        l_doc_lines_table.not_to_exceed_price,
        l_doc_lines_table.negotiated_by_preparer_flag,
        l_doc_lines_table.un_number,
        l_doc_lines_table.un_number_id,
        l_doc_lines_table.hazard_class,
        l_doc_lines_table.hazard_class_id,
        l_doc_lines_table.note_to_vendor,
        l_doc_lines_table.transaction_reason_code,
        l_doc_lines_table.taxable_flag,
        l_doc_lines_table.tax_name,
        l_doc_lines_table.type_1099,
        l_doc_lines_table.capital_expense_flag,
        l_doc_lines_table.inspection_required_flag,
        l_doc_lines_table.receipt_required_flag,
        l_doc_lines_table.payment_terms,
        l_doc_lines_table.terms_id,
        l_doc_lines_table.price_type,
        l_doc_lines_table.min_release_amount,
        l_doc_lines_table.price_break_lookup_code,
        l_doc_lines_table.ussgl_transaction_code,
        l_doc_lines_table.closed_code,
        l_doc_lines_table.closed_reason,
        l_doc_lines_table.closed_date,
        l_doc_lines_table.closed_by,
        l_doc_lines_table.invoice_close_tolerance,
        l_doc_lines_table.receive_close_tolerance,
        l_doc_lines_table.firm_flag,
        l_doc_lines_table.days_early_receipt_allowed,
        l_doc_lines_table.days_late_receipt_allowed,
        l_doc_lines_table.enforce_ship_to_location_code,
        l_doc_lines_table.allow_substitute_receipts_flag,
        l_doc_lines_table.receiving_routing,
        l_doc_lines_table.receiving_routing_id,
        l_doc_lines_table.qty_rcv_tolerance,
        l_doc_lines_table.over_tolerance_error_flag,
        l_doc_lines_table.qty_rcv_exception_code,
        l_doc_lines_table.receipt_days_exception_code,
        l_doc_lines_table.ship_to_organization_code,
        l_doc_lines_table.ship_to_organization_id,
        l_doc_lines_table.ship_to_location,
        l_doc_lines_table.ship_to_location_id,
        l_doc_lines_table.need_by_date,
        l_doc_lines_table.promised_date,
        l_doc_lines_table.accrue_on_receipt_flag,
        l_doc_lines_table.lead_time,
        l_doc_lines_table.lead_time_unit,
        l_doc_lines_table.price_discount,
        l_doc_lines_table.freight_carrier,
        l_doc_lines_table.fob,
        l_doc_lines_table.freight_terms,
        l_doc_lines_table.effective_date,
        l_doc_lines_table.expiration_date,
        l_doc_lines_table.from_header_id,
        l_doc_lines_table.from_line_id,
        l_doc_lines_table.from_line_location_id,
        l_doc_lines_table.line_attribute_category_lines,
        l_doc_lines_table.line_attribute1,
        l_doc_lines_table.line_attribute2,
        l_doc_lines_table.line_attribute3,
        l_doc_lines_table.line_attribute4,
        l_doc_lines_table.line_attribute5,
        l_doc_lines_table.line_attribute6,
        l_doc_lines_table.line_attribute7,
        l_doc_lines_table.line_attribute8,
        l_doc_lines_table.line_attribute9,
        l_doc_lines_table.line_attribute10,
        l_doc_lines_table.line_attribute11,
        l_doc_lines_table.line_attribute12,
        l_doc_lines_table.line_attribute13,
        l_doc_lines_table.line_attribute14,
        l_doc_lines_table.line_attribute15,
        l_doc_lines_table.shipment_attribute_category,
        l_doc_lines_table.shipment_attribute1,
        l_doc_lines_table.shipment_attribute2,
        l_doc_lines_table.shipment_attribute3,
        l_doc_lines_table.shipment_attribute4,
        l_doc_lines_table.shipment_attribute5,
        l_doc_lines_table.shipment_attribute6,
        l_doc_lines_table.shipment_attribute7,
        l_doc_lines_table.shipment_attribute8,
        l_doc_lines_table.shipment_attribute9,
        l_doc_lines_table.shipment_attribute10,
        l_doc_lines_table.shipment_attribute11,
        l_doc_lines_table.shipment_attribute12,
        l_doc_lines_table.shipment_attribute13,
        l_doc_lines_table.shipment_attribute14,
        l_doc_lines_table.shipment_attribute15,
        l_doc_lines_table.last_update_date,
        l_doc_lines_table.last_updated_by,
        l_doc_lines_table.last_update_login,
        l_doc_lines_table.creation_date,
        l_doc_lines_table.created_by,
        l_doc_lines_table.request_id,
        l_doc_lines_table.program_application_id,
        l_doc_lines_table.program_id,
        l_doc_lines_table.program_update_date,
        l_doc_lines_table.invoice_close_tolerance,
        l_doc_lines_table.organization_id,
        l_doc_lines_table.item_attribute_category,
        l_doc_lines_table.item_attribute1,
        l_doc_lines_table.item_attribute2,
        l_doc_lines_table.item_attribute3,
        l_doc_lines_table.item_attribute4,
        l_doc_lines_table.item_attribute5,
        l_doc_lines_table.item_attribute6,
        l_doc_lines_table.item_attribute7,
        l_doc_lines_table.item_attribute8,
        l_doc_lines_table.item_attribute9,
        l_doc_lines_table.item_attribute10,
        l_doc_lines_table.item_attribute11,
        l_doc_lines_table.item_attribute12,
        l_doc_lines_table.item_attribute13,
        l_doc_lines_table.item_attribute14,
        l_doc_lines_table.item_attribute15,
        l_doc_lines_table.unit_weight,
        l_doc_lines_table.weight_uom_code,
        l_doc_lines_table.volume_uom_code,
        l_doc_lines_table.unit_volume,
        l_doc_lines_table.template_id,
        l_doc_lines_table.template_name,
        l_doc_lines_table.line_reference_num,
        l_doc_lines_table.sourcing_rule_name,
        l_doc_lines_table.tax_status_indicator,
        l_doc_lines_table.process_code,
        l_doc_lines_table.price_chg_accept_flag,
        l_doc_lines_table.price_break_flag,
        l_doc_lines_table.price_update_tolerance,
        l_doc_lines_table.tax_user_override_flag,
        l_doc_lines_table.tax_code_id,
        l_doc_lines_table.note_to_receiver,
        l_doc_lines_table.oke_contract_header_id,
        l_doc_lines_table.oke_contract_header_num,
        l_doc_lines_table.oke_contract_version_id,
        l_doc_lines_table.secondary_unit_of_measure,
        l_doc_lines_table.secondary_uom_code,
        l_doc_lines_table.secondary_quantity,
        l_doc_lines_table.preferred_grade,
        l_doc_lines_table.vmi_flag,
        l_doc_lines_table.auction_header_id,
        l_doc_lines_table.auction_line_number,
        l_doc_lines_table.auction_display_number,
        l_doc_lines_table.bid_number,
        l_doc_lines_table.bid_line_number,
        l_doc_lines_table.orig_from_req_flag,
        l_doc_lines_table.consigned_flag,
        l_doc_lines_table.supplier_ref_number,
        l_doc_lines_table.contract_id,
        l_doc_lines_table.job_id,
        l_doc_lines_table.amount,
        l_doc_lines_table.job_name,
        l_doc_lines_table.contractor_first_name,
        l_doc_lines_table.contractor_last_name,
        l_doc_lines_table.drop_ship_flag,
        l_doc_lines_table.base_unit_price,
        l_doc_lines_table.transaction_flow_header_id,
        l_doc_lines_table.job_business_group_id,
        l_doc_lines_table.job_business_group_name,
        l_doc_lines_table.tracking_quantity_ind,
        l_doc_lines_table.secondary_default_ind,
        l_doc_lines_table.dual_uom_deviation_high,
        l_doc_lines_table.dual_uom_deviation_low,
        l_doc_lines_table.processing_id,
        l_doc_lines_table.line_loc_populated_flag,
        l_doc_lines_table.catalog_name,
        l_doc_lines_table.supplier_part_auxid,
        l_doc_lines_table.ip_category_id,
        l_doc_lines_table.ip_category_name,
        l_doc_lines_table.has_errors,
        l_doc_lines_table.org_id,
        l_doc_lines_table.order_type_lookup_code,
        l_doc_lines_table.purchase_basis,
        l_doc_lines_table.matching_basis
      LIMIT g_job.batch_size;

      l_progress := '030';

     IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_doc_lines_table.interface_line_id.COUNT='||l_doc_lines_table.interface_line_id.COUNT); END IF;

      EXIT WHEN l_doc_lines_table.interface_line_id.COUNT = 0;

      l_progress := '040';
      -- derive logic
      --PO_PROCESS_LINES_PVT.derive_lines(l_doc_lines_table);

      l_progress := '050';
      -- default logic
      PO_R12_CAT_UPG_DEF_PVT.default_lines(l_doc_lines_table);

      l_progress := '060';
      -- validate logic
      PO_R12_CAT_UPG_VAL_PVT.validate_lines(l_doc_lines_table);

      l_progress := '070';
      -- Skip transfer if running in Validate Only mode.
      IF (p_validate_only_mode = FND_API.G_FALSE) THEN
        -- Transfer Lines
        transfer_doc_lines(p_doc_lines_rec => l_doc_lines_table);

        l_progress := '080';
        -- cascade rejected status to attribute and other levels
        l_count := 0;
        FOR i IN 1..l_doc_lines_table.interface_line_id.COUNT
        LOOP
          IF (l_doc_lines_table.has_errors(i) = 'Y') THEN
            l_count := l_count + 1;
            l_err_interface_line_ids(l_count) := l_doc_lines_table.interface_line_id(i);
          END IF;
        END LOOP;

        l_progress := '090';
        IF (l_count > 0) THEN
          PO_R12_CAT_UPG_UTL.reject_lines_intf('INTERFACE_LINE_ID',
                                               l_err_interface_line_ids,
                                               FND_API.G_TRUE);
        END IF;

      END IF; -- IF (p_validate_only_mode = FND_API.G_FALSE)

      l_progress := '100';
      COMMIT;

      -- Call IP's API to update the line ID in IP's tables
      update_ip_tables_line
      (
        p_doc_lines_table => l_doc_lines_table
      );

      l_progress := '110';
      IF (l_doc_lines_table.interface_line_id.COUNT
                < g_job.batch_size) THEN
        EXIT;
      END IF;
      l_progress := '120';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_lines_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '130';
        COMMIT;

        l_progress := '140';
        CLOSE load_lines_csr;

        l_progress := '150';
        OPEN load_lines_csr(g_processing_id);
        l_progress := '160';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP;

  l_progress := '170';
  IF (load_lines_csr%ISOPEN) THEN
    CLOSE load_lines_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_lines_csr%ISOPEN) THEN
      CLOSE load_lines_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END migrate_document_lines;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: transfer_doc_lines
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Transfers a batch of document lines given in a plsql table, into the
  --  transaction tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of line information for
  --  creating a new line.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE transfer_doc_lines
(
   p_doc_lines_rec    IN record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'transfer_doc_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Insert Lines
  insert_doc_lines(p_doc_lines_rec => p_doc_lines_rec);

  l_progress := '020';
  -- Update Lines
  update_doc_lines(p_doc_lines_rec => p_doc_lines_rec);

  l_progress := '030';
  -- Delete Lines
  delete_doc_lines(p_doc_lines_rec => p_doc_lines_rec);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END transfer_doc_lines;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: get_hdr_process_code_list
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Inserts a batch of document lines given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of line information for
  --  creating a new GBPA line.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_hdr_process_code_list
(
  p_doc_lines_rec     IN record_of_lines_type
, x_process_code_list IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_hdr_process_code_list';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_process_code_list    PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_index                NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF (p_doc_lines_rec.interface_line_id IS NULL OR
      p_doc_lines_rec.interface_line_id.COUNT = 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Early return because there are no records to process.'); END IF;
    RETURN;
  END IF;

  -- pick a new key from temp table which will be used in all validate logic
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_doc_lines_rec.interface_line_id.COUNT);

  -- Check if the header had any errors. If yes, we need to skip the insert of the line
  l_progress := '030';
  FORALL i IN 1 .. p_doc_lines_rec.interface_line_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              char1)
    SELECT l_key,
           l_subscript_array(i),
           POHI.process_code
    FROM PO_HEADERS_INTERFACE POHI
    WHERE interface_header_id = p_doc_lines_rec.interface_header_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to get the process_codes
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = l_key
  RETURNING num1, char1
  BULK COLLECT INTO l_indexes, l_process_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  -- Rearrange the indexes properly
  l_progress := '050';
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    x_process_code_list(i) := NULL;
  END LOOP;

  l_progress := '060';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_process_code_list(l_index) := l_process_code_list(i);
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_process_code_list(1)='||x_process_code_list(1)); END IF;

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_hdr_process_code_list;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: insert_doc_lines
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Inserts a batch of document lines given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of line information for
  --  creating a new GBPA line.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_doc_lines
(
  p_doc_lines_rec IN record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_doc_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_max_po_line_num PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_valid_lines record_of_lines_type;
  l_count NUMBER;
  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;
  l_process_code_list    PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  get_hdr_process_code_list
  (
    p_doc_lines_rec     => p_doc_lines_rec
  , x_process_code_list => l_process_code_list
  );

  -- Get the valid rows into l_valid_headers array.
  l_count := 0;
  FOR i IN 1 .. p_doc_lines_rec.interface_line_id.COUNT
  LOOP
    l_progress := '020';

    IF (p_doc_lines_rec.has_errors(i) = 'N'
        AND l_process_code_list(i) = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_PROCESSED
        AND p_doc_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create) THEN
      l_progress := '030';

      l_count := l_count + 1;

      l_progress := '040';
      -- Get the next po_line_id from the sequence
      SELECT PO_LINES_S.nextval
      INTO l_valid_lines.po_line_id(l_count)
      FROM dual;

      l_progress := '050';
      -- Assign Line Numbers.
      -- For each PO Header, assign a value in l_max_line_num array.
      -- If an entry does not exist in the array, query the max(line_num) from
      -- the tables and assign max(line_num)+1 to l_max_line_num of that Header.
      -- If an entry already exists, then increment max_line_num.
      IF (l_max_po_line_num.exists(p_doc_lines_rec.po_header_id(i))) THEN
        l_progress := '060';
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_max_po_line_num(p_doc_lines_rec.po_header_id(i))='||l_max_po_line_num(p_doc_lines_rec.po_header_id(i))); END IF;

        l_max_po_line_num(p_doc_lines_rec.po_header_id(i)) :=
              l_max_po_line_num(p_doc_lines_rec.po_header_id(i)) + 1;
      ELSE
        l_progress := '070';
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'max_line_num for po_header_id['||p_doc_lines_rec.po_header_id(i)||'] does not exist'); END IF;

        SELECT (NVL(max(line_num), 0) + 1)
        INTO l_max_po_line_num(p_doc_lines_rec.po_header_id(i))
        FROM PO_LINES_ALL
        WHERE po_header_id = p_doc_lines_rec.po_header_id(i);

        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Queried max_line_num for po_header_id['||p_doc_lines_rec.po_header_id(i)||'] from tables='||l_max_po_line_num(p_doc_lines_rec.po_header_id(i))); END IF;
      END IF;

      l_progress := '080';
      -- Finally, copy the value of l_max_po_line_num into the structure
      l_valid_lines.line_num(l_count) := l_max_po_line_num(p_doc_lines_rec.po_header_id(i));

      l_valid_lines.interface_line_id(l_count) := p_doc_lines_rec.interface_line_id(i);
      l_valid_lines.interface_header_id(l_count) := p_doc_lines_rec.interface_header_id(i);
      l_valid_lines.action(l_count) := p_doc_lines_rec.action(i);
      l_valid_lines.group_code(l_count) := p_doc_lines_rec.group_code(i);
      l_valid_lines.shipment_num(l_count) := p_doc_lines_rec.shipment_num(i);
      l_valid_lines.line_location_id(l_count) := p_doc_lines_rec.line_location_id(i);
      l_valid_lines.shipment_type(l_count) := p_doc_lines_rec.shipment_type(i);
      l_valid_lines.requisition_line_id(l_count) := p_doc_lines_rec.requisition_line_id(i);
      l_valid_lines.document_num(l_count) := p_doc_lines_rec.document_num(i);
      l_valid_lines.release_num(l_count) := p_doc_lines_rec.release_num(i);
      l_valid_lines.po_header_id(l_count) := p_doc_lines_rec.po_header_id(i);
      l_valid_lines.po_release_id(l_count) := p_doc_lines_rec.po_release_id(i);
      l_valid_lines.source_shipment_id(l_count) := p_doc_lines_rec.source_shipment_id(i);
      l_valid_lines.contract_num(l_count) := p_doc_lines_rec.contract_num(i);
      l_valid_lines.line_type(l_count) := p_doc_lines_rec.line_type(i);
      l_valid_lines.line_type_id(l_count) := p_doc_lines_rec.line_type_id(i);
      l_valid_lines.item(l_count) := p_doc_lines_rec.item(i);
      l_valid_lines.item_id(l_count) := p_doc_lines_rec.item_id(i);
      l_valid_lines.item_revision(l_count) := p_doc_lines_rec.item_revision(i);
      l_valid_lines.category(l_count) := p_doc_lines_rec.category(i);
      l_valid_lines.category_id(l_count) := p_doc_lines_rec.category_id(i);
      l_valid_lines.item_description(l_count) := p_doc_lines_rec.item_description(i);
      l_valid_lines.vendor_product_num(l_count) := p_doc_lines_rec.vendor_product_num(i);
      l_valid_lines.uom_code(l_count) := p_doc_lines_rec.uom_code(i);
      l_valid_lines.unit_of_measure(l_count) := p_doc_lines_rec.unit_of_measure(i);
      l_valid_lines.quantity(l_count) := p_doc_lines_rec.quantity(i);
      l_valid_lines.committed_amount(l_count) := p_doc_lines_rec.committed_amount(i);
      l_valid_lines.min_order_quantity(l_count) := p_doc_lines_rec.min_order_quantity(i);
      l_valid_lines.max_order_quantity(l_count) := p_doc_lines_rec.max_order_quantity(i);
      l_valid_lines.unit_price(l_count) := p_doc_lines_rec.unit_price(i);
      l_valid_lines.list_price_per_unit(l_count) := p_doc_lines_rec.list_price_per_unit(i);
      l_valid_lines.market_price(l_count) := p_doc_lines_rec.market_price(i);
      l_valid_lines.allow_price_override_flag(l_count) := p_doc_lines_rec.allow_price_override_flag(i);
      l_valid_lines.not_to_exceed_price(l_count) := p_doc_lines_rec.not_to_exceed_price(i);
      l_valid_lines.negotiated_by_preparer_flag(l_count) := p_doc_lines_rec.negotiated_by_preparer_flag(i);
      l_valid_lines.un_number(l_count) := p_doc_lines_rec.un_number(i);
      l_valid_lines.un_number_id(l_count) := p_doc_lines_rec.un_number_id(i);
      l_valid_lines.hazard_class(l_count) := p_doc_lines_rec.hazard_class(i);
      l_valid_lines.hazard_class_id(l_count) := p_doc_lines_rec.hazard_class_id(i);
      l_valid_lines.note_to_vendor(l_count) := p_doc_lines_rec.note_to_vendor(i);
      l_valid_lines.transaction_reason_code(l_count) := p_doc_lines_rec.transaction_reason_code(i);
      l_valid_lines.taxable_flag(l_count) := p_doc_lines_rec.taxable_flag(i);
      l_valid_lines.tax_name(l_count) := p_doc_lines_rec.tax_name(i);
      l_valid_lines.type_1099(l_count) := p_doc_lines_rec.type_1099(i);
      l_valid_lines.capital_expense_flag(l_count) := p_doc_lines_rec.capital_expense_flag(i);
      l_valid_lines.inspection_required_flag(l_count) := p_doc_lines_rec.inspection_required_flag(i);
      l_valid_lines.receipt_required_flag(l_count) := p_doc_lines_rec.receipt_required_flag(i);
      l_valid_lines.payment_terms(l_count) := p_doc_lines_rec.payment_terms(i);
      l_valid_lines.terms_id(l_count) := p_doc_lines_rec.terms_id(i);
      l_valid_lines.price_type(l_count) := p_doc_lines_rec.price_type(i);
      l_valid_lines.min_release_amount(l_count) := p_doc_lines_rec.min_release_amount(i);
      l_valid_lines.price_break_lookup_code(l_count) := p_doc_lines_rec.price_break_lookup_code(i);
      l_valid_lines.ussgl_transaction_code(l_count) := p_doc_lines_rec.ussgl_transaction_code(i);
      l_valid_lines.closed_code(l_count) := p_doc_lines_rec.closed_code(i);
      l_valid_lines.closed_reason(l_count) := p_doc_lines_rec.closed_reason(i);
      l_valid_lines.closed_date(l_count) := p_doc_lines_rec.closed_date(i);
      l_valid_lines.closed_by(l_count) := p_doc_lines_rec.closed_by(i);
      l_valid_lines.invoice_close_tolerance(l_count) := p_doc_lines_rec.invoice_close_tolerance(i);
      l_valid_lines.receive_close_tolerance(l_count) := p_doc_lines_rec.receive_close_tolerance(i);
      l_valid_lines.firm_flag(l_count) := p_doc_lines_rec.firm_flag(i);
      l_valid_lines.days_early_receipt_allowed(l_count) := p_doc_lines_rec.days_early_receipt_allowed(i);
      l_valid_lines.days_late_receipt_allowed(l_count) := p_doc_lines_rec.days_late_receipt_allowed(i);
      l_valid_lines.enforce_ship_to_location_code(l_count) := p_doc_lines_rec.enforce_ship_to_location_code(i);
      l_valid_lines.allow_substitute_receipts_flag(l_count) := p_doc_lines_rec.allow_substitute_receipts_flag(i);
      l_valid_lines.receiving_routing(l_count) := p_doc_lines_rec.receiving_routing(i);
      l_valid_lines.receiving_routing_id(l_count) := p_doc_lines_rec.receiving_routing_id(i);
      l_valid_lines.qty_rcv_tolerance(l_count) := p_doc_lines_rec.qty_rcv_tolerance(i);
      l_valid_lines.over_tolerance_error_flag(l_count) := p_doc_lines_rec.over_tolerance_error_flag(i);
      l_valid_lines.qty_rcv_exception_code(l_count) := p_doc_lines_rec.qty_rcv_exception_code(i);
      l_valid_lines.receipt_days_exception_code(l_count) := p_doc_lines_rec.receipt_days_exception_code(i);
      l_valid_lines.ship_to_organization_code(l_count) := p_doc_lines_rec.ship_to_organization_code(i);
      l_valid_lines.ship_to_organization_id(l_count) := p_doc_lines_rec.ship_to_organization_id(i);
      l_valid_lines.ship_to_location(l_count) := p_doc_lines_rec.ship_to_location(i);
      l_valid_lines.ship_to_location_id(l_count) := p_doc_lines_rec.ship_to_location_id(i);
      l_valid_lines.need_by_date(l_count) := p_doc_lines_rec.need_by_date(i);
      l_valid_lines.promised_date(l_count) := p_doc_lines_rec.promised_date(i);
      l_valid_lines.accrue_on_receipt_flag(l_count) := p_doc_lines_rec.accrue_on_receipt_flag(i);
      l_valid_lines.lead_time(l_count) := p_doc_lines_rec.lead_time(i);
      l_valid_lines.lead_time_unit(l_count) := p_doc_lines_rec.lead_time_unit(i);
      l_valid_lines.price_discount(l_count) := p_doc_lines_rec.price_discount(i);
      l_valid_lines.freight_carrier(l_count) := p_doc_lines_rec.freight_carrier(i);
      l_valid_lines.fob(l_count) := p_doc_lines_rec.fob(i);
      l_valid_lines.freight_terms(l_count) := p_doc_lines_rec.freight_terms(i);
      l_valid_lines.effective_date(l_count) := p_doc_lines_rec.effective_date(i);
      l_valid_lines.expiration_date(l_count) := p_doc_lines_rec.expiration_date(i);
      l_valid_lines.from_header_id(l_count) := p_doc_lines_rec.from_header_id(i);
      l_valid_lines.from_line_id(l_count) := p_doc_lines_rec.from_line_id(i);
      l_valid_lines.from_line_location_id(l_count) := p_doc_lines_rec.from_line_location_id(i);
      l_valid_lines.line_attribute_category_lines(l_count) := p_doc_lines_rec.line_attribute_category_lines(i);
      l_valid_lines.line_attribute1(l_count) := p_doc_lines_rec.line_attribute1(i);
      l_valid_lines.line_attribute2(l_count) := p_doc_lines_rec.line_attribute2(i);
      l_valid_lines.line_attribute3(l_count) := p_doc_lines_rec.line_attribute3(i);
      l_valid_lines.line_attribute4(l_count) := p_doc_lines_rec.line_attribute4(i);
      l_valid_lines.line_attribute5(l_count) := p_doc_lines_rec.line_attribute5(i);
      l_valid_lines.line_attribute6(l_count) := p_doc_lines_rec.line_attribute6(i);
      l_valid_lines.line_attribute7(l_count) := p_doc_lines_rec.line_attribute7(i);
      l_valid_lines.line_attribute8(l_count) := p_doc_lines_rec.line_attribute8(i);
      l_valid_lines.line_attribute9(l_count) := p_doc_lines_rec.line_attribute9(i);
      l_valid_lines.line_attribute10(l_count) := p_doc_lines_rec.line_attribute10(i);
      l_valid_lines.line_attribute11(l_count) := p_doc_lines_rec.line_attribute11(i);
      l_valid_lines.line_attribute12(l_count) := p_doc_lines_rec.line_attribute12(i);
      l_valid_lines.line_attribute13(l_count) := p_doc_lines_rec.line_attribute13(i);
      l_valid_lines.line_attribute14(l_count) := p_doc_lines_rec.line_attribute14(i);
      l_valid_lines.line_attribute15(l_count) := p_doc_lines_rec.line_attribute15(i);
      l_valid_lines.shipment_attribute_category(l_count) := p_doc_lines_rec.shipment_attribute_category(i);
      l_valid_lines.shipment_attribute1(l_count) := p_doc_lines_rec.shipment_attribute1(i);
      l_valid_lines.shipment_attribute2(l_count) := p_doc_lines_rec.shipment_attribute2(i);
      l_valid_lines.shipment_attribute3(l_count) := p_doc_lines_rec.shipment_attribute3(i);
      l_valid_lines.shipment_attribute4(l_count) := p_doc_lines_rec.shipment_attribute4(i);
      l_valid_lines.shipment_attribute5(l_count) := p_doc_lines_rec.shipment_attribute5(i);
      l_valid_lines.shipment_attribute6(l_count) := p_doc_lines_rec.shipment_attribute6(i);
      l_valid_lines.shipment_attribute7(l_count) := p_doc_lines_rec.shipment_attribute7(i);
      l_valid_lines.shipment_attribute8(l_count) := p_doc_lines_rec.shipment_attribute8(i);
      l_valid_lines.shipment_attribute9(l_count) := p_doc_lines_rec.shipment_attribute9(i);
      l_valid_lines.shipment_attribute10(l_count) := p_doc_lines_rec.shipment_attribute10(i);
      l_valid_lines.shipment_attribute11(l_count) := p_doc_lines_rec.shipment_attribute11(i);
      l_valid_lines.shipment_attribute12(l_count) := p_doc_lines_rec.shipment_attribute12(i);
      l_valid_lines.shipment_attribute13(l_count) := p_doc_lines_rec.shipment_attribute13(i);
      l_valid_lines.shipment_attribute14(l_count) := p_doc_lines_rec.shipment_attribute14(i);
      l_valid_lines.shipment_attribute15(l_count) := p_doc_lines_rec.shipment_attribute15(i);
      l_valid_lines.last_update_date(l_count) := p_doc_lines_rec.last_update_date(i);
      l_valid_lines.last_updated_by(l_count) := p_doc_lines_rec.last_updated_by(i);
      l_valid_lines.last_update_login(l_count) := p_doc_lines_rec.last_update_login(i);
      l_valid_lines.creation_date(l_count) := p_doc_lines_rec.creation_date(i);
      l_valid_lines.created_by(l_count) := p_doc_lines_rec.created_by(i);
      l_valid_lines.request_id(l_count) := p_doc_lines_rec.request_id(i);
      l_valid_lines.program_application_id(l_count) := p_doc_lines_rec.program_application_id(i);
      l_valid_lines.program_id(l_count) := p_doc_lines_rec.program_id(i);
      l_valid_lines.program_update_date(l_count) := p_doc_lines_rec.program_update_date(i);
      l_valid_lines.invoice_close_tolerance(l_count) := p_doc_lines_rec.invoice_close_tolerance(i);
      l_valid_lines.organization_id(l_count) := p_doc_lines_rec.organization_id(i);
      l_valid_lines.item_attribute_category(l_count) := p_doc_lines_rec.item_attribute_category(i);
      l_valid_lines.item_attribute1(l_count) := p_doc_lines_rec.item_attribute1(i);
      l_valid_lines.item_attribute2(l_count) := p_doc_lines_rec.item_attribute2(i);
      l_valid_lines.item_attribute3(l_count) := p_doc_lines_rec.item_attribute3(i);
      l_valid_lines.item_attribute4(l_count) := p_doc_lines_rec.item_attribute4(i);
      l_valid_lines.item_attribute5(l_count) := p_doc_lines_rec.item_attribute5(i);
      l_valid_lines.item_attribute6(l_count) := p_doc_lines_rec.item_attribute6(i);
      l_valid_lines.item_attribute7(l_count) := p_doc_lines_rec.item_attribute7(i);
      l_valid_lines.item_attribute8(l_count) := p_doc_lines_rec.item_attribute8(i);
      l_valid_lines.item_attribute9(l_count) := p_doc_lines_rec.item_attribute9(i);
      l_valid_lines.item_attribute10(l_count) := p_doc_lines_rec.item_attribute10(i);
      l_valid_lines.item_attribute11(l_count) := p_doc_lines_rec.item_attribute11(i);
      l_valid_lines.item_attribute12(l_count) := p_doc_lines_rec.item_attribute12(i);
      l_valid_lines.item_attribute13(l_count) := p_doc_lines_rec.item_attribute13(i);
      l_valid_lines.item_attribute14(l_count) := p_doc_lines_rec.item_attribute14(i);
      l_valid_lines.item_attribute15(l_count) := p_doc_lines_rec.item_attribute15(i);
      l_valid_lines.unit_weight(l_count) := p_doc_lines_rec.unit_weight(i);
      l_valid_lines.weight_uom_code(l_count) := p_doc_lines_rec.weight_uom_code(i);
      l_valid_lines.volume_uom_code(l_count) := p_doc_lines_rec.volume_uom_code(i);
      l_valid_lines.unit_volume(l_count) := p_doc_lines_rec.unit_volume(i);
      l_valid_lines.template_id(l_count) := p_doc_lines_rec.template_id(i);
      l_valid_lines.template_name(l_count) := p_doc_lines_rec.template_name(i);
      l_valid_lines.line_reference_num(l_count) := p_doc_lines_rec.line_reference_num(i);
      l_valid_lines.sourcing_rule_name(l_count) := p_doc_lines_rec.sourcing_rule_name(i);
      l_valid_lines.tax_status_indicator(l_count) := p_doc_lines_rec.tax_status_indicator(i);
      l_valid_lines.process_code(l_count) := p_doc_lines_rec.process_code(i);
      l_valid_lines.price_chg_accept_flag(l_count) := p_doc_lines_rec.price_chg_accept_flag(i);
      l_valid_lines.price_break_flag(l_count) := p_doc_lines_rec.price_break_flag(i);
      l_valid_lines.price_update_tolerance(l_count) := p_doc_lines_rec.price_update_tolerance(i);
      l_valid_lines.tax_user_override_flag(l_count) := p_doc_lines_rec.tax_user_override_flag(i);
      l_valid_lines.tax_code_id(l_count) := p_doc_lines_rec.tax_code_id(i);
      l_valid_lines.note_to_receiver(l_count) := p_doc_lines_rec.note_to_receiver(i);
      l_valid_lines.oke_contract_header_id(l_count) := p_doc_lines_rec.oke_contract_header_id(i);
      l_valid_lines.oke_contract_header_num(l_count) := p_doc_lines_rec.oke_contract_header_num(i);
      l_valid_lines.oke_contract_version_id(l_count) := p_doc_lines_rec.oke_contract_version_id(i);
      l_valid_lines.secondary_unit_of_measure(l_count) := p_doc_lines_rec.secondary_unit_of_measure(i);
      l_valid_lines.secondary_uom_code(l_count) := p_doc_lines_rec.secondary_uom_code(i);
      l_valid_lines.secondary_quantity(l_count) := p_doc_lines_rec.secondary_quantity(i);
      l_valid_lines.preferred_grade(l_count) := p_doc_lines_rec.preferred_grade(i);
      l_valid_lines.vmi_flag(l_count) := p_doc_lines_rec.vmi_flag(i);
      l_valid_lines.auction_header_id(l_count) := p_doc_lines_rec.auction_header_id(i);
      l_valid_lines.auction_line_number(l_count) := p_doc_lines_rec.auction_line_number(i);
      l_valid_lines.auction_display_number(l_count) := p_doc_lines_rec.auction_display_number(i);
      l_valid_lines.bid_number(l_count) := p_doc_lines_rec.bid_number(i);
      l_valid_lines.bid_line_number(l_count) := p_doc_lines_rec.bid_line_number(i);
      l_valid_lines.orig_from_req_flag(l_count) := p_doc_lines_rec.orig_from_req_flag(i);
      l_valid_lines.consigned_flag(l_count) := p_doc_lines_rec.consigned_flag(i);
      l_valid_lines.supplier_ref_number(l_count) := p_doc_lines_rec.supplier_ref_number(i);
      l_valid_lines.contract_id(l_count) := p_doc_lines_rec.contract_id(i);
      l_valid_lines.job_id(l_count) := p_doc_lines_rec.job_id(i);
      l_valid_lines.amount(l_count) := p_doc_lines_rec.amount(i);
      l_valid_lines.job_name(l_count) := p_doc_lines_rec.job_name(i);
      l_valid_lines.contractor_first_name(l_count) := p_doc_lines_rec.contractor_first_name(i);
      l_valid_lines.contractor_last_name(l_count) := p_doc_lines_rec.contractor_last_name(i);
      l_valid_lines.drop_ship_flag(l_count) := p_doc_lines_rec.drop_ship_flag(i);
      l_valid_lines.base_unit_price(l_count) := p_doc_lines_rec.base_unit_price(i);
      l_valid_lines.transaction_flow_header_id(l_count) := p_doc_lines_rec.transaction_flow_header_id(i);
      l_valid_lines.job_business_group_id(l_count) := p_doc_lines_rec.job_business_group_id(i);
      l_valid_lines.job_business_group_name(l_count) := p_doc_lines_rec.job_business_group_name(i);
      l_valid_lines.tracking_quantity_ind(l_count) := p_doc_lines_rec.tracking_quantity_ind(i);
      l_valid_lines.secondary_default_ind(l_count) := p_doc_lines_rec.secondary_default_ind(i);
      l_valid_lines.dual_uom_deviation_high(l_count) := p_doc_lines_rec.dual_uom_deviation_high(i);
      l_valid_lines.dual_uom_deviation_low(l_count) := p_doc_lines_rec.dual_uom_deviation_low(i);
      l_valid_lines.processing_id(l_count) := p_doc_lines_rec.processing_id(i);
      l_valid_lines.line_loc_populated_flag(l_count) := p_doc_lines_rec.line_loc_populated_flag(i);
      l_valid_lines.catalog_name(l_count) := p_doc_lines_rec.catalog_name(i);
      l_valid_lines.supplier_part_auxid(l_count) := p_doc_lines_rec.supplier_part_auxid(i);
      l_valid_lines.ip_category_id(l_count) := p_doc_lines_rec.ip_category_id(i);
      l_valid_lines.ip_category_name(l_count) := p_doc_lines_rec.ip_category_name(i);
      l_valid_lines.order_type_lookup_code(l_count) := p_doc_lines_rec.order_type_lookup_code(i);
      l_valid_lines.purchase_basis(l_count) := p_doc_lines_rec.purchase_basis(i);
      l_valid_lines.matching_basis(l_count) := p_doc_lines_rec.matching_basis(i);
      l_valid_lines.org_id(l_count) := p_doc_lines_rec.org_id(i); -- Not present in interface tables
    END IF;
  END LOOP;

  l_progress := '090';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_count='||l_count); END IF;

  -- SQL What: Insert rows that have no errors, and action = PO_R12_CAT_UPG_PVT.g_action_line_create
  -- SQL Why : To migrate data to txn tables
  -- SQL Join: none
  FORALL i IN 1 .. l_valid_lines.po_line_id.COUNT
    INSERT INTO po_lines_all POL
                         (po_line_id,
                          last_update_date,
                          last_updated_by,
                          po_header_id,
                          line_type_id,
                          line_num,
                          last_update_login,
                          creation_date,
                          created_by,
                          item_id,
                          item_revision,
                          category_id,
                          item_description,
                          unit_meas_lookup_code,
                          quantity_committed,
                          committed_amount,
                          allow_price_override_flag,
                          not_to_exceed_price,
                          list_price_per_unit,
                          unit_price,
                          quantity,
                          un_number_id,
                          hazard_class_id,
                          note_to_vendor,
                          from_header_id,
                          from_line_id,
                          min_order_quantity,
                          max_order_quantity,
                          qty_rcv_tolerance,
                          over_tolerance_error_flag,
                          market_price,
                          unordered_flag,
                          closed_flag,
                          user_hold_flag,
                          cancel_flag,
                          cancelled_by,
                          cancel_date,
                          cancel_reason,
                          firm_status_lookup_code,
                          firm_date,
                          vendor_product_num,
                          contract_num,
                          taxable_flag,
                          tax_name,
                          type_1099,
                          capital_expense_flag,
                          negotiated_by_preparer_flag,
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
                          reference_num,
                          attribute11,
                          attribute12,
                          attribute13,
                          attribute14,
                          attribute15,
                          min_release_amount,
                          price_type_lookup_code,
                          closed_code,
                          price_break_lookup_code,
                          ussgl_transaction_code,
                          government_context,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          closed_date,
                          closed_reason,
                          closed_by,
                          transaction_reason_code,
                          org_id,
                          qc_grade,
                          base_uom,
                          base_qty,
                          secondary_uom,
                          secondary_qty,
                          global_attribute_category,
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
                          line_reference_num,
                          project_id,
                          task_id,
                          expiration_date,
                          tax_code_id,
                          oke_contract_header_id,
                          oke_contract_version_id,
                          secondary_quantity,
                          secondary_unit_of_measure,
                          preferred_grade,
                          auction_header_id,
                          auction_display_number,
                          auction_line_number,
                          bid_number,
                          bid_line_number,
                          retroactive_date,
                          --supplier_ref_number, TODO: Not present in 11.5.9
                          --contract_id, TODO: Not present in 11.5.9
                          --start_date, TODO: Not present in 11.5.9
                          --amount, TODO: Not present in 11.5.9
                          --job_id, TODO: Not present in 11.5.9
                          --contractor_first_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --contractor_last_name, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          --from_line_location_id, TODO: Not present in 11.5.9. For 11.5.10, default NULL
                          order_type_lookup_code, -- Not present in 11.5.9. For 11.5.10, default as in PDOI (iP will not provide)
                          purchase_basis, -- Not present in 11.5.9. For 11.5.10, default as in PDOI (iP will not provide)
                          matching_basis, -- Not present in 11.5.9. For 11.5.10, default as in PDOI (iP will not provide)
                          --svc_amount_notif_sent, Not present in 11.5.9. For 11.5.10, default NULL
                          --svc_completion_notif_sent, Not present in 11.5.9. For 11.5.10, default NULL
                          --base_unit_price, Not present in 11.5.9. For 11.5.10, default as in PDOI (iP will not provide)
                          manual_price_change_flag,
                          --retainage_rate, Not present in 11.5.9, 11.5.10
                          --max_retainage_amount, Not present in 11.5.9, 11.5.10
                          --progress_payment_rate, Not present in 11.5.9, 11.5.10
                          --recoupment_rate, Not present in 11.5.9, 11.5.10
                          catalog_name,
                          supplier_part_auxid,
                          ip_category_id,
                          last_updated_program
                          --advance_amount Not present in 11.5.9, 11.5.10
                         )
    VALUES
    (
      l_valid_lines.po_line_id(i), -- From sequence PO_LINES_S
      sysdate, -- last_update_date
      FND_GLOBAL.user_id, -- last_updated_by
      l_valid_lines.po_header_id(i),
      l_valid_lines.line_type_id(i),
      l_valid_lines.line_num(i), -- TODO: double check the defaulting
      FND_GLOBAL.login_id, -- last_update_login
      sysdate, -- creation_date
      g_R12_UPGRADE_USER, -- created_by = -12
      l_valid_lines.item_id(i),
      l_valid_lines.item_revision(i),
      l_valid_lines.category_id(i),
      l_valid_lines.item_description(i),
      l_valid_lines.unit_of_measure(i), -- unit_meas_lookup_code
      NULL, -- quantity_committed
      NULL, -- committed_amount
      l_valid_lines.allow_price_override_flag(i),
      NULL, -- not_to_exceed_price
      l_valid_lines.list_price_per_unit(i),
      l_valid_lines.unit_price(i),
      1, -- quantity
      l_valid_lines.un_number_id(i),
      l_valid_lines.hazard_class_id(i),
      NULL, -- note_to_vendor
      NULL, -- from_header_id
      NULL, -- from_line_id
      NULL, -- min_order_quantity
      NULL, -- max_order_quantity
      l_valid_lines.qty_rcv_tolerance(i),
      NULL, -- over_tolerance_error_flag
      l_valid_lines.market_price(i),
      'N', -- unordered_flag,
      'N', -- closed_flag,
      'N', -- user_hold_flag,
      'N', -- cancel_flag,
      NULL, -- cancelled_by,
      NULL, -- cancel_date,
      NULL, -- cancel_reason,
      NULL, -- firm_status_lookup_code,
      NULL, -- firm_date,
      l_valid_lines.vendor_product_num(i),
      NULL, -- contract_num
      l_valid_lines.taxable_flag(i),
      l_valid_lines.tax_name(i),
      l_valid_lines.type_1099(i),
      'N', -- capital_expense_flag
      l_valid_lines.negotiated_by_preparer_flag(i),
      NULL, -- attribute_category
      NULL, -- attribute1
      NULL, -- attribute2
      NULL, -- attribute3
      NULL, -- attribute4
      NULL, -- attribute5
      NULL, -- attribute6
      NULL, -- attribute7
      NULL, -- attribute8
      NULL, -- attribute9
      NULL, -- attribute10
      NULL, -- reference_num
      NULL, -- attribute11
      NULL, -- attribute12
      NULL, -- attribute13
      NULL, -- attribute14
      NULL, -- attribute15
      l_valid_lines.min_release_amount(i),
      l_valid_lines.price_type(i),
      'OPEN', -- closed_code
      NULL, -- price_break_lookup_code
      NULL, -- ussgl_transaction_code
      NULL, -- government_context
      FND_GLOBAL.conc_request_id, -- request_id: iPs conc program request id
      NULL, -- program_application_id
      NULL, -- program_id
      NULL, -- program_update_date
      NULL, -- closed_date
      NULL, -- closed_reason
      NULL, -- closed_by
      NULL, -- transaction_reason_code
      l_valid_lines.org_id(i),
      NULL, -- qc_grade (Obsolete)
      NULL, -- base_uom (Obsolete)
      NULL, -- base_qty (Obsolete)
      NULL, -- secondary_uom (Obsolete)
      NULL, -- secondary_qty (Obsolete)
      NULL, -- global_attribute_category
      NULL, -- global_attribute1
      NULL, -- global_attribute2
      NULL, -- global_attribute3
      NULL, -- global_attribute4
      NULL, -- global_attribute5
      NULL, -- global_attribute6
      NULL, -- global_attribute7
      NULL, -- global_attribute8
      NULL, -- global_attribute9
      NULL, -- global_attribute10
      NULL, -- global_attribute11
      NULL, -- global_attribute12
      NULL, -- global_attribute13
      NULL, -- global_attribute14
      NULL, -- global_attribute15
      NULL, -- global_attribute16
      NULL, -- global_attribute17
      NULL, -- global_attribute18
      NULL, -- global_attribute19
      NULL, -- global_attribute20
      NULL, -- line_reference_num
      NULL, -- project_id
      NULL, -- task_id
      NULL, -- expiration_date
      l_valid_lines.tax_code_id(i),
      NULL, -- oke_contract_header_id
      NULL, -- oke_contract_version_id
      NULL, -- secondary_quantity
      NULL, -- secondary_unit_of_measure
      NULL, -- preferred_grade
      NULL, -- auction_header_id
      NULL, -- auction_display_number
      NULL, -- auction_line_number
      NULL, -- bid_number
      NULL, -- bid_line_number
      NULL, -- retroactive_date
      --NULL, -- supplier_ref_number, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- contract_id, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- start_date, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- amount, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- job_id, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- contractor_first_name, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- contractor_last_name, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- from_line_location_id, Not present in 11.5.9. For 11.5.10, default NULL
      l_valid_lines.order_type_lookup_code(i),
      l_valid_lines.purchase_basis(i),
      l_valid_lines.matching_basis(i),
      --NULL, -- svc_amount_notif_sent, Not present in 11.5.9. For 11.5.10, default NULL
      --NULL, -- svc_completion_notif_sent, Not present in 11.5.9. For 11.5.10, default NULL
      --l_valid_lines.base_unit_price(i), Not present in 11.5.9. For 11.5.10, default as in PDOI (iP will not provide)
      NULL, -- manual_price_change_flag,
      --NULL, -- retainage_rate, Not present in 11.5.9, 11.5.10
      --NULL, -- max_retainage_amount, Not present in 11.5.9, 11.5.10
      --NULL, -- progress_payment_rate, Not present in 11.5.9, 11.5.10
      --NULL, -- recoupment_rate, Not present in 11.5.9, 11.5.10
      l_valid_lines.catalog_name(i),
      l_valid_lines.supplier_part_auxid(i),
      l_valid_lines.ip_category_id(i),
      g_R12_MIGRATION_PROGRAM -- last_updated_program
      --NULL, -- advance_amount, Not present in 11.5.9, 11.5.10
    );

  l_progress := '100';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines inserted='||SQL%rowcount); END IF;

  l_progress := '110';
  -- SQL What: Insert the PO_LINE_ID back into Interface table for successfull
  --           line creation.
  -- SQL Why : To make it available to the calling program of the migration API.
  -- SQL Join: interface_line_id
  FORALL i IN 1 .. l_valid_lines.po_line_id.COUNT
    UPDATE PO_LINES_INTERFACE
    SET PO_LINE_ID = l_valid_lines.po_line_id(i),
        PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_line_id = l_valid_lines.interface_line_id(i);

  l_progress := '120';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of interface_line recs updated='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END insert_doc_lines;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_doc_lines
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Updates a batch of document lines given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of line information for
  --  creating a new GBPA line.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_doc_lines
(
   p_doc_lines_rec    IN record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_doc_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
  l_po_line_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER; --Bug#4731494
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF (p_doc_lines_rec.po_line_id.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_rec.po_line_id(1)='||p_doc_lines_rec.po_line_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_rec.has_errors(1)='||p_doc_lines_rec.has_errors(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_rec.action(1)='||p_doc_lines_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_rec.ip_category_id(1)='||p_doc_lines_rec.ip_category_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_doc_lines_rec.item_description(1)='||p_doc_lines_rec.item_description(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Update all the lines that were NOT created by the Catalog Upgrade
  --           and don't have any errors.
  -- SQL Why : To update the line level columns
  -- SQL Join: po_line_id
  FORALL i IN 1..p_doc_lines_rec.po_line_id.COUNT
    UPDATE po_lines_all
    SET
      -- Only the following 3 columns are allowed to be updated on a line,
      -- when it was not created by the migration program. Rest of them will
      -- be ignored. But for lines that were created by the migration program,
      -- many more column may be updated (see next statement).
      ip_category_id =      DECODE(p_doc_lines_rec.ip_category_id(i),
                                NULL, ip_category_id,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.ip_category_id(i)),
      catalog_name =        DECODE(p_doc_lines_rec.catalog_name(i),
                                NULL, catalog_name,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.catalog_name(i)),
      supplier_part_auxid = DECODE(p_doc_lines_rec.supplier_part_auxid(i),
                                NULL, supplier_part_auxid,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.supplier_part_auxid(i))
    WHERE po_line_id = p_doc_lines_rec.po_line_id(i)
      AND p_doc_lines_rec.has_errors(i) = 'N'
      AND p_doc_lines_rec.action(i) = 'UPDATE'
      AND created_by <> g_R12_UPGRADE_USER; --Bug#4865568

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines updated for exiting docs='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Update all the lines that were created by the Catalog Upgrade
  --           and don't have any errors.
  -- SQL Why : To update the line level columns
  -- SQL Join: po_line_id
  FORALL i IN 1..p_doc_lines_rec.po_line_id.COUNT
    UPDATE po_lines_all
    SET
      -- Only the following 9 columns are allowed to be updated on a line,
      -- when it was created by the migration program. Rest of them will
      -- be ignored.
      unit_price =          DECODE(p_doc_lines_rec.unit_price(i),
                                NULL, unit_price,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.unit_price(i)),
      item_description =    DECODE(p_doc_lines_rec.item_description(i),
                                NULL, item_description,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.item_description(i)),
      catalog_name =        DECODE(p_doc_lines_rec.catalog_name(i),
                                NULL, catalog_name,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.catalog_name(i)),
      supplier_part_auxid = DECODE(p_doc_lines_rec.supplier_part_auxid(i),
                                NULL, supplier_part_auxid,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.supplier_part_auxid(i)),
      unit_meas_lookup_code = DECODE(p_doc_lines_rec.unit_of_measure(i),
                                NULL, unit_meas_lookup_code,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.unit_of_measure(i)),
      negotiated_by_preparer_flag = DECODE(p_doc_lines_rec.negotiated_by_preparer_flag(i),
                                NULL, negotiated_by_preparer_flag,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.negotiated_by_preparer_flag(i)),
      ip_category_id =      DECODE(p_doc_lines_rec.ip_category_id(i),
                                NULL, ip_category_id,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.ip_category_id(i)),
      category_id =         DECODE(p_doc_lines_rec.category_id(i),
                                NULL, category_id,
                                g_NULLIFY_NUM, NULL,
                                p_doc_lines_rec.category_id(i)),
      vendor_product_num  = DECODE(p_doc_lines_rec.vendor_product_num (i),
                                NULL, vendor_product_num ,
                                g_NULLIFY_VARCHAR, NULL,
                                p_doc_lines_rec.vendor_product_num (i))
    WHERE po_line_id = p_doc_lines_rec.po_line_id(i)
      AND p_doc_lines_rec.has_errors(i) = 'N'
      AND p_doc_lines_rec.action(i) = 'UPDATE'
      AND created_by = g_R12_UPGRADE_USER    --Bug#4865568
    RETURNING po_line_id BULK COLLECT into l_po_line_ids; --Bug#4731494

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines updated for docs created by migration program='||SQL%rowcount); END IF;

  l_progress := '035';

    -- Bug#4731494
    -- SQL What: Update last_update_date for the rows that are updated and was
    --           originally created by upgrade/migration program
    -- SQL Why : To mark them as successfully updated
    -- SQL Join: interface_line_id
    FORALL i in 1..l_po_line_ids.COUNT
      UPDATE PO_LINES_ALL
      SET LAST_UPDATED_BY      = g_R12_UPGRADE_USER,
          LAST_UPDATE_LOGIN    = g_R12_UPGRADE_USER,
          LAST_UPDATED_PROGRAM = g_R12_MIGRATION_PROGRAM,
          LAST_UPDATE_DATE     = sysdate
      WHERE PO_LINE_ID = l_po_line_ids(i);

  l_progress := '040';
  -- SQL What: Update the process_code of lines interface rows with PROCESSED
  -- SQL Why : To mark them as successfully updated
  -- SQL Join: interface_line_id
  FORALL i IN 1..p_doc_lines_rec.po_line_id.COUNT
    UPDATE po_lines_interface
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_line_id = p_doc_lines_rec.interface_line_id(i)
      AND p_doc_lines_rec.has_errors(i) = 'N'
      AND p_doc_lines_rec.action(i) = 'UPDATE';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of interface lines PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_doc_lines;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: delete_doc_lines
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Deletes a batch of document lines given in a plsql table, from the transaction
  --  tables:
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of line information for
  --  creating a new GBPA line.
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_doc_lines
(
   p_doc_lines_rec IN record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_doc_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_po_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Delete Rows that do not have errors
  FORALL i IN 1..p_doc_lines_rec.po_line_id.COUNT
    DELETE FROM po_lines_all
    WHERE po_line_id = p_doc_lines_rec.po_line_id(i)
      AND p_doc_lines_rec.has_errors(i) = 'N'
      AND p_doc_lines_rec.action(i) = 'DELETE'
    RETURNING po_line_id
    BULK COLLECT INTO l_po_line_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines deleted='||SQL%rowcount); END IF;

  l_progress := '020';

  -- Delete from Attribute tables
  FORALL i IN 1.. l_po_line_ids.COUNT
    DELETE FROM PO_ATTRIBUTE_VALUES
    WHERE PO_LINE_ID = l_po_line_ids(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of attr deleted='||SQL%rowcount); END IF;

  l_progress := '030';

  -- Delete from Attribute TLP tables
  FORALL i IN 1.. l_po_line_ids.COUNT
    DELETE FROM PO_ATTRIBUTE_VALUES_TLP
    WHERE PO_LINE_ID = l_po_line_ids(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP deleted='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark interface lines as PROCESSED
  FORALL i IN 1..p_doc_lines_rec.po_line_id.COUNT
    UPDATE po_lines_interface
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_line_id = p_doc_lines_rec.interface_line_id(i)
      AND p_doc_lines_rec.has_errors(i) = 'N'
      AND p_doc_lines_rec.action(i) = 'DELETE';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END delete_doc_lines;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: migrate_attributes
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the attribute values from interface to draft tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_attributes
(
   p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to load attribute values
  -- SQL Why : To migrate data to PO txn tables
  -- SQL Join: processing_id, action
  -- Bug 5677911: Added the hint for performance reason.
  CURSOR load_attrib_csr(request_processing_id NUMBER) IS
    SELECT /*+ INDEX(attrib, PO_ATTR_VALUES_INT_N2)*/
           attrib.interface_attr_values_id,
           attrib.interface_header_id,
           attrib.interface_line_id,
           attrib.action,
           attrib.process_code,
           -- The po_line_id would be stamped on PO_LINES_INTERFACE for successfully migrated lines
           NVL(DECODE(attrib.po_line_id,
                      g_NOT_REQUIRED_ID, POLI.po_line_id,
                      NULL, POLI.po_line_id,
                      attrib.po_line_id),
               g_NOT_REQUIRED_ID),
           attrib.req_template_name,
           attrib.req_template_line_num,
           attrib.ip_category_id,
           attrib.inventory_item_id,
           attrib.org_id,
           attrib.manufacturer_part_num,
           attrib.thumbnail_image,
           attrib.supplier_url,
           attrib.manufacturer_url,
           attrib.attachment_url,
           attrib.unspsc,
           attrib.availability,
           attrib.lead_time,
           attrib.text_base_attribute1,
           attrib.text_base_attribute2,
           attrib.text_base_attribute3,
           attrib.text_base_attribute4,
           attrib.text_base_attribute5,
           attrib.text_base_attribute6,
           attrib.text_base_attribute7,
           attrib.text_base_attribute8,
           attrib.text_base_attribute9,
           attrib.text_base_attribute10,
           attrib.text_base_attribute11,
           attrib.text_base_attribute12,
           attrib.text_base_attribute13,
           attrib.text_base_attribute14,
           attrib.text_base_attribute15,
           attrib.text_base_attribute16,
           attrib.text_base_attribute17,
           attrib.text_base_attribute18,
           attrib.text_base_attribute19,
           attrib.text_base_attribute20,
           attrib.text_base_attribute21,
           attrib.text_base_attribute22,
           attrib.text_base_attribute23,
           attrib.text_base_attribute24,
           attrib.text_base_attribute25,
           attrib.text_base_attribute26,
           attrib.text_base_attribute27,
           attrib.text_base_attribute28,
           attrib.text_base_attribute29,
           attrib.text_base_attribute30,
           attrib.text_base_attribute31,
           attrib.text_base_attribute32,
           attrib.text_base_attribute33,
           attrib.text_base_attribute34,
           attrib.text_base_attribute35,
           attrib.text_base_attribute36,
           attrib.text_base_attribute37,
           attrib.text_base_attribute38,
           attrib.text_base_attribute39,
           attrib.text_base_attribute40,
           attrib.text_base_attribute41,
           attrib.text_base_attribute42,
           attrib.text_base_attribute43,
           attrib.text_base_attribute44,
           attrib.text_base_attribute45,
           attrib.text_base_attribute46,
           attrib.text_base_attribute47,
           attrib.text_base_attribute48,
           attrib.text_base_attribute49,
           attrib.text_base_attribute50,
           attrib.text_base_attribute51,
           attrib.text_base_attribute52,
           attrib.text_base_attribute53,
           attrib.text_base_attribute54,
           attrib.text_base_attribute55,
           attrib.text_base_attribute56,
           attrib.text_base_attribute57,
           attrib.text_base_attribute58,
           attrib.text_base_attribute59,
           attrib.text_base_attribute60,
           attrib.text_base_attribute61,
           attrib.text_base_attribute62,
           attrib.text_base_attribute63,
           attrib.text_base_attribute64,
           attrib.text_base_attribute65,
           attrib.text_base_attribute66,
           attrib.text_base_attribute67,
           attrib.text_base_attribute68,
           attrib.text_base_attribute69,
           attrib.text_base_attribute70,
           attrib.text_base_attribute71,
           attrib.text_base_attribute72,
           attrib.text_base_attribute73,
           attrib.text_base_attribute74,
           attrib.text_base_attribute75,
           attrib.text_base_attribute76,
           attrib.text_base_attribute77,
           attrib.text_base_attribute78,
           attrib.text_base_attribute79,
           attrib.text_base_attribute80,
           attrib.text_base_attribute81,
           attrib.text_base_attribute82,
           attrib.text_base_attribute83,
           attrib.text_base_attribute84,
           attrib.text_base_attribute85,
           attrib.text_base_attribute86,
           attrib.text_base_attribute87,
           attrib.text_base_attribute88,
           attrib.text_base_attribute89,
           attrib.text_base_attribute90,
           attrib.text_base_attribute91,
           attrib.text_base_attribute92,
           attrib.text_base_attribute93,
           attrib.text_base_attribute94,
           attrib.text_base_attribute95,
           attrib.text_base_attribute96,
           attrib.text_base_attribute97,
           attrib.text_base_attribute98,
           attrib.text_base_attribute99,
           attrib.text_base_attribute100,
           attrib.num_base_attribute1,
           attrib.num_base_attribute2,
           attrib.num_base_attribute3,
           attrib.num_base_attribute4,
           attrib.num_base_attribute5,
           attrib.num_base_attribute6,
           attrib.num_base_attribute7,
           attrib.num_base_attribute8,
           attrib.num_base_attribute9,
           attrib.num_base_attribute10,
           attrib.num_base_attribute11,
           attrib.num_base_attribute12,
           attrib.num_base_attribute13,
           attrib.num_base_attribute14,
           attrib.num_base_attribute15,
           attrib.num_base_attribute16,
           attrib.num_base_attribute17,
           attrib.num_base_attribute18,
           attrib.num_base_attribute19,
           attrib.num_base_attribute20,
           attrib.num_base_attribute21,
           attrib.num_base_attribute22,
           attrib.num_base_attribute23,
           attrib.num_base_attribute24,
           attrib.num_base_attribute25,
           attrib.num_base_attribute26,
           attrib.num_base_attribute27,
           attrib.num_base_attribute28,
           attrib.num_base_attribute29,
           attrib.num_base_attribute30,
           attrib.num_base_attribute31,
           attrib.num_base_attribute32,
           attrib.num_base_attribute33,
           attrib.num_base_attribute34,
           attrib.num_base_attribute35,
           attrib.num_base_attribute36,
           attrib.num_base_attribute37,
           attrib.num_base_attribute38,
           attrib.num_base_attribute39,
           attrib.num_base_attribute40,
           attrib.num_base_attribute41,
           attrib.num_base_attribute42,
           attrib.num_base_attribute43,
           attrib.num_base_attribute44,
           attrib.num_base_attribute45,
           attrib.num_base_attribute46,
           attrib.num_base_attribute47,
           attrib.num_base_attribute48,
           attrib.num_base_attribute49,
           attrib.num_base_attribute50,
           attrib.num_base_attribute51,
           attrib.num_base_attribute52,
           attrib.num_base_attribute53,
           attrib.num_base_attribute54,
           attrib.num_base_attribute55,
           attrib.num_base_attribute56,
           attrib.num_base_attribute57,
           attrib.num_base_attribute58,
           attrib.num_base_attribute59,
           attrib.num_base_attribute60,
           attrib.num_base_attribute61,
           attrib.num_base_attribute62,
           attrib.num_base_attribute63,
           attrib.num_base_attribute64,
           attrib.num_base_attribute65,
           attrib.num_base_attribute66,
           attrib.num_base_attribute67,
           attrib.num_base_attribute68,
           attrib.num_base_attribute69,
           attrib.num_base_attribute70,
           attrib.num_base_attribute71,
           attrib.num_base_attribute72,
           attrib.num_base_attribute73,
           attrib.num_base_attribute74,
           attrib.num_base_attribute75,
           attrib.num_base_attribute76,
           attrib.num_base_attribute77,
           attrib.num_base_attribute78,
           attrib.num_base_attribute79,
           attrib.num_base_attribute80,
           attrib.num_base_attribute81,
           attrib.num_base_attribute82,
           attrib.num_base_attribute83,
           attrib.num_base_attribute84,
           attrib.num_base_attribute85,
           attrib.num_base_attribute86,
           attrib.num_base_attribute87,
           attrib.num_base_attribute88,
           attrib.num_base_attribute89,
           attrib.num_base_attribute90,
           attrib.num_base_attribute91,
           attrib.num_base_attribute92,
           attrib.num_base_attribute93,
           attrib.num_base_attribute94,
           attrib.num_base_attribute95,
           attrib.num_base_attribute96,
           attrib.num_base_attribute97,
           attrib.num_base_attribute98,
           attrib.num_base_attribute99,
           attrib.num_base_attribute100,
           attrib.text_cat_attribute1,
           attrib.text_cat_attribute2,
           attrib.text_cat_attribute3,
           attrib.text_cat_attribute4,
           attrib.text_cat_attribute5,
           attrib.text_cat_attribute6,
           attrib.text_cat_attribute7,
           attrib.text_cat_attribute8,
           attrib.text_cat_attribute9,
           attrib.text_cat_attribute10,
           attrib.text_cat_attribute11,
           attrib.text_cat_attribute12,
           attrib.text_cat_attribute13,
           attrib.text_cat_attribute14,
           attrib.text_cat_attribute15,
           attrib.text_cat_attribute16,
           attrib.text_cat_attribute17,
           attrib.text_cat_attribute18,
           attrib.text_cat_attribute19,
           attrib.text_cat_attribute20,
           attrib.text_cat_attribute21,
           attrib.text_cat_attribute22,
           attrib.text_cat_attribute23,
           attrib.text_cat_attribute24,
           attrib.text_cat_attribute25,
           attrib.text_cat_attribute26,
           attrib.text_cat_attribute27,
           attrib.text_cat_attribute28,
           attrib.text_cat_attribute29,
           attrib.text_cat_attribute30,
           attrib.text_cat_attribute31,
           attrib.text_cat_attribute32,
           attrib.text_cat_attribute33,
           attrib.text_cat_attribute34,
           attrib.text_cat_attribute35,
           attrib.text_cat_attribute36,
           attrib.text_cat_attribute37,
           attrib.text_cat_attribute38,
           attrib.text_cat_attribute39,
           attrib.text_cat_attribute40,
           attrib.text_cat_attribute41,
           attrib.text_cat_attribute42,
           attrib.text_cat_attribute43,
           attrib.text_cat_attribute44,
           attrib.text_cat_attribute45,
           attrib.text_cat_attribute46,
           attrib.text_cat_attribute47,
           attrib.text_cat_attribute48,
           attrib.text_cat_attribute49,
           attrib.text_cat_attribute50,
           attrib.num_cat_attribute1,
           attrib.num_cat_attribute2,
           attrib.num_cat_attribute3,
           attrib.num_cat_attribute4,
           attrib.num_cat_attribute5,
           attrib.num_cat_attribute6,
           attrib.num_cat_attribute7,
           attrib.num_cat_attribute8,
           attrib.num_cat_attribute9,
           attrib.num_cat_attribute10,
           attrib.num_cat_attribute11,
           attrib.num_cat_attribute12,
           attrib.num_cat_attribute13,
           attrib.num_cat_attribute14,
           attrib.num_cat_attribute15,
           attrib.num_cat_attribute16,
           attrib.num_cat_attribute17,
           attrib.num_cat_attribute18,
           attrib.num_cat_attribute19,
           attrib.num_cat_attribute20,
           attrib.num_cat_attribute21,
           attrib.num_cat_attribute22,
           attrib.num_cat_attribute23,
           attrib.num_cat_attribute24,
           attrib.num_cat_attribute25,
           attrib.num_cat_attribute26,
           attrib.num_cat_attribute27,
           attrib.num_cat_attribute28,
           attrib.num_cat_attribute29,
           attrib.num_cat_attribute30,
           attrib.num_cat_attribute31,
           attrib.num_cat_attribute32,
           attrib.num_cat_attribute33,
           attrib.num_cat_attribute34,
           attrib.num_cat_attribute35,
           attrib.num_cat_attribute36,
           attrib.num_cat_attribute37,
           attrib.num_cat_attribute38,
           attrib.num_cat_attribute39,
           attrib.num_cat_attribute40,
           attrib.num_cat_attribute41,
           attrib.num_cat_attribute42,
           attrib.num_cat_attribute43,
           attrib.num_cat_attribute44,
           attrib.num_cat_attribute45,
           attrib.num_cat_attribute46,
           attrib.num_cat_attribute47,
           attrib.num_cat_attribute48,
           attrib.num_cat_attribute49,
           attrib.num_cat_attribute50,
           attrib.last_update_login,
           attrib.last_updated_by,
           attrib.last_update_date,
           attrib.created_by,
           attrib.creation_date,
           attrib.request_id,
           attrib.program_application_id,
           attrib.program_id,
           attrib.program_update_date,
           attrib.processing_id,
           'N' -- has_errors
    FROM   PO_ATTR_VALUES_INTERFACE attrib,
           PO_LINES_INTERFACE POLI
    WHERE  attrib.processing_id = request_processing_id
    AND    attrib.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW
    AND    attrib.action IN (PO_R12_CAT_UPG_PVT.g_action_attr_create, 'UPDATE', 'DELETE')
    AND    attrib.interface_line_id = POLI.interface_line_id;

  l_attrib_table record_of_attr_values_type;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Algorithm:
  -- 1. Load Lines batch (batch_size) into pl/sql table.
  -- 2. Call PDOI modules to process data in batches (default, derive, validate).
  -- 3. Get the validated pl/sql table for the batch from PDOI.
  -- 4. Transfer directly to Transaction tables

  OPEN load_attrib_csr(g_processing_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      FETCH load_attrib_csr BULK COLLECT INTO
        l_attrib_table.interface_attr_values_id,
        l_attrib_table.interface_header_id,
        l_attrib_table.interface_line_id,
        l_attrib_table.action,
        l_attrib_table.process_code,
        l_attrib_table.po_line_id,
        l_attrib_table.req_template_name,
        l_attrib_table.req_template_line_num,
        l_attrib_table.ip_category_id,
        l_attrib_table.inventory_item_id,
        l_attrib_table.org_id,
        l_attrib_table.manufacturer_part_num,
        l_attrib_table.thumbnail_image,
        l_attrib_table.supplier_url,
        l_attrib_table.manufacturer_url,
        l_attrib_table.attachment_url,
        l_attrib_table.unspsc,
        l_attrib_table.availability,
        l_attrib_table.lead_time,
        l_attrib_table.text_base_attribute1,
        l_attrib_table.text_base_attribute2,
        l_attrib_table.text_base_attribute3,
        l_attrib_table.text_base_attribute4,
        l_attrib_table.text_base_attribute5,
        l_attrib_table.text_base_attribute6,
        l_attrib_table.text_base_attribute7,
        l_attrib_table.text_base_attribute8,
        l_attrib_table.text_base_attribute9,
        l_attrib_table.text_base_attribute10,
        l_attrib_table.text_base_attribute11,
        l_attrib_table.text_base_attribute12,
        l_attrib_table.text_base_attribute13,
        l_attrib_table.text_base_attribute14,
        l_attrib_table.text_base_attribute15,
        l_attrib_table.text_base_attribute16,
        l_attrib_table.text_base_attribute17,
        l_attrib_table.text_base_attribute18,
        l_attrib_table.text_base_attribute19,
        l_attrib_table.text_base_attribute20,
        l_attrib_table.text_base_attribute21,
        l_attrib_table.text_base_attribute22,
        l_attrib_table.text_base_attribute23,
        l_attrib_table.text_base_attribute24,
        l_attrib_table.text_base_attribute25,
        l_attrib_table.text_base_attribute26,
        l_attrib_table.text_base_attribute27,
        l_attrib_table.text_base_attribute28,
        l_attrib_table.text_base_attribute29,
        l_attrib_table.text_base_attribute30,
        l_attrib_table.text_base_attribute31,
        l_attrib_table.text_base_attribute32,
        l_attrib_table.text_base_attribute33,
        l_attrib_table.text_base_attribute34,
        l_attrib_table.text_base_attribute35,
        l_attrib_table.text_base_attribute36,
        l_attrib_table.text_base_attribute37,
        l_attrib_table.text_base_attribute38,
        l_attrib_table.text_base_attribute39,
        l_attrib_table.text_base_attribute40,
        l_attrib_table.text_base_attribute41,
        l_attrib_table.text_base_attribute42,
        l_attrib_table.text_base_attribute43,
        l_attrib_table.text_base_attribute44,
        l_attrib_table.text_base_attribute45,
        l_attrib_table.text_base_attribute46,
        l_attrib_table.text_base_attribute47,
        l_attrib_table.text_base_attribute48,
        l_attrib_table.text_base_attribute49,
        l_attrib_table.text_base_attribute50,
        l_attrib_table.text_base_attribute51,
        l_attrib_table.text_base_attribute52,
        l_attrib_table.text_base_attribute53,
        l_attrib_table.text_base_attribute54,
        l_attrib_table.text_base_attribute55,
        l_attrib_table.text_base_attribute56,
        l_attrib_table.text_base_attribute57,
        l_attrib_table.text_base_attribute58,
        l_attrib_table.text_base_attribute59,
        l_attrib_table.text_base_attribute60,
        l_attrib_table.text_base_attribute61,
        l_attrib_table.text_base_attribute62,
        l_attrib_table.text_base_attribute63,
        l_attrib_table.text_base_attribute64,
        l_attrib_table.text_base_attribute65,
        l_attrib_table.text_base_attribute66,
        l_attrib_table.text_base_attribute67,
        l_attrib_table.text_base_attribute68,
        l_attrib_table.text_base_attribute69,
        l_attrib_table.text_base_attribute70,
        l_attrib_table.text_base_attribute71,
        l_attrib_table.text_base_attribute72,
        l_attrib_table.text_base_attribute73,
        l_attrib_table.text_base_attribute74,
        l_attrib_table.text_base_attribute75,
        l_attrib_table.text_base_attribute76,
        l_attrib_table.text_base_attribute77,
        l_attrib_table.text_base_attribute78,
        l_attrib_table.text_base_attribute79,
        l_attrib_table.text_base_attribute80,
        l_attrib_table.text_base_attribute81,
        l_attrib_table.text_base_attribute82,
        l_attrib_table.text_base_attribute83,
        l_attrib_table.text_base_attribute84,
        l_attrib_table.text_base_attribute85,
        l_attrib_table.text_base_attribute86,
        l_attrib_table.text_base_attribute87,
        l_attrib_table.text_base_attribute88,
        l_attrib_table.text_base_attribute89,
        l_attrib_table.text_base_attribute90,
        l_attrib_table.text_base_attribute91,
        l_attrib_table.text_base_attribute92,
        l_attrib_table.text_base_attribute93,
        l_attrib_table.text_base_attribute94,
        l_attrib_table.text_base_attribute95,
        l_attrib_table.text_base_attribute96,
        l_attrib_table.text_base_attribute97,
        l_attrib_table.text_base_attribute98,
        l_attrib_table.text_base_attribute99,
        l_attrib_table.text_base_attribute100,
        l_attrib_table.num_base_attribute1,
        l_attrib_table.num_base_attribute2,
        l_attrib_table.num_base_attribute3,
        l_attrib_table.num_base_attribute4,
        l_attrib_table.num_base_attribute5,
        l_attrib_table.num_base_attribute6,
        l_attrib_table.num_base_attribute7,
        l_attrib_table.num_base_attribute8,
        l_attrib_table.num_base_attribute9,
        l_attrib_table.num_base_attribute10,
        l_attrib_table.num_base_attribute11,
        l_attrib_table.num_base_attribute12,
        l_attrib_table.num_base_attribute13,
        l_attrib_table.num_base_attribute14,
        l_attrib_table.num_base_attribute15,
        l_attrib_table.num_base_attribute16,
        l_attrib_table.num_base_attribute17,
        l_attrib_table.num_base_attribute18,
        l_attrib_table.num_base_attribute19,
        l_attrib_table.num_base_attribute20,
        l_attrib_table.num_base_attribute21,
        l_attrib_table.num_base_attribute22,
        l_attrib_table.num_base_attribute23,
        l_attrib_table.num_base_attribute24,
        l_attrib_table.num_base_attribute25,
        l_attrib_table.num_base_attribute26,
        l_attrib_table.num_base_attribute27,
        l_attrib_table.num_base_attribute28,
        l_attrib_table.num_base_attribute29,
        l_attrib_table.num_base_attribute30,
        l_attrib_table.num_base_attribute31,
        l_attrib_table.num_base_attribute32,
        l_attrib_table.num_base_attribute33,
        l_attrib_table.num_base_attribute34,
        l_attrib_table.num_base_attribute35,
        l_attrib_table.num_base_attribute36,
        l_attrib_table.num_base_attribute37,
        l_attrib_table.num_base_attribute38,
        l_attrib_table.num_base_attribute39,
        l_attrib_table.num_base_attribute40,
        l_attrib_table.num_base_attribute41,
        l_attrib_table.num_base_attribute42,
        l_attrib_table.num_base_attribute43,
        l_attrib_table.num_base_attribute44,
        l_attrib_table.num_base_attribute45,
        l_attrib_table.num_base_attribute46,
        l_attrib_table.num_base_attribute47,
        l_attrib_table.num_base_attribute48,
        l_attrib_table.num_base_attribute49,
        l_attrib_table.num_base_attribute50,
        l_attrib_table.num_base_attribute51,
        l_attrib_table.num_base_attribute52,
        l_attrib_table.num_base_attribute53,
        l_attrib_table.num_base_attribute54,
        l_attrib_table.num_base_attribute55,
        l_attrib_table.num_base_attribute56,
        l_attrib_table.num_base_attribute57,
        l_attrib_table.num_base_attribute58,
        l_attrib_table.num_base_attribute59,
        l_attrib_table.num_base_attribute60,
        l_attrib_table.num_base_attribute61,
        l_attrib_table.num_base_attribute62,
        l_attrib_table.num_base_attribute63,
        l_attrib_table.num_base_attribute64,
        l_attrib_table.num_base_attribute65,
        l_attrib_table.num_base_attribute66,
        l_attrib_table.num_base_attribute67,
        l_attrib_table.num_base_attribute68,
        l_attrib_table.num_base_attribute69,
        l_attrib_table.num_base_attribute70,
        l_attrib_table.num_base_attribute71,
        l_attrib_table.num_base_attribute72,
        l_attrib_table.num_base_attribute73,
        l_attrib_table.num_base_attribute74,
        l_attrib_table.num_base_attribute75,
        l_attrib_table.num_base_attribute76,
        l_attrib_table.num_base_attribute77,
        l_attrib_table.num_base_attribute78,
        l_attrib_table.num_base_attribute79,
        l_attrib_table.num_base_attribute80,
        l_attrib_table.num_base_attribute81,
        l_attrib_table.num_base_attribute82,
        l_attrib_table.num_base_attribute83,
        l_attrib_table.num_base_attribute84,
        l_attrib_table.num_base_attribute85,
        l_attrib_table.num_base_attribute86,
        l_attrib_table.num_base_attribute87,
        l_attrib_table.num_base_attribute88,
        l_attrib_table.num_base_attribute89,
        l_attrib_table.num_base_attribute90,
        l_attrib_table.num_base_attribute91,
        l_attrib_table.num_base_attribute92,
        l_attrib_table.num_base_attribute93,
        l_attrib_table.num_base_attribute94,
        l_attrib_table.num_base_attribute95,
        l_attrib_table.num_base_attribute96,
        l_attrib_table.num_base_attribute97,
        l_attrib_table.num_base_attribute98,
        l_attrib_table.num_base_attribute99,
        l_attrib_table.num_base_attribute100,
        l_attrib_table.text_cat_attribute1,
        l_attrib_table.text_cat_attribute2,
        l_attrib_table.text_cat_attribute3,
        l_attrib_table.text_cat_attribute4,
        l_attrib_table.text_cat_attribute5,
        l_attrib_table.text_cat_attribute6,
        l_attrib_table.text_cat_attribute7,
        l_attrib_table.text_cat_attribute8,
        l_attrib_table.text_cat_attribute9,
        l_attrib_table.text_cat_attribute10,
        l_attrib_table.text_cat_attribute11,
        l_attrib_table.text_cat_attribute12,
        l_attrib_table.text_cat_attribute13,
        l_attrib_table.text_cat_attribute14,
        l_attrib_table.text_cat_attribute15,
        l_attrib_table.text_cat_attribute16,
        l_attrib_table.text_cat_attribute17,
        l_attrib_table.text_cat_attribute18,
        l_attrib_table.text_cat_attribute19,
        l_attrib_table.text_cat_attribute20,
        l_attrib_table.text_cat_attribute21,
        l_attrib_table.text_cat_attribute22,
        l_attrib_table.text_cat_attribute23,
        l_attrib_table.text_cat_attribute24,
        l_attrib_table.text_cat_attribute25,
        l_attrib_table.text_cat_attribute26,
        l_attrib_table.text_cat_attribute27,
        l_attrib_table.text_cat_attribute28,
        l_attrib_table.text_cat_attribute29,
        l_attrib_table.text_cat_attribute30,
        l_attrib_table.text_cat_attribute31,
        l_attrib_table.text_cat_attribute32,
        l_attrib_table.text_cat_attribute33,
        l_attrib_table.text_cat_attribute34,
        l_attrib_table.text_cat_attribute35,
        l_attrib_table.text_cat_attribute36,
        l_attrib_table.text_cat_attribute37,
        l_attrib_table.text_cat_attribute38,
        l_attrib_table.text_cat_attribute39,
        l_attrib_table.text_cat_attribute40,
        l_attrib_table.text_cat_attribute41,
        l_attrib_table.text_cat_attribute42,
        l_attrib_table.text_cat_attribute43,
        l_attrib_table.text_cat_attribute44,
        l_attrib_table.text_cat_attribute45,
        l_attrib_table.text_cat_attribute46,
        l_attrib_table.text_cat_attribute47,
        l_attrib_table.text_cat_attribute48,
        l_attrib_table.text_cat_attribute49,
        l_attrib_table.text_cat_attribute50,
        l_attrib_table.num_cat_attribute1,
        l_attrib_table.num_cat_attribute2,
        l_attrib_table.num_cat_attribute3,
        l_attrib_table.num_cat_attribute4,
        l_attrib_table.num_cat_attribute5,
        l_attrib_table.num_cat_attribute6,
        l_attrib_table.num_cat_attribute7,
        l_attrib_table.num_cat_attribute8,
        l_attrib_table.num_cat_attribute9,
        l_attrib_table.num_cat_attribute10,
        l_attrib_table.num_cat_attribute11,
        l_attrib_table.num_cat_attribute12,
        l_attrib_table.num_cat_attribute13,
        l_attrib_table.num_cat_attribute14,
        l_attrib_table.num_cat_attribute15,
        l_attrib_table.num_cat_attribute16,
        l_attrib_table.num_cat_attribute17,
        l_attrib_table.num_cat_attribute18,
        l_attrib_table.num_cat_attribute19,
        l_attrib_table.num_cat_attribute20,
        l_attrib_table.num_cat_attribute21,
        l_attrib_table.num_cat_attribute22,
        l_attrib_table.num_cat_attribute23,
        l_attrib_table.num_cat_attribute24,
        l_attrib_table.num_cat_attribute25,
        l_attrib_table.num_cat_attribute26,
        l_attrib_table.num_cat_attribute27,
        l_attrib_table.num_cat_attribute28,
        l_attrib_table.num_cat_attribute29,
        l_attrib_table.num_cat_attribute30,
        l_attrib_table.num_cat_attribute31,
        l_attrib_table.num_cat_attribute32,
        l_attrib_table.num_cat_attribute33,
        l_attrib_table.num_cat_attribute34,
        l_attrib_table.num_cat_attribute35,
        l_attrib_table.num_cat_attribute36,
        l_attrib_table.num_cat_attribute37,
        l_attrib_table.num_cat_attribute38,
        l_attrib_table.num_cat_attribute39,
        l_attrib_table.num_cat_attribute40,
        l_attrib_table.num_cat_attribute41,
        l_attrib_table.num_cat_attribute42,
        l_attrib_table.num_cat_attribute43,
        l_attrib_table.num_cat_attribute44,
        l_attrib_table.num_cat_attribute45,
        l_attrib_table.num_cat_attribute46,
        l_attrib_table.num_cat_attribute47,
        l_attrib_table.num_cat_attribute48,
        l_attrib_table.num_cat_attribute49,
        l_attrib_table.num_cat_attribute50,
        l_attrib_table.last_update_login,
        l_attrib_table.last_updated_by,
        l_attrib_table.last_update_date,
        l_attrib_table.created_by,
        l_attrib_table.creation_date,
        l_attrib_table.request_id,
        l_attrib_table.program_application_id,
        l_attrib_table.program_id,
        l_attrib_table.program_update_date,
        l_attrib_table.processing_id,
        l_attrib_table.has_errors
      LIMIT g_job.batch_size;

      l_progress := '030';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_attrib_table.interface_line_id.COUNT='||l_attrib_table.interface_line_id.COUNT); END IF;

      IF (l_attrib_table.interface_line_id.COUNT > 0) THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_attrib_table.interface_attr_values_id(1)='||l_attrib_table.interface_attr_values_id(1)); END IF;
      END IF;

      EXIT WHEN l_attrib_table.interface_line_id.COUNT = 0;

      -- Derive + Default + Validation are not required for attribute values

      l_progress := '070';
      -- Skip transfer if running in Validate Only mode.
      IF (p_validate_only_mode = FND_API.G_FALSE) THEN
        -- Transfer Attribute Values
        transfer_attributes(p_attrib_values_tbl => l_attrib_table);
      END IF; -- IF (p_validate_only_mode = FND_API.G_FALSE)

      l_progress := '100';
      COMMIT;

      l_progress := '110';
      IF (l_attrib_table.interface_attr_values_id.COUNT < g_job.batch_size) THEN
        EXIT;
      END IF;
      l_progress := '120';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_attrib_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '130';
        COMMIT;

        l_progress := '140';
        CLOSE load_attrib_csr;

        l_progress := '150';
        OPEN load_attrib_csr(g_processing_id);
        l_progress := '160';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP;

  l_progress := '170';
  IF (load_attrib_csr%ISOPEN) THEN
    CLOSE load_attrib_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_attrib_csr%ISOPEN) THEN
      CLOSE load_attrib_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END migrate_attributes;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: transfer_attributes
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Transfers a batch of attribute values given in a plsql table, into the
  --  transaction tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attrib_values_tbl
  --  A table of plsql records containing a batch of attribute values
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE transfer_attributes
(
   p_attrib_values_tbl    IN record_of_attr_values_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'transfer_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Insert Attributes
  insert_attributes(p_attr_values_tbl => p_attrib_values_tbl);

  l_progress := '020';
  -- Update Attributes
  update_attributes(p_attr_values_tbl => p_attrib_values_tbl);

  l_progress := '030';
  -- Delete Attributes
  -- This procedure is not required anymore. Deletion of the default attribute row is
  -- not allowed. Only update is allowed. In the pre-process validations, the rows
  -- that specified the DELETE action are already filtered.
  --delete_attributes(p_attr_values_tbl => p_attrib_values_tbl);
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END transfer_attributes;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: insert_attributes
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Inserts a batch of attr values given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attr_values_tbl
  --  A table of plsql records containing a batch of attr values
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_attributes
(
   p_attr_values_tbl IN record_of_attr_values_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_attr_values_tbl.po_line_id.COUNT='||p_attr_values_tbl.po_line_id.COUNT); END IF;

  IF (p_attr_values_tbl.po_line_id.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_attr_values_tbl.has_errors(1)='||p_attr_values_tbl.has_errors(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_attr_values_tbl.action(1)='||p_attr_values_tbl.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_attr_values_tbl.interface_attr_values_id(1)='||p_attr_values_tbl.interface_attr_values_id(1)); END IF;
  END IF;

  -- SQL What: Insert rows that have no errors, and action = PO_R12_CAT_UPG_PVT.g_action_attr_create
  -- SQL Why : To migrate data to txn tables
  -- SQL Join: none
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    INSERT INTO po_attribute_values
                         (attribute_values_id,
                          po_line_id,
                          req_template_name,
                          req_template_line_num,
                          ip_category_id,
                          inventory_item_id,
                          org_id,
                          manufacturer_part_num,
                          thumbnail_image,
                          supplier_url,
                          manufacturer_url,
                          attachment_url,
                          unspsc,
                          availability,
                          lead_time,
                          text_base_attribute1,
                          text_base_attribute2,
                          text_base_attribute3,
                          text_base_attribute4,
                          text_base_attribute5,
                          text_base_attribute6,
                          text_base_attribute7,
                          text_base_attribute8,
                          text_base_attribute9,
                          text_base_attribute10,
                          text_base_attribute11,
                          text_base_attribute12,
                          text_base_attribute13,
                          text_base_attribute14,
                          text_base_attribute15,
                          text_base_attribute16,
                          text_base_attribute17,
                          text_base_attribute18,
                          text_base_attribute19,
                          text_base_attribute20,
                          text_base_attribute21,
                          text_base_attribute22,
                          text_base_attribute23,
                          text_base_attribute24,
                          text_base_attribute25,
                          text_base_attribute26,
                          text_base_attribute27,
                          text_base_attribute28,
                          text_base_attribute29,
                          text_base_attribute30,
                          text_base_attribute31,
                          text_base_attribute32,
                          text_base_attribute33,
                          text_base_attribute34,
                          text_base_attribute35,
                          text_base_attribute36,
                          text_base_attribute37,
                          text_base_attribute38,
                          text_base_attribute39,
                          text_base_attribute40,
                          text_base_attribute41,
                          text_base_attribute42,
                          text_base_attribute43,
                          text_base_attribute44,
                          text_base_attribute45,
                          text_base_attribute46,
                          text_base_attribute47,
                          text_base_attribute48,
                          text_base_attribute49,
                          text_base_attribute50,
                          text_base_attribute51,
                          text_base_attribute52,
                          text_base_attribute53,
                          text_base_attribute54,
                          text_base_attribute55,
                          text_base_attribute56,
                          text_base_attribute57,
                          text_base_attribute58,
                          text_base_attribute59,
                          text_base_attribute60,
                          text_base_attribute61,
                          text_base_attribute62,
                          text_base_attribute63,
                          text_base_attribute64,
                          text_base_attribute65,
                          text_base_attribute66,
                          text_base_attribute67,
                          text_base_attribute68,
                          text_base_attribute69,
                          text_base_attribute70,
                          text_base_attribute71,
                          text_base_attribute72,
                          text_base_attribute73,
                          text_base_attribute74,
                          text_base_attribute75,
                          text_base_attribute76,
                          text_base_attribute77,
                          text_base_attribute78,
                          text_base_attribute79,
                          text_base_attribute80,
                          text_base_attribute81,
                          text_base_attribute82,
                          text_base_attribute83,
                          text_base_attribute84,
                          text_base_attribute85,
                          text_base_attribute86,
                          text_base_attribute87,
                          text_base_attribute88,
                          text_base_attribute89,
                          text_base_attribute90,
                          text_base_attribute91,
                          text_base_attribute92,
                          text_base_attribute93,
                          text_base_attribute94,
                          text_base_attribute95,
                          text_base_attribute96,
                          text_base_attribute97,
                          text_base_attribute98,
                          text_base_attribute99,
                          text_base_attribute100,
                          num_base_attribute1,
                          num_base_attribute2,
                          num_base_attribute3,
                          num_base_attribute4,
                          num_base_attribute5,
                          num_base_attribute6,
                          num_base_attribute7,
                          num_base_attribute8,
                          num_base_attribute9,
                          num_base_attribute10,
                          num_base_attribute11,
                          num_base_attribute12,
                          num_base_attribute13,
                          num_base_attribute14,
                          num_base_attribute15,
                          num_base_attribute16,
                          num_base_attribute17,
                          num_base_attribute18,
                          num_base_attribute19,
                          num_base_attribute20,
                          num_base_attribute21,
                          num_base_attribute22,
                          num_base_attribute23,
                          num_base_attribute24,
                          num_base_attribute25,
                          num_base_attribute26,
                          num_base_attribute27,
                          num_base_attribute28,
                          num_base_attribute29,
                          num_base_attribute30,
                          num_base_attribute31,
                          num_base_attribute32,
                          num_base_attribute33,
                          num_base_attribute34,
                          num_base_attribute35,
                          num_base_attribute36,
                          num_base_attribute37,
                          num_base_attribute38,
                          num_base_attribute39,
                          num_base_attribute40,
                          num_base_attribute41,
                          num_base_attribute42,
                          num_base_attribute43,
                          num_base_attribute44,
                          num_base_attribute45,
                          num_base_attribute46,
                          num_base_attribute47,
                          num_base_attribute48,
                          num_base_attribute49,
                          num_base_attribute50,
                          num_base_attribute51,
                          num_base_attribute52,
                          num_base_attribute53,
                          num_base_attribute54,
                          num_base_attribute55,
                          num_base_attribute56,
                          num_base_attribute57,
                          num_base_attribute58,
                          num_base_attribute59,
                          num_base_attribute60,
                          num_base_attribute61,
                          num_base_attribute62,
                          num_base_attribute63,
                          num_base_attribute64,
                          num_base_attribute65,
                          num_base_attribute66,
                          num_base_attribute67,
                          num_base_attribute68,
                          num_base_attribute69,
                          num_base_attribute70,
                          num_base_attribute71,
                          num_base_attribute72,
                          num_base_attribute73,
                          num_base_attribute74,
                          num_base_attribute75,
                          num_base_attribute76,
                          num_base_attribute77,
                          num_base_attribute78,
                          num_base_attribute79,
                          num_base_attribute80,
                          num_base_attribute81,
                          num_base_attribute82,
                          num_base_attribute83,
                          num_base_attribute84,
                          num_base_attribute85,
                          num_base_attribute86,
                          num_base_attribute87,
                          num_base_attribute88,
                          num_base_attribute89,
                          num_base_attribute90,
                          num_base_attribute91,
                          num_base_attribute92,
                          num_base_attribute93,
                          num_base_attribute94,
                          num_base_attribute95,
                          num_base_attribute96,
                          num_base_attribute97,
                          num_base_attribute98,
                          num_base_attribute99,
                          num_base_attribute100,
                          text_cat_attribute1,
                          text_cat_attribute2,
                          text_cat_attribute3,
                          text_cat_attribute4,
                          text_cat_attribute5,
                          text_cat_attribute6,
                          text_cat_attribute7,
                          text_cat_attribute8,
                          text_cat_attribute9,
                          text_cat_attribute10,
                          text_cat_attribute11,
                          text_cat_attribute12,
                          text_cat_attribute13,
                          text_cat_attribute14,
                          text_cat_attribute15,
                          text_cat_attribute16,
                          text_cat_attribute17,
                          text_cat_attribute18,
                          text_cat_attribute19,
                          text_cat_attribute20,
                          text_cat_attribute21,
                          text_cat_attribute22,
                          text_cat_attribute23,
                          text_cat_attribute24,
                          text_cat_attribute25,
                          text_cat_attribute26,
                          text_cat_attribute27,
                          text_cat_attribute28,
                          text_cat_attribute29,
                          text_cat_attribute30,
                          text_cat_attribute31,
                          text_cat_attribute32,
                          text_cat_attribute33,
                          text_cat_attribute34,
                          text_cat_attribute35,
                          text_cat_attribute36,
                          text_cat_attribute37,
                          text_cat_attribute38,
                          text_cat_attribute39,
                          text_cat_attribute40,
                          text_cat_attribute41,
                          text_cat_attribute42,
                          text_cat_attribute43,
                          text_cat_attribute44,
                          text_cat_attribute45,
                          text_cat_attribute46,
                          text_cat_attribute47,
                          text_cat_attribute48,
                          text_cat_attribute49,
                          text_cat_attribute50,
                          num_cat_attribute1,
                          num_cat_attribute2,
                          num_cat_attribute3,
                          num_cat_attribute4,
                          num_cat_attribute5,
                          num_cat_attribute6,
                          num_cat_attribute7,
                          num_cat_attribute8,
                          num_cat_attribute9,
                          num_cat_attribute10,
                          num_cat_attribute11,
                          num_cat_attribute12,
                          num_cat_attribute13,
                          num_cat_attribute14,
                          num_cat_attribute15,
                          num_cat_attribute16,
                          num_cat_attribute17,
                          num_cat_attribute18,
                          num_cat_attribute19,
                          num_cat_attribute20,
                          num_cat_attribute21,
                          num_cat_attribute22,
                          num_cat_attribute23,
                          num_cat_attribute24,
                          num_cat_attribute25,
                          num_cat_attribute26,
                          num_cat_attribute27,
                          num_cat_attribute28,
                          num_cat_attribute29,
                          num_cat_attribute30,
                          num_cat_attribute31,
                          num_cat_attribute32,
                          num_cat_attribute33,
                          num_cat_attribute34,
                          num_cat_attribute35,
                          num_cat_attribute36,
                          num_cat_attribute37,
                          num_cat_attribute38,
                          num_cat_attribute39,
                          num_cat_attribute40,
                          num_cat_attribute41,
                          num_cat_attribute42,
                          num_cat_attribute43,
                          num_cat_attribute44,
                          num_cat_attribute45,
                          num_cat_attribute46,
                          num_cat_attribute47,
                          num_cat_attribute48,
                          num_cat_attribute49,
                          num_cat_attribute50,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          created_by,
                          creation_date,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          last_updated_program
                         )
    -- Bug 5677911: Added the hint for performance reason.
    SELECT /*+ INDEX(POAVI, PO_ATTR_VALUES_INT_U1)*/
           PO_ATTRIBUTE_VALUES_S.nextval,

           -- ECO bug 4738058
           --p_attr_values_tbl.po_line_id(i),
          --bug 7245624 added nvl condition
           Nvl( POLI.po_line_id,-2),

           p_attr_values_tbl.req_template_name(i),
           p_attr_values_tbl.req_template_line_num(i),
           p_attr_values_tbl.ip_category_id(i),
           p_attr_values_tbl.inventory_item_id(i),
           p_attr_values_tbl.org_id(i),
           p_attr_values_tbl.manufacturer_part_num(i),
           p_attr_values_tbl.thumbnail_image(i),
           p_attr_values_tbl.supplier_url(i),
           p_attr_values_tbl.manufacturer_url(i),
           p_attr_values_tbl.attachment_url(i),
           p_attr_values_tbl.unspsc(i),
           p_attr_values_tbl.availability(i),
           p_attr_values_tbl.lead_time(i),
           p_attr_values_tbl.text_base_attribute1(i),
           p_attr_values_tbl.text_base_attribute2(i),
           p_attr_values_tbl.text_base_attribute3(i),
           p_attr_values_tbl.text_base_attribute4(i),
           p_attr_values_tbl.text_base_attribute5(i),
           p_attr_values_tbl.text_base_attribute6(i),
           p_attr_values_tbl.text_base_attribute7(i),
           p_attr_values_tbl.text_base_attribute8(i),
           p_attr_values_tbl.text_base_attribute9(i),
           p_attr_values_tbl.text_base_attribute10(i),
           p_attr_values_tbl.text_base_attribute11(i),
           p_attr_values_tbl.text_base_attribute12(i),
           p_attr_values_tbl.text_base_attribute13(i),
           p_attr_values_tbl.text_base_attribute14(i),
           p_attr_values_tbl.text_base_attribute15(i),
           p_attr_values_tbl.text_base_attribute16(i),
           p_attr_values_tbl.text_base_attribute17(i),
           p_attr_values_tbl.text_base_attribute18(i),
           p_attr_values_tbl.text_base_attribute19(i),
           p_attr_values_tbl.text_base_attribute20(i),
           p_attr_values_tbl.text_base_attribute21(i),
           p_attr_values_tbl.text_base_attribute22(i),
           p_attr_values_tbl.text_base_attribute23(i),
           p_attr_values_tbl.text_base_attribute24(i),
           p_attr_values_tbl.text_base_attribute25(i),
           p_attr_values_tbl.text_base_attribute26(i),
           p_attr_values_tbl.text_base_attribute27(i),
           p_attr_values_tbl.text_base_attribute28(i),
           p_attr_values_tbl.text_base_attribute29(i),
           p_attr_values_tbl.text_base_attribute30(i),
           p_attr_values_tbl.text_base_attribute31(i),
           p_attr_values_tbl.text_base_attribute32(i),
           p_attr_values_tbl.text_base_attribute33(i),
           p_attr_values_tbl.text_base_attribute34(i),
           p_attr_values_tbl.text_base_attribute35(i),
           p_attr_values_tbl.text_base_attribute36(i),
           p_attr_values_tbl.text_base_attribute37(i),
           p_attr_values_tbl.text_base_attribute38(i),
           p_attr_values_tbl.text_base_attribute39(i),
           p_attr_values_tbl.text_base_attribute40(i),
           p_attr_values_tbl.text_base_attribute41(i),
           p_attr_values_tbl.text_base_attribute42(i),
           p_attr_values_tbl.text_base_attribute43(i),
           p_attr_values_tbl.text_base_attribute44(i),
           p_attr_values_tbl.text_base_attribute45(i),
           p_attr_values_tbl.text_base_attribute46(i),
           p_attr_values_tbl.text_base_attribute47(i),
           p_attr_values_tbl.text_base_attribute48(i),
           p_attr_values_tbl.text_base_attribute49(i),
           p_attr_values_tbl.text_base_attribute50(i),
           p_attr_values_tbl.text_base_attribute51(i),
           p_attr_values_tbl.text_base_attribute52(i),
           p_attr_values_tbl.text_base_attribute53(i),
           p_attr_values_tbl.text_base_attribute54(i),
           p_attr_values_tbl.text_base_attribute55(i),
           p_attr_values_tbl.text_base_attribute56(i),
           p_attr_values_tbl.text_base_attribute57(i),
           p_attr_values_tbl.text_base_attribute58(i),
           p_attr_values_tbl.text_base_attribute59(i),
           p_attr_values_tbl.text_base_attribute60(i),
           p_attr_values_tbl.text_base_attribute61(i),
           p_attr_values_tbl.text_base_attribute62(i),
           p_attr_values_tbl.text_base_attribute63(i),
           p_attr_values_tbl.text_base_attribute64(i),
           p_attr_values_tbl.text_base_attribute65(i),
           p_attr_values_tbl.text_base_attribute66(i),
           p_attr_values_tbl.text_base_attribute67(i),
           p_attr_values_tbl.text_base_attribute68(i),
           p_attr_values_tbl.text_base_attribute69(i),
           p_attr_values_tbl.text_base_attribute70(i),
           p_attr_values_tbl.text_base_attribute71(i),
           p_attr_values_tbl.text_base_attribute72(i),
           p_attr_values_tbl.text_base_attribute73(i),
           p_attr_values_tbl.text_base_attribute74(i),
           p_attr_values_tbl.text_base_attribute75(i),
           p_attr_values_tbl.text_base_attribute76(i),
           p_attr_values_tbl.text_base_attribute77(i),
           p_attr_values_tbl.text_base_attribute78(i),
           p_attr_values_tbl.text_base_attribute79(i),
           p_attr_values_tbl.text_base_attribute80(i),
           p_attr_values_tbl.text_base_attribute81(i),
           p_attr_values_tbl.text_base_attribute82(i),
           p_attr_values_tbl.text_base_attribute83(i),
           p_attr_values_tbl.text_base_attribute84(i),
           p_attr_values_tbl.text_base_attribute85(i),
           p_attr_values_tbl.text_base_attribute86(i),
           p_attr_values_tbl.text_base_attribute87(i),
           p_attr_values_tbl.text_base_attribute88(i),
           p_attr_values_tbl.text_base_attribute89(i),
           p_attr_values_tbl.text_base_attribute90(i),
           p_attr_values_tbl.text_base_attribute91(i),
           p_attr_values_tbl.text_base_attribute92(i),
           p_attr_values_tbl.text_base_attribute93(i),
           p_attr_values_tbl.text_base_attribute94(i),
           p_attr_values_tbl.text_base_attribute95(i),
           p_attr_values_tbl.text_base_attribute96(i),
           p_attr_values_tbl.text_base_attribute97(i),
           p_attr_values_tbl.text_base_attribute98(i),
           p_attr_values_tbl.text_base_attribute99(i),
           p_attr_values_tbl.text_base_attribute100(i),
           p_attr_values_tbl.num_base_attribute1(i),
           p_attr_values_tbl.num_base_attribute2(i),
           p_attr_values_tbl.num_base_attribute3(i),
           p_attr_values_tbl.num_base_attribute4(i),
           p_attr_values_tbl.num_base_attribute5(i),
           p_attr_values_tbl.num_base_attribute6(i),
           p_attr_values_tbl.num_base_attribute7(i),
           p_attr_values_tbl.num_base_attribute8(i),
           p_attr_values_tbl.num_base_attribute9(i),
           p_attr_values_tbl.num_base_attribute10(i),
           p_attr_values_tbl.num_base_attribute11(i),
           p_attr_values_tbl.num_base_attribute12(i),
           p_attr_values_tbl.num_base_attribute13(i),
           p_attr_values_tbl.num_base_attribute14(i),
           p_attr_values_tbl.num_base_attribute15(i),
           p_attr_values_tbl.num_base_attribute16(i),
           p_attr_values_tbl.num_base_attribute17(i),
           p_attr_values_tbl.num_base_attribute18(i),
           p_attr_values_tbl.num_base_attribute19(i),
           p_attr_values_tbl.num_base_attribute20(i),
           p_attr_values_tbl.num_base_attribute21(i),
           p_attr_values_tbl.num_base_attribute22(i),
           p_attr_values_tbl.num_base_attribute23(i),
           p_attr_values_tbl.num_base_attribute24(i),
           p_attr_values_tbl.num_base_attribute25(i),
           p_attr_values_tbl.num_base_attribute26(i),
           p_attr_values_tbl.num_base_attribute27(i),
           p_attr_values_tbl.num_base_attribute28(i),
           p_attr_values_tbl.num_base_attribute29(i),
           p_attr_values_tbl.num_base_attribute30(i),
           p_attr_values_tbl.num_base_attribute31(i),
           p_attr_values_tbl.num_base_attribute32(i),
           p_attr_values_tbl.num_base_attribute33(i),
           p_attr_values_tbl.num_base_attribute34(i),
           p_attr_values_tbl.num_base_attribute35(i),
           p_attr_values_tbl.num_base_attribute36(i),
           p_attr_values_tbl.num_base_attribute37(i),
           p_attr_values_tbl.num_base_attribute38(i),
           p_attr_values_tbl.num_base_attribute39(i),
           p_attr_values_tbl.num_base_attribute40(i),
           p_attr_values_tbl.num_base_attribute41(i),
           p_attr_values_tbl.num_base_attribute42(i),
           p_attr_values_tbl.num_base_attribute43(i),
           p_attr_values_tbl.num_base_attribute44(i),
           p_attr_values_tbl.num_base_attribute45(i),
           p_attr_values_tbl.num_base_attribute46(i),
           p_attr_values_tbl.num_base_attribute47(i),
           p_attr_values_tbl.num_base_attribute48(i),
           p_attr_values_tbl.num_base_attribute49(i),
           p_attr_values_tbl.num_base_attribute50(i),
           p_attr_values_tbl.num_base_attribute51(i),
           p_attr_values_tbl.num_base_attribute52(i),
           p_attr_values_tbl.num_base_attribute53(i),
           p_attr_values_tbl.num_base_attribute54(i),
           p_attr_values_tbl.num_base_attribute55(i),
           p_attr_values_tbl.num_base_attribute56(i),
           p_attr_values_tbl.num_base_attribute57(i),
           p_attr_values_tbl.num_base_attribute58(i),
           p_attr_values_tbl.num_base_attribute59(i),
           p_attr_values_tbl.num_base_attribute60(i),
           p_attr_values_tbl.num_base_attribute61(i),
           p_attr_values_tbl.num_base_attribute62(i),
           p_attr_values_tbl.num_base_attribute63(i),
           p_attr_values_tbl.num_base_attribute64(i),
           p_attr_values_tbl.num_base_attribute65(i),
           p_attr_values_tbl.num_base_attribute66(i),
           p_attr_values_tbl.num_base_attribute67(i),
           p_attr_values_tbl.num_base_attribute68(i),
           p_attr_values_tbl.num_base_attribute69(i),
           p_attr_values_tbl.num_base_attribute70(i),
           p_attr_values_tbl.num_base_attribute71(i),
           p_attr_values_tbl.num_base_attribute72(i),
           p_attr_values_tbl.num_base_attribute73(i),
           p_attr_values_tbl.num_base_attribute74(i),
           p_attr_values_tbl.num_base_attribute75(i),
           p_attr_values_tbl.num_base_attribute76(i),
           p_attr_values_tbl.num_base_attribute77(i),
           p_attr_values_tbl.num_base_attribute78(i),
           p_attr_values_tbl.num_base_attribute79(i),
           p_attr_values_tbl.num_base_attribute80(i),
           p_attr_values_tbl.num_base_attribute81(i),
           p_attr_values_tbl.num_base_attribute82(i),
           p_attr_values_tbl.num_base_attribute83(i),
           p_attr_values_tbl.num_base_attribute84(i),
           p_attr_values_tbl.num_base_attribute85(i),
           p_attr_values_tbl.num_base_attribute86(i),
           p_attr_values_tbl.num_base_attribute87(i),
           p_attr_values_tbl.num_base_attribute88(i),
           p_attr_values_tbl.num_base_attribute89(i),
           p_attr_values_tbl.num_base_attribute90(i),
           p_attr_values_tbl.num_base_attribute91(i),
           p_attr_values_tbl.num_base_attribute92(i),
           p_attr_values_tbl.num_base_attribute93(i),
           p_attr_values_tbl.num_base_attribute94(i),
           p_attr_values_tbl.num_base_attribute95(i),
           p_attr_values_tbl.num_base_attribute96(i),
           p_attr_values_tbl.num_base_attribute97(i),
           p_attr_values_tbl.num_base_attribute98(i),
           p_attr_values_tbl.num_base_attribute99(i),
           p_attr_values_tbl.num_base_attribute100(i),
           p_attr_values_tbl.text_cat_attribute1(i),
           p_attr_values_tbl.text_cat_attribute2(i),
           p_attr_values_tbl.text_cat_attribute3(i),
           p_attr_values_tbl.text_cat_attribute4(i),
           p_attr_values_tbl.text_cat_attribute5(i),
           p_attr_values_tbl.text_cat_attribute6(i),
           p_attr_values_tbl.text_cat_attribute7(i),
           p_attr_values_tbl.text_cat_attribute8(i),
           p_attr_values_tbl.text_cat_attribute9(i),
           p_attr_values_tbl.text_cat_attribute10(i),
           p_attr_values_tbl.text_cat_attribute11(i),
           p_attr_values_tbl.text_cat_attribute12(i),
           p_attr_values_tbl.text_cat_attribute13(i),
           p_attr_values_tbl.text_cat_attribute14(i),
           p_attr_values_tbl.text_cat_attribute15(i),
           p_attr_values_tbl.text_cat_attribute16(i),
           p_attr_values_tbl.text_cat_attribute17(i),
           p_attr_values_tbl.text_cat_attribute18(i),
           p_attr_values_tbl.text_cat_attribute19(i),
           p_attr_values_tbl.text_cat_attribute20(i),
           p_attr_values_tbl.text_cat_attribute21(i),
           p_attr_values_tbl.text_cat_attribute22(i),
           p_attr_values_tbl.text_cat_attribute23(i),
           p_attr_values_tbl.text_cat_attribute24(i),
           p_attr_values_tbl.text_cat_attribute25(i),
           p_attr_values_tbl.text_cat_attribute26(i),
           p_attr_values_tbl.text_cat_attribute27(i),
           p_attr_values_tbl.text_cat_attribute28(i),
           p_attr_values_tbl.text_cat_attribute29(i),
           p_attr_values_tbl.text_cat_attribute30(i),
           p_attr_values_tbl.text_cat_attribute31(i),
           p_attr_values_tbl.text_cat_attribute32(i),
           p_attr_values_tbl.text_cat_attribute33(i),
           p_attr_values_tbl.text_cat_attribute34(i),
           p_attr_values_tbl.text_cat_attribute35(i),
           p_attr_values_tbl.text_cat_attribute36(i),
           p_attr_values_tbl.text_cat_attribute37(i),
           p_attr_values_tbl.text_cat_attribute38(i),
           p_attr_values_tbl.text_cat_attribute39(i),
           p_attr_values_tbl.text_cat_attribute40(i),
           p_attr_values_tbl.text_cat_attribute41(i),
           p_attr_values_tbl.text_cat_attribute42(i),
           p_attr_values_tbl.text_cat_attribute43(i),
           p_attr_values_tbl.text_cat_attribute44(i),
           p_attr_values_tbl.text_cat_attribute45(i),
           p_attr_values_tbl.text_cat_attribute46(i),
           p_attr_values_tbl.text_cat_attribute47(i),
           p_attr_values_tbl.text_cat_attribute48(i),
           p_attr_values_tbl.text_cat_attribute49(i),
           p_attr_values_tbl.text_cat_attribute50(i),
           p_attr_values_tbl.num_cat_attribute1(i),
           p_attr_values_tbl.num_cat_attribute2(i),
           p_attr_values_tbl.num_cat_attribute3(i),
           p_attr_values_tbl.num_cat_attribute4(i),
           p_attr_values_tbl.num_cat_attribute5(i),
           p_attr_values_tbl.num_cat_attribute6(i),
           p_attr_values_tbl.num_cat_attribute7(i),
           p_attr_values_tbl.num_cat_attribute8(i),
           p_attr_values_tbl.num_cat_attribute9(i),
           p_attr_values_tbl.num_cat_attribute10(i),
           p_attr_values_tbl.num_cat_attribute11(i),
           p_attr_values_tbl.num_cat_attribute12(i),
           p_attr_values_tbl.num_cat_attribute13(i),
           p_attr_values_tbl.num_cat_attribute14(i),
           p_attr_values_tbl.num_cat_attribute15(i),
           p_attr_values_tbl.num_cat_attribute16(i),
           p_attr_values_tbl.num_cat_attribute17(i),
           p_attr_values_tbl.num_cat_attribute18(i),
           p_attr_values_tbl.num_cat_attribute19(i),
           p_attr_values_tbl.num_cat_attribute20(i),
           p_attr_values_tbl.num_cat_attribute21(i),
           p_attr_values_tbl.num_cat_attribute22(i),
           p_attr_values_tbl.num_cat_attribute23(i),
           p_attr_values_tbl.num_cat_attribute24(i),
           p_attr_values_tbl.num_cat_attribute25(i),
           p_attr_values_tbl.num_cat_attribute26(i),
           p_attr_values_tbl.num_cat_attribute27(i),
           p_attr_values_tbl.num_cat_attribute28(i),
           p_attr_values_tbl.num_cat_attribute29(i),
           p_attr_values_tbl.num_cat_attribute30(i),
           p_attr_values_tbl.num_cat_attribute31(i),
           p_attr_values_tbl.num_cat_attribute32(i),
           p_attr_values_tbl.num_cat_attribute33(i),
           p_attr_values_tbl.num_cat_attribute34(i),
           p_attr_values_tbl.num_cat_attribute35(i),
           p_attr_values_tbl.num_cat_attribute36(i),
           p_attr_values_tbl.num_cat_attribute37(i),
           p_attr_values_tbl.num_cat_attribute38(i),
           p_attr_values_tbl.num_cat_attribute39(i),
           p_attr_values_tbl.num_cat_attribute40(i),
           p_attr_values_tbl.num_cat_attribute41(i),
           p_attr_values_tbl.num_cat_attribute42(i),
           p_attr_values_tbl.num_cat_attribute43(i),
           p_attr_values_tbl.num_cat_attribute44(i),
           p_attr_values_tbl.num_cat_attribute45(i),
           p_attr_values_tbl.num_cat_attribute46(i),
           p_attr_values_tbl.num_cat_attribute47(i),
           p_attr_values_tbl.num_cat_attribute48(i),
           p_attr_values_tbl.num_cat_attribute49(i),
           p_attr_values_tbl.num_cat_attribute50(i),
           FND_GLOBAL.login_id, -- last_update_login
           FND_GLOBAL.user_id, -- last_updated_by
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate, -- creation_date
           FND_GLOBAL.conc_request_id, -- request_id
           p_attr_values_tbl.program_application_id(i),
           p_attr_values_tbl.program_id(i),
           p_attr_values_tbl.program_update_date(i),
           g_R12_MIGRATION_PROGRAM -- last_updated_program
    FROM  PO_ATTR_VALUES_INTERFACE POAVI,
          PO_LINES_INTERFACE POLI -- ECO bug 4738058
    WHERE POAVI.interface_attr_values_id = p_attr_values_tbl.interface_attr_values_id(i)
      AND p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = PO_R12_CAT_UPG_PVT.g_action_attr_create
      -- ECO bug 4738058
      AND POLI.interface_line_id = POAVI.interface_line_id;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Attr inserted='||SQL%rowcount); END IF;

  l_progress := '020';
  -- SQL What: Update the process_code on interface table as PROCESSED
  -- SQL Why : To mark the rows as successfully inserted
  -- SQL Join: interface_attr_values_id
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    UPDATE PO_ATTR_VALUES_INTERFACE POAVI
    SET /*+ INDEX(POAVI, PO_ATTR_VALUES_INT_U1)*/
      process_code = g_PROCESS_CODE_PROCESSED
      -- ECO bug 4738058
      , po_line_id = (SELECT POLI.po_line_id
                      FROM PO_LINES_INTERFACE POLI
                      WHERE POLI.interface_line_id = POAVI.interface_line_id)
    WHERE POAVI.interface_attr_values_id = p_attr_values_tbl.interface_attr_values_id(i)
      AND p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = PO_R12_CAT_UPG_PVT.g_action_attr_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Interface Attr PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END insert_attributes;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_attributes
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Updates a batch of attr values given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attr_values_tbl
  --  A table of plsql records containing a batch of attr values
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_attributes
(
   p_attr_values_tbl    IN record_of_attr_values_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Update Rows that do not have errors. Overwrite all values
  --           from interface table to transaction table
  -- SQL Why : To update the po_attribute_values columns
  -- SQL Join: po_line_id

  -- Bug#5389286: Removed unnecessary OR conditions in the criteria
  -- For an update action, iP will always populate the
  -- po_line_id/req_template_name/req_template_line_num/org_id  in the
  -- attr/attr_tlp interface tables
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    UPDATE po_attribute_values
    SET
      ip_category_id = p_attr_values_tbl.ip_category_id(i),
      inventory_item_id = p_attr_values_tbl.inventory_item_id(i),
      manufacturer_part_num = p_attr_values_tbl.manufacturer_part_num(i),
      thumbnail_image = p_attr_values_tbl.thumbnail_image(i),
      supplier_url = p_attr_values_tbl.supplier_url(i),
      manufacturer_url = p_attr_values_tbl.manufacturer_url(i),
      attachment_url = p_attr_values_tbl.attachment_url(i),
      unspsc = p_attr_values_tbl.unspsc(i),
      availability = p_attr_values_tbl.availability(i),
      lead_time = p_attr_values_tbl.lead_time(i),
      text_base_attribute1 = p_attr_values_tbl.text_base_attribute1(i),
      text_base_attribute2 = p_attr_values_tbl.text_base_attribute2(i),
      text_base_attribute3 = p_attr_values_tbl.text_base_attribute3(i),
      text_base_attribute4 = p_attr_values_tbl.text_base_attribute4(i),
      text_base_attribute5 = p_attr_values_tbl.text_base_attribute5(i),
      text_base_attribute6 = p_attr_values_tbl.text_base_attribute6(i),
      text_base_attribute7 = p_attr_values_tbl.text_base_attribute7(i),
      text_base_attribute8 = p_attr_values_tbl.text_base_attribute8(i),
      text_base_attribute9 = p_attr_values_tbl.text_base_attribute9(i),
      text_base_attribute10 = p_attr_values_tbl.text_base_attribute10(i),
      text_base_attribute11 = p_attr_values_tbl.text_base_attribute11(i),
      text_base_attribute12 = p_attr_values_tbl.text_base_attribute12(i),
      text_base_attribute13 = p_attr_values_tbl.text_base_attribute13(i),
      text_base_attribute14 = p_attr_values_tbl.text_base_attribute14(i),
      text_base_attribute15 = p_attr_values_tbl.text_base_attribute15(i),
      text_base_attribute16 = p_attr_values_tbl.text_base_attribute16(i),
      text_base_attribute17 = p_attr_values_tbl.text_base_attribute17(i),
      text_base_attribute18 = p_attr_values_tbl.text_base_attribute18(i),
      text_base_attribute19 = p_attr_values_tbl.text_base_attribute19(i),
      text_base_attribute20 = p_attr_values_tbl.text_base_attribute20(i),
      text_base_attribute21 = p_attr_values_tbl.text_base_attribute21(i),
      text_base_attribute22 = p_attr_values_tbl.text_base_attribute22(i),
      text_base_attribute23 = p_attr_values_tbl.text_base_attribute23(i),
      text_base_attribute24 = p_attr_values_tbl.text_base_attribute24(i),
      text_base_attribute25 = p_attr_values_tbl.text_base_attribute25(i),
      text_base_attribute26 = p_attr_values_tbl.text_base_attribute26(i),
      text_base_attribute27 = p_attr_values_tbl.text_base_attribute27(i),
      text_base_attribute28 = p_attr_values_tbl.text_base_attribute28(i),
      text_base_attribute29 = p_attr_values_tbl.text_base_attribute29(i),
      text_base_attribute30 = p_attr_values_tbl.text_base_attribute30(i),
      text_base_attribute31 = p_attr_values_tbl.text_base_attribute31(i),
      text_base_attribute32 = p_attr_values_tbl.text_base_attribute32(i),
      text_base_attribute33 = p_attr_values_tbl.text_base_attribute33(i),
      text_base_attribute34 = p_attr_values_tbl.text_base_attribute34(i),
      text_base_attribute35 = p_attr_values_tbl.text_base_attribute35(i),
      text_base_attribute36 = p_attr_values_tbl.text_base_attribute36(i),
      text_base_attribute37 = p_attr_values_tbl.text_base_attribute37(i),
      text_base_attribute38 = p_attr_values_tbl.text_base_attribute38(i),
      text_base_attribute39 = p_attr_values_tbl.text_base_attribute39(i),
      text_base_attribute40 = p_attr_values_tbl.text_base_attribute40(i),
      text_base_attribute41 = p_attr_values_tbl.text_base_attribute41(i),
      text_base_attribute42 = p_attr_values_tbl.text_base_attribute42(i),
      text_base_attribute43 = p_attr_values_tbl.text_base_attribute43(i),
      text_base_attribute44 = p_attr_values_tbl.text_base_attribute44(i),
      text_base_attribute45 = p_attr_values_tbl.text_base_attribute45(i),
      text_base_attribute46 = p_attr_values_tbl.text_base_attribute46(i),
      text_base_attribute47 = p_attr_values_tbl.text_base_attribute47(i),
      text_base_attribute48 = p_attr_values_tbl.text_base_attribute48(i),
      text_base_attribute49 = p_attr_values_tbl.text_base_attribute49(i),
      text_base_attribute50 = p_attr_values_tbl.text_base_attribute50(i),
      text_base_attribute51 = p_attr_values_tbl.text_base_attribute51(i),
      text_base_attribute52 = p_attr_values_tbl.text_base_attribute52(i),
      text_base_attribute53 = p_attr_values_tbl.text_base_attribute53(i),
      text_base_attribute54 = p_attr_values_tbl.text_base_attribute54(i),
      text_base_attribute55 = p_attr_values_tbl.text_base_attribute55(i),
      text_base_attribute56 = p_attr_values_tbl.text_base_attribute56(i),
      text_base_attribute57 = p_attr_values_tbl.text_base_attribute57(i),
      text_base_attribute58 = p_attr_values_tbl.text_base_attribute58(i),
      text_base_attribute59 = p_attr_values_tbl.text_base_attribute59(i),
      text_base_attribute60 = p_attr_values_tbl.text_base_attribute60(i),
      text_base_attribute61 = p_attr_values_tbl.text_base_attribute61(i),
      text_base_attribute62 = p_attr_values_tbl.text_base_attribute62(i),
      text_base_attribute63 = p_attr_values_tbl.text_base_attribute63(i),
      text_base_attribute64 = p_attr_values_tbl.text_base_attribute64(i),
      text_base_attribute65 = p_attr_values_tbl.text_base_attribute65(i),
      text_base_attribute66 = p_attr_values_tbl.text_base_attribute66(i),
      text_base_attribute67 = p_attr_values_tbl.text_base_attribute67(i),
      text_base_attribute68 = p_attr_values_tbl.text_base_attribute68(i),
      text_base_attribute69 = p_attr_values_tbl.text_base_attribute69(i),
      text_base_attribute70 = p_attr_values_tbl.text_base_attribute70(i),
      text_base_attribute71 = p_attr_values_tbl.text_base_attribute71(i),
      text_base_attribute72 = p_attr_values_tbl.text_base_attribute72(i),
      text_base_attribute73 = p_attr_values_tbl.text_base_attribute73(i),
      text_base_attribute74 = p_attr_values_tbl.text_base_attribute74(i),
      text_base_attribute75 = p_attr_values_tbl.text_base_attribute75(i),
      text_base_attribute76 = p_attr_values_tbl.text_base_attribute76(i),
      text_base_attribute77 = p_attr_values_tbl.text_base_attribute77(i),
      text_base_attribute78 = p_attr_values_tbl.text_base_attribute78(i),
      text_base_attribute79 = p_attr_values_tbl.text_base_attribute79(i),
      text_base_attribute80 = p_attr_values_tbl.text_base_attribute80(i),
      text_base_attribute81 = p_attr_values_tbl.text_base_attribute81(i),
      text_base_attribute82 = p_attr_values_tbl.text_base_attribute82(i),
      text_base_attribute83 = p_attr_values_tbl.text_base_attribute83(i),
      text_base_attribute84 = p_attr_values_tbl.text_base_attribute84(i),
      text_base_attribute85 = p_attr_values_tbl.text_base_attribute85(i),
      text_base_attribute86 = p_attr_values_tbl.text_base_attribute86(i),
      text_base_attribute87 = p_attr_values_tbl.text_base_attribute87(i),
      text_base_attribute88 = p_attr_values_tbl.text_base_attribute88(i),
      text_base_attribute89 = p_attr_values_tbl.text_base_attribute89(i),
      text_base_attribute90 = p_attr_values_tbl.text_base_attribute90(i),
      text_base_attribute91 = p_attr_values_tbl.text_base_attribute91(i),
      text_base_attribute92 = p_attr_values_tbl.text_base_attribute92(i),
      text_base_attribute93 = p_attr_values_tbl.text_base_attribute93(i),
      text_base_attribute94 = p_attr_values_tbl.text_base_attribute94(i),
      text_base_attribute95 = p_attr_values_tbl.text_base_attribute95(i),
      text_base_attribute96 = p_attr_values_tbl.text_base_attribute96(i),
      text_base_attribute97 = p_attr_values_tbl.text_base_attribute97(i),
      text_base_attribute98 = p_attr_values_tbl.text_base_attribute98(i),
      text_base_attribute99 = p_attr_values_tbl.text_base_attribute99(i),
      text_base_attribute100 = p_attr_values_tbl.text_base_attribute100(i),
      num_base_attribute1 = p_attr_values_tbl.num_base_attribute1(i),
      num_base_attribute2 = p_attr_values_tbl.num_base_attribute2(i),
      num_base_attribute3 = p_attr_values_tbl.num_base_attribute3(i),
      num_base_attribute4 = p_attr_values_tbl.num_base_attribute4(i),
      num_base_attribute5 = p_attr_values_tbl.num_base_attribute5(i),
      num_base_attribute6 = p_attr_values_tbl.num_base_attribute6(i),
      num_base_attribute7 = p_attr_values_tbl.num_base_attribute7(i),
      num_base_attribute8 = p_attr_values_tbl.num_base_attribute8(i),
      num_base_attribute9 = p_attr_values_tbl.num_base_attribute9(i),
      num_base_attribute10 = p_attr_values_tbl.num_base_attribute10(i),
      num_base_attribute11 = p_attr_values_tbl.num_base_attribute11(i),
      num_base_attribute12 = p_attr_values_tbl.num_base_attribute12(i),
      num_base_attribute13 = p_attr_values_tbl.num_base_attribute13(i),
      num_base_attribute14 = p_attr_values_tbl.num_base_attribute14(i),
      num_base_attribute15 = p_attr_values_tbl.num_base_attribute15(i),
      num_base_attribute16 = p_attr_values_tbl.num_base_attribute16(i),
      num_base_attribute17 = p_attr_values_tbl.num_base_attribute17(i),
      num_base_attribute18 = p_attr_values_tbl.num_base_attribute18(i),
      num_base_attribute19 = p_attr_values_tbl.num_base_attribute19(i),
      num_base_attribute20 = p_attr_values_tbl.num_base_attribute20(i),
      num_base_attribute21 = p_attr_values_tbl.num_base_attribute21(i),
      num_base_attribute22 = p_attr_values_tbl.num_base_attribute22(i),
      num_base_attribute23 = p_attr_values_tbl.num_base_attribute23(i),
      num_base_attribute24 = p_attr_values_tbl.num_base_attribute24(i),
      num_base_attribute25 = p_attr_values_tbl.num_base_attribute25(i),
      num_base_attribute26 = p_attr_values_tbl.num_base_attribute26(i),
      num_base_attribute27 = p_attr_values_tbl.num_base_attribute27(i),
      num_base_attribute28 = p_attr_values_tbl.num_base_attribute28(i),
      num_base_attribute29 = p_attr_values_tbl.num_base_attribute29(i),
      num_base_attribute30 = p_attr_values_tbl.num_base_attribute30(i),
      num_base_attribute31 = p_attr_values_tbl.num_base_attribute31(i),
      num_base_attribute32 = p_attr_values_tbl.num_base_attribute32(i),
      num_base_attribute33 = p_attr_values_tbl.num_base_attribute33(i),
      num_base_attribute34 = p_attr_values_tbl.num_base_attribute34(i),
      num_base_attribute35 = p_attr_values_tbl.num_base_attribute35(i),
      num_base_attribute36 = p_attr_values_tbl.num_base_attribute36(i),
      num_base_attribute37 = p_attr_values_tbl.num_base_attribute37(i),
      num_base_attribute38 = p_attr_values_tbl.num_base_attribute38(i),
      num_base_attribute39 = p_attr_values_tbl.num_base_attribute39(i),
      num_base_attribute40 = p_attr_values_tbl.num_base_attribute40(i),
      num_base_attribute41 = p_attr_values_tbl.num_base_attribute41(i),
      num_base_attribute42 = p_attr_values_tbl.num_base_attribute42(i),
      num_base_attribute43 = p_attr_values_tbl.num_base_attribute43(i),
      num_base_attribute44 = p_attr_values_tbl.num_base_attribute44(i),
      num_base_attribute45 = p_attr_values_tbl.num_base_attribute45(i),
      num_base_attribute46 = p_attr_values_tbl.num_base_attribute46(i),
      num_base_attribute47 = p_attr_values_tbl.num_base_attribute47(i),
      num_base_attribute48 = p_attr_values_tbl.num_base_attribute48(i),
      num_base_attribute49 = p_attr_values_tbl.num_base_attribute49(i),
      num_base_attribute50 = p_attr_values_tbl.num_base_attribute50(i),
      num_base_attribute51 = p_attr_values_tbl.num_base_attribute51(i),
      num_base_attribute52 = p_attr_values_tbl.num_base_attribute52(i),
      num_base_attribute53 = p_attr_values_tbl.num_base_attribute53(i),
      num_base_attribute54 = p_attr_values_tbl.num_base_attribute54(i),
      num_base_attribute55 = p_attr_values_tbl.num_base_attribute55(i),
      num_base_attribute56 = p_attr_values_tbl.num_base_attribute56(i),
      num_base_attribute57 = p_attr_values_tbl.num_base_attribute57(i),
      num_base_attribute58 = p_attr_values_tbl.num_base_attribute58(i),
      num_base_attribute59 = p_attr_values_tbl.num_base_attribute59(i),
      num_base_attribute60 = p_attr_values_tbl.num_base_attribute60(i),
      num_base_attribute61 = p_attr_values_tbl.num_base_attribute61(i),
      num_base_attribute62 = p_attr_values_tbl.num_base_attribute62(i),
      num_base_attribute63 = p_attr_values_tbl.num_base_attribute63(i),
      num_base_attribute64 = p_attr_values_tbl.num_base_attribute64(i),
      num_base_attribute65 = p_attr_values_tbl.num_base_attribute65(i),
      num_base_attribute66 = p_attr_values_tbl.num_base_attribute66(i),
      num_base_attribute67 = p_attr_values_tbl.num_base_attribute67(i),
      num_base_attribute68 = p_attr_values_tbl.num_base_attribute68(i),
      num_base_attribute69 = p_attr_values_tbl.num_base_attribute69(i),
      num_base_attribute70 = p_attr_values_tbl.num_base_attribute70(i),
      num_base_attribute71 = p_attr_values_tbl.num_base_attribute71(i),
      num_base_attribute72 = p_attr_values_tbl.num_base_attribute72(i),
      num_base_attribute73 = p_attr_values_tbl.num_base_attribute73(i),
      num_base_attribute74 = p_attr_values_tbl.num_base_attribute74(i),
      num_base_attribute75 = p_attr_values_tbl.num_base_attribute75(i),
      num_base_attribute76 = p_attr_values_tbl.num_base_attribute76(i),
      num_base_attribute77 = p_attr_values_tbl.num_base_attribute77(i),
      num_base_attribute78 = p_attr_values_tbl.num_base_attribute78(i),
      num_base_attribute79 = p_attr_values_tbl.num_base_attribute79(i),
      num_base_attribute80 = p_attr_values_tbl.num_base_attribute80(i),
      num_base_attribute81 = p_attr_values_tbl.num_base_attribute81(i),
      num_base_attribute82 = p_attr_values_tbl.num_base_attribute82(i),
      num_base_attribute83 = p_attr_values_tbl.num_base_attribute83(i),
      num_base_attribute84 = p_attr_values_tbl.num_base_attribute84(i),
      num_base_attribute85 = p_attr_values_tbl.num_base_attribute85(i),
      num_base_attribute86 = p_attr_values_tbl.num_base_attribute86(i),
      num_base_attribute87 = p_attr_values_tbl.num_base_attribute87(i),
      num_base_attribute88 = p_attr_values_tbl.num_base_attribute88(i),
      num_base_attribute89 = p_attr_values_tbl.num_base_attribute89(i),
      num_base_attribute90 = p_attr_values_tbl.num_base_attribute90(i),
      num_base_attribute91 = p_attr_values_tbl.num_base_attribute91(i),
      num_base_attribute92 = p_attr_values_tbl.num_base_attribute92(i),
      num_base_attribute93 = p_attr_values_tbl.num_base_attribute93(i),
      num_base_attribute94 = p_attr_values_tbl.num_base_attribute94(i),
      num_base_attribute95 = p_attr_values_tbl.num_base_attribute95(i),
      num_base_attribute96 = p_attr_values_tbl.num_base_attribute96(i),
      num_base_attribute97 = p_attr_values_tbl.num_base_attribute97(i),
      num_base_attribute98 = p_attr_values_tbl.num_base_attribute98(i),
      num_base_attribute99 = p_attr_values_tbl.num_base_attribute99(i),
      num_base_attribute100 = p_attr_values_tbl.num_base_attribute100(i),
      text_cat_attribute1 = p_attr_values_tbl.text_cat_attribute1(i),
      text_cat_attribute2 = p_attr_values_tbl.text_cat_attribute2(i),
      text_cat_attribute3 = p_attr_values_tbl.text_cat_attribute3(i),
      text_cat_attribute4 = p_attr_values_tbl.text_cat_attribute4(i),
      text_cat_attribute5 = p_attr_values_tbl.text_cat_attribute5(i),
      text_cat_attribute6 = p_attr_values_tbl.text_cat_attribute6(i),
      text_cat_attribute7 = p_attr_values_tbl.text_cat_attribute7(i),
      text_cat_attribute8 = p_attr_values_tbl.text_cat_attribute8(i),
      text_cat_attribute9 = p_attr_values_tbl.text_cat_attribute9(i),
      text_cat_attribute10 = p_attr_values_tbl.text_cat_attribute10(i),
      text_cat_attribute11 = p_attr_values_tbl.text_cat_attribute11(i),
      text_cat_attribute12 = p_attr_values_tbl.text_cat_attribute12(i),
      text_cat_attribute13 = p_attr_values_tbl.text_cat_attribute13(i),
      text_cat_attribute14 = p_attr_values_tbl.text_cat_attribute14(i),
      text_cat_attribute15 = p_attr_values_tbl.text_cat_attribute15(i),
      text_cat_attribute16 = p_attr_values_tbl.text_cat_attribute16(i),
      text_cat_attribute17 = p_attr_values_tbl.text_cat_attribute17(i),
      text_cat_attribute18 = p_attr_values_tbl.text_cat_attribute18(i),
      text_cat_attribute19 = p_attr_values_tbl.text_cat_attribute19(i),
      text_cat_attribute20 = p_attr_values_tbl.text_cat_attribute20(i),
      text_cat_attribute21 = p_attr_values_tbl.text_cat_attribute21(i),
      text_cat_attribute22 = p_attr_values_tbl.text_cat_attribute22(i),
      text_cat_attribute23 = p_attr_values_tbl.text_cat_attribute23(i),
      text_cat_attribute24 = p_attr_values_tbl.text_cat_attribute24(i),
      text_cat_attribute25 = p_attr_values_tbl.text_cat_attribute25(i),
      text_cat_attribute26 = p_attr_values_tbl.text_cat_attribute26(i),
      text_cat_attribute27 = p_attr_values_tbl.text_cat_attribute27(i),
      text_cat_attribute28 = p_attr_values_tbl.text_cat_attribute28(i),
      text_cat_attribute29 = p_attr_values_tbl.text_cat_attribute29(i),
      text_cat_attribute30 = p_attr_values_tbl.text_cat_attribute30(i),
      text_cat_attribute31 = p_attr_values_tbl.text_cat_attribute31(i),
      text_cat_attribute32 = p_attr_values_tbl.text_cat_attribute32(i),
      text_cat_attribute33 = p_attr_values_tbl.text_cat_attribute33(i),
      text_cat_attribute34 = p_attr_values_tbl.text_cat_attribute34(i),
      text_cat_attribute35 = p_attr_values_tbl.text_cat_attribute35(i),
      text_cat_attribute36 = p_attr_values_tbl.text_cat_attribute36(i),
      text_cat_attribute37 = p_attr_values_tbl.text_cat_attribute37(i),
      text_cat_attribute38 = p_attr_values_tbl.text_cat_attribute38(i),
      text_cat_attribute39 = p_attr_values_tbl.text_cat_attribute39(i),
      text_cat_attribute40 = p_attr_values_tbl.text_cat_attribute40(i),
      text_cat_attribute41 = p_attr_values_tbl.text_cat_attribute41(i),
      text_cat_attribute42 = p_attr_values_tbl.text_cat_attribute42(i),
      text_cat_attribute43 = p_attr_values_tbl.text_cat_attribute43(i),
      text_cat_attribute44 = p_attr_values_tbl.text_cat_attribute44(i),
      text_cat_attribute45 = p_attr_values_tbl.text_cat_attribute45(i),
      text_cat_attribute46 = p_attr_values_tbl.text_cat_attribute46(i),
      text_cat_attribute47 = p_attr_values_tbl.text_cat_attribute47(i),
      text_cat_attribute48 = p_attr_values_tbl.text_cat_attribute48(i),
      text_cat_attribute49 = p_attr_values_tbl.text_cat_attribute49(i),
      text_cat_attribute50 = p_attr_values_tbl.text_cat_attribute50(i),
      num_cat_attribute1 = p_attr_values_tbl.num_cat_attribute1(i),
      num_cat_attribute2 = p_attr_values_tbl.num_cat_attribute2(i),
      num_cat_attribute3 = p_attr_values_tbl.num_cat_attribute3(i),
      num_cat_attribute4 = p_attr_values_tbl.num_cat_attribute4(i),
      num_cat_attribute5 = p_attr_values_tbl.num_cat_attribute5(i),
      num_cat_attribute6 = p_attr_values_tbl.num_cat_attribute6(i),
      num_cat_attribute7 = p_attr_values_tbl.num_cat_attribute7(i),
      num_cat_attribute8 = p_attr_values_tbl.num_cat_attribute8(i),
      num_cat_attribute9 = p_attr_values_tbl.num_cat_attribute9(i),
      num_cat_attribute10 = p_attr_values_tbl.num_cat_attribute10(i),
      num_cat_attribute11 = p_attr_values_tbl.num_cat_attribute11(i),
      num_cat_attribute12 = p_attr_values_tbl.num_cat_attribute12(i),
      num_cat_attribute13 = p_attr_values_tbl.num_cat_attribute13(i),
      num_cat_attribute14 = p_attr_values_tbl.num_cat_attribute14(i),
      num_cat_attribute15 = p_attr_values_tbl.num_cat_attribute15(i),
      num_cat_attribute16 = p_attr_values_tbl.num_cat_attribute16(i),
      num_cat_attribute17 = p_attr_values_tbl.num_cat_attribute17(i),
      num_cat_attribute18 = p_attr_values_tbl.num_cat_attribute18(i),
      num_cat_attribute19 = p_attr_values_tbl.num_cat_attribute19(i),
      num_cat_attribute20 = p_attr_values_tbl.num_cat_attribute20(i),
      num_cat_attribute21 = p_attr_values_tbl.num_cat_attribute21(i),
      num_cat_attribute22 = p_attr_values_tbl.num_cat_attribute22(i),
      num_cat_attribute23 = p_attr_values_tbl.num_cat_attribute23(i),
      num_cat_attribute24 = p_attr_values_tbl.num_cat_attribute24(i),
      num_cat_attribute25 = p_attr_values_tbl.num_cat_attribute25(i),
      num_cat_attribute26 = p_attr_values_tbl.num_cat_attribute26(i),
      num_cat_attribute27 = p_attr_values_tbl.num_cat_attribute27(i),
      num_cat_attribute28 = p_attr_values_tbl.num_cat_attribute28(i),
      num_cat_attribute29 = p_attr_values_tbl.num_cat_attribute29(i),
      num_cat_attribute30 = p_attr_values_tbl.num_cat_attribute30(i),
      num_cat_attribute31 = p_attr_values_tbl.num_cat_attribute31(i),
      num_cat_attribute32 = p_attr_values_tbl.num_cat_attribute32(i),
      num_cat_attribute33 = p_attr_values_tbl.num_cat_attribute33(i),
      num_cat_attribute34 = p_attr_values_tbl.num_cat_attribute34(i),
      num_cat_attribute35 = p_attr_values_tbl.num_cat_attribute35(i),
      num_cat_attribute36 = p_attr_values_tbl.num_cat_attribute36(i),
      num_cat_attribute37 = p_attr_values_tbl.num_cat_attribute37(i),
      num_cat_attribute38 = p_attr_values_tbl.num_cat_attribute38(i),
      num_cat_attribute39 = p_attr_values_tbl.num_cat_attribute39(i),
      num_cat_attribute40 = p_attr_values_tbl.num_cat_attribute40(i),
      num_cat_attribute41 = p_attr_values_tbl.num_cat_attribute41(i),
      num_cat_attribute42 = p_attr_values_tbl.num_cat_attribute42(i),
      num_cat_attribute43 = p_attr_values_tbl.num_cat_attribute43(i),
      num_cat_attribute44 = p_attr_values_tbl.num_cat_attribute44(i),
      num_cat_attribute45 = p_attr_values_tbl.num_cat_attribute45(i),
      num_cat_attribute46 = p_attr_values_tbl.num_cat_attribute46(i),
      num_cat_attribute47 = p_attr_values_tbl.num_cat_attribute47(i),
      num_cat_attribute48 = p_attr_values_tbl.num_cat_attribute48(i),
      num_cat_attribute49 = p_attr_values_tbl.num_cat_attribute49(i),
      num_cat_attribute50 = p_attr_values_tbl.num_cat_attribute50(i),
      last_update_login = FND_GLOBAL.login_id,
      last_updated_by   = FND_GLOBAL.user_id,
      last_update_date  = sysdate,
      created_by        = g_R12_UPGRADE_USER,
      creation_date     = sysdate,
      request_id        = FND_GLOBAL.conc_request_id,
      program_application_id = p_attr_values_tbl.program_application_id(i),
      program_id = p_attr_values_tbl.program_id(i),
      program_update_date = p_attr_values_tbl.program_update_date(i),
      last_updated_program = g_R12_MIGRATION_PROGRAM
    WHERE p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = 'UPDATE'
      AND po_line_id = p_attr_values_tbl.po_line_id(i)
      AND req_template_name = p_attr_values_tbl.req_template_name (i)
      AND req_template_line_num = p_attr_values_tbl.req_template_line_num(i)
      AND org_id = p_attr_values_tbl.org_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Attr updated='||SQL%rowcount); END IF;

  l_progress := '020';
  -- SQL What: Update the process_code on interface table as PROCESSED
  -- SQL Why : To mark the rows as successfully inserted
  -- SQL Join: interface_attr_values_id
  -- Bug#5389286: Removed unnecessary OR conditions in the criteria
  -- For an update action, iP will always populate the
  -- po_line_id/req_template_name/req_template_line_num/org_id  in the
  -- attr/attr_tlp interface tables
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    UPDATE /*+ INDEX(POATRI, PO_ATTR_VALUES_INT_N3)*/
           PO_ATTR_VALUES_INTERFACE POATRI
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = 'UPDATE'
      AND po_line_id = p_attr_values_tbl.po_line_id(i)
      AND req_template_name = p_attr_values_tbl.req_template_name (i)
      AND req_template_line_num = p_attr_values_tbl.req_template_line_num(i)
      AND org_id = p_attr_values_tbl.org_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Interface Attr PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_attributes;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: delete_attributes
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Deletes a batch of attr values given in a plsql table, from the transaction
  --  tables. This function is not required anymore because the delete will be
  --  performed at the line level, which deletes the corresponding attribute row
  --  as well.
  --Parameters:
  --IN:
  -- p_attr_values_tbl
  --  A table of plsql records containing a batch of attr values
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_attributes
(
   p_attr_values_tbl IN record_of_attr_values_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_attributes';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Delete Rows that do not have errors
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    DELETE FROM po_attribute_values
    WHERE p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = 'DELETE'
      AND (   (po_line_id = p_attr_values_tbl.po_line_id(i)
               AND p_attr_values_tbl.po_line_id(i) <> g_NOT_REQUIRED_ID)
           OR
              (req_template_name = p_attr_values_tbl.req_template_name (i)
               AND req_template_line_num = p_attr_values_tbl.req_template_line_num(i)
               AND org_id = p_attr_values_tbl.org_id(i)
               AND p_attr_values_tbl.req_template_line_num(i) <> g_NOT_REQUIRED_ID));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Attr deleted='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Mark interface attr rows as PROCESSED
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tbl.po_line_id.COUNT
    UPDATE /*+ INDEX(POATRI, PO_ATTR_VALUES_INT_N3)*/
           PO_ATTR_VALUES_INTERFACE POATRI
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE p_attr_values_tbl.has_errors(i) = 'N'
      AND p_attr_values_tbl.action(i) = 'DELETE'
      AND (   (po_line_id = p_attr_values_tbl.po_line_id(i)
               AND p_attr_values_tbl.po_line_id(i) <> g_NOT_REQUIRED_ID)
           OR
              (req_template_name = p_attr_values_tbl.req_template_name (i)
               AND req_template_line_num = p_attr_values_tbl.req_template_line_num(i)
               AND org_id = p_attr_values_tbl.org_id(i)
               AND p_attr_values_tbl.req_template_line_num(i) <> g_NOT_REQUIRED_ID));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Interface Attr rows PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END delete_attributes;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: migrate_attributes_tlp
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the attribute tlp values from interface to draft tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_attributes_tlp
(
   p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to attribute TLP values
  -- SQL Why : To migrate data to PO txn tables
  -- SQL Join: processing_id, action
  -- Bug 5677911: Added the hint for performance reason.
  CURSOR load_attrib_tlp_csr(request_processing_id NUMBER) IS
    SELECT /*+ INDEX(attrib_tlp, PO_ATTR_VALUES_TLP_INT_N2)*/
           attrib_tlp.interface_attr_values_tlp_id,
           attrib_tlp.interface_header_id,
           attrib_tlp.interface_line_id,
           attrib_tlp.action,
           attrib_tlp.process_code,
           -- The po_line_id would be stamped on PO_LINES_INTERFACE for successfully migrated lines
           NVL(DECODE(attrib_tlp.po_line_id,
                      g_NOT_REQUIRED_ID, POLI.po_line_id,
                      NULL, POLI.po_line_id,
                      attrib_tlp.po_line_id),
               g_NOT_REQUIRED_ID),
           attrib_tlp.req_template_name,
           attrib_tlp.req_template_line_num,
           attrib_tlp.ip_category_id,
           attrib_tlp.inventory_item_id,
           attrib_tlp.org_id,
           attrib_tlp.language,
           attrib_tlp.description,
           attrib_tlp.manufacturer,
           attrib_tlp.comments,
           attrib_tlp.alias,
           attrib_tlp.long_description,
           attrib_tlp.tl_text_base_attribute1,
           attrib_tlp.tl_text_base_attribute2,
           attrib_tlp.tl_text_base_attribute3,
           attrib_tlp.tl_text_base_attribute4,
           attrib_tlp.tl_text_base_attribute5,
           attrib_tlp.tl_text_base_attribute6,
           attrib_tlp.tl_text_base_attribute7,
           attrib_tlp.tl_text_base_attribute8,
           attrib_tlp.tl_text_base_attribute9,
           attrib_tlp.tl_text_base_attribute10,
           attrib_tlp.tl_text_base_attribute11,
           attrib_tlp.tl_text_base_attribute12,
           attrib_tlp.tl_text_base_attribute13,
           attrib_tlp.tl_text_base_attribute14,
           attrib_tlp.tl_text_base_attribute15,
           attrib_tlp.tl_text_base_attribute16,
           attrib_tlp.tl_text_base_attribute17,
           attrib_tlp.tl_text_base_attribute18,
           attrib_tlp.tl_text_base_attribute19,
           attrib_tlp.tl_text_base_attribute20,
           attrib_tlp.tl_text_base_attribute21,
           attrib_tlp.tl_text_base_attribute22,
           attrib_tlp.tl_text_base_attribute23,
           attrib_tlp.tl_text_base_attribute24,
           attrib_tlp.tl_text_base_attribute25,
           attrib_tlp.tl_text_base_attribute26,
           attrib_tlp.tl_text_base_attribute27,
           attrib_tlp.tl_text_base_attribute28,
           attrib_tlp.tl_text_base_attribute29,
           attrib_tlp.tl_text_base_attribute30,
           attrib_tlp.tl_text_base_attribute31,
           attrib_tlp.tl_text_base_attribute32,
           attrib_tlp.tl_text_base_attribute33,
           attrib_tlp.tl_text_base_attribute34,
           attrib_tlp.tl_text_base_attribute35,
           attrib_tlp.tl_text_base_attribute36,
           attrib_tlp.tl_text_base_attribute37,
           attrib_tlp.tl_text_base_attribute38,
           attrib_tlp.tl_text_base_attribute39,
           attrib_tlp.tl_text_base_attribute40,
           attrib_tlp.tl_text_base_attribute41,
           attrib_tlp.tl_text_base_attribute42,
           attrib_tlp.tl_text_base_attribute43,
           attrib_tlp.tl_text_base_attribute44,
           attrib_tlp.tl_text_base_attribute45,
           attrib_tlp.tl_text_base_attribute46,
           attrib_tlp.tl_text_base_attribute47,
           attrib_tlp.tl_text_base_attribute48,
           attrib_tlp.tl_text_base_attribute49,
           attrib_tlp.tl_text_base_attribute50,
           attrib_tlp.tl_text_base_attribute51,
           attrib_tlp.tl_text_base_attribute52,
           attrib_tlp.tl_text_base_attribute53,
           attrib_tlp.tl_text_base_attribute54,
           attrib_tlp.tl_text_base_attribute55,
           attrib_tlp.tl_text_base_attribute56,
           attrib_tlp.tl_text_base_attribute57,
           attrib_tlp.tl_text_base_attribute58,
           attrib_tlp.tl_text_base_attribute59,
           attrib_tlp.tl_text_base_attribute60,
           attrib_tlp.tl_text_base_attribute61,
           attrib_tlp.tl_text_base_attribute62,
           attrib_tlp.tl_text_base_attribute63,
           attrib_tlp.tl_text_base_attribute64,
           attrib_tlp.tl_text_base_attribute65,
           attrib_tlp.tl_text_base_attribute66,
           attrib_tlp.tl_text_base_attribute67,
           attrib_tlp.tl_text_base_attribute68,
           attrib_tlp.tl_text_base_attribute69,
           attrib_tlp.tl_text_base_attribute70,
           attrib_tlp.tl_text_base_attribute71,
           attrib_tlp.tl_text_base_attribute72,
           attrib_tlp.tl_text_base_attribute73,
           attrib_tlp.tl_text_base_attribute74,
           attrib_tlp.tl_text_base_attribute75,
           attrib_tlp.tl_text_base_attribute76,
           attrib_tlp.tl_text_base_attribute77,
           attrib_tlp.tl_text_base_attribute78,
           attrib_tlp.tl_text_base_attribute79,
           attrib_tlp.tl_text_base_attribute80,
           attrib_tlp.tl_text_base_attribute81,
           attrib_tlp.tl_text_base_attribute82,
           attrib_tlp.tl_text_base_attribute83,
           attrib_tlp.tl_text_base_attribute84,
           attrib_tlp.tl_text_base_attribute85,
           attrib_tlp.tl_text_base_attribute86,
           attrib_tlp.tl_text_base_attribute87,
           attrib_tlp.tl_text_base_attribute88,
           attrib_tlp.tl_text_base_attribute89,
           attrib_tlp.tl_text_base_attribute90,
           attrib_tlp.tl_text_base_attribute91,
           attrib_tlp.tl_text_base_attribute92,
           attrib_tlp.tl_text_base_attribute93,
           attrib_tlp.tl_text_base_attribute94,
           attrib_tlp.tl_text_base_attribute95,
           attrib_tlp.tl_text_base_attribute96,
           attrib_tlp.tl_text_base_attribute97,
           attrib_tlp.tl_text_base_attribute98,
           attrib_tlp.tl_text_base_attribute99,
           attrib_tlp.tl_text_base_attribute100,
           attrib_tlp.tl_text_cat_attribute1,
           attrib_tlp.tl_text_cat_attribute2,
           attrib_tlp.tl_text_cat_attribute3,
           attrib_tlp.tl_text_cat_attribute4,
           attrib_tlp.tl_text_cat_attribute5,
           attrib_tlp.tl_text_cat_attribute6,
           attrib_tlp.tl_text_cat_attribute7,
           attrib_tlp.tl_text_cat_attribute8,
           attrib_tlp.tl_text_cat_attribute9,
           attrib_tlp.tl_text_cat_attribute10,
           attrib_tlp.tl_text_cat_attribute11,
           attrib_tlp.tl_text_cat_attribute12,
           attrib_tlp.tl_text_cat_attribute13,
           attrib_tlp.tl_text_cat_attribute14,
           attrib_tlp.tl_text_cat_attribute15,
           attrib_tlp.tl_text_cat_attribute16,
           attrib_tlp.tl_text_cat_attribute17,
           attrib_tlp.tl_text_cat_attribute18,
           attrib_tlp.tl_text_cat_attribute19,
           attrib_tlp.tl_text_cat_attribute20,
           attrib_tlp.tl_text_cat_attribute21,
           attrib_tlp.tl_text_cat_attribute22,
           attrib_tlp.tl_text_cat_attribute23,
           attrib_tlp.tl_text_cat_attribute24,
           attrib_tlp.tl_text_cat_attribute25,
           attrib_tlp.tl_text_cat_attribute26,
           attrib_tlp.tl_text_cat_attribute27,
           attrib_tlp.tl_text_cat_attribute28,
           attrib_tlp.tl_text_cat_attribute29,
           attrib_tlp.tl_text_cat_attribute30,
           attrib_tlp.tl_text_cat_attribute31,
           attrib_tlp.tl_text_cat_attribute32,
           attrib_tlp.tl_text_cat_attribute33,
           attrib_tlp.tl_text_cat_attribute34,
           attrib_tlp.tl_text_cat_attribute35,
           attrib_tlp.tl_text_cat_attribute36,
           attrib_tlp.tl_text_cat_attribute37,
           attrib_tlp.tl_text_cat_attribute38,
           attrib_tlp.tl_text_cat_attribute39,
           attrib_tlp.tl_text_cat_attribute40,
           attrib_tlp.tl_text_cat_attribute41,
           attrib_tlp.tl_text_cat_attribute42,
           attrib_tlp.tl_text_cat_attribute43,
           attrib_tlp.tl_text_cat_attribute44,
           attrib_tlp.tl_text_cat_attribute45,
           attrib_tlp.tl_text_cat_attribute46,
           attrib_tlp.tl_text_cat_attribute47,
           attrib_tlp.tl_text_cat_attribute48,
           attrib_tlp.tl_text_cat_attribute49,
           attrib_tlp.tl_text_cat_attribute50,
           attrib_tlp.last_update_login,
           attrib_tlp.last_updated_by,
           attrib_tlp.last_update_date,
           attrib_tlp.created_by,
           attrib_tlp.creation_date,
           attrib_tlp.request_id,
           attrib_tlp.program_application_id,
           attrib_tlp.program_id,
           attrib_tlp.program_update_date,
           attrib_tlp.processing_id,
           'N' -- has_errors
    FROM   PO_ATTR_VALUES_TLP_INTERFACE attrib_tlp,
           PO_LINES_INTERFACE POLI
    WHERE  attrib_tlp.processing_id = request_processing_id
    AND    attrib_tlp.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW
    AND    attrib_tlp.action IN (PO_R12_CAT_UPG_PVT.g_action_tlp_create, 'UPDATE', 'DELETE')
    AND    attrib_tlp.interface_line_id = POLI.interface_line_id;

  l_attrib_tlp_table record_of_attr_values_tlp_type;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Algorithm:
  -- 1. Load Lines batch (batch_size) into pl/sql table.
  -- 2. Call PDOI modules to process data in batches (default, derive, validate).
  -- 3. Get the validated pl/sql table for the batch from PDOI.
  -- 4. Transfer directly to Transaction tables

  OPEN load_attrib_tlp_csr(g_processing_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      FETCH load_attrib_tlp_csr BULK COLLECT INTO
        l_attrib_tlp_table.interface_attr_values_tlp_id,
        l_attrib_tlp_table.interface_header_id,
        l_attrib_tlp_table.interface_line_id,
        l_attrib_tlp_table.action,
        l_attrib_tlp_table.process_code,
        l_attrib_tlp_table.po_line_id,
        l_attrib_tlp_table.req_template_name,
        l_attrib_tlp_table.req_template_line_num,
        l_attrib_tlp_table.ip_category_id,
        l_attrib_tlp_table.inventory_item_id,
        l_attrib_tlp_table.org_id,
        l_attrib_tlp_table.language,
        l_attrib_tlp_table.description,
        l_attrib_tlp_table.manufacturer,
        l_attrib_tlp_table.comments,
        l_attrib_tlp_table.alias,
        l_attrib_tlp_table.long_description,
        l_attrib_tlp_table.tl_text_base_attribute1,
        l_attrib_tlp_table.tl_text_base_attribute2,
        l_attrib_tlp_table.tl_text_base_attribute3,
        l_attrib_tlp_table.tl_text_base_attribute4,
        l_attrib_tlp_table.tl_text_base_attribute5,
        l_attrib_tlp_table.tl_text_base_attribute6,
        l_attrib_tlp_table.tl_text_base_attribute7,
        l_attrib_tlp_table.tl_text_base_attribute8,
        l_attrib_tlp_table.tl_text_base_attribute9,
        l_attrib_tlp_table.tl_text_base_attribute10,
        l_attrib_tlp_table.tl_text_base_attribute11,
        l_attrib_tlp_table.tl_text_base_attribute12,
        l_attrib_tlp_table.tl_text_base_attribute13,
        l_attrib_tlp_table.tl_text_base_attribute14,
        l_attrib_tlp_table.tl_text_base_attribute15,
        l_attrib_tlp_table.tl_text_base_attribute16,
        l_attrib_tlp_table.tl_text_base_attribute17,
        l_attrib_tlp_table.tl_text_base_attribute18,
        l_attrib_tlp_table.tl_text_base_attribute19,
        l_attrib_tlp_table.tl_text_base_attribute20,
        l_attrib_tlp_table.tl_text_base_attribute21,
        l_attrib_tlp_table.tl_text_base_attribute22,
        l_attrib_tlp_table.tl_text_base_attribute23,
        l_attrib_tlp_table.tl_text_base_attribute24,
        l_attrib_tlp_table.tl_text_base_attribute25,
        l_attrib_tlp_table.tl_text_base_attribute26,
        l_attrib_tlp_table.tl_text_base_attribute27,
        l_attrib_tlp_table.tl_text_base_attribute28,
        l_attrib_tlp_table.tl_text_base_attribute29,
        l_attrib_tlp_table.tl_text_base_attribute30,
        l_attrib_tlp_table.tl_text_base_attribute31,
        l_attrib_tlp_table.tl_text_base_attribute32,
        l_attrib_tlp_table.tl_text_base_attribute33,
        l_attrib_tlp_table.tl_text_base_attribute34,
        l_attrib_tlp_table.tl_text_base_attribute35,
        l_attrib_tlp_table.tl_text_base_attribute36,
        l_attrib_tlp_table.tl_text_base_attribute37,
        l_attrib_tlp_table.tl_text_base_attribute38,
        l_attrib_tlp_table.tl_text_base_attribute39,
        l_attrib_tlp_table.tl_text_base_attribute40,
        l_attrib_tlp_table.tl_text_base_attribute41,
        l_attrib_tlp_table.tl_text_base_attribute42,
        l_attrib_tlp_table.tl_text_base_attribute43,
        l_attrib_tlp_table.tl_text_base_attribute44,
        l_attrib_tlp_table.tl_text_base_attribute45,
        l_attrib_tlp_table.tl_text_base_attribute46,
        l_attrib_tlp_table.tl_text_base_attribute47,
        l_attrib_tlp_table.tl_text_base_attribute48,
        l_attrib_tlp_table.tl_text_base_attribute49,
        l_attrib_tlp_table.tl_text_base_attribute50,
        l_attrib_tlp_table.tl_text_base_attribute51,
        l_attrib_tlp_table.tl_text_base_attribute52,
        l_attrib_tlp_table.tl_text_base_attribute53,
        l_attrib_tlp_table.tl_text_base_attribute54,
        l_attrib_tlp_table.tl_text_base_attribute55,
        l_attrib_tlp_table.tl_text_base_attribute56,
        l_attrib_tlp_table.tl_text_base_attribute57,
        l_attrib_tlp_table.tl_text_base_attribute58,
        l_attrib_tlp_table.tl_text_base_attribute59,
        l_attrib_tlp_table.tl_text_base_attribute60,
        l_attrib_tlp_table.tl_text_base_attribute61,
        l_attrib_tlp_table.tl_text_base_attribute62,
        l_attrib_tlp_table.tl_text_base_attribute63,
        l_attrib_tlp_table.tl_text_base_attribute64,
        l_attrib_tlp_table.tl_text_base_attribute65,
        l_attrib_tlp_table.tl_text_base_attribute66,
        l_attrib_tlp_table.tl_text_base_attribute67,
        l_attrib_tlp_table.tl_text_base_attribute68,
        l_attrib_tlp_table.tl_text_base_attribute69,
        l_attrib_tlp_table.tl_text_base_attribute70,
        l_attrib_tlp_table.tl_text_base_attribute71,
        l_attrib_tlp_table.tl_text_base_attribute72,
        l_attrib_tlp_table.tl_text_base_attribute73,
        l_attrib_tlp_table.tl_text_base_attribute74,
        l_attrib_tlp_table.tl_text_base_attribute75,
        l_attrib_tlp_table.tl_text_base_attribute76,
        l_attrib_tlp_table.tl_text_base_attribute77,
        l_attrib_tlp_table.tl_text_base_attribute78,
        l_attrib_tlp_table.tl_text_base_attribute79,
        l_attrib_tlp_table.tl_text_base_attribute80,
        l_attrib_tlp_table.tl_text_base_attribute81,
        l_attrib_tlp_table.tl_text_base_attribute82,
        l_attrib_tlp_table.tl_text_base_attribute83,
        l_attrib_tlp_table.tl_text_base_attribute84,
        l_attrib_tlp_table.tl_text_base_attribute85,
        l_attrib_tlp_table.tl_text_base_attribute86,
        l_attrib_tlp_table.tl_text_base_attribute87,
        l_attrib_tlp_table.tl_text_base_attribute88,
        l_attrib_tlp_table.tl_text_base_attribute89,
        l_attrib_tlp_table.tl_text_base_attribute90,
        l_attrib_tlp_table.tl_text_base_attribute91,
        l_attrib_tlp_table.tl_text_base_attribute92,
        l_attrib_tlp_table.tl_text_base_attribute93,
        l_attrib_tlp_table.tl_text_base_attribute94,
        l_attrib_tlp_table.tl_text_base_attribute95,
        l_attrib_tlp_table.tl_text_base_attribute96,
        l_attrib_tlp_table.tl_text_base_attribute97,
        l_attrib_tlp_table.tl_text_base_attribute98,
        l_attrib_tlp_table.tl_text_base_attribute99,
        l_attrib_tlp_table.tl_text_base_attribute100,
        l_attrib_tlp_table.tl_text_cat_attribute1,
        l_attrib_tlp_table.tl_text_cat_attribute2,
        l_attrib_tlp_table.tl_text_cat_attribute3,
        l_attrib_tlp_table.tl_text_cat_attribute4,
        l_attrib_tlp_table.tl_text_cat_attribute5,
        l_attrib_tlp_table.tl_text_cat_attribute6,
        l_attrib_tlp_table.tl_text_cat_attribute7,
        l_attrib_tlp_table.tl_text_cat_attribute8,
        l_attrib_tlp_table.tl_text_cat_attribute9,
        l_attrib_tlp_table.tl_text_cat_attribute10,
        l_attrib_tlp_table.tl_text_cat_attribute11,
        l_attrib_tlp_table.tl_text_cat_attribute12,
        l_attrib_tlp_table.tl_text_cat_attribute13,
        l_attrib_tlp_table.tl_text_cat_attribute14,
        l_attrib_tlp_table.tl_text_cat_attribute15,
        l_attrib_tlp_table.tl_text_cat_attribute16,
        l_attrib_tlp_table.tl_text_cat_attribute17,
        l_attrib_tlp_table.tl_text_cat_attribute18,
        l_attrib_tlp_table.tl_text_cat_attribute19,
        l_attrib_tlp_table.tl_text_cat_attribute20,
        l_attrib_tlp_table.tl_text_cat_attribute21,
        l_attrib_tlp_table.tl_text_cat_attribute22,
        l_attrib_tlp_table.tl_text_cat_attribute23,
        l_attrib_tlp_table.tl_text_cat_attribute24,
        l_attrib_tlp_table.tl_text_cat_attribute25,
        l_attrib_tlp_table.tl_text_cat_attribute26,
        l_attrib_tlp_table.tl_text_cat_attribute27,
        l_attrib_tlp_table.tl_text_cat_attribute28,
        l_attrib_tlp_table.tl_text_cat_attribute29,
        l_attrib_tlp_table.tl_text_cat_attribute30,
        l_attrib_tlp_table.tl_text_cat_attribute31,
        l_attrib_tlp_table.tl_text_cat_attribute32,
        l_attrib_tlp_table.tl_text_cat_attribute33,
        l_attrib_tlp_table.tl_text_cat_attribute34,
        l_attrib_tlp_table.tl_text_cat_attribute35,
        l_attrib_tlp_table.tl_text_cat_attribute36,
        l_attrib_tlp_table.tl_text_cat_attribute37,
        l_attrib_tlp_table.tl_text_cat_attribute38,
        l_attrib_tlp_table.tl_text_cat_attribute39,
        l_attrib_tlp_table.tl_text_cat_attribute40,
        l_attrib_tlp_table.tl_text_cat_attribute41,
        l_attrib_tlp_table.tl_text_cat_attribute42,
        l_attrib_tlp_table.tl_text_cat_attribute43,
        l_attrib_tlp_table.tl_text_cat_attribute44,
        l_attrib_tlp_table.tl_text_cat_attribute45,
        l_attrib_tlp_table.tl_text_cat_attribute46,
        l_attrib_tlp_table.tl_text_cat_attribute47,
        l_attrib_tlp_table.tl_text_cat_attribute48,
        l_attrib_tlp_table.tl_text_cat_attribute49,
        l_attrib_tlp_table.tl_text_cat_attribute50,
        l_attrib_tlp_table.last_update_login,
        l_attrib_tlp_table.last_updated_by,
        l_attrib_tlp_table.last_update_date,
        l_attrib_tlp_table.created_by,
        l_attrib_tlp_table.creation_date,
        l_attrib_tlp_table.request_id,
        l_attrib_tlp_table.program_application_id,
        l_attrib_tlp_table.program_id,
        l_attrib_tlp_table.program_update_date,
        l_attrib_tlp_table.processing_id,
        l_attrib_tlp_table.has_errors
      LIMIT g_job.batch_size;

      l_progress := '030';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_attrib_tlp_table.interface_line_id.COUNT='||l_attrib_tlp_table.interface_line_id.COUNT); END IF;

      EXIT WHEN l_attrib_tlp_table.interface_line_id.COUNT = 0;

      -- Derive + Default + Validation are not required for attribute tlp values

      l_progress := '070';
      -- Skip transfer if runnning in Validate Only mode.
      IF (p_validate_only_mode = FND_API.G_FALSE) THEN
        -- Transfer Attribute tlp values
        transfer_attributes_tlp(p_attrib_tlp_values_tbl => l_attrib_tlp_table);
      END IF; -- IF (p_validate_only_mode = FND_API.G_FALSE)

      l_progress := '100';
      COMMIT;

      l_progress := '110';
      IF (l_attrib_tlp_table.interface_attr_values_tlp_id.COUNT
                  < g_job.batch_size) THEN
        EXIT;
      END IF;
      l_progress := '120';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_attrib_tlp_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '130';
        COMMIT;

        l_progress := '140';
        CLOSE load_attrib_tlp_csr;

        l_progress := '150';
        OPEN load_attrib_tlp_csr(g_processing_id);
        l_progress := '160';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP; -- batch loop

  l_progress := '170';
  IF (load_attrib_tlp_csr%ISOPEN) THEN
    CLOSE load_attrib_tlp_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_attrib_tlp_csr%ISOPEN) THEN
      CLOSE load_attrib_tlp_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END migrate_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: transfer_attributes_tlp
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Transfers a batch of attribute tlp values given in a plsql table, into the
  --  transaction tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attrib_values_tbl
  --  A table of plsql records containing a batch of attribute tlp values
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE transfer_attributes_tlp
(
   p_attrib_tlp_values_tbl    IN record_of_attr_values_tlp_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'transfer_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Insert Attributes TLP
  insert_attributes_tlp(p_attr_values_tlp_tbl => p_attrib_tlp_values_tbl);

  l_progress := '020';
  -- Update Attributes TLP
  update_attributes_tlp(p_attr_values_tlp_tbl => p_attrib_tlp_values_tbl);

  l_progress := '030';
  -- Delete Attributes TLP
  delete_attributes_tlp(p_attr_values_tlp_tbl => p_attrib_tlp_values_tbl);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END transfer_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: insert_attributes_tlp
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Inserts a batch of attr values TLP given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attr_values_tbl
  --  A table of plsql records containing a batch of attr values TLP
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_attributes_tlp
(
   p_attr_values_tlp_tbl IN record_of_attr_values_tlp_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Insert rows that have no errors, and action = PO_R12_CAT_UPG_PVT.g_action_tlp_create
  -- SQL Why : To migrate data to txn tables
  -- SQL Join: none
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    INSERT INTO po_attribute_values_tlp
                         (attribute_values_tlp_id,
                          po_line_id,
                          req_template_name,
                          req_template_line_num,
                          ip_category_id,
                          inventory_item_id,
                          org_id,
                          language,
                          description,
                          manufacturer,
                          comments,
                          alias,
                          long_description,
                          tl_text_base_attribute1,
                          tl_text_base_attribute2,
                          tl_text_base_attribute3,
                          tl_text_base_attribute4,
                          tl_text_base_attribute5,
                          tl_text_base_attribute6,
                          tl_text_base_attribute7,
                          tl_text_base_attribute8,
                          tl_text_base_attribute9,
                          tl_text_base_attribute10,
                          tl_text_base_attribute11,
                          tl_text_base_attribute12,
                          tl_text_base_attribute13,
                          tl_text_base_attribute14,
                          tl_text_base_attribute15,
                          tl_text_base_attribute16,
                          tl_text_base_attribute17,
                          tl_text_base_attribute18,
                          tl_text_base_attribute19,
                          tl_text_base_attribute20,
                          tl_text_base_attribute21,
                          tl_text_base_attribute22,
                          tl_text_base_attribute23,
                          tl_text_base_attribute24,
                          tl_text_base_attribute25,
                          tl_text_base_attribute26,
                          tl_text_base_attribute27,
                          tl_text_base_attribute28,
                          tl_text_base_attribute29,
                          tl_text_base_attribute30,
                          tl_text_base_attribute31,
                          tl_text_base_attribute32,
                          tl_text_base_attribute33,
                          tl_text_base_attribute34,
                          tl_text_base_attribute35,
                          tl_text_base_attribute36,
                          tl_text_base_attribute37,
                          tl_text_base_attribute38,
                          tl_text_base_attribute39,
                          tl_text_base_attribute40,
                          tl_text_base_attribute41,
                          tl_text_base_attribute42,
                          tl_text_base_attribute43,
                          tl_text_base_attribute44,
                          tl_text_base_attribute45,
                          tl_text_base_attribute46,
                          tl_text_base_attribute47,
                          tl_text_base_attribute48,
                          tl_text_base_attribute49,
                          tl_text_base_attribute50,
                          tl_text_base_attribute51,
                          tl_text_base_attribute52,
                          tl_text_base_attribute53,
                          tl_text_base_attribute54,
                          tl_text_base_attribute55,
                          tl_text_base_attribute56,
                          tl_text_base_attribute57,
                          tl_text_base_attribute58,
                          tl_text_base_attribute59,
                          tl_text_base_attribute60,
                          tl_text_base_attribute61,
                          tl_text_base_attribute62,
                          tl_text_base_attribute63,
                          tl_text_base_attribute64,
                          tl_text_base_attribute65,
                          tl_text_base_attribute66,
                          tl_text_base_attribute67,
                          tl_text_base_attribute68,
                          tl_text_base_attribute69,
                          tl_text_base_attribute70,
                          tl_text_base_attribute71,
                          tl_text_base_attribute72,
                          tl_text_base_attribute73,
                          tl_text_base_attribute74,
                          tl_text_base_attribute75,
                          tl_text_base_attribute76,
                          tl_text_base_attribute77,
                          tl_text_base_attribute78,
                          tl_text_base_attribute79,
                          tl_text_base_attribute80,
                          tl_text_base_attribute81,
                          tl_text_base_attribute82,
                          tl_text_base_attribute83,
                          tl_text_base_attribute84,
                          tl_text_base_attribute85,
                          tl_text_base_attribute86,
                          tl_text_base_attribute87,
                          tl_text_base_attribute88,
                          tl_text_base_attribute89,
                          tl_text_base_attribute90,
                          tl_text_base_attribute91,
                          tl_text_base_attribute92,
                          tl_text_base_attribute93,
                          tl_text_base_attribute94,
                          tl_text_base_attribute95,
                          tl_text_base_attribute96,
                          tl_text_base_attribute97,
                          tl_text_base_attribute98,
                          tl_text_base_attribute99,
                          tl_text_base_attribute100,
                          tl_text_cat_attribute1,
                          tl_text_cat_attribute2,
                          tl_text_cat_attribute3,
                          tl_text_cat_attribute4,
                          tl_text_cat_attribute5,
                          tl_text_cat_attribute6,
                          tl_text_cat_attribute7,
                          tl_text_cat_attribute8,
                          tl_text_cat_attribute9,
                          tl_text_cat_attribute10,
                          tl_text_cat_attribute11,
                          tl_text_cat_attribute12,
                          tl_text_cat_attribute13,
                          tl_text_cat_attribute14,
                          tl_text_cat_attribute15,
                          tl_text_cat_attribute16,
                          tl_text_cat_attribute17,
                          tl_text_cat_attribute18,
                          tl_text_cat_attribute19,
                          tl_text_cat_attribute20,
                          tl_text_cat_attribute21,
                          tl_text_cat_attribute22,
                          tl_text_cat_attribute23,
                          tl_text_cat_attribute24,
                          tl_text_cat_attribute25,
                          tl_text_cat_attribute26,
                          tl_text_cat_attribute27,
                          tl_text_cat_attribute28,
                          tl_text_cat_attribute29,
                          tl_text_cat_attribute30,
                          tl_text_cat_attribute31,
                          tl_text_cat_attribute32,
                          tl_text_cat_attribute33,
                          tl_text_cat_attribute34,
                          tl_text_cat_attribute35,
                          tl_text_cat_attribute36,
                          tl_text_cat_attribute37,
                          tl_text_cat_attribute38,
                          tl_text_cat_attribute39,
                          tl_text_cat_attribute40,
                          tl_text_cat_attribute41,
                          tl_text_cat_attribute42,
                          tl_text_cat_attribute43,
                          tl_text_cat_attribute44,
                          tl_text_cat_attribute45,
                          tl_text_cat_attribute46,
                          tl_text_cat_attribute47,
                          tl_text_cat_attribute48,
                          tl_text_cat_attribute49,
                          tl_text_cat_attribute50,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          created_by,
                          creation_date,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          last_updated_program
                         )
    -- Bug 5677911: Added the hint for performance reason.
    SELECT /*+ INDEX(POAVTI, PO_ATTR_VALUES_TLP_INT_U1)*/
           PO_ATTRIBUTE_VALUES_TLP_S.nextval,

           -- ECO bug 4738058
           --p_attr_values_tlp_tbl.po_line_id(i),
           --bug 7245624 added nvl cond
           Nvl( POLI.po_line_id,-2),
           p_attr_values_tlp_tbl.req_template_name(i),
           p_attr_values_tlp_tbl.req_template_line_num(i),
           p_attr_values_tlp_tbl.ip_category_id(i),
           p_attr_values_tlp_tbl.inventory_item_id(i),
           p_attr_values_tlp_tbl.org_id(i),
           p_attr_values_tlp_tbl.language(i),
           p_attr_values_tlp_tbl.description(i),
           p_attr_values_tlp_tbl.manufacturer(i),
           p_attr_values_tlp_tbl.comments(i),
           p_attr_values_tlp_tbl.alias(i),
           p_attr_values_tlp_tbl.long_description(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute1(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute2(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute3(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute4(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute5(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute6(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute7(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute8(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute9(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute10(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute11(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute12(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute13(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute14(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute15(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute16(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute17(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute18(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute19(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute20(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute21(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute22(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute23(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute24(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute25(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute26(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute27(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute28(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute29(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute30(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute31(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute32(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute33(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute34(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute35(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute36(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute37(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute38(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute39(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute40(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute41(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute42(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute43(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute44(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute45(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute46(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute47(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute48(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute49(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute50(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute51(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute52(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute53(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute54(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute55(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute56(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute57(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute58(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute59(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute60(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute61(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute62(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute63(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute64(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute65(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute66(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute67(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute68(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute69(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute70(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute71(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute72(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute73(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute74(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute75(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute76(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute77(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute78(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute79(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute80(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute81(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute82(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute83(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute84(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute85(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute86(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute87(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute88(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute89(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute90(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute91(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute92(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute93(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute94(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute95(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute96(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute97(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute98(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute99(i),
           p_attr_values_tlp_tbl.tl_text_base_attribute100(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute1(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute2(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute3(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute4(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute5(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute6(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute7(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute8(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute9(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute10(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute11(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute12(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute13(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute14(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute15(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute16(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute17(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute18(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute19(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute20(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute21(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute22(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute23(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute24(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute25(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute26(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute27(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute28(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute29(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute30(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute31(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute32(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute33(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute34(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute35(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute36(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute37(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute38(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute39(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute40(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute41(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute42(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute43(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute44(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute45(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute46(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute47(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute48(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute49(i),
           p_attr_values_tlp_tbl.tl_text_cat_attribute50(i),
           FND_GLOBAL.login_id, -- last_update_login
           FND_GLOBAL.user_id, -- last_updated_by
           sysdate, -- last_update_date
           g_R12_UPGRADE_USER, -- created_by
           sysdate, -- creation_date
           FND_GLOBAL.conc_request_id, -- request_id
           p_attr_values_tlp_tbl.program_application_id(i),
           p_attr_values_tlp_tbl.program_id(i),
           p_attr_values_tlp_tbl.program_update_date(i),
           g_R12_MIGRATION_PROGRAM -- last_updated_program
    FROM  PO_ATTR_VALUES_TLP_INTERFACE POAVTI,
          PO_LINES_INTERFACE POLI -- ECO bug 4738058
    WHERE POAVTI.interface_attr_values_tlp_id = p_attr_values_tlp_tbl.interface_attr_values_tlp_id(i)
      AND p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = PO_R12_CAT_UPG_PVT.g_action_tlp_create
      -- ECO bug 4738058
      AND POLI.interface_line_id = POAVTI.interface_line_id;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP inserted='||SQL%rowcount); END IF;

  l_progress := '020';
  -- SQL What: Update the process_code in interface table as PROCESSED
  -- SQL Why : To mark the rows as successfully inserted
  -- SQL Join: interface_attr_values_tlp_id
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    UPDATE PO_ATTR_VALUES_TLP_INTERFACE POAVTI
    SET /*+ INDEX(POAVTI, PO_ATTR_VALUES_TLP_INT_U1)*/
        process_code = g_PROCESS_CODE_PROCESSED
      -- ECO bug 4738058
      , po_line_id = (SELECT POLI.po_line_id
                      FROM PO_LINES_INTERFACE POLI
                      WHERE POLI.interface_line_id = POAVTI.interface_line_id)
    WHERE POAVTI.interface_attr_values_tlp_id = p_attr_values_tlp_tbl.interface_attr_values_tlp_id(i)
      AND p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = PO_R12_CAT_UPG_PVT.g_action_tlp_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Interface TLP rows PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END insert_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_attributes_tlp
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Updates a batch of attr values TLP given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_attr_values_tlp_tbl
  --  A table of plsql records containing a batch of attr values TLP
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_attributes_tlp
(
   p_attr_values_tlp_tbl    IN record_of_attr_values_tlp_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Update Rows that do not have errors. Overwrite all values
  --           from interface table to transaction table
  -- SQL Why : To update the po_attribute_tlp_values columns
  -- SQL Join: po_line_id
  -- Bug#5389286: Removed unnecessary OR conditions in the criteria
  -- For an update action, iP will always populate the
  -- po_line_id/req_template_name/req_template_line_num/org_id  in the
  -- attr/attr_tlp interface tables
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    UPDATE po_attribute_values_tlp
    SET
      ip_category_id =  p_attr_values_tlp_tbl.ip_category_id(i),
      inventory_item_id =  p_attr_values_tlp_tbl.inventory_item_id(i),
      language =  p_attr_values_tlp_tbl.language(i),
      description = DECODE(p_attr_values_tlp_tbl.description(i),
                           NULL, description,
                           g_NULLIFY_VARCHAR, NULL,
                           p_attr_values_tlp_tbl.description(i)),
      manufacturer =  p_attr_values_tlp_tbl.manufacturer(i),
      comments =  p_attr_values_tlp_tbl.comments(i),
      alias =  p_attr_values_tlp_tbl.alias(i),
      long_description =  p_attr_values_tlp_tbl.long_description(i),
      tl_text_base_attribute1 =  p_attr_values_tlp_tbl.tl_text_base_attribute1(i),
      tl_text_base_attribute2 =  p_attr_values_tlp_tbl.tl_text_base_attribute2(i),
      tl_text_base_attribute3 =  p_attr_values_tlp_tbl.tl_text_base_attribute3(i),
      tl_text_base_attribute4 =  p_attr_values_tlp_tbl.tl_text_base_attribute4(i),
      tl_text_base_attribute5 =  p_attr_values_tlp_tbl.tl_text_base_attribute5(i),
      tl_text_base_attribute6 =  p_attr_values_tlp_tbl.tl_text_base_attribute6(i),
      tl_text_base_attribute7 =  p_attr_values_tlp_tbl.tl_text_base_attribute7(i),
      tl_text_base_attribute8 =  p_attr_values_tlp_tbl.tl_text_base_attribute8(i),
      tl_text_base_attribute9 =  p_attr_values_tlp_tbl.tl_text_base_attribute9(i),
      tl_text_base_attribute10 =  p_attr_values_tlp_tbl.tl_text_base_attribute10(i),
      tl_text_base_attribute11 =  p_attr_values_tlp_tbl.tl_text_base_attribute11(i),
      tl_text_base_attribute12 =  p_attr_values_tlp_tbl.tl_text_base_attribute12(i),
      tl_text_base_attribute13 =  p_attr_values_tlp_tbl.tl_text_base_attribute13(i),
      tl_text_base_attribute14 =  p_attr_values_tlp_tbl.tl_text_base_attribute14(i),
      tl_text_base_attribute15 =  p_attr_values_tlp_tbl.tl_text_base_attribute15(i),
      tl_text_base_attribute16 =  p_attr_values_tlp_tbl.tl_text_base_attribute16(i),
      tl_text_base_attribute17 =  p_attr_values_tlp_tbl.tl_text_base_attribute17(i),
      tl_text_base_attribute18 =  p_attr_values_tlp_tbl.tl_text_base_attribute18(i),
      tl_text_base_attribute19 =  p_attr_values_tlp_tbl.tl_text_base_attribute19(i),
      tl_text_base_attribute20 =  p_attr_values_tlp_tbl.tl_text_base_attribute20(i),
      tl_text_base_attribute21 =  p_attr_values_tlp_tbl.tl_text_base_attribute21(i),
      tl_text_base_attribute22 =  p_attr_values_tlp_tbl.tl_text_base_attribute22(i),
      tl_text_base_attribute23 =  p_attr_values_tlp_tbl.tl_text_base_attribute23(i),
      tl_text_base_attribute24 =  p_attr_values_tlp_tbl.tl_text_base_attribute24(i),
      tl_text_base_attribute25 =  p_attr_values_tlp_tbl.tl_text_base_attribute25(i),
      tl_text_base_attribute26 =  p_attr_values_tlp_tbl.tl_text_base_attribute26(i),
      tl_text_base_attribute27 =  p_attr_values_tlp_tbl.tl_text_base_attribute27(i),
      tl_text_base_attribute28 =  p_attr_values_tlp_tbl.tl_text_base_attribute28(i),
      tl_text_base_attribute29 =  p_attr_values_tlp_tbl.tl_text_base_attribute29(i),
      tl_text_base_attribute30 =  p_attr_values_tlp_tbl.tl_text_base_attribute30(i),
      tl_text_base_attribute31 =  p_attr_values_tlp_tbl.tl_text_base_attribute31(i),
      tl_text_base_attribute32 =  p_attr_values_tlp_tbl.tl_text_base_attribute32(i),
      tl_text_base_attribute33 =  p_attr_values_tlp_tbl.tl_text_base_attribute33(i),
      tl_text_base_attribute34 =  p_attr_values_tlp_tbl.tl_text_base_attribute34(i),
      tl_text_base_attribute35 =  p_attr_values_tlp_tbl.tl_text_base_attribute35(i),
      tl_text_base_attribute36 =  p_attr_values_tlp_tbl.tl_text_base_attribute36(i),
      tl_text_base_attribute37 =  p_attr_values_tlp_tbl.tl_text_base_attribute37(i),
      tl_text_base_attribute38 =  p_attr_values_tlp_tbl.tl_text_base_attribute38(i),
      tl_text_base_attribute39 =  p_attr_values_tlp_tbl.tl_text_base_attribute39(i),
      tl_text_base_attribute40 =  p_attr_values_tlp_tbl.tl_text_base_attribute40(i),
      tl_text_base_attribute41 =  p_attr_values_tlp_tbl.tl_text_base_attribute41(i),
      tl_text_base_attribute42 =  p_attr_values_tlp_tbl.tl_text_base_attribute42(i),
      tl_text_base_attribute43 =  p_attr_values_tlp_tbl.tl_text_base_attribute43(i),
      tl_text_base_attribute44 =  p_attr_values_tlp_tbl.tl_text_base_attribute44(i),
      tl_text_base_attribute45 =  p_attr_values_tlp_tbl.tl_text_base_attribute45(i),
      tl_text_base_attribute46 =  p_attr_values_tlp_tbl.tl_text_base_attribute46(i),
      tl_text_base_attribute47 =  p_attr_values_tlp_tbl.tl_text_base_attribute47(i),
      tl_text_base_attribute48 =  p_attr_values_tlp_tbl.tl_text_base_attribute48(i),
      tl_text_base_attribute49 =  p_attr_values_tlp_tbl.tl_text_base_attribute49(i),
      tl_text_base_attribute50 =  p_attr_values_tlp_tbl.tl_text_base_attribute50(i),
      tl_text_base_attribute51 =  p_attr_values_tlp_tbl.tl_text_base_attribute51(i),
      tl_text_base_attribute52 =  p_attr_values_tlp_tbl.tl_text_base_attribute52(i),
      tl_text_base_attribute53 =  p_attr_values_tlp_tbl.tl_text_base_attribute53(i),
      tl_text_base_attribute54 =  p_attr_values_tlp_tbl.tl_text_base_attribute54(i),
      tl_text_base_attribute55 =  p_attr_values_tlp_tbl.tl_text_base_attribute55(i),
      tl_text_base_attribute56 =  p_attr_values_tlp_tbl.tl_text_base_attribute56(i),
      tl_text_base_attribute57 =  p_attr_values_tlp_tbl.tl_text_base_attribute57(i),
      tl_text_base_attribute58 =  p_attr_values_tlp_tbl.tl_text_base_attribute58(i),
      tl_text_base_attribute59 =  p_attr_values_tlp_tbl.tl_text_base_attribute59(i),
      tl_text_base_attribute60 =  p_attr_values_tlp_tbl.tl_text_base_attribute60(i),
      tl_text_base_attribute61 =  p_attr_values_tlp_tbl.tl_text_base_attribute61(i),
      tl_text_base_attribute62 =  p_attr_values_tlp_tbl.tl_text_base_attribute62(i),
      tl_text_base_attribute63 =  p_attr_values_tlp_tbl.tl_text_base_attribute63(i),
      tl_text_base_attribute64 =  p_attr_values_tlp_tbl.tl_text_base_attribute64(i),
      tl_text_base_attribute65 =  p_attr_values_tlp_tbl.tl_text_base_attribute65(i),
      tl_text_base_attribute66 =  p_attr_values_tlp_tbl.tl_text_base_attribute66(i),
      tl_text_base_attribute67 =  p_attr_values_tlp_tbl.tl_text_base_attribute67(i),
      tl_text_base_attribute68 =  p_attr_values_tlp_tbl.tl_text_base_attribute68(i),
      tl_text_base_attribute69 =  p_attr_values_tlp_tbl.tl_text_base_attribute69(i),
      tl_text_base_attribute70 =  p_attr_values_tlp_tbl.tl_text_base_attribute70(i),
      tl_text_base_attribute71 =  p_attr_values_tlp_tbl.tl_text_base_attribute71(i),
      tl_text_base_attribute72 =  p_attr_values_tlp_tbl.tl_text_base_attribute72(i),
      tl_text_base_attribute73 =  p_attr_values_tlp_tbl.tl_text_base_attribute73(i),
      tl_text_base_attribute74 =  p_attr_values_tlp_tbl.tl_text_base_attribute74(i),
      tl_text_base_attribute75 =  p_attr_values_tlp_tbl.tl_text_base_attribute75(i),
      tl_text_base_attribute76 =  p_attr_values_tlp_tbl.tl_text_base_attribute76(i),
      tl_text_base_attribute77 =  p_attr_values_tlp_tbl.tl_text_base_attribute77(i),
      tl_text_base_attribute78 =  p_attr_values_tlp_tbl.tl_text_base_attribute78(i),
      tl_text_base_attribute79 =  p_attr_values_tlp_tbl.tl_text_base_attribute79(i),
      tl_text_base_attribute80 =  p_attr_values_tlp_tbl.tl_text_base_attribute80(i),
      tl_text_base_attribute81 =  p_attr_values_tlp_tbl.tl_text_base_attribute81(i),
      tl_text_base_attribute82 =  p_attr_values_tlp_tbl.tl_text_base_attribute82(i),
      tl_text_base_attribute83 =  p_attr_values_tlp_tbl.tl_text_base_attribute83(i),
      tl_text_base_attribute84 =  p_attr_values_tlp_tbl.tl_text_base_attribute84(i),
      tl_text_base_attribute85 =  p_attr_values_tlp_tbl.tl_text_base_attribute85(i),
      tl_text_base_attribute86 =  p_attr_values_tlp_tbl.tl_text_base_attribute86(i),
      tl_text_base_attribute87 =  p_attr_values_tlp_tbl.tl_text_base_attribute87(i),
      tl_text_base_attribute88 =  p_attr_values_tlp_tbl.tl_text_base_attribute88(i),
      tl_text_base_attribute89 =  p_attr_values_tlp_tbl.tl_text_base_attribute89(i),
      tl_text_base_attribute90 =  p_attr_values_tlp_tbl.tl_text_base_attribute90(i),
      tl_text_base_attribute91 =  p_attr_values_tlp_tbl.tl_text_base_attribute91(i),
      tl_text_base_attribute92 =  p_attr_values_tlp_tbl.tl_text_base_attribute92(i),
      tl_text_base_attribute93 =  p_attr_values_tlp_tbl.tl_text_base_attribute93(i),
      tl_text_base_attribute94 =  p_attr_values_tlp_tbl.tl_text_base_attribute94(i),
      tl_text_base_attribute95 =  p_attr_values_tlp_tbl.tl_text_base_attribute95(i),
      tl_text_base_attribute96 =  p_attr_values_tlp_tbl.tl_text_base_attribute96(i),
      tl_text_base_attribute97 =  p_attr_values_tlp_tbl.tl_text_base_attribute97(i),
      tl_text_base_attribute98 =  p_attr_values_tlp_tbl.tl_text_base_attribute98(i),
      tl_text_base_attribute99 =  p_attr_values_tlp_tbl.tl_text_base_attribute99(i),
      tl_text_base_attribute100 =  p_attr_values_tlp_tbl.tl_text_base_attribute100(i),
      tl_text_cat_attribute1 =  p_attr_values_tlp_tbl.tl_text_cat_attribute1(i),
      tl_text_cat_attribute2 =  p_attr_values_tlp_tbl.tl_text_cat_attribute2(i),
      tl_text_cat_attribute3 =  p_attr_values_tlp_tbl.tl_text_cat_attribute3(i),
      tl_text_cat_attribute4 =  p_attr_values_tlp_tbl.tl_text_cat_attribute4(i),
      tl_text_cat_attribute5 =  p_attr_values_tlp_tbl.tl_text_cat_attribute5(i),
      tl_text_cat_attribute6 =  p_attr_values_tlp_tbl.tl_text_cat_attribute6(i),
      tl_text_cat_attribute7 =  p_attr_values_tlp_tbl.tl_text_cat_attribute7(i),
      tl_text_cat_attribute8 =  p_attr_values_tlp_tbl.tl_text_cat_attribute8(i),
      tl_text_cat_attribute9 =  p_attr_values_tlp_tbl.tl_text_cat_attribute9(i),
      tl_text_cat_attribute10 =  p_attr_values_tlp_tbl.tl_text_cat_attribute10(i),
      tl_text_cat_attribute11 =  p_attr_values_tlp_tbl.tl_text_cat_attribute11(i),
      tl_text_cat_attribute12 =  p_attr_values_tlp_tbl.tl_text_cat_attribute12(i),
      tl_text_cat_attribute13 =  p_attr_values_tlp_tbl.tl_text_cat_attribute13(i),
      tl_text_cat_attribute14 =  p_attr_values_tlp_tbl.tl_text_cat_attribute14(i),
      tl_text_cat_attribute15 =  p_attr_values_tlp_tbl.tl_text_cat_attribute15(i),
      tl_text_cat_attribute16 =  p_attr_values_tlp_tbl.tl_text_cat_attribute16(i),
      tl_text_cat_attribute17 =  p_attr_values_tlp_tbl.tl_text_cat_attribute17(i),
      tl_text_cat_attribute18 =  p_attr_values_tlp_tbl.tl_text_cat_attribute18(i),
      tl_text_cat_attribute19 =  p_attr_values_tlp_tbl.tl_text_cat_attribute19(i),
      tl_text_cat_attribute20 =  p_attr_values_tlp_tbl.tl_text_cat_attribute20(i),
      tl_text_cat_attribute21 =  p_attr_values_tlp_tbl.tl_text_cat_attribute21(i),
      tl_text_cat_attribute22 =  p_attr_values_tlp_tbl.tl_text_cat_attribute22(i),
      tl_text_cat_attribute23 =  p_attr_values_tlp_tbl.tl_text_cat_attribute23(i),
      tl_text_cat_attribute24 =  p_attr_values_tlp_tbl.tl_text_cat_attribute24(i),
      tl_text_cat_attribute25 =  p_attr_values_tlp_tbl.tl_text_cat_attribute25(i),
      tl_text_cat_attribute26 =  p_attr_values_tlp_tbl.tl_text_cat_attribute26(i),
      tl_text_cat_attribute27 =  p_attr_values_tlp_tbl.tl_text_cat_attribute27(i),
      tl_text_cat_attribute28 =  p_attr_values_tlp_tbl.tl_text_cat_attribute28(i),
      tl_text_cat_attribute29 =  p_attr_values_tlp_tbl.tl_text_cat_attribute29(i),
      tl_text_cat_attribute30 =  p_attr_values_tlp_tbl.tl_text_cat_attribute30(i),
      tl_text_cat_attribute31 =  p_attr_values_tlp_tbl.tl_text_cat_attribute31(i),
      tl_text_cat_attribute32 =  p_attr_values_tlp_tbl.tl_text_cat_attribute32(i),
      tl_text_cat_attribute33 =  p_attr_values_tlp_tbl.tl_text_cat_attribute33(i),
      tl_text_cat_attribute34 =  p_attr_values_tlp_tbl.tl_text_cat_attribute34(i),
      tl_text_cat_attribute35 =  p_attr_values_tlp_tbl.tl_text_cat_attribute35(i),
      tl_text_cat_attribute36 =  p_attr_values_tlp_tbl.tl_text_cat_attribute36(i),
      tl_text_cat_attribute37 =  p_attr_values_tlp_tbl.tl_text_cat_attribute37(i),
      tl_text_cat_attribute38 =  p_attr_values_tlp_tbl.tl_text_cat_attribute38(i),
      tl_text_cat_attribute39 =  p_attr_values_tlp_tbl.tl_text_cat_attribute39(i),
      tl_text_cat_attribute40 =  p_attr_values_tlp_tbl.tl_text_cat_attribute40(i),
      tl_text_cat_attribute41 =  p_attr_values_tlp_tbl.tl_text_cat_attribute41(i),
      tl_text_cat_attribute42 =  p_attr_values_tlp_tbl.tl_text_cat_attribute42(i),
      tl_text_cat_attribute43 =  p_attr_values_tlp_tbl.tl_text_cat_attribute43(i),
      tl_text_cat_attribute44 =  p_attr_values_tlp_tbl.tl_text_cat_attribute44(i),
      tl_text_cat_attribute45 =  p_attr_values_tlp_tbl.tl_text_cat_attribute45(i),
      tl_text_cat_attribute46 =  p_attr_values_tlp_tbl.tl_text_cat_attribute46(i),
      tl_text_cat_attribute47 =  p_attr_values_tlp_tbl.tl_text_cat_attribute47(i),
      tl_text_cat_attribute48 =  p_attr_values_tlp_tbl.tl_text_cat_attribute48(i),
      tl_text_cat_attribute49 =  p_attr_values_tlp_tbl.tl_text_cat_attribute49(i),
      tl_text_cat_attribute50 =  p_attr_values_tlp_tbl.tl_text_cat_attribute50(i),
      last_update_login = FND_GLOBAL.login_id,
      last_updated_by   = FND_GLOBAL.user_id,
      last_update_date  = sysdate,
      created_by        = g_R12_UPGRADE_USER,
      creation_date     = sysdate,
      request_id        = FND_GLOBAL.conc_request_id,
      program_application_id =  p_attr_values_tlp_tbl.program_application_id(i),
      program_id =  p_attr_values_tlp_tbl.program_id(i),
      program_update_date =  p_attr_values_tlp_tbl.program_update_date(i),
      last_updated_program = g_R12_MIGRATION_PROGRAM
    WHERE p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = 'UPDATE'
      AND language = p_attr_values_tlp_tbl.language(i)
      AND po_line_id = p_attr_values_tlp_tbl.po_line_id(i)
      AND req_template_name = p_attr_values_tlp_tbl.req_template_name (i)
      AND req_template_line_num = p_attr_values_tlp_tbl.req_template_line_num(i)
      AND org_id = p_attr_values_tlp_tbl.org_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP updated='||SQL%rowcount); END IF;

  l_progress := '020';
  -- SQL What: Update the process_code in interface table as PROCESSED
  -- SQL Why : To mark the rows as successfully updated
  -- SQL Join: language, po_line_id, req_template_name, req_template_line_num
  -- Bug#5389286: Removed unnecessary OR conditions in the criteria
  -- For an update action, iP will always populate the
  -- po_line_id/req_template_name/req_template_line_num/org_id  in the
  -- attr/attr_tlp interface tables
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    UPDATE /*+ INDEX(POTLPI, PO_ATTR_VALUES_TLP_INT_N3)*/
           PO_ATTR_VALUES_TLP_INTERFACE POTLPI
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = 'UPDATE'
      AND language = p_attr_values_tlp_tbl.language(i)
      AND po_line_id = p_attr_values_tlp_tbl.po_line_id(i)
      AND req_template_name = p_attr_values_tlp_tbl.req_template_name (i)
      AND req_template_line_num = p_attr_values_tlp_tbl.req_template_line_num(i)
      AND org_id = p_attr_values_tlp_tbl.org_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of interface TLP rows PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: delete_attributes_tlp
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Deletes a batch of attr values TLP given in a plsql table, from the transaction
  --  tables:
  --Parameters:
  --IN:
  -- p_attr_values_tlp_tbl
  --  A table of plsql records containing a batch of attr values TLP
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_attributes_tlp
(
   p_attr_values_tlp_tbl IN record_of_attr_values_tlp_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_attributes_tlp';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Delete Rows that do not have errors
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    DELETE FROM po_attribute_values_tlp
    WHERE p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = 'DELETE'
      AND language = p_attr_values_tlp_tbl.language(i)
      AND (   (po_line_id = p_attr_values_tlp_tbl.po_line_id(i)
               AND p_attr_values_tlp_tbl.po_line_id(i) <> g_NOT_REQUIRED_ID)
           OR
              (req_template_name = p_attr_values_tlp_tbl.req_template_name (i)
               AND req_template_line_num = p_attr_values_tlp_tbl.req_template_line_num(i)
               AND org_id = p_attr_values_tlp_tbl.org_id(i)
               AND p_attr_values_tlp_tbl.req_template_line_num(i) <> g_NOT_REQUIRED_ID));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP deleted='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Delete Rows that do not have errors
  -- Bug 5677911: Added the hint for performance reason.
  FORALL i IN 1..p_attr_values_tlp_tbl.po_line_id.COUNT
    UPDATE /*+ INDEX(POTLPI, PO_ATTR_VALUES_TLP_INT_N3)*/
           PO_ATTR_VALUES_TLP_INTERFACE POTLPI
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE p_attr_values_tlp_tbl.has_errors(i) = 'N'
      AND p_attr_values_tlp_tbl.action(i) = 'DELETE'
      AND language = p_attr_values_tlp_tbl.language(i)
      AND (   (po_line_id = p_attr_values_tlp_tbl.po_line_id(i)
               AND p_attr_values_tlp_tbl.po_line_id(i) <> g_NOT_REQUIRED_ID)
           OR
              (req_template_name = p_attr_values_tlp_tbl.req_template_name (i)
               AND req_template_line_num = p_attr_values_tlp_tbl.req_template_line_num(i)
               AND org_id = p_attr_values_tlp_tbl.org_id(i)
               AND p_attr_values_tlp_tbl.req_template_line_num(i) <> g_NOT_REQUIRED_ID));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of Interface TLP rows PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END delete_attributes_tlp;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_req_templates
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_header_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Migrate the lines for Requisition Templates. The Unique Key for Req Template
  --  Lines is:
  --
  --      (EXPRESS_NAME, SEQUENCE_NUM, ORG_ID)
  --
  --  Update the following columns in the Requisition Templates with data from
  --  the TLP tables. (The TLP tables were migrated already in the previous
  --  steps of the migration program).
  --
  --         ip_category_id
  --         ITEM_DESCRIPTION
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --p_batch_size
  --  The maximum number of rows that should be processed at a time, to avoid
  --  exceeding rollback segment. The transaction would be committed after
  --  processing each batch.
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  --x_return_status
  -- Apps API Std
  --  FND_API.g_ret_sts_success - if the procedure completed successfully
  --  FND_API.g_ret_sts_error - if an error occurred
  --  FND_API.g_ret_sts_unexp_error - unexpected error occurred
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_req_templates
(
   p_batch_size       IN NUMBER default 2500
,  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
,  x_return_status    OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_req_templates';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to load RT lines
  -- SQL Why : To migrate data to PO txn tables
  -- SQL Join: processing_id, interface_line_id, language, req_template_name
  --           req_template_line_num
  -- Bug 5677911: Added the hint for performance reason.
  CURSOR load_rt_lines_csr(p_request_processing_id NUMBER,
                           p_base_lang VARCHAR2) IS
    SELECT /*+ INDEX(intf_tlp, PO_ATTR_VALUES_TLP_INT_N2)*/
           intf_tlp.interface_attr_values_tlp_id,
           intf_tlp.interface_header_id,
           intf_tlp.interface_line_id,
           intf_tlp.req_template_name,
           intf_tlp.req_template_line_num,
           intf_tlp.org_id,
           intf_tlp.ip_category_id,
           intf_tlp.description
    FROM   PO_ATTR_VALUES_TLP_INTERFACE intf_tlp
          -- Not negative, means it was migrated successfully in prev steps
    WHERE intf_tlp.processing_id = p_request_processing_id
    AND   intf_tlp.process_code = g_PROCESS_CODE_PROCESSED
    AND   intf_tlp.action IN (PO_R12_CAT_UPG_PVT.g_action_tlp_create, 'UPDATE')
    AND   intf_tlp.language = p_base_lang
    AND   intf_tlp.req_template_name is not null
    AND   intf_tlp.req_template_line_num is not null
    AND   intf_tlp.req_template_line_num <> g_NOT_REQUIRED_ID
    AND   intf_tlp.org_id is not null;

  l_rt_lines_table record_of_rt_lines_type;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_progress := '010';

  -- Algorithm:
  -- 1. Load Lines batch (batch_size) into pl/sql table.
  -- 2. Transfer directly to Transaction tables

  OPEN load_rt_lines_csr(g_processing_id,
                         PO_R12_CAT_UPG_UTL.get_base_lang());

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      FETCH load_rt_lines_csr BULK COLLECT INTO
        l_rt_lines_table.interface_attr_values_tlp_id,
        l_rt_lines_table.interface_header_id,
        l_rt_lines_table.interface_line_id,
        l_rt_lines_table.req_template_name,
        l_rt_lines_table.req_template_line_num,
        l_rt_lines_table.org_id,
        l_rt_lines_table.ip_category_id,
        l_rt_lines_table.description
      LIMIT p_batch_size;

      l_progress := '030';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_rt_lines_table.req_template_name.COUNT='||l_rt_lines_table.req_template_name.COUNT); END IF;

      EXIT WHEN l_rt_lines_table.req_template_name.COUNT = 0;

      l_progress := '070';
      -- Skip transfer if runnning in Validate Only mode.
      IF (p_validate_only_mode = FND_API.G_FALSE) THEN
        -- Transfer Lines
        update_req_template_batch(p_rt_lines_rec => l_rt_lines_table);
      END IF; -- IF (p_validate_only_mode = FND_API.G_FALSE)

      l_progress := '100';
      COMMIT;

      l_progress := '110';
      IF (l_rt_lines_table.req_template_name.COUNT
                < g_job.batch_size) THEN
        EXIT;
      END IF;
      l_progress := '120';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_rt_lines_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '130';
        COMMIT;

        l_progress := '140';
        CLOSE load_rt_lines_csr;

        l_progress := '150';
        OPEN load_rt_lines_csr(g_processing_id,
                               PO_R12_CAT_UPG_UTL.get_base_lang());
        l_progress := '160';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP; -- batch loop

  l_progress := '170';
  IF (load_rt_lines_csr%ISOPEN) THEN
    CLOSE load_rt_lines_csr;
  END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_rt_lines_csr%ISOPEN) THEN
      CLOSE load_rt_lines_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_req_templates;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: update_req_template_batch
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO Interface Tables (inserts new po_line_id for successful rows, back
  --     to the Interface tables.
  --  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed the migration.
  --  c) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Updates a batch of ReqTemplate lines given in a plsql table, into the transaction
  --  tables.
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  -- p_doc_lines_rec
  --  A table of plsql records containing a batch of RT line information
  --OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_req_template_batch
(
   p_rt_lines_rec    IN record_of_rt_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'update_req_template_batch';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Update all the ReqTemplate lines.
  --           For these, only the IP_CATEGORY_ID and DESCRIPTION is allowed
  --           to be updated. The other columns, if provided in the interface
  --           tables, will be ignored. Here, g_NULL_IP_CATEGORY_ID is -2.
  -- SQL Why : To update the po_reqexpress_lines_all columns
  -- SQL Join: express_name, sequence_num (They form the PK)
  FORALL i IN 1..p_rt_lines_rec.ip_category_id.COUNT
    UPDATE PO_REQEXPRESS_LINES_ALL
    SET
      ip_category_id   = DECODE(p_rt_lines_rec.ip_category_id(i),
                                NULL, ip_category_id,
                                g_NULLIFY_NUM, g_NULL_IP_CATEGORY_ID,
                                p_rt_lines_rec.ip_category_id(i)),
      item_description = DECODE(p_rt_lines_rec.description(i),
                                NULL, item_description,
                                g_NULLIFY_VARCHAR, NULL,
                                p_rt_lines_rec.description(i))
    WHERE express_name = p_rt_lines_rec.req_template_name(i)
      AND sequence_num = p_rt_lines_rec.req_template_line_num(i)
      AND org_id = p_rt_lines_rec.org_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of RT updated='||SQL%rowcount); END IF;

  -- Now update the upper level Line and Header Records to mark them PROCESSED
  FORALL i IN 1..p_rt_lines_rec.interface_attr_values_tlp_id.COUNT
    UPDATE PO_LINES_INTERFACE
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_line_id = p_rt_lines_rec.interface_line_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of LinesInterface rows marked PROCESSED='||SQL%rowcount); END IF;

  FORALL i IN 1..p_rt_lines_rec.interface_attr_values_tlp_id.COUNT
    UPDATE PO_HEADERS_INTERFACE
    SET PROCESS_CODE = g_PROCESS_CODE_PROCESSED
    WHERE interface_header_id = p_rt_lines_rec.interface_header_id(i);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of HeadersInterface rows marked PROCESSED='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END update_req_template_batch;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_distinct_orgs
--Pre-reqs:
--  The iP catalog data is populated in PO Interface tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Finds the list of distinct org_id's for which the data has been populated
--  in the interface headers table for the given batch.
--Parameters:
--IN:
--p_batch_id
--  Batch ID to identify the data in interface tables that needs to be migrated.
--IN/OUT:
--x_org_id_list
--  A plsql table containing a list of distinct org id's.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_distinct_orgs
(
  p_batch_id    IN NUMBER
, p_batch_size  IN NUMBER
, p_validate_only_mode IN VARCHAR2
, x_org_id_list IN OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_distinct_orgs';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- Validate the org_id's. For invalid orgs, mark all associated records as REJECTED.
  PO_R12_CAT_UPG_VAL_PVT.validate_org_ids(
                              p_batch_id           => p_batch_id
                            , p_batch_size         => p_batch_size
                            , p_validate_only_mode => p_validate_only_mode);

  -- SQL What: Finds the list of distinct org_id's for which the data has been
  --           populated in the interface headers table for the given batch.
  -- SQL Why : It will be used to migrate data per org.
  -- SQL Join: batch_id
  SELECT distinct org_id
  BULK COLLECT INTO x_org_id_list
  FROM po_headers_interface
  WHERE batch_id = p_batch_id
  AND process_code = g_PROCESS_CODE_NEW;

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of distinct orgs='||x_org_id_list.COUNT); END IF;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_distinct_orgs;

END PO_R12_CAT_UPG_PVT;

/
