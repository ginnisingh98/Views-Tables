--------------------------------------------------------
--  DDL for Package Body QP_CLEANUP_ADJUSTMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CLEANUP_ADJUSTMENTS_PVT" AS
/* $Header: QPXVCLNB.pls 120.9.12010000.6 2009/10/08 08:56:07 kdurgasi ship $ */

G_CALC_INSERT VARCHAR2(30) := 'INSERTED FOR CALCULATION';
--to store the line_detail_index with which the relationships were inserted
G_PBH_LINE_DTL_INDEX QP_PREQ_GRP.NUMBER_TYPE;
G_PBH_LINE_INDEX QP_PREQ_GRP.NUMBER_TYPE;
G_PBH_PRICE_ADJ_ID QP_PREQ_GRP.NUMBER_TYPE;
G_PBH_PLSQL_IND QP_PREQ_GRP.NUMBER_TYPE;
G_MAX_DTL_INDEX NUMBER := 0;
G_ORD_LVL_LDET_INDEX QP_PREQ_GRP.PLS_INTEGER_TYPE; -- 3031108

l_debug VARCHAR2(3);
--to populate the price_adjustment_id for modifiers applied by the
--pricing engine. The price_adjustment_id is queried from the
--sequence OE_PRICE_ADJUSTMENTS_S
PROCEDURE Populate_Price_Adj_ID(x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

BEGIN
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Populate_Price_Adj_ID: Java Engine not Installed ----------');
 END IF;
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
        Update qp_npreq_ldets_tmp set price_adjustment_id =
                OE_PRICE_ADJUSTMENTS_S.NEXTVAL
                where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                and process_code = QP_PREQ_PUB.G_STATUS_NEW
                and (automatic_flag = QP_PREQ_PUB.G_YES
                or created_from_list_line_type = QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and nvl(created_from_list_type_code,'NULL') not in
                (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER);
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
ELSE
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Populate_Price_Adj_ID: Java Engine is Installed ----------');
 END IF;
IF (QP_UTIL_PUB.HVOP_Pricing_ON = 'Y') THEN
  Update qp_int_ldets set price_adjustment_id =
                OE_PRICE_ADJUSTMENTS_S.NEXTVAL
                where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                and process_code = QP_PREQ_PUB.G_STATUS_NEW
                and (applied_flag = QP_PREQ_PUB.G_YES
                     or automatic_flag = QP_PREQ_PUB.G_YES)
  --                   or created_from_list_line_type = QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and nvl(created_from_list_type_code,'NULL') not in
                (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER);

 ELSE

        Update qp_int_ldets set price_adjustment_id =
                OE_PRICE_ADJUSTMENTS_S.NEXTVAL
                where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                and process_code = QP_PREQ_PUB.G_STATUS_NEW
                and (automatic_flag = QP_PREQ_PUB.G_YES)
--                or created_from_list_line_type = QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and nvl(created_from_list_type_code,'NULL') not in
                (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER);
END IF;
END IF;
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
        x_return_status := FND_API.G_RET_STS_SUCCESS;
Exception
When OTHERS Then
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_status_text := 'QP_CLEANUP_ADJUSTMENTS_PVT.Populate_Price_Adj_ID '||SQLERRM;
END Populate_Price_Adj_ID;

--This is used on PUB to get the sum of operand to see if the sum of
--the % on order level adjustments have changed during a
--changed lines request call to see if new order level adjustments
--are added or if existing ones have changed
FUNCTION get_sum_operand(p_header_id IN NUMBER) RETURN NUMBER IS
l_adj_sum_operand number;
BEGIN

        l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
        select sum(operand) into l_adj_sum_operand
                from oe_price_adjustments adj
                where adj.header_id = p_header_id
                and adj.line_id is null
                and adj.modifier_level_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and adj.automatic_flag = QP_PREQ_PUB.G_YES
                and applied_flag = QP_PREQ_PUB.G_YES;

        IF l_adj_sum_operand is null
        THEN
                l_adj_sum_operand := 0;
        END IF;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' Sum of adj operand '||l_adj_sum_operand);
 END IF;
        RETURN l_adj_sum_operand;

EXCEPTION
When NO_DATA_FOUND Then
l_adj_sum_operand := 0;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' Sum of adj operand '||l_adj_sum_operand);
 END IF;
        RETURN l_adj_sum_operand;
When OTHERS Then
l_adj_sum_operand := FND_API.G_MISS_NUM;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' Exception adj operand '||SQLERRM);
        QP_PREQ_GRP.engine_debug(' Sum of adj operand '||l_adj_sum_operand);
 END IF;
        RETURN l_adj_sum_operand;
END get_sum_operand;

PROCEDURE cleanup_adjustments(p_view_code IN VARCHAR2,
                                p_request_type_code IN VARCHAR2,
                                p_cleanup_flag IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

--the same cursor for unchanged as well
--[julin/4865213] merged oe_price_adjustments unions, commented qp_npreq_ldets_tmp
CURSOR l_update_cur IS
        SELECT /*+ ORDERED USE_NL(adj ldet ql) dynamic_sampling(1) index(LDET QP_PREQ_LDETS_TMP_N1)*/ -- Bug No: 6753550
                ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                -- Begin Bug No: 6753550
                --, ldet.list_line_id created_from_list_line_id
                ,ldet.CREATED_FROM_LIST_LINE_ID
                -- End Bug No: 6753550
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                -- Begin Bug No: 6753550
                --, ldet.substitution_attribute substitution_type_code
                ,ql_det.substitution_attribute substitution_type_code
                -- End Bug No: 6753550
                --, ldet.substitution_value_to substitution_value_to   --8593826
                ,ql_det.substitution_value substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                -- Begin Bug No: 6753550
                --, ldet.override_flag override_flag
                , ql_det.override_flag override_flag
                -- End Bug No: 6753550
                , ldet.benefit_qty benefit_qty
                -- Begin Bug No: 6753550
                --, ldet.benefit_uom_code benefit_uom_code
                , ql_det.benefit_uom_code benefit_uom_code
                --, ldet.accrual_flag accrual_flag
                , ql_det.accrual_flag accrual_flag
                --, ldet.accrual_conversion_rate accrual_conversion_rate
                , ql_det.accrual_conversion_rate accrual_conversion_rate
                -- End Bug No: 6753550
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.line_id adj_line_id
--              , adj.header_id adj_header_id
--              , adj.list_line_id adj_list_line_id
                , adj.modified_from adj_modified_from
                , adj.modified_to adj_modified_to
                , adj.update_allowed adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.range_break_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , adj.expiration_date adj_expiration_date
                , adj.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_attribute adj_substitution_attribute
                , adj.proration_type_code adj_proration_type_code
                , adj.include_on_returns_flag adj_include_on_returns
                , nvl(adj.operand_per_pqty, adj.operand) adj_operand
                --, adj.adjusted_amount_per_pqty adj_adjusted_amount    --8593826
                , NVL(adj.adjusted_amount_per_pqty,0) adj_adjusted_amount
                , adj.arithmetic_operator adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                --, adj.adjusted_amount adj_ord_qty_adjamt   --8593826
                , NVL(adj.adjusted_amount,0) adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.operand adj_ord_qty_operand
        FROM qp_npreq_lines_tmp line
                , oe_price_adjustments adj
                -- Begin Bug No: 6753550
                --,qp_ldets_v ldet
                ,qp_npreq_ldets_tmp ldet
                ,qp_list_lines ql_det
                -- End Bug No: 6753550
                , qp_list_lines ql
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and ((line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and line.line_id = adj.line_id)
             OR
             (line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and line.line_id = adj.header_id))
        -- Begin Bug No: 6753550
        --and ldet.list_line_id = to_number(adj.list_line_id) -- bug 6023524
        --and ldet.list_line_id = ql.list_line_id;
        and ldet.CREATED_FROM_LIST_LINE_ID = to_number(adj.list_line_id)
        and ldet.CREATED_FROM_LIST_LINE_ID = ql.list_line_id
        and ldet.CREATED_FROM_LIST_LINE_ID = ql_det.LIST_LINE_ID
        and ldet.PRICING_STATUS_CODE = 'N'
        and ldet.REQUEST_ID = nvl ( SYS_CONTEXT ( 'QP_CONTEXT' , 'REQUEST_ID' ) , 1 );
        -- End Bug No: 6753550
/*
        UNION
        SELECT /*+ ORDERED USE_NL(adj ldet ql)/
                ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                , ldet.list_line_id created_from_list_line_id
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                , ldet.substitution_attribute substitution_type_code
                , ldet.substitution_value_to substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                , ldet.override_flag override_flag
                , ldet.benefit_qty benefit_qty
                , ldet.benefit_uom_code benefit_uom_code
                , ldet.accrual_flag accrual_flag
                , ldet.accrual_conversion_rate accrual_conversion_rate
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.line_id adj_line_id
--              , adj.header_id adj_header_id
--              , adj.list_line_id adj_list_line_id
                , adj.modified_from adj_modified_from
                , adj.modified_to adj_modified_to
                , adj.update_allowed adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.range_break_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , adj.expiration_date adj_expiration_date
                , adj.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_attribute adj_substitution_attribute
                , adj.proration_type_code adj_proration_type_code
                , adj.include_on_returns_flag adj_include_on_returns
                , nvl(adj.operand_per_pqty, adj.operand) adj_operand
                , adj.adjusted_amount_per_pqty adj_adjusted_amount
                , adj.arithmetic_operator adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                , adj.adjusted_amount adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.operand adj_ord_qty_operand
        FROM qp_npreq_lines_tmp line
                , oe_price_adjustments adj
                ,qp_ldets_v ldet
                , qp_list_lines ql
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and (line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and line.line_id = adj.header_id)
        and ldet.list_line_id = adj.list_line_id
        and ldet.list_line_id = ql.list_line_id
        UNION
        SELECT ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                , ldet.list_line_id created_from_list_line_id
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                , ldet.substitution_attribute substitution_type_code
                , ldet.substitution_value_to substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                , ldet.override_flag override_flag
                , ldet.benefit_qty benefit_qty
                , ldet.benefit_uom_code benefit_uom_code
                , ldet.accrual_flag accrual_flag
                , ldet.accrual_conversion_rate accrual_conversion_rate
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.created_from_list_line_id adj_list_line_id
                , adj.substitution_value_from adj_modified_from
                , adj.substitution_value_to adj_modified_to
                , adj.override_flag adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.line_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , ql.expiration_date adj_expiration_date
                , ql.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_type_code adj_substitution_attribute
                , ql.proration_type_code adj_proration_type_code
                , ql.include_on_returns_flag adj_include_on_returns
                , adj.operand_value adj_operand
                , adj.adjustment_amount adj_adjusted_amount
                , adj.operand_calculation_code adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                , adj.order_qty_adj_amt adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.order_qty_operand adj_ord_qty_operand
        FROM qp_npreq_lines_tmp line
                , qp_npreq_ldets_tmp adj
                ,qp_ldets_v ldet
                , qp_list_lines ql
--        WHERE p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and adj.line_index = line.line_index
        and adj.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
        and ldet.list_line_id = adj.created_from_list_line_id
        and ldet.list_line_id = ql.list_line_id;
*/

--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
--[julin/4865213] merged oe_price_adjustments unions, commented qp_npreq_ldets_tmp
CURSOR l_update_int_cur IS
        SELECT /*+ ORDERED USE_NL(adj ldet ql)*/
                ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                , ldet.list_line_id created_from_list_line_id
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                , ldet.substitution_attribute substitution_type_code
                , ldet.substitution_value_to substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                , ldet.override_flag override_flag
                , ldet.benefit_qty benefit_qty
                , ldet.benefit_uom_code benefit_uom_code
                , ldet.accrual_flag accrual_flag
                , ldet.accrual_conversion_rate accrual_conversion_rate
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.line_id adj_line_id
--              , adj.header_id adj_header_id
--              , adj.list_line_id adj_list_line_id
                , adj.modified_from adj_modified_from
                , adj.modified_to adj_modified_to
                , adj.update_allowed adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.range_break_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , adj.expiration_date adj_expiration_date
                , adj.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_attribute adj_substitution_attribute
                , adj.proration_type_code adj_proration_type_code
                , adj.include_on_returns_flag adj_include_on_returns
                , nvl(adj.operand_per_pqty, adj.operand) adj_operand
                , adj.adjusted_amount_per_pqty adj_adjusted_amount
                , adj.arithmetic_operator adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                , adj.adjusted_amount adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.operand adj_ord_qty_operand
        FROM qp_int_lines line
                , oe_price_adjustments adj
                ,qp_ldets_v ldet
                , qp_list_lines ql
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and ((line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and line.line_id = adj.line_id)
             OR
             (line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and line.line_id = adj.header_id))
        and ldet.list_line_id = adj.list_line_id
        and ldet.list_line_id = ql.list_line_id;
/*
        UNION
        SELECT /*+ ORDERED USE_NL(adj ldet ql)/
                ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                , ldet.list_line_id created_from_list_line_id
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                , ldet.substitution_attribute substitution_type_code
                , ldet.substitution_value_to substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                , ldet.override_flag override_flag
                , ldet.benefit_qty benefit_qty
                , ldet.benefit_uom_code benefit_uom_code
                , ldet.accrual_flag accrual_flag
                , ldet.accrual_conversion_rate accrual_conversion_rate
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.line_id adj_line_id
--              , adj.header_id adj_header_id
--              , adj.list_line_id adj_list_line_id
                , adj.modified_from adj_modified_from
                , adj.modified_to adj_modified_to
                , adj.update_allowed adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.range_break_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , adj.expiration_date adj_expiration_date
                , adj.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_attribute adj_substitution_attribute
                , adj.proration_type_code adj_proration_type_code
                , adj.include_on_returns_flag adj_include_on_returns
                , nvl(adj.operand_per_pqty, adj.operand) adj_operand
                , adj.adjusted_amount_per_pqty adj_adjusted_amount
                , adj.arithmetic_operator adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                , adj.adjusted_amount adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.operand adj_ord_qty_operand
        FROM qp_int_lines line
                , oe_price_adjustments adj
                ,qp_ldets_v ldet
                , qp_list_lines ql
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and (line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and line.line_id = adj.header_id)
        and ldet.list_line_id = adj.list_line_id
        and ldet.list_line_id = ql.list_line_id
        UNION
        SELECT ldet.line_index line_index
                , ldet.line_detail_index line_detail_index
                , ldet.list_line_id created_from_list_line_id
                , ldet.process_code process_code
                , ldet.price_break_type_code price_break_type_code
                , ldet.pricing_group_sequence pricing_group_sequence
                , ldet.operand_calculation_code operand_calculation_code
                , ldet.operand_value operand_value
                , ldet.adjustment_amount adjustment_amount
                , ldet.substitution_attribute substitution_type_code
                , ldet.substitution_value_to substitution_value_to
                , ldet.pricing_phase_id pricing_phase_id
                , ldet.applied_flag applied_flag
                , ldet.automatic_flag automatic_flag
                , ldet.override_flag override_flag
                , ldet.benefit_qty benefit_qty
                , ldet.benefit_uom_code benefit_uom_code
                , ldet.accrual_flag accrual_flag
                , ldet.accrual_conversion_rate accrual_conversion_rate
                , ldet.charge_type_code charge_type_code
                , ldet.charge_subtype_code charge_subtype_code
                , ldet.line_quantity line_quantity
                , adj.automatic_flag adj_automatic_flag
                , adj.created_from_list_line_id adj_list_line_id
                , adj.substitution_value_from adj_modified_from
                , adj.substitution_value_to adj_modified_to
                , adj.override_flag adj_update_allowed
                , adj.updated_flag adj_updated_flag
                , adj.applied_flag adj_applied_flag
                , adj.pricing_phase_id adj_pricing_phase_id
                , adj.charge_type_code adj_charge_type_code
                , adj.charge_subtype_code adj_charge_subtype_code
                , adj.line_quantity adj_range_break_quantity
                , adj.accrual_conversion_rate adj_accrual_conv_rate
                , adj.pricing_group_sequence adj_pricing_group_seq
                , adj.accrual_flag adj_accrual_flag
                , adj.benefit_qty adj_benefit_qty
                , adj.benefit_uom_code adj_benefit_uom_code
                , ql.expiration_date adj_expiration_date
                , ql.rebate_transaction_type_code adj_rebate_txn_type_code
                , adj.price_break_type_code adj_price_break_type_code
                , adj.substitution_type_code adj_substitution_attribute
                , ql.proration_type_code adj_proration_type_code
                , ql.include_on_returns_flag adj_include_on_returns
                , adj.operand_value adj_operand
                , adj.adjustment_amount adj_adjusted_amount
                , adj.operand_calculation_code adj_arithmetic_operator
                , ql.expiration_date
                , ql.proration_type_code
                , ql.include_on_returns_flag
                , ql.rebate_transaction_type_code
                , ldet.pricing_status_text
                , adj.price_adjustment_id
                , ldet.order_qty_adj_amt ord_qty_adjamt
                , adj.order_qty_adj_amt adj_ord_qty_adjamt
                , ldet.order_qty_operand ord_qty_operand
                , adj.order_qty_operand adj_ord_qty_operand
        FROM qp_int_lines line
                , qp_int_ldets adj
                ,qp_ldets_v ldet
                , qp_list_lines ql
--        WHERE p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> QP_PREQ_PUB.G_YES
        and line.line_index = ldet.line_index
        and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
             OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
        and line.pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
        and line.process_status in (QP_PREQ_PUB.G_STATUS_NEW,
                                    QP_PREQ_PUB.G_STATUS_UPDATED,
                                    QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                   'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                   'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
        and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                         ,QP_PREQ_PUB.G_STATUS_UPDATED)
        and adj.line_index = line.line_index
        and adj.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
        and ldet.list_line_id = adj.created_from_list_line_id
        and ldet.list_line_id = ql.list_line_id;
*/
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
/*
cursor l_attr_cur IS
        SELECT line_index,
                line_detail_index,
                pricing_status_code,
                context,
                attribute,
                value_from
        FROM qp_npreq_line_attrs_tmp
        WHERE line_detail_index is not null;

--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
cursor l_attr_int_cur IS
        SELECT line_index,
                line_detail_index,
                pricing_status_code,
                context,
                attribute,
                value_from
        FROM qp_int_line_attrs
        WHERE line_detail_index is not null;
--ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
*/
l_cur_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_process_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_price_brk_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_pricing_grp_seq_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_operator_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_operand_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_adj_amt_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_substn_attr_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_substn_val_to_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_phase_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_cur_automatic_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_cur_override_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_cur_benefit_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_benefit_uom_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_accrual_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_cur_accr_conv_rate_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_charge_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_charge_subtype_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_line_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_automatic_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
--l_adj_header_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
--l_adj_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_modified_from_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_modified_to_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_update_allowed_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_updated_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_phase_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_charge_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_charge_subtype_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_range_break_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_accrual_conv_rate_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_pricing_grp_seq_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_accrual_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_benefit_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_benefit_uom_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_exp_date_tbl QP_PREQ_GRP.DATE_TYPE;
l_adj_rebate_txn_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_price_brk_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_substn_attr_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_prorat_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_adj_include_ret_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_adj_operand_pqty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_adj_amt_pqty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_adj_operator_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_exp_date_tbl QP_PREQ_GRP.DATE_TYPE;
l_cur_prorat_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_include_ret_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_cur_reb_txn_type_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_prc_sts_txt_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_cur_price_adj_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_cur_ord_qty_adjamt QP_PREQ_GRP.NUMBER_TYPE;
l_adj_ord_qty_adjamt QP_PREQ_GRP.NUMBER_TYPE;
l_cur_ord_qty_operand  QP_PREQ_GRP.NUMBER_TYPE;
l_adj_ord_qty_operand QP_PREQ_GRP.NUMBER_TYPE;


l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_price_adj_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_process_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_pricing_sts_text_tbl QP_PREQ_GRP.VARCHAR_TYPE;





X PLS_INTEGER;
nrows NUMBER := 500;
BEGIN

l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
x:=0;
IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('begin update check clnup '||p_cleanup_flag);
qp_preq_grp.engine_debug('begin update check reqtype '||p_request_type_code);
qp_preq_grp.engine_debug('begin update check viewcode '||p_view_code);
 END IF;  --Bug No 4033618
--IF p_request_type_code in ('ONT','ASO')
IF p_cleanup_flag = 'Y'
--and p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
and QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
THEN
        IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('in update cleanup '||p_cleanup_flag);
        END IF; -- Bug No 4033618
      --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
     IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('cleanup_adjustments Java Engine not Installed ----------');
        END IF;
      --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881

        OPEN l_update_cur;
        LOOP

                l_cur_line_index_tbl.delete;
                l_cur_dtl_index_tbl.delete;
                l_cur_list_line_id_tbl.delete;
                l_cur_process_code_tbl.delete;
                l_cur_price_brk_type_tbl.delete;
                l_cur_pricing_grp_seq_tbl.delete;
                l_cur_operator_tbl.delete;
                l_cur_operand_tbl.delete;
                l_cur_adj_amt_tbl.delete;
                l_cur_substn_attr_tbl.delete;
                l_cur_substn_val_to_tbl.delete;
                l_cur_phase_id_tbl.delete;
                l_cur_applied_flag_tbl.delete;
                l_cur_automatic_flag_tbl.delete;
                l_cur_override_flag_tbl.delete;
                l_cur_benefit_qty_tbl.delete;
                l_cur_benefit_uom_code_tbl.delete;
                l_cur_accrual_flag_tbl.delete;
                l_cur_accr_conv_rate_tbl.delete;
                l_cur_charge_type_tbl.delete;
                l_cur_charge_subtype_tbl.delete;
                l_cur_line_qty_tbl.delete;
                l_adj_automatic_flag_tbl.delete;
                l_adj_line_id_tbl.delete;
                --l_adj_header_id_tbl.delete;
                --l_adj_list_line_id_tbl.delete;
                l_adj_modified_from_tbl.delete;
                l_adj_modified_to_tbl.delete;
                l_adj_update_allowed_tbl.delete;
                l_adj_updated_flag_tbl.delete;
                l_adj_applied_flag_tbl.delete;
                l_adj_phase_id_tbl.delete;
                l_adj_charge_type_tbl.delete;
                l_adj_charge_subtype_tbl.delete;
                l_adj_range_break_qty_tbl.delete;
                l_adj_accrual_conv_rate_tbl.delete;
                l_adj_pricing_grp_seq_tbl.delete;
                l_adj_accrual_flag_tbl.delete;
                l_adj_benefit_qty_tbl.delete;
                l_adj_benefit_uom_code_tbl.delete;
                l_adj_exp_date_tbl.delete;
                l_adj_rebate_txn_type_tbl.delete;
                l_adj_price_brk_type_tbl.delete;
                l_adj_substn_attr_tbl.delete;
                l_adj_prorat_type_tbl.delete;
                l_adj_include_ret_flag_tbl.delete;
                l_adj_operand_pqty_tbl.delete;
                l_adj_adj_amt_pqty_tbl.delete;
                l_adj_operator_tbl.delete;
                l_cur_exp_date_tbl.delete;
                l_cur_prorat_type_tbl.delete;
                l_cur_include_ret_flag_tbl.delete;
                l_cur_reb_txn_type_tbl.delete;
                l_cur_prc_sts_txt_tbl.delete;
                l_cur_price_adj_id_tbl.delete;
                l_cur_ord_qty_adjamt.delete;
                l_adj_ord_qty_adjamt.delete;
                l_cur_ord_qty_operand.delete;
                l_adj_ord_qty_operand.delete;


        FETCH l_update_cur
        BULK COLLECT INTO
                l_cur_line_index_tbl,
                l_cur_dtl_index_tbl,
                l_cur_list_line_id_tbl,
                l_cur_process_code_tbl,
                l_cur_price_brk_type_tbl,
                l_cur_pricing_grp_seq_tbl,
                l_cur_operator_tbl,
                l_cur_operand_tbl,
                l_cur_adj_amt_tbl,
                l_cur_substn_attr_tbl,
                l_cur_substn_val_to_tbl,
--              l_cur_prc_sts_txt_tbl,
                l_cur_phase_id_tbl,
                l_cur_applied_flag_tbl,
                l_cur_automatic_flag_tbl,
                l_cur_override_flag_tbl,
                l_cur_benefit_qty_tbl,
                l_cur_benefit_uom_code_tbl,
                l_cur_accrual_flag_tbl,
                l_cur_accr_conv_rate_tbl,
                l_cur_charge_type_tbl,
                l_cur_charge_subtype_tbl,
                l_cur_line_qty_tbl,
                l_adj_automatic_flag_tbl,
                l_adj_line_id_tbl,
                --l_adj_header_id_tbl,
                --l_adj_list_line_id_tbl,
                l_adj_modified_from_tbl,
                l_adj_modified_to_tbl,
                l_adj_update_allowed_tbl,
                l_adj_updated_flag_tbl,
                l_adj_applied_flag_tbl,
                l_adj_phase_id_tbl,
                l_adj_charge_type_tbl,
                l_adj_charge_subtype_tbl,
                l_adj_range_break_qty_tbl,
                l_adj_accrual_conv_rate_tbl,
                l_adj_pricing_grp_seq_tbl,
                l_adj_accrual_flag_tbl,
                l_adj_benefit_qty_tbl,
                l_adj_benefit_uom_code_tbl,
                l_adj_exp_date_tbl,
                l_adj_rebate_txn_type_tbl,
                l_adj_price_brk_type_tbl,
                l_adj_substn_attr_tbl,
                l_adj_prorat_type_tbl,
                l_adj_include_ret_flag_tbl,
                l_adj_operand_pqty_tbl,
                l_adj_adj_amt_pqty_tbl,
                l_adj_operator_tbl,
                l_cur_exp_date_tbl,
                l_cur_prorat_type_tbl,
                l_cur_include_ret_flag_tbl,
                l_cur_reb_txn_type_tbl,
                l_cur_prc_sts_txt_tbl,
                l_cur_price_adj_id_tbl,
                l_cur_ord_qty_adjamt,
                l_adj_ord_qty_adjamt,
                l_cur_ord_qty_operand,
                l_adj_ord_qty_operand
        LIMIT nrows;
        EXIT WHEN l_cur_dtl_index_tbl.COUNT = 0;

                FOR i IN l_cur_dtl_index_tbl.FIRST..l_cur_dtl_index_tbl.LAST
                LOOP

                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
                THEN
                qp_preq_grp.engine_debug('loop update cur line ind '
                ||l_cur_line_index_tbl(i)||' line_dtl_index '
                ||l_cur_dtl_index_tbl(i)||' price_adj_id '
                ||l_cur_price_adj_id_tbl(i));
                qp_preq_grp.engine_debug('adj amt '||l_cur_adj_amt_tbl(i)
                ||' adj '||l_adj_adj_amt_pqty_tbl(i));
                qp_preq_grp.engine_debug('operand '||l_cur_operand_tbl(i)
                ||' adj '||l_adj_operand_pqty_tbl(i));
                qp_preq_grp.engine_debug('bucket '||l_cur_pricing_grp_seq_tbl(i)
                ||' adj '||l_adj_pricing_grp_seq_tbl(i));
                qp_preq_grp.engine_debug('charg type '||l_cur_charge_type_tbl(i)
                ||' adj '||l_adj_charge_type_tbl(i));
                qp_preq_grp.engine_debug('chstype '||l_cur_charge_subtype_tbl(i)
                ||' adj charge subtype '||l_adj_charge_subtype_tbl(i));
                qp_preq_grp.engine_debug('pbrk '||l_cur_price_brk_type_tbl(i)
                ||' adj price brk type '||l_adj_price_brk_type_tbl(i));
                qp_preq_grp.engine_debug('operator '||l_cur_operator_tbl(i)
                ||' adj operator '||l_adj_operator_tbl(i));
                qp_preq_grp.engine_debug('phase id '||l_cur_phase_id_tbl(i)
                ||' adj phase id '||l_adj_phase_id_tbl(i));
                qp_preq_grp.engine_debug('autoflg '||l_cur_automatic_flag_tbl(i)
                ||' adj autom flag '||l_adj_automatic_flag_tbl(i));
                qp_preq_grp.engine_debug('override '||l_cur_override_flag_tbl(i)
                ||' adj override '||l_adj_update_allowed_tbl(i));
                qp_preq_grp.engine_debug('sub attr '||l_cur_substn_attr_tbl(i)
                ||' adj sub attr '||l_adj_substn_attr_tbl(i));
                qp_preq_grp.engine_debug('subval '||l_cur_substn_val_to_tbl(i)
                ||' adj substn val '||l_adj_modified_to_tbl(i));
                qp_preq_grp.engine_debug('benf qty '||l_cur_benefit_qty_tbl(i)
                ||' adj benefit qty '||l_adj_benefit_qty_tbl(i));
                qp_preq_grp.engine_debug('bnuom '||l_cur_benefit_uom_code_tbl(i)
                ||' adj benefit uom '||l_adj_benefit_uom_code_tbl(i));
                qp_preq_grp.engine_debug('accrual '||l_cur_accrual_flag_tbl(i)
                ||' adj accrual flag '||l_adj_accrual_flag_tbl(i));
                qp_preq_grp.engine_debug('conv '||l_cur_accr_conv_rate_tbl(i)
                ||' adj accr conv rate '||l_adj_accrual_conv_rate_tbl(i));
                qp_preq_grp.engine_debug('rebtxn '||l_cur_reb_txn_type_tbl(i)
                ||' adj rebate txn type '||l_adj_rebate_txn_type_tbl(i));
                qp_preq_grp.engine_debug('prorat typ '||l_cur_prorat_type_tbl(i)
                ||' adj proration type '||l_adj_prorat_type_tbl(i));
                qp_preq_grp.engine_debug('incl '||l_cur_include_ret_flag_tbl(i)
                ||' adj include on ret '||l_adj_include_ret_flag_tbl(i));
                qp_preq_grp.engine_debug('line_qty '||l_cur_line_qty_tbl(i)
                ||' adj range_brk_qty '||l_adj_range_break_qty_tbl(i));
                qp_preq_grp.engine_debug('exp date '||l_cur_exp_date_tbl(i)
                ||' adj exp date '||l_adj_exp_date_tbl(i)
                ||' pricing sts text '||l_cur_prc_sts_txt_tbl(i));
                qp_preq_grp.engine_debug('ord_qty_adjamt '
                ||l_cur_ord_qty_adjamt(i)
                ||' adj ord_qty_adjamt '||l_adj_ord_qty_adjamt(i)
                ||' ord_qty_operand '||l_cur_ord_qty_operand(i)
                ||' adj ord_qty_operand '||l_adj_ord_qty_operand(i));
                END IF;--debug


                        IF
                        nvl(l_cur_adj_amt_tbl(i),FND_API.G_MISS_NUM) =
                        nvl(l_adj_adj_amt_pqty_tbl(i),FND_API.G_MISS_NUM)
                        AND nvl(l_cur_operand_tbl(i),FND_API.G_MISS_NUM) =
                        nvl(l_adj_operand_pqty_tbl(i),FND_API.G_MISS_NUM)
                        AND nvl(l_cur_pricing_grp_seq_tbl(i),-1) =
                                nvl(l_adj_pricing_grp_seq_tbl(i),-1)
                        AND nvl(l_cur_charge_type_tbl(i),'NULL') =
                                nvl(l_adj_charge_type_tbl(i),'NULL')
                        AND nvl(l_cur_charge_subtype_tbl(i),'NULL') =
                                nvl(l_adj_charge_subtype_tbl(i), 'NULL')
                        AND nvl(l_cur_price_brk_type_tbl(i), 'NULL') =
                                nvl(l_adj_price_brk_type_tbl(i), 'NULL')
                        AND nvl(l_cur_operator_tbl(i),'NULL') =
                                nvl(l_adj_operator_tbl(i), 'NULL')
                        AND nvl(l_cur_phase_id_tbl(i),0) =
                                nvl(l_adj_phase_id_tbl(i),0)
                        AND nvl(l_cur_automatic_flag_tbl(i),' ') =
                                nvl(l_adj_automatic_flag_tbl(i),' ')
                        AND nvl(l_cur_override_flag_tbl(i),' ') =
                                nvl(l_adj_update_allowed_tbl(i),' ')
                        AND nvl(l_cur_substn_attr_tbl(i),'NULL') =
                                nvl(l_adj_substn_attr_tbl(i),'NULL')
                        AND nvl(l_cur_substn_val_to_tbl(i), 'NULL') =
                                nvl(l_adj_modified_to_tbl(i), 'NULL')
                        AND nvl(l_cur_benefit_qty_tbl(i),0) =
                                nvl(l_adj_benefit_qty_tbl(i),0)
                        AND nvl(l_cur_benefit_uom_code_tbl(i),'NULL') =
                                nvl(l_adj_benefit_uom_code_tbl(i),'NULL')
                        AND nvl(l_cur_accrual_flag_tbl(i),' ') =
                                nvl(l_adj_accrual_flag_tbl(i),'NULL')
                        AND nvl(l_cur_accr_conv_rate_tbl(i),0) =
                                nvl(l_adj_accrual_conv_rate_tbl(i),0)
                        AND nvl(l_cur_reb_txn_type_tbl(i),'NULL') =
                                nvl(l_adj_rebate_txn_type_tbl(i),'NULL')
                        AND nvl(l_cur_prorat_type_tbl(i),'NULL') =
                                nvl(l_adj_prorat_type_tbl(i),'NULL')
                        AND nvl(l_cur_include_ret_flag_tbl(i), ' ') =
                                nvl(l_adj_include_ret_flag_tbl(i),' ')
                        AND nvl(l_cur_exp_date_tbl(i),FND_API.G_MISS_DATE) =
                                nvl(l_adj_exp_date_tbl(i), FND_API.G_MISS_DATE)
                        AND nvl(l_cur_line_qty_tbl(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_range_break_qty_tbl(i), FND_API.G_MISS_NUM)
                        AND nvl(l_cur_ord_qty_adjamt(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_ord_qty_adjamt(i), FND_API.G_MISS_NUM)
                        AND nvl(l_cur_ord_qty_operand(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_ord_qty_operand(i), FND_API.G_MISS_NUM)
                        THEN
                                x:=x+1;
                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('if update check '||x);
                        qp_preq_grp.engine_debug('update check dtls '
                        ||l_cur_dtl_index_tbl(i)||' adj_id '
                        ||l_cur_price_adj_id_tbl(i)||' id '
                        ||l_cur_list_line_id_tbl(i)||' adj adj amt '
                        ||l_adj_adj_amt_pqty_tbl(i)||' adj amt '
                        ||l_cur_adj_amt_tbl(i));
                END IF;   --Bug No 4033618
                        l_line_index_tbl(x) := l_cur_line_index_tbl(i);
                        l_line_dtl_index_tbl(x) := l_cur_dtl_index_tbl(i);
                        l_price_adj_id_tbl(x) := l_cur_price_adj_id_tbl(i);
                        l_process_code_tbl(x) := QP_PREQ_PUB.G_STATUS_UNCHANGED;
                        l_pricing_sts_text_tbl(x) := 'ADJUSTMENT INFO UNCHANGED';
                        ELSE
                                x:=x+1;
                  IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('else update check '||x);
                        qp_preq_grp.engine_debug('update check dtls '
                        ||l_cur_dtl_index_tbl(i)||' adj_id '
                        ||l_cur_price_adj_id_tbl(i)||' id '
                        ||l_cur_list_line_id_tbl(i)||' adj adj amt '
                        ||l_adj_adj_amt_pqty_tbl(i)||' adj amt '
                        ||l_cur_adj_amt_tbl(i));
                  END IF;   --Bug No 4033618

                        l_line_index_tbl(x) := l_cur_line_index_tbl(i);
                        l_line_dtl_index_tbl(x) := l_cur_dtl_index_tbl(i);
                        l_price_adj_id_tbl(x) := l_cur_price_adj_id_tbl(i);
                        l_process_code_tbl(x) := QP_PREQ_PUB.G_STATUS_UPDATED;
                        l_pricing_sts_text_tbl(x) := l_cur_prc_sts_txt_tbl(i);
                        END IF;

                END LOOP;--check each rec from fetch
        END LOOP;--bulk fetch
        CLOSE l_update_cur;
      ELSE
        --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.ENGINE_DEBUG('cleanup_adjustments() Java Engine is Installed ----------');
        END IF;
        --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881

        OPEN l_update_int_cur;
        LOOP

                l_cur_line_index_tbl.delete;
                l_cur_dtl_index_tbl.delete;
                l_cur_list_line_id_tbl.delete;
                l_cur_process_code_tbl.delete;
                l_cur_price_brk_type_tbl.delete;
                l_cur_pricing_grp_seq_tbl.delete;
                l_cur_operator_tbl.delete;
                l_cur_operand_tbl.delete;
                l_cur_adj_amt_tbl.delete;
                l_cur_substn_attr_tbl.delete;
                l_cur_substn_val_to_tbl.delete;
                l_cur_phase_id_tbl.delete;
                l_cur_applied_flag_tbl.delete;
                l_cur_automatic_flag_tbl.delete;
                l_cur_override_flag_tbl.delete;
                l_cur_benefit_qty_tbl.delete;
                l_cur_benefit_uom_code_tbl.delete;
                l_cur_accrual_flag_tbl.delete;
                l_cur_accr_conv_rate_tbl.delete;
                l_cur_charge_type_tbl.delete;
                l_cur_charge_subtype_tbl.delete;
                l_cur_line_qty_tbl.delete;
                l_adj_automatic_flag_tbl.delete;
                l_adj_line_id_tbl.delete;
                --l_adj_header_id_tbl.delete;
                --l_adj_list_line_id_tbl.delete;
                l_adj_modified_from_tbl.delete;
                l_adj_modified_to_tbl.delete;
                l_adj_update_allowed_tbl.delete;
                l_adj_updated_flag_tbl.delete;
                l_adj_applied_flag_tbl.delete;
                l_adj_phase_id_tbl.delete;
                l_adj_charge_type_tbl.delete;
                l_adj_charge_subtype_tbl.delete;
                l_adj_range_break_qty_tbl.delete;
                l_adj_accrual_conv_rate_tbl.delete;
                l_adj_pricing_grp_seq_tbl.delete;
                l_adj_accrual_flag_tbl.delete;
                l_adj_benefit_qty_tbl.delete;
                l_adj_benefit_uom_code_tbl.delete;
                l_adj_exp_date_tbl.delete;
                l_adj_rebate_txn_type_tbl.delete;
                l_adj_price_brk_type_tbl.delete;
                l_adj_substn_attr_tbl.delete;
                l_adj_prorat_type_tbl.delete;
                l_adj_include_ret_flag_tbl.delete;
                l_adj_operand_pqty_tbl.delete;
                l_adj_adj_amt_pqty_tbl.delete;
                l_adj_operator_tbl.delete;
                l_cur_exp_date_tbl.delete;
                l_cur_prorat_type_tbl.delete;
                l_cur_include_ret_flag_tbl.delete;
                l_cur_reb_txn_type_tbl.delete;
                l_cur_prc_sts_txt_tbl.delete;
                l_cur_price_adj_id_tbl.delete;
                l_cur_ord_qty_adjamt.delete;
                l_adj_ord_qty_adjamt.delete;
                l_cur_ord_qty_operand.delete;
                l_adj_ord_qty_operand.delete;


        FETCH l_update_int_cur
        BULK COLLECT INTO
                l_cur_line_index_tbl,
                l_cur_dtl_index_tbl,
                l_cur_list_line_id_tbl,
                l_cur_process_code_tbl,
                l_cur_price_brk_type_tbl,
                l_cur_pricing_grp_seq_tbl,
                l_cur_operator_tbl,
                l_cur_operand_tbl,
                l_cur_adj_amt_tbl,
                l_cur_substn_attr_tbl,
                l_cur_substn_val_to_tbl,
--              l_cur_prc_sts_txt_tbl,
                l_cur_phase_id_tbl,
                l_cur_applied_flag_tbl,
                l_cur_automatic_flag_tbl,
                l_cur_override_flag_tbl,
                l_cur_benefit_qty_tbl,
                l_cur_benefit_uom_code_tbl,
                l_cur_accrual_flag_tbl,
                l_cur_accr_conv_rate_tbl,
                l_cur_charge_type_tbl,
                l_cur_charge_subtype_tbl,
                l_cur_line_qty_tbl,
                l_adj_automatic_flag_tbl,
                l_adj_line_id_tbl,
                --l_adj_header_id_tbl,
                --l_adj_list_line_id_tbl,
                l_adj_modified_from_tbl,
                l_adj_modified_to_tbl,
                l_adj_update_allowed_tbl,
                l_adj_updated_flag_tbl,
                l_adj_applied_flag_tbl,
                l_adj_phase_id_tbl,
                l_adj_charge_type_tbl,
                l_adj_charge_subtype_tbl,
                l_adj_range_break_qty_tbl,
                l_adj_accrual_conv_rate_tbl,
                l_adj_pricing_grp_seq_tbl,
                l_adj_accrual_flag_tbl,
                l_adj_benefit_qty_tbl,
                l_adj_benefit_uom_code_tbl,
                l_adj_exp_date_tbl,
                l_adj_rebate_txn_type_tbl,
                l_adj_price_brk_type_tbl,
                l_adj_substn_attr_tbl,
                l_adj_prorat_type_tbl,
                l_adj_include_ret_flag_tbl,
                l_adj_operand_pqty_tbl,
                l_adj_adj_amt_pqty_tbl,
                l_adj_operator_tbl,
                l_cur_exp_date_tbl,
                l_cur_prorat_type_tbl,
                l_cur_include_ret_flag_tbl,
                l_cur_reb_txn_type_tbl,
                l_cur_prc_sts_txt_tbl,
                l_cur_price_adj_id_tbl,
                l_cur_ord_qty_adjamt,
                l_adj_ord_qty_adjamt,
                l_cur_ord_qty_operand,
                l_adj_ord_qty_operand
        LIMIT nrows;
        EXIT WHEN l_cur_dtl_index_tbl.COUNT = 0;

                FOR i IN l_cur_dtl_index_tbl.FIRST..l_cur_dtl_index_tbl.LAST
                LOOP

                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
                THEN
                qp_preq_grp.engine_debug('loop update cur line ind '
                ||l_cur_line_index_tbl(i)||' line_dtl_index '
                ||l_cur_dtl_index_tbl(i)||' price_adj_id '
                ||l_cur_price_adj_id_tbl(i));
                qp_preq_grp.engine_debug('adj amt '||l_cur_adj_amt_tbl(i)
                ||' adj '||l_adj_adj_amt_pqty_tbl(i));
                qp_preq_grp.engine_debug('operand '||l_cur_operand_tbl(i)
                ||' adj '||l_adj_operand_pqty_tbl(i));
                qp_preq_grp.engine_debug('bucket '||l_cur_pricing_grp_seq_tbl(i)
                ||' adj '||l_adj_pricing_grp_seq_tbl(i));
                qp_preq_grp.engine_debug('charg type '||l_cur_charge_type_tbl(i)
                ||' adj '||l_adj_charge_type_tbl(i));
                qp_preq_grp.engine_debug('chstype '||l_cur_charge_subtype_tbl(i)
                ||' adj charge subtype '||l_adj_charge_subtype_tbl(i));
                qp_preq_grp.engine_debug('pbrk '||l_cur_price_brk_type_tbl(i)
                ||' adj price brk type '||l_adj_price_brk_type_tbl(i));
                qp_preq_grp.engine_debug('operator '||l_cur_operator_tbl(i)
                ||' adj operator '||l_adj_operator_tbl(i));
                qp_preq_grp.engine_debug('phase id '||l_cur_phase_id_tbl(i)
                ||' adj phase id '||l_adj_phase_id_tbl(i));
                qp_preq_grp.engine_debug('autoflg '||l_cur_automatic_flag_tbl(i)
                ||' adj autom flag '||l_adj_automatic_flag_tbl(i));
                qp_preq_grp.engine_debug('override '||l_cur_override_flag_tbl(i)
                ||' adj override '||l_adj_update_allowed_tbl(i));
                qp_preq_grp.engine_debug('sub attr '||l_cur_substn_attr_tbl(i)
                ||' adj sub attr '||l_adj_substn_attr_tbl(i));
                qp_preq_grp.engine_debug('subval '||l_cur_substn_val_to_tbl(i)
                ||' adj substn val '||l_adj_modified_to_tbl(i));
                qp_preq_grp.engine_debug('benf qty '||l_cur_benefit_qty_tbl(i)
                ||' adj benefit qty '||l_adj_benefit_qty_tbl(i));
                qp_preq_grp.engine_debug('bnuom '||l_cur_benefit_uom_code_tbl(i)
                ||' adj benefit uom '||l_adj_benefit_uom_code_tbl(i));
                qp_preq_grp.engine_debug('accrual '||l_cur_accrual_flag_tbl(i)
                ||' adj accrual flag '||l_adj_accrual_flag_tbl(i));
                qp_preq_grp.engine_debug('conv '||l_cur_accr_conv_rate_tbl(i)
                ||' adj accr conv rate '||l_adj_accrual_conv_rate_tbl(i));
                qp_preq_grp.engine_debug('rebtxn '||l_cur_reb_txn_type_tbl(i)
                ||' adj rebate txn type '||l_adj_rebate_txn_type_tbl(i));
                qp_preq_grp.engine_debug('prorat typ '||l_cur_prorat_type_tbl(i)
                ||' adj proration type '||l_adj_prorat_type_tbl(i));
                qp_preq_grp.engine_debug('incl '||l_cur_include_ret_flag_tbl(i)
                ||' adj include on ret '||l_adj_include_ret_flag_tbl(i));
                qp_preq_grp.engine_debug('line_qty '||l_cur_line_qty_tbl(i)
                ||' adj range_brk_qty '||l_adj_range_break_qty_tbl(i));
                qp_preq_grp.engine_debug('exp date '||l_cur_exp_date_tbl(i)
                ||' adj exp date '||l_adj_exp_date_tbl(i)
                ||' pricing sts text '||l_cur_prc_sts_txt_tbl(i));
                qp_preq_grp.engine_debug('ord_qty_adjamt '
                ||l_cur_ord_qty_adjamt(i)
                ||' adj ord_qty_adjamt '||l_adj_ord_qty_adjamt(i)
                ||' ord_qty_operand '||l_cur_ord_qty_operand(i)
                ||' adj ord_qty_operand '||l_adj_ord_qty_operand(i));
                END IF;--debug


                        IF
                        nvl(l_cur_adj_amt_tbl(i),FND_API.G_MISS_NUM) =
                        nvl(l_adj_adj_amt_pqty_tbl(i),FND_API.G_MISS_NUM)
                        AND nvl(l_cur_operand_tbl(i),FND_API.G_MISS_NUM) =
                        nvl(l_adj_operand_pqty_tbl(i),FND_API.G_MISS_NUM)
                        AND nvl(l_cur_pricing_grp_seq_tbl(i),-1) =
                                nvl(l_adj_pricing_grp_seq_tbl(i),-1)
                        AND nvl(l_cur_charge_type_tbl(i),'NULL') =
                                nvl(l_adj_charge_type_tbl(i),'NULL')
                        AND nvl(l_cur_charge_subtype_tbl(i),'NULL') =
                                nvl(l_adj_charge_subtype_tbl(i), 'NULL')
                        AND nvl(l_cur_price_brk_type_tbl(i), 'NULL') =
                                nvl(l_adj_price_brk_type_tbl(i), 'NULL')
                        AND nvl(l_cur_operator_tbl(i),'NULL') =
                                nvl(l_adj_operator_tbl(i), 'NULL')
                        AND nvl(l_cur_phase_id_tbl(i),0) =
                                nvl(l_adj_phase_id_tbl(i),0)
                        AND nvl(l_cur_automatic_flag_tbl(i),' ') =
                                nvl(l_adj_automatic_flag_tbl(i),' ')
                        AND nvl(l_cur_override_flag_tbl(i),' ') =
                                nvl(l_adj_update_allowed_tbl(i),' ')
                        AND nvl(l_cur_substn_attr_tbl(i),'NULL') =
                                nvl(l_adj_substn_attr_tbl(i),'NULL')
                        AND nvl(l_cur_substn_val_to_tbl(i), 'NULL') =
                                nvl(l_adj_modified_to_tbl(i), 'NULL')
                        AND nvl(l_cur_benefit_qty_tbl(i),0) =
                                nvl(l_adj_benefit_qty_tbl(i),0)
                        AND nvl(l_cur_benefit_uom_code_tbl(i),'NULL') =
                                nvl(l_adj_benefit_uom_code_tbl(i),'NULL')
                        AND nvl(l_cur_accrual_flag_tbl(i),' ') =
                                nvl(l_adj_accrual_flag_tbl(i),'NULL')
                        AND nvl(l_cur_accr_conv_rate_tbl(i),0) =
                                nvl(l_adj_accrual_conv_rate_tbl(i),0)
                        AND nvl(l_cur_reb_txn_type_tbl(i),'NULL') =
                                nvl(l_adj_rebate_txn_type_tbl(i),'NULL')
                        AND nvl(l_cur_prorat_type_tbl(i),'NULL') =
                                nvl(l_adj_prorat_type_tbl(i),'NULL')
                        AND nvl(l_cur_include_ret_flag_tbl(i), ' ') =
                                nvl(l_adj_include_ret_flag_tbl(i),' ')
                        AND nvl(l_cur_exp_date_tbl(i),FND_API.G_MISS_DATE) =
                                nvl(l_adj_exp_date_tbl(i), FND_API.G_MISS_DATE)
                        AND nvl(l_cur_line_qty_tbl(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_range_break_qty_tbl(i), FND_API.G_MISS_NUM)
                        AND nvl(l_cur_ord_qty_adjamt(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_ord_qty_adjamt(i), FND_API.G_MISS_NUM)
                        AND nvl(l_cur_ord_qty_operand(i),FND_API.G_MISS_NUM) =
                                nvl(l_adj_ord_qty_operand(i), FND_API.G_MISS_NUM)
                        THEN
                                x:=x+1;
                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('if update check '||x);
                        qp_preq_grp.engine_debug('update check dtls '
                        ||l_cur_dtl_index_tbl(i)||' adj_id '
                        ||l_cur_price_adj_id_tbl(i)||' id '
                        ||l_cur_list_line_id_tbl(i)||' adj adj amt '
                        ||l_adj_adj_amt_pqty_tbl(i)||' adj amt '
                        ||l_cur_adj_amt_tbl(i));
                END IF;  --Bug No 4033618
                        l_line_index_tbl(x) := l_cur_line_index_tbl(i);
                        l_line_dtl_index_tbl(x) := l_cur_dtl_index_tbl(i);
                        l_price_adj_id_tbl(x) := l_cur_price_adj_id_tbl(i);
                        l_process_code_tbl(x) := QP_PREQ_PUB.G_STATUS_UNCHANGED;
                        l_pricing_sts_text_tbl(x) := 'ADJUSTMENT INFO UNCHANGED';
                        ELSE
                                x:=x+1;
                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('else update check '||x);
                        qp_preq_grp.engine_debug('update check dtls '
                        ||l_cur_dtl_index_tbl(i)||' adj_id '
                        ||l_cur_price_adj_id_tbl(i)||' id '
                        ||l_cur_list_line_id_tbl(i)||' adj adj amt '
                        ||l_adj_adj_amt_pqty_tbl(i)||' adj amt '
                        ||l_cur_adj_amt_tbl(i));
                END IF; --Bug No 4033618
                        l_line_index_tbl(x) := l_cur_line_index_tbl(i);
                        l_line_dtl_index_tbl(x) := l_cur_dtl_index_tbl(i);
                        l_price_adj_id_tbl(x) := l_cur_price_adj_id_tbl(i);
                        l_process_code_tbl(x) := QP_PREQ_PUB.G_STATUS_UPDATED;
                        l_pricing_sts_text_tbl(x) := l_cur_prc_sts_txt_tbl(i);
                        END IF;

                END LOOP;--check each rec from fetch
        END LOOP;--bulk fetch
        CLOSE l_update_int_cur;
      --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
      END IF;
      --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881

        IF l_line_dtl_index_tbl.COUNT > 0
        THEN

                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
                THEN
                        FOR x IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
                        LOOP
   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Cleanup debug '
                        ||' line index '||l_line_index_tbl(x)
                        ||' line dtl index '||l_line_dtl_index_tbl(x)
                        ||' price_adj_id '||l_price_adj_id_tbl(x)
                        ||' process code '||l_process_code_tbl(x)
                        ||' status text '||l_pricing_sts_text_tbl(x));
   END IF;
                        END LOOP;
                END IF;
              --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
              IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N' THEN
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.ENGINE_DEBUG('Java Engine not Installed ----------');
                END IF;
                --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881

                FORALL x IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
                        UPDATE qp_npreq_ldets_tmp
                        SET process_code = l_process_code_tbl(x)
                                , price_adjustment_id = l_price_adj_id_tbl(x)
                                , pricing_status_text = l_pricing_sts_text_tbl(x)
                        WHERE line_index = l_line_index_tbl(x)
                        and line_detail_index = l_line_dtl_index_tbl(x);
              --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
              ELSE
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.ENGINE_DEBUG('Java Engine is Installed ----------');
                END IF;
                FORALL x IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
                        UPDATE qp_int_ldets
                        SET process_code = l_process_code_tbl(x)
                                , price_adjustment_id = l_price_adj_id_tbl(x)
                                , pricing_status_text = l_pricing_sts_text_tbl(x)
                        WHERE line_index = l_line_index_tbl(x)
                        and line_detail_index = l_line_dtl_index_tbl(x);
              END IF;
              --ADDED BY YANGLI FOR JAVA ENGINE PUB 3086881
        END IF;
/*
        UPDATE qp_npreq_line_attrs_tmp lattr
                SET lattr.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
                WHERE lattr.attribute_type = QP_PREQ_PUB.G_PRICING_TYPE
                and EXISTS ( SELECT 'X' FROM
                        qp_npreq_lines_tmp line,
                        qp_npreq_ldets_tmp ldet,
                        oe_price_adjustments adj,
                        oe_price_adj_attribs_v attr
                        WHERE line.price_flag in
                                (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
                        and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                        and line.pricing_status_code in
                        (QP_PREQ_PUB.G_STATUS_UPDATED,
                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
                        and ldet.line_index = line.line_index
                        and ldet.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                        and adj.line_id = line.line_id
                        and attr.price_adjustment_id = adj.price_adjustment_id
                        and attr.pricing_context = lattr.context
                        and attr.pricing_attribute = lattr.attribute
                        and attr.pricing_attr_value_from = lattr.value_from
                        UNION
                        SELECT 'X' FROM
                        qp_npreq_lines_tmp line,
                        qp_npreq_ldets_tmp ldet,
                        oe_price_adjustments adj,
                        oe_price_adj_attribs_v attr
                        WHERE line.price_flag in
                                (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
                        and line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                        and line.pricing_status_code in
                        (QP_PREQ_PUB.G_STATUS_UPDATED,
                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                        QP_PREQ_PUB.G_STATUS_GSA_VIOLATION)
                        and ldet.line_index = line.line_index
                        and ldet.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                        and adj.header_id = line.line_id
                        and adj.line_id is null
                        and attr.price_adjustment_id = adj.price_adjustment_id
                        and attr.pricing_context = lattr.context
                        and attr.pricing_attribute = lattr.attribute
                        and attr.pricing_attr_value_from = lattr.value_from);


        IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        for cl in l_attr_cur
        loop
                qp_preq_grp.engine_debug('attr details '
                ||cl.line_index||' dtl index '||cl.line_detail_index
                ||' sts code '||cl.pricing_status_code||' context '
                ||cl.context||' attr '||cl.attribute
                ||' val from '||cl.value_from);
        end loop;
        END IF;
*/



END IF;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Completed QP_CLEANUP.cleanup_adjustments');
 END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
When OTHERS Then
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('error in QP_CLEANUP_ADJ.cleanup_adjustments '||SQLERRM);
END IF;
x_return_status := FND_API.G_RET_STS_ERROR;
--x_return_status_text := 'error QP_CLEANUP_ADJ.cleanup_adjustments '||SQLERRM';

END cleanup_adjustments;

FUNCTION Get_line_detail_index(p_line_index IN NUMBER,
                                p_price_adj_id IN NUMBER)
RETURN NUMBER IS
BEGIN
        l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
IF G_PBH_PLSQL_IND.EXISTS(mod(p_price_adj_id,G_BINARY_LIMIT)) THEN   --8744755
IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('begin get loop ');
  END IF;--l_debug
FOR i IN G_PBH_LINE_DTL_INDEX.FIRST..G_PBH_LINE_DTL_INDEX.LAST
LOOP
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('in get loop '||G_PBH_LINE_INDEX(i)||' '
        ||G_PBH_PRICE_ADJ_ID(i));
  END IF;--l_debug
  IF G_PBH_LINE_INDEX(i) = p_line_index
  and G_PBH_PRICE_ADJ_ID(i) = p_price_adj_id THEN
        Return G_PBH_LINE_DTL_INDEX(i);
  END IF;
END LOOP;
END IF;--G_PBH_PLSQL_IND.EXISTS

G_MAX_DTL_INDEX := G_MAX_DTL_INDEX + 1;
Return G_MAX_DTL_INDEX;

EXCEPTION
When OTHERS THEN
G_MAX_DTL_INDEX := G_MAX_DTL_INDEX + 1;
Return G_MAX_DTL_INDEX;
END Get_line_detail_index;

PROCEDURE Insert_Rltd_Lines(p_request_type_code IN VARCHAR2,
                                p_calculate_flag IN VARCHAR2,
                                p_event_code IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

CURSOR l_rltd_line_info_cur IS
        SELECT /*+ ORDERED USE_NL(adj_pbh ass adj attr) */
/*index(ass OE_PRICE_ADJ_ASSOCS_N3)*/
         line.line_index line_index,
         adj_pbh.price_adjustment_id line_detail_index,
         line.line_index related_line_index,
         ass.rltd_price_adj_id related_line_detail_index,
         adj_pbh.list_line_id list_line_id,
         adj.list_line_id related_list_line_id,
         adj.list_line_type_code related_list_line_type,
         adj.arithmetic_operator,
         nvl(adj.operand_per_pqty, adj.operand) operand,
         adj_pbh.pricing_group_sequence,
         adj_pbh.price_break_type_code,
         adj_pbh.modifier_level_code,
         attr.pricing_attr_value_from setup_value_from,
         attr.pricing_attr_value_to setup_value_to,
         adj_pbh.range_break_quantity,
--added these columns to insert child break lines for bug 3314259
         adj.pricing_phase_id,
         adj.automatic_flag,
         adj.applied_flag,
         adj.updated_flag,
         attr.list_header_id,
         adj.list_line_no
        FROM qp_npreq_lines_tmp line
                ,oe_price_adjustments adj_pbh
                ,oe_price_adj_assocs ass
                ,oe_price_adjustments adj
                , qp_pricing_attributes attr
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
        and line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
        and line.line_id = adj_pbh.line_id
        and adj_pbh.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
        and (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or adj_pbh.updated_flag = QP_PREQ_PUB.G_YES
                or p_event_code = ',' --we pad comma when it is null
                or adj_pbh.pricing_phase_id not in
                (select ph.pricing_phase_id
                from qp_event_phases evt , qp_pricing_phases ph
                where ph.pricing_phase_id = evt.pricing_phase_id
---introduced the end date condition for bug 8976668 condition was missed during the fix of 3376902
                and (evt.end_date_active is null or (evt.end_date_active is not null and evt.end_date_active > line.pricing_effective_date))
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,evt.pricing_event_code||',') > 0
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id,line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
        and adj_pbh.price_adjustment_id = ass.price_adjustment_id
        and ass.rltd_price_adj_id = adj.price_adjustment_id
        and attr.list_line_id = adj.list_line_id
        and attr.pricing_attribute_context = QP_PREQ_PUB.G_PRIC_VOLUME_CONTEXT
        UNION
        SELECT /*+ ORDERED USE_NL(adj_pbh ass adj attr) */
--/*+ index(ass OE_PRICE_ADJ_ASSOCS_N3)*/
--      (adj_pbh.quote_header_id+nvl(adj_pbh.quote_line_id,0)) line_index,
        line.line_index,
         adj_pbh.line_detail_index line_detail_index,
--         adj.quote_line_id related_line_index,
        line.line_index related_line_index,
         ass.related_line_detail_index related_line_detail_index,
         adj_pbh.created_from_list_line_id list_line_id,
         adj.created_from_list_line_id related_list_line_id,
         adj.created_from_list_line_type related_list_line_type,
         adj.operand_calculation_code arithmetic_operator,
         adj.operand_value operand,
         adj_pbh.pricing_group_sequence,
         adj_pbh.price_break_type_code,
         adj_pbh.modifier_level_code,
         attr.pricing_attr_value_from setup_value_from,
         attr.pricing_attr_value_to setup_value_to,
         adj_pbh.line_quantity range_break_quantity,
--added these columns to insert child break lines for bug 3314259
         adj.pricing_phase_id,
         adj.automatic_flag,
         adj.applied_flag,
         adj.updated_flag,
         attr.list_header_id,
         adj.list_line_no
        FROM qp_npreq_lines_tmp line
                ,qp_npreq_ldets_tmp adj_pbh
                ,qp_npreq_rltd_lines_tmp ass
                ,qp_npreq_ldets_tmp adj
                , qp_pricing_attributes attr
--        WHERE p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> QP_PREQ_PUB.G_YES
        and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
        and line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
        and line.line_index = adj_pbh.line_index
        and adj_pbh.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
        and adj_pbh.created_from_list_line_type = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
        and (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or adj_pbh.updated_flag = QP_PREQ_PUB.G_YES
                or p_event_code = ',' --we pad comma when it is null
                or adj_pbh.pricing_phase_id not in
                (select ph.pricing_phase_id
                from qp_event_phases evt, qp_pricing_phases ph
                where ph.pricing_phase_id = evt.pricing_phase_id
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,evt.pricing_event_code||',') > 0
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
        and ass.line_detail_index = adj_pbh.line_detail_index
        and adj.line_detail_index = ass.related_line_detail_index
        and attr.list_line_id = adj.created_from_list_line_id
        and attr.pricing_attribute_context = QP_PREQ_PUB.G_PRIC_VOLUME_CONTEXT;


CURSOR l_pbh_adj_exists_cur IS
        SELECT /*+ index(adj OE_PRICE_ADJUSTMENTS_N2) */ 'Y'
        FROM
                qp_npreq_lines_tmp line,
                oe_price_adjustments adj
--      WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and adj.line_id = line.line_id
        and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
        and adj.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
        and (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or adj.updated_flag = QP_PREQ_PUB.G_YES
                or p_event_code = ',' -- we pad ',' when it is null
                or adj.pricing_phase_id not in
                (select ph.pricing_phase_id
                from qp_event_phases evt, qp_pricing_phases ph
                where ph.pricing_phase_id = evt.pricing_phase_id
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,evt.pricing_event_code||',') > 0
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
        UNION
        SELECT /*+ index(adj OE_PRICE_ADJUSTMENTS_N1) */ 'Y'
        FROM
                qp_npreq_lines_tmp line,
                oe_price_adjustments adj
--        WHERE p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
        and adj.header_id = line.line_id
        and line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
        and adj.list_line_type_code = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
        and (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or p_event_code = ',' -- we pad ',' when it is null
                or adj.pricing_phase_id not in
                (select ph.pricing_phase_id
                from qp_event_phases evt, qp_pricing_phases ph
                where ph.pricing_phase_id = evt.pricing_phase_id
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,evt.pricing_event_code||',') > 0
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
        UNION
        SELECT 'Y'
        FROM
                qp_npreq_lines_tmp line,
                qp_npreq_ldets_tmp adj
--        WHERE p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        WHERE QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> QP_PREQ_PUB.G_YES
        and adj.line_index = line.line_index
        and adj.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
        and adj.created_from_list_line_type = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
        and (p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or p_event_code = ',' -- we pad ',' when it is null
                or adj.pricing_phase_id not in
                (select ph.pricing_phase_id
                from qp_event_phases evt, qp_pricing_phases ph
                where ph.pricing_phase_id = evt.pricing_phase_id
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,evt.pricing_event_code||',') > 0
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) = QP_PREQ_PUB.G_YES))));

l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_rltd_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_rltd_line_dtl_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_rltd_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_list_line_type_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_operand_calc_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_operand_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_pricing_group_seq_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_price_brk_type_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_setup_value_from_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_setup_value_to_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_qualifier_value_tbl QP_PREQ_GRP.NUMBER_TYPE;
--added these columns to insert child break lines for bug 3314259
l_mod_level_code_tbl QP_PREQ_GRP.VARCHAR_TYPE;
l_pricing_phase_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_auto_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_applied_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_updated_flag_tbl QP_PREQ_GRP.FLAG_TYPE;
l_list_hdr_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_list_line_no_tbl QP_PREQ_GRP.VARCHAR_TYPE;

l_pbh_adj_exists VARCHAR2(1) := QP_PREQ_PUB.G_NO;
N pls_integer;
BEGIN
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('Begin Insert_rltd_lines rqtyp '||p_request_type_code);
QP_PREQ_GRP.engine_debug('Begin Insert_rltd_lines calcflag '||p_calculate_flag);
QP_PREQ_GRP.engine_debug('Begin Insert_rltd_lines event '||p_event_code);

END IF;
        OPEN l_pbh_adj_exists_cur;
        FETCH l_pbh_adj_exists_cur INTO l_pbh_adj_exists;
        CLOSE l_pbh_adj_exists_cur;

 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Check l_pbh_adj_exists '||l_pbh_adj_exists);

 END IF;
N := 0;

        IF l_pbh_adj_exists = QP_PREQ_PUB.G_YES
        THEN
        l_line_index_tbl.delete;
        l_line_dtl_index_tbl.delete;
        l_rltd_line_index_tbl.delete;
        l_rltd_line_dtl_index_tbl.delete;
        l_list_line_id_tbl.delete;
        l_rltd_list_line_id_tbl.delete;
        l_list_line_type_code_tbl.delete;
        l_operand_calc_code_tbl.delete;
        l_operand_tbl.delete;
        l_pricing_group_seq_tbl.delete;
        l_price_brk_type_code_tbl.delete;
        l_setup_value_from_tbl.delete;
        l_setup_value_to_tbl.delete;
        l_qualifier_value_tbl.delete;
--added these columns to insert child break lines for bug 3314259
        l_mod_level_code_tbl.delete;
        l_pricing_phase_id_tbl.delete;
        l_auto_flag_tbl.delete;
        l_applied_flag_tbl.delete;
        l_updated_flag_tbl.delete;
        l_list_hdr_id_tbl.delete;
        l_list_line_no_tbl.delete;

                FOR I IN l_rltd_line_info_cur
                LOOP
   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('In l_rltd_line_info_cur');
   END IF;
                        N := N+1;
                        l_line_index_tbl(N):=I.line_index;
                        l_line_dtl_index_tbl(N) :=
                        Get_line_detail_index(I.line_index, I.line_detail_index);
                        l_rltd_line_index_tbl(N):=I.related_line_index;

                        l_rltd_line_dtl_index_tbl(N):=
                        Get_line_detail_index(I.related_line_index, I.related_line_detail_index);
                          IF l_debug = FND_API.G_TRUE THEN
                                QP_PREQ_GRP.engine_debug('Pbh dtl_index '
                                ||l_line_dtl_index_tbl(N)
                                ||' rltd_dtl_index '
                                ||l_rltd_line_dtl_index_tbl(N));
                          END IF;--l_debug
                        l_list_line_id_tbl(N):=I.list_line_id;
                        l_rltd_list_line_id_tbl(N):=I.related_list_line_id;
                        l_list_line_type_code_tbl(N):=I.related_list_line_type;
                        l_operand_calc_code_tbl(N):=I.arithmetic_operator;
                        l_operand_tbl(N):=I.operand;
                        l_pricing_group_seq_tbl(N):=I.pricing_group_sequence;
                        l_price_brk_type_code_tbl(N):=I.price_break_type_code;
                        l_setup_value_from_tbl(N):=
                        qp_number.canonical_to_number(I.setup_value_from);
                        l_setup_value_to_tbl(N):=
                        qp_number.canonical_to_number(I.setup_value_to);
                        l_qualifier_value_tbl(N):=I.range_break_quantity;
--added these columns to insert child break lines for bug 3314259
                        l_mod_level_code_tbl(N) := I.modifier_level_code;
                        l_pricing_phase_id_tbl(N) := I.pricing_phase_id;
                        l_auto_flag_tbl(N) := I.automatic_flag;
                        l_applied_flag_tbl(N) := I.applied_flag;
                        l_updated_flag_tbl(N) := I.updated_flag;
                        l_list_hdr_id_tbl(N) := I.list_header_id;
                        l_list_line_no_tbl(N) := I.list_line_no;

   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('price brk child details '
                        ||l_line_dtl_index_tbl(N)||' rltd_dtl '
                        ||l_rltd_line_dtl_index_tbl(N)||' bucket '
                        ||l_pricing_group_seq_tbl(N)||' '
                        ||' parent id '||l_list_line_id_tbl(N)
                        ||' child id '||l_rltd_list_line_id_tbl(N)
                        ||' operand '||l_operand_tbl(N)||' '
                        ||l_operand_calc_code_tbl(N)||' brk type '
                        ||l_price_brk_type_code_tbl(N)||' value from '
                        ||l_setup_value_from_tbl(N)||' value to '
                        ||l_setup_value_to_tbl(N)||' qualifier value '
                        ||l_qualifier_value_tbl(N));
   END IF;
                END LOOP;

   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('price brk after loop ');
   END IF;
                IF l_line_dtl_index_tbl.COUNT > 0
                THEN
   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('price brk before insert ');
   END IF;
                FORALL I IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
                        INSERT INTO qp_npreq_rltd_lines_tmp
                        (
                        pricing_status_text,
                        line_index,
                        line_detail_index,
                        relationship_type_code,
                        related_line_index,
                        related_line_detail_index,
                        pricing_status_code,
                        list_line_id,
                        related_list_line_id,
                        related_list_line_type,
                        operand_calculation_code,
                        operand,
                        pricing_group_sequence,
                        relationship_type_detail,
                        setup_value_from,
                        setup_value_to,
                        qualifier_value
                        )
                        VALUES
                        (
                        G_CALC_INSERT,
                        l_line_index_tbl(I),
                        l_line_dtl_index_tbl(I),
                        QP_PREQ_PUB.G_PBH_LINE,
                        l_rltd_line_index_tbl(I),
                        l_rltd_line_dtl_index_tbl(I),
                        QP_PREQ_PUB.G_STATUS_NEW,
                        l_list_line_id_tbl(I),
                        l_rltd_list_line_id_tbl(I),
                        l_list_line_type_code_tbl(I),
                        l_operand_calc_code_tbl(I),
                        l_operand_tbl(I),
                        l_pricing_group_seq_tbl(I),
                        l_price_brk_type_code_tbl(I),
                        l_setup_value_from_tbl(I),
                        l_setup_value_to_tbl(I),
                        l_qualifier_value_tbl(I)
                        );

                --added this insert for bug 3314259 to insert child break lines to tmp table
                FORALL I IN l_line_dtl_index_tbl.FIRST..l_line_dtl_index_tbl.LAST
                INSERT INTO qp_npreq_ldets_tmp
                (
                line_detail_index
                ,line_index
                ,line_detail_type_code
                ,pricing_status_code
                ,pricing_status_text
                ,process_code
                ,created_from_list_header_id
                ,created_from_list_line_id
                ,created_from_list_line_type
                ,adjustment_amount
                ,operand_value
                ,modifier_level_code
                ,price_break_type_code
--                ,line_quantity
                ,operand_calculation_code
                ,pricing_group_sequence
--                ,created_from_list_type_code
                ,applied_flag
--                ,limit_code
--                ,limit_text
                ,list_line_no
--                ,charge_type_code
--                ,charge_subtype_code
                ,updated_flag
                ,automatic_flag
                ,pricing_phase_id)
                values
                (l_rltd_line_dtl_index_tbl(I)
                ,l_rltd_line_index_tbl(I)
                ,QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- bug 3487840, pass QP_PREQ_GRP.G_CHILD_DETAIL_TYPE instead of null
                ,QP_PREQ_PUB.G_STATUS_NEW
                ,''
                ,QP_PREQ_PUB.G_STATUS_NEW
                ,l_list_hdr_id_tbl(I) --put list_header_id
                ,l_rltd_list_line_id_tbl(I)
                ,l_list_line_type_code_tbl(I)
                ,0
                ,l_operand_tbl(I)
                ,l_mod_level_code_tbl(I) --modifier_level_code
                ,l_price_brk_type_code_tbl(I)
                ,l_operand_calc_code_tbl(I)
                ,l_pricing_group_seq_tbl(I)
                ,l_applied_flag_tbl(I) --QP_PREQ_PUB.G_YES
                ,l_list_line_no_tbl(I)
                ,l_updated_flag_tbl(I) --QP_PREQ_PUB.G_YES
                ,l_auto_flag_tbl(I) --QP_PREQ_PUB.G_NO
                ,l_pricing_phase_id_tbl(I));

   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('price brk after insert ');

   END IF;
                END IF;
        END IF;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('End Insert_rltd_lines');
 END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
When OTHERS Then
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Error Insert_rltd_lines'||SQLERRM);
 END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status_text := 'Error in QP_CLEANUP_ADJUSTMENTS.Insert_Rltd_Lines '||SQLERRM;
END Insert_Rltd_Lines;



PROCEDURE fetch_adjustments(p_view_code IN VARCHAR2,
                                p_event_code IN VARCHAR2,
                                p_calculate_flag IN VARCHAR2,
                                p_rounding_flag IN VARCHAR2,
                                p_request_type_code IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2) IS

--changed to make sure lumpsum on order level frt charge divide by 1 quantity
CURSOR l_calculate_cur IS
        select /*+ ORDERED USE_NL(adj qplh) */
                   adj.list_line_id created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , adj.price_adjustment_id line_detail_index
                , adj.list_line_type_code created_from_list_line_type
                , adj.list_header_id created_from_list_header_id
                , adj.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , adj.range_break_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , adj.automatic_flag
                , adj.update_allowed override_flag
                , adj.pricing_group_sequence
                , adj.arithmetic_operator operand_calculation_code
                , nvl(adj.operand_per_pqty,adj.operand) operand_value
                , nvl(adj.adjusted_amount_per_pqty,
                      adj.adjusted_amount) adjustment_amount -- 4757680
                , line.unit_price
                , adj.accrual_flag
                , nvl(adj.updated_flag, QP_PREQ_PUB.G_NO)
                , 'N' process_code
                , 'N' pricing_status_code
                , ' ' pricing_status_text
                , adj.price_break_type_code
                , adj.charge_type_code
                , adj.charge_subtype_code
                , line.rounding_factor
                , adj.pricing_phase_id
                , qplh.list_type_code created_from_list_type_code -- [4222237/4500246]
                , '' limit_code
                , '' limit_text
                , adj.list_line_no
                , adj.modifier_level_code
                , adj.range_break_quantity group_quantity
                , adj.range_break_quantity group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_ADJ_LINE_TYPE is_ldet_rec
                , line.line_type_code
                , NULL net_amount_flag  --bucketed_flag
                , NULL calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , NULL line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line, oe_price_adjustments adj,
                qp_list_headers_b qplh
--        where p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        where QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
                -- bug# 2739322
                -- not needed as this condition will always be false having this was causing the bug where
                -- the adjustments against the freegood line are not getting selected
                -- also we would like to get the adjustments for the freegood line
                -- and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and adj.line_id = line.line_id
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE,QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and line.unit_price is not null -- bug 3501866, calculation to be done for line having unit price
                and (adj.updated_flag = QP_PREQ_PUB.G_YES
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or (p_event_code is null and adj.updated_flag is null)
                or adj.pricing_phase_id not in (select ph.pricing_phase_id
                        from qp_event_phases ev, qp_pricing_phases ph
--changes to enable multiple events passed as a string
                where ph.pricing_phase_id = ev.pricing_phase_id
---introduced the end date condition for bug 3376902
                and (ev.end_date_active is null or (ev.end_date_active is not null and ev.end_date_active > line.pricing_effective_date))
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,ev.pricing_event_code||',') > 0
                -- 3721860, pass list_line_id and line_index both for function Get_buy_line_price_flag
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
                and adj.modifier_level_code IN (QP_PREQ_PUB.G_LINE_LEVEL,QP_PREQ_PUB.G_LINE_GROUP)
--              and adj.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW,QP_PREQ_PUB.G_STATUS_UPDATED)
        --commented to fetch auto overridden unapplied adj(user deleted)
--              and adj.applied_flag = QP_PREQ_PUB.G_YES
--              and adj.list_line_type_code IN (QP_PREQ_PUB.G_DISCOUNT
--                        , QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
              and qplh.list_header_id = adj.list_header_id
              and qplh.list_type_code not in (QP_PREQ_PUB.G_PRICE_LIST_HEADER,
                        QP_PREQ_PUB.G_AGR_LIST_HEADER)
              and not exists (select 'x'
                              from oe_price_adj_assocs a, oe_price_adjustments b
                              where a.RLTD_PRICE_ADJ_ID = adj.price_adjustment_id
                              and b.price_adjustment_id = a.price_adjustment_id
                              and b.list_line_type_code = QP_PREQ_GRP.G_PRICE_BREAK_TYPE)
        UNION
        select /*+ ORDERED USE_NL(adj line qplh)  index(adj OE_PRICE_ADJUSTMENTS_N1) dynamic_sampling(1) */ -- Bug No: 6753550
                   adj.list_line_id created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , adj.price_adjustment_id line_detail_index
                , adj.list_line_type_code created_from_list_line_type
                , adj.list_header_id created_from_list_header_id
                , adj.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , adj.range_break_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , adj.automatic_flag
                , adj.update_allowed override_flag
                , adj.pricing_group_sequence
                , adj.arithmetic_operator operand_calculation_code
                , nvl(adj.operand_per_pqty, adj.operand) operand_value
                , adj.adjusted_amount_per_pqty adjustment_amount
                , line.unit_price
                , adj.accrual_flag
                , nvl(adj.updated_flag, QP_PREQ_PUB.G_NO)
                , 'N' process_code
                , 'N' pricing_status_code
                , ' ' pricing_status_text
                , adj.price_break_type_code
                , adj.charge_type_code
                , adj.charge_subtype_code
                , line.rounding_factor
                , adj.pricing_phase_id
                , qplh.list_type_code created_from_list_type_code -- [4222237/4500246]
                , '' limit_code
                , '' limit_text
                , adj.list_line_no
                , adj.modifier_level_code
                , adj.range_break_quantity group_quantity
                , adj.range_break_quantity group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_ADJ_ORDER_TYPE is_ldet_rec
                , line.line_type_code
                , NULL net_amount_flag  --bucketed_flag
                , NULL calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , NULL line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line1, oe_price_adjustments adj
                ,qp_npreq_lines_tmp line, qp_list_headers_b qplh
--        where p_request_type_code = 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        where QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES
                --and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line1.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.line_id = adj.header_id
                and line1.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and (line1.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line1.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and (line.unit_price is not null or line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL) -- bug 3501866
                and (adj.updated_flag = QP_PREQ_PUB.G_YES
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
                or (p_event_code is null and adj.updated_flag is null)
                or adj.pricing_phase_id not in (select ph.pricing_phase_id
                        from qp_event_phases ev, qp_pricing_phases ph
--changes to enable multiple events passed as a string
                where ph.pricing_phase_id = ev.pricing_phase_id
---introduced the end date condition for bug 3376902
                and (ev.end_date_active is null or (ev.end_date_active is not null and ev.end_date_active > line.pricing_effective_date))
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,ev.pricing_event_code||',') > 0
-- Ravi changed from line.price_flag to line1.price_flag , bug# 2739322 where the order level discounts are not
-- getting selected with each line, since line has price_flag = 'Y' and is in phase
-- by making it line1.price_flag , the summary line's price_flag = 'P'(when there is a freegood line created with
-- partial price) it works as though it is out of phase as price_flag = 'P' and freeze_override_flag = 'N' and the
-- modifier is selected across all the lines
                -- 3721860, pass list_line_id and line_index both for function Get_buy_line_price_flag
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line1.line_index),line1.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(adj.list_line_id, line1.line_index),line1.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) = QP_PREQ_PUB.G_YES))))
                and adj.modifier_level_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and adj.line_id is null
--              and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW,QP_PREQ_PUB.G_STATUS_UPDATED)
--              and ldet.applied_flag = QP_PREQ_PUB.G_YES
--                and adj.list_line_type_code IN (QP_PREQ_PUB.G_DISCOUNT
--                        , QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and qplh.list_header_id = adj.list_header_id
                and qplh.list_type_code not in (QP_PREQ_PUB.G_PRICE_LIST_HEADER,
                        QP_PREQ_PUB.G_AGR_LIST_HEADER)
        UNION
        select /*+ ORDERED USE_NL(ldet) index(ldet QP_PREQ_LDETS_TMP_N1) */
                ldet.created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , ldet.line_detail_index
                , ldet.created_from_list_line_type
                , ldet.created_from_list_header_id
                , ldet.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , ldet.line_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , ldet.automatic_flag
                , ldet.override_flag
                , ldet.pricing_group_sequence
                , ldet.operand_calculation_code
                , ldet.operand_value
                , ldet.adjustment_amount
                , line.unit_price
                , ldet.accrual_flag
                , nvl(ldet.updated_flag, QP_PREQ_PUB.G_NO)
                , ldet.process_code
                , ldet.pricing_status_code
                , ldet.pricing_status_text
                , ldet.price_break_type_code
                , ldet.charge_type_code
                , ldet.charge_subtype_code
                , line.rounding_factor
                , ldet.pricing_phase_id
                , ldet.created_from_list_type_code
                , ldet.limit_code
                , substr(ldet.limit_text,1,240)
                , ldet.list_line_no
                , ldet.modifier_level_code
                , ldet.group_quantity group_quantity
                , ldet.group_amount group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_LDET_LINE_TYPE is_ldet_rec
                , line.line_type_code
                , ldet.net_amount_flag net_amount_flag  --bucketed_flag
                , ldet.calculation_code calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , ldet.line_detail_type_code line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line, qp_npreq_ldets_tmp ldet
        where line.line_index = ldet.line_index
                --and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and line.unit_price is not null -- bug 3501866, calculation to be done for line having unit price
                and ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW,QP_PREQ_PUB.G_STATUS_UPDATED)--,QP_PREQ_PUB.G_STATUS_UNCHANGED)
--fix for frt charge issue to calculate adj amt for manual frt charge
                and (ldet.applied_flag = QP_PREQ_PUB.G_YES
                        or (ldet.applied_flag = QP_PREQ_PUB.G_NO
                        and ldet.created_from_list_line_type =
                                        QP_PREQ_PUB.G_FREIGHT_CHARGE
                        and ldet.automatic_flag = QP_PREQ_PUB.G_NO))
--              and ldet.created_from_list_line_type IN (QP_PREQ_PUB.G_DISCOUNT
--                      , QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and ldet.created_from_list_type_code not in
                (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER)
                and ldet.modifier_level_code IN (QP_PREQ_PUB.G_LINE_LEVEL,QP_PREQ_PUB.G_LINE_GROUP)
                and nvl(ldet.line_detail_type_code,'NULL') <> QP_PREQ_PUB.G_CHILD_DETAIL_TYPE
        UNION
        select /*+ ORDERED USE_NL(ldet line) index(ldet QP_PREQ_LDETS_TMP_N1) */
                ldet.created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , ldet.line_detail_index
                , ldet.created_from_list_line_type
                , ldet.created_from_list_header_id
                , ldet.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , ldet.line_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , ldet.automatic_flag
                , ldet.override_flag
                , ldet.pricing_group_sequence
                , ldet.operand_calculation_code
                , ldet.operand_value
                , ldet.adjustment_amount
                , line.unit_price
                , ldet.accrual_flag
                , nvl(ldet.updated_flag, QP_PREQ_PUB.G_NO)
                , ldet.process_code
                , ldet.pricing_status_code
                , ldet.pricing_status_text
                , ldet.price_break_type_code
                , ldet.charge_type_code
                , ldet.charge_subtype_code
                , line.rounding_factor
                , ldet.pricing_phase_id
                , ldet.created_from_list_type_code
                , ldet.limit_code
                , substr(ldet.limit_text,1,240)
                , ldet.list_line_no
                , ldet.modifier_level_code
                , ldet.group_quantity group_quantity
                , ldet.group_amount group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_LDET_ORDER_TYPE is_ldet_rec
                , line.line_type_code
                , ldet.net_amount_flag net_amount_flag  --bucketed_flag
                , ldet.calculation_code calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , ldet.line_detail_type_code line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line1, qp_npreq_ldets_tmp ldet
                                   , qp_npreq_lines_tmp line
        where --line.line_index = p_line_index
                ldet.line_index = line1.line_index
                --and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line1.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE)
                and line1.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
--              and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and (line.unit_price is not null or line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL) -- bug 3501866
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                AND ldet.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_NEW,QP_PREQ_PUB.G_STATUS_UPDATED)
--fix for frt charge issue to calculate adj amt for manual frt charge
                and (ldet.applied_flag = QP_PREQ_PUB.G_YES
                        or (ldet.applied_flag = QP_PREQ_PUB.G_NO
                        and ldet.created_from_list_line_type =
                                        QP_PREQ_PUB.G_FREIGHT_CHARGE
                        and ldet.automatic_flag = QP_PREQ_PUB.G_NO))
--              and ldet.created_from_list_line_type IN (QP_PREQ_PUB.G_DISCOUNT,
--                      QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and ldet.modifier_level_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and ldet.created_from_list_type_code not in
                (QP_PREQ_PUB.G_PRICE_LIST_HEADER, QP_PREQ_PUB.G_AGR_LIST_HEADER)
        UNION
        select /*+ ORDERED USE_NL(ldet qplh) index(ldet QP_PREQ_LDETS_TMP_N1) */
                ldet.created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , ldet.line_detail_index
                , ldet.created_from_list_line_type
                , ldet.created_from_list_header_id
                , ldet.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , ldet.line_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , ldet.automatic_flag
                , ldet.override_flag
                , ldet.pricing_group_sequence
                , ldet.operand_calculation_code
                , ldet.operand_value
                , ldet.adjustment_amount
                , line.unit_price
                , ldet.accrual_flag
                , nvl(ldet.updated_flag, QP_PREQ_PUB.G_NO)
                , ldet.process_code
                , ldet.pricing_status_code
                , ldet.pricing_status_text
                , ldet.price_break_type_code
                , ldet.charge_type_code
                , ldet.charge_subtype_code
                , line.rounding_factor
                , ldet.pricing_phase_id
                , ldet.created_from_list_type_code
                , ldet.limit_code
                , substr(ldet.limit_text,1,240)
                , ldet.list_line_no
                , ldet.modifier_level_code
                , ldet.group_quantity group_quantity
                , ldet.group_amount group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_ASO_LINE_TYPE is_ldet_rec
                , line.line_type_code
                , ldet.net_amount_flag net_amount_flag  --bucketed_flag
                , ldet.calculation_code calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , ldet.line_detail_type_code line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line, qp_npreq_ldets_tmp ldet,
                qp_list_headers_b qplh
--        where p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        where nvl(QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG,QP_PREQ_PUB.G_NO) <> QP_PREQ_PUB.G_YES
                --and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and line.line_type_code = QP_PREQ_PUB.G_LINE_LEVEL
                and line.unit_price is not null -- bug 3501866, calculation to be done for line having unit price
                and ldet.line_index = line.line_index
                and ldet.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
                and (ldet.updated_flag = QP_PREQ_PUB.G_YES
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
--              or (p_event_code is null and ldet.updated_flag is null)
                or ldet.pricing_phase_id not in (select ph.pricing_phase_id
                        from qp_event_phases ev, qp_pricing_phases ph
--changes to enable multiple events passed as a string
                where ph.pricing_phase_id = ev.pricing_phase_id
---introduced the end date condition for bug 3376902
                and (ev.end_date_active is null or (ev.end_date_active is not null and ev.end_date_active > line.pricing_effective_date))
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,ev.pricing_event_code||',') > 0
                -- 3721860, pass list_line_id and line_index both for function Get_buy_line_price_flag
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(ldet.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(ldet.created_from_list_line_id, line.line_index),line.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag,ph.freeze_override_flag) =
                        QP_PREQ_PUB.G_YES))))
                and ldet.modifier_level_code IN (QP_PREQ_PUB.G_LINE_LEVEL,QP_PREQ_PUB.G_LINE_GROUP)
        --commented to fetch auto overridden unapplied adj(user deleted)
--              and ldet.applied_flag = QP_PREQ_PUB.G_YES
--              and ldet.created_from_list_line_type IN (QP_PREQ_PUB.G_DISCOUNT
--                        , QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
              and qplh.list_header_id = ldet.created_from_list_header_id
              and qplh.list_type_code not in (QP_PREQ_PUB.G_PRICE_LIST_HEADER,
                        QP_PREQ_PUB.G_AGR_LIST_HEADER)
              and nvl(ldet.line_detail_type_code,'NULL') <> QP_PREQ_PUB.G_CHILD_DETAIL_TYPE -- updated in update_passed_in_pbh
        UNION
        select /*+ ORDERED USE_NL(ldet line qplh) index(ldet QP_PREQ_LDETS_TMP_N1) */
                ldet.created_from_list_line_id
                , line.line_index line_ind
                , line.line_index curr_line_index
                , line.line_id line_id
                , ldet.line_detail_index
                , ldet.created_from_list_line_type
                , ldet.created_from_list_header_id
                , ldet.applied_flag
                , (line.updated_adjusted_unit_price
                        - line.adjusted_unit_price) amount_changed
                , line.adjusted_unit_price
                , ldet.line_quantity priced_quantity
                , line.priced_quantity line_priced_quantity
                , line.updated_adjusted_unit_price
                , ldet.automatic_flag
                , ldet.override_flag
                , ldet.pricing_group_sequence
                , ldet.operand_calculation_code
                , ldet.operand_value
                , ldet.adjustment_amount
                , line.unit_price
                , ldet.accrual_flag
                , nvl(ldet.updated_flag, QP_PREQ_PUB.G_NO)
                , ldet.process_code
                , ldet.pricing_status_code
                , ldet.pricing_status_text
                , ldet.price_break_type_code
                , ldet.charge_type_code
                , ldet.charge_subtype_code
                , line.rounding_factor
                , ldet.pricing_phase_id
                , ldet.created_from_list_type_code
                , ldet.limit_code
                , substr(ldet.limit_text,1,240)
                , ldet.list_line_no
                , ldet.modifier_level_code
                , ldet.group_quantity group_quantity
                , ldet.group_amount group_amount
                , line.pricing_status_code line_pricing_status_code
                , QP_PREQ_PUB.G_ASO_ORDER_TYPE is_ldet_rec
                , line.line_type_code
                , ldet.net_amount_flag net_amount_flag  --bucketed_flag
                , ldet.calculation_code calculation_code
                , line.catchweight_qty
                , line.actual_order_quantity
                , line.line_unit_price
                , line.line_quantity ordered_qty
                , ldet.line_detail_type_code line_detail_type_code
                , line.line_category
                , line.price_flag
        from qp_npreq_lines_tmp line1, qp_npreq_ldets_tmp ldet
                ,qp_npreq_lines_tmp line, qp_list_headers_b qplh
--        where p_request_type_code <> 'ONT'
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
        where nvl(QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG,QP_PREQ_PUB.G_NO) <> QP_PREQ_PUB.G_YES
                --and nvl(line.processed_flag,'N') <> QP_PREQ_PUB.G_FREEGOOD_LINE -- Ravi
                and line1.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line.process_status in (QP_PREQ_PUB.G_STATUS_UPDATED,
                                        QP_PREQ_PUB.G_STATUS_NEW,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        'NEW'||QP_PREQ_PUB.G_STATUS_UNCHANGED,
                --fix for bug 2823886 to do cleanup and calc for old fg line
                                        'OLD'||QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL
                and (line1.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line1.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and (line.price_flag in (QP_PREQ_PUB.G_YES, QP_PREQ_PUB.G_PHASE, QP_PREQ_PUB.G_CALCULATE_ONLY)
                OR nvl(line.processed_code,'0') = QP_PREQ_PUB.G_BY_ENGINE)
                and (line.unit_price is not null or line.line_type_code = QP_PREQ_PUB.G_ORDER_LEVEL) -- bug 3501866
                and line.pricing_status_code IN (QP_PREQ_PUB.G_STATUS_UPDATED
                            ,QP_PREQ_PUB.G_STATUS_GSA_VIOLATION
                                ,QP_PREQ_PUB.G_STATUS_UNCHANGED)
                and line1.line_index = ldet.line_index
                and ldet.pricing_status_code = QP_PREQ_PUB.G_STATUS_UNCHANGED
                and (ldet.updated_flag = QP_PREQ_PUB.G_YES
                or line.price_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
--              or (p_event_code is null and ldet.updated_flag is null)
                or ldet.pricing_phase_id not in (select ph.pricing_phase_id
                        from qp_event_phases ev, qp_pricing_phases ph
--changes to enable multiple events passed as a string
                where ph.pricing_phase_id = ev.pricing_phase_id
---introduced the end date condition for bug 3376902
                and (ev.end_date_active is null or (ev.end_date_active is not null and ev.end_date_active > line.pricing_effective_date))
--introduced for freight_rating functionality to return only modifiers in
--phases where freight_exist = 'Y' if G_GET_FREIGHT_FLAG = 'Y'
                and ((QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_YES
                and ph.freight_exists = QP_PREQ_PUB.G_YES)
                or (QP_PREQ_PUB.G_GET_FREIGHT_FLAG = QP_PREQ_PUB.G_NO))
                and instr(p_event_code,ev.pricing_event_code||',') > 0
-- Ravi changed from line.price_flag to line1.price_flag
                -- 3721860, pass list_line_id and line_index both for function Get_buy_line_price_flag
                and (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(ldet.created_from_list_line_id, line1.line_index),line1.price_flag) = QP_PREQ_PUB.G_YES
                or (nvl(QP_PREQ_PUB.Get_buy_line_price_flag(ldet.created_from_list_line_id, line1.line_index),line1.price_flag) = QP_PREQ_PUB.G_PHASE
                and nvl(ph.user_freeze_override_flag, ph.freeze_override_flag) =
                         QP_PREQ_PUB.G_YES))))
                and ldet.modifier_level_code = QP_PREQ_PUB.G_ORDER_LEVEL
        --commented to fetch auto overridden unapplied adj(user deleted)
--              and ldet.applied_flag = QP_PREQ_PUB.G_YES
--              and ldet.created_from_list_line_type IN (QP_PREQ_PUB.G_DISCOUNT
--                        , QP_PREQ_PUB.G_SURCHARGE , QP_PREQ_PUB.G_PRICE_BREAK_TYPE, QP_PREQ_PUB.G_FREIGHT_CHARGE)
                and qplh.list_header_id = ldet.created_from_list_header_id
                and qplh.list_type_code not in (QP_PREQ_PUB.G_PRICE_LIST_HEADER,
                        QP_PREQ_PUB.G_AGR_LIST_HEADER)
        --order by line_ind,pricing_group_sequence,is_ldet_rec; -- 2892848 net_amt
        order by pricing_group_sequence,line_ind, is_ldet_rec; -- 2892848, net_amt


CURSOR l_max_dtl_index_cur IS
        SELECT max(line_detail_index)
        FROM qp_npreq_ldets_tmp;

Pricing_Exception Exception;

i Pls_Integer;
m Pls_Integer;
x Pls_Integer;
d Pls_Integer;
g Pls_Integer;
n Pls_Integer;

l_curr_line_index number := -1;--fnd_api.g_miss_num;
l_auto_line_dtl_index_tbl qp_preq_grp.number_type;
l_auto_override_dtl_id_tbl qp_preq_grp.number_type;

l_adj_tbl QP_PREQ_PUB.adj_tbl_type;
l_adj_overflow_tbl QP_PREQ_PUB.adj_tbl_type;
l_frt_tbl QP_PREQ_PUB.frt_charge_tbl;

l_list_line_id_tbl QP_PREQ_GRP.number_type;
l_line_index_tbl QP_PREQ_GRP.number_type;
l_curr_line_index_tbl QP_PREQ_GRP.number_type;
l_line_id_tbl QP_PREQ_GRP.number_type;
l_line_dtl_index_tbl QP_PREQ_GRP.number_type;
l_list_line_type_code_tbl QP_PREQ_GRP.varchar_type;
l_list_header_id_tbl QP_PREQ_GRP.number_type;
l_applied_flag_tbl QP_PREQ_GRP.flag_type;
l_amount_changed_tbl QP_PREQ_GRP.number_type;
l_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
l_priced_quantity_tbl QP_PREQ_GRP.number_type;
l_upd_adj_unit_price_tbl QP_PREQ_GRP.number_type;
l_automatic_flag_tbl QP_PREQ_GRP.flag_type;
l_override_flag_tbl QP_PREQ_GRP.flag_type;
l_pricing_group_sequence_tbl QP_PREQ_GRP.number_type;
l_operand_calc_code_tbl QP_PREQ_GRP.varchar_type;
l_operand_value_tbl QP_PREQ_GRP.number_type;
l_adjustment_amount_tbl QP_PREQ_GRP.number_type;
l_unit_price_tbl QP_PREQ_GRP.number_type;
l_accrual_flag_tbl QP_PREQ_GRP.flag_type;
l_updated_flag_tbl QP_PREQ_GRP.flag_type;
l_process_code_tbl QP_PREQ_GRP.varchar_type;
l_status_code_tbl QP_PREQ_GRP.varchar_type;
l_status_text_tbl QP_PREQ_GRP.varchar_type;
l_price_break_type_code_tbl QP_PREQ_GRP.varchar_type;
l_charge_type_code_tbl QP_PREQ_GRP.varchar_type;
l_charge_subtype_code_tbl QP_PREQ_GRP.varchar_type;
l_rounding_factor_tbl QP_PREQ_GRP.number_type;
l_pricing_phase_id_tbl QP_PREQ_GRP.number_type;
l_list_type_code_tbl QP_PREQ_GRP.varchar_type;
l_list_line_no_tbl QP_PREQ_GRP.varchar_type;
l_limit_code_tbl QP_PREQ_GRP.varchar_type;
l_limit_text_tbl QP_PREQ_GRP.varchar_type;
l_modifier_level_tbl QP_PREQ_GRP.varchar_type;
l_group_qty_tbl QP_PREQ_GRP.number_type;
l_group_amt_tbl QP_PREQ_GRP.number_type;
l_line_sts_code_tbl QP_PREQ_GRP.varchar_type;
l_is_ldet_rec_tbl QP_PREQ_GRP.varchar_type;
l_line_type_code_tbl QP_PREQ_GRP.varchar_type;
l_line_priced_qty_tbl QP_PREQ_GRP.number_type;
--2388011
l_net_amount_flag_tbl QP_PREQ_GRP.flag_type;
--2388011
l_calculation_code_tbl QP_PREQ_GRP.varchar_type;
l_catchweight_qty_tbl QP_PREQ_GRP.number_type;
l_actual_order_qty_tbl QP_PREQ_GRP.number_type;
l_line_unit_price_tbl QP_PREQ_GRP.number_type;
l_ord_qty_tbl QP_PREQ_GRP.number_type;
l_line_detail_type_code_tbl QP_PREQ_GRP.varchar_type;
l_line_category_tbl QP_PREQ_GRP.varchar_type;
l_price_flag_tbl QP_PREQ_GRP.flag_type;

l_prev_line_start_index number :=0;
l_cleanup_flag VARCHAR2(1) := QP_PREQ_PUB.G_YES;
nrows CONSTANT number := 2;

--added to check for duplicate list_line_ids
l_dup_ind NUMBER;
l_dup_updated_flag QP_PREQ_GRP.FLAG_TYPE;
l_dup_is_ldet_rec QP_PREQ_GRP.VARCHAR_TYPE;
l_dup_uniq_ind QP_PREQ_GRP.VARCHAR_TYPE;
l_dup_plsql_ind QP_PREQ_GRP.NUMBER_TYPE;
--added to check for duplicate list_line_ids

BEGIN

l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

IF l_debug = FND_API.G_TRUE THEN
 QP_PREQ_GRP.engine_debug('begin fetch adj event'||p_event_code);
 QP_PREQ_GRP.engine_debug('begin fetch adj reqtype '||p_request_type_code);
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
 QP_PREQ_GRP.engine_debug('begin fetch adj chk_cust '||QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG);
 QP_PREQ_GRP.engine_debug('begin fetch adj calc_flag '||p_calculate_flag);
 QP_PREQ_GRP.engine_debug('begin fetch adj round_flag '||p_rounding_flag);
 QP_PREQ_GRP.engine_debug('begin fetch adj view_code '||p_view_code);
 QP_PREQ_GRP.engine_debug('SL, with net_amt change, ordered by bucket, line_index.');
END IF;

--cleanup needs to be done only for OM as OC/OKC delete and insert adjustments
--setting up cleanup_flag accordingly to not peform cleanup for adj if
--not called by OM
--IF p_request_type_code = 'ONT' THEN
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES THEN
  l_cleanup_flag := QP_PREQ_PUB.G_YES;
ELSE
  l_cleanup_flag := QP_PREQ_PUB.G_NO;
END IF;--p_request_type_code

--fix for bug 2969419 this updated line_detail_type_code
--to recognize the PBH child lines. This update needs to be
--done before the l_calculate_cur fetch
--IF p_request_type_code <> 'ONT' THEN
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG <> QP_PREQ_PUB.G_YES THEN
  --This will be called for OC and others who will pass the PBH
  --and the relationship in which case the relationship needs to be updated
    QP_PREQ_PUB.Update_passed_in_pbh(x_return_status, x_return_status_text);
END IF;--p_request_type_code

        OPEN l_max_dtl_index_cur;
        FETCH l_max_dtl_index_cur INTO G_max_dtl_index;
        CLOSE l_max_dtl_index_cur;

        G_max_dtl_index := nvl(G_max_dtl_index,0);
        G_PBH_LINE_DTL_INDEX.delete;
        G_PBH_LINE_INDEX.delete;
        G_PBH_PRICE_ADJ_ID.delete;
        G_PBH_PLSQL_IND.delete;
        G_ORD_LVL_LDET_INDEX.delete; -- 3031108

 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('G_MAX_DTL_INDEX '||G_MAX_DTL_INDEX);

 END IF;

--to eliminate the duplicate manual adjustments in the temp table to prevent cleanup for them bug 2191169
--fix for bug 2515297 not to check applied_flag in this update
         UPDATE qp_npreq_ldets_tmp ldet2
                set ldet2.pricing_status_code = QP_PREQ_PUB.G_STATUS_DELETED,
                        pricing_status_text = 'DUPLICATE MANUAL-OVERRIDEABLE'
                where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                and nvl(ldet2.updated_flag,QP_PREQ_PUB.G_NO) = QP_PREQ_PUB.G_NO
                and exists ( select 'X'
                from qp_npreq_ldets_tmp ldet
                where nvl(ldet.updated_flag,QP_PREQ_PUB.G_NO) =QP_PREQ_PUB.G_YES
                and ldet.line_index = ldet2.line_index
                and ldet.created_from_list_line_id =
                                ldet2.created_from_list_line_id);

       IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('DUPLICATE MANUAL-OVERR '||SQL%ROWCOUNT);
       END IF;

-- bug 3359924 - AFTER APPLYING MANUAL PBH ENGINE RETURNS DUPLICATE RELATIONSHIP RECORDS
         UPDATE qp_npreq_rltd_lines_tmp rltd
            set rltd.pricing_status_code = QP_PREQ_PUB.G_STATUS_DELETED,
                rltd.pricing_status_text = 'DUPLICATE MANUAL-OVERRIDEABLE'
          where rltd.pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
            and rltd.line_detail_index in (select ldet.line_detail_index
                                            from qp_npreq_ldets_tmp ldet
                                           where ldet.pricing_status_code = QP_PREQ_PUB.G_STATUS_DELETED
                                             and ldet.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_PUB.G_BY_PBH);

       IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('DUPLICATE MANUAL-OVERR '||SQL%ROWCOUNT);
       END IF;

--      IF p_event_code IS NULL
--      and p_calculate_flag = QP_PREQ_GRP.G_CALCULATE_ONLY
--      THEN

--   IF p_request_type_code = 'ONT'
--   and p_view_code = 'ONTVIEW'
 --  THEN
 IF l_debug = FND_API.G_TRUE THEN
--      QP_PREQ_GRP.engine_debug('open ONT cur'||p_request_type_code);
        QP_PREQ_GRP.engine_debug('open ONT cur'||QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG);
 END IF;

--bug 4900095 get service qty for lumpsum
 IF QP_PREQ_GRP.G_Service_line_qty_tbl.COUNT = 0 THEN
   QP_PREQ_PUB.Determine_svc_item_quantity;
 END IF;

        OPEN l_calculate_cur;
--   END IF;


        LOOP

l_dup_updated_flag.delete;
l_dup_is_ldet_rec.delete;
l_dup_plsql_ind.delete;
l_dup_uniq_ind.delete;

l_list_line_id_tbl.delete;
l_line_index_tbl.delete;
l_curr_line_index_tbl.delete;
l_line_id_tbl.delete;
l_line_dtl_index_tbl.delete;
l_list_line_type_code_tbl.delete;
l_list_header_id_tbl.delete;
l_applied_flag_tbl.delete;
l_amount_changed_tbl.delete;
l_adjusted_unit_price_tbl.delete;
l_priced_quantity_tbl.delete;
l_line_priced_qty_tbl.delete;
l_upd_adj_unit_price_tbl.delete;
l_automatic_flag_tbl.delete;
l_override_flag_tbl.delete;
l_pricing_group_sequence_tbl.delete;
l_operand_calc_code_tbl.delete;
l_operand_value_tbl.delete;
l_adjustment_amount_tbl.delete;
l_unit_price_tbl.delete;
l_accrual_flag_tbl.delete;
l_updated_flag_tbl.delete;
l_process_code_tbl.delete;
l_status_code_tbl.delete;
l_status_text_tbl.delete;
l_price_break_type_code_tbl.delete;
l_charge_type_code_tbl.delete;
l_charge_subtype_code_tbl.delete;
l_rounding_factor_tbl.delete;
l_pricing_phase_id_tbl.delete;
l_list_line_no_tbl.delete;
l_limit_text_tbl.delete;
l_limit_code_tbl.delete;
l_list_type_code_tbl.delete;
l_modifier_level_tbl.delete;
l_group_qty_tbl.delete;
l_group_amt_tbl.delete;
l_line_sts_code_tbl.delete;
l_is_ldet_rec_tbl.delete;
l_line_type_code_tbl.delete;
--2388011
l_net_amount_flag_tbl.delete;
--2388011
l_calculation_code_tbl.delete;
l_catchweight_qty_tbl.delete;
l_actual_order_qty_tbl.delete;
l_line_unit_price_tbl.delete;
l_ord_qty_tbl.delete;
l_line_detail_type_code_tbl.delete;
l_line_category_tbl.delete;
l_price_flag_tbl.delete;

d := l_adj_overflow_tbl.COUNT;
--l_adj_tbl := l_adj_overflow_tbl;
l_adj_overflow_tbl.delete;
g := 0;
l_prev_line_start_index := 0;


 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('fetch cur');
 END IF;


        FETCH l_calculate_cur
        BULK COLLECT INTO
                l_list_line_id_tbl
                ,l_line_index_tbl
                ,l_curr_line_index_tbl
                ,l_line_id_tbl
                ,l_line_dtl_index_tbl
                ,l_list_line_type_code_tbl
                ,l_list_header_id_tbl
                ,l_applied_flag_tbl
                ,l_amount_changed_tbl
                ,l_adjusted_unit_price_tbl
                ,l_priced_quantity_tbl
                ,l_line_priced_qty_tbl
                ,l_upd_adj_unit_price_tbl
                ,l_automatic_flag_tbl
                ,l_override_flag_tbl
                ,l_pricing_group_sequence_tbl
                ,l_operand_calc_code_tbl
                ,l_operand_value_tbl
                ,l_adjustment_amount_tbl
                ,l_unit_price_tbl
                ,l_accrual_flag_tbl
                ,l_updated_flag_tbl
                ,l_process_code_tbl
                ,l_status_code_tbl
                ,l_status_text_tbl
                ,l_price_break_type_code_tbl
                ,l_charge_type_code_tbl
                ,l_charge_subtype_code_tbl
                ,l_rounding_factor_tbl
                ,l_pricing_phase_id_tbl
                ,l_list_type_code_tbl
                ,l_limit_code_tbl
                ,l_limit_text_tbl
                ,l_list_line_no_tbl
                ,l_modifier_level_tbl
                ,l_group_qty_tbl
                ,l_group_amt_tbl
                ,l_line_sts_code_tbl
                ,l_is_ldet_rec_tbl
                ,l_line_type_code_tbl
                --2388011
                ,l_net_amount_flag_tbl
                --2388011
                ,l_calculation_code_tbl
                ,l_catchweight_qty_tbl
                ,l_actual_order_qty_tbl
                ,l_line_unit_price_tbl
                ,l_ord_qty_tbl
                ,l_line_detail_type_code_tbl
                ,l_line_category_tbl
                ,l_price_flag_tbl;
--      LIMIT nrows;
        EXIT WHEN l_list_line_id_tbl.COUNT = 0;

        IF l_list_line_id_tbl.COUNT > 0
        and QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        and l_debug = FND_API.G_TRUE
        THEN
        for i in l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
        LOOP
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('list_line_id '||l_list_line_id_tbl(i)||
                'line index '||l_line_index_tbl(i)||' is ldet '||
                l_is_ldet_rec_tbl(i)||' linetype '||l_line_type_code_tbl(i) ||
                'line detail type code ' || l_line_detail_type_code_tbl(i)||
                ' line_category '||l_line_category_tbl(i)||' priceflag '||
                l_price_flag_tbl(i));
 END IF;
        END LOOP;
        END IF;--l_list_line_id_tbl.COUNT


        IF l_list_line_id_tbl.COUNT > 0
        THEN
        FOR i IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
        LOOP
                d := d + 1;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('adj_tbl count '||d);
        QP_PREQ_GRP.engine_debug('loop cur '||i);

 END IF;
                IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
                qp_preq_grp.engine_debug('display details '
                ||l_list_line_id_tbl(i)||' line index '||l_line_index_tbl(i)
                ||' line detail index '||l_line_dtl_index_tbl(i)
                ||' auto '||l_automatic_flag_tbl(i)
                ||' overr '||l_override_flag_tbl(i)
                ||' updated '||l_updated_flag_tbl(i)
                ||' applied '||l_applied_flag_tbl(i)
                ||' hdr id '||l_list_header_id_tbl(i)||' is ldet '
                ||l_is_ldet_rec_tbl(i)||' linetype '||l_line_type_code_tbl(i));

                qp_preq_grp.engine_debug('list_line_type ' || l_list_line_type_code_tbl(i)
                                       || 'modifier_level ' || l_modifier_level_tbl(i)
                                       || 'net_amount_flag ' || l_net_amount_flag_tbl(i)
                                       || 'is_ldet_rec ' || l_is_ldet_rec_tbl(i));
                END IF;

          -- bug 3618464 - PBH, GROUP OF LINES, OVERRIDE, NET AMOUNT modifier calculation fix
          if l_list_line_type_code_tbl(i) = QP_PREQ_PUB.G_PRICE_BREAK_TYPE and
             l_modifier_level_tbl(i) = QP_PREQ_PUB.G_LINE_GROUP and
             l_is_ldet_rec_tbl(i) in (QP_PREQ_PUB.G_ADJ_ORDER_TYPE, QP_PREQ_PUB.G_ADJ_LINE_TYPE)
            then

              if l_net_amount_flag_tbl(i) is null then
                select net_amount_flag
                  into l_net_amount_flag_tbl(i)
                  from qp_list_lines
                 where list_line_id = l_list_line_id_tbl(i);
              end if;

              if l_net_amount_flag_tbl(i) = 'Y' then
                if QP_PREQ_PUB.G_LINE_INDEXES_FOR_LINE_ID.exists(l_list_line_id_tbl(i)) then
                   QP_PREQ_PUB.G_LINE_INDEXES_FOR_LINE_ID(l_list_line_id_tbl(i)) := QP_PREQ_PUB.G_LINE_INDEXES_FOR_LINE_ID(l_list_line_id_tbl(i)) || l_line_index_tbl(i) || ',';
                else
                   QP_PREQ_PUB.G_LINE_INDEXES_FOR_LINE_ID(l_list_line_id_tbl(i)) := l_line_index_tbl(i) || ',';
                end if;
              end if;
          end if;

--added to check for duplicate list_line_ids
/*
                l_dup_ind := l_line_index_tbl(i) + l_list_line_id_tbl(i);

                IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Duplicate list line check '
                ||' line_index+list_line_id val: '||l_dup_ind);
                END IF;--l_debug

                IF l_dup_updated_flag.exists(l_dup_ind) THEN
                  IF l_debug = FND_API.G_TRUE THEN
                    QP_PREQ_GRP.engine_debug('Duplicate list line exists ');
                  END IF;--l_debug

                  IF l_dup_updated_flag(l_dup_ind) = QP_PREQ_PUB.G_YES
                  and l_updated_flag_tbl(i) = QP_PREQ_PUB.G_NO THEN
                  --in this case the oe_price_adj record must be applied
                  --so engine selected needs to be marked as deleted
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('Duplicate adj overridden ');
                    END IF;--l_debug
                    IF l_is_ldet_rec_tbl(i) in (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                      QP_PREQ_PUB.G_LDET_LINE_TYPE) THEN
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Marking non-overrdn adj '
                        ||'as deleted ');
                      END IF;--l_debug
                      l_status_code_tbl(i) := QP_PREQ_PUB.G_STATUS_DELETED;
                      l_status_text_tbl(i) := 'DUPLICATE MODIFIER PICKED UP';
                    END IF;--l_is_ldet_rec_tbl
                  ELSIF l_updated_flag_tbl(i) = QP_PREQ_PUB.G_YES
                  and l_dup_updated_flag(l_dup_ind) = QP_PREQ_PUB.G_YES THEN
                  --current adj is overridden
                      l_adj_tbl(l_dup_plsql_ind(l_dup_ind)).pricing_status_code
                      := QP_PREQ_PUB.G_STATUS_DELETED;
                      l_adj_tbl(l_dup_plsql_ind(l_dup_ind)).pricing_status_text
                      := 'DUPLICATE MODIFIER PICKED UP';
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Marking prev overdn deltd ');
                      END IF;--l_debug
                      --replace l_dup values w/current values
                      l_dup_updated_flag(l_dup_ind) := l_updated_flag_tbl(i);
                      l_dup_is_ldet_rec(l_dup_ind) := l_is_ldet_rec_tbl(i);
                      l_dup_plsql_ind(l_dup_ind) := d;
                  ELSE --updated_flag is 'N'
                  --in this case the engine selected record must be applied
                  --so adj from oe_price_adj needs to be marked as deleted
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug('Duplicate adj not overridden ');
                      QP_PREQ_GRP.engine_debug('Prev adj is_ldet: '
                      ||l_dup_is_ldet_rec(l_dup_ind));
                      QP_PREQ_GRP.engine_debug('Current adj is_ldet: '
                      ||l_is_ldet_rec_tbl(i));
                    END IF;--l_debug
                    IF l_dup_is_ldet_rec(l_dup_ind) in
                    (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                      QP_PREQ_PUB.G_LDET_LINE_TYPE)
                    and l_is_ldet_rec_tbl(i) not in
                    (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                      QP_PREQ_PUB.G_LDET_LINE_TYPE) THEN
                      --mark the current record as deleted as
                      --it is from oe_price_adj
                      l_status_code_tbl(i) := QP_PREQ_PUB.G_STATUS_DELETED;
                      l_status_text_tbl(i) := 'DUPLICATE MODIFIER PICKED UP';
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Marking curr adj deleted ');
                      END IF;--l_debug
                    ELSIF l_is_ldet_rec_tbl(i) in
                    (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                      QP_PREQ_PUB.G_LDET_LINE_TYPE)
                    and l_dup_is_ldet_rec(l_dup_ind) not in
                    (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                      QP_PREQ_PUB.G_LDET_LINE_TYPE) THEN
                      l_adj_tbl(l_dup_plsql_ind(l_dup_ind)).pricing_status_code
                      := QP_PREQ_PUB.G_STATUS_DELETED;
                      l_adj_tbl(l_dup_plsql_ind(l_dup_ind)).pricing_status_text
                      := 'DUPLICATE MODIFIER PICKED UP';
                      --replace l_dup values w/current values
                      l_dup_updated_flag(l_dup_ind) := l_updated_flag_tbl(i);
                      l_dup_is_ldet_rec(l_dup_ind) := l_is_ldet_rec_tbl(i);
                      l_dup_plsql_ind(l_dup_ind) := d;
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Marking prev adj deleted ');
                      END IF;--l_debug
                    ELSE--both the records have same is_ldet so delete one
                      l_status_code_tbl(i) := QP_PREQ_PUB.G_STATUS_DELETED;
                      l_status_text_tbl(i) := 'DUPLICATE MODIFIER PICKED UP';
                      IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('Marking else curr adj deltd');
                      END IF;--l_debug
                    END IF;--l_is_ldet_rec_tbl(i)
                  END IF;--l_dup_updated_flag
                ELSE
                  l_dup_updated_flag(l_dup_ind) := l_updated_flag_tbl(i);
                  l_dup_is_ldet_rec(l_dup_ind) := l_is_ldet_rec_tbl(i);
                  l_dup_plsql_ind(l_dup_ind) := d;
                END IF;--l_dup_updated_flag.exists

*/
--added to check for duplicate list_line_ids

                l_adj_tbl(d).created_from_list_line_id := l_list_line_id_tbl(i);
                l_adj_tbl(d).line_ind := l_line_index_tbl(i);
                l_adj_tbl(d).curr_line_index := l_curr_line_index_tbl(i);
                l_adj_tbl(d).line_id := l_line_id_tbl(i);
                l_adj_tbl(d).created_from_list_header_id :=
                                        l_list_header_id_tbl(i);
                l_adj_tbl(d).created_from_list_line_type :=
                                        l_list_line_type_code_tbl(i);
                l_adj_tbl(d).applied_flag := l_applied_flag_tbl(i);
                l_adj_tbl(d).amount_changed := l_amount_changed_tbl(i);
                l_adj_tbl(d).adjusted_unit_price :=
                                        l_adjusted_unit_price_tbl(i);
                l_adj_tbl(d).priced_quantity := l_priced_quantity_tbl(i);
                --if limits is installed GRP makes line_quantity on ldets 0
                --for bug2897524 retain line_quantity for zerounitprice
                IF (l_adj_tbl(d).priced_quantity = 0
                and l_adj_tbl(d).unit_price <> 0)
                THEN
   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('ldet.line_qty is zero');
   END IF;
                        l_adj_tbl(d).priced_quantity := null;
                ELSE
   IF l_debug = FND_API.G_TRUE THEN
                        QP_PREQ_GRP.engine_debug('ldet.line_qty not zero');
   END IF;
                END IF;
                l_adj_tbl(d).line_priced_quantity := l_line_priced_qty_tbl(i);
                l_adj_tbl(d).updated_adjusted_unit_price :=
                                        l_upd_adj_unit_price_tbl(i);
                l_adj_tbl(d).automatic_flag := l_automatic_flag_tbl(i);
                l_adj_tbl(d).override_flag := l_override_flag_tbl(i);
                l_adj_tbl(d).pricing_group_sequence :=
                                        l_pricing_group_sequence_tbl(i);
                l_adj_tbl(d).operand_calculation_code :=
                                        l_operand_calc_code_tbl(i);
                l_adj_tbl(d).operand_value := l_operand_value_tbl(i);
                l_adj_tbl(d).adjustment_amount := l_adjustment_amount_tbl(i);
                l_adj_tbl(d).unit_price := l_unit_price_tbl(i);
                l_adj_tbl(d).accrual_flag := l_accrual_flag_tbl(i);
                l_adj_tbl(d).updated_flag := l_updated_flag_tbl(i);
                l_adj_tbl(d).pricing_status_code := l_status_code_tbl(i);
                l_adj_tbl(d).pricing_status_text := l_status_text_tbl(i);
                l_adj_tbl(d).price_break_type_code :=
                                        l_price_break_type_code_tbl(i);
                l_adj_tbl(d).charge_type_code := l_charge_type_code_tbl(i);
                l_adj_tbl(d).charge_subtype_code :=
                                        l_charge_subtype_code_tbl(i);
                l_adj_tbl(d).rounding_factor :=
                                        l_rounding_factor_tbl(i);
                l_adj_tbl(d).pricing_phase_id := l_pricing_phase_id_tbl(i);
                l_adj_tbl(d).created_from_list_type_code :=
                                                l_list_type_code_tbl(i);
                l_adj_tbl(d).limit_code := l_limit_code_tbl(i);
                l_adj_tbl(d).limit_text := l_limit_text_tbl(i);
                l_adj_tbl(d).list_line_no := l_list_line_no_tbl(i);
                l_adj_tbl(d).modifier_level_code := l_modifier_level_tbl(i);
                l_adj_tbl(d).group_quantity := l_group_qty_tbl(i);
                l_adj_tbl(d).group_amount := l_group_amt_tbl(i);
                l_adj_tbl(d).line_pricing_status_code := l_line_sts_code_tbl(i);
                l_adj_tbl(d).is_ldet_rec := l_is_ldet_rec_tbl(i);
                l_adj_tbl(d).line_type_code := l_line_type_code_tbl(i);

                --2388011
                l_adj_tbl(d).net_amount_flag := l_net_amount_flag_tbl(i);
                --2388011
                l_adj_tbl(d).calculation_code := l_calculation_code_tbl(i);
                l_adj_tbl(d).catchweight_qty := l_catchweight_qty_tbl(i);
                l_adj_tbl(d).actual_order_qty := l_actual_order_qty_tbl(i);
                l_adj_tbl(d).line_unit_price := l_line_unit_price_tbl(i);
                l_adj_tbl(d).ordered_qty := l_ord_qty_tbl(i);
                l_adj_tbl(d).line_category := l_line_category_tbl(i);
                l_adj_tbl(d).price_flag := l_price_flag_tbl(i);

                IF l_curr_line_index <> l_line_index_tbl(i)
                THEN
                        l_prev_line_start_index := i;
                IF l_debug = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('auto_overr: new line');
                END IF; --Bug No 4033618
                        l_curr_line_index := l_line_index_tbl(i);
                        x := 0;
                        l_auto_line_dtl_index_tbl.delete;
                        l_auto_override_dtl_id_tbl.delete;
                END IF;

                IF l_curr_line_index = l_line_index_tbl(i)
                and l_is_ldet_rec_tbl(i) IN (QP_PREQ_PUB.G_ADJ_ORDER_TYPE,
                                                QP_PREQ_PUB.G_ADJ_LINE_TYPE,
                                                QP_PREQ_PUB.G_ASO_LINE_TYPE,
                                                QP_PREQ_PUB.G_ASO_ORDER_TYPE)
                --there w/b duplicate applied adj in the cursor
                --l_calculate_cur only in case of automatic overrideable
                --adj and manual unapplied adj to filter those
                /*
                and ((nvl(l_automatic_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                        QP_PREQ_PUB.G_YES
                and nvl(l_updated_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_YES
                and nvl(l_applied_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_YES)
                or
                (nvl(l_automatic_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                        QP_PREQ_PUB.G_YES
                and nvl(l_applied_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_NO))
                */
                --commented out because we need to look at all updated adj
                --and retain the updated(overridden) adj ,delete engine picked
                and nvl(l_updated_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_YES
                THEN
                        x := x+1;
                        l_auto_line_dtl_index_tbl(x) := l_line_dtl_index_tbl(i);
                        l_auto_override_dtl_id_tbl(x) := l_list_line_id_tbl(i);
--                      l_adj_tbl(d).pricing_status_code :=
--                                      QP_PREQ_PUB.G_STATUS_UPDATED;
                        IF l_debug = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('auto_overr: from adj tbl '
                                ||l_line_dtl_index_tbl(i)||' adj id '
                                ||l_list_line_id_tbl(i));
                         END IF; --Bug No 4033618
                ELSIF l_curr_line_index = l_line_index_tbl(i)
                and l_is_ldet_rec_tbl(i) in (QP_PREQ_PUB.G_LDET_ORDER_TYPE,
                                                QP_PREQ_PUB.G_LDET_LINE_TYPE)
                --commented out because we need to look at all updated adj
                --and retain the updated(overridden) adj ,delete engine picked
                /*
                and ((nvl(l_automatic_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_YES
                and nvl(l_override_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_YES
                and nvl(l_updated_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_NO)
                or (nvl(l_automatic_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_NO
                and nvl(l_applied_flag_tbl(i),QP_PREQ_PUB.G_NO) =
                                                QP_PREQ_PUB.G_NO))
                */
                THEN
                        IF l_debug = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('auto_overr: from ldet tbl '
                                ||l_adj_tbl(d).created_from_list_line_id
                                ||' adj index '||l_adj_tbl(d).line_detail_index);
                         END IF; --Bug No 4033618
                        m := l_auto_line_dtl_index_tbl.FIRST;
                        WHILE (m IS NOT NULL
                        and l_auto_line_dtl_index_tbl.COUNT > 0)
                        LOOP
                        IF l_debug = FND_API.G_TRUE THEN
                        qp_preq_grp.engine_debug('auto_overr: from auto_ov tbl '
                                ||m||' adj id '||l_auto_override_dtl_id_tbl(m)
                                ||' dtl index '||l_auto_line_dtl_index_tbl(m));
                         END IF; --Bug No 4033618
                                IF l_list_line_id_tbl(i) =
                                        l_auto_override_dtl_id_tbl(m)
                                THEN
     IF l_debug = FND_API.G_TRUE THEN
                                        QP_PREQ_GRP.engine_debug('duplicate hit'
                                        ||' '||l_list_line_id_tbl(i));
     END IF;
                                        l_adj_tbl(d).pricing_status_code :=
                                                QP_PREQ_GRP.G_STATUS_DELETED;
                                        l_adj_tbl(d).pricing_status_text :=
                                                'DUPLICATE AUTO-OVERRIDEABLE';
                                        l_auto_override_dtl_id_tbl.delete(m);
                                        l_auto_line_dtl_index_tbl.delete(m);
                                END IF;
                                m := l_auto_line_dtl_index_tbl.NEXT(m);
                        END LOOP;
                END IF;

           --need to populate pricing_attribute for pbh calculation
           --for bug 2388011
           IF l_adj_tbl(d).created_from_list_line_type = QP_PREQ_PUB.G_PRICE_BREAK_TYPE
           THEN
                BEGIN
                        select pricing_attribute
                        into QP_PREQ_PUB.G_pbhvolattr_attribute(l_adj_tbl(d).created_from_list_line_id)
                        from qp_pricing_attributes
                        where list_line_id =
                                l_adj_tbl(d).created_from_list_line_id
                                and excluder_flag='N'; --3607956
                EXCEPTION
                When OTHERS Then
                        QP_PREQ_PUB.G_pbhvolattr_attribute(l_adj_tbl(d).created_from_list_line_id) := null;
                END;

                IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug(' PBH vol attr for list_line_id '
                ||l_adj_tbl(d).created_from_list_line_id||' attr '
                ||QP_PREQ_PUB.G_pbhvolattr_attribute(l_adj_tbl(d).created_from_list_line_id));
                END IF;--l_debug
            END IF;--l_adj_tbl(d).created_from_list_line_type

           IF nvl(l_adj_tbl(d).is_ldet_rec,QP_PREQ_PUB.G_YES) IN
                (QP_PREQ_PUB.G_LDET_LINE_TYPE,QP_PREQ_PUB.G_LDET_ORDER_TYPE
                ,QP_PREQ_PUB.G_ASO_LINE_TYPE, QP_PREQ_PUB.G_ASO_ORDER_TYPE)
           THEN
                l_adj_tbl(d).process_code := QP_PREQ_PUB.G_STATUS_NEW;
                l_adj_tbl(d).line_detail_index := l_line_dtl_index_tbl(i);
           ELSE
                l_adj_tbl(d).process_code := QP_PREQ_PUB.G_STATUS_UPDATED;
--per bug 2846527, when freegood gets repriced, same outofphase adj
--may get selected on old and newfg with line w/same priceadjid
--adding line_index to resolve this

                -- Bug 3031108, OM only
                -- For order level adj, we apply them on each line, but for purpose
                -- of calculating total adj amt, each adj ldet should be inserted with
                -- same ldet index.  So for each list line ID, we cache the ldet index
                -- and reuse when necessary.  Only for order-level adjs.
                IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = 'Y'
                   and nvl(l_adj_tbl(d).is_ldet_rec,QP_PREQ_PUB.G_YES) = QP_PREQ_PUB.G_ADJ_ORDER_TYPE
                THEN
                  IF G_ORD_LVL_LDET_INDEX.EXISTS(l_adj_tbl(d).created_from_list_line_id) THEN
                    l_adj_tbl(d).line_detail_index := G_ORD_LVL_LDET_INDEX(l_adj_tbl(d).created_from_list_line_id);
                  ELSE
                    G_MAX_DTL_INDEX := G_MAX_DTL_INDEX + 1;
                    l_adj_tbl(d).line_detail_index := G_MAX_DTL_INDEX;
                    G_ORD_LVL_LDET_INDEX(l_adj_tbl(d).created_from_list_line_id) := G_MAX_DTL_INDEX;
                  END IF;
                ELSE
                  -- this is the standard funcionality
                  G_MAX_DTL_INDEX := G_MAX_DTL_INDEX + 1;
                  l_adj_tbl(d).line_detail_index := G_MAX_DTL_INDEX;
                END IF; -- g_check_cust_view_flag

                IF l_adj_tbl(d).created_from_list_line_type =
                        QP_PREQ_PUB.G_PRICE_BREAK_TYPE THEN
                G_PBH_LINE_INDEX(G_PBH_LINE_INDEX.COUNT+1) :=
                                        l_adj_tbl(d).line_ind;
                G_PBH_LINE_DTL_INDEX(G_PBH_LINE_INDEX.COUNT) :=
                                        l_adj_tbl(d).line_detail_index;
                G_PBH_PRICE_ADJ_ID(G_PBH_LINE_INDEX.COUNT) :=
                                        l_line_dtl_index_tbl(i);
                G_PBH_PLSQL_IND(mod(l_line_dtl_index_tbl(i),G_BINARY_LIMIT)) :=  --8744755
                        G_PBH_LINE_INDEX.COUNT;
                END IF;--l_adj_tbl(d).created_from_list_line_type
                IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('figuring out line_dtl_index '
                ||l_adj_tbl(d).line_detail_index);
                END IF;--l_debug
            END IF;--nvl(l_adj_tbl(d).is_ldet_rec



 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('load tbl'||l_adj_tbl(d).line_detail_index
                ||' list_line_id '||l_adj_tbl(d).created_from_list_line_id
                ||' list_hdr_id '||l_adj_tbl(d).created_from_list_header_id
                ||' line dtl index '||l_adj_tbl(d).line_detail_index
                ||' operand '||l_adj_tbl(d).operand_value
                ||' pricing sts code '||l_adj_tbl(d).pricing_status_code
                ||' is ldet rec '||l_adj_tbl(d).is_ldet_rec);
 END IF;
--      i:=l_list_line_id_tbl.NEXT(i);
        END LOOP;
        END IF;

/*
        i := l_adj_tbl.NEXT(l_prev_line_start_index-1);
        g := 0;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('last line starts at '||l_prev_line_start_index);
 END IF;
        WHILE i IS NOT NULL
        LOOP
                g := g + 1;
                l_adj_overflow_tbl(g) := l_adj_tbl(i);
        i := l_adj_tbl.NEXT(i);
        END LOOP;--l_adj_tbl

        l_adj_tbl.delete(l_prev_line_start_index,l_adj_tbl.COUNT);

        IF l_adj_tbl.COUNT > 0
        and QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE
        THEN
        i := l_adj_tbl.first;
        WHILE i IS NOT NULL
        LOOP
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('list_line_id '||l_adj_tbl(i).line_detail_index);--||
        END IF;
        i := l_adj_tbl.next(i);
        END LOOP;
        END IF;
*/
        n:=G_PBH_LINE_DTL_INDEX.FIRST;
        WHILE n IS NOT NULL
        LOOP
          IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('G_PBH_LINE_DTL_INDEX loop '
                ||' lineindex '||G_PBH_LINE_INDEX(n)
                ||' price_adj_id '||G_PBH_PRICE_ADJ_ID(n)
                ||' linedtlind '||G_PBH_LINE_DTL_INDEX(n));
          END IF;
          n:=G_PBH_LINE_DTL_INDEX.NEXT(n);
        END LOOP;

--this needs to be done only for OM, OC and others will pass PBH relationship
--  IF p_request_type_code = 'ONT' THEN
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
  IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES THEN
                Insert_rltd_lines(p_request_type_code,
                                p_calculate_flag, p_event_code,
                                x_return_status, x_return_status_text);
--      END IF;
/*
  ELSE
  --This will be called for OC and others who will pass the PBH
  --and the relationship in which case the relationship needs to be updated
    QP_PREQ_PUB.Update_passed_in_pbh(x_return_status, x_return_status_text);
*/
  END IF;--p_request_type_code

  IF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
    Raise Pricing_Exception;
  END IF;

        IF l_adj_tbl.COUNT > 0
        THEN

                QP_PREQ_PUB.calculate_price(p_request_type_code => 'ONT'
                                ,p_rounding_flag => p_rounding_flag
                                ,p_view_name => 'ONTVIEW'
                                ,p_event_code => p_event_code
                                ,p_adj_tbl => l_adj_tbl
                                ,x_return_status => x_return_status
                                ,x_return_status_text => x_return_status_text);
                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;
        END IF;


        END LOOP;

--   IF p_request_type_code = 'ONT'
 --  and p_view_name = 'ONTVIEW'
 --  THEN
        CLOSE l_calculate_cur;
 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('close cur');
 END IF;
  -- END IF;

--commenting to do the delete at all times
--      IF p_event_code = ','
--      and p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
--      THEN
  IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('deleting related lines');
  END IF;
                delete from qp_npreq_rltd_lines_tmp
                        where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                        and relationship_type_code = QP_PREQ_PUB.G_PBH_LINE
                        and pricing_status_text = G_CALC_INSERT;
  IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('deleted related lines '||SQL%ROWCOUNT);
  END IF;
--      END IF;

--This is to update the status code on the child lines on PBH for
--pricing integ to insert/update the child line info as the parent changes
              QP_PREQ_PUB.Update_Child_Break_Lines(x_return_status,
                                       x_return_status_text);

--to eliminate the duplicate manual adjustments in the temp table to prevent cleanup for them bug 2191169
--fix for bug 2515297 not to check applied_flag in this update
         UPDATE qp_npreq_ldets_tmp ldet2
                set ldet2.pricing_status_code = QP_PREQ_PUB.G_STATUS_DELETED,
                        pricing_status_text = 'DUPLICATE MANUAL-OVERRIDEABLE'
                where pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
                and nvl(ldet2.updated_flag,QP_PREQ_PUB.G_NO) = QP_PREQ_PUB.G_NO
                and exists ( select 'X'
                from qp_npreq_ldets_tmp ldet
                where nvl(ldet.updated_flag,QP_PREQ_PUB.G_NO) =QP_PREQ_PUB.G_YES
                and ldet.line_index = ldet2.line_index
                and ldet.created_from_list_line_id =
                                ldet2.created_from_list_line_id);

       IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('DUPLICATE MANUAL-OVERR '||SQL%ROWCOUNT);
       END IF;

       -- 4528043, mark any newly picked-up manual modifiers as 'deleted'
       -- to prevent OM from incorrectly displaying them in View Adjs
       -- 5413797, but don't delete any manual modifiers that appear new
       -- because they were repriced with a different quantity
       IF (QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES and
           QP_PREQ_GRP.G_MANUAL_ADJUSTMENTS_CALL_FLAG = QP_PREQ_PUB.G_NO)
       THEN
         UPDATE qp_npreq_ldets_tmp
         SET    pricing_status_code = QP_PREQ_PUB.G_STATUS_DELETED
         WHERE  pricing_status_code = QP_PREQ_PUB.G_STATUS_NEW
         AND    automatic_flag = QP_PREQ_PUB.G_NO
         AND    applied_flag = QP_PREQ_PUB.G_NO
         and    updated_flag = QP_PREQ_PUB.G_NO; -- 5413797

         IF (l_debug = FND_API.G_TRUE) THEN
           QP_PREQ_GRP.engine_debug(SQL%ROWCOUNT||' new manual modifier(s) marked as DELETED');
         END IF;
       END IF;

        --Fix for bug 2247167 Status on lines is unchanged although
        --the adjustments have changed
        QP_PREQ_PUB.Update_Line_Status(x_return_status,x_return_status_text);


                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;

        --fix for bug 2242736 where the selling price is not unit_price
        --when engine is called with calculate_only and there are no applied
        --adjustments to affect the selling price
        --removed the calculate_flag if condition due to bug 2567288
        --if the line does not qualify for the only discount anymore, this
        --update needs to be done
--      IF p_calculate_flag = QP_PREQ_PUB.G_CALCULATE_ONLY
--      THEN
  IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('calculate_only call check to see'
                        ||' if there are adjustments');
  END IF;
                QP_PREQ_PUB.update_unit_price(x_return_status,
                                        x_return_status_text);

                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;
--      END IF;--p_calculate_flag


  IF l_cleanup_flag = QP_PREQ_PUB.G_YES THEN
  --call cleanup of adj only for OM
        cleanup_adjustments('ONTVIEW',
                                p_request_type_code,
                                l_cleanup_flag,
                                x_return_status,
                                x_return_status_text);
                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;
  END IF;--l_cleanup_flag

--populate the price adjustment id from sequence for rec with process_code = N
--      IF p_request_type_code = 'ONT' THEN
--bug 3085453 handle pricing availability UI
-- they pass reqtype ONT and insert adj into ldets
      IF QP_PREQ_PUB.G_CHECK_CUST_VIEW_FLAG = QP_PREQ_PUB.G_YES THEN
        Populate_Price_Adj_ID(x_return_status,x_return_status_text);

                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;
        END IF;--QP_PREQ_PUB.G_REQUEST_TYPE_CODE

--gsa violation check
        IF QP_PREQ_PUB.G_GSA_INDICATOR = QP_PREQ_PUB.G_NO
        THEN
                QP_PREQ_PUB.check_gsa_violation(
                                x_return_status => x_return_status,
                                x_return_status_text => x_return_status_text);
                IF x_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        Raise Pricing_Exception;
                END IF;
        END IF;--GSA_INDICATOR



 IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('end fetch adjustments');


 END IF;
EXCEPTION
When PRICING_EXCEPTION Then
x_return_status := FND_API.G_RET_STS_ERROR;
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('error in fetch_adjustments: '||SQLERRM);
QP_PREQ_GRP.engine_debug('error in fetch_adjustments: '||x_return_status_text);
END IF;
When OTHERS Then
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_status_text := 'Error in fetch_adjustments: '||SQLERRM;
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('error in fetch_adjustments: '||SQLERRM);
END IF;
END fetch_adjustments;




END QP_CLEANUP_ADJUSTMENTS_PVT;

/
