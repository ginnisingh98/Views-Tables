--------------------------------------------------------
--  DDL for Package Body QP_CALCULATE_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CALCULATE_PRICE_PUB" AS
  /* $Header: QPXPCLPB.pls 120.22.12010000.3 2009/12/18 05:47:04 jputta ship $ */

  l_debug VARCHAR2(3);
  l_line_index NUMBER; -- for accum range break
  l_prev_list_line_id NUMBER; -- accum range break
  l_accum_global NUMBER; -- accum range break
  l_prev_order_id NUMBER; -- accum range break
  l_prev_line_index NUMBER; -- accum range break
  l_accum_context_cache QP_LIST_LINES.ACCUM_CONTEXT%TYPE; -- accum range break
  l_accum_attrib_cache QP_LIST_LINES.ACCUM_ATTRIBUTE%TYPE; -- accum range break
  l_accum_flag_cache QP_LIST_LINES.ACCUM_ATTR_RUN_SRC_FLAG%TYPE; -- accum range break
  l_accum_list_line_no_cache QP_LIST_LINES.LIST_LINE_NO%TYPE; -- accum range break


  --4900095
  G_Lumpsum_Qty NUMBER;
  --private function to return service quantity
  FUNCTION Get_lumpsum_qty(p_line_index NUMBER, p_line_detail_index NUMBER
                           , p_modifier_level_code VARCHAR2)
  RETURN NUMBER IS
  x_lumpsum_qty NUMBER;
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Get_Lumpsum_Qty ..., QPXPCLPB.pls');
      QP_PREQ_GRP.engine_debug('line_index '|| p_line_index
                               ||' line_dtl_index '|| p_line_detail_index
                               ||' level '|| p_modifier_level_code);
      IF QP_PREQ_GRP.G_service_line_qty_tbl.EXISTS(p_line_index) THEN
        QP_PREQ_GRP.engine_debug('line_index qty '
                                 || QP_PREQ_GRP.G_service_line_qty_tbl(p_line_index));
      END IF; --QP_PREQ_GRP.G_service_line_qty_tbl
      IF QP_PREQ_GRP.G_service_line_qty_tbl.EXISTS(p_line_detail_index) THEN
        QP_PREQ_GRP.engine_debug('line_detail_index qty '
                                 || QP_PREQ_GRP.G_service_line_qty_tbl(p_line_detail_index));
      END IF; --QP_PREQ_GRP.G_service_line_qty_tbl
    END IF;
    --4900095
    IF (QP_PREQ_GRP.G_service_line_qty_tbl.EXISTS(p_line_index)
        OR QP_PREQ_GRP.G_service_ldet_qty_tbl.EXISTS(p_line_detail_index)) THEN
      IF p_modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP THEN
        x_lumpsum_qty :=
        nvl(QP_PREQ_PUB.G_Service_pbh_lg_amt_qty(p_line_detail_index),
            QP_PREQ_GRP.G_service_ldet_qty_tbl(p_line_detail_index));
      ELSIF p_modifier_level_code = QP_PREQ_GRP.G_LINE_LEVEL THEN
        x_lumpsum_qty :=
        QP_PREQ_GRP.G_service_line_qty_tbl(p_line_index);
      END IF; --p_modifier_level_code
    END IF; --QP_PREQ_GRP.G_service_line_qty_tbl

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Get_Lumpsum_Qty '|| x_lumpsum_qty);
    END IF;

    RETURN x_lumpsum_qty;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_lumpsum_qty;

  -- Public Calculate_List_Price
  PROCEDURE Calculate_List_Price
  (p_operand_calc_code VARCHAR2,
   p_operand_value NUMBER,
   p_request_qty NUMBER,
   p_rltd_item_price NUMBER,
   p_service_duration NUMBER,
   p_rounding_flag VARCHAR2,
   p_rounding_factor NUMBER,
   x_list_price OUT NOCOPY NUMBER,
   x_percent_price OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_return_status_txt OUT NOCOPY VARCHAR2) AS

  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.Calculate_List_Price';
  v_price_round_options VARCHAR2(30) := NULL; --shu, new rounding

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Calculate_List_Price ..., QPXPCLPB.pls');
    END IF;
    IF (p_operand_calc_code = QP_PREQ_GRP.G_UNIT_PRICE) THEN
      x_list_price := p_operand_value * p_service_duration;
    ELSIF(p_operand_calc_code = QP_PREQ_GRP.G_BLOCK_PRICE) THEN -- block pricing
      IF (p_request_qty = 0) THEN
        x_list_price := 0;
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('In Calculate_List_Price #1');
        END IF;
        x_list_price := (p_operand_value / p_request_qty);
        IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('Request Qty: ' || p_request_qty);
          qp_preq_grp.engine_debug('List Price: ' || x_list_price);
        END IF;
      END IF;
    ELSIF(p_operand_calc_code = QP_PREQ_GRP.G_PERCENT_PRICE) THEN
      x_list_price := (p_operand_value / 100) * p_rltd_item_price * p_service_duration;
      x_percent_price := p_operand_value; -- service duration is not applicable here.Discussion with Alison
    END IF;

    -- ravi passed (-1)*request_line.rounding_factor when calling this procedure, therefore needs to *(-1)
    -- to print the original rounding_factor
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In procedure Calculate_List_Price ...');
      QP_PREQ_GRP.engine_debug('G_ROUNDING_FLAG: '|| QP_PREQ_GRP.G_ROUNDING_FLAG); -- aso rounding, shu, 2457629
      QP_PREQ_GRP.engine_debug('rounding_factor: '|| ( - 1) * p_rounding_factor); -- ravi passed (-1)*request_line.rounding_factor

    END IF;
    IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN

      x_list_price := ROUND(x_list_price, p_rounding_factor);
      x_percent_price := ROUND(x_percent_price, p_rounding_factor);

    ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check v_selling_price_rounding_options profile
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('are we here 2?');
      END IF;
      v_price_round_options := nvl(FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS'), QP_Calculate_Price_PUB.G_NO_ROUND); --shu, new rounding
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('selling_price_rounding_options: '|| v_price_round_options );
      END IF;
      IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN
        x_list_price := ROUND(x_list_price, p_rounding_factor);
        x_percent_price := ROUND(x_percent_price, p_rounding_factor);
      END IF;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('x_list_price' || x_list_price);
    END IF;
    -- end shu new rounding
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Calculate_List_Price;

  -- Local to the calculation Engine
  PROCEDURE Calculate_List_Price_PVT
  (p_operand_calc_code VARCHAR2,
   p_operand_value NUMBER,
   p_recurring_value NUMBER,  -- block pricing
   p_request_qty NUMBER,
   p_rltd_item_price NUMBER,
   p_service_duration NUMBER,
   p_rounding_flag VARCHAR2,
   p_rounding_factor NUMBER,
   x_list_price OUT NOCOPY NUMBER,
   x_percent_price OUT NOCOPY NUMBER,
   x_extended_price OUT NOCOPY NUMBER,  -- block pricing
   x_return_status OUT NOCOPY VARCHAR2,
   x_return_status_txt OUT NOCOPY VARCHAR2) AS

  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.Calculate_List_Price_PVT';
  v_price_round_options VARCHAR2(30) := NULL; --shu, new rounding

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Calculate_List_Price_PVT..., QPXPCLPB.pls');
    END IF;
    IF (p_operand_calc_code IN (QP_PREQ_GRP.G_UNIT_PRICE, QP_PREQ_GRP.G_BREAKUNIT_PRICE)) THEN
      x_list_price := p_operand_value * p_service_duration;
    ELSIF(p_operand_calc_code = QP_PREQ_GRP.G_BLOCK_PRICE) THEN -- block pricing
      IF (p_request_qty = 0) THEN
        x_list_price := 0;
        x_extended_price := p_operand_value;
      ELSE
        IF (p_recurring_value IS NULL) THEN
          IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('In Calculate_List_Price_PVT #1');
          END IF;
          x_list_price := (p_operand_value / p_request_qty);
          x_extended_price := p_operand_value;
          IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Extended Price #1 : ' || x_extended_price);
            qp_preq_grp.engine_debug('Request Qty: ' || p_request_qty);
            qp_preq_grp.engine_debug('List Price: ' || x_list_price);
          END IF;
        ELSE
          IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('In Calculate_List_Price_PVT #2');
          END IF;
          x_list_price := p_operand_value / p_recurring_value;
          x_extended_price := x_list_price * p_request_qty;
          IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Extended Price #2: ' || x_extended_price);
          END IF;
        END IF;
      END IF;
    ELSIF(p_operand_calc_code = QP_PREQ_GRP.G_PERCENT_PRICE) THEN
      x_list_price := (p_operand_value / 100) * p_rltd_item_price * p_service_duration;
      x_percent_price := p_operand_value; -- service duration is not applicable here.Discussion with Alison
    END IF;

    -- ravi passed (-1)*request_line.rounding_factor when calling this procedure, therefore needs to *(-1)
    -- to print the original rounding_factor
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In procedure Calculate_List_Price_PVT...');
      QP_PREQ_GRP.engine_debug('G_ROUNDING_FLAG: '|| QP_PREQ_GRP.G_ROUNDING_FLAG); -- aso rounding, shu, 2457629
      QP_PREQ_GRP.engine_debug('rounding_factor: '|| ( - 1) * p_rounding_factor); -- ravi passed (-1)*request_line.rounding_factor

    END IF;
    IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN

      x_list_price := ROUND(x_list_price, p_rounding_factor);
      x_percent_price := ROUND(x_percent_price, p_rounding_factor);

    ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check v_selling_price_rounding_options profile

      v_price_round_options := nvl(FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS'), QP_Calculate_Price_PUB.G_NO_ROUND); --shu, new rounding
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('selling_price_rounding_options: '|| v_price_round_options );
      END IF;

      IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN
        x_list_price := ROUND(x_list_price, p_rounding_factor);
        x_percent_price := ROUND(x_percent_price, p_rounding_factor);
      END IF;
    END IF; -- end rounding stuff

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('x_list_price' || x_list_price);
    END IF;
    -- end shu new rounding
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Calculate_List_Price_PVT;

  PROCEDURE Calculate_Adjusted_Price
  (p_list_price NUMBER,
   p_discounted_price NUMBER,
   p_old_pricing_sequence NUMBER,
   p_new_pricing_sequence NUMBER,
   p_operand_calc_code VARCHAR2,
   p_operand_value NUMBER,
   p_list_line_type VARCHAR2,
   p_request_qty NUMBER,
   p_accrual_flag VARCHAR2,
   p_rounding_flag VARCHAR2,
   p_rounding_factor NUMBER,
   p_orig_unit_price NUMBER,
   x_discounted_price OUT NOCOPY NUMBER,
   x_adjusted_amount OUT NOCOPY NUMBER,
   x_list_price OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_return_status_txt OUT NOCOPY VARCHAR2) AS

  v_list_price NUMBER;
  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.Calculate_Adjusted_Price';
  v_price_round_options VARCHAR2(30) := NULL; --shu, new rounding

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Calculate_Adjusted_Price...');
    END IF;
    v_price_round_options := FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS'); --shu, new rounding
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('selling_price_rounding_options: '|| v_price_round_options );
      QP_PREQ_GRP.engine_debug('G_ROUNDING_FLAG: '|| QP_PREQ_GRP.G_ROUNDING_FLAG); -- aso rounding, shu, 2457629
    END IF;
    -- ravi passed (-1)*request_line.rounding_factor when calling this procedure, therefore needs to *(-1)
    -- to print the original rounding_factor
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('rounding_factor: '|| ( - 1) * p_rounding_factor); -- ravi passed (-1)*request_line.rounding_factor
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_old_pricing_sequence = p_new_pricing_sequence AND p_new_pricing_sequence IS NOT NULL) THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('I am in Calculate Adjusted Price');
      END IF;

      -- G_BREAKUNIT_PRICE added for FTE breakunit
      IF (p_operand_calc_code IN (QP_PREQ_GRP.G_AMOUNT_DISCOUNT, QP_PREQ_GRP.G_BREAKUNIT_PRICE)) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
          x_adjusted_amount :=  - (p_operand_value);
          IF (p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
          ELSE
            x_discounted_price := p_discounted_price - p_operand_value;
          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN
          x_adjusted_amount := p_operand_value;
          x_discounted_price := p_discounted_price + p_operand_value;

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN
          x_discounted_price := p_discounted_price;
          x_adjusted_amount := p_operand_value;
        END IF; -- end if p_list_line_type

      ELSIF (p_operand_calc_code = QP_PREQ_GRP.G_PERCENT_DISCOUNT) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
          IF (p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
            x_adjusted_amount :=  - (abs(p_list_price) * (p_operand_value / 100));
          ELSE
            --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
            IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
              x_discounted_price := p_discounted_price - ROUND((abs(p_list_price) * (p_operand_value / 100)), p_rounding_factor);
            ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
              IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                x_discounted_price := p_discounted_price - ROUND((abs(p_list_price) * (p_operand_value / 100)), p_rounding_factor);
	      ELSE
		x_discounted_price := p_discounted_price - (abs(p_list_price) * (p_operand_value/100)); --8521107
              END IF;
            ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
              x_discounted_price := p_discounted_price - (abs(p_list_price) * (p_operand_value / 100));
            END IF; -- end if QP_PREQ_GRP.G_ROUNDING_FLAG

            x_adjusted_amount :=  - (abs(p_list_price) * (p_operand_value / 100));
          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN

          --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
          IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
            x_discounted_price := p_discounted_price + ROUND((abs(p_list_price) * (p_operand_value / 100)), p_rounding_factor);
          ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
            IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
              x_discounted_price := p_discounted_price + ROUND((abs(p_list_price) * (p_operand_value / 100)), p_rounding_factor);
	    ELSE
	      x_discounted_price := p_discounted_price + (abs(p_list_price) * (p_operand_value/100)); --8521107
            END IF;
          ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
            x_discounted_price := p_discounted_price + (abs(p_list_price) * (p_operand_value / 100));
          END IF; -- end if QP_PREQ_GRP.G_ROUNDING_FLAG

          x_adjusted_amount := abs(p_list_price) * (p_operand_value / 100);

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN
          x_discounted_price := p_discounted_price;
          x_adjusted_amount := abs(p_list_price) * (p_operand_value / 100);
        END IF; -- end if p_list_line_type

      ELSIF(p_operand_calc_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN

        -- For NewPrice Calculation is same for Discount and Surcharge
        IF (p_list_line_type IN (QP_PREQ_GRP.G_DISCOUNT, QP_PREQ_GRP.G_SURCHARGE)) THEN
          x_discounted_price := p_operand_value;
          x_adjusted_amount :=  - (p_list_price - p_operand_value);
          --fix bug 2353905
          --Negative list price can get correct adjusted_amount
        END IF;

      ELSIF (p_operand_calc_code = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN

          IF (p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
            IF (p_request_qty <> 0) THEN -- ask ravi, how about null?
              x_adjusted_amount :=  - (p_operand_value / p_request_qty);
            ELSE
              x_adjusted_amount := 0; -- bug2385874, should be 0 instead of -p_operand_value
            END IF; -- end if p_request_qty
          ELSE -- else if p_accural_flag

            IF (p_request_qty = 0) THEN -- ask ravi how about null??
              x_discounted_price := p_discounted_price;
              x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
            ELSE

              --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
              IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price - ROUND((p_operand_value / nvl(G_Lumpsum_qty, p_request_qty)), p_rounding_factor);
              ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
                IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                  --4900095 added nvl to G_Lumpsum_qty
                  x_discounted_price := p_discounted_price - ROUND((p_operand_value / nvl(G_Lumpsum_qty, p_request_qty)), p_rounding_factor);
                ELSE
		  x_discounted_price := p_discounted_price - (abs(p_list_price) * (p_operand_value/100)); --8521107
                END IF;
              ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price - (p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty));
              END IF; -- end if QP_PREQ_GRP.G_ROUNDING_FLAG
              --4900095 added nvl to G_Lumpsum_qty
              x_adjusted_amount :=  - (p_operand_value / nvl(G_Lumpsum_qty, p_request_qty));

            END IF; -- end if p_request_qty
          END IF; -- end if p_accural_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN

          IF (p_accrual_flag = QP_PREQ_GRP.G_YES) THEN

            x_discounted_price := p_discounted_price;
            IF (p_request_qty <> 0) THEN -- ask ravi, how about null?
              --4900095 added nvl to G_Lumpsum_qty
              x_adjusted_amount := (p_operand_value / nvl(G_Lumpsum_qty, p_request_qty));
            ELSE
              --x_adjusted_amount := p_operand_value;
              x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
            END IF;

          ELSE -- else if p_accrual_flag

            IF (p_request_qty = 0) THEN
              x_discounted_price := p_discounted_price;
              --x_adjusted_amount := p_operand_value;
              x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
            ELSE
              --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
              IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price + ROUND((p_operand_value / nvl(G_Lumpsum_qty, p_request_qty)), p_rounding_factor);
              ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
                IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                  --4900095 added nvl to G_Lumpsum_qty
                  x_discounted_price := p_discounted_price + ROUND((p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty)), p_rounding_factor);
		ELSE
		  x_discounted_price := p_discounted_price + (abs(p_list_price) * (p_operand_value/100)); --8521107
                END IF;
              ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price + (p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty));
              END IF; -- end if QP_PREQ_GRP.G_ROUNDING_FLAG

              --4900095 added nvl to G_Lumpsum_qty
              x_adjusted_amount := (p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty));
            END IF; -- end if p_request_qty
          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Freight Charge');
            QP_PREQ_GRP.engine_debug('Discounted Price : ' || p_discounted_price);
          END IF;
          x_discounted_price := p_discounted_price;

          IF (p_request_qty = 0) THEN
            x_adjusted_amount := p_operand_value;
          ELSE
            --4900095 added nvl to G_Lumpsum_qty
            x_adjusted_amount := p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty);
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('Adjusted Amount: ' || x_adjusted_amount);
            END IF;
          END IF; -- end IF p_request_qty

        END IF; -- end if p_list_line_type = G_FREIGHT_CHARGE

      END IF; -- end if p_operand_calc_code

      x_list_price := p_list_price;

    ELSE -- else IF (p_old_pricing_sequence = p_new_pricing_sequence AND p_new_pricing_sequence IS NOT NULL)
      -- On Sequence Change , the base price changes to the current discount price

      IF (p_new_pricing_sequence IS NULL) THEN
        v_list_price := p_orig_unit_price;
      ELSE
        v_list_price := p_discounted_price;
      END IF;

      -- G_BREAKUNIT_PRICE added for FTE breakunit
      IF (p_operand_calc_code IN (QP_PREQ_GRP.G_AMOUNT_DISCOUNT, QP_PREQ_GRP.G_BREAKUNIT_PRICE)) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN

          IF(p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
            x_adjusted_amount :=  - (p_operand_value) ;
          ELSE
            x_discounted_price := p_discounted_price - p_operand_value;
            x_adjusted_amount :=  - (p_operand_value) ;
          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN

          x_discounted_price := p_discounted_price + p_operand_value;
          x_adjusted_amount := p_operand_value;

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN
          x_discounted_price := p_discounted_price;
          x_adjusted_amount := p_operand_value;
        END IF; -- end if p_list_line_type

      ELSIF (p_operand_calc_code = QP_PREQ_GRP.G_PERCENT_DISCOUNT) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN

          IF(p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
            x_adjusted_amount :=  - (abs(v_list_price) * (p_operand_value / 100));
          ELSE
            --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
            IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
              x_discounted_price := p_discounted_price - ROUND((abs(v_list_price) * (p_operand_value / 100)), p_rounding_factor);
            ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
              IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                x_discounted_price := p_discounted_price - ROUND((abs(v_list_price) * (p_operand_value / 100)), p_rounding_factor);
              END IF;
            ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
              x_discounted_price := p_discounted_price - (abs(v_list_price) * (p_operand_value / 100));
            END IF; -- end if QP_PREQ_GRP.G_ROUNDING_FLAG

            --x_discounted_price := p_discounted_price - (abs(v_list_price) *(p_operand_value/100));
            x_adjusted_amount :=  - (abs(v_list_price) * (p_operand_value / 100));

          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN -- the sign along with value

          --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
          IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
            x_discounted_price := p_discounted_price + ROUND((abs(v_list_price) * (p_operand_value / 100)), p_rounding_factor);
          ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
            IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
              x_discounted_price := p_discounted_price + ROUND((abs(v_list_price) * (p_operand_value / 100)), p_rounding_factor);
            END IF;
          ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
            x_discounted_price := p_discounted_price + (abs(v_list_price) * (p_operand_value / 100));
          END IF;

          --x_discounted_price := p_discounted_price + (abs(v_list_price) *(p_operand_value/100));
          x_adjusted_amount := abs(v_list_price) * (p_operand_value / 100);

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN
          x_discounted_price := p_discounted_price;
          x_adjusted_amount := abs(v_list_price) * (p_operand_value / 100);
        END IF; -- end if p_list_line_type

      ELSIF (p_operand_calc_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN

        IF (p_list_line_type IN (QP_PREQ_GRP.G_DISCOUNT, QP_PREQ_GRP.G_SURCHARGE)) THEN
          x_discounted_price := p_operand_value;
          x_adjusted_amount :=  - (v_list_price - p_operand_value);
          --fix bug 2353905
          --Negative list price can get correct adjusted_amount
        END IF;

      ELSIF (p_operand_calc_code = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT) THEN

        IF (p_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN

          IF(p_accrual_flag = QP_PREQ_GRP.G_YES) THEN
            x_discounted_price := p_discounted_price;
            IF (p_request_qty = 0) THEN
              --x_adjusted_amount := p_operand_value;
              x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
            ELSE
              --4900095 added nvl to G_Lumpsum_qty
              x_adjusted_amount :=  - (p_operand_value / nvl(G_Lumpsum_qty, p_request_qty));
            END IF; -- end if p_request_qty
          ELSE
            IF (p_request_qty = 0) THEN
              x_discounted_price := p_discounted_price;
              --x_adjusted_amount := p_operand_value;
              x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
            ELSE
              --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
              IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price - ROUND((p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty)), p_rounding_factor);
              ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
                IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                  --4900095 added nvl to G_Lumpsum_qty
                  x_discounted_price := p_discounted_price - ROUND((p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty)), p_rounding_factor);
                END IF;
              ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price - (p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty));
              END IF;

              --4900095 added nvl to G_Lumpsum_qty
              -- x_discounted_price := p_discounted_price - (p_operand_value/nvl(G_Lumpsum_Qty,p_request_qty));
              --4900095 added nvl to G_Lumpsum_qty
              x_adjusted_amount :=  - (p_operand_value / nvl(G_Lumpsum_qty, p_request_qty));
            END IF; -- end if p_request_qty

          END IF; -- end if p_accrual_flag

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN

          IF (p_request_qty = 0) THEN
            x_discounted_price := p_discounted_price;
            --x_adjusted_amount := p_operand_value;
            x_adjusted_amount := 0; --bug2385874, should be 0 instead of p_operand_value
          ELSE
            --IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
            IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
              --4900095 added nvl to G_Lumpsum_qty
              x_discounted_price := p_discounted_price + ROUND((p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty)), p_rounding_factor);
            ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
              IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
                --4900095 added nvl to G_Lumpsum_qty
                x_discounted_price := p_discounted_price + ROUND((p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty)), p_rounding_factor);
              END IF;
            ELSE -- QP_PREQ_GRP.G_ROUNDING_FLAG ='N' or 'U', un-round adjs
              --4900095 added nvl to G_Lumpsum_qty
              x_discounted_price := p_discounted_price + (p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty));
            END IF; -- end if p_request_qty

            --4900095 added nvl to G_Lumpsum_qty
            -- x_discounted_price := p_discounted_price + (p_operand_value/nvl(G_Lumpsum_Qty,p_request_qty));
            x_adjusted_amount := p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty);

          END IF; -- end if p_request_qty

        ELSIF (p_list_line_type = QP_PREQ_GRP.G_FREIGHT_CHARGE) THEN
          x_discounted_price := p_discounted_price;

          IF (p_request_qty = 0) THEN
            x_adjusted_amount := p_operand_value;
          ELSE
            --4900095 added nvl to G_Lumpsum_qty
            x_adjusted_amount := p_operand_value / nvl(G_Lumpsum_Qty, p_request_qty);
          END IF;
        END IF; -- end if p_list_line_type
      END IF; -- end if p_operand_calc_code

      x_list_price := v_list_price;

    END IF; -- end IF (p_old_pricing_sequence = p_new_pricing_sequence AND p_new_pricing_sequence IS NOT NULL)

    -- round it all
    -- IF (v_round_individual_adj_flag = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu
    IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN -- shu, new rounding
      x_adjusted_amount := ROUND(x_adjusted_amount, p_rounding_factor);
    ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile
      IF (v_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN -- do not round if profile is null
        x_adjusted_amount := ROUND(x_adjusted_amount, p_rounding_factor);
      END IF;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Calculate_Adjusted_Price;

  PROCEDURE Process_Price_Break(
                                p_list_line_id NUMBER,  -- list line id, used for accum range break
                                p_list_line_index NUMBER,  -- PBH Line Detail Index
                                p_operand_calc_code VARCHAR, -- PBH arithmetic operator
                                p_list_line_qty NUMBER,  -- Ordered Qty
                                p_actual_line_qty NUMBER,  -- Line Qty, 2388011 pbh_grp_amt
                                p_pbh_type VARCHAR2,
                                p_list_price NUMBER,  -- Applicable when it is discount break
                                p_discounted_price NUMBER,
                                p_old_pricing_grp_seq NUMBER,
                                p_related_item_price NUMBER,  -- Applicable in case of service item
                                p_service_duration NUMBER,
                                p_related_request_lines l_related_request_lines_tbl,
                                p_rounding_flag VARCHAR2,
                                p_rounding_factor NUMBER,
                                p_group_value NUMBER := 0,  -- LINEGROUP, 2388011 pbh_grp_amt
                                x_pbh_list_price OUT NOCOPY NUMBER,
                                x_pbh_extended_price OUT NOCOPY NUMBER,  -- block pricing
                                x_adjustment_amount OUT NOCOPY NUMBER,
                                x_related_request_lines_tbl OUT NOCOPY l_related_request_lines_tbl,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_txt OUT NOCOPY VARCHAR2) AS

  v_temp NUMBER := 0;
  v_ord_qty NUMBER;
  v_count NUMBER := 0;
  v_index NUMBER := 0;
  v_total_amount NUMBER := 0;
  v_discounted_price NUMBER;
  v_operand_calc_code VARCHAR2(30);
  v_operand_value NUMBER;
  v_old_pricing_sequence NUMBER;
  v_zero_count NUMBER;
  x_discounted_price NUMBER;
  x_list_price NUMBER;
  x_percent_price NUMBER;
  x_extended_price NUMBER; -- block pricing
  x_adjusted_amount NUMBER;
  v_related_request_lines l_related_request_lines_tbl;
  x_ret_status VARCHAR2(30);
  x_ret_status_txt VARCHAR2(240);
  k NUMBER;
  l_precision NUMBER;
  l_value_from_precision NUMBER;
  l_value_to_precision NUMBER;
  l_difference NUMBER;
  l_satisfied_value NUMBER;
  l_qualifier_value NUMBER; -- 2388011, 2388011 pbh_grp_amt
  v_attribute_value_per_unit NUMBER; --2388011_latest
  v_calculate_per_unit_flag VARCHAR2(1);
  l_price_round_options VARCHAR2(30) := NULL;

  -- 4061138, 5183755 continuous price breaks
  CURSOR get_continuous_flag_cur IS
    SELECT nvl(continuous_price_break_flag, 'N')
    FROM   qp_list_lines
    WHERE  list_line_id = p_list_line_id;

  l_continuous_flag VARCHAR2(1) := 'N';
  l_prorated_flag VARCHAR2(1) := 'N';

  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.Process_Price_Break';

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    v_related_request_lines := p_related_request_lines;
    v_old_pricing_sequence := p_old_pricing_grp_seq;

    -- 4061138, 5183755
    OPEN get_continuous_flag_cur;
    FETCH get_continuous_flag_cur INTO l_continuous_flag;
    CLOSE get_continuous_flag_cur;

    k := p_related_request_lines.FIRST;
    WHILE (k IS NOT NULL)
      LOOP
      IF (p_related_request_lines(k).LINE_DETAIL_INDEX = p_list_line_index) THEN
        IF l_debug = FND_API.G_TRUE THEN
          IF l_continuous_flag = 'Y' THEN
            QP_PREQ_GRP.engine_debug ('<-------- CONTINUOUS PRICE BREAK -------->');
          ELSE
            QP_PREQ_GRP.engine_debug ('<---------------------------------------->');
          END IF;
          QP_PREQ_GRP.engine_debug ('p_list_line_id: '|| p_list_line_id);
          QP_PREQ_GRP.engine_debug ('p_list_line_index: '|| p_list_line_index);
        END IF; -- END IF l_debug = FND_API.G_TRUE

        -- 4061138
        -- check if PBH is prorated, important for continuous processing later
        IF l_continuous_flag = 'Y' AND QP_PREQ_GRP.G_BREAK_UOM_PRORATION = 'Y'
          THEN
          BEGIN
            SELECT 'Y' INTO l_prorated_flag
            FROM qp_npreq_ldets_tmp
            WHERE line_detail_index = p_list_line_index
            AND break_uom_code IS NOT NULL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_prorated_flag := 'N';
          END;
        END IF;

        IF (p_related_request_lines(k).PRICE_BREAK_TYPE_CODE = QP_PREQ_GRP.G_POINT_BREAK) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('i am in Point break'); -- shu dbg 2388011
            QP_PREQ_GRP.engine_debug ('p_group_value: '|| p_group_value); -- shu dbg 2388011
            QP_PREQ_GRP.engine_debug ('p_list_line_qty: '|| p_list_line_qty); -- shu dbg 2388011
          END IF; -- END IF l_debug = FND_API.G_TRUE

          -- 2388011, Applicable for group of lines based PBH
          v_ord_qty := p_list_line_qty; -- Store the ordered qty
          --IF (p_group_value > - 1) THEN --[julin/5158413]
	  IF (p_group_value > 0) THEN --6896139 undoing changes done as part of bug 5158413
            v_temp := p_group_value;
          ELSE
            v_temp := p_list_line_qty;
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('v_temp, for evaluation (either p_group_value or p_list_line_qty): '|| v_temp); -- shu dbg 2388011
          END IF; -- END IF l_debug = FND_API.G_TRUE

          -- If it falls in the range
          /* rewritten for 4061138
	 IF (v_temp >= p_related_request_lines(k).VALUE_FROM AND  --2388011
           v_temp <= nvl(p_related_request_lines(k).VALUE_TO,v_temp)) THEN --2388011, 2 changes
         */
          IF ((l_continuous_flag <> 'Y' AND
               v_temp BETWEEN p_related_request_lines(k).VALUE_FROM AND nvl(p_related_request_lines(k).VALUE_TO, v_temp))
              OR
              (l_continuous_flag = 'Y' AND
               p_related_request_lines(k).VALUE_FROM < v_temp AND
               v_temp <= nvl(p_related_request_lines(k).VALUE_TO, v_temp)) )
            THEN
            v_related_request_lines(k).LINE_QTY := v_temp; -- PBH line qty/v_ord_qty, 2388011

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug ('PBH operand Calc Code : ' || p_operand_calc_code);
            END IF;

            -- Do not calculate per unit satisfied value if it is BLOCK_PRICING
            IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
              IF (p_operand_calc_code = 'BLOCK_PRICE') THEN
                v_calculate_per_unit_flag := 'N';
              ELSE
                v_calculate_per_unit_flag := 'Y';
              END IF;
            ELSE
              v_calculate_per_unit_flag := 'Y';
            END IF;
            -- for FTE breakunit
            -- also do not calculate per unit value if line is BREAKUNIT_PRICE
            IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_BREAKUNIT_PRICE) THEN
              v_calculate_per_unit_flag := 'N';
            END IF;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug ('Calculate Per Unit Flag : ' || v_calculate_per_unit_flag);
            END IF;

            -- This happens only if it is line group based Applicable for both Linegroup Amount and Item Amount
            -- 2388011_new
            IF (p_group_value > 0 AND v_calculate_per_unit_flag = 'Y') THEN
              v_attribute_value_per_unit := p_group_value / p_list_line_qty; -- 2388011_latest
              v_related_request_lines(k).LINE_QTY := v_temp / v_attribute_value_per_unit; -- 2388011_latest
            ELSE
              v_related_request_lines(k).LINE_QTY := v_temp;
            END IF;


            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('List Line Quantity: ' || v_related_request_lines(k).LINE_QTY );
              QP_PREQ_GRP.engine_debug('PBH Type: ' || p_pbh_type);
            END IF; -- END IF l_debug = FND_API.G_TRUE

            -- Call the Calculate List Price Function
            IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
              Calculate_List_Price_PVT(
                                       p_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_related_request_lines(k).OPERAND_VALUE,
                                       p_related_request_lines(k).RECURRING_VALUE,  -- block pricing
                                       v_ord_qty,  -- 2388011_new, for calculation
                                       p_related_item_price,
                                       p_service_duration,
                                       QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor,
                                       x_list_price,
                                       x_percent_price,
                                       x_extended_price,
                                       x_ret_status,
                                       x_ret_status_txt);

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final list price after break evaluation
              -- changed for block pricing
              IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = qp_preq_grp.G_BLOCK_PRICE) THEN
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_extended_price;
              ELSE
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_list_price;
              END IF;

              x_pbh_list_price := x_list_price;
              x_pbh_extended_price := x_extended_price; -- block pricing

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('final list price after break evaluation..');
                QP_PREQ_GRP.engine_debug('List Line Price: ' || v_related_request_lines(k).ADJUSTMENT_AMOUNT );
                QP_PREQ_GRP.engine_debug('List Line Price: ' || x_pbh_list_price );
              END IF; -- END IF l_debug = FND_API.G_TRUE

            ELSE -- DIS/SUR/FREIGHT_CHARGE

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('I am in Discount Break');
                QP_PREQ_GRP.engine_debug('List Price: ' || p_list_price);
                QP_PREQ_GRP.engine_debug('Discounted Price: ' || p_discounted_price);
                QP_PREQ_GRP.engine_debug('Old Pricing Seq: ' || v_old_pricing_sequence);
                QP_PREQ_GRP.engine_debug('New Pricing Seq: ' || v_related_request_lines(k).PRICING_GROUP_SEQUENCE);
              END IF; -- END IF l_debug = FND_API.G_TRUE

              Calculate_Adjusted_Price(p_list_price => p_list_price,  -- List Price
                                       p_discounted_price => p_discounted_price,
                                       p_old_pricing_sequence => nvl(v_old_pricing_sequence,
                                                                     v_related_request_lines(k).PRICING_GROUP_SEQUENCE),
                                       p_new_pricing_sequence => v_related_request_lines(k).PRICING_GROUP_SEQUENCE,
                                       p_operand_calc_code => v_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_operand_value => v_related_request_lines(k).OPERAND_VALUE,
                                       p_list_line_type => v_related_request_lines(k).RELATED_LIST_LINE_TYPE,
                                       --p_request_qty          => v_related_request_lines(k).LINE_QTY, -- 2388011,
                                       p_request_qty => p_list_line_qty,  -- 2388011_new
                                       p_accrual_flag => v_related_request_lines(k).ACCRUAL_FLAG,
                                       p_rounding_flag => QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor => p_rounding_factor,
                                       p_orig_unit_price => p_list_price,
                                       x_discounted_price => x_discounted_price,  -- Output Discounted Price
                                       x_adjusted_amount => x_adjusted_amount,  -- Discount amount for this line
                                       x_list_price => x_list_price,  -- Output List Price
                                       x_return_status => x_ret_status,
                                       x_return_status_txt => x_ret_status_txt);

              v_old_pricing_sequence := v_related_request_lines(k).PRICING_GROUP_SEQUENCE;

              IF (x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final selling price after break evaluation for this discount line
              v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_adjusted_amount;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Adjusted Line Amount: ' || v_related_request_lines(k).ADJUSTMENT_AMOUNT);
              END IF; -- END IF l_debug = FND_API.G_TRUE
            END IF; -- END IF (p_pbh_type in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER))

            -- ELSE IF (v_temp >= p_related_request_lines(k).VALUE_FROM AND...
          ELSE -- Store the break line which did not satisfy with qty 0,for other related lines
            v_related_request_lines(k).LINE_QTY := 0;
            -- This is the final list price or selling price after break evaluation
            IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN

              Calculate_List_Price_PVT(
                                       p_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_related_request_lines(k).OPERAND_VALUE,
                                       p_related_request_lines(k).RECURRING_VALUE,  -- block pricing
                                       0,  -- p_request_qty = 0
                                       p_related_item_price,
                                       p_service_duration,
                                       QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor,
                                       x_list_price,
                                       x_percent_price,
                                       x_extended_price,  -- block pricing
                                       x_ret_status,
                                       x_ret_status_txt);

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || x_ret_status_txt);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF; -- END IF(x_ret_status = FND_API.G_RET_STS_ERROR)

              -- This is the final list price after break evaluation
              -- modified for block pricing
              IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = qp_preq_grp.G_BLOCK_PRICE) THEN
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_extended_price;
              ELSE
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_list_price;
              END IF;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('List Line Price: ' || v_related_request_lines(k).ADJUSTMENT_AMOUNT );
              END IF;

            ELSE --DIS/SUR/FREIGHT_CHARGE

              Calculate_Adjusted_Price(p_list_price => p_list_price,  -- List Price
                                       p_discounted_price => p_discounted_price,
                                       p_old_pricing_sequence => nvl(v_old_pricing_sequence,
                                                                     v_related_request_lines(k).PRICING_GROUP_SEQUENCE),
                                       p_new_pricing_sequence => v_related_request_lines(k).PRICING_GROUP_SEQUENCE,
                                       p_operand_calc_code => v_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_operand_value => v_related_request_lines(k).OPERAND_VALUE,
                                       p_list_line_type => v_related_request_lines(k).RELATED_LIST_LINE_TYPE,
                                       p_request_qty => 0,  -- p_request_qty
                                       p_accrual_flag => v_related_request_lines(k).ACCRUAL_FLAG,
                                       p_rounding_flag => QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor => p_rounding_factor,
                                       p_orig_unit_price => p_list_price,
                                       x_discounted_price => x_discounted_price,  -- Output Discounted Price
                                       x_adjusted_amount => x_adjusted_amount,  -- Discount amount for this line
                                       x_list_price => x_list_price,  -- Output List Price
                                       x_return_status => x_ret_status,
                                       x_return_status_txt => x_ret_status_txt);

              v_old_pricing_sequence := v_related_request_lines(k).PRICING_GROUP_SEQUENCE;

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final selling price after break evaluation for this discount line
              v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_adjusted_amount;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Adjusted Line Amount: ' || x_adjustment_amount);
              END IF; -- END IF l_debug = FND_API.G_TRUE
            END IF; -- END IF (p_pbh_type in (QP_PREQ_GRP.G_PRICE_LIST_HEADER
          END IF; -- END IF (v_temp >= p_related_request_lines(k).VALUE_FROM AND

          -- RANGE BREAK
        ELSIF (p_related_request_lines(k).PRICE_BREAK_TYPE_CODE = QP_PREQ_GRP.G_RANGE_BREAK) THEN

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('I am in Range Break');
            QP_PREQ_GRP.engine_debug('The value of v_count is:' || v_count );
          END IF;

          IF (v_count = 0) THEN
            -- begin 2388011, grp_lines_pbh
            IF (p_group_value > 0 ) THEN -- Ravi Change
              l_qualifier_value := p_group_value;
              v_temp := p_group_value;
            ELSE
              l_qualifier_value := p_list_line_qty;
              v_temp := p_list_line_qty;
            END IF;
            -- end 2388011
            v_ord_qty := p_list_line_qty;
          END IF; -- end IF (v_count = 0)

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('p_group_value: ' || p_group_value); -- shu debug, 2388011
            QP_PREQ_GRP.engine_debug('p_list_line_qty (v_ord_qty): ' || p_list_line_qty); -- shu debug, 2388011
            QP_PREQ_GRP.engine_debug('l_qualifier_value (either p_group_value or p_list_line_qty): ' || l_qualifier_value); -- shu debug, 2388011
            QP_PREQ_GRP.engine_debug('v_temp (either p_group_value or p_list_line_qty): ' || v_temp); -- shu debug, 2388011
          END IF; -- END IF l_debug = FND_API.G_TRUE

          -- The check to see if the ordered quantity falls in the range needs to be done only once
          -- Ex: If Ord Qty = 50 and 100-null then u do not get it

          IF (p_related_request_lines(k).VALUE_FROM > v_temp AND v_count = 0) THEN --2388011
            v_temp := 0;
          END IF;

          IF (v_temp > 0) THEN

            -- Ex: 100-NULL
            IF (p_related_request_lines(k).VALUE_TO IS NULL) THEN
              v_related_request_lines(k).LINE_QTY := v_temp;
            ELSE
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('C100# value from: ' || p_related_request_lines(k).value_from);
                QP_PREQ_GRP.engine_debug('C200# value to: ' || p_related_request_lines(k).value_to);
                QP_PREQ_GRP.engine_debug('C300# Qualifier Value: ' || l_qualifier_value); --2388011
                QP_PREQ_GRP.engine_debug('C400# Group Amount: ' || p_group_value); --2388011
              END IF; -- END IF l_debug = FND_API.G_TRUE

              Get_Satisfied_Range(
                                  p_related_request_lines(k).value_from,
                                  p_related_request_lines(k).value_to,
                                  l_qualifier_value,  --2388011
                                  p_list_line_id,  -- for accum range break
                                  l_continuous_flag,  -- 4061138
                                  l_prorated_flag,  -- 4061138
                                  l_satisfied_value);

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('C500#: ' || l_satisfied_value);
                QP_PREQ_GRP.engine_debug('C600# list price : ' || p_list_price);
              END IF; -- END IF l_debug = FND_API.G_TRUE

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug ('PBH operand Calc Code : ' || p_operand_calc_code);
              END IF;

              -- Do not calculate the per unit satisfied value if it is BLOCK_PRICING
              IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
                IF (p_operand_calc_code = 'BLOCK_PRICE') THEN
                  v_calculate_per_unit_flag := 'N';
                ELSE
                  v_calculate_per_unit_flag := 'Y';
                END IF;
              ELSE
                v_calculate_per_unit_flag := 'Y';
              END IF;
              -- for FTE breakunit
              -- also do not calculate per unit value if line is BREAKUNIT_PRICE
              IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_BREAKUNIT_PRICE) THEN
                v_calculate_per_unit_flag := 'N';
              END IF;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug ('Calculate Per Unit Flag : ' || v_calculate_per_unit_flag);
              END IF;

              -- 2388011_new
              -- Ravi Change Applicable for both linegroup Group Amount and Line Item Amt
              IF (p_group_value > 0 AND v_calculate_per_unit_flag = 'Y') THEN
                v_attribute_value_per_unit := p_group_value / p_list_line_qty; -- 2388011_latest
                v_related_request_lines(k).LINE_QTY := l_satisfied_value / v_attribute_value_per_unit; -- 2388011_latest
              ELSE
                v_related_request_lines(k).LINE_QTY := l_satisfied_value;
              END IF;

              v_temp := v_temp - l_satisfied_value;

              -- shu, fix bug 2372064
              -- l_satisfied_value is 0 have 2 cases: 1) no more to satisfied 2) from=to such as 0-0 break
              -- only for case 1) should reset v_temp
              -- for accum range break, case 1 should take into account accum_value
              -- to determine if no more need to be satisfied:
              --    if (stored accum value + l_qualifier) < value_to
              --    then no more satisfied
              IF (l_satisfied_value = 0
                  AND p_related_request_lines(k).value_from <> p_related_request_lines(k).value_to
                  AND l_accum_global + l_qualifier_value < p_related_request_lines(k).value_to)
                THEN
                v_temp := 0;
              END IF; -- END IF (l_satisfied_value = 0

            END IF; -- END IF (p_related_request_lines(k).VALUE_TO IS NULL)

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('List Line Quantity: ' || v_related_request_lines(k).LINE_QTY );
              QP_PREQ_GRP.engine_debug('Temp: ' || v_temp );
            END IF;

            IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
              -- Call the Calculate List Price Function
              Calculate_List_Price_PVT(
                                       p_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_related_request_lines(k).OPERAND_VALUE,
                                       p_related_request_lines(k).RECURRING_VALUE,  -- block pricing
                                       --v_ord_qty, -- 2388011_new
                                       v_related_request_lines(k).LINE_QTY,  -- new fix, error found in block pricing
                                       p_related_item_price,
                                       p_service_duration,
                                       QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       NULL,  -- fix bug 2724697, null rounding_factor so operand does not get rounded, it will be rounded later at Average Out PBH Lines
                                       x_list_price,
                                       x_percent_price,
                                       x_extended_price,  -- block pricing
                                       x_ret_status,
                                       x_ret_status_txt);

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final list price after break evaluation
              -- modified for block pricing
              IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = qp_preq_grp.G_BLOCK_PRICE) THEN
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_extended_price;
              ELSE
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_list_price;
              END IF;

            ELSE -- DIS/SUR/FREIGHT_CHARGE
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('I am in Discount Break (RANGE BLOCK)');
                QP_PREQ_GRP.engine_debug('OPERAND_VALUE: '|| v_related_request_lines(k).OPERAND_VALUE); --shu debug 2388011
                QP_PREQ_GRP.engine_debug('LINE_QTY: '|| v_related_request_lines(k).LINE_QTY); --shu debug 2388011
                QP_PREQ_GRP.engine_debug('l_qualifier_value (p_request_qty)'|| l_qualifier_value); --shu debug 2388011
              END IF;

              --p_request_qty          => l_qualifier_value,
              -- 2388011, range break should be total amount not l_satisfied_value
              --p_request_qty          => p_list_line_qty,
              -- group quantity,group value or item quantity 2388011_new

              Calculate_Adjusted_Price(
                                       p_list_price => p_list_price,  -- List Price
                                       p_discounted_price => p_discounted_price,
                                       p_old_pricing_sequence => nvl(v_old_pricing_sequence,
                                                                     v_related_request_lines(k).PRICING_GROUP_SEQUENCE),
                                       p_new_pricing_sequence => v_related_request_lines(k).PRICING_GROUP_SEQUENCE,
                                       p_operand_calc_code => v_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_operand_value => v_related_request_lines(k).OPERAND_VALUE,
                                       p_list_line_type => v_related_request_lines(k).RELATED_LIST_LINE_TYPE,
                                       p_request_qty => v_related_request_lines(k).LINE_QTY,  --always satisfied qty
                                       p_accrual_flag => v_related_request_lines(k).ACCRUAL_FLAG,
                                       p_rounding_flag => QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor => p_rounding_factor,
                                       p_orig_unit_price => p_list_price,
                                       x_discounted_price => x_discounted_price,  -- Output Discounted Price
                                       x_adjusted_amount => x_adjusted_amount,  -- Discount amount for this line
                                       x_list_price => x_list_price,  -- Output List Price
                                       x_return_status => x_ret_status,
                                       x_return_status_txt => x_ret_status_txt);

              v_old_pricing_sequence := v_related_request_lines(k).PRICING_GROUP_SEQUENCE;

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final list price after break evaluation
              v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_adjusted_amount;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Adjusted Line Amount: ' || x_adjusted_amount);
              END IF;
            END IF;

            v_count := v_count + 1;
          ELSE -- v_temp > 0

            -- Store the break line which did not satisfy with qty 0
            v_related_request_lines(k).LINE_QTY := 0;
            -- This is the final list price or selling price after break evaluation
            IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN

              Calculate_List_Price_PVT(p_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_related_request_lines(k).OPERAND_VALUE,
                                       p_related_request_lines(k).RECURRING_VALUE,  -- block pricing
                                       0,
                                       p_related_item_price,
                                       p_service_duration,
                                       QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       NULL,  -- fix bug 2724697, null rounding_factor so operand does not get rounded, it will be rounded later at Average Out PBH Lines
                                       x_list_price,
                                       x_percent_price,
                                       x_extended_price,
                                       x_ret_status,
                                       x_ret_status_txt);

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final list price after break evaluation
              -- modified for block pricing
              IF (p_related_request_lines(k).OPERAND_CALCULATION_CODE = qp_preq_grp.G_BLOCK_PRICE) THEN
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_extended_price;
              ELSE
                v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_list_price;
              END IF;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('List Line Price: ' || x_list_price);
              END IF;

            ELSE -- DIS/SUR/FREIGHT_CHARGE

              Calculate_Adjusted_Price(
                                       p_list_price => p_list_price,  -- List Price
                                       p_discounted_price => p_discounted_price,
                                       p_old_pricing_sequence => nvl(v_old_pricing_sequence
                                                                     , v_related_request_lines(k).PRICING_GROUP_SEQUENCE),
                                       p_new_pricing_sequence => v_related_request_lines(k).PRICING_GROUP_SEQUENCE,
                                       p_operand_calc_code =>
                                       v_related_request_lines(k).OPERAND_CALCULATION_CODE,
                                       p_operand_value => v_related_request_lines(k).OPERAND_VALUE,
                                       p_list_line_type => v_related_request_lines(k).RELATED_LIST_LINE_TYPE,
                                       p_request_qty => 0,
                                       p_accrual_flag => v_related_request_lines(k).ACCRUAL_FLAG,
                                       p_rounding_flag => QP_PREQ_GRP.G_ROUNDING_FLAG,
                                       p_rounding_factor => p_rounding_factor,
                                       p_orig_unit_price => p_list_price,
                                       x_discounted_price => x_discounted_price,  -- Output Discounted Price
                                       x_adjusted_amount => x_adjusted_amount,  -- Discount amount for this line
                                       x_list_price => x_list_price,  -- Output List Price
                                       x_return_status => x_ret_status,
                                       x_return_status_txt => x_ret_status_txt);

              v_old_pricing_sequence := v_related_request_lines(k).PRICING_GROUP_SEQUENCE;

              IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- This is the final list price after break evaluation
              v_related_request_lines(k).ADJUSTMENT_AMOUNT := x_adjusted_amount;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('Adjusted Line Amount: ' || x_adjusted_amount);
              END IF;
            END IF;

            v_count := v_count + 1;
          END IF; -- v_temp >0
        END IF; -- POINT or RANGE Break
      END IF; -- p_line_detail_index match

      EXIT WHEN k = v_related_request_lines.LAST;
      k := v_related_request_lines.NEXT(k);
    END LOOP; -- END WHILE (k IS NOT NULL)

    -- This needs to be done only to get the averaged out value for the PBH Line
    IF (v_related_request_lines.COUNT > 0) THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('.........Average out value for the PBH line........ ' );
      END IF;
      v_index := v_related_request_lines.FIRST;
      WHILE (v_index IS NOT NULL)
        LOOP
        IF (v_related_request_lines(v_index).LINE_DETAIL_INDEX = p_list_line_index) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('p_list_line_index '|| p_list_line_index ); -- shu debug 2388011
            QP_PREQ_GRP.engine_debug('p_list_line_qty: '|| p_list_line_qty ); -- shu debug 2388011
            QP_PREQ_GRP.engine_debug('p_actual_line_qty: '|| p_actual_line_qty ); -- shu debug 2388011
          END IF;

          IF (p_pbh_type IN (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
            -- modified for block pricing
            IF (v_related_request_lines(v_index).OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_BLOCK_PRICE) THEN
              IF (v_related_request_lines(v_index).LINE_QTY <> 0) THEN
                v_total_amount := v_total_amount + v_related_request_lines(v_index).ADJUSTMENT_AMOUNT;

                -- fix for OM Pricing/Availability
                IF (v_related_request_lines(v_index).RECURRING_VALUE > 0) THEN
                  v_related_request_lines(v_index).ADJUSTMENT_AMOUNT :=
                  v_related_request_lines(v_index).ADJUSTMENT_AMOUNT / v_related_request_lines(v_index).LINE_QTY;
                END IF;
              ELSE
                -- fix for OM Pricing/Availability
                IF (v_related_request_lines(v_index).RECURRING_VALUE > 0) THEN
                  v_related_request_lines(v_index).ADJUSTMENT_AMOUNT :=
                  v_related_request_lines(v_index).ADJUSTMENT_AMOUNT / v_related_request_lines(v_index).RECURRING_VALUE;
                END IF;
              END IF;
            ELSE
              v_total_amount := v_total_amount + (v_related_request_lines(v_index).LINE_QTY *
                                                  v_related_request_lines(v_index).ADJUSTMENT_AMOUNT);
            END IF;

            -- begin 2388011_new, grp_lines_pbh,
            -- fix 2724697, round here after average out PBH lines

            IF (p_list_line_qty <> 0 ) THEN

              x_pbh_list_price := v_total_amount / p_list_line_qty; -- Divide by grp amount/unit or group quantity
              x_pbh_extended_price := v_total_amount; -- block pricing

            ELSE -- bug 3075286 discussed the solution with rtata

              x_pbh_list_price := v_total_amount;
              x_pbh_extended_price := 0; -- block pricing

            END IF;

            IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES AND p_rounding_factor IS NOT NULL) THEN
              x_pbh_list_price := ROUND (x_pbh_list_price, p_rounding_factor); -- Divide by grp amount/unit or group quantity
            ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check v_selling_price_rounding_options profile
              l_price_round_options := nvl(FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS'), QP_Calculate_Price_PUB.G_NO_ROUND);
              IF (l_price_round_options = G_ROUND_ADJ AND p_rounding_factor IS NOT NULL) THEN
                x_pbh_list_price := ROUND (x_pbh_list_price, p_rounding_factor); -- Divide by grp amount/unit or group quantity
              END IF; -- end if G_ROUND_ADJ
            END IF; --end if rounding stuff

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('x_pbh_list_price: '|| x_pbh_list_price);
            END IF; -- END IF l_debug


          ELSE
            v_total_amount := v_total_amount + (v_related_request_lines(v_index).LINE_QTY *
                                                v_related_request_lines(v_index).ADJUSTMENT_AMOUNT);
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug ('v_index: '|| v_index); --2388011
              QP_PREQ_GRP.engine_debug ('LINE_QTY : '|| v_related_request_lines(v_index).LINE_QTY ); --2388011
              QP_PREQ_GRP.engine_debug ('ADJUSTMENT_AMOUNT for the line: '|| v_related_request_lines(v_index).ADJUSTMENT_AMOUNT); --2388011
              QP_PREQ_GRP.engine_debug ('v_total_amount for now: '|| v_total_amount); --2388011
            END IF; -- END IF l_debug = FND_API.G_TRUE

            -- begin 2388011_new, grp_lines_pbh,


            IF (p_list_line_qty <> 0 ) THEN

              x_adjustment_amount := v_total_amount / p_list_line_qty; -- Divide by grp amount/unit or group quantity

            ELSE -- bug 3075286

              x_adjustment_amount := v_total_amount;

            END IF;

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug ('p_list_line_qty: '|| p_list_line_qty); --2388011
              QP_PREQ_GRP.engine_debug ('x_adjustment_amount: '|| x_adjustment_amount); --2388011
            END IF; -- END IF l_debug = FND_API.G_TRUE
            -- end 2388011, grp_lines_pbh

          END IF; -- END IF (p_pbh_type in (QP_PREQ_GRP.G_PRICE_LIST_HEADER...

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('Total Amount : ' || v_total_amount);
            QP_PREQ_GRP.engine_debug ('Total Qty : ' || v_ord_qty);
            QP_PREQ_GRP.engine_debug ('Total Adjustment : ' || x_adjustment_amount);
          END IF; -- END IF l_debug = FND_API.G_TRUE THEN
        END IF;

        EXIT WHEN v_index = v_related_request_lines.LAST;
        v_index := v_related_request_lines.NEXT(v_index);
      END LOOP;
    END IF;
    x_related_request_lines_tbl := v_related_request_lines;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || x_ret_status_txt);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := x_ret_status_txt;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Process_Price_Break;

  PROCEDURE Calculate_Adjustment(p_price NUMBER
                                 , p_operand_calculation_code VARCHAR2
                                 , p_operand_value NUMBER
                                 , p_priced_quantity NUMBER
                                 , x_calc_adjustment OUT NOCOPY NUMBER
                                 , x_return_status OUT NOCOPY VARCHAR2
                                 , x_return_status_text OUT NOCOPY VARCHAR2) IS

  l_routine VARCHAR2(50) := 'QP_Calculate_Price_PUB.Calculate_Adjustment';

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('In Routine: ' || l_routine);

      -- begin 2892848
      QP_PREQ_GRP.ENGINE_DEBUG('p_price: ' || p_price);
      QP_PREQ_GRP.ENGINE_DEBUG('p_operand_calculation_code: ' || p_operand_calculation_code);
      QP_PREQ_GRP.ENGINE_DEBUG('p_operand_value: ' || p_operand_value);
      QP_PREQ_GRP.ENGINE_DEBUG('p_priced_quantity: ' || p_priced_quantity);
      -- end 2892848

    END IF;
    IF p_operand_calculation_code = QP_PREQ_GRP.G_PERCENT_DISCOUNT THEN
     -- x_calc_adjustment := abs(p_price) * p_operand_value / 100; bug 6122488
     x_calc_adjustment := p_price * p_operand_value / 100;
    ELSIF p_operand_calculation_code = QP_PREQ_GRP.G_AMOUNT_DISCOUNT THEN
      x_calc_adjustment := p_operand_value;
    ELSIF p_operand_calculation_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT THEN
      x_calc_adjustment := (abs(p_price) - p_operand_value);
    ELSIF p_operand_calculation_code = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT THEN
      -- [julin/4571612/4671446] explicitly set FND_API.G_NULL_NUM qty means infinity; this qty and zero qty yield no adj
      IF (p_priced_quantity = FND_API.G_NULL_NUM OR p_priced_quantity = 0) THEN
        x_calc_adjustment := 0;
      ELSE
        x_calc_adjustment := p_operand_value / p_priced_quantity;
      END IF;
    ELSIF p_operand_calculation_code = QP_PREQ_GRP.G_BREAKUNIT_PRICE THEN
      x_calc_adjustment := p_operand_value; -- FTE breakunit
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status_text := l_routine ||' SUCCESS';

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.ENGINE_DEBUG('Out of Routine: ' || l_routine);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in calculating bucket price '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END Calculate_Adjustment;

  PROCEDURE Get_Satisfied_Range(p_value_from NUMBER,
                                p_value_to NUMBER,
                                p_qualifier_value NUMBER,
                                p_list_line_id NUMBER,  -- for accum range break
                                p_continuous_flag VARCHAR,  -- 4061138, continuous price break
                                p_prorated_flag VARCHAR,  -- 4061138
                                x_satisfied_value OUT NOCOPY NUMBER) AS
  l_value_from NUMBER;
  l_precision NUMBER;
  l_difference NUMBER;
  l_value_from_precision NUMBER;
  l_value_to_precision NUMBER;

  -- variables for accumulated range break
  l_new_qualifier NUMBER;
  l_accum NUMBER; -- accumulated value
  l_accum_context VARCHAR2(30);
  l_accum_attrib VARCHAR2(240);
  l_accum_flag VARCHAR2(1);
  v_list_line_no QP_LIST_LINES.LIST_LINE_NO%TYPE;
  v_price_eff_date DATE;
  v_line_id NUMBER;
  l_req_attrs_tbl QP_RUNTIME_SOURCE.accum_req_line_attrs_tbl;
  l_accum_rec QP_RUNTIME_SOURCE.accum_record_type;
  counter PLS_INTEGER := 1;

  -- for accum range break
  -- gets request line attributes to pass to the custom API call
  -- (only the attributes that qualified for the price break in question)
  CURSOR l_req_line_attrs_cur(p_list_line_id NUMBER) IS
    SELECT line_index, attribute_type, context, attribute, value_from, grouping_number
    FROM qp_npreq_line_attrs_tmp
    WHERE list_line_id = p_list_line_id
    AND pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW;

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Procedure : Get_Satisfied_Range');
      QP_PREQ_GRP.engine_debug('               continuous_flag = '|| p_continuous_flag);
      QP_PREQ_GRP.engine_debug('               prorated_flag   = '|| p_prorated_flag);
    END IF;
    l_value_from_precision := power(10, - (length(to_char(abs(p_value_from) - trunc(abs(p_value_from)))) - 1));

    l_value_to_precision := power(10, - (length(to_char(abs(p_value_to) - trunc(abs(p_value_to)))) - 1));

    l_difference := least(l_value_from_precision, l_value_to_precision);

    -- 4061138, precision not needed if continuous break
    IF p_continuous_flag <> 'Y' THEN
      -- if break is prorated, only consider the from precision
      IF p_prorated_flag = 'Y' THEN
        l_precision := l_value_from_precision;
      ELSE
        l_precision := power(10, - (length(to_char(abs(l_difference) - trunc(abs(l_difference)))) - 1));
      END IF;
    ELSE
      l_precision := 0;
    END IF;

    -- 4061138, added p_continuous_flag condition to prevent remapping of a zero-value value_from
    IF (p_value_from = 0 AND p_continuous_flag <> 'Y') THEN
      l_value_from := l_difference;
    ELSE
      l_value_from := p_value_from;
    END IF;

    IF (nvl(FND_PROFILE.VALUE('QP_ACCUM_ATTR_ENABLED'), QP_PREQ_GRP.G_NO) = QP_PREQ_GRP.G_YES AND
        p_list_line_id IS NOT NULL AND
        nvl(QP_PREQ_PUB.G_CALL_FROM_PRICE_BOOK, QP_PREQ_GRP.G_NO) <> QP_PREQ_GRP.G_YES) -- price book
      THEN
      -- fetch accumulation attribute
      -- these are "cached" on the basis of list_line_id
      -- if list_line_id changes, then need to retrieve values from temp table
      -- else use previously cached values
      IF (p_list_line_id = l_prev_list_line_id) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('   list_line_id = '|| p_list_line_id ||', prev = '|| l_prev_list_line_id);
        END IF;
        l_accum_context := l_accum_context_cache;
        l_accum_attrib := l_accum_attrib_cache;
        l_accum_flag := l_accum_flag_cache;
        v_list_line_no := l_accum_list_line_no_cache;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('   using cached values for accum context, attribute, etc.');
        END IF;
      ELSE
        BEGIN
          SELECT accum_context, accum_attribute, accum_attr_run_src_flag, list_line_no
          INTO l_accum_context, l_accum_attrib, l_accum_flag, v_list_line_no
          FROM qp_list_lines
          WHERE list_line_id = p_list_line_id;
          --   from qp_npreq_ldets_tmp
          --   where created_from_list_line_id = p_list_line_id
          --   and rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('   No rows returned for list line ID '|| p_list_line_id);
            END IF;
        END;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('   accum context, attribute, etc. not cached');
        END IF;
        -- cache the values
        l_accum_context_cache := l_accum_context;
        l_accum_attrib_cache := l_accum_attrib;
        l_accum_flag_cache := l_accum_flag;
        l_accum_list_line_no_cache := v_list_line_no;
        l_prev_list_line_id := p_list_line_id;
      END IF;
      IF (l_accum_attrib IS NULL) THEN
        -- conceptually, this means no accumulation processing
        -- in this code, we set accum=0 and let accumulation processing fall through
        l_accum := 0;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('   no accum attribute specified.');
        END IF;
      ELSE
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('   accum attribute = '|| l_accum_attrib);
          QP_PREQ_GRP.engine_debug('   line index = '|| l_line_index);
        END IF;

        -- try to get accum value from request line
        BEGIN
          SELECT DISTINCT value_from
          INTO l_accum
          FROM qp_npreq_line_attrs_tmp
          WHERE line_index = l_line_index -- (l_line_index is a global package variable)
          AND context = l_accum_context
          AND attribute = l_accum_attrib
          AND pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('   accum value '|| l_accum ||' passed on request line.');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('   accum value not passed on request line.');
            END IF;
            -- accum value was not passed on request line
            IF l_accum_flag = 'Y'
              THEN
              ------------------------------------------------------
              -- call the custom API
              -- 1. construct the table of request line attributes
              -- 2. construct the accumulation record
              -- 3. call function Get_numeric_attribute_value
              --
              -- For performance reasons, the code does not follow steps 1,2,3 in order.
              -- One select statement (a cursor) needed for step 1.
              -- Another select needed for steps 2 and 3.
              -- Last select needed to get order id.
              ------------------------------------------------------
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug(' * Calling Custom API for accumulation *');
                QP_PREQ_GRP.engine_debug('   request line attr(s):');
              END IF;
              FOR attrs IN l_req_line_attrs_cur(p_list_line_id) LOOP
                l_req_attrs_tbl(counter).line_index := attrs.line_index;
                l_req_attrs_tbl(counter).attribute_type := attrs.attribute_type;
                l_req_attrs_tbl(counter).context := attrs.context;
                l_req_attrs_tbl(counter).attribute := attrs.attribute;
                l_req_attrs_tbl(counter).VALUE := attrs.value_from;
                l_req_attrs_tbl(counter).grouping_no := attrs.grouping_number;
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('   '|| counter ||': line index '|| attrs.line_index ||', '|| attrs.attribute_type
                                           ||', '|| attrs.context ||', '|| attrs.attribute ||', '|| attrs.value_from
                                           ||', '|| attrs.grouping_number);
                END IF;
                counter := counter + 1;
              END LOOP;

              -- get the order (header) ID if it's null
              -- this should never happen, though
              IF QP_PREQ_GRP.G_ORDER_ID IS NULL THEN
                BEGIN
                  SELECT line_id
                  INTO QP_PREQ_GRP.G_ORDER_ID
                  FROM qp_npreq_lines_tmp
                  WHERE line_type_code = QP_PREQ_GRP.G_ORDER_LEVEL;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    IF l_debug = FND_API.G_TRUE THEN
                      QP_PREQ_GRP.engine_debug(' - summary line not present; cannot get order ID');
                    END IF;
                END;
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug(' ^ G_ORDER_ID was null, select statement got value '|| QP_PREQ_GRP.G_ORDER_ID);
                END IF;
              END IF;

              -- get order line ID and pricing effective date
              -- these values are "cached" on the basis of order_id and line_index
              -- if the composite line_index+order_id changes, then need to retrieve new line_id/eff date
              -- else use the previously cached values
              IF (QP_PREQ_GRP.G_LINE_ID IS NULL OR
                  QP_PREQ_GRP.G_PRICE_EFF_DATE IS NULL OR
                  -- 4613884 bugfix
                  TO_CHAR(l_line_index || QP_PREQ_GRP.G_ORDER_ID) <> TO_CHAR(l_prev_line_index || l_prev_order_id))
                THEN
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('   need to cache line_id, price_eff_date!');
                  QP_PREQ_GRP.engine_debug('    - order_id ('|| qp_preq_grp.G_ORDER_ID ||'), prev_order_id ('|| l_prev_order_id || ')');
                  QP_PREQ_GRP.engine_debug('    - line_index ('|| l_line_index ||'), prev_line_index ('|| l_prev_line_index || ')');
                END IF;
                SELECT lines.line_id, lines.pricing_effective_date
                INTO v_line_id, v_price_eff_date
                FROM qp_npreq_lines_tmp lines
                WHERE lines.line_index = l_line_index;

                QP_PREQ_GRP.G_LINE_ID := v_line_id;
                QP_PREQ_GRP.G_PRICE_EFF_DATE := v_price_eff_date;
                l_prev_order_id := QP_PREQ_GRP.G_ORDER_ID;
                l_prev_line_index := l_line_index;
              ELSE
                IF l_debug = FND_API.G_TRUE THEN
                  QP_PREQ_GRP.engine_debug('   using cached line_id, price_eff_date');
                END IF;
                v_line_id := QP_PREQ_GRP.G_LINE_ID;
                v_price_eff_date := QP_PREQ_GRP.G_PRICE_EFF_DATE;
              END IF;

              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('   order ID '|| QP_PREQ_GRP.G_ORDER_ID ||
                                         ', line ID '|| QP_PREQ_GRP.G_LINE_ID);
              END IF;

              l_accum_rec.p_request_type_code := QP_PREQ_GRP.G_REQUEST_TYPE_CODE;
              l_accum_rec.context := l_accum_context;
              l_accum_rec.attribute := l_accum_attrib;
              IF (l_accum_context = 'VOLUME' AND l_accum_attrib = 'PRICING_ATTRIBUTE19') THEN
                l_accum := QP_TM_RUNTIME_SOURCE.Get_numeric_attribute_value(p_list_line_id,
                                                                            v_list_line_no,
                                                                            QP_PREQ_GRP.G_ORDER_ID,
                                                                            v_line_id,
                                                                            v_price_eff_date,
                                                                            l_req_attrs_tbl,
                                                                            l_accum_rec
                                                                            );
              ELSE
                l_accum := QP_RUNTIME_SOURCE.Get_numeric_attribute_value(p_list_line_id,
                                                                         v_list_line_no,
                                                                         QP_PREQ_GRP.G_ORDER_ID,
                                                                         v_line_id,
                                                                         v_price_eff_date,
                                                                         l_req_attrs_tbl,
                                                                         l_accum_rec
                                                                         );
              END IF;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('   accum value returned from custom API = '|| l_accum);
              END IF;
            ELSE
              -- this case should almost never happen, but if it does, set accum=0
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('***oops.  this should not be here!');
                QP_PREQ_GRP.engine_debug('   Profile Value = '|| FND_PROFILE.VALUE('QP_ACCUM_ATTR_ENABLED'));
              END IF;
              l_accum := 0;
            END IF;
        END;

      END IF; -- if (l_accum_attrib is null)
    ELSE
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' - Accumulation Profile is not enabled');
      END IF;
      l_accum := 0;
    END IF; -- if ACCUM_ATTR_ENABLED profile...

    -- save accumulation value into global variable for Process_Price_Break to use
    l_accum_global := l_accum;

    -- accumulation processing:
    -- if accumulation value, then remap the value_from and offset qualifier value as necessary
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(' * begin accumulation processing (if necessary) *');
    END IF;
    IF p_value_to <= l_accum THEN
      -- skip this break because no quantity is satisfied
      x_satisfied_value := 0;
      l_accum_global := nvl(l_accum_global, 0);
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(' - skipping this break');
      END IF;
      RETURN;
    ELSE
      IF l_accum <> 0 THEN
        -- remap value_from
        l_value_from := greatest(l_value_from, l_accum + l_precision);
      END IF;
      -- when l_accum=0, it means that either
      -- 1. no accumulation processing needed, or
      -- 2. accum has just started
      -- so no need to remap value_from
    END IF;
    -- offset qualifier value if necessary
    l_new_qualifier := l_accum + p_qualifier_value;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('   l_accum = '|| l_accum);
      QP_PREQ_GRP.engine_debug('   l_value_from = '|| l_value_from);
      QP_PREQ_GRP.engine_debug('   l_new_qualifier = '|| l_new_qualifier);
    END IF;

    -- shulin, fix bug 2372064
    -- 4999377, restrict shulin's fix to only 0-0 case
    IF (p_value_from = p_value_to AND p_value_from = 0) THEN -- for cases like 0-0, 2-2, 0.5-0.5
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('value_from is the same as value_to, x_satisfied_value is 0');
      END IF;
      x_satisfied_value := 0;
    ELSIF (l_new_qualifier - l_value_from + l_precision > 0) THEN
      x_satisfied_value := least(l_new_qualifier - l_value_from + l_precision, p_value_to - l_value_from + l_precision);
    ELSE
      x_satisfied_value := 0;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Out of Procedure :  Get_Satisfied_Range');

    END IF;
  END Get_Satisfied_Range;


  -- this procedure is used by QPXPPREB.pls to perform price_break_Calculation

  PROCEDURE Price_Break_Calculation(p_list_line_id NUMBER,
                                    p_break_type VARCHAR2,
                                    p_line_index NUMBER,
                                    p_req_value_per_unit NUMBER,  -- Item qty,group qty,group value
                                    p_applied_req_value_per_unit NUMBER,  -- [julin/4112395/4220399]
                                    p_total_value NUMBER,  -- Total value (Group amount or item amount)
                                    p_list_price NUMBER,
                                    p_line_quantity NUMBER,  -- remove default 0, Acutal quantity on order line
                                    p_bucketed_adjustment NUMBER,
                                    p_bucketed_flag VARCHAR2,
                                    p_automatic_flag VARCHAR2,  -- 5413797
                                    x_adjustment_amount OUT NOCOPY NUMBER,  --2388011_latest
                                    x_return_status OUT NOCOPY VARCHAR2,  --2388011_latest
                                    x_return_status_text OUT NOCOPY VARCHAR2) AS --2388011_latest

  -- 2388011_latest1
  CURSOR get_price_break_details IS
    SELECT  rltd.related_line_detail_index
          , rltd.list_line_id -- for accum range break
          , rltd.related_list_line_id
          , rltd.related_list_line_type
          , rltd.operand_calculation_code
          , rltd.operand
          , rltd.pricing_group_sequence
          , rltd.relationship_type_detail price_break_type
          , rltd.setup_value_from value_from
          , rltd.setup_value_to   value_to
          , rltd.qualifier_value
          , line.line_quantity ordered_qty
          , line.priced_quantity priced_qty
          , line.catchweight_qty catchweight_qty
          , line.actual_order_quantity actual_order_qty
    FROM  qp_npreq_rltd_lines_tmp rltd, qp_npreq_lines_tmp line
    WHERE rltd.list_line_id = p_list_line_id
    AND   rltd.line_index = p_line_index
    AND   line.line_index = p_line_index
    AND   rltd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND   rltd.line_index = line.line_index -- sql repos
    UNION
    SELECT  rltd.related_line_detail_index
          , rltd.list_line_id -- for accum range break
          , rltd.related_list_line_id
          , rltd.related_list_line_type
          , rltd.operand_calculation_code
          , rltd.operand
          , rltd.pricing_group_sequence
          , rltd.relationship_type_detail price_break_type
          , rltd.setup_value_from value_from
          , rltd.setup_value_to   value_to
          , rltd.qualifier_value
          , line.line_quantity ordered_qty
          , line.priced_quantity priced_qty
          , line.catchweight_qty catchweight_qty
          , line.actual_order_quantity actual_order_qty
    FROM  qp_npreq_rltd_lines_tmp rltd, qp_npreq_lines_tmp line
    WHERE QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES
    AND   rltd.line_index = p_line_index
    AND   line_detail_index = p_list_line_id
    AND   line.line_index = p_line_index
    AND   rltd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND   rltd.line_index = line.line_index -- sql repos
    ORDER BY 7, 9;
  -- 5169222 added order by 9 to sort breaks by ascending value from

  pbh_child_rec get_price_break_details%ROWTYPE;

  l_sign NUMBER;
  l_adjustment_amount NUMBER;
  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);

  TYPE pbh_adjustment_rec IS RECORD (
                                     l_related_list_line_id NUMBER,
                                     l_related_line_detail_index NUMBER,
                                     l_adjustment_amount NUMBER,
                                     l_satisfied_value NUMBER,
                                     l_raw_satisfied_value NUMBER); -- 5335689

  TYPE pbh_adjustment_tab IS TABLE OF pbh_adjustment_rec INDEX BY BINARY_INTEGER;
  TYPE pbh_child_tbl IS TABLE OF get_price_break_details%ROWTYPE INDEX BY BINARY_INTEGER;

  pbh_adjustments pbh_adjustment_tab;
  pbh_child_dtl_tbl pbh_child_tbl;

  i NUMBER := 0;
  l_qualifier_value NUMBER := 0;
  l_total_value NUMBER := 0;
  l_satisfied_value NUMBER;
  l_range_adjustment NUMBER := 0;
  l_ord_qty_operand NUMBER := 0;
  l_ord_qty_adj_amt NUMBER := 0;
  v_attribute_value_per_unit NUMBER := 0; --2388011_latest
  l_priced_quantity NUMBER := 0; -- fte breakunit
  l_routine VARCHAR2(50) := 'QP_Calculate_Price_PUB.Price_Break_Calculation';

  -- 4061138, 5183755 continuous price breaks
  CURSOR get_continuous_flag_cur IS
    SELECT nvl(qpll.continuous_price_break_flag, 'N')
    FROM   qp_list_lines qpll, qp_npreq_rltd_lines_tmp rltd
    WHERE  rltd.line_index = p_line_index
    AND    rltd.line_detail_index = p_list_line_id
    AND    rltd.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND    rltd.list_line_id = qpll.list_line_id
    AND    ROWNUM = 1;

  l_continuous_flag VARCHAR2(1) := 'N';
  l_break_qualified VARCHAR2(1) := 'N';
  l_del_index_tbl QP_PREQ_GRP.NUMBER_TYPE;

  BEGIN

    x_adjustment_amount := 0;
    l_line_index := p_line_index; -- accum range break

    -- 4061138, 5183755
    OPEN get_continuous_flag_cur;
    FETCH get_continuous_flag_cur INTO l_continuous_flag;
    CLOSE get_continuous_flag_cur;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In Procedure '|| l_routine || '...');
      IF l_continuous_flag = 'Y' THEN
        QP_PREQ_GRP.engine_debug('---------- CONTINUOUS PRICE BREAK ----------');
      END IF;
      QP_PREQ_GRP.engine_debug('SL with net_amt changes.'); -- 2892848
      QP_PREQ_GRP.engine_debug('p_list_line_id: '|| p_list_line_id);
      QP_PREQ_GRP.engine_debug('p_line_index: '|| p_line_index);
      QP_PREQ_GRP.engine_debug('p_req_value_per_unit: '|| p_req_value_per_unit);
      QP_PREQ_GRP.engine_debug('p_total_value: '|| p_total_value);
      QP_PREQ_GRP.engine_debug('p_list_price: '|| p_list_price); -- 2892848
      QP_PREQ_GRP.engine_debug('p_line_quantity: '|| p_line_quantity);
      QP_PREQ_GRP.engine_debug('p_bucketed_adjustment: '|| p_bucketed_adjustment);
      QP_PREQ_GRP.engine_debug('p_bucketed_flag: '|| p_bucketed_flag);
    END IF;

    OPEN get_price_break_details;

    LOOP
      i := i + 1;

      FETCH get_price_break_details INTO pbh_child_rec;
      EXIT WHEN get_price_break_details%NOTFOUND;

      IF (p_bucketed_flag = 'Y') THEN
        --pbh_child_rec.qualifier_value := p_total_value + nvl(p_bucketed_adjustment*p_line_quantity,0);
        pbh_child_rec.qualifier_value := p_bucketed_adjustment; -- 2892848
      ELSE
        IF (p_total_value > 0) THEN -- ravi_new
          pbh_child_rec.qualifier_value := p_total_value;
        ELSE
          pbh_child_rec.qualifier_value := p_req_value_per_unit;
        END IF;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('PBH Qualifier Value : ' || pbh_child_rec.qualifier_value);
        QP_PREQ_GRP.engine_debug('PBH Value From : ' || pbh_child_rec.value_from);
        QP_PREQ_GRP.engine_debug('PBH Value To : ' || pbh_child_rec.value_to);
        QP_PREQ_GRP.engine_debug('PBH Break Type : ' || p_break_type);
      END IF;

      IF (p_break_type = QP_PREQ_GRP.G_POINT_BREAK) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('i am in POINT block...');
          QP_PREQ_GRP.engine_debug('Before PBH List Line Type : ' || pbh_child_rec.related_list_line_type);
        END IF;

        -- rewritten for 4061138
        IF ((l_continuous_flag <> 'Y' AND
             pbh_child_rec.qualifier_value BETWEEN pbh_child_rec.value_from AND pbh_child_rec.value_to)
            OR
            (l_continuous_flag = 'Y' AND
             pbh_child_rec.value_from < pbh_child_rec.qualifier_value AND
             pbh_child_rec.qualifier_value <= pbh_child_rec.value_to)
            )
          THEN

          l_break_qualified := 'Y'; --[julin/4671446]

          IF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
            l_sign := 1;
          ELSIF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN
            l_sign :=  - 1;
          END IF;

          IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN
            l_sign := 1; -- new price discount/surcharge are the same
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('l sign: '|| l_sign);
          END IF;
          -- fte breakunit
          IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_BREAKUNIT_PRICE AND
              p_total_value > 0)
            THEN
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('fte breakunit price, using p_total_value = '|| p_total_value);
            END IF;
            l_priced_quantity := p_total_value;
          ELSIF (p_applied_req_value_per_unit > 0) THEN -- [julin/4112395/4220399]
            l_priced_quantity := p_applied_req_value_per_unit;
          ELSE
            l_priced_quantity := p_req_value_per_unit;
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('l_priced_quantity '|| l_priced_quantity);
          END IF; --l_debug

          --4900095 lumpsum
          IF pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT
            AND QP_PREQ_GRP.G_service_line_ind_tbl.EXISTS(p_line_index) THEN
            IF QP_PREQ_PUB.G_PBH_MOD_LEVEL_CODE.EXISTS(p_list_line_id)
              AND QP_PREQ_PUB.G_PBH_MOD_LEVEL_CODE(p_list_line_id) = 'LINE' THEN
              l_priced_quantity := nvl(p_applied_req_value_per_unit,
                                       QP_PREQ_GRP.G_service_line_qty_tbl(p_line_index));
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('service line pbh with line level');
              END IF; --l_debug
              --p_request_qty * l_parent_qty;
            ELSIF QP_PREQ_PUB.G_PBH_MOD_LEVEL_CODE.EXISTS(p_list_line_id)
              AND QP_PREQ_PUB.G_PBH_MOD_LEVEL_CODE(p_list_line_id) = 'LINEGROUP' THEN
              l_priced_quantity := nvl(p_applied_req_value_per_unit,
                                       QP_PREQ_GRP.G_service_ldet_qty_tbl(p_list_line_id));
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('service line pbh with linegrp level');
              END IF; --l_debug
            ELSE
              l_priced_quantity := nvl(p_applied_req_value_per_unit, p_req_value_per_unit);
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('non-service line pbh with linegrp level');
              END IF; --l_debug
            END IF; --QP_PREQ_GRP.G_service_line_ind_tbl.exists

            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('lumpsum qty '|| l_priced_quantity);
            END IF; --l_debug
          END IF; --pbh_child_rec.operand_calculation_code

          Calculate_Adjustment(p_list_price,
                               pbh_child_rec.operand_calculation_code,
                               pbh_child_rec.operand * l_sign,
                               --pbh_child_rec.qualifier_value ,
                               --p_req_value_per_unit, -- ravi_new
                               l_priced_quantity,  -- fte breakunit
                               l_adjustment_amount,
                               l_return_status,
                               l_return_status_text);

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('PBH Adjustment : ' || l_adjustment_amount);
          END IF;

          pbh_adjustments(i).l_adjustment_amount := l_adjustment_amount;

          -- begin 2892848
          IF (p_bucketed_flag = 'Y') THEN
            pbh_adjustments(i).l_satisfied_value := pbh_child_rec.qualifier_value;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('POINT net amount break l_satisfied_value: '|| pbh_adjustments(i).l_satisfied_value);
            END IF; -- END IF l_debug
          ELSE -- end 2892848

            -- ravi_new
            IF (p_total_value > 0 AND p_req_value_per_unit <> 0) THEN --6896139 added to avoid divide by zero error
              v_attribute_value_per_unit := p_total_value / p_req_value_per_unit; --2388011_latest
              -- bug 3603096 - commented if..else
              --IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_BREAKUNIT_PRICE) THEN
              pbh_adjustments(i).l_satisfied_value := pbh_child_rec.qualifier_value; -- fte breakunit
              --ELSE
              -- pbh_adjustments(i).l_satisfied_value := pbh_child_rec.qualifier_value/v_attribute_value_per_unit; --2388011_latest
              --END IF;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('p_total_value > 0');
                QP_PREQ_GRP.engine_debug('v_attribute_value_per_unit (p_total_value/p_req_value_per_unit): ' || v_attribute_value_per_unit);
                QP_PREQ_GRP.engine_debug('l_satisfied_value (qualifier_value/v_attribute_value_per_unit): '|| pbh_adjustments(i).l_satisfied_value);
              END IF; -- END IF l_debug
            ELSE
              pbh_adjustments(i).l_satisfied_value := pbh_child_rec.qualifier_value;
              IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.engine_debug('POINT break l_satisfied_value: '|| pbh_adjustments(i).l_satisfied_value);
              END IF; -- END IF l_debug
            END IF; -- END IF (p_total_value > 0)
          END IF; -- END IF (p_bucketed_flag = 'Y') 2892848

          x_adjustment_amount := l_adjustment_amount;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('POINT break x_adjustment_amount: '|| x_adjustment_amount);
          END IF; -- END IF l_debug
          -- fte breakunit
          -- Normally, point breaks assume the adj amt on the header is the same as
          -- the single qualifying child line.  This is true for regular breaks, but
          -- for block pricing (breakunit), the header and line quantity may not be
          -- the same UOM, so need to calculate a different adj amt for the PBH.
          IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_BREAKUNIT_PRICE AND
              p_total_value > 0)
            THEN
            x_adjustment_amount := l_adjustment_amount * l_priced_quantity / p_req_value_per_unit;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('fte breakunit, PBH x_adjustment_amount: '|| x_adjustment_amount);
            END IF;
          END IF;
        ELSE
          pbh_adjustments(i).l_adjustment_amount := NULL;
          pbh_adjustments(i).l_satisfied_value := 0;
        END IF;

        pbh_adjustments(i).l_related_list_line_id := pbh_child_rec.related_list_line_id;
        pbh_adjustments(i).l_related_line_detail_index := pbh_child_rec.related_line_detail_index;
        pbh_child_dtl_tbl(i) := pbh_child_rec;

      ELSIF (p_break_type = QP_PREQ_GRP.G_RANGE_BREAK) THEN

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('i am in RANGE block...');
        END IF; -- END IF l_debug

        IF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
          l_sign := 1;
        ELSIF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN
          l_sign :=  - 1;
        END IF;

        IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN
          l_sign := 1; -- new price discount/surcharge are the same
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l sign: '|| l_sign);
        END IF; -- END IF l_debug

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l_total_value now: '|| l_total_value || ' is used to get_satisfied_range.');
        END IF; -- END IF l_debug

        Get_Satisfied_Range(pbh_child_rec.value_from, pbh_child_rec.value_to, pbh_child_rec.qualifier_value,
                            pbh_child_rec.list_line_id, l_continuous_flag, 'N', l_satisfied_value);

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l_satisfied_range from Get_Satisfied_Range: '|| l_satisfied_value);
        END IF; -- END IF l_debug
        pbh_adjustments(i).l_raw_satisfied_value := l_satisfied_value; -- 5335689
        IF l_satisfied_value > 0 THEN
          l_break_qualified := 'Y'; --[julin/4671446]
        END IF;

        IF (p_bucketed_flag = 'Y') THEN
          pbh_adjustments(i).l_satisfied_value := l_satisfied_value / p_list_price; -- this is the p_price_qty for Calculate_Adjustment
        ELSE
          -- ravi_new
          IF (p_total_value > 0) THEN
            v_attribute_value_per_unit := p_total_value / p_req_value_per_unit; --2388011_latest
            --pbh_adjustments(i).l_satisfied_value  := pbh_child_rec.qualifier_value/v_attribute_value_per_unit; --2388011_latest
            pbh_adjustments(i).l_satisfied_value := l_satisfied_value / v_attribute_value_per_unit; -- SHU diff RAVI
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('p_total_value >= 0');
              QP_PREQ_GRP.engine_debug('v_attribute_value_per_unit (p_total_value/p_req_value_per_unit): ' || v_attribute_value_per_unit);
              QP_PREQ_GRP.engine_debug('l_raw_satisfied_value: ' || pbh_adjustments(i).l_raw_satisfied_value);
              QP_PREQ_GRP.engine_debug('l_satisfied_value assigned back to this child break: '|| pbh_adjustments(i).l_satisfied_value);
            END IF; -- END IF l_debug
          ELSE
            pbh_adjustments(i).l_satisfied_value := l_satisfied_value;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('l_satisfied_value assigned back to this child break: '|| pbh_adjustments(i).l_satisfied_value);
            END IF; -- END IF l_debug
          END IF; -- END IF (p_total_value > 0)
        END IF; -- END IF (p_bucketed_flag = 'Y') THEN

        --If operator is lumpsum and l_satisfied_value is zero do not calculate
        IF l_satisfied_value = 0 THEN
          l_adjustment_amount := NULL;
        ELSE
          Calculate_Adjustment(p_list_price,
                               pbh_child_rec.operand_calculation_code,
                               pbh_child_rec.operand * l_sign,
                               pbh_adjustments(i).l_satisfied_value,  -- SL, p_priced_qty
                               l_adjustment_amount,
                               l_return_status,
                               l_return_status_text);
        END IF;

        pbh_adjustments(i).l_related_list_line_id := pbh_child_rec.related_list_line_id;
        pbh_adjustments(i).l_related_line_detail_index := pbh_child_rec.related_line_detail_index;
        pbh_adjustments(i).l_adjustment_amount := l_adjustment_amount;
        pbh_child_dtl_tbl(i) := pbh_child_rec;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Adjustment : (' || i || ') ' || l_adjustment_amount);
          QP_PREQ_GRP.engine_debug('Satisfied Value : (' || i || ') ' || l_satisfied_value);
          QP_PREQ_GRP.engine_debug('Total Value for next child line: (' || i || ') ' || l_total_value);
        END IF; -- END IF l_debug

      END IF; -- END IF (p_break_type = POINT or RANGE

    END LOOP;

    CLOSE get_price_break_details;

    IF (p_break_type = QP_PREQ_GRP.G_RANGE_BREAK) THEN
      FOR i IN 1 .. pbh_adjustments.COUNT
        LOOP

        l_range_adjustment := l_range_adjustment + nvl(pbh_adjustments(i).l_adjustment_amount *
                                                       pbh_adjustments(i).l_satisfied_value, 0);

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('--- '||'break child '|| i ||' ---');
          QP_PREQ_GRP.engine_debug('l_adjustment_amount: '|| pbh_adjustments(i).l_adjustment_amount);
          QP_PREQ_GRP.engine_debug('l_satisfied_value: '|| nvl(pbh_adjustments(i).l_raw_satisfied_value,
                                                               pbh_adjustments(i).l_satisfied_value));
          QP_PREQ_GRP.engine_debug('l_range_adjustment total: '|| l_range_adjustment);
        END IF; -- END IF l_debug
      END LOOP;
      x_adjustment_amount := l_range_adjustment / p_req_value_per_unit; -- ravi_new
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Range Break Averaged Adjustment : ' || x_adjustment_amount);
      END IF; -- END IF l_debug

    END IF;

    -- Update the adjustments/satisfied ranges info on line details
    IF (QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES) THEN
      IF (pbh_adjustments.COUNT > 0) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('updating child pbh lines '|| pbh_adjustments.COUNT);
          QP_PREQ_GRP.engine_debug('l_break_qualified=' || l_break_qualified);
        END IF; -- END IF l_debug
        IF l_break_qualified = 'Y' THEN
          FOR i IN pbh_adjustments.FIRST .. pbh_adjustments.LAST LOOP
            l_ord_qty_operand := 0;
            l_ord_qty_adj_amt := 0;

            BEGIN
              QP_PREQ_PUB.GET_ORDERQTY_VALUES(p_ordered_qty =>
                                              pbh_child_dtl_tbl(i).ordered_qty,
                                              p_priced_qty =>
                                              pbh_child_dtl_tbl(i).priced_qty,
                                              p_catchweight_qty =>
                                              pbh_child_dtl_tbl(i).catchweight_qty,
                                              p_actual_order_qty =>
                                              pbh_child_dtl_tbl(i).actual_order_qty,
                                              p_operand => pbh_child_dtl_tbl(i).operand,
                                              p_adjustment_amt =>
                                              pbh_adjustments(i).l_adjustment_amount,
                                              p_operand_calculation_code =>
                                              pbh_child_dtl_tbl(i).operand_calculation_code,
                                              p_input_type => 'OPERAND',
                                              x_ordqty_output1 => l_ord_qty_operand,
                                              x_ordqty_output2 => l_ord_qty_adj_amt,
                                              x_return_status => x_return_status,
                                              x_return_status_text => x_return_status_text);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            IF l_debug = FND_API.G_TRUE THEN
              QP_PREQ_GRP.engine_debug('child dtl adj amt '
                                       || pbh_adjustments(i).l_adjustment_amount
                                       ||' l_satisfied_value '|| pbh_adjustments(i).l_satisfied_value
                                       ||' ordqtyadjamt '|| l_ord_qty_adj_amt
                                       ||' order_qty_operand '|| l_ord_qty_operand
                                       ||' dtl index '|| pbh_adjustments(i).l_related_line_detail_index);
            END IF; -- END IF l_debug

            UPDATE qp_npreq_ldets_tmp
                 --changes for bug 2264566 update adjamt on child lines of manualpbh
            SET adjustment_amount =  - (pbh_adjustments(i).l_adjustment_amount),
            --SET adjustment_amount  = l_sign * pbh_adjustments(i).l_adjustment_amount,
                line_quantity = nvl(pbh_adjustments(i).l_raw_satisfied_value,  -- 5335689
                                    pbh_adjustments(i).l_satisfied_value)
                , order_qty_adj_amt =  - (l_ord_qty_adj_amt) -- bug 3285662
                , order_qty_operand = l_ord_qty_operand
            WHERE line_detail_index = pbh_adjustments(i).l_related_line_detail_index
            AND   pricing_status_code IN (QP_PREQ_GRP.G_STATUS_NEW,
                                          --changes for bug 2264566 update adjamt on child lines of manualpbh
                                          QP_PREQ_GRP.G_STATUS_UNCHANGED);
          END LOOP;
        ELSE
          IF p_automatic_flag <> QP_PREQ_PUB.G_NO THEN -- 5413797
            l_del_index_tbl(1) := p_list_line_id;
            QP_Resolve_Incompatability_PVT.Delete_Ldets_Complete(
                                                                 l_del_index_tbl, 'No breaks qualified', x_return_status, x_return_status_text);
          END IF;
        END IF;
      END IF;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in price break calculation: '|| SQLERRM);
      END IF; -- END IF l_debug
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END Price_Break_Calculation;

  PROCEDURE Price_Break_Calculation(p_list_line_id NUMBER,
                                    p_break_type VARCHAR2,
                                    p_line_index NUMBER,
                                    p_request_qty NUMBER,
                                    p_list_price NUMBER,
                                    x_adjustment_amount OUT NOCOPY NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_return_status_text OUT NOCOPY VARCHAR2) AS

  CURSOR get_price_break_details IS
    SELECT  related_line_detail_index
          , related_list_line_id
          , related_list_line_type
          , list_line_id -- for accum range break
          , operand_calculation_code
          , operand
          , pricing_group_sequence
          , relationship_type_detail price_break_type
          , setup_value_from value_from
          , setup_value_to   value_to
          , qualifier_value
    FROM  qp_npreq_rltd_lines_tmp
    WHERE QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_NO
    AND list_line_id = p_list_line_id
    AND   line_index = p_line_index
    AND   pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    --fix for bug 2515762 added the union clause to distinguish between
    --the passed-in rltd lines of PBH modifier versus the engine-inserted
    --when called from public API
    --made corresponding changes in the public API to pass the dtl_index
    UNION
    SELECT  related_line_detail_index
          , related_list_line_id
          , related_list_line_type
          , list_line_id -- for accum range break
          , operand_calculation_code
          , operand
          , pricing_group_sequence
          , relationship_type_detail price_break_type
          , setup_value_from value_from
          , setup_value_to   value_to
          , qualifier_value
    FROM  qp_npreq_rltd_lines_tmp
    WHERE QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES
    AND   line_index = p_line_index
    AND line_detail_index = p_list_line_id
    AND   pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    ORDER BY 7 ;

  pbh_child_rec get_price_break_details%ROWTYPE;

  l_sign NUMBER;
  l_adjustment_amount NUMBER;
  l_return_status VARCHAR2(30);
  l_return_status_text VARCHAR2(240);

  TYPE pbh_adjustment_rec IS RECORD (
                                     l_related_list_line_id NUMBER,
                                     l_related_line_detail_index NUMBER,
                                     l_adjustment_amount NUMBER,
                                     l_satisfied_value NUMBER);

  TYPE pbh_adjustment_tab IS TABLE OF pbh_adjustment_rec INDEX BY BINARY_INTEGER;

  pbh_adjustments pbh_adjustment_tab;

  i NUMBER := 0;
  l_qualifier_value NUMBER := 0;
  l_total_value NUMBER;
  l_satisfied_value NUMBER;
  l_range_adjustment NUMBER := 0;
  l_routine VARCHAR2(50) := 'QP_Calculate_Price_PUB.Price_Break_Calculation';

  -- 4061138, 5183755 continuous price breaks
  CURSOR get_continuous_flag_cur IS
    SELECT nvl(continuous_price_break_flag, 'N')
    FROM   qp_list_lines
    WHERE  QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_NO
    AND    list_line_id = p_list_line_id
    AND    ROWNUM = 1
    UNION
    SELECT nvl(qpll.continuous_price_break_flag, 'N')
    FROM   qp_list_lines qpll, qp_npreq_rltd_lines_tmp rltd
    WHERE  QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES
    AND    rltd.line_index = p_line_index
    AND    rltd.line_detail_index = p_list_line_id
    AND    rltd.list_line_id = qpll.list_line_id
    AND    ROWNUM = 1;

  l_continuous_flag VARCHAR2(1) := 'N';

  BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('#90 p_id '|| p_list_line_id ||' pub_api_call_flg '
                               || QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG);
    END IF;
    x_adjustment_amount := 0;
    l_line_index := p_line_index; -- accum range break
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('#100');

    END IF;

    -- 4061138, 5183755
    OPEN get_continuous_flag_cur;
    FETCH get_continuous_flag_cur INTO l_continuous_flag;
    CLOSE get_continuous_flag_cur;

    OPEN get_price_break_details;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('#101');

    END IF;
    LOOP

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('#102');
      END IF;

      i := i + 1;

      FETCH get_price_break_details INTO pbh_child_rec;
      EXIT WHEN get_price_break_details%NOTFOUND;

      IF (QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES) THEN
        pbh_child_rec.qualifier_value := p_request_qty;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('PBH Qualifier Value : ' || pbh_child_rec.qualifier_value);
        QP_PREQ_GRP.engine_debug('PBH Value From : ' || pbh_child_rec.value_from);
        QP_PREQ_GRP.engine_debug('PBH Value To : ' || pbh_child_rec.value_to);
        QP_PREQ_GRP.engine_debug('PBH Break Type : ' || p_break_type);

      END IF;

      IF (p_break_type = QP_PREQ_GRP.G_POINT_BREAK) THEN

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Before PBH List Line Type : ' || pbh_child_rec.related_list_line_type);
        END IF;
        -- rewritten for 4061138
        IF ((l_continuous_flag <> 'Y' AND
             pbh_child_rec.qualifier_value BETWEEN pbh_child_rec.value_from AND pbh_child_rec.value_to)
            OR
            (l_continuous_flag = 'Y' AND
             pbh_child_rec.value_from < pbh_child_rec.qualifier_value AND
             pbh_child_rec.qualifier_value <= pbh_child_rec.value_to) )
          THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('In PBH List Line Type : ' || pbh_child_rec.related_list_line_type);

          END IF;
          IF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
            l_sign := 1;
          ELSIF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN
            l_sign :=  - 1;
          END IF;

          IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN
            l_sign := 1; -- new price discount/surcharge are the same
          END IF;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('l sign: '|| l_sign);

          END IF;
          Calculate_Adjustment(p_list_price,
                               pbh_child_rec.operand_calculation_code,
                               pbh_child_rec.operand * l_sign,
                               p_request_qty,
                               l_adjustment_amount,
                               l_return_status,
                               l_return_status_text);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('PBH Adjustment : ' || l_adjustment_amount);

          END IF;
          pbh_adjustments(i).l_adjustment_amount := l_adjustment_amount;
          pbh_adjustments(i).l_satisfied_value := pbh_child_rec.qualifier_value;

          x_adjustment_amount := l_adjustment_amount;
        ELSE
          pbh_adjustments(i).l_adjustment_amount := NULL;
          pbh_adjustments(i).l_satisfied_value := 0;
        END IF;

        pbh_adjustments(i).l_related_list_line_id := pbh_child_rec.related_list_line_id;
        pbh_adjustments(i).l_related_line_detail_index := pbh_child_rec.related_line_detail_index;

      ELSIF (p_break_type = QP_PREQ_GRP.G_RANGE_BREAK) THEN

        IF (l_qualifier_value = 0) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Range Break');
          END IF;
          l_qualifier_value := pbh_child_rec.qualifier_value;
          l_total_value := pbh_child_rec.qualifier_value;
        END IF;

        IF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_DISCOUNT) THEN
          l_sign := 1;
        ELSIF (pbh_child_rec.related_list_line_type = QP_PREQ_GRP.G_SURCHARGE) THEN
          l_sign :=  - 1;
        END IF;

        IF (pbh_child_rec.operand_calculation_code = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN
          l_sign := 1; -- new price discount/surcharge are the same
        END IF;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('l sign: '|| l_sign);

        END IF;
        -- 3943868: was passing p_list_line_id instead of pbh_child_rec.list_line_id
        Get_Satisfied_Range(pbh_child_rec.value_from, pbh_child_rec.value_to,
                            l_total_value, pbh_child_rec.list_line_id, l_continuous_flag, 'N', l_satisfied_value);
        pbh_adjustments(i).l_satisfied_value := l_satisfied_value;

        --If operator is lumpsum and l_satisfied_value is zero do not calculate
        IF l_satisfied_value = 0
          THEN
          l_adjustment_amount := NULL;
        ELSE
          Calculate_Adjustment(p_list_price,
                               pbh_child_rec.operand_calculation_code,
                               pbh_child_rec.operand * l_sign,
                               pbh_adjustments(i).l_satisfied_value,
                               --l_total_value,
                               l_adjustment_amount,
                               l_return_status,
                               l_return_status_text);
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        pbh_adjustments(i).l_related_list_line_id := pbh_child_rec.related_list_line_id;
        pbh_adjustments(i).l_related_line_detail_index := pbh_child_rec.related_line_detail_index;
        pbh_adjustments(i).l_adjustment_amount := l_adjustment_amount;

        --IF (l_total_value > 0) THEN
        --l_total_value := l_total_value - l_satisfied_value;  -- this is correct to be commented out

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Adjustment : (' || i || ') ' || l_adjustment_amount);
          QP_PREQ_GRP.engine_debug('Satisfied Value : (' || i || ') ' || l_satisfied_value);
          QP_PREQ_GRP.engine_debug('Total Value : (' || i || ') ' || l_total_value);
        END IF;
        --ELSE
        -- pbh_adjustments(i).l_satisfied_value  := 0;
        --END IF;

      END IF;

    END LOOP;

    CLOSE get_price_break_details;

    IF (p_break_type = QP_PREQ_GRP.G_RANGE_BREAK) THEN
      FOR i IN 1 .. pbh_adjustments.COUNT
        LOOP
        l_range_adjustment := l_range_adjustment + nvl(pbh_adjustments(i).l_adjustment_amount * pbh_adjustments(i).l_satisfied_value, 0);
      END LOOP;
      x_adjustment_amount := l_range_adjustment / l_qualifier_value;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Averaged Adjustment : ' || x_adjustment_amount);

      END IF;
    END IF;

    -- Update the adjustments/satisfied ranges info on line details
    IF (QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = QP_PREQ_GRP.G_YES) THEN
      IF (pbh_adjustments.COUNT > 0) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('updating child pbh lines '
                                   || pbh_adjustments.COUNT);
        END IF;
        FOR i IN pbh_adjustments.FIRST .. pbh_adjustments.LAST LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('child dtl adj amt '
                                     || pbh_adjustments(i).l_adjustment_amount
                                     ||' qty '|| pbh_adjustments(i).l_satisfied_value
                                     ||' dtl index '|| pbh_adjustments(i).l_related_line_detail_index);
          END IF;
          UPDATE qp_npreq_ldets_tmp
               --changes for bug 2264566 update adjamt on child lines of manualpbh
          SET adjustment_amount =  - (pbh_adjustments(i).l_adjustment_amount),
          --SET adjustment_amount  = l_sign * pbh_adjustments(i).l_adjustment_amount,
              line_quantity = pbh_adjustments(i).l_satisfied_value
          WHERE line_detail_index = pbh_adjustments(i).l_related_line_detail_index
          AND   pricing_status_code IN (QP_PREQ_GRP.G_STATUS_NEW,
                                        --changes for bug 2264566 update adjamt on child lines of manualpbh
                                        QP_PREQ_GRP.G_STATUS_UNCHANGED);
        END LOOP;
      END IF;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.ENGINE_DEBUG('Error in price break calculation: '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_routine ||' '|| SQLERRM;
  END Price_Break_Calculation;

  PROCEDURE GSA_Max_Discount_Check(p_adjusted_unit_price NUMBER,
                                   p_line_index NUMBER,
                                   p_pricing_date DATE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_return_status_txt OUT NOCOPY VARCHAR2) AS

  v_list_line_id NUMBER;
  v_operand NUMBER;
  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.GSA_Max_Discount_Check';
  v_source_system_code VARCHAR2(30);

  GSA_VIOLATION EXCEPTION;

  CURSOR get_source_system_code IS
    SELECT b.SOURCE_SYSTEM_CODE
    FROM  qp_npreq_ldets_tmp a, QP_LIST_HEADERS_B b
    WHERE a.CREATED_FROM_LIST_HEADER_ID = b.LIST_HEADER_ID
    AND   a.LINE_INDEX = p_line_index
    AND   a.CREATED_FROM_LIST_LINE_TYPE = 'PLL'
    AND   a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

  CURSOR get_list_details_cur(p_source_system_code VARCHAR2) IS
    SELECT /*+ ORDERED USE_NL(a b c d e) */ c.LIST_LINE_ID, c.OPERAND
    FROM
     qp_npreq_line_attrs_tmp a, QP_PRICING_ATTRIBUTES b, QP_LIST_LINES c, QP_LIST_HEADERS_B d, QP_QUALIFIERS e
    WHERE  a.LINE_INDEX = p_line_index
    AND    a.CONTEXT = b.PRODUCT_ATTRIBUTE_CONTEXT
    AND    a.ATTRIBUTE = b.PRODUCT_ATTRIBUTE
    AND    a.VALUE_FROM = b.PRODUCT_ATTR_VALUE
    AND    b.PRICING_ATTRIBUTE_CONTEXT IS NULL
    AND    b.LIST_LINE_ID = c.LIST_LINE_ID
    AND    c.ARITHMETIC_OPERATOR = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT
    AND    c.LIST_HEADER_ID = d.LIST_HEADER_ID
    AND    trunc(p_pricing_date) BETWEEN nvl(TRUNC(c.START_DATE_ACTIVE), trunc(p_pricing_date))
                          AND     nvl(TRUNC(c.END_DATE_ACTIVE), trunc(p_pricing_date))
    AND    d.SOURCE_SYSTEM_CODE = p_source_system_code
    AND    d.ACTIVE_FLAG = QP_PREQ_GRP.G_YES
    AND    d.LIST_HEADER_ID = e.LIST_HEADER_ID
    AND    e.QUALIFIER_CONTEXT = QP_PREQ_GRP.G_CUSTOMER_CONTEXT
    AND    e.QUALIFIER_ATTRIBUTE = QP_PREQ_GRP.G_GSA_ATTRIBUTE
    AND    e.QUALIFIER_ATTR_VALUE = QP_PREQ_GRP.G_YES
    ORDER  BY 2;

  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_source_system_code;
    FETCH get_source_system_code INTO v_source_system_code;
    CLOSE get_source_system_code;

    OPEN get_list_details_cur(v_source_system_code);
    FETCH get_list_details_cur INTO v_list_line_id, v_operand;
    CLOSE get_list_details_cur;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug ('GSA List Line : ' || v_list_line_id);
      QP_PREQ_GRP.engine_debug ('GSA Price : ' || v_operand);
      QP_PREQ_GRP.engine_debug('GSA List Line : ' || v_list_line_id);
      QP_PREQ_GRP.engine_debug('GSA Price : ' || v_operand);

    END IF;
    IF (v_operand IS NOT NULL)
      --changes made by spgopal for ASO bug 1898927
      AND (p_adjusted_unit_price <= v_operand)
      THEN
      RAISE GSA_VIOLATION;
    END IF;

  EXCEPTION
    WHEN GSA_VIOLATION THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' GSA Violation. GSA Price: ' || v_operand || 'List Line: ' || v_list_line_id);
      END IF;
      x_return_status := QP_PREQ_GRP.G_STATUS_GSA_VIOLATION;
      x_return_status_txt := v_operand ;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END GSA_Max_Discount_Check;

  PROCEDURE Calculate_Price(p_request_line IN OUT NOCOPY l_request_line_rec,
                            p_request_line_details IN OUT NOCOPY l_request_line_details_tbl,
                            p_related_request_lines IN OUT NOCOPY l_related_request_lines_tbl,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_txt OUT NOCOPY VARCHAR2) AS

  x_related_request_lines_tbl l_related_request_lines_tbl;

  x_pbh_list_price NUMBER;
  x_list_price NUMBER;
  x_adjusted_amount NUMBER;
  x_percent_price NUMBER;
  x_extended_price NUMBER; -- block pricing
  x_discounted_price NUMBER;
  x_benefit_line_qty NUMBER;

  --v_request_line_rec            l_request_line_rec;
  --v_request_line_details_tbl    l_request_line_details_tbl;
  --v_related_request_lines       l_related_request_lines_tbl;
  v_list_line_id NUMBER;
  v_list_line_index NUMBER;
  v_ord_qty NUMBER;
  v_discounted_price NUMBER;
  v_old_pricing_sequence NUMBER;
  v_list_price NUMBER;
  v_total_adj_amt NUMBER;
  v_operand_calc_code VARCHAR2(30);
  v_operand_value NUMBER;
  v_related_item_price NUMBER := 0;
  v_index NUMBER := 0;
  v_orig_list_price NUMBER;
  v_service_duration NUMBER;
  v_actual_line_qty NUMBER; -- begin 2388011, grp_lines_pbh,
  v_bucketed_value NUMBER := NULL; -- IT bucket
  v_bucketed_qty NUMBER := NULL; -- IT bucket
  v_total_value NUMBER; -- end 2388011, LINEGROUP PBH
  x_ret_status VARCHAR2(30);
  x_ret_status_txt VARCHAR2(240);

  v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Calculate_Price_PUB.Calculate_Price';
  --v_round_individual_adj_flag varchar2(3); --shu
  v_price_round_options VARCHAR2(30) := FND_PROFILE.VALUE('QP_SELLING_PRICE_ROUNDING_OPTIONS'); --shu, new rounding

  BEGIN
    -- Get the records from the l_request_line_details_tbl in the order
    --of pricing sequence(this cannot be done
    -- using PL/SQL table. I am assuming that I would get the records in ordered sequence

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug ('In Procedure Calculate_Price...'); -- shu, aso rounding, 2457629
      QP_PREQ_GRP.engine_debug ('selling price rounding options : ' || v_price_round_options); -- shu
      QP_PREQ_GRP.engine_debug ('Rounding Flag  : ' || QP_PREQ_GRP.G_ROUNDING_FLAG); -- aso rounding, 2457629
      QP_PREQ_GRP.engine_debug ('Rounding Factor  : ' || p_request_line.rounding_factor);
    END IF;

    IF (p_request_line.rounding_flag = 'Y' AND p_request_line.rounding_factor IS NULL) THEN -- shu
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('WARNING: rounding_flag is Y, but rounding_factor is NULL!!!');
      END IF;
    END IF;

    -- For accum range break
    l_line_index := p_request_line.line_index;

    -- Loop through the p_request_line_details

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('The request line tables count is: ' || p_request_line_details.COUNT);
    END IF;

    v_index := p_request_line_details.FIRST;
    WHILE (v_index IS NOT NULL )
      LOOP

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('LOOPing through p_request_line_details........');
        QP_PREQ_GRP.engine_debug('The request line index is: ' || v_index);
        QP_PREQ_GRP.engine_debug('PBH Type123:' || p_request_line_details(v_index).CREATED_FROM_LIST_TYPE);
      END IF;

      -- Store the ordered qty
      v_ord_qty := nvl(p_request_line_details(v_index).line_quantity, 0); -- 2388011_latest

      -- begin 2388011
      -- Store the total group amount , applicable for LINEGROUP PBH Ravi Change
      --[julin/5158413] defaulting to -1 (instead of 0) to distinguish null qual value from 0 qual value
      --v_total_value := nvl(p_request_line_details(v_index).qualifier_value,  - 1); -- 2388011_latest
      v_total_value := nvl(p_request_line_details(v_index).qualifier_value,  0); --6896139 undoing changes done as part of bug 5158413

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('ldets.qualifier_value, (v_ord_qty) : ' || v_ord_qty);
        QP_PREQ_GRP.engine_debug('ldets.line_quqntity, (v_total_value) : ' || v_total_value);
        -- If bucketed net amount flag is set to 'Y'
        QP_PREQ_GRP.engine_debug('Bucketed Old PGS  : ' || v_old_pricing_sequence);
        QP_PREQ_GRP.engine_debug('Bucketed New PGS  : ' || p_request_line_details(v_index).PRICING_GROUP_SEQUENCE);
      END IF; -- END IF l_debug = FND_API.G_TRUE

      IF (nvl(v_old_pricing_sequence, - 9999) <> p_request_line_details(v_index).PRICING_GROUP_SEQUENCE AND
          p_request_line_details(v_index).bucketed_flag = 'Y') THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Before Bucketed Group Amount : ' || v_bucketed_value);
          QP_PREQ_GRP.engine_debug('Before Bucketed Line Amount : ' || v_bucketed_qty);
          QP_PREQ_GRP.engine_debug('Bucket Adjustment Amount: ' || nvl(v_total_adj_amt, 0));
        END IF; -- END IF l_debug = FND_API.G_TRUE

        IF (v_total_value > 0) THEN
          v_bucketed_value := v_total_value + nvl(v_total_adj_amt * v_actual_line_qty, 0); -- Net Group Amount
          v_bucketed_qty := NULL;
        ELSE -- Only needed when group amount is not passed
          v_bucketed_qty := v_ord_qty + nvl(v_total_adj_amt * v_actual_line_qty, 0); -- Net Item Amount
          v_bucketed_value := NULL;
        END IF; -- END IF (v_total_value > 0)

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Net Bucketed Group Amount : ' || v_bucketed_value);
          QP_PREQ_GRP.engine_debug('Net Bucketed Line Amount : ' || v_bucketed_qty);
        END IF; -- END IF l_debug = FND_API.G_TRUE
      END IF; -- END IF (nvl(v_old_pricing_sequence,-9999)

      -- end fix 2388011, grp_lines_pbh, IT bucket

      IF (v_ord_qty = 0) THEN
        v_ord_qty := nvl(p_request_line.qualifier_value, 0);
      END IF;

      -- fix 2388011, grp_lines_pbh
      -- Actual quantity on the order line
      v_actual_line_qty := nvl(p_request_line.qualifier_value, 0);

      -- Store the related item price
      v_related_item_price := p_request_line.RELATED_ITEM_PRICE;
      v_service_duration := nvl(p_request_line.SERVICE_DURATION, 1);

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Service Duration : ' || v_service_duration);

      END IF;

      -- Store the list line id
      v_list_line_index := p_request_line_details(v_index).LINE_DETAIL_INDEX;

      -- Store the operand calc code for the PBH line
      v_operand_calc_code := p_request_line_details(v_index).operand_calculation_code;

      -- Calculate List Price for Pricing Sequence 0 for a PBH line
      -- Process PBH for Getting List Price(if exists)

      -- Null Bucket
      IF (p_request_line_details(v_index).PRICING_GROUP_SEQUENCE IS NULL) THEN
        v_orig_list_price := p_request_line.UNIT_PRICE;
      ELSE
        IF (v_list_price IS NULL) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug ('V_List_Price is null');
          END IF;
          v_list_price := p_request_line.UNIT_PRICE;

          IF nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y') = QP_PREQ_GRP.G_YES AND -- shu, aso debug 2457629
            p_request_line.ROUNDING_FACTOR IS NOT NULL THEN
            v_list_price := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));
            p_request_line.UNIT_PRICE := v_list_price;
          ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check v_selling_price_rounding_options profile

            IF (v_price_round_options = G_ROUND_ADJ AND p_request_line.ROUNDING_FACTOR IS NOT NULL) THEN
              v_list_price := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));
              p_request_line.UNIT_PRICE := v_list_price;
            END IF;
          END IF; -- end IF  nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y')
          v_discounted_price := nvl(p_request_line.ADJUSTED_UNIT_PRICE, v_list_price);

        END IF; -- END IF (v_list_price IS NULL)
        v_orig_list_price := v_list_price;
      END IF; -- END IF (p_request_line_details(v_index).PRICING_GROUP_SEQUENCE IS NULL)

      IF (p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE =
          QP_PREQ_GRP.G_PRICE_BREAK_TYPE) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('PBH Type:' || p_request_line_details(v_index).CREATED_FROM_LIST_TYPE);
          QP_PREQ_GRP.engine_debug('PBH Unit Price:' || p_request_line.UNIT_PRICE);
          QP_PREQ_GRP.engine_debug('Old PGS:' || v_old_pricing_sequence);
        END IF;

        -- 2388011, pbh_grp_amt
        Process_Price_Break(
                            p_request_line_details(v_index).created_from_list_line_id,  -- PBH list line ID, for accum range break
                            v_list_line_index,  -- PBH Line Id
                            v_operand_calc_code,  -- PBH Line arithmetic operator
                            v_ord_qty,  -- 2388011_new
                            v_actual_line_qty,  -- 2388011,
                            p_request_line_details(v_index).CREATED_FROM_LIST_TYPE,  -- Prc/Dis Break
                            nvl(v_orig_list_price, p_request_line.UNIT_PRICE),  -- Unit Price(for discount break)
                            nvl(v_discounted_price, p_request_line.UNIT_PRICE),
                            v_old_pricing_sequence,
                            v_related_item_price,  -- Related Item Price
                            v_service_duration,  -- Service Duration for service line pricing
                            p_related_request_lines,  -- Children of PBH Lines
                            nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y'), -- shu, aso debug 2457629
                            ( - 1) * p_request_line.ROUNDING_FACTOR,
                            nvl(v_bucketed_value, v_total_value),  -- 2388011, PBH LINEGROUP Ravi Change
                            x_pbh_list_price,  -- List Price for the Request Line
                            x_extended_price,  -- block pricing
                            x_adjusted_amount,  -- Adjustment Amount for the PBH Line
                            x_related_request_lines_tbl,  -- Related Request Lines Detail Table
                            x_ret_status,
                            x_ret_status_txt);
        v_old_pricing_sequence := p_request_line_details(v_index).PRICING_GROUP_SEQUENCE;

        IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (p_request_line_details(v_index).CREATED_FROM_LIST_TYPE IN
                                 (QP_PREQ_GRP.G_PRICE_LIST_HEADER, QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN

          -- Update the list price on the p_request_line_details structure for the PBH line
          p_request_line.UNIT_PRICE := x_pbh_list_price;
          p_request_line.EXTENDED_PRICE := x_extended_price; -- block pricing
          p_request_line_details(v_index).ADJUSTMENT_AMOUNT := nvl(x_pbh_list_price, 0);
          p_request_line_details(v_index).LINE_QUANTITY := v_ord_qty;
          -- Init the price list values for input to the Calculate_Adjusted_Price function
          v_list_price := x_pbh_list_price;
          v_discounted_price := x_pbh_list_price;
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Unit Price:' || x_pbh_list_price);
            QP_PREQ_GRP.engine_debug('Extended Price on the Line: ' || p_request_line.EXTENDED_PRICE);
            QP_PREQ_GRP.engine_debug('Related Request Lines Table Count:'|| x_related_request_lines_tbl.COUNT);
          END IF;
        ELSE
          -- Update the adjustment amount on the p_request_line_details
          p_request_line_details(v_index).ADJUSTMENT_AMOUNT := nvl(x_adjusted_amount, 0);
          p_request_line_details(v_index).LINE_QUANTITY := v_ord_qty;
          -- Update the adjusted unit price
          -- Total Adjusted amount is not calculated on Freight Charges and manual price breaks which will have
          -- automatic_flag = 'N'

          IF (p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE <> QP_PREQ_GRP.G_FREIGHT_CHARGE AND
              p_request_line_details(v_index).AUTOMATIC_FLAG <> QP_PREQ_GRP.G_NO) THEN
            IF (nvl(p_request_line_details(v_index).ACCRUAL_FLAG, QP_PREQ_GRP.G_NO) <> QP_PREQ_GRP.G_YES) THEN
              v_total_adj_amt := nvl(v_total_adj_amt, 0) + nvl(x_adjusted_amount, 0);
            END IF;
            p_request_line.ADJUSTED_UNIT_PRICE := p_request_line.UNIT_PRICE + nvl(v_total_adj_amt, 0);
          END IF;
          v_discounted_price := p_request_line.ADJUSTED_UNIT_PRICE;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Adjusted Amount:' || x_adjusted_amount);
            QP_PREQ_GRP.engine_debug('Unit Price:' || p_request_line.UNIT_PRICE );
            QP_PREQ_GRP.engine_debug('Adjusted Unit Price:' || v_discounted_price);
          END IF;

        END IF; -- END IF (p_request_line_details(v_index).CREATED_FROM_LIST_TYPE...

        -- Update the passed in p_related_request_lines with new structure, which has the
        -- LIST_QTY and LIST_PRICE
        -- and SELLING PRICE for each PBH Line
        p_related_request_lines := x_related_request_lines_tbl;
      END IF;

      -- Calculate List Price for Pricing Sequence 0 for a PLL Line
      --IF (p_request_line_details(v_index).CREATED_FROM_LIST_TYPE in
      --	(QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)) THEN
      IF (p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_PRICE_LIST_TYPE) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('I am in PLL');
        END IF;
        Calculate_List_Price_PVT(p_request_line_details(v_index).OPERAND_CALCULATION_CODE,
                                 p_request_line_details(v_index).OPERAND_VALUE,
                                 0,  -- block pricing
                                 v_ord_qty,
                                 v_related_item_price,
                                 v_service_duration,
                                 --nvl(p_request_line.ROUNDING_FLAG,'Y'),
                                 nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y'),  -- shu, aso debug 2457629
                                 ( - 1) * p_request_line.ROUNDING_FACTOR,
                                 x_list_price,
                                 x_percent_price,
                                 x_extended_price,  -- block pricing
                                 x_ret_status,
                                 x_ret_status_txt);
        IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_request_line.UNIT_PRICE := x_list_price;
        p_request_line.PERCENT_PRICE := x_percent_price;
        p_request_line_details(v_index).ADJUSTMENT_AMOUNT := nvl(x_list_price, 0);
        p_request_line_details(v_index).LINE_QUANTITY := v_ord_qty;

        -- Init the price list values for input to the Calculate_Adjusted_Price function
        v_list_price := x_list_price;
        v_discounted_price := x_list_price;
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('The List Price23 is: ' || v_list_price);

        END IF;
      END IF;

      -- Set the list price and discounted price if they are null
      -- This can be the case if pll lines are not passed
      -- nvl , if the caller wants the adjustments to be applied to an already
      -- discounted line
      IF (v_list_price IS NULL) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug ('V_List_Price is null');
        END IF;
        v_list_price := p_request_line.UNIT_PRICE;

        IF nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y') = QP_PREQ_GRP.G_YES AND -- shu, aso debug 2457629
          p_request_line.ROUNDING_FACTOR IS NOT NULL THEN
          v_list_price := ROUND(p_request_line.UNIT_PRICE, p_request_line.ROUNDING_FACTOR * ( - 1));
          p_request_line.UNIT_PRICE := v_list_price;
          -- shu, aso debug 2457629
        ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- shu, check v_selling_price_rounding_options profile
          IF (v_price_round_options = G_ROUND_ADJ AND p_request_line.ROUNDING_FACTOR IS NOT NULL) THEN
            v_list_price := ROUND(p_request_line.UNIT_PRICE, p_request_line.ROUNDING_FACTOR * ( - 1));
            p_request_line.UNIT_PRICE := v_list_price;
          END IF;

        END IF;
        v_discounted_price := nvl(p_request_line.ADJUSTED_UNIT_PRICE, v_list_price);
      END IF;

      -- Calculate Adjusted Price
      IF (p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE
          IN (QP_PREQ_GRP.G_DISCOUNT, QP_PREQ_GRP.G_SURCHARGE, QP_PREQ_GRP.G_FREIGHT_CHARGE)) THEN
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('I am in DIS');
          QP_PREQ_GRP.engine_debug('The List Price is: ' || v_list_price);
          QP_PREQ_GRP.engine_debug('The Discounted Price is: ' || v_discounted_price);
          QP_PREQ_GRP.engine_debug('Old Pricing Seq: ' || v_old_pricing_sequence);
          QP_PREQ_GRP.engine_debug('New Pricing Seq: ' || p_request_line_details(v_index).PRICING_GROUP_SEQUENCE);
          QP_PREQ_GRP.engine_debug('Operand Calc Code: ' || p_request_line_details(v_index).OPERAND_CALCULATION_CODE);
          QP_PREQ_GRP.engine_debug('Operand Calc Value: ' || p_request_line_details(v_index).OPERAND_VALUE);
          QP_PREQ_GRP.engine_debug('List Line Type: ' || p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE);

        END IF;

/* [julin/5529345] recurring logic moved to QP_PREQ_GRP.PRICE_REQUEST
        -- Recurring flag check
        IF (p_request_line_details(v_index).PRICE_BREAK_TYPE_CODE = QP_PREQ_GRP.G_RECURRING_BREAK AND
            QP_PREQ_GRP.G_LIMITS_CODE_EXECUTED = QP_PREQ_GRP.G_NO) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('In Recurring Routine --- #1');
            QP_PREQ_GRP.engine_debug('List Line Id: ' || p_request_line_details(v_index).CREATED_FROM_LIST_LINE_ID );
            QP_PREQ_GRP.engine_debug('List Line Index: ' || p_request_line.LINE_INDEX );
          END IF;
          -- Call Recurring Routine
          QP_Process_Other_Benefits_PVT.Calculate_Recurring_Quantity(
                                                                     p_request_line_details(v_index).CREATED_FROM_LIST_LINE_ID,
                                                                     p_request_line_details(v_index).CREATED_FROM_LIST_HEADER_ID,
                                                                     p_request_line.LINE_INDEX,
                                                                     NULL,
                                                                     x_benefit_line_qty,
                                                                     x_ret_status,
                                                                     x_ret_status_txt);
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Return Status Text : ' || x_ret_status_txt);

          END IF;
          IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          p_request_line_details(v_index).OPERAND_VALUE := x_benefit_line_qty;

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Limits Code Not Executed.Did call Recurring Qty Routine');
            QP_PREQ_GRP.engine_debug('After Recurring Routine Value --- #2 : ' || x_benefit_line_qty);

          END IF;
        END IF;

        IF (p_request_line_details(v_index).PRICE_BREAK_TYPE_CODE = QP_PREQ_GRP.G_RECURRING_BREAK AND
            QP_PREQ_GRP.G_LIMITS_CODE_EXECUTED = QP_PREQ_GRP.G_YES) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Limits Code Executed.Do not calculate OPERAND value 2nd time.');
            QP_PREQ_GRP.engine_debug('List Line Id: ' || p_request_line_details(v_index).CREATED_FROM_LIST_LINE_ID );
            QP_PREQ_GRP.engine_debug('List Line Index: ' || p_request_line.LINE_INDEX );
            QP_PREQ_GRP.engine_debug('Recurring Value: ' || p_request_line_details(v_index).OPERAND_VALUE );
          END IF;
        END IF;
*/

        IF (nvl(p_request_line_details(v_index).ACCRUAL_FLAG, QP_PREQ_GRP.G_NO) = QP_PREQ_GRP.G_YES) THEN
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('OPERAND_CALCULATION_CODE is ' || p_request_line_details(v_index).OPERAND_CALCULATION_CODE);
            QP_PREQ_GRP.engine_debug('v_ord_qty is ' || v_ord_qty);
          END IF;
          -- bug 4002891 - benefit_qty should be multiplied by ordered_qty for application_method other than LUMPSUM
          IF p_request_line_details(v_index).OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT THEN
            p_request_line_details(v_index).BENEFIT_QTY :=
            p_request_line_details(v_index).OPERAND_VALUE *
            1 / nvl(p_request_line_details(v_index).ACCRUAL_CONVERSION_RATE, 1) *
            nvl(p_request_line_details(v_index).ESTIM_ACCRUAL_RATE, 100) / 100;
          ELSE
            p_request_line_details(v_index).BENEFIT_QTY :=
            (p_request_line_details(v_index).OPERAND_VALUE *
             1 / nvl(p_request_line_details(v_index).ACCRUAL_CONVERSION_RATE, 1) *
             nvl(p_request_line_details(v_index).ESTIM_ACCRUAL_RATE, 100) / 100) * v_ord_qty;
          END IF;
        END IF;

        --4900095
        --calculate lumpsum qty for svc lines
        IF p_request_line_details(v_index).modifier_level_code
          IN (QP_PREQ_GRP.G_LINE_LEVEL
              , QP_PREQ_GRP.G_LINE_GROUP)
          AND p_request_line_details(v_index).operand_calculation_code
          = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT THEN
          --G_Lumpsum_qty will be not null only for service items
          --when uom_quantity is passed as null,
          -- and contract_start/end_dates are passed
          --and for a line/linegroup lumpsum DIS/PBH/SUR/FREIGHT
          G_Lumpsum_qty := Get_lumpsum_qty(l_line_index,
                                           p_request_line_details(v_index).line_detail_index,
                                           p_request_line_details(v_index).modifier_level_code);
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Lumpsum_qty '
                                     || G_Lumpsum_qty);
          END IF;
        END IF; --p_request_line_details(v_index).modifier_level_code

        Calculate_Adjusted_Price(p_list_price => v_orig_list_price,
                                 p_discounted_price => v_discounted_price,  -- Discounted Price
                                 p_old_pricing_sequence => nvl(v_old_pricing_sequence,
                                                               p_request_line_details(v_index).PRICING_GROUP_SEQUENCE),
                                 p_new_pricing_sequence => p_request_line_details(v_index).PRICING_GROUP_SEQUENCE,
                                 p_operand_calc_code => p_request_line_details(v_index).OPERAND_CALCULATION_CODE,
                                 p_operand_value => p_request_line_details(v_index).OPERAND_VALUE,
                                 p_list_line_type => p_request_line_details(v_index).CREATED_FROM_LIST_LINE_TYPE,
                                 p_request_qty => v_ord_qty,
                                 p_accrual_flag => p_request_line_details(v_index).ACCRUAL_FLAG,
                                 --p_rounding_flag	     => nvl(p_request_line.ROUNDING_FLAG,'Y'),
                                 p_rounding_flag => nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, 'Y'),  -- shu, aso debug 2457629
                                 p_rounding_factor => ( - 1) * p_request_line.ROUNDING_FACTOR,
                                 p_orig_unit_price => p_request_line.UNIT_PRICE,
                                 x_discounted_price => x_discounted_price,  -- Output Discounted Price
                                 x_adjusted_amount => x_adjusted_amount,
                                 x_list_price => x_list_price, -- Output List Price
                                 x_return_status => x_ret_status,
                                 x_return_status_txt => x_ret_status_txt);

        IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        v_old_pricing_sequence := p_request_line_details(v_index).PRICING_GROUP_SEQUENCE;
        v_discounted_price := x_discounted_price;
        v_list_price := x_List_price;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('Adjusted Amount: ' || x_adjusted_amount);

        END IF;
        -- Update the adjusted amount on the request line
        p_request_line_details(v_index).ADJUSTMENT_AMOUNT := nvl(x_adjusted_amount, 0);
        p_request_line_details(v_index).LINE_QUANTITY := v_ord_qty;

        -- Update the adjusted unit price(the adjusted_unit_price gets updated for
        -- every dis/sur line,which
        -- is same as updating once, because the adjusted_unit_price value gets overwritten
        -- Total Adjustment amount is not calculated for freight charges

        IF (p_request_line_details(v_index).CREATED_FROM_LIST_TYPE <>
            QP_PREQ_GRP.G_CHARGES_HEADER) THEN
          IF (nvl(p_request_line_details(v_index).ACCRUAL_FLAG, QP_PREQ_GRP.G_NO) <> QP_PREQ_GRP.G_YES AND
              p_request_line_details(v_index).AUTOMATIC_FLAG <> QP_PREQ_GRP.G_NO) THEN
            v_total_adj_amt := nvl(v_total_adj_amt, 0) + nvl(x_adjusted_amount, 0);
          END IF;
          --[prarasto:Post Round]removed rounding of unit selling price, the unrounded value will be
          --sent from calculation engine and it will be rounded in QP_PREQ_GRP.Call_Calculation_Engine
          /*

		        -- DO UNIT SELLING PRICE ROUNDING HERE, shu

			--IF (( nvl(p_request_line.rounding_flag, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES OR p_request_line.rounding_flag = G_CHAR_U) and p_request_line.rounding_factor IS NOT NULL) THEN -- shu
			IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG,'Y')='Y' OR QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_U) and p_request_line.rounding_factor IS NOT NULL THEN-- aso rounding, 2457629, shu
		      		p_request_line.ADJUSTED_UNIT_PRICE := ROUND ((p_request_line.UNIT_PRICE + nvl(v_total_adj_amt,0)), (-1) * p_request_line.rounding_factor);
		      	ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- check qp_selling_price_rounding_options profile -- shu, new rounding
		      		IF ((v_price_round_options = G_ROUND_ADJ OR v_price_round_options = G_NO_ROUND_ADJ) AND p_request_line.rounding_factor IS NOT NULL) THEN -- do not round if profile is null
					p_request_line.ADJUSTED_UNIT_PRICE := ROUND ((p_request_line.UNIT_PRICE + nvl(v_total_adj_amt,0)), (-1) * p_request_line.rounding_factor);
				ELSE -- NO_ROUND
					p_request_line.ADJUSTED_UNIT_PRICE := p_request_line.UNIT_PRICE + nvl(v_total_adj_amt,0);
				END IF;

		      	ELSE -- rounding_flag is 'N'
		      		p_request_line.ADJUSTED_UNIT_PRICE := p_request_line.UNIT_PRICE + nvl(v_total_adj_amt,0);
		      	END IF; -- end rounding
		      	-- end shu fix
*/
          p_request_line.ADJUSTED_UNIT_PRICE := p_request_line.UNIT_PRICE + nvl(v_total_adj_amt, 0);
          --[prarasto:Post Round] End post round fix

        END IF;

        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('The Adjusted Amount is: ' || v_total_adj_amt);
          QP_PREQ_GRP.engine_debug('The Unit Price: ' || p_request_line.UNIT_PRICE );
          QP_PREQ_GRP.engine_debug('The Adjusted Price: ' || p_request_line.ADJUSTED_UNIT_PRICE );

        END IF;
      END IF;
      EXIT WHEN v_index = p_request_line_details.LAST;
      v_index := p_request_line_details.NEXT(v_index);
    END LOOP;

    -- If price list is not passed , round the unit price and adjusted unit price
    IF (v_list_price IS NULL) THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('V_List_Price is null');
      END IF;
      v_list_price := p_request_line.UNIT_PRICE ;
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('List Price after rounding: ' || v_list_price);
      END IF;

      -- shu new rounding
      IF (nvl(QP_PREQ_GRP.G_ROUNDING_FLAG, QP_PREQ_GRP.G_YES) = QP_PREQ_GRP.G_YES -- aso rounding, shu, 2457629
          AND p_request_line.rounding_factor IS NOT NULL) THEN -- shu new rounding

        p_request_line.UNIT_PRICE := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));
        v_list_price := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));

      ELSIF (QP_PREQ_GRP.G_ROUNDING_FLAG = G_CHAR_Q) THEN -- aso rounding, shu, 2457629
        -- no round if rounding_flag is Q bug QP profile is null
        IF v_price_round_options = G_ROUND_ADJ AND p_request_line.rounding_factor IS NOT NULL THEN -- bug 2415571
          p_request_line.UNIT_PRICE := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));
          v_list_price := ROUND(v_list_price, p_request_line.ROUNDING_FACTOR * ( - 1));
        END IF;

      END IF;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug ('List Price after rounding1: ' || p_request_line.UNIT_PRICE);
        QP_PREQ_GRP.engine_debug ('List Price after rounding2: ' || v_list_price);
      END IF;
      v_discounted_price := nvl(p_request_line.ADJUSTED_UNIT_PRICE, v_list_price);
    END IF;

    -- Call GSA Check only for non-gsa customers(where GSA_QUALIFIER_FLAG IS NULL)
    IF (p_request_line.GSA_QUALIFIER_FLAG IS NULL AND nvl(QP_PREQ_GRP.G_GSA_CHECK_FLAG, 'Y') = QP_PREQ_GRP.G_YES AND
        p_request_line.GSA_ENABLED_FLAG = QP_PREQ_GRP.G_YES AND
        QP_PREQ_GRP.G_GSA_DUP_CHECK_FLAG = QP_PREQ_GRP.G_YES ) THEN
      GSA_Max_Discount_Check(p_request_line.ADJUSTED_UNIT_PRICE,
                             p_request_line.LINE_INDEX,
                             p_request_line.PRICING_EFFECTIVE_DATE,
                             x_ret_status,
                             x_ret_status_txt);
      IF(x_ret_status = QP_PREQ_GRP.G_STATUS_GSA_VIOLATION) THEN
        x_return_status := QP_PREQ_GRP.G_STATUS_GSA_VIOLATION;
        x_return_status_txt := x_ret_status_txt;
      END IF;
    END IF;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug ('Before Update List Price after rounding1: ' || p_request_line.UNIT_PRICE);

    END IF;
    -- Populate the Output records
    --p_request_line := p_request_line;
    --p_request_line_details := p_request_line_details;
    --p_related_request_lines := p_related_request_lines;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || x_ret_status_txt);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || x_ret_status_txt;
    WHEN OTHERS THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_txt := v_routine_name || ' ' || SQLERRM;

  END Calculate_Price;

END QP_Calculate_Price_PUB;

/
