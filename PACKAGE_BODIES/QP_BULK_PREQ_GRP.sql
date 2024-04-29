--------------------------------------------------------
--  DDL for Package Body QP_BULK_PREQ_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_PREQ_GRP" AS
/* $Header: QPBGPREB.pls 120.1 2005/08/19 18:12:35 spgopal noship $ */

--API to indicate calling applications whether pricing
--is happening through HVOP or NOT
--This check needs to be done in QP_SOURCING_API_PUB
--and other custom APIs which may have references to
--OE_ORDER_PUB.G_LINE/G_HDR to source any attributes
--so that those APIs look at the bulk memory structures
--to srouce values appropriately when pricing happens
--through HVOP

Procedure Bulk_insert_lines(p_header_rec IN OE_BULK_ORDER_PVT.HEADER_REC_TYPE,
			    p_line_rec IN OE_WSH_BULK_GRP.Line_Rec_Type,
                            p_org_id IN NUMBER DEFAULT NULL, --added for moac
			    x_return_status OUT NOCOPY VARCHAR2,

			    x_return_status_text OUT NOCOPY VARCHAR2) IS

l_qual_ctxts_result_tbl QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE;
l_price_ctxts_result_tbl QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE;

l_line_line_index QP_PREQ_GRP.number_type;
l_hdr_line_index QP_PREQ_GRP.number_type;
l_line_count NUMBER;
l_preq_count NUMBER;
my_usage_type VARCHAR2(30);
PRAGMA AUTONOMOUS_TRANSACTION;
i pls_integer;
type cur_code_type is table of varchar2(30) index by BINARY_INTEGER;
type date_type is table of date index by BINARY_INTEGER;
l_currency_code_tbl cur_code_type;
l_active_date_first_tbl  date_type;
--added for moac
l_org_id NUMBER;

BEGIN

--added for moac
--because this is a group API we expect calling app to have set the org context
--but we need to populate QP_ATTR_MAPPING_PUB.G_ORG_ID for sourcing rules
l_org_id := nvl(p_org_id, QP_UTIL.get_org_id);
QP_ATTR_MAPPING_PUB.G_ORG_ID := l_org_id;

l_line_count := p_line_rec.line_id.count;
G_header_rec := p_header_rec;
G_line_rec := p_line_rec;
l_line_count := p_line_rec.line_id.count;
QP_PREQ_GRP.Set_QP_Debug;
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
If l_debug = 'T' Then
  i := p_line_rec.line_id.first;
--changes for bug 3395657
--changed for to while loop and to loop based on line_index
--instead of line_id as line_id may be null
  while i is not null
  loop
  --for i in 1..p_line_rec.line_id.count loop
		oe_debug_pub.add ('in bulk_preq, line_index : '|| p_line_rec.line_index(i));
  i := p_line_rec.line_id.next(i);
  end loop;
End If;--debug
G_HVOP_pricing_ON := 'Y';


--OM will give a different structure to populate
--the new control rec columns introduced on lines_tmp for java engine

IF p_header_rec.header_id.COUNT > 0 THEN
forall i in p_header_rec.header_id.FIRST..p_header_rec.header_id.LAST
    insert into qp_int_lines
    (
    LINE_INDEX,
    LINE_TYPE_CODE,
    PRICING_EFFECTIVE_DATE,
    START_DATE_ACTIVE_FIRST,
    ACTIVE_DATE_FIRST_TYPE,
    START_DATE_ACTIVE_SECOND,
    ACTIVE_DATE_SECOND_TYPE,
    LINE_QUANTITY,
    LINE_UOM_CODE,
    REQUEST_TYPE_CODE,
    PRICED_QUANTITY,
    PRICED_UOM_CODE,
    CURRENCY_CODE,
    UNIT_PRICE,
    ADJUSTED_UNIT_PRICE,
    PRICE_FLAG,
    UOM_QUANTITY,
    LINE_ID,
    HEADER_ID,
    ROUNDING_FACTOR,
    UPDATED_ADJUSTED_UNIT_PRICE,
    PRICE_LIST_HEADER_ID,
    PRICE_REQUEST_CODE,
    USAGE_PRICING_TYPE,
    LINE_CATEGORY,
    CONTRACT_START_DATE,
    CONTRACT_END_DATE,
    CATCHWEIGHT_QTY,
    ACTUAL_ORDER_QUANTITY,
    PRICING_STATUS_CODE,
    PRICING_EVENT

    )
    values
    (
    p_header_rec.header_index(i)+l_line_count,--p_header_rec.line_index(i),--Will OM populate this as well??
    'ORDER',
    p_header_rec.PRICING_DATE(i),
    p_header_rec.ORDERED_DATE(i),--p_line_rec.ACTIVE_DATE_FIRST(i)),
    'ORDER',--p_line_rec.ACTIVE_DATE_FIRST_TYPE(i),
    NULL,--p_line_rec.ACTIVE_DATE_SECOND(i)),
    NULL,--p_line_rec.ACTIVE_DATE_SECOND_TYPE(i),
    NULL,

    NULL,
    'ONT',--request_type_code hard-coded
    NULL,
    NULL,
    p_header_rec.transactional_curr_code(i),
    NULL,
    NULL,
    'Y',--this needs to change after OM adds calculate_price_flag to their rec structure--p_header_rec.CALCULATE_PRICE_FLAG(i),
    NULL,--service pricing not supported
    NULL,--line_id is null for summary line
    p_header_rec.HEADER_ID(i),

    NULL,--rounding_factor is null
    NULL,--updated_adjusted_unit_price w/b null for OM
    p_header_rec.PRICE_LIST_ID(i),
    NULL,--price_request_code not required as limits not supported
    QP_PREQ_GRP.G_REGULAR_USAGE_TYPE,--usage_pricing_type
    'ORDER',--line_category
    NULL,--CONTRACT_START_DATE
    NULL,--CONTRACT_END_DATE
    NULL,--CATCHWEIGHT_QTY
    NULL,--ACTUAL_ORDER_QUANTITY
    'X',
    p_header_rec.event_code(i)
    );

  QP_PREQ_GRP.G_INT_LINES_NO := QP_PREQ_GRP.G_INT_LINES_NO + l_line_count;

If l_debug = 'T' Then
	select count(*) into l_preq_count
	from qp_int_lines ;
	oe_debug_pub.add('bulk.l_preq_count := ' || l_preq_count);
        oe_debug_pub.add('QP_PREQ_GRP.G_INT_LINES_NO='||QP_PREQ_GRP.G_INT_LINES_NO);
End If;

 G_line_index.delete;

  G_attr_type.delete;
  G_attr_context.delete;
  G_attr_attr.delete;
  G_attr_value.delete;
  G_validated_flag.delete;

  If l_debug = 'T' Then
  	oe_debug_pub.add('Before QP_BUILD_SOURCING_PVT.get_attribute_values (H)');
  	oe_debug_pub.add ('G_line_index.count := ' || G_line_index.count);
	oe_debug_pub.add ('G_line_rec.line_id.count := ' || G_line_rec.line_id.count);
  End If;


 Begin
 QP_BUILD_SOURCING_PVT.get_attribute_values
 ('ONT', 'H',
  l_qual_ctxts_result_tbl, l_price_ctxts_result_tbl);
 Exception
	when others then
		Null;
		If l_debug = 'T' Then
			oe_debug_pub.add ('Build Sourcing Errored Out with: ' || sqlerrm);
		End If;
  End;


END IF;--p_header_rec.line_id.COUNT

If l_debug = 'T' Then
  	oe_debug_pub.add('GlineCOUNT = '||G_line_index.COUNT);

   if G_line_index.count > 0 then
   null;
   oe_debug_pub.add('Glinelast = '||G_line_index.last);
   end if;

--need to populate the new columns added to lines_tmp
--which are columns on ctrl rec for java engine

oe_debug_pub.add ('*************Bulk Debug Holes************');


for i in G_line_index.first..G_line_index.last loop
        oe_debug_pub.add ('i := ' || i);
	oe_debug_pub.add ('G_line_index(i)+l_line_count '|| (G_line_index(i)+l_line_count));
        oe_debug_pub.add ('G_attr_type(i) '|| G_attr_type(i));
        oe_debug_pub.add ('G_attr_context(i) '|| G_attr_context(i));
        oe_debug_pub.add ('G_attr_attr(i) '|| G_attr_attr(i));
        oe_debug_pub.add ('G_attr_value(i) '|| G_attr_value(i));
        oe_debug_pub.add ('G_validated_flag(i) '|| NVL (G_validated_flag(i), 'N'));
end loop;
oe_debug_pub.add ('*************Bulk Debug Holes************');
End If; --debug


BEGIN
If G_line_index.count > 0 then
forall i in G_line_index.first..G_line_index.last
insert into qp_int_line_attrs
                (line_index,
                 attribute_level,
                 attribute_type,
                 context,
                 attribute,
                 value_from,
                 validated_flag,
                 applied_flag,
                 pricing_status_code,
                 pricing_attr_flag
                )
   VALUES	(G_line_index(i)+l_line_count,
                 QP_PREQ_PUB.G_LINE_LEVEL,
		 G_attr_type(i),
                 G_attr_context(i),
                 G_attr_attr(i),
                 G_attr_value(i),
                 NVL (G_validated_flag(i), 'N'),
                 QP_PREQ_PUB.G_LIST_NOT_APPLIED,
                 QP_PREQ_PUB.G_STATUS_UNCHANGED,
                 QP_PREQ_PUB.G_YES
                );

 QP_PREQ_GRP.G_INT_ATTRS_NO := QP_PREQ_GRP.G_INT_ATTRS_NO + G_attr_context.count;
 IF l_debug = 'T' THEN
   oe_debug_pub.add ('QP_PREQ_GRP.G_INT_ATTRS_NO='||QP_PREQ_GRP.G_INT_ATTRS_NO);
 END IF;
End If;
EXCEPTION
	WHEN OTHERS THEN
		If l_debug = 'T' Then
			oe_debug_pub.add('Error inserting to qp_preq_line_attrs_temp' || sqlerrm);
		End If;
END;



IF p_line_rec.line_id.COUNT > 0 THEN


FOR i in p_line_rec.line_id.FIRST..p_line_rec.line_id.LAST
 LOOP
  FOR j in p_header_rec.header_id.FIRST..p_header_rec.header_id.LAST
  LOOP
    IF p_header_rec.header_id(j)= p_line_rec.header_id(i) THEN
       l_currency_code_tbl(i):= p_header_rec.transactional_curr_code(j);
       l_active_date_first_tbl(i):= p_header_rec.ordered_date(j);
    END IF;
  END LOOP;
END LOOP;

 for i in l_currency_code_tbl.FIRST..l_currency_code_tbl.LAST LOOP
  qp_preq_grp.engine_debug('UK Code   '||l_currency_code_tbl(i));
   qp_preq_grp.engine_debug('UK Date   '||l_active_date_first_tbl(i));
 end loop;


forall i in p_line_rec.line_id.FIRST..p_line_rec.line_id.LAST
    insert into qp_int_lines
   (
    LINE_INDEX,
    LINE_TYPE_CODE,
    PRICING_EFFECTIVE_DATE,
    START_DATE_ACTIVE_FIRST,
    ACTIVE_DATE_FIRST_TYPE,
    START_DATE_ACTIVE_SECOND,
    ACTIVE_DATE_SECOND_TYPE,
    LINE_QUANTITY,
    LINE_UOM_CODE,
    REQUEST_TYPE_CODE,
    PRICED_QUANTITY,
    PRICED_UOM_CODE,
    CURRENCY_CODE,
    UNIT_PRICE,
    ADJUSTED_UNIT_PRICE,
    PRICE_FLAG,
    UOM_QUANTITY,
    LINE_ID,
    HEADER_ID,
    ROUNDING_FACTOR,
    UPDATED_ADJUSTED_UNIT_PRICE,
    PRICE_LIST_HEADER_ID,
    PRICE_REQUEST_CODE,
    USAGE_PRICING_TYPE,
    LINE_CATEGORY,
    CONTRACT_START_DATE,
    CONTRACT_END_DATE,
    CATCHWEIGHT_QTY,
    ACTUAL_ORDER_QUANTITY,
    PRICING_STATUS_CODE
    )
    values
(
--select
    p_line_rec.LINE_INDEX(i),
    'LINE',                      --line_type_code
    p_line_rec.PRICING_DATE(i),   --OM will default the right value
   --line.START_DATE_ACTIVE_FIRST,
    l_active_date_first_tbl(i),
    'ORDER',--p_line_rec.ACTIVE_DATE_FIRST_TYPE(i),
    NULL,--p_line_rec.ACTIVE_DATE_SECOND(i)),
    NULL,--p_line_rec.ACTIVE_DATE_SECOND_TYPE(i),
    p_line_rec.ORDERED_QUANTITY(i),
    p_line_rec.ORDER_QUANTITY_UOM(i),
    'ONT',--request_type_code hard-coded
    p_line_rec.PRICING_QUANTITY(i),
    p_line_rec.PRICING_QUANTITY_UOM(i),
--    line.currency_code,
    l_CURRENCY_CODE_tbl(i),   --this w/b populated by OM
    p_line_rec.unit_list_price_per_pqty(i),
    p_line_rec.unit_selling_price_per_pqty(i),

    p_line_rec.CALCULATE_PRICE_FLAG(i),----OM will default the right value
    NULL,--uom_qty service pricing is not supported for this phase of HVOP
    p_line_rec.LINE_ID(i),
    p_line_rec.HEADER_ID(i),
    NULL,--rounding_factor is null
    NULL,--UPDATED_ADJUSTED_UNIT_PRICE is null for OM
    p_line_rec.PRICE_LIST_ID(i),
    NULL,--price_req_code is null limits not supported for this phase of HVOP
    QP_PREQ_GRP.G_REGULAR_USAGE_TYPE,--usage_pricing_type
    p_line_rec.LINE_CATEGORY_CODE(i),
    NULL,--CONTRACT_START_DATE
    NULL,--CONTRACT_END_DATE
    NULL,--CATCHWT_QTY

    NULL,--ACTUAL_ORDER_QTY
    'X'  );
    /*FROM qp_int_lines line
    WHERE line.header_id = p_line_rec.HEADER_ID(i)
    AND ROWNUM = 1;                             */

    QP_PREQ_GRP.G_INT_LINES_NO := QP_PREQ_GRP.G_INT_LINES_NO + p_line_rec.LINE_ID.count;

    if l_debug = 'T' then
	    oe_debug_pub.add ('QP_PREQ_GRP.G_INT_LINES_NO :=' ||  QP_PREQ_GRP.G_INT_LINES_NO);
    end if; --debug

END IF;--p_line_rec.line_id.COUNT

  G_line_index.delete;
  G_attr_type.delete;
  G_attr_context.delete;
  G_attr_attr.delete;
  G_attr_value.delete;
  G_validated_flag.delete;


If l_debug = 'T' Then
	oe_debug_pub.add ('Checking header_id on lines.....');
  IF p_line_rec.line_id.count > 0 THEN
	for i in p_line_rec.line_id.first..p_line_rec.line_id.last
	loop
                IF p_line_rec.header_id.exists(i) THEN
		oe_debug_pub.add ('header_id ' ||i || ': ' || p_line_rec.header_id(i));
		oe_debug_pub.add ('header_index ' ||i || ': ' || p_line_rec.header_index(i));
                END IF;
	end loop;
	oe_debug_pub.add('Before get_attributes code=L');
  END IF;
End If;

 QP_BUILD_SOURCING_PVT.get_attribute_values
 ('ONT', 'L',
  l_qual_ctxts_result_tbl, l_price_ctxts_result_tbl);

If l_debug = 'T' Then
	oe_debug_pub.add('After get_attributes code=L');
	oe_debug_pub.add ('*************Bulk Debug Holes Lines Begin************');
	for i in G_line_index.first..G_line_index.last loop
	Null;
        oe_debug_pub.add ('i := ' || i);
        oe_debug_pub.add ('G_line_index(i)+l_line_count '|| (G_line_index(i)+l_line_count));
        oe_debug_pub.add ('G_attr_type(i) '|| G_attr_type(i));
        oe_debug_pub.add ('G_attr_context(i) '|| G_attr_context(i));
        oe_debug_pub.add ('G_attr_attr(i) '|| G_attr_attr(i));
        oe_debug_pub.add ('G_attr_value(i) '|| G_attr_value(i));
        oe_debug_pub.add ('G_validated_flag(i) '|| NVL (G_validated_flag(i), 'N'));
	end loop;
	oe_debug_pub.add ('*************Bulk Debug Holes Lines End************');
End If;

if G_line_index.count > 0 then
forall i in G_line_index.first..G_line_index.last
insert into qp_int_line_attrs
                (line_index,
                 attribute_level,
                 attribute_type,
                 context,
                 attribute,
                 value_from,
                 validated_flag,
                 applied_flag,
                 pricing_status_code,
                 pricing_attr_flag
                )
   VALUES	(G_line_index(i),
                 QP_PREQ_PUB.G_LINE_LEVEL,
		 G_attr_type(i),
                 G_attr_context(i),
                 G_attr_attr(i),
                 G_attr_value(i),
                 G_validated_flag(i),
                 QP_PREQ_PUB.G_LIST_NOT_APPLIED,
                 QP_PREQ_PUB.G_STATUS_UNCHANGED,
                 QP_PREQ_PUB.G_YES
                );
 QP_PREQ_GRP.G_INT_ATTRS_NO := QP_PREQ_GRP.G_INT_ATTRS_NO + G_attr_context.count;
 IF l_debug = FND_API.G_TRUE THEN
   oe_debug_pub.add ('QP_PREQ_GRP.G_INT_ATTRS_NO='||QP_PREQ_GRP.G_INT_ATTRS_NO);
 END IF;
end if;--G_line_index.count

If l_debug = 'T' Then
	oe_debug_pub.add ('Finished QPBGPREB lines: Success');
End If;
	COMMIT;

EXCEPTION
When OTHERS Then
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_status_text := 'Exception in Bulk_insert_lines '||SQLERRM;
If l_debug = 'T' Then
	oe_debug_pub.add ('Finished QPBGPREB lines:' ||SQLERRM);
End If;
END Bulk_insert_lines;

Procedure Bulk_insert_adj(x_return_status OUT NOCOPY VARCHAR2,
                         x_return_status_text OUT NOCOPY VARCHAR2) IS
ldet_count number;
line_ldet_count number;              --added for bug 3406218
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

If l_debug = 'T' Then
	oe_debug_pub.add ('Started QPBGPREB Adjs:' ||SQLERRM);
End If;
insert into qp_int_ldets
  (LINE_DETAIL_INDEX,
  LINE_DETAIL_TYPE_CODE,
  PRICE_BREAK_TYPE_CODE,
  LINE_INDEX,
  CREATED_FROM_LIST_HEADER_ID,
  CREATED_FROM_LIST_LINE_ID,
  CREATED_FROM_LIST_LINE_TYPE,
  CREATED_FROM_LIST_TYPE_CODE,
  PRICING_GROUP_SEQUENCE,
  PRICING_PHASE_ID,
  OPERAND_CALCULATION_CODE,
  OPERAND_VALUE,
  SUBSTITUTION_TYPE_CODE,
  SUBSTITUTION_VALUE_FROM,
  SUBSTITUTION_VALUE_TO,
  PRICE_FORMULA_ID,
  PRICING_STATUS_CODE,
  PRODUCT_PRECEDENCE,
  INCOMPATABILITY_GRP_CODE,
  APPLIED_FLAG,
  AUTOMATIC_FLAG,
  OVERRIDE_FLAG,
  MODIFIER_LEVEL_CODE,
  BENEFIT_QTY,
  BENEFIT_UOM_CODE,
  LIST_LINE_NO,
  ACCRUAL_FLAG,
  ACCRUAL_CONVERSION_RATE,
  ESTIM_ACCRUAL_RATE,
  CHARGE_TYPE_CODE,
  CHARGE_SUBTYPE_CODE,
  PROCESS_CODE,
  LINE_QUANTITY,
  UPDATED_FLAG, -- begin shu, fix Bug 2599822
  CALCULATION_CODE,
  CHANGE_REASON_CODE,
  CHANGE_REASON_TEXT,
  ADJUSTMENT_AMOUNT)
(select
  rownum,
  'NULL',
  ll.PRICE_BREAK_TYPE_CODE,
  line.LINE_INDEX,
  ll.LIST_HEADER_ID,
  ll.LIST_LINE_ID,
  ll.LIST_LINE_TYPE_CODE,
  lhdr.LIST_TYPE_CODE,
  ll.PRICING_GROUP_SEQUENCE,
  ll.PRICING_PHASE_ID,
  ll.ARITHMETIC_OPERATOR,
  nvl(adj_iface.OPERAND_PER_PQTY,adj_iface.OPERAND),
  ll.SUBSTITUTION_ATTRIBUTE,
  ll.SUBSTITUTION_VALUE,
  NULL,
  ll.PRICE_BY_FORMULA_ID,
  QP_PREQ_PUB.G_STATUS_UNCHANGED,
  ll.PRODUCT_PRECEDENCE,
  ll.INCOMPATIBILITY_GRP_CODE,
  adj_iface.APPLIED_FLAG,
  ll.AUTOMATIC_FLAG,
  ll.OVERRIDE_FLAG,
  ll.MODIFIER_LEVEL_CODE,
  ll.BENEFIT_QTY,
  ll.BENEFIT_UOM_CODE,
  ll.LIST_LINE_NO,
  ll.ACCRUAL_FLAG,
  ll.ACCRUAL_CONVERSION_RATE,
  ll.ESTIM_ACCRUAL_RATE,
  ll.CHARGE_TYPE_CODE,
  ll.CHARGE_SUBTYPE_CODE,
  QP_PREQ_PUB.G_STATUS_NEW,
  line.priced_quantity, --adj_iface.range_break_quantity, --need to find out what engine populates this as
  adj_iface.UPDATED_FLAG, -- begin shu, fix Bug 2599822
  NULL,
  NULL,
  NULL,
  adj_iface.ADJUSTED_AMOUNT_PER_PQTY
From  oe_price_adjs_iface_all adj_iface,
      oe_lines_iface_all lines_iface,
      qp_int_lines line,
      qp_list_lines ll,
      qp_list_headers_b lhdr
Where adj_iface.ORDER_SOURCE_ID = lines_iface.ORDER_SOURCE_ID
and adj_iface.ORIG_SYS_DOCUMENT_REF = lines_iface.ORIG_SYS_DOCUMENT_REF
and adj_iface.ORIG_SYS_LINE_REF = lines_iface.ORIG_SYS_LINE_REF
and line.line_type_code = 'LINE'
and   lines_iface.line_id = line.line_id
--and   lines_iface.header_id = line.header_id
and   ll.list_line_id = adj_iface.list_line_id
and   lhdr.list_header_id = ll.list_header_id);

select nvl(max(line_detail_index),0) into line_ldet_count from qp_int_ldets;  -- fix for bug 3406218

If l_debug = 'T' Then
oe_debug_pub.add('Number of line level adjustments are '||line_ldet_count);
End if;

--UNION                     --split the insert statement for bug 3406218
insert into qp_int_ldets
  (LINE_DETAIL_INDEX,
  LINE_DETAIL_TYPE_CODE,
  PRICE_BREAK_TYPE_CODE,
  LINE_INDEX,
  CREATED_FROM_LIST_HEADER_ID,
  CREATED_FROM_LIST_LINE_ID,
  CREATED_FROM_LIST_LINE_TYPE,
  CREATED_FROM_LIST_TYPE_CODE,
  PRICING_GROUP_SEQUENCE,
  PRICING_PHASE_ID,
  OPERAND_CALCULATION_CODE,
  OPERAND_VALUE,
  SUBSTITUTION_TYPE_CODE,
  SUBSTITUTION_VALUE_FROM,
  SUBSTITUTION_VALUE_TO,
  PRICE_FORMULA_ID,
  PRICING_STATUS_CODE,
  PRODUCT_PRECEDENCE,
  INCOMPATABILITY_GRP_CODE,
  APPLIED_FLAG,
  AUTOMATIC_FLAG,
  OVERRIDE_FLAG,
  MODIFIER_LEVEL_CODE,
  BENEFIT_QTY,
  BENEFIT_UOM_CODE,
  LIST_LINE_NO,
  ACCRUAL_FLAG,
  ACCRUAL_CONVERSION_RATE,
  ESTIM_ACCRUAL_RATE,
  CHARGE_TYPE_CODE,
  CHARGE_SUBTYPE_CODE,
  PROCESS_CODE,
  LINE_QUANTITY,
  UPDATED_FLAG, -- begin shu, fix Bug 2599822
  CALCULATION_CODE,
  CHANGE_REASON_CODE,
  CHANGE_REASON_TEXT,
  ADJUSTMENT_AMOUNT)
(select
  rownum+line_ldet_count,
  'NULL',
  ll.PRICE_BREAK_TYPE_CODE,
  line.LINE_INDEX,
  ll.LIST_HEADER_ID,
  ll.LIST_LINE_ID,
  ll.LIST_LINE_TYPE_CODE,
  lhdr.LIST_TYPE_CODE,
  ll.PRICING_GROUP_SEQUENCE,
  ll.PRICING_PHASE_ID,
  ll.ARITHMETIC_OPERATOR,
  nvl(adj_iface.OPERAND_PER_PQTY,adj_iface.OPERAND),
  ll.SUBSTITUTION_ATTRIBUTE,
  ll.SUBSTITUTION_VALUE,
  NULL,
  ll.PRICE_BY_FORMULA_ID,
  QP_PREQ_PUB.G_STATUS_UNCHANGED,
  ll.PRODUCT_PRECEDENCE,
  ll.INCOMPATIBILITY_GRP_CODE,
  adj_iface.APPLIED_FLAG,
  ll.AUTOMATIC_FLAG,
  ll.OVERRIDE_FLAG,
  ll.MODIFIER_LEVEL_CODE,
  ll.BENEFIT_QTY,
  ll.BENEFIT_UOM_CODE,
  ll.LIST_LINE_NO,
  ll.ACCRUAL_FLAG,
  ll.ACCRUAL_CONVERSION_RATE,
  ll.ESTIM_ACCRUAL_RATE,
  ll.CHARGE_TYPE_CODE,
  ll.CHARGE_SUBTYPE_CODE,
  QP_PREQ_PUB.G_STATUS_NEW,
  line.priced_quantity, --adj_iface.range_break_quantity, --need to find out what engine populates this as
  adj_iface.UPDATED_FLAG, -- begin shu, fix Bug 2599822
  NULL,
  NULL,
  NULL,
  adj_iface.ADJUSTED_AMOUNT_PER_PQTY
From  oe_price_adjs_iface_all adj_iface,
      oe_headers_iface_all hdrs_iface,
      qp_int_lines line,
      qp_list_lines ll,
      qp_list_headers_b lhdr
Where adj_iface.ORDER_SOURCE_ID = hdrs_iface.ORDER_SOURCE_ID
and adj_iface.ORIG_SYS_DOCUMENT_REF = hdrs_iface.ORIG_SYS_DOCUMENT_REF
and line.line_type_code = 'ORDER'
and adj_iface.ORIG_SYS_LINE_REF is null
and   hdrs_iface.header_id = line.header_id     -- fix for bug 3406218
and line.line_id is null
--and   lines_iface.header_id = line.header_id
and   ll.list_line_id = adj_iface.list_line_id
and   lhdr.list_header_id = ll.list_header_id);

  IF l_debug = FND_API.G_TRUE THEN
    oe_debug_pub.add ('QP_BULK_PREQ_GRP.bulk_insert_adj inserted adj count='||SQL%ROWCOUNT);
  END IF;

--added for java engine stats accumulation on li's request
select count(*) into ldet_count
From  oe_price_adjs_iface_all adj_iface,
      oe_lines_iface_all lines_iface,
      qp_int_lines line,
      qp_list_lines ll,
      qp_list_headers_b lhdr
Where adj_iface.ORIG_SYS_LINE_REF = lines_iface.ORIG_SYS_LINE_REF
and   lines_iface.line_id = line.line_id
--and   lines_iface.header_id = line.header_id
and   ll.list_line_id = adj_iface.list_line_id
and   lhdr.list_header_id = ll.list_header_id;

  QP_PREQ_GRP.G_INT_LDETS_NO := QP_PREQ_GRP.G_INT_LDETS_NO + ldet_count;
  IF l_debug = FND_API.G_TRUE THEN
    oe_debug_pub.add ('QP_PREQ_GRP.G_INT_LDETS_NO='||QP_PREQ_GRP.G_INT_LDETS_NO);
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    FOR cl in (select line_index, line_detail_index, operand_value, operand_calculation_code, updated_flag, applied_flag
              ,created_from_list_line_id, automatic_flag, override_flag from qp_int_ldets)
    LOOP
      oe_debug_pub.add('Inserted ldet details: line_index '||cl.line_index||' line_detail_index '||cl.line_detail_index
      ||' created_from_list_line_id '||cl.created_from_list_line_id||' operand_value '||cl.operand_value||' arithmetic_operator '
      ||cl.operand_calculation_code||' updated_flag '||cl.updated_flag||' applied_flag '||cl.applied_flag||' automatic_flag '
      ||cl.automatic_flag||' override_flag '||cl.override_flag);
    END LOOP;
  END IF;

COMMIT;

If l_debug = 'T' Then
	oe_debug_pub.add ('Finished QPBGPREB adjs: Success') ;
End If;
EXCEPTION
When OTHERS Then
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_status_text := 'Exception in Bulk_insert_adj '||SQLERRM;
If l_debug = 'T' Then
	oe_debug_pub.add ('Finished QPBGPREB adjs:' ||SQLERRM);
End If;
End Bulk_insert_adj;

END QP_BULK_PREQ_GRP;


/
