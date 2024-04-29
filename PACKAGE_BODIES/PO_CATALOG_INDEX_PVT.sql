--------------------------------------------------------
--  DDL for Package Body PO_CATALOG_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CATALOG_INDEX_PVT" AS
/* $Header: PO_CATALOG_INDEX_PVT.plb 120.7.12010000.11 2014/05/22 02:52:31 beyi ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_CATALOG_INDEX_PVT';
g_log_head CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

-- Read the profile option that enables/disables the debug log
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_application_err_num CONSTANT NUMBER := -20000;

-- Forward function declarations: Start

PROCEDURE populate_sessiongt_for_pa
(
  p_po_header_ids IN PO_TBL_NUMBER
);

PROCEDURE populate_sessiongt_for_quote
(
  p_po_header_id IN NUMBER
);

PROCEDURE populate_sessiongt_for_rt
(
  p_reqexpress_name IN VARCHAR2
, p_org_id          IN NUMBER
);

PROCEDURE insert_header_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
);

PROCEDURE insert_line_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
);

PROCEDURE insert_attr_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
);

PROCEDURE insert_tlp_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
);

PROCEDURE delete_processed_headers
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
);

PROCEDURE populate_sessiongt_for_orgs
(
  p_po_header_ids IN PO_TBL_NUMBER
);

-- <Bug 7655719>
-- Moved code for updating of item description and category to
-- PO_LINES_SV11.update_line
/*PROCEDURE synch_item_description
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
);

-- Bug6979842: Added new procedure synch_item_category.
PROCEDURE synch_item_category
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
);*/
-- Forward function declarations: End

--------------------------------------------------------------------------------
--Start of Comments
--Name: rebuild_index
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  To populate or rebuild the intermedia index required for iProcurement
--  Catalog Search. The search will support following document changes:
--
--           1) Global Blankets
--           2) Quotations
--           3) ReqTemplates
--
--  This API populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc. In the end, it calls the iProc API to
--  populate/rebuild the index. All exceptions in this API will be silently
--  logged in the debug logs. The errors/exceptions in th rebuild_index API
--  are not thrown up to the calling program, so as not to interrupt the
--  normal flow.
--
--Parameters:
--IN:
--p_type:
-- Specifies what kind of document is being passed in for rebuilding the
-- index. It can take the following values:
--
--           1)  'BLANKET'
--           2)  'BLANKET_BULK'
--           3)  'QUOTATION'
--           4)  'REQ_TEMPLATE'
--
--p_po_header_id
--p_reqexpress_name
--  All ID parameters of this API has default NULL values. Depending on the
--  type specified, only the respective ID has to be specified. For example,
--  when a BLANKET type is specified, only the p_po_header_id parameter has
--  to have a value specified. Other parameters such as p_reqexpress_name will be
--  ignored.
--p_org_id
--  Org ID to which the ReqTemplate belongs. This is required only if the
--  p_type parameter is REQ_TEMPLATE.
--p_po_header_ids
--  Required when p_type parameter is BLANKET_BULK. This is intended for
--  PDOI flow where documents are processed in bulk.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE rebuild_index
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'rebuild_index';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_po_header_ids PO_TBL_NUMBER := PO_TBL_NUMBER(1);
BEGIN

  -- Log the input parameters into debug logs
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_type',p_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_header_id',p_po_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_reqexpress_name',p_reqexpress_name);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_id',p_org_id);

    IF ( (p_po_header_ids IS NOT NULL) AND
         (p_po_header_ids.COUNT > 0) ) THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_header_ids.COUNT',p_po_header_ids.COUNT);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_header_ids(1)',p_po_header_ids(1));
    ELSE
      PO_DEBUG.debug_stmt (l_log_head,l_progress,'p_po_header_ids LIST is NULL');
    END IF;
  END IF;

  l_progress := '010';
  -- Main switchboard. Call the respective procedures, based on p_type.
  IF (p_type = TYPE_BLANKET) THEN

    -- <Bug 7655719>
    -- Moved code for updating of item description and category to
    -- PO_LINES_SV11.update_line
    /*synch_item_description
    (
       p_type               => p_type
    ,  p_po_header_id       => p_po_header_id
    );

    -- Bug6979842: Synch item category also.
    synch_item_category
    (
       p_type               => p_type
    ,  p_po_header_id       => p_po_header_id
    );*/

    l_po_header_ids(1) := p_po_header_id;
    populate_sessiongt_for_pa(p_po_header_ids => l_po_header_ids);

  ELSIF (p_type = TYPE_BLANKET_BULK) THEN
    /*synch_item_description
    (
       p_type               => p_type
    ,  p_po_header_ids      => p_po_header_ids
    );

    -- Bug6979842: Synch item category also.
    synch_item_category
    (
       p_type               => p_type
    ,  p_po_header_ids      => p_po_header_ids
    );*/

    populate_sessiongt_for_pa(p_po_header_ids => p_po_header_ids);

  ELSIF (p_type = TYPE_QUOTATION) THEN
    /*synch_item_description
    (
       p_type               => p_type
    ,  p_po_header_id       => p_po_header_id
    );

    -- Bug6979842: Synch item category also.
    synch_item_category
    (
       p_type               => p_type
    ,  p_po_header_id       => p_po_header_id
    );*/

    populate_sessiongt_for_quote(p_po_header_id => p_po_header_id);

  ELSIF (p_type = TYPE_REQ_TEMPLATE) THEN
    /*synch_item_description
    (
       p_type               => p_type
    ,  p_reqexpress_name    => p_reqexpress_name
    ,  p_org_id             => p_org_id
    );

    -- Bug6979842: Synch item category also.
    synch_item_category
    (
       p_type               => p_type
    ,  p_reqexpress_name    => p_reqexpress_name
    ,  p_org_id             => p_org_id
    );*/

    populate_sessiongt_for_rt( p_reqexpress_name => p_reqexpress_name
                             , p_org_id => p_org_id);
  ELSE
    -- Invalid type
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Invalid type:'||p_type); END IF;
  END IF;

  l_progress := '020';
  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
    -- do not raise the exception as rebuild_index errors have to be ignored
    -- by the calling program.
END rebuild_index;


--------------------------------------------------------------------------------
-- Internal procedures
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_sessiongt_for_quote
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  To populate or rebuild the intermedia index required for iProcurement
--  Catalog Search for Quotations. It populates the GT table with all the
--  lines in the given Quotation.
--
--  This API populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc. In the end, it calls the iProc API to
--  populate/rebuild the index. All exceptions in this API will be silently
--  logged in the debug logs. The errors/exceptions in th rebuild_index API
--  are not thrown up to the calling program, so as not to interrupt the
--  normal flow.
--
--Parameters:
--IN:
--p_po_header_id
--  The PO_HEADER_ID for the Quotation header required to be made searchable
--  in the catalog.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE populate_sessiongt_for_quote
(
  p_po_header_id IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_sessiongt_for_quote';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  l_return_status VARCHAR2(1);
  l_num_rows_is_gt NUMBER := 0;

  l_segment1 PO_HEADERS_ALL.segment1%TYPE;
BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_header_id',p_po_header_id);
  END IF;

  l_progress := '010';
  -- pick a new key for temp table
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- Insert all lines in the given Quotation into the GT table
  INSERT INTO PO_SESSION_GT
             (
               key
             , index_num1 -- PO_LINE_ID (for Quotation Line): Required by iProc
             , index_num2 -- PO_HEADER_ID (for Quotation Header): Internal to PO
             , char5      -- DATA INFO: Internal to PO
             )
  SELECT l_key
       , po_line_id       -- PO_LINE_ID (for Quotation Line): Required by iProc
       , po_header_id     -- PO_HEADER_ID (for Quotation Header): Internal to PO
       , 'QUOTATION'      -- DATA INFO: Internal to PO
  FROM   PO_LINES_ALL POL
  WHERE  po_header_id = p_po_header_id
   --bug 16690524 begin
   --and last_update_date between sysdate-1 and sysdate+1;
    AND (
        EXISTS
         (
          SELECT 'last update date of po_lines is greater than ip record'
            FROM ICX_CAT_ITEMS_CTX_HDRS_TLP HDRS
           WHERE HDRS.po_line_id = POL.po_line_id
             AND POL.last_update_date > HDRS.last_update_date
         )
         OR NOT EXISTS
         (
          SELECT '1' FROM ICX_CAT_ITEMS_CTX_HDRS_TLP HDRS
           WHERE HDRS.po_line_id = POL.po_line_id
         )
        );
   --bug 16690524 end

  l_num_rows_is_gt := SQL%rowcount;

  l_progress := '030';
  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF (l_num_rows_is_gt > 0) THEN
    IF g_debug_stmt THEN
      PO_LOG.stmt_session_gt
      (
         p_module_base     => l_log_head -- IN  VARCHAR2
       , p_position        => l_progress -- IN  NUMBER
       , p_key             => l_key      -- IN  NUMBER
       , p_column_name_tbl => NULL       -- IN  PO_TBL_VARCHAR30 DEFAULT NULL (For all columns)
      );

      SELECT segment1
      INTO l_segment1
      FROM PO_HEADERS_ALL
      WHERE po_header_id = p_po_header_id;

      PO_DEBUG.debug_stmt(l_log_head,l_progress,'SEGMENT1 = '||l_segment1||', for PO_HEADER_ID = '||p_po_header_id);
    END IF;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling iProc API ICX_CAT_POPULATE_QUOTE_GRP.populateOnlineQuotes() to rebuild index'); END IF;
    -- Call iproc api for rebuild index for Quotations
    -- Pass in the key for PO_SESSION_GT table
    l_progress := '040';

    ICX_CAT_POPULATE_QUOTE_GRP.populateOnlineQuotes
    (
      p_api_version      => 1.0,                        -- NUMBER   IN
      p_commit           => FND_API.G_TRUE,             -- VARCHAR2 IN
      p_init_msg_list    => FND_API.G_FALSE,            -- VARCHAR2 IN
      p_validation_level => FND_API.G_VALID_LEVEL_FULL, -- VARCHAR2 IN
      x_return_status    => l_return_status,            -- VARCHAR2 OUT
      p_key              => l_key                       -- NUMBER   IN
    );

    l_progress := '050';
    -- In case of error, just log in debug logs. There is no need to raise
    -- it up, because rebuild_index errors have to be ignored by the calling
    -- program.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'iProc API ICX_CAT_POPULATE_QUOTE_GRP.populateOnlineQuotes() returned error: '||l_return_status); END IF;
    END IF;
  ELSE
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Skipped: iProc API ICX_CAT_POPULATE_QUOTE_GRP.populateOnlineQuotes()'); END IF;
  END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END populate_sessiongt_for_quote;

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_sessiongt_for_rt
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  To populate or rebuild the intermedia index required for iProcurement
--  Catalog Search for ReqTempaltes. It populates the GT table with all the
--  lines in the given ReqTemplate.
--
--  This API populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc. In the end, it calls the iProc API to
--  populate/rebuild the index. All exceptions in this API will be silently
--  logged in the debug logs. The errors/exceptions in th rebuild_index API
--  are not thrown up to the calling program, so as not to interrupt the
--  normal flow.
--
--Parameters:
--IN:
--p_reqexpress_name
--  The ReqTemplate Name for the ReqTemplate that is required to be made
--  searchable in the catalog.
--p_org_id
--  The Org ID to which the ReqTemplate belongs.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE populate_sessiongt_for_rt
(
  p_reqexpress_name IN VARCHAR2
, p_org_id          IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_sessiongt_for_rt';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  l_return_status VARCHAR2(1);
  l_num_rows_is_gt NUMBER := 0;
BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- pick a new key for temp table
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- Insert all lines in the given ReqTemplate into the GT table
  INSERT INTO PO_SESSION_GT
             (
               key
             , index_char1   -- ReqTemplate Name
             , index_num1    -- Reqtemplate Line Num
             , index_num2    -- Org Id
             , char5         -- DATA INFO: Internal to PO
             )
  SELECT l_key
       , p_reqexpress_name   -- ReqTemplate Name
       , sequence_num        -- Reqtemplate Line Num
       , org_id              -- Org Id
       , 'REQ_TEMPLATE'      -- DATA INFO: Internal to PO
    FROM PO_REQEXPRESS_LINES_ALL
   WHERE express_name = p_reqexpress_name
     AND org_id = p_org_id
     and last_update_date between sysdate-1 and sysdate+1;

  l_num_rows_is_gt := SQL%rowcount;

  l_progress := '030';
  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF (l_num_rows_is_gt > 0) THEN
    IF g_debug_stmt THEN
      PO_LOG.stmt_session_gt
      (
         p_module_base     => l_log_head -- IN  VARCHAR2
       , p_position        => l_progress -- IN  NUMBER
       , p_key             => l_key      -- IN  NUMBER
       , p_column_name_tbl => NULL       -- IN  PO_TBL_VARCHAR30 DEFAULT NULL (For all columns)
      );
    END IF;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling iProc API ICX_CAT_POPULATE_REQTMPL_GRP.populateOnlineReqTemplates() to rebuild index'); END IF;
    -- Call iproc api for rebuild index for ReqTemplates
    -- Pass in the key for PO_SESSION_GT table
    l_progress := '040';

    ICX_CAT_POPULATE_REQTMPL_GRP.populateOnlineReqTemplates
    (
      p_api_version      => 1.0,                        -- NUMBER   IN
      p_commit           => FND_API.G_TRUE,             -- VARCHAR2 IN
      p_init_msg_list    => FND_API.G_FALSE,            -- VARCHAR2 IN
      p_validation_level => FND_API.G_VALID_LEVEL_FULL, -- VARCHAR2 IN
      x_return_status    => l_return_status,            -- VARCHAR2 OUT
      p_key              => l_key                       -- NUMBER   IN
    );

    l_progress := '050';
    -- In case of error, just log in debug logs. There is no need to raise
    -- it up, because rebuild_index errors have to be ignored by the calling
    -- program.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'iProc API ICX_CAT_POPULATE_REQTMPL_GRP.populateOnlineReqTemplates() returned error: '||l_return_status); END IF;
    END IF;
  ELSE
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Skipped: iProc API ICX_CAT_POPULATE_REQTMPL_GRP.populateOnlineReqTemplates()'); END IF;
  END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END populate_sessiongt_for_rt;

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_sessiongt_for_pa
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  To populate or rebuild the intermedia index required for iProcurement
--  Catalog Search for Blankets / Global Blankets. It populates the GT table
--  with all those lines in the given document, that have one of the following
--  searchable fields modified:
--
--    Header Level: SUPPLIER, SUPPLIER_SITE, SUPPLIER_CONTACT
--    Line Level  : IP_CATEGORY_ID, PO_CATEGORY_ID, SUPP_REF_NUM,
--                  SUPPLIER_PART_AUX_ID, ITEM_ID, ITEM_REVISION
--    Attr Level  : ANY FIELD
--    TLP Level   : ANY FIELD
--
--  This API populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc. In the end, it calls the iProc API to
--  populate/rebuild the index. All exceptions in this API will be silently
--  logged in the debug logs. The errors/exceptions in th rebuild_index API
--  are not thrown up to the calling program, so as not to interrupt the
--  normal flow.
--
--Parameters:
--IN:
--p_po_header_ids
--  The list of PO_HEADER_ID's for the Global Blankets that are required to be
--  made searchable in the Catalog.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE populate_sessiongt_for_pa
(
  p_po_header_ids IN PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_sessiongt_for_pa';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key PO_SESSION_GT.key%TYPE;
  l_key_remaining_headers PO_SESSION_GT.key%TYPE;
  l_key_org_assignments PO_SESSION_GT.key%TYPE;
  l_return_status VARCHAR2(1);
  l_num_rows_is_gt NUMBER := 0;

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- pick a new key for temp table, to store records to be passed to iProc
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  -- Pick another key for temp table, used for remaining headers to be processed
  -- This will be the key to those PO_HEADER_ID's in PO_SESSSION_GT table that
  -- have not been completely checked to see if they contain any changes to the
  -- searchable attributes at Heade/Line/Attr/TLP levels.
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key_remaining_headers
  FROM DUAL;

  -- Insert ALL the doc_id's that came in in the input parameter list into the
  -- 'remaining_headers' list
  FORALL i in 1..p_po_header_ids.COUNT
    INSERT INTO PO_SESSION_GT
    (
      key                       -- Key: Internal to PO
    , index_num1                -- List of Input PO_HEADER_ID's
    , char5                     -- DATA INFO: Internal to PO
    )
    VALUES
    (
      l_key_remaining_headers   -- Key: Internal to PO
    , p_po_header_ids(i)        -- List of Input PO_HEADER_ID's
    , 'Remaining PO_HEADER_IDs' -- DATA INFO: Internal to PO
    );

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_HEADER_IDs inserted into GT table='||SQL%rowcount); END IF;

  -- Insert lines for headers that have been modified
  -- The fields that need rebuild index are:
  --    SUPPLIER, SUPPLIER_SITE
  insert_header_changes
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );

  -- From now on consider only those headers that do not have any changes on it
  -- we need to figure out if there are any changes at line level for these headers
  -- Get the headers that did not have any changes i.e. p_po_header_ids - <docIds inserted in _gt>

  -- From the input list, delete those that were already marked as having
  -- header level changes
  delete_processed_headers
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );

  -- Now we have only those documents that did not have header changes
  -- For these documents check if there were any line changes
  -- Field changes that need rebuild index:
  --  IP_CATEGORY_ID, PO_CATEGORY_ID, AUXID, PART_NUM, ITEM_ID, ITEM_REVISION
  insert_line_changes
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );

  -- From the remaining headers list, delete those that have been marked as
  -- having line level changes
  --Bug#17943097 allow insert record for attr_changes/tlp_changes of subsequent lines beside previous lines change
  /*delete_processed_headers
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );*/

  -- Now we have the documents for which there were no Header or Line
  -- changes, but there could potentialy be some Attribute, TLP, Org assignment
  -- changes
  -- Field changes that need rebuild index:
  --  ANY field at Attr Level
  insert_attr_changes
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );

  -- From the remaining headers list, delete those that have been marked as
  -- having Attr level changes
  --Bug#17943097 allow insert record for attr_changes/tlp_changes of subsequent lines beside previous lines change
  /*delete_processed_headers
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );*/

  -- Now we have the documents for which there were no Header/Line/Attr
  -- changes, but there could potentialy be some TLP changes
  -- Field changes that need rebuild index:
  --  ANY field at TLP Level
  insert_tlp_changes
  (
    p_key => l_key
  , p_key_remaining_headers => l_key_remaining_headers
  );

  -- SQL What: Get the number of rows inserted in GT table
  -- SQL Why : To check if we need to call iProc API
  -- SQL Join: key
  SELECT count(*)
  INTO l_num_rows_is_gt
  FROM PO_SESSION_GT
  WHERE key = l_key;

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||l_num_rows_is_gt); END IF;

  IF (l_num_rows_is_gt > 0) THEN
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineBlankets() to rebuild index'); END IF;
    -- Call iproc api for rebuild index for ReqTemplates
    -- Pass in the key for PO_SESSION_GT table
    l_progress := '040';

    IF g_debug_stmt THEN
      PO_LOG.stmt_session_gt
      (
         p_module_base     => l_log_head -- IN  VARCHAR2
       , p_position        => l_progress -- IN  NUMBER
       , p_key             => l_key      -- IN  NUMBER
       , p_column_name_tbl => NULL       -- IN  PO_TBL_VARCHAR30 DEFAULT NULL (For all columns)
      );
    END IF;

    ICX_CAT_POPULATE_BPA_GRP.populateOnlineBlankets
    (
      p_api_version      => 1.0,                        -- NUMBER   IN
      p_commit           => FND_API.G_TRUE,             -- VARCHAR2 IN
      p_init_msg_list    => FND_API.G_FALSE,            -- VARCHAR2 IN
      p_validation_level => FND_API.G_VALID_LEVEL_FULL, -- VARCHAR2 IN
      x_return_status    => l_return_status,            -- VARCHAR2 OUT
      p_key              => l_key                       -- NUMBER   IN
    );

    l_progress := '050';
    -- In case of error, just log in debug logs. There is no need to raise
    -- it up, because rebuild_index errors have to be ignored by the calling
    -- program.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineBlankets() returned error: '||l_return_status); END IF;
    END IF;
  ELSE
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Skipped: iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineBlankets()'); END IF;
  END IF;

  -- Finally, see if Org Assignments have changed, and call a separate
  -- iProc API, to pass in Org Assignment information
  populate_sessiongt_for_orgs
  (
    p_po_header_ids => p_po_header_ids
  );

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END populate_sessiongt_for_pa;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_header_changes
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  This API tracks the changes to the following searchable fields at the Header
--  Level of a GBPA.
--
--    SUPPLIER, SUPPLIER_SITE, SUPPLIER_CONTACT
--
--  It tracks the changes by comparing the data in the Header archive table.
--  It populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc.
--
--Parameters:
--IN:
--p_key
--  The key to those records in PO_SESSSION_GT table that will be passed onto
--  the iProc API.
--p_key_remaining_headers
--  The key to those PO_HEADER_ID's in PO_SESSSION_GT table that have not been
--  completely checked to see if they contain any changes to the searchable
--  attributes at Header/Line/Attr/TLP levels.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_header_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_header_changes';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';

  -- Insert lines for headers that have been modified
  -- The fields that need rebuild index are:
  --    supplier, supplier_site, supplier_contact
  INSERT INTO PO_SESSION_GT
  (
    key
  , index_num1       -- PO_LINE_ID
  , index_char1      -- Line Changed Flag
  , index_char2      -- Attr Changed Flag
  , char1            -- TLP Changed Flag
  , char2            -- Language
  , char3            -- Global Agreement Flag
  , index_num2       -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , char5            -- DATA INFO: Internal to PO
  )
  SELECT
    p_key
  , POL.po_line_id   -- PO_LINE_ID
  , 'Y'              -- Line Changed Flag
  , NULL             -- Attr Changed Flag: n/a if line_changed_flag is Y
  , NULL             -- TLP Changed Flag: n/a if line_changed_flag is Y
  , NULL             -- Language: n/a if line_changed_flag is Y
  , POH.global_agreement_flag -- Global Agreement Flag
  , POH.po_header_id -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , 'BLANKET:HEADER' -- DATA INFO: Internal to PO
  FROM  PO_LINES_ALL POL
      , PO_HEADERS_ALL POH
      , PO_SESSION_GT GT_REMAINING_HDRS
  WHERE GT_REMAINING_HDRS.key = p_key_remaining_headers
    AND POH.po_header_id = GT_REMAINING_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POL.po_header_id = POH.po_header_id
    AND ( NOT EXISTS
             (SELECT 'Headers were archived'
                FROM PO_HEADERS_ARCHIVE_ALL POHA
               WHERE POHA.po_header_id = POH.po_header_id)
          OR
            EXISTS
             (SELECT 'Some attribute is modified'
                FROM PO_HEADERS_ARCHIVE_ALL POHA
               WHERE POHA.po_header_id = POH.po_header_id
                 AND POHA.latest_external_flag = 'Y'
                 AND (POH.vendor_id <> POHA.vendor_id OR
                      (POH.vendor_id IS NULL AND POHA.vendor_id IS NOT NULL) OR
                      (POH.vendor_id IS NOT NULL AND POHA.vendor_id IS NULL) OR
                      POH.vendor_site_id <> POHA.vendor_site_id OR
                      (POH.vendor_site_id IS NULL AND POHA.vendor_site_id IS NOT NULL) OR
                      (POH.vendor_site_id IS NOT NULL AND POHA.vendor_site_id IS NULL) OR
	              --Bug 16196550: insert records when supplier contact is modified
                      POH.vendor_contact_id <> POHA.vendor_contact_id OR
                     (POH.vendor_contact_id IS NULL AND POHA. vendor_contact_id IS NOT NULL) OR
                     (POH.vendor_contact_id IS NOT NULL AND POHA.vendor_contact_id IS NULL))));

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END insert_header_changes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_line_changes
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  This API tracks the changes to the following searchable fields at the Line
--  Level of a GBPA.
--
--    IP_CATEGORY_ID, PO_CATEGORY_ID, SUPP_REF_NUM,
--    SUPPLIER_PART_AUX_ID, ITEM_ID, ITEM_REVISION
--
--  It tracks the changes by comparing the data in the Line archive table.
--  It populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc.
--
--Parameters:
--IN:
--p_key
--  The key to those records in PO_SESSSION_GT table that will be passed onto
--  the iProc API.
--p_key_remaining_headers
--  The key to those PO_HEADER_ID's in PO_SESSSION_GT table that have not been
--  completely checked to see if they contain any changes to the searchable
--  attributes at Header/Line/Attr/TLP levels.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_line_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_line_changes';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- Now we have only those documents that did not have header changes
  -- For these documents check if there were any line changes
  -- Field changes that need rebuild index:
  --  ip_category_id, po_category_id, auxid, part_num
  -- Bug#4902870: Check for vendor_product_num changes
  INSERT INTO PO_SESSION_GT
  (
    key
  , index_num1       -- PO_LINE_ID
  , index_char1      -- Line Changed Flag
  , index_char2      -- Attr Changed Flag
  , char1            -- TLP Changed Flag
  , char2            -- Language
  , char3            -- Global Agreement Flag
  , index_num2       -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , char5            -- DATA INFO: Internal to PO
  )
  SELECT
    p_key
  , POL.po_line_id   -- PO_LINE_ID
  , 'Y'              -- Line Changed Flag
  , NULL             -- Attr Changed Flag: n/a if line_changed_flag is Y
  , NULL             -- TLP Changed Flag: n/a if line_changed_flag is Y
  , NULL             -- Language: n/a if line_changed_flag is Y
  , POH.global_agreement_flag -- Global Agreement Flag
  , POH.po_header_id -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , 'BLANKET:LINE'   -- DATA INFO: Internal to PO
  FROM  PO_LINES_ALL POL
      , PO_HEADERS_ALL POH
      , PO_SESSION_GT GT_REMAINING_HDRS
  WHERE GT_REMAINING_HDRS.key = p_key_remaining_headers
    AND POH.po_header_id = GT_REMAINING_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POL.po_header_id = POH.po_header_id
  /*Bug12530695 : Revert ECO change. Instead handle it by comparing last
    update date of po lines with extracted ip record for already extracted
    records */
  /* Bug 5559492: As part of this ECO, we are not checking if any specific list
     of columns have changed. We always call the IP's rebuild_index API.*/
    AND ( NOT EXISTS
             (SELECT 'Lines were archived'
                FROM PO_LINES_ARCHIVE_ALL POLA
               WHERE POLA.po_line_id = POL.po_line_id)
          OR
            EXISTS
              (
                SELECT 'last update date of po_lines is greater than ip record'
	            FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs
	            WHERE hdrs.PO_LINE_ID = POL.PO_LINE_ID
	            AND   POL.last_update_date > hdrs.last_update_date )
	            --Bug 13343886
	            OR
		       ( NOT EXISTS
          		(
           	 	SELECT '1' FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs WHERE HDRS.PO_LINE_ID = POL.PO_LINE_ID
          		) --Bug 13343886
                        AND Nvl(pol.expiration_date,SYSDATE+1) > SYSDATE    --17943817 filter is added so that expired line is not picked
		      )
	            );

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END insert_line_changes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_attr_changes
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  This API tracks the changes to any fields at the Attr Level of a GBPA.
--  It uses the REBUILD_SEARCH_INDEX_FLAG column in the Attr table to check
--  if the record was modified.
--  It populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc.
--
--Parameters:
--IN:
--p_key
--  The key to those records in PO_SESSSION_GT table that will be passed onto
--  the iProc API.
--p_key_remaining_headers
--  The key to those PO_HEADER_ID's in PO_SESSSION_GT table that have not been
--  completely checked to see if they contain any changes to the searchable
--  attributes at Header/Line/Attr/TLP levels.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_attr_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_attr_changes';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- Now we have the documents for which there were no Header or Line
  -- changes, but there could potentialy be some Attribute changes
  INSERT INTO PO_SESSION_GT
  (
    key
  , index_num1       -- PO_LINE_ID
  , index_char1      -- Line Changed Flag
  , index_char2      -- Attr Changed Flag
  , char1            -- TLP Changed Flag
  , char2            -- Language
  , char3            -- Global Agreement Flag
  , index_num2       -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , char5            -- DATA INFO: Internal to PO
  )
  SELECT
    p_key
  , POL.po_line_id   -- PO_LINE_ID
  , 'N'              -- Line Changed Flag
  , 'Y'              -- Attr Changed Flag
  , NULL             -- TLP Changed Flag: n/a if line_changed_flag is Y
  , NULL             -- Language: n/a if line_changed_flag is Y
  , POH.global_agreement_flag -- Global Agreement Flag
  , POH.po_header_id -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , 'BLANKET:ATTR'   -- DATA INFO: Internal to PO
  FROM  PO_LINES_ALL POL
      , PO_HEADERS_ALL POH
      , PO_ATTRIBUTE_VALUES POATR
      , PO_SESSION_GT GT_REMAINING_HDRS
  WHERE GT_REMAINING_HDRS.key = p_key_remaining_headers
    AND POH.po_header_id = GT_REMAINING_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POL.po_header_id = POH.po_header_id
    AND POATR.po_line_id = POL.po_line_id
    AND POATR.rebuild_search_index_flag = 'Y'
  /*Bug12530695 : Revert ECO change. Instead handle it by comparing last
    update date of po lines with extracted ip record for already extracted
    records */
    AND ( NOT EXISTS
             (SELECT 'Lines were archived'
              FROM PO_LINES_ARCHIVE_ALL POLA
              WHERE POLA.po_line_id = POL.po_line_id)
          OR
            EXISTS
             (
               SELECT 'last update date of po_attribute greater than ip record'
               FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs
               WHERE hdrs.PO_LINE_ID = POL.PO_LINE_ID
               AND   POATR.last_update_date > hdrs.last_update_date )
              --Bug 13343886
	            OR NOT EXISTS
          		(
            	SELECT '1' FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs WHERE HDRS.PO_LINE_ID = POL.PO_LINE_ID
          		) --Bug 13343886
          		)
     --Bug#17943097 filter duplicate lines change
     AND NOT EXISTS
     (
       SELECT '1' FROM PO_SESSION_GT psg WHERE psg.index_num1 = POL.PO_LINE_ID and psg.key=p_key
     );

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END insert_attr_changes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_tlp_changes
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  This API tracks the changes to any fields at the TLP Level of a GBPA.
--  It uses the REBUILD_SEARCH_INDEX_FLAG column in the TLP table to check
--  if the record was modified.
--  It populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc.
--
--Parameters:
--IN:
--p_key
--  The key to those records in PO_SESSSION_GT table that will be passed onto
--  the iProc API.
--p_key_remaining_headers
--  The key to those PO_HEADER_ID's in PO_SESSSION_GT table that have not been
--  completely checked to see if they contain any changes to the searchable
--  attributes at Header/Line/Attr/TLP levels.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_tlp_changes
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'insert_tlp_changes';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- Now we have the documents for which there were no Header/Line/Attr
  -- changes, but there could potentialy be some TLP changes
  INSERT INTO PO_SESSION_GT
  (
    key
  , index_num1       -- PO_LINE_ID
  , index_char1      -- Line Changed Flag
  , index_char2      -- Attr Changed Flag
  , char1            -- TLP Changed Flag
  , char2            -- Language
  , char3            -- Global Agreement Flag
  , index_num2       -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , char5            -- DATA INFO: Internal to PO
  )
  SELECT
    p_key
  , POL.po_line_id   -- PO_LINE_ID
  , 'N'              -- Line Changed Flag
  , 'N'              -- Attr Changed Flag
  , 'Y'              -- TLP Changed Flag
  , POTLP.language   -- Language
  , POH.global_agreement_flag -- Global Agreement Flag
  , POH.po_header_id -- PO_HEADER_ID (Internal to PO Dev, not required by iProc)
  , 'BLANKET:TLP'    -- DATA INFO: Internal to PO
  FROM  PO_LINES_ALL POL
      , PO_HEADERS_ALL POH
      , PO_ATTRIBUTE_VALUES_TLP POTLP
      , PO_SESSION_GT GT_REMAINING_HDRS
  WHERE GT_REMAINING_HDRS.key = p_key_remaining_headers
    AND POH.po_header_id = GT_REMAINING_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POL.po_header_id = POH.po_header_id
    AND POTLP.po_line_id = POL.po_line_id
    AND POTLP.rebuild_search_index_flag = 'Y'
  /*Bug12530695 : Revert ECO change. Instead handle it by comparing last
    update date of po lines with extracted ip record for already extracted
    records */
    AND ( NOT EXISTS
             (SELECT 'Lines were archived'
              FROM PO_LINES_ARCHIVE_ALL POLA
              WHERE POLA.po_line_id = POL.po_line_id)
          OR
            EXISTS
             (
               SELECT 'last update date of po_attribute tlp greater than ip rec'
               FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs
               WHERE hdrs.PO_LINE_ID = POL.PO_LINE_ID
               AND   POTLP.last_update_date > hdrs.last_update_date )
            --Bug 13343886
	          OR NOT EXISTS
          	(
            	SELECT '1' FROM ICX_CAT_ITEMS_CTX_HDRS_TLP hdrs WHERE HDRS.PO_LINE_ID = POL.PO_LINE_ID
          	) --Bug 13343886
          )
     --Bug#17943097 filter duplicate lines change
     AND NOT EXISTS
     (
       SELECT '1' FROM PO_SESSION_GT psg WHERE psg.index_num1 = POL.PO_LINE_ID and psg.key=p_key
     );

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or recs inserted into GT table='||SQL%rowcount); END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END insert_tlp_changes;

--------------------------------------------------------------------------------
--Start of Comments
--Name: delete_processed_headers
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (deletes data)
--Locks:
--  None.
--Function:
--  This procedure deletes the records from the 'remaining headers' queue
--  in the PO_SESSION_GT table by checking if that PO_HEADER_ID has already
--  been inserted in the 'to be processed' queue. The PO_HEADER_ID in the
--  to-be-processed queue must be present in the INDEX_NUM2 column of the
--  PO_SESSION_GT table.
--
--Parameters:
--IN:
--p_key
--  The key to those records in PO_SESSSION_GT table that will be passed onto
--  the iProc API.
--p_key_remaining_headers
--  The key to those PO_HEADER_ID's in PO_SESSSION_GT table that have not been
--  completely checked to see if they contain any changes to the searchable
--  attributes at Header/Line/Attr/TLP levels.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_processed_headers
(
  p_key IN NUMBER
, p_key_remaining_headers IN NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'delete_processed_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- From the input list, delete those that were already marked as having
  -- header level changes. The PO_HEADER_ID in the to-be-processed queue
  -- is present in the INDEX_NUM2 column of the PO_SESSION_GT table.
  DELETE FROM PO_SESSION_GT GT_REMAINING_HDRS
  WHERE GT_REMAINING_HDRS.key = p_key_remaining_headers
  AND EXISTS
       (SELECT 'Header is already present in the to-be-processed queue in GT table'
        FROM PO_SESSION_GT GT1
        WHERE GT1.key = p_key
          AND GT1.index_num2 = GT_REMAINING_HDRS.index_num1);

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_HEADER_IDs deleted='||SQL%rowcount); END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END delete_processed_headers;

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_sessiongt_for_orgs
--Pre-reqs:
--  None
--Modifies:
--  a) PO_SESSION_GT Table (inserts data to be passed onto iProc API)
--Locks:
--  None.
--Function:
--  To populate or rebuild the intermedia index required for iProcurement
--  Catalog Search for Global Blankets, if their Org Assignments have been
--  modified. It populates the GT table with all those GBPA lines in the
--  given document, that have any of the following searchable fields modified:
--
--      Enabled/Disabled Flag
--      Purchasing Org
--      Purchasing Site
--
--  This API populates the PO_SESSION_GT table with the data required in the
--  format specified by iProc. In the end, it calls the iProc API to
--  populate/rebuild the index. All exceptions in this API will be silently
--  logged in the debug logs. The errors/exceptions in the rebuild_index API
--  are not thrown up to the calling program, so as not to interrupt the
--  normal flow.
--
--Parameters:
--IN:
--  The list of PO_HEADER_ID's for the Global Blankets that are required to be
--  made searchable in the Catalog.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE populate_sessiongt_for_orgs
(
  p_po_header_ids IN PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'populate_sessiongt_for_orgs';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_key_input_headers PO_SESSION_GT.key%TYPE;
  l_key_org_assignments PO_SESSION_GT.key%TYPE;
  l_return_status VARCHAR2(1);
  l_num_rows_is_gt NUMBER := 0;
BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  l_progress := '010';
  -- Pick a key for temp table, used for org_assignemnts
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key_org_assignments
  FROM DUAL;

  -- Pick another key for temp table, used for input headers
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key_input_headers
  FROM DUAL;

  -- Insert ALL the doc_id's that came in as the input parameter list
  FORALL i in 1..p_po_header_ids.COUNT
    INSERT INTO PO_SESSION_GT
    (
      key
    , index_num1       -- PO_HEADER_IDs to be processed
    , char5            -- DATA INFO: Internal to PO
    )
    VALUES
    (
      l_key_input_headers
    , p_po_header_ids(i)                    -- PO_HEADER_IDs to be processed
    , 'ORG_ASSIGNMENT:Input PO_HEADER_IDs'  -- DATA INFO: Internal to PO
    );

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or input PO_HEADER_IDs inserted into GT table='||SQL%rowcount); END IF;

  -- Attribute changes that need rebuild index
  --  enabled_flag, purchasing org, purchasing site
  INSERT INTO PO_SESSION_GT
  (
    key
  , index_num1               -- PO_HEADER_ID
  , index_num2               -- ORG_ASSIGNMENT_ID
  , index_char1              -- Enabled/Disabled changed flag
  , index_char2              -- Other fields Changed Flag (Purc Org, Purch Site)
  , char5                    -- DATA INFO: Internal to PO
  )
  SELECT
    l_key_org_assignments
  , POH.po_header_id         -- PO_HEADER_ID
  , POGA.org_assignment_id   -- ORG_ASSIGNMENT_ID
  , 'Y'                      -- Enabled/Disabled changed flag
  , 'Y'                      -- Other fields Changed Flag (Purc Org, Purch Site)
  , 'BLANKET:ORG_ASSIGNMENT' -- DATA INFO: Internal to PO
  FROM  PO_HEADERS_ALL POH
      , PO_GA_ORG_ASSIGNMENTS POGA
      , PO_SESSION_GT GT_INPUT_HDRS
  WHERE GT_INPUT_HDRS.key = l_key_input_headers
    AND POH.po_header_id = GT_INPUT_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POH.global_agreement_flag = 'Y'
    AND POGA.po_header_id = POH.po_header_id
    AND ( NOT EXISTS
             (SELECT 'Headers were archived'
                FROM PO_GA_ORG_ASSIGNMENTS_ARCHIVE ARCH
               WHERE ARCH.org_assignment_id = POGA.org_assignment_id))
  UNION ALL
  SELECT
    l_key_org_assignments
  , POH.po_header_id         -- PO_HEADER_ID
  , POGA.org_assignment_id   -- ORG_ASSIGNMENT_ID
  , 'Y'                      -- Enabled/Disabled changed flag
  , 'N'                      -- Other fields Changed Flag (Purc Org, Purch Site)
  , 'BLANKET:ORG_ASSIGNMENT' -- DATA INFO: Internal to PO
  FROM  PO_HEADERS_ALL POH
      , PO_GA_ORG_ASSIGNMENTS POGA
      , PO_SESSION_GT GT_INPUT_HDRS
  WHERE GT_INPUT_HDRS.key = l_key_input_headers
    AND POH.po_header_id = GT_INPUT_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POH.global_agreement_flag = 'Y'
    AND POGA.po_header_id = POH.po_header_id
    AND EXISTS
             (SELECT 'Only Enabled/disabled flag is modified'
                FROM PO_GA_ORG_ASSIGNMENTS_ARCHIVE ARCH
               WHERE ARCH.org_assignment_id = POGA.org_assignment_id
                 AND ARCH.latest_external_flag = 'Y'
                 AND ARCH.enabled_flag <> POGA.enabled_flag
                 AND ARCH.purchasing_org_id = POGA.purchasing_org_id
                 AND ARCH.vendor_site_id = POGA.vendor_site_id)
  UNION ALL
  SELECT
    l_key_org_assignments
  , POH.po_header_id         -- PO_HEADER_ID
  , POGA.org_assignment_id   -- ORG_ASSIGNMENT_ID
  , 'N'                      -- Enabled/Disabled changed flag
  , 'Y'                      -- Other fields Changed Flag (Purc Org, Purch Site)
  , 'BLANKET:ORG_ASSIGNMENT' -- DATA INFO: Internal to PO
  FROM  PO_HEADERS_ALL POH
      , PO_GA_ORG_ASSIGNMENTS POGA
      , PO_SESSION_GT GT_INPUT_HDRS
  WHERE GT_INPUT_HDRS.key = l_key_input_headers
    AND POH.po_header_id = GT_INPUT_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POH.global_agreement_flag = 'Y'
    AND POGA.po_header_id = POH.po_header_id
    AND EXISTS
             (SELECT 'Only Purch Org/Purch Site is modified'
                FROM PO_GA_ORG_ASSIGNMENTS_ARCHIVE ARCH
               WHERE ARCH.org_assignment_id = POGA.org_assignment_id
                 AND ARCH.latest_external_flag = 'Y'
                 AND (ARCH.purchasing_org_id <> POGA.purchasing_org_id OR
                      ARCH.vendor_site_id <> POGA.vendor_site_id)
                 AND ARCH.enabled_flag = POGA.enabled_flag)
  UNION ALL
  SELECT
    l_key_org_assignments
  , POH.po_header_id         -- PO_HEADER_ID
  , POGA.org_assignment_id   -- ORG_ASSIGNMENT_ID
  , 'Y'                      -- Enabled/Disabled changed flag
  , 'Y'                      -- Other fields Changed Flag (Purc Org, Purch Site)
  , 'BLANKET:ORG_ASSIGNMENT' -- DATA INFO: Internal to PO
  FROM  PO_HEADERS_ALL POH
      , PO_GA_ORG_ASSIGNMENTS POGA
      , PO_SESSION_GT GT_INPUT_HDRS
  WHERE GT_INPUT_HDRS.key = l_key_input_headers
    AND POH.po_header_id = GT_INPUT_HDRS.index_num1 -- index_num1 stores the PO_HEADER_ID
    AND POH.global_agreement_flag = 'Y'
    AND POGA.po_header_id = POH.po_header_id
    AND EXISTS
             (SELECT 'Both enable_flag AND Purch Org/Purch Site are modified'
                FROM PO_GA_ORG_ASSIGNMENTS_ARCHIVE ARCH
               WHERE ARCH.org_assignment_id = POGA.org_assignment_id
                 AND ARCH.latest_external_flag = 'Y'
                 AND (ARCH.purchasing_org_id <> POGA.purchasing_org_id OR
                      ARCH.vendor_site_id <> POGA.vendor_site_id)
                 AND ARCH.enabled_flag <> POGA.enabled_flag);

  l_num_rows_is_gt := SQL%rowcount;

  IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number of recs inserted into GT table='||l_num_rows_is_gt); END IF;

  IF (l_num_rows_is_gt > 0) THEN
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineOrgAssgnmnts() to rebuild index'); END IF;
    -- Call iproc api for rebuild index for ReqTemplates
    -- Pass in the key for PO_SESSION_GT table
    l_progress := '040';

    IF g_debug_stmt THEN
      PO_LOG.stmt_session_gt
      (
         p_module_base     => l_log_head -- IN  VARCHAR2
       , p_position        => l_progress -- IN  NUMBER
       , p_key             => l_key_org_assignments -- IN  NUMBER
       , p_column_name_tbl => NULL       -- IN  PO_TBL_VARCHAR30 DEFAULT NULL (For all columns)
      );
    END IF;

    ICX_CAT_POPULATE_BPA_GRP.populateOnlineOrgAssgnmnts
    (
      p_api_version      => 1.0,                        -- NUMBER   IN
      p_commit           => FND_API.G_TRUE,             -- VARCHAR2 IN
      p_init_msg_list    => FND_API.G_FALSE,            -- VARCHAR2 IN
      p_validation_level => FND_API.G_VALID_LEVEL_FULL, -- VARCHAR2 IN
      x_return_status    => l_return_status,            -- VARCHAR2 OUT
      p_key              => l_key_org_assignments       -- NUMBER   IN
    );

    l_progress := '050';
    -- In case of error, just log in debug logs. There is no need to raise
    -- it up, because rebuild_index errors have to be ignored by the calling
    -- program.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineOrgAssgnmnts() returned error: '||l_return_status); END IF;
    END IF;
  ELSE
    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Skipped: iProc API ICX_CAT_POPULATE_BPA_GRP.populateOnlineOrgAssgnmnts()'); END IF;
  END IF;

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END populate_sessiongt_for_orgs;

-- <Bug 7655719>
-- Commented out procedures - synch_item_description and synch_item_category
--------------------------------------------------------------------------------
--Start of Comments
--Name: synch_item_description
--Pre-reqs:
--  None
--Modifies:
--  PO_ATTRIBUTE_VALUES_TLP.item_description
--Locks:
--  None.
--Function:
--  When the item description is updated on a Blanket PO Line, it has to be
--  updated in the TLP level as well, so that the line is searchable with the
--  new description.
--     This procedure is called from the ON-UPDATE trigger of the Enter PO
--  form if the type_lookup_code is BLANKET. It updates the
--  PO_ATTRIBUTE_VALUES_TLP.item_description column with the description
--  at the line level.
--     This also works the same for QUOTATIONS and REQ-TEMPLATE lines.
--
--Parameters:
--IN:
--p_doc_type
--  The document type of the header. This can only be BLANKET or QUOTATION
--p_po_header_id
--  The PO header for which the attribute TLP rows need to be synch'd.
--  This is applicable when p_type is BLANKET or QUOTATION.
--p_po_header_ids
--  The list of PO headers for which the attribute and TLP rows need to be synch'd.
--  This is applicable when p_type is BLANKET_BULK
--p_reqexpress_name
--p_org_id
--  The Req Template name and ORG_ID on the Req Template.
--  These are applicable when p_type is REQ_TEMPLATE
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
/*PROCEDURE synch_item_description
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'synch_item_description';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_po_line_id_list PO_TBL_NUMBER;
  l_item_description_list PO_TBL_VARCHAR240;
  l_created_lang_list PO_TBL_VARCHAR5;

  l_req_template_name_list PO_TBL_VARCHAR25;
  l_req_template_line_num_list PO_TBL_NUMBER;
  l_req_template_org_id_list PO_TBL_NUMBER;

  l_key PO_SESSION_GT.key%TYPE;
  l_base_lang FND_LANGUAGES.language_code%TYPE;
BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  IF (p_type IN (TYPE_BLANKET, TYPE_QUOTATION, TYPE_BLANKET_BULK)) THEN
    l_progress := '010';
    -- pick a new key for temp table
    SELECT PO_SESSION_GT_S.nextval
    INTO l_key
    FROM DUAL;

    IF (p_type IN (TYPE_BLANKET, TYPE_QUOTATION)) THEN
      l_progress := '020';

      -- Only 1 row
      INSERT INTO PO_SESSION_GT(key, index_num1) -- PO_HEADER_ID
      VALUES (l_key, p_po_header_id);

    ELSE -- BLANKET_BULK
      l_progress := '030';

      -- Multiple rows
      FORALL i in 1..p_po_header_ids.COUNT
        INSERT INTO PO_SESSION_GT(key, index_num1) -- PO_HEADER_ID
        VALUES (l_key, p_po_header_ids(i));

    END IF;

    l_progress := '040';
    -- Get the list of PO_LINE_ID's whose item description have changed.
    SELECT POL.po_line_id,
           POL.item_description,
           POH.created_language
    BULK COLLECT INTO
           l_po_line_id_list,
           l_item_description_list,
           l_created_lang_list
      FROM PO_LINES_ALL POL,
           PO_HEADERS_ALL POH,
           PO_SESSION_GT INPUT_HDRS
     WHERE POH.po_header_id = INPUT_HDRS.index_num1
       AND INPUT_HDRS.key = l_key -- Bug 6942699 - Added the condition to improve performance
       AND POL.po_header_id = POH.po_header_id
       AND (NOT EXISTS
               (SELECT 'Lines were archived'
                  FROM PO_LINES_ARCHIVE_ALL POLA
                 WHERE POLA.po_line_id = POL.po_line_id)
           OR EXISTS
           (SELECT 'Item description has been modified'
              FROM PO_LINES_ARCHIVE_ALL POLA
             WHERE POLA.po_line_id = POL.po_line_id
               AND POLA.latest_external_flag = 'Y'
               AND (POL.item_description <> POLA.item_description OR
                    (POL.item_description IS NULL AND POLA.item_description IS NOT NULL) OR
                    (POL.item_description IS NOT NULL AND POLA.item_description IS NULL))));

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_LINE descriptions selected to synch='||SQL%rowcount); END IF;

    l_progress := '050';
    -- For all the lines whose description have changed, update the TLP records as well.
    FORALL i IN 1 .. l_po_line_id_list.COUNT
      UPDATE PO_ATTRIBUTE_VALUES_TLP POTLP
         SET description = l_item_description_list(i)
       WHERE POTLP.po_line_id = l_po_line_id_list(i)
         AND language = l_created_lang_list(i);

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_LINE descriptions synchd='||SQL%rowcount); END IF;

  ELSIF (p_type = TYPE_REQ_TEMPLATE) THEN

    l_progress := '060';
    -- Get the list of Req template line's whose item description have changed.
    SELECT PORTL.express_name,
           PORTL.sequence_num,
           PORTL.org_id,
           PORTL.item_description
    BULK COLLECT INTO
           l_req_template_name_list,
           l_req_template_line_num_list,
           l_req_template_org_id_list,
           l_item_description_list
      FROM PO_REQEXPRESS_LINES_ALL PORTL
     WHERE PORTL.express_name = p_reqexpress_name
       AND PORTL.org_id = p_org_id;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or REQ_TEMPLATE line descriptions selected to synch='||SQL%rowcount); END IF;

    l_progress := '070';
    -- Get the base language
    SELECT language_code
    INTO l_base_lang
    FROM FND_LANGUAGES
    WHERE installed_flag='B';

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Base language is = '||l_base_lang); END IF;

    l_progress := '080';
    -- For all the lines whose description have changed, update the TLP records as well.
    FORALL i IN 1 .. l_req_template_line_num_list.COUNT
      UPDATE PO_ATTRIBUTE_VALUES_TLP POTLP
         SET description = l_item_description_list(i)
       WHERE POTLP.req_template_name = l_req_template_name_list(i)
         AND req_template_line_num = l_req_template_line_num_list(i)
         AND org_id = l_req_template_org_id_list(i)
         AND language = l_base_lang;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or REQ_TEMPLATE line descriptions synchd='||SQL%rowcount); END IF;
  END IF;

  l_progress := '090';

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END synch_item_description;

--------------------------------------------------------------------------------
--Start of Comments
--Bug 6979842: Added new procedure
--Name: synch_item_category
--Pre-reqs:
--  None
--Modifies:
--  PO_ATTRIBUTE_VALUES.ip_category_id
--  PO_ATTRIBUTE_VALUES_TLP.ip_category_id
--Locks:
--  None.
--Function:
--  When the item category is updated on a Blanket PO Line, it has to be updated
--  in the attribute (TLP) level as well, so that the line is searchable with
--  the new category.
--     This procedure is called from the ON-UPDATE trigger of the Enter PO
--  form if the type_lookup_code is BLANKET. It updates the
--  PO_ATTRIBUTE_VALUES(TLP).ip_category_id column with the category
--  at the line level.
--     This also works the same for QUOTATIONS and REQ-TEMPLATE lines.
--
--Parameters:
--IN:
--p_doc_type
--  The document type of the header. This can only be BLANKET or QUOTATION
--p_po_header_id
--  The PO header for which the attribute (TLP) rows need to be synch'd.
--  This is applicable when p_type is BLANKET or QUOTATION.
--p_po_header_ids
--  The list of PO headers for which the attribute and TLP rows need to be synch'd.
--  This is applicable when p_type is BLANKET_BULK
--p_reqexpress_name
--p_org_id
--  The Req Template name and ORG_ID on the Req Template.
--  These are applicable when p_type is REQ_TEMPLATE
--OUT:
-- None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE synch_item_category
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'synch_item_category';
  l_log_head      CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_po_line_id_list PO_TBL_NUMBER;
  l_category_id_list PO_TBL_VARCHAR240;
  l_new_ip_category_id NUMBER;
  l_old_ip_category_id_list PO_TBL_NUMBER;

  l_req_template_name_list PO_TBL_VARCHAR25;
  l_req_template_line_num_list PO_TBL_NUMBER;
  l_req_template_org_id_list PO_TBL_NUMBER;

  l_key PO_SESSION_GT.key%TYPE;
BEGIN
  IF g_debug_stmt THEN PO_DEBUG.debug_begin(l_log_head); END IF;

  IF (p_type IN (TYPE_BLANKET, TYPE_QUOTATION, TYPE_BLANKET_BULK)) THEN
    l_progress := '010';
    -- pick a new key for temp table
    SELECT PO_SESSION_GT_S.nextval
    INTO l_key
    FROM DUAL;

    IF (p_type IN (TYPE_BLANKET, TYPE_QUOTATION)) THEN
      l_progress := '020';

      -- Only 1 row
      INSERT INTO PO_SESSION_GT(key, index_num1) -- PO_HEADER_ID
      VALUES (l_key, p_po_header_id);

    ELSE -- BLANKET_BULK
      l_progress := '030';

      -- Multiple rows
      FORALL i in 1..p_po_header_ids.COUNT
        INSERT INTO PO_SESSION_GT(key, index_num1) -- PO_HEADER_ID
        VALUES (l_key, p_po_header_ids(i));

    END IF;

    l_progress := '040';
    -- Get the list of item category ids from PO_LINES_ALL
    SELECT POL.po_line_id,
           POL.category_id,
           POATR.ip_category_id
    BULK COLLECT INTO
           l_po_line_id_list,
           l_category_id_list,
           l_old_ip_category_id_list
      FROM PO_LINES_ALL POL,
           PO_HEADERS_ALL POH,
           PO_ATTRIBUTE_VALUES POATR,
           PO_SESSION_GT INPUT_HDRS
     WHERE POH.po_header_id = INPUT_HDRS.index_num1
       AND INPUT_HDRS.key = l_key
       AND POL.po_header_id = POH.po_header_id
       AND POL.po_line_id = POATR.po_line_id
       AND POL.category_id IS NOT NULL;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_LINE category ids selected to synch='||SQL%rowcount); END IF;

    l_progress := '050';
    -- Get the ip_category_id for all the po lines selected above and update
    -- PO_ATTRIBUTE_VALUES and PO_ATTRIBUTE_VALUES_TLP
    FOR i IN 1 .. l_po_line_id_list.COUNT LOOP
      PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id(l_category_id_list(i), l_new_ip_category_id);

      -- Update ip_category_id only if changed.
      IF l_new_ip_category_id <> l_old_ip_category_id_list(i) THEN
          UPDATE PO_ATTRIBUTE_VALUES
             SET ip_category_id = l_new_ip_category_id
           WHERE po_line_id = l_po_line_id_list(i);

          UPDATE PO_ATTRIBUTE_VALUES_TLP
             SET ip_category_id = l_new_ip_category_id
           WHERE po_line_id = l_po_line_id_list(i);
      END IF;
    END LOOP;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or PO_LINE category ids synchd='||SQL%rowcount); END IF;

  ELSIF (p_type = TYPE_REQ_TEMPLATE) THEN

    l_progress := '060';
    -- Get the list of category ids from PO_REQEXPRESS_LINES_ALL
    SELECT PORTL.express_name,
           PORTL.sequence_num,
           PORTL.org_id,
           PORTL.category_id,
           POATR.ip_category_id
    BULK COLLECT INTO
           l_req_template_name_list,
           l_req_template_line_num_list,
           l_req_template_org_id_list,
           l_category_id_list,
           l_old_ip_category_id_list
      FROM PO_REQEXPRESS_LINES_ALL PORTL,
           PO_ATTRIBUTE_VALUES POATR
     WHERE PORTL.express_name = p_reqexpress_name
       AND PORTL.po_line_id = POATR.po_line_id
       AND PORTL.org_id = p_org_id;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or REQ_TEMPLATE line category ids selected to synch='||SQL%rowcount); END IF;

    l_progress := '070';

    -- Get the ip_category_id for all the po lines selected above and update
    -- PO_ATTRIBUTE_VALUES and PO_ATTRIBUTE_VALUES_TLP
    FOR i IN 1 .. l_req_template_line_num_list.COUNT LOOP
      PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id(l_category_id_list(i), l_new_ip_category_id);

      -- Update ip_category_id only if changed.
      IF l_new_ip_category_id <> l_old_ip_category_id_list(i) THEN
          UPDATE PO_ATTRIBUTE_VALUES
             SET ip_category_id = l_new_ip_category_id
           WHERE req_template_name = l_req_template_name_list(i)
             AND req_template_line_num = l_req_template_line_num_list(i)
             AND org_id = l_req_template_org_id_list(i);

          UPDATE PO_ATTRIBUTE_VALUES_TLP
             SET ip_category_id = l_new_ip_category_id
           WHERE req_template_name = l_req_template_name_list(i)
             AND req_template_line_num = l_req_template_line_num_list(i)
             AND org_id = l_req_template_org_id_list(i);
      END IF;
    END LOOP;

    IF g_debug_stmt THEN PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number or REQ_TEMPLATE line category ids synchd='||SQL%rowcount); END IF;
  END IF;

  l_progress := '080';

  IF g_debug_stmt THEN PO_DEBUG.debug_end(l_log_head); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN PO_DEBUG.debug_exc(l_log_head,l_progress); END IF;
END synch_item_category;*/

END PO_CATALOG_INDEX_PVT;

/
