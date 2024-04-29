--------------------------------------------------------
--  DDL for Package Body FTE_QP_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_QP_ENGINE" AS
/* $Header: FTEFRQPB.pls 115.21 2003/12/18 21:26:48 susurend ship $ */

-- This package encapsulates all qp engine related methods and data structures.
-- It provides several utility packages to create engine input records.
-- It will also hold engine i/p and o/p in global tables per event.

 -- stores defaults for each pricing event
 g_engine_defaults_tab       pricing_engine_def_tab_type;

-- utility methods

 -- this procedure calculates the total base price of a shipment, for a given set.
 -- multiplies unit price by line quantity
 -- price is in the priced currency

 -- can we really have set number here? set num is not stored in any of the actual qp lines
 PROCEDURE get_total_base_price       (p_set_num          IN NUMBER DEFAULT 1,
                                       x_price            OUT NOCOPY  NUMBER,
                                       x_return_status    OUT NOCOPY  VARCHAR2)
 IS
    i                  NUMBER;
    l_currency         VARCHAR2(30);
    l_price            NUMBER;
    l_cum_price        NUMBER := 0;
    l_return_status    VARCHAR2(1);
    l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
    l_method_name VARCHAR2(50) := 'get_total_base_price';
 BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'get_total_base_price');

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'p_set_num = '||p_set_num);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_O_line_tbl.COUNT = '||g_O_line_tbl.COUNT);
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_I_line_extras_tbl.FIRST = '||g_I_line_extras_tbl.FIRST);

      i := g_O_line_tbl.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Outside If input_set_number = '||g_I_line_extras_tbl(i).input_set_number);
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'unit_price = '||g_O_line_tbl(i).unit_price);
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'priced_quantity = '||g_O_line_tbl(i).priced_quantity);
             IF ( g_I_line_extras_tbl(i).input_set_number = p_set_num ) THEN
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'input_set_number = '||g_I_line_extras_tbl(i).input_set_number);
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'unit_price = '||g_O_line_tbl(i).unit_price);
                  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'priced_quantity = '||g_O_line_tbl(i).priced_quantity);
                  l_cum_price := l_cum_price + (g_O_line_tbl(i).unit_price * g_O_line_tbl(i).priced_quantity);
             END IF;
      EXIT WHEN i >= g_O_line_tbl.LAST;
             i := g_O_line_tbl.NEXT(i);
      END LOOP;
      END IF;

     FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'l_cum_price = '||l_cum_price);

     x_price := l_cum_price;

     fte_freight_pricing_util.unset_method(l_log_level,'get_total_base_price');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'get_total_base_price');

 END get_total_base_price;

-- prorate (apply) new charge across engine output lines by ratio of current unit_price to current total unit price?
--   ( it could also be by ratio of current line amount to current total base price)
-- assumes that the new price is in the priced currency.
PROCEDURE apply_new_base_price       ( p_set_num          IN NUMBER  DEFAULT 1,
                                       p_new_total_price  IN NUMBER,
                                       x_return_status    OUT NOCOPY  VARCHAR2)
IS
  i                    NUMBER;
  l_cum_price          NUMBER := 0;
  l_cum_unit_price     NUMBER := 0;
  l_total_base_price   NUMBER := 0;

  l_return_status    VARCHAR2(1);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'apply_new_base_price';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,'apply_new_base_price');

  -- first get total base price for the ratio
  get_total_base_price(
    p_set_num          => p_set_num,
    x_price            => l_total_base_price,
    x_return_status    => l_return_status);

  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after get_total_base_price ');
  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      raise FTE_FREIGHT_PRICING_UTIL.g_total_base_price_failed;
    END IF;
  ELSE
    FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'l_total_base_price = '||l_total_base_price);
  END IF;

  i := g_O_line_tbl.FIRST;
  IF (i is NOT NULL) THEN
  LOOP
    IF ( g_I_line_extras_tbl(g_O_line_tbl(i).line_index).input_set_number = p_set_num ) THEN
      g_O_line_tbl(i).unit_price
        := (g_O_line_tbl(i).unit_price * p_new_total_price)/l_total_base_price;
      -- also change adjusted unit price just in case.
      g_O_line_tbl(i).adjusted_unit_price
        := (g_O_line_tbl(i).adjusted_unit_price * p_new_total_price)/l_total_base_price;
    END IF; -- set num

    EXIT WHEN i >= g_O_line_tbl.LAST;
    i := g_O_line_tbl.NEXT(i);
  END LOOP;
  END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'apply_new_base_price');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_total_base_price_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'total_base_price_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'apply_new_base_price');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'apply_new_base_price');

 END apply_new_base_price;

 PROCEDURE print_commodity_price_rows (p_comm_price_rows  IN commodity_price_tbl_type)
 IS
   i NUMBER :=0;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'print_commodity_price_rows';
 BEGIN

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'----Commodity Price Rows ----');
     i := p_comm_price_rows.FIRST;
     IF ( i IS NOT NULL) THEN
     LOOP
          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'category_id = '||p_comm_price_rows(i).category_id);
          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'unit_price  = '||p_comm_price_rows(i).unit_price);
          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'total_wt =    '||p_comm_price_rows(i).total_wt);
          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_INF,'wt_uom =      '||p_comm_price_rows(i).wt_uom);
     EXIT WHEN  i >= p_comm_price_rows.LAST;
        i := p_comm_price_rows.NEXT(i);
     END LOOP;
     END IF;

 END print_commodity_price_rows;

  -- get me unit price for each individual commodity for each set
  -- get me total wt. for each individual commodity
  -- give me all weights in the deficit wt uom
  -- currently we have implementation only for event num =1
 PROCEDURE analyse_output_for_deficit_wt (p_set_num          IN NUMBER,
                                          p_wt_uom           IN VARCHAR2,
                                          x_commodity_price_rows  OUT NOCOPY  commodity_price_tbl_type,
                                          x_return_status    OUT NOCOPY  VARCHAR2)
 IS
   l_return_status      VARCHAR2(1);
   i                    NUMBER;
   l_category_id        NUMBER;
   l_comm_tbl           commodity_price_tbl_type;
   l_comm_row           commodity_price_rec_type;
   l_curr_wt            NUMBER;
   l_curr_wt_uom        VARCHAR2(30);
   l_curr_uom_unit_price  NUMBER:=0;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'analyse_output_for_deficit_wt';
 BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'analyse_output_for_deficit_wt');

      -- scan for commodities
      i := g_O_line_tbl.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
        IF (g_I_line_extras_tbl(g_O_line_tbl(i).line_index).input_set_number = p_set_num) THEN
           l_category_id  := g_I_line_extras_tbl(g_O_line_tbl(i).line_index).category_id;
            -- convert current line quantity to p_wt_uom
           IF (g_O_line_tbl(i).priced_uom_code <> p_wt_uom ) THEN
               l_curr_wt  :=  WSH_WV_UTILS.convert_uom(g_O_line_tbl(i).priced_uom_code,
                                                       p_wt_uom,
                                                       g_O_line_tbl(i).priced_quantity,
                                                       0);  -- Within same UOM class
               l_curr_uom_unit_price := g_O_line_tbl(i).unit_price*(g_O_line_tbl(i).priced_quantity/l_curr_wt);

           ELSE
               l_curr_wt  := g_O_line_tbl(i).priced_quantity;
               l_curr_uom_unit_price := g_O_line_tbl(i).unit_price;
           END IF;

           -- now add the category to the commodity table
           IF (l_comm_tbl.EXISTS(l_category_id)) THEN
             -- add to existing category row
             -- Theoretically this should never happen in LTL
             -- ie. there should not be more than one output line per commodity

	     -- The above assumption is not true, because there are loose items --xizhang

                l_comm_tbl(l_category_id).total_wt := l_comm_tbl(l_category_id).total_wt + l_curr_wt;

                -- the next if statement is not really required, because unit price for a commodity will be
                -- the same within a shipment, most of the time
                -- this statement makes sure that, if this is not the case, the lowest unit price is captured
                -- Not required AG 5/13
                -- As even if this happens in a rate chart
                -- it would create a wrong picture of deficit wt calculation
                -- For now, we will attach deficit wt charge to the
                -- qp output line that had the lowest unit price for selected commodity
                -- As according to this design even more than one output line per category
                -- is a problem

                IF (l_curr_uom_unit_price < l_comm_tbl(l_category_id).unit_price ) THEN

                    l_comm_tbl(l_category_id).unit_price := l_curr_uom_unit_price;
                    l_comm_tbl(l_category_id).priced_uom := g_O_line_tbl(i).priced_uom_code;
                    l_comm_tbl(l_category_id).output_line_index := g_O_line_tbl(i).line_index;
                    l_comm_tbl(l_category_id).output_line_priced_quantity := l_curr_wt;
                END IF;

           ELSE
             -- create new row
                l_comm_row.category_id := l_category_id;

                -- The unit price returned here does not take into account the uom conversion
                -- QP returns unit price always in priced_uom_code
                -- while p_wt_uom can be different from priced_uom_code AG 5/12

                l_comm_row.unit_price  := l_curr_uom_unit_price;
                FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'l_comm_row.unit_price = '||l_comm_row.unit_price);
                l_comm_row.total_wt    := l_curr_wt;  -- it is assumed that only wt basis is present
                l_comm_row.wt_uom      := p_wt_uom;
                l_comm_row.priced_uom  := g_O_line_tbl(i).priced_uom_code;
                l_comm_row.output_line_index  := g_O_line_tbl(i).line_index;
                l_comm_row.output_line_priced_quantity  := l_curr_wt;
                l_comm_tbl(l_category_id) := l_comm_row;
           END IF;

        END IF; --set num

      EXIT WHEN i >= g_O_line_tbl.LAST;
      i := g_O_line_tbl.NEXT(i);
      END LOOP;
      END IF;

      print_commodity_price_rows(l_comm_tbl);

      x_commodity_price_rows := l_comm_tbl;

 fte_freight_pricing_util.unset_method(l_log_level,'analyse_output_for_deficit_wt');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'analyse_output_for_deficit_wt');

 END analyse_output_for_deficit_wt;

-- clear qp input line table, line extra table, attribute/qualifier tabl
PROCEDURE clear_qp_input(x_return_status OUT NOCOPY  VARCHAR2)
IS
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'clear_qp_input';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  g_I_control_rec := null;

  g_I_request_type_code.delete;
  g_I_line_id.delete;
  g_I_line_index.delete;
  g_I_line_type_code.delete;
  g_I_pricing_effective_date.delete;
  g_I_active_date_first.delete;
  g_I_active_date_second.delete;
  g_I_line_quantity.delete;
  g_I_line_uom_code.delete;
  g_I_currency_code.delete;
  g_I_price_flag.delete;
  G_I_ACTIVE_DATE_FIRST_TYPE.delete;
  G_I_ACTIVE_DATE_SECOND_TYPE.delete;
  G_I_PRICED_QUANTITY.delete;
  G_I_PRICED_UOM_CODE.delete;
  G_I_UNIT_PRICE.delete;
  G_I_PERCENT_PRICE.delete;
  G_I_UOM_QUANTITY.delete;
  G_I_ADJUSTED_UNIT_PRICE.delete;
  G_I_UPD_ADJUSTED_UNIT_PRICE.delete;
  G_I_PROCESSED_FLAG.delete;
  G_I_PROCESSING_ORDER.delete;
  G_I_PRICING_STATUS_CODE.delete;
  G_I_PRICING_STATUS_TEXT.delete;
  G_I_ROUNDING_FLAG.delete;
  G_I_ROUNDING_FACTOR.delete;
  G_I_QUALIFIERS_EXIST_FLAG.delete;
  G_I_PRICING_ATTRS_EXIST_FLAG.delete;
  G_I_PRICE_LIST_ID.delete;
  G_I_VALIDATED_FLAG.delete;
  G_I_PRICE_REQUEST_CODE.delete;
  G_I_USAGE_PRICING_TYPE.delete;
  G_I_LINE_CATEGORY.delete;

  g_I_line_extras_tbl.delete;

    g_I_A_LINE_INDEX.delete;
    g_I_A_CONTEXT.delete;
    g_I_A_ATTRIBUTE_TYPE.delete;
    g_I_A_ATTRIBUTE.delete;
    g_I_A_VALUE_FROM.delete;
    G_I_A_VALIDATED_FLAG.delete;
    G_I_A_LINE_DETAIL_INDEX.delete;
    G_I_A_ATTRIBUTE_LEVEL.delete;
    G_I_A_LIST_HEADER_ID.delete;
    G_I_A_LIST_LINE_ID.delete;
    G_I_A_SETUP_VALUE_FROM.delete;
    G_I_A_VALUE_TO.delete;
    G_I_A_SETUP_VALUE_TO.delete;
    G_I_A_GROUPING_NUMBER.delete;
    G_I_A_NO_QUALIFIERS_IN_GRP.delete;
    G_I_A_APPLIED_FLAG.delete;
    G_I_A_PRICING_STATUS_CODE.delete;
    G_I_A_PRICING_STATUS_TEXT.delete;
    G_I_A_QUALIFIER_PRECEDENCE.delete;
    G_I_A_DATATYPE.delete;
    G_I_A_PRICING_ATTR_FLAG.delete;
    G_I_A_QUALIFIER_TYPE.delete;
    G_I_A_PRODUCT_UOM_CODE.delete;
    G_I_A_EXCLUDER_FLAG.delete;
    G_I_A_PRICING_PHASE_ID.delete;
    G_I_A_INCOMPATABILITY_GRP_CODE.delete;
    G_I_A_LINE_DETAIL_TYPE_CODE.delete;
    G_I_A_MODIFIER_LEVEL_CODE.delete;
    G_I_A_PRIMARY_UOM_FLAG.delete;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END clear_qp_input;

-- delete from qp input line table, line extra table, attribute/qualifier table
PROCEDURE delete_line_from_qp_input(
  p_line_index IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
IS
   i NUMBER;
   j NUMBER;
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'delete_line_from_qp_input';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  fte_freight_pricing_util.print_msg(l_log_level,'p_line_index = '||p_line_index);

  i := p_line_index;
  fte_freight_pricing_util.print_msg(l_log_level,'delete line where i = '||i);

  g_I_request_type_code.delete(i);
  g_I_line_id.delete(i);
  g_I_line_index.delete(i);
  g_I_line_type_code.delete(i);
  g_I_pricing_effective_date.delete(i);
  g_I_active_date_first.delete(i);
  g_I_active_date_second.delete(i);
  g_I_line_quantity.delete(i);
  g_I_line_uom_code.delete(i);
  g_I_currency_code.delete(i);
  g_I_price_flag.delete(i);
  G_I_ACTIVE_DATE_FIRST_TYPE.delete(i);
  G_I_ACTIVE_DATE_SECOND_TYPE.delete(i);
  G_I_PRICED_QUANTITY.delete(i);
  G_I_PRICED_UOM_CODE.delete(i);
  G_I_UNIT_PRICE.delete(i);
  G_I_PERCENT_PRICE.delete(i);
  G_I_UOM_QUANTITY.delete(i);
  G_I_ADJUSTED_UNIT_PRICE.delete(i);
  G_I_UPD_ADJUSTED_UNIT_PRICE.delete(i);
  G_I_PROCESSED_FLAG.delete(i);
  G_I_PROCESSING_ORDER.delete(i);
  G_I_PRICING_STATUS_CODE.delete(i);
  G_I_PRICING_STATUS_TEXT.delete(i);
  G_I_ROUNDING_FLAG.delete(i);
  G_I_ROUNDING_FACTOR.delete(i);
  G_I_QUALIFIERS_EXIST_FLAG.delete(i);
  G_I_PRICING_ATTRS_EXIST_FLAG.delete(i);
  G_I_PRICE_LIST_ID.delete(i);
  G_I_VALIDATED_FLAG.delete(i);
  G_I_PRICE_REQUEST_CODE.delete(i);
  G_I_USAGE_PRICING_TYPE.delete(i);
  G_I_LINE_CATEGORY.delete(i);

  g_I_line_extras_tbl.delete(i);

  j := g_I_A_LINE_INDEX.FIRST;
  if (j is not null) then
    loop
      if (g_I_A_LINE_INDEX(j) = i) then

  fte_freight_pricing_util.print_msg(l_log_level,'delete line attr where j = '||j);
    g_I_A_LINE_INDEX.delete(j);
    g_I_A_CONTEXT.delete(j);
    g_I_A_ATTRIBUTE_TYPE.delete(j);
    g_I_A_ATTRIBUTE.delete(j);
    g_I_A_VALUE_FROM.delete(j);
    G_I_A_VALIDATED_FLAG.delete(j);
    G_I_A_LINE_DETAIL_INDEX.delete(j);
    G_I_A_ATTRIBUTE_LEVEL.delete(j);
    G_I_A_LIST_HEADER_ID.delete(j);
    G_I_A_LIST_LINE_ID.delete(j);
    G_I_A_SETUP_VALUE_FROM.delete(j);
    G_I_A_VALUE_TO.delete(j);
    G_I_A_SETUP_VALUE_TO.delete(j);
    G_I_A_GROUPING_NUMBER.delete(j);
    G_I_A_NO_QUALIFIERS_IN_GRP.delete(j);
    G_I_A_APPLIED_FLAG.delete(j);
    G_I_A_PRICING_STATUS_CODE.delete(j);
    G_I_A_PRICING_STATUS_TEXT.delete(j);
    G_I_A_QUALIFIER_PRECEDENCE.delete(j);
    G_I_A_DATATYPE.delete(j);
    G_I_A_PRICING_ATTR_FLAG.delete(j);
    G_I_A_QUALIFIER_TYPE.delete(j);
    G_I_A_PRODUCT_UOM_CODE.delete(j);
    G_I_A_EXCLUDER_FLAG.delete(j);
    G_I_A_PRICING_PHASE_ID.delete(j);
    G_I_A_INCOMPATABILITY_GRP_CODE.delete(j);
    G_I_A_LINE_DETAIL_TYPE_CODE.delete(j);
    G_I_A_MODIFIER_LEVEL_CODE.delete(j);
    G_I_A_PRIMARY_UOM_FLAG.delete(j);

      end if;
      exit when j >= g_I_A_LINE_INDEX.LAST;
      j := g_I_A_LINE_INDEX.NEXT(j);
    end loop;
  end if;

fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

END delete_line_from_qp_input;

-- delete from qp output line table, line detail table
PROCEDURE delete_line_from_qp_output(
  p_line_index IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
IS
   j NUMBER;
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'delete_line_from_qp_output';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  fte_freight_pricing_util.print_msg(l_log_level,'p_line_index = '||p_line_index);

  g_O_line_tbl.delete(p_line_index);
  fte_freight_pricing_util.print_msg(l_log_level,'delete line where i = '||p_line_index);

  j := g_O_line_detail_tbl.FIRST;
  if (j is not null) then
    loop
      if (g_O_line_detail_tbl(j).line_index = p_line_index) then

  fte_freight_pricing_util.print_msg(l_log_level,'delete line attr where j = '||j);

	g_O_line_detail_tbl.delete(j);
      end if;
      exit when j >= g_O_line_detail_tbl.LAST;
      j := g_O_line_detail_tbl.NEXT(j);
    end loop;
  end if;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END delete_line_from_qp_output;

 -- delete a set from the input and output lines for event 1
 PROCEDURE delete_set_from_line_event(p_set_num          IN NUMBER,
                                      x_return_status    OUT NOCOPY  VARCHAR2)
 IS
   i NUMBER :=0;
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'delete_set_from_line_event';
 BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'delete_set_from_line_event');

      FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'p_set_num ='||p_set_num);

      --delete input lines, output lines, attributes and qualifiers
      i := g_I_LINE_INDEX.FIRST;
      if (i is not null) then
        loop
          FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'i = '||i);
          FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'line_index = '||g_I_line_index(i));
          FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'input_set_num ='||g_I_line_extras_tbl(g_I_line_index(i)).input_set_number);
          IF (g_I_line_extras_tbl(g_I_line_index(i)).input_set_number = p_set_num) THEN
	    delete_line_from_qp_input(
		p_line_index => i,
		x_return_status => l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_set_failed;
            END IF;

	    delete_line_from_qp_output(
		p_line_index => i,
		x_return_status => l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_set_failed;
            END IF;

	  END IF;
        exit when i>= g_I_LINE_INDEX.LAST;
        i := g_I_LINE_INDEX.NEXT(i);
        end loop;
      end if;

 fte_freight_pricing_util.unset_method(l_log_level,'delete_set_from_line_event');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_set_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'delete_set_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'delete_set_from_line_event');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'delete_set_from_line_event');
 END delete_set_from_line_event;


-- delete from event tables for the specified line_index
PROCEDURE delete_lines(p_line_index      IN NUMBER,
                       x_qp_output_line_rows    IN OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
                       x_qp_output_detail_rows  IN OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                       x_return_status   OUT NOCOPY  VARCHAR2)
IS
  i NUMBER;
  l_return_status VARCHAR2(1);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'delete_lines';
 BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'delete_lines');

	    delete_line_from_qp_input(
		p_line_index => p_line_index,
		x_return_status => l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed;
            END IF;

	    delete_line_from_qp_output(
		p_line_index => p_line_index,
		x_return_status => l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                raise FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed;
            END IF;

        x_qp_output_line_rows   := g_O_line_tbl;
        x_qp_output_detail_rows := g_O_line_detail_tbl;

 fte_freight_pricing_util.unset_method(l_log_level,'delete_lines');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_qpline_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'delete_qpline_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'delete_lines');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'delete_lines');

END delete_lines;

PROCEDURE move_line_row(
    p_from_index IN NUMBER,
    p_to_index NUMBER)
IS
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
BEGIN
  fte_freight_pricing_util.print_msg(l_log_level,'move qp input line from '||p_from_index ||' to '||p_to_index);

  G_I_LINE_INDEX(p_to_index) := G_I_LINE_INDEX(p_from_index);
  G_I_LINE_TYPE_CODE(p_to_index) := G_I_LINE_TYPE_CODE(p_from_index);
  G_I_PRICING_EFFECTIVE_DATE(p_to_index) := G_I_PRICING_EFFECTIVE_DATE(p_from_index);
  G_I_ACTIVE_DATE_FIRST(p_to_index) := G_I_ACTIVE_DATE_FIRST(p_from_index);
  G_I_ACTIVE_DATE_FIRST_TYPE(p_to_index) := G_I_ACTIVE_DATE_FIRST_TYPE(p_from_index);
  G_I_ACTIVE_DATE_SECOND(p_to_index) := G_I_ACTIVE_DATE_SECOND(p_from_index);
  G_I_ACTIVE_DATE_SECOND_TYPE(p_to_index) := G_I_ACTIVE_DATE_SECOND_TYPE(p_from_index);
  G_I_LINE_QUANTITY(p_to_index) := G_I_LINE_QUANTITY(p_from_index);
  G_I_LINE_UOM_CODE(p_to_index) := G_I_LINE_UOM_CODE(p_from_index);
  G_I_REQUEST_TYPE_CODE(p_to_index) := G_I_REQUEST_TYPE_CODE(p_from_index);
  G_I_PRICED_QUANTITY(p_to_index) := G_I_PRICED_QUANTITY(p_from_index);
  G_I_PRICED_UOM_CODE(p_to_index) := G_I_PRICED_UOM_CODE(p_from_index);
  G_I_CURRENCY_CODE(p_to_index) := G_I_CURRENCY_CODE(p_from_index);
  G_I_UNIT_PRICE(p_to_index) := G_I_UNIT_PRICE(p_from_index);
  G_I_PERCENT_PRICE(p_to_index) := G_I_PERCENT_PRICE(p_from_index);
  G_I_UOM_QUANTITY(p_to_index) := G_I_UOM_QUANTITY(p_from_index);
  G_I_ADJUSTED_UNIT_PRICE(p_to_index) := G_I_ADJUSTED_UNIT_PRICE(p_from_index);
  G_I_UPD_ADJUSTED_UNIT_PRICE(p_to_index) := G_I_UPD_ADJUSTED_UNIT_PRICE(p_from_index);
  G_I_PROCESSED_FLAG(p_to_index) := G_I_PROCESSED_FLAG(p_from_index);
  G_I_PRICE_FLAG(p_to_index) := G_I_PRICE_FLAG(p_from_index);
  G_I_LINE_ID(p_to_index) := G_I_LINE_ID(p_from_index);
  G_I_PROCESSING_ORDER(p_to_index) := G_I_PROCESSING_ORDER(p_from_index);
  G_I_PRICING_STATUS_CODE(p_to_index) := G_I_PRICING_STATUS_CODE(p_from_index);
  G_I_PRICING_STATUS_TEXT(p_to_index) := G_I_PRICING_STATUS_TEXT(p_from_index);
  G_I_ROUNDING_FLAG(p_to_index) := G_I_ROUNDING_FLAG(p_from_index);
  G_I_ROUNDING_FACTOR(p_to_index) := G_I_ROUNDING_FACTOR(p_from_index);
  G_I_QUALIFIERS_EXIST_FLAG(p_to_index) := G_I_QUALIFIERS_EXIST_FLAG(p_from_index);
  G_I_PRICING_ATTRS_EXIST_FLAG(p_to_index) := G_I_PRICING_ATTRS_EXIST_FLAG(p_from_index);
  G_I_PRICE_LIST_ID(p_to_index) := G_I_PRICE_LIST_ID(p_from_index);
  G_I_VALIDATED_FLAG(p_to_index) := G_I_VALIDATED_FLAG(p_from_index);
  G_I_PRICE_REQUEST_CODE(p_to_index) := G_I_PRICE_REQUEST_CODE(p_from_index);
  G_I_USAGE_PRICING_TYPE(p_to_index) := G_I_USAGE_PRICING_TYPE(p_from_index);
  G_I_LINE_CATEGORY(p_to_index) := G_I_LINE_CATEGORY(p_from_index);

  g_I_line_extras_tbl(p_to_index) := g_I_line_extras_tbl(p_from_index);

END move_line_row;

PROCEDURE move_attribute_row(
    p_from_index IN NUMBER,
    p_to_index NUMBER)
IS
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
BEGIN
  fte_freight_pricing_util.print_msg(l_log_level,'move qp input attribute from '||p_from_index ||' to '||p_to_index);
  G_I_A_LINE_INDEX(p_to_index) := G_I_A_LINE_INDEX(p_from_index);
  G_I_A_LINE_DETAIL_INDEX(p_to_index) := G_I_A_LINE_DETAIL_INDEX(p_from_index);
  G_I_A_ATTRIBUTE_LEVEL(p_to_index) := G_I_A_ATTRIBUTE_LEVEL(p_from_index);
  G_I_A_ATTRIBUTE_TYPE(p_to_index) := G_I_A_ATTRIBUTE_TYPE(p_from_index);
  G_I_A_LIST_HEADER_ID(p_to_index) := G_I_A_LIST_HEADER_ID(p_from_index);
  G_I_A_LIST_LINE_ID(p_to_index) := G_I_A_LIST_LINE_ID(p_from_index);
  G_I_A_CONTEXT(p_to_index) := G_I_A_CONTEXT(p_from_index);
  G_I_A_ATTRIBUTE(p_to_index) := G_I_A_ATTRIBUTE(p_from_index);
  G_I_A_VALUE_FROM(p_to_index) := G_I_A_VALUE_FROM(p_from_index);
  G_I_A_SETUP_VALUE_FROM(p_to_index) := G_I_A_SETUP_VALUE_FROM(p_from_index);
  G_I_A_VALUE_TO(p_to_index) := G_I_A_VALUE_TO(p_from_index);
  G_I_A_SETUP_VALUE_TO(p_to_index) := G_I_A_SETUP_VALUE_TO(p_from_index);
  G_I_A_GROUPING_NUMBER(p_to_index) := G_I_A_GROUPING_NUMBER(p_from_index);
  G_I_A_NO_QUALIFIERS_IN_GRP(p_to_index) := G_I_A_NO_QUALIFIERS_IN_GRP(p_from_index);
  G_I_A_COMPARISON_OPERATOR_TYPE(p_to_index) := G_I_A_COMPARISON_OPERATOR_TYPE(p_from_index);
  G_I_A_VALIDATED_FLAG(p_to_index) := G_I_A_VALIDATED_FLAG(p_from_index);
  G_I_A_APPLIED_FLAG(p_to_index) := G_I_A_APPLIED_FLAG(p_from_index);
  G_I_A_PRICING_STATUS_CODE(p_to_index) := G_I_A_PRICING_STATUS_CODE(p_from_index);
  G_I_A_PRICING_STATUS_TEXT(p_to_index) := G_I_A_PRICING_STATUS_TEXT(p_from_index);
  G_I_A_QUALIFIER_PRECEDENCE(p_to_index) := G_I_A_QUALIFIER_PRECEDENCE(p_from_index);
  G_I_A_DATATYPE(p_to_index) := G_I_A_DATATYPE(p_from_index);
  G_I_A_PRICING_ATTR_FLAG(p_to_index) := G_I_A_PRICING_ATTR_FLAG(p_from_index);
  G_I_A_QUALIFIER_TYPE(p_to_index) := G_I_A_QUALIFIER_TYPE(p_from_index);
  G_I_A_PRODUCT_UOM_CODE(p_to_index) := G_I_A_PRODUCT_UOM_CODE(p_from_index);
  G_I_A_EXCLUDER_FLAG(p_to_index) := G_I_A_EXCLUDER_FLAG(p_from_index);
  G_I_A_PRICING_PHASE_ID(p_to_index) := G_I_A_PRICING_PHASE_ID(p_from_index);
  G_I_A_INCOMPATABILITY_GRP_CODE(p_to_index) := G_I_A_INCOMPATABILITY_GRP_CODE(p_from_index);
  G_I_A_LINE_DETAIL_TYPE_CODE(p_to_index) := G_I_A_LINE_DETAIL_TYPE_CODE(p_from_index);
  G_I_A_MODIFIER_LEVEL_CODE(p_to_index) := G_I_A_MODIFIER_LEVEL_CODE(p_from_index);
  G_I_A_PRIMARY_UOM_FLAG(p_to_index) := G_I_A_PRIMARY_UOM_FLAG(p_from_index);

END move_attribute_row;

-- removes gaps in qp input lines and attribtues
-- because qp bulk inserts requrie that elements in the input tables has to be consecutive
PROCEDURE remove_gaps(
  x_return_status OUT NOCOPY  VARCHAR2)
IS
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'remove_gaps';

   l_count NUMBER;
   l_first_index NUMBER;
   l_old_last_index NUMBER;
   i NUMBER;
   l_current_index NUMBER;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

    -- work on the lines first
    -- then work on the line attribtues

    l_first_index := G_I_LINE_INDEX.first;
    l_old_last_index := G_I_LINE_INDEX.last;
    l_count := G_I_LINE_INDEX.count;

    if (l_count = 0) then
      fte_freight_pricing_util.print_msg(l_log_level,'qp input line table is empty, do nothing');
    else
      if (l_count = (l_old_last_index - l_first_index + 1)) then
        fte_freight_pricing_util.print_msg(l_log_level,'qp input line table no gaps, do nothing');
      else

  	l_current_index := l_first_index;
    	for i in l_first_index..l_old_last_index loop
      	  if (G_I_LINE_INDEX.exists(i)) then
   	    if (i > l_current_index) then
	      move_line_row(p_from_index =>i, p_to_index =>l_current_index);
  	    end if;
	    l_current_index := l_current_index + 1;
          end if;
    	end loop;

    	for i in l_current_index..l_old_last_index loop
      	  if (G_I_LINE_INDEX.exists(i)) then
	    G_I_LINE_INDEX.delete(i);
            g_I_line_extras_tbl.delete(i);
      	  end if;
    	end loop;

      end if;
    end if;

    l_first_index := G_I_A_LINE_INDEX.first;
    l_old_last_index := G_I_A_LINE_INDEX.last;
    l_count := G_I_A_LINE_INDEX.count;

    if (l_count = 0) then
      fte_freight_pricing_util.print_msg(l_log_level,'qp input attribute table is empty, do nothing');
    else
      if (l_count = (l_old_last_index - l_first_index + 1)) then
        fte_freight_pricing_util.print_msg(l_log_level,'qp input attribute table no gaps, do nothing');
      else

    	l_current_index := l_first_index;
    	for i in l_first_index..l_old_last_index loop
      	  if (G_I_A_LINE_INDEX.exists(i)) then
	    if (i > l_current_index) then
	      move_attribute_row(p_from_index =>i, p_to_index =>l_current_index);
	    end if;
	    l_current_index := l_current_index + 1;
      	  end if;
    	end loop;

    	for i in l_current_index..l_old_last_index loop
      	  if (G_I_A_LINE_INDEX.exists(i)) then
	    G_I_A_LINE_INDEX.delete(i);
      	  end if;
    	end loop;

      end if;
    end if;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END remove_gaps;

-- copies input lines of one event to the input of another event
-- the base prices from the source event are carried over to the input of the target event
-- currently it will copy only from event 1 to event 2
PROCEDURE prepare_next_event_request ( x_return_status    OUT NOCOPY  VARCHAR2)
IS
  i                    NUMBER;
  j                    NUMBER;
  l_return_status      VARCHAR2(1);
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'prepare_next_event_request';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,'prepare_next_event_request');

  --modify event 1 input based on event 1 output to make it event 2 input

  g_I_control_rec.pricing_event := g_engine_defaults_tab(G_CHARGE_EVENT_NUM).pricing_event_code;

  i := g_I_line_index.FIRST;
  IF (i IS NOT NULL) THEN
  LOOP
    fte_freight_pricing_util.print_msg(l_log_level,'copy line from O to I where i = '||i);

    --copy over unit price and other fields from output
    g_I_request_type_code(i) := g_engine_defaults_tab(G_CHARGE_EVENT_NUM).request_type_code ;
    g_I_line_type_code(i)    := g_engine_defaults_tab(G_CHARGE_EVENT_NUM).line_type_code;
    g_I_price_flag(i)        := g_engine_defaults_tab(G_CHARGE_EVENT_NUM).price_flag;
    g_I_unit_price(i)        := g_O_line_tbl(i).unit_price;
    g_I_priced_quantity(i)   := g_O_line_tbl(i).priced_quantity;
    g_I_priced_uom_code(i)   := g_O_line_tbl(i).priced_uom_code;

    EXIT WHEN i >= g_I_line_index.LAST;
    i := g_I_line_index.NEXT(i);
  END LOOP;
  END IF;

  remove_gaps(x_return_status => l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      and l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    raise FTE_FREIGHT_PRICING_UTIL.g_remove_gaps_failed;
  END IF;

  fte_freight_pricing_util.unset_method(l_log_level,'prepare_next_event_request');
EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_remove_gaps_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'remove_gaps_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'prepare_next_event_request');

END prepare_next_event_request;


 -- we need procedures to :
 --        create the control record
 --        create line record
 --        create attribute record
 --        create qualifier record

 -- creates a control record based on defaults and adds it to the input table for the event
 PROCEDURE create_control_record (p_event_num  IN NUMBER,
                                  x_return_status  OUT NOCOPY  VARCHAR2) IS
 l_control_rec     QP_PREQ_GRP.CONTROL_RECORD_TYPE;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 l_method_name VARCHAR2(50) := 'create_control_record';
 BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'create_control_record');

     l_control_rec.pricing_event := g_engine_defaults_tab(p_event_num).pricing_event_code;
     l_control_rec.calculate_flag := 'Y';
     l_control_rec.simulation_flag := 'N';
     l_control_rec.rounding_flag := 'N';
     l_control_rec.temp_table_insert_flag := 'N';
     -- l_control_rec.request_type_code := 'FTE';
     l_control_rec.request_type_code := g_engine_defaults_tab(p_event_num).request_type_code;

     g_I_control_rec := l_control_rec;

 fte_freight_pricing_util.unset_method(l_log_level,'create_control_record');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'create_control_record');
 END create_control_record;

 -- creates a single line record and adds it to the event input table
 PROCEDURE  create_line_record (p_pricing_control_rec       IN  fte_freight_pricing.pricing_control_input_rec_type,
                                p_pricing_engine_input_rec  IN  fte_freight_pricing.pricing_engine_input_rec_type,
                                x_return_status             OUT NOCOPY  VARCHAR2) IS

 line_extras                 line_extras_rec;
 l_event_num                 NUMBER;
  i NUMBER;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
 l_method_name VARCHAR2(50) := 'create_line_record';
 BEGIN

         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         fte_freight_pricing_util.reset_dbg_vars;
         fte_freight_pricing_util.set_method(l_log_level,'create_line_record');

         l_event_num := p_pricing_control_rec.pricing_event_num;

	 i := p_pricing_engine_input_rec.input_index;

         g_I_request_type_code(i) := g_engine_defaults_tab(l_event_num).request_type_code;
         g_I_line_id(i) := p_pricing_control_rec.lane_id;
         g_I_line_index(i) := to_char(p_pricing_engine_input_rec.input_index);
         g_I_line_type_code(i) := g_engine_defaults_tab(l_event_num).line_type_code;
         g_I_pricing_effective_date(i) := nvl(fte_freight_pricing.g_effectivity_dates.date_from,sysdate);
         g_I_active_date_first(i) := nvl(fte_freight_pricing.g_effectivity_dates.date_from,sysdate);
         g_I_active_date_second(i) := nvl(fte_freight_pricing.g_effectivity_dates.date_to,sysdate);
         g_I_line_quantity(i) := to_char(p_pricing_engine_input_rec.line_quantity);
         g_I_line_uom_code(i) := p_pricing_engine_input_rec.line_uom;
         g_I_currency_code(i) := NVL(p_pricing_control_rec.currency_code,'USD'); --nvl for DEBUG ONLY
         g_I_price_flag(i) := g_engine_defaults_tab(l_event_num).price_flag;

  --following are default values for price request line
  G_I_ACTIVE_DATE_FIRST_TYPE(i) := 'NO TYPE';
  G_I_ACTIVE_DATE_SECOND_TYPE(i) := 'NO TYPE';
  G_I_PRICED_QUANTITY(i) := null;
  G_I_PRICED_UOM_CODE(i) := null;
  G_I_UNIT_PRICE(i) := null;
  G_I_PERCENT_PRICE(i) := null;
  G_I_UOM_QUANTITY(i) := null;
  G_I_ADJUSTED_UNIT_PRICE(i) := null;
  G_I_UPD_ADJUSTED_UNIT_PRICE(i) := null;
  G_I_PROCESSED_FLAG(i) := null;
  G_I_PROCESSING_ORDER(i) := null;
  G_I_PRICING_STATUS_CODE(i) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
  G_I_PRICING_STATUS_TEXT(i) := null;
  G_I_ROUNDING_FLAG(i) := null;
  G_I_ROUNDING_FACTOR(i) := null;
  G_I_QUALIFIERS_EXIST_FLAG(i) := 'N';
  G_I_PRICING_ATTRS_EXIST_FLAG(i) := 'N';
  G_I_PRICE_LIST_ID(i) := -9999;
  G_I_VALIDATED_FLAG(i) := 'N';
  G_I_PRICE_REQUEST_CODE(i) := null;
  G_I_USAGE_PRICING_TYPE(i) := QP_PREQ_GRP.G_REGULAR_USAGE_TYPE;
  G_I_LINE_CATEGORY(i) := null;

         line_extras.line_index       := p_pricing_engine_input_rec.input_index ;
         line_extras.input_set_number := p_pricing_engine_input_rec.input_set_number;
         line_extras.category_id      := p_pricing_engine_input_rec.category_id;  -- note this will have value only for WITHIN

         g_I_line_extras_tbl(i) := line_extras;

 fte_freight_pricing_util.unset_method(l_log_level,'create_line_record');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'create_line_record');
 END create_line_record;

 -- creates a single qualifier record and adds it to the appropriate i/p table
 PROCEDURE  create_qual_record (p_event_num             IN  NUMBER,
                                p_qual_rec              IN  qualifier_rec_type,
                                x_return_status         OUT NOCOPY  VARCHAR2) IS

     j                           NUMBER;

      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'create_qual_record';
 BEGIN

         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         fte_freight_pricing_util.reset_dbg_vars;
         -- fte_freight_pricing_util.set_method(l_log_level,'create_qual_record');
         -- fte_freight_pricing_util.print_msg(l_log_level,'p_qual_rec.input_index='||p_qual_rec.input_index);
         -- fte_freight_pricing_util.print_msg(l_log_level,'p_qual_rec.qualifier_name='||p_qual_rec.qualifier_name);

	 j := g_I_A_LINE_INDEX.COUNT + 1;
         -- fte_freight_pricing_util.print_msg(l_log_level,'p_qual_rec.j='||j);

         g_I_A_LINE_INDEX(j) := p_qual_rec.input_index;
         IF (p_qual_rec.qualifier_name = 'PRICELIST') THEN
             g_I_A_CONTEXT(j) :='MODLIST';
             g_I_A_ATTRIBUTE(j) :='QUALIFIER_ATTRIBUTE4';
         ELSIF (p_qual_rec.qualifier_name = 'SUPPLIER') THEN
             g_I_A_CONTEXT(j) :='PARTY';
             g_I_A_ATTRIBUTE(j) :='QUALIFIER_ATTRIBUTE1';
         ELSIF (p_qual_rec.qualifier_name = 'MODE_OF_TRANSPORT') THEN
             g_I_A_CONTEXT(j) :=fte_rtg_globals.G_QX_MODE_OF_TRANSPORT;
             g_I_A_ATTRIBUTE(j) :=fte_rtg_globals.G_Q_MODE_OF_TRANSPORT;
         ELSIF (p_qual_rec.qualifier_name = 'SERVICE_TYPE') THEN
             g_I_A_CONTEXT(j) :=fte_rtg_globals.G_QX_SERVICE_TYPE;
             g_I_A_ATTRIBUTE(j) :=fte_rtg_globals.G_Q_SERVICE_TYPE;
         END IF;
         g_I_A_VALUE_FROM(j) := p_qual_rec.qualifier_value;
         g_I_A_COMPARISON_OPERATOR_TYPE(j) := p_qual_rec.operator;

         fte_freight_pricing_util.print_msg(l_log_level,
             'inpidx='||p_qual_rec.input_index||' j='||j||'name='||p_qual_rec.qualifier_name||' qualval='||p_qual_rec.qualifier_value);

    -- default values in attributes
    G_I_A_COMPARISON_OPERATOR_TYPE(j) := '=';
    G_I_A_VALIDATED_FLAG(j) :='N';
    G_I_A_LINE_DETAIL_INDEX(j) := null;
    G_I_A_ATTRIBUTE_LEVEL(j) := QP_PREQ_GRP.G_LINE_LEVEL;
    G_I_A_LIST_HEADER_ID(j) := null;
    G_I_A_LIST_LINE_ID(j) := null;
    G_I_A_SETUP_VALUE_FROM(j) := null;
    G_I_A_VALUE_TO(j) := null;
    G_I_A_SETUP_VALUE_TO(j) := null;
    G_I_A_GROUPING_NUMBER(j) := null;
    G_I_A_NO_QUALIFIERS_IN_GRP(j) := null;
    G_I_A_APPLIED_FLAG(j) := null;
    G_I_A_PRICING_STATUS_CODE(j) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
    G_I_A_PRICING_STATUS_TEXT(j) := null;
    G_I_A_QUALIFIER_PRECEDENCE(j) := null;
    G_I_A_DATATYPE(j) := null;
    G_I_A_PRICING_ATTR_FLAG(j) := null;
    -- default values in qualifiers
    G_I_A_VALIDATED_FLAG(j) :='Y';
    G_I_A_LINE_DETAIL_INDEX(j) := null;
    G_I_A_ATTRIBUTE_LEVEL(j) := QP_PREQ_GRP.G_LINE_LEVEL;
    G_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
    G_I_A_LIST_HEADER_ID(j) := null;
    G_I_A_LIST_LINE_ID(j) := null;
    G_I_A_SETUP_VALUE_FROM(j) := null;
    G_I_A_VALUE_TO(j) := null;
    G_I_A_SETUP_VALUE_TO(j) := null;
    G_I_A_GROUPING_NUMBER(j) := null;
    G_I_A_NO_QUALIFIERS_IN_GRP(j) := null;
    G_I_A_APPLIED_FLAG(j) := null;
    G_I_A_PRICING_STATUS_CODE(j) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
    G_I_A_PRICING_STATUS_TEXT(j) := null;
    G_I_A_QUALIFIER_PRECEDENCE(j) := null;
    G_I_A_DATATYPE(j) := null;
    G_I_A_PRICING_ATTR_FLAG(j) := null;
    G_I_A_QUALIFIER_TYPE(j) := null;
    G_I_A_PRODUCT_UOM_CODE(j) := null;
    G_I_A_EXCLUDER_FLAG(j) := null;
    G_I_A_PRICING_PHASE_ID(j) := null;
    G_I_A_INCOMPATABILITY_GRP_CODE(j) := null;
    G_I_A_LINE_DETAIL_TYPE_CODE(j) := null;
    G_I_A_MODIFIER_LEVEL_CODE(j) := null;
    G_I_A_PRIMARY_UOM_FLAG(j) := null;

 -- fte_freight_pricing_util.unset_method(l_log_level,'create_qual_record');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'create_qual_record');
 END create_qual_record;

-- Volume type of qp pricing attribute is passed to QP in attribute_value_from
-- column which is varchar2, to avoid converting errors in QP, trunc it to
-- 20 positions after the decimal point

FUNCTION get_qp_volume_string(
        p_string1	IN VARCHAR2) RETURN VARCHAR2
IS
  k NUMBER;
  l_limit CONSTANT NUMBER := 20;
BEGIN

  IF p_string1 is null THEN
    RETURN '';
  END IF;

  k := instr(p_string1, '.', 1,1);
  IF k > 0 THEN
    RETURN substr(p_string1, 1, k + l_limit);
  ELSE
    RETURN p_string1;
  END IF;

END get_qp_volume_string;

 -- creates a single attribute record and adds it to the appropriate i/p table
 PROCEDURE  create_attr_record         (p_event_num             IN  NUMBER,
                                        p_attr_rec              IN  fte_freight_pricing.pricing_attribute_rec_type,
                                        x_return_status         OUT NOCOPY  VARCHAR2) IS

     j                            NUMBER;
	k NUMBER;

      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'create_attr_record';
 BEGIN

         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         fte_freight_pricing_util.reset_dbg_vars;
         -- fte_freight_pricing_util.set_method(l_log_level,'create_attr_record');

	 j := g_I_A_LINE_INDEX.COUNT + 1;

         g_I_A_LINE_INDEX(j) := p_attr_rec.input_index;

         IF (p_attr_rec.attribute_name = 'CONTAINER_TYPE') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE2';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'CATEGORY_ID') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE1';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'SERVICE_TYPE') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE3';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'ADDITIONAL_CHARGE') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE4';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'ORIGIN_ZONE') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE7';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'DESTINATION_ZONE') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE8';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TOTAL_SHIPMENT_QUANTITY') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE9';
               g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TOTAL_ITEM_QUANTITY') THEN
               g_I_A_CONTEXT(j) :='VOLUME'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE20';
		-- trunc it to 10 positions after the decimal point
		-- in order to avoid converting error in QP
		--k := instr(p_attr_rec.attribute_value, '.', 1, 1);
		--if (k > 0) then
		  --g_I_A_VALUE_FROM(j)  := substr(p_attr_rec.attribute_value,1,k+10);
		--else
		  --g_I_A_VALUE_FROM(j)  := p_attr_rec.attribute_value;
		--end if;
		g_I_A_VALUE_FROM(j)  := get_qp_volume_string(p_attr_rec.attribute_value);
         ELSIF (p_attr_rec.attribute_name = 'ITEM_ALL') THEN
               g_I_A_CONTEXT(j) :='ITEM'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRODUCT_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE3';
               g_I_A_VALUE_FROM(j)  := 'ALL';
         ELSIF (p_attr_rec.attribute_name = 'MULTIPIECE_FLAG') THEN
               g_I_A_CONTEXT(j) :='LOGISTICS'; --
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) :='PRICING_ATTRIBUTE10';
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_RATE_BASIS') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_RATE_BASIS;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_RATE_BASIS;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_RATE_TYPE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_RATE_TYPE;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_RATE_TYPE;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DISTANCE_TYPE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DISTANCE_TYPE;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DISTANCE_TYPE;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         -- ELSIF (p_attr_rec.attribute_name = 'SERVICE_TYPE') THEN
         --       g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_SERVICE_TYPE;
         --       g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
         --       g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_SERVICE_TYPE;
         --       g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'VEHICLE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_VEHICLE;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_VEHICLE;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_ORIGIN_ZONE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_ORIGIN_ZONE;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_ORIGIN_ZONE;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DESTINATION_ZONE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_DESTINATION_ZONE;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_DESTINATION_ZONE;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_NUM_WEEKEND_LAYOVERS') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_NUM_WEEKEND_LAYOVERS;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_NUM_WEEKEND_LAYOVERS;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'LOADING_PROTOCOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_LOADING_PROTOCOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_LOADING_PROTOCOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_CM_DISCOUNT_FLG') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_CM_DISCOUNT_FLG;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_CM_DISCOUNT_FLG;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DEADHEAD_RT_VAR') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DEADHEAD_RT_VAR;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DEADHEAD_RT_VAR;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_NUM_STOPS') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_NUM_STOPS;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_NUM_STOPS;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_CHARGED_OUT_RT_DISTANCE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_CHARGED_OUT_RT_DIST;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_CHARGED_OUT_RT_DIST;
               --g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
		g_I_A_VALUE_FROM(j)  := get_qp_volume_string(p_attr_rec.attribute_value);
         ELSIF (p_attr_rec.attribute_name = 'TL_HANDLING_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_HANDLING_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_HANDLING_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_HANDLING_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_HANDLING_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_HANDLING_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_PICKUP_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_PICKUP_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_PICKUP_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_PICKUP_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_PICKUP_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_PICKUP_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_PICKUP_CONTAINER') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_PICKUP_CONTAINER;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_PICKUP_CONTAINER;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_PICKUP_PALLET') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_PICKUP_PALLET;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_PICKUP_PALLET;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DROPOFF_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DROPOFF_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DROPOFF_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DROPOFF_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DROPOFF_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DROPOFF_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DROPOFF_CONTAINER') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DROPOFF_CONTAINER;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DROPOFF_CONTAINER;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_DROPOFF_PALLET') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_DROPOFF_PALLET;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_DROPOFF_PALLET;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_NUM_WEEKDAY_LAYOVERS') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_NUM_WEEKDAY_LAYOVERS;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_NUM_WEEKDAY_LAYOVERS;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_WEEKEND_LAYOVER_MILEAGE') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_WEEKEND_LAYOVER_MIL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_WEEKEND_LAYOVER_MIL;
               --g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
		g_I_A_VALUE_FROM(j)  := get_qp_volume_string(p_attr_rec.attribute_value);
         ELSIF (p_attr_rec.attribute_name = 'FAC_PICKUP_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_PICKUP_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_PICKUP_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_PICKUP_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_PICKUP_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_PICKUP_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_PICKUP_CONTAINER') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_PICKUP_CONTAINER;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_PICKUP_CONTAINER;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_PICKUP_PALLET') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_PICKUP_PALLET;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_PICKUP_PALLET;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_DROPOFF_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_DROPOFF_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_DROPOFF_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_DROPOFF_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_DROPOFF_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_DROPOFF_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_DROPOFF_CONTAINER') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_DROPOFF_CONTAINER;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_DROPOFF_CONTAINER;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_DROPOFF_PALLET') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_DROPOFF_PALLET;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_DROPOFF_PALLET;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_HANDLING_WT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_HANDLING_WT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_HANDLING_WT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_HANDLING_VOL') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_HANDLING_VOL;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_HANDLING_VOL;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_HANDLING_CONTAINER') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_HANDLING_CONTAINER;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_HANDLING_CONTAINER;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'FAC_HANDLING_PALLET') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_FAC_HANDLING_PALLET;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_FAC_HANDLING_PALLET;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_STOP_LOADING_ACT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_STOP_LOADING_ACT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_STOP_LOADING_ACT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_STOP_UNLOADING_ACT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_STOP_UNLOADING_ACT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_STOP_UNLOADING_ACT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSIF (p_attr_rec.attribute_name = 'TL_HANDLING_ACT') THEN
               g_I_A_CONTEXT(j) := fte_rtg_globals.G_AX_TL_HANDLING_ACT;
               g_I_A_ATTRIBUTE_TYPE(j) := QP_PREQ_GRP.G_PRICING_TYPE;
               g_I_A_ATTRIBUTE(j) := fte_rtg_globals.G_A_TL_HANDLING_ACT;
               g_I_A_VALUE_FROM(j)  :=  p_attr_rec.attribute_value;
         ELSE
               null;
               fte_freight_pricing_util.print_msg(l_log_level,'Big problemo!');
         END IF;

         fte_freight_pricing_util.print_msg(l_log_level,
             'inpidx='||p_attr_rec.input_index||' j='||j||' name='||p_attr_rec.attribute_name||' attrval='||p_attr_rec.attribute_value);

    -- default values in attributes
    G_I_A_COMPARISON_OPERATOR_TYPE(j) := '=';
    G_I_A_VALIDATED_FLAG(j) :='N';
    G_I_A_LINE_DETAIL_INDEX(j) := null;
    G_I_A_ATTRIBUTE_LEVEL(j) := QP_PREQ_GRP.G_LINE_LEVEL;
    G_I_A_LIST_HEADER_ID(j) := null;
    G_I_A_LIST_LINE_ID(j) := null;
    G_I_A_SETUP_VALUE_FROM(j) := null;
    G_I_A_VALUE_TO(j) := null;
    G_I_A_SETUP_VALUE_TO(j) := null;
    G_I_A_GROUPING_NUMBER(j) := null;
    G_I_A_NO_QUALIFIERS_IN_GRP(j) := null;
    G_I_A_APPLIED_FLAG(j) := null;
    G_I_A_PRICING_STATUS_CODE(j) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
    G_I_A_PRICING_STATUS_TEXT(j) := null;
    G_I_A_QUALIFIER_PRECEDENCE(j) := null;
    G_I_A_DATATYPE(j) := null;
    G_I_A_PRICING_ATTR_FLAG(j) := null;
    G_I_A_QUALIFIER_TYPE(j) := null;
    G_I_A_PRODUCT_UOM_CODE(j) := null;
    G_I_A_EXCLUDER_FLAG(j) := null;
    G_I_A_PRICING_PHASE_ID(j) := null;
    G_I_A_INCOMPATABILITY_GRP_CODE(j) := null;
    G_I_A_LINE_DETAIL_TYPE_CODE(j) := null;
    G_I_A_MODIFIER_LEVEL_CODE(j) := null;
    G_I_A_PRIMARY_UOM_FLAG(j) := null;

 -- fte_freight_pricing_util.unset_method(l_log_level,'create_attr_record');
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'create_attr_record');
 END create_attr_record;


-- This procedure is called to create pricing attributes per line rec from the input attr rows
PROCEDURE prepare_qp_line_attributes (
        p_event_num               IN     NUMBER,
        p_input_index             IN     NUMBER,
        p_attr_rows               IN     fte_freight_pricing.pricing_attribute_tab_type,
        x_return_status           OUT NOCOPY     VARCHAR2 )
IS
       i                   NUMBER;
       l_return_status     VARCHAR2(30);
       l_pricing_attr_rec  fte_freight_pricing.pricing_attribute_rec_type;
       j                   NUMBER;
        l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
       l_method_name VARCHAR2(50) := 'prepare_qp_line_attributes';
 BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'prepare_qp_line_attributes');

      i := p_attr_rows.FIRST;
      IF (i IS NOT NULL) THEN
      LOOP
         IF (p_attr_rows(i).input_index = p_input_index ) THEN
               create_attr_record (     p_event_num              => p_event_num,
                                        p_attr_rec               => p_attr_rows(i),
                                        x_return_status          => l_return_status);

           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after create_attr_record -1 ');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FTE_FREIGHT_PRICING_UTIL.g_create_attribute_failed;
                 END IF;
           END IF;

         END IF;
      EXIT WHEN i = p_attr_rows.LAST;
      i := p_attr_rows.NEXT(i);
      END LOOP;
      END IF;

      -- add other default attributes
      l_pricing_attr_rec.attribute_index  := p_attr_rows(p_attr_rows.LAST).attribute_index + 1;
      l_pricing_attr_rec.input_index      := p_input_index;
      l_pricing_attr_rec.attribute_name   := 'ITEM_ALL';
      l_pricing_attr_rec.attribute_value  := 'ALL';
      create_attr_record (     p_event_num              => p_event_num,
                               p_attr_rec               => l_pricing_attr_rec,
                               x_return_status          => l_return_status);

      FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after create_attr_record -2 ');
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FTE_FREIGHT_PRICING_UTIL.g_create_attribute_failed;
              END IF;
      END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_attributes');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_create_attribute_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'create_attribute_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_attributes');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_attributes');

END prepare_qp_line_attributes;

PROCEDURE prepare_qp_line_qualifiers (p_event_num            IN     NUMBER,
                                      p_pricing_control_rec     IN     fte_freight_pricing.pricing_control_input_rec_type,
                                      p_input_index             IN     NUMBER,
                                      x_return_status           OUT NOCOPY     VARCHAR2 )
IS
      l_qual_rec       qualifier_rec_type;
      l_return_status  VARCHAR2(1);
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'prepare_qp_line_qualifiers';
 BEGIN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
         fte_freight_pricing_util.reset_dbg_vars;
         fte_freight_pricing_util.set_method(l_log_level,'prepare_qp_line_qualifiers');

         l_qual_rec.qualifier_index      := 1;
         l_qual_rec.input_index          := p_input_index;
         l_qual_rec.qualifier_name       :='PRICELIST';
         l_qual_rec.qualifier_value      := to_char(p_pricing_control_rec.price_list_id);
          create_qual_record (p_event_num            => p_event_num,
                              p_qual_rec             => l_qual_rec,
                              x_return_status        => l_return_status);

           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after create_qual_record -1 ');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FTE_FREIGHT_PRICING_UTIL.g_create_qual_record_failed;
                 END IF;
           END IF;

         l_qual_rec.qualifier_index      := 2;
         l_qual_rec.qualifier_name       :='SUPPLIER';
         l_qual_rec.qualifier_value      := to_char(p_pricing_control_rec.party_id);

          FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'===>p_pricing_control_rec.party_id = '||p_pricing_control_rec.party_id);
          create_qual_record (p_event_num            => p_event_num,
                              p_qual_rec             => l_qual_rec,
                              x_return_status        => l_return_status);

           FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after create_qual_record -2 ');
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FTE_FREIGHT_PRICING_UTIL.g_create_qual_record_failed;
                 END IF;
           END IF;

 fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_qualifiers');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_create_qual_record_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'create_qual_record_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_qualifiers');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'prepare_qp_line_qualifiers');

END  prepare_qp_line_qualifiers;

-- add one qp output line detail record into qp output line detail table
-- most of the qp output should come directly from qp
-- since qp cannot handle all of FTE pricing reqirement (e.g. deficit weight for LTL)
-- In some cases, FTE pricing engine needs to add some more records into
-- qp output tables
PROCEDURE add_qp_output_detail(
  p_line_index		IN NUMBER,
  p_list_line_type_code	IN VARCHAR2,
  p_charge_subtype_code IN VARCHAR2,
  p_adjustment_amount	IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
IS
   l_qp_output_detail_row   QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;
   l_line_detail_index NUMBER;
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'add_qp_output_detail';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  fte_freight_pricing_util.print_msg(l_log_level,'p_line_index:'||p_line_index);
  fte_freight_pricing_util.print_msg(l_log_level,'p_list_line_type_code:'||p_list_line_type_code);
  fte_freight_pricing_util.print_msg(l_log_level,'p_charge_subtype_code:'||p_charge_subtype_code);
  fte_freight_pricing_util.print_msg(l_log_level,'p_adjustment_amount:'||p_adjustment_amount);

  IF (g_O_line_detail_tbl.COUNT <= 0) THEN
    l_line_detail_index := 1;
  ELSE
    l_line_detail_index := g_O_line_detail_tbl.LAST + 1;
  END IF;

  l_qp_output_detail_row.line_detail_index    := l_line_detail_index;
  l_qp_output_detail_row.line_index           := p_line_index;
  l_qp_output_detail_row.list_line_type_code  := p_list_line_type_code;
  l_qp_output_detail_row.charge_subtype_code  := p_charge_subtype_code;
  l_qp_output_detail_row.adjustment_amount    := p_adjustment_amount;

  g_O_line_detail_tbl(l_line_detail_index) := l_qp_output_detail_row;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END add_qp_output_detail;

PROCEDURE check_qp_output_errors (x_return_status  OUT NOCOPY  VARCHAR2)
IS
  i  NUMBER :=0;
  l_error_flag BOOLEAN := false;
  l_category   VARCHAR2(30);
     l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'check_qp_output_errors';
 BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,'check_output_errors');

         i := g_O_line_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_O_line_tbl(i).status_code IN (
                  QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                  QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                  QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                  QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                  QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                  QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                  QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                  QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                  QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                  QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' LineIndex = '||i||' Status Code = '||g_O_line_tbl(i).status_code||' Text = '||g_O_line_tbl(i).status_text);
                 IF (g_O_line_tbl(i).status_code = 'IPL') THEN
                    raise fte_freight_pricing_util.g_not_on_pricelist;
                 END IF;
             END IF;
             IF (g_O_line_tbl(i).unit_price IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price is null');
	     -- ELSIF (g_O_line_tbl(i).unit_price <= 0) THEN
	     ELSIF (g_O_line_tbl(i).unit_price < 0) THEN         -- TL
                 l_error_flag := true;
                 -- fte_freight_pricing_util.print_msg(l_log_level,'Unit price non-positive');
                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price negative');
             END IF;
         EXIT WHEN i >= g_O_line_tbl.LAST;
             i := g_O_line_tbl.NEXT(i);
         END LOOP;
        END IF;

         i := g_O_line_detail_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_O_line_detail_tbl(i).adjustment_amount IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(l_log_level,'Adjustment amount is null');
             END IF;
         EXIT WHEN i >= g_O_line_detail_tbl.LAST;
             i := g_O_line_detail_tbl.NEXT(i);
         END LOOP;
        END IF;

     IF (l_error_flag) THEN
             raise FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed;
     END IF;

     fte_freight_pricing_util.unset_method(l_log_level,'check_output_errors');
    EXCEPTION
        WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Following item quantity not found on pricelist :');
           l_category := g_I_line_extras_tbl(i).category_id;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      Quantity = '||g_I_line_quantity(i)||' '||g_I_line_uom_code(i));
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      CategoryId = '||nvl(l_category,'Consolidated'));
           fte_freight_pricing_util.unset_method(l_log_level,'check_output_errors');
        WHEN fte_freight_pricing_util.g_qp_price_request_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'check_output_errors');
        WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'check_output_errors');

END check_qp_output_errors;

PROCEDURE check_tl_qp_output_errors (x_return_status  OUT NOCOPY  VARCHAR2)
IS
  i  NUMBER :=0;
  l_error_flag BOOLEAN := false;
  l_category   VARCHAR2(30);
  l_ipl_cnt    NUMBER := 0;
  l_line_cnt   NUMBER := 0;
     l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'check_tl_qp_output_errors';
 BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,'check_tl_qp_output_errors');

         i := g_O_line_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             l_line_cnt := l_line_cnt + 1;
             IF (g_O_line_tbl(i).status_code IN (
                  QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                  QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                  QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                  QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                  QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                  QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                  QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                  QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                  QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                  QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' LineIndex = '||i||' Status Code = '||g_O_line_tbl(i).status_code||' Text = '||g_O_line_tbl(i).status_text);
                 IF (g_O_line_tbl(i).status_code = 'IPL') THEN
                     l_ipl_cnt := l_ipl_cnt + 1;
                     g_O_line_tbl(i).unit_price := 0;
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,
                       'Following item quantity not found on pricelist :');
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,
                       '      Quantity = '||g_I_line_quantity(i)||' '||g_I_line_uom_code(i));
                 ELSE
                     l_error_flag := true;
                 END IF;
             END IF;
             IF (g_O_line_tbl(i).unit_price IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price is null');
	     -- ELSIF (g_O_line_tbl(i).unit_price <= 0) THEN
	     ELSIF (g_O_line_tbl(i).unit_price < 0) THEN         -- TL
                 l_error_flag := true;
                 -- fte_freight_pricing_util.print_msg(l_log_level,'Unit price non-positive');
                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price negative');
             END IF;
         EXIT WHEN i >= g_O_line_tbl.LAST;
             i := g_O_line_tbl.NEXT(i);
         END LOOP;
        END IF;

        IF (l_ipl_cnt >= l_line_cnt) THEN
            -- probably big failure - not good
            fte_freight_pricing_util.print_msg(l_log_level,'l_ipl_cnt >= l_line_cnt');
            raise fte_freight_pricing_util.g_not_on_pricelist;
        ELSIF (l_ipl_cnt > 0) THEN
            -- probably ok
            fte_freight_pricing_util.print_msg(l_log_level,'WARNING: SOME LINES HAD IPL !!!');
        END IF;

         i := g_O_line_detail_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_O_line_detail_tbl(i).adjustment_amount IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(l_log_level,'Adjustment amount is null');
             END IF;
         EXIT WHEN i >= g_O_line_detail_tbl.LAST;
             i := g_O_line_detail_tbl.NEXT(i);
         END LOOP;
        END IF;

     IF (l_error_flag) THEN
             raise FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed;
     END IF;

     fte_freight_pricing_util.unset_method(l_log_level,'check_tl_qp_output_errors');
    EXCEPTION
        WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Following item quantity not found on pricelist :');
           l_category := g_I_line_extras_tbl(i).category_id;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      Quantity = '||g_I_line_quantity(i)||' '||g_I_line_uom_code(i));
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      CategoryId = '||nvl(l_category,'Consolidated'));
           fte_freight_pricing_util.unset_method(l_log_level,'check_tl_qp_output_errors');
        WHEN fte_freight_pricing_util.g_qp_price_request_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed');
           fte_freight_pricing_util.unset_method(l_log_level,'check_tl_qp_output_errors');
        WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'check_tl_qp_output_errors');

END check_tl_qp_output_errors;

PROCEDURE check_parcel_output_errors (p_event_num      IN NUMBER,
                                      x_return_code    OUT NOCOPY  NUMBER,
                                      x_return_status  OUT NOCOPY  VARCHAR2)
IS
  i  NUMBER :=0;
  l_error_flag BOOLEAN := false;
  l_category   VARCHAR2(30);
  l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'check_parcel_output_errors';
  l_mp_line_cnt   NUMBER := 0;
  l_mp_ipl_cnt    NUMBER := 0;
  l_sp_ipl_cnt    NUMBER := 0;
 BEGIN
    -- loop through output
    -- If error (any error type) is from set 1
          -- if error = ipl, sp_ipl_cnt ++;
          -- if error any other than ipl, then throw an error.
    -- If error is from set 2 :
          -- if error = IPL, iplCount++
          -- if error any other than IPL, then throw error
    -- If (iplCount from set 2) = (count of lines in set 2), then this is NOT an error. This condition
    -- probably means that the total quantity does not fall in any of the defined breaks.
    -- Else throw an error
    -- x_return_code =  G_PAR_NO_MP_PRICE means multi-piece (hundredwt) prices did not exist

    -- set 1 is single piece lines
    -- set 2 is multi piece lines

    -- if (set 2 result all successful)
    --   set 2 result valid;
    -- else if (set 2 result all ipl)
    --   set 2 result invalid; -- but not exception;
    -- else -- set 2 parcial ipl
    --   exception;
    -- if (set 1 result all successfull)
    --   set 1 result valid;
    -- else -- set 1 all or parcial ipl
    --   set 1 result invalid; -- but not exception;

    -- if (set 1 result valid) and (set 2 result valid)
    --    x_return_status := SUCCESS;
    --    x_return_code   := 0;
    -- else if (set 1 result valid) and (set 2 result invalid)
    --    x_return_status := SUCCESS;
    --    x_return_code   := G_PAR_NO_MP_PRICE;
    -- else if (set 1 result invalid) and (set 2 result valid)
    --    x_return_status := SUCCESS;
    --    x_return_code   := G_PAR_NO_SP_PRICE;
    -- else --(set 1 result invalid) and (set 2 result invalid)
    --    x_return_status := ERROR;
    --    x_return_code   := 0;


     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     x_return_code   := 0;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);

     IF (p_event_num = G_LINE_EVENT_NUM ) THEN
         i := g_O_line_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_I_line_extras_tbl(i).input_set_number = 1) THEN
                  IF (g_O_line_tbl(i).status_code IN (
                       --QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                       QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                       QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                       QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                       QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                       QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                       QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                       QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                       QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                       QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                       QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                       QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                       QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Event = '||p_event_num||' LineIndex = '||i||' Status Code = '||g_O_line_tbl(i).status_code||' Text = '||g_O_line_tbl(i).status_text);
                  END IF;
                  IF (g_O_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST) THEN
                  --IF (g_O_line_tbl(i).status_code = 'IPL') THEN
                         l_sp_ipl_cnt := l_sp_ipl_cnt + 1;
                         --raise fte_freight_pricing_util.g_not_on_pricelist;
                  ELSIF (g_O_line_tbl(i).unit_price IS NULL) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Unit price is null');
		  ELSIF (g_O_line_tbl(i).unit_price <= 0) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(l_log_level,'Unit price non-positive');
                  END IF;
             ELSIF (g_I_line_extras_tbl(i).input_set_number = 2) THEN
                  l_mp_line_cnt := l_mp_line_cnt + 1;
                  IF (g_O_line_tbl(i).status_code IN (
                       --QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                       QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                       QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                       QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                       QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                       QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                       QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                       QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                       QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                       QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                       QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                       QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                       QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Event = '||p_event_num||' LineIndex = '||i||' Status Code = '||g_O_line_tbl(i).status_code||' Text = '||g_O_line_tbl(i).status_text);
                  END IF;
                  -- check for IPL
                  IF (g_O_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST) THEN
                         l_mp_ipl_cnt := l_mp_ipl_cnt +1;
                  ELSIF (g_O_line_tbl(i).unit_price IS NULL) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Unit price is
null for reasons other than IPL');
		  ELSIF (g_O_line_tbl(i).unit_price <= 0) THEN
                      l_error_flag := true;
                      fte_freight_pricing_util.print_msg(l_log_level,'Unit price non-positive');
                  END IF;
             ELSE
                null;
             END IF; -- input_set_number

         EXIT WHEN i >= g_O_line_tbl.LAST;
             i := g_O_line_tbl.NEXT(i);
         END LOOP;

         IF (l_mp_line_cnt > 0) THEN
	   IF (l_mp_ipl_cnt > 0) THEN
	     IF (l_mp_line_cnt = l_mp_ipl_cnt) THEN
  	       IF (l_sp_ipl_cnt > 0) THEN
		 l_error_flag := true;
	       ELSE
	         x_return_code := G_PAR_NO_MP_PRICE;
	       END IF;
	     ELSE
               raise fte_freight_pricing_util.g_not_on_pricelist;
	     END IF;
	   ELSE
	     IF (l_sp_ipl_cnt > 0) THEN
	       x_return_code := G_PAR_NO_SP_PRICE;
	     ELSE
	       x_return_code := 0;
	     END IF;
	   END IF;
	 ELSE -- no mp lines
	   IF (l_sp_ipl_cnt >0) THEN
             l_error_flag := true;
	   ELSE
	     x_return_code := G_PAR_NO_MP_PRICE;
	   END IF;
	 END IF;
/*
         IF ((l_mp_ipl_cnt < l_mp_line_cnt) AND (l_mp_ipl_cnt <> 0) ) THEN
             -- there were IPLs and they are probably not something we can ignore
             l_error_flag := true;
             raise fte_freight_pricing_util.g_not_on_pricelist;
         ELSE
            IF (l_mp_ipl_cnt >0 ) THEN
              fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'IPLs were found but num of ipls = num of set2 lines');
              x_return_code := G_PAR_NO_MP_PRICE; -- multipiece price not found
            END IF;
         END IF;
*/
        END IF;   -- i is not null
     ELSIF (p_event_num = G_CHARGE_EVENT_NUM) THEN
        i := g_O_line_tbl.FIRST ;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_O_line_tbl(i).status_code IN (
                  QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                  QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                  QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                  QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                  QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                  QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                  QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                  QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                  QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                  QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Event = '||p_event_num||' LineIndex = '||i||' Status Code = '||g_O_line_tbl(i).status_code||' Text = '||g_O_line_tbl(i).status_text);
                 IF (g_O_line_tbl(i).status_code = 'IPL') THEN
                    raise fte_freight_pricing_util.g_not_on_pricelist;
                 END IF;
             END IF;
             IF (g_O_line_tbl(i).unit_price IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Unit price is null');
             END IF;
         EXIT WHEN i >= g_O_line_tbl.LAST;
             i := g_O_line_tbl.NEXT(i);
         END LOOP;
        END IF;
     ELSE
        null;
     END IF;

         i := g_O_line_detail_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (g_O_line_detail_tbl(i).adjustment_amount IS NULL) THEN
                 l_error_flag := true;
                 fte_freight_pricing_util.print_msg(l_log_level,'Adjustment amount is null');
             END IF;
         EXIT WHEN i >= g_O_line_detail_tbl.LAST;
             i := g_O_line_detail_tbl.NEXT(i);
         END LOOP;
        END IF;

     IF (l_error_flag) THEN
             raise FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed;
     END IF;

     fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
    EXCEPTION
        WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Following item quantity not found on pricelist :');
           l_category := g_I_line_extras_tbl(i).category_id;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      Quantity = '||g_I_line_quantity(i)||' '||g_I_line_uom_code(i));
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      CategoryId = '||nvl(l_category,'Consolidated'));
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
        WHEN fte_freight_pricing_util.g_qp_price_request_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
        WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

END check_parcel_output_errors;

-- return the pointer to the qp outputs
PROCEDURE get_qp_output(
  x_qp_output_line_rows    OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
  x_qp_output_detail_rows  OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
  x_return_status OUT NOCOPY  VARCHAR2)
IS
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'get_qp_output';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  x_qp_output_line_rows := g_O_line_tbl;
  x_qp_output_detail_rows := g_O_line_detail_tbl;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END get_qp_output;

-- populate qp output from the temp table
PROCEDURE populate_qp_output  (
        x_qp_output_line_rows    OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows  OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
        x_return_status          OUT NOCOPY   VARCHAR2)
IS
    l_return_status_text   VARCHAR2(240);
    l_return_status        VARCHAR2(1);

     l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
     l_method_name VARCHAR2(50) := 'populate_qp_output';

  cursor c_qp_lines_tmp is
    select
	request_type_code,
	line_id,
	line_index,
	line_type_code,
	pricing_effective_date,
	line_quantity,
	line_uom_code,
	priced_quantity,
	priced_uom_code,
	currency_code,
	unit_price,
	adjusted_unit_price,
	price_flag,
	extended_price,
	start_date_active_first,
	start_date_active_second,
	pricing_status_code,
	pricing_status_text
    from qp_preq_lines_tmp;

  cursor c_qp_line_details_tmp is
    select
	line_detail_index,
	line_detail_type_code,
	line_index,
	list_header_id,
	list_line_id,
	list_line_type_code,
	adjustment_amount,
	charge_type_code,
	charge_subtype_code,
	line_quantity,
	operand_calculation_code,
	operand_value,
	automatic_flag,
	override_flag,
	pricing_status_code,
	pricing_status_text
    from qp_ldets_v
    where pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    and ( list_line_type_code = QP_PREQ_GRP.G_DISCOUNT
          or ((list_line_type_code = QP_PREQ_GRP.G_SURCHARGE
	          or list_line_type_code = QP_PREQ_GRP.G_PRICE_BREAK_TYPE )    -- TL
               and charge_subtype_code IS NOT NULL)                         -- TL
         );

    -- Note : discounts not guaranteed to have a subtype code in LTL / Parcel


    CURSOR  c_qp_child_details (c_parent_line_index NUMBER,
                                c_parent_line_detail_index NUMBER)
    IS
    SELECT
        ldets.line_detail_index,
        ldets.line_detail_type_code,
        ldets.line_index,
        ldets.list_header_id,
        ldets.list_line_id,
        ldets.list_line_type_code,
        ldets.adjustment_amount,
        ldets.charge_type_code,
        ldets.charge_subtype_code,
        ldets.line_quantity,
        ldets.operand_calculation_code,
        ldets.operand_value,
        ldets.automatic_flag,
        ldets.override_flag,
        ldets.pricing_status_code,
        ldets.pricing_status_text
    FROM qp_ldets_v ldets,
         qp_preq_rltd_lines_tmp rltd
    WHERE
        rltd.related_line_index = ldets.line_index
     AND rltd.related_line_detail_index = ldets.line_detail_index
     AND rltd.line_index = c_parent_line_index
     AND rltd.line_detail_index = c_parent_line_detail_index
     AND rltd.relationship_type_code = QP_PREQ_GRP.G_PBH_LINE
     AND rltd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
     AND ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
     AND ldets.list_line_type_code = QP_PREQ_GRP.G_SURCHARGE
     AND ldets.operand_calculation_code = 'LUMPSUM'
     AND ldets.line_quantity >0;


  i NUMBER;

BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,l_method_name);

      g_O_line_tbl.DELETE;
      g_O_line_detail_tbl.DELETE;

      i := 0;
      for l in c_qp_lines_tmp loop
	i := i+1;
	g_O_line_tbl(i).request_type_code := l.request_type_code;
	g_O_line_tbl(i).line_index := l.line_index;
	g_O_line_tbl(i).line_id := l.line_id;
	g_O_line_tbl(i).line_type_code := l.line_type_code;
	g_O_line_tbl(i).pricing_effective_date := l.pricing_effective_date;
	g_O_line_tbl(i).active_date_first := l.start_date_active_first;
	g_O_line_tbl(i).active_date_second := l.start_date_active_second;
	g_O_line_tbl(i).line_quantity := l.line_quantity;
	g_O_line_tbl(i).line_uom_code := l.line_uom_code;
	g_O_line_tbl(i).priced_quantity := l.priced_quantity;
	g_O_line_tbl(i).priced_uom_code := l.priced_uom_code;
	g_O_line_tbl(i).currency_code := l.currency_code;
	g_O_line_tbl(i).unit_price := l.unit_price;
	g_O_line_tbl(i).adjusted_unit_price := l.adjusted_unit_price;
	g_O_line_tbl(i).price_flag := l.price_flag;
	g_O_line_tbl(i).extended_price := l.extended_price;
	g_O_line_tbl(i).status_code := l.pricing_status_code;
	g_O_line_tbl(i).status_text := l.pricing_status_text;
      end loop;

      i := 0;
      for l in c_qp_line_details_tmp loop
	i := i+1;
	g_O_line_detail_tbl(i).line_detail_index := l.line_detail_index;
	g_O_line_detail_tbl(i).line_detail_type_code := l.line_detail_type_code;
	g_O_line_detail_tbl(i).line_index := l.line_index;
	g_O_line_detail_tbl(i).list_header_id := l.list_header_id;
	g_O_line_detail_tbl(i).list_line_id := l.list_line_id;
	g_O_line_detail_tbl(i).list_line_type_code := l.list_line_type_code;
	g_O_line_detail_tbl(i).adjustment_amount := l.adjustment_amount;
	g_O_line_detail_tbl(i).charge_type_code := l.charge_type_code;
	g_O_line_detail_tbl(i).charge_subtype_code := l.charge_subtype_code;
	g_O_line_detail_tbl(i).line_quantity := l.line_quantity;
	g_O_line_detail_tbl(i).operand_calculation_code := l.operand_calculation_code;
	g_O_line_detail_tbl(i).operand_value := l.operand_value;
	g_O_line_detail_tbl(i).automatic_flag := l.automatic_flag;
	g_O_line_detail_tbl(i).override_flag := l.override_flag;
	g_O_line_detail_tbl(i).status_code := l.pricing_status_code;
	g_O_line_detail_tbl(i).status_text := l.pricing_status_text;


        IF l.line_quantity > 0
	  AND l.charge_subtype_code IN (
         fte_rtg_globals.G_C_HANDLING_WEIGHT_CH,
         fte_rtg_globals.G_C_HANDLING_VOLUME_CH,
         fte_rtg_globals.G_C_LOADING_WEIGHT_CH,
         fte_rtg_globals.G_C_LOADING_VOLUME_CH,
         fte_rtg_globals.G_C_LOADING_PALLET_CH,
         fte_rtg_globals.G_C_LOADING_CONTAINER_CH,
         fte_rtg_globals.G_C_AST_LOADING_WEIGHT_CH,
         fte_rtg_globals.G_C_AST_LOADING_VOLUME_CH,
         fte_rtg_globals.G_C_AST_LOADING_PALLET_CH,
         fte_rtg_globals.G_C_AST_LOADING_CONTAINER_CH,
         fte_rtg_globals.G_C_UNLOADING_WEIGHT_CH,
         fte_rtg_globals.G_C_UNLOADING_VOLUME_CH,
         fte_rtg_globals.G_C_UNLOADING_PALLET_CH,
         fte_rtg_globals.G_C_UNLOADING_CONTAINER_CH,
         fte_rtg_globals.G_C_AST_UNLOADING_WEIGHT_CH,
         fte_rtg_globals.G_C_AST_UNLOADING_VOLUME_CH,
         fte_rtg_globals.G_C_AST_UNLOADING_PALLET_CH,
         fte_rtg_globals.G_C_AST_UNLOADING_CONTAINER_CH,
         fte_rtg_globals.G_F_LOADING_WEIGHT_CH,
         fte_rtg_globals.G_F_LOADING_VOLUME_CH,
         fte_rtg_globals.G_F_LOADING_PALLET_CH,
         fte_rtg_globals.G_F_LOADING_CONTAINER_CH,
         fte_rtg_globals.G_F_AST_LOADING_WEIGHT_CH,
         fte_rtg_globals.G_F_AST_LOADING_VOLUME_CH,
         fte_rtg_globals.G_F_AST_LOADING_PALLET_CH,
         fte_rtg_globals.G_F_AST_LOADING_CONTAINER_CH,
         fte_rtg_globals.G_F_UNLOADING_WEIGHT_CH,
         fte_rtg_globals.G_F_UNLOADING_VOLUME_CH,
         fte_rtg_globals.G_F_UNLOADING_PALLET_CH,
         fte_rtg_globals.G_F_UNLOADING_CONTAINER_CH,
         fte_rtg_globals.G_F_AST_UNLOADING_WEIGHT_CH,
         fte_rtg_globals.G_F_AST_UNLOADING_VOLUME_CH,
         fte_rtg_globals.G_F_AST_UNLOADING_PALLET_CH,
         fte_rtg_globals.G_F_AST_UNLOADING_CONTAINER_CH,
         fte_rtg_globals.G_F_HANDLING_WEIGHT_CH,
         fte_rtg_globals.G_F_HANDLING_VOLUME_CH,
         fte_rtg_globals.G_F_HANDLING_PALLET_CH,
         fte_rtg_globals.G_F_HANDLING_CONTAINER_CH )
        THEN

           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,
            'Found line_index:'||l.line_index||'det_idx '||l.line_detail_index||
            ' charge subtype '||l.charge_subtype_code||' line type :'||l.list_line_type_code
            ||' OrigLineQty: '||l.line_quantity );

             FOR c_child_rec IN c_qp_child_details(l.line_index, l.line_detail_index)             LOOP
                FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,
                 'Child detail : LnDetIdx :'||c_child_rec.line_detail_index
                 ||' LnQty:'||c_child_rec.line_quantity||' AdjAmt:'
                 ||c_child_rec.adjustment_amount||' OperCalc: '||c_child_rec.operand_calculation_code);

               --IF (c_child_rec.operand_calculation_code = 'LUMPSUM') THEN
                 -- update parent line_quantity
                 g_O_line_detail_tbl(i).line_quantity := 1;
               --END IF;

             END LOOP;

        END IF;

      end loop;


      print_qp_output();

      x_qp_output_line_rows   := g_O_line_tbl;
      x_qp_output_detail_rows := g_O_line_detail_tbl;

      fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
 EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	   fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

END populate_qp_output;

PROCEDURE peek_qp_input_line IS
  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'peek_qp_input_line';
  i1 NUMBER;
  i2 NUMBER;
  i3 NUMBER;
  i4 NUMBER;
  i5 NUMBER;
  i6 NUMBER;
  i7 NUMBER;
  i8 NUMBER;
  i9 NUMBER;
  i11 NUMBER;
  i12 NUMBER;
  i13 NUMBER;
  i14 NUMBER;
  i15 NUMBER;
  i16 NUMBER;
  i17 NUMBER;
  i18 NUMBER;
  i19 NUMBER;
  i21 NUMBER;
  i22 NUMBER;
  i23 NUMBER;
  i24 NUMBER;
  i25 NUMBER;
  i26 NUMBER;
  i27 NUMBER;
  i28 NUMBER;
  i29 NUMBER;
  i10 NUMBER;
  i20 NUMBER;
  i30 NUMBER;
  i31 NUMBER;
  i32 NUMBER;
  i33 NUMBER;
BEGIN
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  i1 := G_I_LINE_INDEX.FIRST;
  i2 := G_I_LINE_TYPE_CODE.FIRST;
  i3 := G_I_PRICING_EFFECTIVE_DATE.FIRST;
  i4 := G_I_ACTIVE_DATE_FIRST.FIRST;
  i5 := G_I_ACTIVE_DATE_FIRST_TYPE.FIRST;
  i6 := G_I_ACTIVE_DATE_SECOND.FIRST;
  i7 := G_I_ACTIVE_DATE_SECOND_TYPE.FIRST;
  i8 := G_I_LINE_QUANTITY.FIRST;
  i9 := G_I_LINE_UOM_CODE.FIRST;
  i10 := G_I_REQUEST_TYPE_CODE.FIRST;
  i11 := G_I_PRICED_QUANTITY.FIRST;
  i12 := G_I_PRICED_UOM_CODE.FIRST;
  i13 := G_I_CURRENCY_CODE.FIRST;
  i14 := G_I_UNIT_PRICE.FIRST;
  i15 := G_I_PERCENT_PRICE.FIRST;
  i16 := G_I_UOM_QUANTITY.FIRST;
  i17 := G_I_ADJUSTED_UNIT_PRICE.FIRST;
  i18 := G_I_UPD_ADJUSTED_UNIT_PRICE.FIRST;
  i19 := G_I_PROCESSED_FLAG.FIRST;
  i20 := G_I_PRICE_FLAG.FIRST;
  i21 := G_I_LINE_ID.FIRST;
  i22 := G_I_PROCESSING_ORDER.FIRST;
  i23 := G_I_PRICING_STATUS_CODE.FIRST;
  i24 := G_I_PRICING_STATUS_TEXT.FIRST;
  i25 := G_I_ROUNDING_FLAG.FIRST;
  i26 := G_I_ROUNDING_FACTOR.FIRST;
  i27 := G_I_QUALIFIERS_EXIST_FLAG.FIRST;
  i28 := G_I_PRICING_ATTRS_EXIST_FLAG.FIRST;
  i29 := G_I_PRICE_LIST_ID.FIRST;
  i30 := G_I_VALIDATED_FLAG.FIRST;
  i31 := G_I_PRICE_REQUEST_CODE.FIRST;
  i32 := G_I_USAGE_PRICING_TYPE.FIRST;
  i33 := G_I_LINE_CATEGORY.FIRST;

  if i1 is not null then
    loop

  fte_freight_pricing_util.print_msg(l_log_level,'i1 = '||i1);
  if (i2 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i2 = '||i2);
  end if;
  if (i3 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i3 = '||i3);
  end if;
  if (i4 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i4 = '||i4);
  end if;
  if (i5 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i5 = '||i5);
  end if;
  if (i6 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i6 = '||i6);
  end if;
  if (i7 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i7 = '||i7);
  end if;
  if (i8 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i8 = '||i8);
  end if;
  if (i9 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i9 = '||i9);
  end if;
  if (i10 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i10 = '||i10);
  end if;
  if (i11 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i11 = '||i11);
  end if;
  if (i12 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i12 = '||i12);
  end if;
  if (i13 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i13 = '||i13);
  end if;
  if (i14 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i14 = '||i14);
  end if;
  if (i15 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i15 = '||i15);
  end if;
  if (i16 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i16 = '||i16);
  end if;
  if (i17 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i17 = '||i17);
  end if;
  if (i18 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i18 = '||i18);
  end if;
  if (i19 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i19 = '||i19);
  end if;
  if (i20 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i20 = '||i20);
  end if;
  if (i21 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i21 = '||i21);
  end if;
  if (i22 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i22 = '||i22);
  end if;
  if (i23 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i23 = '||i23);
  end if;
  if (i24 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i24 = '||i24);
  end if;
  if (i25 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i25 = '||i25);
  end if;
  if (i26 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i26 = '||i26);
  end if;
  if (i27 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i27 = '||i27);
  end if;
  if (i28 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i28 = '||i28);
  end if;
  if (i29 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i29 = '||i29);
  end if;
  if (i30 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i30 = '||i30);
  end if;
  if (i31 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i31 = '||i31);
  end if;
  if (i32 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i32 = '||i32);
  end if;
  if (i33 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i33 = '||i33);
  end if;

  fte_freight_pricing_util.print_msg(l_log_level,'-----------------------------------------------');

      exit when i1 = G_I_LINE_INDEX.LAST;

  i1 := G_I_LINE_INDEX.NEXT(i1);
  i2 := G_I_LINE_TYPE_CODE.NEXT(i2);
  i3 := G_I_PRICING_EFFECTIVE_DATE.NEXT(i3);
  i4 := G_I_ACTIVE_DATE_FIRST.NEXT(i4);
  i5 := G_I_ACTIVE_DATE_FIRST_TYPE.NEXT(i5);
  i6 := G_I_ACTIVE_DATE_SECOND.NEXT(i6);
  i7 := G_I_ACTIVE_DATE_SECOND_TYPE.NEXT(i7);
  i8 := G_I_LINE_QUANTITY.NEXT(i8);
  i9 := G_I_LINE_UOM_CODE.NEXT(i9);
  i10 := G_I_REQUEST_TYPE_CODE.NEXT(i10);
  i11 := G_I_PRICED_QUANTITY.NEXT(i11);
  i12 := G_I_PRICED_UOM_CODE.NEXT(i12);
  i13 := G_I_CURRENCY_CODE.NEXT(i13);
  i14 := G_I_UNIT_PRICE.NEXT(i14);
  i15 := G_I_PERCENT_PRICE.NEXT(i15);
  i16 := G_I_UOM_QUANTITY.NEXT(i16);
  i17 := G_I_ADJUSTED_UNIT_PRICE.NEXT(i17);
  i18 := G_I_UPD_ADJUSTED_UNIT_PRICE.NEXT(i18);
  i19 := G_I_PROCESSED_FLAG.NEXT(i19);
  i20 := G_I_PRICE_FLAG.NEXT(i20);
  i21 := G_I_LINE_ID.NEXT(i21);
  i22 := G_I_PROCESSING_ORDER.NEXT(i22);
  i23 := G_I_PRICING_STATUS_CODE.NEXT(i23);
  i24 := G_I_PRICING_STATUS_TEXT.NEXT(i24);
  i25 := G_I_ROUNDING_FLAG.NEXT(i25);
  i26 := G_I_ROUNDING_FACTOR.NEXT(i26);
  i27 := G_I_QUALIFIERS_EXIST_FLAG.NEXT(i27);
  i28 := G_I_PRICING_ATTRS_EXIST_FLAG.NEXT(i28);
  i29 := G_I_PRICE_LIST_ID.NEXT(i29);
  i30 := G_I_VALIDATED_FLAG.NEXT(i30);
  i31 := G_I_PRICE_REQUEST_CODE.NEXT(i31);
  i32 := G_I_USAGE_PRICING_TYPE.NEXT(i32);
  i33 := G_I_LINE_CATEGORY.NEXT(i33);

    end loop;
  end if;

  i1 := G_I_LINE_INDEX.LAST;
  i2 := G_I_LINE_TYPE_CODE.LAST;
  i3 := G_I_PRICING_EFFECTIVE_DATE.LAST;
  i4 := G_I_ACTIVE_DATE_FIRST.LAST;
  i5 := G_I_ACTIVE_DATE_FIRST_TYPE.LAST;
  i6 := G_I_ACTIVE_DATE_SECOND.LAST;
  i7 := G_I_ACTIVE_DATE_SECOND_TYPE.LAST;
  i8 := G_I_LINE_QUANTITY.LAST;
  i9 := G_I_LINE_UOM_CODE.LAST;
  i10 := G_I_REQUEST_TYPE_CODE.LAST;
  i11 := G_I_PRICED_QUANTITY.LAST;
  i12 := G_I_PRICED_UOM_CODE.LAST;
  i13 := G_I_CURRENCY_CODE.LAST;
  i14 := G_I_UNIT_PRICE.LAST;
  i15 := G_I_PERCENT_PRICE.LAST;
  i16 := G_I_UOM_QUANTITY.LAST;
  i17 := G_I_ADJUSTED_UNIT_PRICE.LAST;
  i18 := G_I_UPD_ADJUSTED_UNIT_PRICE.LAST;
  i19 := G_I_PROCESSED_FLAG.LAST;
  i20 := G_I_PRICE_FLAG.LAST;
  i21 := G_I_LINE_ID.LAST;
  i22 := G_I_PROCESSING_ORDER.LAST;
  i23 := G_I_PRICING_STATUS_CODE.LAST;
  i24 := G_I_PRICING_STATUS_TEXT.LAST;
  i25 := G_I_ROUNDING_FLAG.LAST;
  i26 := G_I_ROUNDING_FACTOR.LAST;
  i27 := G_I_QUALIFIERS_EXIST_FLAG.LAST;
  i28 := G_I_PRICING_ATTRS_EXIST_FLAG.LAST;
  i29 := G_I_PRICE_LIST_ID.LAST;
  i30 := G_I_VALIDATED_FLAG.LAST;
  i31 := G_I_PRICE_REQUEST_CODE.LAST;
  i32 := G_I_USAGE_PRICING_TYPE.LAST;
  i33 := G_I_LINE_CATEGORY.LAST;

  fte_freight_pricing_util.print_msg(l_log_level,'---last index---');
  fte_freight_pricing_util.print_msg(l_log_level,'i1 = '||i1);
  if (i2 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i2 = '||i2);
  end if;
  if (i3 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i3 = '||i3);
  end if;
  if (i4 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i4 = '||i4);
  end if;
  if (i5 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i5 = '||i5);
  end if;
  if (i6 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i6 = '||i6);
  end if;
  if (i7 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i7 = '||i7);
  end if;
  if (i8 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i8 = '||i8);
  end if;
  if (i9 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i9 = '||i9);
  end if;
  if (i10 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i10 = '||i10);
  end if;
  if (i11 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i11 = '||i11);
  end if;
  if (i12 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i12 = '||i12);
  end if;
  if (i13 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i13 = '||i13);
  end if;
  if (i14 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i14 = '||i14);
  end if;
  if (i15 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i15 = '||i15);
  end if;
  if (i16 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i16 = '||i16);
  end if;
  if (i17 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i17 = '||i17);
  end if;
  if (i18 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i18 = '||i18);
  end if;
  if (i19 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i19 = '||i19);
  end if;
  if (i20 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i20 = '||i20);
  end if;
  if (i21 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i21 = '||i21);
  end if;
  if (i22 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i22 = '||i22);
  end if;
  if (i23 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i23 = '||i23);
  end if;
  if (i24 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i24 = '||i24);
  end if;
  if (i25 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i25 = '||i25);
  end if;
  if (i26 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i26 = '||i26);
  end if;
  if (i27 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i27 = '||i27);
  end if;
  if (i28 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i28 = '||i28);
  end if;
  if (i29 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i29 = '||i29);
  end if;
  if (i30 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i30 = '||i30);
  end if;
  if (i31 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i31 = '||i31);
  end if;
  if (i32 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i32 = '||i32);
  end if;
  if (i33 <> i1) then
    fte_freight_pricing_util.print_msg(l_log_level,'i33 = '||i33);
  end if;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END peek_qp_input_line;

PROCEDURE   call_qp_api  (
        x_qp_output_line_rows    OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
        x_qp_output_detail_rows  OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
	x_return_status          OUT NOCOPY   VARCHAR2)
IS
    l_return_status_text   VARCHAR2(240);
    l_return_status        VARCHAR2(1);

  start_time DATE;
  end_time DATE;

     l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
     l_method_name VARCHAR2(50) := 'call_qp_api';
BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,'call_qp_api');

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
          'G_I_LINE_INDEX.count = '||G_I_LINE_INDEX.count);
      print_qp_input();

      -- peek_qp_input_line();

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'CALLING QP ENGINE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
      start_time := sysdate;

      --set request_id
      QP_PRICE_REQUEST_CONTEXT.set_request_id();

      IF G_I_LINE_INDEX.COUNT > 0 THEN
        QP_PREQ_GRP.INSERT_LINES2(
    p_LINE_INDEX                   => G_I_LINE_INDEX,
    p_LINE_TYPE_CODE               => G_I_LINE_TYPE_CODE,
    p_PRICING_EFFECTIVE_DATE       => G_I_PRICING_EFFECTIVE_DATE,
    p_ACTIVE_DATE_FIRST            => G_I_ACTIVE_DATE_FIRST,
    p_ACTIVE_DATE_FIRST_TYPE       => G_I_ACTIVE_DATE_FIRST_TYPE,
    p_ACTIVE_DATE_SECOND           => G_I_ACTIVE_DATE_SECOND,
    p_ACTIVE_DATE_SECOND_TYPE      => G_I_ACTIVE_DATE_SECOND_TYPE,
    p_LINE_QUANTITY                => G_I_LINE_QUANTITY,
    p_LINE_UOM_CODE                => G_I_LINE_UOM_CODE,
    p_REQUEST_TYPE_CODE            => G_I_REQUEST_TYPE_CODE,
    p_PRICED_QUANTITY              => G_I_PRICED_QUANTITY,
    p_PRICED_UOM_CODE              => G_I_PRICED_UOM_CODE,
    p_CURRENCY_CODE                => G_I_CURRENCY_CODE,
    p_UNIT_PRICE                   => G_I_UNIT_PRICE,
    p_PERCENT_PRICE                => G_I_PERCENT_PRICE,
    p_UOM_QUANTITY                 => G_I_UOM_QUANTITY,
    p_ADJUSTED_UNIT_PRICE          => G_I_ADJUSTED_UNIT_PRICE,
    p_UPD_ADJUSTED_UNIT_PRICE      => G_I_UPD_ADJUSTED_UNIT_PRICE,
    p_PROCESSED_FLAG               => G_I_PROCESSED_FLAG,
    p_PRICE_FLAG                   => G_I_PRICE_FLAG,
    p_LINE_ID                      => G_I_LINE_ID,
    p_PROCESSING_ORDER             => G_I_PROCESSING_ORDER,
    p_PRICING_STATUS_CODE          => G_I_PRICING_STATUS_CODE,
    p_PRICING_STATUS_TEXT          => G_I_PRICING_STATUS_TEXT,
    p_ROUNDING_FLAG                => G_I_ROUNDING_FLAG,
    p_ROUNDING_FACTOR              => G_I_ROUNDING_FACTOR,
    p_QUALIFIERS_EXIST_FLAG        => G_I_QUALIFIERS_EXIST_FLAG,
    p_PRICING_ATTRS_EXIST_FLAG     => G_I_PRICING_ATTRS_EXIST_FLAG,
    p_PRICE_LIST_ID                => G_I_PRICE_LIST_ID,
    p_VALIDATED_FLAG               => G_I_VALIDATED_FLAG,
    p_PRICE_REQUEST_CODE           => G_I_PRICE_REQUEST_CODE,
    p_USAGE_PRICING_TYPE           => G_I_USAGE_PRICING_TYPE,
    p_line_category                => G_I_LINE_CATEGORY,
    x_status_code                  => l_return_status,
    x_status_text                  => l_return_status_text);

      END IF;

      FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after QP_PREQ_GRP_INSERT_LINES2');
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_qp_insert_lines2_failed;
      END IF;

      IF G_I_A_LINE_INDEX.count > 0 THEN
        QP_PREQ_GRP.INSERT_LINE_ATTRS2(
    p_LINE_INDEX_tbl               => G_I_A_LINE_INDEX,
    p_LINE_DETAIL_INDEX_tbl        => G_I_A_LINE_DETAIL_INDEX,
    p_ATTRIBUTE_LEVEL_tbl          => G_I_A_ATTRIBUTE_LEVEL,
    p_ATTRIBUTE_TYPE_tbl           => G_I_A_ATTRIBUTE_TYPE,
    p_LIST_HEADER_ID_tbl           => G_I_A_LIST_HEADER_ID,
    p_LIST_LINE_ID_tbl             => G_I_A_LIST_LINE_ID,
    p_CONTEXT_tbl                  => G_I_A_CONTEXT,
    p_ATTRIBUTE_tbl                => G_I_A_ATTRIBUTE,
    p_VALUE_FROM_tbl               => G_I_A_VALUE_FROM,
    p_SETUP_VALUE_FROM_tbl         => G_I_A_SETUP_VALUE_FROM,
    p_VALUE_TO_tbl                 => G_I_A_VALUE_TO,
    p_SETUP_VALUE_TO_tbl           => G_I_A_SETUP_VALUE_TO,
    p_GROUPING_NUMBER_tbl          => G_I_A_GROUPING_NUMBER,
    p_NO_QUALIFIERS_IN_GRP_tbl     => G_I_A_NO_QUALIFIERS_IN_GRP,
    p_COMPARISON_OPERATOR_TYPE_tbl => G_I_A_COMPARISON_OPERATOR_TYPE,
    p_VALIDATED_FLAG_tbl           => G_I_A_VALIDATED_FLAG,
    p_APPLIED_FLAG_tbl             => G_I_A_APPLIED_FLAG,
    p_PRICING_STATUS_CODE_tbl      => G_I_A_PRICING_STATUS_CODE,
    p_PRICING_STATUS_TEXT_tbl      => G_I_A_PRICING_STATUS_TEXT,
    p_QUALIFIER_PRECEDENCE_tbl     => G_I_A_QUALIFIER_PRECEDENCE,
    p_DATATYPE_tbl                 => G_I_A_DATATYPE,
    p_PRICING_ATTR_FLAG_tbl        => G_I_A_PRICING_ATTR_FLAG,
    p_QUALIFIER_TYPE_tbl           => G_I_A_QUALIFIER_TYPE,
    p_PRODUCT_UOM_CODE_TBL         => G_I_A_PRODUCT_UOM_CODE,
    p_EXCLUDER_FLAG_TBL            => G_I_A_EXCLUDER_FLAG,
    p_PRICING_PHASE_ID_TBL         => G_I_A_PRICING_PHASE_ID,
    p_INCOMPATABILITY_GRP_CODE_TBL => G_I_A_INCOMPATABILITY_GRP_CODE,
    p_LINE_DETAIL_TYPE_CODE_TBL    => G_I_A_LINE_DETAIL_TYPE_CODE,
    p_MODIFIER_LEVEL_CODE_TBL      => G_I_A_MODIFIER_LEVEL_CODE,
    p_PRIMARY_UOM_FLAG_TBL         => G_I_A_PRIMARY_UOM_FLAG,
    x_status_code                  => l_return_status,
    x_status_text                  => l_return_status_text);

      end if;

      FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after QP_PREQ_GRP_INSERT_LINE_ATTRS2');
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_qp_insert_line_attrs2_failed;
      END IF;

      --The pricing engine output is in the temporary table after this call
      QP_PREQ_PUB.PRICE_REQUEST (
        g_I_control_rec,
        l_return_status,
        l_return_status_text);

      FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after QP_PREQ_PUB.PRICE_REQUEST');
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed;
      ELSE
        FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'qp_price_request_finished. Return status = '||l_return_status);
        FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_DBG,'Return status text = '||l_return_status_text);
      END IF;

      populate_qp_output(
	x_qp_output_line_rows    => x_qp_output_line_rows,
	x_qp_output_detail_rows  => x_qp_output_detail_rows,
	x_return_status          => l_return_status);

      FTE_FREIGHT_PRICING_UTIL.set_location(p_loc=>'after populate qp output');
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed;
        END IF;
      END IF;

      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'AFTER CALL TO QP ENGINE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
      end_time := sysdate;
      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'time difference '||(end_time-start_time)*24*3600 || ' seconds');
      --fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'time difference '||to_char(to_date('00:00:00','HH24:MI:SS') + (end_time-start_time), 'HH24:MI:SS'));

 fte_freight_pricing_util.unset_method(l_log_level,'call_qp_api');
 EXCEPTION
      WHEN FTE_FREIGHT_PRICING_UTIL.g_qp_price_request_failed THEN
           --x_return_status := l_return_status;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'qp_price_request_failed');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status = '||l_return_status);
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status text = '||l_return_status_text);
           fte_freight_pricing_util.unset_method(l_log_level,'call_qp_api');
      WHEN FTE_FREIGHT_PRICING_UTIL.g_qp_insert_lines2_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'qp_insert_lines2_failed');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status = '||l_return_status);
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status text = '||l_return_status_text);
           fte_freight_pricing_util.unset_method(l_log_level,'call_qp_api');
      WHEN FTE_FREIGHT_PRICING_UTIL.g_qp_insert_line_attrs2_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'qp_insert_line_attrs2_failed');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status = '||l_return_status);
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Return status text = '||l_return_status_text);
           fte_freight_pricing_util.unset_method(l_log_level,'call_qp_api');
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           print_qp_output();
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,'call_qp_api');

END call_qp_api;

-- Debug methods --

PROCEDURE print_qp_input IS
  I NUMBER;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'print_qp_input';
BEGIN

  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-----------QP Inputs-------------');
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-----------Control Record Information-------------');

  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing Event '||g_I_control_rec.pricing_event);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Calculate Flag  '||g_I_control_rec.calculate_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Simulation Flag '||g_I_control_rec.simulation_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Rounding Flag '||g_I_control_rec.rounding_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Temp Table Insert Flag '||g_I_control_rec.temp_table_insert_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Request Type Code '||g_I_control_rec.request_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'---------------------------------------------------');

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-------------Input Request Line Information-------------------');

I := g_I_line_index.FIRST;
IF I IS NOT NULL THEN
 LOOP
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I: '||I);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Index: '||g_I_line_index(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Request Type Code : '||g_I_request_type_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Type Code : '||g_I_line_type_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Quantity : '||g_I_line_quantity(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Uom Code : '||g_I_line_uom_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Currency Code : '||g_I_currency_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Price Flag : '||g_I_price_flag(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Unit_price: '||g_I_unit_price(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Priced Quantity: '||g_I_priced_quantity(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Priced UOM Code: '||g_I_priced_uom_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Percent price: '||g_I_percent_price(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Adjusted Unit Price: '||g_I_adjusted_unit_price(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing Effective Date : '||g_I_pricing_effective_date(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Active Date First: '||g_I_active_date_first(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Active Date Second: '||g_I_active_date_second(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing status code: '||g_I_pricing_status_code(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing status text: '||g_I_pricing_status_text(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'---------------------------------------------------');
  EXIT WHEN I = g_I_line_index.LAST;
  I := g_I_line_index.NEXT(I);
 END LOOP;
END IF;

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'----------- Input Line Extras Table ---------------------');
I := g_I_line_extras_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I: '||I);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Index: '||g_I_line_extras_tbl(I).line_index);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'input_set_number : '||g_I_line_extras_tbl(I).input_set_number);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'category_id : '||g_I_line_extras_tbl(I).category_id);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'---------------------------------------------------');

  EXIT WHEN I = g_I_line_extras_tbl.LAST;
  I := g_I_line_extras_tbl.NEXT(I);
 END LOOP;
END IF;
fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'----------- Input Pricing Attributes and qualifiers Information-------------');

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_I_A_line_index.COUNT:'||g_I_A_line_index.COUNT);

I := g_I_A_line_index.FIRST;
IF I IS NOT NULL THEN
 LOOP

  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I: '||I);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Index '||g_I_A_line_index(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Context '||g_I_A_context(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Attribute Type '||g_I_A_attribute_type(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Attribute '||g_I_A_attribute(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Value From '||g_I_A_value_from(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Validated Flag '||g_I_A_VALIDATED_FLAG(i));
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'---------------------------------------------------');

  EXIT WHEN I = g_I_A_line_index.last;
  I:=g_I_A_line_index.NEXT(I);

 END LOOP;
END IF;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END print_qp_input;

PROCEDURE print_qp_output IS
I NUMBER;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'print_qp_output';
 BEGIN
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-------------Output Request Line Information-------------------');

I := g_O_line_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I: '||I);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Index: '||g_O_line_tbl(I).line_index);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Request Type Code : '||g_O_line_tbl(I).request_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Type Code : '||g_O_line_tbl(I).line_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Quantity : '||g_O_line_tbl(I).line_quantity);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Uom Code : '||g_O_line_tbl(I).line_uom_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Currency Code : '||g_O_line_tbl(I).currency_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Priced Quantity : '||g_O_line_tbl(I).priced_quantity);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Priced Uom Code : '||g_O_line_tbl(I).priced_uom_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Price Flag : '||g_O_line_tbl(I).price_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Unit_price: '||g_O_line_tbl(I).unit_price);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Percent price: '||g_O_line_tbl(I).percent_price);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Adjusted Unit Price: '||g_O_line_tbl(I).adjusted_unit_price);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Extended Price: '||g_O_line_tbl(I).extended_price);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing status code: '||g_O_line_tbl(I).status_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Pricing status text: '||g_O_line_tbl(I).status_text);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'---------------------------------------------------');
  EXIT WHEN I = g_O_line_tbl.LAST;
  I := g_O_line_tbl.NEXT(I);
 END LOOP;
END IF;

fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'------------Price List/Discount Information------------');

I := g_O_line_detail_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'I: '||I);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Index: '||g_O_line_detail_tbl(I).line_index);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Detail Index: '||g_O_line_detail_tbl(I).line_detail_index);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Detail Type:'||g_O_line_detail_tbl(I).line_detail_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'List Header Id: '||g_O_line_detail_tbl(I).list_header_id);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'List Line Id: '||g_O_line_detail_tbl(I).list_line_id);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'List Line Type Code: '||g_O_line_detail_tbl(I).list_line_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Adjustment Amount : '||g_O_line_detail_tbl(I).adjustment_amount);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Line Quantity : '||g_O_line_detail_tbl(I).line_quantity);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Operand Calculation Code: '||g_O_line_detail_tbl(I).Operand_calculation_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Operand value: '||g_O_line_detail_tbl(I).operand_value);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Automatic Flag: '||g_O_line_detail_tbl(I).automatic_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Override Flag: '||g_O_line_detail_tbl(I).override_flag);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'ChargeTypeCode : '||g_O_line_detail_tbl(I).charge_type_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'ChargeSubTypeCode : '||g_O_line_detail_tbl(I).charge_subtype_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'status_code: '||g_O_line_detail_tbl(I).status_code);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'status text: '||g_O_line_detail_tbl(I).status_text);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'-------------------------------------------');
  EXIT WHEN I =  g_O_line_detail_tbl.LAST;
  I := g_O_line_detail_tbl.NEXT(I);
 END LOOP;
END IF;
  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END print_qp_output;

--
-- Added for TL rating
-- Clears variables used for input to and output from qp
-- Should to be executed before creating inputs for a new call
--

PROCEDURE clear_globals (
  x_return_status OUT NOCOPY VARCHAR2)
IS
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := 'CLEAR_GLOBALS';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Before ->G_I_LINE_INDEX.COUNT = '||G_I_LINE_INDEX.COUNT);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Before ->g_O_line_tbl.COUNT = '||g_O_line_tbl.COUNT);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Before ->g_O_line_detail_tbl.COUNT = '||g_O_line_detail_tbl.COUNT);

  G_I_LINE_INDEX.DELETE;
  G_I_LINE_TYPE_CODE.DELETE;
  G_I_PRICING_EFFECTIVE_DATE.DELETE;
  G_I_ACTIVE_DATE_FIRST.DELETE;
  G_I_ACTIVE_DATE_FIRST_TYPE.DELETE;
  G_I_ACTIVE_DATE_SECOND.DELETE;
  G_I_ACTIVE_DATE_SECOND_TYPE.DELETE;
  G_I_LINE_QUANTITY.DELETE;
  G_I_LINE_UOM_CODE.DELETE;
  G_I_REQUEST_TYPE_CODE.DELETE;
  G_I_PRICED_QUANTITY.DELETE;
  G_I_PRICED_UOM_CODE.DELETE;
  G_I_CURRENCY_CODE.DELETE;
  G_I_UNIT_PRICE.DELETE;
  G_I_PERCENT_PRICE.DELETE;
  G_I_UOM_QUANTITY.DELETE;
  G_I_ADJUSTED_UNIT_PRICE.DELETE;
  G_I_UPD_ADJUSTED_UNIT_PRICE.DELETE;
  G_I_PROCESSED_FLAG.DELETE;
  G_I_PRICE_FLAG.DELETE;
  G_I_LINE_ID.DELETE;
  G_I_PROCESSING_ORDER.DELETE;
  G_I_PRICING_STATUS_CODE.DELETE;
  G_I_PRICING_STATUS_TEXT.DELETE;
  G_I_ROUNDING_FLAG.DELETE;
  G_I_ROUNDING_FACTOR.DELETE;
  G_I_QUALIFIERS_EXIST_FLAG.DELETE;
  G_I_PRICING_ATTRS_EXIST_FLAG.DELETE;
  G_I_PRICE_LIST_ID.DELETE;
  G_I_VALIDATED_FLAG.DELETE;
  G_I_PRICE_REQUEST_CODE.DELETE;
  G_I_USAGE_PRICING_TYPE.DELETE;
  G_I_LINE_CATEGORY.DELETE;

  G_I_A_LINE_INDEX.DELETE;
  G_I_A_LINE_DETAIL_INDEX.DELETE;
  G_I_A_ATTRIBUTE_LEVEL.DELETE;
  G_I_A_ATTRIBUTE_TYPE.DELETE;
  G_I_A_LIST_HEADER_ID.DELETE;
  G_I_A_LIST_LINE_ID.DELETE;
  G_I_A_CONTEXT.DELETE;
  G_I_A_ATTRIBUTE.DELETE;
  G_I_A_VALUE_FROM.DELETE;
  G_I_A_SETUP_VALUE_FROM.DELETE;
  G_I_A_VALUE_TO.DELETE;
  G_I_A_SETUP_VALUE_TO.DELETE;
  G_I_A_GROUPING_NUMBER.DELETE;
  G_I_A_NO_QUALIFIERS_IN_GRP.DELETE;
  G_I_A_COMPARISON_OPERATOR_TYPE.DELETE;
  G_I_A_VALIDATED_FLAG.DELETE;
  G_I_A_APPLIED_FLAG.DELETE;
  G_I_A_PRICING_STATUS_CODE.DELETE;
  G_I_A_PRICING_STATUS_TEXT.DELETE;
  G_I_A_QUALIFIER_PRECEDENCE.DELETE;
  G_I_A_DATATYPE.DELETE;
  G_I_A_PRICING_ATTR_FLAG.DELETE;
  G_I_A_QUALIFIER_TYPE.DELETE;
  G_I_A_PRODUCT_UOM_CODE.DELETE;
  G_I_A_EXCLUDER_FLAG.DELETE;
  G_I_A_PRICING_PHASE_ID.DELETE;
  G_I_A_INCOMPATABILITY_GRP_CODE.DELETE;
  G_I_A_LINE_DETAIL_TYPE_CODE.DELETE;
  G_I_A_MODIFIER_LEVEL_CODE.DELETE;
  G_I_A_PRIMARY_UOM_FLAG.DELETE;

  --g_I_control_rec := null;
  g_I_line_extras_tbl.DELETE;

  -- output from QP
  g_O_line_tbl.DELETE;
  g_O_line_detail_tbl.DELETE;

  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'After ->G_I_LINE_INDEX.COUNT = '||G_I_LINE_INDEX.COUNT);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'After ->g_O_line_tbl.COUNT = '||g_O_line_tbl.COUNT);
  fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'After ->g_O_line_detail_tbl.COUNT = '||g_O_line_detail_tbl.COUNT);
  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END clear_globals;

/* template for a procedure
--
PROCEDURE (
  x_return_status OUT NOCOPY VARCHAR2)
IS
   l_return_status    VARCHAR2(1);
   l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
   l_method_name VARCHAR2(50) := '';
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);


  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
EXCEPTION
      WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FTE_FREIGHT_PRICING_UTIL.set_exception(l_method_name,l_log_level,'g_others');
           FTE_FREIGHT_PRICING_UTIL.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
END ;
*/

  -- package initialization
  -- should be executed only once when the package is loaded into memory
 BEGIN
    g_engine_defaults_tab.DELETE;

    -- Load the defaults table
     /* -- Uncomment for TL testing and comment out original block
     g_engine_defaults_tab(G_LINE_EVENT_NUM).pricing_event_num  := G_LINE_EVENT_NUM;
     g_engine_defaults_tab(G_LINE_EVENT_NUM).pricing_event_code := 'BATCH';
     g_engine_defaults_tab(G_LINE_EVENT_NUM).request_type_code  := 'ONT';
     g_engine_defaults_tab(G_LINE_EVENT_NUM).line_type_code     := 'LINE';
     g_engine_defaults_tab(G_LINE_EVENT_NUM).price_flag         := 'Y';

     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).pricing_event_num  := G_CHARGE_EVENT_NUM;
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).pricing_event_code := G_CHARGE_EVENT_CODE;
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).request_type_code  := 'ONT';
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).line_type_code     := 'LINE';
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).price_flag         := 'Y';
     */

    -- Load the defaults table
     g_engine_defaults_tab(G_LINE_EVENT_NUM).pricing_event_num  := G_LINE_EVENT_NUM;
     g_engine_defaults_tab(G_LINE_EVENT_NUM).pricing_event_code := G_LINE_EVENT_CODE;
     g_engine_defaults_tab(G_LINE_EVENT_NUM).request_type_code  := 'FTE';
     g_engine_defaults_tab(G_LINE_EVENT_NUM).line_type_code     := 'LINE';
     g_engine_defaults_tab(G_LINE_EVENT_NUM).price_flag         := 'Y';

     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).pricing_event_num  := G_CHARGE_EVENT_NUM;
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).pricing_event_code := G_CHARGE_EVENT_CODE;
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).request_type_code  := 'FTE';
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).line_type_code     := 'LINE';
     g_engine_defaults_tab(G_CHARGE_EVENT_NUM).price_flag         := 'Y';

END FTE_QP_ENGINE;

/
