--------------------------------------------------------
--  DDL for Package Body PO_PRICE_ADJ_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_ADJ_DRAFT_PKG" AS
/* $Header: PO_PRICE_ADJ_DRAFT_PKG.plb 120.0.12010000.1 2009/06/01 23:30:02 ababujan noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_PRICE_ADJ_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for price adjustments based on the information given
--  If only draft_id is provided, then all price adjustments for the draft
--  will be deleted
--  If price_adjustment_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_price_adjustment_id
--  po price adjustment unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_price_adjustment_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_price_adj_attribs_draft
  WHERE draft_id = p_draft_id
  AND price_adjustment_id = NVL(p_price_adjustment_id, price_adjustment_id);

  DELETE FROM po_price_adjustments_draft
  WHERE draft_id = p_draft_id
  AND price_adjustment_id = NVL(p_price_adjustment_id, price_adjustment_id);

  d_position := 10;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_rows;

-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Copy data from transaction table to draft table, if the corresponding
--  record in draft table does not exist. It also sets the delete flag of
--  the draft record according to the parameter.
--Parameters:
--IN:
--p_price_adjustment_id_tbl
--  table of po price_adjustment unique identifier
--p_draft_id_tbl
--  table of draft ids this sync up will be done for
--p_delete_flag_tbl
--  table fo flags to indicate whether the draft record should be maked as
--  "to be deleted"
--IN OUT:
--OUT:
--x_record_already_exist_tbl
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_price_adjustment_id_tbl  IN PO_TBL_NUMBER,
  p_draft_id_tbl             IN PO_TBL_NUMBER,
  p_delete_flag_tbl          IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_distinct_id_list DBMS_SQL.NUMBER_TABLE;
l_duplicate_flag_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_record_already_exist_tbl :=
    PO_PRICE_ADJ_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_price_adjustment_id_tbl => p_price_adjustment_id_tbl
    );

  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_price_adjustment_id_tbl.COUNT);

  FOR i IN 1..p_price_adjustment_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_price_adjustment_id_tbl(i))) THEN
        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;
        l_distinct_id_list(p_price_adjustment_id_tbl(i)) := 1;
      END IF;
    ELSE
      l_duplicate_flag_tbl(i) := NULL;
    END IF;
  END LOOP;

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer records from txn to dft');
  END IF;

  FORALL i IN 1..p_price_adjustment_id_tbl.COUNT
    INSERT INTO PO_PRICE_ADJUSTMENTS_DRAFT
      (DRAFT_ID
         , DELETE_FLAG
         , CHANGE_ACCEPTED_FLAG
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
    SELECT p_draft_id_tbl(i)
         , p_delete_flag_tbl(i)
         , NULL
         , ADJ.price_adjustment_id
         , ADJ.adj_line_num
         , ADJ.creation_date
         , ADJ.created_by
         , ADJ.last_update_date
         , ADJ.last_updated_by
         , ADJ.last_update_login
         , ADJ.program_application_id
         , ADJ.program_id
         , ADJ.program_update_date
         , ADJ.request_id
         , ADJ.po_header_id
         , ADJ.automatic_flag
         , ADJ.po_line_id
         , ADJ.context
         , ADJ.attribute1
         , ADJ.attribute2
         , ADJ.attribute3
         , ADJ.attribute4
         , ADJ.attribute5
         , ADJ.attribute6
         , ADJ.attribute7
         , ADJ.attribute8
         , ADJ.attribute9
         , ADJ.attribute10
         , ADJ.attribute11
         , ADJ.attribute12
         , ADJ.attribute13
         , ADJ.attribute14
         , ADJ.attribute15
         , ADJ.orig_sys_discount_ref
         , ADJ.list_header_id
         , ADJ.list_line_id
         , ADJ.list_line_type_code
         , ADJ.modified_from
         , ADJ.modified_to
         , ADJ.updated_flag
         , ADJ.update_allowed
         , ADJ.applied_flag
         , ADJ.change_reason_code
         , ADJ.change_reason_text
         , ADJ.operand
         , ADJ.arithmetic_operator
         , ADJ.cost_id
         , ADJ.tax_code
         , ADJ.tax_exempt_flag
         , ADJ.tax_exempt_number
         , ADJ.tax_exempt_reason_code
         , ADJ.parent_adjustment_id
         , ADJ.invoiced_flag
         , ADJ.estimated_flag
         , ADJ.inc_in_sales_performance
         , ADJ.adjusted_amount
         , ADJ.pricing_phase_id
         , ADJ.charge_type_code
         , ADJ.charge_subtype_code
         , ADJ.list_line_no
         , ADJ.source_system_code
         , ADJ.benefit_qty
         , ADJ.benefit_uom_code
         , ADJ.print_on_invoice_flag
         , ADJ.expiration_date
         , ADJ.rebate_transaction_type_code
         , ADJ.rebate_transaction_reference
         , ADJ.rebate_payment_system_code
         , ADJ.redeemed_date
         , ADJ.redeemed_flag
         , ADJ.accrual_flag
         , ADJ.range_break_quantity
         , ADJ.accrual_conversion_rate
         , ADJ.pricing_group_sequence
         , ADJ.modifier_level_code
         , ADJ.price_break_type_code
         , ADJ.substitution_attribute
         , ADJ.proration_type_code
         , ADJ.credit_or_charge_flag
         , ADJ.include_on_returns_flag
         , ADJ.ac_context
         , ADJ.ac_attribute1
         , ADJ.ac_attribute2
         , ADJ.ac_attribute3
         , ADJ.ac_attribute4
         , ADJ.ac_attribute5
         , ADJ.ac_attribute6
         , ADJ.ac_attribute7
         , ADJ.ac_attribute8
         , ADJ.ac_attribute9
         , ADJ.ac_attribute10
         , ADJ.ac_attribute11
         , ADJ.ac_attribute12
         , ADJ.ac_attribute13
         , ADJ.ac_attribute14
         , ADJ.ac_attribute15
         , ADJ.operand_per_pqty
         , ADJ.adjusted_amount_per_pqty
         , 1
    FROM PO_PRICE_ADJUSTMENTS ADJ
    WHERE ADJ.price_adjustment_id = p_price_adjustment_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_price_adjustment_id_tbl.COUNT
    UPDATE po_price_adjustments_draft
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  (price_adjustment_id = p_price_adjustment_id_tbl(i)
            OR parent_adjustment_id = p_price_adjustment_id_tbl(i))
    AND    draft_id = p_draft_id_tbl(i)
    AND    NVL(delete_flag, 'N') <> 'Y'
    AND    x_record_already_exist_tbl(i) = FND_API.G_TRUE;

  d_position := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'update draft records that are already' ||
                ' in draft table. Count = ' || SQL%ROWCOUNT);
  END IF;

  --No Need to update the price adjustment attributes if already found in draft table
  FORALL i IN 1..p_price_adjustment_id_tbl.COUNT
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
    SELECT p_draft_id_tbl(i)
         , ATTR.price_adjustment_id
         , ATTR.pricing_context
         , ATTR.pricing_attribute
         , ATTR.creation_date
         , ATTR.created_by
         , ATTR.last_update_date
         , ATTR.last_updated_by
         , ATTR.last_update_login
         , ATTR.program_application_id
         , ATTR.program_id
         , ATTR.program_update_date
         , ATTR.request_id
         , ATTR.pricing_attr_value_from
         , ATTR.pricing_attr_value_to
         , ATTR.comparison_operator
         , ATTR.flex_title
         , ATTR.price_adj_attrib_id
         , 1
    FROM PO_PRICE_ADJ_ATTRIBS ATTR
    WHERE ATTR.price_adjustment_id = p_price_adjustment_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 40;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Attribute records transfer count = ' || SQL%ROWCOUNT);
  END IF;

  d_position := 50;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;

-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Same functionality as the bulk version of this procedure
--Parameters:
--IN:
--p_price_adjustment_id
--  price adjustment unique identifier
--p_draft_id
--  the draft this sync up will be done for
--p_delete_flag
--  flag to indicate whether the draft record should be maked as "to be
--  deleted"
--IN OUT:
--OUT:
--x_record_already_exist
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_price_adjustment_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_delete_flag IN VARCHAR2,
  x_record_already_exist OUT NOCOPY VARCHAR2
) IS
--
  d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
  d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_record_already_exist_tbl PO_TBL_VARCHAR1;
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_price_adjustment_id', p_price_adjustment_id);
  END IF;

  sync_draft_from_txn
  ( p_price_adjustment_id_tbl  => PO_TBL_NUMBER(p_price_adjustment_id),
    p_draft_id_tbl             => PO_TBL_NUMBER(p_draft_id),
    p_delete_flag_tbl          => PO_TBL_VARCHAR1(p_delete_flag),
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );

  x_record_already_exist := l_record_already_exist_tbl(1);

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
    PO_LOG.proc_end(d_module, 'x_record_already_exist', x_record_already_exist);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;


-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Same functionality as the bulk version of this procedure
--Parameters:
--IN:
--p_draft_id
--  this sync up will be done for
--p_order_line_id
--  po line unique identifier
--IN OUT:
--OUT:

--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_draft_id IN NUMBER,
  p_order_header_id NUMBER,
  p_order_line_id IN NUMBER,
  p_delete_flag IN VARCHAR2
  --x_record_already_exist OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_record_already_exist_tbl PO_TBL_VARCHAR1;
l_price_adjustment_id_tbl  PO_TBL_NUMBER;
l_draft_id_tbl PO_TBL_NUMBER;
l_delete_flag_tbl PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin(d_module, 'p_order_header_id', p_order_header_id);
    PO_LOG.proc_begin(d_module, 'p_order_line_id', p_order_line_id);
    PO_LOG.proc_begin(d_module, 'p_delete_flag', p_delete_flag);
  END IF;

  --Get all price_adjustment_ids under the order line id
  SELECT ADJ.price_adjustment_id
        ,p_draft_id
        ,p_delete_flag
  BULK COLLECT INTO l_price_adjustment_id_tbl
                   ,l_draft_id_tbl
                   ,l_delete_flag_tbl
  FROM po_price_adjustments ADJ
  WHERE ADJ.po_header_id = p_order_header_id
  AND ADJ.po_line_id = NVL(p_order_line_id, ADJ.po_line_id);

  sync_draft_from_txn
  ( p_price_adjustment_id_tbl  => l_price_adjustment_id_tbl,
    p_draft_id_tbl             => l_draft_id_tbl,
    p_delete_flag_tbl          => l_delete_flag_tbl,
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );
  --x_record_already_exist := l_record_already_exist_tbl(1);

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
    --PO_LOG.proc_end(d_module, 'x_record_already_exist', x_record_already_exist);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Merge the records in draft table to transaction table
--  Either insert, update or delete will be performed on top of transaction
--  table, depending on the delete_flag on the draft record and whether the
--  record already exists in transaction table
--
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_changes
( p_draft_id IN NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'merge_changes';
  d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_price_adjustment_id_tbl NUMBER_TYPE;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Since putting DELETE within MERGE statement is causing database
  -- to thrown internal error, for now we just separate the DELETE statement.
  -- Once this is fixed we'll move the delete statement back to the merge
  -- statement

  -- Delete only records that have not been rejected
  DELETE FROM po_price_adjustments ADJ
  WHERE ADJ.price_adjustment_id IN
         ( SELECT ADJD.price_adjustment_id
           FROM   po_price_adjustments_draft ADJD
           WHERE  ADJD.draft_id = p_draft_id
           AND    ADJD.delete_flag = 'Y'
           AND    NVL(ADJD.change_accepted_flag, 'Y') = 'Y')
  RETURNING ADJ.price_adjustment_id BULK COLLECT INTO l_price_adjustment_id_tbl;

/*
  --Set the Delete Flag to Y for the child price break lines if the price break header is marked for deletion
  UPDATE po_price_adjustments_draft ADJD
  SET delete_flag = 'Y'
  WHERE EXISTS (SELECT 1
                FROM po_price_adjustments_draft DADJD
                WHERE DADJD.price_adjustment_id = ADJD.parent_adjustment_id
                AND DADJD.delete_flag = 'Y');
*/
  --Delete Child adjustment lines
  FORALL i IN l_price_adjustment_id_tbl.FIRST .. l_price_adjustment_id_tbl.LAST
  DELETE FROM po_price_adjustments ADJ
  WHERE ADJ.parent_adjustment_id = l_price_adjustment_id_tbl(i);

  --Delete the attributes corresponding to the lines that are marked for deletion
  DELETE FROM po_price_adj_attribs ATTR
  WHERE ATTR.price_adjustment_id IN
         (SELECT ADJD.price_adjustment_id
          FROM   po_price_adjustments_draft ADJD
          WHERE  ADJD.draft_id = p_draft_id
          --AND    ADJD.delete_flag = 'Y'  --delete all attributes irrespective of the flag
          AND    NVL(ADJD.change_accepted_flag, 'Y') = 'Y');

  MERGE INTO po_price_adjustments ADJ
  USING (
    SELECT DFT.draft_id
         , DFT.change_accepted_flag
         , DFT.delete_flag
         , DFT.price_adjustment_id
         , DFT.adj_line_num
         , DFT.creation_date
         , DFT.created_by
         , DFT.last_update_date
         , DFT.last_updated_by
         , DFT.last_update_login
         , DFT.program_application_id
         , DFT.program_id
         , DFT.program_update_date
         , DFT.request_id
         , DFT.po_header_id
         , DFT.automatic_flag
         , DFT.po_line_id
         , DFT.context
         , DFT.attribute1
         , DFT.attribute2
         , DFT.attribute3
         , DFT.attribute4
         , DFT.attribute5
         , DFT.attribute6
         , DFT.attribute7
         , DFT.attribute8
         , DFT.attribute9
         , DFT.attribute10
         , DFT.attribute11
         , DFT.attribute12
         , DFT.attribute13
         , DFT.attribute14
         , DFT.attribute15
         , DFT.orig_sys_discount_ref
         , DFT.list_header_id
         , DFT.list_line_id
         , DFT.list_line_type_code
         , DFT.modified_from
         , DFT.modified_to
         , DFT.updated_flag
         , DFT.update_allowed
         , DFT.applied_flag
         , DFT.change_reason_code
         , DFT.change_reason_text
         , DFT.operand
         , DFT.arithmetic_operator
         , DFT.cost_id
         , DFT.tax_code
         , DFT.tax_exempt_flag
         , DFT.tax_exempt_number
         , DFT.tax_exempt_reason_code
         , DFT.parent_adjustment_id
         , DFT.invoiced_flag
         , DFT.estimated_flag
         , DFT.inc_in_sales_performance
         , DFT.adjusted_amount
         , DFT.pricing_phase_id
         , DFT.charge_type_code
         , DFT.charge_subtype_code
         , DFT.list_line_no
         , DFT.source_system_code
         , DFT.benefit_qty
         , DFT.benefit_uom_code
         , DFT.print_on_invoice_flag
         , DFT.expiration_date
         , DFT.rebate_transaction_type_code
         , DFT.rebate_transaction_reference
         , DFT.rebate_payment_system_code
         , DFT.redeemed_date
         , DFT.redeemed_flag
         , DFT.accrual_flag
         , DFT.range_break_quantity
         , DFT.accrual_conversion_rate
         , DFT.pricing_group_sequence
         , DFT.modifier_level_code
         , DFT.price_break_type_code
         , DFT.substitution_attribute
         , DFT.proration_type_code
         , DFT.credit_or_charge_flag
         , DFT.include_on_returns_flag
         , DFT.ac_context
         , DFT.ac_attribute1
         , DFT.ac_attribute2
         , DFT.ac_attribute3
         , DFT.ac_attribute4
         , DFT.ac_attribute5
         , DFT.ac_attribute6
         , DFT.ac_attribute7
         , DFT.ac_attribute8
         , DFT.ac_attribute9
         , DFT.ac_attribute10
         , DFT.ac_attribute11
         , DFT.ac_attribute12
         , DFT.ac_attribute13
         , DFT.ac_attribute14
         , DFT.ac_attribute15
         , DFT.operand_per_pqty
         , DFT.adjusted_amount_per_pqty
    FROM po_price_adjustments_draft DFT
    WHERE DFT.draft_id = p_draft_id
    AND NVL(DFT.change_accepted_flag, 'Y') = 'Y') ADJD
    ON (ADJ.price_adjustment_id = ADJD.price_adjustment_id)
  WHEN MATCHED THEN
    UPDATE
      SET  ADJ.last_update_date  = ADJD.last_update_date
         , ADJ.last_updated_by = ADJD.last_updated_by
         , ADJ.last_update_login = ADJD.last_update_login
         , ADJ.program_application_id = ADJD.program_application_id
         , ADJ.program_id = ADJD.program_id
         , ADJ.program_update_date = ADJD.program_update_date
         , ADJ.request_id = ADJD.request_id
         , ADJ.adj_line_num = ADJD.adj_line_num
         , ADJ.po_header_id = ADJD.po_header_id
         , ADJ.automatic_flag = ADJD.automatic_flag
         , ADJ.po_line_id = ADJD.po_line_id
         , ADJ.context = ADJD.context
         , ADJ.attribute1 = ADJD.attribute1
         , ADJ.attribute2 = ADJD.attribute2
         , ADJ.attribute3 = ADJD.attribute3
         , ADJ.attribute4 = ADJD.attribute4
         , ADJ.attribute5 = ADJD.attribute5
         , ADJ.attribute6 = ADJD.attribute6
         , ADJ.attribute7 = ADJD.attribute7
         , ADJ.attribute8 = ADJD.attribute8
         , ADJ.attribute9 = ADJD.attribute9
         , ADJ.attribute10 = ADJD.attribute10
         , ADJ.attribute11 = ADJD.attribute11
         , ADJ.attribute12 = ADJD.attribute12
         , ADJ.attribute13 = ADJD.attribute13
         , ADJ.attribute14 = ADJD.attribute14
         , ADJ.attribute15 = ADJD.attribute15
         , ADJ.orig_sys_discount_ref = ADJD.orig_sys_discount_ref
         , ADJ.list_header_id = ADJD.list_header_id
         , ADJ.list_line_id = ADJD.list_line_id
         , ADJ.list_line_type_code = ADJD.list_line_type_code
         , ADJ.modified_from = ADJD.modified_from
         , ADJ.modified_to = ADJD.modified_to
         , ADJ.updated_flag = ADJD.updated_flag
         , ADJ.update_allowed = ADJD.update_allowed
         , ADJ.applied_flag = ADJD.applied_flag
         , ADJ.change_reason_code = ADJD.change_reason_code
         , ADJ.change_reason_text = ADJD.change_reason_text
         , ADJ.operand = ADJD.operand
         , ADJ.arithmetic_operator = ADJD.arithmetic_operator
         , ADJ.cost_id = ADJD.cost_id
         , ADJ.tax_code   = ADJD.tax_code
         , ADJ.tax_exempt_flag = ADJD.tax_exempt_flag
         , ADJ.tax_exempt_number = ADJD.tax_exempt_number
         , ADJ.tax_exempt_reason_code = ADJD.tax_exempt_reason_code
         , ADJ.parent_adjustment_id = ADJD.parent_adjustment_id
         , ADJ.invoiced_flag = ADJD.invoiced_flag
         , ADJ.estimated_flag = ADJD.estimated_flag
         , ADJ.inc_in_sales_performance  = ADJD.inc_in_sales_performance
         , ADJ.adjusted_amount = ADJD.adjusted_amount
         , ADJ.pricing_phase_id  = ADJD.pricing_phase_id
         , ADJ.charge_type_code  = ADJD.charge_type_code
         , ADJ.charge_subtype_code = ADJD.charge_subtype_code
         , ADJ.list_line_no = ADJD.list_line_no
         , ADJ.source_system_code = ADJD.source_system_code
         , ADJ.benefit_qty = ADJD.benefit_qty
         , ADJ.benefit_uom_code  = ADJD.benefit_uom_code
         , ADJ.print_on_invoice_flag = ADJD.print_on_invoice_flag
         , ADJ.expiration_date = ADJD.expiration_date
         , ADJ.rebate_transaction_type_code = ADJD.rebate_transaction_type_code
         , ADJ.rebate_transaction_reference = ADJD.rebate_transaction_reference
         , ADJ.rebate_payment_system_code = ADJD.rebate_payment_system_code
         , ADJ.redeemed_date = ADJD.redeemed_date
         , ADJ.redeemed_flag = ADJD.redeemed_flag
         , ADJ.accrual_flag = ADJD.accrual_flag
         , ADJ.range_break_quantity = ADJD.range_break_quantity
         , ADJ.accrual_conversion_rate = ADJD.accrual_conversion_rate
         , ADJ.pricing_group_sequence = ADJD.pricing_group_sequence
         , ADJ.modifier_level_code = ADJD.modifier_level_code
         , ADJ.price_break_type_code = ADJD.price_break_type_code
         , ADJ.substitution_attribute = ADJD.substitution_attribute
         , ADJ.proration_type_code = ADJD.proration_type_code
         , ADJ.credit_or_charge_flag = ADJD.credit_or_charge_flag
         , ADJ.include_on_returns_flag = ADJD.include_on_returns_flag
         , ADJ.ac_context = ADJD.ac_context
         , ADJ.ac_attribute1 = ADJD.ac_attribute1
         , ADJ.ac_attribute2 = ADJD.ac_attribute2
         , ADJ.ac_attribute3 = ADJD.ac_attribute3
         , ADJ.ac_attribute4 = ADJD.ac_attribute4
         , ADJ.ac_attribute5 = ADJD.ac_attribute5
         , ADJ.ac_attribute6 = ADJD.ac_attribute6
         , ADJ.ac_attribute7 = ADJD.ac_attribute7
         , ADJ.ac_attribute8 = ADJD.ac_attribute8
         , ADJ.ac_attribute9 = ADJD.ac_attribute9
         , ADJ.ac_attribute10 = ADJD.ac_attribute10
         , ADJ.ac_attribute11 = ADJD.ac_attribute11
         , ADJ.ac_attribute12 = ADJD.ac_attribute12
         , ADJ.ac_attribute13 = ADJD.ac_attribute13
         , ADJ.ac_attribute14 = ADJD.ac_attribute14
         , ADJ.ac_attribute15 = ADJD.ac_attribute15
         , ADJ.operand_per_pqty  = ADJD.operand_per_pqty
         , ADJ.adjusted_amount_per_pqty  = ADJD.adjusted_amount_per_pqty
         , ADJ.lock_control = ADJ.lock_control + 1
  WHEN NOT MATCHED THEN
    INSERT
         ( PRICE_ADJUSTMENT_ID
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
    VALUES
         ( ADJD.price_adjustment_id
         , ADJD.adj_line_num
         , ADJD.creation_date
         , ADJD.created_by
         , ADJD.last_update_date
         , ADJD.last_updated_by
         , ADJD.last_update_login
         , ADJD.program_application_id
         , ADJD.program_id
         , ADJD.program_update_date
         , ADJD.request_id
         , ADJD.po_header_id
         , ADJD.automatic_flag
         , ADJD.po_line_id
         , ADJD.context
         , ADJD.attribute1
         , ADJD.attribute2
         , ADJD.attribute3
         , ADJD.attribute4
         , ADJD.attribute5
         , ADJD.attribute6
         , ADJD.attribute7
         , ADJD.attribute8
         , ADJD.attribute9
         , ADJD.attribute10
         , ADJD.attribute11
         , ADJD.attribute12
         , ADJD.attribute13
         , ADJD.attribute14
         , ADJD.attribute15
         , ADJD.orig_sys_discount_ref
         , ADJD.list_header_id
         , ADJD.list_line_id
         , ADJD.list_line_type_code
         , ADJD.modified_from
         , ADJD.modified_to
         , ADJD.updated_flag
         , ADJD.update_allowed
         , ADJD.applied_flag
         , ADJD.change_reason_code
         , ADJD.change_reason_text
         , ADJD.operand
         , ADJD.arithmetic_operator
         , ADJD.cost_id
         , ADJD.tax_code
         , ADJD.tax_exempt_flag
         , ADJD.tax_exempt_number
         , ADJD.tax_exempt_reason_code
         , ADJD.parent_adjustment_id
         , ADJD.invoiced_flag
         , ADJD.estimated_flag
         , ADJD.inc_in_sales_performance
         , ADJD.adjusted_amount
         , ADJD.pricing_phase_id
         , ADJD.charge_type_code
         , ADJD.charge_subtype_code
         , ADJD.list_line_no
         , ADJD.source_system_code
         , ADJD.benefit_qty
         , ADJD.benefit_uom_code
         , ADJD.print_on_invoice_flag
         , ADJD.expiration_date
         , ADJD.rebate_transaction_type_code
         , ADJD.rebate_transaction_reference
         , ADJD.rebate_payment_system_code
         , ADJD.redeemed_date
         , ADJD.redeemed_flag
         , ADJD.accrual_flag
         , ADJD.range_break_quantity
         , ADJD.accrual_conversion_rate
         , ADJD.pricing_group_sequence
         , ADJD.modifier_level_code
         , ADJD.price_break_type_code
         , ADJD.substitution_attribute
         , ADJD.proration_type_code
         , ADJD.credit_or_charge_flag
         , ADJD.include_on_returns_flag
         , ADJD.ac_context
         , ADJD.ac_attribute1
         , ADJD.ac_attribute2
         , ADJD.ac_attribute3
         , ADJD.ac_attribute4
         , ADJD.ac_attribute5
         , ADJD.ac_attribute6
         , ADJD.ac_attribute7
         , ADJD.ac_attribute8
         , ADJD.ac_attribute9
         , ADJD.ac_attribute10
         , ADJD.ac_attribute11
         , ADJD.ac_attribute12
         , ADJD.ac_attribute13
         , ADJD.ac_attribute14
         , ADJD.ac_attribute15
         , ADJD.operand_per_pqty
         , ADJD.adjusted_amount_per_pqty
         , 1
         )
    WHERE NVL(ADJD.delete_flag, 'N') <> 'Y';

  INSERT INTO po_price_adj_attribs
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
  SELECT ATTR.price_adjustment_id
       , ATTR.pricing_context
       , ATTR.pricing_attribute
       , ATTR.creation_date
       , ATTR.created_by
       , ATTR.last_update_date
       , ATTR.last_updated_by
       , ATTR.last_update_login
       , ATTR.program_application_id
       , ATTR.program_id
       , ATTR.program_update_date
       , ATTR.request_id
       , ATTR.pricing_attr_value_from
       , ATTR.pricing_attr_value_to
       , ATTR.comparison_operator
       , ATTR.flex_title
       , ATTR.price_adj_attrib_id
       , 1
  FROM po_price_adj_attribs_draft ATTR
      ,po_price_adjustments_draft ADJD
  WHERE ADJD.draft_id = p_draft_id
  AND ADJD.draft_id = ATTR.draft_id
  AND ADJD.price_adjustment_id = ATTR.price_adjustment_id
  AND NVL(ADJD.delete_flag, 'N') <> 'Y'
  AND NVL(ADJD.change_accepted_flag, 'Y') = 'Y';

  d_position := 40;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Attribute records transfer count = ' || SQL%ROWCOUNT);
  END IF;

  d_position := 50;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END merge_changes;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_draft_record
--Function:
--  Obtain database lock for the record in draft table
--Parameters:
--IN:
--p_price_adjustment_id
--  id for po price adjustments record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_price_adjustment_id IN NUMBER,
  p_draft_id        IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_draft_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_price_adjustments_draft
  WHERE price_adjustment_id = p_price_adjustment_id
  AND draft_id = p_draft_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_draft_record;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_transaction_record
--Function:
--  Obtain database lock for the record in transaction table
--Parameters:
--IN:
--p_price_adjustment_id
--  id for price adjustment record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_price_adjustment_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_transaction_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_price_adjustments
  WHERE price_adjustment_id = p_price_adjustment_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_PRICE_ADJ_DRAFT_PKG;

/
