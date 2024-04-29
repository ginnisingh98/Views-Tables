--------------------------------------------------------
--  DDL for Package Body PO_PDOI_PRICE_TOLERANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_PRICE_TOLERANCE_PVT" AS
/* $Header: PO_PDOI_PRICE_TOLERANCE_PVT.plb 120.3.12010000.3 2010/08/19 09:19:50 ppadilam ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_PRICE_TOLERANCE_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------



--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: start_price_tolerance_wf
--Function:
--  start the workflow to send notification of price exceeding tolerance
--  to users
--Parameters:
--IN:
--  p_intf_header_id
--    identifier in interface table for the document
--  p_po_header_id
--    identifier in txn table for the document
--  p_document_num
--    document number
--  p_batch_id
--    batch_id of current request
--  p_document_type
--    document type, can be STANDARD/BLANKET/QUOTATION
--  p_document_subtype
--    subtype of the document type
--  p_commit_interval
--    value passed from request
--  p_any_line_updated
--    flag to indicate whether there is any other line created or updated
--    for the same document
--  p_buyer_id
--    value passed from request
--  p_agent_id
--    agent_id for the document
--  p_vendor_id
--    vendor_id for the document
--  p_vendor_name
--    corresponding vendor name derived from vendor_id
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE start_price_tolerance_wf
(
  p_intf_header_id    IN  NUMBER,
  p_po_header_id      IN  NUMBER,
  p_document_num      IN  VARCHAR2,
  p_batch_id          IN  NUMBER,
  p_document_type     IN  VARCHAR2,
  p_document_subtype  IN  VARCHAR2,
  p_commit_interval   IN  NUMBER,
  p_any_line_updated  IN  VARCHAR2,
  p_buyer_id          IN  NUMBER,
  p_agent_id          IN  NUMBER,
  p_vendor_id         IN  NUMBER,
  p_vendor_name       IN  VARCHAR2
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'start_price_tolerance_wf';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_wf_item_type       VARCHAR2(240) := 'POPRICAT';
  l_wf_item_key        VARCHAR2(240);
  l_wf_item_exists     VARCHAR2(1) := 'N';
  l_wf_item_end_date   DATE;

  l_num_of_items       NUMBER;

  l_orig_system        VARCHAR2(5) := 'PER';
  l_agent_username     VARCHAR2(240);
  l_agent_display_name VARCHAR2(240);

  l_open_form          VARCHAR2(240);
  l_batch_id  Number;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_intf_header_id', p_intf_header_id);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_document_num', p_document_num);
    PO_LOG.proc_begin(d_module, 'p_batch_id', p_batch_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_commit_interval', p_commit_interval);
    PO_LOG.proc_begin(d_module, 'p_any_line_updated', p_any_line_updated);
    PO_LOG.proc_begin(d_module, 'p_buyer_id', p_buyer_id);
    PO_LOG.proc_begin(d_module, 'p_agent_id', p_agent_id);
    PO_LOG.proc_begin(d_module, 'p_vendor_id', p_vendor_id);
    PO_LOG.proc_begin(d_module, 'p_vendor_name', p_vendor_name);
  END IF;
/*Bug 10023715:<Start> Retrived the batch_id value from Po_headers_interface table*/
  SELECT batch_id
   INTO   l_batch_id
   FROM   po_headers_interface
   WHERE  INTERFACE_HEADER_ID = p_intf_header_id;

  l_wf_item_key := 'POI-PRICAT-' || to_char(p_intf_header_id) || '-' || to_char(l_batch_id);
/* Bug 10023715 <end>*/
  -- check whether there is same item exist and open
  BEGIN
    SELECT 'Y', WI.end_date
    INTO   l_wf_item_exists, l_wf_item_end_date
    FROM   WF_ITEMS_V WI
    WHERE  WI.ITEM_TYPE = l_wf_item_type
    AND    WI.ITEM_KEY  = l_wf_item_key;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
  END;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_wf_item_key', l_wf_item_key);
    PO_LOG.stmt(d_module, d_position, 'l_wf_item_exists', l_wf_item_exists);
    PO_LOG.stmt(d_module, d_position, 'l_wf_item_end_date', l_wf_item_end_date);
  END IF;

  d_position := 10;

  -- check whether workflow needs to be started
  IF (l_wf_item_exists = 'Y' AND l_wf_item_end_date IS NULL) THEN
    d_position := 20;

    -- Workflow item exists and is still open - bypass creating workflow
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end (d_module, 'bypass workflow', l_wf_item_exists);
    END IF;

    RETURN;
  ELSE
    d_position := 30;

    IF (l_wf_item_exists = 'Y' AND l_wf_item_end_date IS NOT NULL) THEN
      -- Call purge workflow to remove the completed process
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Purging completed Workflow');
      END IF;

      WF_PURGE.TOTAL
      (
        l_wf_item_type,
        l_wf_item_key
      );
    END IF;

    d_position := 40;

    -- start workflow
    SELECT COUNT(1)
    INTO   l_num_of_items
    FROM   po_lines_interface
    WHERE  interface_header_id = p_intf_header_id
    AND    process_code = 'NOTIFIED'
    AND    nvl(price_break_flag,'N') = 'N';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_num_of_items', l_num_of_items);
    END IF;

    d_position := 50;

    WF_DIRECTORY.GetUserName
    (
      l_orig_system,
      p_agent_id,
      l_agent_username,
      l_agent_display_name
    );

    d_position := 60;

    l_open_form := 'PO_POXPCATN:INTERFACE_HEADER_ID="' || '&' || 'INTERFACE_HEADER_ID"' ||
                   ' ACCESS_LEVEL_CODE="' || '&' || 'ACCESS_LEVEL_CODE"';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_agent_username', l_agent_username);
      PO_LOG.stmt(d_module, d_position, 'l_agent_display_name', l_agent_display_name);
      PO_LOG.stmt(d_module, d_position, 'l_open_form', l_open_form);
    END IF;

    WF_ENGINE.createProcess
    (
      ItemType  => l_wf_item_type,
      ItemKey   => l_wf_item_key,
      Process   => 'PROCESS_LINE_ITEMS'
    );

    d_position := 70;

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'INTERFACE_HEADER_ID',
      avalue    => p_intf_header_id
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'DOCUMENT_ID',
      avalue    => p_po_header_id
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'DOCUMENT_NUM',
      avalue    => p_document_num
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'BATCH_ID',
      avalue    => p_batch_id
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'DOCUMENT_TYPE_CODE',
      avalue    => p_document_type
    );

    d_position := 80;

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'DOCUMENT_SUBTYPE',
      avalue    => p_document_subtype
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'COMMIT_INTERVAL',
      avalue    => p_commit_interval
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'NUMBER_OF_ITEMS',
      avalue    => l_num_of_items
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'ANY_LINE_ITEM_UPDATED',
      avalue    => NVL(p_any_line_updated, 'N')
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'BUYER_ID',
      avalue    => p_buyer_id
    );

    d_position := 90;

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'BUYER_USER_NAME',
      avalue    => l_agent_username
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'BUYER_DISPLAY_NAME',
      avalue    => l_agent_display_name
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'OPEN_FORM_COMMAND',
      avalue    => l_open_form
    );

    WF_ENGINE.SetItemAttrNumber
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'SUPPLIER_ID',
      avalue    => p_vendor_id
    );

    WF_ENGINE.SetItemAttrText
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      aname     => 'SUPPLIER',
      avalue    => p_vendor_name
    );

    WF_ENGINE.SetItemOwner
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key,
      owner     => l_agent_username
    );

    d_position := 100;

    WF_ENGINE.startprocess
    (
      itemtype  => l_wf_item_type,
      itemkey   => l_wf_item_key
    );
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'workflow started');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END start_price_tolerance_wf;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_price_tolerance
--Function: get the price tolerance percentage for each line
--Parameters:
--IN:
--  p_index_tbl
--    table containing indexes of rows
--  p_po_header_id_tbl
--    list of po_header_id within the batch
--  p_item_id_tbl
--    list of item_ids within the batch
--  p_category_id_tbl
--    list of category_ids within the batch
--  p_vendor_id_tbl
--    list of vendor_ids within the batch
--IN OUT:
--  x_price_update_tolerance_tbl
--    list of price_update_tolerance values within the batch;
--    the extracted result in this procedure will also will
--    saved in this pl/sql table
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_price_tolerance
(
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_po_header_id_tbl           IN PO_TBL_NUMBER,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  p_category_id_tbl            IN PO_TBL_NUMBER,
  p_vendor_id_tbl              IN PO_TBL_NUMBER,
  x_price_update_tolerance_tbl OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_price_tolerance';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key           po_session_gt.key%TYPE;

  l_index_tbl     PO_TBL_NUMBER;
  l_tolerance_tbl PO_TBL_NUMBER;

  l_index         NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_header_id_tbl', p_po_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_category_id_tbl', p_category_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_vendor_id_tbl', p_vendor_id_tbl);
  END IF;

  -- initialize out parameter
  x_price_update_tolerance_tbl := PO_TBL_NUMBER();
  x_price_update_tolerance_tbl.EXTEND(p_po_header_id_tbl.COUNT);

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- first, the value is fetched from po_asl_attributes table
  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_index_tbl(i),
           price_update_tolerance
    FROM   po_asl_attributes
    WHERE  (item_id = p_item_id_tbl(i) OR
            category_id = p_category_id_tbl(i) OR
            category_id IN
              (SELECT MIC.category_id
               FROM   MTL_ITEM_CATEGORIES MIC
               WHERE  MIC.inventory_item_id = p_item_id_tbl(i)
               AND    MIC.organization_id =
                      PO_PDOI_PARAMS.g_sys.master_inv_org_id)
           )
    AND    vendor_id = p_vendor_id_tbl(i)
    AND    using_organization_id IN (-1, PO_PDOI_PARAMS.g_sys.master_inv_org_id);

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_tolerance_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'price tolerance from asl attributes',
                  l_tolerance_tbl(i));
    END IF;

    x_price_update_tolerance_tbl(l_index_tbl(i)) := l_tolerance_tbl(i);
  END LOOP;

  d_position := 30;

  -- if tolerance is still null, get value from document header
  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_index_tbl(i),
           price_update_tolerance
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id_tbl(i)
    AND    type_lookup_code = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
    AND    x_price_update_tolerance_tbl(i) IS NULL;

  d_position := 40;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_tolerance_tbl;

  FOR I IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'price tolerance from headers',
                  l_tolerance_tbl(i));
    END IF;

    x_price_update_tolerance_tbl(l_index_tbl(i)) := l_tolerance_tbl(i);
  END LOOP;

  d_position := 50;

  -- set up price_tolerance from profile for the incoming index
  l_index := p_index_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    d_position := 60;

    IF (x_price_update_tolerance_tbl(l_index) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', l_index);
        PO_LOG.stmt(d_module, d_position, 'price tolerance from profile',
                    PO_PDOI_PARAMS.g_profile.po_price_update_tolerance);
      END IF;

      x_price_update_tolerance_tbl(l_index) :=
        PO_PDOI_PARAMS.g_profile.po_price_update_tolerance;
    END IF;

    l_index := p_index_tbl.NEXT(l_index);
  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_price_tolerance;

-----------------------------------------------------------------------
--Start of Comments
--Name: exceed_tolerance_check
--Function: check whether new price exceeds the tolerance
--Parameters:
--IN:
--  p_price_tolerance
--    update tolerance value
--  p_old_price
--    price before update
--  p_new_price
--    new price after update
--IN OUT:
--OUT:
--RETURN: flag indicate whether new price exceeds the tolerance
--End of Comments
------------------------------------------------------------------------
FUNCTION exceed_tolerance_check
(
  p_price_tolerance IN NUMBER,
  p_old_price       IN NUMBER,
  p_new_price       IN NUMBER
) RETURN VARCHAR2
IS

  d_api_name CONSTANT VARCHAR2(30) := 'exceed_tolerance_check';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_exceed VARCHAR2(1) := FND_API.g_FALSE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_price_tolerance', p_price_tolerance);
    PO_LOG.proc_begin(d_module, 'p_old_price', p_old_price);
    PO_LOG.proc_begin(d_module, 'p_new_price', p_new_price);
  END IF;

  d_position := 10;

  IF (p_price_tolerance IS NOT NULL AND
      ((1 + p_price_tolerance/100) * p_old_price < p_new_price)) THEN
    l_exceed := FND_API.g_TRUE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_exceed);
  END IF;

  RETURN l_exceed;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END exceed_tolerance_check;
-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

END PO_PDOI_PRICE_TOLERANCE_PVT;

/
