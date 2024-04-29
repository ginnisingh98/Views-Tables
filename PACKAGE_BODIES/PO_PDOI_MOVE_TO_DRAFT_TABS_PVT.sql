--------------------------------------------------------
--  DDL for Package Body PO_PDOI_MOVE_TO_DRAFT_TABS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_MOVE_TO_DRAFT_TABS_PVT" AS
/* $Header: PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.plb 120.35.12010000.32 2014/11/13 08:08:34 shikapoo ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_MOVE_TO_DRAFT_TABS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------
PROCEDURE insert_po_headers_draft_all
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE insert_po_ga_org_assign_draft
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE insert_blk_dists_draft_all
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE insert_po_lines_draft_all
(
  p_lines   IN PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE insert_po_line_locs_draft_all
(
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE insert_po_dists_draft_all
(
  p_dists   IN PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE insert_po_price_diff_draft
(
  p_price_diffs   IN PO_PDOI_TYPES.price_diffs_rec_type
);

PROCEDURE merge_po_attr_values_draft
(
  p_key                IN po_session_gt.key%TYPE,
  p_attr_values        IN PO_PDOI_TYPES.attr_values_rec_type
);

PROCEDURE merge_po_attr_values_tlp_draft
(
  p_key                IN po_session_gt.key%TYPE,
  p_attr_values_tlp    IN PO_PDOI_TYPES.attr_values_tlp_rec_type
);

PROCEDURE reset_cat_attributes
(
  p_index_tbl       IN DBMS_SQL.NUMBER_TABLE,
  p_po_line_id_tbl  IN PO_TBL_NUMBER,
  p_draft_id_tbl    IN PO_TBL_NUMBER
);
--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_headers
--Function:
--  transfer header related data to draft table
--Parameters:
--IN:
--p_headers
--  record which contains processed header attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_headers
(
  p_headers     IN PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_INSERT);

  -- insert records into po_headers_draft_all table
  insert_po_headers_draft_all
  (
    p_headers   =>   p_headers
  );

  d_position := 10;

  -- insert records into po_ga_org_assign_draft table
  insert_po_ga_org_assign_draft
  (
    p_headers   =>   p_headers
  );

  d_position := 20;

  -- insert a row into po_distributions_draft_all for a blanket
  -- if encumbrance is required
  insert_blk_dists_draft_all
  (
    p_headers   =>   p_headers
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_INSERT);

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
END insert_headers;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_lines
--Function:
--  insert new po lines into draft table
--Parameters:
--IN:
--p_lines
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_INSERT);

  d_position := 10;

  -- set all lines to notified if:
  -- 1. user role is CAT ADMIN and
  -- 2. document type is LBPA/QTN and
  -- 3. the line's current status is not notified
  IF (PO_PDOI_PARAMS.g_request.role = PO_GLOBAL.g_role_CAT_ADMIN
      AND
      ((PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET         -- blanket
        AND
          ( x_lines.rec_count > 0 AND
            NVL(x_lines.hd_global_agreement_flag_tbl(1), 'N') = 'N'))  -- local
        OR
        PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION
      )
      AND
      (PO_PDOI_PARAMS.g_request.process_code <>
       PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED)
     ) THEN
    d_position := 20;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'set lines to be notified');
    END IF;

    -- update interface table with new status set to NOTIFIED
    -- bug 6743283 added a condition to check the action, so that only for update
    -- we made the line notified if call comes from catalog admin.
    FOR i IN 1..x_lines.rec_count
    LOOP
      IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
          x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE AND
          x_lines.action_tbl(i) = 'UPDATE') THEN
        x_lines.process_code_tbl(i) := PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED;
	--Bug fix 13906472. has_lines_to_notify flag should be set to TRUE when the lines are notified.
	-- set status on header level for notified lines
	PO_PDOI_PARAMS.g_docs_info(x_lines.intf_header_id_tbl(1)).has_lines_to_notify := FND_API.g_TRUE;
      END IF;
    END LOOP;

  ELSE
    d_position := 30;

    -- populate value of has_lines_updated in g_doc_info for each document
    FOR i IN 1..x_lines.rec_count
    LOOP
      IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
          x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN
        PO_PDOI_PARAMS.g_docs_info(x_lines.intf_header_id_tbl(i)).has_lines_updated := 'Y';
      END IF;
    END LOOP;

  END IF;

  -- bug5149827
  -- Insert all lines to draft lines regardless of whether the lines are in
  -- status 'NOTIFIED' or not... those lines will be removed from the draft
  -- table during post processing.

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'insert lines into draft table');
  END IF;

  -- insert lines into po_lines_draft_all
  insert_po_lines_draft_all
  (
    p_lines    =>   x_lines
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_INSERT);

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
END insert_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_lines
--Function:
--  update existing po lines; the new attribute value will override the
--  existing value of the attribute in draft table
--  the list of updatable attributes includes:
--  description, unit_price, unit_of_measure, amount,
--  attribute14, expiration_date, po_category_id,
--  ip_category_id, nogotiated_by_preparer_flag
--Parameters:
--IN:
--IN OUT:
--x_lines
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_po_line_id                NUMBER;
  l_count                     NUMBER := 0;
  l_key                       po_session_gt.key%TYPE;
  l_index                     NUMBER;

  l_uom_different             VARCHAR2(1);
  l_exceed_tolerance          VARCHAR2(1);

  -- variable used to bulk update description in item master
  l_update_item_queue         DBMS_SQL.NUMBER_TABLE;

  -- hashtable used in two places:
  -- 1. remove duplicate po_line_ids in p_lines
  -- 2. store position of each row indexed by po_line_id
  l_line_ref_tbl              DBMS_SQL.NUMBER_TABLE;

  -- table to save distinct po_line_ids within the batch
  l_po_line_id_tbl            PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_draft_id_tbl              PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_delete_flag_tbl           PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

  -- tables containing existing values for updatable attrs
  l_unit_of_measure_tbl       PO_TBL_VARCHAR30;
  l_unit_price_tbl            PO_TBL_NUMBER;
  l_item_desc_tbl             PO_TBL_VARCHAR2000;
  l_expiration_date_tbl       PO_TBL_DATE;
  l_retroactive_date_tbl      PO_TBL_DATE;
  l_price_break_lookup_code_tbl PO_TBL_VARCHAR30;
  l_base_unit_price_tbl       PO_TBL_NUMBER;
  l_attribute14_tbl           PO_TBL_VARCHAR2000;
  l_amount_tbl                PO_TBL_NUMBER;
  l_price_limit_tbl           PO_TBL_NUMBER;
  l_negotiated_flag_tbl       PO_TBL_VARCHAR1;
  l_category_id_tbl           PO_TBL_NUMBER;
  l_ip_category_id_tbl        PO_TBL_NUMBER;
  l_orig_intf_line_id_tbl     PO_TBL_NUMBER; -- bug5149827
  -- Bug 13506679
  l_un_number_id_tbl             PO_TBL_NUMBER;
  l_hazard_class_id_tbl       PO_TBL_NUMBER;
  -- Bug 13506679

  -- need the item_id value in processing even thought
  -- it is not updatable
  l_item_id_tbl               PO_TBL_NUMBER;
  -- values read from item table
  l_allow_desc_update_tbl     PO_TBL_VARCHAR1;

  -- variables to hold result from temp table
  l_index_tbl                 PO_TBL_NUMBER;

  -- ordered num list
  l_num_tbl                   DBMS_SQL.NUMBER_TABLE;

  -- variables used in UOM processing
  l_precision                 FND_CURRENCIES.precision%TYPE;
  l_precision_tbl             PO_PDOI_TYPES.varchar_index_tbl_type;
  l_uom_rate                  NUMBER;

  -- location lines that need to be updated
  l_update_loc_queue          DBMS_SQL.NUMBER_TABLE;
  l_change_loc_id_tbl         PO_TBL_NUMBER;

  -- lines for which uom warning needs to be given
  l_uom_warning_queue         DBMS_SQL.NUMBER_TABLE;
  l_price_limit_queue         DBMS_SQL.NUMBER_TABLE;

  -- index of the po line for which description is changed;
  -- we may need to update po_attribute_values_tlp_draft table
  l_update_desc_queue         DBMS_SQL.NUMBER_TABLE;
  l_sync_attr_tlp_id_tbl      PO_TBL_NUMBER;
  l_sync_attr_id_tbl          PO_TBL_NUMBER; -- <Bug 7655719>

  -- lines for which we need to null out the cat based attribute values
  l_ip_cat_id_updated_queue   DBMS_SQL.NUMBER_TABLE;

  -- table of modified ip_category_id. The index for this table is record number
  l_modified_ip_cat_id_tbl    PO_TBL_NUMBER := PO_TBL_NUMBER(); -- <Bug 7655719>
  l_modified_ip_cat_id_tbl_tmp  PO_TBL_NUMBER; -- <Bug 7655719>

  -- variables to hold results from INV's API call
  l_inventory_item_id           NUMBER;
  l_organization_id             NUMBER;
  l_return_status               VARCHAR2(1);
  l_msg_count                   VARCHAR2(10);
  l_msg_data                    VARCHAR2(1000);
  l_message_list                Error_Handler.Error_Tbl_Type;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_UPDATE);

  -- get ids of po lines that are going to be updated;
  -- the id list will only contain distinct values
  FOR i IN 1..x_lines.rec_count
  LOOP
    l_po_line_id := x_lines.po_line_id_tbl(i);

    IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
        x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN
      IF (l_line_ref_tbl.EXISTS(l_po_line_id) = FALSE) THEN
        l_count := l_count + 1;
        l_po_line_id_tbl.EXTEND;
        l_draft_id_tbl.EXTEND;
        l_delete_flag_tbl.EXTEND;
        l_po_line_id_tbl(l_count) := l_po_line_id;
        l_draft_id_tbl(l_count) := x_lines.draft_id_tbl(i);
        l_delete_flag_tbl(l_count) := 'N';
        l_line_ref_tbl(l_po_line_id) := i;
      END IF;

      -- mark lines that are going to be processed
      l_num_tbl(i) := i;
    END IF;
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'count of to-be-processed lines',
              l_num_tbl.COUNT);
  END IF;

  IF (l_num_tbl.COUNT = 0) THEN
    PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_UPDATE);

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end (d_module);
    END IF;

    RETURN;
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'po line ids', l_po_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'draft ids', l_draft_id_tbl);
  END IF;

  d_position := 10;

  -- read from txn table to draft table; if there is already a draft change
  -- in the draft table, the line won't be read
  PO_LINES_DRAFT_PKG.sync_draft_from_txn
  (
    p_po_line_id_tbl           => l_po_line_id_tbl,
    p_draft_id_tbl             => l_draft_id_tbl,
    p_delete_flag_tbl          => l_delete_flag_tbl,
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );

  d_position := 20;

  -- get existing values for all updatable attributes
  l_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN 1..l_po_line_id_tbl.COUNT
    INSERT INTO po_session_gt
    (
      key,
      num1,  -- po_line_id
      char1, -- unit_of_measure
      num2,  -- unit_price
      char2, -- item_description
      date1, -- expiration_date
      date2, -- retroactive_date
      char3, -- price_break_lookup_code
      num3,  -- base_unit_price,
      char4, -- attribute14
      num4,  -- amount
      num5,  -- not_to_exceed_price
      char5, -- negotiated_flag
      num6,  -- category_id
      num7,  -- ip_category_id
      num8,  -- original_interface_line_id
      char6,  -- allow_item_desc_update_flag
      num9,    -- Draft ID -- Bug 11927927
       -- Bug 13506679
      num10,      -- un number
      index_num1  -- hazard class id
      -- Bug 13506679

    )
    SELECT
      l_key,
      draft_lines.po_line_id,
      draft_lines.unit_meas_lookup_code,
      draft_lines.unit_price,
      draft_lines.item_description,
      TRUNC(draft_lines.expiration_date),
      draft_lines.retroactive_date,
      draft_lines.price_break_lookup_code,
      draft_lines.base_unit_price,
      draft_lines.attribute14,
      draft_lines.amount,
      draft_lines.not_to_exceed_price,
      draft_lines.negotiated_by_preparer_flag,
    draft_lines.category_id,
    draft_lines.ip_category_id,
      draft_lines.original_interface_line_id, -- bug5149827
    items.allow_item_desc_update_flag,
    draft_lines.draft_id,  -- Bug 11927927
    -- Bug 13506679
    draft_lines.un_number_id,
    draft_lines.hazard_class_id
    -- Bug 13506679

    FROM   po_lines_draft_all draft_lines,
           mtl_system_items items
    WHERE  draft_lines.po_line_id = l_po_line_id_tbl(i)
    AND    draft_lines.draft_id   = l_draft_id_tbl(i)
    AND    draft_lines.item_id = items.inventory_item_id(+)
    AND    items.organization_id(+) = PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, char1, num2, char2, date1, date2, char3,
            num3, char4, num4, num5, char5, num6, num7, num8, char6,num9, -- Bug 11927927
            num10, index_num1 -- Bug 13506679
  BULK COLLECT INTO
    l_po_line_id_tbl,
    l_unit_of_measure_tbl,
    l_unit_price_tbl,
    l_item_desc_tbl,
    l_expiration_date_tbl,
    l_retroactive_date_tbl,
    l_price_break_lookup_code_tbl,
    l_base_unit_price_tbl,
    l_attribute14_tbl,
    l_amount_tbl,
    l_price_limit_tbl,
    l_negotiated_flag_tbl,
    l_category_id_tbl,
    l_ip_category_id_tbl,
    l_orig_intf_line_id_tbl, -- bug5149827
    l_allow_desc_update_tbl,
    l_draft_id_tbl, -- Bug 11927927
    -- Bug 13506679
    l_un_number_id_tbl,
    l_hazard_class_id_tbl;
    -- Bug 13506679


  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'orig po line ids', l_po_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig uom', l_unit_of_measure_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig unit price', l_unit_price_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig item desc', l_item_desc_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig expiration date',
                l_expiration_date_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig retroactive date',
                l_retroactive_date_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig price break lookup code',
                l_price_break_lookup_code_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig base unit price',
                l_base_unit_price_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig attribute_14', l_attribute14_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig amount', l_amount_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig price limit', l_price_limit_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig negotiated flag', l_negotiated_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig category_id', l_category_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'orig ip category id', l_ip_category_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'allow desc update', l_allow_desc_update_tbl);
    PO_LOG.stmt(d_module, d_position, 'draft id tbl', l_draft_id_tbl);-- Bug 11927927
     -- Bug 13506679
    PO_LOG.stmt(d_module, d_position, 'un number tbl', l_un_number_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'hazard class id tbl', l_hazard_class_id_tbl);
    -- Bug 13506679

  END IF;

  -- set up hashtable to refer to existing values
  l_line_ref_tbl.DELETE;
  FOR i IN 1..l_po_line_id_tbl.COUNT
  LOOP
    l_line_ref_tbl(l_po_line_id_tbl(i)) := i;
  END LOOP;

  d_position := 40;

  FOR i IN 1.. x_lines.rec_count
  LOOP

    -- bug5107324
    -- Only process lines that do not contain error or destined to get
    -- rejected.
    IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
        x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'po_line_id', x_lines.po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'reference',
                  l_line_ref_tbl(x_lines.po_line_id_tbl(i)));
        PO_LOG.stmt(d_module, d_position, 'orig category_id', x_lines.category_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'new category_id',
                    l_category_id_tbl(l_line_ref_tbl(x_lines.po_line_id_tbl(i))));
        PO_LOG.stmt(d_module, d_position, 'allow_desc_update_flag',
                    l_allow_desc_update_tbl(l_line_ref_tbl(x_lines.po_line_id_tbl(i))));
      END IF;


      IF (x_lines.category_id_tbl(i) IS NULL) THEN
        x_lines.category_id_tbl(i) :=
        l_category_id_tbl(l_line_ref_tbl(x_lines.po_line_id_tbl(i)));
      END IF;


      -- bug5107324
      -- The initialization of the table is now done in
      -- PO_PDOI_LINE_PROCESS_PVT. We just need to assign the value here

      x_lines.allow_desc_update_flag_tbl(i) :=
        l_allow_desc_update_tbl(l_line_ref_tbl(x_lines.po_line_id_tbl(i)));

    END IF;
  END LOOP;

  -- get price update tolerance
  PO_PDOI_PRICE_TOLERANCE_PVT.get_price_tolerance
  (
    p_index_tbl                  => l_num_tbl,
    p_po_header_id_tbl           => x_lines.hd_po_header_id_tbl,
    p_item_id_tbl                => x_lines.item_id_tbl,
    p_category_id_tbl            => x_lines.category_id_tbl,
    p_vendor_id_tbl              => x_lines.hd_vendor_id_tbl,
    x_price_update_tolerance_tbl => x_lines.price_update_tolerance_tbl
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'price tolerance',
                x_lines.price_update_tolerance_tbl);
  END IF;

  d_position := 50;

  -- loop through each line in x_lines and apply update on top of the
  -- existing values
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 60;

       --For bug 13736932
       --Bug 9795725 if it is inside loop it can try to assign  value to  l_modified_ip_cat_id_tbl(2)  when we can not have array above 1
       --For ex when second line modified at that time i will be 2 and   l_modified_ip_cat_id_tbl.EXTEND will return 1
       l_modified_ip_cat_id_tbl.EXTEND;

       --For bug 13736932
	--For bug 13243413
	--Extending l_ip_category_id_tbl for avoiding ORA-06533
       l_ip_category_id_tbl.EXTEND;

    IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
        x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'update line on index', i);
      END IF;

      -- reset variables
      l_uom_different := FND_API.g_FALSE;
      l_exceed_tolerance := FND_API.g_FALSE;

      -- get index reference in existing value tables
      l_index := l_line_ref_tbl(x_lines.po_line_id_tbl(i));

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'reference in original values',
                    l_index);
      END IF;

      d_position := 70;

      -- check whether uom has been changed
      IF (x_lines.unit_of_measure_tbl(i) IS NOT NULL AND
          x_lines.order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND
          x_lines.unit_of_measure_tbl(i) <> l_unit_of_measure_tbl(l_index)) THEN
        l_uom_different := FND_API.g_TRUE;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'uom_different',
                      l_uom_different);
        END IF;

      END IF;

      d_position := 80;

      -- update description
      IF (NVL(x_lines.allow_desc_update_flag_tbl(i), 'Y') = 'Y' AND
          x_lines.item_desc_tbl(i) IS NOT NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'item id', x_lines.item_id_tbl(i));
          PO_LOG.stmt(d_module, d_position, 'item desc', x_lines.item_desc_tbl(i));
        END IF;

        -- update description in item master
        IF (NVL(PO_PDOI_PARAMS.g_request.create_items, 'N') = 'Y' AND
            x_lines.item_id_tbl(i) IS NOT NULL) THEN
          l_update_item_queue(i) := i;
        END IF;

        d_position := 90;

        -- update description in po_lines_all
        IF (l_item_desc_tbl(l_index) <> x_lines.item_desc_tbl(i)) THEN
          l_item_desc_tbl(l_index) := x_lines.item_desc_tbl(i);

          -- record down the index because we may need to change description
          -- field in po_attribute_values_tlp_draft
          l_update_desc_queue(i) := i;
        END IF;
      END IF;

      d_position := 100;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'create_line_loc',
                x_lines.create_line_loc_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'unit_price',
                x_lines.unit_price_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'orig unit_price',
                l_unit_price_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'process_code in request',
                PO_PDOI_PARAMS.g_request.process_code);
        PO_LOG.stmt(d_module, d_position, 'role in request',
                PO_PDOI_PARAMS.g_request.role);
        PO_LOG.stmt(d_module, d_position, 'global agreement flag',
                x_lines.hd_global_agreement_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'uom_different',
                l_uom_different);
        PO_LOG.stmt(d_module, d_position, 'orig intf line id',
                l_orig_intf_line_id_tbl(l_index));
      END IF;

      -- bug5149827
      -- If original intf line id exists, automatically set exceed tolerance
      -- to true so that it goes through price tolerance check
      IF (PO_PDOI_PARAMS.g_request.process_code <>
              PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
  	      AND
          l_orig_intf_line_id_tbl(l_index) IS NOT NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'orig_intf_line_id exists');
        END IF;

        l_exceed_tolerance := FND_API.G_TRUE;
        x_lines.parent_interface_line_id_tbl(i) := l_orig_intf_line_id_tbl(l_index);

      -- check unit price
      ELSIF (x_lines.create_line_loc_tbl(i) = FND_API.g_FALSE AND
        x_lines.unit_price_tbl(i) IS NOT NULL AND
        x_lines.unit_price_tbl(i) <> NVL(l_unit_price_tbl(l_index), -1)) THEN

        IF (x_lines.unit_price_tbl(i) <> PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
          -- only check tolerance when previous status is not NOTIFIED
          IF (PO_PDOI_PARAMS.g_request.process_code <>
              PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED) THEN

            -- bug5149827
            -- If original interface line id is there, then the line
            -- automatically exceeds tolerance

            -- do not check the price tolerance when
            -- 1. user role is CAT ADMIN/SUPPLIER and
            -- 2. document type is GBPA

            IF (PO_PDOI_PARAMS.g_request.role = PO_GLOBAL.g_role_BUYER
                OR
                NOT
                  (PO_PDOI_PARAMS.g_request.document_type =
                     PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
                   AND
                   NVL(x_lines.hd_global_agreement_flag_tbl(i), 'N') = 'Y')) THEN

              d_position := 110;
              -- only perform tolerance checking when uom is not changed
              IF (l_uom_different = FND_API.g_FALSE AND
                  x_lines.unit_price_tbl(i) <> l_unit_price_tbl(l_index)) THEN
                -- check whether new price exceeds the tolerance
                l_exceed_tolerance :=
                    PO_PDOI_PRICE_TOLERANCE_PVT.exceed_tolerance_check
                            (
                              p_price_tolerance => x_lines.price_update_tolerance_tbl(i),
                              p_old_price       => l_unit_price_tbl(l_index),
                              p_new_price       => x_lines.unit_price_tbl(i)
                            );
              END IF;  -- if uom_different = F and unit price different
            END IF;  -- if buyer or not modifying ga
          END IF; -- if process code <> 'NOTIFIED'
        ELSE
          x_lines.unit_price_tbl(i) := NULL;
        END IF;  -- if unit price = NULLIFY_NUM

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'l_exceed_tolerance', l_exceed_tolerance);
        END IF;

        d_position := 120;

        -- update unit_price, base_unit_price and retroactive_date
        -- if price does not exceed tolerance
        IF (l_exceed_tolerance = FND_API.g_FALSE) THEN
          -- When we update an existing blanket with a new unit_price,
          -- retroactive_date in po_lines must be updated with the timestamp.
          -- This has to be done for non-cumulative blanket lines only.
          IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET AND
              NVL(l_price_break_lookup_code_tbl(l_index), 'NON CUMULATIVE') = 'NON CUMULATIVE') THEN
            l_retroactive_date_tbl(l_index) := sysdate;
          END IF;

          -- set unit_price and base_unit_price
          l_unit_price_tbl(l_index) := x_lines.unit_price_tbl(i);
          IF (x_lines.base_unit_price_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
            l_base_unit_price_tbl(l_index) := NULL;
          ELSE
            l_base_unit_price_tbl(l_index) :=
              NVL(x_lines.base_unit_price_tbl(i), x_lines.unit_price_tbl(i));
          END IF;

          d_position := 130;

          -- setup the queue to change price break when there is price change
          -- the indexes saved in this queue must have distinct po_line_id
          IF (NOT l_line_ref_tbl.EXISTS(x_lines.po_line_id_tbl(i))) THEN
            l_update_loc_queue(i) := i;
            l_line_ref_tbl(x_lines.po_line_id_tbl(i)) := i;
          END IF;

        END IF; -- If Exceed tolerance = F
      END IF;  -- if create_line_loc = false and unit price different

      d_position := 150;

      -- bug5149827
      -- Move the handling of exceed tolerance = T to here
      IF (l_exceed_tolerance = FND_API.g_TRUE) THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'set line to be notified', i);
          PO_LOG.stmt(d_module, d_position, 'notified intf header id',
                x_lines.intf_header_id_tbl(i));
        END IF;

        -- set process_code to be 'NOTIFIED' for this line;
        x_lines.process_code_tbl(i) := PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED;

        -- set status on header level for notified lines
        PO_PDOI_PARAMS.g_docs_info(x_lines.intf_header_id_tbl(i)).has_lines_to_notify := FND_API.g_TRUE;

      END IF; -- l_exceed_tolerance = true

      -- check check expiration_date
      -- do the following update only when price does not exceed tolerance
      IF (l_exceed_tolerance = FND_API.g_FALSE) THEN
        -- If the new value is '#DEL', we null out the expiration_date
        IF (PO_PDOI_PARAMS.g_request.document_type IN (
            PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET, PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)  AND --bug10132621
            x_lines.expiration_date_tbl(i) IS NOT NULL) THEN
          IF (x_lines.expiration_date_tbl(i) =
              PO_PDOI_CONSTANTS.g_NULLIFY_DATE) THEN
            l_expiration_date_tbl(l_index) := NULL;
          ELSE
            l_expiration_date_tbl(l_index) := x_lines.expiration_date_tbl(i);
          END IF;
        END IF;
      END IF;

      d_position := 160;

      -- check unit_of_measure
      IF (x_lines.unit_of_measure_tbl(i) IS NOT NULL AND
          x_lines.unit_of_measure_tbl(i) <> l_unit_of_measure_tbl(l_index)) THEN
        BEGIN
          -- if price is not specified in the request and customer update
          -- the uom for the line, the existing price needs to be converted
          -- to corresponding price in new uom
          IF (x_lines.unit_price_tbl(i) IS NULL) THEN

            PO_UOM_S.po_uom_conversion(
              from_unit     => l_unit_of_measure_tbl(l_index),
              to_unit       => x_lines.unit_of_measure_tbl(i),
              item_id       => NVL(x_lines.item_id_tbl(i),0),
              uom_rate      => l_uom_rate
            );

            d_position := 170;

            l_precision :=
              PO_PDOI_MAINPROC_UTL_PVT.get_currency_precision
              (
                p_currency_code     => x_lines.hd_currency_code_tbl(i),
                x_precision_tbl     => l_precision_tbl
              );

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'l_precision', l_precision);
            END IF;

            -- retroactive_date reset to sysdate since price is changed
            IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET AND
                NVL(l_price_break_lookup_code_tbl(l_index), 'NON CUMULATIVE') = 'NON CUMULATIVE') THEN
              l_retroactive_date_tbl(l_index) := sysdate;
            END IF;

            d_position := 180;

            l_unit_price_tbl(l_index) :=
               round((l_unit_price_tbl(l_index)/l_uom_rate),l_precision);

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'new price', l_unit_price_tbl(l_index));
            END IF;

            IF (x_lines.base_unit_price_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
              l_base_unit_price_tbl(l_index) := NULL;
            ELSE
              l_base_unit_price_tbl(l_index) :=
                NVL(x_lines.base_unit_price_tbl(i), l_unit_price_tbl(l_index));
            END IF;
          END IF;

          d_position := 190;

          -- save new uom
          l_unit_of_measure_tbl(l_index) := x_lines.unit_of_measure_tbl(i);

          -- give warnings if price break exist or line price limit is set;
          -- the actual action to check price break is delayed until
          -- all lines in the table is processed
          l_uom_warning_queue(i) := i;
          l_price_limit_queue(i) := l_price_limit_tbl(l_index);
        EXCEPTION
          WHEN OTHERS THEN
            PO_PDOI_ERR_UTL.add_fatal_error
            (
              p_interface_header_id  => x_lines.intf_header_id_tbl(i),
              p_interface_line_id    => x_lines.intf_line_id_tbl(i),
              p_error_message_name   => 'PO_PDOI_INVALID_UOM_CODE',
              p_table_name           => 'PO_LINES_INTERFACE',
              p_column_name          => 'UNIT_OF_MEASURE',
              p_column_value         => x_lines.unit_of_measure_tbl(i),
              p_token1_name          => 'VALUE',
              p_token1_value         => x_lines.unit_of_measure_tbl(i)
            );
        END;
      END IF;

      d_position := 200;

      -- check attribute14
      IF (x_lines.attribute14_tbl(i) IS NOT NULL) THEN
        IF (x_lines.attribute14_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR) THEN
          l_attribute14_tbl(l_index) := NULL;
        ELSE
          l_attribute14_tbl(l_index) := x_lines.attribute14_tbl(i);
        END IF;
      END IF;

      d_position := 210;

      -- check amount
      IF (x_lines.amount_tbl(i) IS NOT NULL) THEN
        IF (x_lines.amount_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
          l_amount_tbl(l_index) := NULL;
        ELSE
          IF (x_lines.amount_tbl(i) <> 0) THEN
            l_amount_tbl(l_index) := x_lines.amount_tbl(i);
          END IF;
        END IF;
      END IF;

      d_position := 220;

      -- check negotiated_by_preparer_flag
      IF (x_lines.negotiated_flag_tbl(i) IS NOT NULL) THEN
        IF (x_lines.negotiated_flag_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR) THEN
          l_negotiated_flag_tbl(l_index) := NULL;
        ELSE
          l_negotiated_flag_tbl(l_index) := x_lines.negotiated_flag_tbl(i);
        END IF;
      END IF;

      d_position := 230;

      -- check po category_id
      IF (x_lines.category_id_tbl(i) IS NOT NULL) THEN
        IF (x_lines.category_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
          l_category_id_tbl(l_index) := NULL;
        ELSE
          l_category_id_tbl(l_index) := x_lines.category_id_tbl(i);
        END IF;
      END IF;

      d_position := 240;
      --For bug 13736932
      --Removing the extend of l_modified_ip_cat_id_tbl from here and including it just after the starting of FOR loop
       --Bug 9795725 if it is inside loop it can try to assign  value to  l_modified_ip_cat_id_tbl(2)  when we can not have array above 1
       --For ex when second line modified at that time i will be 2 and   l_modified_ip_cat_id_tbl.EXTEND will return 1
       --       l_modified_ip_cat_id_tbl.EXTEND;
      -- check ip_category_id

      IF (x_lines.ip_category_id_tbl(i) IS NOT NULL AND
        x_lines.ip_category_id_tbl(i) <> l_ip_category_id_tbl(l_index)) THEN
        IF (x_lines.ip_category_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
          l_ip_category_id_tbl(l_index) := -2;
        ELSE
          l_ip_category_id_tbl(l_index) := x_lines.ip_category_id_tbl(i);
        END IF;

        -- mark down the index of line for which ip_category_id is changed,
        -- need to null out all category based attribute values on
        -- attribute_values and attribute_values_tlp tables
        l_ip_cat_id_updated_queue(i) := i;

	 --For bug 13736932
      --Removing the extend of l_ip_category_id_tbl from here and including it just after the starting of FOR loop
	--For bug 13243413
	--Extending l_ip_category_id_tbl for avoiding ORA-06533
	--l_ip_category_id_tbl.EXTEND;

        -- <Bug 7655719>
        -- create a table of modified (new) ip_category_id
        -- the index for this table is record number (i) and not line reference (l_index)



        l_modified_ip_cat_id_tbl(i) := l_ip_category_id_tbl(l_index);
    END IF;

     -- bug 13506679
     -- check un number

     IF (x_lines.un_number_id_tbl(i) IS NOT NULL) THEN
                IF (x_lines.un_number_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
                  l_un_number_id_tbl(l_index) := NULL;
                ELSE
                  l_un_number_id_tbl(l_index) := x_lines.un_number_id_tbl(i);
                END IF;
              END IF;

      --check hazard class id

      IF (x_lines.hazard_class_id_tbl(i) IS NOT NULL) THEN
                IF (x_lines.hazard_class_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM) THEN
                  l_hazard_class_id_tbl(l_index) := NULL;
                ELSE
                  l_hazard_class_id_tbl(l_index) := x_lines.hazard_class_id_tbl(i);
                END IF;
              END IF;

    -- end bug 13506679

      d_position := 250;

      -- set has_lines_updated flag in g_docs_info
      IF (l_exceed_tolerance = FND_API.g_FALSE) THEN
        PO_PDOI_PARAMS.g_docs_info(x_lines.intf_header_id_tbl(i)).has_lines_updated := 'Y';

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'line updated for document',
                      x_lines.intf_header_id_tbl(i));
        END IF;
      END IF;

    END IF; -- IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE)
  END LOOP;

  d_position := 260;

  /*
     After processing each line, we need to make following changes:
     1. update item with new description; Item is updated before po line
        since we want to fail the line if item update failed
     2. update line draft table with all changes
     3. update or delete price break depending on document type
     4. give warning message for lines in l_uom_warning_queue
     5. update description field in po_attribute_values_tlp table if necessary
     6. null out all cat attribute values in attribute_values and tlp tables
  */
  -- 1. update item master with new description
  l_index := l_update_item_queue.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    EGO_ITEM_PUB.Process_Item
  (
      p_api_version                 => 1.0,
      p_init_msg_list               => FND_API.g_TRUE,
      p_commit                      => FND_API.g_TRUE,
      p_Transaction_Type            => 'UPDATE',
      p_Inventory_Item_Id           => x_lines.item_id_tbl(l_index),
      p_Organization_Id             => PO_PDOI_PARAMS.g_sys.def_inv_org_id,
      p_description                 => NVL(x_lines.item_desc_tbl(l_index), EGO_ITEM_PUB.G_MISS_CHAR),
      p_Item_Number                 => x_lines.item_tbl(l_index),
      x_Inventory_Item_Id           => l_inventory_item_id,
      x_Organization_Id             => l_organization_id,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data
  );

    d_position := 270;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'return status for item update',
                l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- error handling
    Error_Handler.GET_MESSAGE_LIST
    (
      x_message_list  => l_message_list
    );

    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'count of error message',
                    l_message_list.COUNT);
      END IF;

      FOR i IN 1..l_message_list.COUNT
    LOOP
      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'index', i);
          PO_LOG.stmt(d_module, d_position, 'intf header id',
                  x_lines.intf_header_id_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'intf line id',
                  x_lines.intf_line_id_tbl(l_index));
          PO_LOG.stmt(d_module, d_position, 'message text',
                  l_message_list(i).message_text);
      PO_LOG.stmt(d_module, d_position, 'table name',
                  l_message_list(i).table_name);
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
          p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
          p_app_name             => 'INV',
          p_error_message_name   => l_message_list(i).message_text,
          p_table_name           => l_message_list(i).table_name,
          p_column_name          => NULL,
          p_column_value         => NULL
        );
      END LOOP;

      x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;

      PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_UPDATE);

      IF (PO_LOG.d_proc) THEN
        PO_LOG.proc_end (d_module);
      END IF;

      RETURN;
  END IF;

  l_index := l_update_item_queue.NEXT(l_index);
  END LOOP;
/*
  FORALL i IN 1..l_update_item_id_tbl.COUNT
    UPDATE mtl_system_items
    SET    description = l_update_item_desc_tbl(i),
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id,
           request_id = FND_GLOBAL.conc_request_id,
           program_application_id = FND_GLOBAL.prog_appl_id,
           program_id = FND_GLOBAL.conc_program_id,
           program_update_date = sysdate
    WHERE  inventory_item_id = l_update_item_id_tbl(i)
    AND    organization_id = PO_PDOI_PARAMS.g_sys.master_inv_org_id;

  d_position := 280;

  FORALL i IN 1..l_update_item_id_tbl.COUNT
    UPDATE mtl_system_items_tl
    SET    description = l_update_item_desc_tbl(i)
    WHERE  inventory_item_id = l_update_item_id_tbl(i)
    AND    organization_id = PO_PDOI_PARAMS.g_sys.master_inv_org_id
    AND    language = USERENV('LANG');
 */

  d_position := 280;

  -- 2. update draft table with all the changes
  FORALL i IN 1..l_po_line_id_tbl.COUNT
    UPDATE po_lines_draft_all
    SET    unit_price = l_unit_price_tbl(i),
           unit_meas_lookup_code = l_unit_of_measure_tbl(i),
           item_description = l_item_desc_tbl(i),
           expiration_date = l_expiration_date_tbl(i),
           retroactive_date = l_retroactive_date_tbl(i),
           base_unit_price = l_base_unit_price_tbl(i),
           attribute14 = l_attribute14_tbl(i),
           amount = l_amount_tbl(i),
           negotiated_by_preparer_flag = l_negotiated_flag_tbl(i),
           category_id = l_category_id_tbl(i),
           ip_category_id = l_ip_category_id_tbl(i),
           -- Bug 13506679
           un_number_id = l_un_number_id_tbl(i),
           hazard_class_id = l_hazard_class_id_tbl(i),
           -- Bug 13506679
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id,
           request_id = FND_GLOBAL.conc_request_id,
           program_application_id = FND_GLOBAL.prog_appl_id,
           program_id = FND_GLOBAL.conc_program_id,
           program_update_date = sysdate
    WHERE  po_line_id = l_po_line_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

  d_position := 290;

  -- 3. update or delete price break depending on document type
  --    when price is changed
  FORALL i IN INDICES OF l_update_loc_queue
    INSERT INTO po_session_gt(key, num1, num2, char1)
    SELECT l_key,
           line_location_id,
           x_lines.draft_id_tbl(i),
           'Y'
    FROM   po_line_locations
    WHERE  po_line_id = x_lines.po_line_id_tbl(i);

  d_position := 300;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2, char1 BULK COLLECT INTO
    l_change_loc_id_tbl, l_draft_id_tbl, l_delete_flag_tbl;

  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
    -- read lines into draft, the actual update of price discount
    -- happens when we process the line locations
    FOR i IN 1..l_change_loc_id_tbl.COUNT
    LOOP
      l_delete_flag_tbl(i) := 'N';
    END LOOP;
    PO_LINE_LOCATIONS_DRAFT_PKG.sync_draft_from_txn
    (
      p_line_location_id_tbl     => l_change_loc_id_tbl,
      p_draft_id_tbl             => l_draft_id_tbl,
      p_delete_flag_tbl          => l_delete_flag_tbl,
      x_record_already_exist_tbl => l_record_already_exist_tbl
    );
  ELSE -- document_type = 'QUOTATION'
    -- delete price breaks for the line
    PO_LINE_LOCATIONS_DRAFT_PKG.sync_draft_from_txn
    (
      p_line_location_id_tbl     => l_change_loc_id_tbl,
      p_draft_id_tbl             => l_draft_id_tbl,
      p_delete_flag_tbl          => l_delete_flag_tbl,
      x_record_already_exist_tbl => l_record_already_exist_tbl
    );
  END IF;

  d_position := 310;

  -- 4. give warning message for lines in l_uom_warning_queue
  FORALL i IN INDICES OF l_uom_warning_queue
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_uom_warning_queue(i)
    FROM   DUAL
    WHERE  EXISTS (SELECT 1
                   FROM   po_line_locations
                   WHERE  po_line_id = x_lines.po_line_id_tbl(i)
                   AND    shipment_type = 'PRICE BREAK')
    OR     EXISTS (SELECT 1
                   FROM   po_line_locations_draft_all
                   WHERE  po_line_id =
                            x_lines.po_line_id_tbl(i)
                   AND    draft_id = x_lines.draft_id_tbl(i)
                   AND    shipment_type = 'PRICE BREAK')
    OR     l_price_limit_queue(i) IS NOT NULL;

  d_position := 320;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (x_lines.unit_price_tbl(l_index) IS NULL) THEN
      PO_PDOI_ERR_UTL.add_warning
      (
        p_interface_header_id   => x_lines.intf_header_id_tbl(l_index),
        p_interface_line_id     => x_lines.intf_line_id_tbl(l_index),
        p_error_message_name    => 'PO_BLANKET_UPDATE_PRICE_BREAKS',
        p_table_name            => 'PO_LINES_INTERFACE',
        p_column_name           => 'UNIT_OF_MEASURE'
      );
    ELSE
      PO_PDOI_ERR_UTL.add_warning
      (
        p_interface_header_id   => x_lines.intf_header_id_tbl(l_index),
        p_interface_line_id     => x_lines.intf_line_id_tbl(l_index),
        p_error_message_name    => 'PO_BLANKET_UPDATE_PB_NO_CONV',
        p_table_name            => 'PO_LINES_INTERFACE',
        p_column_name           => 'UNIT_OF_MEASURE'
      );
    END IF;
  END LOOP;

  d_position := 330;

  -- <Bug 7655719 Start>
  -- 5.a. udpate ip category in po_attribute_values table
  FORALL i IN INDICES OF l_ip_cat_id_updated_queue
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1,
      char2
    )
    SELECT
      l_key,
      attribute_values_id,
      x_lines.draft_id_tbl(i),
      l_modified_ip_cat_id_tbl(i),
      'N'
    FROM  po_attribute_values
    WHERE po_line_id = x_lines.po_line_id_tbl(i);

  d_position := 333;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2, char1, char2
  BULK COLLECT INTO
    l_sync_attr_id_tbl, l_draft_id_tbl,
    l_modified_ip_cat_id_tbl_tmp, l_delete_flag_tbl;

  d_position := 335;

  -- sync from txn table to draft table
  PO_ATTR_VALUES_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_id_tbl      => l_sync_attr_id_tbl,
    p_draft_id_tbl                 => l_draft_id_tbl,
    p_delete_flag_tbl              => l_delete_flag_tbl,
    x_record_already_exist_tbl     => l_record_already_exist_tbl
  );

  d_position := 336;

  -- c. update records in draft table
  FORALL i IN 1..l_sync_attr_id_tbl.COUNT
    UPDATE po_attribute_values_draft
    SET    ip_category_id = l_modified_ip_cat_id_tbl_tmp(i)
    WHERE  attribute_values_id = l_sync_attr_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

  d_position := 337;
  -- <Bug 7655719 End>

  -- 5. update description field in po_attribute_values_tlp table for current lang
  -- b. get rows that need to be synced from txn table to draft table;
  FORALL i IN INDICES OF l_update_desc_queue
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1,
      char2,
      num3,                                       -- <Bug 7655719>
      num4                                        -- <Bug 7655719>
    )
    SELECT
      l_key,
      attribute_values_tlp_id,
      x_lines.draft_id_tbl(i),
      x_lines.item_desc_tbl(i),
      'N',
      l_update_desc_queue(i), -- index to compare records in MERGE sql below
      NULL -- ip_category_id (Dummy insert to ensure that this field is not reused)
    FROM  po_attribute_values_tlp
    WHERE po_line_id = x_lines.po_line_id_tbl(i)
    AND   language = USERENV('LANG');

  d_position := 340;

  -- <Bug 7655719 Start>
  -- merge rows for which ip category is to be updated with
  -- rows identified above (for which description is to be updated)
  FORALL i IN INDICES OF l_ip_cat_id_updated_queue
    MERGE INTO po_session_gt merged
      USING dual
      ON (merged.num3 = l_ip_cat_id_updated_queue(i)
          AND merged.key = l_key)
      WHEN MATCHED THEN
        UPDATE
        SET
          num4 = l_modified_ip_cat_id_tbl(i)
      WHEN NOT MATCHED THEN
        INSERT
        (
          key,
          num1,
          num2,
          char1,
          char2,
          num3,
          num4
        )
        VALUES
        (
          l_key,
          (SELECT attribute_values_tlp_id
           FROM   po_attribute_values_tlp
           WHERE  po_line_id = x_lines.po_line_id_tbl(i)
                  AND language = USERENV('LANG')),
          x_lines.draft_id_tbl(i),
          x_lines.item_desc_tbl(i),
          'N',
          l_ip_cat_id_updated_queue(i),
          l_modified_ip_cat_id_tbl(i)
        );
  -- <Bug 7655719 End>

  d_position := 345;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2, char1, char2, num4
  BULK COLLECT INTO
    l_sync_attr_tlp_id_tbl, l_draft_id_tbl,
    l_item_desc_tbl, l_delete_flag_tbl,
    l_modified_ip_cat_id_tbl_tmp;               -- <Bug 7655719>

  d_position := 350;

  -- sync from txn table to draft table
  PO_ATTR_VALUES_TLP_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_tlp_id_tbl  => l_sync_attr_tlp_id_tbl,
    p_draft_id_tbl                 => l_draft_id_tbl,
    p_delete_flag_tbl              => l_delete_flag_tbl,
    x_record_already_exist_tbl     => l_record_already_exist_tbl
  );

  d_position := 360;

  -- c. update records in draft table
  FORALL i IN 1..l_sync_attr_tlp_id_tbl.COUNT
    UPDATE po_attribute_values_tlp_draft
    SET    description = l_item_desc_tbl(i),
           ip_category_id = NVL(l_modified_ip_cat_id_tbl_tmp(i), ip_category_id) -- <Bug 7655719>
    WHERE  attribute_values_tlp_id = l_sync_attr_tlp_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

  d_position := 370;

  -- 6. null out all cat attribute values in attribute_values and tlp tables
  reset_cat_attributes
  (
    p_index_tbl       => l_ip_cat_id_updated_queue,
    p_po_line_id_tbl  => x_lines.po_line_id_tbl,
    p_draft_id_tbl    => x_lines.draft_id_tbl
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_UPDATE);

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
END update_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_line_locs
--Function:
--  transfer new line location rows to draft table
--Parameters:
--IN:
--p_line_locs
--  record which contains processed line location attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_line_locs
(
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                       po_session_gt.key%TYPE;

  l_change_loc_id_tbl         PO_TBL_NUMBER;
  l_draft_id_tbl              PO_TBL_NUMBER;
  l_delete_flag_tbl           PO_TBL_VARCHAR1;
  l_record_already_exist_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_INSERT);

/*
  -- delete existing price breaks for Quotation if new price breaks are added
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
    d_position := 10;

    -- get existing line_location_ids
    l_key := PO_CORE_S.get_session_gt_nextval;
    FORALL i IN 1..p_line_locs.rec_count
    INSERT INTO po_session_gt(key, num1, num2, char1)
    SELECT DISTINCT l_key,
           line_location_id,
           p_line_locs.draft_id_tbl(i),
           'Y'
    FROM   po_line_locations
    WHERE  po_line_id = p_line_locs.ln_po_line_id_tbl(i)
    AND    p_line_locs.error_flag_tbl(i) = FND_API.g_FALSE;

    d_position := 20;

    DELETE FROM po_session_gt
    WHERE  key = l_key
    RETURNING num1, num2, char1 BULK COLLECT INTO
    l_change_loc_id_tbl, l_draft_id_tbl, l_delete_flag_tbl;

    d_position := 30;

    -- sync from txn to draft table with delete_flag set to 'Y'
    PO_LINE_LOCATIONS_DRAFT_PKG.sync_draft_from_txn
    (
      p_line_location_id_tbl     => l_change_loc_id_tbl,
      p_draft_id_tbl             => l_draft_id_tbl,
      p_delete_flag_tbl          => l_delete_flag_tbl,
      x_record_already_exist_tbl => l_record_already_exist_tbl
    );
  END IF;
*/
  d_position := 40;

  -- insert line location rows into po_line_locations_draft_all
  insert_po_line_locs_draft_all
  (
    p_line_locs    =>   p_line_locs
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_INSERT);

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
END insert_line_locs;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_dists
--Function:
--  insert new distribution rows into draft table
--Parameters:
--IN:
--p_dists
--  record which contains processed distribution attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_dists
(
  p_dists       IN PO_PDOI_TYPES.distributions_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_dists';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_DIST_INSERT);

  -- insert distribution rows into po_distributions_draft_all
  insert_po_dists_draft_all
  (
    p_dists    =>   p_dists
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_DIST_INSERT);

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
END insert_dists;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_price_diffs
--Function:
--  insert new price differential rows into draft table
--Parameters:
--IN:
--p_price_diffs
--  record which contains processed price diff attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_price_diffs
(
  p_price_diffs IN PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_INSERT);

  -- insert price differential rows into po_price_diff_draft
  insert_po_price_diff_draft
  (
    p_price_diffs    =>   p_price_diffs
  );

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_INSERT);

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
END insert_price_diffs;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_attr_values
--Function:
--  insert new or update existing attribute values
--Parameters:
--IN:
--p_processing_row_tbl
--  index of rows to be created or updated
--p_sync_attr_id_tbl
--  existing attribute values rows we need to read from txn table
--  to draft table
--p_sync_draft_id_tbl
--  draft_id we need to populate for rows read from txn table to
--  draft table
--p_attr_values
--  record which contains processed attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_attr_values
(
  p_processing_row_tbl IN DBMS_SQL.NUMBER_TABLE,
  p_sync_attr_id_tbl   IN PO_TBL_NUMBER,
  p_sync_draft_id_tbl  IN PO_TBL_NUMBER,
  p_attr_values        IN PO_PDOI_TYPES.attr_values_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'merge_attr_values';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                      po_session_gt.key%TYPE;

  -- variables used to sync attr values rows from txn table
  -- to draft table
  l_delete_flag_tbl          PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_sync_attr_id_tbl', p_sync_attr_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_sync_draft_id_tbl', p_sync_draft_id_tbl);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_ATTR_VALUES_INSERT);

  -- sync rows from txn tables to draft tables for update
  l_delete_flag_tbl.EXTEND(p_sync_attr_id_tbl.COUNT);
  FOR i IN 1..p_sync_attr_id_tbl.COUNT
  LOOP
    l_delete_flag_tbl(i) := 'N';
  END LOOP;

  PO_ATTR_VALUES_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_id_tbl   => p_sync_attr_id_tbl,
    p_draft_id_tbl              => p_sync_draft_id_tbl,
    p_delete_flag_tbl           => l_delete_flag_tbl,
    x_record_already_exist_tbl  => l_record_already_exist_tbl
  );

  d_position := 10;

  -- save id attr values into po_session_gt for MERGE query
  l_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF p_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,  -- interface_attr_values_id
      num2,  -- attribute_values_id
      num3,  -- draft_id
      num4,  -- po_line_id
      num5,  -- ip_category_id
      num6,  -- item_id
      num7   -- lead_time -- Bug#17998869
    )
    SELECT
      l_key,
      p_attr_values.intf_attr_values_id_tbl(i),
      p_attr_values.attribute_values_id_tbl(i),
      p_attr_values.draft_id_tbl(i),
      p_attr_values.ln_po_line_id_tbl(i),
      p_attr_values.ln_ip_category_id_tbl(i),
      p_attr_values.ln_item_id_tbl(i),
      p_attr_values.lead_time_tbl(i)
    FROM   DUAL
    WHERE  p_attr_values.error_flag_tbl(i) = FND_API.g_FALSE;

  d_position := 20;

  -- merge values from interface tables to draft tables
  merge_po_attr_values_draft
  (
    p_key                => l_key,
    p_attr_values        => p_attr_values
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_ATTR_VALUES_INSERT);

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
END merge_attr_values;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_attr_values_tlp
--Function:
--  insert or update attribute values tlp rows into draft table
--Parameters:
--IN:
--p_processing_row_tbl
--  index of attr values tlp rows to be processed
--p_sync_attr_tlp_id_tbl
--  existing attribute values rows we need to read from txn table
--  to draft table
--p_sync_draft_id_tbl
--  draft_id we need to populate for rows read from txn table to
--  draft table
--p_attr_values_tlp
--  record which contains processed attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_attr_values_tlp
(
  p_processing_row_tbl   IN DBMS_SQL.NUMBER_TABLE,
  p_sync_attr_tlp_id_tbl IN PO_TBL_NUMBER,
  p_sync_draft_id_tbl    IN PO_TBL_NUMBER,
  p_attr_values_tlp      IN PO_PDOI_TYPES.attr_values_tlp_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'merge_attr_values_tlp';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                      po_session_gt.key%TYPE;

  -- variables used to sync attr values rows from txn table
  -- to draft table
  l_delete_flag_tbl          PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_sync_attr_tlp_id_tbl', p_sync_attr_tlp_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_sync_draft_id_tbl', p_sync_draft_id_tbl);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_ATTR_VALUES_TLP_INSERT);

  -- sync rows from txn tables to draft tables for update
  l_delete_flag_tbl.EXTEND(p_sync_attr_tlp_id_tbl.COUNT);
  FOR i IN 1..p_sync_attr_tlp_id_tbl.COUNT
  LOOP
    l_delete_flag_tbl(i) := 'N';
  END LOOP;

  PO_ATTR_VALUES_TLP_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_tlp_id_tbl   => p_sync_attr_tlp_id_tbl,
    p_draft_id_tbl                  => p_sync_draft_id_tbl,
    p_delete_flag_tbl               => l_delete_flag_tbl,
    x_record_already_exist_tbl      => l_record_already_exist_tbl
  );

  d_position := 10;

  -- save id attr values tlp into po_session_gt for MERGE query
  l_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF p_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,  -- interface_attr_values_tlp_id
      num2,  -- attribute_values_tlp_id
      num3,  -- draft_id
      num4,  -- po_line_id
      num5,  -- ip_category_id
      num6,  -- item_id
      char1,  -- item_desc
      char2   -- long_desc           -- Bug7722053
    )
    SELECT
      l_key,
      p_attr_values_tlp.intf_attr_values_tlp_id_tbl(i),
      p_attr_values_tlp.attribute_values_tlp_id_tbl(i),
      p_attr_values_tlp.draft_id_tbl(i),
      p_attr_values_tlp.ln_po_line_id_tbl(i),
      p_attr_values_tlp.ln_ip_category_id_tbl(i),
      p_attr_values_tlp.ln_item_id_tbl(i),
      p_attr_values_tlp.ln_item_desc_tbl(i),
      p_attr_values_tlp.ln_item_long_desc_tbl(i)      -- Bug7722053
    FROM   DUAL
    WHERE  p_attr_values_tlp.error_flag_tbl(i) = FND_API.g_FALSE;

  d_position := 20;

  -- insert or update attribute values rows into po_attribute_values_draft
  merge_po_attr_values_tlp_draft
  (
    p_key                => l_key,
    p_attr_values_tlp    => p_attr_values_tlp
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_ATTR_VALUES_TLP_INSERT);

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
END merge_attr_values_tlp;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_headers_draft_all
--Function:
--  insert new documents attribute values into po_headers_draft_all
--Parameters:
--IN:
--p_headers
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_headers_draft_all
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_headers_draft_all';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_valid_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_count NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    FOR i IN 1..p_headers.rec_count
    LOOP
      IF (p_headers.error_flag_tbl(i) = FND_API.G_FALSE) THEN
        l_valid_intf_header_id_tbl.EXTEND(1);
        l_count := l_valid_intf_header_id_tbl.COUNT;
        l_valid_intf_header_id_tbl(l_count) :=
          p_headers.intf_header_id_tbl(i);
      END IF;
    END LOOP;

    PO_LOG.stmt(d_module, d_position, 'intf header to be inserted',
                l_valid_intf_header_id_tbl);
  END IF;

  FORALL i IN 1..p_headers.rec_count
    INSERT INTO po_headers_draft_all
    (
      draft_id,
      org_id,
      delete_flag,
      change_accepted_flag,
      po_header_id,
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
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      interface_source_code,
      reference_num,
      pay_on_code,
      quote_warning_delay_unit,
      global_agreement_flag,
      --<PDOI Enhancement Bug#17063664 Start>
      consume_req_demand_flag,
      pcard_id,
      --<PDOI Enhancement Bug#17063664 End>
      shipping_control,
      encumbrance_required_flag,
      document_creation_method,

      -- new columns in R12
      style_id,
      created_language,
      tax_attribute_update_code,

      --bug17940049
      ame_approval_id,
      ame_transaction_type,
      consigned_consumption_flag, -- Bug 18891225
      supply_agreement_flag -- Bug 20022541 PDOI Support for Supply_agreement_flag
    )
    SELECT
      p_headers.draft_id_tbl(i),
      PO_PDOI_PARAMS.g_request.org_id,
      NULL, -- delete_flag
      NULL, -- change_accepted_flag
      p_headers.po_header_id_tbl(i),
      p_headers.agent_id_tbl(i),
      p_headers.doc_type_tbl(i),
      p_headers.last_update_date_tbl(i),
      p_headers.last_updated_by_tbl(i),
      p_headers.document_num_tbl(i),
      'N',  -- summary flag
      'Y',  -- enabled_flag,
      NULL, -- segment2,
      NULL, -- segment3,
      NULL, -- segment4,
      NULL, -- segment5,
      NULL, -- start_date_active,
      NULL, -- end_date_active,
      p_headers.last_update_login_tbl(i),
      p_headers.creation_date_tbl(i),
      p_headers.created_by_tbl(i),
      p_headers.vendor_id_tbl(i),
      p_headers.vendor_site_id_tbl(i),
      p_headers.vendor_contact_id_tbl(i),
      p_headers.ship_to_loc_id_tbl(i),
      p_headers.bill_to_loc_id_tbl(i),
      p_headers.terms_id_tbl(i),
      p_headers.freight_carrier_tbl(i),
      p_headers.fob_tbl(i),
      p_headers.freight_term_tbl(i),
      p_headers.status_lookup_code_tbl(i),
      p_headers.currency_code_tbl(i),
      p_headers.rate_type_code_tbl(i),
      TRUNC(p_headers.rate_date_tbl(i)),
      p_headers.rate_tbl(i),
      p_headers.from_header_id_tbl(i),
      p_headers.from_type_lookup_code_tbl(i),
      TRUNC(effective_date),
      TRUNC(expiration_date),
      amount_agreed,
      'INCOMPLETE', -- p_headers.authorization_status_tbl(i),
      p_headers.revision_num_tbl(i),
      revised_date,
      p_headers.approved_flag_tbl(i),
      p_headers.approved_date_tbl(i),
      p_headers.amount_limit_tbl(i), -- bug5352625
      p_headers.min_release_amount_tbl(i),
      NULL, -- note_to_authorizer,
      note_to_vendor,
      note_to_receiver,
      p_headers.print_count_tbl(i),
      printed_date,
      p_headers.vendor_order_num_tbl(i),
      p_headers.confirming_order_flag_tbl(i),
      comments,
      TRUNC(p_headers.reply_date_tbl(i)),
      reply_method,
      TRUNC(rfq_close_date),
      p_headers.doc_subtype_tbl(i),
      p_headers.quotation_class_code_tbl(i),
      p_headers.quote_warning_delay_tbl(i),
      p_headers.quote_vendor_quote_num_tbl(i),
      p_headers.acceptance_required_flag_tbl(i),
      TRUNC(p_headers.acceptance_due_date_tbl(i)),
      closed_date,
      NULL, -- user_hold_flag,
      p_headers.approval_required_flag_tbl(i),
      p_headers.cancel_flag_tbl(i),
      NULL, -- firm_status_lookup_code,
      NULL, -- firm_date,
      p_headers.frozen_flag_tbl(i),
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
      p_headers.closed_code_tbl(i),
      NULL, -- government_context,
      p_headers.request_id_tbl(i),
      p_headers.program_application_id_tbl(i),
      p_headers.program_id_tbl(i),
      p_headers.program_update_date_tbl(i),
      DECODE(PO_PDOI_PARAMS.g_request.calling_module,PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,NULL,interface_source_code), --BUG19896976
      reference_num,
      p_headers.pay_on_code_tbl(i),
      NULL, -- quote_warning_delay_unit,
      p_headers.global_agreement_flag_tbl(i),
      --<PDOI Enhancement Bug#17063664 Start>
      p_headers.consume_req_demand_flag_tbl(i),
      p_headers.pcard_id_tbl(i),
      --<PDOI Enhancement Bug#17063664 End>
      p_headers.shipping_control_tbl(i),
      p_headers.encumbrance_required_flag_tbl(i),
      p_headers.doc_creation_method_tbl(i),

      -- new columns added in R12
      p_headers.style_id_tbl(i),
      p_headers.created_language_tbl(i),
      p_headers.tax_attribute_update_code_tbl(i),

      --bug17940049
      p_headers.ame_approval_id_tbl(i),
      p_headers.ame_transaction_type_tbl(i),
      p_headers.consigned_consumption_flag_tbl(i), -- Bug 18891225

      -- Bug 20022541 PDOI Support for Supply_agreement_flag
      decode(p_headers.doc_type_tbl(i), PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
            p_headers.supply_agreement_flag_tbl(i), NULL)-- CUMMINS

    FROM   po_headers_interface
    WHERE  interface_header_id = p_headers.intf_header_id_tbl(i)
    AND    p_headers.error_flag_tbl(i) = FND_API.g_FALSE;

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
END insert_po_headers_draft_all;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_ga_org_assign_draft
--Function:
--  insert rows into po_ga_org_assign draft table;
--  this applies only to global blanket
--Parameters:
--IN:
--p_headers
--  record which contains processed attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_ga_org_assign_draft
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_ga_org_assign_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Bug#17864040: Added condition to insert record into the table
  -- po_ga_org_assignments for CONTRACT type documents as well.
  IF (po_pdoi_params.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET OR
      po_pdoi_params.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) THEN
    FORALL i IN 1..p_headers.rec_count
      INSERT INTO po_ga_org_assign_draft
      (
        draft_id,
        delete_flag,
        change_accepted_flag,
        po_header_id,
        organization_id,
        enabled_flag,
        vendor_site_id,
        purchasing_org_id,
        org_assignment_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by
      )
      SELECT
        p_headers.draft_id_tbl(i),
        NULL, -- delete_flag,
        NULL, -- change_accepted_flag,
        p_headers.po_header_id_tbl(i),
        PO_PDOI_PARAMS.g_request.org_id,
        NVL(global_agreement_flag, PO_PDOI_PARAMS.g_request.ga_flag),
        p_headers.vendor_site_id_tbl(i),
        PO_PDOI_PARAMS.g_request.org_id,
        PO_GA_ORG_ASSIGNMENTS_S.nextval, -- org_assignment_id,
        p_headers.last_update_date_tbl(i),
        p_headers.last_updated_by_tbl(i),
        p_headers.last_update_login_tbl(i),
        p_headers.creation_date_tbl(i),
        p_headers.created_by_tbl(i)
      FROM   po_headers_interface
      WHERE  interface_header_id = p_headers.intf_header_id_tbl(i)
      AND    p_headers.error_flag_tbl(i) = FND_API.g_FALSE
      AND    p_headers.doc_type_tbl(i) IN (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
                , PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) -- Bug#17864040
      AND    COALESCE(global_agreement_flag, PO_PDOI_PARAMS.g_request.ga_flag, 'N') = 'Y';
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
END insert_po_ga_org_assign_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_blk_dists_draft_all
--Function:
--  insert rows into po_distribution draft_all table;
--  There are 2 cases when new rows will be inserted
--  into po_distributions_draft_all table:
--  1. encumberance is required for new blanket: the
--     attribute values will be read from
--     po_headers_interface table
--  2. valid distribution rows exist in interface table:
--     attribute values will be read from
--     po_distributions_interface table
--  This procedure will handle the first case
--Parameters:
--IN:
--p_headers
--  record which contains processed attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_blk_dists_draft_all
(
  p_headers IN PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_blk_dists_draft_all';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- add distribution row from po_headers_interface table
  IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET AND
      PO_PDOI_PARAMS.g_sys.po_encumbrance_flag = 'Y' AND
      PO_PDOI_PARAMS.g_sys.req_encumbrance_flag = 'Y') THEN
    d_position := 10;

    FORALL i IN 1.. p_headers.rec_count
      INSERT INTO po_distributions_draft_all
      (
        draft_id,
        org_id,
        delete_flag,
        change_accepted_flag,
        po_distribution_id,
        po_header_id,
        distribution_num,
        set_of_books_id,
        rate_date,
        rate,
        gl_encumbered_date,
        gl_encumbered_period_name,
        budget_account_id,
        prevent_encumbrance_flag,
        distribution_type,
        amount_to_encumber,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date
      )
      SELECT
        p_headers.draft_id_tbl(i),
        PO_PDOI_PARAMS.g_request.org_id,
        NULL, -- delete_flag,
        NULL, -- change_accepted_flag,
        p_headers.po_dist_id_tbl(i),
        p_headers.po_header_id_tbl(i),
        1, -- distribution_num
        PO_PDOI_PARAMS.g_sys.sob_id,
        p_headers.rate_date_tbl(i),
        p_headers.rate_tbl(i),
        p_headers.gl_encumbered_date_tbl(i),
        p_headers.gl_encumbered_period_tbl(i),
        p_headers.budget_account_id_tbl(i),
        'N', -- prevent_encumbrance_flag
        'AGREEMENT', -- distribution_type
        p_headers.amount_to_encumber_tbl(i),
        sysdate,
        FND_GLOBAL.user_id,
        FND_GLOBAL.login_id,
        sysdate,
        FND_GLOBAL.user_id,
        FND_GLOBAL.conc_request_id,
        FND_GLOBAL.prog_appl_id,
        FND_GLOBAL.conc_program_id,
        sysdate
      FROM   DUAL
      WHERE  p_headers.error_flag_tbl(i) = FND_API.g_FALSE
      AND    p_headers.encumbrance_required_flag_tbl(i) = 'Y';
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
END insert_blk_dists_draft_all;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_dists_draft_all
--Function:
--  insert rows into po_distribution draft_all table;
--  There are 2 cases when new rows will be inserted
--  into po_distributions_draft_all table:
--  1. encumberance is required for new blanket: the
--     attribute values will be read from
--     po_headers_interface table
--  2. valid distribution rows exist in interface table:
--     attribute values will be read from
--     po_distributions_interface table
--  This procedure will handle the second case
--Parameters:
--IN:
--p_dists
--  record which contains processed attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_dists_draft_all
(
  p_dists   IN PO_PDOI_TYPES.distributions_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_dists_draft_all';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables used to print debug message
  l_valid_intf_dist_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_count NUMBER := 0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    FOR i IN 1..p_dists.rec_count
    LOOP
      IF (p_dists.error_flag_tbl(i) = FND_API.g_FALSE) THEN
        l_valid_intf_dist_id_tbl.EXTEND(1);
        l_count := l_count + 1;
        l_valid_intf_dist_id_tbl(l_count) :=
          p_dists.intf_dist_id_tbl(i);
      END IF;
    END LOOP;

    PO_LOG.stmt(d_module, d_position, 'intf dist to be inserted',
                l_valid_intf_dist_id_tbl);
  END IF;

  -- add distribution row from po_distributions_inteface table
  FORALL i IN 1..p_dists.rec_count
    INSERT INTO po_distributions_draft_all
    (
      draft_id,
      org_id,
      delete_flag,
      change_accepted_flag,
      po_distribution_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      line_location_id,
      set_of_books_id,
      code_combination_id,
      quantity_ordered,
      last_update_login,
      creation_date,
      created_by,
      po_release_id,
      quantity_delivered,
      quantity_billed,
      quantity_cancelled,
      req_header_reference_num,
      req_line_reference_num,
      req_distribution_id,
      deliver_to_location_id,
      deliver_to_person_id,
      rate_date,
      rate,
      amount_billed,
      accrued_flag,
      encumbered_flag,
      encumbered_amount,
      unencumbered_quantity,
      unencumbered_amount,
      failed_funds_lookup_code,
      gl_encumbered_date,
      gl_encumbered_period_name,
      gl_cancelled_date,
      destination_type_code,
      destination_organization_id,
      destination_subinventory,
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
      wip_entity_id,
      wip_operation_seq_num,
      wip_resource_seq_num,
      wip_repetitive_schedule_id,
      wip_line_id,
      bom_resource_id,
      budget_account_id,
      accrual_account_id,
      variance_account_id,
      dest_charge_account_id,
      dest_variance_account_id,
      prevent_encumbrance_flag,
      government_context,
      destination_context,
      distribution_num,
      source_distribution_id,
      --<<Bug#14088099 Start>>
      request_id,
      program_application_id,
      program_id,
      program_update_date,
	    --<<Bug#14088099 End>>
      project_id,
      task_id,
      expenditure_type,
      project_accounting_context,
      expenditure_organization_id,
      gl_closed_date,
      accrue_on_receipt_flag,
      expenditure_item_date,
      end_item_unit_number,
      recovery_rate,
      tax_recovery_override_flag,
      award_id,
      oke_contract_line_id,
      oke_contract_deliverable_id,
      amount_ordered,
      distribution_type,
      amount_to_encumber,
      tax_attribute_update_code,
      global_attribute_category,  --<Gtas Project>
      kanban_card_id, -- Bug 18599449
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
      interface_distribution_ref -- Bug 18891225
    )
    SELECT
      p_dists.draft_id_tbl(i),
      PO_PDOI_PARAMS.g_request.org_id,
      NULL, -- delete_flag,
      NULL, -- change_accepted_flag,
      p_dists.po_dist_id_tbl(i),
      p_dists.last_update_date_tbl(i),
      p_dists.last_updated_by_tbl(i),
      p_dists.hd_po_header_id_tbl(i),
      p_dists.ln_po_line_id_tbl(i),
      p_dists.loc_line_loc_id_tbl(i),
      PO_PDOI_PARAMS.g_sys.sob_id,
      p_dists.charge_account_id_tbl(i),
      p_dists.quantity_ordered_tbl(i),
      p_dists.last_update_login_tbl(i),
      p_dists.creation_date_tbl(i),
      p_dists.created_by_tbl(i),
      NULL, -- po_release_id,
      0, -- quantity_delivered,
      0, -- quantity_billed,
      0, -- quantity_cancelled,
      req_header_reference_num,
      req_line_reference_num,
      p_dists.req_distribution_id_tbl(i), -- req_distribution_id,
      p_dists.deliver_to_loc_id_tbl(i),
      p_dists.deliver_to_person_id_tbl(i),
      p_dists.hd_rate_date_tbl(i),
      p_dists.hd_rate_tbl(i),
      amount_billed,
      NULL, -- accrued_flag,
      'N', -- encumbered_flag,
      NULL, -- encumbered_amount,
      NULL, -- unencumbered_quantity,
      NULL, -- unencumbered_amount,
      NULL, -- failed_funds_lookup_code,
      p_dists.gl_encumbered_date_tbl(i),
      p_dists.gl_encumbered_period_tbl(i),
      NULL, -- gl_cancelled_date,
      p_dists.dest_type_code_tbl(i),
      p_dists.dest_org_id_tbl(i),
      p_dists.dest_subinventory_tbl(i),
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
      p_dists.wip_entity_id_tbl(i),
      p_dists.wip_operation_seq_num_tbl(i),
      p_dists.wip_resource_seq_num_tbl(i),
      p_dists.wip_rep_schedule_id_tbl(i),
      p_dists.wip_line_id_tbl(i),
      p_dists.bom_resource_id_tbl(i),
      p_dists.budget_account_id_tbl(i),
      p_dists.accrual_account_id_tbl(i),
      p_dists.variance_account_id_tbl(i),
      p_dists.dest_charge_account_id_tbl(i),
      p_dists.dest_variance_account_id_tbl(i),
      p_dists.prevent_encumbrance_flag_tbl(i),
      NULL, -- government_context
      p_dists.dest_context_tbl(i),
      p_dists.dist_num_tbl(i),
      source_distribution_id,
	    --<<Bug#14088099 Start>>
      p_dists.request_id_tbl(i),
      p_dists.program_application_id_tbl(i),
      p_dists.program_id_tbl(i),
      p_dists.program_update_date_tbl(i),
	    --<<Bug#14088099 End>>
      p_dists.project_id_tbl(i),
      p_dists.task_id_tbl(i),
      p_dists.expenditure_type_tbl(i),
      p_dists.project_accounting_context_tbl(i),
      p_dists.expenditure_org_id_tbl(i),
      NULL, -- gl_closed_date,
      p_dists.loc_accrue_on_receipt_flag_tbl(i),
      p_dists.expenditure_item_date_tbl(i),
      p_dists.end_item_unit_number_tbl(i),
      p_dists.recovery_rate_tbl(i),
      p_dists.tax_recovery_override_flag_tbl(i),
      p_dists.award_set_id_tbl(i),  -- bug 5201306: Should insert award_set_id
      p_dists.oke_contract_line_id_tbl(i), -- PDOI Enhancement Bug#17063664
      p_dists.oke_contract_del_id_tbl(i), -- PDOI Enhancement Bug#17063664
      p_dists.amount_ordered_tbl(i),
      p_dists.loc_shipment_type_tbl(i),
      NULL, -- amount_to_encumber
      p_dists.tax_attribute_update_code_tbl(i),
      --<Bug 14610858 START> -Global attributes should be fetched from p_dists
      p_dists.global_attribute_category_tbl(i),  --<Gtas Project>
      p_dists.kanban_card_id_tbl(i), -- Bug 18599449
      p_dists.global_attribute1_tbl(i),
      p_dists.global_attribute2_tbl(i),
      p_dists.global_attribute3_tbl(i),
      p_dists.global_attribute4_tbl(i),
      p_dists.global_attribute5_tbl(i),
      p_dists.global_attribute6_tbl(i),
      p_dists.global_attribute7_tbl(i),
      p_dists.global_attribute8_tbl(i),
      p_dists.global_attribute9_tbl(i),
      p_dists.global_attribute10_tbl(i),
      p_dists.global_attribute11_tbl(i),
      p_dists.global_attribute12_tbl(i),
      p_dists.global_attribute13_tbl(i),
      p_dists.global_attribute14_tbl(i),
      p_dists.global_attribute15_tbl(i),
      p_dists.global_attribute16_tbl(i),
      p_dists.global_attribute17_tbl(i),
      p_dists.global_attribute18_tbl(i),
      p_dists.global_attribute19_tbl(i),
      p_dists.global_attribute20_tbl(i),
      --<Bug 14610858 END>
      p_dists.interface_distribution_ref_tbl(i) -- Bug 18891225
    FROM   po_distributions_interface
    WHERE  interface_distribution_id = p_dists.intf_dist_id_tbl(i)
    AND    p_dists.error_flag_tbl(i) = FND_API.g_FALSE;

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
END insert_po_dists_draft_all;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_lines_draft_all
--Function:
--  insert new line attribute values into po_lines_draft_all
--Parameters:
--IN:
--p_lines
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_lines_draft_all
(
  p_lines   IN PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_lines_draft_all';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables used to print debug message
  l_valid_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_count NUMBER := 0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;


  IF (PO_LOG.d_stmt) THEN

    FOR i IN 1..p_lines.rec_count
    LOOP
      IF (p_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
          p_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN
    PO_LOG.stmt(d_module, d_position, 'interface line id', p_lines.intf_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'po_header_id', p_lines.hd_po_header_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line_num', p_lines.line_num_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'draft_id', p_lines.draft_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'supplier_part_auxid',
                p_lines.supplier_part_auxid_tbl(i));
      END IF;
    END LOOP;
  END IF;

  d_position := 10;

  FORALL i IN 1..p_lines.rec_count
    INSERT INTO po_lines_draft_all
    (
      draft_id,
      org_id,
      delete_flag,
      change_accepted_flag,
      po_line_id,
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
      ip_category_id,
      item_description,
      unit_meas_lookup_code,
      quantity_committed,
      committed_amount,
      allow_price_override_flag,
      not_to_exceed_price,
      list_price_per_unit,
      base_unit_price,
      unit_price,
      quantity,
      un_number_id,
      hazard_class_id,
      note_to_vendor,
      from_header_id,
      from_line_id,
      contract_id, --<PDOI Enhancement Bug#17063664>
      min_order_quantity,
      max_order_quantity,
      qty_rcv_tolerance,
      over_tolerance_error_flag,
      market_price,
      unordered_flag,
      closed_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      vendor_product_num,
      contract_num,
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
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      min_release_amount,
      price_type_lookup_code,
      closed_code,
      price_break_lookup_code,
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      closed_date,
      closed_reason,
      closed_by,
      bid_number,
      bid_line_number,
      auction_header_id,
      auction_line_number,
      auction_display_number,
      transaction_reason_code,
      supplier_ref_number,
      line_reference_num,
      oke_contract_header_id,
      oke_contract_version_id,
      expiration_date,
      job_id,
      contractor_first_name,
      contractor_last_name,
      amount,
      start_date,
      order_type_lookup_code,
      purchase_basis,
      matching_basis,
      tax_attribute_update_code,
      supplier_part_auxid,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      catalog_name,
      original_interface_line_id, -- bug5149827
       -- << PDOI for Complex PO Project: Start >>
      retainage_rate,
      max_retainage_amount,
      progress_payment_rate,
      recoupment_rate
      -- << PDOI for Complex PO Project: End >>
    )
    SELECT
      p_lines.draft_id_tbl(i),
      p_lines.org_id_tbl(i),
      NULL, -- delete_flag,
      DECODE (p_lines.process_code_tbl(i),
                PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED,
                PO_DRAFTS_PVT.g_chg_accepted_flag_NOTIFY,
                NULL), -- change_accepted_flag  -- bug5149827
      p_lines.po_line_id_tbl(i),
      p_lines.last_update_date_tbl(i),
      p_lines.last_updated_by_tbl(i),
      p_lines.hd_po_header_id_tbl(i), --PDOI Ehancement Bug#17063664
      p_lines.line_type_id_tbl(i),
      p_lines.line_num_tbl(i),
      p_lines.last_update_login_tbl(i),
      p_lines.creation_date_tbl(i),
      p_lines.created_by_tbl(i),
      p_lines.item_id_tbl(i),
      p_lines.item_revision_tbl(i),
      p_lines.category_id_tbl(i),
      p_lines.ip_category_id_tbl(i),
      p_lines.item_desc_tbl(i),
      p_lines.unit_of_measure_tbl(i),
      p_lines.quantity_committed_tbl(i),
      p_lines.committed_amount_tbl(i),
      p_lines.allow_price_override_flag_tbl(i),
      p_lines.not_to_exceed_price_tbl(i),
      p_lines.list_price_per_unit_tbl(i),
      p_lines.base_unit_price_tbl(i),
      p_lines.unit_price_tbl(i),
      p_lines.quantity_tbl(i),
      p_lines.un_number_id_tbl(i),
      p_lines.hazard_class_id_tbl(i),
      p_lines.note_to_vendor_tbl(i),     -- Bug#17063664
      p_lines.from_header_id_tbl(i),
      p_lines.from_line_id_tbl(i),
      p_lines.contract_id_tbl(i), --<PDOI Enhancement Bug#17063664>
      min_order_quantity,
      max_order_quantity,
      p_lines.qty_rcv_tolerance_tbl(i), -- Bug 18891225
      p_lines.over_tolerance_err_flag_tbl(i),
      p_lines.market_price_tbl(i),
      p_lines.unordered_flag_tbl(i),
      NULL, -- closed_flag,
      p_lines.cancel_flag_tbl(i),
      NULL, -- cancelled_by,
      NULL, -- cancel_date,
      NULL, -- cancel_reason,
      p_lines.vendor_product_num_tbl(i),
      p_lines.contract_num_tbl(i),
      p_lines.type_1099_tbl(i),
      p_lines.capital_expense_flag_tbl(i),
      p_lines.negotiated_flag_tbl(i),
      line_attribute_category_lines,
      line_attribute1,
      line_attribute2,
      line_attribute3,
      line_attribute4,
      line_attribute5,
      line_attribute6,
      line_attribute7,
      line_attribute8,
      line_attribute9,
      line_attribute10,
      line_attribute11,
      line_attribute12,
      line_attribute13,
      line_attribute14,
      line_attribute15,
      p_lines.min_release_amount_tbl(i),
      p_lines.price_type_tbl(i),
      p_lines.closed_code_tbl(i),
      p_lines.price_break_lookup_code_tbl(i),
      NULL, -- government_context,
      p_lines.request_id_tbl(i),
      p_lines.program_application_id_tbl(i),
      p_lines.program_id_tbl(i),
      p_lines.program_update_date_tbl(i),
      p_lines.closed_date_tbl(i),
      closed_reason,
      p_lines.closed_by_tbl(i),
      p_lines.bid_number_tbl(i),
      p_lines.bid_line_number_tbl(i),
      p_lines.auction_header_id_tbl(i),
      p_lines.auction_line_number_tbl(i),
      p_lines.auction_display_number_tbl(i),
      p_lines.transaction_reason_code_tbl(i), -- Bug#17063664
      p_lines.supplier_ref_number_tbl(i), -- Bug#17063664
      line_reference_num,
      p_lines.oke_contract_header_id_tbl(i), -- <PDOI Enhancement Bug#17063664 >
      p_lines.oke_contract_version_id_tbl(i), --<PDOI Enhancement Bug#17063664 >
      p_lines.expiration_date_tbl(i),
      p_lines.job_id_tbl(i),
      p_lines.contractor_first_name_tbl(i),
      p_lines.contractor_last_name_tbl(i),
      p_lines.amount_tbl(i),
      DECODE(PO_PDOI_PARAMS.g_request.document_type, PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
        DECODE(p_lines.purchase_basis_tbl(i), 'TEMP LABOR', TRUNC(p_lines.effective_date_tbl(i)), NULL),
        NULL), -- bug 4181354
      p_lines.order_type_lookup_code_tbl(i),
      p_lines.purchase_basis_tbl(i),
      p_lines.matching_basis_tbl(i),
      p_lines.tax_attribute_update_code_tbl(i),
      p_lines.supplier_part_auxid_tbl(i),
      p_lines.secondary_quantity_tbl(i),
      p_lines.secondary_unit_of_meas_tbl(i),
      p_lines.preferred_grade_tbl(i),
      catalog_name,
      DECODE (p_lines.process_code_tbl(i),
                PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED,
                p_lines.intf_line_id_tbl(i),
                NULL) , -- bug5149827
      -- << PDOI for Complex PO Project: Start >>
      p_lines.retainage_rate_tbl(i),
      p_lines.max_retainage_amount_tbl(i),
      p_lines.progress_payment_rate_tbl(i),
      p_lines.recoupment_rate_tbl(i)
      -- << PDOI for Complex PO Project: End >>
    FROM   po_lines_interface
    WHERE  interface_line_id = p_lines.intf_line_id_tbl(i)
    AND    p_lines.error_flag_tbl(i) = FND_API.g_FALSE
    AND    p_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE;

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
END insert_po_lines_draft_all;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_line_locs_draft_all
--Function:
--  insert new line location attribute values into
--  po_line_locations_draft_all
--Parameters:
--IN:
--p_line_locs
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_line_locs_draft_all
(
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_line_locs_draft_all';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables used to print debug message
  l_valid_intf_loc_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_count NUMBER := 0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    FOR i IN 1..p_line_locs.rec_count
    LOOP
      IF (p_line_locs.error_flag_tbl(i) = FND_API.g_FALSE) THEN
        l_valid_intf_loc_id_tbl.EXTEND(1);
        l_count := l_count + 1;
        l_valid_intf_loc_id_tbl(l_count) :=
          p_line_locs.intf_line_loc_id_tbl(i);
      END IF;
    END LOOP;

    PO_LOG.stmt(d_module, d_position, 'intf line loc to be inserted',
                l_valid_intf_loc_id_tbl);
  END IF;

  --Bug 8565385. If unit_meas_lookup_code is null for line_locations,
  --get the value from lines_draft. When code executed to this point, the
  --lines_draft has been inserted with derived and defaulted values
  FORALL i IN 1..p_line_locs.rec_count
    INSERT INTO po_line_locations_draft_all
    (
      draft_id,
      org_id,
      delete_flag,
      change_accepted_flag,
      line_location_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      last_update_login,
      creation_date,
      created_by,
      quantity,
      quantity_received,
      quantity_accepted,
      quantity_rejected,
      quantity_billed,
      quantity_cancelled,
      unit_meas_lookup_code,
      po_release_id,
      ship_to_location_id,
      ship_via_lookup_code,
      need_by_date,
      promised_date,
      last_accept_date,
      price_override,
      encumbered_flag,
      encumbered_date,
      fob_lookup_code,
      freight_terms_lookup_code,
      tax_name,
      from_header_id,
      from_line_id,
      from_line_location_id,
      start_date,
      end_date,
      lead_time,
      lead_time_unit,
      price_discount,
      terms_id,
      approved_flag,
      closed_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      firm_status_lookup_code,
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
      inspection_required_flag,
      receipt_required_flag,
      qty_rcv_tolerance,
      qty_rcv_exception_code,
      enforce_ship_to_location_code,
      allow_substitute_receipts_flag,
      days_early_receipt_allowed,
      days_late_receipt_allowed,
      receipt_days_exception_code,
      invoice_close_tolerance,
      receive_close_tolerance,
      ship_to_organization_id,
      shipment_num,
      source_shipment_id,
      shipment_type,
      closed_code,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      government_context,
      receiving_routing_id,
      accrue_on_receipt_flag,
      closed_reason,
      closed_date,
      closed_by,
      match_option,
      note_to_receiver,
      transaction_flow_header_id,
      -- <<PDOI Enhancement Bug#17063664 Start>>
      vmi_flag,
      consigned_flag,
      drop_ship_flag,
      closed_for_invoice_date,
      -- <<PDOI Enhancement Bug#17063664 End>>
      amount,
      amount_received,
      amount_cancelled,
      amount_billed,
      outsourced_assembly,
      tax_attribute_update_code,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      value_basis,
      matching_basis,
      payment_type, -- PDOI for Complex PO Project
      description -- PDOI for Complex PO Project

    )
    SELECT
      p_line_locs.draft_id_tbl(i),
      PO_PDOI_PARAMS.g_request.org_id,
      NULL, -- delete_flag,
      NULL, -- change_accepted_flag,
      p_line_locs.line_loc_id_tbl(i),
      p_line_locs.last_update_date_tbl(i),
      p_line_locs.last_updated_by_tbl(i),
      p_line_locs.hd_po_header_id_tbl(i),
      p_line_locs.ln_po_line_id_tbl(i),
      p_line_locs.last_update_login_tbl(i),
      p_line_locs.creation_date_tbl(i),
      p_line_locs.created_by_tbl(i),
      p_line_locs.quantity_tbl(i),
      0, -- quantity_received
      0, -- quantity_accepted
      0, -- quantity_rejected
      0, -- quantity_billed
      0, -- quantity_canceled
      NVL(p_line_locs.unit_of_measure_tbl(i),
          (select unit_meas_lookup_code from po_lines_draft_all
           where po_line_id = p_line_locs.ln_po_line_id_tbl(i) --8565385
	   AND draft_id = p_line_locs.draft_id_tbl(i))), --Bug 12980629
      NULL, -- po_release_id,
      p_line_locs.ship_to_loc_id_tbl(i),
      p_line_locs.freight_carrier_tbl(i),
      p_line_locs.need_by_date_tbl(i),
      p_line_locs.promised_date_tbl(i),
      Decode(p_line_locs.promised_date_tbl(i), NULL,NULL,
trunc(p_line_locs.promised_date_tbl(i)+Nvl(p_line_locs.days_late_receipt_allowed_tbl(i),0))), -- 9650712 fix NULL, -- last_accept_date,
      p_line_locs.price_override_tbl(i),
      'N', -- encumbered_flag,
      NULL, -- encumbered_date,
      p_line_locs.fob_tbl(i),
      p_line_locs.freight_term_tbl(i),
      p_line_locs.tax_name_tbl(i),
      p_line_locs.ln_from_header_id_tbl(i),
      p_line_locs.ln_from_line_id_tbl(i),
      from_line_location_id,
      p_line_locs.start_date_tbl(i),
      p_line_locs.end_date_tbl(i),
      p_line_locs.lead_time_tbl(i),
      lead_time_unit,
      p_line_locs.price_discount_tbl(i),
      p_line_locs.terms_id_tbl(i),
      p_line_locs.hd_approved_flag_tbl(i),
      NULL, -- closed_flag,
      NULL, -- cancel_flag,
      NULL, -- cancelled_by,
      NULL, -- cancel_date,
      NULL, -- cancel_reason,
      p_line_locs.firm_flag_tbl(i),
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
      p_line_locs.inspection_required_flag_tbl(i),
      p_line_locs.receipt_required_flag_tbl(i),
      p_line_locs.qty_rcv_tolerance_tbl(i),
      p_line_locs.qty_rcv_exception_code_tbl(i),
      p_line_locs.enforce_ship_to_loc_code_tbl(i),
      p_line_locs.allow_sub_receipts_flag_tbl(i),
      p_line_locs.days_early_receipt_allowed_tbl(i),
      p_line_locs.days_late_receipt_allowed_tbl(i),
      p_line_locs.receipt_days_except_code_tbl(i),
      p_line_locs.invoice_close_tolerance_tbl(i),
      p_line_locs.receive_close_tolerance_tbl(i),
      p_line_locs.ship_to_org_id_tbl(i),
      p_line_locs.shipment_num_tbl(i),
      source_shipment_id,
      p_line_locs.shipment_type_tbl(i),
      p_line_locs.ln_closed_code_tbl(i),
      p_line_locs.request_id_tbl(i),
      p_line_locs.program_application_id_tbl(i),
      p_line_locs.program_id_tbl(i),
      p_line_locs.program_update_date_tbl(i),
      p_line_locs.ln_government_context_tbl(i),
      p_line_locs.receiving_routing_id_tbl(i),
      NVL2(p_line_locs.txn_flow_header_id_tbl(i), 'Y',
        p_line_locs.accrue_on_receipt_flag_tbl(i)),
      p_line_locs.ln_closed_reason_tbl(i),
      p_line_locs.ln_closed_date_tbl(i),
      p_line_locs.ln_closed_by_tbl(i),
      p_line_locs.match_option_tbl(i),
      p_line_locs.note_to_receiver_tbl(i),
      p_line_locs.txn_flow_header_id_tbl(i),
      -- <<PDOI Enhancement Bug#17063664 Start>>
      p_line_locs.vmi_flag_tbl(i),
      p_line_locs.consigned_flag_tbl(i),
      p_line_locs.drop_ship_flag_tbl(i),
      DECODE(p_line_locs.consigned_flag_tbl(i), 'Y', SYSDATE, NULL),
      -- <<PDOI Enhancement Bug#17063664 End>>
      amount,
      0, -- amount_received,
      0, -- amount_cancelled,
      0, -- amount_billed,
      p_line_locs.outsourced_assembly_tbl(i),
      p_line_locs.tax_attribute_update_code_tbl(i),
      p_line_locs.secondary_quantity_tbl(i),
      p_line_locs.secondary_unit_of_meas_tbl(i),
      p_line_locs.preferred_grade_tbl(i),
      p_line_locs.value_basis_tbl(i),
      p_line_locs.matching_basis_tbl(i),
      p_line_locs.payment_type_tbl(i), -- PDOI for Complex PO Project
      p_line_locs.ln_item_desc_tbl(i) -- PDOI for Complex PO Project
    FROM   po_line_locations_interface
    WHERE  interface_line_location_id = p_line_locs.intf_line_loc_id_tbl(i)
    AND    p_line_locs.error_flag_tbl(i) = FND_API.g_FALSE;

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
END insert_po_line_locs_draft_all;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_po_price_diffs_draft
--Function:
--  insert new price differential attribute values into
--  po_price_diff_draft
--Parameters:
--IN:
--p_price_diffs
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_po_price_diff_draft
(
  p_price_diffs   IN PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_po_price_diff_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables used to print debug message
  l_valid_intf_diff_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_count NUMBER := 0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    FOR i IN 1..p_price_diffs.rec_count
    LOOP
      IF (p_price_diffs.error_flag_tbl(i) = FND_API.g_FALSE) THEN
        l_valid_intf_diff_id_tbl.EXTEND(1);
        l_count := l_count + 1;
        l_valid_intf_diff_id_tbl(l_count) :=
          p_price_diffs.intf_price_diff_id_tbl(i);
      END IF;
    END LOOP;

    PO_LOG.stmt(d_module, d_position, 'intf price diff to be inserted',
                l_valid_intf_diff_id_tbl);
  END IF;

  FORALL i IN 1..p_price_diffs.rec_count
    INSERT INTO po_price_diff_draft
    (
      draft_id,
      delete_flag,
      change_accepted_flag,
      price_differential_id,
      price_differential_num,
      entity_type,
      entity_id,
      price_type,
      enabled_flag,
      min_multiplier,
      max_multiplier,
      multiplier,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by
    )
    SELECT
      p_price_diffs.draft_id_tbl(i),
      NULL, -- delete_flag,
      NULL, -- change_accepted_flag,
      PO_PRICE_DIFFERENTIALS_S.nextval,
      p_price_diffs.price_diff_num_tbl(i),
      p_price_diffs.entity_type_tbl(i),
      p_price_diffs.entity_id_tbl(i),
      p_price_diffs.price_type_tbl(i),
      enabled_flag,
      p_price_diffs.min_multiplier_tbl(i),
      p_price_diffs.max_multiplier_tbl(i),
      p_price_diffs.multiplier_tbl(i),
      NVL(last_update_date, sysdate),
      NVL(last_updated_by, FND_GLOBAL.user_id),
      NVL(last_update_login, FND_GLOBAL.login_id),
      NVL(creation_date, sysdate),
      NVL(created_by, FND_GLOBAL.user_id)
    FROM   po_price_diff_interface
    WHERE  price_diff_interface_id = p_price_diffs.intf_price_diff_id_tbl(i)
    AND    p_price_diffs.error_flag_tbl(i) = FND_API.g_FALSE;

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
END insert_po_price_diff_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_po_attr_values_draft
--Function:
--  insert new attribute values or update existing attribute values
--  into po_attribute_values_draft
--Parameters:
--IN:
--p_key
--  key value used to join in MERGE statement
--p_attr_values
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_po_attr_values_draft
(
  p_key                IN po_session_gt.key%TYPE,
  p_attr_values        IN PO_PDOI_TYPES.attr_values_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'merge_po_attr_values_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  MERGE INTO po_attribute_values_draft PAVD
  USING (
    SELECT
      NUM2 AS ATTRIBUTE_VALUES_ID,
      NUM3 AS DRAFT_ID,
      NUM4 AS PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      NUM5 AS IP_CATEGORY_ID,
      NUM6 AS INVENTORY_ITEM_ID,
      ORG_ID,
      MANUFACTURER_PART_NUM,
      THUMBNAIL_IMAGE,
      SUPPLIER_URL,
      MANUFACTURER_URL,
      ATTACHMENT_URL,
      UNSPSC,
      AVAILABILITY,
      NUM7 AS LEAD_TIME,
      TEXT_BASE_ATTRIBUTE1,
      TEXT_BASE_ATTRIBUTE2,
      TEXT_BASE_ATTRIBUTE3,
      TEXT_BASE_ATTRIBUTE4,
      TEXT_BASE_ATTRIBUTE5,
      TEXT_BASE_ATTRIBUTE6,
      TEXT_BASE_ATTRIBUTE7,
      TEXT_BASE_ATTRIBUTE8,
      TEXT_BASE_ATTRIBUTE9,
      TEXT_BASE_ATTRIBUTE10,
      TEXT_BASE_ATTRIBUTE11,
      TEXT_BASE_ATTRIBUTE12,
      TEXT_BASE_ATTRIBUTE13,
      TEXT_BASE_ATTRIBUTE14,
      TEXT_BASE_ATTRIBUTE15,
      TEXT_BASE_ATTRIBUTE16,
      TEXT_BASE_ATTRIBUTE17,
      TEXT_BASE_ATTRIBUTE18,
      TEXT_BASE_ATTRIBUTE19,
      TEXT_BASE_ATTRIBUTE20,
      TEXT_BASE_ATTRIBUTE21,
      TEXT_BASE_ATTRIBUTE22,
      TEXT_BASE_ATTRIBUTE23,
      TEXT_BASE_ATTRIBUTE24,
      TEXT_BASE_ATTRIBUTE25,
      TEXT_BASE_ATTRIBUTE26,
      TEXT_BASE_ATTRIBUTE27,
      TEXT_BASE_ATTRIBUTE28,
      TEXT_BASE_ATTRIBUTE29,
      TEXT_BASE_ATTRIBUTE30,
      TEXT_BASE_ATTRIBUTE31,
      TEXT_BASE_ATTRIBUTE32,
      TEXT_BASE_ATTRIBUTE33,
      TEXT_BASE_ATTRIBUTE34,
      TEXT_BASE_ATTRIBUTE35,
      TEXT_BASE_ATTRIBUTE36,
      TEXT_BASE_ATTRIBUTE37,
      TEXT_BASE_ATTRIBUTE38,
      TEXT_BASE_ATTRIBUTE39,
      TEXT_BASE_ATTRIBUTE40,
      TEXT_BASE_ATTRIBUTE41,
      TEXT_BASE_ATTRIBUTE42,
      TEXT_BASE_ATTRIBUTE43,
      TEXT_BASE_ATTRIBUTE44,
      TEXT_BASE_ATTRIBUTE45,
      TEXT_BASE_ATTRIBUTE46,
      TEXT_BASE_ATTRIBUTE47,
      TEXT_BASE_ATTRIBUTE48,
      TEXT_BASE_ATTRIBUTE49,
      TEXT_BASE_ATTRIBUTE50,
      TEXT_BASE_ATTRIBUTE51,
      TEXT_BASE_ATTRIBUTE52,
      TEXT_BASE_ATTRIBUTE53,
      TEXT_BASE_ATTRIBUTE54,
      TEXT_BASE_ATTRIBUTE55,
      TEXT_BASE_ATTRIBUTE56,
      TEXT_BASE_ATTRIBUTE57,
      TEXT_BASE_ATTRIBUTE58,
      TEXT_BASE_ATTRIBUTE59,
      TEXT_BASE_ATTRIBUTE60,
      TEXT_BASE_ATTRIBUTE61,
      TEXT_BASE_ATTRIBUTE62,
      TEXT_BASE_ATTRIBUTE63,
      TEXT_BASE_ATTRIBUTE64,
      TEXT_BASE_ATTRIBUTE65,
      TEXT_BASE_ATTRIBUTE66,
      TEXT_BASE_ATTRIBUTE67,
      TEXT_BASE_ATTRIBUTE68,
      TEXT_BASE_ATTRIBUTE69,
      TEXT_BASE_ATTRIBUTE70,
      TEXT_BASE_ATTRIBUTE71,
      TEXT_BASE_ATTRIBUTE72,
      TEXT_BASE_ATTRIBUTE73,
      TEXT_BASE_ATTRIBUTE74,
      TEXT_BASE_ATTRIBUTE75,
      TEXT_BASE_ATTRIBUTE76,
      TEXT_BASE_ATTRIBUTE77,
      TEXT_BASE_ATTRIBUTE78,
      TEXT_BASE_ATTRIBUTE79,
      TEXT_BASE_ATTRIBUTE80,
      TEXT_BASE_ATTRIBUTE81,
      TEXT_BASE_ATTRIBUTE82,
      TEXT_BASE_ATTRIBUTE83,
      TEXT_BASE_ATTRIBUTE84,
      TEXT_BASE_ATTRIBUTE85,
      TEXT_BASE_ATTRIBUTE86,
      TEXT_BASE_ATTRIBUTE87,
      TEXT_BASE_ATTRIBUTE88,
      TEXT_BASE_ATTRIBUTE89,
      TEXT_BASE_ATTRIBUTE90,
      TEXT_BASE_ATTRIBUTE91,
      TEXT_BASE_ATTRIBUTE92,
      TEXT_BASE_ATTRIBUTE93,
      TEXT_BASE_ATTRIBUTE94,
      TEXT_BASE_ATTRIBUTE95,
      TEXT_BASE_ATTRIBUTE96,
      TEXT_BASE_ATTRIBUTE97,
      TEXT_BASE_ATTRIBUTE98,
      TEXT_BASE_ATTRIBUTE99,
      TEXT_BASE_ATTRIBUTE100,
      NUM_BASE_ATTRIBUTE1,
      NUM_BASE_ATTRIBUTE2,
      NUM_BASE_ATTRIBUTE3,
      NUM_BASE_ATTRIBUTE4,
      NUM_BASE_ATTRIBUTE5,
      NUM_BASE_ATTRIBUTE6,
      NUM_BASE_ATTRIBUTE7,
      NUM_BASE_ATTRIBUTE8,
      NUM_BASE_ATTRIBUTE9,
      NUM_BASE_ATTRIBUTE10,
      NUM_BASE_ATTRIBUTE11,
      NUM_BASE_ATTRIBUTE12,
      NUM_BASE_ATTRIBUTE13,
      NUM_BASE_ATTRIBUTE14,
      NUM_BASE_ATTRIBUTE15,
      NUM_BASE_ATTRIBUTE16,
      NUM_BASE_ATTRIBUTE17,
      NUM_BASE_ATTRIBUTE18,
      NUM_BASE_ATTRIBUTE19,
      NUM_BASE_ATTRIBUTE20,
      NUM_BASE_ATTRIBUTE21,
      NUM_BASE_ATTRIBUTE22,
      NUM_BASE_ATTRIBUTE23,
      NUM_BASE_ATTRIBUTE24,
      NUM_BASE_ATTRIBUTE25,
      NUM_BASE_ATTRIBUTE26,
      NUM_BASE_ATTRIBUTE27,
      NUM_BASE_ATTRIBUTE28,
      NUM_BASE_ATTRIBUTE29,
      NUM_BASE_ATTRIBUTE30,
      NUM_BASE_ATTRIBUTE31,
      NUM_BASE_ATTRIBUTE32,
      NUM_BASE_ATTRIBUTE33,
      NUM_BASE_ATTRIBUTE34,
      NUM_BASE_ATTRIBUTE35,
      NUM_BASE_ATTRIBUTE36,
      NUM_BASE_ATTRIBUTE37,
      NUM_BASE_ATTRIBUTE38,
      NUM_BASE_ATTRIBUTE39,
      NUM_BASE_ATTRIBUTE40,
      NUM_BASE_ATTRIBUTE41,
      NUM_BASE_ATTRIBUTE42,
      NUM_BASE_ATTRIBUTE43,
      NUM_BASE_ATTRIBUTE44,
      NUM_BASE_ATTRIBUTE45,
      NUM_BASE_ATTRIBUTE46,
      NUM_BASE_ATTRIBUTE47,
      NUM_BASE_ATTRIBUTE48,
      NUM_BASE_ATTRIBUTE49,
      NUM_BASE_ATTRIBUTE50,
      NUM_BASE_ATTRIBUTE51,
      NUM_BASE_ATTRIBUTE52,
      NUM_BASE_ATTRIBUTE53,
      NUM_BASE_ATTRIBUTE54,
      NUM_BASE_ATTRIBUTE55,
      NUM_BASE_ATTRIBUTE56,
      NUM_BASE_ATTRIBUTE57,
      NUM_BASE_ATTRIBUTE58,
      NUM_BASE_ATTRIBUTE59,
      NUM_BASE_ATTRIBUTE60,
      NUM_BASE_ATTRIBUTE61,
      NUM_BASE_ATTRIBUTE62,
      NUM_BASE_ATTRIBUTE63,
      NUM_BASE_ATTRIBUTE64,
      NUM_BASE_ATTRIBUTE65,
      NUM_BASE_ATTRIBUTE66,
      NUM_BASE_ATTRIBUTE67,
      NUM_BASE_ATTRIBUTE68,
      NUM_BASE_ATTRIBUTE69,
      NUM_BASE_ATTRIBUTE70,
      NUM_BASE_ATTRIBUTE71,
      NUM_BASE_ATTRIBUTE72,
      NUM_BASE_ATTRIBUTE73,
      NUM_BASE_ATTRIBUTE74,
      NUM_BASE_ATTRIBUTE75,
      NUM_BASE_ATTRIBUTE76,
      NUM_BASE_ATTRIBUTE77,
      NUM_BASE_ATTRIBUTE78,
      NUM_BASE_ATTRIBUTE79,
      NUM_BASE_ATTRIBUTE80,
      NUM_BASE_ATTRIBUTE81,
      NUM_BASE_ATTRIBUTE82,
      NUM_BASE_ATTRIBUTE83,
      NUM_BASE_ATTRIBUTE84,
      NUM_BASE_ATTRIBUTE85,
      NUM_BASE_ATTRIBUTE86,
      NUM_BASE_ATTRIBUTE87,
      NUM_BASE_ATTRIBUTE88,
      NUM_BASE_ATTRIBUTE89,
      NUM_BASE_ATTRIBUTE90,
      NUM_BASE_ATTRIBUTE91,
      NUM_BASE_ATTRIBUTE92,
      NUM_BASE_ATTRIBUTE93,
      NUM_BASE_ATTRIBUTE94,
      NUM_BASE_ATTRIBUTE95,
      NUM_BASE_ATTRIBUTE96,
      NUM_BASE_ATTRIBUTE97,
      NUM_BASE_ATTRIBUTE98,
      NUM_BASE_ATTRIBUTE99,
      NUM_BASE_ATTRIBUTE100,
      TEXT_CAT_ATTRIBUTE1,
      TEXT_CAT_ATTRIBUTE2,
      TEXT_CAT_ATTRIBUTE3,
      TEXT_CAT_ATTRIBUTE4,
      TEXT_CAT_ATTRIBUTE5,
      TEXT_CAT_ATTRIBUTE6,
      TEXT_CAT_ATTRIBUTE7,
      TEXT_CAT_ATTRIBUTE8,
      TEXT_CAT_ATTRIBUTE9,
      TEXT_CAT_ATTRIBUTE10,
      TEXT_CAT_ATTRIBUTE11,
      TEXT_CAT_ATTRIBUTE12,
      TEXT_CAT_ATTRIBUTE13,
      TEXT_CAT_ATTRIBUTE14,
      TEXT_CAT_ATTRIBUTE15,
      TEXT_CAT_ATTRIBUTE16,
      TEXT_CAT_ATTRIBUTE17,
      TEXT_CAT_ATTRIBUTE18,
      TEXT_CAT_ATTRIBUTE19,
      TEXT_CAT_ATTRIBUTE20,
      TEXT_CAT_ATTRIBUTE21,
      TEXT_CAT_ATTRIBUTE22,
      TEXT_CAT_ATTRIBUTE23,
      TEXT_CAT_ATTRIBUTE24,
      TEXT_CAT_ATTRIBUTE25,
      TEXT_CAT_ATTRIBUTE26,
      TEXT_CAT_ATTRIBUTE27,
      TEXT_CAT_ATTRIBUTE28,
      TEXT_CAT_ATTRIBUTE29,
      TEXT_CAT_ATTRIBUTE30,
      TEXT_CAT_ATTRIBUTE31,
      TEXT_CAT_ATTRIBUTE32,
      TEXT_CAT_ATTRIBUTE33,
      TEXT_CAT_ATTRIBUTE34,
      TEXT_CAT_ATTRIBUTE35,
      TEXT_CAT_ATTRIBUTE36,
      TEXT_CAT_ATTRIBUTE37,
      TEXT_CAT_ATTRIBUTE38,
      TEXT_CAT_ATTRIBUTE39,
      TEXT_CAT_ATTRIBUTE40,
      TEXT_CAT_ATTRIBUTE41,
      TEXT_CAT_ATTRIBUTE42,
      TEXT_CAT_ATTRIBUTE43,
      TEXT_CAT_ATTRIBUTE44,
      TEXT_CAT_ATTRIBUTE45,
      TEXT_CAT_ATTRIBUTE46,
      TEXT_CAT_ATTRIBUTE47,
      TEXT_CAT_ATTRIBUTE48,
      TEXT_CAT_ATTRIBUTE49,
      TEXT_CAT_ATTRIBUTE50,
      NUM_CAT_ATTRIBUTE1,
      NUM_CAT_ATTRIBUTE2,
      NUM_CAT_ATTRIBUTE3,
      NUM_CAT_ATTRIBUTE4,
      NUM_CAT_ATTRIBUTE5,
      NUM_CAT_ATTRIBUTE6,
      NUM_CAT_ATTRIBUTE7,
      NUM_CAT_ATTRIBUTE8,
      NUM_CAT_ATTRIBUTE9,
      NUM_CAT_ATTRIBUTE10,
      NUM_CAT_ATTRIBUTE11,
      NUM_CAT_ATTRIBUTE12,
      NUM_CAT_ATTRIBUTE13,
      NUM_CAT_ATTRIBUTE14,
      NUM_CAT_ATTRIBUTE15,
      NUM_CAT_ATTRIBUTE16,
      NUM_CAT_ATTRIBUTE17,
      NUM_CAT_ATTRIBUTE18,
      NUM_CAT_ATTRIBUTE19,
      NUM_CAT_ATTRIBUTE20,
      NUM_CAT_ATTRIBUTE21,
      NUM_CAT_ATTRIBUTE22,
      NUM_CAT_ATTRIBUTE23,
      NUM_CAT_ATTRIBUTE24,
      NUM_CAT_ATTRIBUTE25,
      NUM_CAT_ATTRIBUTE26,
      NUM_CAT_ATTRIBUTE27,
      NUM_CAT_ATTRIBUTE28,
      NUM_CAT_ATTRIBUTE29,
      NUM_CAT_ATTRIBUTE30,
      NUM_CAT_ATTRIBUTE31,
      NUM_CAT_ATTRIBUTE32,
      NUM_CAT_ATTRIBUTE33,
      NUM_CAT_ATTRIBUTE34,
      NUM_CAT_ATTRIBUTE35,
      NUM_CAT_ATTRIBUTE36,
      NUM_CAT_ATTRIBUTE37,
      NUM_CAT_ATTRIBUTE38,
      NUM_CAT_ATTRIBUTE39,
      NUM_CAT_ATTRIBUTE40,
      NUM_CAT_ATTRIBUTE41,
      NUM_CAT_ATTRIBUTE42,
      NUM_CAT_ATTRIBUTE43,
      NUM_CAT_ATTRIBUTE44,
      NUM_CAT_ATTRIBUTE45,
      NUM_CAT_ATTRIBUTE46,
      NUM_CAT_ATTRIBUTE47,
      NUM_CAT_ATTRIBUTE48,
      NUM_CAT_ATTRIBUTE49,
      NUM_CAT_ATTRIBUTE50,

      -- Bug 4731494: Make WHO columns not-null in Attr/TLP tables
      NVL(LAST_UPDATE_LOGIN, FND_GLOBAL.login_id) AS LAST_UPDATE_LOGIN,
      NVL(LAST_UPDATED_BY, FND_GLOBAL.user_id) AS LAST_UPDATED_BY,
      NVL(LAST_UPDATE_DATE, sysdate) AS LAST_UPDATE_DATE,
      NVL(CREATED_BY, FND_GLOBAL.user_id) AS CREATED_BY,
      NVL(CREATION_DATE, sysdate) AS CREATION_DATE,

      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      PICTURE
    FROM   po_attr_values_interface intf_attrs,
           po_session_gt gt
    WHERE  intf_attrs.interface_attr_values_id = gt.num1
    AND    gt.key = p_key) PAVI
  ON (PAVD.attribute_values_id = PAVI.attribute_values_id
      AND PAVD.draft_id = PAVI.draft_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      CHANGE_ACCEPTED_FLAG = NULL,
      DELETE_FLAG = NULL,
      IP_CATEGORY_ID = NVL(PAVI.IP_CATEGORY_ID, PAVD.IP_CATEGORY_ID),
      MANUFACTURER_PART_NUM = DECODE(PAVI.MANUFACTURER_PART_NUM, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.MANUFACTURER_PART_NUM, PAVI.MANUFACTURER_PART_NUM),
      THUMBNAIL_IMAGE = DECODE(PAVI.THUMBNAIL_IMAGE, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.THUMBNAIL_IMAGE, PAVI.THUMBNAIL_IMAGE),
      SUPPLIER_URL = DECODE(PAVI.SUPPLIER_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.SUPPLIER_URL, PAVI.SUPPLIER_URL),
      MANUFACTURER_URL = DECODE(PAVI.MANUFACTURER_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.MANUFACTURER_URL, PAVI.MANUFACTURER_URL),
      ATTACHMENT_URL = DECODE(PAVI.ATTACHMENT_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.ATTACHMENT_URL, PAVI.ATTACHMENT_URL),
      UNSPSC = DECODE(PAVI.UNSPSC, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.UNSPSC, PAVI.UNSPSC),
      AVAILABILITY = DECODE(PAVI.AVAILABILITY, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.AVAILABILITY, PAVI.AVAILABILITY),
      LEAD_TIME = DECODE(PAVI.LEAD_TIME, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.LEAD_TIME, PAVI.LEAD_TIME),
      TEXT_BASE_ATTRIBUTE1 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE1, PAVI.TEXT_BASE_ATTRIBUTE1),
      TEXT_BASE_ATTRIBUTE2 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE2, PAVI.TEXT_BASE_ATTRIBUTE2),
      TEXT_BASE_ATTRIBUTE3 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE3, PAVI.TEXT_BASE_ATTRIBUTE3),
      TEXT_BASE_ATTRIBUTE4 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE4, PAVI.TEXT_BASE_ATTRIBUTE4),
      TEXT_BASE_ATTRIBUTE5 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE5, PAVI.TEXT_BASE_ATTRIBUTE5),
      TEXT_BASE_ATTRIBUTE6 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE6, PAVI.TEXT_BASE_ATTRIBUTE6),
      TEXT_BASE_ATTRIBUTE7 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE7, PAVI.TEXT_BASE_ATTRIBUTE7),
      TEXT_BASE_ATTRIBUTE8 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE8, PAVI.TEXT_BASE_ATTRIBUTE8),
      TEXT_BASE_ATTRIBUTE9 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE9, PAVI.TEXT_BASE_ATTRIBUTE9),
      TEXT_BASE_ATTRIBUTE10 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE10, PAVI.TEXT_BASE_ATTRIBUTE10),
      TEXT_BASE_ATTRIBUTE11 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE11, PAVI.TEXT_BASE_ATTRIBUTE11),
      TEXT_BASE_ATTRIBUTE12 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE12, PAVI.TEXT_BASE_ATTRIBUTE12),
      TEXT_BASE_ATTRIBUTE13 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE13, PAVI.TEXT_BASE_ATTRIBUTE13),
      TEXT_BASE_ATTRIBUTE14 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE14, PAVI.TEXT_BASE_ATTRIBUTE14),
      TEXT_BASE_ATTRIBUTE15 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE15, PAVI.TEXT_BASE_ATTRIBUTE15),
      TEXT_BASE_ATTRIBUTE16 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE16, PAVI.TEXT_BASE_ATTRIBUTE16),
      TEXT_BASE_ATTRIBUTE17 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE17, PAVI.TEXT_BASE_ATTRIBUTE17),
      TEXT_BASE_ATTRIBUTE18 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE18, PAVI.TEXT_BASE_ATTRIBUTE18),
      TEXT_BASE_ATTRIBUTE19 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE19, PAVI.TEXT_BASE_ATTRIBUTE19),
      TEXT_BASE_ATTRIBUTE20 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE20, PAVI.TEXT_BASE_ATTRIBUTE20),
      TEXT_BASE_ATTRIBUTE21 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE21, PAVI.TEXT_BASE_ATTRIBUTE21),
      TEXT_BASE_ATTRIBUTE22 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE22, PAVI.TEXT_BASE_ATTRIBUTE22),
      TEXT_BASE_ATTRIBUTE23 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE23, PAVI.TEXT_BASE_ATTRIBUTE23),
      TEXT_BASE_ATTRIBUTE24 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE24, PAVI.TEXT_BASE_ATTRIBUTE24),
      TEXT_BASE_ATTRIBUTE25 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE25, PAVI.TEXT_BASE_ATTRIBUTE25),
      TEXT_BASE_ATTRIBUTE26 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE26, PAVI.TEXT_BASE_ATTRIBUTE26),
      TEXT_BASE_ATTRIBUTE27 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE27, PAVI.TEXT_BASE_ATTRIBUTE27),
      TEXT_BASE_ATTRIBUTE28 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE28, PAVI.TEXT_BASE_ATTRIBUTE28),
      TEXT_BASE_ATTRIBUTE29 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE29, PAVI.TEXT_BASE_ATTRIBUTE29),
      TEXT_BASE_ATTRIBUTE30 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE30, PAVI.TEXT_BASE_ATTRIBUTE30),
      TEXT_BASE_ATTRIBUTE31 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE31, PAVI.TEXT_BASE_ATTRIBUTE31),
      TEXT_BASE_ATTRIBUTE32 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE32, PAVI.TEXT_BASE_ATTRIBUTE32),
      TEXT_BASE_ATTRIBUTE33 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE33, PAVI.TEXT_BASE_ATTRIBUTE33),
      TEXT_BASE_ATTRIBUTE34 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE34, PAVI.TEXT_BASE_ATTRIBUTE34),
      TEXT_BASE_ATTRIBUTE35 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE35, PAVI.TEXT_BASE_ATTRIBUTE35),
      TEXT_BASE_ATTRIBUTE36 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE36, PAVI.TEXT_BASE_ATTRIBUTE36),
      TEXT_BASE_ATTRIBUTE37 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE37, PAVI.TEXT_BASE_ATTRIBUTE37),
      TEXT_BASE_ATTRIBUTE38 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE38, PAVI.TEXT_BASE_ATTRIBUTE38),
      TEXT_BASE_ATTRIBUTE39 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE39, PAVI.TEXT_BASE_ATTRIBUTE39),
      TEXT_BASE_ATTRIBUTE40 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE40, PAVI.TEXT_BASE_ATTRIBUTE40),
      TEXT_BASE_ATTRIBUTE41 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE41, PAVI.TEXT_BASE_ATTRIBUTE41),
      TEXT_BASE_ATTRIBUTE42 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE42, PAVI.TEXT_BASE_ATTRIBUTE42),
      TEXT_BASE_ATTRIBUTE43 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE43, PAVI.TEXT_BASE_ATTRIBUTE43),
      TEXT_BASE_ATTRIBUTE44 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE44, PAVI.TEXT_BASE_ATTRIBUTE44),
      TEXT_BASE_ATTRIBUTE45 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE45, PAVI.TEXT_BASE_ATTRIBUTE45),
      TEXT_BASE_ATTRIBUTE46 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE46, PAVI.TEXT_BASE_ATTRIBUTE46),
      TEXT_BASE_ATTRIBUTE47 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE47, PAVI.TEXT_BASE_ATTRIBUTE47),
      TEXT_BASE_ATTRIBUTE48 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE48, PAVI.TEXT_BASE_ATTRIBUTE48),
      TEXT_BASE_ATTRIBUTE49 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE49, PAVI.TEXT_BASE_ATTRIBUTE49),
      TEXT_BASE_ATTRIBUTE50 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE50, PAVI.TEXT_BASE_ATTRIBUTE50),
      TEXT_BASE_ATTRIBUTE51 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE51, PAVI.TEXT_BASE_ATTRIBUTE51),
      TEXT_BASE_ATTRIBUTE52 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE52, PAVI.TEXT_BASE_ATTRIBUTE52),
      TEXT_BASE_ATTRIBUTE53 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE53, PAVI.TEXT_BASE_ATTRIBUTE53),
      TEXT_BASE_ATTRIBUTE54 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE54, PAVI.TEXT_BASE_ATTRIBUTE54),
      TEXT_BASE_ATTRIBUTE55 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE55, PAVI.TEXT_BASE_ATTRIBUTE55),
      TEXT_BASE_ATTRIBUTE56 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE56, PAVI.TEXT_BASE_ATTRIBUTE56),
      TEXT_BASE_ATTRIBUTE57 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE57, PAVI.TEXT_BASE_ATTRIBUTE57),
      TEXT_BASE_ATTRIBUTE58 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE58, PAVI.TEXT_BASE_ATTRIBUTE58),
      TEXT_BASE_ATTRIBUTE59 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE59, PAVI.TEXT_BASE_ATTRIBUTE59),
      TEXT_BASE_ATTRIBUTE60 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE60, PAVI.TEXT_BASE_ATTRIBUTE60),
      TEXT_BASE_ATTRIBUTE61 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE61, PAVI.TEXT_BASE_ATTRIBUTE61),
      TEXT_BASE_ATTRIBUTE62 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE62, PAVI.TEXT_BASE_ATTRIBUTE62),
      TEXT_BASE_ATTRIBUTE63 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE63, PAVI.TEXT_BASE_ATTRIBUTE63),
      TEXT_BASE_ATTRIBUTE64 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE64, PAVI.TEXT_BASE_ATTRIBUTE64),
      TEXT_BASE_ATTRIBUTE65 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE65, PAVI.TEXT_BASE_ATTRIBUTE65),
      TEXT_BASE_ATTRIBUTE66 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE66, PAVI.TEXT_BASE_ATTRIBUTE66),
      TEXT_BASE_ATTRIBUTE67 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE67, PAVI.TEXT_BASE_ATTRIBUTE67),
      TEXT_BASE_ATTRIBUTE68 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE68, PAVI.TEXT_BASE_ATTRIBUTE68),
      TEXT_BASE_ATTRIBUTE69 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE69, PAVI.TEXT_BASE_ATTRIBUTE69),
      TEXT_BASE_ATTRIBUTE70 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE70, PAVI.TEXT_BASE_ATTRIBUTE70),
      TEXT_BASE_ATTRIBUTE71 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE71, PAVI.TEXT_BASE_ATTRIBUTE71),
      TEXT_BASE_ATTRIBUTE72 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE72, PAVI.TEXT_BASE_ATTRIBUTE72),
      TEXT_BASE_ATTRIBUTE73 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE73, PAVI.TEXT_BASE_ATTRIBUTE73),
      TEXT_BASE_ATTRIBUTE74 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE74, PAVI.TEXT_BASE_ATTRIBUTE74),
      TEXT_BASE_ATTRIBUTE75 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE75, PAVI.TEXT_BASE_ATTRIBUTE75),
      TEXT_BASE_ATTRIBUTE76 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE76, PAVI.TEXT_BASE_ATTRIBUTE76),
      TEXT_BASE_ATTRIBUTE77 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE77, PAVI.TEXT_BASE_ATTRIBUTE77),
      TEXT_BASE_ATTRIBUTE78 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE78, PAVI.TEXT_BASE_ATTRIBUTE78),
      TEXT_BASE_ATTRIBUTE79 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE79, PAVI.TEXT_BASE_ATTRIBUTE79),
      TEXT_BASE_ATTRIBUTE80 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE80, PAVI.TEXT_BASE_ATTRIBUTE80),
      TEXT_BASE_ATTRIBUTE81 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE81, PAVI.TEXT_BASE_ATTRIBUTE81),
      TEXT_BASE_ATTRIBUTE82 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE82, PAVI.TEXT_BASE_ATTRIBUTE82),
      TEXT_BASE_ATTRIBUTE83 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE83, PAVI.TEXT_BASE_ATTRIBUTE83),
      TEXT_BASE_ATTRIBUTE84 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE84, PAVI.TEXT_BASE_ATTRIBUTE84),
      TEXT_BASE_ATTRIBUTE85 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE85, PAVI.TEXT_BASE_ATTRIBUTE85),
      TEXT_BASE_ATTRIBUTE86 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE86, PAVI.TEXT_BASE_ATTRIBUTE86),
      TEXT_BASE_ATTRIBUTE87 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE87, PAVI.TEXT_BASE_ATTRIBUTE87),
      TEXT_BASE_ATTRIBUTE88 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE88, PAVI.TEXT_BASE_ATTRIBUTE88),
      TEXT_BASE_ATTRIBUTE89 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE89, PAVI.TEXT_BASE_ATTRIBUTE89),
      TEXT_BASE_ATTRIBUTE90 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE90, PAVI.TEXT_BASE_ATTRIBUTE90),
      TEXT_BASE_ATTRIBUTE91 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE91, PAVI.TEXT_BASE_ATTRIBUTE91),
      TEXT_BASE_ATTRIBUTE92 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE92, PAVI.TEXT_BASE_ATTRIBUTE92),
      TEXT_BASE_ATTRIBUTE93 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE93, PAVI.TEXT_BASE_ATTRIBUTE93),
      TEXT_BASE_ATTRIBUTE94 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE94, PAVI.TEXT_BASE_ATTRIBUTE94),
      TEXT_BASE_ATTRIBUTE95 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE95, PAVI.TEXT_BASE_ATTRIBUTE95),
      TEXT_BASE_ATTRIBUTE96 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE96, PAVI.TEXT_BASE_ATTRIBUTE96),
      TEXT_BASE_ATTRIBUTE97 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE97, PAVI.TEXT_BASE_ATTRIBUTE97),
      TEXT_BASE_ATTRIBUTE98 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE98, PAVI.TEXT_BASE_ATTRIBUTE98),
      TEXT_BASE_ATTRIBUTE99 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE99, PAVI.TEXT_BASE_ATTRIBUTE99),
      TEXT_BASE_ATTRIBUTE100 = DECODE(PAVI.TEXT_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_BASE_ATTRIBUTE100, PAVI.TEXT_BASE_ATTRIBUTE100),
      NUM_BASE_ATTRIBUTE1 = DECODE(PAVI.NUM_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE1, PAVI.NUM_BASE_ATTRIBUTE1),
      NUM_BASE_ATTRIBUTE2 = DECODE(PAVI.NUM_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE2, PAVI.NUM_BASE_ATTRIBUTE2),
      NUM_BASE_ATTRIBUTE3 = DECODE(PAVI.NUM_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE3, PAVI.NUM_BASE_ATTRIBUTE3),
      NUM_BASE_ATTRIBUTE4 = DECODE(PAVI.NUM_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE4, PAVI.NUM_BASE_ATTRIBUTE4),
      NUM_BASE_ATTRIBUTE5 = DECODE(PAVI.NUM_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE5, PAVI.NUM_BASE_ATTRIBUTE5),
      NUM_BASE_ATTRIBUTE6 = DECODE(PAVI.NUM_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE6, PAVI.NUM_BASE_ATTRIBUTE6),
      NUM_BASE_ATTRIBUTE7 = DECODE(PAVI.NUM_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE7, PAVI.NUM_BASE_ATTRIBUTE7),
      NUM_BASE_ATTRIBUTE8 = DECODE(PAVI.NUM_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE8, PAVI.NUM_BASE_ATTRIBUTE8),
      NUM_BASE_ATTRIBUTE9 = DECODE(PAVI.NUM_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE9, PAVI.NUM_BASE_ATTRIBUTE9),
      NUM_BASE_ATTRIBUTE10 = DECODE(PAVI.NUM_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE10, PAVI.NUM_BASE_ATTRIBUTE10),
      NUM_BASE_ATTRIBUTE11 = DECODE(PAVI.NUM_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE11, PAVI.NUM_BASE_ATTRIBUTE11),
      NUM_BASE_ATTRIBUTE12 = DECODE(PAVI.NUM_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE12, PAVI.NUM_BASE_ATTRIBUTE12),
      NUM_BASE_ATTRIBUTE13 = DECODE(PAVI.NUM_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE13, PAVI.NUM_BASE_ATTRIBUTE13),
      NUM_BASE_ATTRIBUTE14 = DECODE(PAVI.NUM_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE14, PAVI.NUM_BASE_ATTRIBUTE14),
      NUM_BASE_ATTRIBUTE15 = DECODE(PAVI.NUM_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE15, PAVI.NUM_BASE_ATTRIBUTE15),
      NUM_BASE_ATTRIBUTE16 = DECODE(PAVI.NUM_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE16, PAVI.NUM_BASE_ATTRIBUTE16),
      NUM_BASE_ATTRIBUTE17 = DECODE(PAVI.NUM_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE17, PAVI.NUM_BASE_ATTRIBUTE17),
      NUM_BASE_ATTRIBUTE18 = DECODE(PAVI.NUM_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE18, PAVI.NUM_BASE_ATTRIBUTE18),
      NUM_BASE_ATTRIBUTE19 = DECODE(PAVI.NUM_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE19, PAVI.NUM_BASE_ATTRIBUTE19),
      NUM_BASE_ATTRIBUTE20 = DECODE(PAVI.NUM_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE20, PAVI.NUM_BASE_ATTRIBUTE20),
      NUM_BASE_ATTRIBUTE21 = DECODE(PAVI.NUM_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE21, PAVI.NUM_BASE_ATTRIBUTE21),
      NUM_BASE_ATTRIBUTE22 = DECODE(PAVI.NUM_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE22, PAVI.NUM_BASE_ATTRIBUTE22),
      NUM_BASE_ATTRIBUTE23 = DECODE(PAVI.NUM_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE23, PAVI.NUM_BASE_ATTRIBUTE23),
      NUM_BASE_ATTRIBUTE24 = DECODE(PAVI.NUM_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE24, PAVI.NUM_BASE_ATTRIBUTE24),
      NUM_BASE_ATTRIBUTE25 = DECODE(PAVI.NUM_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE25, PAVI.NUM_BASE_ATTRIBUTE25),
      NUM_BASE_ATTRIBUTE26 = DECODE(PAVI.NUM_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE26, PAVI.NUM_BASE_ATTRIBUTE26),
      NUM_BASE_ATTRIBUTE27 = DECODE(PAVI.NUM_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE27, PAVI.NUM_BASE_ATTRIBUTE27),
      NUM_BASE_ATTRIBUTE28 = DECODE(PAVI.NUM_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE28, PAVI.NUM_BASE_ATTRIBUTE28),
      NUM_BASE_ATTRIBUTE29 = DECODE(PAVI.NUM_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE29, PAVI.NUM_BASE_ATTRIBUTE29),
      NUM_BASE_ATTRIBUTE30 = DECODE(PAVI.NUM_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE30, PAVI.NUM_BASE_ATTRIBUTE30),
      NUM_BASE_ATTRIBUTE31 = DECODE(PAVI.NUM_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE31, PAVI.NUM_BASE_ATTRIBUTE31),
      NUM_BASE_ATTRIBUTE32 = DECODE(PAVI.NUM_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE32, PAVI.NUM_BASE_ATTRIBUTE32),
      NUM_BASE_ATTRIBUTE33 = DECODE(PAVI.NUM_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE33, PAVI.NUM_BASE_ATTRIBUTE33),
      NUM_BASE_ATTRIBUTE34 = DECODE(PAVI.NUM_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE34, PAVI.NUM_BASE_ATTRIBUTE34),
      NUM_BASE_ATTRIBUTE35 = DECODE(PAVI.NUM_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE35, PAVI.NUM_BASE_ATTRIBUTE35),
      NUM_BASE_ATTRIBUTE36 = DECODE(PAVI.NUM_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE36, PAVI.NUM_BASE_ATTRIBUTE36),
      NUM_BASE_ATTRIBUTE37 = DECODE(PAVI.NUM_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE37, PAVI.NUM_BASE_ATTRIBUTE37),
      NUM_BASE_ATTRIBUTE38 = DECODE(PAVI.NUM_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE38, PAVI.NUM_BASE_ATTRIBUTE38),
      NUM_BASE_ATTRIBUTE39 = DECODE(PAVI.NUM_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE39, PAVI.NUM_BASE_ATTRIBUTE39),
      NUM_BASE_ATTRIBUTE40 = DECODE(PAVI.NUM_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE40, PAVI.NUM_BASE_ATTRIBUTE40),
      NUM_BASE_ATTRIBUTE41 = DECODE(PAVI.NUM_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE41, PAVI.NUM_BASE_ATTRIBUTE41),
      NUM_BASE_ATTRIBUTE42 = DECODE(PAVI.NUM_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE42, PAVI.NUM_BASE_ATTRIBUTE42),
      NUM_BASE_ATTRIBUTE43 = DECODE(PAVI.NUM_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE43, PAVI.NUM_BASE_ATTRIBUTE43),
      NUM_BASE_ATTRIBUTE44 = DECODE(PAVI.NUM_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE44, PAVI.NUM_BASE_ATTRIBUTE44),
      NUM_BASE_ATTRIBUTE45 = DECODE(PAVI.NUM_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE45, PAVI.NUM_BASE_ATTRIBUTE45),
      NUM_BASE_ATTRIBUTE46 = DECODE(PAVI.NUM_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE46, PAVI.NUM_BASE_ATTRIBUTE46),
      NUM_BASE_ATTRIBUTE47 = DECODE(PAVI.NUM_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE47, PAVI.NUM_BASE_ATTRIBUTE47),
      NUM_BASE_ATTRIBUTE48 = DECODE(PAVI.NUM_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE48, PAVI.NUM_BASE_ATTRIBUTE48),
      NUM_BASE_ATTRIBUTE49 = DECODE(PAVI.NUM_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE49, PAVI.NUM_BASE_ATTRIBUTE49),
      NUM_BASE_ATTRIBUTE50 = DECODE(PAVI.NUM_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE50, PAVI.NUM_BASE_ATTRIBUTE50),
      NUM_BASE_ATTRIBUTE51 = DECODE(PAVI.NUM_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE51, PAVI.NUM_BASE_ATTRIBUTE51),
      NUM_BASE_ATTRIBUTE52 = DECODE(PAVI.NUM_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE52, PAVI.NUM_BASE_ATTRIBUTE52),
      NUM_BASE_ATTRIBUTE53 = DECODE(PAVI.NUM_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE53, PAVI.NUM_BASE_ATTRIBUTE53),
      NUM_BASE_ATTRIBUTE54 = DECODE(PAVI.NUM_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE54, PAVI.NUM_BASE_ATTRIBUTE54),
      NUM_BASE_ATTRIBUTE55 = DECODE(PAVI.NUM_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE55, PAVI.NUM_BASE_ATTRIBUTE55),
      NUM_BASE_ATTRIBUTE56 = DECODE(PAVI.NUM_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE56, PAVI.NUM_BASE_ATTRIBUTE56),
      NUM_BASE_ATTRIBUTE57 = DECODE(PAVI.NUM_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE57, PAVI.NUM_BASE_ATTRIBUTE57),
      NUM_BASE_ATTRIBUTE58 = DECODE(PAVI.NUM_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE58, PAVI.NUM_BASE_ATTRIBUTE58),
      NUM_BASE_ATTRIBUTE59 = DECODE(PAVI.NUM_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE59, PAVI.NUM_BASE_ATTRIBUTE59),
      NUM_BASE_ATTRIBUTE60 = DECODE(PAVI.NUM_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE60, PAVI.NUM_BASE_ATTRIBUTE60),
      NUM_BASE_ATTRIBUTE61 = DECODE(PAVI.NUM_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE61, PAVI.NUM_BASE_ATTRIBUTE61),
      NUM_BASE_ATTRIBUTE62 = DECODE(PAVI.NUM_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE62, PAVI.NUM_BASE_ATTRIBUTE62),
      NUM_BASE_ATTRIBUTE63 = DECODE(PAVI.NUM_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE63, PAVI.NUM_BASE_ATTRIBUTE63),
      NUM_BASE_ATTRIBUTE64 = DECODE(PAVI.NUM_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE64, PAVI.NUM_BASE_ATTRIBUTE64),
      NUM_BASE_ATTRIBUTE65 = DECODE(PAVI.NUM_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE65, PAVI.NUM_BASE_ATTRIBUTE65),
      NUM_BASE_ATTRIBUTE66 = DECODE(PAVI.NUM_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE66, PAVI.NUM_BASE_ATTRIBUTE66),
      NUM_BASE_ATTRIBUTE67 = DECODE(PAVI.NUM_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE67, PAVI.NUM_BASE_ATTRIBUTE67),
      NUM_BASE_ATTRIBUTE68 = DECODE(PAVI.NUM_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE68, PAVI.NUM_BASE_ATTRIBUTE68),
      NUM_BASE_ATTRIBUTE69 = DECODE(PAVI.NUM_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE69, PAVI.NUM_BASE_ATTRIBUTE69),
      NUM_BASE_ATTRIBUTE70 = DECODE(PAVI.NUM_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE70, PAVI.NUM_BASE_ATTRIBUTE70),
      NUM_BASE_ATTRIBUTE71 = DECODE(PAVI.NUM_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE71, PAVI.NUM_BASE_ATTRIBUTE71),
      NUM_BASE_ATTRIBUTE72 = DECODE(PAVI.NUM_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE72, PAVI.NUM_BASE_ATTRIBUTE72),
      NUM_BASE_ATTRIBUTE73 = DECODE(PAVI.NUM_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE73, PAVI.NUM_BASE_ATTRIBUTE73),
      NUM_BASE_ATTRIBUTE74 = DECODE(PAVI.NUM_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE74, PAVI.NUM_BASE_ATTRIBUTE74),
      NUM_BASE_ATTRIBUTE75 = DECODE(PAVI.NUM_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE75, PAVI.NUM_BASE_ATTRIBUTE75),
      NUM_BASE_ATTRIBUTE76 = DECODE(PAVI.NUM_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE76, PAVI.NUM_BASE_ATTRIBUTE76),
      NUM_BASE_ATTRIBUTE77 = DECODE(PAVI.NUM_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE77, PAVI.NUM_BASE_ATTRIBUTE77),
      NUM_BASE_ATTRIBUTE78 = DECODE(PAVI.NUM_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE78, PAVI.NUM_BASE_ATTRIBUTE78),
      NUM_BASE_ATTRIBUTE79 = DECODE(PAVI.NUM_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE79, PAVI.NUM_BASE_ATTRIBUTE79),
      NUM_BASE_ATTRIBUTE80 = DECODE(PAVI.NUM_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE80, PAVI.NUM_BASE_ATTRIBUTE80),
      NUM_BASE_ATTRIBUTE81 = DECODE(PAVI.NUM_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE81, PAVI.NUM_BASE_ATTRIBUTE81),
      NUM_BASE_ATTRIBUTE82 = DECODE(PAVI.NUM_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE82, PAVI.NUM_BASE_ATTRIBUTE82),
      NUM_BASE_ATTRIBUTE83 = DECODE(PAVI.NUM_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE83, PAVI.NUM_BASE_ATTRIBUTE83),
      NUM_BASE_ATTRIBUTE84 = DECODE(PAVI.NUM_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE84, PAVI.NUM_BASE_ATTRIBUTE84),
      NUM_BASE_ATTRIBUTE85 = DECODE(PAVI.NUM_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE85, PAVI.NUM_BASE_ATTRIBUTE85),
      NUM_BASE_ATTRIBUTE86 = DECODE(PAVI.NUM_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE86, PAVI.NUM_BASE_ATTRIBUTE86),
      NUM_BASE_ATTRIBUTE87 = DECODE(PAVI.NUM_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE87, PAVI.NUM_BASE_ATTRIBUTE87),
      NUM_BASE_ATTRIBUTE88 = DECODE(PAVI.NUM_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE88, PAVI.NUM_BASE_ATTRIBUTE88),
      NUM_BASE_ATTRIBUTE89 = DECODE(PAVI.NUM_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE89, PAVI.NUM_BASE_ATTRIBUTE89),
      NUM_BASE_ATTRIBUTE90 = DECODE(PAVI.NUM_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE90, PAVI.NUM_BASE_ATTRIBUTE90),
      NUM_BASE_ATTRIBUTE91 = DECODE(PAVI.NUM_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE91, PAVI.NUM_BASE_ATTRIBUTE91),
      NUM_BASE_ATTRIBUTE92 = DECODE(PAVI.NUM_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE92, PAVI.NUM_BASE_ATTRIBUTE92),
      NUM_BASE_ATTRIBUTE93 = DECODE(PAVI.NUM_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE93, PAVI.NUM_BASE_ATTRIBUTE93),
      NUM_BASE_ATTRIBUTE94 = DECODE(PAVI.NUM_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE94, PAVI.NUM_BASE_ATTRIBUTE94),
      NUM_BASE_ATTRIBUTE95 = DECODE(PAVI.NUM_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE95, PAVI.NUM_BASE_ATTRIBUTE95),
      NUM_BASE_ATTRIBUTE96 = DECODE(PAVI.NUM_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE96, PAVI.NUM_BASE_ATTRIBUTE96),
      NUM_BASE_ATTRIBUTE97 = DECODE(PAVI.NUM_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE97, PAVI.NUM_BASE_ATTRIBUTE97),
      NUM_BASE_ATTRIBUTE98 = DECODE(PAVI.NUM_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE98, PAVI.NUM_BASE_ATTRIBUTE98),
      NUM_BASE_ATTRIBUTE99 = DECODE(PAVI.NUM_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE99, PAVI.NUM_BASE_ATTRIBUTE99),
      NUM_BASE_ATTRIBUTE100 = DECODE(PAVI.NUM_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_BASE_ATTRIBUTE100, PAVI.NUM_BASE_ATTRIBUTE100),
      TEXT_CAT_ATTRIBUTE1 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE1, PAVI.TEXT_CAT_ATTRIBUTE1),
      TEXT_CAT_ATTRIBUTE2 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE2, PAVI.TEXT_CAT_ATTRIBUTE2),
      TEXT_CAT_ATTRIBUTE3 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE3, PAVI.TEXT_CAT_ATTRIBUTE3),
      TEXT_CAT_ATTRIBUTE4 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE4, PAVI.TEXT_CAT_ATTRIBUTE4),
      TEXT_CAT_ATTRIBUTE5 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE5, PAVI.TEXT_CAT_ATTRIBUTE5),
      TEXT_CAT_ATTRIBUTE6 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE6, PAVI.TEXT_CAT_ATTRIBUTE6),
      TEXT_CAT_ATTRIBUTE7 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE7, PAVI.TEXT_CAT_ATTRIBUTE7),
      TEXT_CAT_ATTRIBUTE8 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE8, PAVI.TEXT_CAT_ATTRIBUTE8),
      TEXT_CAT_ATTRIBUTE9 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE9, PAVI.TEXT_CAT_ATTRIBUTE9),
      TEXT_CAT_ATTRIBUTE10 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE10, PAVI.TEXT_CAT_ATTRIBUTE10),
      TEXT_CAT_ATTRIBUTE11 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE11, PAVI.TEXT_CAT_ATTRIBUTE11),
      TEXT_CAT_ATTRIBUTE12 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE12, PAVI.TEXT_CAT_ATTRIBUTE12),
      TEXT_CAT_ATTRIBUTE13 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE13, PAVI.TEXT_CAT_ATTRIBUTE13),
      TEXT_CAT_ATTRIBUTE14 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE14, PAVI.TEXT_CAT_ATTRIBUTE14),
      TEXT_CAT_ATTRIBUTE15 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE15, PAVI.TEXT_CAT_ATTRIBUTE15),
      TEXT_CAT_ATTRIBUTE16 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE16, PAVI.TEXT_CAT_ATTRIBUTE16),
      TEXT_CAT_ATTRIBUTE17 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE17, PAVI.TEXT_CAT_ATTRIBUTE17),
      TEXT_CAT_ATTRIBUTE18 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE18, PAVI.TEXT_CAT_ATTRIBUTE18),
      TEXT_CAT_ATTRIBUTE19 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE19, PAVI.TEXT_CAT_ATTRIBUTE19),
      TEXT_CAT_ATTRIBUTE20 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE20, PAVI.TEXT_CAT_ATTRIBUTE20),
      TEXT_CAT_ATTRIBUTE21 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE21, PAVI.TEXT_CAT_ATTRIBUTE21),
      TEXT_CAT_ATTRIBUTE22 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE22, PAVI.TEXT_CAT_ATTRIBUTE22),
      TEXT_CAT_ATTRIBUTE23 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE23, PAVI.TEXT_CAT_ATTRIBUTE23),
      TEXT_CAT_ATTRIBUTE24 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE24, PAVI.TEXT_CAT_ATTRIBUTE24),
      TEXT_CAT_ATTRIBUTE25 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE25, PAVI.TEXT_CAT_ATTRIBUTE25),
      TEXT_CAT_ATTRIBUTE26 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE26, PAVI.TEXT_CAT_ATTRIBUTE26),
      TEXT_CAT_ATTRIBUTE27 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE27, PAVI.TEXT_CAT_ATTRIBUTE27),
      TEXT_CAT_ATTRIBUTE28 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE28, PAVI.TEXT_CAT_ATTRIBUTE28),
      TEXT_CAT_ATTRIBUTE29 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE29, PAVI.TEXT_CAT_ATTRIBUTE29),
      TEXT_CAT_ATTRIBUTE30 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE30, PAVI.TEXT_CAT_ATTRIBUTE30),
      TEXT_CAT_ATTRIBUTE31 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE31, PAVI.TEXT_CAT_ATTRIBUTE31),
      TEXT_CAT_ATTRIBUTE32 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE32, PAVI.TEXT_CAT_ATTRIBUTE32),
      TEXT_CAT_ATTRIBUTE33 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE33, PAVI.TEXT_CAT_ATTRIBUTE33),
      TEXT_CAT_ATTRIBUTE34 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE34, PAVI.TEXT_CAT_ATTRIBUTE34),
      TEXT_CAT_ATTRIBUTE35 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE35, PAVI.TEXT_CAT_ATTRIBUTE35),
      TEXT_CAT_ATTRIBUTE36 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE36, PAVI.TEXT_CAT_ATTRIBUTE36),
      TEXT_CAT_ATTRIBUTE37 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE37, PAVI.TEXT_CAT_ATTRIBUTE37),
      TEXT_CAT_ATTRIBUTE38 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE38, PAVI.TEXT_CAT_ATTRIBUTE38),
      TEXT_CAT_ATTRIBUTE39 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE39, PAVI.TEXT_CAT_ATTRIBUTE39),
      TEXT_CAT_ATTRIBUTE40 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE40, PAVI.TEXT_CAT_ATTRIBUTE40),
      TEXT_CAT_ATTRIBUTE41 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE41, PAVI.TEXT_CAT_ATTRIBUTE41),
      TEXT_CAT_ATTRIBUTE42 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE42, PAVI.TEXT_CAT_ATTRIBUTE42),
      TEXT_CAT_ATTRIBUTE43 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE43, PAVI.TEXT_CAT_ATTRIBUTE43),
      TEXT_CAT_ATTRIBUTE44 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE44, PAVI.TEXT_CAT_ATTRIBUTE44),
      TEXT_CAT_ATTRIBUTE45 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE45, PAVI.TEXT_CAT_ATTRIBUTE45),
      TEXT_CAT_ATTRIBUTE46 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE46, PAVI.TEXT_CAT_ATTRIBUTE46),
      TEXT_CAT_ATTRIBUTE47 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE47, PAVI.TEXT_CAT_ATTRIBUTE47),
      TEXT_CAT_ATTRIBUTE48 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE48, PAVI.TEXT_CAT_ATTRIBUTE48),
      TEXT_CAT_ATTRIBUTE49 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE49, PAVI.TEXT_CAT_ATTRIBUTE49),
      TEXT_CAT_ATTRIBUTE50 = DECODE(PAVI.TEXT_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.TEXT_CAT_ATTRIBUTE50, PAVI.TEXT_CAT_ATTRIBUTE50),
      NUM_CAT_ATTRIBUTE1 = DECODE(PAVI.NUM_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE1, PAVI.NUM_CAT_ATTRIBUTE1),
      NUM_CAT_ATTRIBUTE2 = DECODE(PAVI.NUM_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE2, PAVI.NUM_CAT_ATTRIBUTE2),
      NUM_CAT_ATTRIBUTE3 = DECODE(PAVI.NUM_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE3, PAVI.NUM_CAT_ATTRIBUTE3),
      NUM_CAT_ATTRIBUTE4 = DECODE(PAVI.NUM_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE4, PAVI.NUM_CAT_ATTRIBUTE4),
      NUM_CAT_ATTRIBUTE5 = DECODE(PAVI.NUM_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE5, PAVI.NUM_CAT_ATTRIBUTE5),
      NUM_CAT_ATTRIBUTE6 = DECODE(PAVI.NUM_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE6, PAVI.NUM_CAT_ATTRIBUTE6),
      NUM_CAT_ATTRIBUTE7 = DECODE(PAVI.NUM_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE7, PAVI.NUM_CAT_ATTRIBUTE7),
      NUM_CAT_ATTRIBUTE8 = DECODE(PAVI.NUM_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE8, PAVI.NUM_CAT_ATTRIBUTE8),
      NUM_CAT_ATTRIBUTE9 = DECODE(PAVI.NUM_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE9, PAVI.NUM_CAT_ATTRIBUTE9),
      NUM_CAT_ATTRIBUTE10 = DECODE(PAVI.NUM_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE10, PAVI.NUM_CAT_ATTRIBUTE10),
      NUM_CAT_ATTRIBUTE11 = DECODE(PAVI.NUM_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE11, PAVI.NUM_CAT_ATTRIBUTE11),
      NUM_CAT_ATTRIBUTE12 = DECODE(PAVI.NUM_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE12, PAVI.NUM_CAT_ATTRIBUTE12),
      NUM_CAT_ATTRIBUTE13 = DECODE(PAVI.NUM_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE13, PAVI.NUM_CAT_ATTRIBUTE13),
      NUM_CAT_ATTRIBUTE14 = DECODE(PAVI.NUM_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE14, PAVI.NUM_CAT_ATTRIBUTE14),
      NUM_CAT_ATTRIBUTE15 = DECODE(PAVI.NUM_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE15, PAVI.NUM_CAT_ATTRIBUTE15),
      NUM_CAT_ATTRIBUTE16 = DECODE(PAVI.NUM_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE16, PAVI.NUM_CAT_ATTRIBUTE16),
      NUM_CAT_ATTRIBUTE17 = DECODE(PAVI.NUM_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE17, PAVI.NUM_CAT_ATTRIBUTE17),
      NUM_CAT_ATTRIBUTE18 = DECODE(PAVI.NUM_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE18, PAVI.NUM_CAT_ATTRIBUTE18),
      NUM_CAT_ATTRIBUTE19 = DECODE(PAVI.NUM_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE19, PAVI.NUM_CAT_ATTRIBUTE19),
      NUM_CAT_ATTRIBUTE20 = DECODE(PAVI.NUM_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE20, PAVI.NUM_CAT_ATTRIBUTE20),
      NUM_CAT_ATTRIBUTE21 = DECODE(PAVI.NUM_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE21, PAVI.NUM_CAT_ATTRIBUTE21),
      NUM_CAT_ATTRIBUTE22 = DECODE(PAVI.NUM_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE22, PAVI.NUM_CAT_ATTRIBUTE22),
      NUM_CAT_ATTRIBUTE23 = DECODE(PAVI.NUM_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE23, PAVI.NUM_CAT_ATTRIBUTE23),
      NUM_CAT_ATTRIBUTE24 = DECODE(PAVI.NUM_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE24, PAVI.NUM_CAT_ATTRIBUTE24),
      NUM_CAT_ATTRIBUTE25 = DECODE(PAVI.NUM_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE25, PAVI.NUM_CAT_ATTRIBUTE25),
      NUM_CAT_ATTRIBUTE26 = DECODE(PAVI.NUM_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE26, PAVI.NUM_CAT_ATTRIBUTE26),
      NUM_CAT_ATTRIBUTE27 = DECODE(PAVI.NUM_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE27, PAVI.NUM_CAT_ATTRIBUTE27),
      NUM_CAT_ATTRIBUTE28 = DECODE(PAVI.NUM_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE28, PAVI.NUM_CAT_ATTRIBUTE28),
      NUM_CAT_ATTRIBUTE29 = DECODE(PAVI.NUM_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE29, PAVI.NUM_CAT_ATTRIBUTE29),
      NUM_CAT_ATTRIBUTE30 = DECODE(PAVI.NUM_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE30, PAVI.NUM_CAT_ATTRIBUTE30),
      NUM_CAT_ATTRIBUTE31 = DECODE(PAVI.NUM_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE31, PAVI.NUM_CAT_ATTRIBUTE31),
      NUM_CAT_ATTRIBUTE32 = DECODE(PAVI.NUM_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE32, PAVI.NUM_CAT_ATTRIBUTE32),
      NUM_CAT_ATTRIBUTE33 = DECODE(PAVI.NUM_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE33, PAVI.NUM_CAT_ATTRIBUTE33),
      NUM_CAT_ATTRIBUTE34 = DECODE(PAVI.NUM_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE34, PAVI.NUM_CAT_ATTRIBUTE34),
      NUM_CAT_ATTRIBUTE35 = DECODE(PAVI.NUM_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE35, PAVI.NUM_CAT_ATTRIBUTE35),
      NUM_CAT_ATTRIBUTE36 = DECODE(PAVI.NUM_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE36, PAVI.NUM_CAT_ATTRIBUTE36),
      NUM_CAT_ATTRIBUTE37 = DECODE(PAVI.NUM_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE37, PAVI.NUM_CAT_ATTRIBUTE37),
      NUM_CAT_ATTRIBUTE38 = DECODE(PAVI.NUM_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE38, PAVI.NUM_CAT_ATTRIBUTE38),
      NUM_CAT_ATTRIBUTE39 = DECODE(PAVI.NUM_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE39, PAVI.NUM_CAT_ATTRIBUTE39),
      NUM_CAT_ATTRIBUTE40 = DECODE(PAVI.NUM_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE40, PAVI.NUM_CAT_ATTRIBUTE40),
      NUM_CAT_ATTRIBUTE41 = DECODE(PAVI.NUM_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE41, PAVI.NUM_CAT_ATTRIBUTE41),
      NUM_CAT_ATTRIBUTE42 = DECODE(PAVI.NUM_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE42, PAVI.NUM_CAT_ATTRIBUTE42),
      NUM_CAT_ATTRIBUTE43 = DECODE(PAVI.NUM_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE43, PAVI.NUM_CAT_ATTRIBUTE43),
      NUM_CAT_ATTRIBUTE44 = DECODE(PAVI.NUM_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE44, PAVI.NUM_CAT_ATTRIBUTE44),
      NUM_CAT_ATTRIBUTE45 = DECODE(PAVI.NUM_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE45, PAVI.NUM_CAT_ATTRIBUTE45),
      NUM_CAT_ATTRIBUTE46 = DECODE(PAVI.NUM_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE46, PAVI.NUM_CAT_ATTRIBUTE46),
      NUM_CAT_ATTRIBUTE47 = DECODE(PAVI.NUM_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE47, PAVI.NUM_CAT_ATTRIBUTE47),
      NUM_CAT_ATTRIBUTE48 = DECODE(PAVI.NUM_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE48, PAVI.NUM_CAT_ATTRIBUTE48),
      NUM_CAT_ATTRIBUTE49 = DECODE(PAVI.NUM_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE49, PAVI.NUM_CAT_ATTRIBUTE49),
      NUM_CAT_ATTRIBUTE50 = DECODE(PAVI.NUM_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, NULL, PAVD.NUM_CAT_ATTRIBUTE50, PAVI.NUM_CAT_ATTRIBUTE50),
      LAST_UPDATE_LOGIN = NVL(PAVI.LAST_UPDATE_LOGIN, FND_GLOBAL.login_id),
      LAST_UPDATED_BY = NVL(PAVI.LAST_UPDATED_BY, FND_GLOBAL.user_id),
      LAST_UPDATE_DATE = NVL(PAVI.LAST_UPDATE_DATE, sysdate),
      REQUEST_ID = NVL(PAVI.REQUEST_ID, FND_GLOBAL.conc_request_id),
      PROGRAM_APPLICATION_ID = NVL(PAVI.PROGRAM_APPLICATION_ID, FND_GLOBAL.prog_appl_id),
      PROGRAM_ID = NVL(PAVI.PROGRAM_ID, FND_GLOBAL.conc_program_id),
      PROGRAM_UPDATE_DATE = NVL(PAVI.PROGRAM_UPDATE_DATE, sysdate),
      PICTURE = DECODE(PAVI.PICTURE, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVD.PICTURE, PAVI.PICTURE)
  WHEN NOT MATCHED THEN
    INSERT
    (
      ATTRIBUTE_VALUES_ID,
      DRAFT_ID,
      CHANGE_ACCEPTED_FLAG,
      DELETE_FLAG,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      MANUFACTURER_PART_NUM,
      THUMBNAIL_IMAGE,
      SUPPLIER_URL,
      MANUFACTURER_URL,
      ATTACHMENT_URL,
      UNSPSC,
      AVAILABILITY,
      LEAD_TIME,
      TEXT_BASE_ATTRIBUTE1,
      TEXT_BASE_ATTRIBUTE2,
      TEXT_BASE_ATTRIBUTE3,
      TEXT_BASE_ATTRIBUTE4,
      TEXT_BASE_ATTRIBUTE5,
      TEXT_BASE_ATTRIBUTE6,
      TEXT_BASE_ATTRIBUTE7,
      TEXT_BASE_ATTRIBUTE8,
      TEXT_BASE_ATTRIBUTE9,
      TEXT_BASE_ATTRIBUTE10,
      TEXT_BASE_ATTRIBUTE11,
      TEXT_BASE_ATTRIBUTE12,
      TEXT_BASE_ATTRIBUTE13,
      TEXT_BASE_ATTRIBUTE14,
      TEXT_BASE_ATTRIBUTE15,
      TEXT_BASE_ATTRIBUTE16,
      TEXT_BASE_ATTRIBUTE17,
      TEXT_BASE_ATTRIBUTE18,
      TEXT_BASE_ATTRIBUTE19,
      TEXT_BASE_ATTRIBUTE20,
      TEXT_BASE_ATTRIBUTE21,
      TEXT_BASE_ATTRIBUTE22,
      TEXT_BASE_ATTRIBUTE23,
      TEXT_BASE_ATTRIBUTE24,
      TEXT_BASE_ATTRIBUTE25,
      TEXT_BASE_ATTRIBUTE26,
      TEXT_BASE_ATTRIBUTE27,
      TEXT_BASE_ATTRIBUTE28,
      TEXT_BASE_ATTRIBUTE29,
      TEXT_BASE_ATTRIBUTE30,
      TEXT_BASE_ATTRIBUTE31,
      TEXT_BASE_ATTRIBUTE32,
      TEXT_BASE_ATTRIBUTE33,
      TEXT_BASE_ATTRIBUTE34,
      TEXT_BASE_ATTRIBUTE35,
      TEXT_BASE_ATTRIBUTE36,
      TEXT_BASE_ATTRIBUTE37,
      TEXT_BASE_ATTRIBUTE38,
      TEXT_BASE_ATTRIBUTE39,
      TEXT_BASE_ATTRIBUTE40,
      TEXT_BASE_ATTRIBUTE41,
      TEXT_BASE_ATTRIBUTE42,
      TEXT_BASE_ATTRIBUTE43,
      TEXT_BASE_ATTRIBUTE44,
      TEXT_BASE_ATTRIBUTE45,
      TEXT_BASE_ATTRIBUTE46,
      TEXT_BASE_ATTRIBUTE47,
      TEXT_BASE_ATTRIBUTE48,
      TEXT_BASE_ATTRIBUTE49,
      TEXT_BASE_ATTRIBUTE50,
      TEXT_BASE_ATTRIBUTE51,
      TEXT_BASE_ATTRIBUTE52,
      TEXT_BASE_ATTRIBUTE53,
      TEXT_BASE_ATTRIBUTE54,
      TEXT_BASE_ATTRIBUTE55,
      TEXT_BASE_ATTRIBUTE56,
      TEXT_BASE_ATTRIBUTE57,
      TEXT_BASE_ATTRIBUTE58,
      TEXT_BASE_ATTRIBUTE59,
      TEXT_BASE_ATTRIBUTE60,
      TEXT_BASE_ATTRIBUTE61,
      TEXT_BASE_ATTRIBUTE62,
      TEXT_BASE_ATTRIBUTE63,
      TEXT_BASE_ATTRIBUTE64,
      TEXT_BASE_ATTRIBUTE65,
      TEXT_BASE_ATTRIBUTE66,
      TEXT_BASE_ATTRIBUTE67,
      TEXT_BASE_ATTRIBUTE68,
      TEXT_BASE_ATTRIBUTE69,
      TEXT_BASE_ATTRIBUTE70,
      TEXT_BASE_ATTRIBUTE71,
      TEXT_BASE_ATTRIBUTE72,
      TEXT_BASE_ATTRIBUTE73,
      TEXT_BASE_ATTRIBUTE74,
      TEXT_BASE_ATTRIBUTE75,
      TEXT_BASE_ATTRIBUTE76,
      TEXT_BASE_ATTRIBUTE77,
      TEXT_BASE_ATTRIBUTE78,
      TEXT_BASE_ATTRIBUTE79,
      TEXT_BASE_ATTRIBUTE80,
      TEXT_BASE_ATTRIBUTE81,
      TEXT_BASE_ATTRIBUTE82,
      TEXT_BASE_ATTRIBUTE83,
      TEXT_BASE_ATTRIBUTE84,
      TEXT_BASE_ATTRIBUTE85,
      TEXT_BASE_ATTRIBUTE86,
      TEXT_BASE_ATTRIBUTE87,
      TEXT_BASE_ATTRIBUTE88,
      TEXT_BASE_ATTRIBUTE89,
      TEXT_BASE_ATTRIBUTE90,
      TEXT_BASE_ATTRIBUTE91,
      TEXT_BASE_ATTRIBUTE92,
      TEXT_BASE_ATTRIBUTE93,
      TEXT_BASE_ATTRIBUTE94,
      TEXT_BASE_ATTRIBUTE95,
      TEXT_BASE_ATTRIBUTE96,
      TEXT_BASE_ATTRIBUTE97,
      TEXT_BASE_ATTRIBUTE98,
      TEXT_BASE_ATTRIBUTE99,
      TEXT_BASE_ATTRIBUTE100,
      NUM_BASE_ATTRIBUTE1,
      NUM_BASE_ATTRIBUTE2,
      NUM_BASE_ATTRIBUTE3,
      NUM_BASE_ATTRIBUTE4,
      NUM_BASE_ATTRIBUTE5,
      NUM_BASE_ATTRIBUTE6,
      NUM_BASE_ATTRIBUTE7,
      NUM_BASE_ATTRIBUTE8,
      NUM_BASE_ATTRIBUTE9,
      NUM_BASE_ATTRIBUTE10,
      NUM_BASE_ATTRIBUTE11,
      NUM_BASE_ATTRIBUTE12,
      NUM_BASE_ATTRIBUTE13,
      NUM_BASE_ATTRIBUTE14,
      NUM_BASE_ATTRIBUTE15,
      NUM_BASE_ATTRIBUTE16,
      NUM_BASE_ATTRIBUTE17,
      NUM_BASE_ATTRIBUTE18,
      NUM_BASE_ATTRIBUTE19,
      NUM_BASE_ATTRIBUTE20,
      NUM_BASE_ATTRIBUTE21,
      NUM_BASE_ATTRIBUTE22,
      NUM_BASE_ATTRIBUTE23,
      NUM_BASE_ATTRIBUTE24,
      NUM_BASE_ATTRIBUTE25,
      NUM_BASE_ATTRIBUTE26,
      NUM_BASE_ATTRIBUTE27,
      NUM_BASE_ATTRIBUTE28,
      NUM_BASE_ATTRIBUTE29,
      NUM_BASE_ATTRIBUTE30,
      NUM_BASE_ATTRIBUTE31,
      NUM_BASE_ATTRIBUTE32,
      NUM_BASE_ATTRIBUTE33,
      NUM_BASE_ATTRIBUTE34,
      NUM_BASE_ATTRIBUTE35,
      NUM_BASE_ATTRIBUTE36,
      NUM_BASE_ATTRIBUTE37,
      NUM_BASE_ATTRIBUTE38,
      NUM_BASE_ATTRIBUTE39,
      NUM_BASE_ATTRIBUTE40,
      NUM_BASE_ATTRIBUTE41,
      NUM_BASE_ATTRIBUTE42,
      NUM_BASE_ATTRIBUTE43,
      NUM_BASE_ATTRIBUTE44,
      NUM_BASE_ATTRIBUTE45,
      NUM_BASE_ATTRIBUTE46,
      NUM_BASE_ATTRIBUTE47,
      NUM_BASE_ATTRIBUTE48,
      NUM_BASE_ATTRIBUTE49,
      NUM_BASE_ATTRIBUTE50,
      NUM_BASE_ATTRIBUTE51,
      NUM_BASE_ATTRIBUTE52,
      NUM_BASE_ATTRIBUTE53,
      NUM_BASE_ATTRIBUTE54,
      NUM_BASE_ATTRIBUTE55,
      NUM_BASE_ATTRIBUTE56,
      NUM_BASE_ATTRIBUTE57,
      NUM_BASE_ATTRIBUTE58,
      NUM_BASE_ATTRIBUTE59,
      NUM_BASE_ATTRIBUTE60,
      NUM_BASE_ATTRIBUTE61,
      NUM_BASE_ATTRIBUTE62,
      NUM_BASE_ATTRIBUTE63,
      NUM_BASE_ATTRIBUTE64,
      NUM_BASE_ATTRIBUTE65,
      NUM_BASE_ATTRIBUTE66,
      NUM_BASE_ATTRIBUTE67,
      NUM_BASE_ATTRIBUTE68,
      NUM_BASE_ATTRIBUTE69,
      NUM_BASE_ATTRIBUTE70,
      NUM_BASE_ATTRIBUTE71,
      NUM_BASE_ATTRIBUTE72,
      NUM_BASE_ATTRIBUTE73,
      NUM_BASE_ATTRIBUTE74,
      NUM_BASE_ATTRIBUTE75,
      NUM_BASE_ATTRIBUTE76,
      NUM_BASE_ATTRIBUTE77,
      NUM_BASE_ATTRIBUTE78,
      NUM_BASE_ATTRIBUTE79,
      NUM_BASE_ATTRIBUTE80,
      NUM_BASE_ATTRIBUTE81,
      NUM_BASE_ATTRIBUTE82,
      NUM_BASE_ATTRIBUTE83,
      NUM_BASE_ATTRIBUTE84,
      NUM_BASE_ATTRIBUTE85,
      NUM_BASE_ATTRIBUTE86,
      NUM_BASE_ATTRIBUTE87,
      NUM_BASE_ATTRIBUTE88,
      NUM_BASE_ATTRIBUTE89,
      NUM_BASE_ATTRIBUTE90,
      NUM_BASE_ATTRIBUTE91,
      NUM_BASE_ATTRIBUTE92,
      NUM_BASE_ATTRIBUTE93,
      NUM_BASE_ATTRIBUTE94,
      NUM_BASE_ATTRIBUTE95,
      NUM_BASE_ATTRIBUTE96,
      NUM_BASE_ATTRIBUTE97,
      NUM_BASE_ATTRIBUTE98,
      NUM_BASE_ATTRIBUTE99,
      NUM_BASE_ATTRIBUTE100,
      TEXT_CAT_ATTRIBUTE1,
      TEXT_CAT_ATTRIBUTE2,
      TEXT_CAT_ATTRIBUTE3,
      TEXT_CAT_ATTRIBUTE4,
      TEXT_CAT_ATTRIBUTE5,
      TEXT_CAT_ATTRIBUTE6,
      TEXT_CAT_ATTRIBUTE7,
      TEXT_CAT_ATTRIBUTE8,
      TEXT_CAT_ATTRIBUTE9,
      TEXT_CAT_ATTRIBUTE10,
      TEXT_CAT_ATTRIBUTE11,
      TEXT_CAT_ATTRIBUTE12,
      TEXT_CAT_ATTRIBUTE13,
      TEXT_CAT_ATTRIBUTE14,
      TEXT_CAT_ATTRIBUTE15,
      TEXT_CAT_ATTRIBUTE16,
      TEXT_CAT_ATTRIBUTE17,
      TEXT_CAT_ATTRIBUTE18,
      TEXT_CAT_ATTRIBUTE19,
      TEXT_CAT_ATTRIBUTE20,
      TEXT_CAT_ATTRIBUTE21,
      TEXT_CAT_ATTRIBUTE22,
      TEXT_CAT_ATTRIBUTE23,
      TEXT_CAT_ATTRIBUTE24,
      TEXT_CAT_ATTRIBUTE25,
      TEXT_CAT_ATTRIBUTE26,
      TEXT_CAT_ATTRIBUTE27,
      TEXT_CAT_ATTRIBUTE28,
      TEXT_CAT_ATTRIBUTE29,
      TEXT_CAT_ATTRIBUTE30,
      TEXT_CAT_ATTRIBUTE31,
      TEXT_CAT_ATTRIBUTE32,
      TEXT_CAT_ATTRIBUTE33,
      TEXT_CAT_ATTRIBUTE34,
      TEXT_CAT_ATTRIBUTE35,
      TEXT_CAT_ATTRIBUTE36,
      TEXT_CAT_ATTRIBUTE37,
      TEXT_CAT_ATTRIBUTE38,
      TEXT_CAT_ATTRIBUTE39,
      TEXT_CAT_ATTRIBUTE40,
      TEXT_CAT_ATTRIBUTE41,
      TEXT_CAT_ATTRIBUTE42,
      TEXT_CAT_ATTRIBUTE43,
      TEXT_CAT_ATTRIBUTE44,
      TEXT_CAT_ATTRIBUTE45,
      TEXT_CAT_ATTRIBUTE46,
      TEXT_CAT_ATTRIBUTE47,
      TEXT_CAT_ATTRIBUTE48,
      TEXT_CAT_ATTRIBUTE49,
      TEXT_CAT_ATTRIBUTE50,
      NUM_CAT_ATTRIBUTE1,
      NUM_CAT_ATTRIBUTE2,
      NUM_CAT_ATTRIBUTE3,
      NUM_CAT_ATTRIBUTE4,
      NUM_CAT_ATTRIBUTE5,
      NUM_CAT_ATTRIBUTE6,
      NUM_CAT_ATTRIBUTE7,
      NUM_CAT_ATTRIBUTE8,
      NUM_CAT_ATTRIBUTE9,
      NUM_CAT_ATTRIBUTE10,
      NUM_CAT_ATTRIBUTE11,
      NUM_CAT_ATTRIBUTE12,
      NUM_CAT_ATTRIBUTE13,
      NUM_CAT_ATTRIBUTE14,
      NUM_CAT_ATTRIBUTE15,
      NUM_CAT_ATTRIBUTE16,
      NUM_CAT_ATTRIBUTE17,
      NUM_CAT_ATTRIBUTE18,
      NUM_CAT_ATTRIBUTE19,
      NUM_CAT_ATTRIBUTE20,
      NUM_CAT_ATTRIBUTE21,
      NUM_CAT_ATTRIBUTE22,
      NUM_CAT_ATTRIBUTE23,
      NUM_CAT_ATTRIBUTE24,
      NUM_CAT_ATTRIBUTE25,
      NUM_CAT_ATTRIBUTE26,
      NUM_CAT_ATTRIBUTE27,
      NUM_CAT_ATTRIBUTE28,
      NUM_CAT_ATTRIBUTE29,
      NUM_CAT_ATTRIBUTE30,
      NUM_CAT_ATTRIBUTE31,
      NUM_CAT_ATTRIBUTE32,
      NUM_CAT_ATTRIBUTE33,
      NUM_CAT_ATTRIBUTE34,
      NUM_CAT_ATTRIBUTE35,
      NUM_CAT_ATTRIBUTE36,
      NUM_CAT_ATTRIBUTE37,
      NUM_CAT_ATTRIBUTE38,
      NUM_CAT_ATTRIBUTE39,
      NUM_CAT_ATTRIBUTE40,
      NUM_CAT_ATTRIBUTE41,
      NUM_CAT_ATTRIBUTE42,
      NUM_CAT_ATTRIBUTE43,
      NUM_CAT_ATTRIBUTE44,
      NUM_CAT_ATTRIBUTE45,
      NUM_CAT_ATTRIBUTE46,
      NUM_CAT_ATTRIBUTE47,
      NUM_CAT_ATTRIBUTE48,
      NUM_CAT_ATTRIBUTE49,
      NUM_CAT_ATTRIBUTE50,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      PICTURE
    )
    VALUES
    (
      PO_ATTRIBUTE_VALUES_S.nextval,
      PAVI.DRAFT_ID,
      NULL, -- CHANGE_ACCEPTED_FLAG,
      NULL, -- DELETE_FLAG,
      PAVI.PO_LINE_ID,
      '-2', -- REQ_TEMPLATE_NAME
      -2,   --REQ_TEMPLATE_LINE_NUM
      NVL(PAVI.IP_CATEGORY_ID, -2),
      NVL(PAVI.INVENTORY_ITEM_ID, -2),
      PO_PDOI_PARAMS.g_request.org_id,
      DECODE(PAVI.MANUFACTURER_PART_NUM, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.MANUFACTURER_PART_NUM),
      DECODE(PAVI.THUMBNAIL_IMAGE, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.THUMBNAIL_IMAGE),
      DECODE(PAVI.SUPPLIER_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.SUPPLIER_URL),
      DECODE(PAVI.MANUFACTURER_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.MANUFACTURER_URL),
      DECODE(PAVI.ATTACHMENT_URL, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.ATTACHMENT_URL),
      DECODE(PAVI.UNSPSC, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.UNSPSC),
      DECODE(PAVI.AVAILABILITY, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.AVAILABILITY),
      DECODE(PAVI.LEAD_TIME, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.LEAD_TIME),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE1),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE2),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE3),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE4),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE5),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE6),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE7),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE8),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE9),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE10),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE11),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE12),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE13),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE14),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE15),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE16),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE17),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE18),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE19),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE20),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE21),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE22),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE23),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE24),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE25),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE26),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE27),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE28),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE29),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE30),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE31),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE32),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE33),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE34),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE35),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE36),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE37),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE38),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE39),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE40),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE41),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE42),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE43),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE44),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE45),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE46),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE47),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE48),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE49),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE50),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE51),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE52),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE53),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE54),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE55),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE56),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE57),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE58),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE59),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE60),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE61),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE62),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE63),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE64),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE65),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE66),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE67),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE68),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE69),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE70),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE71),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE72),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE73),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE74),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE75),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE76),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE77),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE78),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE79),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE80),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE81),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE82),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE83),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE84),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE85),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE86),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE87),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE88),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE89),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE90),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE91),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE92),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE93),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE94),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE95),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE96),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE97),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE98),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE99),
      DECODE(PAVI.TEXT_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_BASE_ATTRIBUTE100),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE1),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE2),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE3),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE4),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE5),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE6),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE7),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE8),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE9),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE10),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE11),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE12),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE13),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE14),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE15),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE16),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE17),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE18),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE19),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE20),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE21),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE22),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE23),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE24),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE25),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE26),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE27),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE28),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE29),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE30),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE31),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE32),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE33),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE34),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE35),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE36),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE37),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE38),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE39),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE40),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE41),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE42),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE43),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE44),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE45),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE46),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE47),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE48),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE49),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE50),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE51),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE52),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE53),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE54),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE55),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE56),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE57),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE58),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE59),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE60),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE61),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE62),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE63),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE64),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE65),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE66),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE67),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE68),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE69),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE70),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE71),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE72),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE73),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE74),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE75),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE76),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE77),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE78),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE79),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE80),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE81),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE82),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE83),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE84),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE85),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE86),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE87),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE88),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE89),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE90),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE91),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE92),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE93),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE94),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE95),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE96),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE97),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE98),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE99),
      DECODE(PAVI.NUM_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_BASE_ATTRIBUTE100),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE1),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE2),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE3),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE4),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE5),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE6),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE7),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE8),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE9),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE10),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE11),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE12),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE13),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE14),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE15),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE16),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE17),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE18),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE19),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE20),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE21),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE22),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE23),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE24),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE25),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE26),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE27),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE28),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE29),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE30),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE31),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE32),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE33),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE34),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE35),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE36),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE37),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE38),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE39),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE40),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE41),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE42),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE43),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE44),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE45),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE46),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE47),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE48),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE49),
      DECODE(PAVI.TEXT_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.TEXT_CAT_ATTRIBUTE50),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE1),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE2),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE3),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE4),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE5),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE6),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE7),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE8),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE9),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE10),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE11),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE12),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE13),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE14),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE15),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE16),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE17),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE18),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE19),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE20),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE21),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE22),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE23),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE24),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE25),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE26),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE27),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE28),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE29),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE30),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE31),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE32),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE33),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE34),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE35),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE36),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE37),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE38),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE39),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE40),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE41),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE42),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE43),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE44),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE45),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE46),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE47),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE48),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE49),
      DECODE(PAVI.NUM_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_NUM, NULL, PAVI.NUM_CAT_ATTRIBUTE50),
      NVL(PAVI.LAST_UPDATE_LOGIN, FND_GLOBAL.login_id),
      NVL(PAVI.LAST_UPDATED_BY, FND_GLOBAL.user_id),
      NVL(PAVI.LAST_UPDATE_DATE, sysdate),
      NVL(PAVI.CREATED_BY, FND_GLOBAL.user_id),
      NVL(PAVI.CREATION_DATE, sysdate),
      NVL(PAVI.REQUEST_ID, FND_GLOBAL.conc_request_id),
      NVL(PAVI.PROGRAM_APPLICATION_ID, FND_GLOBAL.prog_appl_id),
      NVL(PAVI.PROGRAM_ID, FND_GLOBAL.conc_program_id),
      NVL(PAVI.PROGRAM_UPDATE_DATE, sysdate),
      DECODE(PAVI.PICTURE, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVI.PICTURE));

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
END merge_po_attr_values_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_po_attr_values_tlp_draft
--Function:
--  insert new attribute tlp values or update existing tlp values
--  into po_attribute_values_tlp_draft
--Parameters:
--IN:
--p_key
--  key value used to join with gt table
--p_attr_values_tlp
--  record which contains processed line attributes in a batch;
--  If there is no processing logic(derive, default, validate) on
--  an attribute, this attribute's value will be read from
--  interface table directly
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_po_attr_values_tlp_draft
(
  p_key                IN po_session_gt.key%TYPE,
  p_attr_values_tlp    IN PO_PDOI_TYPES.attr_values_tlp_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'merge_po_attr_values_tlp_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  MERGE INTO po_attribute_values_tlp_draft PAVTD
  USING (
    SELECT
      NUM2 AS ATTRIBUTE_VALUES_TLP_ID,
      NUM3 AS DRAFT_ID,
      NUM4 AS PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      NUM5 AS IP_CATEGORY_ID,
      NUM6 AS INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      char1 AS LINE_DESCRIPTION, -- used for default if description is null
      MANUFACTURER,
      COMMENTS,
      ALIAS,
      char2 AS LONG_DESCRIPTION,  -- Bug7722053: long description
      TL_TEXT_BASE_ATTRIBUTE1,
      TL_TEXT_BASE_ATTRIBUTE2,
      TL_TEXT_BASE_ATTRIBUTE3,
      TL_TEXT_BASE_ATTRIBUTE4,
      TL_TEXT_BASE_ATTRIBUTE5,
      TL_TEXT_BASE_ATTRIBUTE6,
      TL_TEXT_BASE_ATTRIBUTE7,
      TL_TEXT_BASE_ATTRIBUTE8,
      TL_TEXT_BASE_ATTRIBUTE9,
      TL_TEXT_BASE_ATTRIBUTE10,
      TL_TEXT_BASE_ATTRIBUTE11,
      TL_TEXT_BASE_ATTRIBUTE12,
      TL_TEXT_BASE_ATTRIBUTE13,
      TL_TEXT_BASE_ATTRIBUTE14,
      TL_TEXT_BASE_ATTRIBUTE15,
      TL_TEXT_BASE_ATTRIBUTE16,
      TL_TEXT_BASE_ATTRIBUTE17,
      TL_TEXT_BASE_ATTRIBUTE18,
      TL_TEXT_BASE_ATTRIBUTE19,
      TL_TEXT_BASE_ATTRIBUTE20,
      TL_TEXT_BASE_ATTRIBUTE21,
      TL_TEXT_BASE_ATTRIBUTE22,
      TL_TEXT_BASE_ATTRIBUTE23,
      TL_TEXT_BASE_ATTRIBUTE24,
      TL_TEXT_BASE_ATTRIBUTE25,
      TL_TEXT_BASE_ATTRIBUTE26,
      TL_TEXT_BASE_ATTRIBUTE27,
      TL_TEXT_BASE_ATTRIBUTE28,
      TL_TEXT_BASE_ATTRIBUTE29,
      TL_TEXT_BASE_ATTRIBUTE30,
      TL_TEXT_BASE_ATTRIBUTE31,
      TL_TEXT_BASE_ATTRIBUTE32,
      TL_TEXT_BASE_ATTRIBUTE33,
      TL_TEXT_BASE_ATTRIBUTE34,
      TL_TEXT_BASE_ATTRIBUTE35,
      TL_TEXT_BASE_ATTRIBUTE36,
      TL_TEXT_BASE_ATTRIBUTE37,
      TL_TEXT_BASE_ATTRIBUTE38,
      TL_TEXT_BASE_ATTRIBUTE39,
      TL_TEXT_BASE_ATTRIBUTE40,
      TL_TEXT_BASE_ATTRIBUTE41,
      TL_TEXT_BASE_ATTRIBUTE42,
      TL_TEXT_BASE_ATTRIBUTE43,
      TL_TEXT_BASE_ATTRIBUTE44,
      TL_TEXT_BASE_ATTRIBUTE45,
      TL_TEXT_BASE_ATTRIBUTE46,
      TL_TEXT_BASE_ATTRIBUTE47,
      TL_TEXT_BASE_ATTRIBUTE48,
      TL_TEXT_BASE_ATTRIBUTE49,
      TL_TEXT_BASE_ATTRIBUTE50,
      TL_TEXT_BASE_ATTRIBUTE51,
      TL_TEXT_BASE_ATTRIBUTE52,
      TL_TEXT_BASE_ATTRIBUTE53,
      TL_TEXT_BASE_ATTRIBUTE54,
      TL_TEXT_BASE_ATTRIBUTE55,
      TL_TEXT_BASE_ATTRIBUTE56,
      TL_TEXT_BASE_ATTRIBUTE57,
      TL_TEXT_BASE_ATTRIBUTE58,
      TL_TEXT_BASE_ATTRIBUTE59,
      TL_TEXT_BASE_ATTRIBUTE60,
      TL_TEXT_BASE_ATTRIBUTE61,
      TL_TEXT_BASE_ATTRIBUTE62,
      TL_TEXT_BASE_ATTRIBUTE63,
      TL_TEXT_BASE_ATTRIBUTE64,
      TL_TEXT_BASE_ATTRIBUTE65,
      TL_TEXT_BASE_ATTRIBUTE66,
      TL_TEXT_BASE_ATTRIBUTE67,
      TL_TEXT_BASE_ATTRIBUTE68,
      TL_TEXT_BASE_ATTRIBUTE69,
      TL_TEXT_BASE_ATTRIBUTE70,
      TL_TEXT_BASE_ATTRIBUTE71,
      TL_TEXT_BASE_ATTRIBUTE72,
      TL_TEXT_BASE_ATTRIBUTE73,
      TL_TEXT_BASE_ATTRIBUTE74,
      TL_TEXT_BASE_ATTRIBUTE75,
      TL_TEXT_BASE_ATTRIBUTE76,
      TL_TEXT_BASE_ATTRIBUTE77,
      TL_TEXT_BASE_ATTRIBUTE78,
      TL_TEXT_BASE_ATTRIBUTE79,
      TL_TEXT_BASE_ATTRIBUTE80,
      TL_TEXT_BASE_ATTRIBUTE81,
      TL_TEXT_BASE_ATTRIBUTE82,
      TL_TEXT_BASE_ATTRIBUTE83,
      TL_TEXT_BASE_ATTRIBUTE84,
      TL_TEXT_BASE_ATTRIBUTE85,
      TL_TEXT_BASE_ATTRIBUTE86,
      TL_TEXT_BASE_ATTRIBUTE87,
      TL_TEXT_BASE_ATTRIBUTE88,
      TL_TEXT_BASE_ATTRIBUTE89,
      TL_TEXT_BASE_ATTRIBUTE90,
      TL_TEXT_BASE_ATTRIBUTE91,
      TL_TEXT_BASE_ATTRIBUTE92,
      TL_TEXT_BASE_ATTRIBUTE93,
      TL_TEXT_BASE_ATTRIBUTE94,
      TL_TEXT_BASE_ATTRIBUTE95,
      TL_TEXT_BASE_ATTRIBUTE96,
      TL_TEXT_BASE_ATTRIBUTE97,
      TL_TEXT_BASE_ATTRIBUTE98,
      TL_TEXT_BASE_ATTRIBUTE99,
      TL_TEXT_BASE_ATTRIBUTE100,
      TL_TEXT_CAT_ATTRIBUTE1,
      TL_TEXT_CAT_ATTRIBUTE2,
      TL_TEXT_CAT_ATTRIBUTE3,
      TL_TEXT_CAT_ATTRIBUTE4,
      TL_TEXT_CAT_ATTRIBUTE5,
      TL_TEXT_CAT_ATTRIBUTE6,
      TL_TEXT_CAT_ATTRIBUTE7,
      TL_TEXT_CAT_ATTRIBUTE8,
      TL_TEXT_CAT_ATTRIBUTE9,
      TL_TEXT_CAT_ATTRIBUTE10,
      TL_TEXT_CAT_ATTRIBUTE11,
      TL_TEXT_CAT_ATTRIBUTE12,
      TL_TEXT_CAT_ATTRIBUTE13,
      TL_TEXT_CAT_ATTRIBUTE14,
      TL_TEXT_CAT_ATTRIBUTE15,
      TL_TEXT_CAT_ATTRIBUTE16,
      TL_TEXT_CAT_ATTRIBUTE17,
      TL_TEXT_CAT_ATTRIBUTE18,
      TL_TEXT_CAT_ATTRIBUTE19,
      TL_TEXT_CAT_ATTRIBUTE20,
      TL_TEXT_CAT_ATTRIBUTE21,
      TL_TEXT_CAT_ATTRIBUTE22,
      TL_TEXT_CAT_ATTRIBUTE23,
      TL_TEXT_CAT_ATTRIBUTE24,
      TL_TEXT_CAT_ATTRIBUTE25,
      TL_TEXT_CAT_ATTRIBUTE26,
      TL_TEXT_CAT_ATTRIBUTE27,
      TL_TEXT_CAT_ATTRIBUTE28,
      TL_TEXT_CAT_ATTRIBUTE29,
      TL_TEXT_CAT_ATTRIBUTE30,
      TL_TEXT_CAT_ATTRIBUTE31,
      TL_TEXT_CAT_ATTRIBUTE32,
      TL_TEXT_CAT_ATTRIBUTE33,
      TL_TEXT_CAT_ATTRIBUTE34,
      TL_TEXT_CAT_ATTRIBUTE35,
      TL_TEXT_CAT_ATTRIBUTE36,
      TL_TEXT_CAT_ATTRIBUTE37,
      TL_TEXT_CAT_ATTRIBUTE38,
      TL_TEXT_CAT_ATTRIBUTE39,
      TL_TEXT_CAT_ATTRIBUTE40,
      TL_TEXT_CAT_ATTRIBUTE41,
      TL_TEXT_CAT_ATTRIBUTE42,
      TL_TEXT_CAT_ATTRIBUTE43,
      TL_TEXT_CAT_ATTRIBUTE44,
      TL_TEXT_CAT_ATTRIBUTE45,
      TL_TEXT_CAT_ATTRIBUTE46,
      TL_TEXT_CAT_ATTRIBUTE47,
      TL_TEXT_CAT_ATTRIBUTE48,
      TL_TEXT_CAT_ATTRIBUTE49,
      TL_TEXT_CAT_ATTRIBUTE50,

      -- Bug 4731494: Make WHO columns not-null in Attr/TLP tables
      NVL(LAST_UPDATE_LOGIN, FND_GLOBAL.login_id) AS LAST_UPDATE_LOGIN,
      NVL(LAST_UPDATED_BY, FND_GLOBAL.user_id) AS LAST_UPDATED_BY,
      NVL(LAST_UPDATE_DATE, sysdate) AS LAST_UPDATE_DATE,
      NVL(CREATED_BY, FND_GLOBAL.user_id) AS CREATED_BY,
      NVL(CREATION_DATE, sysdate) AS CREATION_DATE,

      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    FROM   po_attr_values_tlp_interface intf_attrs_tlp,
           po_session_gt gt
    WHERE  intf_attrs_tlp.interface_attr_values_tlp_id = gt.num1
    AND    gt.key = p_key) PAVTI
  ON (PAVTD.attribute_values_tlp_id = PAVTI.attribute_values_tlp_id
      AND PAVTD.draft_id = PAVTI.draft_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      CHANGE_ACCEPTED_FLAG = NULL,
      DELETE_FLAG = NULL,
      IP_CATEGORY_ID = NVL(PAVTI.IP_CATEGORY_ID, PAVTD.IP_CATEGORY_ID),
      DESCRIPTION = DECODE(PAVTI.DESCRIPTION, NULL, PAVTD.DESCRIPTION, PAVTI.DESCRIPTION),
      MANUFACTURER = DECODE(PAVTI.MANUFACTURER, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.MANUFACTURER, PAVTI.MANUFACTURER),
      COMMENTS = DECODE(PAVTI.COMMENTS, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.COMMENTS, PAVTI.COMMENTS),
      ALIAS = DECODE(PAVTI.ALIAS, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.ALIAS, PAVTI.ALIAS),
      LONG_DESCRIPTION = DECODE(PAVTI.LONG_DESCRIPTION, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.LONG_DESCRIPTION, PAVTI.LONG_DESCRIPTION),
      TL_TEXT_BASE_ATTRIBUTE1 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE1, PAVTI.TL_TEXT_BASE_ATTRIBUTE1),
      TL_TEXT_BASE_ATTRIBUTE2 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE2, PAVTI.TL_TEXT_BASE_ATTRIBUTE2),
      TL_TEXT_BASE_ATTRIBUTE3 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE3, PAVTI.TL_TEXT_BASE_ATTRIBUTE3),
      TL_TEXT_BASE_ATTRIBUTE4 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE4, PAVTI.TL_TEXT_BASE_ATTRIBUTE4),
      TL_TEXT_BASE_ATTRIBUTE5 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE5, PAVTI.TL_TEXT_BASE_ATTRIBUTE5),
      TL_TEXT_BASE_ATTRIBUTE6 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE6, PAVTI.TL_TEXT_BASE_ATTRIBUTE6),
      TL_TEXT_BASE_ATTRIBUTE7 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE7, PAVTI.TL_TEXT_BASE_ATTRIBUTE7),
      TL_TEXT_BASE_ATTRIBUTE8 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE8, PAVTI.TL_TEXT_BASE_ATTRIBUTE8),
      TL_TEXT_BASE_ATTRIBUTE9 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE9, PAVTI.TL_TEXT_BASE_ATTRIBUTE9),
      TL_TEXT_BASE_ATTRIBUTE10 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE10, PAVTI.TL_TEXT_BASE_ATTRIBUTE10),
      TL_TEXT_BASE_ATTRIBUTE11 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE11, PAVTI.TL_TEXT_BASE_ATTRIBUTE11),
      TL_TEXT_BASE_ATTRIBUTE12 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE12, PAVTI.TL_TEXT_BASE_ATTRIBUTE12),
      TL_TEXT_BASE_ATTRIBUTE13 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE13, PAVTI.TL_TEXT_BASE_ATTRIBUTE13),
      TL_TEXT_BASE_ATTRIBUTE14 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE14, PAVTI.TL_TEXT_BASE_ATTRIBUTE14),
      TL_TEXT_BASE_ATTRIBUTE15 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE15, PAVTI.TL_TEXT_BASE_ATTRIBUTE15),
      TL_TEXT_BASE_ATTRIBUTE16 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE16, PAVTI.TL_TEXT_BASE_ATTRIBUTE16),
      TL_TEXT_BASE_ATTRIBUTE17 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE17, PAVTI.TL_TEXT_BASE_ATTRIBUTE17),
      TL_TEXT_BASE_ATTRIBUTE18 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE18, PAVTI.TL_TEXT_BASE_ATTRIBUTE18),
      TL_TEXT_BASE_ATTRIBUTE19 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE19, PAVTI.TL_TEXT_BASE_ATTRIBUTE19),
      TL_TEXT_BASE_ATTRIBUTE20 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE20, PAVTI.TL_TEXT_BASE_ATTRIBUTE20),
      TL_TEXT_BASE_ATTRIBUTE21 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE21, PAVTI.TL_TEXT_BASE_ATTRIBUTE21),
      TL_TEXT_BASE_ATTRIBUTE22 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE22, PAVTI.TL_TEXT_BASE_ATTRIBUTE22),
      TL_TEXT_BASE_ATTRIBUTE23 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE23, PAVTI.TL_TEXT_BASE_ATTRIBUTE23),
      TL_TEXT_BASE_ATTRIBUTE24 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE24, PAVTI.TL_TEXT_BASE_ATTRIBUTE24),
      TL_TEXT_BASE_ATTRIBUTE25 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE25, PAVTI.TL_TEXT_BASE_ATTRIBUTE25),
      TL_TEXT_BASE_ATTRIBUTE26 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE26, PAVTI.TL_TEXT_BASE_ATTRIBUTE26),
      TL_TEXT_BASE_ATTRIBUTE27 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE27, PAVTI.TL_TEXT_BASE_ATTRIBUTE27),
      TL_TEXT_BASE_ATTRIBUTE28 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE28, PAVTI.TL_TEXT_BASE_ATTRIBUTE28),
      TL_TEXT_BASE_ATTRIBUTE29 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE29, PAVTI.TL_TEXT_BASE_ATTRIBUTE29),
      TL_TEXT_BASE_ATTRIBUTE30 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE30, PAVTI.TL_TEXT_BASE_ATTRIBUTE30),
      TL_TEXT_BASE_ATTRIBUTE31 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE31, PAVTI.TL_TEXT_BASE_ATTRIBUTE31),
      TL_TEXT_BASE_ATTRIBUTE32 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE32, PAVTI.TL_TEXT_BASE_ATTRIBUTE32),
      TL_TEXT_BASE_ATTRIBUTE33 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE33, PAVTI.TL_TEXT_BASE_ATTRIBUTE33),
      TL_TEXT_BASE_ATTRIBUTE34 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE34, PAVTI.TL_TEXT_BASE_ATTRIBUTE34),
      TL_TEXT_BASE_ATTRIBUTE35 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE35, PAVTI.TL_TEXT_BASE_ATTRIBUTE35),
      TL_TEXT_BASE_ATTRIBUTE36 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE36, PAVTI.TL_TEXT_BASE_ATTRIBUTE36),
      TL_TEXT_BASE_ATTRIBUTE37 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE37, PAVTI.TL_TEXT_BASE_ATTRIBUTE37),
      TL_TEXT_BASE_ATTRIBUTE38 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE38, PAVTI.TL_TEXT_BASE_ATTRIBUTE38),
      TL_TEXT_BASE_ATTRIBUTE39 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE39, PAVTI.TL_TEXT_BASE_ATTRIBUTE39),
      TL_TEXT_BASE_ATTRIBUTE40 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE40, PAVTI.TL_TEXT_BASE_ATTRIBUTE40),
      TL_TEXT_BASE_ATTRIBUTE41 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE41, PAVTI.TL_TEXT_BASE_ATTRIBUTE41),
      TL_TEXT_BASE_ATTRIBUTE42 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE42, PAVTI.TL_TEXT_BASE_ATTRIBUTE42),
      TL_TEXT_BASE_ATTRIBUTE43 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE43, PAVTI.TL_TEXT_BASE_ATTRIBUTE43),
      TL_TEXT_BASE_ATTRIBUTE44 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE44, PAVTI.TL_TEXT_BASE_ATTRIBUTE44),
      TL_TEXT_BASE_ATTRIBUTE45 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE45, PAVTI.TL_TEXT_BASE_ATTRIBUTE45),
      TL_TEXT_BASE_ATTRIBUTE46 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE46, PAVTI.TL_TEXT_BASE_ATTRIBUTE46),
      TL_TEXT_BASE_ATTRIBUTE47 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE47, PAVTI.TL_TEXT_BASE_ATTRIBUTE47),
      TL_TEXT_BASE_ATTRIBUTE48 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE48, PAVTI.TL_TEXT_BASE_ATTRIBUTE48),
      TL_TEXT_BASE_ATTRIBUTE49 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE49, PAVTI.TL_TEXT_BASE_ATTRIBUTE49),
      TL_TEXT_BASE_ATTRIBUTE50 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE50, PAVTI.TL_TEXT_BASE_ATTRIBUTE50),
      TL_TEXT_BASE_ATTRIBUTE51 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE51, PAVTI.TL_TEXT_BASE_ATTRIBUTE51),
      TL_TEXT_BASE_ATTRIBUTE52 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE52, PAVTI.TL_TEXT_BASE_ATTRIBUTE52),
      TL_TEXT_BASE_ATTRIBUTE53 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE53, PAVTI.TL_TEXT_BASE_ATTRIBUTE53),
      TL_TEXT_BASE_ATTRIBUTE54 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE54, PAVTI.TL_TEXT_BASE_ATTRIBUTE54),
      TL_TEXT_BASE_ATTRIBUTE55 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE55, PAVTI.TL_TEXT_BASE_ATTRIBUTE55),
      TL_TEXT_BASE_ATTRIBUTE56 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE56, PAVTI.TL_TEXT_BASE_ATTRIBUTE56),
      TL_TEXT_BASE_ATTRIBUTE57 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE57, PAVTI.TL_TEXT_BASE_ATTRIBUTE57),
      TL_TEXT_BASE_ATTRIBUTE58 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE58, PAVTI.TL_TEXT_BASE_ATTRIBUTE58),
      TL_TEXT_BASE_ATTRIBUTE59 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE59, PAVTI.TL_TEXT_BASE_ATTRIBUTE59),
      TL_TEXT_BASE_ATTRIBUTE60 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE60, PAVTI.TL_TEXT_BASE_ATTRIBUTE60),
      TL_TEXT_BASE_ATTRIBUTE61 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE61, PAVTI.TL_TEXT_BASE_ATTRIBUTE61),
      TL_TEXT_BASE_ATTRIBUTE62 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE62, PAVTI.TL_TEXT_BASE_ATTRIBUTE62),
      TL_TEXT_BASE_ATTRIBUTE63 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE63, PAVTI.TL_TEXT_BASE_ATTRIBUTE63),
      TL_TEXT_BASE_ATTRIBUTE64 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE64, PAVTI.TL_TEXT_BASE_ATTRIBUTE64),
      TL_TEXT_BASE_ATTRIBUTE65 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE65, PAVTI.TL_TEXT_BASE_ATTRIBUTE65),
      TL_TEXT_BASE_ATTRIBUTE66 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE66, PAVTI.TL_TEXT_BASE_ATTRIBUTE66),
      TL_TEXT_BASE_ATTRIBUTE67 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE67, PAVTI.TL_TEXT_BASE_ATTRIBUTE67),
      TL_TEXT_BASE_ATTRIBUTE68 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE68, PAVTI.TL_TEXT_BASE_ATTRIBUTE68),
      TL_TEXT_BASE_ATTRIBUTE69 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE69, PAVTI.TL_TEXT_BASE_ATTRIBUTE69),
      TL_TEXT_BASE_ATTRIBUTE70 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE70, PAVTI.TL_TEXT_BASE_ATTRIBUTE70),
      TL_TEXT_BASE_ATTRIBUTE71 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE71, PAVTI.TL_TEXT_BASE_ATTRIBUTE71),
      TL_TEXT_BASE_ATTRIBUTE72 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE72, PAVTI.TL_TEXT_BASE_ATTRIBUTE72),
      TL_TEXT_BASE_ATTRIBUTE73 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE73, PAVTI.TL_TEXT_BASE_ATTRIBUTE73),
      TL_TEXT_BASE_ATTRIBUTE74 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE74, PAVTI.TL_TEXT_BASE_ATTRIBUTE74),
      TL_TEXT_BASE_ATTRIBUTE75 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE75, PAVTI.TL_TEXT_BASE_ATTRIBUTE75),
      TL_TEXT_BASE_ATTRIBUTE76 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE76, PAVTI.TL_TEXT_BASE_ATTRIBUTE76),
      TL_TEXT_BASE_ATTRIBUTE77 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE77, PAVTI.TL_TEXT_BASE_ATTRIBUTE77),
      TL_TEXT_BASE_ATTRIBUTE78 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE78, PAVTI.TL_TEXT_BASE_ATTRIBUTE78),
      TL_TEXT_BASE_ATTRIBUTE79 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE79, PAVTI.TL_TEXT_BASE_ATTRIBUTE79),
      TL_TEXT_BASE_ATTRIBUTE80 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE80, PAVTI.TL_TEXT_BASE_ATTRIBUTE80),
      TL_TEXT_BASE_ATTRIBUTE81 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE81, PAVTI.TL_TEXT_BASE_ATTRIBUTE81),
      TL_TEXT_BASE_ATTRIBUTE82 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE82, PAVTI.TL_TEXT_BASE_ATTRIBUTE82),
      TL_TEXT_BASE_ATTRIBUTE83 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE83, PAVTI.TL_TEXT_BASE_ATTRIBUTE83),
      TL_TEXT_BASE_ATTRIBUTE84 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE84, PAVTI.TL_TEXT_BASE_ATTRIBUTE84),
      TL_TEXT_BASE_ATTRIBUTE85 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE85, PAVTI.TL_TEXT_BASE_ATTRIBUTE85),
      TL_TEXT_BASE_ATTRIBUTE86 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE86, PAVTI.TL_TEXT_BASE_ATTRIBUTE86),
      TL_TEXT_BASE_ATTRIBUTE87 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE87, PAVTI.TL_TEXT_BASE_ATTRIBUTE87),
      TL_TEXT_BASE_ATTRIBUTE88 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE88, PAVTI.TL_TEXT_BASE_ATTRIBUTE88),
      TL_TEXT_BASE_ATTRIBUTE89 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE89, PAVTI.TL_TEXT_BASE_ATTRIBUTE89),
      TL_TEXT_BASE_ATTRIBUTE90 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE90, PAVTI.TL_TEXT_BASE_ATTRIBUTE90),
      TL_TEXT_BASE_ATTRIBUTE91 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE91, PAVTI.TL_TEXT_BASE_ATTRIBUTE91),
      TL_TEXT_BASE_ATTRIBUTE92 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE92, PAVTI.TL_TEXT_BASE_ATTRIBUTE92),
      TL_TEXT_BASE_ATTRIBUTE93 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE93, PAVTI.TL_TEXT_BASE_ATTRIBUTE93),
      TL_TEXT_BASE_ATTRIBUTE94 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE94, PAVTI.TL_TEXT_BASE_ATTRIBUTE94),
      TL_TEXT_BASE_ATTRIBUTE95 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE95, PAVTI.TL_TEXT_BASE_ATTRIBUTE95),
      TL_TEXT_BASE_ATTRIBUTE96 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE96, PAVTI.TL_TEXT_BASE_ATTRIBUTE96),
      TL_TEXT_BASE_ATTRIBUTE97 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE97, PAVTI.TL_TEXT_BASE_ATTRIBUTE97),
      TL_TEXT_BASE_ATTRIBUTE98 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE98, PAVTI.TL_TEXT_BASE_ATTRIBUTE98),
      TL_TEXT_BASE_ATTRIBUTE99 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE99, PAVTI.TL_TEXT_BASE_ATTRIBUTE99),
      TL_TEXT_BASE_ATTRIBUTE100 = DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_BASE_ATTRIBUTE100, PAVTI.TL_TEXT_BASE_ATTRIBUTE100),
      TL_TEXT_CAT_ATTRIBUTE1 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE1, PAVTI.TL_TEXT_CAT_ATTRIBUTE1),
      TL_TEXT_CAT_ATTRIBUTE2 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE2, PAVTI.TL_TEXT_CAT_ATTRIBUTE2),
      TL_TEXT_CAT_ATTRIBUTE3 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE3, PAVTI.TL_TEXT_CAT_ATTRIBUTE3),
      TL_TEXT_CAT_ATTRIBUTE4 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE4, PAVTI.TL_TEXT_CAT_ATTRIBUTE4),
      TL_TEXT_CAT_ATTRIBUTE5 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE5, PAVTI.TL_TEXT_CAT_ATTRIBUTE5),
      TL_TEXT_CAT_ATTRIBUTE6 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE6, PAVTI.TL_TEXT_CAT_ATTRIBUTE6),
      TL_TEXT_CAT_ATTRIBUTE7 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE7, PAVTI.TL_TEXT_CAT_ATTRIBUTE7),
      TL_TEXT_CAT_ATTRIBUTE8 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE8, PAVTI.TL_TEXT_CAT_ATTRIBUTE8),
      TL_TEXT_CAT_ATTRIBUTE9 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE9, PAVTI.TL_TEXT_CAT_ATTRIBUTE9),
      TL_TEXT_CAT_ATTRIBUTE10 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE10, PAVTI.TL_TEXT_CAT_ATTRIBUTE10),
      TL_TEXT_CAT_ATTRIBUTE11 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE11, PAVTI.TL_TEXT_CAT_ATTRIBUTE11),
      TL_TEXT_CAT_ATTRIBUTE12 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE12, PAVTI.TL_TEXT_CAT_ATTRIBUTE12),
      TL_TEXT_CAT_ATTRIBUTE13 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE13, PAVTI.TL_TEXT_CAT_ATTRIBUTE13),
      TL_TEXT_CAT_ATTRIBUTE14 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE14, PAVTI.TL_TEXT_CAT_ATTRIBUTE14),
      TL_TEXT_CAT_ATTRIBUTE15 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE15, PAVTI.TL_TEXT_CAT_ATTRIBUTE15),
      TL_TEXT_CAT_ATTRIBUTE16 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE16, PAVTI.TL_TEXT_CAT_ATTRIBUTE16),
      TL_TEXT_CAT_ATTRIBUTE17 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE17, PAVTI.TL_TEXT_CAT_ATTRIBUTE17),
      TL_TEXT_CAT_ATTRIBUTE18 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE18, PAVTI.TL_TEXT_CAT_ATTRIBUTE18),
      TL_TEXT_CAT_ATTRIBUTE19 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE19, PAVTI.TL_TEXT_CAT_ATTRIBUTE19),
      TL_TEXT_CAT_ATTRIBUTE20 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE20, PAVTI.TL_TEXT_CAT_ATTRIBUTE20),
      TL_TEXT_CAT_ATTRIBUTE21 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE21, PAVTI.TL_TEXT_CAT_ATTRIBUTE21),
      TL_TEXT_CAT_ATTRIBUTE22 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE22, PAVTI.TL_TEXT_CAT_ATTRIBUTE22),
      TL_TEXT_CAT_ATTRIBUTE23 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE23, PAVTI.TL_TEXT_CAT_ATTRIBUTE23),
      TL_TEXT_CAT_ATTRIBUTE24 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE24, PAVTI.TL_TEXT_CAT_ATTRIBUTE24),
      TL_TEXT_CAT_ATTRIBUTE25 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE25, PAVTI.TL_TEXT_CAT_ATTRIBUTE25),
      TL_TEXT_CAT_ATTRIBUTE26 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE26, PAVTI.TL_TEXT_CAT_ATTRIBUTE26),
      TL_TEXT_CAT_ATTRIBUTE27 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE27, PAVTI.TL_TEXT_CAT_ATTRIBUTE27),
      TL_TEXT_CAT_ATTRIBUTE28 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE28, PAVTI.TL_TEXT_CAT_ATTRIBUTE28),
      TL_TEXT_CAT_ATTRIBUTE29 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE29, PAVTI.TL_TEXT_CAT_ATTRIBUTE29),
      TL_TEXT_CAT_ATTRIBUTE30 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE30, PAVTI.TL_TEXT_CAT_ATTRIBUTE30),
      TL_TEXT_CAT_ATTRIBUTE31 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE31, PAVTI.TL_TEXT_CAT_ATTRIBUTE31),
      TL_TEXT_CAT_ATTRIBUTE32 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE32, PAVTI.TL_TEXT_CAT_ATTRIBUTE32),
      TL_TEXT_CAT_ATTRIBUTE33 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE33, PAVTI.TL_TEXT_CAT_ATTRIBUTE33),
      TL_TEXT_CAT_ATTRIBUTE34 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE34, PAVTI.TL_TEXT_CAT_ATTRIBUTE34),
      TL_TEXT_CAT_ATTRIBUTE35 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE35, PAVTI.TL_TEXT_CAT_ATTRIBUTE35),
      TL_TEXT_CAT_ATTRIBUTE36 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE36, PAVTI.TL_TEXT_CAT_ATTRIBUTE36),
      TL_TEXT_CAT_ATTRIBUTE37 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE37, PAVTI.TL_TEXT_CAT_ATTRIBUTE37),
      TL_TEXT_CAT_ATTRIBUTE38 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE38, PAVTI.TL_TEXT_CAT_ATTRIBUTE38),
      TL_TEXT_CAT_ATTRIBUTE39 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE39, PAVTI.TL_TEXT_CAT_ATTRIBUTE39),
      TL_TEXT_CAT_ATTRIBUTE40 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE40, PAVTI.TL_TEXT_CAT_ATTRIBUTE40),
      TL_TEXT_CAT_ATTRIBUTE41 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE41, PAVTI.TL_TEXT_CAT_ATTRIBUTE41),
      TL_TEXT_CAT_ATTRIBUTE42 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE42, PAVTI.TL_TEXT_CAT_ATTRIBUTE42),
      TL_TEXT_CAT_ATTRIBUTE43 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE43, PAVTI.TL_TEXT_CAT_ATTRIBUTE43),
      TL_TEXT_CAT_ATTRIBUTE44 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE44, PAVTI.TL_TEXT_CAT_ATTRIBUTE44),
      TL_TEXT_CAT_ATTRIBUTE45 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE45, PAVTI.TL_TEXT_CAT_ATTRIBUTE45),
      TL_TEXT_CAT_ATTRIBUTE46 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE46, PAVTI.TL_TEXT_CAT_ATTRIBUTE46),
      TL_TEXT_CAT_ATTRIBUTE47 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE47, PAVTI.TL_TEXT_CAT_ATTRIBUTE47),
      TL_TEXT_CAT_ATTRIBUTE48 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE48, PAVTI.TL_TEXT_CAT_ATTRIBUTE48),
      TL_TEXT_CAT_ATTRIBUTE49 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE49, PAVTI.TL_TEXT_CAT_ATTRIBUTE49),
      TL_TEXT_CAT_ATTRIBUTE50 = DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, NULL, PAVTD.TL_TEXT_CAT_ATTRIBUTE50, PAVTI.TL_TEXT_CAT_ATTRIBUTE50),
      LAST_UPDATE_LOGIN = NVL(PAVTI.LAST_UPDATE_LOGIN, FND_GLOBAL.login_id),
      LAST_UPDATED_BY = NVL(PAVTI.LAST_UPDATED_BY, FND_GLOBAL.user_id),
      LAST_UPDATE_DATE = NVL(PAVTI.LAST_UPDATE_DATE, sysdate),
      REQUEST_ID = NVL(PAVTI.REQUEST_ID, FND_GLOBAL.conc_request_id),
      PROGRAM_APPLICATION_ID = NVL(PAVTI.PROGRAM_APPLICATION_ID, FND_GLOBAL.prog_appl_id),
      PROGRAM_ID = NVL(PAVTI.PROGRAM_ID, FND_GLOBAL.conc_program_id),
      PROGRAM_UPDATE_DATE = NVL(PAVTI.PROGRAM_UPDATE_DATE, sysdate)
  WHEN NOT MATCHED THEN
    INSERT
    (
      ATTRIBUTE_VALUES_TLP_ID,
      DRAFT_ID,
      CHANGE_ACCEPTED_FLAG,
      DELETE_FLAG,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      MANUFACTURER,
      COMMENTS,
      ALIAS,
      LONG_DESCRIPTION,
      TL_TEXT_BASE_ATTRIBUTE1,
      TL_TEXT_BASE_ATTRIBUTE2,
      TL_TEXT_BASE_ATTRIBUTE3,
      TL_TEXT_BASE_ATTRIBUTE4,
      TL_TEXT_BASE_ATTRIBUTE5,
      TL_TEXT_BASE_ATTRIBUTE6,
      TL_TEXT_BASE_ATTRIBUTE7,
      TL_TEXT_BASE_ATTRIBUTE8,
      TL_TEXT_BASE_ATTRIBUTE9,
      TL_TEXT_BASE_ATTRIBUTE10,
      TL_TEXT_BASE_ATTRIBUTE11,
      TL_TEXT_BASE_ATTRIBUTE12,
      TL_TEXT_BASE_ATTRIBUTE13,
      TL_TEXT_BASE_ATTRIBUTE14,
      TL_TEXT_BASE_ATTRIBUTE15,
      TL_TEXT_BASE_ATTRIBUTE16,
      TL_TEXT_BASE_ATTRIBUTE17,
      TL_TEXT_BASE_ATTRIBUTE18,
      TL_TEXT_BASE_ATTRIBUTE19,
      TL_TEXT_BASE_ATTRIBUTE20,
      TL_TEXT_BASE_ATTRIBUTE21,
      TL_TEXT_BASE_ATTRIBUTE22,
      TL_TEXT_BASE_ATTRIBUTE23,
      TL_TEXT_BASE_ATTRIBUTE24,
      TL_TEXT_BASE_ATTRIBUTE25,
      TL_TEXT_BASE_ATTRIBUTE26,
      TL_TEXT_BASE_ATTRIBUTE27,
      TL_TEXT_BASE_ATTRIBUTE28,
      TL_TEXT_BASE_ATTRIBUTE29,
      TL_TEXT_BASE_ATTRIBUTE30,
      TL_TEXT_BASE_ATTRIBUTE31,
      TL_TEXT_BASE_ATTRIBUTE32,
      TL_TEXT_BASE_ATTRIBUTE33,
      TL_TEXT_BASE_ATTRIBUTE34,
      TL_TEXT_BASE_ATTRIBUTE35,
      TL_TEXT_BASE_ATTRIBUTE36,
      TL_TEXT_BASE_ATTRIBUTE37,
      TL_TEXT_BASE_ATTRIBUTE38,
      TL_TEXT_BASE_ATTRIBUTE39,
      TL_TEXT_BASE_ATTRIBUTE40,
      TL_TEXT_BASE_ATTRIBUTE41,
      TL_TEXT_BASE_ATTRIBUTE42,
      TL_TEXT_BASE_ATTRIBUTE43,
      TL_TEXT_BASE_ATTRIBUTE44,
      TL_TEXT_BASE_ATTRIBUTE45,
      TL_TEXT_BASE_ATTRIBUTE46,
      TL_TEXT_BASE_ATTRIBUTE47,
      TL_TEXT_BASE_ATTRIBUTE48,
      TL_TEXT_BASE_ATTRIBUTE49,
      TL_TEXT_BASE_ATTRIBUTE50,
      TL_TEXT_BASE_ATTRIBUTE51,
      TL_TEXT_BASE_ATTRIBUTE52,
      TL_TEXT_BASE_ATTRIBUTE53,
      TL_TEXT_BASE_ATTRIBUTE54,
      TL_TEXT_BASE_ATTRIBUTE55,
      TL_TEXT_BASE_ATTRIBUTE56,
      TL_TEXT_BASE_ATTRIBUTE57,
      TL_TEXT_BASE_ATTRIBUTE58,
      TL_TEXT_BASE_ATTRIBUTE59,
      TL_TEXT_BASE_ATTRIBUTE60,
      TL_TEXT_BASE_ATTRIBUTE61,
      TL_TEXT_BASE_ATTRIBUTE62,
      TL_TEXT_BASE_ATTRIBUTE63,
      TL_TEXT_BASE_ATTRIBUTE64,
      TL_TEXT_BASE_ATTRIBUTE65,
      TL_TEXT_BASE_ATTRIBUTE66,
      TL_TEXT_BASE_ATTRIBUTE67,
      TL_TEXT_BASE_ATTRIBUTE68,
      TL_TEXT_BASE_ATTRIBUTE69,
      TL_TEXT_BASE_ATTRIBUTE70,
      TL_TEXT_BASE_ATTRIBUTE71,
      TL_TEXT_BASE_ATTRIBUTE72,
      TL_TEXT_BASE_ATTRIBUTE73,
      TL_TEXT_BASE_ATTRIBUTE74,
      TL_TEXT_BASE_ATTRIBUTE75,
      TL_TEXT_BASE_ATTRIBUTE76,
      TL_TEXT_BASE_ATTRIBUTE77,
      TL_TEXT_BASE_ATTRIBUTE78,
      TL_TEXT_BASE_ATTRIBUTE79,
      TL_TEXT_BASE_ATTRIBUTE80,
      TL_TEXT_BASE_ATTRIBUTE81,
      TL_TEXT_BASE_ATTRIBUTE82,
      TL_TEXT_BASE_ATTRIBUTE83,
      TL_TEXT_BASE_ATTRIBUTE84,
      TL_TEXT_BASE_ATTRIBUTE85,
      TL_TEXT_BASE_ATTRIBUTE86,
      TL_TEXT_BASE_ATTRIBUTE87,
      TL_TEXT_BASE_ATTRIBUTE88,
      TL_TEXT_BASE_ATTRIBUTE89,
      TL_TEXT_BASE_ATTRIBUTE90,
      TL_TEXT_BASE_ATTRIBUTE91,
      TL_TEXT_BASE_ATTRIBUTE92,
      TL_TEXT_BASE_ATTRIBUTE93,
      TL_TEXT_BASE_ATTRIBUTE94,
      TL_TEXT_BASE_ATTRIBUTE95,
      TL_TEXT_BASE_ATTRIBUTE96,
      TL_TEXT_BASE_ATTRIBUTE97,
      TL_TEXT_BASE_ATTRIBUTE98,
      TL_TEXT_BASE_ATTRIBUTE99,
      TL_TEXT_BASE_ATTRIBUTE100,
      TL_TEXT_CAT_ATTRIBUTE1,
      TL_TEXT_CAT_ATTRIBUTE2,
      TL_TEXT_CAT_ATTRIBUTE3,
      TL_TEXT_CAT_ATTRIBUTE4,
      TL_TEXT_CAT_ATTRIBUTE5,
      TL_TEXT_CAT_ATTRIBUTE6,
      TL_TEXT_CAT_ATTRIBUTE7,
      TL_TEXT_CAT_ATTRIBUTE8,
      TL_TEXT_CAT_ATTRIBUTE9,
      TL_TEXT_CAT_ATTRIBUTE10,
      TL_TEXT_CAT_ATTRIBUTE11,
      TL_TEXT_CAT_ATTRIBUTE12,
      TL_TEXT_CAT_ATTRIBUTE13,
      TL_TEXT_CAT_ATTRIBUTE14,
      TL_TEXT_CAT_ATTRIBUTE15,
      TL_TEXT_CAT_ATTRIBUTE16,
      TL_TEXT_CAT_ATTRIBUTE17,
      TL_TEXT_CAT_ATTRIBUTE18,
      TL_TEXT_CAT_ATTRIBUTE19,
      TL_TEXT_CAT_ATTRIBUTE20,
      TL_TEXT_CAT_ATTRIBUTE21,
      TL_TEXT_CAT_ATTRIBUTE22,
      TL_TEXT_CAT_ATTRIBUTE23,
      TL_TEXT_CAT_ATTRIBUTE24,
      TL_TEXT_CAT_ATTRIBUTE25,
      TL_TEXT_CAT_ATTRIBUTE26,
      TL_TEXT_CAT_ATTRIBUTE27,
      TL_TEXT_CAT_ATTRIBUTE28,
      TL_TEXT_CAT_ATTRIBUTE29,
      TL_TEXT_CAT_ATTRIBUTE30,
      TL_TEXT_CAT_ATTRIBUTE31,
      TL_TEXT_CAT_ATTRIBUTE32,
      TL_TEXT_CAT_ATTRIBUTE33,
      TL_TEXT_CAT_ATTRIBUTE34,
      TL_TEXT_CAT_ATTRIBUTE35,
      TL_TEXT_CAT_ATTRIBUTE36,
      TL_TEXT_CAT_ATTRIBUTE37,
      TL_TEXT_CAT_ATTRIBUTE38,
      TL_TEXT_CAT_ATTRIBUTE39,
      TL_TEXT_CAT_ATTRIBUTE40,
      TL_TEXT_CAT_ATTRIBUTE41,
      TL_TEXT_CAT_ATTRIBUTE42,
      TL_TEXT_CAT_ATTRIBUTE43,
      TL_TEXT_CAT_ATTRIBUTE44,
      TL_TEXT_CAT_ATTRIBUTE45,
      TL_TEXT_CAT_ATTRIBUTE46,
      TL_TEXT_CAT_ATTRIBUTE47,
      TL_TEXT_CAT_ATTRIBUTE48,
      TL_TEXT_CAT_ATTRIBUTE49,
      TL_TEXT_CAT_ATTRIBUTE50,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    VALUES
    (
      PO_ATTRIBUTE_VALUES_TLP_S.nextval,
      PAVTI.DRAFT_ID,
      NULL, -- CHANGE_ACCEPTED_FLAG,
      NULL, -- DELETE_FLAG,
      PAVTI.PO_LINE_ID,
      '-2', -- REQ_TEMPLATE_NAME
      -2,   -- REQ_TEMPLATE_LINE_NUM
      NVL(PAVTI.IP_CATEGORY_ID, -2),
      NVL(PAVTI.INVENTORY_ITEM_ID, -2),
      PO_PDOI_PARAMS.g_request.org_id,
      PAVTI.LANGUAGE,
      NVL(PAVTI.DESCRIPTION, PAVTI.LINE_DESCRIPTION),
      DECODE(PAVTI.MANUFACTURER, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.MANUFACTURER),
      DECODE(PAVTI.COMMENTS, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.COMMENTS),
      DECODE(PAVTI.ALIAS, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.ALIAS),
      DECODE(PAVTI.LONG_DESCRIPTION, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.LONG_DESCRIPTION),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE1),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE2),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE3),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE4),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE5),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE6),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE7),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE8),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE9),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE10),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE11),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE12),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE13),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE14),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE15),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE16),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE17),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE18),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE19),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE20),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE21),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE22),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE23),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE24),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE25),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE26),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE27),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE28),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE29),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE30),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE31),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE32),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE33),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE34),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE35),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE36),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE37),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE38),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE39),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE40),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE41),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE42),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE43),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE44),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE45),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE46),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE47),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE48),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE49),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE50),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE51, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE51),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE52, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE52),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE53, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE53),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE54, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE54),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE55, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE55),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE56, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE56),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE57, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE57),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE58, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE58),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE59, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE59),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE60, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE60),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE61, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE61),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE62, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE62),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE63, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE63),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE64, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE64),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE65, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE65),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE66, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE66),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE67, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE67),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE68, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE68),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE69, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE69),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE70, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE70),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE71, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE71),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE72, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE72),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE73, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE73),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE74, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE74),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE75, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE75),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE76, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE76),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE77, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE77),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE78, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE78),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE79, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE79),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE80, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE80),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE81, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE81),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE82, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE82),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE83, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE83),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE84, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE84),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE85, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE85),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE86, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE86),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE87, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE87),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE88, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE88),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE89, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE89),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE90, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE90),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE91, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE91),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE92, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE92),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE93, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE93),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE94, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE94),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE95, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE95),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE96, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE96),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE97, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE97),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE98, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE98),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE99, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE99),
      DECODE(PAVTI.TL_TEXT_BASE_ATTRIBUTE100, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_BASE_ATTRIBUTE100),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE1, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE1),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE2, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE2),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE3, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE3),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE4, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE4),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE5, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE5),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE6, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE6),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE7, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE7),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE8, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE8),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE9, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE9),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE10, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE10),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE11, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE11),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE12, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE12),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE13, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE13),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE14, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE14),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE15, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE15),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE16, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE16),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE17, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE17),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE18, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE18),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE19, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE19),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE20, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE20),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE21, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE21),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE22, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE22),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE23, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE23),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE24, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE24),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE25, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE25),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE26, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE26),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE27, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE27),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE28, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE28),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE29, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE29),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE30, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE30),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE31, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE31),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE32, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE32),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE33, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE33),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE34, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE34),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE35, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE35),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE36, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE36),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE37, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE37),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE38, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE38),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE39, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE39),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE40, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE40),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE41, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE41),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE42, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE42),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE43, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE43),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE44, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE44),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE45, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE45),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE46, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE46),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE47, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE47),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE48, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE48),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE49, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE49),
      DECODE(PAVTI.TL_TEXT_CAT_ATTRIBUTE50, PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR, NULL, PAVTI.TL_TEXT_CAT_ATTRIBUTE50),
      NVL(PAVTI.LAST_UPDATE_LOGIN, FND_GLOBAL.login_id),
      NVL(PAVTI.LAST_UPDATED_BY, FND_GLOBAL.user_id),
      NVL(PAVTI.LAST_UPDATE_DATE, sysdate),
      NVL(PAVTI.CREATED_BY, FND_GLOBAL.user_id),
      NVL(PAVTI.CREATION_DATE, sysdate),
      NVL(PAVTI.REQUEST_ID, FND_GLOBAL.conc_request_id),
      NVL(PAVTI.PROGRAM_APPLICATION_ID, FND_GLOBAL.prog_appl_id),
      NVL(PAVTI.PROGRAM_ID, FND_GLOBAL.conc_program_id),
      NVL(PAVTI.PROGRAM_UPDATE_DATE, sysdate));

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
END merge_po_attr_values_tlp_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: reset_cat_attributes
--Function:
--  reset all category attribute values to NULL on attribute_values and
--  tlp tables if ip_category_id is changed
--Parameters:
--IN:
--p_index_tbl
--  mark down for which line we need to perform the reset
--p_po_line_id_tbl
--  list of po_line_id values. But only for lines marked in p_index_tbl,
--  we will perform the reset on category attributes
--p_draft_id_tbl
--  list of draft id values.
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reset_cat_attributes
(
  p_index_tbl       IN DBMS_SQL.NUMBER_TABLE,
  p_po_line_id_tbl  IN PO_TBL_NUMBER,
  p_draft_id_tbl    IN PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'reset_cat_attributes';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key      po_session_gt.key%TYPE;

  l_sync_attr_values_id_tbl     PO_TBL_NUMBER;
  l_sync_attr_values_tlp_id_tbl PO_TBL_NUMBER;
  l_draft_id_tbl                PO_TBL_NUMBER;
  l_delete_flag_tbl             PO_TBL_VARCHAR1;
  l_record_already_exist_tbl    PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_line_id_tbl', p_po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
  END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- get attribute_values_id we need to sync from txn tables
  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1
    )
    SELECT
      l_key,
      attribute_values_id,
      p_draft_id_tbl(i),
      'N'
    FROM  po_attribute_values
    WHERE po_line_id = p_po_line_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2, char1 BULK COLLECT INTO
    l_sync_attr_values_id_tbl, l_draft_id_tbl,
    l_delete_flag_tbl;

  d_position := 20;

  -- sync from txn table to draft table
  PO_ATTR_VALUES_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_id_tbl      => l_sync_attr_values_id_tbl,
    p_draft_id_tbl                 => l_draft_id_tbl,
    p_delete_flag_tbl              => l_delete_flag_tbl,
    x_record_already_exist_tbl     => l_record_already_exist_tbl
  );

  d_position := 30;

  -- update records in draft table
  FORALL i IN 1..l_sync_attr_values_id_tbl.COUNT
    UPDATE po_attribute_values_draft
    SET    TEXT_CAT_ATTRIBUTE1 = NULL,
           TEXT_CAT_ATTRIBUTE2 = NULL,
           TEXT_CAT_ATTRIBUTE3 = NULL,
           TEXT_CAT_ATTRIBUTE4 = NULL,
           TEXT_CAT_ATTRIBUTE5 = NULL,
           TEXT_CAT_ATTRIBUTE6 = NULL,
           TEXT_CAT_ATTRIBUTE7 = NULL,
           TEXT_CAT_ATTRIBUTE8 = NULL,
           TEXT_CAT_ATTRIBUTE9 = NULL,
           TEXT_CAT_ATTRIBUTE10 = NULL,
           TEXT_CAT_ATTRIBUTE11 = NULL,
           TEXT_CAT_ATTRIBUTE12 = NULL,
           TEXT_CAT_ATTRIBUTE13 = NULL,
           TEXT_CAT_ATTRIBUTE14 = NULL,
           TEXT_CAT_ATTRIBUTE15 = NULL,
           TEXT_CAT_ATTRIBUTE16 = NULL,
           TEXT_CAT_ATTRIBUTE17 = NULL,
           TEXT_CAT_ATTRIBUTE18 = NULL,
           TEXT_CAT_ATTRIBUTE19 = NULL,
           TEXT_CAT_ATTRIBUTE20 = NULL,
           TEXT_CAT_ATTRIBUTE21 = NULL,
           TEXT_CAT_ATTRIBUTE22 = NULL,
           TEXT_CAT_ATTRIBUTE23 = NULL,
           TEXT_CAT_ATTRIBUTE24 = NULL,
           TEXT_CAT_ATTRIBUTE25 = NULL,
           TEXT_CAT_ATTRIBUTE26 = NULL,
           TEXT_CAT_ATTRIBUTE27 = NULL,
           TEXT_CAT_ATTRIBUTE28 = NULL,
           TEXT_CAT_ATTRIBUTE29 = NULL,
           TEXT_CAT_ATTRIBUTE30 = NULL,
           TEXT_CAT_ATTRIBUTE31 = NULL,
           TEXT_CAT_ATTRIBUTE32 = NULL,
           TEXT_CAT_ATTRIBUTE33 = NULL,
           TEXT_CAT_ATTRIBUTE34 = NULL,
           TEXT_CAT_ATTRIBUTE35 = NULL,
           TEXT_CAT_ATTRIBUTE36 = NULL,
           TEXT_CAT_ATTRIBUTE37 = NULL,
           TEXT_CAT_ATTRIBUTE38 = NULL,
           TEXT_CAT_ATTRIBUTE39 = NULL,
           TEXT_CAT_ATTRIBUTE40 = NULL,
           TEXT_CAT_ATTRIBUTE41 = NULL,
           TEXT_CAT_ATTRIBUTE42 = NULL,
           TEXT_CAT_ATTRIBUTE43 = NULL,
           TEXT_CAT_ATTRIBUTE44 = NULL,
           TEXT_CAT_ATTRIBUTE45 = NULL,
           TEXT_CAT_ATTRIBUTE46 = NULL,
           TEXT_CAT_ATTRIBUTE47 = NULL,
           TEXT_CAT_ATTRIBUTE48 = NULL,
           TEXT_CAT_ATTRIBUTE49 = NULL,
           TEXT_CAT_ATTRIBUTE50 = NULL,
           NUM_CAT_ATTRIBUTE1 = NULL,
           NUM_CAT_ATTRIBUTE2 = NULL,
           NUM_CAT_ATTRIBUTE3 = NULL,
           NUM_CAT_ATTRIBUTE4 = NULL,
           NUM_CAT_ATTRIBUTE5 = NULL,
           NUM_CAT_ATTRIBUTE6 = NULL,
           NUM_CAT_ATTRIBUTE7 = NULL,
           NUM_CAT_ATTRIBUTE8 = NULL,
           NUM_CAT_ATTRIBUTE9 = NULL,
           NUM_CAT_ATTRIBUTE10 = NULL,
           NUM_CAT_ATTRIBUTE11 = NULL,
           NUM_CAT_ATTRIBUTE12 = NULL,
           NUM_CAT_ATTRIBUTE13 = NULL,
           NUM_CAT_ATTRIBUTE14 = NULL,
           NUM_CAT_ATTRIBUTE15 = NULL,
           NUM_CAT_ATTRIBUTE16 = NULL,
           NUM_CAT_ATTRIBUTE17 = NULL,
           NUM_CAT_ATTRIBUTE18 = NULL,
           NUM_CAT_ATTRIBUTE19 = NULL,
           NUM_CAT_ATTRIBUTE20 = NULL,
           NUM_CAT_ATTRIBUTE21 = NULL,
           NUM_CAT_ATTRIBUTE22 = NULL,
           NUM_CAT_ATTRIBUTE23 = NULL,
           NUM_CAT_ATTRIBUTE24 = NULL,
           NUM_CAT_ATTRIBUTE25 = NULL,
           NUM_CAT_ATTRIBUTE26 = NULL,
           NUM_CAT_ATTRIBUTE27 = NULL,
           NUM_CAT_ATTRIBUTE28 = NULL,
           NUM_CAT_ATTRIBUTE29 = NULL,
           NUM_CAT_ATTRIBUTE30 = NULL,
           NUM_CAT_ATTRIBUTE31 = NULL,
           NUM_CAT_ATTRIBUTE32 = NULL,
           NUM_CAT_ATTRIBUTE33 = NULL,
           NUM_CAT_ATTRIBUTE34 = NULL,
           NUM_CAT_ATTRIBUTE35 = NULL,
           NUM_CAT_ATTRIBUTE36 = NULL,
           NUM_CAT_ATTRIBUTE37 = NULL,
           NUM_CAT_ATTRIBUTE38 = NULL,
           NUM_CAT_ATTRIBUTE39 = NULL,
           NUM_CAT_ATTRIBUTE40 = NULL,
           NUM_CAT_ATTRIBUTE41 = NULL,
           NUM_CAT_ATTRIBUTE42 = NULL,
           NUM_CAT_ATTRIBUTE43 = NULL,
           NUM_CAT_ATTRIBUTE44 = NULL,
           NUM_CAT_ATTRIBUTE45 = NULL,
           NUM_CAT_ATTRIBUTE46 = NULL,
           NUM_CAT_ATTRIBUTE47 = NULL,
           NUM_CAT_ATTRIBUTE48 = NULL,
           NUM_CAT_ATTRIBUTE49 = NULL,
           NUM_CAT_ATTRIBUTE50 = NULL,
           LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
           LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATE_DATE = sysdate,
           REQUEST_ID = FND_GLOBAL.conc_request_id,
           PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
           PROGRAM_ID = FND_GLOBAL.conc_program_id,
           PROGRAM_UPDATE_DATE = sysdate
    WHERE  attribute_values_id = l_sync_attr_values_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

  d_position := 40;

  -- get attribute_values_tlp_id we need to sync from txn tables
  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1
    )
    SELECT
      l_key,
      attribute_values_tlp_id,
      p_draft_id_tbl(i),
      'N'
    FROM  po_attribute_values_tlp
    WHERE po_line_id = p_po_line_id_tbl(i);

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2, char1 BULK COLLECT INTO
    l_sync_attr_values_tlp_id_tbl, l_draft_id_tbl,
    l_delete_flag_tbl;

  d_position := 60;

  -- sync from txn table to draft table
  PO_ATTR_VALUES_TLP_DRAFT_PKG.sync_draft_from_txn
  (
    p_attribute_values_tlp_id_tbl  => l_sync_attr_values_tlp_id_tbl,
    p_draft_id_tbl                 => l_draft_id_tbl,
    p_delete_flag_tbl              => l_delete_flag_tbl,
    x_record_already_exist_tbl     => l_record_already_exist_tbl
  );

  d_position := 70;

  -- update records in draft table
  FORALL i IN 1..l_sync_attr_values_tlp_id_tbl.COUNT
    UPDATE po_attribute_values_tlp_draft
    SET    TL_TEXT_CAT_ATTRIBUTE1 = NULL,
           TL_TEXT_CAT_ATTRIBUTE2 = NULL,
           TL_TEXT_CAT_ATTRIBUTE3 = NULL,
           TL_TEXT_CAT_ATTRIBUTE4 = NULL,
           TL_TEXT_CAT_ATTRIBUTE5 = NULL,
           TL_TEXT_CAT_ATTRIBUTE6 = NULL,
           TL_TEXT_CAT_ATTRIBUTE7 = NULL,
           TL_TEXT_CAT_ATTRIBUTE8 = NULL,
           TL_TEXT_CAT_ATTRIBUTE9 = NULL,
           TL_TEXT_CAT_ATTRIBUTE10 = NULL,
           TL_TEXT_CAT_ATTRIBUTE11 = NULL,
           TL_TEXT_CAT_ATTRIBUTE12 = NULL,
           TL_TEXT_CAT_ATTRIBUTE13 = NULL,
           TL_TEXT_CAT_ATTRIBUTE14 = NULL,
           TL_TEXT_CAT_ATTRIBUTE15 = NULL,
           TL_TEXT_CAT_ATTRIBUTE16 = NULL,
           TL_TEXT_CAT_ATTRIBUTE17 = NULL,
           TL_TEXT_CAT_ATTRIBUTE18 = NULL,
           TL_TEXT_CAT_ATTRIBUTE19 = NULL,
           TL_TEXT_CAT_ATTRIBUTE20 = NULL,
           TL_TEXT_CAT_ATTRIBUTE21 = NULL,
           TL_TEXT_CAT_ATTRIBUTE22 = NULL,
           TL_TEXT_CAT_ATTRIBUTE23 = NULL,
           TL_TEXT_CAT_ATTRIBUTE24 = NULL,
           TL_TEXT_CAT_ATTRIBUTE25 = NULL,
           TL_TEXT_CAT_ATTRIBUTE26 = NULL,
           TL_TEXT_CAT_ATTRIBUTE27 = NULL,
           TL_TEXT_CAT_ATTRIBUTE28 = NULL,
           TL_TEXT_CAT_ATTRIBUTE29 = NULL,
           TL_TEXT_CAT_ATTRIBUTE30 = NULL,
           TL_TEXT_CAT_ATTRIBUTE31 = NULL,
           TL_TEXT_CAT_ATTRIBUTE32 = NULL,
           TL_TEXT_CAT_ATTRIBUTE33 = NULL,
           TL_TEXT_CAT_ATTRIBUTE34 = NULL,
           TL_TEXT_CAT_ATTRIBUTE35 = NULL,
           TL_TEXT_CAT_ATTRIBUTE36 = NULL,
           TL_TEXT_CAT_ATTRIBUTE37 = NULL,
           TL_TEXT_CAT_ATTRIBUTE38 = NULL,
           TL_TEXT_CAT_ATTRIBUTE39 = NULL,
           TL_TEXT_CAT_ATTRIBUTE40 = NULL,
           TL_TEXT_CAT_ATTRIBUTE41 = NULL,
           TL_TEXT_CAT_ATTRIBUTE42 = NULL,
           TL_TEXT_CAT_ATTRIBUTE43 = NULL,
           TL_TEXT_CAT_ATTRIBUTE44 = NULL,
           TL_TEXT_CAT_ATTRIBUTE45 = NULL,
           TL_TEXT_CAT_ATTRIBUTE46 = NULL,
           TL_TEXT_CAT_ATTRIBUTE47 = NULL,
           TL_TEXT_CAT_ATTRIBUTE48 = NULL,
           TL_TEXT_CAT_ATTRIBUTE49 = NULL,
           TL_TEXT_CAT_ATTRIBUTE50 = NULL,
           LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
           LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATE_DATE = sysdate,
           REQUEST_ID = FND_GLOBAL.conc_request_id,
           PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
           PROGRAM_ID = FND_GLOBAL.conc_program_id,
           PROGRAM_UPDATE_DATE = sysdate
    WHERE  attribute_values_tlp_id = l_sync_attr_values_tlp_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

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
END reset_cat_attributes;

END PO_PDOI_MOVE_TO_DRAFT_TABS_PVT;

/
