--------------------------------------------------------
--  DDL for Package Body QP_PRICE_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_BOOK_PVT" AS
/* $Header: QPXVGPBB.pls 120.76.12010000.7 2009/09/25 07:17:24 dnema ship $*/

--Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'qp_price_book_pvt';

/*****************************************************************************
 Internal API to create Delta Price Book
*****************************************************************************/
PROCEDURE Create_Delta_Price_Book(p_delta_price_book_header_id    IN NUMBER,
                                  p_delta_price_book_name         IN VARCHAR2,
                                  p_delta_price_book_customer_id  IN NUMBER)
IS
CURSOR unchanged_lines_cur(a_price_book_header_id NUMBER)
IS
  SELECT price_book_line_id
  FROM   qp_price_book_lines
  WHERE  sync_action_code = 'N'
  AND    price_book_header_id = a_price_book_header_id;

l_user_id               NUMBER;
l_login_id              NUMBER;

l_unchanged_line_id_tbl NUMBER_TYPE;
l_deleted_line_id_tbl NUMBER_TYPE;
l_new_deleted_line_id_tbl NUMBER_TYPE;
l_item_number_tbl       NUMBER_TYPE;
l_uom_code_tbl    VARCHAR3_TYPE;
l_list_price_tbl        NUMBER_TYPE;
l_net_price_tbl       NUMBER_TYPE;
l_line_status_code_tbl  FLAG_TYPE;

l_full_price_book_header_id   NUMBER;

CURSOR deleted_lines_cur(a_full_price_book_header_id  NUMBER,
                         a_delta_price_book_header_id NUMBER)
IS
  SELECT a.price_book_line_id, a.item_number, a.product_uom_code,
         a.list_price, a.net_price, a.line_status_code
  FROM   qp_price_book_lines a
  WHERE  a.price_book_header_id = a_full_price_book_header_id
  AND    NOT EXISTS (SELECT 'X'
                     FROM   qp_price_book_lines b
                     WHERE  b.price_book_header_id=a_delta_price_book_header_id
                     AND    b.item_number = a.item_number
                     AND    b.product_uom_code = a.product_uom_code)
  ORDER BY a.price_book_line_id;

CURSOR deleted_line_dets_cur(a_full_price_book_header_id NUMBER,
                             a_delta_price_book_header_id NUMBER,
                             a_deleted_line_id_first NUMBER,
                             a_deleted_line_id_last NUMBER)
IS
  SELECT price_book_line_det_id, price_book_line_id
  FROM   qp_price_book_line_details
  WHERE  price_book_header_id = a_full_price_book_header_id
  AND    price_book_line_id IN (SELECT a.price_book_line_id
          FROM   qp_price_book_lines a
          WHERE  a.price_book_header_id =
           a_full_price_book_header_id
          AND    NOT EXISTS
                                       (SELECT 'X'
                          FROM   qp_price_book_lines b
                                        WHERE  b.price_book_header_id =
                                            a_delta_price_book_header_id
                          AND    b.item_number = a.item_number
                          AND    b.product_uom_code =
                                                  a.product_uom_code)
                               )
  AND   price_book_line_id BETWEEN
             a_deleted_line_id_first AND a_deleted_line_id_last
  ORDER BY price_book_line_det_id;

BEGIN
  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.conc_login_id;

  --Get the price_book_header_id of the corresponding full price book
  BEGIN
    SELECT price_book_header_id
    INTO   l_full_price_book_header_id
    FROM   qp_price_book_headers_vl
    WHERE  price_book_type_code = 'F'
    AND    price_book_name = p_delta_price_book_name
    AND    customer_id = p_delta_price_book_customer_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --Mark those delta price book lines with 'N' (not changed) that have not
  --changed wrt to previous full price book
  UPDATE qp_price_book_lines a
  SET    a.sync_action_code = 'N' -- unchanged lines will be removed from delta
  WHERE  a.price_book_header_id = p_delta_price_book_header_id
  AND    EXISTS (SELECT 'X'
                 FROM   qp_price_book_lines b
                 WHERE  b.price_book_header_id = l_full_price_book_header_id
                 AND    b.item_number = a.item_number
                 AND    b.product_uom_code = a.product_uom_code
                 AND    nvl(b.list_price, 0) = nvl(a.list_price, 0)
                 AND    nvl(b.net_price, 0) = nvl(a.net_price, 0));

  UPDATE qp_price_book_lines a
  SET    a.sync_action_code = 'A' --Add
  WHERE  a.price_book_header_id = p_delta_price_book_header_id
  AND    NOT EXISTS (SELECT 'X'
                     FROM   qp_price_book_lines b
                     WHERE  b.price_book_header_id = l_full_price_book_header_id
                     AND    b.item_number = a.item_number
                     AND    b.product_uom_code = a.product_uom_code);

  UPDATE qp_price_book_lines a
  SET    sync_action_code = 'R' --Replace
  WHERE  price_book_header_id = p_delta_price_book_header_id
  AND    EXISTS (SELECT 'X'
                 FROM   qp_price_book_lines b
                 WHERE  b.price_book_header_id = l_full_price_book_header_id
                 AND    b.item_number = a.item_number
                 AND    b.product_uom_code = a.product_uom_code
                 AND    (nvl(b.list_price, 0) <> nvl(a.list_price, 0) OR
                         nvl(b.net_price, 0) <> nvl(a.net_price, 0)));

  --Insert into delta price book with sync_action_code = 'D', any item+uom that
  --was present in the previous full price book but not present in delta
  OPEN deleted_lines_cur(l_full_price_book_header_id,
                         p_delta_price_book_header_id);
  LOOP
    l_deleted_line_id_tbl.delete;
    l_new_deleted_line_id_tbl.delete;
    l_item_number_tbl.delete;
    l_uom_code_tbl.delete;
    l_list_price_tbl.delete;
    l_net_price_tbl.delete;
    l_line_status_code_tbl.delete;

    FETCH deleted_lines_cur BULK COLLECT INTO l_deleted_line_id_tbl,
                l_item_number_tbl, l_uom_code_tbl, l_list_price_tbl,
                l_net_price_tbl, l_line_status_code_tbl LIMIT rows;

    --For each record in any of the bulk collection returned by the
    --deleted_lines_cur cursor
    FORALL i IN l_item_number_tbl.FIRST..l_item_number_tbl.LAST
      INSERT INTO qp_price_book_lines
             (price_book_line_id, price_book_header_id,
              item_number,
              product_uom_code,
              list_price,
              net_price,
              sync_action_code, line_status_code, creation_date,
              created_by, last_update_date, last_updated_by,
              last_update_login)
      VALUES (qp_price_book_lines_s.nextval, p_delta_price_book_header_id,
              l_item_number_tbl(i),
              l_uom_code_tbl(i),
              l_list_price_tbl(i),
              l_net_price_tbl(i),
              'D', l_line_status_code_tbl(i), sysdate,
              l_user_id, sysdate, l_user_id,
              l_login_id)
      RETURNING price_book_line_id BULK COLLECT INTO l_new_deleted_line_id_tbl;

    --For each of the deleted price book lines also copy the product attributes
    --(Item Categories) , which have line_det_id = -1, since without the
    --product attributes these lines will not be shown on Hgrid
    FORALL i IN l_new_deleted_line_id_tbl.FIRST..l_new_deleted_line_id_tbl.LAST
      INSERT INTO qp_price_book_attributes
             (price_book_attribute_id, price_book_line_det_id,
              price_book_line_id, price_book_header_id,
              pricing_prod_context, pricing_prod_attribute,
              pricing_prod_attr_value_from, pricing_attr_value_to,
              comparison_operator_code, pricing_prod_attr_datatype,
              attribute_type, creation_date, created_by, last_update_date,
              last_updated_by, last_update_login)
      SELECT  qp_price_book_attributes_s.nextval, price_book_line_det_id,
              l_new_deleted_line_id_tbl(i), p_delta_price_book_header_id,
              pricing_prod_context, pricing_prod_attribute,
              pricing_prod_attr_value_from, pricing_attr_value_to,
              comparison_operator_code, pricing_prod_attr_datatype,
              attribute_type, sysdate, l_user_id, sysdate, l_user_id,
              l_login_id
      FROM    qp_price_book_attributes
      WHERE   price_book_line_id = l_deleted_line_id_tbl(i)
      AND     price_book_line_det_id = -1;

    EXIT WHEN deleted_lines_cur%NOTFOUND;

  END LOOP;
  CLOSE deleted_lines_cur;


  --For delta price book lines that are unchanged wrt to the full price book
  OPEN unchanged_lines_cur(p_delta_price_book_header_id);
  LOOP
    l_unchanged_line_id_tbl.delete;
    FETCH unchanged_lines_cur BULK COLLECT INTO l_unchanged_line_id_tbl
               LIMIT rows;

    --Delete the price book break lines
    FORALL i IN l_unchanged_line_id_tbl.FIRST..l_unchanged_line_id_tbl.LAST
      DELETE FROM qp_price_book_break_lines
      WHERE  price_book_line_id = l_unchanged_line_id_tbl(i);

    --Delete the price book attributes
    FORALL i IN l_unchanged_line_id_tbl.FIRST..l_unchanged_line_id_tbl.LAST
      DELETE FROM qp_price_book_attributes
      WHERE  price_book_line_id = l_unchanged_line_id_tbl(i);

    --Delete the price book line details
    FORALL i IN l_unchanged_line_id_tbl.FIRST..l_unchanged_line_id_tbl.LAST
      DELETE FROM qp_price_book_line_details
      WHERE  price_book_line_id = l_unchanged_line_id_tbl(i);

    --Delete the price book lines
    FORALL i IN l_unchanged_line_id_tbl.FIRST..l_unchanged_line_id_tbl.LAST
      DELETE FROM qp_price_book_lines
      WHERE  price_book_line_id = l_unchanged_line_id_tbl(i);

    --Delete the price book line level messages
    FORALL i IN l_unchanged_line_id_tbl.FIRST..l_unchanged_line_id_tbl.LAST
      DELETE FROM qp_price_book_messages
      WHERE  price_book_line_id = l_unchanged_line_id_tbl(i)
      AND    pb_input_header_id IS NULL;

    EXIT WHEN unchanged_lines_cur%NOTFOUND;

  END LOOP;
  CLOSE unchanged_lines_cur;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Create_Delta_Price_Book;

/*****************************************************************************
 Internal API to Insert Price Book Lines, Attributes, Break Lines and Messages
******************************************************************************/
PROCEDURE Insert_Price_Book_Content(
            p_pb_input_header_rec IN qp_pb_input_headers_vl%ROWTYPE,
            p_pb_input_lines_tbl  IN QP_PRICE_BOOK_UTIL.pb_input_lines_tbl,
            p_price_book_header_id IN NUMBER
           )
IS

  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_return_status_text  VARCHAR2(240) ;
  l_count               NUMBER := 0;

  TYPE GLOBAL_STRUCT_REC IS RECORD(seeded_value_string VARCHAR2(2000),
                                   user_value_string VARCHAR2(2000),
                                   order_level_global_struct VARCHAR2(80),
                                   line_level_global_struct VARCHAR2(80));
  l_rec GLOBAL_STRUCT_REC;

  l_line_index_tbl            QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_line_type_code_tbl        QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_effective_date_tbl    QP_PREQ_GRP.DATE_TYPE;
  l_active_date_first_tbl               QP_PREQ_GRP.DATE_TYPE;
  l_active_date_first_type_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
  l_active_date_second_tbl              QP_PREQ_GRP.DATE_TYPE;
  l_active_date_second_type_tbl         QP_PREQ_GRP.VARCHAR_TYPE;
  l_line_quantity_tbl       QP_PREQ_GRP.NUMBER_TYPE;
  l_line_uom_code_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
  l_request_type_code_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
  l_priced_quantity_tbl                 QP_PREQ_GRP.NUMBER_TYPE;
  l_priced_uom_code_tbl                 QP_PREQ_GRP.VARCHAR_TYPE;
  l_currency_code_tbl       QP_PREQ_GRP.VARCHAR_TYPE;
  l_unit_price_tbl                      QP_PREQ_GRP.NUMBER_TYPE;
  l_percent_price_tbl                   QP_PREQ_GRP.NUMBER_TYPE;
  l_uom_quantity_tbl                    QP_PREQ_GRP.NUMBER_TYPE;
  l_adjusted_unit_price_tbl             QP_PREQ_GRP.NUMBER_TYPE;
  l_upd_adjusted_unit_price_tbl         QP_PREQ_GRP.NUMBER_TYPE;
  l_processed_flag_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  l_price_flag_tbl        QP_PREQ_GRP.VARCHAR_TYPE;
  l_line_id_tbl         QP_PREQ_GRP.NUMBER_TYPE;
  l_processing_order_tbl                QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_pricing_status_code_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_status_text_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  l_rounding_flag_tbl     QP_PREQ_GRP.FLAG_TYPE;
  l_rounding_factor_tbl                 QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_qualifiers_exist_flag_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
  l_pricing_attrs_exist_flag_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_price_list_id_tbl     QP_PREQ_GRP.NUMBER_TYPE;
  l_validated_flag_tbl      QP_PREQ_GRP.VARCHAR_TYPE;
  l_price_request_code_tbl              QP_PREQ_GRP.VARCHAR_TYPE;
  l_usage_pricing_type_tbl              QP_PREQ_GRP.VARCHAR_TYPE;
  l_item_number_tbl               NUMBER_TYPE;

  CURSOR insert_lines2_cur (a_price_book_header_id NUMBER,
                            a_effective_date    DATE,
                            a_item_quantity     NUMBER,
                            a_request_type_code VARCHAR2,
                            a_currency_code     VARCHAR2,
                            a_price_based_on    VARCHAR2,
                            a_pl_agr_bsa_id     NUMBER)
  IS
     SELECT 'LINE', a_effective_date,
            null, null, --active_date_first, active_first_date_type
            null, null, --active_date_second, active_first_second_type
            a_item_quantity, --line_quantity
            product_uom_code, --line_uom_code
            a_request_type_code,
            null, null, --priced_quantity, priced_uom_code
            a_currency_code,
            null, null, null, --unit_price, percent_price, uom_quantity
            null, null, --adjusted_unit_price, upd_adjusted_unit_price
            QP_PREQ_GRP.G_NOT_PROCESSED,   --processed_flag
            'Y',                           --price_flag
            price_book_line_id,            --line_id
            null,                          --processing_order
            QP_PREQ_GRP.G_STATUS_UNCHANGED, --pricing_status_code
            null,                           --pricing_status_text
            'Q',                            --rounding_flag
            null,                           --rounding_factor
            'N',                            --qualifiers_exist_flag
            'N',                            --pricing_attrs_exist_flag
             decode(a_price_based_on, 'PRICE_LIST',
                    a_pl_agr_bsa_id, NULL), --price_list_id
            'N',                            --validated_flag
            null,                           --price_request_code
            null,                           --usage_pricing_type
            item_number
     FROM   qp_price_book_lines
     WHERE  price_book_header_id = a_price_book_header_id
     ORDER BY price_book_line_id;

  l_attrs_line_index_tbl  QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_line_detail_index_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_attribute_level_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_attribute_type_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_list_header_id_tbl  QP_PREQ_GRP.NUMBER_TYPE;
  l_attrs_list_line_id_tbl  QP_PREQ_GRP.NUMBER_TYPE;
  l_attrs_context_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_attribute_tbl   QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_value_from_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_setup_value_from_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_value_to_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_setup_value_to_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_grouping_number_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_no_quals_in_grp_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_comp_oper_type_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_validated_flag_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_applied_flag_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_pri_status_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_pri_status_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_qual_precedence_tbl QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_datatype_tbl    QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_pricing_attr_flag_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_qualifier_type_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_product_uom_code_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_excluder_flag_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_pricing_phase_id_tbl  QP_PREQ_GRP.PLS_INTEGER_TYPE;
  l_attrs_incomp_grp_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_line_det_typ_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_modif_level_code_tbl  QP_PREQ_GRP.VARCHAR_TYPE;
  l_attrs_primary_uom_flag_tbl  QP_PREQ_GRP.VARCHAR_TYPE;


  --Cursor to get 'User Entered' attributes to insert into line_attrs_tmp table
  CURSOR insert_line_attrs2_cur (a_line_index     NUMBER,
                                 a_request_type_code  VARCHAR2,
                                 a_pb_input_header_id   NUMBER)
  IS
    SELECT a_line_index, null, --line_index, line_detail_index
           QP_PREQ_GRP.G_LINE_LEVEL, --attribute_level
           decode(l.attribute_type,
                  'PRICING_ATTRIBUTE', QP_PREQ_GRP.G_PRICING_TYPE,
                  l.attribute_type),    --attribute_type
           null, null,          --list_header_id, list_line_id
           l.context,     --context
           l.attribute,   --attribute
           l.attribute_value,   --value_from
           null, null, null,  --setup_value_from, value_to, setup_value_to
           null, null,    --grouping_number, no_qualifiers_in_group
           null,                --comparison_operator_type
           'N',                 --validated_flag
           QP_PREQ_GRP.G_LIST_NOT_APPLIED,   --applied_flag
           QP_PREQ_GRP.G_STATUS_UNCHANGED,   --pricing_status_code
           null, null,  --pricing_status_text, qualifier_precedence
           null,        --datatype
           QP_PREQ_GRP.G_YES,    --pricing_attr_flag
           null, null,  --qualifier_type, product_uom_code
           null, null,  --excluder_flag, pricing_phase_id
           null, null,  --incompatibility_grp_code, line_detail_type_code
           null, null   --modifier_level_code, primary_uom_flag
    FROM   qp_pb_input_lines l
    WHERE  pb_input_header_id = a_pb_input_header_id
    AND    EXISTS (SELECT 'x'
                   FROM   qp_pte_segments qppseg, qp_prc_contexts_b qpcon,
                            qp_segments_b qpseg, qp_pte_request_types_b qpreq
                   WHERE  qpcon.prc_context_code = l.context
                    AND    qpcon.prc_context_type = l.attribute_type
                    AND    qpseg.prc_context_id = qpcon.prc_context_id
                    AND    qpseg.segment_mapping_column = l.attribute
                    AND    qppseg.segment_id = qpseg.segment_id
                    AND    qpreq.request_type_code = a_request_type_code
                    AND    qppseg.pte_code = qpreq.pte_code
                    AND    qppseg.user_sourcing_method = 'USER ENTERED');

  CURSOR global_struct_attrs_cur(a_request_type_code VARCHAR2,
                                 a_sourcing_level VARCHAR2,
                                 a_context_type   VARCHAR2,
                                 a_context_code   VARCHAR2,
                                 a_segment_mapping_column VARCHAR2)
  IS
    SELECT qpsour.seeded_value_string,
           qpsour.user_value_string,
           qpreq.order_level_global_struct,
           qpreq.line_level_global_struct
    FROM
      qp_segments_b qpseg,
      qp_attribute_sourcing qpsour,
      qp_prc_contexts_b qpcon,
      qp_pte_request_types_b qpreq,
      qp_pte_segments qppseg
    WHERE
      qpsour.segment_id = qpseg.segment_id
      AND qpsour.attribute_sourcing_level = a_sourcing_level
      AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
      AND qpsour.request_type_code = a_request_type_code
      AND qpseg.prc_context_id = qpcon.prc_context_id
      AND qpreq.request_type_code = qpsour.request_type_code
      AND qppseg.pte_code = qpreq.pte_code
      AND qppseg.segment_id = qpsour.segment_id
      AND qppseg.sourcing_enabled = 'Y'
      AND qpcon.prc_context_type = a_context_type
      AND qpcon.prc_context_code = a_context_code
      AND qpseg.segment_mapping_column = a_segment_mapping_column
      AND rownum = 1;

  l_sql_stmt          VARCHAR2(2000) := '';
  l_adhoc_lines_tbl   QP_PRICE_BOOK_UTIL.pb_input_lines_tbl;
  k                   NUMBER;
  l_blanket_number    NUMBER;
  l_bsa_hdr_price_list_id   NUMBER;
  l_bsa_line_price_list_id  NUMBER;
  l_application_id    NUMBER;

  l_control_rec       QP_PREQ_GRP.CONTROL_RECORD_TYPE;

  CURSOR pb_items_cur(a_price_book_header_id NUMBER)
  IS
    SELECT price_book_line_id, item_number --inventory_item_id
    FROM   qp_price_book_lines
    WHERE  price_book_header_id = a_price_book_header_id;

  l_inv_org_id          NUMBER;
  l_net_price_tbl       NUMBER_TYPE;

  CURSOR lines_cur
  IS
    SELECT line_index, line_unit_price list_price,
           order_uom_selling_price net_price, line_id,
           pricing_status_code, pricing_status_text
    FROM   qp_preq_lines_tmp
    ORDER  BY line_index;

  l_cf_list_header_id_tbl   NUMBER_TYPE;
  l_cf_list_line_id_tbl     NUMBER_TYPE;
  l_list_line_no_tbl        VARCHAR_TYPE;
  l_list_price_tbl              NUMBER_TYPE;
  l_modifier_operand_tbl        NUMBER_TYPE;
  l_modifier_appl_method_tbl    VARCHAR30_TYPE;
  l_adjustment_amount_tbl       NUMBER_TYPE;
  l_list_line_type_code_tbl     VARCHAR30_TYPE;
  l_pricing_phase_id_tbl        NUMBER_TYPE;

  l_price_break_type_code_tbl   VARCHAR_TYPE;
  l_line_detail_index_tbl NUMBER_TYPE;

  CURSOR line_dets_cur
  IS
    SELECT a.created_from_list_header_id, a.created_from_list_line_id,
           a.list_line_no,
           decode(pricing_phase_id, 1, b.line_unit_price, a.order_qty_adj_amt)
            list_price,
           a.order_qty_operand modifier_operand,
           a.operand_calculation_code modifier_application_method,
           a.order_qty_adj_amt adjustment_amount,
           a.created_from_list_line_type, a.pricing_phase_id,
           a.price_break_type_code, a.line_index, a.line_detail_index,
           b.line_id
    FROM   qp_preq_ldets_tmp a, qp_preq_lines_tmp b
    WHERE  a.line_index = b.line_index
    AND    a.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND    a.line_detail_type_code = 'NULL' --not a child line
    AND    a.applied_flag = 'Y' --automatic and applied discounts
    AND    nvl(a.accrual_flag,'N') = 'N' --exclude accruals
    ORDER BY a.line_index,
             decode(pricing_phase_id, 1, 1, 2), --to order pll before modifiers
             decode(a.created_from_list_line_type, 'FREIGHT_CHARGE', null,
                    a.pricing_group_sequence),
             decode(a.created_from_list_line_type, 'FREIGHT_CHARGE', 2, 1);

  l_pb_line_det_id_tbl    NUMBER_TYPE;
  l_pb_line_id_tbl    NUMBER_TYPE;
  l_line_index2_tbl     NUMBER_TYPE;
  l_line_detail_index2_tbl  NUMBER_TYPE;
  l_list_line_type_code2_tbl  VARCHAR30_TYPE;

  l_user_id                     NUMBER;
  l_login_id                    NUMBER;

  l_pricing_events              VARCHAR2(2000); --Check the datatype and length
  l_price_book_messages_tbl     QP_PRICE_BOOK_UTIL.price_book_messages_tbl;

  sql_exception     EXCEPTION;
  l_pb_line_count               NUMBER := 0;

  l_validated_flag              VARCHAR2(1);

BEGIN

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.conc_login_id;

  --Set Policy Context to 'S' for Single Org, namely, the org on the price book
  --request of the Price Book being created. Note that republishing should have
  --access mode of 'M', only creation has access mode 'S'.
  mo_global.set_policy_context(p_access_mode => 'S',
                               p_org_id => p_pb_input_header_rec.org_id);

  BEGIN
    SELECT 1
    INTO   l_pb_line_count
    FROM   qp_price_book_lines
    WHERE  price_book_header_id = p_price_book_header_id
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      l_pb_line_count := 0;
  END;

  IF l_pb_line_count = 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --  SNIMMAGA.
  --
  --  The following logic has problems.  All the price book lines are
  --  being sent to the pricing engine in a single go.  When the size of
  --  the price book is huge (something like half a million price book lines
  --  or so), the pricing engine can get choked.
  --
  --  A solution for this issue is to have a profile option, indicating
  --  a permissible batch size of price book lines sent to the pricing engine
  --  at a time; read the value of the profile option in the beginning of
  --  of the Price Book Generation Concurrent program, issue muliple calls to
  --  the pricing engine with such optimized price book line data sets, till
  --  all such sets get priced.

--   qp_price_request_context.set_request_id;

  --Insert records in qp_preq_lines_tmp
  OPEN insert_lines2_cur(p_price_book_header_id,
                         p_pb_input_header_rec.effective_date,
                         p_pb_input_header_rec.item_quantity,
                         p_pb_input_header_rec.request_type_code,
                         p_pb_input_header_rec.currency_code,
                         p_pb_input_header_rec.price_based_on,
                         p_pb_input_header_rec.pl_agr_bsa_id);
  LOOP
    --  This statement is moved into the loop (to process the price book
    --  lines in batches.
    qp_price_request_context.set_request_id;
    fnd_file.put_line(fnd_file.Log, 'Pricing Engine Request ID: '
                        || qp_price_request_context.get_request_id);

    --Delete the plsql table of records for each loop repetition
    l_line_type_code_tbl.delete;
    l_pricing_effective_date_tbl.delete;
    l_active_date_first_tbl.delete;
    l_active_date_first_type_tbl.delete;
    l_active_date_second_tbl.delete;
    l_active_date_second_type_tbl.delete;
    l_line_quantity_tbl.delete;
    l_line_uom_code_tbl.delete;
    l_request_type_code_tbl.delete;
    l_priced_quantity_tbl.delete;
    l_priced_uom_code_tbl.delete;
    l_currency_code_tbl.delete;
    l_unit_price_tbl.delete;
    l_percent_price_tbl.delete;
    l_uom_quantity_tbl.delete;
    l_adjusted_unit_price_tbl.delete;
    l_upd_adjusted_unit_price_tbl.delete;
    l_processed_flag_tbl.delete;
    l_price_flag_tbl.delete;
    l_line_id_tbl.delete;
    l_pricing_status_code_tbl.delete;
    l_pricing_status_text_tbl.delete;
    l_rounding_flag_tbl.delete;
    l_rounding_factor_tbl.delete;
    l_qualifiers_exist_flag_tbl.delete;
    l_pricing_attrs_exist_flag_tbl.delete;
    l_price_list_id_tbl.delete;
    l_validated_flag_tbl.delete;
    l_price_request_code_tbl.delete;
    l_usage_pricing_type_tbl.delete;
    l_item_number_tbl.delete;

    FETCH insert_lines2_cur BULK COLLECT INTO
       l_line_type_code_tbl, l_pricing_effective_date_tbl,
       l_active_date_first_tbl, l_active_date_first_type_tbl,
       l_active_date_second_tbl, l_active_date_second_type_tbl,
       l_line_quantity_tbl, l_line_uom_code_tbl, l_request_type_code_tbl,
       l_priced_quantity_tbl, l_priced_uom_code_tbl,
       l_currency_code_tbl,
       l_unit_price_tbl, l_percent_price_tbl, l_uom_quantity_tbl,
       l_adjusted_unit_price_tbl, l_upd_adjusted_unit_price_tbl,
       l_processed_flag_tbl, l_price_flag_tbl,
       l_line_id_tbl, l_processing_order_tbl,
       l_pricing_status_code_tbl, l_pricing_status_text_tbl,
       l_rounding_flag_tbl, l_rounding_factor_tbl,
       l_qualifiers_exist_flag_tbl, l_pricing_attrs_exist_flag_tbl,
       l_price_list_id_tbl, l_validated_flag_tbl,
       l_price_request_code_tbl, l_usage_pricing_type_tbl,
       l_item_number_tbl LIMIT rows;

    --Set line_index values in the l_line_index_tbl plsql table
    IF l_line_type_code_tbl.COUNT > 0 THEN

      l_line_index_tbl.delete;

      l_count :=  0;

      FOR i IN l_line_type_code_tbl.FIRST..l_line_type_code_tbl.LAST
      LOOP
        l_line_index_tbl(i) := l_count + i;
      END LOOP;

      l_count := l_count + insert_lines2_cur%ROWCOUNT; --highest index of the previous loop
      fnd_file.put_line(FND_FILE.LOG, 'insert_lines2_cur rowcount =  '|| l_count);

      QP_PREQ_GRP.INSERT_LINES2(
         p_LINE_INDEX => l_line_index_tbl,
         p_LINE_TYPE_CODE => l_line_type_code_tbl,
         p_PRICING_EFFECTIVE_DATE => l_pricing_effective_date_tbl,
         p_ACTIVE_DATE_FIRST => l_active_date_first_tbl,
         p_ACTIVE_DATE_FIRST_TYPE => l_active_date_first_type_tbl,
         p_ACTIVE_DATE_SECOND => l_active_date_second_tbl,
         p_ACTIVE_DATE_SECOND_TYPE => l_active_date_second_type_tbl,
         p_LINE_QUANTITY => l_line_quantity_tbl,
         p_LINE_UOM_CODE => l_line_uom_code_tbl,
         p_REQUEST_TYPE_CODE => l_request_type_code_tbl,
         p_PRICED_QUANTITY => l_priced_quantity_tbl,
         p_PRICED_UOM_CODE => l_priced_uom_code_tbl,
         p_CURRENCY_CODE => l_currency_code_tbl,
         p_UNIT_PRICE => l_unit_price_tbl,
         p_PERCENT_PRICE => l_percent_price_tbl,
         p_UOM_QUANTITY => l_uom_quantity_tbl,
         p_ADJUSTED_UNIT_PRICE => l_adjusted_unit_price_tbl,
         p_UPD_ADJUSTED_UNIT_PRICE => l_upd_adjusted_unit_price_tbl,
         p_PROCESSED_FLAG => l_processed_flag_tbl,
         p_PRICE_FLAG =>  l_price_flag_tbl,
         p_LINE_ID => l_line_id_tbl,
         p_PROCESSING_ORDER => l_processing_order_tbl,
         p_PRICING_STATUS_CODE => l_pricing_status_code_tbl,
         p_PRICING_STATUS_TEXT => l_pricing_status_text_tbl,
         p_ROUNDING_FLAG => l_rounding_flag_tbl,
         p_ROUNDING_FACTOR => l_rounding_factor_tbl,
         p_QUALIFIERS_EXIST_FLAG => l_qualifiers_exist_flag_tbl,
         p_PRICING_ATTRS_EXIST_FLAG => l_pricing_attrs_exist_flag_tbl,
         p_PRICE_LIST_ID => l_price_list_id_tbl,
         p_VALIDATED_FLAG => l_validated_flag_tbl,
         p_PRICE_REQUEST_CODE => l_price_request_code_tbl,
         p_USAGE_PRICING_TYPE => l_usage_pricing_type_tbl,
         x_status_code => l_return_status,
         x_status_text => l_return_status_text
      );

      fnd_file.put_line(FND_FILE.LOG, 'insert_lines2 return status '|| l_return_status);
      fnd_file.put_line(FND_FILE.LOG, 'insert_lines2 return text'|| l_return_status_text);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        fnd_file.put_line(fnd_file.Log, '   Raising SQL Exception...');
        RAISE SQL_EXCEPTION;
      END IF;
    END IF; --if l_line_type_code_tbl.count > 0

    IF p_pb_input_lines_tbl.COUNT > 0 THEN
     fnd_file.put_line(fnd_file.Log, ' p_pb_input_lines_tbl.count: ' || p_pb_input_lines_tbl.Count);

      --Build sql stmts and execute them dynamically to assign values to ORDER
      --level global structure columns
      FOR j IN p_pb_input_lines_tbl.FIRST..p_pb_input_lines_tbl.COUNT
      LOOP
        --Get the orderlevel global structure col names from attributemapping setup
        OPEN global_struct_attrs_cur(p_pb_input_header_rec.request_type_code,
                                     'ORDER',
                                     p_pb_input_lines_tbl(j).attribute_type,
                                     p_pb_input_lines_tbl(j).context,
                                     p_pb_input_lines_tbl(j).attribute);

        FETCH global_struct_attrs_cur INTO l_rec;
        --If global_struct_attrs_cur%FOUND THEN
            --dbms_output.put_line('record fetched');
        --END IF;

        IF global_struct_attrs_cur%FOUND THEN
        -- SYMANTEC THROUGHPUT Fix: removed the dynamic SQL execution with standard
        -- PL/SQL code.
        /*
          --Assign the value to the global structure in a sql_stmt string
          l_sql_stmt := 'BEGIN '||
                    nvl(l_rec.user_value_string, l_rec.seeded_value_string) ||
                    ' := :attr_value; ' ||
                    'END; ';
               --Check if to_datatype( ) is required. Mostly yes.

          BEGIN
            EXECUTE IMMEDIATE l_sql_stmt
              USING p_pb_input_lines_tbl(j).attribute_value;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        */
          IF ( l_rec.user_value_string IS NOT NULL ) THEN
            l_rec.user_value_string := p_pb_input_lines_tbl(j).attribute_value;
          ELSE
            l_rec.seeded_value_string := p_pb_input_lines_tbl(j).attribute_value;
          END IF; -- check: l_rec.user_value_string is not NULL

        END IF; -- check: global_struct_attrs_cur
        CLOSE global_struct_attrs_cur;
      END LOOP; --Loop over p_pb_input_lines_tbl                             l
    END IF; --If p_pb_input_lines_tbl.count > 0

    --Populate l_adhoc_lines_tbl with specific qualifier attributes - customer
    --name, price list id and BSA id - from the price book request header.
    --Before populating it, clean it up.
    l_adhoc_lines_tbl.DELETE;

    k := 1;
    l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
    l_adhoc_lines_tbl(k).context := 'CUSTOMER';
    l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE16'; --Party Id
    l_adhoc_lines_tbl(k).attribute_value :=
                             p_pb_input_header_rec.customer_attr_value;
    k := k + 1;

    l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
    l_adhoc_lines_tbl(k).context := 'ASOPARTYINFO';
    l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE1'; --Customer Party
    l_adhoc_lines_tbl(k).attribute_value :=
                             p_pb_input_header_rec.customer_attr_value;
    k := k + 1;

    l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
    l_adhoc_lines_tbl(k).context := 'CUSTOMER';
    l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE2'; --Sold to Org Id
    l_adhoc_lines_tbl(k).attribute_value := p_pb_input_header_rec.cust_account_id;
    k := k + 1;

    l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
    l_adhoc_lines_tbl(k).context := 'INTERCOMPANY_INVOICING';
    l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE3'; --Customer
    l_adhoc_lines_tbl(k).attribute_value := p_pb_input_header_rec.cust_account_id;
    k := k + 1;

    IF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' OR
       p_pb_input_header_rec.price_based_on = 'PRICE_LIST'
    THEN
      l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
      l_adhoc_lines_tbl(k).context := 'MODLIST';
      l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE4';
      l_adhoc_lines_tbl(k).attribute_value :=
                             p_pb_input_header_rec.pl_agr_bsa_id;
      k := k + 1;
    END IF;

    IF p_pb_input_header_rec.price_based_on = 'AGREEMENT'
    THEN
      l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
      l_adhoc_lines_tbl(k).context := 'MODLIST';
      l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE4';
      BEGIN
        SELECT price_list_id
        INTO   l_adhoc_lines_tbl(k).attribute_value
        FROM   oe_agreements_vl
        WHERE  agreement_id = p_pb_input_header_rec.pl_agr_bsa_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_adhoc_lines_tbl(k).attribute_value := null;
      END;
      k := k + 1;
    END IF;

    IF  p_pb_input_header_rec.price_based_on = 'BSA' THEN
      BEGIN
        SELECT order_number
        INTO   l_blanket_number
        FROM   oe_blanket_headers_all
        WHERE  header_id = p_pb_input_header_rec.pl_agr_bsa_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_blanket_number := NULL;
          --Add exception handling
      END;
      --source the blanket number as a qualifier attribute
      l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
      l_adhoc_lines_tbl(k).context := 'ORDER';
      l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE3';
      l_adhoc_lines_tbl(k).attribute_value := l_blanket_number;
      k := k + 1;

      --source the BSA's price list
      l_adhoc_lines_tbl(k).attribute_type := 'QUALIFIER';
      l_adhoc_lines_tbl(k).context := 'MODLIST';
      l_adhoc_lines_tbl(k).attribute := 'QUALIFIER_ATTRIBUTE4';
      BEGIN
        SELECT price_list_id
        INTO   l_bsa_hdr_price_list_id
        FROM   oe_blanket_headers_all
        WHERE  header_id = p_pb_input_header_rec.pl_agr_bsa_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_bsa_hdr_price_list_id := null;
      END;
      l_adhoc_lines_tbl(k).attribute_value := l_bsa_hdr_price_list_id;
      k := k + 1;
    END IF;

    IF l_adhoc_lines_tbl.COUNT > 0 THEN
      --For the adhoc qualifiers set above build sql stmts and execute
      --dynamically to assign values to the ORDER level global structure columns
      FOR j IN 1..l_adhoc_lines_tbl.COUNT
      LOOP
        OPEN global_struct_attrs_cur(p_pb_input_header_rec.request_type_code,
                                     'ORDER',
                                     l_adhoc_lines_tbl(j).attribute_type,
                                     l_adhoc_lines_tbl(j).context,
                                     l_adhoc_lines_tbl(j).attribute);
        FETCH global_struct_attrs_cur INTO l_rec;
        --If global_struct_attrs_cur%FOUND THEN
          --dbms_output.put_line('record fetched 2');
        --END IF;
        IF global_struct_attrs_cur%FOUND THEN
        -- SYMANTEC THROUGHPUT Fix: removed the dynamic SQL execution with standard
        -- PL/SQL code.
          /*
          --Assign the value to the global structure in a sql_stmt string
          l_sql_stmt := ''; --initialize
          l_sql_stmt := 'BEGIN '||
                    nvl(l_rec.user_value_string, l_rec.seeded_value_string) ||
                    ' := :attr_value; ' ||
                    'END; ';
               --Check if to_datatype( ) is required. Mostly yes.

          BEGIN
            EXECUTE IMMEDIATE l_sql_stmt
               USING l_adhoc_lines_tbl(j).attribute_value;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
            */
          IF ( l_rec.user_value_string IS NOT NULL ) THEN
            l_rec.user_value_string := l_adhoc_lines_tbl(j).attribute_value;
          ELSE
            l_rec.seeded_value_string := l_adhoc_lines_tbl(j).attribute_value;
          END IF;

        END IF; -- check: global_struct_attrs_cur%FOuND
        CLOSE global_struct_attrs_cur;
      END LOOP; --over l_adhoc_lines_tbl
    END IF; --If l_adhoc_lines_tbl.count > 0

    --For agreement_id since there is no attribute to map the global structure
    --column for agreement_id, directly assign value to the ORDER level global
    --structure column
    IF p_pb_input_header_rec.price_based_on = 'AGREEMENT' THEN
      OE_ORDER_PUB.G_HDR.agreement_id := p_pb_input_header_rec.pl_agr_bsa_id;
    END IF;

    IF l_line_type_code_tbl.COUNT > 0 THEN
      FOR ii IN l_line_type_code_tbl.FIRST..l_line_type_code_tbl.LAST
      LOOP
        IF p_pb_input_lines_tbl.COUNT > 0 THEN
          --Build sql stmts and execute them dynamically to assign values to
          --LINE level global structure columns
          FOR j IN p_pb_input_lines_tbl.FIRST..p_pb_input_lines_tbl.LAST
          LOOP
            --Get the line level global structure col names from attribute
            --mapping setup
            OPEN global_struct_attrs_cur(p_pb_input_header_rec.request_type_code,
                                       'LINE',
                                       p_pb_input_lines_tbl(j).attribute_type,
                                       p_pb_input_lines_tbl(j).context,
                                       p_pb_input_lines_tbl(j).attribute);

            FETCH global_struct_attrs_cur INTO l_rec;

            IF global_struct_attrs_cur%FOUND THEN

	      -- uncommenting for Pattern since it is required to populate global variable
	      -- before calling build context otherwise attribute will not be sourced.

              -- SYMANTEC THROUGHPUT Fix: removed the dynamic SQL execution with standard
              -- PL/SQL code.

              --Assign the value to the global structure in a sql_stmt string
              l_sql_stmt := 'BEGIN '||
                    nvl(l_rec.user_value_string, l_rec.seeded_value_string) ||
                    ' := :attr_value; ' ||
                    'END; ';
                   --Check if to_datatype( ) is required. Mostly yes.

              BEGIN
                EXECUTE IMMEDIATE l_sql_stmt
                  USING p_pb_input_lines_tbl(j).attribute_value;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

              IF ( l_rec.user_value_string IS NOT NULL ) THEN
                l_rec.user_value_string :=  p_pb_input_lines_tbl(j).attribute_value;
              ELSE
                l_rec.seeded_value_string :=  p_pb_input_lines_tbl(j).attribute_value;
              END IF;

            END IF;
            CLOSE global_struct_attrs_cur;

          END LOOP;--Loop over p_pb_input_lines_tbl for LINE level global struct
        END IF; --If p_pb_input_lines_tbl.count > 0

        --Add inventory_item_id to the attributes in the adhoc_lines_tbl
        --Note that we are not incrementing k after since we want the kth
        --element to be overwritten for each repetition of the line_index loop
        l_adhoc_lines_tbl(k).attribute_type := 'PRODUCT';
        l_adhoc_lines_tbl(k).context := 'ITEM';
        l_adhoc_lines_tbl(k).attribute := 'PRICING_ATTRIBUTE1';
        l_adhoc_lines_tbl(k).attribute_value := l_item_number_tbl(ii);


        IF l_adhoc_lines_tbl.COUNT > 0 THEN
          --For the adhoc qualifiers set earlier build sql stmts and execute
          --dynamically to assign values to the LINE level global structure
          --columns
          FOR j IN 1..l_adhoc_lines_tbl.COUNT
          LOOP
            OPEN global_struct_attrs_cur(p_pb_input_header_rec.request_type_code,
                                         'LINE',
                                         l_adhoc_lines_tbl(j).attribute_type,
                                         l_adhoc_lines_tbl(j).context,
                                         l_adhoc_lines_tbl(j).attribute);
            FETCH global_struct_attrs_cur INTO l_rec;
            IF global_struct_attrs_cur%FOUND THEN
              --Assign the value to the global structure in a sql_stmt string
              l_sql_stmt := 'BEGIN '||
                    nvl(l_rec.user_value_string, l_rec.seeded_value_string) ||
                    ' := :attr_value; ' ||
                    'END; ';
                   --Check if to_datatype( ) is required. Mostly yes.

              BEGIN
                EXECUTE IMMEDIATE l_sql_stmt
                    USING l_adhoc_lines_tbl(j).attribute_value;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
            CLOSE global_struct_attrs_cur;
          END LOOP; --over l_adhoc_lines_tbl for LINE level global structure
        END IF; --If l_adhoc_lines_tbl.count > 0

        --For agreement_id since there is no attribute to map the global
        --structure column for agreement_id, directly assign value to the LINE
        --level global structure column
        IF p_pb_input_header_rec.price_based_on = 'AGREEMENT' THEN
          OE_ORDER_PUB.G_LINE.agreement_id :=
                  p_pb_input_header_rec.pl_agr_bsa_id;
          l_validated_flag := 'Y';
        ELSE
          l_validated_flag := 'N';
        END IF;

        --If price_based_on is BSA then map the line-level global structure
        --column for price list to the one on the BSA line for the specific
        --item and pricing effectivity date
        IF p_pb_input_header_rec.price_based_on = 'BSA' THEN
          BEGIN
            SELECT a.price_list_id
            INTO   l_bsa_line_price_list_id
            FROM   oe_blanket_lines_all a, oe_blanket_lines_ext b
            WHERE  a.header_id = p_pb_input_header_rec.pl_agr_bsa_id
            AND    a.line_id = b.line_id
            AND    a.inventory_item_id = l_item_number_tbl(ii)
            AND    p_pb_input_header_rec.effective_date BETWEEN
                   nvl(trunc(b.start_date_active),
                       p_pb_input_header_rec.effective_date) AND
                   nvl(trunc(b.end_date_active),
                       p_pb_input_header_rec.effective_date);
          EXCEPTION
            WHEN OTHERS THEN
              l_bsa_line_price_list_id := null;
          END;

          --Assign blanket pricelist to appropriate line level structure column
          OE_ORDER_PUB.G_LINE.price_list_id :=
                   nvl(l_bsa_line_price_list_id, l_bsa_hdr_price_list_id);

        END IF; --If price_based_on is 'BSA'

        --Call Build Contexts for line record
        QP_Attr_Mapping_PUB.Build_Contexts(
                               p_request_type_code => p_pb_input_header_rec.request_type_code,
                               p_line_index => l_line_index_tbl(ii),
                               p_pricing_type_code => 'L',
                               p_price_list_validated_flag => l_validated_flag,
                               p_org_id => p_pb_input_header_rec.org_id);

        --Clear the plsql tables, fetch User-Entered attributes from the
        --pricebook input lines table, then insert into the line attrs temp
        --table using the qp_preq_grp.insert_line_attrs2 API
        OPEN insert_line_attrs2_cur(l_line_index_tbl(ii),
                                    p_pb_input_header_rec.request_type_code,
                                    p_pb_input_header_rec.pb_input_header_id);
        LOOP
          l_attrs_line_index_tbl.delete;
          l_attrs_line_detail_index_tbl.delete;
          l_attrs_attribute_level_tbl.delete;
          l_attrs_attribute_type_tbl.delete;
          l_attrs_list_header_id_tbl.delete;
          l_attrs_list_line_id_tbl.delete;
          l_attrs_context_tbl.delete;
          l_attrs_attribute_tbl.delete;
          l_attrs_value_from_tbl.delete;
          l_attrs_setup_value_from_tbl.delete;
          l_attrs_value_to_tbl.delete;
          l_attrs_setup_value_to_tbl.delete;
          l_attrs_grouping_number_tbl.delete;
          l_attrs_no_quals_in_grp_tbl.delete;
          l_attrs_comp_oper_type_tbl.delete;
          l_attrs_validated_flag_tbl.delete;
          l_attrs_applied_flag_tbl.delete;
          l_attrs_pri_status_code_tbl.delete;
          l_attrs_pri_status_text_tbl.delete;
          l_attrs_qual_precedence_tbl.delete;
          l_attrs_datatype_tbl.delete;
          l_attrs_pricing_attr_flag_tbl.delete;
          l_attrs_qualifier_type_tbl.delete;
          l_attrs_product_uom_code_tbl.delete;
          l_attrs_excluder_flag_tbl.delete;
          l_attrs_pricing_phase_id_tbl.delete;
          l_attrs_incomp_grp_code_tbl.delete;
          l_attrs_line_det_typ_code_tbl.delete;
          l_attrs_modif_level_code_tbl.delete;
          l_attrs_primary_uom_flag_tbl.delete;

          FETCH insert_line_attrs2_cur BULK COLLECT INTO
            l_attrs_line_index_tbl, l_attrs_line_detail_index_tbl,
            l_attrs_attribute_level_tbl, l_attrs_attribute_type_tbl,
            l_attrs_list_header_id_tbl, l_attrs_list_line_id_tbl,
            l_attrs_context_tbl, l_attrs_attribute_tbl,
            l_attrs_value_from_tbl, l_attrs_setup_value_from_tbl,
            l_attrs_value_to_tbl, l_attrs_setup_value_to_tbl,
            l_attrs_grouping_number_tbl, l_attrs_no_quals_in_grp_tbl,
            l_attrs_comp_oper_type_tbl, l_attrs_validated_flag_tbl,
            l_attrs_applied_flag_tbl, l_attrs_pri_status_code_tbl,
            l_attrs_pri_status_text_tbl, l_attrs_qual_precedence_tbl,
            l_attrs_datatype_tbl, l_attrs_pricing_attr_flag_tbl,
            l_attrs_qualifier_type_tbl, l_attrs_product_uom_code_tbl,
            l_attrs_excluder_flag_tbl, l_attrs_pricing_phase_id_tbl,
            l_attrs_incomp_grp_code_tbl, l_attrs_line_det_typ_code_tbl,
            l_attrs_modif_level_code_tbl, l_attrs_primary_uom_flag_tbl
          LIMIT rows;

          IF l_attrs_line_index_tbl.count > 0 THEN
            QP_PREQ_GRP.INSERT_LINE_ATTRS2(
              p_LINE_INDEX_tbl  => l_attrs_line_index_tbl,
              p_LINE_DETAIL_INDEX_tbl => l_attrs_line_detail_index_tbl,
              p_ATTRIBUTE_LEVEL_tbl   => l_attrs_attribute_level_tbl,
              p_ATTRIBUTE_TYPE_tbl    => l_attrs_attribute_type_tbl,
              p_LIST_HEADER_ID_tbl    => l_attrs_list_header_id_tbl,
              p_LIST_LINE_ID_tbl      => l_attrs_list_line_id_tbl,
              p_CONTEXT_tbl           => l_attrs_context_tbl,
              p_ATTRIBUTE_tbl         => l_attrs_attribute_tbl,
              p_VALUE_FROM_tbl        => l_attrs_value_from_tbl,
              p_SETUP_VALUE_FROM_tbl  => l_attrs_setup_value_from_tbl,
              p_VALUE_TO_tbl          => l_attrs_value_to_tbl,
              p_SETUP_VALUE_TO_tbl    => l_attrs_setup_value_to_tbl,
              p_GROUPING_NUMBER_tbl   => l_attrs_grouping_number_tbl,
              p_NO_QUALIFIERS_IN_GRP_tbl     => l_attrs_no_quals_in_grp_tbl,
              p_COMPARISON_OPERATOR_TYPE_tbl => l_attrs_comp_oper_type_tbl,
              p_VALIDATED_FLAG_tbl           => l_attrs_validated_flag_tbl,
              p_APPLIED_FLAG_tbl             => l_attrs_applied_flag_tbl,
              p_PRICING_STATUS_CODE_tbl      => l_attrs_pri_status_code_tbl,
              p_PRICING_STATUS_TEXT_tbl      => l_attrs_pri_status_text_tbl,
              p_QUALIFIER_PRECEDENCE_tbl     => l_attrs_qual_precedence_tbl,
              p_DATATYPE_tbl                 => l_attrs_datatype_tbl,
              p_PRICING_ATTR_FLAG_tbl        => l_attrs_pricing_attr_flag_tbl,
              p_QUALIFIER_TYPE_tbl           => l_attrs_qualifier_type_tbl,
              p_PRODUCT_UOM_CODE_TBL         => l_attrs_product_uom_code_tbl,
              p_EXCLUDER_FLAG_TBL            => l_attrs_excluder_flag_tbl,
              p_PRICING_PHASE_ID_TBL         => l_attrs_pricing_phase_id_tbl,
              p_INCOMPATABILITY_GRP_CODE_TBL => l_attrs_incomp_grp_code_tbl,
              p_LINE_DETAIL_TYPE_CODE_TBL    => l_attrs_line_det_typ_code_tbl,
              p_MODIFIER_LEVEL_CODE_TBL      => l_attrs_modif_level_code_tbl,
              p_PRIMARY_UOM_FLAG_TBL         => l_attrs_primary_uom_flag_tbl,
              x_status_code                  => l_return_status,
              x_status_text                  => l_return_status_text
            );

            fnd_file.put_line(FND_FILE.LOG, 'insert_line_attrs2 return status '||l_return_status);
            fnd_file.put_line(FND_FILE.LOG, 'insert_line_attrs2 return text'||l_return_status_text);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE SQL_EXCEPTION;
            END IF;

          END IF; -- If l_attrs_line_index_tbl.count > 0

          EXIT WHEN insert_line_attrs2_cur%NOTFOUND;

        END LOOP; --Loop over cursor insert_line_attrs2_cur

        CLOSE insert_line_attrs2_cur;


      END LOOP; --Loop over l_line_type_code_tbl

    END IF; --If l_line_type_code_tbl.count > 0

--    EXIT WHEN insert_lines2_cur%NOTFOUND;

-- SNIMMAGA.
-- Call the pricing engine for the current 'chunk' of the price list lines,
-- and attributes.  Once that's done for this chunk, insert that data into
-- price book.

--------
-- TODO: Identify the records requiring clean-up per every iteration, and
--       write the clean-up code before the immediate  hyphenated string.

----------------------------------
    QP_PREQ_PUB.g_call_from_price_book := 'Y';

    --Fetch he Pricing Events info from the Pricing Parameters setup
    l_pricing_events := QP_Param_Util.Get_Parameter_Value (
                  p_level => 'REQ', --For Request Type level
                  p_level_name => p_pb_input_header_rec.pricing_perspective_code,
                  p_parameter_code => 'QP_PRICE_BOOK_PRICING_EVENTS');

    fnd_file.put_line(FND_FILE.LOG, 'Pricing Events - '||l_pricing_events);
    --Set the l_control_rec field values
    l_control_rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
    l_control_rec.simulation_flag := 'Y';
    l_control_rec.pricing_event := l_pricing_events; --from pricing parameter
    l_control_rec.temp_table_insert_flag := 'N';
    l_control_rec.check_cust_view_flag := 'N'; --Find out what this is
    l_control_rec.request_type_code := p_pb_input_header_rec.request_type_code;
    l_control_rec.rounding_flag := 'Q';
    l_control_rec.use_multi_currency:= null;
    l_control_rec.function_currency:= null;
    l_control_rec.org_id := p_pb_input_header_rec.org_id;
    l_control_rec.full_pricing_call := 'Y';

--fnd_file.put_line(fnd_file.Log, 'l_request_type_code:  '|| l_request_type_code);
    fnd_file.put_line(fnd_file.Log, 'Before Pricing Engine call');

    --Call the Pricing Engine

    QP_PREQ_PUB.Price_Request(l_control_rec,
                              l_return_status,
                              l_return_status_text);

    fnd_file.put_line(fnd_file.Log, 'After Pricing Engine Call...');
    fnd_file.put_line(FND_FILE.LOG, 'Price_Request return status: '||l_return_status);
    fnd_file.put_line(FND_FILE.LOG, 'Price_Request return text: '||l_return_status_text);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE SQL_EXCEPTION;
    END IF;

    OPEN lines_cur;
    LOOP
      l_line_index_tbl.delete;
      l_line_id_tbl.delete;
      l_list_price_tbl.delete;
      l_net_price_tbl.delete;
      l_pricing_status_code_tbl.delete;
      l_pricing_status_text_tbl.delete;

      FETCH lines_cur BULK COLLECT INTO l_line_index_tbl, l_list_price_tbl,
                l_net_price_tbl, l_line_id_tbl,
                l_pricing_status_code_tbl, l_pricing_status_text_tbl
      LIMIT rows;

      --Update the list and net price in the price book lines table with the values
      --calculated by the engine that are in the lines temp table
      FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
        UPDATE qp_price_book_lines
        SET    list_price = l_list_price_tbl(i),
              net_price = l_net_price_tbl(i)
        WHERE  price_book_line_id = l_line_id_tbl(i);

      --Copy price book line level messages from lines_tmp table into
      --qp_price_book_messages
      IF l_line_id_tbl.COUNT > 0 THEN
        FOR i IN l_line_id_tbl.FIRST..l_line_id_tbl.LAST
        LOOP
          IF l_pricing_status_code_tbl(i) NOT IN ('UPDATED', 'UNCHANGED') THEN
            --Exclude informational messages
            INSERT INTO qp_price_book_messages
            (message_id, message_type, message_code, message_text,
            pb_input_header_id, price_book_header_id, price_book_line_id,
            creation_date, created_by, last_update_date, last_updated_by,
            last_update_login
            )
            VALUES
            (qp_price_book_messages_s.nextval, 'E', l_pricing_status_code_tbl(i),
            l_pricing_status_text_tbl(i), null, p_price_book_header_id,
            l_line_id_tbl(i), sysdate, l_user_id, sysdate, l_user_id,
            l_login_id
            );
          END IF;
        END LOOP;
      END IF; --If l_line_id_tbl.COUNT > 0

      EXIT WHEN lines_cur%NOTFOUND;

    END LOOP; --Loop over lines_cur
    CLOSE lines_cur;

    l_inv_org_id := fnd_profile.value('QP_ORGANIZATION_ID');

    --For each item(line) in the price book insert the parent categories into the
    --qp_price_book_attributes table. The line_detail_id will be -1 since these
    --attributes are at the price book line level and used for UI and get_catalog
    --purposes.
    OPEN pb_items_cur (p_price_book_header_id);
    LOOP

      l_line_id_tbl.delete;
      l_item_number_tbl.delete;

      FETCH pb_items_cur BULK COLLECT INTO l_line_id_tbl, l_item_number_tbl
        LIMIT rows;

      FORALL i IN l_line_id_tbl.FIRST..l_line_id_tbl.LAST
        INSERT INTO qp_price_book_attributes
          (price_book_attribute_id, price_book_line_det_id,
          price_book_line_id, price_book_header_id,
          pricing_prod_context, pricing_prod_attribute,
          comparison_operator_code, pricing_prod_attr_value_from,
          pricing_attr_value_to, pricing_prod_attr_datatype,
          attribute_type, creation_date, created_by, last_update_date,
          last_updated_by, last_update_login
          )
        SELECT qp_price_book_attributes_s.nextval, -1,
            l_line_id_tbl(i), p_price_book_header_id,
            'ITEM', 'PRICING_ATTRIBUTE2', --Item Category
            '=', category_id, null, 'N',
            'PRODUCT', sysdate, l_user_id, sysdate,
            l_user_id, l_login_id
        FROM (SELECT DISTINCT a.category_id
              FROM mtl_item_categories a, mtl_categories_b b,
                  mtl_category_sets_b c, mtl_default_category_sets d
              WHERE a.inventory_item_id = l_item_number_tbl(i)
              AND a.organization_id = l_inv_org_id --inventory org, not OU
              AND b.category_id = a.category_id
              AND c.structure_id = b.structure_id
              AND d.category_set_id = c.category_set_id
              AND d.functional_area_id IN
              (SELECT ssf.functional_area_id
              FROM   qp_pte_source_systems pss,
                      qp_pte_request_types_b prt,
                      qp_sourcesystem_fnarea_map ssf
              WHERE  pss.pte_code = prt.pte_code
              AND    pss.enabled_flag = 'Y'
              AND    prt.enabled_flag = 'Y'
              AND    ssf.enabled_flag = 'Y'
              AND    prt.request_type_code = p_pb_input_header_rec.request_type_code
              AND    pss.pte_source_system_id = ssf.pte_source_system_id)
            );

      EXIT WHEN pb_items_cur%NOTFOUND;

    END LOOP; --loop over pb_items_cur
    CLOSE pb_items_cur;

    OPEN line_dets_cur;
    LOOP
      l_cf_list_header_id_tbl.delete;
      l_cf_list_line_id_tbl.delete;
      l_list_line_no_tbl.delete;
      l_list_price_tbl.delete;
      l_modifier_operand_tbl.delete;
      l_modifier_appl_method_tbl.delete;
      l_adjustment_amount_tbl.delete;
      l_list_line_type_code_tbl.delete;
      l_price_break_type_code_tbl.delete;
      l_line_index_tbl.delete;
      l_line_detail_index_tbl.delete;
      l_line_id_tbl.delete;
      l_pricing_phase_id_tbl.delete;

      l_pb_line_det_id_tbl.delete;
      l_pb_line_id_tbl.delete;
      l_line_index2_tbl.delete;
      l_line_detail_index2_tbl.delete;
      l_list_line_type_code2_tbl.delete;

      FETCH line_dets_cur
      BULK COLLECT INTO l_cf_list_header_id_tbl,
            l_cf_list_line_id_tbl, l_list_line_no_tbl,
            l_list_price_tbl, l_modifier_operand_tbl,
            l_modifier_appl_method_tbl, l_adjustment_amount_tbl,
            l_list_line_type_code_tbl, l_pricing_phase_id_tbl,
            l_price_break_type_code_tbl, l_line_index_tbl,
            l_line_detail_index_tbl, l_line_id_tbl
      LIMIT rows;

      fnd_file.put_line(FND_FILE.LOG, 'No of line details '||to_char(l_line_id_tbl.count));

      --Insert records into the price book line details table from the line
      --details temp table
      FORALL j IN l_line_id_tbl.FIRST..l_line_id_tbl.LAST
        INSERT INTO qp_price_book_line_details
          (price_book_line_det_id, price_book_line_id,
          price_book_header_id,
          list_header_id, list_line_id,
          list_line_no, list_price,
          modifier_operand, modifier_application_method, adjustment_amount,
          adjusted_net_price, list_line_type_code,
          price_break_type_code,
          creation_date, created_by, last_update_date,
          last_updated_by, last_update_login
          )
        VALUES
          (qp_price_book_line_details_s.nextval, l_line_id_tbl(j),
          p_price_book_header_id,
          l_cf_list_header_id_tbl(j), l_cf_list_line_id_tbl(j),
          decode(l_pricing_phase_id_tbl(j), 1, null, l_list_line_no_tbl(j)),
                  --insert null for list_line_no in case of PLL, PBH price list line
          decode(l_list_price_tbl(j), l_adjustment_amount_tbl(j), null,
                  l_list_price_tbl(j)),
          l_modifier_operand_tbl(j), l_modifier_appl_method_tbl(j),
          l_adjustment_amount_tbl(j), null,
          l_list_line_type_code_tbl(j), l_price_break_type_code_tbl(j),
          sysdate, l_user_id, sysdate, l_user_id, l_login_id)
        RETURNING price_book_line_det_id, price_book_line_id, l_line_index_tbl(j),
                l_line_detail_index_tbl(j), l_list_line_type_code_tbl(j)
        BULK COLLECT INTO l_pb_line_det_id_tbl, l_pb_line_id_tbl,
                l_line_index2_tbl, l_line_detail_index2_tbl, l_list_line_type_code2_tbl;

      --Insert records into the price book attrs table from the line attrs temp
      --table for Price List Lines
      FORALL k IN l_line_index2_tbl.FIRST..l_line_index2_tbl.LAST
        INSERT INTO qp_price_book_attributes
            (price_book_attribute_id, price_book_line_det_id,
            price_book_line_id, price_book_header_id,
            pricing_prod_context, pricing_prod_attribute,
            comparison_operator_code, pricing_prod_attr_value_from,
            pricing_attr_value_to, pricing_prod_attr_datatype,
            attribute_type, creation_date, created_by, last_update_date,
            last_updated_by, last_update_login
            )
        SELECT qp_price_book_attributes_s.nextval, a.pb_line_det_id,
              a.pb_line_id, a.price_book_header_id,
              a.context, a.attribute,
              a.comparison_operator_type_code, a.setup_value_from,
              a.setup_value_to, a.datatype, a.attribute_type,
              sysdate, l_user_id, sysdate,
              l_user_id, l_login_id
        FROM  (SELECT DISTINCT l_pb_line_det_id_tbl(k) pb_line_det_id,
              l_pb_line_id_tbl(k) pb_line_id,
              p_price_book_header_id price_book_header_id,
              a.context, a.attribute,
              a.comparison_operator_type_code, a.setup_value_from,
              a.setup_value_to, a.datatype,
              decode(a.attribute_type, QP_PREQ_GRP.G_PRICING_TYPE,
                  'PRICING_ATTRIBUTE', a.attribute_type) attribute_type
        FROM   qp_preq_line_attrs_tmp a, qp_list_headers_vl b
        WHERE  a.line_index = l_line_index2_tbl(k)
        AND    a.line_detail_index = l_line_detail_index2_tbl(k)
        AND    a.list_header_id = b.list_header_id
        AND    b.list_type_code = 'PRL'
        AND    a.attribute_type = QP_PREQ_GRP.G_PRICING_TYPE
                              --Only pricing attributes
        AND    a.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW) a;

        -- (08/03/06) Added distinct in the select statement above since the
        -- pricing engine creates multiple records for pricing attributes in
        -- the tmp table depending on the number of qualifier attributes
        -- attached to a pricelist. However split the select stmt since
        -- sequence.next cannot be selected in conjunction with DISTINCT.

      fnd_file.put_line(FND_FILE.LOG, 'No of pricing attributes '||to_char(sql%rowcount));

      --Insert records into the price book break lines table from the line attrs
      --temp table for PBH Price List and Modifier Lines
      FORALL k IN l_line_index2_tbl.FIRST..l_line_index2_tbl.LAST
        INSERT INTO qp_price_book_break_lines
          (price_book_break_line_id, price_book_line_det_id,
          price_book_line_id, price_book_header_id,
          pricing_context, pricing_attribute, pricing_attr_value_from,
          pricing_attr_value_to, comparison_operator_code,
          pricing_attribute_datatype, operand, application_method,
          recurring_value,
          creation_date, created_by, last_update_date, last_updated_by,
          last_update_login)
        SELECT /*+ ORDERED index(a QP_PREQ_LINE_ATTRS_TMP_N3) */ qp_price_book_break_lines_s.nextval, l_pb_line_det_id_tbl(k),
              l_pb_line_id_tbl(k), p_price_book_header_id,
              a.context, a.attribute, a.value_from,
              a.value_to, a.comparison_operator_type_code,
              a.datatype, b.operand_value, b.operand_calculation_code,
              b.recurring_value,
              sysdate, l_user_id, sysdate, l_user_id, l_login_id
        FROM   qp_preq_rltd_lines_tmp r, qp_preq_ldets_tmp b, qp_preq_line_attrs_tmp a
        WHERE  l_list_line_type_code2_tbl(k) = 'PBH'
        AND    r.line_index = l_line_index2_tbl(k)
        AND    r.line_detail_index = l_line_detail_index2_tbl(k)
        AND    r.relationship_type_code = QP_PREQ_GRP.G_PBH_LINE -- just in case db goes to table before first condition
        AND    b.line_detail_index = r.related_line_detail_index
        AND    a.line_detail_index = b.line_detail_index;

      fnd_file.put_line(FND_FILE.LOG, 'No of price breaks '||to_char(sql%rowcount));

      EXIT WHEN line_dets_cur%NOTFOUND;

    END LOOP; --loop over line_dets_cur
    CLOSE line_dets_cur;
----------------------------------
    EXIT WHEN insert_lines2_cur%NOTFOUND;
  END LOOP; --Loop over cursor insert_lines2_cur
  CLOSE insert_lines2_cur;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE;
END Insert_Price_Book_Content;



/*****************************************************************************
 Private API to Generate and/or Publish Price Book
******************************************************************************/
PROCEDURE Generate_Publish_Price_Book(p_pb_input_header_id IN  NUMBER,
                                      x_request_id         OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2,
                                      x_retcode            OUT NOCOPY NUMBER,
                                      x_err_buf            OUT NOCOPY VARCHAR2)
IS
x_return_text     VARCHAR2(2000) := NULL;
l_generation_time_code  VARCHAR2(30);
l_gen_schedule_date   DATE;

BEGIN

  --Perform validation of input criteria
  QP_PRICE_BOOK_UTIL.Validate_PB_Inp_Criteria_Wrap(
                  p_pb_input_header_id => p_pb_input_header_id,
                  x_return_status => x_return_status,
                  x_return_text => x_return_text);

  IF x_return_status = 'E' THEN
    RETURN;
  END IF;

  --submit the parent concurrent request

  x_request_id := FND_REQUEST.SUBMIT_REQUEST(
     'QP', 'QPXPRBKB', 'Price Book Generate and Publish',
     '',
     FALSE, p_pb_input_header_id);

  IF x_request_id = 0 THEN --Error occurred
   x_err_buf := substr(FND_MESSAGE.GET, 1, 240);
   x_retcode := 2;
   x_return_status := 'E';
  ELSE -- conc request submission successful
   x_err_buf := '';
   x_retcode := 0;
   x_return_status := 'S';

   --Update the input header table with the request_id of the parent conc request
   UPDATE qp_pb_input_headers_b
   SET    request_id = x_request_id
   WHERE  pb_input_header_id = p_pb_input_header_id;

   COMMIT; --To complete parent concurrent request submission
--dbms_output.put_line('after submitting parent concurrent pgm');

  END IF;

END Generate_Publish_Price_Book;


/*******************************************************************************
 Concurrent Program to Generate and/or Publish Price Book. Called by the Private API Generate_Publish_Price_Book
*******************************************************************************/
PROCEDURE Price_Book_Conc_Pgm(
                              retcode                 OUT NOCOPY NUMBER,
                              errbuf                  OUT NOCOPY VARCHAR2,
                              p_pb_input_header_id    IN  NUMBER,
                              p_customer_id           IN  NUMBER := NULL,
                              p_price_book_header_id  IN  NUMBER := NULL,
                              p_spawned_request       IN  VARCHAR2 := 'N')
IS
  l_pb_input_header_rec        qp_pb_input_headers_vl%ROWTYPE;
  l_pb_input_lines_tbl         QP_PRICE_BOOK_UTIL.pb_input_lines_tbl;
  l_publish_price_book_header_id      NUMBER := NULL;
  l_overwrite_pb_header_id    NUMBER := NULL;
  l_item_validation_org_id     NUMBER;
  l_child_request_id           NUMBER;
  l_submit          VARCHAR2(30) := NULL;
  l_document_type          VARCHAR2(30) := NULL;

  TYPE uom_tbl IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE item_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  l_item_tbl            item_tbl;
  l_item2_tbl           item_tbl;
  l_uom_tbl             uom_tbl;

  CURSOR pl_items_cur(a_price_list_id NUMBER)
  IS
    SELECT DISTINCT product_attr_value item_id
         --Since an item can occur multiple times in a pl if attributes differ
    FROM   qp_pricing_attributes
    WHERE  list_header_id = a_price_list_id
    AND    product_attribute = 'PRICING_ATTRIBUTE1' --Item Number
    AND    product_attribute_context = 'ITEM';

  CURSOR cat_items_cur(a_category_id NUMBER, a_organization_id NUMBER)
  IS
    SELECT DISTINCT cat.inventory_item_id item_id
    FROM   mtl_item_categories cat
    WHERE  cat.organization_id = a_organization_id
    AND    (cat.category_id = a_category_id
            OR
            EXISTS (SELECT 'Y'
                    FROM   eni_denorm_hierarchies
                    WHERE  parent_id = a_category_id and
                           child_id = cat.category_id)
           );

  CURSOR items_cur(a_organization_id NUMBER, a_pricing_perspective VARCHAR2)
  IS
    SELECT msi.inventory_item_id item_id
    FROM   mtl_system_items_b msi
    WHERE  msi.organization_id = a_organization_id
    AND    msi.purchasing_enabled_flag = decode(a_pricing_perspective,
                                        'PO', 'Y', msi.purchasing_enabled_flag)
    AND    EXISTS (SELECT 'X'
                   FROM   mtl_item_categories mic
                   WHERE  inventory_item_id = msi.inventory_item_id
                   AND    organization_id = msi.organization_id);

  CURSOR item_uom_cur(a_item_id NUMBER, a_organization_id NUMBER,
                      a_effective_date DATE)
  IS
    SELECT msi.inventory_item_id item_id, msi.primary_uom_code uom_code
    FROM   mtl_system_items msi, mtl_units_of_measure muom
    WHERE  msi.organization_id = a_organization_id
    AND    msi.inventory_item_id = a_item_id
    AND    muom.uom_code = msi.primary_uom_code
    AND    nvl(muom.disable_date, trunc(a_effective_date) + 1) >
                         trunc(a_effective_date)
    UNION
    SELECT a_item_id item_id, muom.uom_code uom_code
    FROM mtl_system_items msi2,
         mtl_units_of_measure muom2,
         mtl_uom_conversions mcon,
         mtl_units_of_measure muom,
         mtl_uom_classes mcl
    WHERE muom2.uom_code = msi2.primary_uom_code
                             and    msi2.organization_id = a_organization_id
                             and    msi2.inventory_item_id = a_item_id
                             and    nvl(muom2.disable_date,
                                        trunc(a_effective_date) + 1) >
                                    trunc(a_effective_date)
    AND   mcon.uom_class = muom2.uom_class
    AND    mcon.inventory_item_id = 0
    AND  mcon.uom_code = muom.uom_code
    AND    nvl(mcon.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date)
    AND    mcl.uom_class = muom.uom_class
    AND    nvl(mcl.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date)
    AND    nvl(muom.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date)
    AND   EXISTS  (
                    SELECT   'x'
                    FROM     qp_pricing_attributes pa
                    WHERE    pa.product_attribute_context   =   'ITEM'
                    AND      pa.product_attribute           =   'PRICING_ATTRIBUTE1'
                    AND      pa.product_attr_value          =   To_Char(a_item_id)
                    AND      pa.product_uom_code            =   muom.uom_code
                    AND      pa.qualification_ind IN (4,6,20,22)
                    AND      pa.pricing_phase_id            =   1
                  )
    UNION
    SELECT a_item_id item_id, muom.uom_code uom_code
    FROM   mtl_units_of_measure muom,
           mtl_uom_conversions  mcon,
           mtl_uom_classes      mcl
    WHERE  mcon.uom_code  = muom.uom_code
    AND    mcon.inventory_item_id = a_item_id
    AND    mcl.uom_class = muom.uom_class
    AND    nvl(mcl.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date)
    AND    nvl(muom.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date)
    AND    nvl(mcon.disable_date,trunc(a_effective_date)+1) >
           trunc(a_effective_date);

  l_user_id     NUMBER;
  l_login_id    NUMBER;

  l_price_book_messages_tbl    QP_PRICE_BOOK_UTIL.price_book_messages_tbl;
  l_message_text  VARCHAR2(2000);
  i       NUMBER :=1;
  m                     NUMBER;
  l_net_price     NUMBER;

  l_line_id_tbl   NUMBER_TYPE;
  l_list_price_tbl    NUMBER_TYPE;
  l_line_det_id_tbl   NUMBER_TYPE;
  l_adjustment_amount_tbl   NUMBER_TYPE;
  l_line_det_id_tbl2    NUMBER_TYPE;
  l_net_price_tbl   NUMBER_TYPE;
  l_line_id_tbl2    NUMBER_TYPE;

  CURSOR pb_lines_cur
  IS
    SELECT price_book_line_id, list_price
    FROM   qp_price_book_lines
    WHERE  price_book_header_id = p_price_book_header_id
    ORDER BY price_book_line_id;

  l_old_input_header_id   NUMBER;
  l_debug_file                  VARCHAR2(240);
  l_return_status     VARCHAR2(30);
  l_return_status_text    VARCHAR2(2000);

  l_document_id           NUMBER;
  l_delta_document_id           NUMBER;

  l_corr_delta_pb_header_id     NUMBER;
  l_delta_input_header_id NUMBER;

  l_old_request_id              NUMBER;
  l_old_delta_request_id        NUMBER;
  l_req_phase     VARCHAR2(400);
  l_req_status      VARCHAR2(400);
  l_req_dev_status    VARCHAR2(400);
  l_req_dev_phase   VARCHAR2(400);
  l_req_message     VARCHAR2(4000);
  l_result      BOOLEAN;

  -- Introduced for the purpose of PL/SQL profiling (snimmaga)
  err       NUMBER;

BEGIN

  -- Introduced for the purpose of PL/SQL profiling (snimmaga)
/*
  fnd_file.put_line(fnd_file.Log, 'Switching on PL/SQL Profiler...');
  err := DBMS_PROFILER.START_PROFILER (to_char(sysdate,'dd-Mon-YYYY hh:mi:ss'));
*/

  fnd_file.put_line(FND_FILE.LOG, 'In Conc Program');

  BEGIN
    SELECT *
    INTO   l_pb_input_header_rec
    FROM   qp_pb_input_headers_vl
    WHERE  pb_input_header_id = p_pb_input_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('QP', 'QP_INPUT_REC_NOT_FOUND');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code :=
                            'QP_INPUT_REC_NOT_FOUND';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id := p_pb_input_header_id;
      QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(l_price_book_messages_tbl);
      l_price_book_messages_tbl.delete;
      commit;
      retcode := 2;
      errbuf := substr(l_message_text,1,240);
      fnd_file.put_line(FND_FILE.LOG, errbuf);
      RETURN;
  END;

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

--dbms_output.put_line('user id = '||l_user_id);
  --Multi-Org Init since Conc Program is run in a different session (check this)
  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
  END IF;

  fnd_file.put_line(FND_FILE.LOG, 'Orgs initialized');
  fnd_file.put_line(FND_FILE.LOG, 'Price Book Name = '|| l_pb_input_header_rec.price_book_name);
  fnd_file.put_line(FND_FILE.LOG, 'Price Book Type = '|| l_pb_input_header_rec.price_book_type_code);
  fnd_file.put_line(FND_FILE.LOG, 'Customer = '|| l_pb_input_header_rec.customer_attr_value);

  --  SNIMMAGA.
  --
  --  If not already done, initialize the global variable:
  --    G_pb_Processor_Batchsize
  --
  IF ( G_pb_Processor_Batchsize IS NULL ) THEN
    G_pb_Processor_Batchsize :=
          QP_PRICE_BOOK_UTIL.Get_Processing_BatchSize;
  END IF;

  rows  :=  QP_PRICE_BOOK_PVT.G_pb_Processor_Batchsize;

  fnd_file.put_line(fnd_file.Log, 'Processing Batch Size: ' ||
                            qp_price_book_pvt.G_pb_Processor_Batchsize);


  IF p_spawned_request = 'N' THEN --Parent request

    fnd_file.put_line(FND_FILE.LOG, 'In Parent Concurrent Request');

    IF l_pb_input_header_rec.publish_existing_pb_flag = 'Y' THEN
                 --Publish existing price book
      BEGIN
        SELECT price_book_header_id
        INTO   l_publish_price_book_header_id
        FROM   qp_price_book_headers_vl
        WHERE  customer_id = l_pb_input_header_rec.customer_attr_value
        AND    price_book_type_code =
                       l_pb_input_header_rec.price_book_type_code
        AND    price_book_name = l_pb_input_header_rec.price_book_name;
      EXCEPTION
        WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('QP', 'QP_PRICE_BOOK_DOES_NOT_EXIST');
           FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          l_pb_input_header_rec.price_book_name);
           FND_MESSAGE.SET_TOKEN('PRICE_BOOK_TYPE_CODE',
                          l_pb_input_header_rec.price_book_type_code);
           l_message_text := FND_MESSAGE.GET;
           l_price_book_messages_tbl(i).message_code :=
                                   'QP_PRICE_BOOK_DOES_NOT_EXIST';
           l_price_book_messages_tbl(i).message_text := l_message_text;
           l_price_book_messages_tbl(i).pb_input_header_id :=
                                                p_pb_input_header_id;
           QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                               l_price_book_messages_tbl);
           l_price_book_messages_tbl.delete;
           commit;--inserted message with pb_input_header_id
                  --since price_book_header_id not yet usable.
           retcode := 2;
           errbuf := substr(l_message_text,1,240);
           fnd_file.put_line(FND_FILE.LOG, errbuf);
           RETURN;
      END;
fnd_file.put_line(FND_FILE.LOG, ' price book header id to publish '||l_publish_price_book_header_id);
    ELSIF nvl(l_pb_input_header_rec.publish_existing_pb_flag, 'N') = 'N' THEN
      --Generate new price book or existing price book to publish not found

      fnd_file.put_line(FND_FILE.LOG, 'Publish_existing_pb_flag = N');

      BEGIN
        SELECT price_book_header_id, request_id
        INTO   l_overwrite_pb_header_id, l_old_request_id
        FROM   qp_price_book_headers_vl
        WHERE  price_book_name = l_pb_input_header_rec.price_book_name
        AND    price_book_type_code =
                                 l_pb_input_header_rec.price_book_type_code
        AND    customer_id = l_pb_input_header_rec.customer_attr_value;
      EXCEPTION
        WHEN OTHERS THEN
          l_overwrite_pb_header_id := NULL;
      END;

      IF nvl(l_pb_input_header_rec.overwrite_existing_pb_flag, 'N') = 'Y' THEN

        IF l_overwrite_pb_header_id IS NOT NULL THEN

          --Get concurrent request status for request_id of the price book to be
          --overwritten
          l_result := fnd_concurrent.get_request_status(
                       request_id => l_old_request_id, --Input parameter
                       phase => l_req_phase,
                       status => l_req_status,
                       dev_phase => l_req_dev_phase,
                       dev_status => l_req_dev_status,
                       message => l_req_message);

          IF nvl(l_req_dev_phase, 'COMPLETE') <> 'COMPLETE' THEN
            l_price_book_messages_tbl(i).message_code :=
                         'QP_CONC_REQUEST_IN_PROGRESS';
            l_message_text := substr(sqlerrm, 1, 240);
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
            QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
            l_price_book_messages_tbl.delete;
            commit; --inserted message with pb_input_header_id
                    --since price_book_header_id not yet usable.
            retcode := 2;
            errbuf := l_message_text;
            fnd_file.put_line(FND_FILE.LOG, errbuf);
            RETURN;

          ELSE --Old Request is Null or Completed
            DELETE FROM qp_price_book_headers_b
            WHERE  price_book_header_id = l_overwrite_pb_header_id
            RETURNING pb_input_header_id, document_id
            INTO l_old_input_header_id, l_document_id;

            DELETE FROM qp_price_book_headers_tl
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_price_book_lines
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_price_book_line_details
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_price_book_attributes
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_price_book_break_lines
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_price_book_messages
            WHERE  price_book_header_id = l_overwrite_pb_header_id;

            DELETE FROM qp_documents
            WHERE  document_id = l_document_id;

            DELETE FROM qp_price_book_messages
            WHERE  pb_input_header_id = l_old_input_header_id;

            DELETE FROM qp_pb_input_headers_b
            WHERE  pb_input_header_id = l_old_input_header_id;

            DELETE FROM qp_pb_input_headers_tl
            WHERE  pb_input_header_id = l_old_input_header_id;

            DELETE FROM qp_pb_input_lines
            WHERE  pb_input_header_id = l_old_input_header_id;

            --If full price book is to be overwritten, then delete the
            --corresponding Delta price book
            IF l_pb_input_header_rec.price_book_type_code = 'F' THEN
              BEGIN
                SELECT price_book_header_id, request_id
                INTO   l_corr_delta_pb_header_id, l_old_delta_request_id
                FROM   qp_price_book_headers_vl
                WHERE  price_book_name = l_pb_input_header_rec.price_book_name
                AND    price_book_type_code = 'D'
                AND    customer_id = l_pb_input_header_rec.customer_attr_value;
              EXCEPTION
                WHEN OTHERS THEN
                  l_corr_delta_pb_header_id := NULL;
              END;

              IF l_corr_delta_pb_header_id IS NOT NULL THEN

                --Get concurrent request status for request_id of the
                --corresponding delta price book to be overwritten
                l_result := fnd_concurrent.get_request_status(
                       request_id => l_old_delta_request_id, --Input parameter
                       phase => l_req_phase,
                       status => l_req_status,
                       dev_phase => l_req_dev_phase,
                       dev_status => l_req_dev_status,
                       message => l_req_message);

                IF nvl(l_req_dev_phase, 'COMPLETE') <> 'COMPLETE' THEN
                  rollback; --Delete stmts on corresponding Full Price Book data
                  l_price_book_messages_tbl(i).message_code :=
                               'QP_CONC_REQUEST_IN_PROGRESS';
                  l_message_text := substr(sqlerrm, 1, 240);
                  l_price_book_messages_tbl(i).message_text := l_message_text;
                  l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
                  QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
                  l_price_book_messages_tbl.delete;
                  commit; --inserted message with pb_input_header_id
                          --since price_book_header_id not yet usable.
                  retcode := 2;
                  errbuf := l_message_text;
                  fnd_file.put_line(FND_FILE.LOG, errbuf);
                  RETURN;

                ELSE --Old Delta Request is Null or Complete
                  DELETE FROM qp_price_book_headers_b
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id
                  RETURNING pb_input_header_id, document_id
                  INTO l_delta_input_header_id, l_delta_document_id;

                  DELETE FROM qp_price_book_headers_tl
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_price_book_lines
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_price_book_line_details
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_price_book_attributes
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_price_book_break_lines
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_price_book_messages
                  WHERE  price_book_header_id = l_corr_delta_pb_header_id;

                  DELETE FROM qp_documents
                  WHERE  document_id = l_delta_document_id;

                  DELETE FROM qp_price_book_messages
                  WHERE  pb_input_header_id = l_delta_input_header_id;

                  DELETE FROM qp_pb_input_headers_b
                  WHERE  pb_input_header_id = l_delta_input_header_id;

                  DELETE FROM qp_pb_input_headers_tl
                  WHERE  pb_input_header_id = l_delta_input_header_id;

                  DELETE FROM qp_pb_input_lines
                  WHERE  pb_input_header_id = l_delta_input_header_id;

                END IF; --If Old Delta Request is Not Null or Complete

              END IF; --If l_corr_delta_pb_header_id is not null

            END IF; --If full price book is being overwritten

          END IF; --If Old request is not Null or Completed

        END IF; --If l_overwrite_pb_header_id is not null

        fnd_file.put_line(FND_FILE.LOG, 'Before inserting price book header');

        --Create Price Book Header
        BEGIN
          QP_PRICE_BOOK_UTIL.Insert_Price_Book_Header(
                  p_pb_input_header_rec => l_pb_input_header_rec,
                  x_price_book_header_id => l_publish_price_book_header_id);

          fnd_file.put_line(FND_FILE.LOG, 'After inserting price book header'||
                          to_char(l_publish_price_book_header_id));
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            FND_MESSAGE.SET_NAME('QP', 'QP_PB_EXISTS_IN_ANOTHER_ORG');
            FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          l_pb_input_header_rec.price_book_name);
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code :=
                         'QP_PB_EXISTS_IN_ANOTHER_ORG';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
            QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
            l_price_book_messages_tbl.delete;
            commit; --inserted message with pb_input_header_id
                    --since price_book_header_id not yet usable.
            retcode := 2;
            errbuf := l_message_text;
            fnd_file.put_line(FND_FILE.LOG, errbuf);
            RETURN;

          WHEN OTHERS THEN
            l_price_book_messages_tbl(i).message_code :=
                         'INSERT_PRICE_BOOK_HEADER_ERROR';
            l_message_text := substr(sqlerrm, 1, 240);
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
            QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
            l_price_book_messages_tbl.delete;
            commit; --inserted message with pb_input_header_id
                    --since price_book_header_id not yet usable.
            retcode := 2;
            errbuf := l_message_text;
            fnd_file.put_line(FND_FILE.LOG, errbuf);
            RETURN;
        END;

--dbms_output.put_line('Conc Program price book header id = '||l_publish_price_book_header_id);
      ELSE --If overwrite_flag = 'N'

        IF l_overwrite_pb_header_id IS NULL THEN

          BEGIN
            --Create Price Book Header
            QP_PRICE_BOOK_UTIL.Insert_Price_Book_Header(
                    p_pb_input_header_rec => l_pb_input_header_rec,
                    x_price_book_header_id => l_publish_price_book_header_id);
          EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
              FND_MESSAGE.SET_NAME('QP', 'QP_PB_EXISTS_IN_ANOTHER_ORG');
              FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          l_pb_input_header_rec.price_book_name);
              l_message_text := FND_MESSAGE.GET;
              l_price_book_messages_tbl(i).message_code :=
                         'QP_PB_EXISTS_IN_ANOTHER_ORG';
              l_price_book_messages_tbl(i).message_text := l_message_text;
              l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
              QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
              l_price_book_messages_tbl.delete;
              commit; --inserted message with pb_input_header_id
                      --since price_book_header_id not yet usable.
              retcode := 2;
              errbuf := l_message_text;
              fnd_file.put_line(FND_FILE.LOG, errbuf);
              RETURN;

            WHEN OTHERS THEN
              l_price_book_messages_tbl(i).message_code :=
                         'INSERT_PRICE_BOOK_HEADER_ERROR';
              l_message_text := substr(sqlerrm, 1, 240);
              l_price_book_messages_tbl(i).message_text := l_message_text;
              l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
              QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
              l_price_book_messages_tbl.delete;
              commit; --inserted message with pb_input_header_id
                      --since price_book_header_id not yet usable.
              retcode := 2;
              errbuf := l_message_text;
              fnd_file.put_line(FND_FILE.LOG, errbuf);
              RETURN;
          END;

        ELSE
          FND_MESSAGE.SET_NAME('QP', 'QP_PRICE_BOOK_ALREADY_EXISTS');
          FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          l_pb_input_header_rec.price_book_name);
          FND_MESSAGE.SET_TOKEN('PRICE_BOOK_TYPE_CODE',
                          l_pb_input_header_rec.price_book_type_code);
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code :=
                         'QP_PRICE_BOOK_ALREADY_EXISTS';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_id;
          QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
          l_price_book_messages_tbl.delete;
          commit; --inserted message with pb_input_header_id
                  --since price_book_header_id not yet usable.
          retcode := 2;
          errbuf := substr(l_message_text,1,240);
          fnd_file.put_line(FND_FILE.LOG, errbuf);
          RETURN;
        END IF; --overwrite_price_book_header_id is null

      END IF;--If overwrite flag = 'Y'

      --Get Item-Uom combinations and create preliminary price book lines
      --that will be updated by child process with information obtained from
      --pricing engine
      l_item_validation_org_id := QP_UTIL.Get_Item_Validation_Org;

      fnd_file.put_line(FND_FILE.LOG, 'Item Validation Org = ' ||
                          to_char(l_item_validation_org_id));
--dbms_output.put_line('l_item_validation_org_id = '||l_item_validation_org_id);
      IF l_pb_input_header_rec.limit_products_by = 'PRICE_LIST' THEN

        fnd_file.put_line(fnd_file.Log, 'limit products by  = PRICE_LIST ');
        fnd_file.put_line(fnd_file.Log, 'pl_agr_bsa_id = '||l_pb_input_header_rec.pl_agr_bsa_id);

        --For items in price list
        OPEN pl_items_cur(l_pb_input_header_rec.pl_agr_bsa_id);
        LOOP
          l_item_tbl.delete;

          FETCH pl_items_cur BULK COLLECT INTO l_item_tbl LIMIT rows;

          IF l_item_tbl.COUNT > 0 THEN
--dbms_output.put_line(' item tbl count '||l_item_tbl.count);
            FOR i IN  l_item_tbl.FIRST..l_item_tbl.LAST
            LOOP
              --get item-uom combinations and insert prelim pricebook lines
              OPEN item_uom_cur(l_item_tbl(i), l_item_validation_org_id,
                                l_pb_input_header_rec.effective_date);
              LOOP
                l_item2_tbl.delete;
                l_uom_tbl.delete;

                FETCH item_uom_cur BULK COLLECT INTO  l_item2_tbl, l_uom_tbl
                LIMIT rows;

--dbms_output.put_line(' item2 tbl count '||l_item2_tbl.count);
                FORALL j IN l_item2_tbl.FIRST..l_item2_tbl.LAST
                  INSERT INTO qp_price_book_lines
                  (price_book_line_id,
                   price_book_header_id,
                   item_number,
                   product_uom_code,
                   sync_action_code,
                   creation_date,
                   created_by,
                   last_update_date,
                   last_updated_by,
                   last_update_login
                    )
                  VALUES
                  (qp_price_book_lines_s.nextval,
                   l_publish_price_book_header_id,
                   l_item2_tbl(j),
                   l_uom_tbl(j),
                   'R',
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   l_login_id
                  );

                EXIT WHEN item_uom_cur%NOTFOUND;

              END LOOP; --Loop over item_uom_cur
              CLOSE item_uom_cur;

            END LOOP; --For loop over l_item_tbl
          END IF; --If l_item_tbl.count > 0

          EXIT WHEN pl_items_cur%NOTFOUND;

        END LOOP; --loop over pl_items_cur
        CLOSE pl_items_cur;


      ELSIF l_pb_input_header_rec.limit_products_by = 'ITEM' THEN

        --get item and uom combinations for item and insert prelim price book lines
        fnd_file.put_line(fnd_file.Log, 'limit_products_by = ITEM');

        OPEN item_uom_cur(l_pb_input_header_rec.product_attr_value,
                          l_item_validation_org_id,
                          l_pb_input_header_rec.effective_date);
        LOOP
          l_item2_tbl.delete;
          l_uom_tbl.delete;

          FETCH item_uom_cur BULK COLLECT INTO  l_item2_tbl, l_uom_tbl
          LIMIT rows;

          FORALL j IN l_item2_tbl.FIRST..l_item2_tbl.LAST
            INSERT INTO qp_price_book_lines
            (price_book_line_id,
             price_book_header_id,
             item_number,
             product_uom_code,
             sync_action_code,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
            )
            VALUES
            (qp_price_book_lines_s.nextval,
             l_publish_price_book_header_id,
             l_item2_tbl(j),
             l_uom_tbl(j),
             'R',
             sysdate,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id
            );

          EXIT WHEN item_uom_cur%NOTFOUND;

        END LOOP; --Loop over item_uom_cur
        CLOSE item_uom_cur;


      ELSIF l_pb_input_header_rec.limit_products_by = 'ITEM_CATEGORY' THEN

         --For items in category
         fnd_file.put_line(fnd_file.Log, 'limit_products_by = ITEM_CATEGORY');

         OPEN cat_items_cur(l_pb_input_header_rec.product_attr_value,
                            l_item_validation_org_id);
         LOOP
           l_item_tbl.delete;
           FETCH cat_items_cur BULK COLLECT INTO l_item_tbl LIMIT rows;

           IF l_item_tbl.COUNT > 0 THEN
             FOR i IN  l_item_tbl.FIRST..l_item_tbl.LAST
             LOOP
             --get item and uom combinations and insert prelim pricebook lines
               OPEN item_uom_cur(l_item_tbl(i),
                                 l_item_validation_org_id,
                                 l_pb_input_header_rec.effective_date);
               LOOP
                 l_item2_tbl.delete;
                 l_uom_tbl.delete;

                 FETCH item_uom_cur BULK COLLECT INTO l_item2_tbl, l_uom_tbl
                 LIMIT rows;

                 FORALL j IN l_item2_tbl.FIRST..l_item2_tbl.LAST
                   INSERT INTO qp_price_book_lines
                   (price_book_line_id,
                    price_book_header_id,
                    item_number,
                    product_uom_code,
                    sync_action_code,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    last_update_login
                   )
                   VALUES
                   (qp_price_book_lines_s.nextval,
                    l_publish_price_book_header_id,
                    l_item2_tbl(j),
                    l_uom_tbl(j),
                    'R',
                    sysdate,
                    l_user_id,
                    sysdate,
                    l_user_id,
                    l_login_id
                   );

                 EXIT WHEN item_uom_cur%NOTFOUND;

               END LOOP; --Loop over item_uom_cur
               CLOSE item_uom_cur;

             END LOOP; --For loop over l_item_tbl
           END IF; --If l_item_tbl.count > 0

           EXIT WHEN cat_items_cur%NOTFOUND;

         END LOOP; --loop over cat_items_cur
         CLOSE cat_items_cur;


      ELSIF l_pb_input_header_rec.limit_products_by = 'ALL_ITEMS' THEN

        --get all item-uom combinations and create price book lines
        fnd_file.put_line(fnd_file.Log, 'limit_products_by = ALL_ITEMS');

        OPEN items_cur(l_item_validation_org_id,
                       l_pb_input_header_rec.pricing_perspective_code);
        LOOP
          l_item_tbl.delete;
          FETCH items_cur BULK COLLECT INTO l_item_tbl LIMIT rows;

          IF l_item_tbl.COUNT > 0 THEN
            FOR i IN  l_item_tbl.FIRST..l_item_tbl.LAST
            LOOP
              --get item-uom combinations and insert prelim pricebook lines
              OPEN item_uom_cur(l_item_tbl(i),
                                l_item_validation_org_id,
                                l_pb_input_header_rec.effective_date);
              LOOP
                l_item2_tbl.delete;
                l_uom_tbl.delete;

                FETCH item_uom_cur BULK COLLECT INTO l_item2_tbl, l_uom_tbl
                LIMIT rows;

                FORALL j IN l_item2_tbl.FIRST..l_item2_tbl.LAST
                  INSERT INTO qp_price_book_lines
                  (price_book_line_id,
                   price_book_header_id,
                   item_number,
                   product_uom_code,
                   sync_action_code,
                   creation_date,
                   created_by,
                   last_update_date,
                   last_updated_by,
                   last_update_login
                  )
                  VALUES
                  (qp_price_book_lines_s.nextval,
                   l_publish_price_book_header_id,
                   l_item2_tbl(j),
                   l_uom_tbl(j),
                   'R',
                   sysdate,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   l_login_id
                  );

                EXIT WHEN item_uom_cur%NOTFOUND;

              END LOOP; --Loop over item_uom_cur
              CLOSE item_uom_cur;

            END LOOP; --For loop over l_item_tbl
          END IF; --if l_item_tbl.count > 0

          EXIT WHEN items_cur%NOTFOUND;

        END LOOP; --loop over items_cur
        CLOSE items_cur;

      END IF; --If limit_products_by is price_list, item or item_category

    END IF; --Publish existing price book

    fnd_file.put_line(FND_FILE.LOG, 'Preparing to submit child request');

--dbms_output.put_line('Came to end');--test code to be removed
--commit; --test code to be removed

    IF l_pb_input_header_rec.generation_time_code = 'SCHEDULE' THEN
      l_submit :=
           fnd_date.date_to_canonical(l_pb_input_header_rec.gen_schedule_date);
    END IF;

    fnd_file.put_line(FND_FILE.LOG, 'Before submitting child request');

    --submit a child concurrent request

    l_child_request_id := FND_REQUEST.SUBMIT_REQUEST(
     'QP', 'QPXPRBKB', 'Price Book Generate and Publish', l_submit, FALSE,
      l_pb_input_header_rec.pb_input_header_id,
      l_pb_input_header_rec.customer_attr_value,
      l_publish_price_book_header_id,
      'Y');

--dbms_output.put_line('child request id = '||l_child_request_id);

    IF l_child_request_id = 0 THEN
      errbuf := substr(FND_MESSAGE.GET, 1, 240);
      retcode := 2;
      fnd_file.put_line(FND_FILE.LOG, errbuf);
    ELSE --submit request successful
      errbuf := '';
      retcode := 0;

      UPDATE qp_price_book_headers_b
      SET    request_id = l_child_request_id
      WHERE  price_book_header_id = l_publish_price_book_header_id;

      COMMIT; --to complete request submission

--dbms_output.put_line('after submitting child request ');
      fnd_file.put_line(FND_FILE.LOG, 'After submitting child request');

    END IF; --If child_request_id = 0

  ELSE --p_spawned_request = 'Y'

    fnd_file.put_line(FND_FILE.LOG, 'In child request');

    --generate engine debug file if the 'QP: Debug' profile is on
    IF FND_PROFILE.VALUE_SPECIFIC(name => 'QP_DEBUG', application_id => 661)
       IN ('Y','V')
    THEN
      oe_debug_pub.SetDebugLevel(10);
      oe_debug_pub.Initialize;
      oe_debug_pub.debug_on;
      l_debug_file := oe_debug_pub.Set_Debug_Mode('FILE');
      fnd_file.put_line(FND_FILE.LOG, 'Engine Debug File = '||l_debug_file);
    END IF;

    IF nvl(l_pb_input_header_rec.publish_existing_pb_flag, 'N') = 'N' THEN
                                            --Price Book is to be generated

      SELECT * BULK COLLECT
      INTO   l_pb_input_lines_tbl
      FROM   qp_pb_input_lines
      WHERE  pb_input_header_id = p_pb_input_header_id;

      fnd_file.put_line(FND_FILE.LOG, 'Before Insert_Price_Book_Content ');

      --Create price book line details, pricing attributes, price break lines
      BEGIN
        Insert_Price_Book_Content(
            p_pb_input_header_rec => l_pb_input_header_rec,
            p_pb_input_lines_tbl  => l_pb_input_lines_tbl,
            p_price_book_header_id => p_price_book_header_id);
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_price_book_messages_tbl(i).message_code :=
                         'QP_NO_PB_LINES_TO_PRICE';
          FND_MESSAGE.SET_NAME('FND', 'QP_NO_PB_LINES_TO_PRICE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
          l_price_book_messages_tbl(i).price_book_header_id :=
                                 p_price_book_header_id;
          QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
          l_price_book_messages_tbl.delete;
          commit;
          retcode := 0;
          RETURN;
      END;

      fnd_file.put_line(FND_FILE.LOG, 'After Insert_Price_Book_Content ');

      --Update price book line details with running net price
      OPEN pb_lines_cur;
      LOOP
        l_line_id_tbl.delete;
        l_list_price_tbl.delete;
        l_line_det_id_tbl2.delete;
        l_net_price_tbl.delete;
        l_line_id_tbl2.delete;
        m := 1;

        FETCH pb_lines_cur BULK COLLECT INTO l_line_id_tbl, l_list_price_tbl;

        IF l_line_id_tbl.COUNT > 0 THEN
          FOR i IN l_line_id_tbl.FIRST..l_line_id_tbl.LAST
          LOOP
            l_line_det_id_tbl.delete;
            l_adjustment_amount_tbl.delete;

            --For each pricebook line set the starting net_price to list_price
            l_net_price := nvl(l_list_price_tbl(i), 0);

            SELECT /*+ index(qpbdtls qp_price_book_line_details_n1) */
		qpbdtls.price_book_line_det_id, qpbdtls.adjustment_amount --bug 8933586
            BULK COLLECT INTO l_line_det_id_tbl, l_adjustment_amount_tbl
            FROM   qp_price_book_line_details qpbdtls
            WHERE  qpbdtls.price_book_line_id = l_line_id_tbl(i)
            ORDER BY qpbdtls.price_book_line_det_id;

            IF l_line_det_id_tbl.COUNT > 0 THEN
              --For each pricebook line det id, calculate cumulative net price
              FOR j IN l_line_det_id_tbl.FIRST..l_line_det_id_tbl.LAST
              LOOP
                l_net_price := l_net_price + nvl(l_adjustment_amount_tbl(j),0);
                --copy the line det plsql tables to another set of plsql
                --tables which will hold all line details for all lines in
                --current iteration of pb_lines_cur
                l_line_det_id_tbl2(m) := l_line_det_id_tbl(j);
                l_net_price_tbl(m) := l_net_price;
                l_line_id_tbl2(m) := l_line_id_tbl(i);
                m := m + 1; --increment m
              END LOOP; --Loop over l_line_det_id_tbl
            END IF; --If l_line_det_id_tbl.count > 0

          END LOOP; --Loop over l_line_id_tbl
        END IF;

        --Bulk update price book line details with cumulative net prices
        --for all line details belonging to all lines in current iteration of
        --pb_lines_cur
        FORALL m IN l_line_det_id_tbl2.FIRST..l_line_det_id_tbl2.LAST
          UPDATE qp_price_book_line_details
          SET    adjusted_net_price = l_net_price_tbl(m)
          WHERE  price_book_line_det_id = l_line_det_id_tbl2(m);

        --Bulk update the net price on the summary price book line to the
        --the calculated running net price. This is to ensure that the summary
        --net price includes any freight and special charges.
        FORALL m IN l_line_id_tbl2.FIRST..l_line_id_tbl2.LAST
          UPDATE qp_price_book_lines
          SET    net_price = l_net_price_tbl(m)
          WHERE  price_book_line_id = l_line_id_tbl2(m);

        EXIT WHEN pb_lines_cur%NOTFOUND;

      END LOOP; --Loop over pb_lines_cur


      --Create Delta price book
      IF l_pb_input_header_rec.price_book_type_code = 'D' THEN
        BEGIN
          Create_Delta_Price_Book(p_price_book_header_id,
                                  l_pb_input_header_rec.price_book_name,
                                  l_pb_input_header_rec.customer_attr_value);
        EXCEPTION
          WHEN OTHERS THEN
            l_price_book_messages_tbl(i).message_code :=
                         'CREATE_DELTA_PRICE_BOOK_ERROR';
            l_message_text := substr(sqlerrm, 1, 240);
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_id;
            l_price_book_messages_tbl(i).price_book_header_id :=
                                 p_price_book_header_id;
            QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(
                                              l_price_book_messages_tbl);
            l_price_book_messages_tbl.delete;
            commit;
            retcode := 2;
            errbuf := l_message_text;
            fnd_file.put_line(FND_FILE.LOG, errbuf);
            RETURN;
        END;
      END IF;

    ELSE --publish_existing_pb_flag = 'Y'

      --Delete publish-related error messages for the previous publish request
      DELETE FROM qp_price_book_messages
      WHERE  price_book_header_id = p_price_book_header_id
      AND    message_code like 'PUB_%';

      --Republish request has null template-code
      IF l_pb_input_header_rec.pub_template_code IS NULL THEN

        BEGIN
          --select the previous document_id if it exists on the price book
          SELECT document_id
          INTO   l_document_id
          FROM   qp_price_book_headers_all_b
          WHERE  price_book_header_id = p_price_book_header_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_document_id := null;
        END;

        IF l_document_id IS NOT NULL THEN
          UPDATE qp_price_book_headers_all_b
          SET    document_id = null
          WHERE  price_book_header_id = p_price_book_header_id;

          DELETE FROM qp_documents
          WHERE  document_id = l_document_id;
        END IF;

      END IF; --template-code is null

    END IF; --publish_existing_pb_flag = 'N', i.e. price book is to be generated

    --Publish the price book identified by p_price_book_header_id
    fnd_file.put_line(FND_FILE.LOG,'Begin Publishing');
	/** KDURGASI **/
	SELECT PUB_OUTPUT_DOCUMENT_TYPE
	INTO l_document_type
	FROM QP_PB_INPUT_HEADERS_B
	WHERE pb_input_header_id = p_pb_input_header_id;

	QP_PRICE_BOOK_UTIL.GENERATE_PRICE_BOOK_XML
	(
	  p_price_book_header_id,
	  QP_PRICE_BOOK_UTIL.get_content_type(l_document_type),
	  QP_PRICE_BOOK_UTIL.get_document_name(p_pb_input_header_id,l_document_type),
	  l_return_status,
	  l_return_status_text
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	/** KDURGASI **/
    --If a template has been specified
    IF l_pb_input_header_rec.pub_template_code IS NOT NULL
    THEN

      QP_PRICE_BOOK_UTIL.Publish_and_Deliver(
              p_pb_input_header_id => p_pb_input_header_id,
          p_price_book_header_id => p_price_book_header_id,
          x_return_status => l_return_status,
          x_return_status_text =>  l_return_status_text);

      fnd_file.put_line(FND_FILE.LOG, 'Publish_and_Deliver return status '||l_return_status);
      fnd_file.put_line(FND_FILE.LOG, 'Publish_and_Deliver return text'||l_return_status_text);

    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      retcode := 1;
      errbuf := l_return_status_text;
    END IF;

    --If XML Message flag checked
    IF l_pb_input_header_rec.dlv_xml_flag = 'Y' THEN
      QP_PRICE_BOOK_UTIL.Send_Sync_Catalog(
                              p_price_book_header_id => p_price_book_header_id,
                              x_return_status => l_return_status,
                              x_return_status_text => l_return_status_text);
      fnd_file.put_line(FND_FILE.LOG, 'XML Message return status '||l_return_status);
      fnd_file.put_line(FND_FILE.LOG, 'XML Message return text'||l_return_status_text);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_price_book_messages_tbl(i).message_code := 'SYNC_CATALOG_ERROR';
        l_price_book_messages_tbl(i).message_text := l_return_status_text;
        l_price_book_messages_tbl(i).pb_input_header_id := p_pb_input_header_id;
        l_price_book_messages_tbl(i).price_book_header_id := p_price_book_header_id;
        QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(l_price_book_messages_tbl);
        l_price_book_messages_tbl.delete;
        commit;
        retcode := 1;
        errbuf := l_return_status_text;
        i := i + 1;
      END IF;

    END IF; --If xml flag checked

    fnd_file.put_line(FND_FILE.LOG,'Done Publishing');

    IF FND_PROFILE.VALUE_SPECIFIC(name => 'QP_DEBUG', application_id => 661)
       IN ('Y','V')
    THEN
      oe_debug_pub.debug_off;
    END IF;

  END IF; -- p_spawned_request = 'N'

  COMMIT;

  -- Introduced for the purpose of PL/SQL Profiling (snimmaga)
/*
  fnd_file.put_line(fnd_file.Log, 'Stopping PL/SQL Profiler...');
  err := DBMS_PROFILER.STOP_PROFILER ;
*/

EXCEPTION
  WHEN OTHERS THEN
    l_message_text := substr(sqlerrm, 1, 240);
    l_price_book_messages_tbl(i).message_code := 'PRICE_BOOK_CONC_PGM_ERROR';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                               l_pb_input_header_rec.pb_input_header_id;
    l_price_book_messages_tbl(i).price_book_header_id := p_price_book_header_id;
    QP_PRICE_BOOK_UTIL.Insert_Price_Book_Messages(l_price_book_messages_tbl);
    l_price_book_messages_tbl.delete;
    commit;
    retcode := 2;
    errbuf := l_message_text;
    fnd_file.put_line(FND_FILE.LOG, errbuf);
END Price_Book_Conc_Pgm;


END qp_price_book_pvt;

/
