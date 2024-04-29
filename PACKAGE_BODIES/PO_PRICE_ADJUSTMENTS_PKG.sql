--------------------------------------------------------
--  DDL for Package Body PO_PRICE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_ADJUSTMENTS_PKG" AS
-- $Header: PO_PRICE_ADJUSTMENTS_PKG.plb 120.0.12010000.5 2013/10/03 08:45:00 inagdeo noship $

---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
  D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PRICE_ADJUSTMENTS_PKG');

-- The module base for the subprogram.
  D_popl_manual_overridden_adj CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'popl_manual_overridden_adj');

-- The module base for the subprogram.
  D_extract_price_adjustments CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'extract_price_adjustments');

-- The module base for the subprogram.
  D_complete_manual_mod_lov_map CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'complete_manual_mod_lov_map');

-- The module base for the subprogram.
  D_copy_line_adjustments CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'copy_line_adjustments');

-- The module base for the subprogram.
  D_delete_price_adjustments CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'delete_price_adjustments');

-- The module base for the subprogram.
  D_line_modifier_exist CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'line_modifier_exist');

-- The module base for the subprogram.
  D_check_man_ovr_mod_exist CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'check_man_ovr_mod_exist');

---------------------------------------------------------------------------
-- Global Constants.
---------------------------------------------------------------------------

-- Private package constants
g_pkg_name CONSTANT varchar2(30) := 'PO_PRICE_ADJUSTMENTS_PKG';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Debugging
g_debug_stmt BOOLEAN  := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;


--------------------------------------------------------------------------------
-- Forward procedure declarations.
--------------------------------------------------------------------------------

  PROCEDURE delete_line_adjs
    (p_draft_id          IN NUMBER
    ,p_order_header_id   IN NUMBER
    ,p_order_line_id_tbl IN QP_PREQ_GRP.NUMBER_TYPE
    ,p_pricing_events    IN VARCHAR2
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    ,p_pricing_call_src  IN VARCHAR2
    --To fix price override not allowed error
    ,p_allow_price_override_tbl IN PO_TBL_VARCHAR1
    ,p_log_head          IN VARCHAR2
    );

  PROCEDURE update_adj
    (p_draft_id            IN  NUMBER
    ,p_price_adjustment_id IN  NUMBER
    ,p_line_detail_index   IN  NUMBER
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    ,p_pricing_call_src       IN  VARCHAR2
    --To fix price override not allowed error
    ,p_allow_price_override_flag IN VARCHAR2
    ,px_debug_upd_adj_tbl  OUT NOCOPY NUMBER_TYPE
    ,p_log_head            IN  VARCHAR2
    );

  PROCEDURE insert_adj
    (p_draft_id        IN NUMBER
    ,p_order_header_id IN NUMBER
    ,p_doc_sub_type    IN VARCHAR2
    ,p_log_head        IN VARCHAR2
    );

  PROCEDURE update_adj_attribs
    (p_draft_id        IN NUMBER
    ,p_order_header_id IN NUMBER
    ,p_pricing_events IN VARCHAR2
    ,p_log_head       IN VARCHAR2
    );

  PROCEDURE insert_adj_attribs
    (p_draft_id        IN NUMBER
    ,p_order_header_id IN NUMBER
    ,p_log_head        IN VARCHAR2
    );

  PROCEDURE insert_adj_rec
    (p_adj_rec IN PO_PRICE_ADJUSTMENTS%ROWTYPE);

  PROCEDURE insert_draft_adj_rec
    (p_draft_id IN NUMBER
    ,p_adj_rec IN PO_PRICE_ADJUSTMENTS_V%ROWTYPE);

--------------------------------------------------------------------------------
-- Procedure definitions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_applied_modifier_code
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure checks if any modifier got applied for the given PO Header ID and Line Id
--  modifier details
--Parameters:
--IN:
--p_po_header_id
--  Identifies the header that should be checked for applied modifiers
--p_po_line_id
--  Identifies the line that should be checked for applied modifiers
--OUT:
--x_modifier_code
--  Returns the type of modifiers that are applied for the line
--Testing:
--
-- Exceptions:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE get_applied_modifier_code
    (
      p_po_header_id   IN  NUMBER
    , p_po_line_id     IN  NUMBER
    , x_modifier_code  OUT NOCOPY VARCHAR2
    )
  IS
    l_man_mod_count NUMBER;
    l_man_ovr_mod_count NUMBER;
    l_auto_mod_count NUMBER;
    l_auto_ovr_mod_count NUMBER;
    l_modifier_code VARCHAR2(100);
  BEGIN
    --Check if manual modifiers are applied
    SELECT COUNT(1)
    INTO l_man_mod_count
    FROM PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.po_header_id = p_po_header_id
    AND ADJV.po_line_id = p_po_line_id
    AND ADJV.automatic_flag = 'N'
    --AND ADJ.update_allowed = 'N'
    AND NVL(ADJV.updated_flag,'N') = 'N';

    --Check if manual overridden modifiers are applied
    SELECT COUNT(1)
    INTO l_man_ovr_mod_count
    FROM PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.po_header_id = p_po_header_id
    AND ADJV.po_line_id = p_po_line_id
    AND ADJV.automatic_flag = 'N'
    AND ADJV.update_allowed = 'Y'
    AND ADJV.updated_flag = 'Y';

    --Check if automatic modifiers are applied
    SELECT COUNT(1)
    INTO l_auto_mod_count
    FROM PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.po_header_id = p_po_header_id
    AND ADJV.po_line_id = p_po_line_id
    AND ADJV.automatic_flag = 'Y'
    --AND ADJ.update_allowed = 'N'
    AND ADJV.updated_flag = 'N';

    --Check if automatic overridden modifiers are applied
    SELECT COUNT(1)
    INTO l_auto_ovr_mod_count
    FROM PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.po_header_id = p_po_header_id
    AND ADJV.po_line_id = p_po_line_id
    AND ADJV.automatic_flag = 'Y'
    AND ADJV.update_allowed = 'Y'
    AND ADJV.updated_flag = 'Y';

    --reset count
    IF l_man_ovr_mod_count > 0 THEN
      l_man_mod_count := 1;
    END IF;

    IF l_auto_ovr_mod_count > 0 THEN
      l_auto_mod_count := 1;
    END IF;

    l_modifier_code := 'G';
    IF l_auto_mod_count > 0 THEN
      l_modifier_code := l_modifier_code||'_AUTOMATIC';
    END IF;

    IF l_man_mod_count > 0 THEN
      l_modifier_code := l_modifier_code||'_MANUAL';
    END IF;

    IF (l_auto_ovr_mod_count > 0 OR l_man_ovr_mod_count > 0) THEN
      l_modifier_code := l_modifier_code||'_OVR';
    END IF;

    l_modifier_code := l_modifier_code||'_MOD';

    IF l_modifier_code = 'G_MANUAL_MOD' THEN
      x_modifier_code := G_MANUAL_MOD;
    ELSIF l_modifier_code = 'G_AUTOMATIC_MOD' THEN
      x_modifier_code := G_AUTOMATIC_MOD;
    ELSIF l_modifier_code = 'G_AUTOMATIC_MANUAL_MOD' THEN
      x_modifier_code := G_AUTOMATIC_MANUAL_MOD;
    ELSIF l_modifier_code = 'G_AUTOMATIC_OVR_MOD' THEN
      x_modifier_code := G_AUTOMATIC_OVR_MOD;
    ELSIF l_modifier_code = 'G_MANUAL_OVR_MOD' THEN
      x_modifier_code := G_MANUAL_OVR_MOD;
    ELSIF l_modifier_code = 'G_AUTOMATIC_MANUAL_OVR_MOD' THEN
      x_modifier_code := G_AUTOMATIC_MANUAL_OVR_MOD;
    ELSE
      x_modifier_code := G_NO_MOD;
    END IF;

  END get_applied_modifier_code;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: None.
--Locks: None.
--Function:
--  Determines if modifiers are applied on the line
--Parameters:
--IN:
--p_po_header_id
--  Identifies the header that should be checked for applied modifiers
--p_po_line_id
--  Identifies the line that should be checked for applied modifiers
--OUT:
--x_mod_exist
--  Indicates whether manual or overridden modifiers exist
--    'Y' - manual or overridden modifier applied on the line.
--    'N' - no manual or overridden modifier applied on the line.
--  VARCHAR2(1)
--End of Comments
-------------------------------------------------------------------------------

  PROCEDURE line_modifier_exist
    (
      p_po_header_id        IN NUMBER
    , p_po_line_id          IN NUMBER
    , x_line_modifier_exist OUT NOCOPY VARCHAR2
    )
  IS
    d_mod CONSTANT VARCHAR2(100) := D_line_modifier_exist;
    d_position NUMBER := 0;

    l_line_modifiers_exist VARCHAR2(1);
    l_modifier_code VARCHAR2(10);
  BEGIN
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod);
      PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
      PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    END IF;

    d_position := 100;
    x_line_modifier_exist := 'N';

    get_applied_modifier_code
    (
      p_po_header_id   => p_po_header_id
    , p_po_line_id     => p_po_line_id
    , x_modifier_code  => l_modifier_code
    );

    d_position := 200;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_modifier_code', l_modifier_code);
    END IF;

    IF (l_modifier_code = G_MANUAL_MOD
        OR l_modifier_code = G_MANUAL_OVR_MOD
        OR l_modifier_code = G_AUTOMATIC_MOD
        OR l_modifier_code = G_AUTOMATIC_OVR_MOD
        OR l_modifier_code = G_AUTOMATIC_MANUAL_MOD
        OR l_modifier_code = G_AUTOMATIC_MANUAL_OVR_MOD) THEN
      x_line_modifier_exist := 'Y';
    ELSE
      x_line_modifier_exist := 'N';
    END IF;

    d_position := 300;
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_line_modifier_exist', x_line_modifier_exist);
    END IF;
  END line_modifier_exist;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: None.
--Locks: None.
--Function:
--  Determines if manual or overridden modifiers are applied on the line
--Parameters:
--IN:
--p_po_header_id
--  Identifies the header that should be checked.
--p_po_line_id
--  Identifies the line that should be checked.
--OUT:
--x_man_ovr_mod_exist
--  Indicates whether manual or overridden modifiers exist
--    'Y' - manual or overridden modifier applied on the line.
--    'N' - no manual or overridden modifier applied on the line.
--  VARCHAR2(1)
--End of Comments
-------------------------------------------------------------------------------

  PROCEDURE check_man_ovr_mod_exist
    (
      p_po_header_id       IN NUMBER
    , p_po_line_id         IN NUMBER
    , x_man_ovr_mod_exist OUT NOCOPY VARCHAR2
    )
  IS
    d_mod CONSTANT VARCHAR2(100) := D_check_man_ovr_mod_exist;
    d_position NUMBER := 0;

    l_modifier_code VARCHAR2(10);
  BEGIN
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod);
      PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
      PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
    END IF;

    d_position := 100;
    x_man_ovr_mod_exist := 'N';

    get_applied_modifier_code
      (
        p_po_header_id   => p_po_header_id
      , p_po_line_id     => p_po_line_id
      , x_modifier_code  => l_modifier_code
      );

    d_position := 200;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_modifier_code', l_modifier_code);
    END IF;

    IF (l_modifier_code = G_MANUAL_MOD
        OR l_modifier_code = G_MANUAL_OVR_MOD
        OR l_modifier_code = G_AUTOMATIC_MANUAL_MOD
        OR l_modifier_code = G_AUTOMATIC_OVR_MOD
        OR l_modifier_code = G_AUTOMATIC_MANUAL_OVR_MOD) THEN
      x_man_ovr_mod_exist := 'Y';
    ELSE
      x_man_ovr_mod_exist := 'N';
    END IF;

    d_position := 300;
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_man_ovr_mod_exist', x_man_ovr_mod_exist);
    END IF;
  END check_man_ovr_mod_exist;


--------------------------------------------------------------------------------
--Start of Comments
--Name: popl_manual_overridden_adj
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure populates the QP temp tables with manual and overridden
--  modifier details
--Parameters:
--IN:


--Testing:
--
-- Exceptions:
--Exceptions will be pushed into the stack and raised again.
--The Final exception block will catch it and populate the
-- the calling
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE popl_manual_overridden_adj
    (p_draft_id           IN NUMBER
    ,p_order_header_id    IN NUMBER
    ,p_order_line_id_tbl  IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,p_quantity_tbl       IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,x_return_status     OUT NOCOPY VARCHAR2
    )
  IS
  --
    l_api_name        CONSTANT varchar2(30)  := 'popl_manual_overridden_adj';
    l_log_head        CONSTANT varchar2(100) := g_log_head || l_api_name;
    l_progress        VARCHAR2(3) := '000';
    l_exception_msg   FND_NEW_MESSAGES.message_text%TYPE;

    i PLS_INTEGER;
    j PLS_INTEGER;
    k PLS_INTEGER;
    m PLS_INTEGER; --used "m" instead of "l", as "l" looks like number "1"

    --Line Details got from cursor Start
    l_line_det_index             PLS_INTEGER;
    l_from_list_header_id_tbl    QP_PREQ_GRP.NUMBER_TYPE;
    l_from_list_line_id_tbl      QP_PREQ_GRP.NUMBER_TYPE;
    l_from_list_line_type_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
    l_from_list_type_code_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
    l_list_line_no_tbl           QP_PREQ_GRP.VARCHAR_TYPE;

    l_operand_calc_code_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
    l_operand_value_tbl          QP_PREQ_GRP.VARCHAR_TYPE;

    l_updated_flag_tbl           QP_PREQ_GRP.VARCHAR_TYPE;
    l_applied_flag_tbl           QP_PREQ_GRP.VARCHAR_TYPE;
    l_override_flag_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
    l_automatic_flag_tbl         QP_PREQ_GRP.VARCHAR_TYPE;

    l_pricing_group_seq_tbl      QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_price_break_type_code_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
    l_modifier_level_code_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
    l_change_reason_code_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
    l_change_reason_text_tbl     QP_PREQ_GRP.VARCHAR_TYPE;

    l_price_adjustment_id_tbl    QP_PREQ_GRP.NUMBER_TYPE;
    l_rltd_price_adj_id_tbl      QP_PREQ_GRP.NUMBER_TYPE;
    l_relationship_type_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
    l_rltd_list_line_id_tbl      QP_PREQ_GRP.NUMBER_TYPE;
    --Line Details from cursor End


    --Line Detail pl/sql tables Start
    l_line_detail_index           QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_line_detail_type_code       QP_PREQ_GRP.VARCHAR_TYPE;
    l_price_break_type_code       QP_PREQ_GRP.VARCHAR_TYPE;
    l_list_price                  QP_PREQ_GRP.NUMBER_TYPE;
    l_line_index                  QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_created_from_list_header_id QP_PREQ_GRP.NUMBER_TYPE;
    l_created_from_list_line_id   QP_PREQ_GRP.NUMBER_TYPE;
    l_created_from_list_line_type QP_PREQ_GRP.VARCHAR_TYPE;
    l_created_from_list_type_code QP_PREQ_GRP.VARCHAR_TYPE;
    l_created_from_sql            QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_group_sequence      QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_pricing_phase_id            QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_operand_calculation_code    QP_PREQ_GRP.VARCHAR_TYPE;
    l_operand_value               QP_PREQ_GRP.VARCHAR_TYPE;
    l_substitution_type_code      QP_PREQ_GRP.VARCHAR_TYPE;
    l_substitution_value_from     QP_PREQ_GRP.VARCHAR_TYPE;
    l_substitution_value_to       QP_PREQ_GRP.VARCHAR_TYPE;
    l_ask_for_flag                QP_PREQ_GRP.VARCHAR_TYPE;
    l_price_formula_id            QP_PREQ_GRP.NUMBER_TYPE;
    l_pricing_status_code         QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_status_text         QP_PREQ_GRP.VARCHAR_TYPE;
    l_product_precedence          QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_incompatablility_grp_code   QP_PREQ_GRP.VARCHAR_TYPE;
    l_processed_flag              QP_PREQ_GRP.VARCHAR_TYPE;
    l_applied_flag                QP_PREQ_GRP.VARCHAR_TYPE;
    l_automatic_flag              QP_PREQ_GRP.VARCHAR_TYPE;
    l_override_flag               QP_PREQ_GRP.VARCHAR_TYPE;
    l_primary_uom_flag            QP_PREQ_GRP.VARCHAR_TYPE;
    l_print_on_invoice_flag       QP_PREQ_GRP.VARCHAR_TYPE;
    l_modifier_level_code         QP_PREQ_GRP.VARCHAR_TYPE;
    l_benefit_qty                 QP_PREQ_GRP.NUMBER_TYPE;
    l_benefit_uom_code            QP_PREQ_GRP.VARCHAR_TYPE;
    l_list_line_no                QP_PREQ_GRP.VARCHAR_TYPE;
    l_accrual_flag                QP_PREQ_GRP.VARCHAR_TYPE;
    l_accrual_conversion_rate     QP_PREQ_GRP.NUMBER_TYPE;
    l_estim_accrual_rate          QP_PREQ_GRP.NUMBER_TYPE;
    l_recurring_flag              QP_PREQ_GRP.VARCHAR_TYPE;
    l_selected_volume_attr        QP_PREQ_GRP.VARCHAR_TYPE;
    l_rounding_factor             QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_header_limit_exists         QP_PREQ_GRP.VARCHAR_TYPE;
    l_line_limit_exists           QP_PREQ_GRP.VARCHAR_TYPE;
    l_charge_type_code            QP_PREQ_GRP.VARCHAR_TYPE;
    l_charge_subtype_code         QP_PREQ_GRP.VARCHAR_TYPE;
    l_currency_detail_id          QP_PREQ_GRP.NUMBER_TYPE;
    l_currency_header_id          QP_PREQ_GRP.NUMBER_TYPE;
    l_selling_rounding_factor     QP_PREQ_GRP.NUMBER_TYPE;
    l_order_currency              QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_effective_date      QP_PREQ_GRP.DATE_TYPE;
    l_base_currency_code          QP_PREQ_GRP.VARCHAR_TYPE;
    l_line_quantity               QP_PREQ_GRP.NUMBER_TYPE;
    l_updated_flag                QP_PREQ_GRP.VARCHAR_TYPE;
    l_calculation_code            QP_PREQ_GRP.VARCHAR_TYPE;
    l_change_reason_code          QP_PREQ_GRP.VARCHAR_TYPE;
    l_change_reason_text          QP_PREQ_GRP.VARCHAR_TYPE;

    l_price_adjustment_id         QP_PREQ_GRP.NUMBER_TYPE;

    l_accum_context               QP_PREQ_GRP.VARCHAR_TYPE;
    l_accum_attribute             QP_PREQ_GRP.VARCHAR_TYPE;
    l_accum_flag                  QP_PREQ_GRP.VARCHAR_TYPE;
    l_break_uom_code              QP_PREQ_GRP.VARCHAR_TYPE;
    l_break_uom_context           QP_PREQ_GRP.VARCHAR_TYPE;
    l_break_uom_attribute         QP_PREQ_GRP.VARCHAR_TYPE;
    l_process_code                QP_PREQ_GRP.VARCHAR_TYPE;
    --Line Detail pl/sql tables End

    l_line_detail_index_mapping   QP_PREQ_GRP.PLS_INTEGER_TYPE;

    --Related Line Detail pl/sql tables start
    l_line_index_rtbl                 QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_line_detail_index_rtbl          QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_relationship_type_code_rtbl     QP_PREQ_GRP.VARCHAR_TYPE;

    l_rltd_line_index_rtbl            QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_rltd_line_detail_index_rtbl     QP_PREQ_GRP.PLS_INTEGER_TYPE;

    l_list_line_id_rtbl               QP_PREQ_GRP.NUMBER_TYPE;
    l_rltd_list_line_id_rtbl          QP_PREQ_GRP.NUMBER_TYPE;
    l_pricing_status_text_rtbl        QP_PREQ_GRP.VARCHAR_TYPE;
    --Related Line Detail pl/sql tables end

    --Line Attribute pl/sql tables Start
    l_line_index_atbl                QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_line_detail_index_atbl         QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_attribute_level_atbl           QP_PREQ_GRP.VARCHAR_TYPE;
    l_attribute_type_atbl            QP_PREQ_GRP.VARCHAR_TYPE;
    l_list_header_id_atbl            QP_PREQ_GRP.NUMBER_TYPE;
    l_list_line_id_atbl              QP_PREQ_GRP.NUMBER_TYPE;
    l_context_atbl                   QP_PREQ_GRP.VARCHAR_TYPE;
    l_attribute_atbl                 QP_PREQ_GRP.VARCHAR_TYPE;
    l_value_from_atbl                QP_PREQ_GRP.VARCHAR_TYPE;
    l_setup_value_from_atbl          QP_PREQ_GRP.VARCHAR_TYPE;
    l_value_to_atbl                  QP_PREQ_GRP.VARCHAR_TYPE;
    l_setup_value_to_atbl            QP_PREQ_GRP.VARCHAR_TYPE;
    l_grouping_number_atbl           QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_no_qualifiers_in_grp_atbl      QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_compar_oper_type_atbl          QP_PREQ_GRP.VARCHAR_TYPE;
    l_validated_flag_atbl            QP_PREQ_GRP.VARCHAR_TYPE;
    l_applied_flag_atbl              QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_status_code_atbl       QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_status_text_atbl       QP_PREQ_GRP.VARCHAR_TYPE;
    l_qualifier_precedence_atbl      QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_datatype_atbl                  QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_attr_flag_atbl         QP_PREQ_GRP.VARCHAR_TYPE;
    l_qualifier_type_atbl            QP_PREQ_GRP.VARCHAR_TYPE;
    l_product_uom_code_atbl          QP_PREQ_GRP.VARCHAR_TYPE;
    l_excluder_flag_atbl             QP_PREQ_GRP.VARCHAR_TYPE;
    l_pricing_phase_id_atbl          QP_PREQ_GRP.PLS_INTEGER_TYPE;
    l_incomp_grp_code_atbl           QP_PREQ_GRP.VARCHAR_TYPE;
    l_line_detail_type_code_atbl     QP_PREQ_GRP.VARCHAR_TYPE;
    l_modifier_level_code_atbl       QP_PREQ_GRP.VARCHAR_TYPE;
    l_primary_uom_flag_atbl          QP_PREQ_GRP.VARCHAR_TYPE;
    --Line Attribute pl/sql tables End

    l_min_price_adj_id      NUMBER;
    l_return_status_text    VARCHAR2(2000);

    --E_INVALID_PARAMS EXCEPTION;

    CURSOR man_ovr_min_adj_cur(p_order_line_id PO_LINES_ALL.po_line_id%TYPE) IS
      SELECT MIN(ADJV.price_adjustment_id) "MIN_PRICE_ADJ_ID"
      FROM   PO_PRICE_ADJUSTMENTS_V ADJV
      WHERE ADJV.po_header_id = p_order_header_id        --ADJV.draft_id = p_draft_id --sometimes draft_id may be passed as null
      AND   ADJV.po_line_id = p_order_line_id
      AND   NVL(ADJV.applied_flag,'Y') = 'Y'          --To avoid applying manual modifiers selected and cancelled by the user
      AND   (ADJV.automatic_flag = QP_PREQ_GRP.G_NO   -- If modifier is not automatic. i.e., manual
             OR
             (ADJV.automatic_flag = QP_PREQ_GRP.G_YES -- If modifier is automatic, changed and overridable
              AND
              ADJV.updated_flag = QP_PREQ_GRP.G_YES
              AND
              ADJV.update_allowed = QP_PREQ_GRP.G_YES
             )
            );


    CURSOR man_ovr_adj_cur(p_order_line_id NUMBER) IS
      SELECT ADJV.list_header_id         "FROM_LIST_HEADER_ID"
            ,ADJV.list_line_id           "FROM_LIST_LINE_ID"
            ,ADJV.list_line_type_code    "FROM_LIST_LINE_TYPE_CODE"
            ,ADJV.list_type_code         "FROM_LIST_TYPE_CODE"
            ,ADJV.list_line_no           "LIST_LINE_NO"
             --
            ,ADJV.arithmetic_operator    "OPERAND_CALCULATION_CODE"
            ,ADJV.operand                "OPERAND_VALUE"
             --
            ,ADJV.updated_flag           "UPDATED_FLAG"
            ,ADJV.applied_flag           "APPLIED_FLAG"
            ,ADJV.update_allowed         "OVERRIDE_FLAG"
            ,ADJV.automatic_flag         "AUTOMATIC_FLAG"
             --
            ,ADJV.pricing_group_sequence "PRICING_GROUP_SEQUENCE"
            ,ADJV.price_break_type_code  "PRICE_BREAK_TYPE_CODE"
            ,ADJV.modifier_level_code    "MODIFIER_LEVEL_CODE"
            ,ADJV.change_reason_code     "CHANGE_REASON_CODE"
            ,ADJV.change_reason_text     "CHANGE_REASON_TEXT"
             --
            ,ADJV.price_adjustment_id        "PRICE_ADJUSTMENT_ID"      --Child price adjustment id
            ,ADJV.parent_adjustment_id       "RLTD_PRICE_ADJUSTMENT_ID" --Parent price adjustment id
            ,ADJV.parent_list_line_type_code "RELATIONSHIP_TYPE_CODE"   --Parent Child relationship type code
            ,ADJV.parent_list_line_id        "RLTD_LIST_LINE_ID"        --Parent List Line Id
      FROM  PO_PRICE_ADJUSTMENTS_V ADJV
      WHERE ADJV.po_header_id = p_order_header_id        --ADJV.draft_id = p_draft_id --sometimes draft_id may be passed as null
      AND   ADJV.po_line_id   = p_order_line_id
      AND   NVL(ADJV.applied_flag,'Y') = 'Y'          --To avoid applying manual modifiers selected and cancelled by the user
      AND   (ADJV.automatic_flag = QP_PREQ_GRP.G_NO   -- If modifier is not automatic. i.e., manual
             OR
             (ADJV.automatic_flag = QP_PREQ_GRP.G_YES -- If modifier is automatic, changed and overridable
              AND
              ADJV.updated_flag = QP_PREQ_GRP.G_YES
              AND
              ADJV.update_allowed = QP_PREQ_GRP.G_YES
             )
            )
      ORDER BY ADJV.price_adjustment_id ASC;

    CURSOR man_ovr_adj_attr_cur(p_order_line_id NUMBER, p_min_price_adj_id NUMBER) IS
      SELECT (ATTRV.price_adjustment_id - p_min_price_adj_id) "LINE_DETAIL_INDEX"
             --
            ,DECODE(ATTRV.flex_title
                   ,'QP_ATTR_DEFNS_QUALIFIER', 'QUALIFIER'
                   ,'QP_ATTR_DEFNS_PRODUCT', 'PRODUCT'
                   ,'PRICING'
                   )                                          "ATTRIBUTE_TYPE"
            ,ATTRV.pricing_context                            "CONTEXT"
            ,ATTRV.pricing_attribute                          "ATTRIBUTE"
            ,ATTRV.pricing_attr_value_from                    "VALUE_FROM"
            ,ATTRV.pricing_attr_value_to                      "VALUE_TO"
            ,ATTRV.comparison_operator                        "COMPARISON_OPERATOR_TYPE"
            ,DECODE(ATTRV.flex_title
                   ,'QP_ATTR_DEFNS_QUALIFIER', 'Y', 'N')      "VALIDATED_FLAG"
      FROM  PO_PRICE_ADJ_ATTRIBS_V ATTRV
      WHERE ATTRV.po_header_id = p_order_header_id        --ATTRV.draft_id = p_draft_id --sometimes draft_id may be passed as null
      AND   ATTRV.po_line_id   = p_order_line_id
      AND   NVL(ATTRV.applied_flag,'Y') = 'Y'          --To avoid applying manual modifiers selected and cancelled by the user
      AND   (ATTRV.automatic_flag = QP_PREQ_GRP.G_NO   -- If modifier is not automatic. i.e., manual
             OR
             (ATTRV.automatic_flag = QP_PREQ_GRP.G_YES -- If modifier is automatic, changed and overridable
              AND
              ATTRV.updated_flag = QP_PREQ_GRP.G_YES
              AND
              ATTRV.update_allowed = QP_PREQ_GRP.G_YES
             )
            )
      ORDER BY ATTRV.price_adjustment_id ASC;

  BEGIN
    SAVEPOINT POPULATE_QP_TABLES;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress := '000';

    --Check if order_header_id or line_ids are passed
    IF (p_order_header_id IS NULL) THEN
      RETURN;
    ELSIF (p_order_line_id_tbl IS NULL OR p_order_line_id_tbl.count <= 0) THEN
      RETURN;
    ELSIF (p_quantity_tbl IS NULL OR p_quantity_tbl.count <> p_order_line_id_tbl.count) THEN
      --IF order lines are passed and the corresponding quantities are not passed, the quantity will be defaulted to '1' for the lines with missing quantity
      NULL;
    END IF;

    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_header_id',p_order_header_id);

      FOR i IN p_order_line_id_tbl.FIRST..p_order_line_id_tbl.LAST
      LOOP
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_line_id_tbl('||i||')',p_order_line_id_tbl(i));
        IF (p_quantity_tbl.exists(i)) THEN
          PO_DEBUG.debug_var(l_log_head,l_progress,'p_quantity_tbl('||i||')',p_quantity_tbl(i));
        ELSE
          PO_DEBUG.debug_var(l_log_head,l_progress,'missing p_quantity_tbl('||i||')',1);
        END IF;
      END LOOP;
    END IF;

    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Before get manual and overridden price adjustments and associated context attributes');
    END IF;

    --For each order line id get the manual and overridden price adjustments and associated context attributes.
    FOR i IN p_order_line_id_tbl.FIRST .. p_order_line_id_tbl.LAST
    LOOP
      l_progress := '060';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get manual and overridden adjustments for order line id: '||p_order_line_id_tbl(i));
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Reset line detail and related line detail pl/sql tables');
      END IF;

      l_from_list_header_id_tbl.delete;
      l_from_list_line_id_tbl.delete;
      l_from_list_line_type_tbl.delete;
      l_from_list_type_code_tbl.delete;
      l_list_line_no_tbl.delete;

      l_operand_calc_code_tbl.delete;
      l_operand_value_tbl.delete;

      l_updated_flag_tbl.delete;
      l_applied_flag_tbl.delete;
      l_override_flag_tbl.delete;
      l_automatic_flag_tbl.delete;

      l_pricing_group_seq_tbl.delete;
      l_price_break_type_code_tbl.delete;
      l_modifier_level_code_tbl.delete;
      l_change_reason_code_tbl.delete;
      l_change_reason_text_tbl.delete;

      l_price_adjustment_id_tbl.delete;
      l_rltd_price_adj_id_tbl.delete;      --Parent price adjustment id
      l_relationship_type_code_tbl.delete; --Parent Child relationship type code
      l_rltd_list_line_id_tbl.delete;      --Parent List Line Id

      --Reset line detail pl/sql tables Start
      l_line_detail_index.delete;

      l_created_from_list_header_id.delete;
      l_created_from_list_line_id.delete;
      l_created_from_list_line_type.delete;
      l_created_from_list_type_code.delete;
      l_list_line_no.delete;

      l_operand_calculation_code.delete;
      l_operand_value.delete;

      l_updated_flag.delete;
      l_applied_flag.delete;
      l_override_flag.delete;
      l_automatic_flag.delete;

      l_pricing_group_sequence.delete;
      l_price_break_type_code.delete;
      l_modifier_level_code.delete;
      l_change_reason_code.delete;
      l_change_reason_text.delete;

      l_line_index.delete;
      l_line_detail_type_code.delete;
      l_line_quantity.delete;

      l_pricing_status_code.delete;
      l_pricing_status_text.delete;

      l_list_price.delete;

      l_created_from_sql.delete;
      l_pricing_phase_id.delete;

      l_substitution_type_code.delete;
      l_substitution_value_from.delete;
      l_substitution_value_to.delete;
      l_ask_for_flag.delete;
      l_price_formula_id.delete;

      l_product_precedence.delete;
      l_incompatablility_grp_code.delete;

      l_primary_uom_flag.delete;
      l_print_on_invoice_flag.delete;

      l_benefit_qty.delete;
      l_benefit_uom_code.delete;

      l_accrual_flag.delete;
      l_accrual_conversion_rate.delete;
      l_estim_accrual_rate.delete;
      l_recurring_flag.delete;
      l_selected_volume_attr.delete;
      l_rounding_factor.delete;
      l_header_limit_exists.delete;
      l_line_limit_exists.delete;
      l_charge_type_code.delete;
      l_charge_subtype_code.delete;
      l_currency_detail_id.delete;
      l_currency_header_id.delete;
      l_selling_rounding_factor.delete;
      l_order_currency.delete;
      l_pricing_effective_date.delete;
      l_base_currency_code.delete;
      l_calculation_code.delete;

      l_price_adjustment_id.delete;

      l_accum_context.delete;
      l_accum_attribute.delete;
      l_accum_flag.delete;
      l_break_uom_code.delete;
      l_break_uom_context.delete;
      l_break_uom_attribute.delete;
      l_process_code.delete;
      --Reset line detail pl/sql tables End

      --pl/sql tables used for line mapping
      l_line_detail_index_mapping.delete;


      --Reset related lines pl/sql tables, Start
      k := 0;

      l_line_index_rtbl.delete;
      l_line_detail_index_rtbl.delete;
      l_relationship_type_code_rtbl.delete;


      l_rltd_line_index_rtbl.delete;
      l_rltd_line_detail_index_rtbl.delete;

      l_list_line_id_rtbl.delete;
      l_rltd_list_line_id_rtbl.delete;
      l_pricing_status_text_rtbl.delete;
      --Reset related lines pl/sql tables, End


      --Reset line attribute pl/sql tables Start
      l_line_index_atbl.delete;
      l_line_detail_index_atbl.delete;
      l_attribute_level_atbl.delete;
      l_attribute_type_atbl.delete;
      l_list_header_id_atbl.delete;
      l_list_line_id_atbl.delete;
      l_context_atbl.delete;
      l_attribute_atbl.delete;
      l_value_from_atbl.delete;
      l_setup_value_from_atbl.delete;
      l_value_to_atbl.delete;
      l_setup_value_to_atbl.delete;
      l_grouping_number_atbl.delete;
      l_no_qualifiers_in_grp_atbl.delete;
      l_compar_oper_type_atbl.delete;
      l_validated_flag_atbl.delete;
      l_applied_flag_atbl.delete;
      l_pricing_status_code_atbl.delete;
      l_pricing_status_text_atbl.delete;
      l_qualifier_precedence_atbl.delete;
      l_datatype_atbl.delete;
      l_pricing_attr_flag_atbl.delete;
      l_qualifier_type_atbl.delete;
      l_product_uom_code_atbl.delete;
      l_excluder_flag_atbl.delete;
      l_pricing_phase_id_atbl.delete;
      l_incomp_grp_code_atbl.delete;
      l_line_detail_type_code_atbl.delete;
      l_modifier_level_code_atbl.delete;
      l_primary_uom_flag_atbl.delete;
      --Reset line attribute pl/sql tables End


      l_progress := '080';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get Min Price Adjustment Id from the list of manual and overridden price adjustments');
      END IF;
      OPEN man_ovr_min_adj_cur(p_order_line_id_tbl(i));
      FETCH man_ovr_min_adj_cur INTO l_min_price_adj_id;
      CLOSE man_ovr_min_adj_cur;

      l_progress := '090';
      IF l_min_price_adj_id IS NULL THEN --No Adjustments found
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'No Adjustments found, continue with the next order line');
      ELSE --To use it in the calculation of line detail index
        l_min_price_adj_id := l_min_price_adj_id - 1;

        l_progress := '100';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get manual and overridden price adjustments from Price Adjustments tables');
        END IF;

        OPEN man_ovr_adj_cur(p_order_line_id_tbl(i));
        FETCH man_ovr_adj_cur BULK COLLECT INTO
          l_from_list_header_id_tbl,
          l_from_list_line_id_tbl,
          l_from_list_line_type_tbl,
          l_from_list_type_code_tbl,
          l_list_line_no_tbl,

          l_operand_calc_code_tbl,
          l_operand_value_tbl,

          l_updated_flag_tbl,
          l_applied_flag_tbl,
          l_override_flag_tbl,
          l_automatic_flag_tbl,

          l_pricing_group_seq_tbl,
          l_price_break_type_code_tbl,
          l_modifier_level_code_tbl,
          l_change_reason_code_tbl,
          l_change_reason_text_tbl,

          l_price_adjustment_id_tbl,
          l_rltd_price_adj_id_tbl,      --Parent price adjustment id
          l_relationship_type_code_tbl, --Parent Child relationship type code
          l_rltd_list_line_id_tbl;      --Parent List Line Id


        IF l_price_adjustment_id_tbl.count = 0 THEN
          l_progress := '120';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Continue with the next order line, when no manual or overridden modifiers are found');
          END IF;
        ELSE
          l_progress := '140';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Initialize parameters before calling Insert Line Details in QP_PREQ_GRP');
          END IF;
          m := 0;
          FOR j IN l_price_adjustment_id_tbl.FIRST .. l_price_adjustment_id_tbl.LAST
          LOOP
            m := m + 1;
            --Note: If the manual or automatic modifier is overridable and the user has overridden the rate from front end,
            --the updated flag would have been set to G_YES.
            --In case of manual modifiers the updated flag needs to be set to G_YES, to re apply the manual modifier to get the
            --correct unit price

            --Set the source line index
            l_line_index(m) := i;

            l_line_det_index := l_price_adjustment_id_tbl(j) - l_min_price_adj_id;
            --Mapping received index (l_line_det_index_tbl(j))  with the given index (m)
            l_line_detail_index_mapping(l_line_det_index) := m;

            --Initialize pl/sql table returned from cursor
            l_line_detail_index(m) := m;
            l_created_from_list_header_id(m) := l_from_list_header_id_tbl(j);
            l_created_from_list_line_id(m) :=  l_from_list_line_id_tbl(j);
            l_created_from_list_line_type(m) := l_from_list_line_type_tbl(j);
            l_created_from_list_type_code(m) := l_from_list_type_code_tbl(j);
            l_list_line_no(m) := l_list_line_no_tbl(j);

            l_operand_calculation_code(m) := l_operand_calc_code_tbl(j);
            l_operand_value(m) := l_operand_value_tbl(j);

            l_applied_flag(m) := l_applied_flag_tbl(j);
            l_override_flag(m) := l_override_flag_tbl(j);
            l_automatic_flag(m) := l_automatic_flag_tbl(j);

            IF (l_automatic_flag_tbl(j) = QP_PREQ_GRP.G_NO) THEN
              l_updated_flag(m) := QP_PREQ_GRP.G_YES;
              l_applied_flag(m) := QP_PREQ_GRP.G_YES; --the value l_applied_flag_tbl(j) from the cursor Should always be 'Y', this line can be removed once confirmed
            ELSE
              l_updated_flag(m) := l_updated_flag_tbl(j); -- if automatic, it can be either Y or N
            END IF;

            l_pricing_group_sequence(m) := l_pricing_group_seq_tbl(j);
            l_price_break_type_code(m) := l_price_break_type_code_tbl(j);
            l_modifier_level_code(m) := l_modifier_level_code_tbl(j);
            l_change_reason_code(m) := l_change_reason_code_tbl(j);
            l_change_reason_text(m) := l_change_reason_text_tbl(j);

            l_price_adjustment_id(m) := l_price_adjustment_id_tbl(j);
            --Initialize pl/sql table returned from cursor

            --Line Details Type Code cannot be null. Set it to 'NULL' string
            l_line_detail_type_code(m) := 'NULL';

            --Set the process code
            l_process_code(m)                := QP_PREQ_GRP.G_STATUS_NEW;
            l_processed_flag(m)              := NULL;

            --Set line quantity
            IF (p_quantity_tbl.exists(i)) THEN
              l_line_quantity(m)               := p_quantity_tbl(i);
            ELSE
              l_line_quantity(m)               := 1;
            END IF;

            --Set the pricing status to unchanged for the pricing engine to consider the adjsutment
            l_pricing_status_code(m)         := QP_PREQ_GRP.G_STATUS_UNCHANGED;
            l_pricing_status_text(m)         := NULL;

            --Initiailize the other parameters as NULL
            l_list_price(m)                  := NULL;

            l_created_from_sql(m)            := NULL;
            l_pricing_phase_id(m)            := NULL;

            l_substitution_type_code(m)      := NULL;
            l_substitution_value_from(m)     := NULL;
            l_substitution_value_to(m)       := NULL;
            l_ask_for_flag(m)                := NULL;
            l_price_formula_id(m)            := NULL;

            l_product_precedence(m)          := NULL;
            l_incompatablility_grp_code(m)   := NULL;

            l_primary_uom_flag(m)            := NULL;
            l_print_on_invoice_flag(m)       := NULL;

            l_benefit_qty(m)                 := NULL;
            l_benefit_uom_code(m)            := NULL;

            l_accrual_flag(m)                := NULL;
            l_accrual_conversion_rate(m)     := NULL;
            l_estim_accrual_rate(m)          := NULL;
            l_recurring_flag(m)              := NULL;
            l_selected_volume_attr(m)        := NULL;
            l_rounding_factor(m)             := NULL;
            l_header_limit_exists(m)         := NULL;
            l_line_limit_exists(m)           := NULL;
            l_charge_type_code(m)            := NULL;
            l_charge_subtype_code(m)         := NULL;
            l_currency_detail_id(m)          := NULL;
            l_currency_header_id(m)          := NULL;
            l_selling_rounding_factor(m)     := NULL;
            l_order_currency(m)              := NULL;
            l_pricing_effective_date(m)      := NULL;
            l_base_currency_code(m)          := NULL;
            l_calculation_code(m)            := NULL;

            l_accum_context(m)               := NULL;
            l_accum_attribute(m)             := NULL;
            l_accum_flag(m)                  := NULL;
            l_break_uom_code(m)              := NULL;
            l_break_uom_context(m)           := NULL;
            l_break_uom_attribute(m)         := NULL;


            --set the related line information
            IF l_rltd_price_adj_id_tbl(j) IS NOT NULL THEN
              k := k + 1;

              l_line_index_rtbl(k)             := i;
              l_line_detail_index_rtbl(k)      := l_rltd_price_adj_id_tbl(j) - l_min_price_adj_id;

              IF (l_relationship_type_code_tbl(j) = 'PBH') THEN
                l_relationship_type_code_rtbl(k) := 'PBH_LINE';
              ELSE
                l_relationship_type_code_rtbl(k) := l_relationship_type_code_tbl(j);
              END IF;

              l_rltd_line_index_rtbl(k)        := i;
              l_rltd_line_detail_index_rtbl(k) := m;

              l_list_line_id_rtbl(k)           := l_rltd_list_line_id_tbl(j);
              l_rltd_list_line_id_rtbl(k)      := l_from_list_line_id_tbl(j);
              l_pricing_status_text_rtbl(k)    := NULL;
            END IF;

          END LOOP;

          IF l_line_detail_index_rtbl.count > 0 THEN
            FOR k IN l_line_detail_index_rtbl.FIRST .. l_line_detail_index_rtbl.LAST
            LOOP
              l_line_detail_index_rtbl(k) := l_line_detail_index_mapping(l_line_detail_index_rtbl(k)); --The Parent Line will always be found
            END LOOP;
          END IF;


          OPEN man_ovr_adj_attr_cur(p_order_line_id_tbl(i), l_min_price_adj_id);
          FETCH man_ovr_adj_attr_cur BULK COLLECT INTO
            l_line_detail_index_atbl,
            l_attribute_type_atbl,
            l_context_atbl,
            l_attribute_atbl,
            l_value_from_atbl,
            l_value_to_atbl,
            l_compar_oper_type_atbl,
            l_validated_flag_atbl;

          l_progress := '160';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Initialize parameters before calling Insert Line Attr Details in QP_PREQ_GRP');
          END IF;
          IF l_line_detail_index_atbl.count > 0 THEN
            FOR j IN l_line_detail_index_atbl.FIRST .. l_line_detail_index_atbl.LAST
            LOOP
              --Initialize Line Attribute pl/sql tables Start
              l_line_index_atbl(j) := i;

              l_line_detail_index_atbl(j) := l_line_detail_index_mapping(l_line_detail_index_atbl(j));  --The Parent will always exist

              l_attribute_level_atbl(j) := 'Line'; --Default to 'Line'
              --l_attribute_type_atbl(j) := NULL;  --Initialized in fetch statement
              l_list_header_id_atbl(j) := NULL;
              l_list_line_id_atbl(j) := NULL;

              --l_context_atbl(j) := NULL;  --Initialized in fetch statement
              --l_attribute_atbl(j) := NULL;  --Initialized in fetch statement
              --l_value_from_atbl(j) := NULL;  --Initialized in fetch statement
              l_setup_value_from_atbl(j) := NULL;
              --l_value_to_atbl(j) := NULL;  --Initialized in fetch statement
              l_setup_value_to_atbl(j) := NULL;
              l_grouping_number_atbl(j) := NULL;
              l_no_qualifiers_in_grp_atbl(j) := NULL;
              --l_compar_oper_type_atbl(j) := NULL;  --Initialized in fetch statement
              --l_validated_flag_atbl(j) := NULL;  --Initialized in fetch statement
              l_applied_flag_atbl(j) := NULL;
              l_pricing_status_code_atbl(j) := QP_PREQ_GRP.G_STATUS_NEW;
              l_pricing_status_text_atbl(j) := NULL;
              l_qualifier_precedence_atbl(j) := NULL;
              l_datatype_atbl(j) := NULL;
              l_pricing_attr_flag_atbl(j) := NULL;
              l_qualifier_type_atbl(j) := NULL;
              l_product_uom_code_atbl(j) := NULL;
              l_excluder_flag_atbl(j) := NULL;
              l_pricing_phase_id_atbl(j) := NULL;
              l_incomp_grp_code_atbl(j) := NULL;
              l_line_detail_type_code_atbl(j) := NULL;
              l_modifier_level_code_atbl(j) := NULL;
              l_primary_uom_flag_atbl(j) := NULL;
              --Initialize Line Attribute pl/sql tables End
            END LOOP;
          END IF;

          l_progress := '170';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling bulk insert procedure QP_PREQ_GRP.INSERT_LDETS2 to insert line details');
          END IF;

          IF l_price_adjustment_id_tbl.count > 0 THEN
            QP_PREQ_GRP.INSERT_LDETS2
              (p_line_detail_index           => l_line_detail_index
              ,p_line_detail_type_code       => l_line_detail_type_code
              ,p_price_break_type_code       => l_price_break_type_code
              ,p_list_price                  => l_list_price
              ,p_line_index                  => l_line_index
              ,p_created_from_list_header_id => l_created_from_list_header_id
              ,p_created_from_list_line_id   => l_created_from_list_line_id
              ,p_created_from_list_line_type => l_created_from_list_line_type
              ,p_created_from_list_type_code => l_created_from_list_type_code
              ,p_created_from_sql            => l_created_from_sql
              ,p_pricing_group_sequence      => l_pricing_group_sequence
              ,p_pricing_phase_id            => l_pricing_phase_id
              ,p_operand_calculation_code    => l_operand_calculation_code
              ,p_operand_value               => l_operand_value
              ,p_substitution_type_code      => l_substitution_type_code
              ,p_substitution_value_from     => l_substitution_value_from
              ,p_substitution_value_to       => l_substitution_value_to
              ,p_ask_for_flag                => l_ask_for_flag
              ,p_price_formula_id            => l_price_formula_id
              ,p_pricing_status_code         => l_pricing_status_code
              ,p_pricing_status_text         => l_pricing_status_text
              ,p_product_precedence          => l_product_precedence
              ,p_incompatablility_grp_code   => l_incompatablility_grp_code
              ,p_processed_flag              => l_processed_flag
              ,p_applied_flag                => l_applied_flag
              ,p_automatic_flag              => l_automatic_flag
              ,p_override_flag               => l_override_flag
              ,p_primary_uom_flag            => l_primary_uom_flag
              ,p_print_on_invoice_flag       => l_print_on_invoice_flag
              ,p_modifier_level_code         => l_modifier_level_code
              ,p_benefit_qty                 => l_benefit_qty
              ,p_benefit_uom_code            => l_benefit_uom_code
              ,p_list_line_no                => l_list_line_no
              ,p_accrual_flag                => l_accrual_flag
              ,p_accrual_conversion_rate     => l_accrual_conversion_rate
              ,p_estim_accrual_rate          => l_estim_accrual_rate
              ,p_recurring_flag              => l_recurring_flag
              ,p_selected_volume_attr        => l_selected_volume_attr
              ,p_rounding_factor             => l_rounding_factor
              ,p_header_limit_exists         => l_header_limit_exists
              ,p_line_limit_exists           => l_line_limit_exists
              ,p_charge_type_code            => l_charge_type_code
              ,p_charge_subtype_code         => l_charge_subtype_code
              ,p_currency_detail_id          => l_currency_detail_id
              ,p_currency_header_id          => l_currency_header_id
              ,p_selling_rounding_factor     => l_selling_rounding_factor
              ,p_order_currency              => l_order_currency
              ,p_pricing_effective_date      => l_pricing_effective_date
              ,p_base_currency_code          => l_base_currency_code
              ,p_line_quantity               => l_line_quantity
              ,p_updated_flag                => l_updated_flag
              ,p_calculation_code            => l_calculation_code
              ,p_change_reason_code          => l_change_reason_code
              ,p_change_reason_text          => l_change_reason_text
              ,p_price_adjustment_id         => l_price_adjustment_id
              ,p_accum_context               => l_accum_context
              ,p_accum_attribute             => l_accum_attribute
              ,p_accum_flag                  => l_accum_flag
              ,p_break_uom_code              => l_break_uom_code
              ,p_break_uom_context           => l_break_uom_context
              ,p_break_uom_attribute         => l_break_uom_attribute
              ,p_process_code                => l_process_code
              ,x_status_code                 => x_return_status
              ,x_status_text                 => l_return_status_text
              );

            l_progress := '180';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Calling INSERT_LDETS2');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
              PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status_text',l_return_status_text);
            END IF;

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;


          l_progress := '190';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling bulk insert procedure QP_PREQ_GRP.INSERT_RLTD_LINES2 to insert relationship between lines');
          END IF;
          IF l_line_detail_index_rtbl.count > 0 THEN
            QP_PREQ_GRP.INSERT_RLTD_LINES2
              (p_line_index                => l_line_index_rtbl
              ,p_line_detail_index         => l_line_detail_index_rtbl
              ,p_relationship_type_code    => l_relationship_type_code_rtbl
              ,p_related_line_index        => l_rltd_line_index_rtbl
              ,p_related_line_detail_index => l_rltd_line_detail_index_rtbl
              ,x_status_code               => x_return_status
              ,x_status_text               => l_return_status_text
              ,p_list_line_id              => l_list_line_id_rtbl
              ,p_related_list_line_id      => l_rltd_list_line_id_rtbl
              ,p_pricing_status_text       => l_pricing_status_text_rtbl
              );

            l_progress := '200';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Calling INSERT_RLTD_LINES2');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
              PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status_text',l_return_status_text);
            END IF;

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;


          l_progress := '210';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling bulk insert procedure QP_PREQ_GRP.INSERT_LINE_ATTRS2 to insert line attribute details');
          END IF;
          IF l_line_detail_index_atbl.count > 0 THEN
            QP_PREQ_GRP.INSERT_LINE_ATTRS2
              (p_line_index_tbl                => l_line_index_atbl
              ,p_line_detail_index_tbl         => l_line_detail_index_atbl
              ,p_attribute_level_tbl           => l_attribute_level_atbl
              ,p_attribute_type_tbl            => l_attribute_type_atbl
              ,p_list_header_id_tbl            => l_list_header_id_atbl
              ,p_list_line_id_tbl              => l_list_line_id_atbl
              ,p_context_tbl                   => l_context_atbl
              ,p_attribute_tbl                 => l_attribute_atbl
              ,p_value_from_tbl                => l_value_from_atbl
              ,p_setup_value_from_tbl          => l_setup_value_from_atbl
              ,p_value_to_tbl                  => l_value_to_atbl
              ,p_setup_value_to_tbl            => l_setup_value_to_atbl
              ,p_grouping_number_tbl           => l_grouping_number_atbl
              ,p_no_qualifiers_in_grp_tbl      => l_no_qualifiers_in_grp_atbl
              ,p_comparison_operator_type_tbl  => l_compar_oper_type_atbl
              ,p_validated_flag_tbl            => l_validated_flag_atbl
              ,p_applied_flag_tbl              => l_applied_flag_atbl
              ,p_pricing_status_code_tbl       => l_pricing_status_code_atbl
              ,p_pricing_status_text_tbl       => l_pricing_status_text_atbl
              ,p_qualifier_precedence_tbl      => l_qualifier_precedence_atbl
              ,p_datatype_tbl                  => l_datatype_atbl
              ,p_pricing_attr_flag_tbl         => l_pricing_attr_flag_atbl
              ,p_qualifier_type_tbl            => l_qualifier_type_atbl
              ,p_product_uom_code_tbl          => l_product_uom_code_atbl
              ,p_excluder_flag_tbl             => l_excluder_flag_atbl
              ,p_pricing_phase_id_tbl          => l_pricing_phase_id_atbl
              ,p_incompatability_grp_code_tbl  => l_incomp_grp_code_atbl
              ,p_line_detail_type_code_tbl     => l_line_detail_type_code_atbl
              ,p_modifier_level_code_tbl       => l_modifier_level_code_atbl
              ,p_primary_uom_flag_tbl          => l_primary_uom_flag_atbl
              ,x_status_code                   => x_return_status
              ,x_status_text                   => l_return_status_text
              );

            l_progress := '220';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Calling INSERT_LINE_ATTRS2');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
              PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status_text',l_return_status_text);
            END IF;

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
              FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END IF;
        CLOSE man_ovr_adj_attr_cur;
        CLOSE man_ovr_adj_cur;
      END IF;
    END LOOP;
/*
    IF p_order_header_id = 81699 THEN
      DELETE FROM QP_PREQ_RLTD_LINES_TMP_TEST;
      DELETE FROM QP_PREQ_LINE_ATTRS_TMP_TEST;
      DELETE FROM QP_PREQ_LINES_TMP_TEST;
      DELETE FROM QP_PREQ_LDETS_TMP_TEST;

      INSERT INTO QP_PREQ_RLTD_LINES_TMP_TEST (select * from QP_PREQ_RLTD_LINES_TMP);
      INSERT INTO QP_PREQ_LINE_ATTRS_TMP_TEST (select * from QP_PREQ_LINE_ATTRS_TMP);
      INSERT INTO QP_PREQ_LINES_TMP_TEST (select * from QP_PREQ_LINES_TMP);
      INSERT INTO QP_PREQ_LDETS_TMP_TEST (select * from QP_PREQ_LDETS_TMP);
    END IF;
*/
  --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING POPL_MANUAL_OVERRIDDEN_ADJ WITH EXC ERROR with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT POPULATE_QP_TABLES;
      RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING POPL_MANUAL_OVERRIDDEN_ADJ WITH UNEXPECTED ERROR with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT POPULATE_QP_TABLES;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'UnExpected ERROR IN POPL_MANUAL_OVERRIDDEN_ADJ. SQLERRM at '||l_progress||': '||SQLERRM);
      END IF;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING PO_PRICE_ADJUSTMENTS_PKG.POPL_MANUAL_OVERRIDDEN_ADJ with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT POPULATE_QP_TABLES;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END popl_manual_overridden_adj;

--------------------------------------------------------------------------------
--Start of Comments
--Name: extract_price_adjustments
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure extracts price adjustment details from the QP temp tables
--  and populates the PO adjustment tables.
--Parameters:
--IN:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE extract_price_adjustments
    (p_draft_id          IN NUMBER
    ,p_order_header_id   IN NUMBER
    ,p_order_line_id_tbl IN QP_PREQ_GRP.NUMBER_TYPE := G_EMPTY_NUMBER_TYPE
    ,p_pricing_events    IN VARCHAR2
    ,p_calculate_flag    IN VARCHAR2
    ,p_doc_sub_type      IN VARCHAR2
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    ,p_pricing_call_src  IN VARCHAR2
    --To fix price override not allowed error
    --<PDOI Enhancement Bug#17063664>
    --p_allow_price_override_flag should be a table
    ,p_allow_price_override_tbl IN PO_TBL_VARCHAR1 := G_EMPTY_VARCHAR1_TYPE
    ,x_return_status     OUT NOCOPY VARCHAR2
    )
  IS
  --
    l_api_name        CONSTANT varchar2(30)  := 'extract_price_adjustments';
    l_log_head        CONSTANT varchar2(100) := g_log_head || l_api_name;
    l_progress        VARCHAR2(4) := '000';
    l_exception_msg   FND_NEW_MESSAGES.message_text%TYPE;

    i PLS_INTEGER;

    l_debug_upd_line_adj_tbl NUMBER_TYPE;

    l_key po_session_gt.key%TYPE;

    CURSOR upd_line_det_cur IS
    SELECT ADJ.price_adjustment_id
          ,LDUP.line_detail_index
          , gt.char1 allow_price_override_flag
    FROM QP_LDETS_V LDUP
        ,QP_PREQ_LINES_TMP QLUP
        ,PO_PRICE_ADJUSTMENTS_DRAFT ADJ
        ,po_session_gt gt
    WHERE LDUP.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
    AND LDUP.list_line_id = ADJ.list_line_id
    AND ADJ.po_line_id = QLUP.line_id
    AND ADJ.draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
    AND QLUP.line_index = LDUP.line_index
    AND QLUP.pricing_status_code IN (QP_PREQ_GRP.G_STATUS_UPDATED) --QP_PREQ_GRP.G_STATUS_NEW
    AND QLUP.process_status <> 'NOT_VALID'
    AND QLUP.line_type_code = 'LINE'
    AND gt.key = l_key
    AND gt.num1 = ADJ.po_line_id;

  --
  BEGIN
    SAVEPOINT EXTRACT_PRICE_ADJUSTMENTS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress := '000';

    --Check if order_header_id or line_ids are passed
    IF (p_order_header_id IS NULL OR p_order_line_id_tbl IS NULL OR p_order_line_id_tbl.count <= 0) THEN
      RETURN;
    END IF;

    l_progress := '010';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_header_id',p_order_header_id);

      FOR i IN p_order_line_id_tbl.FIRST..p_order_line_id_tbl.LAST
      LOOP
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_line_id_tbl('||i||')',p_order_line_id_tbl(i));
      END LOOP;
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_pricing_events',p_pricing_events);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_calculate_flag',p_calculate_flag);
    END IF;


    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Before extracting adjustments from QP temp tables');
    END IF;

    --Sync PO PRICE ADJUSTMENTS table with PO PRICE ADJUSTMENTS DRAFT
    FOR i IN p_order_line_id_tbl.FIRST .. p_order_line_id_tbl.LAST
    LOOP
      PO_PRICE_ADJ_DRAFT_PKG.sync_draft_from_txn
        ( p_draft_id        => p_draft_id
        , p_order_header_id => p_order_header_id
        , p_order_line_id   => p_order_line_id_tbl(i)
        , p_delete_flag     => NULL);
    END LOOP;

    IF NVL(p_pricing_events, 'PO_BATCH') = 'PO_BATCH' THEN
      l_progress := '030';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Extract adjustments from QP temp tables');
      END IF;

      IF (p_calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY) THEN
        l_progress := '040';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'Delete outdated adjustments and dependant details');
        END IF;
        --Used progress code from 50 to 150
        delete_line_adjs
          (p_draft_id          => p_draft_id
          ,p_order_header_id   => p_order_header_id
          ,p_order_line_id_tbl => p_order_line_id_tbl
          ,p_pricing_events    => p_pricing_events || ','
          --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
          ,p_pricing_call_src     => p_pricing_call_src
          ,p_allow_price_override_tbl => p_allow_price_override_tbl
          ,p_log_head          => l_log_head);
      END IF;
    END IF;

    IF NVL(p_pricing_events, 'PO_BATCH') = 'PO_BATCH' THEN
      l_progress := '160';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Update PO Line Adjustment details');
      END IF;
      l_debug_upd_line_adj_tbl.delete;

      --<PDOI Enhancement Bug#17063664>
      l_key := PO_CORE_S.get_session_gt_nextval;
      -- Insert all line_ids in session_gt.
      FORALL i IN INDICES OF p_order_line_id_tbl
       INSERT INTO po_session_gt
        (KEY, num1,char1
        )
        VALUES (l_key, p_order_line_id_tbl(i), p_allow_price_override_tbl(i));

      FOR upd_line_det IN upd_line_det_cur
      LOOP
        --Used progress code from 170 to 250
        update_adj
          (p_draft_id            => p_draft_id
          ,p_price_adjustment_id => upd_line_det.price_adjustment_id
          ,p_line_detail_index   => upd_line_det.line_detail_index
          --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
          ,p_pricing_call_src       => p_pricing_call_src
          ,p_allow_price_override_flag => upd_line_det.allow_price_override_flag
          ,px_debug_upd_adj_tbl  => l_debug_upd_line_adj_tbl
          ,p_log_head            => l_log_head);
        l_progress := '260';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'UPDATED '|| SQL%ROWCOUNT ||' LINE LEVEL ADJUSTMENTS');
        END IF;
      END LOOP;

      IF (p_calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY) THEN
        --Insert new Adjustments into PO ADJUSTMENTS table
        --Used Progress code from 270 to 350
        insert_adj
          (p_draft_id        => p_draft_id
          ,p_order_header_id => p_order_header_id
          ,p_doc_sub_type    => p_doc_sub_type
          ,p_log_head        => l_log_head);

        --Delete outdated attributes and Insert new attributes
        --Used Progress code from 370 to 450
        update_adj_attribs
          (p_draft_id        => p_draft_id
          ,p_order_header_id => p_order_header_id
          ,p_pricing_events  => p_pricing_events || ','
          ,p_log_head        => l_log_head);


      END IF;

    END IF;

    --Merge PO PRICE ADJUSTMENTS DRAFT table with PO PRICE ADJUSTMENTS for retro calls
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    IF (NVL(p_pricing_call_src, 'NULL') = 'RETRO' OR NVL(p_pricing_call_src, 'NULL') = 'AUTO') THEN
      --Merge Draft table with Base table
      PO_PRICE_ADJ_DRAFT_PKG.merge_changes( p_draft_id => p_draft_id );
      --Delete draft records
      PO_PRICE_ADJ_DRAFT_PKG.delete_rows
        (p_draft_id => p_draft_id
        ,p_price_adjustment_id => NULL);
    END IF;
  --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING EXTRACT_PRICE_ADJUSTMENTS WITH EXC ERROR with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT EXTRACT_PRICE_ADJUSTMENTS;
      RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING EXTRACT_PRICE_ADJUSTMENTS WITH UNEXPECTED ERROR with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT EXTRACT_PRICE_ADJUSTMENTS;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'UnExpected ERROR IN EXTRACT_PRICE_ADJUSTMENTS. SQLERRM at '||l_progress||': '||SQLERRM);
      END IF;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING PO_PRICE_ADJUSTMENTS_PKG.EXTRACT_PRICE_ADJUSTMENTS with rollback');
      END IF;
      ROLLBACK TO SAVEPOINT EXTRACT_PRICE_ADJUSTMENTS;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END extract_price_adjustments;


  PROCEDURE delete_line_adjs
    (p_draft_id          IN NUMBER
    ,p_order_header_id   IN NUMBER
    ,p_order_line_id_tbl IN QP_PREQ_GRP.NUMBER_TYPE
    ,p_pricing_events    IN VARCHAR2
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    ,p_pricing_call_src  IN VARCHAR2
    ,p_allow_price_override_tbl IN PO_TBL_VARCHAR1 --<PDOI Enhancement Bug#17063664>
    ,p_log_head          IN VARCHAR2)
  IS
  --
    l_line_index NUMBER;
    l_line_id    NUMBER;
    l_price_flag VARCHAR2(1);
    l_progress   VARCHAR2(4) := '50';

    i PLS_INTEGER;
    j PLS_INTEGER;
    l_adj_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'Delete old line adjustments for lines with pricing_status_code UPDATED');
    END IF;

    FOR j IN p_order_line_id_tbl.FIRST .. p_order_line_id_tbl.LAST
    LOOP
      l_progress := '60';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'Check if PO Line Id: '||p_order_line_id_tbl(j)||' is UPDATED by pricing engine');
      END IF;
      BEGIN
        SELECT QLINE.line_id, QLINE.price_flag, QLINE.line_index
        INTO   l_line_id, l_price_flag, l_line_index
        FROM  QP_PREQ_LINES_TMP QLINE
        WHERE QLINE.line_id = p_order_line_id_tbl(j)
        AND   QLINE.line_type_code = 'LINE'
        AND   QLINE.price_flag IN ('Y')
        AND   QLINE.process_status <> 'NOT_VALID'
        AND   QLINE.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_line_id := NULL;
          l_price_flag := NULL;
      END;

      IF l_line_id IS NULL THEN
        l_progress := '70';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'The PO Line is not updated by pricing engine');
        END IF;
      ELSE
        --DELETE FROM PO_PRICE_ADJUSTMENTS_DRAFT ADJD
        UPDATE PO_PRICE_ADJUSTMENTS_DRAFT ADJD
        SET ADJD.delete_flag = 'Y'
        WHERE  ADJD.draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
        AND    ADJD.po_header_id = p_order_header_id
        AND    ADJD.po_line_id = l_line_id
        --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
        AND    DECODE(NVL(p_pricing_call_src,'NULL'), 'RETRO', 'N',
                 DECODE(NVL(p_allow_price_override_tbl(j),'Y'), 'Y', NVL(ADJD.updated_flag, 'N'), 'N')) = 'N' --to avoid deleting overridden-automatic and manual modifiers in normal mode
        --AND    ADJD.pricing_phase_id IN (SELECT QPP.pricing_phase_id --this condition has to be checked for pass and fail scenarios, right now it fails for most of the cases
        --                                FROM   qp_event_phases QEP
        --                                      ,qp_pricing_phases QPP
        --                                WHERE instr(p_pricing_events, QEP.pricing_event_code || ',') > 0
        --                                AND   QPP.pricing_phase_id = QEP.pricing_phase_id
        --                                AND   NVL(QPP.user_freeze_override_flag, QPP.freeze_override_flag)
        --                                      = decode(l_price_flag, 'Y', nvl(QPP.user_freeze_override_flag, QPP.freeze_override_flag), 'P', 'Y'))
        AND    ADJD.list_line_id NOT IN (SELECT LD.list_line_id
                                         FROM   qp_ldets_v LD
                                         WHERE  LD.line_index = l_line_index
                                         AND LD.process_code IN (QP_PREQ_GRP.G_STATUS_UPDATED
                                                                ,QP_PREQ_GRP.G_STATUS_UNCHANGED
                                                                ,QP_PREQ_GRP.G_STATUS_NEW)
                                         AND (LD.applied_flag = 'Y'
                                              OR
                                              (nvl(ld.applied_flag, 'N') = 'N'
                                               AND
                                               nvl(ld.line_detail_type_code, 'x') = 'CHILD_DETAIL_LINE'
                                              )
                                             )
                                        )
        RETURNING ADJD.price_adjustment_id BULK COLLECT INTO l_adj_id_tbl;

        l_progress := '80';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'UPDATED '|| SQL%ROWCOUNT ||' LINE LEVEL ADJUSTMENTS WITH DELETE FLAG');
        END IF;

        l_progress := '90';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'Mark child adjustment records for deletion');
        END IF;

        --Only child adjustments are marked for deletion, no need to mark the attributes for deletion. The attributes are deleted along with the adjustments
        IF l_adj_id_tbl.count > 0 THEN
          FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
          UPDATE PO_PRICE_ADJUSTMENTS_DRAFT
          SET delete_flag = 'Y'
          WHERE draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
          AND parent_adjustment_id = l_adj_id_tbl(i);

          l_progress := '100';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head,l_progress,'UPDATED '|| SQL%ROWCOUNT ||' CHILD LINES WITH DELETE FLAG');
          END IF;
        END IF;
        /*
        IF l_adj_id_tbl.count > 0 THEN
          FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
          DELETE FROM PO_PRICE_ADJ_ATTRIBS_DRAFT WHERE draft_id = p_draft_id AND price_adjustment_id = l_adj_id_tbl(i);
          l_progress := '100';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head,l_progress,'DELETED '|| SQL%ROWCOUNT ||' ATTRIBS');
          END IF;

          FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
          DELETE FROM PO_PRICE_ADJ_ASSOCS_DRAFT WHERE draft_id = p_draft_id AND price_adjustment_id = l_adj_id_tbl(i);
          l_progress := '110';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head,l_progress,'DELETED '|| SQL%ROWCOUNT ||' ASSOCS');
          END IF;

          FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
          DELETE FROM PO_PRICE_ADJ_ASSOCS_DRAFT WHERE draft_id = p_draft_id AND rltd_price_adj_id = l_adj_id_tbl(i);
          l_progress := '120';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head,l_progress,'DELETED '|| SQL%ROWCOUNT ||' RLTD ASSOCS');
          END IF;
        END IF;
        */
      END IF;
    END LOOP;
  END delete_line_adjs;

  PROCEDURE update_adj(p_draft_id            IN  NUMBER
                      ,p_price_adjustment_id IN  NUMBER
                      ,p_line_detail_index   IN  NUMBER
                      --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                      ,p_pricing_call_src    IN  VARCHAR2
                      ,p_allow_price_override_flag IN VARCHAR2
                      ,px_debug_upd_adj_tbl  OUT NOCOPY NUMBER_TYPE
                      ,p_log_head            IN  VARCHAR2)
  IS
    l_progress   VARCHAR2(4) := '170';
    l_price_adjustment_id NUMBER;

  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'Update PO Line Adjustment details for');
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_draft_id',p_draft_id);
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_price_adjustment_id',p_price_adjustment_id);
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_line_detail_index',p_line_detail_index);
    END IF;

    BEGIN
      SELECT ADJ.price_adjustment_id
      INTO   l_price_adjustment_id
      FROM   PO_PRICE_ADJUSTMENTS_DRAFT ADJ
      WHERE  ADJ.draft_id = p_draft_id
      AND  ADJ.price_adjustment_id = p_price_adjustment_id
      FOR UPDATE NOWAIT;

      l_progress := '180';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'Adjustment row successfully locked');
      END IF;
    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        l_progress := '190';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'in lock record exception, someone else working on the row');
        END IF;
        --FND_MESSAGE.SET_NAME('ONT', 'PO_LOCK_ROW_ALREADY_LOCKED');
        --PO_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN NO_DATA_FOUND THEN
        l_progress := '200';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'no_data_found, record lock exception');
        END IF;
      WHEN OTHERS THEN
        l_progress := '210';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head,l_progress,'record lock exception, others');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    UPDATE PO_PRICE_ADJUSTMENTS_DRAFT ADJD
      SET ( LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATE_LOGIN
          , operand
          , operand_per_pqty
          , adjusted_amount
          , adjusted_amount_per_pqty
          , arithmetic_operator
          , pricing_phase_id
          , pricing_group_sequence
          , automatic_flag
          , list_line_type_code
          , applied_flag
          , update_allowed
          --, updated_flag
          , charge_type_code
          , charge_subtype_code
          , range_break_quantity
          , accrual_conversion_rate
          , accrual_flag
          , list_line_no
          , print_on_invoice_flag
          , expiration_date
          , rebate_transaction_type_code
          , modifier_level_code
          , price_break_type_code
          , include_on_returns_flag
          , lock_control
          )
      =
      (SELECT
           SYSDATE                             -- LAST_UPDATE_DATE
         , FND_GLOBAL.user_id                  -- LAST_UPDATED_BY
         , FND_GLOBAL.login_id                 -- LAST_UPDATE_LOGIN
         , LDETS.order_qty_operand
         , LDETS.operand_value
         , LDETS.order_qty_adj_amt
         , LDETS.adjustment_amount
         , LDETS.operand_calculation_code
         , LDETS.pricing_phase_id
         , LDETS.pricing_group_sequence
         , LDETS.automatic_flag
         , LDETS.list_line_type_code
         , LDETS.applied_flag
         , LDETS.override_flag
         --, LDETS.updated_flag
         , LDETS.charge_type_code
         , LDETS.charge_subtype_code
         , LDETS.line_quantity --range_break_quantity
         , LDETS.accrual_conversion_rate
         , LDETS.accrual_flag
         , LDETS.list_line_no
         , LDETS.print_on_invoice_flag
         , LDETS.expiration_date
         , LDETS.rebate_transaction_type_code
         , LDETS.modifier_level_code
         , LDETS.price_break_type_code
         , LDETS.include_on_returns_flag
         , ADJD.lock_control + 1
       FROM QP_LDETS_v LDETS
       WHERE ldets.line_detail_index = p_line_detail_index
      )
    WHERE ADJD.draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
    AND ADJD.price_adjustment_id = p_price_adjustment_id
    RETURNING ADJD.list_line_id BULK COLLECT INTO px_debug_upd_adj_tbl;

    --reset the columns used to identify the overridden modifier
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    IF NVL(p_pricing_call_src, 'NULL') = 'RETRO' OR NVL(p_allow_price_override_flag, 'Y') <> 'Y' THEN
      UPDATE PO_PRICE_ADJUSTMENTS_DRAFT ADJD
      SET ADJD.updated_flag = 'N',
          ADJD.change_reason_code = null,
          ADJD.change_reason_text = null
      WHERE ADJD.draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
      AND ADJD.price_adjustment_id = p_price_adjustment_id;
    END IF;

    l_progress := '210';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'exiting update_adj procedure');
    END IF;
  END update_adj;


  PROCEDURE insert_adj(p_draft_id        IN NUMBER
                      ,p_order_header_id IN NUMBER
                      ,p_doc_sub_type    IN VARCHAR2
                      ,p_log_head        IN VARCHAR2)
  IS
  --
    l_progress VARCHAR2(4) := '270';
    l_price_adjustment_id_tbl    QP_PREQ_GRP.NUMBER_TYPE;
    l_rltd_price_adj_id_tbl      QP_PREQ_GRP.NUMBER_TYPE;
    i PLS_INTEGER;
  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'Insert Adjustments called with Order Header ID: '||p_order_header_id);
    END IF;

    INSERT INTO PO_PRICE_ADJUSTMENTS_DRAFT
      (DRAFT_ID
         , PRICE_ADJUSTMENT_ID
         , ADJ_LINE_NUM
         , CREATION_DATE
         , CREATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_LOGIN
         , PROGRAM_APPLICATION_ID
         , PROGRAM_ID
         , PROGRAM_UPDATE_DATE
         , REQUEST_ID
         , PO_HEADER_ID
         , AUTOMATIC_FLAG
         , PO_LINE_ID
         , CONTEXT
         , ATTRIBUTE1
         , ATTRIBUTE2
         , ATTRIBUTE3
         , ATTRIBUTE4
         , ATTRIBUTE5
         , ATTRIBUTE6
         , ATTRIBUTE7
         , ATTRIBUTE8
         , ATTRIBUTE9
         , ATTRIBUTE10
         , ATTRIBUTE11
         , ATTRIBUTE12
         , ATTRIBUTE13
         , ATTRIBUTE14
         , ATTRIBUTE15
         , ORIG_SYS_DISCOUNT_REF
         , LIST_HEADER_ID
         , LIST_LINE_ID
         , LIST_LINE_TYPE_CODE
         , MODIFIED_FROM
         , MODIFIED_TO
         , UPDATED_FLAG
         , UPDATE_ALLOWED
         , APPLIED_FLAG
         , CHANGE_REASON_CODE
         , CHANGE_REASON_TEXT
         , operand
         , Arithmetic_operator
         , COST_ID
         , TAX_CODE
         , TAX_EXEMPT_FLAG
         , TAX_EXEMPT_NUMBER
         , TAX_EXEMPT_REASON_CODE
         , PARENT_ADJUSTMENT_ID
         , INVOICED_FLAG
         , ESTIMATED_FLAG
         , INC_IN_SALES_PERFORMANCE
         , ADJUSTED_AMOUNT
         , PRICING_PHASE_ID
         , CHARGE_TYPE_CODE
         , CHARGE_SUBTYPE_CODE
         , list_line_no
         , source_system_code
         , benefit_qty
         , benefit_uom_code
         , print_on_invoice_flag
         , expiration_date
         , rebate_transaction_type_code
         , rebate_transaction_reference
         , rebate_payment_system_code
         , redeemed_date
         , redeemed_flag
         , accrual_flag
         , range_break_quantity
         , accrual_conversion_rate
         , pricing_group_sequence
         , modifier_level_code
         , price_break_type_code
         , substitution_attribute
         , proration_type_code
         , CREDIT_OR_CHARGE_FLAG
         , INCLUDE_ON_RETURNS_FLAG
         , AC_CONTEXT
         , AC_ATTRIBUTE1
         , AC_ATTRIBUTE2
         , AC_ATTRIBUTE3
         , AC_ATTRIBUTE4
         , AC_ATTRIBUTE5
         , AC_ATTRIBUTE6
         , AC_ATTRIBUTE7
         , AC_ATTRIBUTE8
         , AC_ATTRIBUTE9
         , AC_ATTRIBUTE10
         , AC_ATTRIBUTE11
         , AC_ATTRIBUTE12
         , AC_ATTRIBUTE13
         , AC_ATTRIBUTE14
         , AC_ATTRIBUTE15
         , OPERAND_PER_PQTY
         , ADJUSTED_AMOUNT_PER_PQTY
         , LOCK_CONTROL
      )
      (SELECT
           p_draft_id                          --DRAFT_ID
         , po_price_adjustments_s.nextval      -- PRICE_ADJUSTMENT_ID
         , LDETS.line_detail_index             --ADJ_LINE_NUM
         , SYSDATE                             -- CREATION_DATE
         , FND_GLOBAL.user_id                  -- CREATED_BY
         , SYSDATE                             -- LAST_UPDATE_DATE
         , FND_GLOBAL.user_id                  -- LAST_UPDATED_BY
         , FND_GLOBAL.login_id                 -- LAST_UPDATE_LOGIN
         , NULL                                -- PROGRAM_APPLICATION_ID
         , NULL                                -- PROGRAM_ID
         , NULL                                -- PROGRAM_UPDATE_DATE
         , NULL                                -- REQUEST_ID
         , p_order_header_id                   -- HEADER_ID
         , LDETS.automatic_flag                -- AUTOMATIC_FLAG
         , QLINE.line_id                       -- ORDER_LINE_ID
         , NULL                                -- CONTEXT
         , NULL                                -- ATTRIBUTE1
         , NULL                                -- ATTRIBUTE2
         , NULL                                -- ATTRIBUTE3
         , NULL                                -- ATTRIBUTE4
         , NULL                                -- ATTRIBUTE5
         , NULL                                -- ATTRIBUTE6
         , NULL                                -- ATTRIBUTE7
         , NULL                                -- ATTRIBUTE8
         , NULL                                -- ATTRIBUTE9
         , NULL                                -- ATTRIBUTE10
         , NULL                                -- ATTRIBUTE11
         , NULL                                -- ATTRIBUTE12
         , NULL                                -- ATTRIBUTE13
         , NULL                                -- ATTRIBUTE14
         , NULL                                -- ATTRIBUTE15
         , NULL                                -- ORIG_SYS_DISCOUNT_REF
         , LDETS.LIST_HEADER_ID                -- LIST_HEADER_ID
         , LDETS.LIST_LINE_ID                  -- LIST_LINE_ID
         , LDETS.LIST_LINE_TYPE_CODE           -- LIST_LINE_TYPE_CODE
         , NULL                                -- MODIFIED FROM
         , NULL                                -- MODIFIED_TO
         , LDETS.updated_flag                  -- UPDATED_FLAG
         , LDETS.override_flag                 -- UPDATE_ALLOWED
         , LDETS.applied_flag                  -- APPLIED_FLAG
         , NULL                                -- CHANGE_REASON_CODE
         , NULL                                -- CHANGE_REASON_TEXT
         , nvl(ldets.order_qty_operand, decode(ldets.operand_calculation_code
                                              ,'%', ldets.operand_value
                                              ,'LUMPSUM', ldets.operand_value
                                              ,ldets.operand_value * qline.priced_quantity / nvl(qline.line_quantity, 1)))
                                               --OPERAND
         , ldets.operand_calculation_code      -- ARITHMETIC_OPERATOR
         , NULL                                -- COST_ID
         , NULL                                -- TAX_CODE
         , NULL                                -- TAX_EXEMPT_FLAG
         , NULL                                -- TAX_EXEMPT_NUMBER
         , NULL                                -- TAX_EXEMPT_REASON_CODE
         , NULL                                -- PARENT_ADJUSTMENT_ID
         , NULL                                -- INVOICED_FLAG
         , NULL                                -- ESTIMATED_FLAG
         , NULL                                -- INC_IN_SALES_PERFORMANCE
         , nvl(ldets.order_qty_adj_amt, ldets.adjustment_amount * nvl(qline.priced_quantity, 1) / nvl(qline.line_quantity, 1))
                                                 -- ADJUSTED_AMOUNT
         , LDETS.pricing_phase_id                -- PRICING_PHASE_ID
         , LDETS.charge_type_code                -- CHARGE_TYPE_CODE
         , LDETS.charge_subtype_code             -- CHARGE_SUBTYPE_CODE
         , LDETS.list_line_no                    -- LIST_LINE_NO
         , QH.source_system_code||' - '
                                ||p_doc_sub_type -- SOURCE_SYSTEM_CODE
         , NULL                                  -- LDETS.benefit_qty
         , NULL                                  -- LDETS.benefit_uom_code
         , NULL                                  -- PRINT_ON_INVOICE_FLAG
         , LDETS.expiration_date                 -- EXPIRATION_DATE
         , LDETS.rebate_transaction_type_code
         , NULL                                -- REBATE_TRANSACTION_REFERENCE
         , NULL                                -- REBATE_PAYMENT_SYSTEM_CODE
         , NULL                                -- REDEEMED_DATE
         , NULL                                -- REDEEMED_FLAG
         , LDETS.accrual_flag                  -- ACCRUAL_FLAG
         , LDETS.line_quantity                 -- RANGE_BREAK_QUANTITY
         , LDETS.accrual_conversion_rate       -- ACCRUAL_CONVERSION_RATE
         , LDETS.pricing_group_sequence        -- PRICING_GROUP_SEQUENCE
         , LDETS.modifier_level_code           -- MODIFIER_LEVEL_CODE
         , LDETS.price_break_type_code         -- PRICE_BREAK_TYPE_CODE
         , NULL                                -- LDETS.SUBSTITUTION_ATTRIBUTE
         , NULL                                -- LDETS.PRORATION_TYPE_CODE
         , NULL                                -- CREDIT_OR_CHARGE_FLAG
         , LDETS.include_on_returns_flag       -- INCLUDE_ON_RETURNS_FLAG
         , NULL                                -- AC_CONTEXT
         , NULL                                -- AC_ATTRIBUTE1
         , NULL                                -- AC_ATTRIBUTE2
         , NULL                                -- AC_ATTRIBUTE3
         , NULL                                -- AC_ATTRIBUTE4
         , NULL                                -- AC_ATTRIBUTE5
         , NULL                                -- AC_ATTRIBUTE6
         , NULL                                -- AC_ATTRIBUTE7
         , NULL                                -- AC_ATTRIBUTE8
         , NULL                                -- AC_ATTRIBUTE9
         , NULL                                -- AC_ATTRIBUTE10
         , NULL                                -- AC_ATTRIBUTE11
         , NULL                                -- AC_ATTRIBUTE12
         , NULL                                -- AC_ATTRIBUTE13
         , NULL                                -- AC_ATTRIBUTE14
         , NULL                                -- AC_ATTRIBUTE15
         , LDETS.operand_value                 -- OPERAND_PER_PQTY
         , LDETS.adjustment_amount             -- ADJUSTED_AMOUNT_PER_PQTY
         , 1                                   -- LOCK_CONTROL
       FROM QP_LDETS_v LDETS
          , QP_PREQ_LINES_TMP QLINE
          , QP_LIST_HEADERS_B QH
       WHERE LDETS.list_header_id = QH.list_header_id
       AND LDETS.process_code = QP_PREQ_GRP.G_STATUS_NEW
       AND QLINE.pricing_status_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
       AND QLINE.process_status <> 'NOT_VALID'
       AND LDETS.line_index = QLINE.line_index
       AND (nvl(LDETS.automatic_flag, 'N') = 'Y')
       AND LDETS.created_from_list_type_code NOT IN ('PRL', 'AGR')
       AND LDETS.list_line_type_code <> 'PLL'
       AND LDETS.list_line_id NOT IN (SELECT ADJ.list_line_id
                                      FROM   PO_PRICE_ADJUSTMENTS_DRAFT ADJ
                                      WHERE  ADJ.list_line_id = LDETS.list_line_id
                                      AND    ADJ.po_line_id = QLINE.line_id)
      );
    l_progress := '280';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'INSERTED '|| SQL%ROWCOUNT ||' ADJUSTMENTS');
    END IF;

    --New Parent Adjustment Id Logic Start
    SELECT  ADJ.price_adjustment_id
          , RADJ.price_adjustment_id
    BULK COLLECT INTO l_price_adjustment_id_tbl
                     ,l_rltd_price_adj_id_tbl
    FROM    QP_PREQ_RLTD_LINES_TMP RLTD
          , QP_PREQ_LINES_TMP QPL
          , PO_PRICE_ADJUSTMENTS_DRAFT ADJ
          , PO_PRICE_ADJUSTMENTS_DRAFT RADJ
    WHERE QPL.LINE_INDEX = RLTD.LINE_INDEX
    AND   QPL.LINE_ID = ADJ.PO_LINE_ID
    AND   ADJ.draft_id = p_draft_id
    AND   QPL.LINE_TYPE_CODE = 'LINE'
    AND   QPL.PROCESS_STATUS <> 'NOT_VALID'
    AND   RLTD.LIST_LINE_ID = ADJ.LIST_LINE_ID
    AND   RLTD.RELATED_LINE_INDEX = QPL.LINE_INDEX
    AND   RLTD.RELATED_LIST_LINE_ID = RADJ.LIST_LINE_ID
    AND   ADJ.PO_LINE_ID = RADJ.PO_LINE_ID
    AND   ADJ.draft_id = RADJ.draft_id
    AND   RLTD.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

    --Update adjustment table with parent record
    FORALL i IN l_rltd_price_adj_id_tbl.FIRST..l_rltd_price_adj_id_tbl.LAST
    UPDATE PO_PRICE_ADJUSTMENTS_DRAFT ADJ
    SET ADJ.parent_adjustment_id = l_price_adjustment_id_tbl(i)
    WHERE ADJ.price_adjustment_id = l_rltd_price_adj_id_tbl(i);
    --New Parent Adjustment Id Logic end

  EXCEPTION
    WHEN OTHERS THEN
      l_progress := '300';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'ERROR in inserting adjustments and associations');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  END insert_adj;

  PROCEDURE update_adj_attribs(p_draft_id        IN NUMBER
                              ,p_order_header_id IN NUMBER
                              ,p_pricing_events IN VARCHAR2
                              ,p_log_head       IN VARCHAR2)
  IS
  --
    l_adj_id_tbl NUMBER_TYPE;
    l_line_detail_index_tbl NUMBER_TYPE;
    i PLS_INTEGER;
    l_progress VARCHAR2(4):= '370';

    CURSOR refresh_attribs_cur IS
      SELECT ADJ.price_adjustment_id, ldets.line_detail_index
      FROM   QP_PREQ_LINES_TMP QPL
           , PO_PRICE_ADJUSTMENTS_DRAFT ADJ
           , QP_LDETS_V LDETS
      WHERE LDETS.list_line_id = ADJ.list_line_id
      AND ADJ.draft_id = p_draft_id --For now draft_id in this place can never be null, but this condition needs to be changed or removed if null value is allowed in draft_id
      AND LDETS.line_index = QPL.line_index
      AND ADJ.pricing_phase_id IN (SELECT QEP.pricing_phase_id
                                   FROM   qp_event_phases QEP
                                   WHERE  instr(p_pricing_events, QEP.pricing_event_code || ',') > 0)
      AND LDETS.process_code IN (QP_PREQ_GRP.G_STATUS_UNCHANGED, QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_NEW)
      AND nvl(ADJ.updated_flag, 'N') = 'N'
      AND QPL.line_id = ADJ.po_line_id
      AND QPL.process_status <> 'NOT_VALID'
      AND QPL.line_type_code = 'LINE'
      AND QPL.pricing_status_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED);
  --
  BEGIN
  --
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'Update Adjustment Attributes called with the below parameters');
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_order_header_id',p_order_header_id);
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_pricing_events',p_pricing_events);
    END IF;
    l_adj_id_tbl.delete;
    l_line_detail_index_tbl.delete;

    OPEN refresh_attribs_cur;
    FETCH refresh_attribs_cur BULK COLLECT INTO l_adj_id_tbl, l_line_detail_index_tbl;

    IF l_adj_id_tbl.count > 0 THEN
      FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
       DELETE FROM PO_PRICE_ADJ_ATTRIBS_DRAFT WHERE draft_id = p_draft_id AND price_adjustment_id = l_adj_id_tbl(i)
       AND ( pricing_context
           , pricing_attribute
           , pricing_attr_value_from
           , pricing_attr_value_to
           )
           NOT IN
           (SELECT  QPLAT.context
                  , QPLAT.attribute
                  , QPLAT.setup_value_from
                  , QPLAT.setup_value_to
            FROM   QP_PREQ_LINE_ATTRS_TMP QPLAT
            WHERE  QPLAT.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
            AND    QPLAT.line_detail_index = l_line_detail_index_tbl(i)
           );

      l_progress := '380';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'DELETED '|| SQL%ROWCOUNT ||' ATTRIBUTES');
      END IF;

      FORALL i IN l_adj_id_tbl.FIRST..l_adj_id_tbl.LAST
      INSERT INTO PO_PRICE_ADJ_ATTRIBS_DRAFT
       (DRAFT_ID
               , PRICE_ADJUSTMENT_ID
               , PRICING_CONTEXT
               , PRICING_ATTRIBUTE
               , CREATION_DATE
               , CREATED_BY
               , LAST_UPDATE_DATE
               , LAST_UPDATED_BY
               , LAST_UPDATE_LOGIN
               , PROGRAM_APPLICATION_ID
               , PROGRAM_ID
               , PROGRAM_UPDATE_DATE
               , REQUEST_ID
               , PRICING_ATTR_VALUE_FROM
               , PRICING_ATTR_VALUE_TO
               , COMPARISON_OPERATOR
               , FLEX_TITLE
               , PRICE_ADJ_ATTRIB_ID
               , LOCK_CONTROL
       )
       (SELECT
               p_draft_id
             , l_adj_id_tbl(i) --ADJ.PRICE_ADJUSTMENT_ID
             , QPLAT.context
             , QPLAT.attribute
             , SYSDATE
             , fnd_global.user_id
             , SYSDATE
             , fnd_global.user_id
             , fnd_global.login_id
             , NULL
             , NULL
             , NULL
             , NULL
             , QPLAT.setup_value_from --VALUE_FROM
             , QPLAT.setup_value_to   --VALUE_TO
             , QPLAT.comparison_operator_type_code
             , decode(QPLAT.attribute_type,
                     'QUALIFIER', 'QP_ATTR_DEFNS_QUALIFIER',
                     'QP_ATTR_DEFNS_PRICING')
             , PO_PRICE_ADJ_ATTRIBS_S.nextval
             , 1
        FROM  QP_PREQ_LINE_ATTRS_TMP QPLAT
        WHERE QPLAT.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
        AND   QPLAT.LINE_DETAIL_INDEX = l_line_detail_index_tbl(i)
        AND ( QPLAT.context
            , QPLAT.attribute
            , QPLAT.setup_value_from
            , QPLAT.setup_value_to
            )
            NOT IN
            (SELECT  pricing_context
                   , pricing_attribute
                   , pricing_attr_value_from
                   , pricing_attr_value_to
             FROM PO_PRICE_ADJ_ATTRIBS_DRAFT
             WHERE PRICE_ADJUSTMENT_ID = l_adj_id_tbl(i))
       );

      l_progress := '390';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'INSERTED '|| SQL%ROWCOUNT ||' CHANGED ATTRIBS');
      END IF;
    END IF;
    CLOSE refresh_attribs_cur;
  END update_adj_attribs;


  PROCEDURE insert_adj_attribs(p_draft_id        IN NUMBER
                              ,p_order_header_id IN NUMBER
                              ,p_log_head        IN VARCHAR2)
  IS
  --
   l_progress VARCHAR2(4) := '450';
  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head,l_progress,'Insert Adjustment Attributes called with the below parameters');
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_draft_id',p_draft_id);
      PO_DEBUG.debug_var(p_log_head,l_progress,'p_order_header_id',p_order_header_id);
    END IF;

    INSERT INTO PO_PRICE_ADJ_ATTRIBS_DRAFT
                (DRAFT_ID
                       , PRICE_ADJUSTMENT_ID
                       , PRICING_CONTEXT
                       , PRICING_ATTRIBUTE
                       , CREATION_DATE
                       , CREATED_BY
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , LAST_UPDATE_LOGIN
                       , PROGRAM_APPLICATION_ID
                       , PROGRAM_ID
                       , PROGRAM_UPDATE_DATE
                       , REQUEST_ID
                       , PRICING_ATTR_VALUE_FROM
                       , PRICING_ATTR_VALUE_TO
                       , COMPARISON_OPERATOR
                       , FLEX_TITLE
                       , PRICE_ADJ_ATTRIB_ID
                       , LOCK_CONTROL
                )
                (SELECT  p_draft_id
                       , ADJ.price_adjustment_id
                       , QPLAT.context
                       , QPLAT.attribute
                       , SYSDATE
                       , fnd_global.user_id
                       , SYSDATE
                       , fnd_global.user_id
                       , fnd_global.login_id
                       , NULL
                       , NULL
                       , NULL
                       , NULL
                       , QPLAT.setup_value_from --VALUE_FROM
                       , QPLAT.setup_value_to   --VALUE_TO
                       , QPLAT.comparison_operator_type_code
                       , decode(QPLAT.attribute_type,
                               'QUALIFIER', 'QP_ATTR_DEFNS_QUALIFIER',
                               'QP_ATTR_DEFNS_PRICING')
                       , PO_PRICE_ADJ_ATTRIBS_S.nextval
                       , 1
                 FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
                    , QP_LDETS_v LDETS
                    , PO_PRICE_ADJUSTMENTS_DRAFT ADJ
                    , QP_PREQ_LINES_TMP QPLINE
                 WHERE ADJ.po_header_id = p_order_header_id
                 AND   QPLAT.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                 AND   QPLAT.line_detail_index = LDETS.line_detail_index
                 AND   QPLAT.line_index = LDETS.line_index
                 AND   LDETS.list_line_id = ADJ.list_line_id
                 AND   LDETS.process_code = QP_PREQ_PUB.G_STATUS_NEW
                 AND   LDETS.line_index = QPLINE.line_index
                 AND   QPLINE.line_id = ADJ.po_line_id
                 AND   QPLINE.line_type_code = 'LINE'
                 AND   QPLINE.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED)
                 AND   QPLINE.process_status <> 'NOT_VALID'
                );
      l_progress := '460';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head,l_progress,'INSERTED '|| SQL%ROWCOUNT ||' ATTRIBS');
      END IF;
  END insert_adj_attribs;

  PROCEDURE complete_manual_mod_lov_map
    (p_draft_id           IN  NUMBER
    ,p_doc_sub_type       IN  VARCHAR2
    ,x_return_status_text OUT NOCOPY VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    )
  IS
  --
    d_mod CONSTANT VARCHAR2(100) := D_complete_manual_mod_lov_map;
    d_position NUMBER := 0;

    l_price_adjustment_id_tbl NUMBER_TYPE;
  BEGIN
  --
    d_position := 1;
    SAVEPOINT COMPLETE_MANUAL_MOD_LOV_MAP;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_mod);
      PO_LOG.proc_begin(d_mod, 'p_draft_id', p_draft_id);
      PO_LOG.proc_begin(d_mod, 'p_doc_sub_type', p_doc_sub_type);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    d_position := 100;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'Get newly added manual modifier lines');
    END IF;

    SELECT price_adjustment_id
    BULK COLLECT INTO l_price_adjustment_id_tbl
    FROM po_price_adjustments_draft ADJD
    WHERE ADJD.draft_id = p_draft_id
    AND ADJD.applied_flag IS NULL                  --this check is needed to ensure if the manual modifier is newly added
    AND NVL(ADJD.automatic_flag, 'N') = 'N'        --line is not automatic modifier
    AND NVL(ADJD.delete_flag, 'N') = 'N'           --line is not marked for deletion
    AND NVL(ADJD.change_accepted_flag, 'Y') = 'Y'; --change is accepted for the line. Do we need this condition??

    d_position := 120;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'Populate PO_PRICE_ADJ_ATTRIBS table with pricing attribute details');
    END IF;

    FORALL i IN l_price_adjustment_id_tbl.FIRST .. l_price_adjustment_id_tbl.LAST
      INSERT INTO PO_PRICE_ADJ_ATTRIBS_DRAFT
                (DRAFT_ID
                       , PRICE_ADJUSTMENT_ID
                       , PRICING_CONTEXT
                       , PRICING_ATTRIBUTE
                       , CREATION_DATE
                       , CREATED_BY
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , LAST_UPDATE_LOGIN
                       , PROGRAM_APPLICATION_ID
                       , PROGRAM_ID
                       , PROGRAM_UPDATE_DATE
                       , REQUEST_ID
                       , PRICING_ATTR_VALUE_FROM
                       , PRICING_ATTR_VALUE_TO
                       , COMPARISON_OPERATOR
                       , FLEX_TITLE
                       , PRICE_ADJ_ATTRIB_ID
                       , LOCK_CONTROL
                )
                (SELECT  p_draft_id
                       , ADJD.price_adjustment_id
                       , PRA.pricing_attribute_context
                       , PRA.pricing_attribute
                       , SYSDATE
                       , fnd_global.user_id
                       , SYSDATE
                       , fnd_global.user_id
                       , fnd_global.login_id
                       , NULL
                       , NULL
                       , NULL
                       , NULL
                       , PRA.pricing_attr_value_from --VALUE_FROM
                       , PRA.pricing_attr_value_to   --VALUE_TO
                       , PRA.comparison_operator_code
                       , 'QP_ATTR_DEFNS_PRICING' --FLEX_TITLE
                       , PO_PRICE_ADJ_ATTRIBS_S.nextval
                       , 1
                 FROM QP_PRICING_ATTRIBUTES PRA
                     ,PO_PRICE_ADJUSTMENTS_DRAFT ADJD
                 WHERE ADJD.draft_id = p_draft_id
                 AND ADJD.price_adjustment_id = l_price_adjustment_id_tbl(i)
                 AND ADJD.list_header_id = PRA.list_header_id
                 AND ADJD.list_line_id = PRA.list_line_id
                 AND PRA.pricing_attribute_context IS NOT NULL --only pricing attributes are picked, also to avoid product attributes
                 AND PRA.pricing_attr_value_from IS NOT NULL); --pricing attr with from value should not be null

    d_position := 140;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'INSERTED '|| SQL%ROWCOUNT ||' PRICING PRICE ADJ ATTRIBS');
    END IF;

    d_position := 160;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'Populate PO_PRICE_ADJ_ATTRIBS table with qualifier attribute details');
    END IF;

    FORALL i IN l_price_adjustment_id_tbl.FIRST .. l_price_adjustment_id_tbl.LAST
      INSERT INTO PO_PRICE_ADJ_ATTRIBS_DRAFT
                (DRAFT_ID
                       , PRICE_ADJUSTMENT_ID
                       , PRICING_CONTEXT
                       , PRICING_ATTRIBUTE
                       , CREATION_DATE
                       , CREATED_BY
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , LAST_UPDATE_LOGIN
                       , PROGRAM_APPLICATION_ID
                       , PROGRAM_ID
                       , PROGRAM_UPDATE_DATE
                       , REQUEST_ID
                       , PRICING_ATTR_VALUE_FROM
                       , PRICING_ATTR_VALUE_TO
                       , COMPARISON_OPERATOR
                       , FLEX_TITLE
                       , PRICE_ADJ_ATTRIB_ID
                       , LOCK_CONTROL
                )
                (SELECT  p_draft_id
                       , ADJD.price_adjustment_id
                       , QUAL.qualifier_context
                       , QUAL.qualifier_attribute
                       , SYSDATE
                       , fnd_global.user_id
                       , SYSDATE
                       , fnd_global.user_id
                       , fnd_global.login_id
                       , NULL
                       , NULL
                       , NULL
                       , NULL
                       , QUAL.qualifier_attr_value --VALUE_FROM
                       , QUAL.qualifier_attr_value_to   --VALUE_TO
                       , QUAL.comparison_operator_code
                       , 'QP_ATTR_DEFNS_QUALIFIER' --FLEX_TITLE
                       , PO_PRICE_ADJ_ATTRIBS_S.nextval
                       , 1
                 FROM QP_QUALIFIERS QUAL
                     ,PO_PRICE_ADJUSTMENTS_DRAFT ADJD
                 WHERE ADJD.draft_id = p_draft_id
                 AND ADJD.price_adjustment_id = l_price_adjustment_id_tbl(i)
                 AND ADJD.list_header_id = QUAL.list_header_id
                 AND ADJD.list_line_id = QUAL.list_line_id
                 AND QUAL.qualifier_attr_value IS NOT NULL); --qualifier attr with from value should not be null

    d_position := 180;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'INSERTED '|| SQL%ROWCOUNT ||' QUALIFIER PRICE ADJ ATTRIBS');
    END IF;

    d_position := 200;
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_return_status_text', x_return_status_text);
      PO_LOG.proc_end(d_mod, 'x_return_status', x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status_text := 'UnExpected ERROR IN COMPLETE_MANUAL_MOD_LOV_MAP. SQLERRM at '||d_position||': '||SQLERRM;
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, d_position, x_return_status_text);
      END IF;
      ROLLBACK TO SAVEPOINT COMPLETE_MANUAL_MOD_LOV_MAP;
  END complete_manual_mod_lov_map;

  PROCEDURE copy_line_adjustments
    ( p_src_po_line_id     IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE
    , p_dest_po_header_id  IN PO_PRICE_ADJUSTMENTS.po_header_id%TYPE
    , p_dest_po_line_id    IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE
    , p_mode               IN VARCHAR2
    , x_return_status_text OUT NOCOPY VARCHAR2
    , x_return_status      OUT NOCOPY VARCHAR2
    )
  IS
  --
    l_api_name CONSTANT varchar2(30)  := 'copy_line_adjustments';
    l_log_head CONSTANT varchar2(100) := g_log_head || l_api_name;
    l_progress VARCHAR2(4) := '000';
    l_return_status_text VARCHAR2(2000);
    COPYDOC_ADJUSTMENT_FAILURE EXCEPTION;

    l_po_price_adjustment_record PO_PRICE_ADJUSTMENTS%ROWTYPE;
    l_src_price_adjustment_id PO_PRICE_ADJUSTMENTS.price_adjustment_id%TYPE;

    l_src_adj_count NUMBER;
    --l_src_asoc_count NUMBER;
    l_src_attr_count NUMBER;

    l_dest_adj_count NUMBER;
    --l_dest_asoc_count NUMBER;
    l_dest_attr_count NUMBER;

    l_adjustments_exist NUMBER;
    l_dml_count NUMBER;

    l_auto_manual_flag VARCHAR2(1);
    l_override_allowed_flag VARCHAR2(1);
    l_overridden_flag VARCHAR2(1);

    l_src_price_adjustment_id_tbl  NUMBER_TYPE;
    l_dest_price_adjustment_id_tbl NUMBER_TYPE;
    i PLS_INTEGER;

    --Used to pick only the parent adjustments
    CURSOR po_price_adjustments_cur(p_src_line_id PO_PRICE_ADJUSTMENTS.po_line_id%TYPE
                                   ,p_auto_manual_flag VARCHAR2
                                   ,p_override_allowed_flag VARCHAR2
                                   ,p_overridden_flag VARCHAR2) IS
      SELECT ADJ.*
      FROM PO_PRICE_ADJUSTMENTS ADJ
      WHERE ADJ.po_line_id = p_src_line_id
      AND (p_auto_manual_flag IS NULL OR ADJ.automatic_flag = p_auto_manual_flag)
      AND (p_override_allowed_flag IS NULL OR ADJ.update_allowed = p_override_allowed_flag)
      AND (p_overridden_flag IS NULL OR ADJ.updated_flag = p_overridden_flag);

  BEGIN
    SAVEPOINT COPY_LINE_ADJUSTMENTS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress := '010';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_src_po_line_id',p_src_po_line_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_dest_po_header_id',p_dest_po_header_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_dest_po_line_id',p_dest_po_line_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_mode',p_mode);
    END IF;

    IF (p_mode = G_COPY_MANUAL_MOD) THEN
      l_auto_manual_flag := 'N';
      l_override_allowed_flag := 'N';
      l_overridden_flag := 'N';
    ELSIF (p_mode = G_COPY_MANUAL_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := 'N';
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSIF (p_mode = G_COPY_AUTO_MOD) THEN
      l_auto_manual_flag := 'Y';
      l_override_allowed_flag := 'N';
      l_overridden_flag := 'N';
    ELSIF (p_mode = G_COPY_AUTO_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := 'Y';
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSIF (p_mode = G_COPY_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := NULL;
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSE --G_COPY_ALL_MOD
      l_auto_manual_flag := NULL;
      l_override_allowed_flag := NULL;
      l_overridden_flag := NULL;
    END IF;

    l_progress := '020';
    --Check if the required parameters are passed
    IF (p_src_po_line_id IS NULL
        OR p_dest_po_header_id IS NULL OR p_dest_po_line_id IS NULL) THEN
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Incomplete parameters');
      END IF;

      l_return_status_text := 'Incomplete parameters - '||
                              'p_src_po_line_id: '||p_src_po_line_id||', '||
                              'p_dest_po_header_id: '||p_dest_po_header_id||', '||
                              'p_dest_po_line_id: '||p_dest_po_line_id;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;

    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Check if adjustments already exist for the destination line id');
    END IF;

    --Check if adjsutments already exist for the destination line id
    SELECT COUNT(1)
    INTO l_adjustments_exist
    FROM  PO_PRICE_ADJUSTMENTS ADJ
    WHERE ADJ.po_line_id = p_dest_po_line_id
    AND (l_auto_manual_flag IS NULL OR ADJ.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ADJ.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ADJ.updated_flag = l_overridden_flag);

    IF (l_adjustments_exist > 0) THEN
      l_return_status_text := 'Adjustments already exist for the destination Header Id: '||p_dest_po_header_id||' and Line Id: '||p_dest_po_line_id;
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
      END IF;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;

    l_progress := '050';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get the current src record status');
    END IF;

    SELECT COUNT(1)
    INTO l_src_adj_count
    FROM PO_PRICE_ADJUSTMENTS ADJ
    WHERE ADJ.po_line_id = p_src_po_line_id
    AND (l_auto_manual_flag IS NULL OR ADJ.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ADJ.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ADJ.updated_flag = l_overridden_flag);

    SELECT COUNT(1)
    INTO l_src_attr_count
    FROM PO_PRICE_ADJ_ATTRIBS ATTR
        ,PO_PRICE_ADJUSTMENTS ADJ
    WHERE ATTR.price_adjustment_id = ADJ.price_adjustment_id
    AND ADJ.po_line_id = p_src_po_line_id
    AND (l_auto_manual_flag IS NULL OR ADJ.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ADJ.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ADJ.updated_flag = l_overridden_flag);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_adj_count',l_src_adj_count);
      --PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_asoc_count',l_src_asoc_count);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_attr_count',l_src_attr_count);
    END IF;

    l_progress := '070';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Loop through and Copy Adjustments');
    END IF;

    i := 0;
    OPEN po_price_adjustments_cur( p_src_po_line_id
                                 , l_auto_manual_flag
                                 , l_override_allowed_flag
                                 , l_overridden_flag);
    <<ADJUSTMENTS>>
    LOOP
      FETCH po_price_adjustments_cur INTO l_po_price_adjustment_record;
      EXIT ADJUSTMENTS WHEN po_price_adjustments_cur%NOTFOUND;

      -- reset for new record
      l_po_price_adjustment_record.po_header_id := p_dest_po_header_id;
      l_po_price_adjustment_record.po_line_id := p_dest_po_line_id;

      l_src_price_adjustment_id := l_po_price_adjustment_record.price_adjustment_id;
      SELECT po_price_adjustments_s.nextval
      INTO   l_po_price_adjustment_record.price_adjustment_id
      FROM   SYS.DUAL;

      --reset Standard and other columns
      l_po_price_adjustment_record.created_by        := fnd_global.user_id;
      l_po_price_adjustment_record.creation_date     := SYSDATE;
      l_po_price_adjustment_record.last_updated_by   := fnd_global.user_id;
      l_po_price_adjustment_record.last_update_date  := SYSDATE;
      l_po_price_adjustment_record.last_update_login := fnd_global.login_id;

      l_po_price_adjustment_record.program_application_id := NULL;
      l_po_price_adjustment_record.program_id             := NULL;
      l_po_price_adjustment_record.program_update_date    := NULL;
      l_po_price_adjustment_record.request_id             := NULL;

      l_progress := '080';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call insert adjustment record');
      END IF;

      insert_adj_rec(l_po_price_adjustment_record);

      l_dml_count := SQL%ROWCOUNT;
      IF (l_dml_count = 0) THEN
        l_return_status_text := 'Insert adjustment record failed';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
        END IF;
        RAISE COPYDOC_ADJUSTMENT_FAILURE;
      END IF;
      l_dest_adj_count := l_dest_adj_count + l_dml_count;

      l_progress := '090';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Insert attributes corresponding to the adjustment');
      END IF;

      --copy attribute lines for the adjustment
      INSERT INTO PO_PRICE_ADJ_ATTRIBS
                 (PRICE_ADJUSTMENT_ID
                        , PRICING_CONTEXT
                        , PRICING_ATTRIBUTE
                        , CREATION_DATE
                        , CREATED_BY
                        , LAST_UPDATE_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATE_LOGIN
                        , PROGRAM_APPLICATION_ID
                        , PROGRAM_ID
                        , PROGRAM_UPDATE_DATE
                        , REQUEST_ID
                        , PRICING_ATTR_VALUE_FROM
                        , PRICING_ATTR_VALUE_TO
                        , COMPARISON_OPERATOR
                        , FLEX_TITLE
                        , PRICE_ADJ_ATTRIB_ID
                        , LOCK_CONTROL
                 )
                 (SELECT
                          l_po_price_adjustment_record.price_adjustment_id --newly copied price_adjustment_id
                        , ATTR.pricing_context
                        , ATTR.pricing_attribute
                        , SYSDATE
                        , fnd_global.user_id
                        , SYSDATE
                        , fnd_global.user_id
                        , fnd_global.login_id
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , ATTR.pricing_attr_value_from
                        , ATTR.pricing_attr_value_to
                        , ATTR.comparison_operator
                        , ATTR.FLEX_TITLE
                        , PO_PRICE_ADJ_ATTRIBS_S.nextval
                        , 1
                  FROM  PO_PRICE_ADJ_ATTRIBS ATTR
                  WHERE ATTR.price_adjustment_id = l_src_price_adjustment_id);
      l_dest_attr_count :=  l_dest_attr_count + SQL%ROWCOUNT;

      --Get the source and dest price adjustment id mapping, will be used later to update the parent adjustment ids
      i := i + 1;
      l_src_price_adjustment_id_tbl(i) := l_src_price_adjustment_id;
      l_dest_price_adjustment_id_tbl(i) := l_po_price_adjustment_record.price_adjustment_id;
    END LOOP ADJUSTMENTS;
    CLOSE po_price_adjustments_cur;

    l_progress := '100';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Update parent adjustment ids');
    END IF;

    FORALL i IN l_src_price_adjustment_id_tbl.FIRST .. l_src_price_adjustment_id_tbl.LAST
    UPDATE PO_PRICE_ADJUSTMENTS
    SET parent_adjustment_id = l_dest_price_adjustment_id_tbl(i)
    WHERE parent_adjustment_id = l_src_price_adjustment_id_tbl(i)
    AND po_header_id = p_dest_po_header_id
    AND po_line_id = p_dest_po_line_id
    AND parent_adjustment_id IS NOT NULL; --Only child lines are considered

    l_progress := '120';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Check if the entire price structure is copied');
    END IF;

    IF (l_src_adj_count <> l_dest_adj_count OR l_src_attr_count <> l_dest_attr_count) THEN --OR l_src_asoc_count <> l_dest_asoc_count
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Copy Line Adjustment failed with incomplete price structure');
        PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Adjustment Count: '||l_src_adj_count||', Destination Adjustment Count: '||l_dest_adj_count);
        --PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Association Count: '||l_src_asoc_count||', Destination Association Count: '||l_dest_asoc_count);
        PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Attribute Count: '||l_src_attr_count||', Destination Attribute Count: '||l_dest_attr_count);
      END IF;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status_text',x_return_status_text);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
    END IF;

  EXCEPTION
    WHEN COPYDOC_ADJUSTMENT_FAILURE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_return_status_text;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING COPY_LINE_ADJUSTMENTS with ERROR: '||l_return_status_text);
      END IF;
      ROLLBACK TO SAVEPOINT COPY_LINE_ADJUSTMENTS;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status_text := 'UnExpected ERROR IN COPY_LINE_ADJUSTMENTS. SQLERRM at '||l_progress||': '||SQLERRM;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, x_return_status_text);
      END IF;
      ROLLBACK TO SAVEPOINT COPY_LINE_ADJUSTMENTS;
  END copy_line_adjustments;


  PROCEDURE copy_draft_line_adjustments
    ( p_draft_id           IN PO_PRICE_ADJUSTMENTS_DRAFT.draft_id%TYPE
    , p_src_po_line_id     IN PO_PRICE_ADJUSTMENTS_DRAFT.po_line_id%TYPE
    , p_dest_po_header_id  IN PO_PRICE_ADJUSTMENTS_DRAFT.po_header_id%TYPE
    , p_dest_po_line_id    IN PO_PRICE_ADJUSTMENTS_DRAFT.po_line_id%TYPE
    , p_mode               IN VARCHAR2
    , x_return_status_text OUT NOCOPY VARCHAR2
    , x_return_status      OUT NOCOPY VARCHAR2
    )
  IS
  --
    l_api_name CONSTANT varchar2(30)  := 'copy_draft_line_adjustments';
    l_log_head CONSTANT varchar2(100) := g_log_head || l_api_name;
    l_progress VARCHAR2(4) := '000';
    l_return_status_text VARCHAR2(2000);
    COPYDOC_ADJUSTMENT_FAILURE EXCEPTION;

    l_po_price_adjustment_record PO_PRICE_ADJUSTMENTS_V%ROWTYPE;
    l_src_price_adjustment_id PO_PRICE_ADJUSTMENTS_DRAFT.price_adjustment_id%TYPE;

    l_src_adj_count NUMBER;
    --l_src_asoc_count NUMBER;
    l_src_attr_count NUMBER;

    l_dest_adj_count NUMBER;
    --l_dest_asoc_count NUMBER;
    l_dest_attr_count NUMBER;

    l_adjustments_exist NUMBER;
    l_dml_count NUMBER;

    l_auto_manual_flag VARCHAR2(1);
    l_override_allowed_flag VARCHAR2(1);
    l_overridden_flag VARCHAR2(1);

    l_src_price_adjustment_id_tbl  NUMBER_TYPE;
    l_dest_price_adjustment_id_tbl NUMBER_TYPE;
    i PLS_INTEGER;

    --Used to pick only the parent adjustments
    CURSOR po_price_adjustments_cur(p_src_line_id PO_PRICE_ADJUSTMENTS_DRAFT.po_line_id%TYPE
                                   ,p_auto_manual_flag VARCHAR2
                                   ,p_override_allowed_flag VARCHAR2
                                   ,p_overridden_flag VARCHAR2) IS
      SELECT ADJV.*
      FROM PO_PRICE_ADJUSTMENTS_V ADJV
      WHERE ADJV.po_line_id = p_src_line_id --ADJV.draft_id = p_draft_id --the draft id may not have been initialized when copy event was triggered
      AND (p_auto_manual_flag IS NULL OR ADJV.automatic_flag = p_auto_manual_flag)
      AND (p_override_allowed_flag IS NULL OR ADJV.update_allowed = p_override_allowed_flag)
      AND (p_overridden_flag IS NULL OR ADJV.updated_flag = p_overridden_flag);

  BEGIN
    SAVEPOINT COPY_DRAFT_LINE_ADJUSTMENTS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress := '010';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_draft_id',p_draft_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_src_po_line_id',p_src_po_line_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_dest_po_header_id',p_dest_po_header_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_dest_po_line_id',p_dest_po_line_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_mode',p_mode);
    END IF;

    /*
    IF (p_mode <> G_COPY_ALL_MOD) THEN
      l_return_status_text := 'The only mode supported for now is COPY ALL ADJUSTMENTS';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
      END IF;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;
    */
    IF (p_mode = G_COPY_MANUAL_MOD) THEN
      l_auto_manual_flag := 'N';
      l_override_allowed_flag := 'N';
      l_overridden_flag := 'N';
    ELSIF (p_mode = G_COPY_MANUAL_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := 'N';
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSIF (p_mode = G_COPY_AUTO_MOD) THEN
      l_auto_manual_flag := 'Y';
      l_override_allowed_flag := 'N';
      l_overridden_flag := 'N';
    ELSIF (p_mode = G_COPY_AUTO_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := 'Y';
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSIF (p_mode = G_COPY_OVERRIDDEN_MOD) THEN
      l_auto_manual_flag := NULL;
      l_override_allowed_flag := 'Y';
      l_overridden_flag := 'Y';
    ELSE --G_COPY_ALL_MOD
      l_auto_manual_flag := NULL;
      l_override_allowed_flag := NULL;
      l_overridden_flag := NULL;
    END IF;

    l_progress := '020';
    --Check if the required parameters are passed
    IF (p_draft_id IS NULL OR p_src_po_line_id IS NULL
        OR p_dest_po_header_id IS NULL OR p_dest_po_line_id IS NULL) THEN
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Incomplete parameters');
      END IF;

      l_return_status_text := 'Incomplete parameters - '||
                              'p_draft_id: '||p_draft_id||', '||
                              'p_src_po_line_id: '||p_src_po_line_id||', '||
                              'p_dest_po_header_id: '||p_dest_po_header_id||', '||
                              'p_dest_po_line_id: '||p_dest_po_line_id;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;

    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Check if adjustments already exist for the destination line id');
    END IF;

    --Check if adjsutments already exist for the destination line id
    SELECT COUNT(1)
    INTO l_adjustments_exist
    FROM  PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.draft_id = p_draft_id
    AND  ADJV.po_line_id = p_dest_po_line_id
    AND (l_auto_manual_flag IS NULL OR ADJV.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ADJV.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ADJV.updated_flag = l_overridden_flag);

    IF (l_adjustments_exist > 0) THEN
      l_return_status_text := 'Adjustments already exist for the Draft Id: '||p_draft_id||', Destination Header Id: '||p_dest_po_header_id||' and Line Id: '||p_dest_po_line_id;
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
      END IF;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;

    l_progress := '050';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get the current src record status');
    END IF;

    SELECT COUNT(1)
    INTO l_src_adj_count
    FROM PO_PRICE_ADJUSTMENTS_V ADJV
    WHERE ADJV.po_line_id = p_src_po_line_id --ADJV.draft_id = p_draft_id  --the draft id may not have been initialized when copy event was triggered
    AND (l_auto_manual_flag IS NULL OR ADJV.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ADJV.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ADJV.updated_flag = l_overridden_flag);

    /*
    SELECT COUNT(1)
    INTO l_src_asoc_count
    FROM PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
    WHERE ASOC.draft_id = p_draft_id
    AND ASOC.line_id = p_src_po_line_id
    AND EXISTS (SELECT 1
                FROM PO_PRICE_ADJUSTMENTS_DRAFT ADJ
                WHERE ADJ.draft_id = p_draft_id
                AND ADJ.line_id = p_src_po_line_id
                AND (l_auto_manual_flag IS NULL OR ADJ.automatic_flag = l_auto_manual_flag)
                AND (l_override_allowed_flag IS NULL OR ADJ.update_allowed = l_override_allowed_flag)
                AND (l_overridden_flag IS NULL OR ADJ.updated_flag = l_overridden_flag));
    */

    SELECT COUNT(1)
    INTO l_src_attr_count
    FROM PO_PRICE_ADJ_ATTRIBS_V ATTRV
    WHERE ATTRV.po_line_id = p_src_po_line_id --ADJV.draft_id = p_draft_id AND ATTRV.draft_id = ADJV.draft_id  --the draft id may not have been initialized when copy event was triggered
    AND (l_auto_manual_flag IS NULL OR ATTRV.automatic_flag = l_auto_manual_flag)
    AND (l_override_allowed_flag IS NULL OR ATTRV.update_allowed = l_override_allowed_flag)
    AND (l_overridden_flag IS NULL OR ATTRV.updated_flag = l_overridden_flag);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_adj_count',l_src_adj_count);
      --PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_asoc_count',l_src_asoc_count);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_src_attr_count',l_src_attr_count);
    END IF;

    /*
    l_progress := '060';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Copy Draft ssociation records first');
    END IF;

    --Copy Association records with p_src_po_line_id
    INSERT INTO PO_PRICE_ADJ_ASSOCS_DRAFT
               (DRAFT_ID
                      , PRICE_ADJUSTMENT_ID
                      , CREATION_DATE
                      , CREATED_BY
                      , LAST_UPDATE_DATE
                      , LAST_UPDATED_BY
                      , LAST_UPDATE_LOGIN
                      , PROGRAM_APPLICATION_ID
                      , PROGRAM_ID
                      , PROGRAM_UPDATE_DATE
                      , REQUEST_ID
                      , PRICE_ADJ_ASSOC_ID
                      , LINE_ID
                      , RLTD_PRICE_ADJ_ID
                      , LOCK_CONTROL
               )
               (SELECT  p_draft_id
                      , ASOC.price_adjustment_id
                      , SYSDATE --p_Line_Adj_Assoc_Rec.creation_date
                      , fnd_global.user_id --p_Line_Adj_Assoc_Rec.CREATED_BY
                      , SYSDATE --p_Line_Adj_Assoc_Rec.LAST_UPDATE_DATE
                      , fnd_global.user_id --p_Line_Adj_Assoc_Rec.LAST_UPDATED_BY
                      , fnd_global.login_id --p_Line_Adj_Assoc_Rec.LAST_UPDATE_LOGIN
                      , NULL --p_Line_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID
                      , NULL --p_Line_Adj_Assoc_Rec.PROGRAM_ID
                      , NULL --p_Line_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE
                      , NULL --p_Line_Adj_Assoc_Rec.REQUEST_ID
                      , PO_PRICE_ADJ_ASSOCS_S.nextval
                      , p_dest_po_line_id
                      , ASOC.rltd_price_adj_id
                      , 1
                FROM  PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
                WHERE ASOC.draft_id = p_draft_id
                AND ASOC.line_id = p_src_po_line_id
                AND EXISTS (SELECT 1
                            FROM PO_PRICE_ADJUSTMENTS_DRAFT ADJ
                            WHERE ADJ.draft_id = p_draft_id
                            AND ADJ.line_id = p_src_po_line_id
                            AND (l_auto_manual_flag IS NULL OR ADJ.automatic_flag = l_auto_manual_flag)
                            AND (l_override_allowed_flag IS NULL OR ADJ.update_allowed = l_override_allowed_flag)
                            AND (l_overridden_flag IS NULL OR ADJ.updated_flag = l_overridden_flag)));

    l_dest_asoc_count := SQL%ROWCOUNT;
    IF (l_src_asoc_count <> l_dest_asoc_count) THEN
      l_return_status_text := 'Copy association record failed';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
      END IF;
      RAISE COPYDOC_ADJUSTMENT_FAILURE;
    END IF;
    */

    l_progress := '070';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Loop through and Copy Adjustments');
    END IF;
    i := 0;
    OPEN po_price_adjustments_cur( p_src_po_line_id
                                 , l_auto_manual_flag
                                 , l_override_allowed_flag
                                 , l_overridden_flag);
    <<ADJUSTMENTS>>
    LOOP
      FETCH po_price_adjustments_cur INTO l_po_price_adjustment_record;
      EXIT ADJUSTMENTS WHEN po_price_adjustments_cur%NOTFOUND;

      -- reset for new record
      --l_po_price_adjustment_record.draft_id := p_draft_id;
      l_po_price_adjustment_record.po_header_id := p_dest_po_header_id;
      l_po_price_adjustment_record.po_line_id := p_dest_po_line_id;

      l_src_price_adjustment_id := l_po_price_adjustment_record.price_adjustment_id;
      SELECT po_price_adjustments_s.nextval
      INTO   l_po_price_adjustment_record.price_adjustment_id
      FROM   SYS.DUAL;

      --reset Standard columns
      l_po_price_adjustment_record.created_by        := fnd_global.user_id;
      l_po_price_adjustment_record.creation_date     := SYSDATE;
      l_po_price_adjustment_record.last_updated_by   := fnd_global.user_id;
      l_po_price_adjustment_record.last_update_date  := SYSDATE;
      l_po_price_adjustment_record.last_update_login := fnd_global.login_id;

      l_po_price_adjustment_record.program_application_id := NULL;
      l_po_price_adjustment_record.program_id             := NULL;
      l_po_price_adjustment_record.program_update_date    := NULL;
      l_po_price_adjustment_record.request_id             := NULL;


      l_progress := '080';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call insert adjustment record');
      END IF;

      insert_draft_adj_rec(p_draft_id, l_po_price_adjustment_record);

      l_dml_count := SQL%ROWCOUNT;
      IF (l_dml_count = 0) THEN
        l_return_status_text := 'Insert adjustment record failed';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,l_return_status_text);
        END IF;
        RAISE COPYDOC_ADJUSTMENT_FAILURE;
      END IF;
      l_dest_adj_count := l_dest_adj_count + l_dml_count;

      l_progress := '090';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Insert attributes corresponding to the adjustment');
      END IF;

      --copy attribute lines for the adjustment
      INSERT INTO PO_PRICE_ADJ_ATTRIBS_DRAFT
                 (DRAFT_ID
                        , PRICE_ADJUSTMENT_ID
                        , PRICING_CONTEXT
                        , PRICING_ATTRIBUTE
                        , CREATION_DATE
                        , CREATED_BY
                        , LAST_UPDATE_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATE_LOGIN
                        , PROGRAM_APPLICATION_ID
                        , PROGRAM_ID
                        , PROGRAM_UPDATE_DATE
                        , REQUEST_ID
                        , PRICING_ATTR_VALUE_FROM
                        , PRICING_ATTR_VALUE_TO
                        , COMPARISON_OPERATOR
                        , FLEX_TITLE
                        , PRICE_ADJ_ATTRIB_ID
                        , LOCK_CONTROL
                 )
                 (SELECT
                          p_draft_id --ATTRV.draft_id --draft_id may not have been initialized when copy event was triggered
                        , l_po_price_adjustment_record.price_adjustment_id --newly copied price_adjustment_id
                        , ATTRV.pricing_context
                        , ATTRV.pricing_attribute
                        , SYSDATE
                        , fnd_global.user_id
                        , SYSDATE
                        , fnd_global.user_id
                        , fnd_global.login_id
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , ATTRV.pricing_attr_value_from
                        , ATTRV.pricing_attr_value_to
                        , ATTRV.comparison_operator
                        , ATTRV.FLEX_TITLE
                        , PO_PRICE_ADJ_ATTRIBS_S.nextval
                        , 1
                  FROM  PO_PRICE_ADJ_ATTRIBS_V ATTRV
                  WHERE ATTRV.price_adjustment_id = l_src_price_adjustment_id); --ATTRV.draft_id = p_draft_id --draft_id may not have been initialized when copy event was triggered
      l_dest_attr_count :=  l_dest_attr_count + SQL%ROWCOUNT;

      --Get the source and dest price adjustment id mapping, will be used later to update the parent adjustment ids
      i := i + 1;
      l_src_price_adjustment_id_tbl(i) := l_src_price_adjustment_id;
      l_dest_price_adjustment_id_tbl(i) := l_po_price_adjustment_record.price_adjustment_id;
    END LOOP ADJUSTMENTS;
    CLOSE po_price_adjustments_cur;

    l_progress := '100';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Update parent adjustment ids');
    END IF;

    FORALL i IN l_src_price_adjustment_id_tbl.FIRST .. l_src_price_adjustment_id_tbl.LAST
    UPDATE PO_PRICE_ADJUSTMENTS_DRAFT
    SET parent_adjustment_id = l_dest_price_adjustment_id_tbl(i)
    WHERE parent_adjustment_id = l_src_price_adjustment_id_tbl(i)
    AND draft_id = p_draft_id
    AND po_header_id = p_dest_po_header_id
    AND po_line_id = p_dest_po_line_id
    AND parent_adjustment_id IS NOT NULL; --Only child lines are considered

    l_progress := '120';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Check if the entire price structure is copied');
    END IF;

    IF (l_src_adj_count <> l_dest_adj_count OR l_src_attr_count <> l_dest_attr_count) THEN --OR l_src_asoc_count <> l_dest_asoc_count
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Copy Draft Line Adjustment failed with incomplete price structure');
        PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Adjustment Count: '||l_src_adj_count||', Destination Adjustment Count: '||l_dest_adj_count);
        --PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Association Count: '||l_src_asoc_count||', Destination Association Count: '||l_dest_asoc_count);
        PO_DEBUG.debug_stmt(l_log_head,l_progress,' Source Attribute Count: '||l_src_attr_count||', Destination Attribute Count: '||l_dest_attr_count);
      END IF;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status_text',x_return_status_text);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
    END IF;

  EXCEPTION
    WHEN COPYDOC_ADJUSTMENT_FAILURE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_return_status_text;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'EXITING COPY_DRAFT_LINE_ADJUSTMENTS with ERROR: '||l_return_status_text);
      END IF;
      ROLLBACK TO SAVEPOINT COPY_DRAFT_LINE_ADJUSTMENTS;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status_text := 'UnExpected ERROR IN COPY_DRAFT_LINE_ADJUSTMENTS. SQLERRM at '||l_progress||': '||SQLERRM;

      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, x_return_status_text);
      END IF;
      ROLLBACK TO SAVEPOINT COPY_DRAFT_LINE_ADJUSTMENTS;
  END copy_draft_line_adjustments;




  PROCEDURE insert_adj_rec(p_adj_rec IN PO_PRICE_ADJUSTMENTS%ROWTYPE)
  IS
  BEGIN
    INSERT INTO PO_PRICE_ADJUSTMENTS
      (PRICE_ADJUSTMENT_ID
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_LOGIN
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , REQUEST_ID
             , PO_HEADER_ID
             , AUTOMATIC_FLAG
             , PO_LINE_ID
             , ADJ_LINE_NUM
             , CONTEXT
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , ORIG_SYS_DISCOUNT_REF
             , LIST_HEADER_ID
             , LIST_LINE_ID
             , LIST_LINE_TYPE_CODE
             , MODIFIED_FROM
             , MODIFIED_TO
             , UPDATED_FLAG
             , UPDATE_ALLOWED
             , APPLIED_FLAG
             , CHANGE_REASON_CODE
             , CHANGE_REASON_TEXT
             , OPERAND
             , ARITHMETIC_OPERATOR
             , COST_ID
             , TAX_CODE
             , TAX_EXEMPT_FLAG
             , TAX_EXEMPT_NUMBER
             , TAX_EXEMPT_REASON_CODE
             , PARENT_ADJUSTMENT_ID
             , INVOICED_FLAG
             , ESTIMATED_FLAG
             , INC_IN_SALES_PERFORMANCE
             , ADJUSTED_AMOUNT
             , PRICING_PHASE_ID
             , CHARGE_TYPE_CODE
             , CHARGE_SUBTYPE_CODE
             , LIST_LINE_NO
             , SOURCE_SYSTEM_CODE
             , BENEFIT_QTY
             , BENEFIT_UOM_CODE
             , PRINT_ON_INVOICE_FLAG
             , EXPIRATION_DATE
             , REBATE_TRANSACTION_TYPE_CODE
             , REBATE_TRANSACTION_REFERENCE
             , REBATE_PAYMENT_SYSTEM_CODE
             , REDEEMED_DATE
             , REDEEMED_FLAG
             , ACCRUAL_FLAG
             , RANGE_BREAK_QUANTITY
             , ACCRUAL_CONVERSION_RATE
             , PRICING_GROUP_SEQUENCE
             , MODIFIER_LEVEL_CODE
             , PRICE_BREAK_TYPE_CODE
             , SUBSTITUTION_ATTRIBUTE
             , PRORATION_TYPE_CODE
             , CREDIT_OR_CHARGE_FLAG
             , INCLUDE_ON_RETURNS_FLAG
             , AC_CONTEXT
             , AC_ATTRIBUTE1
             , AC_ATTRIBUTE2
             , AC_ATTRIBUTE3
             , AC_ATTRIBUTE4
             , AC_ATTRIBUTE5
             , AC_ATTRIBUTE6
             , AC_ATTRIBUTE7
             , AC_ATTRIBUTE8
             , AC_ATTRIBUTE9
             , AC_ATTRIBUTE10
             , AC_ATTRIBUTE11
             , AC_ATTRIBUTE12
             , AC_ATTRIBUTE13
             , AC_ATTRIBUTE14
             , AC_ATTRIBUTE15
             , OPERAND_PER_PQTY
             , ADJUSTED_AMOUNT_PER_PQTY
             , LOCK_CONTROL
      )
      (SELECT  p_adj_rec.price_adjustment_id
             , p_adj_rec.creation_date
             , p_adj_rec.created_by
             , p_adj_rec.last_update_date
             , p_adj_rec.last_updated_by
             , p_adj_rec.last_update_login
             , p_adj_rec.program_application_id
             , p_adj_rec.program_id
             , p_adj_rec.program_update_date
             , p_adj_rec.request_id
             , p_adj_rec.po_header_id
             , p_adj_rec.automatic_flag
             , p_adj_rec.po_line_id
             , p_adj_rec.adj_line_num
             , p_adj_rec.context
             , p_adj_rec.attribute1
             , p_adj_rec.attribute2
             , p_adj_rec.attribute3
             , p_adj_rec.attribute4
             , p_adj_rec.attribute5
             , p_adj_rec.attribute6
             , p_adj_rec.attribute7
             , p_adj_rec.attribute8
             , p_adj_rec.attribute9
             , p_adj_rec.attribute10
             , p_adj_rec.attribute11
             , p_adj_rec.attribute12
             , p_adj_rec.attribute13
             , p_adj_rec.attribute14
             , p_adj_rec.attribute15
             , p_adj_rec.orig_sys_discount_ref
             , p_adj_rec.list_header_id
             , p_adj_rec.list_line_id
             , p_adj_rec.list_line_type_code
             , p_adj_rec.modified_from
             , p_adj_rec.modified_to
             , p_adj_rec.updated_flag
             , p_adj_rec.update_allowed
             , p_adj_rec.applied_flag
             , p_adj_rec.change_reason_code
             , p_adj_rec.change_reason_text
             , p_adj_rec.operand
             , p_adj_rec.arithmetic_operator
             , p_adj_rec.cost_id
             , p_adj_rec.tax_code
             , p_adj_rec.tax_exempt_flag
             , p_adj_rec.tax_exempt_number
             , p_adj_rec.tax_exempt_reason_code
             , p_adj_rec.parent_adjustment_id
             , p_adj_rec.invoiced_flag
             , p_adj_rec.estimated_flag
             , p_adj_rec.inc_in_sales_performance
             , p_adj_rec.adjusted_amount
             , p_adj_rec.pricing_phase_id
             , p_adj_rec.charge_type_code
             , p_adj_rec.charge_subtype_code
             , p_adj_rec.list_line_no
             , p_adj_rec.source_system_code
             , p_adj_rec.benefit_qty
             , p_adj_rec.benefit_uom_code
             , p_adj_rec.print_on_invoice_flag
             , p_adj_rec.expiration_date
             , p_adj_rec.rebate_transaction_type_code
             , p_adj_rec.rebate_transaction_reference
             , p_adj_rec.rebate_payment_system_code
             , p_adj_rec.redeemed_date
             , p_adj_rec.redeemed_flag
             , p_adj_rec.accrual_flag
             , p_adj_rec.range_break_quantity
             , p_adj_rec.accrual_conversion_rate
             , p_adj_rec.pricing_group_sequence
             , p_adj_rec.modifier_level_code
             , p_adj_rec.price_break_type_code
             , p_adj_rec.substitution_attribute
             , p_adj_rec.proration_type_code
             , p_adj_rec.credit_or_charge_flag
             , p_adj_rec.include_on_returns_flag
             , p_adj_rec.ac_context
             , p_adj_rec.ac_attribute1
             , p_adj_rec.ac_attribute2
             , p_adj_rec.ac_attribute3
             , p_adj_rec.ac_attribute4
             , p_adj_rec.ac_attribute5
             , p_adj_rec.ac_attribute6
             , p_adj_rec.ac_attribute7
             , p_adj_rec.ac_attribute8
             , p_adj_rec.ac_attribute9
             , p_adj_rec.ac_attribute10
             , p_adj_rec.ac_attribute11
             , p_adj_rec.ac_attribute12
             , p_adj_rec.ac_attribute13
             , p_adj_rec.ac_attribute14
             , p_adj_rec.ac_attribute15
             , p_adj_rec.operand_per_pqty
             , p_adj_rec.adjusted_amount_per_pqty
             , 1  -- LOCK_CONTROL
      FROM DUAL
      );
    --Exception will be caught by the calling procedure
  END insert_adj_rec;

  PROCEDURE insert_draft_adj_rec(p_draft_id IN NUMBER
                                ,p_adj_rec IN PO_PRICE_ADJUSTMENTS_V%ROWTYPE)
  IS
  BEGIN
    INSERT INTO PO_PRICE_ADJUSTMENTS_DRAFT
      (DRAFT_ID
             , CHANGE_ACCEPTED_FLAG
             , DELETE_FLAG
             , PRICE_ADJUSTMENT_ID
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_LOGIN
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , REQUEST_ID
             , PO_HEADER_ID
             , AUTOMATIC_FLAG
             , PO_LINE_ID
             , ADJ_LINE_NUM
             , CONTEXT
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , ORIG_SYS_DISCOUNT_REF
             , LIST_HEADER_ID
             , LIST_LINE_ID
             , LIST_LINE_TYPE_CODE
             , MODIFIED_FROM
             , MODIFIED_TO
             , UPDATED_FLAG
             , UPDATE_ALLOWED
             , APPLIED_FLAG
             , CHANGE_REASON_CODE
             , CHANGE_REASON_TEXT
             , OPERAND
             , ARITHMETIC_OPERATOR
             , COST_ID
             , TAX_CODE
             , TAX_EXEMPT_FLAG
             , TAX_EXEMPT_NUMBER
             , TAX_EXEMPT_REASON_CODE
             , PARENT_ADJUSTMENT_ID
             , INVOICED_FLAG
             , ESTIMATED_FLAG
             , INC_IN_SALES_PERFORMANCE
             , ADJUSTED_AMOUNT
             , PRICING_PHASE_ID
             , CHARGE_TYPE_CODE
             , CHARGE_SUBTYPE_CODE
             , LIST_LINE_NO
             , SOURCE_SYSTEM_CODE
             , BENEFIT_QTY
             , BENEFIT_UOM_CODE
             , PRINT_ON_INVOICE_FLAG
             , EXPIRATION_DATE
             , REBATE_TRANSACTION_TYPE_CODE
             , REBATE_TRANSACTION_REFERENCE
             , REBATE_PAYMENT_SYSTEM_CODE
             , REDEEMED_DATE
             , REDEEMED_FLAG
             , ACCRUAL_FLAG
             , RANGE_BREAK_QUANTITY
             , ACCRUAL_CONVERSION_RATE
             , PRICING_GROUP_SEQUENCE
             , MODIFIER_LEVEL_CODE
             , PRICE_BREAK_TYPE_CODE
             , SUBSTITUTION_ATTRIBUTE
             , PRORATION_TYPE_CODE
             , CREDIT_OR_CHARGE_FLAG
             , INCLUDE_ON_RETURNS_FLAG
             , AC_CONTEXT
             , AC_ATTRIBUTE1
             , AC_ATTRIBUTE2
             , AC_ATTRIBUTE3
             , AC_ATTRIBUTE4
             , AC_ATTRIBUTE5
             , AC_ATTRIBUTE6
             , AC_ATTRIBUTE7
             , AC_ATTRIBUTE8
             , AC_ATTRIBUTE9
             , AC_ATTRIBUTE10
             , AC_ATTRIBUTE11
             , AC_ATTRIBUTE12
             , AC_ATTRIBUTE13
             , AC_ATTRIBUTE14
             , AC_ATTRIBUTE15
             , OPERAND_PER_PQTY
             , ADJUSTED_AMOUNT_PER_PQTY
             , LOCK_CONTROL
      )
      (SELECT  p_draft_id
             , p_adj_rec.change_accepted_flag
             , p_adj_rec.delete_flag
             , p_adj_rec.price_adjustment_id
             , p_adj_rec.creation_date
             , p_adj_rec.created_by
             , p_adj_rec.last_update_date
             , p_adj_rec.last_updated_by
             , p_adj_rec.last_update_login
             , p_adj_rec.program_application_id
             , p_adj_rec.program_id
             , p_adj_rec.program_update_date
             , p_adj_rec.request_id
             , p_adj_rec.po_header_id
             , p_adj_rec.automatic_flag
             , p_adj_rec.po_line_id
             , p_adj_rec.adj_line_num
             , p_adj_rec.context
             , p_adj_rec.attribute1
             , p_adj_rec.attribute2
             , p_adj_rec.attribute3
             , p_adj_rec.attribute4
             , p_adj_rec.attribute5
             , p_adj_rec.attribute6
             , p_adj_rec.attribute7
             , p_adj_rec.attribute8
             , p_adj_rec.attribute9
             , p_adj_rec.attribute10
             , p_adj_rec.attribute11
             , p_adj_rec.attribute12
             , p_adj_rec.attribute13
             , p_adj_rec.attribute14
             , p_adj_rec.attribute15
             , p_adj_rec.orig_sys_discount_ref
             , p_adj_rec.list_header_id
             , p_adj_rec.list_line_id
             , p_adj_rec.list_line_type_code
             , p_adj_rec.modified_from
             , p_adj_rec.modified_to
             , p_adj_rec.updated_flag
             , p_adj_rec.update_allowed
             , p_adj_rec.applied_flag
             , p_adj_rec.change_reason_code
             , p_adj_rec.change_reason_text
             , p_adj_rec.operand
             , p_adj_rec.arithmetic_operator
             , p_adj_rec.cost_id
             , p_adj_rec.tax_code
             , p_adj_rec.tax_exempt_flag
             , p_adj_rec.tax_exempt_number
             , p_adj_rec.tax_exempt_reason_code
             , p_adj_rec.parent_adjustment_id
             , p_adj_rec.invoiced_flag
             , p_adj_rec.estimated_flag
             , p_adj_rec.inc_in_sales_performance
             , p_adj_rec.adjusted_amount
             , p_adj_rec.pricing_phase_id
             , p_adj_rec.charge_type_code
             , p_adj_rec.charge_subtype_code
             , p_adj_rec.list_line_no
             , p_adj_rec.source_system_code
             , p_adj_rec.benefit_qty
             , p_adj_rec.benefit_uom_code
             , p_adj_rec.print_on_invoice_flag
             , p_adj_rec.expiration_date
             , p_adj_rec.rebate_transaction_type_code
             , p_adj_rec.rebate_transaction_reference
             , p_adj_rec.rebate_payment_system_code
             , p_adj_rec.redeemed_date
             , p_adj_rec.redeemed_flag
             , p_adj_rec.accrual_flag
             , p_adj_rec.range_break_quantity
             , p_adj_rec.accrual_conversion_rate
             , p_adj_rec.pricing_group_sequence
             , p_adj_rec.modifier_level_code
             , p_adj_rec.price_break_type_code
             , p_adj_rec.substitution_attribute
             , p_adj_rec.proration_type_code
             , p_adj_rec.credit_or_charge_flag
             , p_adj_rec.include_on_returns_flag
             , p_adj_rec.ac_context
             , p_adj_rec.ac_attribute1
             , p_adj_rec.ac_attribute2
             , p_adj_rec.ac_attribute3
             , p_adj_rec.ac_attribute4
             , p_adj_rec.ac_attribute5
             , p_adj_rec.ac_attribute6
             , p_adj_rec.ac_attribute7
             , p_adj_rec.ac_attribute8
             , p_adj_rec.ac_attribute9
             , p_adj_rec.ac_attribute10
             , p_adj_rec.ac_attribute11
             , p_adj_rec.ac_attribute12
             , p_adj_rec.ac_attribute13
             , p_adj_rec.ac_attribute14
             , p_adj_rec.ac_attribute15
             , p_adj_rec.operand_per_pqty
             , p_adj_rec.adjusted_amount_per_pqty
             , 1  -- LOCK_CONTROL
      FROM DUAL
      );
    --Exception will be caught by the calling procedure
  END insert_draft_adj_rec;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_price_adjustments
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_ADJUSTMENTS, PO_PRICE_ADJ_ASSOCS, PO_PRICE_ADJ_ATTRIBS
--Locks:
--  None.
--Function:
--  Deletes the price adjustments of a PO/PO Line or GBPA/GBPA Line
--Parameters:
--IN:
--p_header_id
--  Unique Header Id of PO or GBPA
--p_line_id
--  Unique ID of PO Line or GBPA Line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  PROCEDURE delete_price_adjustments
    ( p_po_header_id IN PO_PRICE_ADJUSTMENTS.po_header_id%TYPE
    , p_po_line_id IN PO_PRICE_ADJUSTMENTS.po_line_id%TYPE DEFAULT NULL
    )
  IS
    l_price_adj_tbl NUMBER_TYPE;
  BEGIN

    --Delete Price Adjustments
    DELETE FROM PO_PRICE_ADJUSTMENTS
    WHERE po_header_id = p_po_header_id
    AND (po_line_id = p_po_line_id OR p_po_line_id IS NULL)
    RETURNING
      price_adjustment_id
    BULK COLLECT INTO
      l_price_adj_tbl;

    IF l_price_adj_tbl.count > 0 THEN
      /*
      --Delete Price Adjustment Associations
      FORALL i IN l_price_adj_tbl.FIRST..l_price_adj_tbl.LAST
      DELETE FROM PO_PRICE_ADJ_ASSOCS WHERE price_adjustment_id = l_price_adj_tbl(i);
      */

      --Delete Price Adjustment Attributes
      FORALL i IN l_price_adj_tbl.FIRST..l_price_adj_tbl.LAST
      DELETE FROM PO_PRICE_ADJ_ATTRIBS WHERE price_adjustment_id = l_price_adj_tbl(i);
    END IF;

    /*
    --Delete dependant fields first
    --Delete Price Adjustment Attributes
    DELETE FROM PO_PRICE_ADJ_ATTRIBS ATTR
    WHERE ATTR.price_adjustment_id IN (SELECT ADJ.price_adjustment_id
                                       FROM PO_PRICE_ADJUSTMENTS ADJ
                                       WHERE ADJ.header_id = p_header_id
                                       AND ADJ.line_id = p_line_id);

    --Delete Price Adjustment Associations
    DELETE FROM PO_PRICE_ADJ_ASSOCS ASOC
    WHERE ASOC.line_id = p_line_id;

    --Delete Price Adjustments
    DELETE FROM PO_PRICE_ADJUSTMENTS ADJ
    WHERE ADJ.header_id = p_header_id
    AND ADJ.line_id = p_line_id;
    */

  EXCEPTION
    WHEN OTHERS THEN
      PO_MESSAGE_S.sql_error('PO_PRICE_ADJUSTMENTS_PKG.delete_price_adjustments','000',sqlcode);
      RAISE;
  END delete_price_adjustments;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_adjustment
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_ADJUSTMENTS, PO_PRICE_ADJ_ASSOCS, PO_PRICE_ADJ_ATTRIBS
--Locks:
--  None.
--Function:
--  Deletes the price adjustments of a PO Line or GBPA Line
--Parameters:
--IN:
--p_price_adjustment_id
--  Unique ID of Price Adjustment
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  PROCEDURE delete_adjustment
    ( p_price_adjustment_id IN PO_PRICE_ADJUSTMENTS.price_adjustment_id%TYPE )
  IS
  BEGIN
    --Delete dependant fields first
    --Delete Price Adjustment Attributes
    DELETE FROM PO_PRICE_ADJ_ATTRIBS ATTR
    WHERE ATTR.price_adjustment_id = p_price_adjustment_id;
    /*
    --Delete Price Adjustment Associations
    DELETE FROM PO_PRICE_ADJ_ASSOCS ASOC
    WHERE ASOC.price_adjustment_id = p_price_adjustment_id;
    */
    /*
    --Delete Related Price Adjustment Associations
    DELETE FROM PO_PRICE_ADJ_ASSOCS ASOC
    WHERE ASOC.rltd_price_adj_id = p_price_adjustment_id;
    */
    --Delete Price Adjustments
    DELETE FROM PO_PRICE_ADJUSTMENTS ADJ
    WHERE ADJ.price_adjustment_id = p_price_adjustment_id;
  EXCEPTION
    WHEN OTHERS THEN
      PO_MESSAGE_S.sql_error('PO_PRICE_ADJUSTMENTS_PKG.delete_adjustment','000',sqlcode);
      RAISE;
  END delete_adjustment;

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_adjustment_dependants
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_ADJ_ASSOCS, PO_PRICE_ADJ_ATTRIBS
--Locks:
--  None.
--Function:
--  Deletes the price adjustments dependants of a PO Line or GBPA Line
--Parameters:
--IN:
--p_price_adjustment_id
--  Unique ID of Price Adjustment
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  PROCEDURE delete_adjustment_dependants
    ( p_draft_id IN PO_PRICE_ADJUSTMENTS_DRAFT.draft_id%TYPE
    , p_price_adjustment_id IN PO_PRICE_ADJUSTMENTS_DRAFT.price_adjustment_id%TYPE )
  IS
  BEGIN
    --Delete dependant fields first
    --Delete Price Adjustment Attributes
    DELETE FROM PO_PRICE_ADJ_ATTRIBS_DRAFT ATTR
    WHERE ATTR.draft_id = p_draft_id
    AND   ATTR.price_adjustment_id IN  (SELECT p_price_adjustment_id FROM DUAL
                                        UNION
                                        SELECT ASOC.rltd_price_adj_id
                                        FROM PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
                                        WHERE ASOC.price_adjustment_id = p_price_adjustment_id);

    DELETE FROM PO_PRICE_ADJUSTMENTS_DRAFT ADJ
    WHERE ADJ.draft_id = p_draft_id
    AND   ADJ.price_adjustment_id IN  (SELECT ASOC.rltd_price_adj_id
                                       FROM PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
                                       WHERE ASOC.price_adjustment_id = p_price_adjustment_id);

    --Delete Price Adjustment Associations
    DELETE FROM PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
    WHERE ASOC.draft_id = p_draft_id
    AND   ASOC.price_adjustment_id = p_price_adjustment_id;

    --Delete Related Price Adjustment Associations
    DELETE FROM PO_PRICE_ADJ_ASSOCS_DRAFT ASOC
    WHERE ASOC.draft_id = p_draft_id
    AND   ASOC.rltd_price_adj_id = p_price_adjustment_id;

  EXCEPTION
    WHEN OTHERS THEN
      PO_MESSAGE_S.sql_error('PO_PRICE_ADJUSTMENTS_PKG.delete_adjustment_dependants','000',sqlcode);
      RAISE;
  END delete_adjustment_dependants;
*/

END PO_PRICE_ADJUSTMENTS_PKG;

/
