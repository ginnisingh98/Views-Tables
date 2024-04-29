--------------------------------------------------------
--  DDL for Package Body QP_COPY_DEBUG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_COPY_DEBUG_PVT" AS
/* $Header: QPXVCDBB.pls 120.0 2005/06/02 01:26:08 appldev noship $ */
l_debug VARCHAR2(3);
PROCEDURE Insert_Request IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  INSERT INTO
  qp_debug_req( REQUEST_ID,
                REQUEST_NAME,
                ORDER_NUMBER,   -- sfiresto 2374448
                CREATED_BY,
                CREATION_DATE,
                PRICING_EVENT,
                CALCULATE_FLAG,
                SIMULATION_FLAG,
                REQUEST_TYPE_CODE,
                VIEW_CODE,
                ROUNDING_FLAG,
                GSA_CHECK_FLAG,
                GSA_DUP_CHECK_FLAG,
                TEMP_TABLE_INSERT_FLAG,
                MANUAL_DISCOUNT_FLAG,
                DEBUG_FLAG,
                SOURCE_ORDER_AMOUNT_FLAG,
                PUBLIC_API_CALL_FLAG,
                MANUAL_ADJUSTMENTS_CALL_FLAG,
                CHECK_CUST_VIEW_FLAG,
                CURRENCY_CODE
              )
         VALUES
              ( g_control_rec.REQUEST_ID,
                g_control_rec.REQUEST_NAME,
                g_control_rec.ORDER_NUMBER,  -- sfiresto 2374448
                g_control_rec.CREATED_BY,
                g_control_rec.CREATION_DATE,
                g_control_rec.PRICING_EVENT,
                g_control_rec.CALCULATE_FLAG,
                nvl(g_control_rec.SIMULATION_FLAG,'N'),
                g_control_rec.REQUEST_TYPE_CODE,
                g_control_rec.VIEW_CODE,
                nvl(g_control_rec.ROUNDING_FLAG,'N'),
                nvl(g_control_rec.GSA_CHECK_FLAG,'N'),
                nvl(g_control_rec.GSA_DUP_CHECK_FLAG,'N'),
                nvl(g_control_rec.TEMP_TABLE_INSERT_FLAG,'N'),
                nvl(g_control_rec.MANUAL_DISCOUNT_FLAG,'N'),
                nvl(g_control_rec.DEBUG_FLAG,'N'),
                nvl(g_control_rec.SOURCE_ORDER_AMOUNT_FLAG,'N'),
                nvl(g_control_rec.PUBLIC_API_CALL_FLAG,'N'),
                nvl(g_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG,'N'),
                nvl(g_control_rec.CHECK_CUST_VIEW_FLAG,'N'),
                g_control_rec.currency_code
              );

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Inserted 1 Record into QP_DEBUG_REQ***');
  END IF;
 -- dbms_output.put_line('***Inserted 1 Record into QP_DEBUG_REQ***');
  COMMIT;

END Insert_Request;

PROCEDURE Insert_Line IS
PRAGMA AUTONOMOUS_TRANSACTION;
  Tbl_Index       NUMBER;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF LINE_ID_T.COUNT >= 1 then
    FORALL Tbl_Index IN LINE_ID_T.FIRST .. LINE_ID_T.LAST
      INSERT INTO
      QP_DEBUG_REQ_LINES( REQUEST_ID,
                          REQUEST_TYPE_CODE,
                          LINE_NUMBER,       -- sfiresto 2374448
                          LINE_ID,
                          LINE_INDEX,
                          LINE_TYPE_CODE,
                          PRICING_EFFECTIVE_DATE,
                          LINE_QUANTITY,
                          LINE_UOM_CODE,
                          PRICED_QUANTITY,
                          PRICED_UOM_CODE,
                          UOM_QUANTITY,
                          CURRENCY_CODE,
                          UNIT_PRICE,
                          PERCENT_PRICE,
                          ADJUSTED_UNIT_PRICE,
                          PARENT_PRICE,
                          PARENT_QUANTITY,
                          PARENT_UOM_CODE,
                          PROCESSING_ORDER,
                          PROCESSED_FLAG,
                          PROCESSED_CODE,
                          PRICE_FLAG,
                          PRICING_STATUS_CODE,
                          PRICING_STATUS_TEXT,
                          START_DATE_ACTIVE_FIRST,
                          ACTIVE_DATE_FIRST_TYPE,
                          START_DATE_ACTIVE_SECOND,
                          ACTIVE_DATE_SECOND_TYPE,
                          GROUP_QUANTITY,
                          GROUP_AMOUNT,
                          LINE_AMOUNT,
                          ROUNDING_FLAG,
                          ROUNDING_FACTOR,
                          UPDATED_ADJUSTED_UNIT_PRICE,
                          PRICE_REQUEST_CODE,
                          HOLD_CODE,
                          HOLD_TEXT,
                          PRICE_LIST_HEADER_ID,
                          VALIDATED_FLAG,
                          QUALIFIERS_EXIST_FLAG,
                          PRICING_ATTRS_EXIST_FLAG,
                          PRIMARY_QUALIFIERS_MATCH_FLAG,
                          USAGE_PRICING_TYPE
                        )
                   VALUES
                        ( REQUEST_ID_T(Tbl_Index),
                          REQUEST_TYPE_CODE_T(Tbl_Index),
                          LINE_NUMBER_T(Tbl_Index),       -- sfiresto 2374448
                          LINE_ID_T(Tbl_Index),
                          LINE_INDEX_T(Tbl_Index),
                          LINE_TYPE_CODE_T(Tbl_Index),
                          PRICING_EFFECTIVE_DATE_T(Tbl_Index),
                          LINE_QUANTITY_T(Tbl_Index),
                          LINE_UOM_CODE_T(Tbl_Index),
                          PRICED_QUANTITY_T(Tbl_Index),
                          PRICED_UOM_CODE_T(Tbl_Index),
                          UOM_QUANTITY_T(Tbl_Index),
                          CURRENCY_CODE_T(Tbl_Index),
                          UNIT_PRICE_T(Tbl_Index),
                          PERCENT_PRICE_T(Tbl_Index),
                          ADJUSTED_UNIT_PRICE_T(Tbl_Index),
                          PARENT_PRICE_T(Tbl_Index),
                          PARENT_QUANTITY_T(Tbl_Index),
                          PARENT_UOM_CODE_T(Tbl_Index),
                          PROCESSING_ORDER_T(Tbl_Index),
                          nvl(PROCESSED_FLAG_T(Tbl_Index),'N'),
                          PROCESSED_CODE_T(Tbl_Index),
                          PRICE_FLAG_T(Tbl_Index),
                          PRICING_STATUS_CODE_T(Tbl_Index),
                          PRICING_STATUS_TEXT_T(Tbl_Index),
                          START_DATE_ACTIVE_FIRST_T(Tbl_Index),
                          ACTIVE_DATE_FIRST_TYPE_T(Tbl_Index),
                          START_DATE_ACTIVE_SECOND_T(Tbl_Index),
                          ACTIVE_DATE_SECOND_TYPE_T(Tbl_Index),
                          GROUP_QUANTITY_T(Tbl_Index),
                          GROUP_AMOUNT_T(Tbl_Index),
                          LINE_AMOUNT_T(Tbl_Index),
                          nvl(ROUNDING_FLAG_T(Tbl_Index),'N'),
                          ROUNDING_FACTOR_T(Tbl_Index),
                          UPDATED_ADJUSTED_UNIT_PRICE_T(Tbl_Index),
                          PRICE_REQUEST_CODE_T(Tbl_Index),
                          HOLD_CODE_T(Tbl_Index),
                          HOLD_TEXT_T(Tbl_Index),
                          PRICE_LIST_HEADER_ID_T(Tbl_Index),
                          nvl(VALIDATED_FLAG_T(Tbl_Index),'N'),
                          nvl(QUALIFIERS_EXIST_FLAG_T(Tbl_Index),'N'),
                          nvl(PRICING_ATTRS_EXIST_FLAG_T(Tbl_Index),'N'),
                          nvl(PRIMARY_QUAL_MATCH_FLAG_T(Tbl_Index),'N'),
                          USAGE_PRICING_TYPE_T(Tbl_Index)
                        );

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Inserted ' || LINE_ID_T.COUNT || ' Records into QP_DEBUG_REQ_LINES***');
      END IF;
     -- dbms_output.put_line('***Inserted 1 Record into QP_DEBUG_REQ_LINES***');
    COMMIT;
  REQUEST_ID_T.delete;
  REQUEST_TYPE_CODE_T.delete;
  LINE_ID_T.delete;
  LINE_INDEX_T.delete;
  LINE_TYPE_CODE_T.delete;
  PRICING_EFFECTIVE_DATE_T.delete;
  LINE_QUANTITY_T.delete;
  LINE_UOM_CODE_T.delete;
  PRICED_QUANTITY_T.delete;
  PRICED_UOM_CODE_T.delete;
  UOM_QUANTITY_T.delete;
  CURRENCY_CODE_T.delete;
  UNIT_PRICE_T.delete;
  PERCENT_PRICE_T.delete;
  ADJUSTED_UNIT_PRICE_T.delete;
  PARENT_PRICE_T.delete;
  PARENT_QUANTITY_T.delete;
  PARENT_UOM_CODE_T.delete;
  PROCESSING_ORDER_T.delete;
  PROCESSED_FLAG_T.delete;
  PROCESSED_CODE_T.delete;
  PRICE_FLAG_T.delete;
  PRICING_STATUS_CODE_T.delete;
  PRICING_STATUS_TEXT_T.delete;
  START_DATE_ACTIVE_FIRST_T.delete;
  ACTIVE_DATE_FIRST_TYPE_T.delete;
  START_DATE_ACTIVE_SECOND_T.delete;
  ACTIVE_DATE_SECOND_TYPE_T.delete;
  GROUP_QUANTITY_T.delete;
  GROUP_AMOUNT_T.delete;
  LINE_AMOUNT_T.delete;
  ROUNDING_FLAG_T.delete;
  ROUNDING_FACTOR_T.delete;
  UPDATED_ADJUSTED_UNIT_PRICE_T.delete;
  PRICE_REQUEST_CODE_T.delete;
  HOLD_CODE_T.delete;
  HOLD_TEXT_T.delete;
  PRICE_LIST_HEADER_ID_T.delete;
  VALIDATED_FLAG_T.delete;
  QUALIFIERS_EXIST_FLAG_T.delete;
  PRICING_ATTRS_EXIST_FLAG_T.delete;
  PRIMARY_QUAL_MATCH_FLAG_T.delete;
  USAGE_PRICING_TYPE_T.delete;
  END IF;
END Insert_Line;

PROCEDURE Insert_LDet IS
PRAGMA AUTONOMOUS_TRANSACTION;
  Tbl_Index       NUMBER;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF LINE_DETAIL_INDEX_T.COUNT >= 1 then
    FORALL Tbl_Index IN LINE_DETAIL_INDEX_T.FIRST .. LINE_DETAIL_INDEX_T.LAST
      INSERT INTO
      QP_DEBUG_REQ_LDETS( REQUEST_ID,
                          LINE_DETAIL_INDEX,
                          LINE_DETAIL_TYPE_CODE,
                          PRICE_BREAK_TYPE_CODE,
                          LINE_INDEX,
                          CREATED_FROM_LIST_HEADER_ID,
                          CREATED_FROM_LIST_LINE_ID,
                          CREATED_FROM_LIST_LINE_TYPE,
                          CREATED_FROM_LIST_TYPE_CODE,
                          MODIFIER_LEVEL_CODE,
                          CREATED_FROM_SQL,
                          PRICING_GROUP_SEQUENCE,
                          OPERAND_CALCULATION_CODE,
                          OPERAND_VALUE,
                          ADJUSTMENT_AMOUNT,
                          LINE_QUANTITY,
                          SUBSTITUTION_TYPE_CODE,
                          SUBSTITUTION_VALUE_FROM,
                          SUBSTITUTION_VALUE_TO,
                          ASK_FOR_FLAG,
                          PRICE_FORMULA_ID,
                          PROCESSED_FLAG,
                          PRICING_STATUS_CODE,
                          PRICING_STATUS_TEXT,
                          PRODUCT_PRECEDENCE,
                          INCOMPATABILITY_GRP_CODE,
                          BEST_PERCENT,
                          PRICING_PHASE_ID,
                          APPLIED_FLAG,
                          AUTOMATIC_FLAG,
                          OVERRIDE_FLAG,
                          PRINT_ON_INVOICE_FLAG,
                          PRIMARY_UOM_FLAG,
                          BENEFIT_QTY,
                          BENEFIT_UOM_CODE,
                          LIST_LINE_NO,
                          ACCRUAL_FLAG,
                          ACCRUAL_CONVERSION_RATE,
                          ESTIM_ACCRUAL_RATE,
                          RECURRING_FLAG,
                          SELECTED_VOLUME_ATTR,
                          ROUNDING_FACTOR,
                          SECONDARY_PRICELIST_IND,
                          GROUP_QUANTITY,
                          GROUP_AMOUNT,
                          PROCESS_CODE,
                          UPDATED_FLAG,
                          CHARGE_TYPE_CODE,
                          CHARGE_SUBTYPE_CODE,
                          LIMIT_CODE,
                          LIMIT_TEXT,
                          HEADER_LIMIT_EXISTS,
                          LINE_LIMIT_EXISTS
                        )
                   VALUES
                        ( REQUEST_ID_T(Tbl_Index),
                          LINE_DETAIL_INDEX_T(Tbl_Index),
                          LINE_DETAIL_TYPE_CODE_T(Tbl_Index),
                          PRICE_BREAK_TYPE_CODE_T(Tbl_Index),
                          LINE_INDEX_T(Tbl_Index),
                          LIST_HEADER_ID_T(Tbl_Index),
                          LIST_LINE_ID_T(Tbl_Index),
                          LIST_LINE_TYPE_T(Tbl_Index),
                          LIST_TYPE_CODE_T(Tbl_Index),
                          MODIFIER_LEVEL_CODE_T(Tbl_Index),
                          CREATED_FROM_SQL_T(Tbl_Index),
                          PRICING_GROUP_SEQUENCE_T(Tbl_Index),
                          OPERAND_CALCULATION_CODE_T(Tbl_Index),
                          OPERAND_VALUE_T(Tbl_Index),
                          ADJUSTMENT_AMOUNT_T(Tbl_Index),
                          LINE_QUANTITY_T(Tbl_Index),
                          SUBSTITUTION_TYPE_CODE_T(Tbl_Index),
                          SUBSTITUTION_VALUE_FROM_T(Tbl_Index),
                          SUBSTITUTION_VALUE_TO_T(Tbl_Index),
                          nvl(ASK_FOR_FLAG_T(Tbl_Index),'N'),
                          PRICE_FORMULA_ID_T(Tbl_Index),
                          nvl(PROCESSED_FLAG_T(Tbl_Index),'N'),
                          PRICING_STATUS_CODE_T(Tbl_Index),
                          PRICING_STATUS_TEXT_T(Tbl_Index),
                          PRODUCT_PRECEDENCE_T(Tbl_Index),
                          INCOMPATABILITY_GRP_CODE_T(Tbl_Index),
                          BEST_PERCENT_T(Tbl_Index),
                          PRICING_PHASE_ID_T(Tbl_Index),
                          nvl(APPLIED_FLAG_T(Tbl_Index),'N'),
                          nvl(AUTOMATIC_FLAG_T(Tbl_Index),'N'),
                          nvl(OVERRIDE_FLAG_T(Tbl_Index),'N'),
                          nvl(PRINT_ON_INVOICE_FLAG_T(Tbl_Index),'N'),
                          nvl(PRIMARY_UOM_FLAG_T(Tbl_Index),'N'),
                          BENEFIT_QTY_T(Tbl_Index),
                          BENEFIT_UOM_CODE_T(Tbl_Index),
                          LIST_LINE_NO_T(Tbl_Index),
                          nvl(ACCRUAL_FLAG_T(Tbl_Index),'N'),
                          ACCRUAL_CONVERSION_RATE_T(Tbl_Index),
                          ESTIM_ACCRUAL_RATE_T(Tbl_Index),
                          RECURRING_FLAG_T(Tbl_Index),
                          SELECTED_VOLUME_ATTR_T(Tbl_Index),
                          ROUNDING_FACTOR_T(Tbl_Index),
                          SECONDARY_PRICELIST_IND_T(Tbl_Index),
                          GROUP_QUANTITY_T(Tbl_Index),
                          GROUP_AMOUNT_T(Tbl_Index),
                          PROCESS_CODE_T(Tbl_Index),
                          nvl(UPDATED_FLAG_T(Tbl_Index),'N'),
                          CHARGE_TYPE_CODE_T(Tbl_Index),
                          CHARGE_SUBTYPE_CODE_T(Tbl_Index),
                          LIMIT_CODE_T(Tbl_Index),
                          LIMIT_TEXT_T(Tbl_Index),
                          nvl(HEADER_LIMIT_EXISTS_T(Tbl_Index),'N'),
                          nvl(LINE_LIMIT_EXISTS_T(Tbl_Index),'N')
                        );

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Inserted ' || LINE_DETAIL_INDEX_T.COUNT || ' Records into QP_DEBUG_REQ_LDETS***');
      END IF;
     -- dbms_output.put_line('***Inserted ' || LINE_DETAIL_INDEX_T.COUNT || ' Records into QP_DEBUG_REQ_LDETS***');

    COMMIT;
  REQUEST_ID_T.delete;
  LINE_DETAIL_INDEX_T.delete;
  LINE_DETAIL_TYPE_CODE_T.delete;
  PRICE_BREAK_TYPE_CODE_T.delete;
  LINE_INDEX_T.delete;
  LIST_HEADER_ID_T.delete;
  LIST_LINE_ID_T.delete;
  LIST_LINE_TYPE_T.delete;
  LIST_TYPE_CODE_T.delete;
  MODIFIER_LEVEL_CODE_T.delete;
  CREATED_FROM_SQL_T.delete;
  PRICING_GROUP_SEQUENCE_T.delete;
  OPERAND_CALCULATION_CODE_T.delete;
  OPERAND_VALUE_T.delete;
  ADJUSTMENT_AMOUNT_T.delete;
  LINE_QUANTITY_T.delete;
  SUBSTITUTION_TYPE_CODE_T.delete;
  SUBSTITUTION_VALUE_FROM_T.delete;
  SUBSTITUTION_VALUE_TO_T.delete;
  ASK_FOR_FLAG_T.delete;
  PRICE_FORMULA_ID_T.delete;
  PROCESSED_FLAG_T.delete;
  PRICING_STATUS_CODE_T.delete;
  PRICING_STATUS_TEXT_T.delete;
  PRODUCT_PRECEDENCE_T.delete;
  INCOMPATABILITY_GRP_CODE_T.delete;
  BEST_PERCENT_T.delete;
  PRICING_PHASE_ID_T.delete;
  APPLIED_FLAG_T.delete;
  AUTOMATIC_FLAG_T.delete;
  OVERRIDE_FLAG_T.delete;
  PRINT_ON_INVOICE_FLAG_T.delete;
  PRIMARY_UOM_FLAG_T.delete;
  BENEFIT_QTY_T.delete;
  BENEFIT_UOM_CODE_T.delete;
  LIST_LINE_NO_T.delete;
  ACCRUAL_FLAG_T.delete;
  ACCRUAL_CONVERSION_RATE_T.delete;
  ESTIM_ACCRUAL_RATE_T.delete;
  RECURRING_FLAG_T.delete;
  SELECTED_VOLUME_ATTR_T.delete;
  ROUNDING_FACTOR_T.delete;
  SECONDARY_PRICELIST_IND_T.delete;
  GROUP_QUANTITY_T.delete;
  GROUP_AMOUNT_T.delete;
  PROCESS_CODE_T.delete;
  UPDATED_FLAG_T.delete;
  CHARGE_TYPE_CODE_T.delete;
  CHARGE_SUBTYPE_CODE_T.delete;
  LIMIT_CODE_T.delete;
  LIMIT_TEXT_T.delete;
  HEADER_LIMIT_EXISTS_T.delete;
  LINE_LIMIT_EXISTS_T.delete;
  END IF;

END Insert_LDet;

PROCEDURE Insert_Line_Attr IS
PRAGMA AUTONOMOUS_TRANSACTION;
  Tbl_Index       NUMBER;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF LINE_INDEX_T.COUNT >= 1 then
   -- dbms_output.put_line('***attrs - 5***');
    FORALL Tbl_Index IN LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST
      INSERT INTO
      QP_DEBUG_REQ_LINE_ATTRS( REQUEST_ID,
                               LINE_INDEX,
                               LINE_DETAIL_INDEX,
                               LINE_ATTRIBUTE_ID,
                               ATTRIBUTE_LEVEL,
                               ATTRIBUTE_TYPE,
                               LIST_HEADER_ID,
                               LIST_LINE_ID,
                               CONTEXT,
                               ATTRIBUTE,
                               VALUE_FROM,
                               SETUP_VALUE_FROM,
                               VALUE_TO,
                               SETUP_VALUE_TO,
                               GROUPING_NUMBER,
                               NO_QUALIFIERS_IN_GRP,
                               COMPARISON_OPERATOR_TYPE_CODE,
                               VALIDATED_FLAG,
                               APPLIED_FLAG,
                               PRICING_STATUS_CODE,
                               PRICING_STATUS_TEXT,
                               QUALIFIER_PRECEDENCE,
                               PRICING_ATTR_FLAG,
                               QUALIFIER_TYPE,
                               DATATYPE,
                               PRODUCT_UOM_CODE,
                               PROCESSED_CODE,
                               EXCLUDER_FLAG,
                               GROUP_QUANTITY,
                               GROUP_AMOUNT,
                               DISTINCT_QUALIFIER_FLAG,
                               PRICING_PHASE_ID,
                               INCOMPATABILITY_GRP_CODE,
                               LINE_DETAIL_TYPE_CODE,
                               MODIFIER_LEVEL_CODE,
                               PRIMARY_UOM_FLAG
                             )
                        VALUES
                             ( REQUEST_ID_T(Tbl_Index),
                               LINE_INDEX_T(Tbl_Index),
                               LINE_DETAIL_INDEX_T(Tbl_Index),
                               LINE_ATTRIBUTE_ID_T(Tbl_Index),
                               ATTRIBUTE_LEVEL_T(Tbl_Index),
                               ATTRIBUTE_TYPE_T(Tbl_Index),
                               LIST_HEADER_ID_T(Tbl_Index),
                               LIST_LINE_ID_T(Tbl_Index),
                               CONTEXT_T(Tbl_Index),
                               ATTRIBUTE_T(Tbl_Index),
                               VALUE_FROM_T(Tbl_Index),
                               SETUP_VALUE_FROM_T(Tbl_Index),
                               VALUE_TO_T(Tbl_Index),
                               SETUP_VALUE_TO_T(Tbl_Index),
                               GROUPING_NUMBER_T(Tbl_Index),
                               NO_QUALIFIERS_IN_GRP_T(Tbl_Index),
                               COMP_OPERATOR_TYPE_CODE_T(Tbl_Index),
                               nvl(VALIDATED_FLAG_T(Tbl_Index),'N'),
                               nvl(APPLIED_FLAG_T(Tbl_Index),'N'),
                               PRICING_STATUS_CODE_T(Tbl_Index),
                               PRICING_STATUS_TEXT_T(Tbl_Index),
                               QUALIFIER_PRECEDENCE_T(Tbl_Index),
                               nvl(PRICING_ATTR_FLAG_T(Tbl_Index),'N'),
                               QUALIFIER_TYPE_T(Tbl_Index),
                               DATATYPE_T(Tbl_Index),
                               PRODUCT_UOM_CODE_T(Tbl_Index),
                               ATTR_PROCESSED_CODE_T(Tbl_Index),
                               nvl(EXCLUDER_FLAG_T(Tbl_Index),'N'),
                               GROUP_QUANTITY_T(Tbl_Index),
                               GROUP_AMOUNT_T(Tbl_Index),
                               nvl(DISTINCT_QUALIFIER_FLAG_T(Tbl_Index),'N'),
                               PRICING_PHASE_ID_T(Tbl_Index),
                               INCOMPATABILITY_GRP_CODE_T(Tbl_Index),
                               LINE_DETAIL_TYPE_CODE_T(Tbl_Index),
                               MODIFIER_LEVEL_CODE_T(Tbl_Index),
                               nvl(PRIMARY_UOM_FLAG_T(Tbl_Index),'N')
                             );
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inserted ' || LINE_INDEX_T.COUNT || ' Records into QP_DEBUG_REQ_LINE_ATTRS***');
    END IF;
   -- dbms_output.put_line('***Inserted ' || LINE_INDEX_T.COUNT || ' Records into QP_DEBUG_REQ_LINE_ATTRS***');
    COMMIT;
   -- dbms_output.put_line('***attrs - 6***');
  REQUEST_ID_T.delete;
  LINE_INDEX_T.delete;
  LINE_DETAIL_INDEX_T.delete;
  LINE_ATTRIBUTE_ID_T.delete;
  ATTRIBUTE_LEVEL_T.delete;
  ATTRIBUTE_TYPE_T.delete;
  LIST_HEADER_ID_T.delete;
  LIST_LINE_ID_T.delete;
  CONTEXT_T.delete;
  ATTRIBUTE_T.delete;
  VALUE_FROM_T.delete;
  SETUP_VALUE_FROM_T.delete;
  VALUE_TO_T.delete;
  SETUP_VALUE_TO_T.delete;
  GROUPING_NUMBER_T.delete;
  NO_QUALIFIERS_IN_GRP_T.delete;
  COMP_OPERATOR_TYPE_CODE_T.delete;
  VALIDATED_FLAG_T.delete;
  APPLIED_FLAG_T.delete;
  PRICING_STATUS_CODE_T.delete;
  PRICING_STATUS_TEXT_T.delete;
  QUALIFIER_PRECEDENCE_T.delete;
  PRICING_ATTR_FLAG_T.delete;
  QUALIFIER_TYPE_T.delete;
  DATATYPE_T.delete;
  PRODUCT_UOM_CODE_T.delete;
  PROCESSED_CODE_T.delete;
  EXCLUDER_FLAG_T.delete;
  GROUP_QUANTITY_T.delete;
  GROUP_AMOUNT_T.delete;
  DISTINCT_QUALIFIER_FLAG_T.delete;
  PRICING_PHASE_ID_T.delete;
  INCOMPATABILITY_GRP_CODE_T.delete;
  LINE_DETAIL_TYPE_CODE_T.delete;
  MODIFIER_LEVEL_CODE_T.delete;
  PRIMARY_UOM_FLAG_T.delete;
  END IF;
END Insert_Line_Attr;

PROCEDURE Insert_RLTD_Line IS
PRAGMA AUTONOMOUS_TRANSACTION;
  Tbl_Index       NUMBER;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF LINE_INDEX_T.COUNT >= 1 then
    FORALL Tbl_Index IN LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST
      INSERT INTO
      QP_DEBUG_REQ_RLTD_LINES( REQUEST_ID,
                               REQUEST_TYPE_CODE,
                               LINE_INDEX,
                               LINE_DETAIL_INDEX,
                               RELATIONSHIP_TYPE_CODE,
                               RELATED_LINE_INDEX,
                               RELATED_LINE_DETAIL_INDEX,
                               PRICING_STATUS_CODE,
                               PRICING_STATUS_TEXT,
                               LIST_LINE_ID,
                               RELATED_LIST_LINE_ID,
                               RELATED_LIST_LINE_TYPE,
                               OPERAND_CALCULATION_CODE,
                               OPERAND,
                               PRICING_GROUP_SEQUENCE,
                               RELATIONSHIP_TYPE_DETAIL,
                               SETUP_VALUE_FROM,
                               SETUP_VALUE_TO,
                               QUALIFIER_VALUE,
                               ADJUSTMENT_AMOUNT,
                               SATISFIED_RANGE_VALUE
                             )
                        VALUES
                             ( REQUEST_ID_T(Tbl_Index),
                               REQUEST_TYPE_CODE_T(Tbl_Index),
                               LINE_INDEX_T(Tbl_Index),
                               LINE_DETAIL_INDEX_T(Tbl_Index),
                               RELATIONSHIP_TYPE_CODE_T(Tbl_Index),
                               RELATED_LINE_INDEX_T(Tbl_Index),
                               RELATED_LINE_DETAIL_INDEX_T(Tbl_Index),
                               PRICING_STATUS_CODE_T(Tbl_Index),
                               PRICING_STATUS_TEXT_T(Tbl_Index),
                               LIST_LINE_ID_T(Tbl_Index),
                               RELATED_LIST_LINE_ID_T(Tbl_Index),
                               LIST_LINE_TYPE_T(Tbl_Index),
                               OPERAND_CALCULATION_CODE_T(Tbl_Index),
                               OPERAND_T(Tbl_Index),
                               PRICING_GROUP_SEQUENCE_T(Tbl_Index),
                               RELATIONSHIP_TYPE_DETAIL_T(Tbl_Index),
                               SETUP_VALUE_FROM_T(Tbl_Index),
                               SETUP_VALUE_TO_T(Tbl_Index),
                               QUALIFIER_VALUE_T(Tbl_Index),
                               ADJUSTMENT_AMOUNT_T(Tbl_Index),
                               SATISFIED_RANGE_VALUE_T(Tbl_Index)
                             );

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Inserted ' || LINE_INDEX_T.COUNT || ' Record into QP_DEBUG_REQ_RLTD_LINES***');
      END IF;
     -- dbms_output.put_line('***Inserted ' || LINE_INDEX_T.COUNT || ' Record into QP_DEBUG_REQ_RLTD_LINES***');

    COMMIT;
  REQUEST_ID_T.delete;
  REQUEST_TYPE_CODE_T.delete;
  LINE_INDEX_T.delete;
  LINE_DETAIL_INDEX_T.delete;
  RELATIONSHIP_TYPE_CODE_T.delete;
  LINE_INDEX_T.delete;
  LINE_DETAIL_INDEX_T.delete;
  PRICING_STATUS_CODE_T.delete;
  PRICING_STATUS_TEXT_T.delete;
  LIST_LINE_ID_T.delete;
  LIST_LINE_ID_T.delete;
  LIST_LINE_TYPE_T.delete;
  OPERAND_CALCULATION_CODE_T.delete;
  OPERAND_T.delete;
  PRICING_GROUP_SEQUENCE_T.delete;
  RELATIONSHIP_TYPE_DETAIL_T.delete;
  SETUP_VALUE_FROM_T.delete;
  SETUP_VALUE_TO_T.delete;
  QUALIFIER_VALUE_T.delete;
  ADJUSTMENT_AMOUNT_T.delete;
  SATISFIED_RANGE_VALUE_T.delete;
  END IF;

END Insert_RLTD_Line;

PROCEDURE Insert_Step_Values IS
PRAGMA AUTONOMOUS_TRANSACTION;
  Tbl_Index       NUMBER;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF LINE_INDEX_T.COUNT >= 1 then
    FORALL Tbl_Index IN LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST
      INSERT INTO
      QP_DEBUG_FORMULA_STEP_VALUES( REQUEST_ID,
                                    PRICE_FORMULA_ID,
                                    STEP_NUMBER,
                                    COMPONENT_VALUE,
                                    PRICE_FORMULA_LINE_TYPE_CODE,
                                    LINE_INDEX,
                                    LIST_LINE_TYPE_CODE,
                                    LIST_HEADER_ID,
                                    LIST_LINE_ID
                                  )
                             VALUES
                                  ( REQUEST_ID_T(Tbl_Index),
                                    PRICE_FORMULA_ID_T(Tbl_Index),
                                    STEP_NUMBER_T(Tbl_Index),
                                    COMPONENT_VALUE_T(Tbl_Index),
                                    PRICE_FORM_LINE_TYPE_CODE_T(Tbl_Index),
                                    LINE_INDEX_T(Tbl_Index),
                                    LIST_LINE_TYPE_T(Tbl_Index),
                                    LIST_HEADER_ID_T(Tbl_Index),
                                    LIST_LINE_ID_T(Tbl_Index)
                                   );

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Inserted ' || LINE_INDEX_T.COUNT || ' Record into QP_DEBUG_FORMULA_STEP_VALUES***');
      END IF;
     -- dbms_output.put_line('***Inserted ' || LINE_INDEX_T.COUNT || ' Record into QP_DEBUG_FORMULA_STEP_VALUES***');

    COMMIT;
  REQUEST_ID_T.delete;
  PRICE_FORMULA_ID_T.delete;
  STEP_NUMBER_T.delete;
  COMPONENT_VALUE_T.delete;
  PRICE_FORM_LINE_TYPE_CODE_T.delete;
  LINE_INDEX_T.delete;
  LIST_LINE_TYPE_T.delete;
  LIST_HEADER_ID_T.delete;
  LIST_LINE_ID_T.delete;
  END IF;

END Insert_Step_Values;

FUNCTION REQUEST_ID RETURN NUMBER IS
BEGIN
RETURN G_DEBUG_REQUEST_ID;
END REQUEST_ID;

PROCEDURE INSERT_DEBUG_LINE(p_text                 IN   VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF (G_DEBUG_TEXT_LINE_NO is null) or (G_DEBUG_REQUEST_ID is null) then
   -- dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: '|| 'This line cannot be written into QP_DEBUG_TEXT');
     return;
  else
   -- dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: '|| 'Written one line into QP_DEBUG_TEXT');
     G_DEBUG_TEXT_LINE_NO := G_DEBUG_TEXT_LINE_NO + 1;

     INSERT INTO qp_debug_text(REQUEST_ID,MESSAGE_LINE_NO,MESSAGE_TEXT)
     VALUES (G_DEBUG_REQUEST_ID, G_DEBUG_TEXT_LINE_NO, p_text);
     COMMIT;
  end if;
EXCEPTION
  WHEN OTHERS THEN
   -- dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: '|| SQLERRM);
    ROLLBACK;
END INSERT_DEBUG_LINE;

PROCEDURE Generate_Debug_Req_Seq(x_return_status   out NOCOPY   varchar2,
                                 x_status_text     out NOCOPY   varchar2)
IS
 CURSOR DEBUG_REQUEST_ID_CUR IS
        SELECT qp_debug_req_s.nextval FROM dual;
l_request_id       number;
BEGIN
-- dbms_output.put_line('*** Initializing Global Variables***');
 G_DEBUG_TEXT_LINE_NO := 0;
 OPEN DEBUG_REQUEST_ID_CUR;
      FETCH DEBUG_REQUEST_ID_CUR INTO l_request_id;
      G_DEBUG_REQUEST_ID := l_request_id;
      if (DEBUG_REQUEST_ID_CUR%NOTFOUND) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_status_text := 'DEBUG_REQUEST_ID_CUR Not Found - ' || SQLERRM;
      end if;
 CLOSE DEBUG_REQUEST_ID_CUR;
-- dbms_output.put_line('G_DEBUG_REQUEST_ID - ' || G_DEBUG_REQUEST_ID || ', G_DEBUG_TEXT_LINE_NO - ' || G_DEBUG_TEXT_LINE_NO);
EXCEPTION
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_status_text := 'DEBUG_REQUEST_ID_CUR Not Found - ' || SQLERRM;
END Generate_Debug_Req_Seq;

PROCEDURE SET_REQUEST_TO_NULL IS
BEGIN
 G_DEBUG_REQUEST_ID := null;
END SET_REQUEST_TO_NULL;

PROCEDURE WRITE_TO_DEBUG_TABLES(p_control_rec          IN   QP_PREQ_GRP.CONTROL_RECORD_TYPE,
                                x_return_status        OUT  NOCOPY VARCHAR2,
                                x_return_status_text   OUT  NOCOPY VARCHAR2)
IS

  CURSOR lines_cur IS
  SELECT REQUEST_TYPE_CODE,
         LINE_ID,
         LINE_INDEX,
         LINE_TYPE_CODE,
         PRICING_EFFECTIVE_DATE,
         LINE_QUANTITY,
         LINE_UOM_CODE,
         PRICED_QUANTITY,
         PRICED_UOM_CODE,
         UOM_QUANTITY,
         CURRENCY_CODE,
         UNIT_PRICE,
         PERCENT_PRICE,
         ADJUSTED_UNIT_PRICE,
         PARENT_PRICE,
         PARENT_QUANTITY,
         PARENT_UOM_CODE,
         PROCESSING_ORDER,
         PROCESSED_FLAG,
         PROCESSED_CODE,
         PRICE_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         START_DATE_ACTIVE_FIRST,
         ACTIVE_DATE_FIRST_TYPE,
         START_DATE_ACTIVE_SECOND,
         ACTIVE_DATE_SECOND_TYPE,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         LINE_AMOUNT,
         ROUNDING_FLAG,
         ROUNDING_FACTOR,
         UPDATED_ADJUSTED_UNIT_PRICE,
         PRICE_REQUEST_CODE,
         HOLD_CODE,
         HOLD_TEXT,
         PRICE_LIST_HEADER_ID,
         VALIDATED_FLAG,
         QUALIFIERS_EXIST_FLAG,
         PRICING_ATTRS_EXIST_FLAG,
         PRIMARY_QUALIFIERS_MATCH_FLAG,
         USAGE_PRICING_TYPE,
         LINE_CATEGORY,
         CONTRACT_START_DATE,
         CONTRACT_END_DATE,
         NULL                            -- sfiresto 2374448
  FROM qp_npreq_lines_tmp
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
  --added by yangli for Java Engine 3086881
  UNION ALL
  SELECT REQUEST_TYPE_CODE,
         LINE_ID,
         LINE_INDEX,
         LINE_TYPE_CODE,
         PRICING_EFFECTIVE_DATE,
         LINE_QUANTITY,
         LINE_UOM_CODE,
         PRICED_QUANTITY,
         PRICED_UOM_CODE,
         UOM_QUANTITY,
         CURRENCY_CODE,
         UNIT_PRICE,
         PERCENT_PRICE,
         ADJUSTED_UNIT_PRICE,
         PARENT_PRICE,
         PARENT_QUANTITY,
         PARENT_UOM_CODE,
         PROCESSING_ORDER,
         PROCESSED_FLAG,
         PROCESSED_CODE,
         PRICE_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         START_DATE_ACTIVE_FIRST,
         ACTIVE_DATE_FIRST_TYPE,
         START_DATE_ACTIVE_SECOND,
         ACTIVE_DATE_SECOND_TYPE,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         LINE_AMOUNT,
         ROUNDING_FLAG,
         ROUNDING_FACTOR,
         UPDATED_ADJUSTED_UNIT_PRICE,
         PRICE_REQUEST_CODE,
         HOLD_CODE,
         HOLD_TEXT,
         PRICE_LIST_HEADER_ID,
         VALIDATED_FLAG,
         QUALIFIERS_EXIST_FLAG,
         PRICING_ATTRS_EXIST_FLAG,
         PRIMARY_QUALIFIERS_MATCH_FLAG,
         USAGE_PRICING_TYPE,
         LINE_CATEGORY,
         CONTRACT_START_DATE,
         CONTRACT_END_DATE,
         NULL                            -- sfiresto 2374448
  FROM qp_int_lines
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
  --added by yangli for Java Engine 3086881
  ORDER BY line_index;

  CURSOR LDETS_CUR IS
  SELECT LINE_DETAIL_INDEX,
         LINE_DETAIL_TYPE_CODE,
         PRICE_BREAK_TYPE_CODE,
         LINE_INDEX,
         CREATED_FROM_LIST_HEADER_ID,
         CREATED_FROM_LIST_LINE_ID,
         CREATED_FROM_LIST_LINE_TYPE,
         CREATED_FROM_LIST_TYPE_CODE,
         MODIFIER_LEVEL_CODE,
         CREATED_FROM_SQL,
         PRICING_GROUP_SEQUENCE,
         OPERAND_CALCULATION_CODE,
         OPERAND_VALUE,
         ADJUSTMENT_AMOUNT,
         LINE_QUANTITY,
         SUBSTITUTION_TYPE_CODE,
         SUBSTITUTION_VALUE_FROM,
         SUBSTITUTION_VALUE_TO,
         ASK_FOR_FLAG,
         PRICE_FORMULA_ID,
         PROCESSED_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         PRODUCT_PRECEDENCE,
         INCOMPATABILITY_GRP_CODE,
         BEST_PERCENT,
         PRICING_PHASE_ID,
         APPLIED_FLAG,
         AUTOMATIC_FLAG,
         OVERRIDE_FLAG,
         PRINT_ON_INVOICE_FLAG,
         PRIMARY_UOM_FLAG,
         BENEFIT_QTY,
         BENEFIT_UOM_CODE,
         LIST_LINE_NO,
         ACCRUAL_FLAG,
         ACCRUAL_CONVERSION_RATE,
         ESTIM_ACCRUAL_RATE,
         RECURRING_FLAG,
         SELECTED_VOLUME_ATTR,
         ROUNDING_FACTOR,
         SECONDARY_PRICELIST_IND,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         PROCESS_CODE,
         UPDATED_FLAG,
         CHARGE_TYPE_CODE,
         CHARGE_SUBTYPE_CODE,
         LIMIT_CODE,
         LIMIT_TEXT,
         HEADER_LIMIT_EXISTS,
         LINE_LIMIT_EXISTS,
         CALCULATION_CODE,
         CURRENCY_HEADER_ID,
         PRICING_EFFECTIVE_DATE,
         BASE_CURRENCY_CODE,
         ORDER_CURRENCY,
         CURRENCY_DETAIL_ID
  FROM qp_npreq_ldets_tmp
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
  --added by yangli for Java Engine 3086881
  UNION ALL
  SELECT LINE_DETAIL_INDEX,
         LINE_DETAIL_TYPE_CODE,
         PRICE_BREAK_TYPE_CODE,
         LINE_INDEX,
         CREATED_FROM_LIST_HEADER_ID,
         CREATED_FROM_LIST_LINE_ID,
         CREATED_FROM_LIST_LINE_TYPE,
         CREATED_FROM_LIST_TYPE_CODE,
         MODIFIER_LEVEL_CODE,
         CREATED_FROM_SQL,
         PRICING_GROUP_SEQUENCE,
         OPERAND_CALCULATION_CODE,
         OPERAND_VALUE,
         ADJUSTMENT_AMOUNT,
         LINE_QUANTITY,
         SUBSTITUTION_TYPE_CODE,
         SUBSTITUTION_VALUE_FROM,
         SUBSTITUTION_VALUE_TO,
         ASK_FOR_FLAG,
         PRICE_FORMULA_ID,
         PROCESSED_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         PRODUCT_PRECEDENCE,
         INCOMPATABILITY_GRP_CODE,
         BEST_PERCENT,
         PRICING_PHASE_ID,
         APPLIED_FLAG,
         AUTOMATIC_FLAG,
         OVERRIDE_FLAG,
         PRINT_ON_INVOICE_FLAG,
         PRIMARY_UOM_FLAG,
         BENEFIT_QTY,
         BENEFIT_UOM_CODE,
         LIST_LINE_NO,
         ACCRUAL_FLAG,
         ACCRUAL_CONVERSION_RATE,
         ESTIM_ACCRUAL_RATE,
         RECURRING_FLAG,
         SELECTED_VOLUME_ATTR,
         ROUNDING_FACTOR,
         SECONDARY_PRICELIST_IND,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         PROCESS_CODE,
         UPDATED_FLAG,
         CHARGE_TYPE_CODE,
         CHARGE_SUBTYPE_CODE,
         LIMIT_CODE,
         LIMIT_TEXT,
         HEADER_LIMIT_EXISTS,
         LINE_LIMIT_EXISTS,
         CALCULATION_CODE,
         CURRENCY_HEADER_ID,
         PRICING_EFFECTIVE_DATE,
         BASE_CURRENCY_CODE,
         ORDER_CURRENCY,
         CURRENCY_DETAIL_ID
  FROM qp_int_ldets
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
  --added by yangli for Java Engine 3086881
  ORDER BY LINE_INDEX, LINE_DETAIL_INDEX;

  CURSOR LINE_ATTRS_CUR IS
  SELECT LINE_INDEX,
         LINE_DETAIL_INDEX,
         ATTRIBUTE_LEVEL,
         ATTRIBUTE_TYPE,
         LIST_HEADER_ID,
         LIST_LINE_ID,
         CONTEXT,
         ATTRIBUTE,
         VALUE_FROM,
         SETUP_VALUE_FROM,
         VALUE_TO,
         SETUP_VALUE_TO,
         GROUPING_NUMBER,
         NO_QUALIFIERS_IN_GRP,
         COMPARISON_OPERATOR_TYPE_CODE,
         VALIDATED_FLAG,
         APPLIED_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         QUALIFIER_PRECEDENCE,
         PRICING_ATTR_FLAG,
         QUALIFIER_TYPE,
         DATATYPE,
         PRODUCT_UOM_CODE,
         PROCESSED_CODE,
         EXCLUDER_FLAG,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         DISTINCT_QUALIFIER_FLAG,
         PRICING_PHASE_ID,
         INCOMPATABILITY_GRP_CODE,
         LINE_DETAIL_TYPE_CODE,
         MODIFIER_LEVEL_CODE,
         PRIMARY_UOM_FLAG
  FROM qp_npreq_line_attrs_tmp
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
  --added by yangli for Java Engine 3086881
  UNION ALL
  SELECT LINE_INDEX,
         LINE_DETAIL_INDEX,
         ATTRIBUTE_LEVEL,
         ATTRIBUTE_TYPE,
         LIST_HEADER_ID,
         LIST_LINE_ID,
         CONTEXT,
         ATTRIBUTE,
         VALUE_FROM,
         SETUP_VALUE_FROM,
         VALUE_TO,
         SETUP_VALUE_TO,
         GROUPING_NUMBER,
         NO_QUALIFIERS_IN_GRP,
         COMPARISON_OPERATOR_TYPE_CODE,
         VALIDATED_FLAG,
         APPLIED_FLAG,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         QUALIFIER_PRECEDENCE,
         PRICING_ATTR_FLAG,
         QUALIFIER_TYPE,
         DATATYPE,
         PRODUCT_UOM_CODE,
         PROCESSED_CODE,
         EXCLUDER_FLAG,
         GROUP_QUANTITY,
         GROUP_AMOUNT,
         DISTINCT_QUALIFIER_FLAG,
         PRICING_PHASE_ID,
         INCOMPATABILITY_GRP_CODE,
         LINE_DETAIL_TYPE_CODE,
         MODIFIER_LEVEL_CODE,
         PRIMARY_UOM_FLAG
  FROM qp_int_line_attrs
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
  --added by yangli for Java Engine 3086881
  ORDER BY LINE_INDEX, LINE_DETAIL_INDEX;

  CURSOR RLTD_LINES_CUR IS
  SELECT REQUEST_TYPE_CODE,
         LINE_INDEX,
         LINE_DETAIL_INDEX,
         RELATIONSHIP_TYPE_CODE,
         RELATED_LINE_INDEX,
         RELATED_LINE_DETAIL_INDEX,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         LIST_LINE_ID,
         RELATED_LIST_LINE_ID,
         RELATED_LIST_LINE_TYPE,
         OPERAND_CALCULATION_CODE,
         OPERAND,
         PRICING_GROUP_SEQUENCE,
         RELATIONSHIP_TYPE_DETAIL,
         SETUP_VALUE_FROM,
         SETUP_VALUE_TO,
         QUALIFIER_VALUE,
         ADJUSTMENT_AMOUNT,
         SATISFIED_RANGE_VALUE
  FROM qp_npreq_rltd_lines_tmp
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
  --added by yangli for Java Engine 3086881
  UNION ALL
  SELECT REQUEST_TYPE_CODE,
         LINE_INDEX,
         LINE_DETAIL_INDEX,
         RELATIONSHIP_TYPE_CODE,
         RELATED_LINE_INDEX,
         RELATED_LINE_DETAIL_INDEX,
         PRICING_STATUS_CODE,
         PRICING_STATUS_TEXT,
         LIST_LINE_ID,
         RELATED_LIST_LINE_ID,
         RELATED_LIST_LINE_TYPE,
         OPERAND_CALCULATION_CODE,
         OPERAND,
         PRICING_GROUP_SEQUENCE,
         RELATIONSHIP_TYPE_DETAIL,
         SETUP_VALUE_FROM,
         SETUP_VALUE_TO,
         QUALIFIER_VALUE,
         ADJUSTMENT_AMOUNT,
         SATISFIED_RANGE_VALUE
  FROM qp_int_rltd_lines
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
  --added by yangli for Java Engine 3086881
  ORDER BY LINE_INDEX, LINE_DETAIL_INDEX;

  CURSOR STEP_VALUES_CUR IS
  SELECT PRICE_FORMULA_ID,
         STEP_NUMBER,
         COMPONENT_VALUE,
         PRICE_FORMULA_LINE_TYPE_CODE,
         LINE_INDEX,
         LIST_LINE_TYPE_CODE,
         LIST_HEADER_ID,
         LIST_LINE_ID
  FROM qp_nformula_step_values_tmp
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
  --added by yangli for Java Engine 3086881
  UNION ALL
  SELECT PRICE_FORMULA_ID,
         STEP_NUMBER,
         COMPONENT_VALUE,
         PRICE_FORMULA_LINE_TYPE_CODE,
         LINE_INDEX,
         LIST_LINE_TYPE_CODE,
         LIST_HEADER_ID,
         LIST_LINE_ID
  FROM qp_int_formula_step_values
  WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
  --added by yangli for Java Engine 3086881
  ORDER BY LINE_INDEX, PRICE_FORMULA_ID, STEP_NUMBER;

--  CURSOR REQUEST_ID_CUR IS
--      SELECT qp_debug_req_s.nextval FROM dual;

  CURSOR LINE_ID_CUR IS
      SELECT LINE_ID FROM qp_npreq_lines_tmp
        WHERE    QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
                AND LINE_TYPE_CODE = 'ORDER'
                AND ROWNUM = 1
      UNION ALL
      SELECT LINE_ID FROM qp_int_lines
        WHERE    QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
                AND LINE_TYPE_CODE = 'ORDER'
                AND ROWNUM = 1;

  CURSOR REQUEST_TYPE_CODE_CUR IS
      SELECT REQUEST_TYPE_CODE FROM qp_npreq_lines_tmp
      WHERE   QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
              AND ROWNUM = 1
      UNION ALL
      SELECT REQUEST_TYPE_CODE FROM qp_int_lines
      WHERE   QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
             AND ROWNUM = 1;

  CURSOR CURRENCY_CODE_CUR IS
      SELECT CURRENCY_CODE FROM qp_npreq_lines_tmp
      WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N'
            AND ROWNUM = 1
      UNION ALL
      SELECT CURRENCY_CODE FROM qp_int_lines
      WHERE  QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'Y'
            AND ROWNUM = 1;

  CURSOR LINE_ATTR_ID_CUR is
      SELECT qp_line_attr_s.nextval FROM dual;

  CURSOR ORDER_NUMBER_CUR (p_line_id VARCHAR2) IS   -- sfiresto 2374448
      SELECT ORDER_NUMBER FROM OE_ORDER_HEADERS_ALL
      WHERE header_id = p_line_id;

  l_request_id             NUMBER;
  l_request_name           VARCHAR2(240);
  l_request_type_code      VARCHAR2(30);
  l_line_attribute_id      NUMBER;
  l_creation_date          DATE := SYSDATE;
  l_created_by             NUMBER := nvl(fnd_global.user_id,-1);
  l_line_id                number;
  l_currency_code          VARCHAR2(30);
  Tbl_Index                NUMBER := 0;
  l_set_request_name       VARCHAR2(100) := substr(nvl(fnd_profile.value('QP_SET_REQUEST_NAME'),'N'),1,100);
  l_order_number           VARCHAR2(50);    -- sfiresto 2374448

  REQUEST_TYPE_CODE_NOT_FOUND EXCEPTION;
  CURRENCY_CODE_NOT_FOUND     EXCEPTION;
  ORDER_NUMBER_NOT_FOUND      EXCEPTION;  -- sfiresto 2374448
  l_Rec_Count              Number;

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Begin Duplicating Temp Table Records ***');
  END IF;
 -- dbms_output.put_line('***Begin Duplicating Temp Table Records ***');

  OPEN LINE_ID_CUR;
       FETCH LINE_ID_CUR INTO l_line_id;
       if (LINE_ID_CUR%NOTFOUND) then
          l_request_name := G_DEBUG_REQUEST_ID;
       end if;
  CLOSE LINE_ID_CUR;

  OPEN ORDER_NUMBER_CUR(l_line_id);         -- sfiresto 2374448
       FETCH ORDER_NUMBER_CUR INTO l_order_number;
       if (ORDER_NUMBER_CUR%NOTFOUND) then
         null;
       end if;
  CLOSE ORDER_NUMBER_CUR;

  l_request_name := l_set_request_name || '-' || nvl(l_line_id,l_request_name);

  OPEN REQUEST_TYPE_CODE_CUR;
       FETCH REQUEST_TYPE_CODE_CUR INTO l_request_type_code;
       if (REQUEST_TYPE_CODE_CUR%NOTFOUND) then
          raise REQUEST_TYPE_CODE_NOT_FOUND;
       end if;
  CLOSE REQUEST_TYPE_CODE_CUR;


  OPEN CURRENCY_CODE_CUR;
       FETCH CURRENCY_CODE_CUR INTO l_currency_code;
       if (CURRENCY_CODE_CUR%NOTFOUND) then
          raise CURRENCY_CODE_NOT_FOUND;
       end if;
  CLOSE CURRENCY_CODE_CUR;


  --g_control_rec.REQUEST_ID := l_request_id;
  g_control_rec.REQUEST_ID := G_DEBUG_REQUEST_ID;
  g_control_rec.REQUEST_NAME := l_request_name;
  g_control_rec.ORDER_NUMBER := l_order_number;   -- sfiresto 2374448
  g_control_rec.CREATED_BY := l_created_by;
  g_control_rec.CREATION_DATE := l_creation_date;
  g_control_rec.PRICING_EVENT := p_control_rec.PRICING_EVENT;
  g_control_rec.CALCULATE_FLAG := p_control_rec.CALCULATE_FLAG;
  g_control_rec.SIMULATION_FLAG := p_control_rec.SIMULATION_FLAG;
  g_control_rec.REQUEST_TYPE_CODE := l_REQUEST_TYPE_CODE;
  g_control_rec.VIEW_CODE := p_control_rec.VIEW_CODE;
  g_control_rec.ROUNDING_FLAG := p_control_rec.ROUNDING_FLAG;
  g_control_rec.GSA_CHECK_FLAG := p_control_rec.GSA_CHECK_FLAG;
  g_control_rec.GSA_DUP_CHECK_FLAG := p_control_rec.GSA_DUP_CHECK_FLAG;
  g_control_rec.TEMP_TABLE_INSERT_FLAG := p_control_rec.TEMP_TABLE_INSERT_FLAG;
  g_control_rec.MANUAL_DISCOUNT_FLAG := p_control_rec.MANUAL_DISCOUNT_FLAG;
  g_control_rec.DEBUG_FLAG := p_control_rec.DEBUG_FLAG;
  g_control_rec.SOURCE_ORDER_AMOUNT_FLAG := p_control_rec.SOURCE_ORDER_AMOUNT_FLAG;
  g_control_rec.PUBLIC_API_CALL_FLAG := p_control_rec.PUBLIC_API_CALL_FLAG;
  g_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG := p_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG;
  g_control_rec.CHECK_CUST_VIEW_FLAG := p_control_rec.CHECK_CUST_VIEW_FLAG;
  g_control_rec.CURRENCY_CODE := l_currency_code;

  Insert_Request;

  OPEN lines_cur;
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inside lines_cur Loop***');
    END IF;
   -- dbms_output.put_line('***Inside lines_cur Loop***');
    FETCH lines_cur
      BULK COLLECT INTO
           REQUEST_TYPE_CODE_T,
           LINE_ID_T,
           LINE_INDEX_T,
           LINE_TYPE_CODE_T,
           PRICING_EFFECTIVE_DATE_T,
           LINE_QUANTITY_T,
           LINE_UOM_CODE_T,
           PRICED_QUANTITY_T,
           PRICED_UOM_CODE_T,
           UOM_QUANTITY_T,
           CURRENCY_CODE_T,
           UNIT_PRICE_T,
           PERCENT_PRICE_T,
           ADJUSTED_UNIT_PRICE_T,
           PARENT_PRICE_T,
           PARENT_QUANTITY_T,
           PARENT_UOM_CODE_T,
           PROCESSING_ORDER_T,
           PROCESSED_FLAG_T,
           PROCESSED_CODE_T,
           PRICE_FLAG_T,
           PRICING_STATUS_CODE_T,
           PRICING_STATUS_TEXT_T,
           START_DATE_ACTIVE_FIRST_T,
           ACTIVE_DATE_FIRST_TYPE_T,
           START_DATE_ACTIVE_SECOND_T,
           ACTIVE_DATE_SECOND_TYPE_T,
           GROUP_QUANTITY_T,
           GROUP_AMOUNT_T,
           LINE_AMOUNT_T,
           ROUNDING_FLAG_T,
           ROUNDING_FACTOR_T,
           UPDATED_ADJUSTED_UNIT_PRICE_T,
           PRICE_REQUEST_CODE_T,
           HOLD_CODE_T,
           HOLD_TEXT_T,
           PRICE_LIST_HEADER_ID_T,
           VALIDATED_FLAG_T,
           QUALIFIERS_EXIST_FLAG_T,
           PRICING_ATTRS_EXIST_FLAG_T,
           PRIMARY_QUAL_MATCH_FLAG_T,
           USAGE_PRICING_TYPE_T,
           LINE_CATEGORY_T,
           CONTRACT_START_DATE_T,
           CONTRACT_END_DATE_T,
           LINE_NUMBER_T               -- sfiresto 2374448
        LIMIT 1000;

        IF LINE_ID_T.COUNT <> 0  then
           FOR Tbl_Index in  LINE_ID_T.FIRST .. LINE_ID_T.LAST LOOP
               --REQUEST_ID_T(Tbl_Index):= l_request_id;
               REQUEST_ID_T(Tbl_Index):= G_DEBUG_REQUEST_ID;


               IF l_REQUEST_TYPE_CODE = 'ONT' THEN                   -- sfiresto 2374448
                  IF LINE_TYPE_CODE_T(Tbl_Index) = 'ORDER' THEN
                     LINE_NUMBER_T(Tbl_Index) := l_order_number;
                  ELSIF LINE_TYPE_CODE_T(Tbl_Index) = 'LINE' THEN
                     BEGIN
                       SELECT LINE_NUMBER INTO LINE_NUMBER_T(Tbl_Index)
                       FROM OE_ORDER_LINES_ALL WHERE LINE_ID = LINE_ID_T(Tbl_Index);
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                         NULL;
                     END;
                  END IF;
               END IF;

           END LOOP;
        END IF;

    Insert_Line;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Repeat lines_cur loop for next 1000 lines - if any***');
    END IF;
   -- dbms_output.put_line('***Repeat lines_cur loop for next 1000 lines - if any***');
    EXIT WHEN lines_cur%NOTFOUND;

  END LOOP; -- --loop over main lines_cur
  CLOSE lines_cur;

  OPEN ldets_cur;
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inside ldets_cur Loop***');
    END IF;
   -- dbms_output.put_line('***Inside ldets_cur Loop***');
    FETCH ldets_cur
      BULK COLLECT INTO
         LINE_DETAIL_INDEX_T,
         LINE_DETAIL_TYPE_CODE_T,
         PRICE_BREAK_TYPE_CODE_T,
         LINE_INDEX_T,
         LIST_HEADER_ID_T,
         LIST_LINE_ID_T,
         LIST_LINE_TYPE_T,
         LIST_TYPE_CODE_T,
         MODIFIER_LEVEL_CODE_T,
         CREATED_FROM_SQL_T,
         PRICING_GROUP_SEQUENCE_T,
         OPERAND_CALCULATION_CODE_T,
         OPERAND_VALUE_T,
         ADJUSTMENT_AMOUNT_T,
         LINE_QUANTITY_T,
         SUBSTITUTION_TYPE_CODE_T,
         SUBSTITUTION_VALUE_FROM_T,
         SUBSTITUTION_VALUE_TO_T,
         ASK_FOR_FLAG_T,
         PRICE_FORMULA_ID_T,
         PROCESSED_FLAG_T,
         PRICING_STATUS_CODE_T,
         PRICING_STATUS_TEXT_T,
         PRODUCT_PRECEDENCE_T,
         INCOMPATABILITY_GRP_CODE_T,
         BEST_PERCENT_T,
         PRICING_PHASE_ID_T,
         APPLIED_FLAG_T,
         AUTOMATIC_FLAG_T,
         OVERRIDE_FLAG_T,
         PRINT_ON_INVOICE_FLAG_T,
         PRIMARY_UOM_FLAG_T,
         BENEFIT_QTY_T,
         BENEFIT_UOM_CODE_T,
         LIST_LINE_NO_T,
         ACCRUAL_FLAG_T,
         ACCRUAL_CONVERSION_RATE_T,
         ESTIM_ACCRUAL_RATE_T,
         RECURRING_FLAG_T,
         SELECTED_VOLUME_ATTR_T,
         ROUNDING_FACTOR_T,
         SECONDARY_PRICELIST_IND_T,
         GROUP_QUANTITY_T,
         GROUP_AMOUNT_T,
         PROCESS_CODE_T,
         UPDATED_FLAG_T,
         CHARGE_TYPE_CODE_T,
         CHARGE_SUBTYPE_CODE_T,
         LIMIT_CODE_T,
         LIMIT_TEXT_T,
         HEADER_LIMIT_EXISTS_T,
         LINE_LIMIT_EXISTS_T,
         CALCULATION_CODE_T,
         CURRENCY_HEADER_ID_T,
         PRICING_EFFECTIVE_DATE_T,
         BASE_CURRENCY_CODE_T,
         ORDER_CURRENCY_T,
         CURRENCY_DETAIL_ID_T
      LIMIT 1000;

        IF LINE_DETAIL_INDEX_T.COUNT <> 0  then
           FOR Tbl_Index in  LINE_DETAIL_INDEX_T.FIRST .. LINE_DETAIL_INDEX_T.LAST LOOP
               --REQUEST_ID_T(Tbl_Index):= l_request_id;
               REQUEST_ID_T(Tbl_Index):= G_DEBUG_REQUEST_ID;
           END LOOP;
        END IF;


    Insert_LDet;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Repeat ldets_cur loop for next 1000 lines - if any***');
    END IF;
   -- dbms_output.put_line('***Repeat ldets_cur loop for next 1000 lines - if any***');

    EXIT WHEN ldets_cur%NOTFOUND;
  END LOOP; -- --loop over main ldets_cur
  CLOSE ldets_cur;


  OPEN line_attrs_cur;
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inside line_attrs_cur Loop***');
    END IF;
   -- dbms_output.put_line('***Inside line_attrs_cur Loop***');
    FETCH line_attrs_cur
      BULK COLLECT INTO
         LINE_INDEX_T,
         LINE_DETAIL_INDEX_T,
         ATTRIBUTE_LEVEL_T,
         ATTRIBUTE_TYPE_T,
         LIST_HEADER_ID_T,
         LIST_LINE_ID_T,
         CONTEXT_T,
         ATTRIBUTE_T,
         VALUE_FROM_T,
         SETUP_VALUE_FROM_T,
         VALUE_TO_T,
         SETUP_VALUE_TO_T,
         GROUPING_NUMBER_T,
         NO_QUALIFIERS_IN_GRP_T,
         COMP_OPERATOR_TYPE_CODE_T,
         VALIDATED_FLAG_T,
         APPLIED_FLAG_T,
         PRICING_STATUS_CODE_T,
         PRICING_STATUS_TEXT_T,
         QUALIFIER_PRECEDENCE_T,
         PRICING_ATTR_FLAG_T,
         QUALIFIER_TYPE_T,
         DATATYPE_T,
         PRODUCT_UOM_CODE_T,
         ATTR_PROCESSED_CODE_T,
         EXCLUDER_FLAG_T,
         GROUP_QUANTITY_T,
         GROUP_AMOUNT_T,
         DISTINCT_QUALIFIER_FLAG_T,
         PRICING_PHASE_ID_T,
         INCOMPATABILITY_GRP_CODE_T,
         LINE_DETAIL_TYPE_CODE_T,
         MODIFIER_LEVEL_CODE_T,
         PRIMARY_UOM_FLAG_T
      LIMIT 1000;

   -- dbms_output.put_line('***attrs - 1***');
        IF LINE_INDEX_T.COUNT <> 0  then
   -- dbms_output.put_line('***attrs - 2***');
           FOR Tbl_Index in  LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST LOOP
   -- dbms_output.put_line('***attrs - 3***');
               --REQUEST_ID_T(Tbl_Index):= l_request_id;
               REQUEST_ID_T(Tbl_Index):= G_DEBUG_REQUEST_ID;
               select QP_LINE_ATTR_S.nextval into l_LINE_ATTRIBUTE_ID from dual;
               LINE_ATTRIBUTE_ID_T(Tbl_Index) := l_LINE_ATTRIBUTE_ID;
           END LOOP;
        END IF;

   -- dbms_output.put_line('***attrs - 4***');
    Insert_Line_Attr;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Repeat line_attrs_cur loop for next 1000 lines - if any***');
    END IF;
   -- dbms_output.put_line('***Repeat line_attrs_cur loop for next 1000 lines - if any***');
    EXIT WHEN line_attrs_cur%NOTFOUND;
  END LOOP; -- --loop over main line_attrs_cur
  CLOSE line_attrs_cur;

  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
  select count(*) into l_Rec_Count from qp_npreq_rltd_lines_tmp;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Record count in qp_npreq_rltd_lines_tmp : ' || l_Rec_Count);
  END IF;
  ELSE
  select count(*) into l_Rec_Count from qp_int_rltd_lines;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Record count in qp_int_rltd_lines : ' || l_Rec_Count);
  END IF;
  END IF;
  OPEN rltd_lines_cur;
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inside rltd_lines_cur Loop***');
    END IF;
   -- dbms_output.put_line('***Inside rltd_lines_cur Loop***');
    FETCH rltd_lines_cur
      BULK COLLECT INTO
         REQUEST_TYPE_CODE_T,
         LINE_INDEX_T,
         LINE_DETAIL_INDEX_T,
         RELATIONSHIP_TYPE_CODE_T,
         RELATED_LINE_INDEX_T,
         RELATED_LINE_DETAIL_INDEX_T,
         PRICING_STATUS_CODE_T,
         PRICING_STATUS_TEXT_T,
         LIST_LINE_ID_T,
         RELATED_LIST_LINE_ID_T,
         LIST_LINE_TYPE_T,
         OPERAND_CALCULATION_CODE_T,
         OPERAND_T,
         PRICING_GROUP_SEQUENCE_T,
         RELATIONSHIP_TYPE_DETAIL_T,
         SETUP_VALUE_FROM_T,
         SETUP_VALUE_TO_T,
         QUALIFIER_VALUE_T,
         ADJUSTMENT_AMOUNT_T,
         SATISFIED_RANGE_VALUE_T
      LIMIT 1000;

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('***Inside rltd_lines_cur Loop : After Fetch***');

      QP_PREQ_GRP.engine_debug('LINE_INDEX_T.COUNT:' || LINE_INDEX_T.COUNT);

      END IF;
        IF LINE_INDEX_T.COUNT <> 0  then
           IF l_debug = FND_API.G_TRUE THEN
           QP_PREQ_GRP.engine_debug('inside loop');
           END IF;
           FOR Tbl_Index in  LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST LOOP
               --REQUEST_ID_T(Tbl_Index):= l_request_id;
               REQUEST_ID_T(Tbl_Index):= G_DEBUG_REQUEST_ID;
           END LOOP;
        END IF;

    Insert_RLTD_Line;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Repeat rltd_lines_cur loop for next 1000 lines - if any***');
    END IF;
   -- dbms_output.put_line('***Repeat rltd_lines_cur loop for next 1000 lines - if any***');
    EXIT WHEN rltd_lines_cur%NOTFOUND;
  END LOOP; -- --loop over main rltd_lines_cur
  CLOSE rltd_lines_cur;


  OPEN step_values_cur;
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Inside step_values_cur Loop***');
    END IF;
   -- dbms_output.put_line('***Inside step_values_cur Loop***');
    FETCH step_values_cur
      BULK COLLECT INTO
         PRICE_FORMULA_ID_T,
         STEP_NUMBER_T,
         COMPONENT_VALUE_T,
         PRICE_FORM_LINE_TYPE_CODE_T,
         LINE_INDEX_T,
         LIST_LINE_TYPE_T,
         LIST_HEADER_ID_T,
         LIST_LINE_ID_T
      LIMIT 1000;

        IF LINE_INDEX_T.COUNT <> 0  then
           FOR Tbl_Index in  LINE_INDEX_T.FIRST .. LINE_INDEX_T.LAST LOOP
               --REQUEST_ID_T(Tbl_Index):= l_request_id;
               REQUEST_ID_T(Tbl_Index):= G_DEBUG_REQUEST_ID;
           END LOOP;
        END IF;

    Insert_Step_Values;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Repeat step_values_cur loop for next 1000 lines - if any***');
    END IF;
   -- dbms_output.put_line('***Repeat step_values_cur loop for next 1000 lines - if any***');
    EXIT WHEN step_values_cur%NOTFOUND;
  END LOOP; -- --loop over main step_values_cur
  CLOSE step_values_cur;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***Procedure WRITE_TO_DEBUG_TABLES successfully completed ***');
  END IF;
 -- dbms_output.put_line('***Procedure WRITE_TO_DEBUG_TABLES successfully completed ***');
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('***End Duplicating Temp Table Records ***');
  END IF;
 -- dbms_output.put_line('***End Duplicating Temp Table Records ***');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_status_text := 'Procedure WRITE_TO_DEBUG_TABLES successfully completed';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('In WRITE_TO_DEBUG_TABLES: '|| SQLERRM);
    END IF;
   -- dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: '|| SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := substr(SQLERRM,1,240);
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    END IF;
   -- dbms_output.put_line('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Duplicating Temp Table Records ***');
    END IF;
   -- dbms_output.put_line('***End Duplicating Temp Table Records ***');

WHEN REQUEST_TYPE_CODE_NOT_FOUND THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('In WRITE_TO_DEBUG_TABLES: REQUEST_TYPE_CODE Not Found'|| SQLERRM);
    END IF;
  --  dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: REQUEST_TYPE_CODE Not Found: '|| SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'REQUEST_TYPE_CODE Not Found - ' || substr(SQLERRM,1,200);
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    END IF;
  --  dbms_output.put_line('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Duplicating Temp Table Records ***');
    END IF;
  --  dbms_output.put_line('***End Duplicating Temp Table Records ***');

  WHEN CURRENCY_CODE_NOT_FOUND THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('In WRITE_TO_DEBUG_TABLES: CURRENCY_CODE Not Found'|| SQLERRM);
    END IF;
  --  dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: CURRENCY_CODE Not Found: '|| SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'CURRENCY_CODE Not Found - ' || substr(SQLERRM,1,200);
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    END IF;
  --  dbms_output.put_line('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Duplicating Temp Table Records ***');
    END IF;
  --  dbms_output.put_line('***End Duplicating Temp Table Records ***');

  WHEN OTHERS THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('In WRITE_TO_DEBUG_TABLES: '|| SQLERRM);
    END IF;
   -- dbms_output.put_line('In WRITE_TO_DEBUG_TABLES: '|| SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := substr(SQLERRM,1,240);
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    END IF;
   -- dbms_output.put_line('***Procedure WRITE_TO_DEBUG_TABLES Failed ***');
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('***End Duplicating Temp Table Records ***');
    END IF;
   -- dbms_output.put_line('***End Duplicating Temp Table Records ***');

END WRITE_TO_DEBUG_TABLES;

END QP_COPY_DEBUG_PVT;

/
