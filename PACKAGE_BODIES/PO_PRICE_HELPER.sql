--------------------------------------------------------
--  DDL for Package Body PO_PRICE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_HELPER" AS
-- $Header: PO_PRICE_HELPER.plb 120.2.12010000.13 2014/07/17 10:39:06 yuandli ship $

---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
  D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
    PO_LOG.get_package_base('PO_PRICE_HELPER');

-- The module base for the subprogram.
  D_no_dists_reserved CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'no_dists_reserved');

-- The module base for the subprogram.
  D_accruals_allow_update CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'accruals_allow_update');

-- The module base for the subprogram.
  D_no_timecards_exist CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'no_timecards_exist');

-- The module base for the subprogram.
  D_no_pending_receipts CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'no_pending_receipts');

-- The module base for the subprogram.
  D_retro_account_allows_update CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'retro_account_allows_update');

-- The module base for the subprogram.
  D_warn_amt_based_notif_ctrls CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'warn_amt_based_notif_ctrls');

-- The module base for the subprogram.
  D_attempt_line_price_update CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'attempt_line_price_update');

-- The module base for the subprogram.
  D_check_system_allows_update CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'check_system_allows_update');

-- The module base for the subprogram.
  D_attempt_man_mod_pricing CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'attempt_man_mod_pricing');

--<PDOI Enhancement Bug#17063664 Start>
-- The module base for the subprogram.
  D_get_line_price CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'get_line_price');

-- The module base for the subprogram.
  D_get_lines_for_price_break CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'get_lines_for_price_break');

-- The module base for the subprogram.
  D_copy_price_break_attributes CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'copy_price_break_attributes');

-- The module base for the subprogram.
  D_copy_pricing_attributes CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'copy_pricing_attributes');

-- The module base for the subprogram.
  D_get_lines_for_advanced CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'get_lines_for_advanced_pricing');

-- The module base for the subprogram.
  D_get_price_from_req CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'get_price_from_req');

-- The module base for the subprogram.
  D_fill_all_req_price_attr CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'fill_all_req_price_attr');

-- The module base for the subprogram.
  D_copy_req_price_attr CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'copy_req_price_attr');

--<PDOI Enhancement Bug#17063664 End>

-- <Bug 17382389: Starts >

-- The module base for the subprogram.
  D_check_price_update_allowed  CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'check_price_update_allowed');

-- <Bug 17382389: Ends >

--<Bug 18372756>:
    D_check_unvalidated_debit_memo CONSTANT VARCHAR2(100) :=
      PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'check_unvalidated_debit_memo');

---------------------------------------------------------------------------
-- Constants.
---------------------------------------------------------------------------

  c_result_type_rank_WARNING CONSTANT NUMBER :=
    PO_VALIDATIONS.result_type_rank(PO_VALIDATIONS.c_result_type_warning);

  c_ENTITY_TYPE_LINE CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_ENTITY_TYPE_LINE;

  c_UNIT_PRICE CONSTANT VARCHAR2(30) := 'UNIT_PRICE';

-- PO_HEADERS_ALL.type_lookup_code
  c_STANDARD CONSTANT VARCHAR2(10) := 'STANDARD';

-- PO_LINES_ALL.order_type_lookup_code
  c_RATE CONSTANT VARCHAR2(5) := 'RATE';

-- RCV_TRANSACTIONS_INTERFACE.transaction_status_code
  c_PENDING CONSTANT VARCHAR2(10) := 'PENDING';

-- Retroactive update mode
  c_ALL_RELEASES CONSTANT VARCHAR2(30) := 'ALL_RELEASES';

-- PO_HEADERS_ALL.authorization_status
  c_INCOMPLETE CONSTANT VARCHAR2(30) := 'INCOMPLETE';

-- PO_LINES_ALL.price_break_lookup_code
  c_NON_CUMULATIVE CONSTANT VARCHAR2(30) := 'NON CUMULATIVE';

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Determines if a line's price is allowed to be updated.
--Parameters:
--IN:
--p_po_line_id
--  Identifies the line that should be checked.
--p_draft_id
--  Further identifies the line.
 -- <Bug 13503748 : Encumbrance ER : Parameter to
 -- identify if the amount on the distributions of the line has been changed
 -- p_amount_changed_flag
--OUT:
--x_system_allows_update
--  Indicates whether or not a price change is allowed.
--    'Y' - price change is allowed.
--    'N' - price change is not allowed.
--  VARCHAR2(1)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE check_system_allows_update(
     p_po_line_id IN NUMBER
   , p_price_break_lookup_code IN VARCHAR2
    ,p_amount_changed_flag IN VARCHAR2  DEFAULT NULL
   , x_system_allows_update OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_check_system_allows_update;
    d_position NUMBER := 0;

    l_line_id_tbl PO_TBL_NUMBER;
    l_price_break_lookup_code_tbl PO_TBL_VARCHAR30;
    l_result_set_id NUMBER;
    l_result_type VARCHAR2(30);
    l_results PO_VALIDATION_RESULTS_TYPE;

    l_amount_changed_flag_tbl PO_TBL_VARCHAR1; --<Bug 13503748 :Encumbrance ER>--

  BEGIN
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_po_line_id', p_po_line_id);
      PO_LOG.proc_begin(d_mod, 'p_price_break_lookup_code', p_price_break_lookup_code);
      PO_LOG.proc_begin(d_mod, 'p_amount_changed_flag', p_amount_changed_flag); --<Bug 13503748 :Encumbrance ER>--
    END IF;

    d_position := 1;
    l_line_id_tbl := PO_TBL_NUMBER(p_po_line_id);
    l_price_break_lookup_code_tbl := PO_TBL_VARCHAR30(p_price_break_lookup_code);
    l_amount_changed_flag_tbl := PO_TBL_VARCHAR1(p_amount_changed_flag); --<Bug 13503748 :Encumbrance ER>--

    d_position := 100;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_line_id_tbl', l_line_id_tbl);
    END IF;

    PO_VALIDATIONS.validate_unit_price_change(
       p_line_id_tbl => l_line_id_tbl
     , p_price_break_lookup_code_tbl => l_price_break_lookup_code_tbl
     , p_amount_changed_flag_tbl => l_amount_changed_flag_tbl  --<Bug 13503748 :Encumbrance ER>--
     , p_stopping_result_type => PO_VALIDATIONS.c_result_type_FAILURE
     , x_result_type => l_result_type
     , x_result_set_id => l_result_set_id
     , x_results => l_results);

    d_position := 200;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_result_set_id', l_result_set_id);
      PO_LOG.stmt(d_mod, d_position, 'l_result_type', l_result_type);
    END IF;

    IF (PO_VALIDATIONS.result_type_rank(l_result_type) >=
        c_result_type_rank_WARNING)
      THEN
      x_system_allows_update := 'Y';
    ELSE
      x_system_allows_update := 'N';
    END IF;

    d_position := 300;
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_system_allows_update', x_system_allows_update);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END check_system_allows_update;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Verifies that the line's price is allowed to be updated
--  and calls the Pricing API to get a new price.
--Parameters:
--  See the parameter descriptions for PO_SOURCING_SV2.get_break_price.
--OUT:
--x_system_allows_update
--  Indicates whether or not a price change is allowed.
--    'Y' - price change is allowed.
--    'N' - price change is not allowed.
--  VARCHAR2(1)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE attempt_line_price_update(
     p_order_quantity IN NUMBER
   , p_ship_to_org IN NUMBER
   , p_ship_to_loc IN NUMBER
   , p_po_line_id IN NUMBER
   , p_need_by_date IN DATE
   , p_line_location_id IN NUMBER
   , p_contract_id IN NUMBER
   , p_org_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_header_id IN NUMBER
   , p_order_line_id IN NUMBER
   , p_line_type_id IN NUMBER
   , p_item_revision IN VARCHAR2
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_uom IN VARCHAR2
   , p_in_price IN NUMBER
   , p_currency_code IN VARCHAR2
   , p_price_break_lookup_code IN VARCHAR2
   --<Enhanced Pricing Start>
   , p_draft_id IN NUMBER DEFAULT NULL
   , p_src_flag IN VARCHAR2 DEFAULT NULL
   , p_doc_sub_type IN VARCHAR2 DEFAULT NULL
   --<Enhanced Pricing End>
    -- <Bug : 13503748 Encumbrance ER : Parameter to identify if the amount on the distributions of the line has been changed
    ,p_amount_changed_flag IN VARCHAR2 DEFAULT NULL
   , x_base_unit_price OUT NOCOPY NUMBER
   , x_price_break_id OUT NOCOPY NUMBER
   , x_price OUT NOCOPY NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   , x_from_advanced_pricing OUT NOCOPY VARCHAR2
   , x_system_allows_update OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_attempt_line_price_update;
    d_position NUMBER := 0;
  BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_order_quantity', p_order_quantity);
      PO_LOG.proc_begin(d_mod, 'p_ship_to_org', p_ship_to_org);
      PO_LOG.proc_begin(d_mod, 'p_ship_to_loc', p_ship_to_loc);
      PO_LOG.proc_begin(d_mod, 'p_po_line_id', p_po_line_id);
      PO_LOG.proc_begin(d_mod, 'p_need_by_date', p_need_by_date);
      PO_LOG.proc_begin(d_mod, 'p_line_location_id', p_line_location_id);
      PO_LOG.proc_begin(d_mod, 'p_contract_id', p_contract_id);
      PO_LOG.proc_begin(d_mod, 'p_org_id', p_org_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_id', p_supplier_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_site_id', p_supplier_site_id);
      PO_LOG.proc_begin(d_mod, 'p_creation_date', p_creation_date);
      PO_LOG.proc_begin(d_mod, 'p_order_header_id', p_order_header_id);
      PO_LOG.proc_begin(d_mod, 'p_order_line_id', p_order_line_id);
      PO_LOG.proc_begin(d_mod, 'p_line_type_id', p_line_type_id);
      PO_LOG.proc_begin(d_mod, 'p_item_revision', p_item_revision);
      PO_LOG.proc_begin(d_mod, 'p_item_id', p_item_id);
      PO_LOG.proc_begin(d_mod, 'p_category_id', p_category_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_item_num', p_supplier_item_num);
      PO_LOG.proc_begin(d_mod, 'p_uom', p_uom);
      PO_LOG.proc_begin(d_mod, 'p_in_price', p_in_price);
      PO_LOG.proc_begin(d_mod, 'p_currency_code', p_currency_code);
      --<Enhanced Pricing Start>
      PO_LOG.proc_begin(d_mod, 'p_draft_id', p_draft_id);
      PO_LOG.proc_begin(d_mod, 'p_src_flag', p_src_flag);
      PO_LOG.proc_begin(d_mod, 'p_doc_sub_type', p_doc_sub_type);
      --<Enhanced Pricing End>
      PO_LOG.proc_begin(d_mod, 'p_amount_changed_flag', p_amount_changed_flag);  -- <Bug : 13503748 Encumbrance ER >--
    END IF;

    d_position := 1;
    check_system_allows_update(
                                 p_po_line_id => p_order_line_id
                               , p_price_break_lookup_code => p_price_break_lookup_code
			        -- <Bug : Encumbrance ER : 13503748: Parameter to identify if the amount on
				-- the distributions of the line has been changed
			       , p_amount_changed_flag  => p_amount_changed_flag
                               , x_system_allows_update => x_system_allows_update
                               );

    d_position := 90;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'x_system_allows_update', x_system_allows_update);
    END IF;

    IF (x_system_allows_update = 'Y') THEN
      d_position := 100;
      PO_SOURCING2_SV.get_break_price(
         p_api_version => 1.0
       , p_order_quantity => p_order_quantity
       , p_ship_to_org => p_ship_to_org
       , p_ship_to_loc => p_ship_to_loc
       , p_po_line_id => p_po_line_id
       , p_cum_flag => FALSE
       , p_need_by_date => TRUNC(p_need_by_date)
       , p_line_location_id => p_line_location_id
       , p_contract_id => p_contract_id
       , p_org_id => p_org_id
       , p_supplier_id => p_supplier_id
       , p_supplier_site_id => p_supplier_site_id
       , p_creation_date => p_creation_date
       , p_order_header_id => p_order_header_id
       , p_order_line_id => p_order_line_id
       , p_line_type_id => p_line_type_id
       , p_item_revision => p_item_revision
       , p_item_id => p_item_id
       , p_category_id => p_category_id
       , p_supplier_item_num => p_supplier_item_num
       , p_uom => p_uom
       , p_in_price => p_in_price
       , p_currency_code => p_currency_code
       --<Enhanced Pricing Start>
       , p_draft_id => p_draft_id
       , p_src_flag => p_src_flag
       , p_doc_sub_type => p_doc_sub_type
       --<Enhanced Pricing End>
       , x_base_unit_price => x_base_unit_price
       , x_price_break_id => x_price_break_id
       , x_price => x_price
       , x_return_status => x_return_status
       , x_from_advanced_pricing => x_from_advanced_pricing);
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_base_unit_price', x_base_unit_price);
      PO_LOG.proc_end(d_mod, 'x_price_break_id', x_price_break_id);
      PO_LOG.proc_end(d_mod, 'x_price', x_price);
      PO_LOG.proc_end(d_mod, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_mod, 'x_from_advanced_pricing', x_from_advanced_pricing);
      PO_LOG.proc_end(d_mod, 'x_system_allows_update', x_system_allows_update);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END attempt_line_price_update;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
--  lines that have a reserved distribution.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--p_amount_changed_flag_tbl
-- <Bug : Encumbrance ER : 13503748: Parameter to identify if the amount
-- on the distributions of the line has been changed
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_FAILURE - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE no_dists_reserved(
     p_line_id_tbl IN PO_TBL_NUMBER
   , p_amt_changed_flag_tbl IN PO_TBL_VARCHAR1
   , x_result_set_id IN OUT NOCOPY NUMBER
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_no_dists_reserved;
    d_position NUMBER := 0;
  BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_line_id_tbl', p_line_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_amt_changed_flag_tbl', p_amt_changed_flag_tbl); -- <Bug13503748 : Encumbrance ER >--
      PO_LOG.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    d_position := 1;
    IF (x_result_set_id IS NULL) THEN
      x_result_set_id := PO_VALIDATIONS.next_result_set_id();
    END IF;

    d_position := 100;
    FORALL i IN 1 .. p_line_id_tbl.COUNT
    INSERT INTO PO_VALIDATION_RESULTS_GT
    (result_set_id
    , entity_type
    , entity_id
    , column_name
    , message_name
    )
    SELECT
      x_result_set_id
    , c_ENTITY_TYPE_LINE
    , p_line_id_tbl(i)
    , c_UNIT_PRICE
    , NULL -- TODO: Get message from PM.
    FROM
      PO_LINES_ALL LINE
    , PO_HEADERS_ALL HEADER
    WHERE
        LINE.po_line_id = p_line_id_tbl(i)
    AND HEADER.po_header_id = LINE.po_header_id
    AND HEADER.type_lookup_code = c_STANDARD
    AND LINE.order_type_lookup_code <> c_RATE
    AND EXISTS
          (SELECT NULL
             FROM PO_DISTRIBUTIONS_ALL DIST
            WHERE  DIST.po_line_id = LINE.po_line_id
             AND DIST.encumbered_flag = 'Y'
	  )
    AND NVL(p_amt_changed_flag_tbl(i),'N') = 'N'; -- <Bug 13503748: Encumbrance ER >--

    d_position := 200;
    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END no_dists_reserved;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for each of the lines specified
--  whose accrued status should prevent an update to the price.
--  An example of an error is that some quantity has been billed and
--  retroactive price updates are not allowed.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_FAILURE - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE accruals_allow_update(
     p_line_id_tbl IN PO_TBL_NUMBER
   , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_accruals_allow_update;
    d_position NUMBER := 0;
    d_stmt CONSTANT BOOLEAN := PO_LOG.d_stmt;

    l_results_count NUMBER;
    l_data_key NUMBER;
    l_line_id_tbl PO_TBL_NUMBER;
    l_expense_accrual_code_tbl PO_TBL_VARCHAR4000;
    l_header_id_tbl PO_TBL_NUMBER;
    l_type_lookup_code_tbl PO_TBL_VARCHAR4000;

    l_quantity_received NUMBER;
    l_quantity_billed NUMBER;
    l_encumbered_flag VARCHAR2(1);
    l_prevent_price_update_flag VARCHAR2(1);
    l_online_req_flag VARCHAR2(1);
    l_quantity_released NUMBER;
    l_amount_released NUMBER;
  BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_line_id_tbl', p_line_id_tbl);
    END IF;

    d_position := 1;
    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT;


    d_position := 10;
    l_data_key := PO_CORE_S.get_session_gt_nextval();

    FORALL i IN 1 .. p_line_id_tbl.COUNT
    INSERT INTO PO_SESSION_GT
    (key
    , num1
    )
    VALUES
    (l_data_key
    , p_line_id_tbl(i)
    )
    ;

    d_position := 20;
    SELECT
      LINE.po_line_id
    , HEADER.po_header_id
    , HEADER.type_lookup_code
    , PARAMS.expense_accrual_code
    BULK COLLECT INTO
      l_line_id_tbl
    , l_header_id_tbl
    , l_type_lookup_code_tbl
    , l_expense_accrual_code_tbl
    FROM
      PO_SESSION_GT SES
    , PO_LINES_ALL LINE
    , PO_HEADERS_ALL HEADER
    , PO_SYSTEM_PARAMETERS_ALL PARAMS
    WHERE
        SES.key = l_data_key
    AND LINE.po_line_id = SES.num1
    AND HEADER.po_header_id = LINE.po_header_id
    AND HEADER.type_lookup_code = c_STANDARD
    AND PARAMS.org_id = HEADER.org_id
    ;

    d_position := 100;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt_session_gt(d_mod, d_position, l_data_key);
      PO_LOG.stmt(d_mod, d_position, 'l_line_id_tbl', l_line_id_tbl);
      PO_LOG.stmt(d_mod, d_position, 'l_header_id_tbl', l_header_id_tbl);
      PO_LOG.stmt(d_mod, d_position, 'l_type_lookup_code_tbl', l_type_lookup_code_tbl);
      PO_LOG.stmt(d_mod, d_position, 'l_expense_accrual_code_tbl', l_expense_accrual_code_tbl);
    END IF;

    FOR i IN 1 .. l_line_id_tbl.COUNT LOOP

  -- The prevent_price_udpate_flag should start as N,
  -- and an error will only be reported if it becomed Y.
      l_prevent_price_update_flag := 'N';

      d_position := 200;
      PO_LINES_SV4.get_ship_quantity_info(
         x_po_line_id => l_line_id_tbl(i)
       , x_expense_accrual_code => l_expense_accrual_code_tbl(i)
       , x_po_header_id => l_header_id_tbl(i)
       , x_type_lookup_code => l_type_lookup_code_tbl(i)
       , x_quantity_received => l_quantity_received
       , x_quantity_billed => l_quantity_billed
       , x_encumbered_flag => l_encumbered_flag
       , x_prevent_price_update_flag => l_prevent_price_update_flag
       , x_online_req_flag => l_online_req_flag
       , x_quantity_released => l_quantity_released
       , x_amount_released => l_amount_released);

      d_position := 300;
      IF d_stmt THEN
        PO_LOG.stmt(d_mod, d_position, 'l_prevent_price_update_flag', l_prevent_price_update_flag);
      END IF;

      IF (l_prevent_price_update_flag = 'Y') THEN
        d_position := 400;
        x_results.add_result(
           p_entity_type => c_ENTITY_TYPE_LINE
         , p_entity_id => l_line_id_tbl(i)
         , p_column_name => c_UNIT_PRICE
         , p_message_name => NULL); -- TODO: need message from PM.

        d_position := 450;
      END IF;

    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END accruals_allow_update;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
--  lines for which there are submitted or approved timecards.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_FAILURE - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE no_timecards_exist(
     p_line_id_tbl IN PO_TBL_NUMBER
   , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    PO_VALIDATION_HELPER.no_timecards_exist(
       p_calling_module => D_no_timecards_exist
     , p_line_id_tbl => p_line_id_tbl
     , p_start_date_tbl => NULL
     , p_expiration_date_tbl => NULL
     , p_column_name => c_UNIT_PRICE
     , p_message_name => PO_MESSAGE_S.PO_CHNG_OTL_NO_PRICE_CHANGE
     , x_results => x_results
     , x_result_type => x_result_type);
  END no_timecards_exist;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
--  lines for which there are pending receipts.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_FAILURE - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE no_pending_receipts(
     p_line_id_tbl IN PO_TBL_NUMBER
   , x_result_set_id IN OUT NOCOPY NUMBER
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_no_pending_receipts;
    d_position NUMBER := 0;
  BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_line_id_tbl', p_line_id_tbl);
      PO_LOG.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    d_position := 1;
    IF (x_result_set_id IS NULL) THEN
      x_result_set_id := PO_VALIDATIONS.next_result_set_id();
    END IF;

    d_position := 100;
    FORALL i IN 1 .. p_line_id_tbl.COUNT
    INSERT INTO PO_VALIDATION_RESULTS_GT
    (result_set_id
    , entity_type
    , entity_id
    , column_name
    , message_name
    )
    SELECT
      x_result_set_id
    , c_ENTITY_TYPE_LINE
    , p_line_id_tbl(i)
    , c_UNIT_PRICE
    , PO_MESSAGE_S.PO_RCV_TRANSACTION_PENDING
    FROM DUAL
    WHERE EXISTS
      (SELECT null
        FROM
          RCV_TRANSACTIONS_INTERFACE RTI
        , PO_LINE_LOCATIONS_ALL POLL
        WHERE
            RTI.po_line_location_id = POLL.line_location_id
        AND POLL.po_line_id = p_line_id_tbl(i)
        AND RTI.transaction_status_code = c_PENDING
      )
    ;

    d_position := 200;
    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END no_pending_receipts;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
--  lines for which the retroactive account setup is not valid.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_FAILURE - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE retro_account_allows_update(
     p_line_id_tbl IN PO_TBL_NUMBER
   , p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30
   , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_retro_account_allows_update;
    d_position NUMBER := 0;
    d_stmt CONSTANT BOOLEAN := PO_LOG.d_stmt;

    l_results_count NUMBER;
    l_data_key NUMBER;

    l_line_id_tbl PO_TBL_NUMBER;
    l_price_break_lookup_code_tbl PO_TBL_VARCHAR4000;

    l_line_id NUMBER;
    l_price_break_lookup_code VARCHAR2(4000);

    l_retroactive_update_mode VARCHAR2(30);
    l_account_valid VARCHAR2(1);
  BEGIN
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_line_id_tbl', p_line_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_price_break_lookup_code_tbl', p_price_break_lookup_code_tbl);
    END IF;

    d_position := 1;
    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT;

    d_position := 50;
    l_retroactive_update_mode := PO_RETROACTIVE_PRICING_PVT.get_retro_mode();

    d_position := 90;
    IF d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_retroactive_update_mode', l_retroactive_update_mode);
    END IF;

    IF (l_retroactive_update_mode = c_ALL_RELEASES) THEN
      d_position := 100;
      l_data_key := PO_CORE_S.get_session_gt_nextval();

      FORALL i IN 1 .. p_line_id_tbl.COUNT
      INSERT INTO PO_SESSION_GT
      (key
      , num1
      , char1
      )
      VALUES
      (l_data_key
      , p_line_id_tbl(i)
      , p_price_break_lookup_code_tbl(i)
      )
      ;

      d_position := 110;
      SELECT
        SES.num1
      , SES.char1
      BULK COLLECT INTO
        l_line_id_tbl
      , l_price_break_lookup_code_tbl
      FROM
        PO_SESSION_GT SES
      , PO_LINES_ALL LINE
      , PO_HEADERS_ALL HEADER
      WHERE
          SES.key = l_data_key
      AND LINE.po_line_id = SES.num1
      AND HEADER.po_header_id = LINE.po_header_id
      AND HEADER.type_lookup_code = c_STANDARD
      AND HEADER.authorization_status <> c_INCOMPLETE
      AND (SES.char1 IS NULL OR SES.char1 = c_NON_CUMULATIVE)
      ;

      d_position := 120;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt_session_gt(d_mod, d_position, l_data_key);
        PO_LOG.stmt(d_mod, d_position, 'l_line_id_tbl', l_line_id_tbl);
        PO_LOG.stmt(d_mod, d_position, 'l_price_break_lookup_code', l_price_break_lookup_code);
      END IF;

      FOR i IN 1 .. l_line_id_tbl.COUNT LOOP
        d_position := 200;
        l_line_id := l_line_id_tbl(i);
        l_price_break_lookup_code := l_price_break_lookup_code_tbl(i);

        IF d_stmt THEN
          PO_LOG.stmt(d_mod, d_position,'iteration '|| i ||' l_line_id', l_line_id);
        END IF;

        l_account_valid :=
        PO_RETROACTIVE_PRICING_PVT.is_adjustment_account_valid(
                                                               p_std_po_price_change => 'Y'
                                                               , p_po_line_id => l_line_id
                                                               , p_po_line_loc_id => NULL
                                                               );

        d_position := 250;
        IF d_stmt THEN
          PO_LOG.stmt(d_mod, d_position, 'l_account_valid', l_account_valid);
        END IF;

        IF (l_account_valid = 'N') THEN
          d_position := 300;
          x_results.add_result(
                               p_entity_type => c_ENTITY_TYPE_LINE
                               , p_entity_id => l_line_id
                               , p_message_name => PO_MESSAGE_S.PO_CHNG_OTL_NO_PRICE_CHANGE
                               , p_column_name => c_UNIT_PRICE
                               );

          d_position := 350;
        END IF;

      END LOOP;

    END IF;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END retro_account_allows_update;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
--  lines for which amount based notification controls exist.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines that should be checked.
--p_draft_id_tbl
--  Used to insert messages into PO_VALIDATION_RESULTS.
--IN OUT:
--x_result_set_id
--  The identifier into PO_VALIDATION_RESULTS for the results produced.
--  If this is NULL, it will be retrieved from the sequence.
--OUT:
--x_result_type
--  Indicates whether or not any error results were produced.
--    c_result_type_WARNING - results were produced.
--    c_result_type_SUCCESS - no errors.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE warn_amt_based_notif_ctrls(
     p_line_id_tbl IN PO_TBL_NUMBER
   , x_result_set_id IN OUT NOCOPY NUMBER
   , x_result_type OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    PO_VALIDATION_HELPER.amount_notif_ctrl_warning(
       p_calling_module => D_warn_amt_based_notif_ctrls
     , p_line_id_tbl => p_line_id_tbl
     , p_quantity_tbl => NULL
     , p_column_name => c_UNIT_PRICE
     , p_message_name => PO_MESSAGE_S.PO_PO_NFC_PRICE_CHANGE
     , x_result_set_id => x_result_set_id
     , x_result_type => x_result_type);
  END warn_amt_based_notif_ctrls;

--<Enhanced Pricing Start>
-------------------------------------------------------------------------------
--Start of Comments
--attempt_man_mod_pricing
-------------------------------------------------------------------------------

  PROCEDURE attempt_man_mod_pricing(
     p_order_quantity IN NUMBER
   , p_ship_to_org IN NUMBER
   , p_ship_to_loc IN NUMBER
   , p_po_line_id IN NUMBER
   , p_need_by_date IN DATE
   , p_line_location_id IN NUMBER
   , p_contract_id IN NUMBER
   , p_org_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_header_id IN NUMBER
   , p_order_line_id IN NUMBER
   , p_line_type_id IN NUMBER
   , p_item_revision IN VARCHAR2
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_uom IN VARCHAR2
   , p_in_price IN NUMBER
   , p_currency_code IN VARCHAR2
   , p_price_break_lookup_code IN VARCHAR2
   --<Enhanced Pricing Start: Parameters to identify calls with or without source docuemnt and document type (standard or blanket)>
   , p_src_flag IN VARCHAR2 DEFAULT NULL
   , p_doc_sub_type IN VARCHAR2 DEFAULT NULL
   --<Enhanced Pricing End>
   , x_return_status OUT NOCOPY VARCHAR2
   , x_system_allows_update OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_attempt_man_mod_pricing;
    d_position NUMBER := 0;

    l_doc_sub_type VARCHAR2(30);
    l_source_document_type PO_HEADERS.type_lookup_code%TYPE;
    l_source_document_header_id PO_LINES.po_header_id%TYPE;
    l_pricing_date PO_LINE_LOCATIONS.need_by_date%TYPE;
    l_rate PO_HEADERS.rate%TYPE;
    l_rate_type PO_HEADERS.rate_type%TYPE;

    l_return_status VARCHAR2(1);
  BEGIN
    -- Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_system_allows_update := 'N';

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_order_quantity', p_order_quantity);
      PO_LOG.proc_begin(d_mod, 'p_ship_to_org', p_ship_to_org);
      PO_LOG.proc_begin(d_mod, 'p_ship_to_loc', p_ship_to_loc);
      PO_LOG.proc_begin(d_mod, 'p_po_line_id', p_po_line_id);
      PO_LOG.proc_begin(d_mod, 'p_need_by_date', p_need_by_date);
      PO_LOG.proc_begin(d_mod, 'p_line_location_id', p_line_location_id);
      PO_LOG.proc_begin(d_mod, 'p_contract_id', p_contract_id);
      PO_LOG.proc_begin(d_mod, 'p_org_id', p_org_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_id', p_supplier_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_site_id', p_supplier_site_id);
      PO_LOG.proc_begin(d_mod, 'p_creation_date', p_creation_date);
      PO_LOG.proc_begin(d_mod, 'p_order_header_id', p_order_header_id);
      PO_LOG.proc_begin(d_mod, 'p_order_line_id', p_order_line_id);
      PO_LOG.proc_begin(d_mod, 'p_line_type_id', p_line_type_id);
      PO_LOG.proc_begin(d_mod, 'p_item_revision', p_item_revision);
      PO_LOG.proc_begin(d_mod, 'p_item_id', p_item_id);
      PO_LOG.proc_begin(d_mod, 'p_category_id', p_category_id);
      PO_LOG.proc_begin(d_mod, 'p_supplier_item_num', p_supplier_item_num);
      PO_LOG.proc_begin(d_mod, 'p_uom', p_uom);
      PO_LOG.proc_begin(d_mod, 'p_in_price', p_in_price);
      PO_LOG.proc_begin(d_mod, 'p_currency_code', p_currency_code);
      PO_LOG.proc_begin(d_mod, 'p_src_flag', p_src_flag);
      PO_LOG.proc_begin(d_mod, 'p_doc_sub_type', p_doc_sub_type);
    END IF;

    d_position := 1;
    check_system_allows_update( p_po_line_id              => p_order_line_id
                              , p_price_break_lookup_code => p_price_break_lookup_code
                              , x_system_allows_update    => x_system_allows_update
                              );

    d_position := 100;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'x_system_allows_update', x_system_allows_update);
    END IF;

    IF (x_system_allows_update = 'Y') THEN
      d_position := 120;
      --Initialize Document Sub Type
      IF (p_doc_sub_type IS NOT NULL) THEN
        l_doc_sub_type := p_doc_sub_type;
      ELSE
        l_doc_sub_type := 'PO';
      END IF;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod, d_position, 'l_doc_sub_type', l_doc_sub_type);
      END IF;

      d_position := 140;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod, d_position, 'Get source document header id and type');
      END IF;

      IF (p_po_line_id IS NOT NULL) THEN
        SELECT ph.type_lookup_code,
               pl.po_header_id
        INTO   l_source_document_type,
             l_source_document_header_id
        FROM po_headers_all ph,
             po_lines_all pl
        WHERE ph.po_header_id = pl.po_header_id
        AND pl.po_line_id = p_po_line_id;
      ELSIF (p_contract_id IS NOT NULL) THEN
        SELECT ph.type_lookup_code,
               ph.po_header_id
        INTO   l_source_document_type,
               l_source_document_header_id
        FROM po_headers_all ph
        WHERE ph.po_header_id = p_contract_id;
      ELSE
        l_source_document_type := NULL;
        l_source_document_header_id := NULL;
      END IF;

      l_pricing_date := NVL(p_need_by_date, SYSDATE);

      IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN
        l_rate_type := NULL;
        l_rate := NULL;
        d_position := 160;
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_mod, d_position, 'Call pricing to retrieve manual modifiers');
        END IF;

        PO_ADVANCED_PRICE_PVT.call_pricing_manual_modifier(
            p_org_id => p_org_id
          , p_supplier_id => p_supplier_id
          , p_supplier_site_id => p_supplier_site_id
          , p_creation_date => p_creation_date
          , p_order_type => l_doc_sub_type
          , p_ship_to_location_id => p_ship_to_loc
          , p_ship_to_org_id => p_ship_to_org
          , p_order_header_id => p_order_header_id
          , p_order_line_id => p_order_line_id
          , p_item_revision => p_item_revision
          , p_item_id => p_item_id
          , p_category_id => p_category_id
          , p_supplier_item_num => p_supplier_item_num
          , p_agreement_type => l_source_document_type
          , p_agreement_id => l_source_document_header_id
          , p_agreement_line_id => p_po_line_id
          , p_rate => l_rate
          , p_rate_type => l_rate_type
          , p_currency_code => p_currency_code
          , p_need_by_date => l_pricing_date
          , p_quantity => p_order_quantity
          , p_uom => p_uom
          , p_unit_price => p_in_price
          , x_return_status => l_return_status );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          app_exception.raise_exception;
        END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

        x_return_status := l_return_status;

        d_position := 180;
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_mod, d_position, 'x_return_status', x_return_status);
        END IF;
      ELSE
        d_position := 200;
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_mod, d_position, 'Not a valid price type to call Advanced Pricing API(NSD - No Source Document)');
        END IF;
      END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/
    END IF;
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_mod, 'x_system_allows_update', x_system_allows_update);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, NULL);
      END IF;
      RAISE;
  END attempt_man_mod_pricing;

--<PDOI Enhancement Bug#17063664 Start>

-----------------------------------------------------------------------
--Start of Comments
--Name: copy_price_break_attributes
--Function:
--<PDOI Enhancement Bug#17063664>
-- The procedure is used to copy price break related attributes from
-- source record to destination record.
-- Destination record will then be passed to get_break_price.
--Parameters:
--IN:
-- source_rec
--  Source Record of pricing_attributes_rec_type.
-- source_index
--  Source Index.
--IN OUT:
-- dest_rec
--  Destination Record of pricing_attributes_rec_type.
-- dest_index
--  Destination index.
--End of Comments
------------------------------------------------------------------------
PROCEDURE copy_price_break_attributes(
         source_rec   IN     PO_PDOI_TYPES.pricing_attributes_rec_type,
         source_index IN     BINARY_INTEGER,
         dest_rec     IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         dest_index   IN     BINARY_INTEGER
         )
IS

  d_mod CONSTANT VARCHAR2(100) := D_copy_price_break_attributes;
  d_position NUMBER := 0;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  IF dest_index = 1 then
      PO_PDOI_TYPES.fill_all_pricing_attr( p_num_records => 1,
                                           x_pricing_rec => dest_rec);
  ELSE
      dest_rec.rec_count := dest_rec.rec_count + 1;
      dest_rec.po_line_id_tbl.extend;
      dest_rec.source_doc_hdr_id_tbl.extend;
      dest_rec.source_doc_line_id_tbl.extend;
      dest_rec.quantity_tbl.extend;
      dest_rec.pricing_date_tbl.extend;
      dest_rec.ship_to_loc_tbl.extend;
      dest_rec.ship_to_org_tbl.extend;
      dest_rec.base_unit_price_tbl.extend;
      dest_rec.price_break_id_tbl.extend;
      dest_rec.return_status_tbl.extend;
      dest_rec.return_mssg_tbl.extend;
  END IF;

  dest_rec.po_line_id_tbl(dest_index) := source_rec.po_line_id_tbl(source_index);
  dest_rec.source_doc_hdr_id_tbl(dest_index) := source_rec.source_doc_hdr_id_tbl(source_index);
  dest_rec.source_doc_line_id_tbl(dest_index) := source_rec.source_doc_line_id_tbl(source_index);
  dest_rec.quantity_tbl(dest_index) := source_rec.quantity_tbl(source_index);

  dest_rec.pricing_date_tbl(dest_index) := source_rec.pricing_date_tbl(source_index);
  dest_rec.ship_to_loc_tbl(dest_index) := source_rec.ship_to_loc_tbl(source_index);
  dest_rec.ship_to_org_tbl(dest_index) := source_rec.ship_to_org_tbl(source_index);

  dest_rec.base_unit_price_tbl(dest_index) := source_rec.base_unit_price_tbl(source_index);
  dest_rec.price_break_id_tbl(dest_index) := source_rec.price_break_id_tbl(source_index);

  dest_rec.return_status_tbl(dest_index) := source_rec.return_status_tbl(source_index);
  dest_rec.return_mssg_tbl(dest_index) := source_rec.return_mssg_tbl(source_index);

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END copy_price_break_attributes;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_lines_for_price_break
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to get lines valid for price break call.
--Parameters:
--IN OUT:
-- pricing_attributes_rec
--  Record of pricing_attributes_rec_type. Contains all attributes needed for pricing.
-- price_break_rec
--  Record of pricing_attributes_rec_type containing lines valid for price break call.
-- index_tbl
--  Index table
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_lines_for_price_break(
         x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         x_price_break_rec        IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         index_tbl                IN OUT NOCOPY dbms_sql.number_table)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_lines_for_price_break;
  d_position NUMBER := 0;

  l_count BINARY_INTEGER := 1;

  l_result_set_id NUMBER;
  l_result_type VARCHAR2(30);
  l_results PO_VALIDATION_RESULTS_TYPE;

  l_valid_for_price_break VARCHAR2(1);
  l_pricing_date PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_return_status VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  -- Algorithm
  -- 1) Lines having from_header_id and from_line_id are valid for get_price_break.
  -- 2) For lines already existing in transaction table we need to call validate_unit_price_change
  -- 3) Call custom API to get pricing date.
  -- 4) Copy valid price break lines in x_price_break_rec.

  FOR i IN 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
  LOOP

    d_position := 10;
    l_valid_for_price_break := 'N';

    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Line id ', x_pricing_attributes_rec.po_line_id_tbl(i));
    END IF;

    IF (x_pricing_attributes_rec.progress_payment_flag_tbl(i) = 'N'  -- Not Complex
         AND x_pricing_attributes_rec.source_document_type_tbl(i) = 'BLANKET'
         AND x_pricing_attributes_rec.source_doc_hdr_id_tbl(i) IS NOT NULL
         AND x_pricing_attributes_rec.source_doc_line_id_tbl(i) IS NOT NULL
         AND (x_pricing_attributes_rec.req_contractor_status(i) IS NULL
            OR x_pricing_attributes_rec.req_contractor_status(i) <> 'ASSIGNED')
         AND x_pricing_attributes_rec.order_type_lookup_tbl(i) NOT IN ('FIXED PRICE', 'AMOUNT')
         AND x_pricing_attributes_rec.doc_sub_type_tbl(i) = 'STANDARD'
         AND x_pricing_attributes_rec.return_status_tbl(i) = FND_API.G_RET_STS_SUCCESS ) THEN

          d_position := 20;
          IF x_pricing_attributes_rec.existing_line_flag_tbl(i) = 'Y' THEN

             d_position := 30;
             BEGIN
                   PO_VALIDATIONS.validate_unit_price_change( p_line_id_tbl                 => PO_TBL_NUMBER(x_pricing_attributes_rec.po_line_id_tbl(i))
                                                            , p_price_break_lookup_code_tbl => PO_TBL_VARCHAR30(x_pricing_attributes_rec.price_break_lookup_code_tbl(i))
                                                            , p_amount_changed_flag_tbl     => PO_TBL_VARCHAR1(x_pricing_attributes_rec.amount_changed_flag_tbl(i))
                                                            , p_stopping_result_type        => PO_VALIDATIONS.c_result_type_FAILURE
                                                            , x_result_type                 => l_result_type
                                                            , x_result_set_id               => l_result_set_id
                                                            , x_results                     => l_results);

                    IF (PO_VALIDATIONS.result_type_rank(l_result_type) >=
                          c_result_type_rank_WARNING)
                    THEN
                         l_valid_for_price_break := 'Y';
                    END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  IF (PO_LOG.d_stmt) THEN
                        PO_LOG.stmt(d_mod, d_position, 'In exception of  validate_unit_price_change ', SQLERRM);
                  END IF;
                 l_valid_for_price_break := 'N';
                 x_pricing_attributes_rec.return_mssg_tbl(i) := SQLERRM;
                 x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
              END;

          ELSE
             l_valid_for_price_break := 'Y';
          END IF;

    END IF;

    d_position := 40;

    IF l_valid_for_price_break = 'Y' THEN

          d_position := 50;

          BEGIN

              l_return_status := FND_API.G_RET_STS_SUCCESS;
              l_pricing_date := NULL;
              PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PRICE_DATE(p_api_version               => 1.0,
                                                        p_source_document_header_id => x_pricing_attributes_rec.source_doc_hdr_id_tbl(i),
                                                        p_source_document_line_id   => x_pricing_attributes_rec.source_doc_line_id_tbl(i),
                                                        p_order_line_id             => x_pricing_attributes_rec.po_line_id_tbl(i),
                                                        p_quantity                  => x_pricing_attributes_rec.quantity_tbl(i),
                                                        p_ship_to_location_id       => x_pricing_attributes_rec.ship_to_loc_tbl(i),
                                                        p_ship_to_organization_id   => x_pricing_attributes_rec.ship_to_org_tbl(i),
                                                        p_need_by_date              => x_pricing_attributes_rec.need_by_date_tbl(i),
                                                        x_pricing_date              => l_pricing_date,
                                                        x_return_status             => l_return_status,
                                                        p_order_type                => 'PO');

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 app_exception.raise_exception;
               END IF;

               IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   x_pricing_attributes_rec.pricing_date_tbl(i) := nvl(l_pricing_date,sysdate);

                   IF (PO_LOG.d_stmt) THEN
                      PO_LOG.stmt(d_mod, d_position, 'CUSTOM_PRICE_DATE ', l_pricing_date);
                    END IF;
               END IF;

               d_position := 60;
               index_tbl(x_pricing_attributes_rec.po_line_id_tbl(i)) := i;
               copy_price_break_attributes(source_rec   => x_pricing_attributes_rec,
                                           source_index => i,
                                           dest_rec     => x_price_break_rec,
                                           dest_index   => l_count);

               l_count := l_count + 1;
               d_position := 70;
          EXCEPTION
              WHEN OTHERS THEN
                  IF (PO_LOG.d_stmt) THEN
                        PO_LOG.stmt(d_mod, d_position, 'In exception of  GET_CUSTOM_PRICE_DATE ', SQLERRM);
                  END IF;
                 l_valid_for_price_break := 'N';
                 x_pricing_attributes_rec.return_mssg_tbl(i) := SQLERRM;
                 x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
          END;

    END IF;

    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Valid for price break ', l_valid_for_price_break);
    END IF;

  END LOOP;

  d_position := 80;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END get_lines_for_price_break;

-----------------------------------------------------------------------
--Start of Comments
--Name: copy_pricing_attributes
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to validate Price update on Line.
--Parameters:
--IN:
-- pricing_attributes_rec
--  Record of pricing_attributes_rec_type. Contains all attributes needed for pricing.
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE copy_pricing_attributes(
         source_rec   IN     PO_PDOI_TYPES.pricing_attributes_rec_type,
         source_index IN     BINARY_INTEGER,
         dest_rec     IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         dest_index   IN     BINARY_INTEGER
         )
IS
  d_mod CONSTANT VARCHAR2(100) := D_copy_pricing_attributes;
  d_position NUMBER := 0;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  IF dest_index = 1 then
      PO_PDOI_TYPES.fill_all_pricing_attr( p_num_records => 1,
                                           x_pricing_rec => dest_rec);
  ELSE
      dest_rec.rec_count := dest_rec.rec_count + 1;
      dest_rec.po_header_id_tbl.extend;
      dest_rec.po_line_id_tbl.extend;
      dest_rec.base_unit_price_tbl.extend;
      dest_rec.org_id_tbl.extend;
      dest_rec.po_vendor_id_tbl.extend;
      dest_rec.po_vendor_site_id_tbl.extend;
      dest_rec.creation_date_tbl.extend;
      dest_rec.order_type_tbl.extend;
      dest_rec.ship_to_loc_tbl.extend;
      dest_rec.ship_to_org_tbl.extend;
      dest_rec.item_id_tbl.extend;
      dest_rec.item_revision_tbl.extend;
      dest_rec.category_id_tbl.extend;
      dest_rec.supplier_item_num_tbl.extend;
      dest_rec.source_document_type_tbl.extend;
      dest_rec.source_doc_hdr_id_tbl.extend;
      dest_rec.source_doc_line_id_tbl.extend;
      dest_rec.allow_price_override_flag_tbl.extend;
      dest_rec.currency_code_tbl.extend;
      dest_rec.need_by_date_tbl.extend;
      dest_rec.pricing_date_tbl.extend;
      dest_rec.quantity_tbl.extend;
      dest_rec.uom_tbl.extend;
      dest_rec.unit_price_tbl.extend;
      dest_rec.existing_line_flag_tbl.extend;
      dest_rec.processed_flag_tbl.extend;
      dest_rec.return_status_tbl.extend;
      dest_rec.return_mssg_tbl.extend;
      dest_rec.draft_id_tbl.extend;
      dest_rec.pricing_src_tbl.extend; -- Bug 18891225
  END IF;

  dest_rec.po_header_id_tbl(dest_index) := source_rec.po_header_id_tbl(source_index);
  dest_rec.po_line_id_tbl(dest_index) := source_rec.po_line_id_tbl(source_index);
  dest_rec.base_unit_price_tbl(dest_index) := source_rec.base_unit_price_tbl(source_index);
  dest_rec.org_id_tbl(dest_index) := source_rec.org_id_tbl(source_index);
  dest_rec.po_vendor_id_tbl(dest_index) := source_rec.po_vendor_id_tbl(source_index);
  dest_rec.po_vendor_site_id_tbl(dest_index) := source_rec.po_vendor_site_id_tbl(source_index);
  dest_rec.creation_date_tbl(dest_index) := source_rec.creation_date_tbl(source_index);
  dest_rec.order_type_tbl(dest_index) := source_rec.order_type_tbl(source_index);
  dest_rec.ship_to_loc_tbl(dest_index) := source_rec.ship_to_loc_tbl(source_index);
  dest_rec.ship_to_org_tbl(dest_index) := source_rec.ship_to_org_tbl(source_index);
  dest_rec.item_id_tbl(dest_index) := source_rec.item_id_tbl(source_index);
  dest_rec.item_revision_tbl(dest_index) := source_rec.item_revision_tbl(source_index);
  dest_rec.category_id_tbl(dest_index) := source_rec.category_id_tbl(source_index);
  dest_rec.supplier_item_num_tbl(dest_index) := source_rec.supplier_item_num_tbl(source_index);
  dest_rec.source_document_type_tbl(dest_index) := source_rec.source_document_type_tbl(source_index);
  dest_rec.source_doc_hdr_id_tbl(dest_index) := source_rec.source_doc_hdr_id_tbl(source_index);
  dest_rec.source_doc_line_id_tbl(dest_index) := source_rec.source_doc_line_id_tbl(source_index);
  dest_rec.allow_price_override_flag_tbl(dest_index) := source_rec.allow_price_override_flag_tbl(source_index);
  dest_rec.currency_code_tbl(dest_index) := source_rec.currency_code_tbl(source_index);
  dest_rec.need_by_date_tbl(dest_index) := source_rec.need_by_date_tbl(source_index);
  dest_rec.pricing_date_tbl(dest_index) := source_rec.pricing_date_tbl(source_index);
  dest_rec.quantity_tbl(dest_index) := source_rec.quantity_tbl(source_index);
  dest_rec.uom_tbl(dest_index) := source_rec.uom_tbl(source_index);
  dest_rec.unit_price_tbl(dest_index) := source_rec.unit_price_tbl(source_index);
  dest_rec.existing_line_flag_tbl(dest_index) := source_rec.existing_line_flag_tbl(source_index);
  dest_rec.processed_flag_tbl(dest_index) := source_rec.processed_flag_tbl(source_index);
  dest_rec.return_status_tbl(dest_index) := source_rec.return_status_tbl(source_index);
  dest_rec.return_mssg_tbl(dest_index) := source_rec.return_mssg_tbl(source_index);
  dest_rec.draft_id_tbl(dest_index) := source_rec.draft_id_tbl(source_index);
  dest_rec.pricing_src_tbl(dest_index) := source_rec.pricing_src_tbl(source_index); -- Bug 18891225

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END copy_pricing_attributes;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_lines_for_advanced_pricing
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to get lines valid for QP Call.
--Parameters:
--IN:
--IN OUT:
-- x_pricing_attributes_rec
--  Record of pricing_attributes_rec_type. Contains all attributes needed for pricing.
-- x_advanced_pricing_rec
--  Record of pricing_attributes_rec_type containing lines valid for QP call.
-- index_tbl
--  Index table
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_lines_for_advanced_pricing(
         x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         x_advanced_pricing_rec   IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
         index_tbl                IN OUT NOCOPY dbms_sql.number_table)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_lines_for_advanced;
  d_position NUMBER := 0;

  l_count BINARY_INTEGER := 1;

  l_result_set_id NUMBER;
  l_result_type VARCHAR2(30);
  l_results PO_VALIDATION_RESULTS_TYPE;

  l_valid_for_advanced_pricing VARCHAR2(1);

  l_qp_license VARCHAR2(30) := NULL;
  l_qp_license_product VARCHAR2(30) := NULL;

  l_pricing_date PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_return_status VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT', l_qp_license);
  l_qp_license_product := FND_PROFILE.VALUE_SPECIFIC(NAME => 'QP_LICENSED_FOR_PRODUCT',application_id => 201);

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_mod, d_position, ' l_qp_license ', l_qp_license);
        PO_LOG.stmt(d_mod, d_position, ' l_qp_license_product ', l_qp_license_product);
  END IF;

  IF NOT (( Nvl(l_qp_license,'X') = 'PO') OR
             ( Nvl (l_qp_license_product,'X') = 'PO' ))
  THEN
      RETURN;
  END IF;

  d_position := 20;

  FOR i IN 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
  LOOP

    l_valid_for_advanced_pricing := 'N';

    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Line id ', x_pricing_attributes_rec.po_line_id_tbl(i));
    END IF;

    IF x_pricing_attributes_rec.progress_payment_flag_tbl(i) = 'N'  -- Not Complex
       AND (x_pricing_attributes_rec.source_document_type_tbl(i) IS NOT NULL -- Either has source doc or enhanced pricing is enabled
          OR x_pricing_attributes_rec.source_doc_hdr_id_tbl(i) IS NOT NULL
          OR x_pricing_attributes_rec.enhanced_pricing_flag_tbl(i) = 'Y')
       AND (x_pricing_attributes_rec.req_contractor_status(i) IS NULL
            OR x_pricing_attributes_rec.req_contractor_status(i) <> 'ASSIGNED')
       AND x_pricing_attributes_rec.order_type_lookup_tbl(i) NOT IN ('FIXED PRICE', 'AMOUNT')
       AND x_pricing_attributes_rec.return_status_tbl(i) = FND_API.G_RET_STS_SUCCESS THEN

          d_position := 30;
          IF (x_pricing_attributes_rec.existing_line_flag_tbl(i) = 'Y'
              AND x_pricing_attributes_rec.source_doc_line_id_tbl(i) IS NULL) THEN

              d_position := 40;
              -- If source_doc_line_id_tbl is not null then these validations are already done in validate_price_break
             BEGIN

                 PO_VALIDATIONS.validate_unit_price_change( p_line_id_tbl => PO_TBL_NUMBER(x_pricing_attributes_rec.po_line_id_tbl(i))
                                                          , p_price_break_lookup_code_tbl => PO_TBL_VARCHAR30(x_pricing_attributes_rec.price_break_lookup_code_tbl(i))
                                                          , p_amount_changed_flag_tbl => PO_TBL_VARCHAR1(x_pricing_attributes_rec.amount_changed_flag_tbl(i))
                                                          , p_stopping_result_type => PO_VALIDATIONS.c_result_type_FAILURE
                                                          , x_result_type => l_result_type
                                                          , x_result_set_id => l_result_set_id
                                                          , x_results => l_results);

                  d_position := 50;

                  IF (PO_VALIDATIONS.result_type_rank(l_result_type) >=
                        c_result_type_rank_WARNING)
                  THEN
                        l_valid_for_advanced_pricing := 'Y';
                  END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  IF (PO_LOG.d_stmt) THEN
                        PO_LOG.stmt(d_mod, d_position, 'In exception of  validate_unit_price_change ', SQLERRM);
                  END IF;
                 l_valid_for_advanced_pricing := 'N';
                 x_pricing_attributes_rec.return_mssg_tbl(i) := SQLERRM;
                 x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
              END;

          ELSE
             l_valid_for_advanced_pricing := 'Y';
          END IF;
    END IF;

    IF l_valid_for_advanced_pricing = 'Y'
       AND x_pricing_attributes_rec.source_doc_line_id_tbl(i) IS NULL THEN

          BEGIN
          d_position := 60;

          l_return_status := FND_API.G_RET_STS_SUCCESS;
          l_pricing_date := NULL;
          PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PRICE_DATE(p_api_version               => 1.0,
                                                    p_source_document_header_id => x_pricing_attributes_rec.source_doc_hdr_id_tbl(i),
                                                    p_source_document_line_id   => NULL,
                                                    p_order_line_id             => x_pricing_attributes_rec.po_line_id_tbl(i), -- <Bug 3754828>
                                                    p_quantity                  => x_pricing_attributes_rec.quantity_tbl(i),
                                                    p_ship_to_location_id       => x_pricing_attributes_rec.ship_to_loc_tbl(i),
                                                    p_ship_to_organization_id   => x_pricing_attributes_rec.ship_to_org_tbl(i),
                                                    p_need_by_date              => x_pricing_attributes_rec.need_by_date_tbl(i),
                                                    x_pricing_date              => l_pricing_date,
                                                    x_return_status             => l_return_status,
                                                    p_order_type                => 'PO');

          d_position := 70;
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                app_exception.raise_exception;
          END IF;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              IF (PO_LOG.d_stmt) THEN
                    PO_LOG.stmt(d_mod, d_position, 'CUSTOM_PRICE_DATE ', l_pricing_date);
              END IF;
             x_pricing_attributes_rec.pricing_date_tbl(i) := nvl(l_pricing_date,sysdate);
         END IF;

        EXCEPTION
              WHEN OTHERS THEN
                  IF (PO_LOG.d_stmt) THEN
                        PO_LOG.stmt(d_mod, d_position, 'In exception of  GET_CUSTOM_PRICE_DATE ', SQLERRM);
                  END IF;
                 l_valid_for_advanced_pricing := 'N';
                 x_pricing_attributes_rec.return_mssg_tbl(i) := SQLERRM;
                 x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
          END;

    END IF;

     IF l_valid_for_advanced_pricing = 'Y' THEN
       d_position := 80;

       index_tbl(x_pricing_attributes_rec.po_line_id_tbl(i)) := i;

       copy_pricing_attributes(source_rec   => x_pricing_attributes_rec,
                               source_index => i,
                               dest_rec     => x_advanced_pricing_rec,
                               dest_index   => l_count);

       l_count := l_count + 1;
     END IF;

    d_position := 90;
    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Valid for advanced pricing ', l_valid_for_advanced_pricing);
    END IF;

  END LOOP;

  d_position := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END get_lines_for_advanced_pricing;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_price_from_req
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to get unit_price, base_unit_price, quantity, amount
--  From req in PO Currency,
--Parameters:
--IN:
--IN OUT:
-- x_req_price_attr - Record type of req_price_attributes
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE get_price_from_req (x_req_price_attr IN OUT NOCOPY req_price_attributes)
IS
  d_mod                        CONSTANT VARCHAR2(100) := D_get_price_from_req;
  d_position                   NUMBER := 0;
  l_key                        po_session_gt.key%TYPE;
  l_inverse_rate_display_flag  VARCHAR2(1) := 'N';
  l_display_rate               NUMBER;
  l_rate                       NUMBER;
  l_precision                  NUMBER;
  l_ext_precision              NUMBER;
  l_min_acct_unit              NUMBER;

  CURSOR req_attributes IS
   SELECT gt.index_num1, -- po_line_id
          gt.index_num2, -- req_line_id
          gt.num1, --po_org_id
          gt.num2, -- po_rate
          gt.char1, -- po_currency_code
          NVL(gt.char2, psp.default_rate_type), -- rate_type
          gt.date1, -- rate_date
          req_fsp.set_of_books_id,  -- req_sob_id
          po_fsp.set_of_books_id,   -- po_sob_id
          prl.order_type_lookup_code,
          prl.base_unit_price,
          prl.unit_price,
          NVL(prl.currency_unit_price,prl.unit_price),
          prl.currency_code,  -- req_currency
          gsb.currency_code,  -- req_ou_currency
          FND_API.G_RET_STS_SUCCESS return_status,
          NULL return_message
   FROM   po_requisition_lines_all prl,
          financials_system_params_all req_fsp,
          gl_sets_of_books gsb,
          financials_system_params_all po_fsp,
          po_system_parameters_all psp,
          po_session_gt gt
   WHERE  gt.key = l_key
          AND gt.index_num2 = prl.requisition_line_id
          AND gt.num1 = po_fsp.org_id
          AND psp.org_id = po_fsp.org_id
          AND nvl(prl.org_id, -99) = nvl(req_fsp.org_id, -99)
          AND req_fsp.set_of_books_id = gsb.set_of_books_id;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  -- get key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  FORALL i IN 1..x_req_price_attr.po_line_id_tbl.COUNT
   INSERT INTO po_session_gt
                       (key,
                        index_num1, -- po_line_id
                        index_num2, -- req_line_id
                        num1, --po_org_id
                        num2, -- po_rate
                        char1, -- po_currency_code
                        char2, -- rate_type
                        date1 -- rate_date
                        )
    SELECT l_key,
           x_req_price_attr.po_line_id_tbl(i),
           x_req_price_attr.req_line_id_tbl(i),
           x_req_price_attr.po_org_id_tbl(i),
           x_req_price_attr.po_rate_tbl(i),
           x_req_price_attr.po_currency_tbl(i),
           x_req_price_attr.po_rate_type_tbl(i),
           x_req_price_attr.po_rate_date_tbl(i)
    FROM   dual;

  d_position := 10;

  OPEN req_attributes;

  FETCH req_attributes
  BULK COLLECT INTO
           x_req_price_attr.po_line_id_tbl,
           x_req_price_attr.req_line_id_tbl,
           x_req_price_attr.po_org_id_tbl,
           x_req_price_attr.po_rate_tbl,
           x_req_price_attr.po_currency_tbl,
           x_req_price_attr.po_rate_type_tbl,
           x_req_price_attr.po_rate_date_tbl,
           x_req_price_attr.req_sob_id_tbl,
           x_req_price_attr.po_sob_id_tbl,
           x_req_price_attr.req_order_type_tbl,
           x_req_price_attr.req_base_price_tbl,
           x_req_price_attr.req_unit_price_tbl,
           x_req_price_attr.req_curr_price_tbl,
           x_req_price_attr.req_currency_tbl,
           x_req_price_attr.req_ou_curr_tbl,
           x_req_price_attr.return_status_tbl,
           x_req_price_attr.return_mssg_tbl;
  CLOSE req_attributes;

   d_position := 20;

   FOR i IN 1..x_req_price_attr.po_line_id_tbl.COUNT
   LOOP
        d_position := 30;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Line id ', x_req_price_attr.po_line_id_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Req Line id ', x_req_price_attr.req_line_id_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Req OU Currency ', x_req_price_attr.req_ou_curr_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'PO Currency ', x_req_price_attr.po_currency_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Req SOB ', x_req_price_attr.req_sob_id_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'PO SOB ', x_req_price_attr.po_sob_id_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Req Currency ', x_req_price_attr.req_currency_tbl(i));
        END IF;

       l_rate := NULL;
       l_inverse_rate_display_flag := NULL;
       l_display_rate := NULL;
       l_precision := NULL;
       l_ext_precision := NULL;
       l_min_acct_unit := NULL;

       -- Conversion not required if req_ou_currency = Po currency
        IF x_req_price_attr.req_ou_curr_tbl(i) <> x_req_price_attr.po_currency_tbl(i) THEN

            -- If req set of books = po set of books then take rate from po_header
            -- Else take rate between req ou currency and PO currency
             IF x_req_price_attr.req_sob_id_tbl(i) = x_req_price_attr.po_sob_id_tbl(i) THEN
                l_rate := x_req_price_attr.po_rate_tbl(i);
                 d_position := 40;
             ELSE
                po_currency_sv.get_rate( x_set_of_books_id              => x_req_price_attr.req_sob_id_tbl(i),
                                         x_currency_code                => x_req_price_attr.po_currency_tbl(i),
                                         x_rate_type                    => x_req_price_attr.po_rate_type_tbl(i),
                                         x_rate_date                    => x_req_price_attr.po_rate_date_tbl(i),
                                         x_inverse_rate_display_flag    => l_inverse_rate_display_flag,
                                         x_rate                         => l_rate,
                                         x_display_rate                 => l_display_rate);

                 IF l_rate IS NULL THEN

                    IF (PO_LOG.d_stmt) THEN
                      PO_LOG.stmt(d_mod, d_position, 'Currency conversion not defined between PO currency and Req OU currency. ');
                    END IF;

                    x_req_price_attr.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
                    x_req_price_attr.return_mssg_tbl(i) := 'PO_PDOI_CURR_CONV_NOT_DEFINED';

                 END IF;
                 d_position := 50;
             END IF;

             IF l_rate IS NOT NULL THEN
                 -- Take precision
                  fnd_currency.get_info (x_req_price_attr.po_currency_tbl(i),
                                        l_precision,
                                        l_ext_precision,
                                        l_min_acct_unit);

                  IF (PO_LOG.d_stmt) THEN
                      PO_LOG.stmt(d_mod, d_position, 'l_rate ', l_rate);
                      PO_LOG.stmt(d_mod, d_position, 'l_ext_precision ', l_ext_precision);
                      PO_LOG.stmt(d_mod, d_position, 'Req order type lookup ', x_req_price_attr.req_order_type_tbl(i));
                      PO_LOG.stmt(d_mod, d_position, 'Req base unit price ', x_req_price_attr.req_base_price_tbl(i));
                      PO_LOG.stmt(d_mod, d_position, 'Req unit price ', x_req_price_attr.req_unit_price_tbl(i));
                      PO_LOG.stmt(d_mod, d_position, 'Req currency unit price ', x_req_price_attr.req_curr_price_tbl(i));
                  END IF;
                    d_position := 60;
                  -- Base unit price are in functional currency of Req.
                  -- So need to convert.
                  -- unit_price has its corresposing currency_unit_price in Req currency.
                  -- So if req currency = PO currency then we can directly take currency_unit_price.

                      d_position := 70;
                      x_req_price_attr.req_base_price_tbl(i) := round(x_req_price_attr.req_base_price_tbl(i)/l_rate, NVL(l_ext_precision, 15));

                      IF x_req_price_attr.req_currency_tbl(i) = x_req_price_attr.po_currency_tbl(i) THEN
                         x_req_price_attr.req_unit_price_tbl(i) :=  x_req_price_attr.req_curr_price_tbl(i);
                         d_position := 80;
                      ELSE
                         x_req_price_attr.req_unit_price_tbl(i) := round(x_req_price_attr.req_unit_price_tbl(i)/l_rate, NVL(l_ext_precision, 15));
                         d_position := 90;
                      END IF;
             END IF;
        END IF;

       IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Req unit Price ', x_req_price_attr.req_unit_price_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Req base unit price ', x_req_price_attr.req_base_price_tbl(i));
      END IF;
   END LOOP;


    DELETE FROM  po_session_gt
           WHERE key = l_key;

    d_position := 90;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END get_price_from_req;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_req_price_attr
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to initialize x_req_price_rec
-- or add p_num_records in x_req_price_rec
--Parameters:
--IN:
-- p_num_records
-- x_req_price_rec
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE fill_all_req_price_attr
( p_num_records   IN            NUMBER,
  x_req_price_rec IN OUT NOCOPY req_price_attributes
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_fill_all_req_price_attr;
  d_position NUMBER := 0;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

   IF (x_req_price_rec.rec_count is null) then
      x_req_price_rec.po_line_id_tbl := PO_TBL_NUMBER();
      x_req_price_rec.req_line_id_tbl := PO_TBL_NUMBER();
      x_req_price_rec.po_org_id_tbl := PO_TBL_NUMBER();
      x_req_price_rec.po_currency_tbl := PO_TBL_VARCHAR30();
      x_req_price_rec.po_rate_tbl := PO_TBL_NUMBER();
      x_req_price_rec.po_rate_type_tbl := PO_TBL_VARCHAR30();
      x_req_price_rec.po_rate_date_tbl := PO_TBL_DATE();
      x_req_price_rec.req_unit_price_tbl := PO_TBL_NUMBER();
      x_req_price_rec.req_base_price_tbl := PO_TBL_NUMBER();
      x_req_price_rec.rec_count := 0;
   END IF;

  x_req_price_rec.rec_count := x_req_price_rec.rec_count + p_num_records;

  x_req_price_rec.po_line_id_tbl.EXTEND(p_num_records);
  x_req_price_rec.req_line_id_tbl.EXTEND(p_num_records);
  x_req_price_rec.po_org_id_tbl.EXTEND(p_num_records);
  x_req_price_rec.po_currency_tbl.EXTEND(p_num_records);
  x_req_price_rec.po_rate_tbl.EXTEND(p_num_records);
  x_req_price_rec.po_rate_type_tbl.EXTEND(p_num_records);
  x_req_price_rec.po_rate_date_tbl.EXTEND(p_num_records);
  x_req_price_rec.req_unit_price_tbl.EXTEND(p_num_records);
  x_req_price_rec.req_base_price_tbl.EXTEND(p_num_records);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END fill_all_req_price_attr;

-----------------------------------------------------------------------
--Start of Comments
--Name: copy_req_price_attr
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to copy req related attributes
-- from pricing_attributes_rec_type to req_price_attributes
--Parameters:
--IN:
-- source_rec - pricing_attributes_rec_type
-- source_index - Source index
--IN OUT:
-- dest_rec -req_price_attributes
-- dest_index - destination index
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE copy_req_price_attr(
         source_rec   IN     PO_PDOI_TYPES.pricing_attributes_rec_type,
         source_index IN     BINARY_INTEGER,
         dest_rec     IN OUT NOCOPY req_price_attributes,
         dest_index   IN OUT NOCOPY BINARY_INTEGER
         )
IS
  d_mod CONSTANT VARCHAR2(100) := D_copy_req_price_attr;
  d_position NUMBER := 0;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  fill_all_req_price_attr( p_num_records => source_rec.req_line_ids(source_index).COUNT,
                           x_req_price_rec => dest_rec);

  FOR i in 1..source_rec.req_line_ids(source_index).COUNT
  LOOP
      dest_rec.po_line_id_tbl(dest_index) := source_rec.po_line_id_tbl(source_index);
      dest_rec.req_line_id_tbl(dest_index) := source_rec.req_line_ids(source_index)(i);
      dest_rec.po_org_id_tbl(dest_index) := source_rec.org_id_tbl(source_index);
      dest_rec.po_currency_tbl(dest_index) := source_rec.currency_code_tbl(source_index);
      dest_rec.po_rate_tbl(dest_index) := source_rec.rate_tbl(source_index);
      dest_rec.po_rate_type_tbl(dest_index) := source_rec.rate_type_tbl(source_index);
      dest_rec.po_rate_date_tbl(dest_index) := source_rec.rate_date_tbl(source_index);
      dest_index := dest_index +1;

      IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_mod, d_position, 'Req Line id ',source_rec.req_line_ids(source_index)(i));
      END IF;

  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END copy_req_price_attr;
-----------------------------------------------------------------------
--Start of Comments
--Name: get_price_from_req
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to get minimum req line price.
--Parameters:
--IN:
--IN OUT:
-- x_pricing_attributes_rec
--  Record of x_pricing_attributes_rec_type. Contains all attributes needed for pricing.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_price_from_req(
                x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type)
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_price_from_req;
  d_position NUMBER := 0;

  rec_price_rec         req_price_attributes;
  l_index_tbl           dbms_sql.number_table;
  l_count               NUMBER:= 1;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_req_unit_price_tbl  PO_TBL_NUMBER;
  l_req_base_price_tbl  PO_TBL_NUMBER;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  -- Copy lines which have req reference in rec_price_rec.

  FOR i IN 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
  LOOP
     IF x_pricing_attributes_rec.req_line_ids(i).COUNT > 0
         AND x_pricing_attributes_rec.order_type_lookup_tbl(i) NOT IN ('FIXED PRICE', 'AMOUNT')
         AND x_pricing_attributes_rec.doc_sub_type_tbl(i) = 'STANDARD'
         AND x_pricing_attributes_rec.existing_line_flag_tbl(i) = 'N' THEN
         d_position := 10;

         IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_mod, d_position, 'Copying req pricing attributes for line  ', x_pricing_attributes_rec.po_line_id_tbl(i));
         END IF;

        copy_req_price_attr( source_rec   => x_pricing_attributes_rec,
                             source_index => i,
                             dest_rec     => rec_price_rec,
                             dest_index   => l_count);

         l_index_tbl(x_pricing_attributes_rec.po_line_id_tbl(i)) := i;
         d_position := 20;
     END IF;
  END LOOP;

  IF NVL(rec_price_rec.rec_count,0) > 0 THEN

       d_position := 30;
       get_price_from_req (x_req_price_attr => rec_price_rec);

       d_position := 40;

       FOR i IN 1..rec_price_rec.po_line_id_tbl.COUNT
       LOOP
          IF rec_price_rec.return_status_tbl(i) <> FND_API.G_RET_STS_SUCCESS
              AND l_index_tbl.exists(rec_price_rec.po_line_id_tbl(i)) THEN
              x_pricing_attributes_rec.return_status_tbl(l_index_tbl(rec_price_rec.po_line_id_tbl(i))) := rec_price_rec.return_status_tbl(i);
              x_pricing_attributes_rec.return_mssg_tbl(l_index_tbl(rec_price_rec.po_line_id_tbl(i))) := rec_price_rec.return_mssg_tbl(i);
          END IF;
       END LOOP;

        -- SQL What : Gets the Minimum req line price
        -- SQL Why  : If multiple req lines are grouped into a single PO line
        --            Then price on PO line should be minimum req line price.
        SELECT po_line_id,
               Min(req_base_price),
               Min(req_unit_price)
        BULK   COLLECT INTO l_po_line_id_tbl, l_req_base_price_tbl, l_req_unit_price_tbl
        FROM   (SELECT po_line.val  po_line_id,
                       req_base.val req_base_price,
                       req_unit.val req_unit_price
                FROM   (SELECT column_value val,
                               ROWNUM       rn
                        FROM   TABLE(rec_price_rec.po_line_id_tbl)) po_line,
                       (SELECT column_value val,
                               ROWNUM       rn
                        FROM   TABLE(rec_price_rec.req_base_price_tbl)) req_base,
                       (SELECT column_value val,
                               ROWNUM       rn
                        FROM   TABLE(rec_price_rec.req_unit_price_tbl)) req_unit,
                       (SELECT column_value val,
                               ROWNUM       rn
                        FROM   TABLE(rec_price_rec.return_status_tbl)) return_status
                WHERE  po_line.rn = req_base.rn
                       AND req_base.rn = req_unit.rn
                       AND req_unit.rn = return_status.rn
                       AND return_status.val = FND_API.G_RET_STS_SUCCESS)
        GROUP  BY po_line_id;

      d_position := 50;
      FOR i IN 1..l_po_line_id_tbl.COUNT
      LOOP
         d_position := 60;
         IF l_index_tbl.exists(l_po_line_id_tbl(i)) THEN
            d_position := 70;
            x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_po_line_id_tbl(i))) := l_req_base_price_tbl(i);
            x_pricing_attributes_rec.min_req_line_price_tbl(l_index_tbl(l_po_line_id_tbl(i))) := l_req_unit_price_tbl(i);

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_mod, d_position, 'Getting price from req for line  ', x_pricing_attributes_rec.po_line_id_tbl(l_index_tbl(l_po_line_id_tbl(i))));
              PO_LOG.stmt(d_mod, d_position, 'Base Unit price  ', x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_po_line_id_tbl(i))));
              PO_LOG.stmt(d_mod, d_position, 'Minimum Req Line   ', x_pricing_attributes_rec.min_req_line_price_tbl(l_index_tbl(l_po_line_id_tbl(i))));
            END IF;

         END IF;
      END LOOP;

  END IF;

  d_position := 80;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END get_price_from_req;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_line_price
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to update Price on Line on the basis of price break
-- and QP pricing API call
--Parameters:
--IN:
-- x_pricing_attributes_rec
--  Record of pricing_attributes_rec_type. Contains all attributes needed for pricing.
--IN OUT:
--OUT:
-- x_return_status
--End of Comments
------------------------------------------------------------------------
  PROCEDURE get_line_price(  x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type
                           , x_return_status          OUT NOCOPY    VARCHAR2
                          )
IS
  d_mod                  CONSTANT VARCHAR2(100) := D_get_line_price;
  d_position             NUMBER := 0;
  l_price_break_rec      PO_PDOI_TYPES.pricing_attributes_rec_type;
  l_advanced_pricing_rec PO_PDOI_TYPES.pricing_attributes_rec_type;
  l_index_tbl            dbms_sql.number_table;
  l_custom_price         NUMBER;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Algorithm
  -- 1) Update base unit price from req (minimum base unit price if multiple reqs)
  -- 2) Update minimum req unit price in min_req_line_price_tbl
  -- 3) Call get_break_price API for lines elligible for price breaks.
  -- 4) Update base_unit_price and price_break_id for these lines.
  -- 5) Call get_advanced_price API for lines elligible for QP.
  -- 6) Update base_unit_price and unit_price.
  -- 7) If no price is obtained from price break or QP and if a backing req is there
  -- update unit price with min_req_line_price_tbl
  -- 8) Call custom API.


  -- get base unit price from req
  d_position := 10;
  get_price_from_req(x_pricing_attributes_rec => x_pricing_attributes_rec);

  -- Get Price from Source Doc
  d_position := 20;
  get_lines_for_price_break( x_pricing_attributes_rec => x_pricing_attributes_rec,
                             x_price_break_rec        => l_price_break_rec,
                             index_tbl                => l_index_tbl);

  d_position := 30;

  IF NVL(l_price_break_rec.rec_count,0) > 0 THEN
     d_position := 40;
     PO_SOURCING2_SV.get_break_price(p_api_version => 1.0,
                                     x_pricing_attributes_rec => l_price_break_rec,
                                     x_return_status => x_return_status
                                     );

    d_position := 50;
    FOR i in 1..l_price_break_rec.po_line_id_tbl.COUNT
    LOOP
      IF l_index_tbl.exists(l_price_break_rec.po_line_id_tbl(i)) THEN

          IF l_price_break_rec.return_status_tbl(i) = FND_API.G_RET_STS_SUCCESS THEN
              x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))) := l_price_break_rec.base_unit_price_tbl(i);
              x_pricing_attributes_rec.price_break_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))) := l_price_break_rec.price_break_id_tbl(i);
              x_pricing_attributes_rec.pricing_src_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))) := 'SOURCE_DOC';

              IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_mod, d_position, 'updating Price from source doc for line  ', x_pricing_attributes_rec.po_line_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Base Unit price  ', x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Source Doc Header Id  ', x_pricing_attributes_rec.source_doc_hdr_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Source Doc Line Id  ', x_pricing_attributes_rec.source_doc_line_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Price Break Id   ', x_pricing_attributes_rec.price_break_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
              END IF;
          ELSE
             x_pricing_attributes_rec.return_status_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))) := l_price_break_rec.return_status_tbl(i);
             x_pricing_attributes_rec.return_mssg_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))) := l_price_break_rec.return_mssg_tbl(i);

              IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_mod, d_position, 'Error occured while getting price from source doc for line  ', x_pricing_attributes_rec.po_line_id_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Return status  ', x_pricing_attributes_rec.return_status_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Return Message  ', x_pricing_attributes_rec.return_mssg_tbl(l_index_tbl(l_price_break_rec.po_line_id_tbl(i))));
              END IF;
          END IF;

      END IF;
    END LOOP;
  END IF;

  -- Deleting the index table as it will be reused in get_lines_for_advanced_pricing.
  d_position := 60;
  l_index_tbl.delete;

  -- Get the lines which are valid for QP call.
  get_lines_for_advanced_pricing(x_pricing_attributes_rec => x_pricing_attributes_rec,
                                 x_advanced_pricing_rec   => l_advanced_pricing_rec,
                                 index_tbl                => l_index_tbl);
  d_position := 70;

  IF NVL(l_advanced_pricing_rec.rec_count,0) > 0 THEN
     d_position := 80;
     PO_ADVANCED_PRICE_PVT.get_advanced_price(p_api_version            => 1.0,
                                              x_pricing_attributes_rec => l_advanced_pricing_rec,
                                              x_return_status          => x_return_status);
     d_position := 90;

     FOR i in 1..l_advanced_pricing_rec.po_line_id_tbl.COUNT
      LOOP
         IF l_index_tbl.exists(l_advanced_pricing_rec.po_line_id_tbl(i)) THEN

            IF l_advanced_pricing_rec.return_status_tbl(i) = FND_API.G_RET_STS_SUCCESS
	       AND l_advanced_pricing_rec.pricing_src_tbl(i) = 'QP'  -- Bug 18891225
	       AND l_advanced_pricing_rec.base_unit_price_tbl(i) IS NOT NULL THEN -- Bug 18702868
                x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))) := l_advanced_pricing_rec.base_unit_price_tbl(i);
                x_pricing_attributes_rec.unit_price_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))) := l_advanced_pricing_rec.unit_price_tbl(i);
                x_pricing_attributes_rec.pricing_src_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))) := 'QP';

                IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_mod, d_position, 'updating Price from QP for line  ', x_pricing_attributes_rec.po_line_id_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Base Unit price  ', x_pricing_attributes_rec.base_unit_price_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Unit   ', x_pricing_attributes_rec.unit_price_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                END IF;
            ELSE
               x_pricing_attributes_rec.return_status_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))) := l_advanced_pricing_rec.return_status_tbl(i);
               x_pricing_attributes_rec.return_mssg_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))) := l_advanced_pricing_rec.return_mssg_tbl(i);

                IF (PO_LOG.d_stmt) THEN
                  PO_LOG.stmt(d_mod, d_position, 'Error occurred from QP for line  ', x_pricing_attributes_rec.po_line_id_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Return status :  ', x_pricing_attributes_rec.return_status_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                  PO_LOG.stmt(d_mod, d_position, 'Return Message   ', x_pricing_attributes_rec.return_mssg_tbl(l_index_tbl(l_advanced_pricing_rec.po_line_id_tbl(i))));
                END IF;
            END IF;

         END IF;
      END LOOP;
  END IF;

  d_position := 100;
  l_index_tbl.delete;


  FOR i in 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
  LOOP
   d_position := 110;
    -- Update unit price with minimum req line price
    -- If price is not obtained from Source doc or Pricing API
    -- And if it is a new line.
    IF x_pricing_attributes_rec.pricing_src_tbl(i) = 'DEFAULT'
       AND x_pricing_attributes_rec.req_line_ids(i).COUNT > 0
       AND x_pricing_attributes_rec.existing_line_flag_tbl(i) = 'N'
       AND x_pricing_attributes_rec.return_status_tbl(i) = FND_API.G_RET_STS_SUCCESS THEN

           d_position := 120;
           x_pricing_attributes_rec.unit_price_tbl(i) := x_pricing_attributes_rec.min_req_line_price_tbl(i);
           x_pricing_attributes_rec.pricing_src_tbl(i) := 'REQ';

           IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_mod, d_position, 'updating Price from Req for line  ', x_pricing_attributes_rec.po_line_id_tbl(i));
              PO_LOG.stmt(d_mod, d_position, 'Unit Price  ', x_pricing_attributes_rec.unit_price_tbl(i));
          END IF;
    END IF;

    -- Call Custom Pricing API.
    BEGIN
        l_custom_price := NULL;
        PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PO_PRICE(p_api_version      => 1.0,
                                                p_order_quantity   => x_pricing_attributes_rec.quantity_tbl(i),
                                                p_ship_to_org      => x_pricing_attributes_rec.ship_to_org_tbl(i),
                                                p_ship_to_loc      => x_pricing_attributes_rec.ship_to_loc_tbl(i),
                                                p_po_line_id       => x_pricing_attributes_rec.source_doc_line_id_tbl(i),
                                                p_cum_flag         => FALSE,
                                                p_need_by_date     => x_pricing_attributes_rec.need_by_date_tbl(i),
                                                p_pricing_date     => x_pricing_attributes_rec.pricing_date_tbl(i),
                                                p_line_location_id => x_pricing_attributes_rec.line_loc_id_tbl(i),
                                                p_price            => NVL(x_pricing_attributes_rec.unit_price_tbl(i),
                                                                          x_pricing_attributes_rec.base_unit_price_tbl(i)),
                                                x_new_price        => l_custom_price,
                                                x_return_status    => x_pricing_attributes_rec.return_status_tbl(i),
                                                p_req_line_price   => x_pricing_attributes_rec.min_req_line_price_tbl(i),
                                                p_order_line_id    => x_pricing_attributes_rec.po_line_id_tbl(i));

         d_position := 130;
        IF x_pricing_attributes_rec.return_status_tbl(i) <> FND_API.G_RET_STS_SUCCESS THEN
           x_pricing_attributes_rec.return_mssg_tbl(i) := 'PO_CUSTOM_PRICE_FAILURE';
        ELSIF l_custom_price IS NOT NULL THEN
              IF l_custom_price < 0 THEN
                 x_pricing_attributes_rec.return_mssg_tbl(i) := 'PO_CUSTOM_PRICE_LESS_0';
                 x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
              ELSE
                 x_pricing_attributes_rec.unit_price_tbl(i) := l_custom_price;
                 x_pricing_attributes_rec.pricing_src_tbl(i) := 'CUSTOM';

                 IF (PO_LOG.d_stmt) THEN
                    PO_LOG.stmt(d_mod, d_position, 'updating Price from Custom API for line  ', x_pricing_attributes_rec.po_line_id_tbl(i));
                    PO_LOG.stmt(d_mod, d_position, 'Unit Price  ', x_pricing_attributes_rec.unit_price_tbl(i));
                 END IF;
              END IF;
        END IF;
    EXCEPTION
       WHEN OTHERS THEN
             x_pricing_attributes_rec.return_mssg_tbl(i) := SQLERRM;
             x_pricing_attributes_rec.return_status_tbl(i) := FND_API.G_RET_STS_ERROR;
    END;
       d_position := 140;
      -- For Debugging
      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_mod, d_position, 'Line id ', x_pricing_attributes_rec.po_line_id_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Return status ', x_pricing_attributes_rec.return_status_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Return Message ', x_pricing_attributes_rec.return_mssg_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Price Source ', x_pricing_attributes_rec.pricing_src_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Unit Price ', x_pricing_attributes_rec.unit_price_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Base Unit Price ', x_pricing_attributes_rec.base_unit_price_tbl(i));
          PO_LOG.stmt(d_mod, d_position, 'Min Req Unit Price ', x_pricing_attributes_rec.min_req_line_price_tbl(i));
      END IF;

  END LOOP;

  d_position := 150;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_mod);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.g_ret_sts_unexp_error;
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => D_PACKAGE_BASE, p_procedure_name => d_mod || '.' || d_position );
       RAISE;

END get_line_price;

--<PDOI Enhancement Bug#17063664 End>

 --<Bug 18372756>:
 ----------------------------------------------------------------------------
 --Start of Comments
 --Pre-reqs: None.
 --Modifies: PO_VALIDATION_RESULTS, sequences.
 --Locks: None.
 --Function:
 --  Inserts a row into PO_VALIDATION_RESULTS for any of the specified
 --  lines for which there are pending receipts.
 --Parameters:
 --IN:
 --p_line_id_tbl
 --  Identifies the lines that should be checked.
 --p_draft_id_tbl
 --  Used to insert messages into PO_VALIDATION_RESULTS.
 --IN OUT:
 --x_result_set_id
 --  The identifier into PO_VALIDATION_RESULTS for the results produced.
 --  If this is NULL, it will be retrieved from the sequence.
 --OUT:
 --x_result_type
 --  Indicates whether or not any error results were produced.
 --    c_result_type_FAILURE - results were produced.
 --    c_result_type_SUCCESS - no errors.
 --  VARCHAR2(30)
 --End of Comments
 -------------------------------------------------------------------------------
   PROCEDURE check_unvalidated_debit_memo(
      p_line_id_tbl IN PO_TBL_NUMBER
    , x_result_set_id IN OUT NOCOPY NUMBER
    , x_result_type OUT NOCOPY VARCHAR2)
   IS
     d_mod CONSTANT VARCHAR2(100) := D_check_unvalidated_debit_memo;
     l_calling_sequence VARCHAR2(100) := 'PO_AP_DEBIT_MEMO_UNVALIDATED';
     d_position NUMBER := 0;
   BEGIN

     IF PO_LOG.d_proc THEN
       PO_LOG.proc_begin(d_mod, 'p_line_id_tbl', p_line_id_tbl);
       PO_LOG.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
     END IF;

     d_position := 1;
     IF (x_result_set_id IS NULL) THEN
       x_result_set_id := PO_VALIDATIONS.next_result_set_id();
     END IF;

     d_position := 100;
     FORALL i IN 1 .. p_line_id_tbl.COUNT
     INSERT INTO PO_VALIDATION_RESULTS_GT
     (result_set_id
     , entity_type
     , entity_id
     , column_name
     , message_name
     )
     SELECT
       x_result_set_id
     , c_ENTITY_TYPE_LINE
     , p_line_id_tbl(i)
     , c_UNIT_PRICE
     , PO_MESSAGE_S.PO_AP_DEBIT_MEMO_UNVALIDATED
     FROM DUAL
     WHERE EXISTS
       (SELECT null
         FROM
           PO_HEADERS_ALL POH
         , PO_LINES_ALL POL
         , PO_LINE_LOCATIONS_ALL POLL
         , po_releases_all por
         WHERE POL.po_line_id = p_line_id_tbl(i)
         AND POH.po_header_id = POL.po_header_id
         AND por.po_header_id(+) = poh.po_header_id
         AND POLL.po_line_id = pol.po_line_id
         AND (poll.quantity_billed = 0 OR poll.quantity_billed is null)
         AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, NULL, NULL, l_calling_sequence) = 1
       );

     d_position := 200;
     IF (SQL%ROWCOUNT > 0) THEN
       x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
     ELSE
       x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
     END IF;

     IF PO_LOG.d_proc THEN
       PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
       PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF PO_LOG.d_exc THEN
         PO_LOG.exc(d_mod, d_position, NULL);
       END IF;
       RAISE;
   END check_unvalidated_debit_memo;


END PO_PRICE_HELPER;

/
