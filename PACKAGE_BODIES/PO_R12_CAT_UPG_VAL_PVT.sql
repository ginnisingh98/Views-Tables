--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_VAL_PVT" AS
/* $Header: PO_R12_CAT_UPG_VAL_PVT.plb 120.15 2006/12/19 11:09:07 bao noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_VAL_PVT';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;
g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

-- Value of PO_LINE_ID and REQ_TEMPLATE_LINE_NUM if they are not
-- required in Attr/TLP tables.
g_NOT_REQUIRED_ID CONSTANT NUMBER := PO_R12_CAT_UPG_PVT.g_NOT_REQUIRED_ID;
-- Value of REQ_TEMPLATE_NAME if it is not required in Attr/TLP tables.
g_NOT_REQUIRED_REQ_TEMPLATE CONSTANT VARCHAR2(30) := PO_R12_CAT_UPG_PVT.g_NOT_REQUIRED_REQ_TEMPLATE ;

-- If the value of a column (vendor_id, site_id, etc.) in the interface table
-- is -2, then treat it as NULL for validation routines.
g_NULL_COLUMN_VALUE NUMBER := -2;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_org_ids
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Interface tables.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates org_id. It can not be NULL or -2.
--  (For Operating Unit (org_id), iProc defined a values of -2 for 'All Orgs'.
--   This value will now fail validation in migration program.)
--  This procedure also validates the org_id against the HR_OPERATING_UNITS
--  table. The org_id must exist in this table and must not be end-dated.
--
--Parameters:
--IN:
--p_batch_id
--  Key used to identify all records to be processed in the interface tables.
--p_batch_size
--  The size of the batch that should be processed in each commit cycle.
--p_validate_only_mode
--  If set to Y, the cascading of errors to lower levels will not happen.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_org_ids
(
  p_batch_id           IN NUMBER
, p_batch_size         IN NUMBER
, p_validate_only_mode IN VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_org_ids';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_org_ids              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_err_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_org_ids              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  i NUMBER;

  l_ou_name HR_ALL_ORGANIZATION_UNITS_TL.name%TYPE;

  -- iProc defined value for org_id if item is valid for All OU's.
  g_OU_REQD CONSTANT NUMBER := -2;

  CURSOR load_org_ids_csr(p_batch_id NUMBER) IS
    SELECT interface_header_id
         , org_id
    FROM PO_HEADERS_INTERFACE
    WHERE batch_id = p_batch_id
      AND process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  OPEN load_org_ids_csr(p_batch_id);

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception

      l_progress := '030';
      FETCH load_org_ids_csr
      BULK COLLECT INTO l_interface_header_ids
                      , l_org_ids
      LIMIT p_batch_size;

      l_progress := '040';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_interface_header_ids.COUNT='||l_interface_header_ids.COUNT); END IF;

      IF (l_interface_header_ids.COUNT > 0) THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_interface_header_ids(1)='||l_interface_header_ids(1)); END IF;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_org_ids(1)='||l_org_ids(1)); END IF;
      END IF;

      l_progress := '050';
      EXIT WHEN l_interface_header_ids.COUNT = 0;

      -- ECO bug 5584556: Add new messages
      l_progress := '060';
      -- SQL What: Bulk validate org_id -- it should not be NULL or -2.
      --           Also validates the org_id against HR_OPERATING_UNITS.
      --           Gets the errored rows into GT table.
      -- SQL Why : It will be used to mark the record in interface tables as rejected.
      -- SQL Join: interface_header_id
      FORALL i IN 1 .. l_interface_header_ids.COUNT
        UPDATE PO_HEADERS_INTERFACE
           SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
         WHERE interface_header_id = l_interface_header_ids(i)
           AND (l_org_ids(i) IS NULL
                OR l_org_ids(i) = g_OU_REQD -- where g_OU_REQD is -2 (iProc defined this value)
                OR NOT EXISTS
                  (SELECT 'ORG_ID exists'
                   FROM HR_ALL_ORGANIZATION_UNITS HAOU
                   WHERE HAOU.organization_id = l_org_ids(i)
                   ))
        RETURNING interface_header_id, org_id
        BULK COLLECT INTO l_err_interface_header_ids, l_err_org_ids;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

      l_progress := '070';
      -- Mark the error records
      FOR i IN 1 .. l_err_interface_header_ids.COUNT
      LOOP
        IF (l_err_org_ids(i) = g_OU_REQD) THEN
          -- ICX_CAT_ALL_BUYERS_DEPRECATED:
          -- "Provide an Operating Unit. 'All Buyers' has been deprecated."
          PO_R12_CAT_UPG_UTL.add_fatal_error(
                  p_interface_header_id => l_err_interface_header_ids(i),
                  --p_error_message_name  => 'PO_R12_CAT_UPG_OU_REQD',
                  p_error_message_name  => 'ICX_CAT_ALL_BUYERS_DEPRECATED',
                  p_table_name          => 'PO_HEADERS_INTERFACE',
                  p_column_name         => 'ORG_ID',
                  p_column_value        => l_err_org_ids(i) -- debug purposes only, not used in the msg
                  );
        ELSE -- if org_id is NULL or if ID does not exist in table.
          -- ICX_CAT_OU_REQD:
          -- "Operating unit is missing."
          PO_R12_CAT_UPG_UTL.add_fatal_error(
                  p_interface_header_id => l_err_interface_header_ids(i),
                  p_error_message_name  => 'ICX_CAT_OU_REQD',
                  p_table_name          => 'PO_HEADERS_INTERFACE',
                  p_column_name         => 'ORG_ID',
                  p_column_value        => l_err_org_ids(i)
                  );
        END IF;

        l_progress := '080';
        -- Cascade errors down to lower levels
        -- Skip cascading of errors in Validate Only mode (iP Requirement - all errors should be reported)
        IF (p_validate_only_mode <> FND_API.G_TRUE) THEN
          PO_R12_CAT_UPG_UTL.reject_headers_intf('INTERFACE_HEADER_ID', l_err_interface_header_ids, 'Y');
        END IF;
      END LOOP;
      -- ECO bug 5584556: End

      l_progress := '090';
      -- SQL What: Bulk validate org_id.
      --           Validate the org_id against HR_OPERATING_UNITS.
      --           Gets the errored rows into GT table.
      -- SQL Why : It will be used to mark the record in interface tables as rejected.
      -- SQL Join: interface_header_id
      FORALL i IN 1 .. l_interface_header_ids.COUNT
        UPDATE PO_HEADERS_INTERFACE
           SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
         WHERE interface_header_id = l_interface_header_ids(i)
           -- ECO bug 5584556: Skip the validations covered above
           AND l_org_ids(i) IS NOT NULL
           AND l_org_ids(i) <> g_OU_REQD -- where g_OU_REQD is -2 (iProc defined this value)
           AND EXISTS
                   (SELECT 'ORG_ID exists'
                    FROM HR_ALL_ORGANIZATION_UNITS HAOU
                    WHERE HAOU.organization_id = l_org_ids(i)
                   )
           -- ECO bug 5584556: End
           AND (
                NOT EXISTS
                  (SELECT 'Valid Operating Unit ID'
                   FROM HR_OPERATING_UNITS HROU
                   WHERE HROU.organization_id = l_org_ids(i)
                     -- Bug 5060582: Dont need the date checks
                     --AND sysdate BETWEEN
                     --        nvl(HROU.date_from, sysdate-1)
                     --    AND nvl(HROU.date_to, sysdate+1)
                   )
                -- ECO bug 5584556: Add new messages
                -- This check is done as part of UT'ing this ECO.
                -- We found a case where the PSP row does not exist for the org_id.
                -- The migration program would die for such cases. The following query
                -- is copied from init_sys_parameters() where it was failing.
                OR
                NOT EXISTS
                ( SELECT 'Valid OU references in FSP, PSP, SOB and RCV'
                  FROM  FINANCIALS_SYSTEM_PARAMS_ALL FSPA,
                        GL_SETS_OF_BOOKS             SOB,
                        PO_SYSTEM_PARAMETERS_ALL     PSPA,
                        RCV_PARAMETERS               RCV
                  WHERE FSPA.set_of_books_id = SOB.set_of_books_id
                    AND RCV.organization_id (+) = FSPA.inventory_organization_id
                    AND PSPA.org_id = l_org_ids(i)
                    AND FSPA.org_id = l_org_ids(i)
                )
                -- ECO bug 5584556: End
               )
        RETURNING interface_header_id, org_id
        BULK COLLECT INTO l_err_interface_header_ids, l_err_org_ids;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

      l_progress := '100';
      -- Mark the error records
      FOR i IN 1 .. l_err_interface_header_ids.COUNT
      LOOP
        -- ECO bug 5584556: id-to-name conversion for new message
        -- Get the Operating Unit name
        BEGIN
          SELECT name
          INTO l_ou_name
          FROM HR_ALL_ORGANIZATION_UNITS_TL HAOUTL
          WHERE HAOUTL.organization_id = l_err_org_ids(i)
            AND language = userenv('LANG');
        EXCEPTION
          WHEN OTHERS THEN
            l_ou_name := to_char(l_err_org_ids(i));
        END;
        -- ECO bug 5584556: End

        -- ICX_CAT_INVALID_OU:
        -- "Operating Unit (VALUE) is invalid or inactive."
        PO_R12_CAT_UPG_UTL.add_fatal_error(
                  p_interface_header_id => l_err_interface_header_ids(i),
                  --p_error_message_name  => 'PO_R12_CAT_UPG_INVALID_OU',
                  p_error_message_name  => 'ICX_CAT_INVALID_OU',
                  p_table_name          => 'PO_HEADERS_INTERFACE',
                  p_column_name         => 'ORG_ID',
                  p_column_value        => l_ou_name, -- ECO bug 5584556
                  p_token1_name         => 'VALUE',
                  p_token1_value        => l_err_org_ids(i)
                  );

        l_progress := '110';
        -- Cascade errors down to lower levels
        -- Skip cascading of errors in Validate Only mode (iP Requirement - all errors should be reported)
        IF (p_validate_only_mode <> FND_API.G_TRUE) THEN
          PO_R12_CAT_UPG_UTL.reject_headers_intf('INTERFACE_HEADER_ID', l_err_interface_header_ids, 'Y');
        END IF;
      END LOOP;

      l_progress := '120';
      COMMIT;

      l_progress := '130';
      IF (l_interface_header_ids.COUNT < p_batch_size) THEN
        EXIT;
      END IF;
      l_progress := '140';
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the load_org_ids_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '150';
        COMMIT;

        l_progress := '160';
        CLOSE load_org_ids_csr;

        l_progress := '170';
        OPEN load_org_ids_csr(p_batch_id);
        l_progress := '180';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP; -- batch loop

  l_progress := '190';
  IF (load_org_ids_csr%ISOPEN) THEN
    CLOSE load_org_ids_csr;
  END IF;

  l_progress := '200';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (load_org_ids_csr%ISOPEN) THEN
      CLOSE load_org_ids_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_org_ids;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_expiration_date
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  End date cannot be earlier than start date. This procedure validates this.
--Parameters:
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_expiration_date
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_expiration_date';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  FOR i IN 1 .. p_headers_rec.expiration_date.COUNT
  LOOP
    l_progress := '020';
    IF (--p_headers_rec.has_errors(i) = 'N' AND
        p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create AND --Bug#5018883
        p_headers_rec.effective_date(i) IS NOT NULL AND
        p_headers_rec.expiration_date(i) IS NOT NULL AND
        p_headers_rec.effective_date(i) > p_headers_rec.expiration_date(i)) THEN

      l_progress := '030';
      p_headers_rec.has_errors(i) := 'Y';

      -- Add error message into INTERFACE_ERRORS table
      -- PO_PDOI_INVALID_START_DATE:
      -- "Effective Date (VALUE =VALUE) specified should be less than the end date specified."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_headers_rec.interface_header_id(i),
            p_error_message_name  => 'PO_PDOI_INVALID_START_DATE',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'EXPIRATION_DATE',
            p_column_value        => p_headers_rec.expiration_date(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => p_headers_rec.effective_date(i)
            );
    END IF;
  END LOOP;

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_expiration_date;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_buyer
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  agent_id can not be null.
--Parameters:
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_buyer
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_buyer';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  FOR i IN 1 .. p_headers_rec.agent_id.COUNT
  LOOP
    l_progress := '020';
    IF (--p_headers_rec.has_errors(i) = 'N' AND
        p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create AND --Bug#5018883
        p_headers_rec.agent_id(i) IS NULL) THEN

      l_progress := '030';
      p_headers_rec.has_errors(i) := 'Y';

      -- Add error message into INTERFACE_ERRORS table
      -- ICX_CAT_BUYER_REQD:
      -- "The system cannot obtain the default value for the buyer."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_headers_rec.interface_header_id(i),
            p_error_message_name  => 'ICX_CAT_BUYER_REQD', -- ECO bug 5584556: changed from ICX_CAT_NO_BUYER
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'AGENT_ID',
            p_column_value        => p_headers_rec.agent_id(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => p_headers_rec.agent_id(i)
            );
    END IF;
  END LOOP;

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_buyer;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_currency_code
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates currency_code not null and against FND_CURRENCIES.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_currency_code
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_currency_code';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_currency_code_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.currency_code.COUNT);

  IF (p_headers_rec.currency_code.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.currency_code(1)='||p_headers_rec.currency_code(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  -- ECO bug 5584556: Add new messages
  FOR i IN 1 .. p_headers_rec.currency_code.COUNT
  LOOP
    IF ( (p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create) AND
         (p_headers_rec.currency_code(i) IS NULL) ) THEN
      p_headers_rec.has_errors(i) := 'Y';

      -- Add error message into INTERFACE_ERRORS table
      -- ICX_CAT_CURRENCY_REQD:
      -- "Currency code is missing."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
              p_interface_header_id => l_interface_header_ids(i),
              p_error_message_name  => 'ICX_CAT_CURRENCY_REQD',
              p_table_name          => 'PO_HEADERS_INTERFACE',
              p_column_name         => 'CURRENCY_CODE',
              p_column_value        => p_headers_rec.currency_code(i)
              );
    END IF;
  END LOOP;
  -- ECO bug 5584556: End

  l_progress := '020';
  -- SQL What: Bulk validate currency_code not null and against FND_CURRENCIES.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: currency_code
  FORALL i IN 1 .. p_headers_rec.currency_code.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              index_char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.currency_code(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    -- ECO bug 5584556: Start
    -- The following validation check is already done above.
    -- So adding these additional where-clauses to skip those cases.
    AND p_headers_rec.currency_code(i) IS NOT NULL
    -- ECO bug 5584556: End
    AND NOT EXISTS(SELECT 1
                   FROM FND_CURRENCIES CUR
                   WHERE p_headers_rec.currency_code(i) = CUR.currency_code
                     AND CUR.enabled_flag = 'Y'
                     AND sysdate BETWEEN
                                 nvl(CUR.start_date_active, sysdate-1)
                             AND nvl(CUR.end_date_active, sysdate+1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, index_char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_currency_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_CURRENCY:
    -- "Currency code (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_PDOI_INVALID_CURRENCY',
            p_error_message_name  => 'ICX_CAT_INVALID_CURRENCY',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'CURRENCY_CODE',
            p_column_value        => l_err_currency_code_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_currency_code_list(i)
            );
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_currency_code;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_vendor_info
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- validate vendorId is Not Null
-- validate vendorSiteId is Not Null
-- validate vendor_id using po_suppliers_val_v
-- validate vendor_site_id using po_supplier_sites_val_v
-- validate vendor_contact_id using po_vendor_contacts
-- validate vendor site CCR if approval status is APPROVED.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_vendor_info
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_vendor_info';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_id_list         PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_name_list       PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR240;
  l_vendor_site_id_list    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_site_code_list  PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;
  l_vendor_contact_id_list PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_ccr_status    VARCHAR2(1);
  l_error_code    NUMBER;

  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;
  i NUMBER;

  -- If the profile option 'Enable Transaction Code' is set to 'Yes',
  -- then it is a Federal instance.
  l_federal_instance VARCHAR2(1) :=
                      NVL(FND_PROFILE.value('USSGL_OPTION'), 'N');
  x_temp_val BOOLEAN;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.vendor_id.COUNT);

  ----------------------------------------------------------------------------
  -- Validate vendor_id
  ----------------------------------------------------------------------------

  -- ECO bug 5584556: Add new messages
  l_progress := '020';
  -- SQL What: Bulk validate vendor_id. Check that the ID is not NULL and it exists
  --           in PO_VENDORS table.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: vendor_id
  FORALL i IN 1 .. p_headers_rec.vendor_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.vendor_id(i)
         , p_headers_rec.vendor_name(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND (p_headers_rec.vendor_id(i) IS NULL
         OR p_headers_rec.vendor_id(i) = g_NULL_COLUMN_VALUE -- -2
         OR NOT EXISTS(SELECT 1
                       FROM PO_VENDORS PV
                       WHERE p_headers_rec.vendor_id(i) = PV.vendor_id));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_vendor_id_list, l_vendor_name_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: vendor_id does not exist'||', vendor_id='||l_vendor_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_SUPPLIER_REQD:
    -- "Supplier is missing."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_SUPPLIER_REQD',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'VENDOR_ID',
            p_column_value        => l_vendor_id_list(i)
            );
  END LOOP;
  -- ECO bug 5584556: End

  l_progress := '050';
  -- SQL What: Bulk validate vendor_id.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: vendor_id
  FORALL i IN 1 .. p_headers_rec.vendor_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.vendor_id(i)
         , p_headers_rec.vendor_name(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    -- ECO bug 5584556: Start
    -- The following 3 validation checks are already done above.
    -- So adding these additional where-clauses to skip those cases.
    AND p_headers_rec.vendor_id(i) IS NOT NULL
    AND p_headers_rec.vendor_id(i) <> g_NULL_COLUMN_VALUE -- -2
    AND EXISTS(SELECT 1
               FROM PO_VENDORS PV
               WHERE p_headers_rec.vendor_id(i) = PV.vendor_id)
    -- ECO bug 5584556: End
    AND NOT EXISTS(SELECT 1
                   FROM PO_SUPPLIERS_VAL_V PSV
                   WHERE p_headers_rec.vendor_id(i) = PSV.vendor_id);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '060';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_vendor_id_list, l_vendor_name_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: vendor_name='||l_vendor_name_list(i)||', vendor_id='||l_vendor_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_SUPPLIER:
    -- "Supplier (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_PDOI_INVALID_VENDOR',
            p_error_message_name  => 'ICX_CAT_INVALID_SUPPLIER',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'VENDOR_NAME',
            p_column_value        => l_vendor_name_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_vendor_id_list(i) -- debug only
            );
  END LOOP;

  ----------------------------------------------------------------------------
  -- Validate vendor_site_id
  ----------------------------------------------------------------------------

  -- ECO bug 5584556: Start: Add new messages
  l_progress := '080';
  -- SQL What: Bulk validate vendor_site_id. Check that it is not NULL or -2.
  --           Also check that the ID exists in PO_VENDOR_SITES_ALL table.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: vendor_site_id
  FORALL i IN 1 .. p_headers_rec.vendor_site_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.vendor_site_id(i)
         , p_headers_rec.vendor_site_code(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
      p_headers_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_header_create, 'UPDATE')
      AND
      (
        (
          -- Handle null Supplier Sites for Create action only
          p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create
          AND (p_headers_rec.vendor_site_id(i) IS NULL
                OR p_headers_rec.vendor_site_id(i) = g_NULL_COLUMN_VALUE)
        )
        OR
        (
          -- Handle invalid Supplier Site id for Create/update action
          p_headers_rec.vendor_site_id(i) IS NOT NULL
          AND p_headers_rec.vendor_site_id(i) <> g_NULL_COLUMN_VALUE
          AND NOT EXISTS( SELECT 1
                         FROM PO_VENDOR_SITES_ALL PVSA
                         WHERE p_headers_rec.vendor_site_id(i) = PVSA.vendor_site_id)
        )
      );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '090';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_vendor_site_id_list, l_vendor_site_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '100';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: vendor_site_id='||l_vendor_site_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_SUPPLIER_SITE_REQD:
    -- "Supplier site is missing."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_SUPPLIER_SITE_REQD',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'VENDOR_SITE_ID',
            p_column_value        => l_vendor_site_id_list(i)
            );
  END LOOP;
  -- ECO bug 5584556: End

  l_progress := '110';
  -- SQL What: Bulk validate vendor_site_id. Check that the site is not inactive.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: vendor_site_id
  FORALL i IN 1 .. p_headers_rec.vendor_site_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.vendor_site_id(i)
         , p_headers_rec.vendor_site_code(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
      p_headers_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_header_create, 'UPDATE')
      -- ECO bug 5584556: Start
      -- The following 3 validation checks are already done above.
      -- So adding these additional where-clauses to skip those cases.
      AND p_headers_rec.vendor_site_id(i) IS NOT NULL
      AND p_headers_rec.vendor_site_id(i) <> g_NULL_COLUMN_VALUE
      AND EXISTS(SELECT 1
                 FROM PO_VENDOR_SITES_ALL PVSA
                 WHERE p_headers_rec.vendor_site_id(i) = PVSA.vendor_site_id)
      -- ECO bug 5584556: End
      AND NOT EXISTS(SELECT 1
                     FROM PO_SUPPLIER_SITES_VAL_V PSSV
                     WHERE p_headers_rec.vendor_site_id(i) = PSSV.vendor_site_id);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '120';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_vendor_site_id_list, l_vendor_site_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '130';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: vendor_site_code='||l_vendor_site_code_list(i)||', vendor_site_id='||l_vendor_site_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_SUPPLIER_SITE:
    -- "Supplier site (VALUE) is not an active and valid purchasing supplier site."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_INVALID_VENDOR_SITE_ID',
            p_error_message_name  => 'ICX_CAT_INVALID_SUPPLIER_SITE',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'VENDOR_SITE_ID',
            p_column_value        => l_vendor_site_code_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_vendor_site_code_list(i)
            );
  END LOOP;

  ----------------------------------------------------------------------------
  -- Validate vendor_contact_id
  ----------------------------------------------------------------------------

  l_progress := '140';
  -- SQL What: Bulk validate vendor_contact_id.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: vendor_id
  FORALL i IN 1 .. p_headers_rec.vendor_contact_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.vendor_contact_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
      p_headers_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_header_create, 'UPDATE')
      AND p_headers_rec.vendor_id(i) IS NOT NULL
      AND p_headers_rec.vendor_site_id(i) IS NOT NULL
      AND p_headers_rec.vendor_contact_id(i) IS NOT NULL
      AND NOT EXISTS(SELECT 1
                     FROM PO_VENDOR_CONTACTS PVC
                     WHERE p_headers_rec.vendor_site_id(i) = PVC.vendor_site_id
                       AND p_headers_rec.vendor_contact_id(i) = PVC.vendor_contact_id);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '150';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_vendor_contact_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '160';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    -- No need to error out. Just NULL out the vendor contact and proceed
    --p_headers_rec.has_errors(l_index) := 'Y';
    p_headers_rec.vendor_contact_id(l_index) := NULL;

    -- Add error message into INTERFACE_ERRORS table
    -- PO_PDOI_INVALID_VDR_CNTCT:
    -- "Supplier Contact (VALUE=VALUE) is not an active and valid contact for the specified supplier site."
    --PO_R12_CAT_UPG_UTL.add_fatal_error(
    --        p_interface_header_id => l_interface_header_ids(i),
    --        p_error_message_name  => 'PO_PDOI_INVALID_VDR_CNTCT',
    --        p_table_name          => 'PO_HEADERS_INTERFACE',
    --        p_column_name         => 'VENDOR_CONTACT_ID',
    --        p_column_value        => l_vendor_contact_id_list(i),
    --        p_token1_name         => 'VALUE',
    --        p_token1_value        => l_vendor_contact_id_list(i)
    --        );
  END LOOP;

  ----------------------------------------------------------------------------
  -- Validate vendor_site_id for CCR status
  ----------------------------------------------------------------------------

  -- The PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis() API is not
  -- available in 11.5.9. It was coded as part of the JFMIP project in 11.5.10

  -- validate vendor site CCR if approval status is APPROVED.
  l_progress := '170';
  IF (l_federal_instance = 'Y') THEN
    FOR i IN 1 .. p_headers_rec.vendor_site_id.COUNT
    LOOP

      IF (p_headers_rec.vendor_id(i) IS NOT NULL AND
          p_headers_rec.vendor_id(i) <> g_NULL_COLUMN_VALUE AND -- -2
          p_headers_rec.vendor_site_id(i) IS NOT NULL AND
          p_headers_rec.vendor_site_id(i) <> g_NULL_COLUMN_VALUE AND -- -2
          p_headers_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_header_create, 'UPDATE') --AND
          --p_headers_rec.has_errors(i) = 'N'
         ) THEN

          l_progress := '180';
          -- Call PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis to check the
          -- Central Contractor Registration (CCR) status of the vendor site
          x_temp_val := PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis(
                                p_vendor_id      => p_headers_rec.vendor_id(i),
                                p_vendor_site_id => p_headers_rec.vendor_site_id(i));

          IF (x_temp_val = FALSE) THEN
            p_headers_rec.has_errors(i) := 'Y';

            l_progress := '190';
            IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: vendor_site_code='||p_headers_rec.vendor_site_code(i)||', vendor_site_id='||p_headers_rec.vendor_site_id(i)||
                                                                                                ', vendor_name='||p_headers_rec.vendor_name(i)||', vendor_id='||p_headers_rec.vendor_id(i)); END IF;

            -- Add error message into INTERFACE_ERRORS table
            -- ICX_CAT_SUPPLIER_SITE_CCR_INV:
            -- "Supplier site (VENDOR_SITE) is assigned to a CCR supplier
            --      (VENDOR_NAME) with an expired or deleted registration."
            PO_R12_CAT_UPG_UTL.add_fatal_error(
                    p_interface_header_id => p_headers_rec.interface_header_id(i),
                    --p_error_message_name  => 'PO_PDOI_VENDOR_SITE_CCR_INV',
                    p_error_message_name  => 'ICX_CAT_SUPPLIER_SITE_CCR_INV',
                    p_table_name          => 'PO_HEADERS_INTERFACE',
                    p_column_name         => 'VENDOR_SITE_ID',
                    p_column_value        => p_headers_rec.vendor_site_code(i),
                    p_token1_name         => 'VENDOR_SITE_ID',
                    p_token1_value        => p_headers_rec.vendor_site_id(i),
                    p_token2_name         => 'VENDOR_NAME',
                    p_token2_value        => p_headers_rec.vendor_name(i)
                    );
          END IF;
       END IF;
    END LOOP;
  END IF; -- IF (l_federal_instance = 'Y')

  l_progress := '200';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_vendor_info;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_hr_location_name_from_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Performs the id-to-name conversion for location_id.
-- Used when logging validation errors.
--Parameters:
--IN:
--p_category_id
--  The LOCATION_ID for which we want the name
--OUT:
--p_category_name
--  The outut name for the given ID.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_hr_location_name_from_id
(
  p_location_id   IN NUMBER,
  x_location_name OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_hr_location_name_from_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_location_id='||p_location_id); END IF;

  -- ECO bug 5584556: id-to-name conversion for new message
  -- Get the category name
  l_progress := '020';
  BEGIN
    SELECT location_code
    INTO x_location_name
    FROM HR_LOCATIONS_ALL_TL
    WHERE location_id = p_location_id
      AND language = userenv('LANG');
  EXCEPTION
    WHEN OTHERS THEN
      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Exception while getting name from HR_LOCATIONS_ALL_TL: '||SQLERRM); END IF;

      x_location_name := p_location_id;
  END;
  -- ECO bug 5584556: End

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'location_name='||x_location_name); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_hr_location_name_from_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_ship_to_location_id
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates ship_to_location_id not null and against HR_LOCATIONS.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_ship_to_location_id
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_ship_to_location_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                 PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_ship_to_loc_id_list PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_location_name HR_LOCATIONS_ALL_TL.location_code%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.ship_to_location_id.COUNT);

  IF (p_headers_rec.currency_code.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.ship_to_location_id(1)='||p_headers_rec.ship_to_location_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- ECO bug 5584556: Start
  -- Add a separate message to check for null values and id's that dont exist

  -- SQL What: Bulk validate ship_to_location_id not null and against HR_LOCATIONS_ALL.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_to_location_id
  FORALL i IN 1 .. p_headers_rec.ship_to_location_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.ship_to_location_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND   (p_headers_rec.ship_to_location_id(i) IS NULL OR
           NOT EXISTS(SELECT 1
                      FROM HR_LOCATIONS_ALL HRLA
                      WHERE p_headers_rec.ship_to_location_id(i) = HRLA.location_id));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_ship_to_loc_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_SHIP_LOC_REQD:
    -- "The system cannot obtain the default value for the ship to location."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_SHIP_LOC_REQD',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'SHIP_TO_LOCATION_ID',
            p_column_value        => l_err_ship_to_loc_id_list(i)
            );
  END LOOP;
  -- ECO bug 5584556: End

  l_progress := '050';
  -- SQL What: Bulk validate ship_to_location_id against HR_LOCATIONS.
  --           Check if it is an active location.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_to_location_id
  FORALL i IN 1 .. p_headers_rec.ship_to_location_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.ship_to_location_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    -- ECO bug 5584556: Start
    -- The following validation checks are already done above.
    -- So adding these additional where-clauses to skip those cases.
    AND p_headers_rec.ship_to_location_id(i) IS NOT NULL
    AND EXISTS(SELECT 'ID exists'
               FROM HR_LOCATIONS_ALL HRLA
               WHERE p_headers_rec.ship_to_location_id(i) = HRLA.location_id)
    -- ECO bug 5584556: End
    AND NOT EXISTS(SELECT 'Active ship-to-location'
                   FROM HR_LOCATIONS HRL
                   WHERE HRL.ship_to_site_flag = 'Y'
                     AND p_headers_rec.ship_to_location_id(i) = HRL.location_id
                     AND SYSDATE < NVL(HRL.inactive_date, SYSDATE + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '060';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_ship_to_loc_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion for new message
    l_progress := '080';
    get_hr_location_name_from_id
    (
      p_location_id   => l_err_ship_to_loc_id_list(i)
    , x_location_name => l_location_name
    );
    -- ECO bug 5584556: End

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_SHIP_LOC:
    -- "Default ship to location (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_PDOI_INVALID_SHIP_LOC_ID',
            p_error_message_name  => 'ICX_CAT_INVALID_SHIP_LOC',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'SHIP_TO_LOCATION_ID',
            p_column_value        => l_location_name, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_ship_to_loc_id_list(i)
            );
  END LOOP;

  l_progress := '090';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_ship_to_location_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_bill_to_location_id
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates bill_to_location_id not null and against HR_LOCATIONS.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_bill_to_location_id
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_bill_to_location_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                 PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_bill_to_loc_id_list PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_location_name HR_LOCATIONS_ALL_TL.location_code%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.bill_to_location_id.COUNT);

  IF (p_headers_rec.currency_code.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.bill_to_location_id(1)='||p_headers_rec.bill_to_location_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate bill_to_location_id not null and against HR_LOCATIONS_ALL.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: bill_to_location_id
  FORALL i IN 1 .. p_headers_rec.bill_to_location_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.bill_to_location_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND   (p_headers_rec.bill_to_location_id(i) IS NULL OR
           NOT EXISTS(SELECT 1
                      FROM HR_LOCATIONS_ALL HRLA
                      WHERE p_headers_rec.bill_to_location_id(i) = HRLA.location_id));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_bill_to_loc_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_BILL_LOC_REQD:
    -- "The system cannot obtain the default value for the bill to location."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_BILL_LOC_REQD',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'BILL_TO_LOCATION_ID',
            p_column_value        => l_err_bill_to_loc_id_list(i)
            );
  END LOOP;

  l_progress := '050';
  -- SQL What: Bulk validate bill_to_location_id against HR_LOCATIONS.
  --           Check if it is an active location.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: bill_to_location_id
  FORALL i IN 1 .. p_headers_rec.bill_to_location_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.bill_to_location_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    -- ECO bug 5584556: Start
    -- The following validation checks are already done above.
    -- So adding these additional where-clauses to skip those cases.
    AND p_headers_rec.bill_to_location_id(i) IS NOT NULL
    AND EXISTS(SELECT 'ID exists'
               FROM HR_LOCATIONS_ALL HRLA
               WHERE p_headers_rec.bill_to_location_id(i) = HRLA.location_id)
    -- ECO bug 5584556: End
    AND NOT EXISTS(SELECT 1
                   FROM HR_LOCATIONS HRL
                   WHERE HRL.bill_to_site_flag = 'Y'
                     AND p_headers_rec.bill_to_location_id(i) = HRL.location_id
                     AND SYSDATE < NVL(HRL.inactive_date, SYSDATE + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '060';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_bill_to_loc_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion for new message
    l_progress := '080';
    get_hr_location_name_from_id
    (
      p_location_id   => l_err_bill_to_loc_id_list(i)
    , x_location_name => l_location_name
    );
    -- ECO bug 5584556: End

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_BILL_LOC:
    -- "Default bill to location (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'PO_PDOI_INVALID_BILL_LOC_ID',
            p_error_message_name  => 'ICX_CAT_INVALID_BILL_LOC',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'BILL_TO_LOCATION_ID',
            p_column_value        => l_location_name, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_bill_to_loc_id_list(i)
            );
  END LOOP;

  l_progress := '090';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_bill_to_location_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_lookup_name_from_code
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Performs the id-to-name conversion for PO_LOOKUP_CODES.
-- Used when logging validation errors.
--Parameters:
--IN:
--p_po_lookup_code
--  The LOOKUP_CODE for which we want the meaning
--p_po_lookup_type
--  The LOOKUP_TYPE for which we want the meaning
--OUT:
--x_lookup_meaning
--  The outut name for the given code.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_lookup_name_from_code
(
  p_po_lookup_code IN VARCHAR2,
  p_po_lookup_type IN VARCHAR2,
  x_lookup_meaning OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_lookup_name_from_code';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_po_lookup_code='||p_po_lookup_code); END IF;

  -- ECO bug 5584556: id-to-name conversion for new message
  -- Get the lookup meaning
  l_progress := '020';
  BEGIN
    SELECT displayed_field
    INTO x_lookup_meaning
    FROM PO_LOOKUP_CODES
    WHERE lookup_code = p_po_lookup_code
      AND lookup_type = p_po_lookup_type;
      -- The PO_LOOKUP_CODES is a view on top of FND_LOOKUP_VALUES with a userenv('LANG') join
      --AND language = userenv('LANG');
  EXCEPTION
    WHEN OTHERS THEN
      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Exception while getting name from PO_LOOKUP_CODES: '||SQLERRM); END IF;

      x_lookup_meaning := p_po_lookup_code;
  END;
  -- ECO bug 5584556: End

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_lookup_meaning='||x_lookup_meaning); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_lookup_name_from_code;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_fob_lookup_code
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates fob_lookup_code against PO_LOOKUP_CODES.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_fob_lookup_code
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_fob_lookup_code';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_fob_lookup_code_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_lookup_meaning PO_LOOKUP_CODES.displayed_field%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Validating a defaulted field -- FOB_LOOKUP_CODE'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.fob.COUNT);

  IF (p_headers_rec.fob.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.fob(1)='||p_headers_rec.fob(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate fob_lookup_code not null and against PO_LOOKUP_CODES.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: bill_to_location_id
  FORALL i IN 1 .. p_headers_rec.fob.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.fob(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
          p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
      AND p_headers_rec.fob(i) IS NOT NULL
      AND NOT EXISTS(SELECT 1
                       FROM PO_LOOKUP_CODES PLC
                      WHERE p_headers_rec.fob(i) = PLC.lookup_code
                        AND PLC.lookup_type = 'FOB'
                        AND SYSDATE < NVL(PLC.inactive_date, SYSDATE + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_fob_lookup_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion
    l_progress := '050';
    get_lookup_name_from_code
    (
      p_po_lookup_code => l_err_fob_lookup_code_list(i)
    , p_po_lookup_type => 'FOB'
    , x_lookup_meaning => l_lookup_meaning
    );
    -- ECO bug 5584556: End

    l_progress := '060';
    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_FOB:
    -- "Default FOB carrier (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'ICX_CAT_INVALID_FOB_CODE',
            p_error_message_name  => 'ICX_CAT_INVALID_FOB', -- Bug 5461235
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'FOB_LOOKUP_CODE',
            p_column_value        => l_lookup_meaning, -- ECO Bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_fob_lookup_code_list(i)
            );
  END LOOP;

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_fob_lookup_code;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_ship_via_luc
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates ship_via_lookup_code against ORG_FREIGHTS.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_ship_via_luc
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_ship_via_luc';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes               PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_ship_via_luc_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Validating a defaulted field -- SHIP_VIA_LOOKUP_CODE (freight_carrier)'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.freight_carrier.COUNT);

  IF (p_headers_rec.freight_carrier.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.freight_carrier(1)='||p_headers_rec.freight_carrier(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate ship_via_lookup_code against ORG_FREIGHT.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_via_lookup_code

  -- bug5601416: use default inv org id instead of master org

  FORALL i IN 1 .. p_headers_rec.freight_carrier.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.freight_carrier(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND p_headers_rec.freight_carrier(i) IS NOT NULL
    AND NOT EXISTS(SELECT 1
                   FROM ORG_FREIGHT OFR
                   WHERE p_headers_rec.freight_carrier(i) = OFR.freight_code
                   AND NVL(OFR.disable_date, SYSDATE + 1) > SYSDATE
                   AND OFR.organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_ship_via_luc_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_FREIGHT_CAR:
    -- "Default freight carrier (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_INVALID_FREIGHT_CAR', -- ECO bug 5584556: 'ICX_CAT_INVALID_SHIP_VIA_CODE',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'SHIP_VIA_LOOKUP_CODE',
            p_column_value        => l_err_ship_via_luc_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_ship_via_luc_list(i)
            );
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_ship_via_luc;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_freight_terms
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates freight_terms_lookup_code against PO_LOOKUP_CODES.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_freight_terms
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_freight_terms';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes                PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_freight_terms_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_lookup_meaning PO_LOOKUP_CODES.displayed_field%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Validating a defaulted field -- SHIP_VIA_LOOKUP_CODE (freight_carrier)'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.freight_terms.COUNT);

  IF (p_headers_rec.freight_terms.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.freight_terms(1)='||p_headers_rec.freight_terms(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate freight_terms_lookup_code against PO_LOOKUP_CODES.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_via_lookup_code
  FORALL i IN 1 .. p_headers_rec.freight_terms.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.freight_terms(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND p_headers_rec.freight_terms(i) IS NOT NULL
    AND NOT EXISTS(
          SELECT 1
            FROM PO_LOOKUP_CODES PLC
           WHERE p_headers_rec.freight_terms(i) = PLC.lookup_code
             AND PLC.lookup_type = 'FREIGHT TERMS'
             AND SYSDATE < NVL(PLC.inactive_date, SYSDATE + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_freight_terms_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion
    l_progress := '050';
    get_lookup_name_from_code
    (
      p_po_lookup_code => l_err_freight_terms_list(i)
    , p_po_lookup_type => 'FREIGHT TERMS'
    , x_lookup_meaning => l_lookup_meaning
    );
    -- ECO bug 5584556: End

    l_progress := '060';
    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_FREIGHT_TERMS:
    -- "Default freight terms (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_INVALID_FREIGHT_TERMS',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'FREIGHT_TERMS_LOOKUP_CODE',
            p_column_value        => l_lookup_meaning, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_freight_terms_list(i)
            );
  END LOOP;

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_freight_terms;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_category_name_from_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Performs the id-to-name conversion for AP's terms_id.
-- Used when logging validation errors.
--Parameters:
--IN:
--p_terms_id
--  The TERMS_ID for which we want the name
--OUT:
--p_terms_name
--  The outut name for the given ID.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_ap_terms_name_from_id
(
  p_terms_id   IN NUMBER,
  x_terms_name OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_ap_terms_name_from_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_terms_id='||p_terms_id); END IF;

  -- ECO bug 5584556: id-to-name conversion for new message
  -- Get the category name
  l_progress := '020';
  BEGIN
    SELECT name
    INTO x_terms_name
    FROM AP_TERMS_TL
    WHERE term_id = p_terms_id
      AND language = userenv('LANG');
  EXCEPTION
    WHEN OTHERS THEN
      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Exception while getting name from AP_TERMS_TL: '||SQLERRM); END IF;

      x_terms_name := p_terms_id;
  END;
  -- ECO bug 5584556: End

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'terms_name='||x_terms_name); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_ap_terms_name_from_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_terms_id
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates terms_id against AP_TERMS.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_terms_id
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_terms_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_terms_id_list    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_terms_name AP_TERMS_TL.name%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Validating a defaulted field -- SHIP_VIA_LOOKUP_CODE (freight_carrier)'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.terms_id.COUNT);

  IF (p_headers_rec.terms_id.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.terms_id(1)='||p_headers_rec.terms_id(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate terms_id against AP_TERMS.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_via_lookup_code
  FORALL i IN 1 .. p_headers_rec.terms_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.terms_id(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND p_headers_rec.terms_id(i) IS NOT NULL
    AND NOT EXISTS
          (SELECT 1
           FROM AP_TERMS APT
           WHERE p_headers_rec.terms_id(i) = APT.term_id
             AND sysdate BETWEEN
                    nvl(APT.start_date_active, sysdate - 1) AND
                    nvl(APT.end_date_active, sysdate + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_terms_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: convert id to name
    l_progress := '050';
    get_ap_terms_name_from_id
    (
      p_terms_id   => l_err_terms_id_list(i)
    , x_terms_name => l_terms_name
    );
    -- ECO bug 5584556: End

    l_progress := '060';
    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_PAY_TERMS
    -- "Default payment terms (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            --p_error_message_name  => 'ICX_CAT_INVALID_TERMS_ID',
            p_error_message_name  => 'ICX_CAT_INVALID_PAY_TERMS', -- Bug 5461235
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'TERMS_ID',
            p_column_value        => l_terms_name, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_terms_id_list(i)
            );
  END LOOP;

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_terms_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_shipping_control
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates shipping_control against PO_LOOKUP_CODES.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_shipping_control
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_shipping_control';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_shipping_control_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_lookup_meaning PO_LOOKUP_CODES.displayed_field%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Validating a defaulted field -- SHIP_VIA_LOOKUP_CODE (freight_carrier)'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.shipping_control.COUNT);

  IF (p_headers_rec.shipping_control.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.shipping_control(1)='||p_headers_rec.shipping_control(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Bulk validate shipping_control against AP_TERMS.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: ship_via_lookup_code
  FORALL i IN 1 .. p_headers_rec.shipping_control.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.shipping_control(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND p_headers_rec.shipping_control(i) IS NOT NULL
    AND NOT EXISTS(
        SELECT 1
          FROM PO_LOOKUP_CODES PLC
         WHERE p_headers_rec.shipping_control(i) = PLC.lookup_code
           AND PLC.lookup_type = 'SHIPPING CONTROL'
           AND SYSDATE < NVL(PLC.inactive_date, SYSDATE + 1));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_shipping_control_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion
    l_progress := '050';
    get_lookup_name_from_code
    (
      p_po_lookup_code => l_err_shipping_control_list(i)
    , p_po_lookup_type => 'SHIPPING CONTROL'
    , x_lookup_meaning => l_lookup_meaning
    );
    -- ECO bug 5584556: End

    l_progress := '060';
    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_SHIPPING_CTRL:
    -- "Default shipping control (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_INVALID_SHIPPING_CTRL', -- ECO bug 5584556 'ICX_CAT_INVALID_SHIP_CONTROL'
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'SHIPPING_CONTROL',
            p_column_value        => l_lookup_meaning, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_shipping_control_list(i)
            );
  END LOOP;

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_shipping_control;

-- Bug 5461235: Start
--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_rate_type_code
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Validates rate_type_code against GL_DAILY_CONVERSION_TYPES_V.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_rate_type_code
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_rate_type_code';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_rate_type_code_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.rate_type_code.COUNT);

  IF (p_headers_rec.rate_type_code.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.rate_type_code(1)='||p_headers_rec.rate_type_code(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.action(1)='||p_headers_rec.action(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.has_errors(1)='||p_headers_rec.has_errors(1)); END IF;
  END IF;

  -- ECO bug 5584556: added new message
  -- Add a separate message for NULL value of rate_type_code
  l_progress := '020';
  FOR i IN 1 .. p_headers_rec.rate_type_code.COUNT
  LOOP
    IF ( (p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create)
     AND (p_headers_rec.currency_code(i) <> PO_R12_CAT_UPG_PVT.g_sys.currency_code)
     AND (p_headers_rec.rate_type_code(i) IS NULL) ) THEN
      -- ICX_CAT_RATE_TYPE_REQD:
      -- "The system cannot obtain the default value for the rate type."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
              p_interface_header_id => p_headers_rec.interface_header_id(i),
              p_error_message_name  => 'ICX_CAT_RATE_TYPE_REQD',
              p_table_name          => 'PO_HEADERS_INTERFACE',
              p_column_name         => 'RATE_TYPE',
              p_column_value        => NULL,
              -- debug purposes only
              p_token1_name         => 'HEADER_CURRENCY',
              p_token1_value        => p_headers_rec.currency_code(i),
              p_token2_name         => 'FUNCTIONAL_CURRENCY',
              p_token2_value        => PO_R12_CAT_UPG_PVT.g_sys.currency_code
              );
    END IF;
  END LOOP;
  -- ECO bug 5584556: End

  l_progress := '030';
  -- SQL What: Bulk validate rate_type_code against GL_DAILY_CONVERSION_TYPES_V.
  --           Get the errored rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: rate_type
  FORALL i IN 1 .. p_headers_rec.rate_type_code.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_headers_rec.interface_header_id(i)
         , p_headers_rec.rate_type_code(i)
    FROM DUAL
    WHERE --p_headers_rec.has_errors(i) = 'N'
        p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create --Bug#5018883
    AND p_headers_rec.currency_code(i) <> PO_R12_CAT_UPG_PVT.g_sys.currency_code
    AND p_headers_rec.rate_type_code(i) IS NOT NULL
    AND NOT EXISTS(
        SELECT 'Rate type exists'
          FROM GL_DAILY_CONVERSION_TYPES_V GLDCT
         WHERE GLDCT.conversion_type = p_headers_rec.rate_type_code(i));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids, l_err_rate_type_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '050';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_RATE_TYPE:
    -- "Default rate type (VALUE) is inactive or invalid."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_error_message_name  => 'ICX_CAT_INVALID_RATE_TYPE',
            p_table_name          => 'PO_HEADERS_INTERFACE',
            p_column_name         => 'RATE_TYPE',
            p_column_value        => l_err_rate_type_code_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_err_rate_type_code_list(i)
            );
  END LOOP;

  l_progress := '060';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_rate_type_code;
-- Bug 5461235: End

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_headers
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This is the main function to validate headers. It calls the following
--  procedures:
--
--     validate_buyer
--     validate_currency_code
--     validate_vendor_info
--     validate_expiration_date
--     validate_ship_to_location_id
--     validate_bill_to_location_id
--     validate_fob_lookup_code
--     validate_ship_via_luc
--     validate_freight_terms
--     validate_terms_id
--     validate_shipping_control
--     validate_rate_type_code
--
--Parameters:
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_headers
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- pick a new key from temp table which will be used in all validate logic
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- validate that agent_id is not null
  validate_buyer
  (
    p_headers_rec => p_headers_rec
  );

  l_progress := '030';
  -- validate currency_code not null and against FND_CURRENCIES.
  validate_currency_code
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '040';
  -- validate vendorId is Not Null
  -- validate vendorSiteId is Not Null
  -- validate vendor_id using PO_SUPPLIERS_VAL_V
  -- validate vendor_site_id using PO_SUPPLIER_SITES_VAL_V
  -- validate vendor_contact_id using PO_VENDOR_CONTACTS
  -- validate vendor site CCR if approval status is APPROVED.
  validate_vendor_info
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '050';
  -- validate that end_date is greater than the start_date
  validate_expiration_date
  (
    p_headers_rec => p_headers_rec
  );

  l_progress := '060';
  -- validate ship_to_location_id not null and against HR_LOCATIONS.
  validate_ship_to_location_id
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '070';
  -- validate bill_to_location_id not null and against HR_LOCATIONS.
  validate_bill_to_location_id
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '080';
  validate_fob_lookup_code
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '090';
  validate_ship_via_luc
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '100';
  validate_freight_terms
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '110';
  validate_terms_id
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '120';
  validate_shipping_control
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '130';
  -- Bug 5461235
  validate_rate_type_code
  (
    p_key         => l_key,
    p_headers_rec => p_headers_rec
  );

  l_progress := '140';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_headers;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Checks that if item id is not null, that it exists in
--  MTL_SYSTEM_ITEMS table.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item
(
  p_key       IN NUMBER,
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_item';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_interface_line_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_item_id_list         PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.item_id.COUNT);

  l_progress := '020';
  -- SQL What: Bulk validate item_id. If item id is not null, it has to exist
  --           in mtl_system_items table.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: item_id
  FORALL i IN 1 .. p_lines_rec.item_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              num4)
    SELECT p_key
         , l_subscript_array(i)
         , p_lines_rec.interface_header_id(i)
         , p_lines_rec.interface_line_id(i)
         , p_lines_rec.item_id(i)
    FROM PO_LINE_TYPES_B PLT
    WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND p_lines_rec.item_id(i) is not null
      AND p_lines_rec.line_type_id(i) is not null
      AND p_lines_rec.line_type_id(i)= PLT.line_type_id
      AND PLT.outside_operation_flag is not null
      AND NOT EXISTS (SELECT 1
               FROM MTL_SYSTEM_ITEMS MSI
               WHERE MSI.inventory_item_id = p_lines_rec.item_id(i)
               AND MSI.organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id
               AND MSI.enabled_flag = 'Y'
               AND MSI.purchasing_item_flag = 'Y'
               AND MSI.purchasing_enabled_flag = 'Y'
               AND MSI.outside_operation_flag = PLT.outside_operation_flag
               AND TRUNC(nvl(MSI.start_date_active, sysdate))<= TRUNC(sysdate)
               AND TRUNC(nvl(MSI.end_date_active, sysdate)) >= TRUNC(sysdate));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, num4
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_interface_line_ids, l_item_id_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    -- For bulkloaded items, there is no issue since there is no item number.
    -- For extracted item, the item is in a PO document. Whatever happens to
    -- the item, the document is still valid. User is not going to fix
    -- existing PO documents for invalid items. Keep item as it is and dont
    -- give any exception.
    --p_lines_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Ignoring validation error in ITEM_ID='||l_item_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- PO_PDOI_INVALID_ITEM_ID:
    -- "ITEM ID (VALUE =VALUE) is not a valid purchasable item."
    --PO_R12_CAT_UPG_UTL.add_fatal_error(
    --        p_interface_header_id => l_interface_header_ids(i),
    --        p_interface_line_id   => l_interface_line_ids(i),
    --        p_error_message_name  => 'PO_PDOI_INVALID_ITEM_ID',
    --        p_table_name          => 'PO_LINES_INTERFACE',
    --        p_column_name         => 'ITEM_ID',
    --        p_column_value        => l_item_id_list(i),
    --        p_token1_name         => 'VALUE',
    --        p_token1_value        => l_item_id_list(i)
    --        );
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_item;


--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item_description
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Make sure that the item_description is populated, and also need to find out
-- if it is different from what is setup for the item.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item_description
(
  p_key       IN NUMBER,
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_item_description';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_interface_header_ids  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_interface_line_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes               PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_item_description_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR240;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.item_id.COUNT);

  l_progress := '020';
  -- SQL What: Bulk validate item_description. Make sure that the
  --           item_description is populated, and also need to find out if it
  --           is different from what is setup for the item.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: item_id
  FORALL i IN 1 .. p_lines_rec.item_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_lines_rec.interface_header_id(i)
         , p_lines_rec.interface_line_id(i)
         , p_lines_rec.item_description(i)
    FROM DUAL
    WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND (p_lines_rec.item_description(i) is null OR
          (p_lines_rec.item_id(i) is not null AND
           EXISTS (SELECT 1
                  FROM MTL_SYSTEM_ITEMS MSI
                  WHERE MSI.inventory_item_id = p_lines_rec.item_id(i)
                  AND MSI.organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id
                  AND MSI.allow_item_desc_update_flag = 'N'
                  AND p_lines_rec.item_description(i) <> MSI.description)));
                  --AND create_or_update_item_flag = 'N'))); its a parameter to PDOI, For catalog migration, it would always be 'N'

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_interface_line_ids, l_item_description_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    -- Do not give an error. In this case, ignore the description that comes from iP.
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Ignoring the validation error of item description for ITEM_ID='||p_lines_rec.item_id(l_index)||'. Also ignoring the item description from interface table'); END IF;
    p_lines_rec.item_description(l_index) := NULL;

    --p_lines_rec.has_errors(l_index) := 'Y';

    -- Add error message into INTERFACE_ERRORS table
    -- PO_PDOI_DIFF_ITEM_DESC:
    -- "Pre-defined item description cannot be changed for this item."
    --PO_R12_CAT_UPG_UTL.add_fatal_error(
    --        p_interface_header_id => l_interface_header_ids(i),
    --        p_interface_line_id   => l_interface_line_ids(i),
    --        p_error_message_name  => 'PO_PDOI_DIFF_ITEM_DESC',
    --        p_table_name          => 'PO_LINES_INTERFACE',
    --        p_column_name         => 'ITEM_DESCRIPTION',
    --        p_column_value        => l_item_description_list(i)
    --        );
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_item_description;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_uom
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- check to see if unit_meas_lookup_code is valid in mtl_item_uoms_view
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_uom
(
  p_key       IN NUMBER,
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_uom';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_interface_line_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_unit_of_measure_list PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_uom_code_list        PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR3;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.item_id.COUNT);

  IF (p_lines_rec.unit_of_measure.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_lines_rec.unit_of_measure(1)='||p_lines_rec.unit_of_measure(1)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_lines_rec.uom_code(1)='||p_lines_rec.uom_code(1)); END IF;
  END IF;

  -- ECO bug 5584556: Add new messages
  -- uom_code must not be NULL. iP populates uom_code.
  FOR i IN 1 .. p_lines_rec.uom_code.COUNT
  LOOP
    l_progress := '050';
    IF (--p_lines_rec.has_errors(i) = 'N' AND

        -- Bug 5060582: UNIT_OF_MEASURE is updatable when CREATED_BY = -12.
        -- If it is specified as NULL in INTF table, then the column
        -- remains unchanged in TXN table. This is handled via a DECODE in the
        -- UPDATE statement, later in the flow. So allow NULL value in UPDATE flow
        -- where CREATED_BY is NOT -12.
        --p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        (   p_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create
         OR
            (p_lines_rec.action(i) = 'UPDATE' AND
             p_lines_rec.created_by(i) = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER)
        )
        AND
        p_lines_rec.uom_code(i) IS NULL) THEN

      l_progress := '060';
      p_lines_rec.has_errors(i) := 'Y';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'CREATED_BY='||p_lines_rec.created_by(i)||', ACTION='||p_lines_rec.action(i)); END IF;

      -- Add error message into INTERFACE_ERRORS table
      -- ECO bug 5584556: Add new messages
      -- ICX_CAT_UOM_CODE_REQD:
      -- "Unit of measure is missing for one or more lines."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_lines_rec.interface_header_id(i),
            p_interface_line_id   => p_lines_rec.interface_line_id(i),
            p_error_message_name  => 'ICX_CAT_UOM_CODE_REQD',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'UOM_CODE',
            p_column_value        => p_lines_rec.uom_code(i)
            );
    END IF;
  END LOOP;
  -- ECO bug 5584556: End

  -- Derive unit_of_measure from uom_code
  FOR i IN 1 .. p_lines_rec.uom_code.COUNT
  LOOP
    l_progress := '020';
    IF (--p_lines_rec.has_errors(i) = 'N' AND
        p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        p_lines_rec.unit_of_measure(i) IS NULL AND
        p_lines_rec.uom_code(i) IS NOT NULL) THEN

      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Deriving unit_of_measure for uom_code='||p_lines_rec.uom_code(i)); END IF;

      BEGIN
        SELECT unit_of_measure
          INTO p_lines_rec.unit_of_measure(i)
          FROM PO_UNITS_OF_MEASURE_VAL_V
         WHERE uom_code = p_lines_rec.uom_code(i)
           -- ECO bug 5584556: This validation is already done above.
           -- So skip these cases.
           AND uom_code IS NOT NULL;
           -- ECO bug 5584556: End
      EXCEPTION
        WHEN OTHERS THEN
          p_lines_rec.unit_of_measure(i) := NULL;
      END;

      l_progress := '040';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'unit_of_measure='||p_lines_rec.unit_of_measure(i)); END IF;
    END IF;
  END LOOP;

  -- unit_of_measure must not be NULL
  FOR i IN 1 .. p_lines_rec.unit_of_measure.COUNT
  LOOP
    l_progress := '050';
    IF (--p_lines_rec.has_errors(i) = 'N' AND

        -- Bug 5060582: UNIT_OF_MEASURE is updatable when CREATED_BY = -12.
        -- If it is specified as NULL in INTF table, then the column
        -- remains unchanged in TXN table. This is handled via a DECODE in the
        -- UPDATE statement, later in the flow. So allow NULL value in UPDATE flow
        -- where CREATED_BY is NOT -12.
        --p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        (   p_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create
         OR
            (p_lines_rec.action(i) = 'UPDATE' AND
             p_lines_rec.created_by(i) = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER)
        )
        AND p_lines_rec.unit_of_measure(i) IS NULL
        -- ECO bug 5584556: This validation is already done above.
        -- So skip these cases.
        AND p_lines_rec.uom_code(i) IS NOT NULL) THEN
        -- ECO bug 5584556: End

      l_progress := '060';
      p_lines_rec.has_errors(i) := 'Y';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'CREATED_BY='||p_lines_rec.created_by(i)||', ACTION='||p_lines_rec.action(i)); END IF;

      -- Add error message into INTERFACE_ERRORS table
      -- ECO bug 5584556: Add new messages
      -- ICX_CAT_INVALID_UOM_CODE:
      -- "The following unit of measure codes are inactive or invalid: VALUE, VALUE"
      PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_lines_rec.interface_header_id(i),
            p_interface_line_id   => p_lines_rec.interface_line_id(i),
            p_error_message_name  => 'ICX_CAT_INVALID_UOM_CODE',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'UOM_CODE',
            p_column_value        => p_lines_rec.uom_code(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => p_lines_rec.uom_code(i)
            );
    END IF;
  END LOOP;

  l_progress := '070';
  -- SQL What: Bulk validate UOM. Check if unit_meas_lookup_code is valid
  --           in MTL_ITEM_UOMS_VIEW.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: item_id, unit_of_measure, inv_org_id
  FORALL i IN 1 .. p_lines_rec.item_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              char1,
                              char2)
    SELECT p_key
         , l_subscript_array(i)
         , p_lines_rec.interface_header_id(i)
         , p_lines_rec.interface_line_id(i)
         , p_lines_rec.unit_of_measure(i)
         , p_lines_rec.uom_code(i)
    FROM DUAL
    WHERE --p_lines_rec.has_errors(i) = 'N'
    p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
    AND p_lines_rec.unit_of_measure(i) is not null
    AND p_lines_rec.uom_code(i) is not null
    AND ( (p_lines_rec.item_id(i) is not null
           AND NOT EXISTS (SELECT 1
                             FROM MTL_ITEM_UOMS_VIEW MIUV
                            WHERE MIUV.inventory_item_id = p_lines_rec.item_id(i)
                              AND MIUV.organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id
                              AND MIUV.unit_of_measure = p_lines_rec.unit_of_measure(i)))
         OR
          (p_lines_rec.item_id(i) is null
           AND NOT EXISTS (SELECT 1
                             FROM MTL_UNITS_OF_MEASURE MUOM
                            WHERE MUOM.unit_of_measure = p_lines_rec.unit_of_measure(i)
                              AND sysdate < NVL(disable_date, sysdate+1))));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '080';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, char1, char2
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_interface_line_ids, l_unit_of_measure_list, l_uom_code_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '090';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_lines_rec.has_errors(l_index) := 'Y';

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: unit_of_measure='||l_unit_of_measure_list(i)||', uom_code='||l_uom_code_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_UOM_CODE:
    -- "The following unit of measure codes are inactive or invalid: VALUE, VALUE"
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_interface_line_id   => l_interface_line_ids(i),
            --p_error_message_name  => 'PO_PDOI_INVALID_UOM_CODE',
            p_error_message_name  => 'ICX_CAT_INVALID_UOM_CODE',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'UOM_CODE',
            p_column_value        => l_uom_code_list(i),
            p_token1_name         => 'VALUE',
            p_token1_value        => l_uom_code_list(i)
            );
  END LOOP;

  l_progress := '100';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_uom;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item_revision
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- If order_type_lookup_code is FIXED PRICE or RATE, or item id is null,
-- then item revision has to be NULL
-- Check to see if the item_revision exists in mtl_item_revisions table
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item_revision
(
  p_key       IN NUMBER,
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_item_revision';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_interface_line_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_item_id_list         PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_item_revision_list   PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR3;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- if item id is null, then item revision has to be NULL
  FOR i IN 1 .. p_lines_rec.item_revision.COUNT
  LOOP
    l_progress := '020';
    IF (--p_lines_rec.has_errors(i) = 'N' AND
        p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        p_lines_rec.item_id(i) IS NULL AND
        p_lines_rec.item_revision(i) IS NOT NULL) THEN

      l_progress := '030';

      -- If this happens, ignore the revision for a non-inventory item. Dont give any exception.
      --p_lines_rec.has_errors(i) := 'Y';
      p_lines_rec.item_revision(i) := NULL;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Ignoring item_revision for interface_lien-id='||p_lines_rec.interface_line_id(i)||' because item_id is NULL'); END IF;

      -- Add error message into INTERFACE_ERRORS table
      --PO_R12_CAT_UPG_UTL.add_fatal_error(
      --      p_interface_header_id => p_lines_rec.interface_header_id(i),
      --      p_interface_line_id   => p_lines_rec.interface_line_id(i),
      --      p_error_message_name  => 'PO_COLUMN_NOT_NULL',
      --      p_table_name          => 'PO_LINES_INTERFACE',
      --      p_column_name         => 'ITEM_REVISION',
      --      p_column_value        => p_lines_rec.item_revision(i)
      --      );
    END IF;
  END LOOP;

  l_progress := '040';
  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.item_id.COUNT);

  l_progress := '050';
  -- SQL What: Bulk validate item revision. Check to see if the item_revision
  --           exists in MTL_ITEM_REVISIONS table.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: item_id, item_revision
  FORALL i IN 1 .. p_lines_rec.item_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              num4,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_lines_rec.interface_header_id(i)
         , p_lines_rec.interface_line_id(i)
         , p_lines_rec.item_id(i)
         , p_lines_rec.item_revision(i)
    FROM DUAL
    WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND p_lines_rec.item_revision(i) is not null
      AND p_lines_rec.item_id(i) is not null
      AND NOT EXISTS (SELECT 1
                     FROM MTL_ITEM_REVISIONS MIR
                     WHERE MIR.inventory_item_id = p_lines_rec.item_id(i)
                       AND MIR.revision = p_lines_rec.item_revision(i));

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '060';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, num4, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_interface_line_ids, l_item_id_list, l_item_revision_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    -- Same as item ID. Keep item as it is and dont give any exception
    --p_lines_rec.has_errors(l_index) := 'Y';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Ignoring the validation error of Item Revision '|| l_item_revision_list(i) ||' for ITEM_ID='||l_item_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- PO_PDOI_ITEM_RELATED_INFO:
    -- "COLUMN_NAME (VALUE=VALUE) specified is inactive or invalid for item_id (VALUE=ITEM)."
    --PO_R12_CAT_UPG_UTL.add_fatal_error(
    --        p_interface_header_id => l_interface_header_ids(i),
    --        p_interface_line_id   => l_interface_line_ids(i),
    --        p_error_message_name  => 'PO_PDOI_ITEM_RELATED_INFO',
    --        p_table_name          => 'PO_LINES_INTERFACE',
    --        p_column_name         => 'ITEM_REVISION',
    --        p_column_value        => l_item_revision_list(i),
    --        p_token1_name         => 'COLUMN_NAME',
    --        p_token1_value        => 'ITEM_REVISION',
    --        p_token2_name         => 'VALUE',
    --        p_token2_value        => l_item_revision_list(i),
    --        p_token3_name         => 'ITEM',
    --        p_token4_value        => l_item_id_list(i)
    --        );
  END LOOP;

  l_progress := '080';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_item_revision;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_category_name_from_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Performs the id-to-name conversion for category_id.
-- Used when logging validation errors.
--Parameters:
--IN:
--p_category_id
--  The CATEGORY_ID for which we want the name
--OUT:
--p_category_name
--  The outut name for the given ID.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_category_name_from_id
(
  p_category_id   IN NUMBER,
  x_category_name OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_category_name_from_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_category_id='||p_category_id); END IF;

  -- ECO bug 5584556: id-to-name conversion for new message
  -- Get the category name
  l_progress := '020';
  BEGIN
    SELECT concatenated_segments
    INTO x_category_name
    FROM MTL_CATEGORIES_B_KFV
    WHERE category_id = p_category_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Exception while getting name from MTL_CATEGORIES_B_KFV: '||SQLERRM); END IF;

      x_category_name := p_category_id;
  END;
  -- ECO bug 5584556: End

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'category_name='||x_category_name); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_category_name_from_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ip_catgeory_name
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Performs the id-to-name conversion for ip_category_id.
-- Used when logging validation errors.
--Parameters:
--IN:
--p_ip_category_id
--  The IP_CATEGORY_ID for which we want the name
--OUT:
--x_ip_category_name
--  The outut name for the given ID.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_ip_catgeory_name
(
  p_ip_category_id      IN NUMBER,
  p_interface_header_id IN NUMBER,
  p_interface_line_id   IN NUMBER,
  x_ip_category_name  OUT NOCOPY VARCHAR2,
  x_ip_catgeory_found OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_ip_catgeory_name';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_ip_category_id='||p_ip_category_id); END IF;

  x_ip_catgeory_found := 'Y';
  -- ECO bug 5584556: id-to-name conversion for new message
  -- Get the category name
  l_progress := '020';
  BEGIN
    SELECT category_name
    INTO x_ip_category_name
    FROM ICX_CAT_CATEGORIES_V
    WHERE rt_category_id = p_ip_category_id
      AND language = userenv('LANG');
  EXCEPTION
    WHEN OTHERS THEN
      -- If the shopping category does not exist, or other cases.
      l_progress := '030';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Exception while getting IP ctageory_name using ICX_CAT_CATEGORIES_V view: '||SQLERRM); END IF;

      x_ip_catgeory_found := 'N';
  END;
  -- ECO bug 5584556: End

  IF ( (x_ip_category_name IS NULL) OR
       (x_ip_catgeory_found = 'N') ) THEN

    x_ip_category_name := p_ip_category_id;
    x_ip_catgeory_found := 'N';

    l_progress := '040';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Could not find IP category name'); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_SHOP_CATEG_REQD:
    -- "Shopping category is missing for one or more lines."
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_interface_header_id,
            p_interface_line_id   => p_interface_line_id,
            p_error_message_name  => 'ICX_CAT_SHOP_CATEG_REQD',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'IP_CATEGORY_ID',
            p_column_value        => p_ip_category_id
            );
  END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_ip_category_name='||x_ip_category_name); END IF;

  l_progress := '060';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_ip_catgeory_name;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_category
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- validate and make sure category_id is a valid category within the default
-- category set for Purchasing. Validate if category_id belong to the item.
-- Check if the Purchasing Category set has 'Validate flag' ON. If Yes, we
-- will validate the Category to exist in the 'Valid Category List'. If No,
-- we will just validate if the category is Enable and Active.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_category
(
  p_key       IN NUMBER,
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_category';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_interface_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_interface_line_ids   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_item_id_list         PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_category_id_list     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_category_name_list   PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR2000;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_validate_flag MTL_CATEGORY_SETS_V.validate_flag%TYPE;
  l_category_set_id MTL_CATEGORY_SETS_V.category_set_id%TYPE;

  l_category_name MTL_CATEGORIES_B_KFV.concatenated_segments%TYPE;

  l_ip_category_name ICX_CAT_CATEGORIES_V.category_name%TYPE;
  l_ip_catgeory_found VARCHAR2(1);
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- category_id must not be NULL
  FOR i IN 1 .. p_lines_rec.category_id.COUNT
  LOOP
    l_progress := '020';
    IF (--p_lines_rec.has_errors(i) = 'N' AND

        -- Bug 5060582: CATEGORY_ID is updatable when CREATED_BY = -12.
        -- If it is specified as NULL in INTF table, then the column
        -- remains unchanged in TXN table. This is handled via a DECODE in the
        -- UPDATE statement, later in the flow. So allow NULL value in UPDATE flow
        -- where CREATED_BY is NOT -12.
        --p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        (   p_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create
         OR
            (p_lines_rec.action(i) = 'UPDATE' AND
             p_lines_rec.created_by(i) = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER)
        )
        AND
        (p_lines_rec.category_id(i) IS NULL
         OR p_lines_rec.category_id(i) = g_NULL_COLUMN_VALUE)) -- -2
    THEN

      l_progress := '030';
      p_lines_rec.has_errors(i) := 'Y';

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: category_name='||p_lines_rec.category(i)||', category_id='||p_lines_rec.category_id(i)); END IF;
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'CREATED_BY='||p_lines_rec.created_by(i)||', ACTION='||p_lines_rec.action(i)); END IF;

      -- ECO bug 5584556: Get the IP category name, that will be the token in th err msg
      l_progress := '035';
      get_ip_catgeory_name
      (
        p_ip_category_id      => p_lines_rec.ip_category_id(i)
      , p_interface_header_id => p_lines_rec.interface_header_id(i)
      , p_interface_line_id   => p_lines_rec.interface_line_id(i)
      , x_ip_category_name    => l_ip_category_name
      , x_ip_catgeory_found   => l_ip_catgeory_found
      );
      -- ECO bug 5584556: End

      IF (l_ip_catgeory_found = 'Y') THEN
        -- Add error message into INTERFACE_ERRORS table
        -- ICX_CAT_CATEGORY_REQD:
        -- "The following categories cannot be mapped to a valid purchasing category: VALUE, VALUE"
        PO_R12_CAT_UPG_UTL.add_fatal_error(
              p_interface_header_id => p_lines_rec.interface_header_id(i),
              p_interface_line_id   => p_lines_rec.interface_line_id(i),
              --p_error_message_name  => 'PO_COLUMN_IS_NULL',
              p_error_message_name  => 'ICX_CAT_CATEGORY_REQD',
              p_table_name          => 'PO_LINES_INTERFACE',
              p_column_name         => 'CATEGORY',
              p_column_value        => l_ip_category_name, -- ECO bug 5584556
              p_token1_name         => 'PO_CATEGORY_ID',
              p_token1_value        => p_lines_rec.category(i), -- debug only, this is NULL here
              p_token2_name         => 'IP_CATGEORY_ID',
              p_token2_value        => p_lines_rec.ip_category_id(i) -- debug only
              );
      END IF; -- IF (l_ip_catgeory_found='Y')
    END IF;
  END LOOP;

  l_progress := '040';
  -- Find out the default category_set_id and validate_flag for function_area
  -- of PURCHASING".
  SELECT validate_flag, category_set_id
  INTO l_validate_flag, l_category_set_id
  FROM MTL_CATEGORY_SETS_V
  WHERE category_set_id =
       (SELECT   category_set_id
        FROM     MTL_DEFAULT_CATEGORY_SETS
        WHERE    functional_area_id = 2) ; -- Purchasing

  l_progress := '050';
  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.item_id.COUNT);

  l_progress := '060';
  -- SQL What: Bulk validate category. Validate if category_id belongs to the
  --           item.
  --           Insert the error rows into GT table.
  -- SQL Why : It will be used to mark the record in plsql table as error.
  -- SQL Join: item_id, category_id
  FORALL i IN 1 .. p_lines_rec.item_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3,
                              num4,
                              num5,
                              char1)
    SELECT p_key
         , l_subscript_array(i)
         , p_lines_rec.interface_header_id(i)
         , p_lines_rec.interface_line_id(i)
         , p_lines_rec.item_id(i)
         , p_lines_rec.category_id(i)
         , p_lines_rec.category(i) -- category name
    FROM DUAL
    WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND p_lines_rec.item_id(i) is not null
      AND p_lines_rec.category_id(i) is not null
      AND p_lines_rec.category_id(i) <> g_NULL_COLUMN_VALUE -- -2
      AND NOT EXISTS (SELECT 1
                     FROM MTL_ITEM_CATEGORIES MIC,
                          MTL_CATEGORIES MCS
                     WHERE
                         MIC.category_id = MCS.category_id
                     AND MIC.category_set_id = l_category_set_id
                     AND MIC.category_id = p_lines_rec.category_id(i)
                     AND MIC.inventory_item_id = p_lines_rec.item_id(i)
                     AND MIC.organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id
                     AND sysdate < nvl(MCS.disable_date, sysdate+1)
                     AND MCS.enabled_flag = 'Y');

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to mark the error records.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2, num3, num4, num5, char1
  BULK COLLECT INTO l_indexes, l_interface_header_ids,
                    l_interface_line_ids, l_item_id_list,
                    l_category_id_list, l_category_name_list;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '080';
  -- Mark the error records
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_lines_rec.has_errors(l_index) := 'Y';

    -- ECO bug 5584556: id-to-name conversion for new message
    l_progress := '085';
    get_category_name_from_id
    (
      p_category_id   => l_category_id_list(i)
    , x_category_name => l_category_name
    );
    -- ECO bug 5584556: End

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: category_name='||l_category_name_list(i)||', category_id='||l_category_id_list(i)||', item_id='||l_item_id_list(i)); END IF;

    -- Add error message into INTERFACE_ERRORS table
    -- ICX_CAT_INVALID_CATEGORY:
    -- "The following purchasing categories are inactive or invalid: VALUE, VALUE"
    PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => l_interface_header_ids(i),
            p_interface_line_id   => l_interface_line_ids(i),
            --p_error_message_name  => 'PO_PDOI_ITEM_RELATED_INFO',
            p_error_message_name  => 'ICX_CAT_INVALID_CATEGORY',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'CATEGORY_ID',
            p_column_value        => l_category_name, -- ECO bug 5584556
            p_token1_name         => 'VALUE',
            p_token1_value        => l_category_id_list(i),
            p_token2_name         => 'ITEM',
            p_token2_value        => l_item_id_list(i)
            );
  END LOOP;

  l_progress := '090';
  IF l_validate_flag = 'Y' THEN
    l_progress := '100';
    -- SQL What: Bulk validate category. Validate category_id against
    --           MTL_CATEGORY_SET_VALID_CATS.
    --           Insert the error rows into GT table.
    -- SQL Why : It will be used to mark the record in plsql table as error.
    -- SQL Join: category_id
    FORALL i IN 1 .. p_lines_rec.item_id.COUNT
      INSERT INTO PO_SESSION_GT(key,
                                num1,
                                num2,
                                num3,
                                num4,
                                char1)
      SELECT p_key
           , l_subscript_array(i)
           , p_lines_rec.interface_header_id(i)
           , p_lines_rec.interface_line_id(i)
           , p_lines_rec.category_id(i)
           , p_lines_rec.category(i) -- category name
      FROM DUAL
      WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND p_lines_rec.item_id(i) is null
      AND p_lines_rec.category_id(i) is not null
      AND p_lines_rec.category_id(i) <> g_NULL_COLUMN_VALUE -- -2
      AND NOT EXISTS
          (SELECT 'Y'
           FROM MTL_CATEGORIES_VL MCS,
                MTL_CATEGORY_SET_VALID_CATS MCSVC
          WHERE MCS.category_id = p_lines_rec.category_id(i)
            AND MCS.category_id = MCSVC.category_id
            AND MCSVC.category_set_id = l_category_set_id
            AND sysdate < nvl(MCS.disable_date, sysdate+1)
            AND MCS.enabled_flag = 'Y');

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

    l_progress := '110';
    -- SQL What: Transfer from session GT table to local arrays
    -- SQL Why : It will be used to mark the error records.
    -- SQL Join: key
    DELETE FROM PO_SESSION_GT
    WHERE  key = p_key
    RETURNING num1, num2, num3, num4, char1
    BULK COLLECT INTO l_indexes, l_interface_header_ids,
                      l_interface_line_ids,
                      l_category_id_list, l_category_name_list;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

    l_progress := '120';
    -- Mark the error records
    FOR i IN 1 .. l_indexes.COUNT
    LOOP
      l_index := l_indexes(i);
      p_lines_rec.has_errors(l_index) := 'Y';

      -- ECO bug 5584556: id-to-name conversion for new message
      l_progress := '125';
      get_category_name_from_id
      (
        p_category_id   => l_category_id_list(i)
      , x_category_name => l_category_name
      );
      -- ECO bug 5584556: End

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: category_name='||l_category_name_list(i)||', category_id='||l_category_id_list(i)); END IF;

      -- Add error message into INTERFACE_ERRORS table
      -- ICX_CAT_INVALID_CATEGORY:
      -- "The following purchasing categories are inactive or invalid: VALUE, VALUE"
      PO_R12_CAT_UPG_UTL.add_fatal_error(
              p_interface_header_id => l_interface_header_ids(i),
              p_interface_line_id   => l_interface_line_ids(i),
              --p_error_message_name  => 'PO_PDOI_INVALID_CATEGORY_ID',
              p_error_message_name  => 'ICX_CAT_INVALID_CATEGORY',
              p_table_name          => 'PO_LINES_INTERFACE',
              p_column_name         => 'CATEGORY_ID',
              p_column_value        => l_category_name, -- ECO bug 5584556
              p_token1_name         => 'VALUE',
              p_token1_value        => l_category_id_list(i)
              );
    END LOOP;

    l_progress := '130';

  ELSE -- IF l_validate_flag <> 'Y' THEN

    l_progress := '140';
    -- SQL What: Bulk validate category. Validate category_id against
    --           MTL_CATEGORIES_VL.
    --           Insert the error rows into GT table.
    -- SQL Why : It will be used to mark the record in plsql table as error.
    -- SQL Join: category_id
    FORALL i IN 1 .. p_lines_rec.item_id.COUNT
      INSERT INTO PO_SESSION_GT(key,
                                num1,
                                num2,
                                num3,
                                num4,
                                char1)
      SELECT p_key
           , l_subscript_array(i)
           , p_lines_rec.interface_header_id(i)
           , p_lines_rec.interface_line_id(i)
           , p_lines_rec.category_id(i)
           , p_lines_rec.category(i) -- category name
      FROM DUAL
      WHERE --p_lines_rec.has_errors(i) = 'N'
      p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE')
      AND p_lines_rec.item_id(i) is null
      AND p_lines_rec.category_id(i) is not null
      AND p_lines_rec.category_id(i) <> g_NULL_COLUMN_VALUE -- -2
      AND NOT EXISTS
          (SELECT 1
           FROM MTL_CATEGORIES_VL MCS
           WHERE MCS.category_id = p_lines_rec.category_id(i)
             AND sysdate < nvl(MCS.disable_date, sysdate+1)
             AND MCS.enabled_flag = 'Y');

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

    l_progress := '150';
    -- SQL What: Transfer from session GT table to local arrays
    -- SQL Why : It will be used to mark the error records.
    -- SQL Join: key
    DELETE FROM PO_SESSION_GT
    WHERE  key = p_key
    RETURNING num1, num2, num3, num4, char1
    BULK COLLECT INTO l_indexes, l_interface_header_ids,
                      l_interface_line_ids,
                      l_category_id_list, l_category_name_list;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

    l_progress := '160';
    -- Mark the error records
    FOR i IN 1 .. l_indexes.COUNT
    LOOP
      l_progress := '170';

      l_index := l_indexes(i);
      p_lines_rec.has_errors(l_index) := 'Y';

      -- ECO bug 5584556: id-to-name conversion for new message
      l_progress := '175';
      get_category_name_from_id
      (
        p_category_id   => l_category_id_list(i)
      , x_category_name => l_category_name
      );
      -- ECO bug 5584556: End

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'VALIDATION ERROR: category_name='||l_category_name_list(i)||', category_id='||l_category_id_list(i)); END IF;

      -- Add error message into INTERFACE_ERRORS table
      -- ICX_CAT_INVALID_CATEGORY:
      -- "The following purchasing categories are inactive or invalid: VALUE, VALUE"
      PO_R12_CAT_UPG_UTL.add_fatal_error(
              p_interface_header_id => l_interface_header_ids(i),
              p_interface_line_id   => l_interface_line_ids(i),
              --p_error_message_name  => 'PO_PDOI_INVALID_CATEGORY_ID',
              p_error_message_name  => 'ICX_CAT_INVALID_CATEGORY',
              p_table_name          => 'PO_LINES_INTERFACE',
              p_column_name         => 'CATEGORY_ID',
              p_column_value        => l_category_name, -- ECO bug 5584556
              p_token1_name         => 'VALUE',
              p_token1_value        => l_category_id_list(i)
              );
    END LOOP;
  END IF; -- IF x_validate_flag = 'Y'

  l_progress := '180';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_category;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_unit_price
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- If order_type_lookup_code is not 'FIXED PRICE', unit_price cannot be null
-- and cannot be less than zero.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_unit_price
(
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_unit_price';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  FOR i IN 1 .. p_lines_rec.unit_price.COUNT
  LOOP
    l_progress := '020';

    IF (--p_lines_rec.has_errors(i) = 'N' AND
        -- Bug 5060582: UNIT_PRICE is updatable when CREATED_BY = -12.
        -- If it is specified as NULL in INTF table, then the column
        -- remains unchanged in TXN table. This is handled via a DECODE in the
        -- UPDATE statement, later in the flow. So allow NULL value in UPDATE flow
        -- where CREATED_BY is NOT -12.
        --p_lines_rec.action(i) IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE') AND
        (    p_lines_rec.action(i) =PO_R12_CAT_UPG_PVT.g_action_line_create
         OR
            (p_lines_rec.action(i) = 'UPDATE' AND
             p_lines_rec.created_by(i) = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER)
        )
        AND
        (p_lines_rec.unit_price(i) IS NULL OR
         p_lines_rec.unit_price(i) < 0)) THEN

      l_progress := '030';

      p_lines_rec.has_errors(i) := 'Y';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'CREATED_BY='||p_lines_rec.created_by(i)||', ACTION='||p_lines_rec.action(i)); END IF;

      -- Add error message into INTERFACE_ERRORS table
      -- PO_PDOI_LT_ZERO:
      -- "COLUMN_NAME (VALUE =VALUE) specified is less than zero."
      PO_R12_CAT_UPG_UTL.add_fatal_error(
            p_interface_header_id => p_lines_rec.interface_header_id(i),
            p_interface_line_id   => p_lines_rec.interface_line_id(i),
            --p_error_message_name  => 'PO_PDOI_LT_ZERO',
            p_error_message_name  => 'ICX_CAT_INVALID_PRICE',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'UNIT_PRICE',
            p_column_value        => p_lines_rec.unit_price(i),
            p_token1_name         => 'COLUMN_NAME',
            p_token1_value        => 'UNIT_PRICE',
            p_token2_name         => 'VALUE',
            p_token2_value        => p_lines_rec.unit_price(i)
            );
    END IF;
  END LOOP;

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_unit_price;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_lines
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: May set the value of 'has_errors' to 'Y'.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This is the main function to validate lines. It calls the following
--  procedures:
--
--     validate_item
--     validate_item_revision
--     validate_item_description
--     validate_uom
--     validate_category
--     validate_unit_price
--
--  UN_NUMBERID, HAZARD_CLASS_ID: These are 2 more defaulted fields
--  (from vendor/site) that IP will not provide in Interface table. However,
--  for these 2 fields, the only validation in PDOI is that if the line
--  type is TEMP LABOR, then these fields must be NULL. Since in IP catalog
--  migration, the line type is always GOODS we do not need these validations.
--
--Parameters:
--IN/OUT:
--p_lines_rec
--  A record of plsql tables containing a batch of lines. If this validation
--  fails, the 'has_errors' column is set to 'Y'.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_lines
(
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- pick a new key from temp table which will be used in all validate logic
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- if item id is not null, it has to exist in mtl_system_items table
  validate_item
  (
    p_key       => l_key,
    p_lines_rec => p_lines_rec
  );

  l_progress := '030';
  -- if order_type_lookup_code is FIXED PRICE or RATE, or item id is null,
  -- then item revision has to be NULL
  -- check to see if there are x_item_revision exists in mtl_item_revisions table
  validate_item_revision
  (
    p_key       => l_key,
    p_lines_rec => p_lines_rec
  );

  l_progress := '040';
  -- Make sure that the item_description is populated, and also need to find out
  -- if it is different from what is setup for the item.
  validate_item_description
  (
    p_key       => l_key,
    p_lines_rec => p_lines_rec
  );

  l_progress := '050';
  --  check to see if unit_meas_lookup_code is valid in mtl_item_uoms_view
  validate_uom
  (
    p_key       => l_key,
    p_lines_rec => p_lines_rec
  );

  l_progress := '060';
  -- validate and make sure category_id is a valid category within the default
  -- category set for Purchasing. Validate if category_id belong to the item.
  -- Check if the Purchasing Category set has 'Validate flag' ON. If Yes, we
  -- will validate the Category to exist in the 'Valid Category List'. If No,
  -- we will just validate if the category is Enable and Active.
  validate_category
  (
    p_key       => l_key,
    p_lines_rec => p_lines_rec
  );

  l_progress := '070';
  -- If order_type_lookup_code is not 'FIXED PRICE', unit_price cannot be null
  -- and cannot be less than zero.
  validate_unit_price
  (
    p_lines_rec => p_lines_rec
  );

  l_progress := '080';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_lines;


--------------------------------------------------------------------------------
-- Validate ACTIONS in pre-process
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--Start of Comments
  --Name: validate_create_action
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed validation.
  --  b) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Validates CREATE actions at line, attribute and TLP levels
  --     * For Lines,
  --         checks that INTERFACE_HEADER_ID is provided where the line needs to be added to
  --     * For Attributes,
  --         checks that INTERFACE_LINE_ID is provided for which the attribute needs to be created for.
  --     * For Attributes TLP,
  --         checks that INTERFACE_LINE_ID is provided for which the attribute TLP needs to be created for
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_create_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_create_action';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_err_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_tlp_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -----------------------------------------------------------------------------
  -- CREATE action validations for Lines
  -----------------------------------------------------------------------------

  l_progress := '040';
  -- For Lines,
  --   ORIGINAL action is not allowed at line level. Use ADD action (to conform
  --   to PDOI style of action names).

  -- SQL What: validate create action at line level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, interface_header_id
  UPDATE PO_LINES_INTERFACE POLI
  SET POLI.processing_id = -POLI.processing_id,
      POLI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POLI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POLI.action = 'ORIGINAL'
  RETURNING POLI.interface_line_id, POLI.interface_header_id
  BULK COLLECT INTO l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Line level='||SQL%rowcount); END IF;

  l_progress := '050';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_line_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ORIG_NOT_ALLOWED',
          p_table_name          => 'PO_LINES_INTERFACE',
          p_column_name         => 'ACTION'
          );
  END LOOP;

  l_progress := '060';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode (iP Requirement - all errors should be reported)
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_intf('INTERFACE_LINE_ID', l_err_line_ids);
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- CREATE action validations for Attribute Values
  -----------------------------------------------------------------------------
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO_R12_CAT_UPG_PVT.g_action_line_create='||PO_R12_CAT_UPG_PVT.g_action_line_create); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO_R12_CAT_UPG_PVT.g_action_attr_create='||PO_R12_CAT_UPG_PVT.g_action_attr_create); END IF;

  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '070';
  -- For Attributes,
  --   check that INTERFACE_LINE_ID is provided for which the attribute needs to be created for

  -- SQL What: validate create action at attr level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, interface_line_id
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = PO_R12_CAT_UPG_PVT.g_action_attr_create
    AND (
           POAI.interface_line_id IS NULL
         OR
            -- the following are NOT NULL columns in the TXN table, so they must
            -- have a not null value in the INTF table as well.
           (
            --POAI.po_line_id IS NULL OR
            POAI.req_template_name IS NULL OR
            POAI.req_template_line_num IS NULL OR
            POAI.org_id IS NULL OR
            POAI.inventory_item_id IS NULL OR
            POAI.ip_category_id IS NULL
           )
        )
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '080';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_NULL_IDS',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

  l_progress := '090';
  -- Cascade errors down to TLP level
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

----------------------------------------------------------------------------------
  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '071';
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = PO_R12_CAT_UPG_PVT.g_action_attr_create
    AND (EXISTS
              (SELECT 'Invalid relationship with Line Level'
               FROM PO_LINES_INTERFACE POLI
               WHERE POLI.interface_line_id = POAI.interface_line_id
                 AND (  -- Attribute Row for GBPA must have appr action at line level
                        (POAI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE AND
                         POAI.req_template_line_num = g_NOT_REQUIRED_ID AND
                         POLI.action NOT IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE', 'DELETE'))
        )))
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '072';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INV_LINE_ACTION_BL',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '071';
  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '07';
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = PO_R12_CAT_UPG_PVT.g_action_attr_create
    AND (EXISTS
              (SELECT 'Invalid relationship with Line Level'
               FROM PO_LINES_INTERFACE POLI
               WHERE POLI.interface_line_id = POAI.interface_line_id
                 AND (  -- Attribute Row for ReqTemplate must have action as REQTEMPALTE at line level
                        ((POAI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE OR
                          POAI.req_template_line_num <> g_NOT_REQUIRED_ID) AND
                          POLI.action NOT IN ('REQTEMPLATE'))
        )))
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '072';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INV_LINE_ACTION_RT',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '073';
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = PO_R12_CAT_UPG_PVT.g_action_attr_create
    AND (
           ( -- For ReqTemplates, ALL the 3 columns must be given
             (POAI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE AND
              (POAI.req_template_line_num = g_NOT_REQUIRED_ID OR
               POAI.org_id = g_NOT_REQUIRED_ID))
             OR
             (POAI.req_template_line_num <> g_NOT_REQUIRED_ID AND
              (POAI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE OR
               POAI.org_id = g_NOT_REQUIRED_ID))
           )
        )
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '074';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ALL_3_FOR_REQT',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '075';
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = PO_R12_CAT_UPG_PVT.g_action_attr_create
    AND (
           (-- For ReqTemplates, the ReqTemplate Line must exist in Txn tables
            POAI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE AND
            POAI.req_template_line_num <> g_NOT_REQUIRED_ID AND
            POAI.org_id <> g_NOT_REQUIRED_ID AND
            NOT EXISTS
              (SELECT 'ReqTemplate Line in txn tables'
               FROM PO_REQEXPRESS_LINES_ALL PORT
               WHERE PORT.express_name = POAI.req_template_name
                 AND PORT.sequence_num = POAI.req_template_line_num
                 AND PORT.org_id = POAI.org_id)
           )
        )
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '076';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ALL_NO_REQTEMP',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

----------------------------------------------------------------------------------

  l_progress := '080';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_ATTR_ROW',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_ID'
          );
  END LOOP;

  l_progress := '090';
  -- Cascade errors down to TLP level
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- CREATE action validations for Attribute Values TLP
  -----------------------------------------------------------------------------
  -- Clear the error arrays
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_header_ids.COUNT='||l_err_header_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_line_ids.COUNT='||l_err_line_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_ids.COUNT='||l_err_attr_values_ids.COUNT); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_err_attr_values_tlp_ids.COUNT='||l_err_attr_values_tlp_ids.COUNT); END IF;

  l_err_attr_values_ids.DELETE;
  l_err_attr_values_tlp_ids.DELETE;
  l_err_line_ids.DELETE;
  l_err_header_ids.DELETE;

  l_progress := '100';
  -- For Attribute Values TLP,
  --   check that INTERFACE_LINE_ID is provided for which the attribute TLP needs to be created for

  -- SQL What: validate create action at attr TLP level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, interface_line_id
  UPDATE PO_ATTR_VALUES_TLP_INTERFACE POATI
  SET POATI.processing_id = -POATI.processing_id,
      POATI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POATI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POATI.action = PO_R12_CAT_UPG_PVT.g_action_tlp_create
    AND (
           POATI.language IS NULL
         OR
           POATI.interface_line_id IS NULL
         OR
            -- the following are NOT NULL columns in the TXN table, so they must
            -- have a not null value in the INTF table as well.
           (
            --POATI.po_line_id IS NULL OR
            POATI.req_template_name IS NULL OR
            POATI.req_template_line_num IS NULL OR
            POATI.org_id IS NULL OR
            POATI.inventory_item_id IS NULL OR
            POATI.ip_category_id IS NULL OR
            POATI.description IS NULL
           )
         OR
           (EXISTS
              (SELECT 'Invalid relationship with Line Level'
               FROM PO_LINES_INTERFACE POLI
               WHERE POLI.interface_line_id = POATI.interface_line_id
                 AND (  -- Attribute Row for GBPA must have appr action at line level
                        (POATI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE AND
                         POATI.req_template_line_num = g_NOT_REQUIRED_ID AND
                         POLI.action NOT IN (PO_R12_CAT_UPG_PVT.g_action_line_create, 'UPDATE', 'DELETE'))
                      OR
                        -- Attribute Row for ReqTemplate must have action as REQTEMPALTE at line level
                        ((POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE OR
                          POATI.req_template_line_num <> g_NOT_REQUIRED_ID) AND
                         POLI.action NOT IN ('REQTEMPLATE'))
                     )
              )
           )
         OR
           ( -- For ReqTemplates, ALL the 3 columns must be given
             (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE AND
              (POATI.req_template_line_num = g_NOT_REQUIRED_ID OR
               POATI.org_id = g_NOT_REQUIRED_ID))
             OR
             (POATI.req_template_line_num <> g_NOT_REQUIRED_ID AND
              (POATI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE OR
               POATI.org_id = g_NOT_REQUIRED_ID))
           )
         OR
           (-- For ReqTemplates, the ReqTemplate Line must exist in Txn tables
            POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE AND
            POATI.req_template_line_num <> g_NOT_REQUIRED_ID AND
            POATI.org_id <> g_NOT_REQUIRED_ID AND
            NOT EXISTS
              (SELECT 'ReqTemplate Line in txn tables'
               FROM PO_REQEXPRESS_LINES_ALL PORT
               WHERE PORT.express_name = POATI.req_template_name
                 AND PORT.sequence_num = POATI.req_template_line_num
                 AND PORT.org_id = POATI.org_id)
           )
        )
  RETURNING POATI.interface_attr_values_tlp_id, POATI.interface_line_id, POATI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_tlp_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid CREATE action at TLP level='||SQL%rowcount); END IF;

  -- TODO: Similar SQL will be used to validate Artributes TLP for Req Templates

  l_progress := '110';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_tlp_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_tlp_id => l_err_attr_values_tlp_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_TLP_ROW',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'INTERFACE_ATTR_VALUES_TLP_ID'
          );
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_create_action;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: validate_add_action
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed validation.
  --  b) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Validates ADD actions at line, attribute and TLP levels
  --     * For Headers,
  --         ADD action is not allowed.
  --     * For Lines,
  --         org_id check same as above for headers
  --         checks that a PO_HEADER_ID is provided where the line needs to be added to
  --         checks that the header document exists and was created by the Migration program
  --     * For Attributes,
  --         checks that a PO_LINE_ID is provided for which the attribute needs to be created for.
  --         checks that the document line exists for the given po_line_id
  --     * For Attributes TLP,
  --         checks that a PO_LINE_ID is provided for which the attribute TLP needs to be created for
  --         checks that the document line exists for the given po_line_id
  --         checks that the TLP row for that lang does not already exist
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_add_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_add_action';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_err_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_tlp_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -----------------------------------------------------------------------------
  -- ADD action validations for Headers
  -----------------------------------------------------------------------------

  -- For Headers,
  --   ADD action is not allowed. Use ORIGINAL.

  -- SQL What: validate add action at header level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action
  UPDATE PO_HEADERS_INTERFACE POHI
  SET POHI.processing_id = -POHI.processing_id,
      POHI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POHI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POHI.action = 'ADD'
  RETURNING POHI.interface_header_id
  BULK COLLECT INTO l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid ADD action at Header level='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_header_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ADD_NOT_ALLOWED',
          p_table_name          => 'PO_HEADERS_INTERFACE',
          p_column_name         => 'ACTION'
          );
  END LOOP;

  l_progress := '030';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode (iP Requirement - all errors should be reported)
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_headers_intf('INTERFACE_HEADER_ID', l_err_header_ids, 'Y');
  END IF;

  -----------------------------------------------------------------------------
  -- ADD action validations for Lines
  -----------------------------------------------------------------------------

  l_progress := '040';
  -- For Lines,
  --   check that a PO_HEADER_ID is provided where the line needs to be added to
  --   (The Line may be added to a Line created by -12, or a pre-existing Header)

  -- SQL What: validate ADD action at line level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_header_id
  UPDATE PO_LINES_INTERFACE POLI
  SET POLI.processing_id = -POLI.processing_id,
      POLI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POLI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POLI.action = PO_R12_CAT_UPG_PVT.g_action_line_create -- ADD
    AND (POLI.interface_header_id IS NULL OR
         (POLI.po_header_id IS NOT NULL AND
          NOT EXISTS
           (SELECT 'PO_HEADER_ID points to valid doc'
            FROM PO_HEADERS_ALL POH
            WHERE POH.po_header_id = POLI.po_header_id)))
  RETURNING POLI.interface_line_id, POLI.interface_header_id
  BULK COLLECT INTO l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid ADD action at Line level='||SQL%rowcount); END IF;

  l_progress := '050';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_line_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_HEADER_ID',
          p_table_name          => 'PO_LINES_INTERFACE',
          p_column_name         => 'PO_HEADER_ID'
          );
  END LOOP;

  l_progress := '060';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode (iP Requirement - all errors should be reported)
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_intf('INTERFACE_LINE_ID', l_err_line_ids);
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- ORIGINAL action validations for Attribute Values
  -----------------------------------------------------------------------------

  l_progress := '070';
  -- For Attributes,
  --   ORIGINAL action is not allowed. Use ADD.

  -- SQL What: validate create action at attr level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = 'ORIGINAL'
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid ORIGINAL action at Attr level='||SQL%rowcount); END IF;

  -- TODO: Similar SQL will be used to validate Artributes for Req Templates

  l_progress := '080';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ORIG_NOT_ALLOWED',
          p_table_name          => 'PO_ATTR_VALUES_INTERFACE',
          p_column_name         => 'ACTION'
          );
  END LOOP;

  l_progress := '090';
  -- Cascade errors down to TLP level
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- ORIGINAL action validations for Attribute Values TLP
  -----------------------------------------------------------------------------

  l_progress := '100';
  -- For Attribute Values TLP,
  --   ORIGINAL action is not allowed. Use ADD.

  -- SQL What: validate create action at attr TLP level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_ATTR_VALUES_TLP_INTERFACE POATI
  SET POATI.processing_id = -POATI.processing_id,
      POATI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POATI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POATI.action = 'ORIGINAL'
  RETURNING POATI.interface_attr_values_tlp_id, POATI.interface_line_id, POATI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_tlp_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid ORIGINAL action at TLP level='||SQL%rowcount); END IF;

  -- TODO: Similar SQL will be used to validate Artributes TLP for Req Templates

  l_progress := '110';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_tlp_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_tlp_id => l_err_attr_values_tlp_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_ORIG_NOT_ALLOWED',
          p_table_name          => 'PO_ATTR_VALUES_TLP_INTERFACE',
          p_column_name         => 'ACTION'
          );
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_add_action;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: validate_update_action
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed validation.
  --  b) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Validates UPDATE actions at header, line, attribute and TLP levels
  --     * For Headers,
  --         check that the ORG_ID is provided (used for defaulting from PSP, etc.)
  --         checks that a PO_HEADER_ID is provided that needs to be updated
  --         checks that the po_header_id points to a valid document
  --     * For Lines,
  --         checks that a PO_LINE_ID is provided that needs to be updated
  --         checks that the po_line_id points to a valid document
  --     * For Attributes,
  --         checks that a PO_LINE_ID is provided for which attr needs to be updated
  --         checks that the po_line_id points to a valid document
  --     * For Attributes TLP,
  --         checks that a PO_LINE_ID is provided for which TLP needs to be updated
  --         checks that the po_line_id points to a valid document
  --         check that a TLP row for the given language exists for updation
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_update_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_update_action';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_err_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_tlp_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -----------------------------------------------------------------------------
  -- UPDATE action validations for Headers
  -----------------------------------------------------------------------------

  -- For Headers,
  --   check that a PO_HEADER_ID is provided that needs to be updated
  --   check that the po_header_id points to an existing document

  -- SQL What: validate update action at Header level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_header_id
  UPDATE PO_HEADERS_INTERFACE POHI
  SET POHI.processing_id = -POHI.processing_id,
      POHI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POHI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POHI.action = 'UPDATE'
    AND (POHI.po_header_id is null
         OR NOT EXISTS
           (SELECT 'document exists'
            FROM PO_HEADERS_ALL POH
            WHERE POH.po_header_id = POHI.po_header_id))
  RETURNING POHI.interface_header_id
  BULK COLLECT INTO l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid UPDATE action at Header level='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_header_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_HEADER_ID',
          p_table_name          => 'PO_HEADERS_INTERFACE',
          p_column_name         => 'PO_HEADER_ID'
          );
  END LOOP;

  l_progress := '030';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_lines_intf(p_id_param_type => 'INTERFACE_HEADER_ID',
                                         p_id_tbl        => l_err_header_ids,
                                         p_cascade       => 'Y');
  END IF;

  -----------------------------------------------------------------------------
  -- UPDATE action validations for Lines
  -----------------------------------------------------------------------------

  -- For Lines,
  --   check that a PO_LINE_ID is provided that needs to be updated
  --   check that the po_line_id points to an existing document

  -- SQL What: validate update action at Line level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_LINES_INTERFACE POLI
  SET POLI.processing_id = -POLI.processing_id,
      POLI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POLI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POLI.action = 'UPDATE'
    AND (POLI.po_line_id is null
         OR NOT EXISTS
           (SELECT 'line exists'
            FROM PO_LINES_ALL POL
            WHERE POL.po_line_id = POLI.po_line_id))
  RETURNING POLI.interface_line_id, POLI.interface_header_id
  BULK COLLECT INTO l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid UPDATE action at Line level='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_line_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_LINE_ID',
          p_table_name          => 'po_lines_interface',
          p_column_name         => 'PO_LINE_ID'
          );
  END LOOP;

  l_progress := '050';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_intf('INTERFACE_LINE_ID', l_err_line_ids);
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- UPDATE action validations for Attribute Values
  -----------------------------------------------------------------------------

  l_progress := '060';
  -- For Attributes,
  -- If all 3 Primary Keys are NULL, its an error
  -- We need at least one PK reference to update in txn tables
  -- If PO_LINE_ID is given then RT keys must be null
  -- IF PO_LINE_ID is given, then Attr for line must exist
  -- IF RT keys is given, then Attr for RT line must exist

  -- SQL What: validate update action at attr level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = 'UPDATE'
    AND (
            -- the following are NOT NULL columns in the TXN table, so they must
            -- have a not null value in the INTF table as well.
           (
            POAI.po_line_id IS NULL OR
            POAI.req_template_name IS NULL OR
            POAI.req_template_line_num IS NULL OR
            POAI.org_id IS NULL OR
            POAI.inventory_item_id IS NULL
            --OR POAI.ip_category_id IS NULL
           )
         OR
          -- If all 3 Primary Keys are -2, its an error
          -- We need at least one PK reference to update in txn tables
           (POAI.po_line_id = g_NOT_REQUIRED_ID
            AND (POAI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POAI.req_template_line_num = g_NOT_REQUIRED_ID))

         ---------------------------------------------------
         -- If PO_LINE_ID is given then RT keys must be null
         OR
           (POAI.po_line_id <> g_NOT_REQUIRED_ID
            AND (POAI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POAI.req_template_line_num <> g_NOT_REQUIRED_ID))
         ---------------------------------------------------

         -- IF PO_LINE_ID is given, then Attr for line must exist
         OR
           (POAI.po_line_id <> g_NOT_REQUIRED_ID
            AND NOT EXISTS
              (SELECT 'Attribute row exists for PO Line'
               FROM PO_ATTRIBUTE_VALUES POAV
               WHERE POAV.po_line_id = POAI.po_line_id))
         -- IF RT keys is given, then Attr for RT line must exist
         OR
           (POAI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
            AND POAI.req_template_line_num <> g_NOT_REQUIRED_ID
            AND NOT EXISTS
              (SELECT 'Attribute row exists for Req Template Line'
               FROM PO_ATTRIBUTE_VALUES POAV
               WHERE POAV.req_template_name = POAI.req_template_name
                 AND POAV.req_template_line_num = POAI.req_template_line_num))
        )
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid UPDATE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_LINE_ID',
          p_table_name          => 'po_attr_values_interface',
          p_column_name         => 'PO_LINE_ID'
          );
  END LOOP;

  l_progress := '080';
  -- Cascade errors down to TLP level
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- UPDATE action validations for Attribute Values TLP
  -----------------------------------------------------------------------------

  l_progress := '090';
  -- For Attribute Values TLP,
  -- If all 3 Primary Keys are NULL, its an error
  -- We need at least one PK reference to update in txn tables
  -- If language is NULL, it is an error.
  -- If PO_LINE_ID is given then RT keys must be null
  -- IF PO_LINE_ID is given, then Attr for line must exist
  -- IF RT keys is given, then Attr for RT line must exist

  -- SQL What: validate update action at attr TLP level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_ATTR_VALUES_TLP_INTERFACE POATI
  SET POATI.processing_id = -POATI.processing_id,
      POATI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POATI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POATI.action = 'UPDATE'
    AND (
            -- the following are NOT NULL columns in the TXN table, so they must
            -- have a not null value in the INTF table as well.
           (
            POATI.po_line_id IS NULL OR
            POATI.req_template_name IS NULL OR
            POATI.req_template_line_num IS NULL OR
            POATI.org_id IS NULL OR
            POATI.inventory_item_id IS NULL OR
            POATI.ip_category_id IS NULL --OR
            --POATI.description IS NULL
           )

         OR POATI.language IS NULL

         OR
         -- If all 3 Primary Keys are NULL, its an error
         -- We need at least one PK reference to update in txn tables
           (POATI.po_line_id = g_NOT_REQUIRED_ID
            AND (POATI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POATI.req_template_line_num = g_NOT_REQUIRED_ID))

         ---------------------------------------------------
         -- If PO_LINE_ID is given then RT keys must be null
         OR
           (POATI.po_line_id <> g_NOT_REQUIRED_ID
            AND (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POATI.req_template_line_num <> g_NOT_REQUIRED_ID))
         ---------------------------------------------------

         -- IF PO_LINE_ID is given, then Attr for line must exist
         OR
           (POATI.po_line_id <> g_NOT_REQUIRED_ID
            AND NOT EXISTS
              (SELECT 'Attribute TLP row exists for PO Line'
               FROM PO_ATTRIBUTE_VALUES_TLP POTLP
               WHERE POTLP.po_line_id = POATI.po_line_id
                 AND POTLP.language = POATI.language))
         -- IF RT keys is given, then:
         --   1. ORG_ID must be given
         --   2. TLP row for RT line must exist
         OR
           (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
            AND POATI.req_template_line_num <> g_NOT_REQUIRED_ID
            AND (POATI.org_id = g_NOT_REQUIRED_ID OR
                 NOT EXISTS
                  (SELECT 'Attribute row exists for Req Template Line'
                   FROM PO_ATTRIBUTE_VALUES_TLP POTLP
                   WHERE POTLP.req_template_name = POATI.req_template_name
                     AND POTLP.req_template_line_num = POATI.req_template_line_num
                     AND POTLP.org_id = POATI.org_id
                     AND POTLP.language = POATI.language)))
        )
  RETURNING POATI.interface_attr_values_tlp_id, POATI.interface_line_id, POATI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_tlp_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid UPDATE action at TLP level='||SQL%rowcount); END IF;

  l_progress := '100';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_tlp_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_tlp_id => l_err_attr_values_tlp_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_LINE_ID',
          p_table_name          => 'po_attr_values_tlp_interface',
          p_column_name         => 'PO_LINE_ID'
          );
  END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_update_action;

--------------------------------------------------------------------------------
--Start of Comments
  --Name: validate_delete_action
  --Pre-reqs:
  --  The iP catalog data is populated in PO Interface tables.
  --Modifies:
  --  a) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
  --     failed validation.
  --  b) FND_MSG_PUB on unhandled exceptions.
  --Locks:
  --  None.
  --Function:
  --  Validates DELETE action at header, line, attribute and TLP levels
  --     * For Headers,
  --         checks that a PO_HEADER_ID is provided that needs to be deleted
  --         checks that the document exists and was created by the Migration program
  --     * For Lines,
  --         checks that a PO_LINE_ID is provided that needs to be deleted
  --         checks that the document exists and was created by the Migration program
  --     * For Attributes,
  --         Never allow deletion of attribute row.
  --     * For Attributes TLP,
  --         checks that a PO_LINE_ID is provided for which TLP needs to be deleted
  --         Never allow deletion of TLP for for the created_lang
  --         check that a TLP row for the given language exists for deletion
  --
  --  This API should be called during the upgrade phase only.
  --Parameters:
  --IN:
  --p_validate_only_mode
  --  Indicates if the API is being called in a Validate Only mode or not
  --OUT:
  -- None
  --
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_delete_action
(
  p_validate_only_mode           IN VARCHAR2 default FND_API.G_FALSE
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'validate_delete_action';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_err_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_err_attr_values_tlp_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_base_language FND_LANGUAGES.language_code%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -----------------------------------------------------------------------------
  -- DELETE action validations for Headers
  -----------------------------------------------------------------------------

  -- For Headers,
  --   check that a PO_HEADER_ID is provided that needs to be deleted
  --   check that the po_header_id points to a valid document

  -- SQL What: validate delete action at header level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_header_id
  UPDATE PO_HEADERS_INTERFACE POHI
  SET POHI.processing_id = -POHI.processing_id,
      POHI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POHI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POHI.action = 'DELETE'
    AND (POHI.po_header_id is null
         OR EXISTS
           (SELECT 'document not created by migration program'
            FROM PO_HEADERS_ALL POH
            WHERE POH.po_header_id = POHI.po_header_id
              AND POH.created_by <> PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER))
  RETURNING POHI.interface_header_id
  BULK COLLECT INTO l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid DELETE action at Header level='||SQL%rowcount); END IF;

  l_progress := '020';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_header_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_HEADER_ID',
          p_table_name          => 'po_headers_interface',
          p_column_name         => 'PO_HEADER_ID'
          );
  END LOOP;

  l_progress := '030';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_lines_intf(p_id_param_type => 'INTERFACE_HEADER_ID',
                                         p_id_tbl        => l_err_header_ids,
                                         p_cascade       => 'Y');
  END IF;

  -----------------------------------------------------------------------------
  -- DELETE action validations for Lines
  -----------------------------------------------------------------------------

  -- For Lines,
  --   check that a PO_LINE_ID is provided that needs to be deleted
  --   check that the document was created by the Migration program

  -- SQL What: validate delete action at line level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, po_line_id
  UPDATE PO_LINES_INTERFACE POLI
  SET POLI.processing_id = -POLI.processing_id,
      POLI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POLI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POLI.action = 'DELETE'
    AND (POLI.po_line_id is null
         OR EXISTS
           (SELECT 'line not created by migration program'
            FROM PO_LINES_ALL POL
            WHERE POL.po_line_id = POLI.po_line_id
              AND POL.created_by <> PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER))
  RETURNING POLI.interface_line_id, POLI.interface_header_id
  BULK COLLECT INTO l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid DELETE action at Line level='||SQL%rowcount); END IF;

  l_progress := '040';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_line_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_LINE_ID',
          p_table_name          => 'po_lines_interface',
          p_column_name         => 'PO_LINE_ID'
          );
  END LOOP;

  l_progress := '050';
  -- Cascade errors down to attribute and TLP levels
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_intf('INTERFACE_LINE_ID', l_err_line_ids);
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- DELETE action validations for Attribute Values
  -----------------------------------------------------------------------------

  l_progress := '060';
  -- For Attributes,
  --   Never allow deletion of attribute row
  --   If required for Lines created by -12, the Line level delete would delete
  --   the Attr row also.
  --   For ReqTemplates you may only UPDATE an Attr row, you may not
  --   delete it.

  -- SQL What: validate delete action at attr level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action
  UPDATE PO_ATTR_VALUES_INTERFACE POAI
  SET POAI.processing_id = -POAI.processing_id,
      POAI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POAI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POAI.action = 'DELETE'
  RETURNING POAI.interface_attr_values_id, POAI.interface_line_id, POAI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid DELETE action at Attr level='||SQL%rowcount); END IF;

  l_progress := '070';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_id => l_err_attr_values_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_CANT_DEL_ATTR',
          p_table_name          => 'po_attr_values_interface',
          p_column_name         => 'ATTRIBUTE_VALUE_ID'
          );
  END LOOP;

  l_progress := '080';
  -- Cascade errors down to TLP level
  -- Skip cascading of errors in Validate Only mode.
  IF (p_validate_only_mode = FND_API.G_FALSE) THEN
    PO_R12_CAT_UPG_UTL.reject_attr_values_tlp_intf('INTERFACE_LINE_ID', l_err_line_ids);
  END IF;

  -----------------------------------------------------------------------------
  -- DELETE action validations for Attribute Values TLP
  -----------------------------------------------------------------------------

  l_progress := '090';
  l_base_language := PO_R12_CAT_UPG_UTL.get_base_lang;

  -- For Attribute Values TLP,
  --   Check that a Unique Key is provided for which the attribute TLP needs to be deleted
  --   Unique key for TLP table is:
  --
  --         LANGUAGE
  --         PO_LINE_ID
  --         (REQ_TEMPLATE_NAME, REQ_TEMPLATE_LINE_NUM, ORG_ID)
  --
  --   For GBPA/BPA/Quotations:
  --     Never allow deletion of TLP row for created_language
  --   For ReqTemplates:
  --     Never allow deletion of TLP row for base_language.
  --
  --   Check that a TLP row for the given language exists for deletion
  --
  --   Note: If required for Lines created by -12, the Line level delete would delete
  --   the Attr TLP row also.
  --   For GBPA/BPA/Quotations you may only UPDATE an Attr row with the created_language
  --   you may not delete it.
  --   For ReqTemplates s you may only UPDATE an Attr row with the base_language
  --   you may not delete it.

  -- SQL What: validate delete action at attr TLP level
  -- SQL Why : To find incorrect action
  -- SQL Join: processing_id, action, ppo_line_id
  UPDATE PO_ATTR_VALUES_TLP_INTERFACE POATI
  SET POATI.processing_id = -POATI.processing_id,
      POATI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
  WHERE POATI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
    AND POATI.action = 'DELETE'
    AND (
            -- the following are NOT NULL columns in the TXN table, so they must
            -- have a not null value in the INTF table as well.
           (
            POATI.po_line_id IS NULL OR
            POATI.req_template_name IS NULL OR
            POATI.req_template_line_num IS NULL OR
            POATI.org_id IS NULL
           )

         OR POATI.language IS NULL

         OR
         -- If all 3 Primary Keys are NULL, its an error
         -- We need at least one PK reference to update in txn tables
           (POATI.po_line_id = g_NOT_REQUIRED_ID
            AND (POATI.req_template_name = g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POATI.req_template_line_num = g_NOT_REQUIRED_ID))

         ---------------------------------------------------
         -- If PO_LINE_ID is given then RT keys must be null
         OR
           (POATI.po_line_id <> g_NOT_REQUIRED_ID
            AND (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
                 OR POATI.req_template_line_num <> g_NOT_REQUIRED_ID))
         ---------------------------------------------------

         -- IF PO_LINE_ID is given, then Attr for line must exist
         OR
           (POATI.po_line_id <> g_NOT_REQUIRED_ID
            AND NOT EXISTS
              (SELECT 'Attribute TLP row exists for PO Line'
               FROM PO_ATTRIBUTE_VALUES_TLP POTLP
               WHERE POTLP.po_line_id = POATI.po_line_id
                 AND POTLP.language = POATI.language))
         -- IF RT keys is given, then:
         --    1. ORG_ID must be given
         --    2. TLP row for RT line must exist
         OR
           (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE
            AND POATI.req_template_line_num <> g_NOT_REQUIRED_ID
            AND (POATI.org_id = g_NOT_REQUIRED_ID OR
                 NOT EXISTS
                  (SELECT 'Attribute row exists for Req Template Line'
                   FROM PO_ATTRIBUTE_VALUES_TLP POTLP
                   WHERE POTLP.req_template_name = POATI.req_template_name
                     AND POTLP.req_template_line_num = POATI.req_template_line_num
                     AND POTLP.org_id = POATI.org_id
                     AND POTLP.language = POATI.language)))
         ---------------------------------------------------

         -- For GBPA/BPA/Quotations, you can not delete TLP row for created_language
         OR (POATI.po_line_id <> g_NOT_REQUIRED_ID
             AND EXISTS
              (SELECT 'TLP row for deletion is specified for created_lang'
               FROM PO_LINES_ALL POL,
                    PO_HEADERS_ALL POH
               WHERE POL.po_line_id = POATI.po_line_id
                 AND POH.po_header_id = POL.po_header_id
                 AND POH.created_language = POATI.language))
         -- For ReqTemplates, you can not delete TLP row for base_language
         OR (POATI.req_template_name <> g_NOT_REQUIRED_REQ_TEMPLATE AND
             POATI.req_template_line_num <> g_NOT_REQUIRED_ID AND
             POATI.language = l_base_language)
        )
  RETURNING POATI.interface_attr_values_tlp_id, POATI.interface_line_id, POATI.interface_header_id
  BULK COLLECT INTO l_err_attr_values_tlp_ids, l_err_line_ids, l_err_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of invalid DELETE action at TLP level='||SQL%rowcount); END IF;

  l_progress := '100';
  -- Add error message into INTERFACE_ERRORS table
  FOR i in 1..l_err_attr_values_tlp_ids.COUNT
  LOOP
    PO_R12_CAT_UPG_UTL.add_fatal_error(
          p_interface_header_id => l_err_header_ids(i),
          p_interface_line_id   => l_err_line_ids(i),
          p_interface_attr_values_tlp_id => l_err_attr_values_tlp_ids(i),
          p_error_message_name  => 'PO_CAT_UPG_INVALID_LINE_ID',
          p_table_name          => 'po_attr_values_tlp_interface',
          p_column_name         => 'PO_LINE_ID'
          );
    END LOOP;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END validate_delete_action;


END PO_R12_CAT_UPG_VAL_PVT;

/
