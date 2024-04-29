--------------------------------------------------------
--  DDL for Package Body PO_PDOI_ITEM_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_ITEM_PROCESS_PVT" AS
/* $Header: PO_PDOI_ITEM_PROCESS_PVT.plb 120.8.12010000.5 2014/10/23 23:45:48 pla ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_ITEM_PROCESS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------
PROCEDURE construct_item_records
(
  p_lines   IN PO_PDOI_TYPES.lines_rec_type,
  x_items   OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE derive_default_loc_attrs
(
  x_items   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE identify_actions
(
  x_items                       IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_unprocessed_row_tbl         IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_proc_row_in_round_tbl       OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_inv_index_tbl     OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_master_index_tbl  OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_ship_to_index_tbl OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_update_index_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE insert_master_item
(
  p_org_type  IN VARCHAR2,
  p_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_items     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE update_master_item
(
  p_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_items     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);
--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: create_items
--Function: create or update item in item master for default inv org,
--          default master org and each ship_to org.
--          The new item id will be set back to x_lines.
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_items
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'create_items';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_items    PO_PDOI_TYPES.line_locs_rec_type;

  l_create_in_inv_index_tbl     DBMS_SQL.NUMBER_TABLE;
  l_create_in_master_index_tbl  DBMS_SQL.NUMBER_TABLE;
  l_create_in_ship_to_index_tbl DBMS_SQL.NUMBER_TABLE;
  l_update_index_tbl            DBMS_SQL.NUMBER_TABLE;

  -- identify rows that have not been processed
  l_unprocessed_row_tbl         DBMS_SQL.NUMBER_TABLE;
  l_index                       NUMBER;

  -- rows processed in current loop round
  l_proc_row_in_round_tbl       DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_ITEM_CREATION);

  -- fetch location attributes and contruct item record on each line location
  construct_item_records
  (
    p_lines   => x_lines,
    x_items   => l_items
  );

  d_position := 10;

  -- derive and default logic for fetched location attributes
  derive_default_loc_attrs
  (
    x_items   => l_items
  );

  d_position := 20;

   -- initialize table containing the row number(index)
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => l_items.rec_count,
    x_num_list => l_unprocessed_row_tbl
  );

  -- remove records that has derivation errors on location attrs;
  -- we won't create/update items for such records
  FOR i IN 1..l_items.rec_count
  LOOP
    IF (l_items.error_flag_tbl(i) = FND_API.g_TRUE) THEN
      l_unprocessed_row_tbl.DELETE(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'record removed due to ' ||
                    'location derivation error', i);
        PO_LOG.stmt(d_module, d_position, 'set line record error ' ||
                    'flag to Y', l_items.line_ref_index_tbl(i));
      END IF;

      -- set corresponding po_line's error_flag to 'Y'
      x_lines.error_flag_tbl(l_items.line_ref_index_tbl(i)) :=
        FND_API.g_TRUE;

    END IF;
  END LOOP;

  -- create/update items
  -- item with same item number will be processed in different
  -- loop round;
  LOOP
    IF (l_unprocessed_row_tbl.COUNT = 0) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'all rows processed');
      END IF;

      EXIT;
    END IF;

    -- identify rows for which items need to be created/updated
    identify_actions
    (
      x_items                       => l_items,
      x_unprocessed_row_tbl         => l_unprocessed_row_tbl,
      x_proc_row_in_round_tbl       => l_proc_row_in_round_tbl,
      x_create_in_inv_index_tbl     => l_create_in_inv_index_tbl,
      x_create_in_master_index_tbl  => l_create_in_master_index_tbl,
      x_create_in_ship_to_index_tbl => l_create_in_ship_to_index_tbl,
      x_update_index_tbl            => l_update_index_tbl
    );

    IF (PO_LOG.d_stmt) THEN
      l_index := l_create_in_inv_index_tbl.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP
        PO_LOG.stmt(d_module, d_position, 'l_create_in_inv_index_tbl('||l_index||')',
                    l_create_in_inv_index_tbl(l_index));
	    l_index := l_create_in_inv_index_tbl.NEXT(l_index);
      END LOOP;

      l_index := l_create_in_master_index_tbl.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP
        PO_LOG.stmt(d_module, d_position, 'l_create_in_master_index_tbl('||l_index||')',
                    l_create_in_master_index_tbl(l_index));
	    l_index := l_create_in_master_index_tbl.NEXT(l_index);
      END LOOP;

      l_index := l_create_in_ship_to_index_tbl.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP
        PO_LOG.stmt(d_module, d_position, 'l_create_in_ship_to_index_tbl('||l_index||')',
                    l_create_in_ship_to_index_tbl(l_index));
	    l_index := l_create_in_ship_to_index_tbl.NEXT(l_index);
      END LOOP;

      l_index := l_update_index_tbl.FIRST;
      WHILE (l_index IS NOT NULL)
      LOOP
        PO_LOG.stmt(d_module, d_position, 'l_update_index_tbl('||l_index||')',
                    l_update_index_tbl(l_index));
	    l_index := l_update_index_tbl.NEXT(l_index);
      END LOOP;
    END IF;

    d_position := 30;

    -- insert item in inv, master and ship_to orgs
    -- new item_id will be set back to l_items

    -- bug5247736
    -- The order of inv org for which the item is to be created should be
    -- 1) Master Org
    -- 2) Inv Org specified in FSP
    -- 3) Ship To Org

    -- Bug7117320: As part of fix 5247736, value for p_index_tbl was not changed
    -- Corrected the param value.

    insert_master_item
    (
      p_org_type  => 'MASTER',
      p_index_tbl => l_create_in_master_index_tbl,
      x_items     => l_items
    );

    d_position := 40;

    insert_master_item
    (
      p_org_type  => 'INV',
      p_index_tbl => l_create_in_inv_index_tbl,
      x_items     => l_items
    );

    d_position := 50;

    insert_master_item
    (
      p_org_type  => 'SHIP_TO',
      p_index_tbl => l_create_in_ship_to_index_tbl,
      x_items     => l_items
    );

    d_position := 60;

    -- update items in item master
    update_master_item
    (
      p_index_tbl  => l_update_index_tbl,
      x_items      => l_items
    );

    d_position := 70;

    -- set item_id and error_flag back to x_lines
    l_index := l_proc_row_in_round_tbl.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'from item index',
                    l_index);
        PO_LOG.stmt(d_module, d_position, 'to line index',
                    l_items.line_ref_index_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'new item id',
                    l_items.ln_item_id_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'new error flag',
                    l_items.error_flag_tbl(l_index));
      END IF;

      x_lines.item_id_tbl(l_items.line_ref_index_tbl(l_index)) :=
        l_items.ln_item_id_tbl(l_index);

      x_lines.error_flag_tbl(l_items.line_ref_index_tbl(l_index)) :=
        l_items.error_flag_tbl(l_index);

      l_index := l_proc_row_in_round_tbl.NEXT(l_index);
    END LOOP;

    d_position := 80;

    -- if there is error occured on item creation, error out the
    -- other unprocessed rows in same po_line
    l_index := l_unprocessed_row_tbl.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
      IF (x_lines.error_flag_tbl(l_items.line_ref_index_tbl(l_index)) =
            FND_API.g_TRUE) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'reject item on index',
                      l_index);
        END IF;

        -- no need to do further processing since line has error
        l_unprocessed_row_tbl.DELETE(l_index);
      END IF;

      l_index := l_unprocessed_row_tbl.NEXT(l_index);
    END LOOP;
  END LOOP;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_ITEM_CREATION);

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
END create_items;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: construct_item_records
--Function:
--  Read all the locations for the lines within the batch. Then construct
--  item records which contain both the line and location info.
--  The records will be used later for derive, default and insert/update
--  into item master
--Parameters:
--IN:
--  p_lines
--    record which stores all the line rows within the batch;
--IN OUT:
--  x_items
--    the item records containing line info for each location
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE construct_item_records
(
  p_lines   IN PO_PDOI_TYPES.lines_rec_type,
  x_items   OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'construct_item_records';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key        PO_SESSION_GT.key%TYPE;
  l_index_tbl  DBMS_SQL.NUMBER_TABLE;
  l_line_index NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;

  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => p_lines.rec_count,
    x_num_list  => l_index_tbl
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'error flag', p_lines.error_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'need to reject flag',
	            p_lines.need_to_reject_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'purchase basis', p_lines.purchase_basis_tbl);
    PO_LOG.stmt(d_module, d_position, 'item', p_lines.item_tbl);
    PO_LOG.stmt(d_module, d_position, 'item id', p_lines.item_id_tbl);
  END IF;

  -- insert interface_line_ids within the batch in po_session_gt table;
  -- Thus it can be used to bulk select location rows
  FORALL i IN 1..p_lines.rec_count
    INSERT INTO po_session_gt
    (
      key,
      num1,  -- index
      num2,  -- interface_line_id
      num3,  -- po_header_id,
      num4   -- draft_id
    )
    SELECT
      l_key,
      l_index_tbl(i),
      p_lines.intf_line_id_tbl(i),
      p_lines.hd_po_header_id_tbl(i),
      p_lines.draft_id_tbl(i)
    FROM   DUAL
    WHERE  p_lines.error_flag_tbl(i) = FND_API.g_FALSE
    AND    p_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE
    AND    p_lines.purchase_basis_tbl(i) NOT IN ('TEMP LABOR', 'SERVICES')
    AND    (p_lines.item_tbl(i) IS NOT NULL OR
            p_lines.item_id_tbl(i) IS NOT NULL);

  d_position := 10;

  -- read location rows and put into x_items
  /* Bug 6926550 modified the where clause to select
   only matched key records from po_session_gt*/
  SELECT
    -- attributes from headers
    NVL(draft_headers.ship_to_location_id, txn_headers.ship_to_location_id),
    NVL(draft_headers.vendor_id, txn_headers.vendor_id),

    -- attributes from line interface
    intf_lines.unit_weight,
    intf_lines.unit_volume,
    intf_lines.item_attribute_category,
    intf_lines.item_attribute1,
    intf_lines.item_attribute2,
    intf_lines.item_attribute3,
    intf_lines.item_attribute4,
    intf_lines.item_attribute5,
    intf_lines.item_attribute6,
    intf_lines.item_attribute7,
    intf_lines.item_attribute8,
    intf_lines.item_attribute9,
    intf_lines.item_attribute10,
    intf_lines.item_attribute11,
    intf_lines.item_attribute12,
    intf_lines.item_attribute13,
    intf_lines.item_attribute14,
    intf_lines.item_attribute15,

    -- attributes from location inteface
    --  changes for bug 19697226 start
 nvl(intf_locs.inspection_required_flag,intf_lines.inspection_required_flag),
nvl(intf_locs.receipt_required_flag,intf_lines.receipt_required_flag),
nvl(intf_locs.invoice_close_tolerance,intf_lines.invoice_close_tolerance),
nvl(intf_locs.receive_close_tolerance,intf_lines.receive_close_tolerance),
nvl(intf_locs.days_early_receipt_allowed,intf_lines.days_early_receipt_allowed),
nvl(intf_locs.days_late_receipt_allowed,intf_lines.days_late_receipt_allowed),
nvl(intf_locs.enforce_ship_to_location_code,intf_lines.enforce_ship_to_location_code),
nvl(intf_locs.allow_substitute_receipts_flag,intf_lines.allow_substitute_receipts_flag),
nvl(intf_locs.receiving_routing,intf_lines.receiving_routing),
nvl(intf_locs.receiving_routing_id,intf_lines.receiving_routing_id),
nvl(intf_locs.receipt_days_exception_code,intf_lines.receipt_days_exception_code),
nvl(intf_locs.ship_to_organization_code,intf_lines.ship_to_organization_code),
nvl(intf_locs.ship_to_organization_id,intf_lines.ship_to_organization_id),
nvl(intf_locs.ship_to_location,intf_lines.ship_to_location),
nvl(intf_locs.ship_to_location_id,intf_lines.ship_to_location_id),
nvl(intf_locs.taxable_flag,intf_lines.taxable_flag),
nvl(intf_locs.qty_rcv_exception_code,intf_lines.qty_rcv_exception_code),
nvl(intf_locs.qty_rcv_tolerance,intf_lines.qty_rcv_tolerance),
    --  changes for bug 19697226 end
    -- assign dummay values on these columns
    -- so they won't be defaulted in location default logic
    'DUMMY', -- shipment_type
    0,       -- shipment_num
    0,       -- line_location_id
    'DUMMY', -- match_option
    NULL,    -- accrue_on_receipt_flag
    NULL,    -- firm_flag
    NULL,    -- tax_name
    NULL,    -- payment_terms
    NULL,    -- terms_id
    NULL,    -- header terms_id
    NULL,    -- fob
    NULL,    -- header fob
    NULL,    -- freight_carrier
    NULL,    -- header freight_carrier
    NULL,    -- freight_term
    NULL,    -- header freight_term
    -1,      -- price_override
    -1,      -- price_discount
    -1,      -- outsourced_assembly
    NULL,    -- value_basis
    NULL,    -- matching_basis
    NULL,    -- unit_of_measure

    -- standard who columns
    sysdate,
    fnd_global.user_id,
    fnd_global.login_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.conc_request_id,
    fnd_global.prog_appl_id,
    fnd_global.conc_program_id,
    sysdate,

    -- error_flag
    FND_API.g_FALSE,

    -- reference index in po_lines
    gt.num1
  BULK COLLECT INTO
    -- attributes from headers
    x_items.hd_ship_to_loc_id_tbl,
    x_items.hd_vendor_id_tbl,

    -- attributes from lines
    x_items.ln_unit_weight_tbl,
    x_items.ln_unit_volume_tbl,
    x_items.ln_item_attribute_category_tbl,
    x_items.ln_item_attribute1_tbl,
    x_items.ln_item_attribute2_tbl,
    x_items.ln_item_attribute3_tbl,
    x_items.ln_item_attribute4_tbl,
    x_items.ln_item_attribute5_tbl,
    x_items.ln_item_attribute6_tbl,
    x_items.ln_item_attribute7_tbl,
    x_items.ln_item_attribute8_tbl,
    x_items.ln_item_attribute9_tbl,
    x_items.ln_item_attribute10_tbl,
    x_items.ln_item_attribute11_tbl,
    x_items.ln_item_attribute12_tbl,
    x_items.ln_item_attribute13_tbl,
    x_items.ln_item_attribute14_tbl,
    x_items.ln_item_attribute15_tbl,

    -- attributes from location inteface
    x_items.inspection_required_flag_tbl,
    x_items.receipt_required_flag_tbl,
    x_items.invoice_close_tolerance_tbl,
    x_items.receive_close_tolerance_tbl,
    x_items.days_early_receipt_allowed_tbl,
    x_items.days_late_receipt_allowed_tbl,
    x_items.enforce_ship_to_loc_code_tbl,
    x_items.allow_sub_receipts_flag_tbl,
    x_items.receiving_routing_tbl,
    x_items.receiving_routing_id_tbl,
    x_items.receipt_days_except_code_tbl,
    x_items.ship_to_org_code_tbl,
    x_items.ship_to_org_id_tbl,
    x_items.ship_to_loc_tbl,
    x_items.ship_to_loc_id_tbl,
    x_items.taxable_flag_tbl,
    x_items.qty_rcv_exception_code_tbl,
    x_items.qty_rcv_tolerance_tbl,

    -- columns with dummay non-empty values
    x_items.shipment_type_tbl,
    x_items.shipment_num_tbl,
    x_items.line_loc_id_tbl,
    x_items.match_option_tbl,
    x_items.accrue_on_receipt_flag_tbl,
    x_items.firm_flag_tbl,
    x_items.tax_name_tbl,
    x_items.payment_terms_tbl,
    x_items.terms_id_tbl,
    x_items.hd_terms_id_tbl,
    x_items.fob_tbl,
    x_items.hd_fob_tbl,
    x_items.freight_carrier_tbl,
    x_items.hd_freight_carrier_tbl,
    x_items.freight_term_tbl,
    x_items.hd_freight_term_tbl,
    x_items.price_override_tbl,
    x_items.price_discount_tbl,
    x_items.outsourced_assembly_tbl,
    x_items.value_basis_tbl,
    x_items.matching_basis_tbl,
    x_items.unit_of_measure_tbl,

    -- standard who columns
    x_items.last_update_date_tbl,
    x_items.last_updated_by_tbl,
    x_items.last_update_login_tbl,
    x_items.creation_date_tbl,
    x_items.created_by_tbl,
    x_items.request_id_tbl,
    x_items.program_application_id_tbl,
    x_items.program_id_tbl,
    x_items.program_update_date_tbl,

    -- error flag
    x_items.error_flag_tbl,

    -- reference index in p_lines
    x_items.line_ref_index_tbl
  FROM   po_line_locations_interface intf_locs,
         po_lines_interface intf_lines,
         po_headers_draft_all draft_headers,
         po_headers_all txn_headers,
         po_session_gt gt
  WHERE  gt.num2 = intf_lines.interface_line_id
  AND    intf_lines.interface_line_id = intf_locs.interface_line_id(+) --    --  changes for bug 19697226
  AND    intf_locs.processing_id(+) = PO_PDOI_PARAMS.g_processing_id   --  changes for bug 19697226
  AND    gt.num3 = draft_headers.po_header_id(+)
  AND    gt.num4 = draft_headers.draft_id(+)
  AND    gt.num3 = txn_headers.po_header_id(+)
  AND    gt.key  = l_key
  ORDER BY gt.num1, intf_locs.interface_line_location_id;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'item count',
                x_items.rec_count);
  END IF;

  d_position := 20;

  -- bug5106386
  -- Initialize all pl/sql tables that are not part of the query
  PO_PDOI_TYPES.fill_all_line_locs_attr
  ( p_num_records => x_items.line_ref_index_tbl.COUNT,
    x_line_locs   => x_items
  );

  FOR i IN 1..x_items.rec_count
  LOOP
    l_line_index := x_items.line_ref_index_tbl(i);

    x_items.intf_header_id_tbl(i) := p_lines.intf_header_id_tbl(l_line_index);
    x_items.intf_line_id_tbl(i) := p_lines.intf_line_id_tbl(l_line_index);
    x_items.ln_po_line_id_tbl(i) := p_lines.po_line_id_tbl(l_line_index);
    x_items.ln_item_tbl(i) := p_lines.item_tbl(l_line_index);
    x_items.ln_item_id_tbl(i) := p_lines.item_id_tbl(l_line_index);
    x_items.ln_item_desc_tbl(i) := p_lines.item_desc_tbl(l_line_index);
    x_items.ln_unit_of_measure_tbl(i) := p_lines.unit_of_measure_tbl(l_line_index);
    x_items.ln_list_price_per_unit_tbl(i) := p_lines.list_price_per_unit_tbl(l_line_index);
    x_items.ln_market_price_tbl(i) := p_lines.market_price_tbl(l_line_index);
    x_items.ln_un_number_id_tbl(i) := p_lines.un_number_id_tbl(l_line_index);
    x_items.ln_hazard_class_id_tbl(i) := p_lines.hazard_class_id_tbl(l_line_index);
    x_items.ln_qty_rcv_exception_code_tbl(i) := p_lines.qty_rcv_exception_code_tbl(l_line_index);
    x_items.ln_weight_uom_code_tbl(i) := p_lines.weight_uom_code_tbl(l_line_index);
    x_items.ln_volume_uom_code_tbl(i) := p_lines.volume_uom_code_tbl(l_line_index);
    x_items.ln_template_id_tbl(i) := p_lines.template_id_tbl(l_line_index);
    x_items.ln_category_id_tbl(i) := p_lines.category_id_tbl(l_line_index);
    x_items.ln_order_type_lookup_code_tbl(i) := p_lines.order_type_lookup_code_tbl(l_line_index);
    x_items.ln_line_type_id_tbl(i) := p_lines.line_type_id_tbl(l_line_index);
    x_items.ln_matching_basis_tbl(i) := p_lines.matching_basis_tbl(l_line_index);
    x_items.ln_unit_price_tbl(i) := p_lines.unit_price_tbl(l_line_index);
    x_items.hd_currency_code_tbl(i) := p_lines.hd_currency_code_tbl(l_line_index); --- Bug# 11834816

  END LOOP;

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
END construct_item_records;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_default_loc_attrs
--Function:
--  derive and default location related attributes read from locations
--  interface table; no need to derive and default line related attributes
--  since it is done before creating/updating items in item master
--Parameters:
--IN:
--IN OUT:
--  x_items
--    the item records containing line info for each location
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_default_loc_attrs
(
  x_items   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_default_loc_attrs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- derive attributes from location interface table
  PO_PDOI_LINE_LOC_PROCESS_PVT.derive_line_locs
  (
    x_line_locs   => x_items
  );

  d_position := 10;

  -- default attributes from location interface table
  PO_PDOI_LINE_LOC_PROCESS_PVT.default_line_locs
  (
    x_line_locs   => x_items
  );

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
END derive_default_loc_attrs;

-----------------------------------------------------------------------
--Start of Comments
--Name: identify_actions
--Function:
--  This procedure is to determine for which location and organization,
--  we need to create/update items in item master;
--  To create an item, the item number must be non-empty; To update
--  an item, item id must be non-empty after line derivation logic;
--  Items can be created in 3 organizations: default inv org, default
--  master org and ship_to org;
--  Items can only be updated in default master org
--Parameters:
--IN:
--  p_items
--   the record containing item information
--IN OUT:
--OUT:
--  x_create_index_tbl
--    index of p_items for which we need to create an item; The organizations
--    in which items are created are specified in x_create_org_id_tbl
--  x_create_org_id_tbl
--    The organizations in which items are created in item master;
--    The values can be default inv org id, default master org id
--    or ship_to org id on each location
--  x_update_index_tbl
--    index of p_items for which items are going to be updated
--End of Comments
------------------------------------------------------------------------
PROCEDURE identify_actions
(
  x_items                       IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_unprocessed_row_tbl         IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_proc_row_in_round_tbl       OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_inv_index_tbl     OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_master_index_tbl  OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_create_in_ship_to_index_tbl OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_update_index_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'identify_actions';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index                    NUMBER;
  l_key                      PO_SESSION_GT.key%TYPE;

  -- variables used to read result from po_session_gt table
  l_index_tbl                PO_TBL_NUMBER;
  l_org_id_tbl               PO_TBL_NUMBER;
  l_item_id_tbl              PO_TBL_NUMBER;

  -- flag to indicate whether item exists in some orgs
  l_exist_in_ship_to_org_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_exist_in_master_org_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_exist_in_inv_org_tbl     PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

  -- hashtable on item number
  TYPE item_ref_type         IS TABLE OF NUMBER INDEX BY VARCHAR2(1000);
  l_item_ref_tbl             item_ref_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- allocate memory for nested table
  l_exist_in_inv_org_tbl.EXTEND(x_items.rec_count);
  l_exist_in_master_org_tbl.EXTEND(x_items.rec_count);
  l_exist_in_ship_to_org_tbl.EXTEND(x_items.rec_count);

  d_position := 10;

  -- determine rows that are going to be processed in this
  -- procedure call
  l_index := x_unprocessed_row_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    IF (NOT l_item_ref_tbl.EXISTS(x_items.ln_item_tbl(l_index))) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'process row index in current round',
                    l_index);
      END IF;

      -- can be processed in this time of procedure call
      x_proc_row_in_round_tbl(l_index) := l_index;

      -- remove this row from unprocessed rows list
      x_unprocessed_row_tbl.DELETE(l_index);

      -- register this item_num in hashtable
      --Bug 6956962 <start>
		 if x_items.ln_item_tbl(l_index) is not null then
		    l_item_ref_tbl(x_items.ln_item_tbl(l_index)) := l_index;
		 else
		    l_item_ref_tbl(x_items.ln_item_id_tbl(l_index)) := l_index;
		 end if;
      --l_item_ref_tbl(x_items.ln_item_tbl(l_index)) := l_index;
      -- Bug 6956962 <end>

      -- set initial values for l_exist_in_xxx_org_tbl to 'N'
      l_exist_in_inv_org_tbl(l_index) := FND_API.g_FALSE;
      l_exist_in_master_org_tbl(l_index) := FND_API.g_FALSE;
      l_exist_in_ship_to_org_tbl(l_index) := FND_API.g_FALSE;
    END IF;

    l_index := x_unprocessed_row_tbl.NEXT(l_index);
  END LOOP;

  d_position := 20;

  l_key := PO_CORE_S.get_session_gt_nextval;
  -- check whether item exists in default inv org, default master
  -- org or ship_to org
  FORALL i IN INDICES OF x_proc_row_in_round_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      l_key,
      x_proc_row_in_round_tbl(i),
      organization_id,
      inventory_item_id
    FROM  mtl_system_items_vl
    WHERE organization_id IN
            (PO_PDOI_PARAMS.g_sys.def_inv_org_id,
             PO_PDOI_PARAMS.g_sys.master_inv_org_id,
             x_items.ship_to_org_id_tbl(i)
            )
    AND   (concatenated_segments = x_items.ln_item_tbl(i)
          OR inventory_item_id = x_items.ln_item_id_tbl(i)) ;  --6956962

          --concatenated_segments = x_items.ln_item_tbl(i);

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_org_id_tbl, l_item_id_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'i', i);
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'l_org_id_tbl(i)', l_org_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'l_item_id_tbl(i)', l_item_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'ship_to_org_id_tbl(l_index)',
                  x_items.ship_to_org_id_tbl(l_index));
    END IF;

    IF (l_org_id_tbl(i) = PO_PDOI_PARAMS.g_sys.def_inv_org_id) THEN
      l_exist_in_inv_org_tbl(l_index) := FND_API.g_TRUE;
      x_items.ln_item_id_tbl(l_index) := l_item_id_tbl(i);
    END IF;

    IF (l_org_id_tbl(i) = PO_PDOI_PARAMS.g_sys.master_inv_org_id) THEN
      l_exist_in_master_org_tbl(l_index) := FND_API.g_TRUE;
      x_items.ln_item_id_tbl(l_index) := l_item_id_tbl(i);
    END IF;

    IF (l_org_id_tbl(i) = x_items.ship_to_org_id_tbl(l_index)) THEN
      l_exist_in_ship_to_org_tbl(l_index) := FND_API.g_TRUE;
      x_items.ln_item_id_tbl(l_index) := l_item_id_tbl(i);
    END IF;
  END LOOP;

  d_position := 40;

  -- depend on whether item exists in item master, assign actions
  l_index := x_proc_row_in_round_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'exist_in_inv_org',
                  l_exist_in_inv_org_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'exist_in_ship_to_org',
                  l_exist_in_ship_to_org_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'exist_in_master_org',
                  l_exist_in_master_org_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'ship_to_org_id',
                  x_items.ship_to_org_id_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'item_id',
                  x_items.ln_item_id_tbl(l_index));
    END IF;

    IF (l_exist_in_inv_org_tbl(l_index) = FND_API.g_FALSE OR
        l_exist_in_ship_to_org_tbl(l_index) = FND_API.g_FALSE) THEN
      -- set whether item needs to be created in inv/master org
      IF (l_exist_in_master_org_tbl(l_index) = FND_API.g_FALSE) THEN
        x_create_in_master_index_tbl(l_index) := l_index;

        IF (l_exist_in_inv_org_tbl(l_index) = FND_API.g_FALSE AND
            PO_PDOI_PARAMS.g_sys.master_inv_org_id <>
              PO_PDOI_PARAMS.g_sys.def_inv_org_id) THEN
          x_create_in_inv_index_tbl(l_index) := l_index;
        END IF;
      END IF;

      d_position := 50;

      -- set flag for whether item needs to be created in ship_to org
      IF (l_exist_in_ship_to_org_tbl(l_index) = FND_API.g_FALSE AND
          x_items.ship_to_org_id_tbl(l_index) IS NOT NULL AND
          x_items.ship_to_org_id_tbl(l_index) <> PO_PDOI_PARAMS.g_sys.master_inv_org_id AND
          x_items.ship_to_org_id_tbl(l_index) <> PO_PDOI_PARAMS.g_sys.def_inv_org_id) THEN
        x_create_in_ship_to_index_tbl(l_index) := l_index;
      END IF;
    ELSIF (x_items.ln_item_id_tbl(l_index) IS NOT NULL) THEN
        -- for each po line, if item_id is not empty, then update item in item master
        x_update_index_tbl(l_index) := l_index;
    END IF;

    l_index := x_proc_row_in_round_tbl.NEXT(l_index);
  END LOOP;

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
END identify_actions;

-----------------------------------------------------------------------
--Start of Comments
--Name: insert_master_item
--Function:
--  This procedure is to create items in item master;
--  we will set item_id in x_items if creation is successful;
--  and set error_flag to g_TRUE if failed
--Parameters:
--IN:
--  p_org_type
--    organization type in which items are going to be created;
--    the values can be 'INV', 'MASTER' or 'SHIP_TO'
--  p_index_tbl
--    index of x_items for which we need to create an item;
--IN OUT:
--  x_items
--   the record containing item information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE insert_master_item
(
  p_org_type  IN VARCHAR2,
  p_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_items     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'insert_master_item';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_set_process_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_index              NUMBER;

  -- key value used to identify records in po_session_gt
  l_key                PO_SESSION_GT.key%TYPE;

  -- variables used to call Inventory API
  l_org_id             NUMBER;
  l_err_text           VARCHAR2(3000);
  l_return_code        NUMBER;

  -- variables used to get processed result from interface table
  l_index_tbl          PO_TBL_NUMBER;
  l_process_flag_tbl   PO_TBL_NUMBER;
  l_transaction_id_tbl PO_TBL_NUMBER;
  l_item_id_tbl        PO_TBL_NUMBER;
  l_org_id_tbl         PO_TBL_NUMBER;
  l_revision_tbl       PO_TBL_VARCHAR5;
  l_category_id_tbl    DBMS_SQL.NUMBER_TABLE;

  -- rows that return errors when creating items
  l_error_index_tbl    DBMS_SQL.NUMBER_TABLE;
  l_table_name_tbl     PO_TBL_VARCHAR30;
  l_message_name_tbl   PO_TBL_VARCHAR30;
  l_column_name_tbl    PO_TBL_VARCHAR100;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_org_type', p_org_type);
  END IF;

  -- insert data in item interface table
  l_set_process_id_tbl.EXTEND(x_items.rec_count);
  l_index := p_index_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    l_set_process_id_tbl(l_index) :=
      PO_PDOI_MAINPROC_UTL_PVT.get_next_set_process_id;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'set process id',
                  l_set_process_id_tbl(l_index));
    END IF;

    l_index := p_index_tbl.NEXT(l_index);
  END LOOP;

  d_position := 10;

  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
    (
      process_flag,
      set_process_id,
      transaction_type,
      item_number,
      inventory_item_id,
      description,
      purchasing_item_flag,
      inventory_item_flag,
      purchasing_enabled_flag,
      primary_unit_of_measure,
      list_price_per_unit,
      market_price,
      un_number_id,
      hazard_class_id,
      taxable_flag,
      inspection_required_flag,
      receipt_required_flag,
      invoice_close_tolerance,
      receive_close_tolerance,
      days_early_receipt_allowed,
      days_late_receipt_allowed,
      enforce_ship_to_location_code,
      allow_substitute_receipts_flag,
      receiving_routing_id,
      qty_rcv_tolerance,
      qty_rcv_exception_code,
      receipt_days_exception_code,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      organization_id,
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
      unit_weight,
      weight_uom_code,
      volume_uom_code,
      unit_volume,
      template_id
    )
    VALUES
    (
      1,  -- process_flag
      l_set_process_id_tbl(i),
      'CREATE', -- transaction_type
      x_items.ln_item_tbl(i),
      x_items.ln_item_id_tbl(i),
      x_items.ln_item_desc_tbl(i),
      'Y',   -- purchasing_item_flag
      decode(x_items.ln_template_id_tbl(i), NULL, 'Y', NULL),     -- inventory_item_flag
      'Y',     -- purchasing_enabled_flag,
      x_items.ln_unit_of_measure_tbl(i),
      x_items.ln_list_price_per_unit_tbl(i),
      x_items.ln_market_price_tbl(i),
      x_items.ln_un_number_id_tbl(i),
      x_items.ln_hazard_class_id_tbl(i),
      x_items.taxable_flag_tbl(i),
      x_items.inspection_required_flag_tbl(i),
      x_items.receipt_required_flag_tbl(i),
      x_items.invoice_close_tolerance_tbl(i),
      x_items.receive_close_tolerance_tbl(i),
      x_items.days_early_receipt_allowed_tbl(i),
      x_items.days_late_receipt_allowed_tbl(i),
      x_items.enforce_ship_to_loc_code_tbl(i),
      x_items.allow_sub_receipts_flag_tbl(i),
      x_items.receiving_routing_id_tbl(i),
      x_items.qty_rcv_tolerance_tbl(i),
      x_items.qty_rcv_exception_code_tbl(i),
      x_items.receipt_days_except_code_tbl(i),
      x_items.last_update_date_tbl(i),
      x_items.last_updated_by_tbl(i),
      x_items.last_update_login_tbl(i),
      x_items.creation_date_tbl(i),
      x_items.created_by_tbl(i),
      x_items.request_id_tbl(i),
      x_items.program_application_id_tbl(i),
      x_items.program_id_tbl(i),
      x_items.program_update_date_tbl(i),
      DECODE(p_org_type, 'MASTER', PO_PDOI_PARAMS.g_sys.master_inv_org_id,
                         'INV',    PO_PDOI_PARAMS.g_sys.def_inv_org_id,
                         x_items.ship_to_org_id_tbl(i)),  -- organization_id
      x_items.ln_item_attribute_category_tbl(i),
      x_items.ln_item_attribute1_tbl(i),
      x_items.ln_item_attribute2_tbl(i),
      x_items.ln_item_attribute3_tbl(i),
      x_items.ln_item_attribute4_tbl(i),
      x_items.ln_item_attribute5_tbl(i),
      x_items.ln_item_attribute6_tbl(i),
      x_items.ln_item_attribute7_tbl(i),
      x_items.ln_item_attribute8_tbl(i),
      x_items.ln_item_attribute9_tbl(i),
      x_items.ln_item_attribute10_tbl(i),
      x_items.ln_item_attribute11_tbl(i),
      x_items.ln_item_attribute12_tbl(i),
      x_items.ln_item_attribute13_tbl(i),
      x_items.ln_item_attribute14_tbl(i),
      x_items.ln_item_attribute15_tbl(i),
      x_items.ln_unit_weight_tbl(i),
      x_items.ln_weight_uom_code_tbl(i),
      x_items.ln_volume_uom_code_tbl(i),
      x_items.ln_unit_volume_tbl(i),
      x_items.ln_template_id_tbl(i)
    );

  d_position := 20;

  -- Call inventory API to handle rows in item interface table
  l_index := p_index_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    IF (p_org_type = 'MASTER') THEN
      l_org_id := PO_PDOI_PARAMS.g_sys.master_inv_org_id;
    ELSIF (p_org_type = 'INV') THEN
      l_org_id := PO_PDOI_PARAMS.g_sys.def_inv_org_id;
    ELSE
      l_org_id := x_items.ship_to_org_id_tbl(l_index);
    END IF;

    -- Bug7117320: Added param names when calling the function.
    l_return_code := invpopif.inopinp_open_interface_process
                     (
                       org_id        => l_org_id,
                       all_org       => 2,
                       val_item_flag => 1,
                       pro_item_flag => 1,
                       del_rec_flag  => 2,  -- do not delete the record
                       prog_appid    => fnd_global.prog_appl_id,
                       prog_id       => -1, -- Inventory does not gather statistics when processing the records inserted into its interface table
                       request_id    => fnd_global.conc_request_id,
                       user_id       => fnd_global.user_id,
                       login_id      => fnd_global.login_id,
                       err_text      => l_err_text,
                       xset_id       => l_set_process_id_tbl(l_index),
                       commit_flag   => 2  -- no commit
                     );

    l_index := p_index_tbl.NEXT(l_index);
  END LOOP;

  d_position := 30;

  l_key := PO_CORE_S.get_session_gt_nextval;
  -- get processed result
  FORALL i IN INDICES OF p_index_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3,
      num4,
      num5,
      num6,
      char1
    )
    SELECT
      l_key,
      p_index_tbl(i),
      set_process_id,
      process_flag,
      transaction_id,
      inventory_item_id,
      organization_id,
      revision
    FROM    mtl_system_items_interface
    WHERE   set_process_id = l_set_process_id_tbl(i);

  d_position := 40;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2, num3, num4, num5, num6, char1
  BULK COLLECT INTO
    l_index_tbl,
    l_set_process_id_tbl,
    l_process_flag_tbl,
    l_transaction_id_tbl,
    l_item_id_tbl,
    l_org_id_tbl,
    l_revision_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl',
                l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_set_process_id_tbl',
                l_set_process_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_process_flag_tbl',
                l_process_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_transaction_id_tbl',
                l_transaction_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_item_id_tbl',
                l_item_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_org_id_tbl',
                l_org_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_revision_tbl',
                l_revision_tbl);
  END IF;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (l_process_flag_tbl(i) = 7) THEN
      -- set item_id back
      x_items.ln_item_id_tbl(l_index) := l_item_id_tbl(i);

      IF (x_items.ln_category_id_tbl(l_index) IS NOT NULL) THEN
        l_category_id_tbl(i) := x_items.ln_category_id_tbl(l_index);
      END IF;
    ELSE
      -- remember the rows with errors
      -- error handling will be done in batch later
      l_error_index_tbl(i) := l_index_tbl(i);

      -- no need to remove records from interface tables below
      l_index_tbl.DELETE(i);
    END IF;
  END LOOP;

  d_position := 50;

  -- update category table
  FORALL i IN INDICES OF l_category_id_tbl
    UPDATE mtl_item_categories
    SET    category_id = l_category_id_tbl(i)
    WHERE  inventory_item_id = l_item_id_tbl(i)
    AND    organization_id =  l_org_id_tbl(i)
    AND    category_set_id = PO_PDOI_PARAMS.g_sys.def_cat_set_id;

  d_position := 60;

  -- delete rows from item interface tables
  FORALL i IN 1..l_index_tbl.COUNT
    DELETE FROM mtl_system_items_interface
    WHERE  transaction_id = l_transaction_id_tbl(i)
    AND    set_process_id = l_set_process_id_tbl(i);

  d_position := 70;

  FORALL i IN 1..l_index_tbl.COUNT
    DELETE FROM mtl_item_categories_interface
    WHERE  inventory_item_id = l_item_id_tbl(i)
    AND    organization_id = l_org_id_tbl(i);

  d_position := 80;

  FORALL i IN 1..l_index_tbl.COUNT
    DELETE FROM mtl_item_revisions_interface
    WHERE  inventory_item_id = l_item_id_tbl(i)
    AND    organization_id = l_org_id_tbl(i)
    AND    revision = l_revision_tbl(i);

  d_position := 90;

  -- handle the errors thrown by item creation
  -- 1. read errors from item error interface table
  FORALL i IN INDICES OF l_error_index_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      char1,
      char2,
      char3
    )
    SELECT
      l_key,
      l_error_index_tbl(i),
      table_name,
      message_name,
      column_name
     FROM  mtl_interface_errors
     WHERE transaction_id = l_transaction_id_tbl(i)
     OR    transaction_id = (
             SELECT transaction_id
             FROM   mtl_item_categories_interface
             WHERE  organization_id = l_org_id_tbl(i)
             AND    inventory_item_id = l_item_id_tbl(i))
     OR    transaction_id = (
             SELECT  transaction_id
             FROM    mtl_item_revisions_interface
             WHERE   organization_id = l_org_id_tbl(i)
             AND     inventory_item_id = l_item_id_tbl(i)
             AND     revision = l_revision_tbl(i));

  d_position := 100;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, char1, char2, char3 BULK COLLECT INTO
    l_error_index_tbl,
    l_table_name_tbl,
    l_message_name_tbl,
    l_column_name_tbl;

  -- add fatal errors to po interface error table
  FOR i IN 1..l_error_index_tbl.COUNT
  LOOP
    -- get index in x_items
    l_index := l_error_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'add error on index',
                  l_index);
      PO_LOG.stmt(d_module, d_position, 'intf line id',
                  x_items.intf_line_id_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'error message',
                  l_message_name_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'table name',
                  l_table_name_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'column name',
                  l_column_name_tbl(i));
    END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_items.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_items.intf_line_id_tbl(l_index),
      p_app_name             => 'INV',
      p_error_message_name   => l_message_name_tbl(i),
      p_table_name           => l_table_name_tbl(i),
      p_column_name          => l_column_name_tbl(i),
      p_column_value         => NULL
    );

    x_items.error_flag_tbl(l_index) := FND_API.g_TRUE;
  END LOOP;

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
END insert_master_item;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_master_item
--Function:
--  This procedure is to update items in item master if needed
--Parameters:
--IN:
--  p_index_tbl
--    index of p_items for which we need to update if needed;
--  p_items
--   the record containing item information
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_master_item
(
  p_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_items     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_master_item';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index     NUMBER;
  l_key       po_session_gt.key%TYPE;

  -- variables to store results of original values defined in item
  l_index_tbl           PO_TBL_NUMBER;
  l_orig_desc_tbl       PO_TBL_VARCHAR2000;
  l_orig_list_price_tbl PO_TBL_NUMBER;

  l_update_index_tbl    DBMS_SQL.NUMBER_TABLE;

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

  -- get original description and list price for comparison
  l_key := PO_CORE_S.get_session_gt_nextval;
  l_update_index_tbl := p_index_tbl;

  FORALL i IN INDICES OF l_update_index_tbl
    INSERT INTO po_session_gt(key, num1, char1, num2)
    SELECT l_key,
           l_update_index_tbl(i),
           description,
           list_price_per_unit
    FROM   mtl_system_items
	WHERE  inventory_item_id = x_items.ln_item_id_tbl(i)
    AND    organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, char1, num2 BULK COLLECT INTO
    l_index_tbl, l_orig_desc_tbl, l_orig_list_price_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl',
                l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_orig_desc_tbl',
                l_orig_desc_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_orig_list_price_tbl',
                l_orig_list_price_tbl);
  END IF;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'i',
                  i);
      PO_LOG.stmt(d_module, d_position, 'l_index',
                  l_index);
      PO_LOG.stmt(d_module, d_position, 'x_items.ln_item_desc_tbl(l_index)',
                  x_items.ln_item_desc_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'x_items.ln_list_price_per_unit_tbl(l_index)',
                  x_items.ln_list_price_per_unit_tbl(l_index));
    END IF;

	d_position := 30;

    IF (x_items.ln_item_desc_tbl(l_index) IS NULL AND
	    x_items.ln_list_price_per_unit_tbl(l_index) IS NULL) THEN
      -- nothing to update
      l_update_index_tbl.DELETE(l_index);
    ELSIF (x_items.ln_item_desc_tbl(l_index) = l_orig_desc_tbl(i) AND
            (x_items.ln_list_price_per_unit_tbl(l_index) = l_orig_list_price_tbl(i)
             OR
              (x_items.ln_list_price_per_unit_tbl(l_index) is null AND
               l_orig_list_price_tbl(i) is null)
	    )
          ) THEN
      -- no change, no need to update
      l_update_index_tbl.DELETE(l_index);
    ELSE
      NULL;
    END IF;
  END LOOP;

  d_position := 40;

  -- call Inventory Team's API to update item description and list price if needed
  l_index := l_update_index_tbl.FIRST;
  WHILE (l_index IS NOT NULL)
  LOOP
    EGO_ITEM_PUB.Process_Item
	(
      p_api_version                 => 1.0,
      p_init_msg_list               => FND_API.g_TRUE,
      p_commit                      => FND_API.g_TRUE,
      p_Transaction_Type            => 'UPDATE',
      p_Inventory_Item_Id           => x_items.ln_item_id_tbl(l_index),
      p_Organization_Id             => PO_PDOI_PARAMS.g_sys.def_inv_org_id,
      p_description                 => NVL(x_items.ln_item_desc_tbl(l_index), EGO_ITEM_PUB.G_MISS_CHAR),
      p_list_price_per_unit         => NVL(x_items.ln_list_price_per_unit_tbl(l_index), EGO_ITEM_PUB.G_MISS_NUM),
      p_Item_Number                 => x_items.ln_item_tbl(l_index),
      x_Inventory_Item_Id           => l_inventory_item_id,
      x_Organization_Id             => l_organization_id,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data
	);

	IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'return status for item update',
	              l_return_status);
    END IF;

	d_position := 50;

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

	  d_position := 60;
      FOR i IN 1..l_message_list.COUNT
	  LOOP
	    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'index', i);
          PO_LOG.stmt(d_module, d_position, 'intf header id',
		              x_items.intf_header_id_tbl(l_index));
		  PO_LOG.stmt(d_module, d_position, 'intf line id',
		              x_items.intf_line_id_tbl(l_index));
          PO_LOG.stmt(d_module, d_position, 'message text',
		              l_message_list(i).message_text);
		  PO_LOG.stmt(d_module, d_position, 'table name',
		              l_message_list(i).table_name);
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_items.intf_header_id_tbl(l_index),
          p_interface_line_id    => x_items.intf_line_id_tbl(l_index),
          p_app_name             => 'INV',
          p_error_message_name   => l_message_list(i).message_text,
          p_table_name           => l_message_list(i).table_name,
          p_column_name          => NULL,
          p_column_value         => NULL
        );
      END LOOP;

      x_items.error_flag_tbl(l_index) := FND_API.g_TRUE;
	END IF;

    l_index := l_update_index_tbl.NEXT(l_index);
  END LOOP;

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
END update_master_item;

END PO_PDOI_ITEM_PROCESS_PVT;

/
